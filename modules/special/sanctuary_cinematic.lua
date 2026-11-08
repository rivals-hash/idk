--[[
    Darling Hub - The Aureate Sanctuary Cinematic Module (Version 1.3)
]]

local SanctuaryCinematic = {}
local activeApi = nil

local function runSanctuaryCinematic(onComplete)
-- DARLING / THE AUREATE SANCTUARY 3.0 / 20 seconds / complete launcher.
-- Paste this WHOLE file into Delta instead of the original one-line loader.
-- Skip or the end restores the game and opens the original Darling Hub once.
local CONFIG = {
    Duration = 20,
    OpenHub = false,
    HubURL = "https://raw.githubusercontent.com/rivals-hash/idk/main/main.lua",
    Quality = "High", -- "Low" reduces background VFX, preserving the models.
    Audio = true,
}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
if not player then error("Darling Intro must run on the Roblox client.", 0) end
local env = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then env = result end
end
local previous = env.DarlingIntro
if type(previous) == "table" and type(previous.Stop) == "function" then previous.Stop() end
for _, key in ipairs({"DarlingWorldbreaker", "DarlingSovereign"}) do
    local cinematic = env[key] or _G[key]
    if type(cinematic) == "table" and type(cinematic.Stop) == "function" then pcall(cinematic.Stop) end
end
local api = {Version = 3, Status = "building", IsPlaying = true}
env.DarlingIntro = api
local V, C = Vector3.new, CFrame.new
local LIGHT = Color3.fromRGB(157, 224, 255)
local HOT = Color3.fromRGB(255, 247, 218)
local GOLD = Color3.fromRGB(231, 184, 87)
local STONE = Color3.fromRGB(225, 224, 213)
local SHADOW = Color3.fromRGB(85, 112, 136)
local ORIGIN = V(0, 60000, 0)
local low = CONFIG.Quality == "Low"
local stopped, hubStarted, bound = false, false, false
local scene, gui, camera, actor, gate, relic, flash, bloom
local connections, hidden, lightingSaved, postSaved = {}, {}, {}, {}
local cameraSaved, humanSaved, environment = {}, {}, {}
local bindName = "DarlingIntro_" .. HttpService:GenerateGUID(false)
local clockStart, count, elapsed = nil, 0, 0
local audio, cues = {}, {}
local TEX = {
    spark = "rbxasset://textures/particles/sparkles_main.dds",
    smoke = "rbxasset://textures/particles/smoke_main.dds",
    fire = "rbxasset://textures/particles/fire_main.dds",
}
local function angle(x, y, z) return CFrame.Angles(math.rad(x), math.rad(y), math.rad(z)) end
local function smooth(x) x = math.clamp(x, 0, 1); return x*x*(3-2*x) end
local function phase(t, a, b) return smooth((t-a)/(b-a)) end
local function mix(a, b, t) return a+(b-a)*t end
local function curve(a,b,c,d,t)
    local u=1-t
    return a*(u*u*u)+b*(3*u*u*t)+c*(3*u*t*t)+d*(t*t*t)
