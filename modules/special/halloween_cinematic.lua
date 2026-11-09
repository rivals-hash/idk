--[[
    Darling Hub - The Hollow Lantern Halloween Cinematic Module (Version 1.3)
]]

local HalloweenCinematic = {}
local activeApi = nil

local function runHalloweenCinematic(onComplete)
-- DARLING / HALLOWEEN / THE HOLLOW LANTERN 4.0 / 20 seconds / complete launcher.
-- Paste this WHOLE file into Delta instead of the original one-line loader.
-- Skip or the end restores the game and opens the original Darling Hub once.
local CONFIG = {
    Duration = 20,
    OpenHub = false,
    HubURL = "https://raw.githubusercontent.com/devdarlingx-dotcom/Darling-hub/main/main.lua",
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
local api = {Version = 4, Status = "building", IsPlaying = true}
env.DarlingIntro = api
local V, C = Vector3.new, CFrame.new
local LIGHT = Color3.fromRGB(164, 255, 116)
local HOT = Color3.fromRGB(255, 219, 134)
local GOLD = Color3.fromRGB(230, 124, 32)
local STONE = Color3.fromRGB(71, 72, 87)
local SHADOW = Color3.fromRGB(27, 29, 43)
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
local function round(parent,name,size,cf,color,material)
    return solid(parent,name,size,cf,color,material,"Sphere")
end
local function pumpkin(parent, radius, frame, detailed)
    local m=model(detailed and "HollowCarvedPumpkin" or "JackOLantern",parent)
    local orange=Color3.fromRGB(175,65,13)
    local function surface(theta,latitude)
        local ridge=1+.075*math.cos(theta*10)
        return V(math.sin(theta)*math.cos(latitude)*radius*ridge,
            math.sin(latitude)*radius*.86,math.cos(theta)*math.cos(latitude)*radius*ridge)
    end
    local function opening(v)
        local x,y=v.X/radius,v.Y/radius
        local eye=math.abs(x)
        if y>.08 and y<.47 and eye>.13 and eye<.60 and y<.51-(eye-.13)*.65 then return true end
        if math.abs(x)<.1 and y>-.11 and y<.06-math.abs(x)*.7 then return true end
        if y<-.23 and y>-.49+math.abs(x)*.22 and math.abs(x)<.65 then
            if math.abs(x)>.19 and math.abs(x)<.31 and y>-.35 then return false end
            return true
        end
        return false
    end
    if detailed then
        -- A genuinely open shell: front triangles are omitted at the eyes, nose and mouth.
        for hemisphere=1,2 do
            local columns=hemisphere==1 and 18 or 8
            local rows=hemisphere==1 and 12 or 8
            local start=hemisphere==1 and -math.pi/2 or math.pi/2
            for x=0,columns-1 do
                for y=0,rows-1 do
                    local a=start+x*math.pi/columns
                    local b=start+(x+1)*math.pi/columns
                    local lo=-math.pi/2+y*math.pi/rows
                    local hi=-math.pi/2+(y+1)*math.pi/rows
                    local v={surface(a,lo),surface(b,lo),surface(b,hi),surface(a,hi)}
                    for _,indices in ipairs({{1,2,3},{1,3,4}}) do
                        local p1,p2,p3=v[indices[1]],v[indices[2]],v[indices[3]]
                        if hemisphere==2 or not opening((p1+p2+p3)/3) then
                            local color=orange:Lerp(GOLD,.16+.12*math.cos((a+b)*5))
                            triangle(m,p1,p2,p3,color,math.max(.018,radius*.035),Enum.Material.SmoothPlastic)
                        end
                    end
                end
            end
        end
    else
        for i=1,10 do
            local a=i*math.pi/5
            round(m,"PumpkinLobe",V(radius*.88,radius*1.65,radius*.88),C(math.sin(a)*radius*.6,0,math.cos(a)*radius*.6),
                orange:Lerp(GOLD,(i%3)*.08),Enum.Material.SmoothPlastic)
        end
        for side=-1,1,2 do
            triangle(m,V(side*.13,.11,1)*radius,V(side*.62,.13,.87)*radius,V(side*.42,.49,.91)*radius,HOT,.035,Enum.Material.Neon)
        end
        for tooth=-2,2 do
            solid(m,"GrinningMouth",V(.18,.11,.07)*radius,C(V(tooth*.2,-.33+math.abs(tooth)*.035,.99-math.abs(tooth)*.025)*radius)*angle(0,0,tooth*7),HOT,Enum.Material.Neon)
        end
    end
    local stemPoints={V(0,.72,0),V(.08,1.0,-.02),V(-.04,1.18,-.08),V(-.21,1.24,-.1)}
    for i=1,#stemPoints-1 do
        bar(m,"TwistedStem",stemPoints[i]*radius,stemPoints[i+1]*radius,radius*(.24-i*.035),radius*.18,Color3.fromRGB(59,66,26),Enum.Material.Wood)
    end
    local core=round(m,"PumpkinFire",V(1.3,1.15,1.05)*radius,C(0,-.06*radius,0),HOT,Enum.Material.Neon)
    m:PivotTo(frame)
    return m,core
end
local function batWing(parent, side, scale)
    local wing=model("ScallopedBatWing",parent)
    local elbow=V(side*.75,.5,0)*scale
    local tips={V(side*2.4,1.0,0)*scale,V(side*2.15,-.15,0)*scale,V(side*1.45,-.7,0)*scale,V(side*.45,-.65,0)*scale}
    bar(wing,"WingArm",V(),elbow,.09*scale,.09*scale,Color3.fromRGB(75,40,76),Enum.Material.SmoothPlastic)
    for i,tip in ipairs(tips) do
        bar(wing,"WingFinger",elbow,tip,.055*scale,.055*scale,Color3.fromRGB(113,63,109),Enum.Material.SmoothPlastic)
        local nextTip=tips[i+1] or V()
        local scallop=tip:Lerp(nextTip,.5):Lerp(elbow,.28)
        triangle(wing,elbow,tip,scallop,Color3.fromRGB(45,20,53),.025,Enum.Material.Fabric)
        triangle(wing,elbow,scallop,nextTip,Color3.fromRGB(60,26,60),.025,Enum.Material.Fabric)
    end
    solid(wing,"WingThumb",V(.14,.42,.12)*scale,C(elbow)*angle(0,0,-side*25),Color3.fromRGB(169,133,133),Enum.Material.SmoothPlastic,"Wedge")
    return wing
end
local function candle(parent,frame,height)
    local m=model("MeltedCandle",parent)
    local wax=Color3.fromRGB(197,184,148)
    local body=solid(m,"WaxColumn",V(height,.34,.34),C(0,height*.5,0)*angle(0,0,90),wax)
    body.Shape=Enum.PartType.Cylinder
    for i=1,5 do
        local a=i*math.pi*.4
        round(m,"WaxDrip",V(.08,.17+i*.04,.08),C(math.cos(a)*.16,height-.08-i*.025,math.sin(a)*.16),wax)
    end
    local flame=solid(m,"CandleFlame",V(.14,.34,.13),C(0,height+.16,0),HOT,Enum.Material.Neon,"Wedge")
    local e=emit(flame,TEX.fire,GOLD,.22,.15,7,.5); e.Enabled=true
    m:PivotTo(frame)
    return m
end
local function buildGate()
    local g={doors={},dust={},light={},rays={}}
    local architecture=model("BlackthornCemeteryGate")
    local iron=Color3.fromRGB(22,24,32)
    for side=-1,1,2 do
        for tier=1,4 do
            solid(architecture,"WeatheredGateBase",V(6-tier*.55,1,6-tier*.55),C(side*15,tier*.9,0),STONE,Enum.Material.Slate)
        end
        solid(architecture,"GatePier",V(3.8,32,3.8),C(side*15,20,0),STONE,Enum.Material.Slate)
        for band=1,7 do
            solid(architecture,"MasonryCourse",V(3.95,.14,3.95),C(side*15,4+band*4.5,0),SHADOW,Enum.Material.Slate)
        end
        solid(architecture,"PierCap",V(5,1.2,5),C(side*15,37,0),SHADOW,Enum.Material.Slate)
        pumpkin(architecture,2.4,C(side*15,40,0),false)
        local door=model("WroughtIronGateLeaf")
        local mid=-side*6.35
        for j=0,9 do
            local x=-side*(.45+j*1.32)
            local height=29+5*math.sin(j/9*math.pi*.5)
            bar(door,"IronPicket",V(x,1,0),V(x,height,0),.24,.24,iron,Enum.Material.Metal)
            solid(door,"SpearFinial",V(.75,1.9,.23),C(x,height+.75,0),iron,Enum.Material.Metal,"Wedge")
            solid(door,"FinialInlay",V(.16,.9,.06),C(x,height+.7,.15),GOLD,Enum.Material.Metal,"Wedge")
        end
        for y=3,27,12 do bar(door,"GateCrossbar",V(-side*.2,y,0),V(-side*12.6,y,0),.38,.38,iron,Enum.Material.Metal) end
        for row=1,3 do
            for flip=-1,1,2 do
                local previous=V(mid,row*8,0)
                for j=1,8 do
                    local f=j/8
                    local point=V(mid+flip*math.sin(f*math.pi)*3.5,row*8+f*5,0)
                    bar(door,"ForgedIronScroll",previous,point,.16,.16,iron,Enum.Material.Metal)
                    previous=point
                end
            end
        end
        for i=0,2 do
            bar(door,"DiagonalBrace",V(-side*.4,3+i*9,.1),V(-side*12.3,12+i*9,.1),.23,.23,iron,Enum.Material.Metal)
        end
        g.doors[#g.doors+1]={model=door,side=side}
        local a=anchor("ThresholdEmbers",C(ORIGIN+V(side*12,5,1)))
        local e=emit(a,TEX.spark,GOLD,.24,4.5,32,2.8); g.dust[#g.dust+1]=e
        local lamp=anchor("GateLanternLight",C(ORIGIN+V(side*13,24,4)))
        g.light[#g.light+1]=new("PointLight",{Color=GOLD,Brightness=0,Range=45,Shadows=false},lamp)
    end
    bar(architecture,"GothicArch",V(-16,36,0),V(0,52,0),2,2.8,STONE,Enum.Material.Slate)
    bar(architecture,"GothicArch",V(0,52,0),V(16,36,0),2,2.8,STONE,Enum.Material.Slate)
    for side=-1,1,2 do
        bar(architecture,"ArchFillet",V(side*16,36,1.5),V(0,52,1.5),.15,.15,GOLD,Enum.Material.Metal)
    end
    pumpkin(architecture,2.5,C(0,45,1),false)
    for tier=1,4 do
        solid(architecture,"CryptAltarStep",V(12-tier*1.6,.8,12-tier*1.6),C(0,2+tier*.7,-15),STONE,Enum.Material.Slate)
    end
    solid(architecture,"ReliquaryObelisk",V(4,13,4),C(0,11.5,-15),SHADOW,Enum.Material.Slate)
    solid(architecture,"CoffinAltar",V(6,.8,8),C(0,19,-15),STONE,Enum.Material.Slate)
    for side=-1,1,2 do
        bar(architecture,"AltarRelief",V(side*1.8,5,-12.9),V(side*1.1,18,-12.9),.16,.16,GOLD,Enum.Material.Metal)
        candle(architecture,C(side*2.5,19.5,-13),1.3)
        candle(architecture,C(side*2.3,19.5,-17),1.7)
    end
    architecture:PivotTo(C(ORIGIN))
    local crest=anchor("CrestEmbers",C(ORIGIN+V(0,44,3)))
    g.release=emit(crest,TEX.spark,GOLD,.32,7,0,2.6)
    for i=1,4 do
        local ray=ribbon(scene,ORIGIN+V((i-2.5)*1.5,24,-3),ORIGIN+V((i-2.5)*4,3,20),LIGHT,.8)
        ray.beam.Texture=TEX.smoke
        ray.beam.Transparency=seq({{0,1},{.2,.86},{.7,.95},{1,1}})
        g.rays[#g.rays+1]=ray
    end
    return g
end
local function buildRelic()
    local r={model=model("Darling_HollowLantern"),wings={},emitters={},shards={},streams={}}
    pumpkin(r.model,1.13,C(),true)
    local iron=Color3.fromRGB(35,29,35)
    local previous=V(-.85,.5,0)
    for i=1,10 do
        local a=math.pi-i*math.pi/10
        local point=V(math.cos(a)*.85,.5+math.sin(a)*1.45,0)
        bar(r.model,"ForgedLanternHandle",previous,point,.075,.075,iron,Enum.Material.Metal)
        previous=point
    end
    for side=-1,1,2 do
        local wing=batWing(r.model,side,.7)
        r.wings[#r.wings+1]={model=wing,side=side}
        bar(r.model,"LanternBail",V(side*.83,.35,0),V(side*.83,.75,0),.13,.13,iron,Enum.Material.Metal)
    end
    crystal(r.model,"GreenSoulPendant",V(.25,.65,.23),C(0,-1.3,.1),LIGHT)
    local flame=anchor("LanternMagic",C(0,-.12,0),r.model)
    r.emitters[1]=emit(flame,TEX.spark,GOLD,.14,1.3,28,1.2)
    r.emitters[2]=emit(flame,TEX.fire,LIGHT,.36,.5,8,.7)
    r.contact=emit(flame,TEX.spark,LIGHT,.2,3.2,0,1.4)
    r.contact.Acceleration=V(0,1,0)
    r.wake=emit(flame,TEX.spark,GOLD,.4,.5,40,1.5); r.wake.Acceleration=V(0,.5,0)
    local ta=new("Attachment",{Position=V(-.24,0,0)},r.model.PrimaryPart)
    local tb=new("Attachment",{Position=V(.24,0,0)},r.model.PrimaryPart)
    r.trail=new("Trail",{Attachment0=ta,Attachment1=tb,Lifetime=.65,FaceCamera=true,
        Color=ColorSequence.new(HOT,GOLD),LightEmission=1,LightInfluence=0,Texture=TEX.fire,
        Transparency=seq({{0,.45},{.55,.75},{1,1}}),WidthScale=seq({{0,1},{1,0}}),Enabled=false},r.model.PrimaryPart)
    r.light=new("PointLight",{Color=GOLD,Brightness=3,Range=23,Shadows=false},flame)
    for i=1,(low and 6 or 10) do
        local m=crystal(scene,"WanderingSoulShard",V(.13,.52,.13),C(ORIGIN),i%2==0 and LIGHT or GOLD)
        local aa=new("Attachment",{Position=V(0,.2,0)},m.PrimaryPart)
        local ab=new("Attachment",{Position=V(0,-.2,0)},m.PrimaryPart)
        local trail=new("Trail",{Attachment0=aa,Attachment1=ab,Lifetime=.5,FaceCamera=true,
            LightEmission=1,Color=ColorSequence.new(LIGHT,GOLD),Texture=TEX.spark,
            Transparency=seq({{0,.4},{.5,.7},{1,1}}),WidthScale=seq({{0,.5},{1,0}}),Enabled=false},m.PrimaryPart)
        local pieces={}
        for _,part in ipairs(m:GetDescendants()) do if part:IsA("BasePart") then pieces[#pieces+1]={obj=part,alpha=part.Transparency} end end
        r.shards[#r.shards+1]={model=m,trail=trail,parts=pieces,offset=V((i%2==0 and 1 or -1)*(2+i*.15),(i%4-1.5)*.5,math.sin(i*4)*1.2)}
    end
    for i=1,5 do r.streams[i]=ribbon(scene,ORIGIN,ORIGIN+V(0,1,0),i%2==0 and LIGHT or GOLD,.12) end
    r.visible={}
    for _,part in ipairs(r.model:GetDescendants()) do if part:IsA("BasePart") then r.visible[#r.visible+1]={obj=part,alpha=part.Transparency} end end
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
    environment.bats={}; environment.pathLights={}
    for _,n in ipairs({V(1,0,0),V(-1,0,0),V(0,1,0),V(0,-1,0),V(0,0,1),V(0,0,-1)}) do
        local wall=solid(scene,"OctoberNight",V(1,1,1),C(ORIGIN+n*430),Color3.fromRGB(10,12,24))
        new("SpecialMesh",{MeshType=Enum.MeshType.Brick,Scale=V(n.X~=0 and 2 or 870,n.Y~=0 and 2 or 870,n.Z~=0 and 2 or 870)},wall)
    end
    solid(scene,"CemeteryGround",V(500,2,500),C(ORIGIN+V(0,0,-35)),Color3.fromRGB(24,30,29),Enum.Material.Ground)
    solid(scene,"OldProcessionalPath",V(19,2,96),C(ORIGIN+V(0,1,22)),SHADOW,Enum.Material.Cobblestone)
    for side=-1,1,2 do
        solid(scene,"PathCurb",V(.7,.4,96),C(ORIGIN+V(side*9.7,2.1,22)),STONE,Enum.Material.Slate)
        for z=-15,65,10 do
            local lantern,core=pumpkin(scene,.8+(z%3)*.13,C(ORIGIN+V(side*10.8,2.1,z))*angle(0,-side*24,side*4),false)
            local lamp=new("PointLight",{Color=GOLD,Brightness=0,Range=14,Shadows=false},lantern.PrimaryPart)
            environment.pathLights[#environment.pathLights+1]={core=core,light=lamp,z=z}
            candle(scene,C(ORIGIN+V(side*9.1,2.3,z+1.4)),.6+(z%3)*.15)
        end
        for i=1,(low and 8 or 13) do
            local x=side*(17+(i%3)*10)
            local z=-35+i*8
            local grave=model("WeatheredGrave")
            solid(grave,"GravePlinth",V(4.8,.6,3),C(0,.3,0),STONE,Enum.Material.Slate)
            solid(grave,"Tombstone",V(3.4,5,.8),C(0,2.9,0),STONE,Enum.Material.Slate)
            triangle(grave,V(-1.7,5.4,0),V(1.7,5.4,0),V(0,6.6,0),STONE,.85,Enum.Material.Slate)
            solid(grave,"InsetPanel",V(2.65,3.3,.07),C(0,3,.46),SHADOW,Enum.Material.Slate)
            round(grave,"SkullRelief",V(.9,.95,.32),C(0,3.7,.6),Color3.fromRGB(148,147,135))
            for eye=-1,1,2 do round(grave,"EyeSocket",V(.22,.27,.07),C(eye*.22,3.8,.78),SHADOW) end
            for tooth=-1,1 do solid(grave,"ReliefTooth",V(.14,.25,.1),C(tooth*.2,3.13,.7),Color3.fromRGB(148,147,135)) end
            solid(grave,"BurialSlab",V(3.2,.25,6),C(0,.22,3),SHADOW,Enum.Material.Slate)
            grave:PivotTo(C(ORIGIN+V(x,1,z))*angle(0,-side*10+(i%3)*7,side*(i%2)*4))
        end
    end
    for i=1,(low and 8 or 13) do
        local side=i%2==0 and 1 or -1
        local base=ORIGIN+V(side*(28+(i%4)*14),1,-65+(i%6)*23)
        local height=20+(i%4)*7
        local p0=base
        local p1=base+V(side*2,height*.4,1)
        local p2=base+V(-side,height*.72,-1)
        local p3=base+V(side*2,height,-2)
        for j,pair in ipairs({{p0,p1},{p1,p2},{p2,p3}}) do
            bar(scene,"TwistedTreeTrunk",pair[1],pair[2],2.7-j*.55,2.6-j*.55,Color3.fromRGB(31,29,35),Enum.Material.Wood)
        end
        for branch=-1,1,2 do
            local elbow=p1+V(branch*7,height*.16,-3)
            local tip=elbow+V(branch*4,height*.24,2)
            bar(scene,"BareBranch",p1,elbow,.8,.8,Color3.fromRGB(31,29,35),Enum.Material.Wood)
            bar(scene,"CrookedTwig",elbow,tip,.4,.4,Color3.fromRGB(31,29,35),Enum.Material.Wood)
            bar(scene,"ForkedTwig",elbow,elbow+V(branch*6,2,4),.27,.27,Color3.fromRGB(31,29,35),Enum.Material.Wood)
        end
    end
    local moonCenter=ORIGIN+V(-52,91,-175)
    round(scene,"OctoberMoon",V(62,62,62),C(moonCenter),Color3.fromRGB(183,198,219),Enum.Material.Neon)
    for i=1,14 do
        local x=math.sin(i*2.4)*22
        local y=math.cos(i*1.7)*20
        if x*x+y*y<27*27 then
            local z=math.sqrt(31*31-x*x-y*y)
            local pos=moonCenter+V(x,y,z)
            round(scene,"LunarCrater",V(3+i%4,2+i%3,.15),CFrame.lookAt(pos,pos+V(x,y,z)),Color3.fromRGB(124,143,168),Enum.Material.Neon)
        end
    end
    for i=1,(low and 4 or 7) do
        local bat=model("FlyingBat")
        round(bat,"BatBody",V(.55,.9,.5),C(),Color3.fromRGB(32,24,40))
        round(bat,"BatHead",V(.49,.48,.42),C(0,.5,.05),Color3.fromRGB(40,28,46))
        for side=-1,1,2 do
            solid(bat,"BatEar",V(.18,.46,.16),C(side*.18,.84,.05),Color3.fromRGB(70,39,65),Enum.Material.SmoothPlastic,"Wedge")
            round(bat,"BatEye",V(.07,.07,.06),C(side*.13,.55,.27),GOLD,Enum.Material.Neon)
        end
        local wings={batWing(bat,-1,.65),batWing(bat,1,.65)}
        local parts={}
        for _,part in ipairs(bat:GetDescendants()) do if part:IsA("BasePart") then parts[#parts+1]={obj=part,alpha=part.Transparency} end end
        environment.bats[#environment.bats+1]={model=bat,wings=wings,parts=parts,side=i%2==0 and 1 or -1,seed=i}
    end
    for i=1,(low and 12 or 18) do
        local pos=V((i%2==0 and 1 or -1)*(12+(i%4)*11),-.4,-45+(i%7)*17)
        local a=anchor("GroundMist",C(ORIGIN+pos))
        local e=emit(a,TEX.smoke,LIGHT,7,1,2,12)
        e.Color=ColorSequence.new(Color3.fromRGB(91,107,120),Color3.fromRGB(53,66,83))
        e.LightEmission=.18; e.Acceleration=V(.15,0,0)
        e.Transparency=seq({{0,.88},{.2,.76},{.8,.87},{1,1}})
        e.Size=seq({{0,5},{.3,7},{1,8}})
        environment.clouds[#environment.clouds+1]=e
    end
    for _,pos in ipairs({V(-7,3,10),V(7,3,25),V(-8,3,45),V(7,8,-8)}) do
        local a=anchor("WanderingEmbers",C(ORIGIN+pos))
        local e=emit(a,TEX.spark,GOLD,.15,1,13,4)
        e.Acceleration=V(.1,.5,.1); environment.dust[#environment.dust+1]=e
    end
    local key=anchor("WarmPortraitLight",C(ORIGIN+V(-4,14,30)))
    new("PointLight",{Color=HOT,Range=45,Brightness=2.1,Shadows=false},key)
    local fill=anchor("MoonlightFill",C(ORIGIN+V(8,12,45)))
    new("PointLight",{Color=Color3.fromRGB(132,162,229),Range=40,Brightness=1.5,Shadows=false},fill)
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
    local batAlpha=phase(t,0,1)*(1-phase(t,13,15))
    for _,f in ipairs(environment.bats) do
        local i=f.seed
        local at=ORIGIN+V(f.side*(20+i*.8+math.sin(t*.65+i)*4),16+(i%4)*5+math.sin(t*1.4+i)*2,-20+i*9+t*2.4)
        local cf=C(at)*angle(math.sin(t+i)*8,t*9+i*47,f.side*12+math.sin(t*.75+i)*12)
        f.model:PivotTo(cf)
        for j,wing in ipairs(f.wings) do
            local side=j==1 and -1 or 1
            wing:PivotTo(cf*C(side*.2,.1,0)*angle(0,side*math.sin(t*10+i)*37,side*math.sin(t*10+i)*15))
        end
        for _,part in ipairs(f.parts) do part.obj.Transparency=1-(1-part.alpha)*batAlpha end
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
    local cf=C(position)*angle(0,mix(math.sin(t*.6)*12,180,arrive),math.sin(t*.6)*3*(1-arrive))
    relic.model:PivotTo(cf)
    for _,wing in ipairs(relic.wings) do
        local sweep=math.sin(t*5)*(1-arrive)*12+phase(t,15.7,16.8)*12
        wing.model:PivotTo(cf*C(wing.side*.78,-.08,-.05)*angle(0,wing.side*math.sin(t*5)*12*(1-arrive),-wing.side*sweep))
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
    gui=new("ScreenGui",{Name="Darling_HalloweenIntro",ResetOnSpawn=false,IgnoreGuiInset=false,DisplayOrder=100000,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},playerGui)
    flash=new("Frame",{Name="LightTransition",Size=UDim2.fromScale(1,1),Position=UDim2.fromOffset(0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=1},gui)
    local skip=new("TextButton",{
        Name="Skip",Text="Skip",Font=Enum.Font.GothamMedium,TextSize=17,
        TextColor3=Color3.fromRGB(255,218,158),TextTransparency=.04,
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
    scene=new("Folder",{Name="Darling_HalloweenCemetery"}) -- Detached until every model is positioned in space.
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
    Lighting.Ambient=Color3.fromRGB(94,98,124); Lighting.OutdoorAmbient=Color3.fromRGB(58,65,93)
    Lighting.Brightness=1.4; Lighting.ClockTime=.5; Lighting.FogStart=95; Lighting.FogEnd=340; Lighting.FogColor=Color3.fromRGB(21,24,43)
    Lighting.ExposureCompensation=.05
    bloom=new("BloomEffect",{Name="DarlingRelicBloom",Intensity=.5,Size=32,Threshold=1.1},Lighting)
    camera.CameraType=Enum.CameraType.Scriptable
    api.Status="playing"
    animate(0)
    scene.Parent=Workspace
    for _,e in ipairs(environment.clouds) do e:Emit(low and 7 or 12) end
    if CONFIG.Audio then
        audio.rumble=new("Sound",{Name="HalloweenAtmosphere",SoundId="rbxassetid://9114223171",Volume=0,Looped=true,PlaybackSpeed=.7},gui)
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
-- END DARLING / HALLOWEEN / THE HOLLOW LANTERN 4.0

end

function HalloweenCinematic.play(onComplete)
    HalloweenCinematic.stop()
    local ok, res = pcall(function()
        return runHalloweenCinematic(onComplete)
    end)
    if ok then
        activeApi = res
        return res
    else
        warn("[HalloweenCinematic] Error starting: " .. tostring(res))
    end
end

function HalloweenCinematic.stop()
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

return HalloweenCinematic
