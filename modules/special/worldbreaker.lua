--[[
    Darling Hub - Worldbreaker Cinematic Module (Version 1.3)
]]

local Worldbreaker = {}
local activeApi = nil

local function runWorldbreaker(onComplete)
-- WORLDBREAKER 2.4 / 40 segundos / archivo completo.
-- Pega desde esta linea hasta FIN WORLDBREAKER 2.4. X cancela.
local CONFIG = {
GiantHeight = 4800, EarthRadius = 900, SpaceAltitude = 60000, Duration = 40,
Quality = "High",
Audio = true, HideGameUI = true,
Music = "rbxassetid://90089940136467",
Impact = "rbxassetid://157878578", Roar = "rbxassetid://9069609200",
Rumble = "rbxassetid://9114223171",
}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
local player = Players.LocalPlayer
if not player then warn("[Worldbreaker] Ejecutar en el CLIENTE de Roblox."); return end
local env = _G
if type(getgenv) == "function" then local ok, e = pcall(getgenv); if ok and type(e) == "table" then env = e end end
local previousScene = env.DarlingSovereign or _G.DarlingSovereign
if type(previousScene)=="table" and type(previousScene.Stop)=="function" then pcall(previousScene.Stop) end
local old = env.DarlingWorldbreaker or _G.DarlingWorldbreaker
if type(old) == "table" and type(old.Stop) == "function" then pcall(old.Stop) end
local api = { IsPlaying = true, Version = 2.4, Status = "starting", Stage = "inicio" }
env.DarlingWorldbreaker, _G.DarlingWorldbreaker = api, api
env.DarlingWorldbreakerLastError, _G.DarlingWorldbreakerLastError = nil, nil
local V3, CF, PI = Vector3.new, CFrame.new, math.pi
local WHITE = Color3.fromRGB(255, 251, 231)
local GOLD = Color3.fromRGB(255, 198, 35)
local CYAN = Color3.fromRGB(108, 140, 255)
local PURPLE = Color3.fromRGB(160, 48, 255)
local METAL = Color3.fromRGB(65, 37, 91)
local rng, low = Random.new(), CONFIG.Quality == "Low"
local TEX = { spark = "rbxassetid://2581273950", mist = "rbxassetid://12865656309",
glint = "rbxassetid://94431438472232", plasma = "rbxasset://textures/particles/smoke_main.dds" }
local dead, accepting, bound, elapsed, started = false, true, false, 0, nil
local scene, gui, screenFlash, cam, character, root, humanoid, base
local cleanupItems, connections, hiddenParts, hiddenGuis, rigs = {}, {}, {}, {}, {}
local saved, incoming, effects, flags, S = {}, {}, {}, {}, {}
local bindName = "Worldbreaker_" .. HttpService:GenerateGUID(false)
local flashPower, shake = 0, 0
local function traceback(message)
local detail="[Worldbreaker / "..tostring(api.Stage).."] "..tostring(message)
if type(debug)=="table" and type(debug.traceback)=="function" then
local ok,result=pcall(debug.traceback,detail,2)
if ok then return result end
end
return detail
end
local function clamp(x, a, b) return math.max(a, math.min(b, x)) end
local function ease(x) x = clamp(x, 0, 1); return x*x*(3-2*x) end
local function phase(t,a,b) return ease((t-a)/(b-a)) end
local function mix(a,b,t) return a+(b-a)*t end
local function angles(x,y,z) return CFrame.Angles(math.rad(x),math.rad(y),math.rad(z)) end
local function out(x) return 1-(1-clamp(x,0,1))^4 end
local function world(x,y,z) return base * V3(x,y,z) end
local function space(x,y,z) return S.spaceBase * V3(x,y,z) end
local function keep(o) cleanupItems[#cleanupItems+1]=o; return o end
local function connect(signal, fn) local c=signal:Connect(fn); connections[#connections+1]=c; return c end
local function make(class, props, parent)
local obj=Instance.new(class)
for k,v in pairs(props or {}) do
local ok,err=pcall(function() obj[k]=v end)
if not ok then obj:Destroy(); error(class.."."..k..": "..tostring(err),0) end
end
obj.Parent=parent
if api.Status=="building" then
S.buildCount=(S.buildCount or 0)+1
if S.buildCount%160==0 then
task.wait()
if dead then error("Construccion cancelada",0) end
end
end
return obj
end
local function stop(reason)
if dead then return end
dead, accepting, api.IsPlaying = true, false, false
api.Status=reason=="finished" and "finished" or "stopped"
if reason and reason~="finished" and reason~="cancelled" then
api.LastError=tostring(reason)
env.DarlingWorldbreakerLastError=api.LastError
_G.DarlingWorldbreakerLastError=api.LastError
end
if bound then pcall(function() RunService:UnbindFromRenderStep(bindName) end) end
for _,c in ipairs(connections) do pcall(function() c:Disconnect() end) end
for _,o in ipairs(cleanupItems) do pcall(function() o:Destroy() end) end
for _,o in pairs(incoming) do pcall(function() o:Destroy() end) end
for p,v in pairs(hiddenParts) do pcall(function() p.LocalTransparencyModifier=v end) end
for g,v in pairs(hiddenGuis) do pcall(function() g.Enabled=v end) end
if saved.root then pcall(function() saved.root.Anchored=saved.anchored end) end
if saved.humanoid then pcall(function()
saved.humanoid.WalkSpeed=saved.walkSpeed; saved.humanoid.AutoRotate=saved.autoRotate
saved.humanoid.JumpPower=saved.jumpPower; saved.humanoid.JumpHeight=saved.jumpHeight
end) end
if saved.camera then pcall(function()
saved.camera.CameraType=saved.cameraType; saved.camera.CameraSubject=saved.subject
saved.camera.CFrame=saved.cameraCF; saved.camera.FieldOfView=saved.fov; saved.camera.Focus=saved.focus
end) end
for key,value in pairs(saved.lighting or {}) do pcall(function() Lighting[key]=value end) end
for obj,values in pairs(saved.atmospheres or {}) do
for key,value in pairs(values) do pcall(function() obj[key]=value end) end
end
for obj,value in pairs(saved.postFX or {}) do pcall(function() obj.Enabled=value end) end
if env.DarlingWorldbreaker==api then env.DarlingWorldbreaker=nil end
if _G.DarlingWorldbreaker==api then _G.DarlingWorldbreaker=nil end
if onComplete then pcall(onComplete) end
if reason and reason~="finished" and reason~="cancelled" then warn("[Worldbreaker] "..tostring(reason)) end
end
api.Stop=function() stop("cancelled") end
local function part(name,color,size,parent,class)
return make(class or "Part", { Name=name, Anchored=true, CanCollide=false, CanQuery=false,
CanTouch=false, CastShadow=false, Material=Enum.Material.Neon, Color=color,
Size=size or V3(1,1,1), Transparency=1,
TopSurface=Enum.SurfaceType.Smooth, BottomSurface=Enum.SurfaceType.Smooth }, parent or scene)
end
local function ball(name,color)
local p=part(name,color); p.Shape=Enum.PartType.Ball; return p
end
local function orb(p,position,size,alpha)
size=math.max(0.05,size); p.Size=V3(size,size,size); p.CFrame=CF(position); p.Transparency=1-clamp(alpha,0,1)
end
local function tube(p,a,b,width,alpha)
local len=(b-a).Magnitude
if len<0.001 or alpha<=0 then p.Transparency=1; return end
p.Shape=Enum.PartType.Cylinder
p.Size=V3(math.min(len,2048),math.max(0.03,width),math.max(0.03,width))
p.CFrame=CFrame.lookAt((a+b)*0.5,b)*angles(0,90,0)
p.Transparency=1-clamp(alpha,0,1)
end
local function flash(power,kick) flashPower=math.max(flashPower,power); shake=math.max(shake,kick or 0) end
local function sound(id,volume,looped)
if not CONFIG.Audio or id=="" then return nil end
return make("Sound",{SoundId=id,Volume=volume,Looped=looped or false},gui)
end
local function play(s) if s then pcall(function() s.TimePosition=0; s:Play() end) end end
local function event(name,time,fn)
if elapsed>=time and not flags[name] then flags[name]=true; fn() end
end
local function every(name,period,fn)
if not flags[name] or elapsed-flags[name]>=period then flags[name]=elapsed; fn() end
end
local function seq(points)
local result={}; for _,p in ipairs(points) do result[#result+1]=NumberSequenceKeypoint.new(p[1],p[2]) end
return NumberSequence.new(result)
end
local function emitter(parent,kind,color,size,speed,life,rate)
return make("ParticleEmitter",{
Texture=TEX[kind], Color=ColorSequence.new(WHITE,color), LightEmission=1,
LightInfluence=0, Lifetime=NumberRange.new(life*0.65,life),
Speed=NumberRange.new(speed*0.5,speed), SpreadAngle=Vector2.new(180,180),
Size=seq({{0,size*0.25},{0.15,size},{0.65,size*0.6},{1,0}}),
Transparency=seq({{0,0.1},{0.6,0.25},{1,1}}), Drag=1.5,
Rotation=NumberRange.new(-180,180), RotSpeed=NumberRange.new(-60,60),
Rate=(rate or 0)*(low and 0.45 or 1), Enabled=false,
},parent)
end
local function spray(position,color,size,count,speed,kind)
local holder=part("Burst",color); holder.CFrame=CF(position)
local e=emitter(holder,kind or "spark",color,size,speed,2.1,0)
e:Emit(math.floor(count*(low and 0.45 or 1)))
effects[#effects+1]={obj=holder,born=elapsed,life=2.5}
end
local function mist(position,size,color,count)
local p=part("LuminousVapor",color); p.CFrame=CF(position)
local e=emitter(p,"mist",color,size,size*0.3,4,0)
e.LightEmission=0.65; e.Drag=0.5; e.Acceleration=V3(0,10,0)
e.Size=seq({{0,size*0.2},{0.3,size},{1,size*1.6}})
e.Transparency=seq({{0,0.82},{0.25,0.68},{1,1}})
e:Emit(math.floor(count*(low and 0.5 or 1)))
effects[#effects+1]={obj=p,born=elapsed,life=4.2}
end
local function plasma(color,width,parent)
local a=part("PlasmaAnchorA",color,nil,parent)
local b=part("PlasmaAnchorB",color,nil,parent)
local aa=make("Attachment",{},a); local ab=make("Attachment",{},b)
local beam=make("Beam",{Attachment0=aa,Attachment1=ab,Texture=TEX.plasma,
TextureMode=Enum.TextureMode.Wrap,TextureLength=110,TextureSpeed=1.5,
Color=ColorSequence.new(WHITE,color),LightEmission=1,LightInfluence=0,
FaceCamera=true,Width0=width,Width1=width,Segments=24,
Transparency=NumberSequence.new(1)},a)
return {a=a,b=b,beam=beam}
end
local function drawPlasma(p,a,b,width,alpha,bend)
if (b-a).Magnitude<0.01 then p.beam.Transparency=NumberSequence.new(1); return end
local aim=CFrame.lookAt(a,b)*angles(0,90,0)
p.a.CFrame=aim; p.b.CFrame=aim+(b-a)
p.beam.Width0=width; p.beam.Width1=width*0.75
p.beam.CurveSize0=0; p.beam.CurveSize1=0
alpha=clamp(alpha,0,1)
p.beam.Transparency=seq({{0,1},{0.12,1-alpha*0.45},{0.4,1-alpha*0.8},{0.76,1-alpha*0.45},{1,1}})
end
local function bolt(color,count)
local b={pieces={},color=color,count=count or (low and 14 or 22)}
for i=1,b.count do b.pieces[i]={core=part("LightningCore",WHITE),glow=part("LightningCorona",color)} end
return b
end
local function drawBolt(b,a,z,width,alpha,seed)
if alpha<=0 then for _,p in ipairs(b.pieces) do p.core.Transparency=1; p.glow.Transparency=1 end; return end
local len=(z-a).Magnitude; if len<0.1 then return end
local axis=CFrame.lookAt(a,z); local previous=a
local frame=math.floor(elapsed*24)
for i,p in ipairs(b.pieces) do
local t=i/b.count
local jag=math.sin(t*PI)*len*0.035
local point=a+(z-a)*t+axis.RightVector*math.noise(i*3.7,frame,seed)*jag
+axis.UpVector*math.noise(seed,i*7.3,frame)*jag
tube(p.core,previous,point,width,alpha)
tube(p.glow,previous,point,width*3.5,alpha*0.24)
previous=point
end
end
local function cloneCharacter()
local arch=character.Archivable; character.Archivable=true
local ok,model=pcall(function() return character:Clone() end)
character.Archivable=arch
if not ok or not model then error("No se pudo copiar tu avatar real.") end
return model
end
local function prepareRig(model, scale, label, color)
keep(model)
model.Name = label
for _, obj in ipairs(model:GetDescendants()) do
if obj:IsA("LuaSourceContainer") or obj:IsA("Tool") or obj:IsA("Animator")
or obj:IsA("Sound") or obj:IsA("ParticleEmitter") or obj:IsA("Trail")
or obj:IsA("Beam") or obj:IsA("Highlight") or obj:IsA("BillboardGui")
or obj:IsA("ForceField") then obj:Destroy() end
end
local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
if not hrp then error("Avatar sin raiz: " .. label) end
model.PrimaryPart = hrp
local hum = model:FindFirstChildOfClass("Humanoid")
if hum then
hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
hum.AutoRotate = false
hum.BreakJointsOnDeath = false
hum.RequiresNeck = false
end
for _, p in ipairs(model:GetDescendants()) do
if p:IsA("BasePart") then
p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
p.LocalTransparencyModifier = 0
p.AssemblyLinearVelocity, p.AssemblyAngularVelocity = V3(0, 0, 0), V3(0, 0, 0)
end
end
local minY,maxY=math.huge,-math.huge
for _,p in ipairs(model:GetChildren()) do
if p:IsA("BasePart") and p~=hrp then
minY=math.min(minY,p.Position.Y-p.Size.Y*0.5)
maxY=math.max(maxY,p.Position.Y+p.Size.Y*0.5)
end
end
if scale then
model:ScaleTo(model:GetScale()*scale/math.max(1,maxY-minY))
end
scale=model:GetScale()
local rig = { model = model, root = hrp, parts = {}, edges = {}, loose = {}, scale = scale, alpha = -1, color = color }
local links, joints = {}, {}
local bottom = hrp.Position.Y
for _, obj in ipairs(model:GetDescendants()) do
if obj:IsA("BasePart") then
rig.parts[obj] = obj == hrp and 1 or obj.Transparency
if obj.Parent == model then bottom = math.min(bottom, obj.Position.Y - obj.Size.Y * 0.5) end
elseif obj:IsA("Decal") or obj:IsA("Texture") then
rig.parts[obj] = obj.Transparency
elseif obj:IsA("JointInstance") or obj:IsA("WeldConstraint") then
joints[#joints + 1] = obj
local a, b = obj.Part0, obj.Part1
if a and b and a:IsDescendantOf(model) and b:IsDescendantOf(model) then
local c0, c1 = a.CFrame:ToObjectSpace(b.CFrame), CF()
if obj:IsA("JointInstance") then c0, c1 = obj.C0, obj.C1 end
links[#links + 1] = { a = a, b = b, c0 = c0, c1 = c1,
name = obj.Name:gsub("%s", ""), motor = obj:IsA("Motor6D") }
end
end
end
rig.height = hrp.Position.Y - bottom
local reached = { [hrp] = true }
local changed = true
while changed do
changed = false
for _, link in ipairs(links) do
if reached[link.a] and not reached[link.b] then
rig.edges[#rig.edges + 1] = link; reached[link.b] = true; changed = true
elseif reached[link.b] and not reached[link.a] then
rig.edges[#rig.edges + 1] = { a = link.b, b = link.a, c0 = link.c1, c1 = link.c0, name = link.name, reverse = true, motor = link.motor }
reached[link.a] = true; changed = true
end
end
end
for p in pairs(rig.parts) do
if p:IsA("BasePart") and not reached[p] then rig.loose[p] = hrp.CFrame:ToObjectSpace(p.CFrame) end
end
for _, joint in ipairs(joints) do joint:Destroy() end
for _, obj in ipairs(model:GetDescendants()) do if obj:IsA("Constraint") then obj:Destroy() end end
rig.highlight = make("Highlight", {
FillColor = color, OutlineColor = WHITE, FillTransparency = 0.97,
OutlineTransparency = 0.7, DepthMode = Enum.HighlightDepthMode.Occluded, Enabled = false,
}, model)
for p in pairs(rig.parts) do p.Transparency = 1 end
model.Parent = scene
rigs[#rigs + 1] = rig
return rig
end
local function visibility(rig, alpha)
alpha = clamp(alpha, 0, 1)
if math.abs(rig.alpha - alpha) < 0.0001 then return end
rig.alpha = alpha
for p, original in pairs(rig.parts) do p.Transparency = 1 - (1 - original) * alpha end
rig.highlight.Enabled = false
rig.highlight.OutlineTransparency = 1 - 0.3 * alpha
end
local function buildEarth(parent, radius, lowQuality)
local earthModel=make("Model",{Name="Earth_SculptedGlobe"},parent)
local ocean=part("Earth_Ocean",Color3.fromRGB(21,78,151),V3(radius*2,radius*2,radius*2),earthModel)
ocean.Shape=Enum.PartType.Ball
ocean.Material=Enum.Material.SmoothPlastic
ocean.Reflectance=0.12
ocean.Transparency=1
ocean.CFrame=CF()
earthModel.PrimaryPart=ocean
local cloudModel=make("Model",{Name="Earth_CloudDeck"},earthModel)
local cloudRoot=part("CloudPivot",Color3.new(1,1,1),V3(0.1,0.1,0.1),cloudModel)
cloudRoot.CFrame=CF(); cloudRoot.Transparency=1; cloudModel.PrimaryPart=cloudRoot
local data={model=earthModel,root=ocean,ocean=ocean,radius=radius,surfaceRadius=radius,landParts={},cloudParts={},minLandPlaneDistance=math.huge,
cloudModel=cloudModel,records={},lastAlpha=-1,lastCorrupt=-1,fragmentParts={},baseOcean=ocean.Color}
local continents={
{name="NorthAmerica",points={{-168,72},{-150,70},{-136,60},{-128,51},{-124,42},{-116,30},{-110,23},{-98,16},{-92,18},{-86,21},{-82,25},{-81,32},{-75,37},{-65,45},{-55,53},{-64,61},{-78,63},{-90,73},{-110,75},{-130,71}}},
{name="CentralAmerica",points={{-98,19},{-91,18},{-87,16},{-85,11},{-79,9},{-77,8},{-79,6},{-84,9},{-88,14},{-95,16}}},
{name="SouthAmerica",points={{-81,11},{-73,12},{-61,8},{-51,3},{-35,-6},{-38,-15},{-47,-27},{-58,-35},{-67,-55},{-73,-51},{-75,-36},{-80,-15},{-80,-4}}},
{name="Greenland",points={{-58,60},{-45,61},{-24,71},{-18,79},{-32,84},{-53,82},{-66,74}}},
{name="Africa",points={{-17,37},{-5,36},{10,37},{24,32},{34,31},{34,22},{43,12},{51,12},{45,2},{41,-10},{35,-18},{30,-30},{18,-35},{12,-22},{8,-5},{-2,5},{-13,8},{-17,18}}},
{name="Eurasia",points={{-10,36},{-10,44},{-3,48},{0,52},{10,56},{4,58},{5,70},{25,72},{40,68},{55,71},{80,76},{110,76},{140,70},{170,66},{179,60},{165,56},{150,60},{138,54},{140,42},{130,38},{120,30},{122,20},{110,20},{108,10},{102,1},{99,8},{96,17},{88,22},{80,8},{75,8},{69,25},{58,25},{52,17},{43,12},{35,29},{26,40},{20,40},{15,36},{12,45},{3,43}}},
{name="Australia",points={{113,-22},{121,-13},{132,-11},{138,-16},{146,-15},{153,-27},{148,-39},{138,-38},{131,-32},{117,-35}}},
{name="Britain",points={{-6,50},{0,51},{-1,55},{-4,59},{-6,57},{-4,54}}},
{name="Ireland",points={{-10,51},{-6,52},{-6,55},{-9,55}}},
{name="Madagascar",points={{44,-13},{50,-14},{49,-21},{45,-26},{43,-21}}},
{name="Japan",points={{130,31},{135,34},{140,36},{145,44},{142,46},{139,39},{134,36}}},
{name="NewZealand",points={{166,-46},{170,-41},{174,-40},{176,-36},{179,-37},{175,-42},{169,-47}}},
{name="Indonesia",points={{95,5},{101,2},{106,-5},{112,-7},{116,-8},{113,-10},{105,-7},{99,-1}}},
{name="Borneo",points={{109,7},{118,7},{119,0},{114,-4},{109,-1}}},
{name="NewGuinea",points={{131,-1},{140,-2},{150,-7},{147,-10},{138,-7},{132,-4}}},
{name="Cuba",points={{-85,23},{-78,22},{-74,20},{-78,20},{-83,21}}},
}
local function cross2(a,b,c)
return (b[1]-a[1])*(c[2]-a[2])-(b[2]-a[2])*(c[1]-a[1])
end
local function contains(p,a,b,c)
local x,y,z=cross2(a,b,p),cross2(b,c,p),cross2(c,a,p)
return x>=-0.0001 and y>=-0.0001 and z>=-0.0001
end
local function triangulate(points)
local polygon={}; for _,p in ipairs(points) do polygon[#polygon+1]={p[1],p[2]} end
local area=0
for i,p in ipairs(polygon) do local q=polygon[i%#polygon+1]; area=area+p[1]*q[2]-q[1]*p[2] end
if area<0 then
local reversed={}; for i=#polygon,1,-1 do reversed[#reversed+1]=polygon[i] end; polygon=reversed
end
local triangles={}; local watchdog=0
while #polygon>3 and watchdog<2000 do
watchdog=watchdog+1; local clipped=false
for i=1,#polygon do
local a,b,c=polygon[(i-2)%#polygon+1],polygon[i],polygon[i%#polygon+1]
if cross2(a,b,c)>0.00001 then
local blocked=false
for j,p in ipairs(polygon) do
if j~=i and j~=(i-2)%#polygon+1 and j~=i%#polygon+1 and contains(p,a,b,c) then blocked=true; break end
end
if not blocked then
triangles[#triangles+1]={a,b,c}; table.remove(polygon,i); clipped=true; break
end
end
end
if not clipped then break end
end
if #polygon==3 then triangles[#triangles+1]={polygon[1],polygon[2],polygon[3]} end
return triangles
end
local function sphere(lon,lat,r)
lon,lat=math.rad(lon),math.rad(lat)
return V3(math.sin(lon)*math.cos(lat),math.sin(lat),-math.cos(lon)*math.cos(lat))*r
end
local function terrainColor(name,lon,lat)
if name=="Greenland" or name=="Antarctica" or lat>71 then return Color3.fromRGB(222,235,235) end
if (name=="Africa" and lat>13 and lat<33) or (lon>35 and lon<59 and lat>15 and lat<30)
or (name=="Australia" and lon>119 and lon<144 and lat<-18) then
return Color3.fromRGB(184,154,91)
end
if name=="SouthAmerica" and lat>-15 and lat<5 then return Color3.fromRGB(35,113,69) end
if lat>50 then return Color3.fromRGB(97,131,98) end
return Color3.fromRGB(65,128,77)
end
local function record(p,original,cloud)
p.Transparency=1
data.records[#data.records+1]={part=p,transparency=original,color=p.Color,cloud=cloud}
if cloud then data.cloudParts[#data.cloudParts+1]=p
else data.landParts[#data.landParts+1]=p; data.fragmentParts[#data.fragmentParts+1]=p end
end
local function triangle(a,b,c,color,name)
local center=a.Unit+b.Unit+c.Unit
if center.Magnitude<0.00001 then return end
local normal=center.Unit
local planeDistance=radius*1.006
local da,db,dc=a.Unit:Dot(normal),b.Unit:Dot(normal),c.Unit:Dot(normal)
if math.min(da,db,dc)<0.5 then return end
a,b,c=a.Unit*(planeDistance/da),b.Unit*(planeDistance/db),c.Unit*(planeDistance/dc)
if (b-a):Cross(c-a).Magnitude<0.00001 then return end
data.minLandPlaneDistance=math.min(data.minLandPlaneDistance,planeDistance)
local thickness=math.max(0.06,radius*0.003)
data.surfaceRadius=math.max(data.surfaceRadius,a.Magnitude+thickness*0.5,b.Magnitude+thickness*0.5,c.Magnitude+thickness*0.5)
local ab,ac,bc=b-a,c-a,c-b
local ab2,ac2,bc2=ab:Dot(ab),ac:Dot(ac),bc:Dot(bc)
if ab2>ac2 and ab2>bc2 then a,c=c,a elseif ac2>ab2 and ac2>bc2 then a,b=b,a end
ab,ac,bc=b-a,c-a,c-b
local right=ac:Cross(ab)
if right.Magnitude<0.00001 or bc.Magnitude<0.00001 then return end
right=right.Unit
local back=bc.Unit; local up=bc:Cross(right).Unit
local height=math.abs(ab:Dot(up))
if height<0.01 then return end
local w1=part(name.."_Terrain",color,V3(thickness,height,math.max(0.03,math.abs(ab:Dot(back)))),earthModel,"WedgePart")
w1.CFrame=CFrame.fromMatrix((a+b)*0.5,right,up,back)
w1.Material=Enum.Material.SmoothPlastic
local w2=part(name.."_Terrain",color,V3(thickness,height,math.max(0.03,math.abs(ac:Dot(back)))),earthModel,"WedgePart")
w2.CFrame=CFrame.fromMatrix((a+c)*0.5,-right,up,-back)
w2.Material=Enum.Material.SmoothPlastic
record(w1,0,false); record(w2,0,false)
end
local budget=2000
local maxEdge=lowQuality and 38 or 20
local drawn=0
local function patch(a,b,c,name,depth)
local function distance(p,q)
local dx=(p[1]-q[1])*math.cos(math.rad((p[2]+q[2])*0.5))
local dy=p[2]-q[2]; return dx*dx+dy*dy
end
local ab,bc,ca=distance(a,b),distance(b,c),distance(c,a)
if math.max(ab,bc,ca)>maxEdge*maxEdge and depth<7 and drawn<budget-20 then
local x,y,z=a,b,c
if bc>ab and bc>=ca then x,y,z=b,c,a elseif ca>ab and ca>bc then x,y,z=c,a,b end
local mid={(x[1]+y[1])*0.5,(x[2]+y[2])*0.5}
patch(x,mid,z,name,depth+1); patch(mid,y,z,name,depth+1)
return
end
drawn=drawn+1
local lon,lat=(a[1]+b[1]+c[1])/3,(a[2]+b[2]+c[2])/3
local col=terrainColor(name,lon,lat)
local shade=0.025+0.05*(0.5+0.5*math.sin(lon*3+lat*7))
col=col:Lerp(Color3.new(1,1,1),shade)
local r=radius
triangle(sphere(a[1],a[2],r),sphere(b[1],b[2],r),sphere(c[1],c[2],r),col,name)
end
for _,region in ipairs(continents) do
for _,t in ipairs(triangulate(region.points)) do patch(t[1],t[2],t[3],region.name,0) end
end
local capSegments=lowQuality and 14 or 22
for i=1,capSegments do
local lon0=(i-1)*360/capSegments-180; local lon1=i*360/capSegments-180
local lat0=-73+math.sin(i*2.4)*3; local lat1=-73+math.sin((i+1)*2.4)*3
triangle(sphere(lon0,lat0,radius*1.023),sphere(lon1,lat1,radius*1.023),V3(0,-radius*1.012,0),Color3.fromRGB(222,234,239),"Antarctica")
end
local clusters=lowQuality and 9 or 17
data.cloudRadius=math.max(radius*1.055,data.surfaceRadius+radius*0.01)
for i=1,clusters do
local longitude=(i*137.508)%360-180
local latitude=math.sin(i*2.17)*54
local normal=sphere(longitude,latitude,1)
local east=V3(-normal.Z,0,normal.X).Unit
local north=normal:Cross(east).Unit
local center=normal*data.cloudRadius
for j=1,lowQuality and 2 or 3 do
local offset=(j-2)*radius*0.06
local position=center+east*offset+north*(math.sin(i+j)*radius*0.025)
local p=part("Earth_CloudWisp",Color3.fromRGB(243,249,255),
V3(radius*(0.12+0.035*(j%2)),radius*0.012,radius*(0.035+0.015*(i%3))),cloudModel)
p.Shape=Enum.PartType.Ball
p.Material=Enum.Material.SmoothPlastic
p.CFrame=CFrame.fromMatrix(position,east,normal,-north)
p.CastShadow=false
record(p,0.28+(j%2)*0.12,true)
end
end
data.instanceCount=#data.landParts+#data.cloudParts+2
data.surfaceTriangleCount=drawn+capSegments
data.samplePoint=function(longitude,latitude,altitude)
return sphere(longitude,latitude,radius+(altitude or 0))
end
return data
end
local function updateEarth(data,frame,elapsed,alpha,corrupted)
alpha=math.max(0,math.min(1,alpha or 1))
corrupted=math.max(0,math.min(1,corrupted or 0))
local spin=CFrame.Angles(math.rad(-12),math.rad(elapsed*1.5),math.rad(8))
data.model:PivotTo(frame*spin)
data.cloudModel:PivotTo(frame*spin*CFrame.Angles(0,math.rad(elapsed*0.7),0))
data.worldFrame=frame*spin
if math.abs(alpha-data.lastAlpha)>0.003 or math.abs(corrupted-data.lastCorrupt)>0.008 then
data.ocean.Transparency=1-alpha
data.ocean.Color=data.baseOcean:Lerp(Color3.fromRGB(235,173,48),corrupted*0.4)
for _,record in ipairs(data.records) do
record.part.Transparency=1-(1-record.transparency)*alpha
local charged=record.cloud and Color3.fromRGB(255,242,189) or Color3.fromRGB(240,182,57)
record.part.Color=record.color:Lerp(charged,corrupted*(record.cloud and 0.6 or 0.73))
end
data.lastAlpha=alpha; data.lastCorrupt=corrupted
end
end
local function poseEarthRig(rig, frame, t, isWitness)
rig.root.CFrame = frame
local p = {}
local breathe = math.sin(t * 1.35) * 1.15
local emerge = 1 - phase(t, 6.8, 10.2)
local reach = phase(t, 10.5, 15.8)
local hold = phase(t, 15.8, 20)
local drawBack = phase(t, 25.8, 28.45)
local crush = phase(t, 29.43, 29.75)
local release = 1 - phase(t, 33.8, 37.0)
local recoil = t >= 29.75 and math.exp(-(t - 29.75) * 7.5) or 0
local tension = math.sin(t * 23) * phase(t, 26, 29.43) * (1 - crush) * 0.42
if isWitness then
p.Neck = angles(16 * phase(t, 3, 7) + breathe, 0, 0)
p.RightShoulder = angles(5, 0, 4)
p.LeftShoulder = angles(5, 0, -4)
else
local stance = phase(t, 6.5, 11)
p.RootJoint = angles(-4 * reach * release + 4 * recoil, 4 * reach * release, 0)
p.Root = angles(-2 * reach * release + 2 * recoil, 0, 0)
p.Waist = angles(-5 * reach * release + 7 * recoil, 9 * reach * release, 0)
p.Neck = angles(-12 * reach * release + breathe, -7 * reach * release, 0)
p.RightHip = angles(-3 * stance, 0, 3 * stance)
p.LeftHip = angles(3 * stance, 0, -3 * stance)
p.RightKnee = angles(-3 * stance, 0, 0)
p.LeftKnee = angles(-3 * stance, 0, 0)
p.RightShoulder = angles(
(18 * emerge + 67 * reach - 12 * drawBack + 14 * crush - 8 * recoil + tension) * release,
18 * reach * release,
(42 * emerge - 7 * reach - 3 * crush) * release
)
p.RightElbow = angles((12 * reach + 18 * drawBack - 12 * crush + 6 * recoil) * release, 0, 0)
p.RightWrist = angles((-12 * reach - 16 * drawBack + 27 * crush - 11 * recoil) * release, 0, -8 * reach * release)
p.LeftShoulder = angles((12 * emerge + 20 * reach + 11 * drawBack - 6 * crush) * release, -5 * hold, (-42 * emerge - 15 * reach) * release)
p.LeftElbow = angles((32 * reach + 12 * drawBack) * release, 0, 0)
p.LeftWrist = angles(-10 * reach * release, 0, 9 * reach * release)
end
for _, edge in ipairs(rig.edges) do
local rotation = (edge.motor and p[edge.name]) or CF()
local basis = edge.c0 - edge.c0.Position
local transform = basis:Inverse() * rotation * basis
if edge.reverse then transform = transform:Inverse() end
edge.b.CFrame = edge.a.CFrame * edge.c0 * transform * edge.c1:Inverse()
end
for bodyPart, relative in pairs(rig.loose) do
bodyPart.CFrame = frame * relative
end
local hand = rig.model:FindFirstChild("RightHand") or rig.model:FindFirstChild("Right Arm") or rig.root
local palm = hand.CFrame * CF(0, -hand.Size.Y * 0.43, -hand.Size.Z * 0.18)
local grip = clamp(0.10 * drawBack + 0.90 * crush, 0, 1)
local data = rig.earthGesture
if not data then
data = { segments = {}, tips = {} }
rig.earthGesture = data
end
data.hand = hand
data.palmCF = palm
data.palmPosition = palm.Position
data.grip = grip
data.castStrength = reach * release
data.fingerAlpha = isWitness and 0 or phase(t, 11.5, 14) * release
data.crush = crush
local unit = hand.Size.X
local segmentIndex = 0
for finger = 1, 4 do
local x = (finger - 2.5) * unit * 0.21
local length = unit * ({ 0.61, 0.79, 0.76, 0.57 })[finger]
local curl = mix(7, 69 + finger * 2, grip)
local spread = (finger - 2.5) * mix(5, 0.7, grip)
local joint = palm * CF(x, 0, 0) * angles(0, 0, spread)
for phalanx = 1, 3 do
local a = joint.Position
joint = joint * angles(curl * (phalanx == 1 and 0.72 or 1), 0, 0)
joint = joint * CF(0, -length * ({ 0.43, 0.33, 0.24 })[phalanx], 0)
segmentIndex = segmentIndex + 1
data.segments[segmentIndex] = {
a = a, b = joint.Position,
width = unit * mix(0.11, 0.067, (phalanx - 1) / 2),
}
end
data.tips[finger] = joint.Position
end
local thumb = palm * CF(-unit * 0.53, unit * 0.14, unit * 0.06) * angles(24 + 30 * grip, 0, mix(-48, -82, grip))
for phalanx = 1, 2 do
local a = thumb.Position
thumb = thumb * angles(mix(15, 54, grip), 0, 0) * CF(0, -unit * 0.30, 0)
segmentIndex = segmentIndex + 1
data.segments[segmentIndex] = { a = a, b = thumb.Position, width = unit * (phalanx == 1 and 0.13 or 0.10) }
end
data.tips[5] = thumb.Position
return data
end
local function trailOn(part0,color,width)
local a=make("Attachment",{Position=V3(-width*0.5,0,0)},part0)
local b=make("Attachment",{Position=V3(width*0.5,0,0)},part0)
return make("Trail",{Attachment0=a,Attachment1=b,Lifetime=0.38,MinLength=0.1,
FaceCamera=true,LightEmission=1,Texture=TEX.plasma,TextureLength=20,
Color=ColorSequence.new(WHITE,color),Transparency=seq({{0,0.5},{0.4,0.75},{1,1}}),
WidthScale=NumberSequence.new(1,0),Enabled=false},part0)
end
local function updateEffects()
for i=#effects,1,-1 do
local e=effects[i]
if elapsed-e.born>=e.life then e.obj:Destroy(); table.remove(effects,i) end
end
end
local function energyAccent(name)
local model=make("Model",{Name=name},scene)
local faces={}
for i=1,2 do
local p=part("GoldenFacet",Color3.fromRGB(205,152,56),V3(1,1,1),model,"WedgePart")
p.Material=Enum.Material.Metal; p.Reflectance=0.14
faces[i]=p
end
return {model=model,faces=faces,seam=plasma(GOLD,2,model)}
end
local function drawAccent(accent,frame,width,length,alpha)
for i,p in ipairs(accent.faces) do
local sign=i==1 and 1 or -1
p.Size=V3(math.max(0.1,width*0.45),math.max(0.1,length*0.5),math.max(0.1,width*0.7))
p.CFrame=frame*CF(sign*width*0.18,sign*length*0.25,0)*(i==1 and CF() or angles(180,0,180))
p.Transparency=1-clamp(alpha,0,1)
end
drawPlasma(accent.seam,frame*V3(0,-length*0.5,-width*0.38),frame*V3(0,length*0.5,-width*0.38),math.max(1.2,width*0.16),alpha*0.9,0)
end
local function buildArrivalDetails()
S.arrival={}; S.tipFX={}; S.fingerArcs={}
local targets={}
for _,name in ipairs({"Head","UpperTorso","Torso","LowerTorso","RightUpperArm","LeftUpperArm","Right Arm","Left Arm","RightUpperLeg","LeftUpperLeg","Right Leg","Left Leg"}) do
local p=S.giant.model:FindFirstChild(name)
if p then targets[#targets+1]=p end
end
if #targets==0 then targets[1]=S.giant.root end
for i=1,low and 14 or 24 do
local target=targets[(i-1)%#targets+1]
local anchor=part("MaterializingDust",PURPLE)
anchor.CFrame=CF(space(0,400,-2800))
local dust=emitter(anchor,"glint",GOLD,8+(i%3)*3,35,0.85,12)
S.arrival[i]={target=target,model=energyAccent("ArrivalSplinter"),anchor=anchor,dust=dust,
offset=V3(math.sin(i*4.3)*0.35,math.cos(i*2.9)*0.36,-0.56),delay=(i%7)*0.38,
trail=trailOn(anchor,PURPLE,3+(i%3))}
end
for i=1,5 do
local anchor=part("FingertipEmitter",PURPLE)
anchor.CFrame=CF(space(0,400,-2800))
local dust=emitter(anchor,"spark",GOLD,5,48,0.6,15)
local vapor=emitter(anchor,"mist",GOLD,14,18,0.45,8)
vapor.Transparency=seq({{0,0.9},{0.3,0.76},{1,1}})
S.tipFX[i]={anchor=anchor,dust=dust,vapor=vapor,trail=trailOn(anchor,GOLD,3)}
end
for i=1,2 do S.fingerArcs[i]=bolt(GOLD,low and 5 or 8) end
end
local function updateArrivalDetails(t,gesture,giantAlpha)
for i,fx in ipairs(S.arrival) do
local start=2.65+fx.delay
local p=phase(t,start,start+3.7)
local target=fx.target.CFrame*(fx.offset*fx.target.Size)
local scatter=base.RightVector*(math.sin(i*3.1)*(560+(i%4)*140))+V3(0,350+(i%5)*120,0)+base.LookVector*(130+(i%3)*80)
local position=target+scatter*(1-p)+base.RightVector*(math.sin(p*PI)*math.sin(i)*100)
local alpha=phase(t,start,start+0.45)*(1-phase(t,start+3,start+3.8))
drawAccent(fx.model,CF(position)*angles(i*31+p*120,i*47+p*90,i*23),14+(i%4)*5,55+(i%5)*18,alpha)
fx.anchor.CFrame=CF(position)
fx.dust.Enabled=alpha>0.1
fx.trail.Enabled=alpha>0.1 and p<0.95
if p>0.95 and not fx.finished then
fx.finished=true
if t<8.8 then fx.dust:Emit(low and 5 or 9) end
end
end
local active=gesture.fingerAlpha*giantAlpha*(1-phase(t,30.3,32))
for i,fx in ipairs(S.tipFX) do
fx.anchor.CFrame=CF(gesture.tips[i])
fx.dust.Enabled=active>0.15; fx.vapor.Enabled=active>0.3
fx.trail.Enabled=active>0.3 and t>25.8 and t<30.3
end
local pulse=(0.18+0.32*math.sin(t*15)^6+phase(t,27,29.7)*0.3)*active
drawBolt(S.fingerArcs[1],gesture.tips[1],gesture.tips[2],1.4,pulse,181)
drawBolt(S.fingerArcs[2],gesture.tips[5],gesture.tips[1],1.2,pulse*0.8,197)
end
local function buildLightningWeb(radius)
local web={root=part("PlanetLightningFrame",GOLD),nodes={},edges={},radius=radius}
local count=low and 34 or 58
for i=1,count do
local y=1-2*(i-0.5)/count
local a=i*2.39996323+rng:NextNumber(-0.1,0.1)
local r=math.sqrt(1-y*y)
web.nodes[i]=V3(math.cos(a)*r,y,math.sin(a)*r)
end
local used={}
for i,node in ipairs(web.nodes) do
local nearest={}
for j,other in ipairs(web.nodes) do
if i~=j then nearest[#nearest+1]={index=j,distance=(node-other).Magnitude} end
end
table.sort(nearest,function(a,b) return a.distance<b.distance end)
for n=1,3 do
local j=nearest[n].index
local key=math.min(i,j)..":"..math.max(i,j)
if not used[key] then
used[key]=true
local edge={start=node,finish=web.nodes[j],pieces={},cores={},points={},phase=rng:NextNumber(0,6.28)}
local steps=low and 3 or 4
for k=0,steps do
local a=k/steps
local direction=(node*(1-a)+web.nodes[j]*a).Unit
local point=make("Attachment",{Position=direction*(radius+3)},web.root)
edge.points[k+1]={attachment=point,direction=direction,t=a}
if k>0 then
edge.pieces[k]=make("Beam",{
Attachment0=edge.points[k].attachment,Attachment1=point,
FaceCamera=true,Segments=1,Width0=1,Width1=1,
Color=ColorSequence.new(WHITE,GOLD),LightEmission=1,LightInfluence=0,
Texture=TEX.plasma,TextureMode=Enum.TextureMode.Wrap,TextureLength=14,
TextureSpeed=7,Transparency=NumberSequence.new(1),
},web.root)
edge.cores[k]=make("Beam",{
Name="WhiteHotLightning",Attachment0=edge.points[k].attachment,Attachment1=point,
FaceCamera=true,Segments=1,Width0=0.2,Width1=0.1,
Color=ColorSequence.new(WHITE),LightEmission=1,LightInfluence=0,
Transparency=NumberSequence.new(1),
},web.root)
end
end
web.edges[#web.edges+1]=edge
end
end
end
return web
end
local function updateWeb(web,frame,t,power,handPosition)
web.root.CFrame=frame
local propagation=phase(t,13,23.8)
local flickerFrame=math.floor(t*22)
local change=web.lastFrame~=flickerFrame
web.lastFrame=flickerFrame
local impactDirection=(frame:Inverse()*handPosition).Unit
for i,edge in ipairs(web.edges) do
local middle=(edge.start+edge.finish).Unit
local threshold=(1-middle:Dot(impactDirection))*0.36
local active=clamp((propagation-threshold)*5,0,1)*power
local intensity=0.64+0.36*math.sin(t*17+edge.phase)^2
for k,beam in ipairs(edge.pieces) do
local width=(5+phase(t,20,28)*16)*intensity
beam.Width0=width; beam.Width1=width*0.75
beam.Transparency=NumberSequence.new(1-active*intensity)
local core=edge.cores[k]
core.Width0=width*0.22; core.Width1=width*0.13
core.Transparency=NumberSequence.new(1-active*0.95)
end
if change and active>0.01 then
for k,p in ipairs(edge.points) do
local noise=V3(math.noise(i*2.3,k,flickerFrame),math.noise(k,i*4.9,flickerFrame),math.noise(flickerFrame,k,i*3.7))
local dir=(p.direction+noise*0.032*math.sin(p.t*PI)).Unit
p.attachment.Position=dir*(web.radius+3+math.sin(t*4+i)*0.6)
end
end
end
end
local function buildSpaceStage()
S.spaceBase=base+V3(0,CONFIG.SpaceAltitude,0)
S.backdrop={}; S.stars={}
local extent=14000
local walls={
{V3(extent,0,0),V3(8,extent*2,extent*2)},
{V3(-extent,0,0),V3(8,extent*2,extent*2)},
{V3(0,extent,0),V3(extent*2,8,extent*2)},
{V3(0,-extent,0),V3(extent*2,8,extent*2)},
{V3(0,0,extent),V3(extent*2,extent*2,8)},
{V3(0,0,-extent),V3(extent*2,extent*2,8)},
}
for _,wall in ipairs(walls) do
local p=part("DeepSpaceBackdrop",Color3.new(0,0,0))
p.CFrame=S.spaceBase*CF(wall[1]); p.Material=Enum.Material.SmoothPlastic
make("SpecialMesh",{MeshType=Enum.MeshType.Brick,Scale=wall[2]},p)
S.backdrop[#S.backdrop+1]=p
end
local count=low and 90 or 180
for i=1,count do
local y=1-2*(i-0.5)/count; local a=i*2.39996323
local direction=V3(math.cos(a)*math.sqrt(1-y*y),y,math.sin(a)*math.sqrt(1-y*y))
local p=ball("DistantStar",i%7==0 and Color3.fromRGB(162,174,255) or WHITE)
local size=4+(i%5)*2.8
p.Size=V3(size,size,size); p.CFrame=CF(space(0,0,-800)+direction*(10500+(i%7)*220))
S.stars[i]=p
end
end
local function buildFracturedPlanet()
S.crust={}; S.debris={}
local radius=CONFIG.EarthRadius
local columns,rows=low and 8 or 10,low and 5 or 6
local function node(row,column)
local j=column%columns
local latitude=-PI/2+PI*row/rows
latitude=latitude+math.sin(j*5.7+row*3.2)*0.105*math.cos(latitude)
local longitude=j*2*PI/columns+math.sin(j*4.7+row*2.9)*0.13*math.cos(latitude)
return V3(math.cos(latitude)*math.cos(longitude),math.sin(latitude),math.cos(latitude)*math.sin(longitude))
end
local function facet(chunk,a,b,c,color,thickness,neon)
local ab,ac,bc=b-a,c-a,c-b
if ab:Cross(ac).Magnitude<0.01 then return end
local ab2,ac2,bc2=ab:Dot(ab),ac:Dot(ac),bc:Dot(bc)
if ab2>ac2 and ab2>bc2 then a,c=c,a elseif ac2>ab2 and ac2>bc2 then a,b=b,a end
ab,ac,bc=b-a,c-a,c-b
local right=ac:Cross(ab).Unit; local back=bc.Unit; local up=bc:Cross(right).Unit
local height=math.abs(ab:Dot(up))
for k=1,2 do
local vertex=k==1 and b or c
local depth=math.max(0.05,math.abs((vertex-a):Dot(back)))
local p=part(neon and "BasaltInterior" or "OceanCrust",color,V3(thickness,math.max(0.05,height),depth),chunk.model,"WedgePart")
p.CFrame=CFrame.fromMatrix((a+vertex)*0.5,k==1 and right or -right,up,k==1 and back or -back)
p.Material=neon and Enum.Material.Slate or Enum.Material.SmoothPlastic
chunk.parts[#chunk.parts+1]={part=p,color=color,mantle=neon}
end
end
for row=0,rows-1 do for column=0,columns-1 do
local dirs={node(row,column),node(row,column+1),node(row+1,column+1),node(row+1,column)}
local direction=(dirs[1]+dirs[2]+dirs[3]+dirs[4]).Unit
local center=direction*radius*0.96
local model=make("Model",{Name="TectonicPlate"},scene)
local pivot=part("PlatePivot",PURPLE,V3(1,1,1),model); pivot.CFrame=CF(center); model.PrimaryPart=pivot
local index=#S.crust+1
local chunk={model=model,pivot=pivot,center=center,direction=direction,parts={},edges={},
speed=490+(index%9)*58,spin=V3(4+index%8*2,-13+index%7*4,7-index%5*3)}
local vertices={}; for j,d in ipairs(dirs) do vertices[j]=d*radius*1.002 end
local blue=Color3.fromRGB(15+index%4*5,48+index%3*8,103+index%5*9)
facet(chunk,vertices[1],vertices[2],vertices[3],blue,radius*0.035,false)
facet(chunk,vertices[1],vertices[3],vertices[4],blue,radius*0.035,false)
local rock=Color3.fromRGB(37+index%4*5,31+index%3*4,44+index%4*6)
facet(chunk,vertices[1]*0.78,vertices[2]*0.78,vertices[3]*0.78,rock,radius*0.012,true)
facet(chunk,vertices[1]*0.78,vertices[3]*0.78,vertices[4]*0.78,rock,radius*0.012,true)
for j=1,4 do
local va,vb=vertices[j],vertices[j%4+1]
facet(chunk,va,vb,vb*0.78,rock,radius*0.009,true)
facet(chunk,va,vb*0.78,va*0.78,rock,radius*0.009,true)
local previous=make("Attachment",{Position=va-center},pivot)
for segment=1,3 do
local fraction=segment/3
local point=va:Lerp(vb,fraction)+direction*(math.sin(fraction*PI)*radius*0.012*math.sin(index*3+j*4))
local nextPoint=make("Attachment",{Position=point-center},pivot)
chunk.edges[#chunk.edges+1]=make("Beam",{Attachment0=previous,Attachment1=nextPoint,FaceCamera=true,Segments=1,
Color=ColorSequence.new(WHITE,GOLD),LightEmission=1,LightInfluence=0,
Width0=5,Width1=2,Transparency=NumberSequence.new(1)},pivot)
previous=nextPoint
end
end
chunk.trail=trailOn(pivot,PURPLE,radius*0.012)
chunk.embers=emitter(pivot,"spark",GOLD,3,85,2.8,0)
S.crust[index]=chunk
end end
for _,source in ipairs(S.earth.landParts) do
local direction=source.Position.Unit; local closest,best=nil,-2
for _,chunk in ipairs(S.crust) do
local score=direction:Dot(chunk.direction)
if score>best then closest,best=chunk,score end
end
local p=source:Clone(); p.Name="BrokenEarthCrust"; p.Transparency=1; p.Parent=closest.model
closest.parts[#closest.parts+1]={part=p,color=p.Color,land=true}
end
for _,chunk in ipairs(S.crust) do
chunk.model:PivotTo(S.spaceBase*CF(0,400,450)*CF(chunk.center))
end
local fragments=low and 36 or 72
for i=1,fragments do
local y=1-2*(i-0.5)/fragments; local a=i*2.39996323
local direction=V3(math.cos(a)*math.sqrt(1-y*y),y,math.sin(a)*math.sqrt(1-y*y))
local p=part("SplinteredRock",Color3.fromRGB(80+i%4*7,65+i%5*5,93+i%3*9),V3(8+i%5*4,18+i%7*7,12+i%4*6),scene,"WedgePart")
p.Material=Enum.Material.Slate; p.CFrame=CF(space(0,400,450))
S.debris[i]={part=p,direction=direction,speed=780+(i%11)*83,trail=trailOn(p,PURPLE,2.5)}
end
end
local function updatePlanetBreakup(t,planetFrame)
if t<29.75 then return end
if not S.fractureFrame then S.fractureFrame=planetFrame end
local age=math.max(0,t-30.1)
local reveal=phase(t,29.75,30.02)
local fade=1-phase(t,35,38.3)
local motion=age<0.45 and age*0.22 or 0.099+(age-0.45)*(1+0.065*(age-0.45))
local separation=CONFIG.EarthRadius*0.035*phase(t,29.75,30.1)
for i,chunk in ipairs(S.crust) do
local direction=S.fractureFrame:VectorToWorldSpace(chunk.direction)
local distance=separation+chunk.speed*motion
local frame=(S.fractureFrame*CF(chunk.center)+direction*distance)*angles(chunk.spin.X*motion,chunk.spin.Y*motion,chunk.spin.Z*motion)
chunk.model:PivotTo(frame)
for _,r in ipairs(chunk.parts) do
r.part.Transparency=1-reveal*fade
r.part.Color=r.color
end
for _,e in ipairs(chunk.edges) do
e.Width0=4+5*(1-phase(t,30.1,30.8)); e.Width1=e.Width0*0.45
e.Transparency=NumberSequence.new(1-reveal*(1-phase(t,30.35,31.4))*(0.55+0.35*math.sin(t*9+i)^2))
end
chunk.trail.Enabled=t>30.2 and t<32.7
if age>0 and not chunk.emitted then chunk.emitted=true; chunk.embers:Emit(low and 8 or 16) end
end
for i,d in ipairs(S.debris) do
local direction=S.fractureFrame:VectorToWorldSpace(d.direction)
local position=S.earthPos+direction*(CONFIG.EarthRadius*0.88+d.speed*motion)
d.part.CFrame=CF(position)*angles(i*29+motion*43,i*11+motion*61,i*23+motion*19)
d.part.Transparency=1-phase(t,30.1,30.3)*(1-phase(t,34.5,37.5))
d.trail.Enabled=t>30.15 and t<32.5
end
end
local function updateSpaceStage(t)
local alpha=t>=2.45 and t<38.4 and 1 or 0
for _,p in ipairs(S.backdrop) do p.Transparency=1-alpha end
for i,p in ipairs(S.stars) do p.Transparency=1-alpha*(0.5+0.45*math.sin(i+t*0.45)^2) end
end
local function buildSolarCharge()
S.solar={}
local count=low and 12 or 24
for i=1,count do
local y=1-2*(i-0.5)/count; local a=i*2.39996323
local direction=V3(math.cos(a)*math.sqrt(1-y*y),y,math.sin(a)*math.sqrt(1-y*y))
local anchor=part("SolarCoronaEmitter",GOLD)
anchor.CFrame=CF(space(0,400,450))
local sparks=emitter(anchor,"spark",GOLD,9,130,1.1,42)
sparks.EmissionDirection=Enum.NormalId.Front; sparks.SpreadAngle=Vector2.new(18,18)
local glitter=emitter(anchor,"glint",WHITE,12,55,0.65,14)
glitter.EmissionDirection=Enum.NormalId.Front; glitter.SpreadAngle=Vector2.new(26,26)
S.solar[i]={anchor=anchor,direction=direction,sparks=sparks,glitter=glitter,
rate=sparks.Rate,glitterRate=glitter.Rate,plume=plasma(GOLD,10),accent=energyAccent("SolarFiligree")}
end
end
local function updateSolarCharge(t,frame)
local power=phase(t,13,18)*(1-phase(t,29.95,30.2))
local surge=phase(t,21,29.5)
for i,fx in ipairs(S.solar) do
local direction=frame:VectorToWorldSpace(fx.direction)
local position=frame*(fx.direction*(S.web.radius+18))
fx.anchor.CFrame=CFrame.lookAt(position,position+direction*100)
fx.sparks.Enabled=power>0.05; fx.glitter.Enabled=power>0.2
fx.sparks.Rate=fx.rate*power*(0.6+surge*1.2)
fx.glitter.Rate=fx.glitterRate*power*(1+surge)
local pulse=0.5+0.5*math.sin(t*3.7+i*2.1)^2
local tip=position+direction*(65+surge*150+pulse*85)
drawPlasma(fx.plume,position,tip,8+surge*12,power*pulse*0.8,0)
local drift=(t*0.7+i*0.137)%1
local shard=position+direction*(30+drift*(90+surge*140))
local alpha=power*math.sin(drift*PI)*0.95
drawAccent(fx.accent,CFrame.lookAt(shard,shard+direction)*angles(90,t*32+i*15,0),9+surge*6,48+surge*35,alpha)
end
end
local function buildWorldScene()
api.Stage="espacio"
buildSpaceStage()
api.Stage="copia del avatar"
S.actor=prepareRig(cloneCharacter(),nil,player.Name.."_Witness",PURPLE)
api.Stage="escala del avatar"
S.giant=prepareRig(cloneCharacter(),CONFIG.GiantHeight,player.Name.."_Worldbreaker",PURPLE)
buildArrivalDetails()
api.Stage="continentes"
S.earth=buildEarth(scene,CONFIG.EarthRadius,low)
api.Stage="placas del planeta"
buildFracturedPlanet()
api.Stage="rayos y particulas"
S.web=buildLightningWeb(S.earth.surfaceRadius or CONFIG.EarthRadius)
buildSolarCharge()
S.tethers={}
for i=1,4 do S.tethers[i]={bolt=bolt(GOLD,low and 12 or 20),plasma=plasma(GOLD,9)} end
S.handSpark=part("PalmEmitter",GOLD)
S.palmParticles=emitter(S.handSpark,"spark",GOLD,11,120,0.8,65)
S.palmLight=make("PointLight",{Color=GOLD,Range=60,Brightness=0,Shadows=false},S.handSpark)
S.fingers={}
for i=1,14 do S.fingers[i]=energyAccent("FingerFacet") end
S.flareJets={}
local jets=low and 5 or 8
for i=1,jets do
local y=1-2*(i-0.5)/jets; local a=i*2.39996323
local direction=V3(math.cos(a)*math.sqrt(1-y*y),y,math.sin(a)*math.sqrt(1-y*y))
S.flareJets[i]={plasma=plasma(GOLD,24),core=plasma(WHITE,4),fork=bolt(GOLD,low and 14 or 22),
direction=direction,length=1800+(i%5)*270,delay=(i%4)*0.07}
end
S.audio={music=sound(CONFIG.Music,0.6),impact=sound(CONFIG.Impact,1.05),rumble=sound(CONFIG.Rumble,0.32,true),
roar=sound(CONFIG.Roar,0.7),snap=sound("rbxasset://sounds/switch.wav",1.2)}
end
local function breakEarth()
if S.exploded then return end
S.exploded=true
for _,chunk in ipairs(S.crust) do
for _,edge in ipairs(chunk.edges) do edge.Color=ColorSequence.new(WHITE,PURPLE) end
end
for _,jet in ipairs(S.flareJets) do
jet.plasma.beam.Color=ColorSequence.new(WHITE,PURPLE)
for _,piece in ipairs(jet.fork.pieces) do piece.glow.Color=PURPLE end
end
spray(S.earthPos,WHITE,18,low and 38 or 65,750,"spark")
for i=1,8 do
local direction=S.flareJets[(i-1)%#S.flareJets+1].direction
local p=S.earthPos+direction*CONFIG.EarthRadius*0.75
spray(p,PURPLE,6,low and 24 or 45,500,"spark")
end
end
local function faceView(p)
local head=S.giant.model:FindFirstChild("Head") or S.giant.root
local size=math.max(head.Size.X,head.Size.Y,head.Size.Z)
local frame=head.CFrame
local focus=head.Position+frame.UpVector*(head.Size.Y*0.025)
local position=focus+frame.LookVector*(size*mix(1.9,1.65,p))+frame.UpVector*(size*0.15)+frame.RightVector*(size*mix(0.16,-0.08,p))
return position,focus
end
local function worldCamera(t,dt)
local pos,focus,fov,roll
roll=0
if t<0.65 then
local p=phase(t,0,0.65)
pos=world(mix(7,4,p),5,14)
focus=world(0,4,0); fov=66
elseif t<2.45 then
local p=clamp((t-0.65)/1.8,0,1)^2
pos=world(4,5,14):Lerp(world(0,24,330),p)
focus=world(0,4,0); fov=mix(66,78,p)
elseif t<6.4 then
local p=phase(t,2.45,6.4)
pos=space(0,620,1700):Lerp(space(1100,1300,3500),p)
focus=S.earthPos:Lerp(space(0,550,-650),p); fov=mix(78,54,p)
elseif t<8.7 then
local p=phase(t,6.4,8.7)
pos=space(1100,1300,3500):Lerp(space(2300,1150,3400),p)
focus=space(0,550,-650):Lerp(space(0,650,-650),p); fov=mix(54,52,p)
elseif t<12.6 then
local p=phase(t,8.7,12.6)
pos,focus=faceView(p); fov=44
elseif t<16 then
local p=phase(t,12.6,16)
local close=S.handPos+base.RightVector*2000-base.LookVector*2600+V3(0,450,0)
local portrait,face=faceView(1)
pos=portrait:Lerp(close,p)
focus=face:Lerp(S.handPos:Lerp(S.earthPos,0.65),p); fov=mix(44,59,p)
elseif t<23 then
local p=phase(t,16,23); local a=-0.6+p*1.65
pos=S.earthPos+base.RightVector*(math.sin(a)*2750)-base.LookVector*(math.cos(a)*2750)+V3(0,650+120*math.sin(p*PI),0)
focus=S.earthPos; fov=61; roll=2*math.sin(p*PI)
elseif t<27 then
local p=phase(t,23,27)
pos=space(-2500,1300,3800):Lerp(space(1900,1150,3900),p)
focus=space(0,550,-500); fov=55
elseif t<29.4 then
local p=phase(t,27,29.2)
local close=S.handPos+base.RightVector*850-base.LookVector*700+V3(0,300,0)
pos=space(1900,1150,3900):Lerp(close,p)
focus=space(0,550,-500):Lerp(S.handPos,p); fov=mix(55,46,p)
elseif t<30.55 then
local p=phase(t,29.4,30.55)
pos=space(1400,600,2800):Lerp(space(1550,650,2900),p)
focus=S.earthPos; fov=56
elseif t<32.2 then
local p=phase(t,30.55,32.2)
pos=space(1550,650,2900):Lerp(space(3600,1500,6200),p)
focus=S.earthPos:Lerp(space(0,400,-500),p); fov=mix(56,78,p); roll=2*math.sin(p*PI)
elseif t<36.8 then
local p=phase(t,32.2,36.8); local a=0.56+p*0.61
pos=space(math.sin(a)*7200,mix(1500,1300,p),450+math.cos(a)*7200)
focus=space(0,400,-500); fov=mix(78,62,p)
elseif t<38.4 then
local p=phase(t,36.8,38.4)
pos=space(math.sin(1.17)*7200,1300,450+math.cos(1.17)*7200):Lerp(space(3100,1700,1500),p)
focus=space(0,400,-500):Lerp(space(0,1500,-2800),p); fov=mix(62,58,p)
else
local p=phase(t,38.4,40)
pos=saved.cameraCF.Position-saved.cameraCF.LookVector*(8*(1-p))
focus=saved.cameraCF.Position+saved.cameraCF.LookVector*30
fov=saved.fov
end
if t>=2.45 and t<30.1 and not (t>=8.7 and t<12.6) then
local delta=pos-S.earthPos
local clearance=CONFIG.EarthRadius*(t<6.4 and 1.8 or 1.55)
if delta.Magnitude<clearance then pos=S.earthPos+delta.Unit*clearance end
end
local offset=V3(math.noise(t*24,1),math.noise(9,t*26),0)*shake
cam.CameraType=Enum.CameraType.Scriptable
cam.CFrame=CFrame.lookAt(pos,focus)*angles(0,0,roll)*CF(offset)
cam.Focus=CF(focus); cam.FieldOfView=fov
shake=math.max(0,shake-dt*14)
end
local function animateWorld(dt)
if dead then return end
if not root.Parent or humanoid.Health<=0 or Workspace.CurrentCamera~=cam then stop("cancelled"); return end
elapsed=os.clock()-started
local t=elapsed
if t>=CONFIG.Duration then stop("finished"); return end
local exitFade=1-phase(t,37.7,38.4)
flashPower=math.max(0,flashPower-dt*5)
screenFlash.BackgroundTransparency=1-clamp(flashPower,0,0.38)
local goldenCharge=phase(t,13,24)*(1-phase(t,29.95,30.4))
S.bloom.Intensity=0.18+flashPower*0.32+goldenCharge*0.65
S.bloom.Threshold=1.1-goldenCharge*0.24
S.grade.Brightness=0
S.grade.TintColor=Color3.fromRGB(255,251,244)
local portraitLight=phase(t,8.3,8.7)*(1-phase(t,12.6,13.2))
Lighting.Ambient=Color3.fromRGB(150,140,165):Lerp(Color3.fromRGB(210,202,190),portraitLight)
local giantAlpha=phase(t,3.3,8.7)*exitFade
local y=S.giant.height-2000+40*math.sin(t*0.45)
S.giantPos=space(0,y,-2800)
local giantFrame=S.spaceBase*CF(0,y,-2800)*angles(0,180,0)
poseEarthRig(S.actor,base*CF(0,S.actor.height,0),t,true)
local gesture=poseEarthRig(S.giant,giantFrame,t,false)
visibility(S.actor,t>=38.4 and phase(t,38.4,38.8) or 1-phase(t,1.8,2.45)); visibility(S.giant,giantAlpha)
updateArrivalDetails(t,gesture,giantAlpha)
local hand=S.giant.model:FindFirstChild("RightHand") or S.giant.model:FindFirstChild("Right Arm") or S.giant.root
local handFrame=gesture.palmCF
S.handPos=gesture.palmPosition
S.earthPos=space(0,400+math.sin(t*0.4)*12,450)
local earthFrame=S.spaceBase*CF(0,400+math.sin(t*0.4)*12,450)*angles(12,20+t*2.8,0)
local earthAlpha=phase(t,2.2,2.45)*(1-phase(t,29.75,30.1))
local corruption=phase(t,18,29.5)*0.22
updateEarth(S.earth,earthFrame,t,earthAlpha,corruption)
local planetFrame=S.earth.worldFrame or earthFrame
updatePlanetBreakup(t,planetFrame)
local power=phase(t,12.8,14)*(1-phase(t,29.9,30.35))
updateWeb(S.web,planetFrame,t,power,S.handPos)
updateSolarCharge(t,planetFrame)
local cast=phase(t,10,14)*(1-phase(t,30.1,32))
for i,fx in ipairs(S.tethers) do
local a=i*PI/2+t*0.4
local facing=(planetFrame:Inverse()*S.handPos).Unit
local side=facing:Cross(V3(0,1,0))
if side.Magnitude<0.01 then side=V3(1,0,0) else side=side.Unit end
local up=side:Cross(facing).Unit
local localImpact=(facing+side*(math.cos(a)*0.32)+up*(math.sin(a)*0.32)).Unit*(S.web.radius+3)
local destination=planetFrame*localImpact
local origin=gesture.tips[i] or S.handPos
local active=power*(0.65+0.35*math.sin(t*8+i)^2)
drawBolt(fx.bolt,origin,destination,3.5+phase(t,21,29)*7,active,i*13)
drawPlasma(fx.plasma,origin,destination,16+phase(t,21,29)*22,active*0.75,0)
end
S.handSpark.CFrame=CF(S.handPos)
S.palmParticles.Enabled=cast>0.1
S.palmLight.Brightness=cast*7
local fingerAlpha=gesture.fingerAlpha*giantAlpha
for i,segment in ipairs(gesture.segments) do
local length=(segment.b-segment.a).Magnitude
if length>0.01 then
local frame=CFrame.lookAt((segment.a+segment.b)*0.5,segment.b)*angles(90,0,0)
drawAccent(S.fingers[i],frame,clamp(segment.width*0.22,5,20),length*0.78,fingerAlpha*0.85)
end
end
local blastAge=math.max(0,t-30.1)
for i,jet in ipairs(S.flareJets) do
local age=math.max(0,blastAge-jet.delay)
local jetAlpha=phase(age,0,0.09)*(1-phase(age,0.65,1.9))
local pressure=phase(t,28.8,29.7)*(1-phase(t,29.9,30.1))*math.sin(t*13+i)^8
local distance=CONFIG.EarthRadius+jet.length*out(age/1.25)
local near=S.earthPos+jet.direction*(age>0 and distance*0.28 or CONFIG.EarthRadius)
local far=S.earthPos+jet.direction*(age>0 and distance or CONFIG.EarthRadius+pressure*180)
local width=5+26*(1-phase(age,0.2,1.6))
drawPlasma(jet.plasma,near,far,width,jetAlpha*0.65+pressure*0.22,0)
drawPlasma(jet.core,near,far,width*0.14,jetAlpha*0.8+pressure*0.25,0)
local branch=far+base.RightVector*math.sin(i*4.1)*400+V3(0,math.cos(i*2.3)*330,0)
drawBolt(jet.fork,near,branch,2+2*(1-phase(age,0.2,1.2)),jetAlpha*0.8+pressure*0.45,i*29)
end
event("summon",0.65,function()
play(S.audio.rumble)
spray(world(0,4,0),PURPLE,0.7,22,9,"spark")
end)
event("planet",2.45,function()
play(S.audio.impact)
end)
event("firstContact",13,function()
flash(0.05,2); spray(S.handPos,WHITE,8,45,120,"spark")
end)
event("fullGrip",24,function()
play(S.audio.roar); shake=math.max(shake,4)
end)
event("silence",28.7,function()
if S.audio.music then S.audio.music.Volume=0.07 end
if S.audio.rumble then S.audio.rumble.Volume=0 end
end)
event("crush",29.75,function()
play(S.audio.snap); flash(0.05,4)
spray(S.handPos,WHITE,10,45,160,"spark")
for _,fx in ipairs(S.tipFX) do fx.dust:Emit(12); fx.vapor:Emit(3) end
end)
event("worldBreak",30.1,function()
flash(0.36,16); play(S.audio.impact); play(S.audio.roar)
if S.audio.music then S.audio.music.Volume=0.75 end
breakEarth()
end)
if t>14 and t<29.8 then every("surfaceDischarge",0.24,function()
local i=math.floor(t*5)%#S.web.nodes+1
local at=planetFrame*(S.web.nodes[i]*(S.web.radius+5))
spray(at,GOLD,7+corruption*9,20,100,"spark")
end) end
if S.audio.music and t>36.5 then S.audio.music.Volume=0.7*exitFade end
worldCamera(t,dt)
updateSpaceStage(t)
updateEffects()
end
local function prepareLighting()
saved.lighting={}; saved.atmospheres={}; saved.postFX={}
for _,key in ipairs({"ClockTime","Brightness","Ambient","OutdoorAmbient","FogStart","FogEnd","FogColor","ExposureCompensation"}) do saved.lighting[key]=Lighting[key] end
for _,o in ipairs(Lighting:GetChildren()) do
if o:IsA("PostEffect") then saved.postFX[o]=o.Enabled; o.Enabled=false end
if o:IsA("Atmosphere") then
saved.atmospheres[o]={Density=o.Density,Haze=o.Haze,Glare=o.Glare}
o.Density=0; o.Haze=0; o.Glare=0
end
end
Lighting.ClockTime=0; Lighting.Brightness=2
Lighting.Ambient=Color3.fromRGB(150,135,175); Lighting.OutdoorAmbient=Color3.fromRGB(145,150,180)
Lighting.ExposureCompensation=0.05; Lighting.FogStart=100000; Lighting.FogEnd=200000
Lighting.FogColor=Color3.new(0,0,0)
S.bloom=keep(make("BloomEffect",{Name="WorldbreakerBloom",Intensity=0.16,Size=22,Threshold=1.1},Lighting))
S.grade=keep(make("ColorCorrectionEffect",{Name="WorldbreakerGrade",Brightness=0,Contrast=0.12,Saturation=0.08,TintColor=Color3.fromRGB(255,249,255)},Lighting))
end
local function setup()
api.Stage="personaje"
character=player.Character or player.CharacterAdded:Wait()
if dead then return end
root=character:WaitForChild("HumanoidRootPart",8)
humanoid=character:FindFirstChildOfClass("Humanoid")
local playerGui=player:WaitForChild("PlayerGui",8)
cam=Workspace.CurrentCamera
if dead then return end
if not root or not humanoid or humanoid.Health<=0 or not playerGui or not cam then error("Espera a aparecer antes de ejecutar.") end
api.Status="building"
scene=keep(make("Folder",{Name="DarlingWorldbreaker_Local"}))
gui=keep(make("ScreenGui",{Name="WorldbreakerFullScreenVFX",IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=999999},playerGui))
local skipBtn = make("TextButton", {
    Name = "SkipButton",
    Size = UDim2.fromOffset(80, 32),
    Position = UDim2.new(1, -20, 0, 16),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Text = "Skip",
    Font = Enum.Font.GothamMedium,
    TextSize = 16,
    TextColor3 = WHITE,
    TextStrokeTransparency = 0.5,
    ZIndex = 1000000,
    Active = true
}, gui)
connect(skipBtn.MouseButton1Click, function()
    api.Stop()
end)
screenFlash=make("Frame",{Name="LightPulse",Size=UDim2.fromScale(1,1),BorderSizePixel=0,
BackgroundColor3=WHITE,BackgroundTransparency=1},gui)
connect(UserInputService.InputBegan,function(input,processed)
if not processed and input.KeyCode==Enum.KeyCode.X then api.Stop() end
end)
connect(player.CharacterRemoving,function(c) if c==character then api.Stop() end end)
connect(humanoid.Died,api.Stop)
task.spawn(function()
local fallbacks={spark="rbxasset://textures/particles/sparkles_main.dds",mist="rbxasset://textures/particles/smoke_main.dds",glint="rbxasset://textures/particles/sparkles_main.dds",plasma=""}
for key,id in pairs(TEX) do
pcall(function() ContentProvider:PreloadAsync({id},function(_,status)
if status==Enum.AssetFetchStatus.Failure and fallbacks[key]~=nil then
TEX[key]=fallbacks[key]
if scene and scene.Parent then
for _,fx in ipairs(scene:GetDescendants()) do
if (fx:IsA("Beam") or fx:IsA("Trail") or fx:IsA("ParticleEmitter")) and fx.Texture==id then
fx.Texture=fallbacks[key]
end
end
end
end
end) end)
if dead then return end
end
end)
if dead then return end
local look=root.CFrame.LookVector*V3(1,0,1)
if look.Magnitude<0.001 then look=V3(0,0,-1) end
local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={character,scene}
local hit=Workspace:Raycast(root.Position+V3(0,2,0),V3(0,-160,0),params)
local ground=hit and hit.Position or root.Position-V3(0,3,0)
base=CFrame.lookAt(ground,ground+look.Unit)
buildWorldScene()
if dead then return end
api.Stage="camara y controles"
saved.camera=cam; saved.cameraType=cam.CameraType; saved.cameraCF=cam.CFrame
saved.fov=cam.FieldOfView; saved.focus=cam.Focus; saved.subject=cam.CameraSubject
saved.root=root; saved.anchored=root.Anchored
saved.humanoid=humanoid; saved.walkSpeed=humanoid.WalkSpeed; saved.autoRotate=humanoid.AutoRotate
saved.jumpPower=humanoid.JumpPower; saved.jumpHeight=humanoid.JumpHeight
root.Anchored=true; humanoid.WalkSpeed=0; humanoid.JumpPower=0; humanoid.JumpHeight=0; humanoid.AutoRotate=false
local function hide(p) if p:IsA("BasePart") then hiddenParts[p]=p.LocalTransparencyModifier; p.LocalTransparencyModifier=1 end end
for _,p in ipairs(character:GetDescendants()) do hide(p) end
connect(character.DescendantAdded,hide)
if CONFIG.HideGameUI then
for _,g in ipairs(playerGui:GetChildren()) do
if g:IsA("ScreenGui") and g~=gui and g.Enabled then hiddenGuis[g]=true; g.Enabled=false end
end
end
api.Stage="iluminacion"
prepareLighting()
cam.CameraType=Enum.CameraType.Scriptable
play(S.audio.music)
api.Stage="primer cuadro"
api.Status="playing"; started=os.clock()
animateWorld(0)
if dead then return end
scene.Parent=Workspace
api.Stage="animacion"
RunService:BindToRenderStep(bindName,Enum.RenderPriority.Camera.Value+10,function(dt)
local ok,err=xpcall(function() animateWorld(dt) end,traceback)
if not ok then stop(err); error(err,0) end
end)
bound=true
task.delay(CONFIG.Duration+3,function() if not dead then stop("finished") end end)
end
print("[Worldbreaker 2.4] Inicio recibido; preparando escena.")
local ok,err=xpcall(setup,traceback)
if not ok and not dead then stop(err); error(err,0) end
return api
-- FIN WORLDBREAKER 2.4

end

function Worldbreaker.play(onComplete)
    Worldbreaker.stop()
    local ok, res = pcall(function()
        return runWorldbreaker(onComplete)
    end)
    if ok then
        activeApi = res
        return res
    else
        warn("[Worldbreaker] Error starting: " .. tostring(res))
    end
end

function Worldbreaker.stop()
    if activeApi and type(activeApi.Stop) == "function" then
        pcall(function() activeApi.Stop("user_stop") end)
    end
    local env = (getgenv and getgenv()) or _G
    local old = env.DarlingWorldbreaker or _G.DarlingWorldbreaker
    if type(old) == "table" and type(old.Stop) == "function" then
        pcall(function() old.Stop("user_stop") end)
    end
    activeApi = nil
end

return Worldbreaker