end
local function seq(points)
    local keys = {}
    for _, p in ipairs(points) do keys[#keys+1] = NumberSequenceKeypoint.new(p[1], p[2]) end
    return NumberSequence.new(keys)
end
local function connect(signal, callback)
    local c = signal:Connect(callback); connections[#connections+1] = c; return c
end
local function new(class, props, parent)
    if stopped then error("Darling intro cancelled", 0) end
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        local ok, err = pcall(function() obj[k] = v end)
        if not ok then obj:Destroy(); error(class .. "." .. k .. ": " .. tostring(err), 0) end
    end
    obj.Parent = parent
    count = count+1
    if api.Status == "building" and count%180 == 0 then
        task.wait()
        if stopped then obj:Destroy(); error("Darling intro cancelled", 0) end
    end
    return obj
end
local function loadHub()
    if hubStarted or not CONFIG.OpenHub then return end
    hubStarted = true
    task.spawn(function()
        api.Status = "loading_hub"
        local ok, err = pcall(function()
            local source = game:HttpGet(CONFIG.HubURL)
            if type(source) ~= "string" or #source < 10 then error("Empty hub download") end
            local fn, compileError = loadstring(source)
            if not fn then error(compileError) end
            fn()
        end)
        api.Status = ok and "complete" or "hub_error"
        if not ok then api.LastError = tostring(err); warn("[Darling Hub] " .. tostring(err)) end
    end)
end
local function finish(openHub)
    if stopped then return end
    stopped, api.IsPlaying, api.Status = true, false, "stopped"
    if bound then pcall(function() RunService:UnbindFromRenderStep(bindName) end) end
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    for g, enabled in pairs(hidden) do pcall(function() g.Enabled = enabled end) end
    if humanSaved.humanoid then pcall(function()
        local h = humanSaved.humanoid
        h.WalkSpeed = humanSaved.speed; h.AutoRotate = humanSaved.rotate
        h.JumpPower = humanSaved.jump; h.JumpHeight = humanSaved.height
    end) end
    if cameraSaved.camera then pcall(function()
        local cam = cameraSaved.camera
        cam.CameraType = cameraSaved.kind; cam.CameraSubject = cameraSaved.subject
        cam.CFrame = cameraSaved.frame; cam.Focus = cameraSaved.focus; cam.FieldOfView = cameraSaved.fov
    end) end
    for k, v in pairs(lightingSaved) do pcall(function() Lighting[k] = v end) end
    for obj, props in pairs(postSaved) do
        for k, v in pairs(props) do pcall(function() obj[k] = v end) end
    end
    if scene then scene:Destroy() end
    if gui then gui:Destroy() end
    if bloom then bloom:Destroy() end
    if actor and actor.model then pcall(function() actor.model:Destroy() end) end
    if openHub and CONFIG.OpenHub then loadHub() end
    if onComplete then task.spawn(pcall, onComplete) end
end
api.Stop = function() finish(false) end
api.Skip = function() finish(true) end
local function solid(parent, name, size, frame, color, material, shape)
    local p = new(shape == "Wedge" and "WedgePart" or "Part", {
        Name=name, Size=size, CFrame=frame, Color=color or STONE,
        Material=material or Enum.Material.SmoothPlastic,
        Anchored=true, CanCollide=false, CanTouch=false, CanQuery=false,
        CastShadow=false, TopSurface=Enum.SurfaceType.Smooth, BottomSurface=Enum.SurfaceType.Smooth,
    }, parent)
    if shape == "Sphere" then new("SpecialMesh", {MeshType=Enum.MeshType.Sphere}, p) end
    return p
end
local function triangle(parent, a, b, c, color, thickness, material)
    local ab, ac, bc = b-a, c-a, c-b
    local ab2, ac2, bc2 = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
    if ab2 > ac2 and ab2 > bc2 then c, a = a, c
    elseif ac2 > bc2 and ac2 > ab2 then a, b = b, a end
    ab, ac, bc = b-a, c-a, c-b
    local normal = ac:Cross(ab)
    if normal.Magnitude < .0001 or bc.Magnitude < .0001 then return end
    local right, back = normal.Unit, bc.Unit
    local up = back:Cross(right)
    local h = math.abs(ab:Dot(up))
    local p1 = solid(parent,"SculptedFacet",V(thickness,h,math.max(.01,math.abs(ab:Dot(back)))),
        CFrame.fromMatrix((a+b)*.5,right,up,back),color,material or Enum.Material.Marble,"Wedge")
    local p2 = solid(parent,"SculptedFacet",V(thickness,h,math.max(.01,math.abs(ac:Dot(back)))),
        CFrame.fromMatrix((a+c)*.5,-right,up,-back),color,material or Enum.Material.Marble,"Wedge")
    return {p1, p2}
end
local function model(name, parent)
    local m = new("Model",{Name=name},parent or scene)
    local pivot = solid(m,"Pivot",V(.1,.1,.1),C(),STONE)
    pivot.Transparency=1; m.PrimaryPart=pivot
    return m
end
local function emit(parent, texture, color, size, speed, rate, life)
    return new("ParticleEmitter",{
        Texture=texture, Color=ColorSequence.new(HOT,color), LightEmission=.8, LightInfluence=0,
        Size=seq({{0,0},{.12,size},{.55,size*.7},{1,0}}),
        Transparency=seq({{0,.2},{.4,.35},{1,1}}),
        Lifetime=NumberRange.new(life*.65,life), Speed=NumberRange.new(speed*.4,speed),
        Rate=rate*(low and .5 or 1), SpreadAngle=Vector2.new(130,130),
        Rotation=NumberRange.new(-180,180), RotSpeed=NumberRange.new(-70,70),
        Acceleration=V(0,2,0), Drag=.4, Enabled=false,
    },parent)
end
local function anchor(name, frame, parent)
    local p=solid(parent or scene,name,V(.1,.1,.1),frame,LIGHT)
    p.Transparency=1; return p
end
local function ribbon(parent, a, b, color, width)
    local pa, pb=anchor("EnergyStart",C(a),parent), anchor("EnergyEnd",C(b),parent)
    local aa, ab=new("Attachment",{},pa), new("Attachment",{},pb)
    local beam=new("Beam",{
        Attachment0=aa,Attachment1=ab,FaceCamera=true,Texture=TEX.fire,
        TextureLength=2,TextureSpeed=1.5,LightEmission=1,LightInfluence=0,
        Color=ColorSequence.new(HOT,color),Width0=width,Width1=width*.25,
        Transparency=seq({{0,1},{.15,.3},{.7,.55},{1,1}}),Segments=12,Enabled=false,
    },pa)
    return {a=pa,b=pb,beam=beam}
end
local function bar(parent, name, a, b, width, depth, color, material)
    return solid(parent,name,V(width,depth,(b-a).Magnitude),CFrame.lookAt((a+b)*.5,b),color,material)
end
local function crystal(parent, name, size, cf, color)
    local m=model(name,parent)
    local top,bottom=V(0,size.Y*.5,0),V(0,-size.Y*.5,0)
    local belt={V(size.X*.5,0,0),V(0,0,size.Z*.5),V(-size.X*.5,0,0),V(0,0,-size.Z*.5)}
    for i=1,4 do
        local a,b=belt[i],belt[i%4+1]
        local tint=color:Lerp(HOT,.12+(i%3)*.14)
        local upper=triangle(m,top,a,b,tint,.025,Enum.Material.Glass)
        local lower=triangle(m,bottom,b,a,tint:Lerp(SHADOW,.18),.025,Enum.Material.Glass)
        for _,pair in ipairs({upper,lower}) do
            if pair then for _,piece in ipairs(pair) do piece.Transparency=.1; piece.Reflectance=.22 end end
        end
        bar(m,"FacetGoldEdge",top,a,math.max(.025,size.X*.025),math.max(.025,size.X*.025),GOLD,Enum.Material.Metal)
        bar(m,"FacetGoldEdge",bottom,a,math.max(.025,size.X*.025),math.max(.025,size.X*.025),GOLD,Enum.Material.Metal)
    end
    solid(m,"LuminousCrystalHeart",size*V(.25,.65,.25),C()*angle(0,45,0),HOT,Enum.Material.Neon,"Wedge")
    m:PivotTo(cf)
    return m
end
local function feather(parent, length, width, frame)
    local m=model("SculptedGoldFeather",parent)
    local previous=V()
    for j=1,8 do
        local f=j/8
        local center=V(math.sin(f*math.pi)*width*.13,length*f,-math.sin(f*math.pi)*.17)
        bar(m,"FeatherQuill",previous,center,.055,.055,HOT,Enum.Material.Metal)
        if j<8 then
            local breadth=width*math.sin(f*math.pi)^.7*.5
            for side=-1,1,2 do
                local edge=center+V(side*breadth,-length*.11,.035)
                triangle(m,previous,edge,center,j%2==0 and GOLD or Color3.fromRGB(248,217,146),.018,Enum.Material.Metal)
                bar(m,"FeatherVein",center,edge,.023,.023,Color3.fromRGB(167,118,48),Enum.Material.Metal)
            end
        end
        previous=center
    end
    m:PivotTo(frame)
    return m
end
local function buildGate()
    local g={doors={},dust={},light={},rays={}}
    local architecture=model("AureateSanctuary_Architecture")
    for side=-1,1,2 do
        local x=side*17
        for level=1,4 do
            solid(architecture,"CarvedColumnPlinth",V(7-level*.6,1.1,7-level*.6),C(x,level*.85,0),STONE,Enum.Material.Marble)
            solid(architecture,"PlinthGoldFillet",V(7-level*.6,.08,7-level*.6),C(x,level*.85+.56,0),GOLD,Enum.Material.Metal)
        end
        solid(architecture,"RecessedPillar",V(3.4,35,3.4),C(x,21,0),SHADOW,Enum.Material.Marble)
        for flute=1,12 do
            local a=flute*math.pi/6
            local rod=solid(architecture,"FlutedMarbleShaft",V(34,.7,.7),C(x+math.cos(a)*1.95,21,math.sin(a)*1.95)*angle(0,0,90),STONE,Enum.Material.Marble)
            rod.Shape=Enum.PartType.Cylinder
        end
        for level=1,4 do
            solid(architecture,"Cornice",V(4+level*.85,.6,4+level*.85),C(x,38+level*.65,0),STONE,Enum.Material.Marble)
            solid(architecture,"CorniceGilt",V(4+level*.85,.08,4+level*.85),C(x,38+level*.65+.31,0),GOLD,Enum.Material.Metal)
        end
        for j=1,4 do
            solid(architecture,"Corbel",V(.8,2.4,1.3),C(x+(j-2.5)*1.1,37.6,2.4)*angle(180,0,0),STONE,Enum.Material.Marble,"Wedge")
        end
        crystal(architecture,"CrowningPrism",V(2.1,6.5,2.1),C(x,44,0),LIGHT)
        local door=model("EngravedSanctuaryDoor")
        local mid=-side*6.35
        solid(door,"DoorFrame",V(12.6,36,1.4),C(mid,18,0),GOLD,Enum.Material.Metal)
        solid(door,"IvoryDoorPanel",V(11.7,35,1.5),C(mid,18,.08),STONE,Enum.Material.Marble)
        for edge=-1,1,2 do
            solid(door,"RaisedBorder",V(.22,34.5,.3),C(mid+edge*5.6,18,1),GOLD,Enum.Material.Metal)
            solid(door,"IlluminatedChasing",V(.045,34.2,.045),C(mid+edge*5.6,18,1.2),HOT,Enum.Material.Neon)
        end
        for row=1,3 do
            local y=6+(row-1)*11
            solid(door,"DeepInset",V(9.8,9.5,.2),C(mid,y,.89),SHADOW,Enum.Material.Marble)
            solid(door,"InsetField",V(8.9,8.7,.2),C(mid,y,1.01),Color3.fromRGB(208,215,211),Enum.Material.Marble)
            local points={V(mid,y+3.8,1.2),V(mid+3.6,y,1.2),V(mid,y-3.8,1.2),V(mid-3.6,y,1.2)}
            for k=1,4 do
                bar(door,"DiamondMoulding",points[k],points[k%4+1],.14,.14,GOLD,Enum.Material.Metal)
                triangle(door,V(mid,y,1.8),points[k],points[k%4+1],k%2==0 and STONE or Color3.fromRGB(196,198,187),.04,Enum.Material.Marble)
            end
            crystal(door,"InsetSapphire",V(.85,2.4,.65),C(mid,y,2),LIGHT)
            for j=-1,1,2 do
                for k=1,3 do
                    solid(door,"ChasedLeaf",V(.65,2.1,.15),C(mid+j*(3.3-k*.28),y-3.5+k*.7,1.5)*angle(0,0,-j*38),GOLD,Enum.Material.Metal,"Wedge")
                end
            end
        end
        for y=4,32,7 do
            local pin=solid(door,"DoorHinge",V(2,.9,.9),C(0,y,0)*angle(0,0,90),GOLD,Enum.Material.Metal)
            pin.Shape=Enum.PartType.Cylinder
        end
        g.doors[#g.doors+1]={model=door,side=side}
        local emitterAnchor=anchor("ThresholdDust",C(ORIGIN+V(side*12,8,1)))
        local e=emit(emitterAnchor,TEX.spark,GOLD,.28,7,60,3)
        e.SpreadAngle=Vector2.new(25,25); e.Acceleration=V(side*1.4,4,0)
        g.dust[#g.dust+1]=e
        local lamp=anchor("ThresholdLight",C(ORIGIN+V(side*10,20,5)))
        g.light[#g.light+1]=new("PointLight",{Color=HOT,Brightness=0,Range=48,Shadows=false},lamp)
    end
    solid(architecture,"Entablature",V(42,3.4,6),C(0,41.5,0),STONE,Enum.Material.Marble)
    for y=40,43,1.5 do
        solid(architecture,"FriezeGilding",V(43,.12,6.2),C(0,y,0),GOLD,Enum.Material.Metal)
    end
    triangle(architecture,V(-21,43,0),V(21,43,0),V(0,54,0),STONE,1.6,Enum.Material.Marble)
    bar(architecture,"PedimentRidge",V(-22,43,1),V(0,54.5,1),.4,.4,GOLD,Enum.Material.Metal)
    bar(architecture,"PedimentRidge",V(0,54.5,1),V(22,43,1),.4,.4,GOLD,Enum.Material.Metal)
    crystal(architecture,"SanctuaryCrest",V(3,6,1.8),C(0,47,2),LIGHT)
    for s=-1,1,2 do
        for i=1,4 do feather(architecture,4.3-i*.3,1.25,C(s*1.5,46,1.8)*angle(0,0,-s*(35+i*15))) end
    end
    for i=-8,8 do
        local x=i*2.25
        solid(architecture,"DentilCarving",V(.85,.75,.7),C(x,40.8,3.1),STONE,Enum.Material.Marble)
        solid(architecture,"FriezeDiamond",V(.65,.65,.16),C(x,42.2,3.12)*angle(0,0,45),GOLD,Enum.Material.Metal)
    end
    for tier=1,4 do
        solid(architecture,"AltarStep",V(12-tier*1.6,.7,12-tier*1.6),C(0,2+tier*.65,-15),STONE,Enum.Material.Marble)
        solid(architecture,"AltarInlay",V(12-tier*1.6,.045,12-tier*1.6),C(0,2.36+tier*.65,-15),GOLD,Enum.Material.Metal)
    end
    solid(architecture,"ReliquaryColumn",V(3.2,13,3.2),C(0,11.5,-15)*angle(0,45,0),SHADOW,Enum.Material.Marble)
    for side=-1,1,2 do
        for zside=-1,1,2 do
            bar(architecture,"ReliquaryFlute",V(side*1.8,5,-15+zside*1.8),V(side*1.1,18,-15+zside*1.1),.32,.32,GOLD,Enum.Material.Metal)
        end
        feather(architecture,5,1.5,C(side*1.1,16,-13.5)*angle(0,0,-side*24))
    end
    solid(architecture,"CrystalCradle",V(5.4,.65,5.4),C(0,19,-15)*angle(0,45,0),STONE,Enum.Material.Marble)
    crystal(architecture,"AltarHeart",V(1,3.2,.8),C(0,14,-12.9),LIGHT)
    architecture:PivotTo(C(ORIGIN))
    local crown=anchor("CrestRelease",C(ORIGIN+V(0,46,3)))
    g.release=emit(crown,TEX.spark,HOT,.4,8,0,2.6)
    for i=1,5 do
        local r=ribbon(scene,ORIGIN+V((i-3)*.7,29-i*3,-1),ORIGIN+V((i-3)*4,2,22),HOT,1.1)
        r.beam.Texture=TEX.smoke; r.beam.TextureSpeed=.3
        r.beam.Transparency=seq({{0,1},{.18,.83},{.7,.94},{1,1}})
        g.rays[#g.rays+1]=r
    end
    return g
end
local function buildRelic()
    local r={model=model("Darling_AureateHeart"),wings={},emitters={},shards={},streams={}}
    crystal(r.model,"FacetedHeart",V(1.25,2.9,1.1),C(),LIGHT)
    for side=-1,1,2 do
        local wing=model("GoldenFiligree",r.model)
        for i=1,4 do
            feather(wing,2.8-i*.25,.72,C(side*(i-1)*.17,-(i-1)*.14,0)*angle(0,0,-side*(20+i*13)))
        end
        r.wings[#r.wings+1]={model=wing,side=side}
    end
    for i=1,3 do
        crystal(r.model,"PendantPrism",V(.16,.5,.16),C((i-2)*.28,-1.8-math.abs(i-2)*.15,0),HOT)
        bar(r.model,"PendantChain",V((i-2)*.28,-1,0),V((i-2)*.28,-1.6,0),.025,.025,GOLD,Enum.Material.Metal)
    end
    local emitterAnchor=anchor("CrystalRadiance",C(),r.model)
    r.emitters[1]=emit(emitterAnchor,TEX.spark,HOT,.16,1.4,38,1.2)
    r.emitters[2]=emit(emitterAnchor,TEX.fire,GOLD,.42,.6,9,.8)
    r.contact=emit(emitterAnchor,TEX.spark,HOT,.2,3.6,0,1.4)
    r.contact.Acceleration=V(0,1.2,0)
    r.wake=emit(emitterAnchor,TEX.spark,GOLD,.48,.5,48,1.5)
    r.wake.Acceleration=V(0,.5,0)
    local ta=new("Attachment",{Position=V(-.26,0,0)},r.model.PrimaryPart)
    local tb=new("Attachment",{Position=V(.26,0,0)},r.model.PrimaryPart)
    r.trail=new("Trail",{Attachment0=ta,Attachment1=tb,Lifetime=.65,FaceCamera=true,
        Color=ColorSequence.new(HOT,GOLD),LightEmission=1,LightInfluence=0,Texture=TEX.fire,
        Transparency=seq({{0,.35},{.55,.72},{1,1}}),WidthScale=seq({{0,1},{1,0}}),Enabled=false},r.model.PrimaryPart)
    r.light=new("PointLight",{Color=HOT,Brightness=3,Range=25,Shadows=false},emitterAnchor)
    for i=1,(low and 6 or 10) do
        local m=crystal(scene,"DriftingCrystalPetal",V(.16,.7,.14),C(ORIGIN),i%2==0 and LIGHT or HOT)
        local aa=new("Attachment",{Position=V(0,.22,0)},m.PrimaryPart)
        local ab=new("Attachment",{Position=V(0,-.22,0)},m.PrimaryPart)
        local trail=new("Trail",{Attachment0=aa,Attachment1=ab,Lifetime=.45,FaceCamera=true,
            LightEmission=1,LightInfluence=0,Color=ColorSequence.new(HOT,GOLD),Texture=TEX.spark,
            Transparency=seq({{0,.35},{.5,.6},{1,1}}),WidthScale=seq({{0,.5},{1,0}}),Enabled=false},m.PrimaryPart)
        local pieces={}
        for _,part in ipairs(m:GetDescendants()) do
            if part:IsA("BasePart") then pieces[#pieces+1]={obj=part,alpha=part.Transparency} end
        end
        r.shards[#r.shards+1]={model=m,trail=trail,parts=pieces,offset=V((i%2==0 and 1 or -1)*(2+i*.19),(i%4-1.5)*.65,math.sin(i*4)*1.3)}
    end
    for i=1,5 do r.streams[i]=ribbon(scene,ORIGIN,ORIGIN+V(0,1,0),GOLD,.16) end
    r.visible={}
    for _,part in ipairs(r.model:GetDescendants()) do
        if part:IsA("BasePart") then r.visible[#r.visible+1]={obj=part,alpha=part.Transparency} end
    end
    return r
end
local function buildActor(character)
    local archivable=character.Archivable; character.Archivable=true
    local ok, clone=pcall(function() return character:Clone() end)
    character.Archivable=archivable
    if not ok or not clone then error("Could not clone your avatar") end
    local a={model=clone,edges={},loose={}}; actor=a
    clone.Name="YourAvatar"
    for _,o in ipairs(clone:GetDescendants()) do
        if o:IsA("LuaSourceContainer") or o:IsA("Tool") or o:IsA("Animator") or o:IsA("Sound")
            or o:IsA("ParticleEmitter") or o:IsA("Beam") or o:IsA("Trail") or o:IsA("BillboardGui")
            or o:IsA("Highlight") or o:IsA("ForceField") then o:Destroy() end
    end
    local root=clone:FindFirstChild("HumanoidRootPart")
    if not root then error("Your avatar has no HumanoidRootPart") end
    a.root=root; clone.PrimaryPart=root
    for _,p in ipairs(clone:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false
            p.LocalTransparencyModifier=0; p.AssemblyLinearVelocity=V(); p.AssemblyAngularVelocity=V()
        end
    end
    local h=clone:FindFirstChildOfClass("Humanoid")
    if h then h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None; h.RequiresNeck=false; h.BreakJointsOnDeath=false end
    clone:ScaleTo(clone:GetScale()*1.55)
    local links,joints={},{}
    local bottom=root.Position.Y
    for _,o in ipairs(clone:GetDescendants()) do
        if o:IsA("BasePart") and o.Parent==clone then bottom=math.min(bottom,o.Position.Y-o.Size.Y*.5) end
        if o:IsA("JointInstance") or o:IsA("WeldConstraint") then
            joints[#joints+1]=o
            if o.Part0 and o.Part1 and o.Part0:IsDescendantOf(clone) and o.Part1:IsDescendantOf(clone) then
                links[#links+1]={a=o.Part0,b=o.Part1,c0=o:IsA("JointInstance") and o.C0 or o.Part0.CFrame:ToObjectSpace(o.Part1.CFrame),
                    c1=o:IsA("JointInstance") and o.C1 or C(),motor=o:IsA("Motor6D"),name=o.Name:gsub("%s","")}
            end
        end
    end
    a.height=root.Position.Y-bottom
    local seen={[root]=true}; local changed=true
    while changed do
        changed=false
        for _,e in ipairs(links) do
            if seen[e.a] and not seen[e.b] then
                a.edges[#a.edges+1]=e; seen[e.b]=true; changed=true
            elseif seen[e.b] and not seen[e.a] then
                a.edges[#a.edges+1]={a=e.b,b=e.a,c0=e.c1,c1=e.c0,motor=e.motor,name=e.name,reverse=true}
                seen[e.a]=true; changed=true
            end
        end
    end
    for _,o in ipairs(clone:GetDescendants()) do
        if o:IsA("BasePart") and not seen[o] then a.loose[o]=root.CFrame:ToObjectSpace(o.CFrame) end
    end
    for _,j in ipairs(joints) do j:Destroy() end
    for _,o in ipairs(clone:GetDescendants()) do if o:IsA("Constraint") then o:Destroy() end end
    clone.Parent=scene
    return a
end
local function poseActor(t)
    local receive=phase(t,11.8,15.8)
    local turn=phase(t,16.2,18.7)
    local frame=C(ORIGIN+V(0,actor.height+2,38))*angle(0,-14*turn,0)
    actor.root.CFrame=frame
    local breath=math.sin(t*1.4)
    local poses={Neck=angle(18*(1-receive)-4*receive+breath*.3,-8*turn,0),Waist=angle(-3*receive+breath*.3,0,0),
        RootJoint=angle(-2*receive,0,0),
        RightShoulder=angle(65*receive,0,12*receive),RightElbow=angle(18*receive,0,0),
        LeftShoulder=angle(61*receive,0,-12*receive),LeftElbow=angle(22*receive,0,0),
        RightWrist=angle(-12*receive,0,-8*receive),LeftWrist=angle(-10*receive,0,8*receive)}
    for _,e in ipairs(actor.edges) do
        local rotation=e.motor and poses[e.name] or C()
        rotation=rotation or C()
        local basis=e.c0-e.c0.Position
        local transform=basis:Inverse()*rotation*basis
        if e.reverse then transform=transform:Inverse() end
        e.b.CFrame=e.a.CFrame*e.c0*transform*e.c1:Inverse()
    end
    for part,relative in pairs(actor.loose) do part.CFrame=frame*relative end
    local right=actor.model:FindFirstChild("RightHand") or actor.model:FindFirstChild("Right Arm") or actor.root
    local left=actor.model:FindFirstChild("LeftHand") or actor.model:FindFirstChild("Left Arm") or actor.root
    local rp=(right.CFrame*C(0,-right.Size.Y*.42,-.1)).Position
    local lp=(left.CFrame*C(0,-left.Size.Y*.42,-.1)).Position
    -- Keep the bright crest below the face in the final portrait.
    return (rp+lp)*.5+V(.35,.55,-.65)
end
local function buildEnvironment()
    environment.clouds={}; environment.dust={}; environment.islands={}; environment.shafts={}
    environment.feathers={}; environment.pathLights={}
    for _,n in ipairs({V(1,0,0),V(-1,0,0),V(0,1,0),V(0,-1,0),V(0,0,1),V(0,0,-1)}) do
        local wall=solid(scene,"DaybreakSky",V(1,1,1),C(ORIGIN+n*430),n.Y<0 and Color3.fromRGB(211,227,232) or Color3.fromRGB(129,165,197))
        new("SpecialMesh",{MeshType=Enum.MeshType.Brick,Scale=V(n.X~=0 and 2 or 870,n.Y~=0 and 2 or 870,n.Z~=0 and 2 or 870)},wall)
    end
    solid(scene,"MarbleProcessionalBridge",V(19,2,96),C(ORIGIN+V(0,1,22)),STONE,Enum.Material.Marble)
    solid(scene,"CentralInlaidPath",V(7,.04,90),C(ORIGIN+V(0,2.03,22)),Color3.fromRGB(182,196,204),Enum.Material.Marble)
    for side=-1,1,2 do
        solid(scene,"BridgeGoldInlay",V(.12,.04,96),C(ORIGIN+V(side*3.6,2.06,22)),GOLD,Enum.Material.Metal)
        solid(scene,"BridgeEdgeCornice",V(1.2,.5,96),C(ORIGIN+V(side*9.5,1.85,22)),STONE,Enum.Material.Marble)
        for z=-15,65,10 do
            solid(scene,"BridgePylon",V(2.8,.6,2.8),C(ORIGIN+V(side*10,2,z)),STONE,Enum.Material.Marble)
            solid(scene,"PylonRecess",V(1.3,4,1.3),C(ORIGIN+V(side*10,4,z)),SHADOW,Enum.Material.Marble)
            for corner=-1,1,2 do
                solid(scene,"PylonFlute",V(.22,4,.22),C(ORIGIN+V(side*10+corner*.7,4,z+.7)),STONE,Enum.Material.Marble)
            end
            solid(scene,"PylonCapital",V(2.2,.4,2.2),C(ORIGIN+V(side*10,6,z)),STONE,Enum.Material.Marble)
            local lantern=crystal(scene,"PathLantern",V(.6,1.3,.6),C(ORIGIN+V(side*10,7,z)),HOT)
            local core=lantern:FindFirstChild("LuminousCrystalHeart")
            local lamp=new("PointLight",{Color=HOT,Brightness=0,Range=10,Shadows=false},lantern.PrimaryPart)
            environment.pathLights[#environment.pathLights+1]={core=core,light=lamp,z=z}
        end
        for z=-10,60,5 do
            solid(scene,"Baluster",V(.4,2.2,.4),C(ORIGIN+V(side*10,3.7,z)),STONE,Enum.Material.Marble)
        end
        solid(scene,"GildedHandrail",V(.55,.45,90),C(ORIGIN+V(side*10,5,25)),GOLD,Enum.Material.Metal)
    end
    for z=-20,65,5 do
        solid(scene,"MarbleJoint",V(18.8,.035,.05),C(ORIGIN+V(0,2.025,z)),SHADOW,Enum.Material.Marble)
    end
    for z=-10,60,10 do
        local points={V(0,2.07,z-3.6),V(2.9,2.07,z),V(0,2.07,z+3.6),V(-2.9,2.07,z)}
        for j=1,4 do
            triangle(scene,ORIGIN+V(0,2.07,z),ORIGIN+points[j],ORIGIN+points[j%4+1],
                j%2==0 and STONE or Color3.fromRGB(140,166,180),.018,Enum.Material.Marble)
            bar(scene,"ProcessionalMosaic",ORIGIN+points[j],ORIGIN+points[j%4+1],.055,.025,GOLD,Enum.Material.Metal)
        end
    end
    for i=1,(low and 4 or 7) do
        local f=feather(scene,1.6+(i%3)*.35,.6,C(ORIGIN))
        local aa=new("Attachment",{Position=V(0,.3,0)},f.PrimaryPart)
        local ab=new("Attachment",{Position=V(0,.55,0)},f.PrimaryPart)
        local trail=new("Trail",{Attachment0=aa,Attachment1=ab,FaceCamera=true,Lifetime=.55,
            Texture=TEX.spark,Color=ColorSequence.new(HOT,GOLD),LightEmission=1,
            Transparency=seq({{0,.55},{.6,.85},{1,1}}),WidthScale=seq({{0,.5},{1,0}}),Enabled=false},f.PrimaryPart)
        local parts={}
        for _,part in ipairs(f:GetDescendants()) do
            if part:IsA("BasePart") then parts[#parts+1]={obj=part,alpha=part.Transparency} end
        end
        environment.feathers[#environment.feathers+1]={model=f,trail=trail,parts=parts,side=i%2==0 and 1 or -1,seed=i}
    end
    for i=1,(low and 7 or 12) do
        local side=i%2==0 and 1 or -1
        local pos=V(side*(45+(i%4)*30),-9+(i%3)*14,-50-(i%5)*28)
        local island=model("FloatingSanctuaryFragment")
        for layer=1,4 do
            solid(island,"FacetedFoundation",V(23-layer*3,4.5,18-layer*2),C(0,-layer*2,0)*angle(180,layer*27,0),SHADOW,Enum.Material.Slate,"Wedge")
        end
        solid(island,"MarbleIslandCrown",V(20,1.2,16),C(),STONE,Enum.Material.Marble)
        for sideX=-1,1,2 do
            solid(island,"RuinedColonnade",V(1.8,10+i%3*3,1.8),C(sideX*6,5+i%3*1.5,0),STONE,Enum.Material.Marble)
            solid(island,"Capital",V(3,.7,3),C(sideX*6,10.3+i%3*3,0),STONE,Enum.Material.Marble)
        end
        solid(island,"BrokenLintel",V(16,1.6,3),C(0,11.5+i%3*3,0),STONE,Enum.Material.Marble)
        island:PivotTo(C(ORIGIN+pos)*angle(0,i*19,0))
        environment.islands[#environment.islands+1]={model=island,frame=island:GetPivot(),seed=i}
    end
    for i=1,(low and 12 or 20) do
        local pos=V((i%2==0 and 1 or -1)*(25+(i%5)*28),-29-(i%3)*4,-85+(i%7)*30)
        local cloud=anchor("CloudBank",C(ORIGIN+pos))
        local e=emit(cloud,TEX.smoke,HOT,50,1.1,2.5,15)
        e.Color=ColorSequence.new(Color3.fromRGB(228,239,249),Color3.fromRGB(190,209,229))
        e.LightEmission=.3; e.LightInfluence=0; e.Acceleration=V(.2,0,0)
        e.Transparency=seq({{0,.86},{.25,.58},{.7,.68},{1,1}})
        e.Size=seq({{0,36},{.3,50},{1,62}})
        environment.clouds[#environment.clouds+1]=e
    end
    for _,pos in ipairs({V(-7,3,10),V(7,3,25),V(-8,3,45),V(7,8,-8)}) do
        local a=anchor("SunlitDust",C(ORIGIN+pos))
        local e=emit(a,TEX.spark,HOT,.11,2,17,5)
        e.Acceleration=V(.1,.7,.1); environment.dust[#environment.dust+1]=e
    end
    for i=1,6 do
        local r=ribbon(scene,ORIGIN+V(20+i*7,80,-60),ORIGIN+V(-40+i*6,-12,-15),HOT,4+i*.6)
        r.beam.Texture=TEX.smoke; r.beam.TextureSpeed=.15
        r.beam.Transparency=seq({{0,1},{.2,.94},{.7,.96},{1,1}})
        environment.shafts[#environment.shafts+1]=r
    end
    local key=anchor("WarmPortraitLight",C(ORIGIN+V(-4,14,30)))
    new("PointLight",{Color=HOT,Range=45,Brightness=2.5,Shadows=false},key)
    local fill=anchor("CoolBounce",C(ORIGIN+V(8,12,45)))
    new("PointLight",{Color=LIGHT,Range=40,Brightness=1.2,Shadows=false},fill)
end
local function animate(t)
    local opening=phase(t,3.1,7.4)
    for _,d in ipairs(gate.doors) do
        d.model:PivotTo(C(ORIGIN+V(d.side*12.7,3,0))*angle(0,-d.side*106*opening,0))
    end
    for _,e in ipairs(gate.dust) do e.Enabled=t>3.1 and t<9.5 end
    for _,lamp in ipairs(gate.light) do lamp.Brightness=opening*3 end
    for _,r in ipairs(gate.rays) do r.beam.Enabled=t>3.8 and t<10 end
    for _,e in ipairs(environment.clouds) do e.Enabled=true end
    for _,e in ipairs(environment.dust) do e.Enabled=true end
    for _,r in ipairs(environment.shafts) do r.beam.Enabled=true end
    for _,lamp in ipairs(environment.pathLights) do
        local a=3.5+(lamp.z+15)*.025
        local power=phase(t,a,a+.85)
        lamp.core.Color=SHADOW:Lerp(HOT,power)
        lamp.light.Brightness=power*1.6
    end
    local featherAlpha=phase(t,0,1)*(1-phase(t,13,15))
    for _,f in ipairs(environment.feathers) do
        local i=f.seed
        local at=ORIGIN+V(f.side*(20+i*.8+math.sin(t*.65+i)*2),9+(i%4)*6+math.sin(t*.8+i)*1.4,-20+i*9+t*1.9)
        f.model:PivotTo(C(at)*angle(math.sin(t+i)*15,t*14+i*47,f.side*25+math.sin(t*.75+i)*18))
        f.trail.Enabled=t>1 and t<13
        for _,part in ipairs(f.parts) do part.obj.Transparency=1-(1-part.alpha)*featherAlpha end
    end
    for _,island in ipairs(environment.islands) do
        island.model:PivotTo(island.frame+V(0,math.sin(t*.35+island.seed)*.6,0))
    end
    for i,at in ipairs({3.25,7.4,16.0}) do
        if t>=at and not cues[i] then
            cues[i]=true
            if i==1 then gate.release:Emit(low and 40 or 80) end
            if i==3 then relic.contact:Emit(low and 32 or 65) end
            if audio.impact then audio.impact.Volume=i==1 and .12 or .065; audio.impact.TimePosition=0; audio.impact:Play() end
        end
    end
    if audio.rumble then audio.rumble.Volume=.1*phase(t,0,1.5)*(1-phase(t,17.5,20)) end
    local hands=poseActor(t)
    local journey=phase(t,7.4,12)
    local arrive=phase(t,12,16)
    local flight=ORIGIN+curve(V(0,24,-15),V(-5,29,-7),V(5,17,12),V(0,12,24),journey)
    local position=flight:Lerp(hands,arrive)
    position=position+V(0,math.sin(t*1.7)*.14*(1-arrive),0)
    local cf=C(position)*angle(0,mix(t*14,180,arrive),math.sin(t*.6)*3*(1-arrive))
    relic.model:PivotTo(cf)
    for _,wing in ipairs(relic.wings) do
        local sweep=math.sin(t*1.3)*2+phase(t,7,9)*12+phase(t,15.7,16.8)*17
        wing.model:PivotTo(cf*C(wing.side*.55,-.1,0)*angle(0,wing.side*math.sin(t)*5,-wing.side*sweep))
    end
    local appear=phase(t,6.4,8)
    for _,p in ipairs(relic.visible) do p.obj.Transparency=1-(1-p.alpha)*appear end
    for _,e in ipairs(relic.emitters) do e.Enabled=t>6.4 end
    relic.wake.Enabled=t>7.4 and t<13
    relic.trail.Enabled=t>7.4 and t<12.5
    local contactGlow=phase(t,15.7,16)*(1-phase(t,16.15,17.2))
    relic.light.Brightness=appear*(3+arrive*2+contactGlow*3+phase(t,18.8,20)*3)
    relic.emitters[1].Rate=(38+contactGlow*65)*(low and .5 or 1)
    local petals=phase(t,7.1,8.6)*(1-phase(t,17,18.5))
    for i,shard in ipairs(relic.shards) do
        local float=V(math.sin(t*.7+i)*.4,math.sin(t*1.2+i*2)*.35,math.sin(t*.6+i)*.3)
        local offset=(shard.offset+float)*(1-phase(t,16,18.3)*.8)
        shard.model:PivotTo(C(position+offset)*angle(i*24+t*11,i*56+t*16,i*37))
        for _,p in ipairs(shard.parts) do p.obj.Transparency=1-(1-p.alpha)*petals end
        shard.trail.Enabled=t>7.4 and t<17.8
    end
    for i,r in ipairs(relic.streams) do
        local a=position+V((i%2==0 and 1 or -1)*(1.5+i*.25),-.8+math.sin(t*1.5+i)*.3,-1.5)
        r.a.CFrame=C(a); r.b.CFrame=C(position+V(0,.2,0))
        r.beam.Enabled=t>7.6 and t<11.5 or t>15.2 and t<17.5
    end
    local pos,focus,fov
    local localRelic=position-ORIGIN
    local head=actor.model:FindFirstChild("Head") or actor.root
    if t<4.1 then
        local p=phase(t,0,4.1)
        pos=curve(V(65,64,132),V(65,41,90),V(26,18,77),V(16,20,48),p)
        focus=V(0,24,0); fov=mix(66,58,p)
    elseif t<7.2 then
        local p=phase(t,4.1,7.2)
        pos=curve(V(16,20,48),V(10,24,42),V(-8,23,35),V(0,24,34),p)
        focus=V(0,24,0):Lerp(localRelic,phase(t,6,7.2)); fov=mix(58,53,p)
    elseif t<10.8 then
        local p=phase(t,7.2,10.8)
        local tracking=localRelic+V(10,3,15):Lerp(V(7,2.4,12),p)
        pos=V(0,24,34):Lerp(tracking,phase(t,7.2,8.9))
        focus=localRelic; fov=mix(53,48,p)
    elseif t<13.8 then
        local p=phase(t,10.8,13.8)
        pos=(localRelic+V(7,2.4,12)):Lerp(V(12,10,46),p)
        focus=localRelic; fov=mix(48,52,p)
    elseif t<16.2 then
        local p=phase(t,13.8,16.2)
        pos=curve(V(12,10,46),V(18,9,43),V(16,11,32),V(10,10,29),p)
        focus=localRelic:Lerp(head.Position-ORIGIN,.28*p); fov=mix(52,49,p)
    else
        local p=phase(t,16.2,19.5)
        local target=position:Lerp(head.Position,mix(.28,.74,p))
        local portrait=target-ORIGIN+head.CFrame.LookVector*10+head.CFrame.RightVector*1.5+V(0,.5,0)
        pos=V(10,10,29):Lerp(portrait,p)
        focus=target-ORIGIN; fov=mix(49,45,p)
    end
    local sway=V(math.sin(t*1.3)*.035,math.sin(t*.9)*.035,0)
    local bank=math.sin(t*.55)*1.5*(1-phase(t,5,8))
    camera.CFrame=CFrame.lookAt(ORIGIN+pos+sway,ORIGIN+focus)*angle(0,0,bank)
    camera.Focus=C(ORIGIN+focus); camera.FieldOfView=fov
    bloom.Intensity=.5+phase(t,6.4,8)*.18+phase(t,15.5,16.5)*.18+contactGlow*.2
    flash.BackgroundTransparency=1
end
local function start()
    local playerGui=player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui",8)
    if not playerGui then error("PlayerGui unavailable") end
    gui=new("ScreenGui",{Name="Darling_AureateIntro",ResetOnSpawn=false,IgnoreGuiInset=false,DisplayOrder=100000,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},playerGui)
    flash=new("Frame",{Name="LightTransition",Size=UDim2.fromScale(1,1),Position=UDim2.fromOffset(0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=1},gui)
    local skip=new("TextButton",{
        Name="Skip",Text="Skip",Font=Enum.Font.GothamMedium,TextSize=17,
        TextColor3=Color3.fromRGB(38,56,78),TextTransparency=.04,
        AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-18,0,14),Size=UDim2.fromOffset(84,44),
        BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,ZIndex=10,
    },gui)
    connect(skip.Activated,function() finish(true) end)
    connect(skip.MouseEnter,function() skip.TextTransparency=0 end)
    connect(skip.MouseLeave,function() skip.TextTransparency=.04 end)
    local character=player.Character
    local deadline=os.clock()+8
    while not character and os.clock()<deadline and not stopped do task.wait(.1); character=player.Character end
    if stopped then return end
    if not character then error("Your character has not loaded") end
    camera=Workspace.CurrentCamera
    if not camera then error("Camera unavailable") end
    scene=new("Folder",{Name="Darling_AureateSanctuary"}) -- Detached until every model is positioned in space.
    buildEnvironment()
    gate=buildGate()
    relic=buildRelic()
    actor=buildActor(character)
    if stopped then return end
    for _,g in ipairs(playerGui:GetChildren()) do
        if g:IsA("ScreenGui") and g~=gui then hidden[g]=g.Enabled; g.Enabled=false end
    end
    local h=character:FindFirstChildOfClass("Humanoid")
    if h then
        humanSaved={humanoid=h,speed=h.WalkSpeed,rotate=h.AutoRotate,jump=h.JumpPower,height=h.JumpHeight}
        h.WalkSpeed=0; h.AutoRotate=false; h.JumpPower=0; h.JumpHeight=0
        connect(h.Died,function() finish(true) end)
    end
    cameraSaved={camera=camera,kind=camera.CameraType,subject=camera.CameraSubject,frame=camera.CFrame,focus=camera.Focus,fov=camera.FieldOfView}
    for _,key in ipairs({"Ambient","OutdoorAmbient","Brightness","ClockTime","FogStart","FogEnd","FogColor","ExposureCompensation"}) do lightingSaved[key]=Lighting[key] end
    for _,o in ipairs(Lighting:GetChildren()) do
        if o:IsA("PostEffect") then postSaved[o]={Enabled=o.Enabled}; o.Enabled=false
        elseif o:IsA("Atmosphere") then postSaved[o]={Density=o.Density,Haze=o.Haze,Glare=o.Glare}; o.Density=0; o.Haze=0; o.Glare=0 end
    end
    Lighting.Ambient=Color3.fromRGB(168,172,181); Lighting.OutdoorAmbient=Color3.fromRGB(146,166,187)
    Lighting.Brightness=2; Lighting.ClockTime=9.3; Lighting.FogStart=150; Lighting.FogEnd=700; Lighting.FogColor=Color3.fromRGB(168,194,216)
    Lighting.ExposureCompensation=.1
    bloom=new("BloomEffect",{Name="DarlingRelicBloom",Intensity=.5,Size=32,Threshold=1.1},Lighting)
    camera.CameraType=Enum.CameraType.Scriptable
    api.Status="playing"
    animate(0)
    scene.Parent=Workspace
    for _,e in ipairs(environment.clouds) do e:Emit(low and 7 or 12) end
    if CONFIG.Audio then
        audio.rumble=new("Sound",{Name="SanctuaryAtmosphere",SoundId="rbxassetid://9114223171",Volume=0,Looped=true,PlaybackSpeed=.7},gui)
        audio.impact=new("Sound",{Name="RelicAccent",SoundId="rbxassetid://157878578",Volume=.1,PlaybackSpeed=1.2},gui)
        audio.rumble:Play()
    end
    connect(player.CharacterRemoving,function(c) if c==character then finish(true) end end)
    connect(Workspace:GetPropertyChangedSignal("CurrentCamera"),function() if Workspace.CurrentCamera~=camera then finish(true) end end)
    clockStart=os.clock()
    RunService:BindToRenderStep(bindName,Enum.RenderPriority.Camera.Value+10,function()
        if stopped then return end
        elapsed=os.clock()-clockStart
        if elapsed>=CONFIG.Duration then finish(true); return end
        local ok,err=pcall(animate,elapsed)
        if not ok then
            api.LastError=tostring(err); warn("[Darling Intro] "..tostring(err)); finish(true)
        end
    end)
    bound=true
end
local ok,err=pcall(start)
if not ok and not stopped then
    api.LastError=tostring(err)
    warn("[Darling Intro] "..tostring(err))
    finish(true)
end
-- END DARLING / THE AUREATE SANCTUARY 3.0

end

function SanctuaryCinematic.play(onComplete)
    SanctuaryCinematic.stop()
    local ok, res = pcall(function()
        return runSanctuaryCinematic(onComplete)
    end)
    if ok then
        activeApi = res
        return res
    else
        warn("[SanctuaryCinematic] Error starting: " .. tostring(res))
    end
end

function SanctuaryCinematic.stop()
    if activeApi and type(activeApi.Stop) == "function" then
        pcall(function() activeApi.Stop() end)
    end
    local env = (getgenv and getgenv()) or _G
    local old = env.DarlingIntro or _G.DarlingIntro
    if type(old) == "table" and type(old.Stop) == "function" then
        pcall(function() old.Stop() end)
    end
    activeApi = nil
end

return SanctuaryCinematic
