--[[
    Darling Hub - Comeback Cinematic (Admin Carmesi V5)
    64-second cinematic anime cutscene with crimson lightning and giant.
]]

local ComebackCinematic = {
    ActiveSession = nil,
}

local function runAnimation(customConfig, onComplete)
    --[[
      COMEBACK ADMIN CARMESI V5 — adaptacion directa de admin_cinematic / Celestial Sovereign.
      Conserva su invocacion, rayo, estrella facetada, salida del gigante y primeras camaras.
      Rayo y estrella rojos; espada contra el suelo; sin admins. Cielo abierto y brillo anime.
      64 segundos; sin texto en pantalla. Ojos y aura rojos al terminar.
      Ejecutar TODO el archivo en el cliente. Tambien admite LocalScript en tu experiencia.
      X / Backspace cancela. _G.DarlingSovereign.Stop() retira tambien el aura final.
      Reejecutar limpia la anterior. Solo visible en tu cliente.
      Modelos: avatar real de mygame43 (912348), sus accesorios originales y espada esculpida.
      Tu avatar real aparece en la invocacion y en el final. Montaje y duracion conservados.
      V5: alcanza el mango, cierra los dedos, saca la espada y la sostiene con ambas manos.
      Entrada: caida, apoyo, impulso, avance con estelas y carga de energia.
      Solo quedan los accesorios originales de mygame43; se retira la corona agregada.
      Geometria propia: EditableMesh si esta habilitado, triangulos si no lo esta.
      Las texturas/audio publicadas de la plantilla tienen alternativa o son opcionales.
      No registra archivos .png/.mesh ni ejecuta Lua remoto. Delta real aun no probado.
    ]]
    local CONFIG = {
        GiantHeight = 650, Duration = 64, KeepAura = true,
        EyeSeparation = .19, EyeHeight = .08, EyeForward = .53,
        Audio = true, HideGameUI = true,
        Music = "rbxassetid://90089940136467",
        Impact = "rbxassetid://157878578", Roar = "rbxassetid://9069609200",
        Rumble = "rbxassetid://9114223171",
    }
    if type(customConfig) == "table" then
        for k, v in pairs(customConfig) do CONFIG[k] = v end
    end
    CONFIG.Duration=math.clamp(tonumber(CONFIG.Duration) or 64,60,110)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")
    local ContentProvider = game:GetService("ContentProvider")
    local player = Players.LocalPlayer
    if not player then warn("[Sovereign] Ejecutar en el CLIENTE de Roblox."); return end
    local env = _G
    if type(getgenv) == "function" then local ok, e = pcall(getgenv); if ok and type(e) == "table" then env = e end end
    local stopped,needsWait={},false
    for _,namespace in ipairs({env,_G}) do
        for _,key in ipairs({"DarlingSovereign","RedEclipseComeback"}) do
            local old=namespace[key]
            if type(old)=="table" and type(old.Stop)=="function" and not stopped[old] then
                stopped[old]=true;pcall(old.Stop);needsWait=true
            end
        end
    end
    -- Solo se limpian contenedores propios de estas versiones; nunca accesorios del avatar.
    for _,obj in ipairs(Workspace:GetChildren()) do
        if obj.Name=="DarlingSovereign_Local" or obj.Name=="__RedEclipseStage_"..player.UserId
            or (obj:IsA("Model") and obj.Name=="FittedCrimsonCrown") then
            obj:Destroy();needsWait=true
        end
    end
    local oldGui=player:FindFirstChildOfClass("PlayerGui")
    if oldGui then
        local marker=oldGui:FindFirstChild("__RedEclipseComeback")
        if marker then
            local cancel=marker:FindFirstChild("Stop")
            if cancel and cancel:IsA("BindableEvent") then pcall(function() cancel:Fire() end) end
            marker:Destroy();needsWait=true
        end
    end
    if needsWait then task.wait(.05) end
    local api = { IsPlaying = true, Version = "AdminCrimson5", Status = "starting" }
    env.DarlingSovereign, _G.DarlingSovereign = api, api
    env.DarlingSovereignLastError, _G.DarlingSovereignLastError = nil, nil
    
    local V3, CF, PI = Vector3.new, CFrame.new, math.pi
    local WHITE = Color3.fromRGB(255, 205, 185)
    local GOLD = Color3.fromRGB(255, 12, 36) -- Carmesi: conserva los nombres internos de la plantilla.
    local CYAN = Color3.fromRGB(255, 45, 83)
    local PURPLE = Color3.fromRGB(161, 12, 70)
    local METAL = Color3.fromRGB(174, 66, 76)
    local rng, low = Random.new(740319), false
    local TEX = { spark = "rbxassetid://2581273950", mist = "rbxassetid://12865656309",
        glint = "rbxassetid://94431438472232", plasma = "rbxassetid://6034176465", fire = "rbxasset://textures/particles/fire_main.dds" }
    local dead, bound, elapsed, started = false, false, 0, nil
    local scene, gui, screenFlash, cam, character, root, humanoid, base
    local cleanupItems, connections, hiddenParts, hiddenGuis, rigs = {}, {}, {}, {}, {}
    local saved, incoming, effects, flags, S = {}, {}, {}, {}, {}
    local bindName = "SovereignV2_" .. HttpService:GenerateGUID(false)
    local flashPower, shake = 0, 0
    local state={alive=true,meshResources={}}
    local persistent,persistentConnections={},{}
    local function clearPersistent()
        for _,c in ipairs(persistentConnections) do pcall(function() c:Disconnect() end) end
        for _,o in ipairs(persistent) do pcall(function() o:Destroy() end) end
        persistent,persistentConnections={},{}
    end
    local function clamp(x, a, b) return math.max(a, math.min(b, x)) end
    local function ease(x) x = clamp(x, 0, 1); return x*x*(3-2*x) end
    local function phase(t,a,b) return ease((t-a)/(b-a)) end
    local function mix(a,b,t) return a+(b-a)*t end
    local function angles(x,y,z) return CFrame.Angles(math.rad(x),math.rad(y),math.rad(z)) end
    local function out(x) return 1-(1-clamp(x,0,1))^4 end
    local function world(x,y,z) return base * V3(x,y,z) end
    local function keep(o) cleanupItems[#cleanupItems+1]=o; return o end
    local function connect(signal, fn) local c=signal:Connect(fn); connections[#connections+1]=c; return c end
    local function make(class, props, parent)
        local obj=Instance.new(class)
        for k,v in pairs(props or {}) do obj[k]=v end
        obj.Parent=parent; return obj
    end
    local function stop(reason)
        if dead then
            if reason~="finished" then
                clearPersistent()
                if env.DarlingSovereign==api then env.DarlingSovereign=nil end
                if _G.DarlingSovereign==api then _G.DarlingSovereign=nil end
            end
            return
        end
        dead, api.IsPlaying = true, false
        state.alive=false
        if reason~="finished" then clearPersistent() end
        api.Status=reason=="finished" and "finished" or "stopped"
        if reason and reason~="finished" and reason~="cancelled" then
            api.LastError=tostring(reason)
            env.DarlingSovereignLastError=api.LastError
            _G.DarlingSovereignLastError=api.LastError
        end
        if bound then pcall(function() RunService:UnbindFromRenderStep(bindName) end) end
        for _,c in ipairs(connections) do pcall(function() c:Disconnect() end) end
        for _,o in ipairs(cleanupItems) do pcall(function() o:Destroy() end) end
        for _,o in pairs(incoming) do pcall(function() o:Destroy() end) end
        for _,o in ipairs(state.meshResources) do pcall(function() o:Destroy() end) end
        state.meshResources={}
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
        if reason~="finished" or not CONFIG.KeepAura then
            if env.DarlingSovereign==api then env.DarlingSovereign=nil end
            if _G.DarlingSovereign==api then _G.DarlingSovereign=nil end
        end
        if reason and reason~="finished" and reason~="cancelled" then warn("[Sovereign] "..tostring(reason)) end
        if onComplete then
            local cb = onComplete
            onComplete = nil
            pcall(cb)
        end
    end
    api.Stop=function() stop("cancelled") end
    local function part(name,color,size,parent,class)
        return make(class or "Part", { Name=name, Anchored=true, CanCollide=false, CanQuery=false,
            CanTouch=false, CastShadow=false, Material=Enum.Material.Neon, Color=color,
            Size=size or V3(1,1,1), Transparency=1,
            TopSurface=Enum.SurfaceType.Smooth, BottomSurface=Enum.SurfaceType.Smooth }, parent or scene)
    end

    -- Cilindro con volumen. No barras rectangulares ni circulos de segmentos.
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
    -- Faceta solida: doble piramide de cuatro caras, construida con WedgeParts.
    -- Permanece visible aunque no carguen meshes externos.
    local makeGroundShard
    local function crystal(name,color,parent)
        local m=make("Model",{Name=name},parent or scene)
        if S.diamondReady then
            local p=part("FacetedDiamondMesh",color,nil,m)
            local mesh=make("SpecialMesh",{MeshType=Enum.MeshType.FileMesh,MeshId="rbxassetid://9756362"},p)
            return {model=m,part=p,mesh=mesh,color=color}
        end
        local faces={}
        for i=1,8 do faces[i]=part("Facet",color,nil,m,"WedgePart") end
        return {model=m,faces=faces,color=color}
    end
    local function drawCrystal(c,frame,width,length,alpha,metal)
        if c.rough then
            c.model:ScaleTo(math.max(.035,width))
            c.model:PivotTo(frame)
            for _,p in ipairs(c.parts) do p.Transparency=1-clamp(alpha,0,1) end
            return
        end
        if c.mesh then
            c.part.CFrame=frame
            c.mesh.Scale=V3(math.max(width,0.05),math.max(length,0.05),math.max(width,0.05))
            c.part.Transparency=1-clamp(alpha,0,1)
            c.part.Material=metal and Enum.Material.Metal or Enum.Material.Neon
            return
        end
        local half=math.max(length*0.5,0.05); local r=math.max(width*0.5,0.05)
        for i,p in ipairs(c.faces) do
            local top=i<=4; local side=(i-1)%4
            p.Size=V3(r,half,r)
            p.CFrame=frame*angles(0,side*90,0)*CF(r*0.5,(top and 1 or -1)*half*0.5,0)
                *(top and CF() or angles(180,0,0))
            p.Transparency=1-clamp(alpha,0,1)
            p.Material=metal and Enum.Material.Metal or Enum.Material.Neon
            p.Color=c.color:Lerp(WHITE,(i%4)*0.09)
        end
    end
    local function plasma(color,width,parent)
        local a=part("PlasmaAnchorA",color,nil,parent)
        local b=part("PlasmaAnchorB",color,nil,parent)
        local aa=make("Attachment",{},a); local ab=make("Attachment",{},b)
        local function layer(name,tint,w)
            return make("Beam",{Name=name,Attachment0=aa,Attachment1=ab,Texture=TEX.plasma,
                TextureMode=Enum.TextureMode.Wrap,TextureLength=28,TextureSpeed=4.5,
                Color=ColorSequence.new(tint),LightEmission=1,LightInfluence=0,
                FaceCamera=true,Width0=w,Width1=w*.7,Segments=24,
                Transparency=NumberSequence.new(1)},a)
        end
        return {a=a,b=b,beam=layer("TexturedPlasma",color,width),
            halo=layer("SoftCrimsonCorona",color,width*2.1),core=layer("HotFilament",WHITE,width*.16)}
    end
    local function drawPlasma(p,a,b,width,alpha,bend)
        p.a.CFrame=CF(a); p.b.CFrame=CF(b)
        alpha=clamp(alpha,0,1)
        local function draw(beam,scale,power)
            beam.Width0=width*scale;beam.Width1=width*scale*.7
            beam.CurveSize0=bend or 0;beam.CurveSize1=-(bend or 0)
            local visible=alpha*power
            beam.Transparency=seq({{0,1-visible*.55},{.13,1-visible},
                {.68,1-visible*.85},{1,1}})
        end
        draw(p.beam,1,1)
        draw(p.halo,2.1,.13)
        draw(p.core,.16,.48)
    end

    local function bolt(color,count)
        local b={pieces={},color=color,count=count or (low and 14 or 22)}
        for i=1,b.count do
            local p={core=part("LightningCore",WHITE),glow=part("LightningCorona",color),branches={}}
            if i%5==0 then
                for j=1,3 do p.branches[j]={core=part("BranchFilament",WHITE),glow=part("BranchCorona",color)} end
            end
            b.pieces[i]=p
        end
        return b
    end
    local function drawBolt(b,a,z,width,alpha,seed)
        if alpha<=0 or (z-a).Magnitude<.1 then
            for _,p in ipairs(b.pieces) do
                p.core.Transparency=1;p.glow.Transparency=1
                for _,branch in ipairs(p.branches) do branch.core.Transparency=1;branch.glow.Transparency=1 end
            end
            return
        end
        local len=(z-a).Magnitude;local axis=CFrame.lookAt(a,z);local previous=a
        local frame=math.floor(elapsed*24)
        for i,p in ipairs(b.pieces) do
            local t=i/b.count;local jag=math.sin(t*PI)*len*.035
            local point=a+(z-a)*t+axis.RightVector*math.noise(i*3.7,frame,seed)*jag
                +axis.UpVector*math.noise(seed,i*7.3,frame)*jag
            tube(p.core,previous,point,width,alpha)
            tube(p.glow,previous,point,width*3.5,alpha*.24)
            local from=point
            for j,branch in ipairs(p.branches) do
                local f=j/3
                local side=(i%2==0 and 1 or -1)
                local tip=point+axis.RightVector*side*len*.065*f
                    +axis.LookVector*len*.075*f
                    +axis.UpVector*math.noise(seed+i,j,frame)*len*.022
                tube(branch.core,from,tip,width*.3*(1-f*.45),alpha*.5)
                tube(branch.glow,from,tip,width*1.2*(1-f*.45),alpha*.14)
                from=tip
            end
            previous=point
        end
    end

    local function detonation(position,radius,color,life,kind)
        -- Fractura volumetrica irregular. Ninguna esfera ni superficie circular.
        local ground=kind=="ground"
        local group=make("Folder",{Name=ground and "ShatteredGround" or "StellarFracture"},scene)
        local fx={obj=group,fracture=true,born=elapsed,life=life or 1.6,pos=position,
            radius=radius,ground=ground,shards={},cracks={}}
        local count=low and 12 or (ground and 32 or 26)
        for i=1,count do
            local direction=V3(rng:NextNumber(-1,1),rng:NextNumber(ground and 0.25 or -0.9,1),rng:NextNumber(-1,1))
            if direction.Magnitude<0.1 then direction=V3(0,1,0) end
            direction=direction.Unit
            local width=radius*rng:NextNumber(0.008,0.022)
            local length=width*rng:NextNumber(2.5,5)
            local c
            if ground then c=makeGroundShard(Color3.fromRGB(66,62,73),group)
            else c=crystal("SolarSplinter",i%3==0 and WHITE or color,group) end
            local wake=plasma(i%3==0 and CYAN or color,width*0.45,group)
            local origin=position+V3(rng:NextNumber(-1,1),ground and 0 or rng:NextNumber(-1,1),rng:NextNumber(-1,1))*radius*0.08
            fx.shards[i]={c=c,wake=wake,direction=direction,origin=origin,width=width,length=length,
                speed=radius*rng:NextNumber(0.28,0.65),spin=V3(rng:NextNumber(-160,160),rng:NextNumber(-160,160),rng:NextNumber(-160,160))}
            if ground and i%5==0 then
                mist(origin,math.min(65,radius*0.09),Color3.fromRGB(190,183,170),4)
            end
        end
        if ground then
            for i=1,low and 5 or 9 do
                local direction=V3(rng:NextNumber(-1,1),0,rng:NextNumber(-1,1))
                if direction.Magnitude<0.1 then direction=V3(1,0,0) end
                direction=direction.Unit
                local points={position+V3(0,0.5,0)}
                local reach=radius*rng:NextNumber(0.2,0.75)
                local side=V3(-direction.Z,0,direction.X)
                local beams={}
                for j=1,4 do
                    points[j+1]=position+direction*(reach*j/4)+side*rng:NextNumber(-reach*0.09,reach*0.09)+V3(0,0.5,0)
                    beams[j]=plasma(j%2==0 and WHITE or color,math.max(0.5,radius*0.004),group)
                end
                fx.cracks[i]={points=points,beams=beams}
            end
        end
        effects[#effects+1]=fx
        spray(position,color,math.min(14,radius*0.018),low and 100 or 220,radius*0.35,"spark")
        spray(position,WHITE,math.min(28,radius*0.025),low and 24 or 55,radius*0.25,"glint")
    end
    local function cloneCharacter()
        local arch=character.Archivable; character.Archivable=true
        local ok,model=pcall(function() return character:Clone() end)
        character.Archivable=arch
        if not ok or not model then error("No se pudo copiar tu avatar real.") end
        return model
    end
    
    -- mygame43 verificado en users.roblox.com: usuario 912348.
    -- Copia de seguridad de su apariencia publica comprobada el 10-11-2026.
    local function cachedGiantDescription()
        local desc=Instance.new("HumanoidDescription")
        desc.Shirt,desc.Pants,desc.Head=3039069,3369926,11236434712
        desc.HatAccessory="1098272,1191135761"
        desc.HeightScale,desc.WidthScale,desc.DepthScale,desc.HeadScale=1,1,1,1
        desc.BodyTypeScale,desc.ProportionScale=0,0
        for _,key in ipairs({"HeadColor","TorsoColor","RightArmColor","LeftArmColor","RightLegColor","LeftLegColor"}) do
            desc[key]=BrickColor.new(21).Color
        end
        return desc
    end

    local function loadGiantAvatar()
        api.Status="loading-mygame43"
        local desc,model
        local ok,result=pcall(function() return Players:GetHumanoidDescriptionFromUserIdAsync(912348) end)
        if not ok then ok,result=pcall(function() return Players:GetHumanoidDescriptionFromUserId(912348) end) end
        if ok and result then desc=result else desc=cachedGiantDescription() end
        if dead then desc:Destroy(); return nil end
        local function create(description)
            local made,avatar=pcall(function()
                return Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15)
            end)
            if not made then made,avatar=pcall(function()
                return Players:CreateHumanoidModelFromDescription(description,Enum.HumanoidRigType.R15)
            end) end
            return made and avatar or nil
        end
        model=create(desc)
        desc:Destroy()
        if not model and not dead then
            local made,avatar=pcall(function() return Players:CreateHumanoidModelFromUserIdAsync(912348) end)
            if made then model=avatar end
        end
        if not model and not dead then
            local backup=cachedGiantDescription()
            model=create(backup)
            backup:Destroy()
        end
        if dead then if model then model:Destroy() end; return nil end
        if not model then error("No se pudo cargar la apariencia de mygame43. Vuelve a ejecutar cuando Roblox cargue avatares.") end
        model.Name="mygame43_CrimsonSovereign"
        api.GiantUserId=912348
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
        -- Normaliza altura corporal, independientemente de la escala previa del juego.
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
        -- Estos actores estan anclados; ninguna constraint debe arrastrarlos.
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
        rig.highlight.Enabled = alpha > 0.05
        rig.highlight.OutlineTransparency = 1 - 0.3 * alpha
    end
    
    
    
    local function blendFrame(a,b,w)
        if w<=0 then return a elseif w>=1 then return b end
        local forward=a.LookVector:Lerp(b.LookVector,w)
        if forward.Magnitude<.001 then forward=b.LookVector end
        forward=forward.Unit
        local up=a.UpVector:Lerp(b.UpVector,w)
        up=up-forward*up:Dot(forward)
        if up.Magnitude<.001 then up=math.abs(forward.Y)>.9 and V3(0,0,1) or V3(0,1,0) end
        local right=forward:Cross(up).Unit
        return CFrame.fromMatrix(a.Position:Lerp(b.Position,w),right,(-forward):Cross(right),-forward)
    end

    local function armData(rig,side)
        local a={}
        for _,edge in ipairs(rig.edges) do
            if not edge.reverse then
                if edge.name==side.."Shoulder" then a.shoulder=edge
                elseif edge.name==side.."Elbow" then a.elbow=edge
                elseif edge.name==side.."Wrist" then a.wrist=edge end
            end
        end
        a.hand=rig.model:FindFirstChild(side.."Hand") or rig.model:FindFirstChild(side.." Arm")
        if not a.shoulder or not a.hand then return nil end
        a.start=(a.shoulder.a.CFrame*a.shoulder.c0).Position
        if a.elbow and a.wrist then
            a.l1=(a.elbow.c0.Position-a.shoulder.c1.Position).Magnitude
            a.l2=(a.wrist.c0.Position-a.elbow.c1.Position).Magnitude
            a.reach=a.l1+a.l2
        else
            a.localGrip=V3(0,-a.hand.Size.Y*.37,-a.hand.Size.Z*.12)
            a.reach=(a.localGrip-a.shoulder.c1.Position).Magnitude
        end
        return a
    end

    local function segmentFrame(a,b,reference)
        local f=(b-a).Unit
        local up=reference or V3(0,1,0)
        if math.abs(f:Dot(up))>.96 then up=math.abs(f.Y)>.9 and V3(0,0,1) or V3(0,1,0) end
        local r=f:Cross(up).Unit
        return CFrame.fromMatrix(a,r,(-f):Cross(r),-f)
    end

    local function solveActorArm(rig,side,desired,weight)
        local arm=armData(rig,side)
        if not arm or weight<=0 then return V3() end
        local before={}
        for _,e in ipairs(rig.edges) do before[e.b]=e.b.CFrame end
        local frame=blendFrame(arm.hand.CFrame,desired,weight)
        local target=frame*(arm.wrist and arm.wrist.c1.Position or arm.localGrip)
        local delta=target-arm.start
        local direction=delta.Magnitude>.001 and delta.Unit or V3(0,-1,0)
        local endpoint
        if arm.elbow and arm.wrist and arm.l1>.01 and arm.l2>.01 then
            local d=clamp(delta.Magnitude,math.abs(arm.l1-arm.l2)+.03,arm.reach-.03)
            endpoint=arm.start+direction*d
            local along=(d*d+arm.l1*arm.l1-arm.l2*arm.l2)/(2*d)
            local lateral=rig.root.CFrame.RightVector*(side=="Right" and 1 or -1)
            local pole=lateral-direction*direction:Dot(lateral)
            if pole.Magnitude<.001 then pole=-rig.root.CFrame.LookVector end
            local elbow=arm.start+direction*along+pole.Unit*math.sqrt(math.max(0,arm.l1*arm.l1-along*along))
            local back=-rig.root.CFrame.LookVector
            arm.shoulder.b.CFrame=segmentFrame(arm.start,elbow,back)
                *segmentFrame(arm.shoulder.c1.Position,arm.elbow.c0.Position):Inverse()
            arm.elbow.b.CFrame=segmentFrame(elbow,endpoint,back)
                *segmentFrame(arm.elbow.c1.Position,arm.wrist.c0.Position):Inverse()
            arm.wrist.b.CFrame=CF(endpoint-target)*frame
        else
            endpoint=arm.start+direction*arm.reach
            arm.hand.CFrame=segmentFrame(arm.start,endpoint,-rig.root.CFrame.LookVector)
                *segmentFrame(arm.shoulder.c1.Position,arm.localGrip):Inverse()
        end
        local moved={[arm.shoulder.b]=true}
        if arm.elbow then moved[arm.elbow.b]=true end
        if arm.wrist then moved[arm.wrist.b]=true end
        for _,e in ipairs(rig.edges) do
            if moved[e.a] and not moved[e.b] and before[e.a] and before[e.b] then
                e.b.CFrame=e.a.CFrame*before[e.a]:ToObjectSpace(before[e.b]);moved[e.b]=true
            end
        end
        return target-endpoint
    end

    local function poseRig(rig,frame,mode,a,t,groundY)
        rig.root.CFrame=frame
        local p={}
        local breathing=math.sin(t*1.8)*1.8
        p.Neck=angles(breathing,0,0)
        p.RightShoulder=angles(0,0,4+breathing)
        p.LeftShoulder=angles(0,0,-4-breathing)
        if mode=="invoke" then
            local wind=phase(t,0.4,2); local release=phase(t,2,3.35)
            p.RootJoint=angles(12*wind-20*release,0,0)
            p.Waist=angles(8*wind-18*release,0,0)
            p.Neck=angles(-32*release,0,0)
            p.RightShoulder=angles(mix(-30,-172,release)*a,0,mix(30,8,release)*a)
            p.LeftShoulder=angles(-42*wind*a,0,-36*wind*a)
            p.RightElbow=angles(-60*(1-release)*a,0,0)
            p.LeftElbow=angles(-45*wind*a,0,0)
        elseif mode=="emerge" then
            p.RootJoint=angles(-9*a,0,0); p.Waist=angles(-10*a,0,0)
            p.RightShoulder=angles(-28*a,0,72*a); p.LeftShoulder=angles(-28*a,0,-72*a)
            p.RightElbow=angles(-15*a,0,0); p.LeftElbow=angles(-15*a,0,0)
            p.RightHip=angles(-15*a,0,7*a); p.LeftHip=angles(12*a,0,-7*a)
            p.RightKnee=angles(18*a,0,0); p.Neck=angles(-22*a,0,0)
        elseif mode=="land" then
            p.RootJoint=angles(20*a,0,0); p.Waist=angles(15*a,0,0)
            p.RightHip=angles(-24*a,0,6*a); p.LeftHip=angles(-24*a,0,-6*a)
            p.RightKnee=angles(42*a,0,0); p.LeftKnee=angles(42*a,0,0)
            p.RightShoulder=angles(-12*a,0,26*a); p.LeftShoulder=angles(-12*a,0,-26*a)
        elseif mode=="kneel" then
            local bow=phase(t,23.05,24.5)
            -- Ejes Roblox: +X lleva el muslo hacia delante (-Z).
            -- Rodilla izquierda abajo; pie derecho delante. El torso se inclina
            -- hacia el gigante DESPUES de apoyar la pierna, no hacia atras.
            p.RootJoint=angles(-4*a,0,0); p.Root=angles(-4*a,0,0)
            p.Waist=angles(-19*bow,0,0); p.Neck=angles(-27*bow,0,0)
            p.RightHip=angles(94*a,0,0); p.LeftHip=angles(4*a,0,0)
            p.RightKnee=angles(-90*a,0,0); p.LeftKnee=angles(-96*a,0,0)
            p.RightAnkle=CF(); p.LeftAnkle=angles(90*a,0,0)
            p.RightShoulder=angles(55*a,0,-8*a); p.LeftShoulder=angles(35*a,0,8*a)
            p.RightElbow=angles(58*a,0,0); p.LeftElbow=angles(78*a,0,0)
            p.RightWrist=angles(-15*a,0,0); p.LeftWrist=angles(-12*a,0,0)
        elseif mode=="weapon" then
            local reach=phase(t,18.5,20)
            local pull=phase(t,20.25,21.65)
            local coil=phase(t,22,26.35)
            local cut=clamp((t-26.4)/1.2,0,1)^2.65
            local recoil=t>=27.6 and math.sin((t-27.6)*9)*math.exp(-(t-27.6)*2.8) or 0
            local lean=10*reach-16*pull-9*coil+27*cut+3*recoil
            p.RootJoint=angles(lean*.45,reach*-5+coil*10-cut*15,-3*reach+cut*4);p.Root=p.RootJoint
            p.Waist=angles(lean*.7,-9*reach+17*coil-25*cut,cut*4)
            p.Neck=angles(12*reach-23*coil+15*cut,-12*reach+8*coil,0)
            p.RightShoulder=angles(-35*reach,0,8+coil*18)
            p.RightElbow=angles(-30*reach,0,0)
            p.LeftShoulder=angles(-15-25*coil,0,-12-coil*24)
            p.LeftElbow=angles(-20-50*coil,0,0)
            p.RightHip=angles(-14*reach-12*coil+16*cut,0,7)
            p.LeftHip=angles(-10*reach-8*coil+9*cut,0,-7)
            p.RightKnee=angles(22*reach+18*coil-13*cut,0,0)
            p.LeftKnee=angles(18*reach+13*coil-10*cut,0,0)
        elseif mode=="arrival" then
            local walk=phase(t,39.7,40.05)*(1-phase(t,41.7,42.15))
            local step=math.sin((t-39.7)*5.2)*walk
            local charge=phase(t,46,48.2)*(1-phase(t,48.2,49.7))
            local release=phase(t,48.2,48.48)*(1-phase(t,48.48,49.7))
            local r6=rig.model:FindFirstChild("Left Leg")~=nil
            p.RootJoint=angles((r6 and 48 or 18)*a+walk*10+charge*5-release*7,0,a*-4);p.Root=p.RootJoint
            p.Waist=angles(17*a+walk*4+charge*5-release*6,0,a*-4)
            p.Neck=angles(-23*a-12*(1-phase(t,42,44.5))-charge*7,0,0)
            p.RightShoulder=angles(52*a-step*24-charge*60-release*12,0,7+release*44)
            p.LeftShoulder=angles(-25*a+step*24-charge*44-release*16,0,-8-release*48)
            p.RightElbow=angles(-15-42*charge-14*walk,0,0)
            p.LeftElbow=angles(-15-58*charge-14*walk,0,0)
            p.RightHip=angles(88*a+step*29,0,3)
            p.LeftHip=angles((r6 and 72 or 4)*a-step*29,0,-3)
            p.RightKnee=angles(-90*a-math.max(0,-step)*32,0,0)
            p.LeftKnee=angles(-96*a-math.max(0,step)*32,0,0)
            p.LeftAnkle=angles(85*a,0,0)

        elseif mode=="snap" then
            local recoil=math.exp(-math.max(0,t-29.65)*12)*(t>=29.65 and 1 or 0)
            p.RightShoulder=angles(-103*a,-12*a,18*a)
            p.RightElbow=angles(-70*a,0,0)
            p.RightWrist=angles(-18*recoil,0,28*a-52*recoil)
            p.Neck=angles(17*a,-14*a,0); p.Waist=angles(0,-6*a,0)
        end
        for _,edge in ipairs(rig.edges) do
            local rotation=(edge.motor and p[edge.name]) or CF()
            local basis=edge.c0-edge.c0.Position
            local transform=basis:Inverse()*rotation*basis
            if edge.reverse then transform=transform:Inverse() end
            edge.b.CFrame=edge.a.CFrame*edge.c0*transform*edge.c1:Inverse()
        end
        for part0,relative in pairs(rig.loose) do part0.CFrame=frame*relative end
        if (mode=="kneel" or mode=="weapon" or mode=="arrival") and groundY then
            -- Apoyo calculado con la geometria y la rotacion reales de los pies
            -- y la rodilla: evita flotar o atravesar el suelo al doblar el rig.
            local lowest=math.huge
            for _,name in ipairs({"RightFoot","LeftFoot","LeftLowerLeg","Right Leg","Left Leg"}) do
                local part0=rig.model:FindFirstChild(name)
                if part0 then
                    local half=math.abs(part0.CFrame.RightVector.Y)*part0.Size.X*0.5
                        +math.abs(part0.CFrame.UpVector.Y)*part0.Size.Y*0.5
                        +math.abs(part0.CFrame.LookVector.Y)*part0.Size.Z*0.5
                    lowest=math.min(lowest,part0.Position.Y-half)
                end
            end
            if lowest<math.huge then
                local shift=V3(0,groundY+0.12-lowest,0)
                for part0 in pairs(rig.parts) do
                    if part0:IsA("BasePart") then part0.CFrame=part0.CFrame+shift end
                end
            end
        end
    end
    

    local V,pi,sin,cos=V3,PI,math.sin,math.cos
    local C={red=GOLD,hot=CYAN,white=WHITE,dark=Color3.fromRGB(34,19,34),
        edge=Color3.fromRGB(208,211,228),armor=Color3.fromRGB(183,10,32),gold=Color3.fromRGB(208,116,105)}
    local function rotation(x,y,z) return CFrame.Angles(x or 0,y or 0,z or 0) end
    local function new(class,parent,properties) return make(class,properties,parent) end
    local function safeDestroy(obj) if obj then pcall(function() obj:Destroy() end) end end
    local Geo={}
function Geo.part(parent, size, cf, color, material, transparency, shape)
    return new("Part", parent, {
        Name = "Geometry", Size = size, CFrame = cf, Color = color or C.armor,
        Material = material or Enum.Material.SmoothPlastic,
        Transparency = transparency or 0, Shape = shape or Enum.PartType.Block,
        Anchored = true, CanCollide = false, CanTouch = false, CanQuery = false,
        CastShadow = false, TopSurface = Enum.SurfaceType.Smooth,
        BottomSurface = Enum.SurfaceType.Smooth,
    })
end
function Geo.ball(parent, position, size, color, alpha)
    return Geo.part(parent, size, CF(position), color, Enum.Material.Neon, alpha, Enum.PartType.Ball)
end
function Geo.rod(parent, a, b, width, color, alpha, material)
    local length = (b - a).Magnitude
    if length < 0.001 then
        b = a + V(0, 0.001, 0)
        length = 0.001
    end
    return Geo.part(parent, V(length, width, width), CFrame.lookAt((a + b) / 2, b) * rotation(0,pi/2,0),
        color, material or Enum.Material.Neon, alpha, Enum.PartType.Cylinder)
end
function Geo.wedge(parent, size, cf, color, material)
    return new("WedgePart", parent, {
        Name = "Facet", Size = size, CFrame = cf, Color = color or C.armor,
        Material = material or Enum.Material.Metal, Anchored = true,
        CanCollide = false, CanTouch = false, CanQuery = false, CastShadow = false,
        TopSurface = Enum.SurfaceType.Smooth, BottomSurface = Enum.SurfaceType.Smooth,
    })
end
function Geo.triangle(parent, a, b, c, color, thickness, material)
    local ab, ac, bc = b - a, c - a, c - b
    local ab2, ac2, bc2 = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
    if ac2 > ab2 and ac2 > bc2 then a, b = b, a
    elseif ab2 > ac2 and ab2 > bc2 then a, c = c, a end
    ab, ac, bc = b - a, c - a, c - b
    local cross = ac:Cross(ab)
    if cross.Magnitude < 0.0001 or bc.Magnitude < 0.0001 then return end
    local right, back = cross.Unit, bc.Unit
    local up = back:Cross(right).Unit
    local height = math.abs(ab:Dot(up))
    Geo.wedge(parent, V(thickness or 0.06, height, math.max(0.001, math.abs(ab:Dot(back)))),
        CFrame.fromMatrix((a + b) / 2, right, up, back), color, material)
    Geo.wedge(parent, V(thickness or 0.06, height, math.max(0.001, math.abs(ac:Dot(back)))),
        CFrame.fromMatrix((a + c) / 2, -right, up, -back), color, material)
end
function Geo.gem(parent, cf, width, height, depth, color)
    -- Ocho caras de un cristal; el canto central queda elevado.
    local p = {
        V(0, height / 2, 0), V(width / 2, 0, 0), V(0, -height / 2, 0),
        V(-width / 2, 0, 0), V(0, 0, -depth / 2), V(0, 0, depth / 2),
    }
    for i = 1, 4 do
        local j = i % 4 + 1
        Geo.triangle(parent, cf * p[i], cf * p[j], cf * p[5],
            color:Lerp(C.white, i == 2 and 0.14 or 0), 0.035, Enum.Material.Metal)
        Geo.triangle(parent, cf * p[j], cf * p[i], cf * p[6], color, 0.035, Enum.Material.Metal)
    end
end
function Geo.nativeSurface(parent, grid, color, material)
    if state.nativeMesh == false then return false end
    local editable, result
    local ok = pcall(function()
        local assets = game:GetService("AssetService")
        editable = assets:CreateEditableMesh()
        if not editable then error("EditableMesh no disponible") end
        local lo,hi=V(math.huge,math.huge,math.huge),V(-math.huge,-math.huge,-math.huge)
        for _,row in ipairs(grid) do
            for _,p in ipairs(row) do
                lo=V(math.min(lo.X,p.X),math.min(lo.Y,p.Y),math.min(lo.Z,p.Z))
                hi=V(math.max(hi.X,p.X),math.max(hi.Y,p.Y),math.max(hi.Z,p.Z))
            end
        end
        local center=(lo+hi)/2
        local vids,uvs,normals={},{},{}
        for j,row in ipairs(grid) do
            vids[j],uvs[j],normals[j]={},{},{}
            for i,p in ipairs(row) do
                vids[j][i]=editable:AddVertex(p-center)
                uvs[j][i]=editable:AddUV(Vector2.new((i-1)/(#row-1),(j-1)/(#grid-1)))
                local du=row[math.min(#row,i+1)]-row[math.max(1,i-1)]
                local dv=grid[math.min(#grid,j+1)][i]-grid[math.max(1,j-1)][i]
                local normal=du:Cross(dv)
                normals[j][i]=editable:AddNormal(normal.Magnitude>.00001 and normal.Unit or V(0,0,-1))
            end
        end
        for j=1,#grid-1 do
            for i=1,#grid[j]-1 do
                local f=editable:AddTriangle(vids[j][i],vids[j][i+1],vids[j+1][i+1])
                editable:SetFaceUVs(f,{uvs[j][i],uvs[j][i+1],uvs[j+1][i+1]})
                editable:SetFaceNormals(f,{normals[j][i],normals[j][i+1],normals[j+1][i+1]})
                local g=editable:AddTriangle(vids[j][i],vids[j+1][i+1],vids[j+1][i])
                editable:SetFaceUVs(g,{uvs[j][i],uvs[j+1][i+1],uvs[j+1][i]})
                editable:SetFaceNormals(g,{normals[j][i],normals[j+1][i+1],normals[j+1][i]})
            end
        end
        result=assets:CreateMeshPartAsync(Content.fromObject(editable))
        if not state.alive then error("Cinematica cancelada") end
        result.Name="SculptedSurface"
        result.Anchored=true
        result.CanCollide,result.CanTouch,result.CanQuery=false,false,false
        result.CastShadow=false
        result.DoubleSided=true
        result.Material=material or Enum.Material.CorrodedMetal
        result.Color=color
        result.CFrame=CF(center)
        result.Parent=parent
    end)
    if ok and result then
        state.meshResources[#state.meshResources+1]=editable
        state.nativeMesh=true
        return true
    end
    safeDestroy(result)
    safeDestroy(editable)
    state.nativeMesh=false
    return false
end

-- Superficies construidas por perfiles, con relieve y variacion de material.
-- No usa un mesh externo ni necesita registrar archivos con Delta.
function Geo.surface(parent, cf, nu, nv, sample, color, material)
    local grid = {}
    for j = 0, nv do
        grid[j + 1] = {}
        for i = 0, nu do grid[j + 1][i + 1] = cf * sample(i / nu, j / nv) end
    end
    if Geo.nativeSurface(parent,grid,color,material) then return end
    if not state.alive then error("Cinematica cancelada durante la construccion") end
    for j = 1, nv do
        for i = 1, nu do
            local shade = (sin(i * 2.17 + j * 3.19) + sin(i * 4.1 - j * 1.9)) * 0.035
            local tint = color:Lerp(shade > 0 and C.edge or C.dark, math.abs(shade))
            local a,b,c,d = grid[j][i],grid[j][i+1],grid[j+1][i+1],grid[j+1][i]
            Geo.triangle(parent,a,b,c,tint,0.018,material or Enum.Material.CorrodedMetal)
            Geo.triangle(parent,a,c,d,tint,0.018,material or Enum.Material.CorrodedMetal)
        end
    end
end

function Geo.loft(parent, cf, profiles, color, sections, material)
    local rings = sections or 12
    Geo.surface(parent,cf,rings,#profiles-1,function(u,v)
        local idx = math.min(#profiles-1,math.floor(v*(#profiles-1))+1)
        local f = v*(#profiles-1)-(idx-1)
        local p,q = profiles[idx],profiles[idx+1]
        local a = u*2*pi*(profiles[#profiles][1]>profiles[1][1] and -1 or 1)
        local ripple = 1 + 0.018*sin(a*5+v*11) + 0.012*sin(a*9-v*13)
        return V(cos(a)*mix(p[2],q[2],f)*ripple,
            mix(p[1],q[1],f),sin(a)*mix(p[3],q[3],f)*ripple+mix(p[4] or 0,q[4] or 0,f))
    end,color,material)
end

function Geo.plate(parent, cf, width, length, depth, color)
    Geo.surface(parent,cf,8,7,function(u,v)
        local x = (u*2-1)
        local silhouette = (0.16 + 0.84*sin((0.06+v*0.9)*pi)^0.55)
        local corrugation = 0.035*sin(v*51+x*13)*sin(v*pi)
        return V(x*width*.5*silhouette,(0.5-v)*length,
            -depth*(1-x*x)*sin(v*pi) - corrugation)
    end,color,Enum.Material.CorrodedMetal)
    -- Ribete tridimensional: sigue el contorno, no es un bloque pintado.
    for _,side in ipairs({-1,1}) do
        local previous
        for i=0,16 do
            local v=i/16
            local p=cf*V(side*width*.49*(.16+.84*sin((.06+v*.9)*pi)^.55),(.5-v)*length,-.045)
            if previous then Geo.rod(parent,previous,p,.065,C.gold,0,Enum.Material.Metal) end
            previous=p
        end
    end
    -- Nervaduras y cortes de forja sobre el relieve.
    for row=1,5 do
        local v=.16+row*.11
        for _,side in ipairs({-1,1}) do
            local previous
            for i=0,5 do
                local x=side*(.08+i*.12)
                local vv=v+math.abs(x)*.09
                local p=cf*V(x*width*.5*(.16+.84*sin((.06+vv*.9)*pi)^.55),
                    (.5-vv)*length,-depth*(1-x*x)*sin(vv*pi)-.06)
                if previous then Geo.rod(parent,previous,p,.04,row%2==0 and C.gold or C.edge,0,Enum.Material.Metal) end
                previous=p
            end
        end
    end
end

function Geo.horn(parent, cf, length, radius, bend, sweep, color)
    Geo.surface(parent,cf,9,10,function(u,v)
        local a=-u*2*pi
        local r=radius*(1-v)^.8*(1+.08*sin(v*15*pi))+.008
        return V(bend*v*v+cos(a)*r,v*length,sweep*v*v+sin(a)*r)
    end,color or C.armor,Enum.Material.CorrodedMetal)
end

function Geo.shard(parent, cf, size, color)
    local m=new("Model",parent,{Name="BrokenBasalt"})
    local ring={}
    for i=1,7 do
        local a=i/7*2*pi
        local r=.75+.2*sin(i*17.4+size.X)
        ring[i]=V(cos(a)*size.X*.5*r,(sin(i*3.7)*.2)*size.Y,sin(a)*size.Z*.5*r)
    end
    local top,bottom=V(size.X*.08,size.Y*.5,0),V(-size.X*.13,-size.Y*.5,size.Z*.15)
    for i=1,7 do
        local j=i%7+1
        Geo.triangle(m,top,ring[i],ring[j],color:Lerp(C.edge,(i%3)*.065),.03,Enum.Material.Rock)
        Geo.triangle(m,bottom,ring[j],ring[i],color,.03,Enum.Material.Slate)
    end
    m.WorldPivot=CF()
    m:PivotTo(cf)
    return m
end


    -- Espada esculpida; sigue la mano real del rig de la plantilla.
    local function buildSword()
        local sword = make("Model", {Name="CrimsonWorldsplitter"}, scene)
        S.sword = {model=sword, parts={}}
        Geo.loft(sword,CF(),{{-4,.2,.2},{-3.2,.9,.8},{2.5,.85,.8},{4,1.3,1}},C.dark,12,Enum.Material.Metal)
        local previous
        for i=0,96 do
            local u=i/96; local a=u*PI*12
            local p=V3(math.cos(a)*.92,-3+u*6,math.sin(a)*.92)
            if previous then Geo.rod(sword,previous,p,.1,C.gold,0,Enum.Material.Metal) end
            previous=p
        end
        Geo.gem(sword,CF(0,-4.9,0),2.3,4.1,2,C.red)
        for _,side in ipairs({-1,1}) do
            Geo.horn(sword,CF(side*1.2,3.5,0)*rotation(0,0,-side*1.15),8.3,1.1,side*2.6,-.3,C.armor)
            Geo.plate(sword,CF(side*3.9,4.1,-.7)*rotation(0,0,-side*1.08),2.7,8.1,.65,C.gold)
        end
        Geo.loft(sword,CF(),{{5,3.4,.65},{7,4.1,1},{10,3.45,1.05},{28,2.65,.8},{37,2.15,.5},{47,.015,.015}},C.edge,12,Enum.Material.Metal)
        for _,side in ipairs({-1,1}) do
            previous=nil
            for i=0,40 do
                local u=i/40; local p=V3(side*(3.8*(1-u)^.62),7+u*38,-.02)
                if previous then Geo.rod(sword,previous,p,.105,C.red,.03) end
                previous=p
            end
            for i=1,11 do
                local y=8+i*2.8
                Geo.rod(sword,V3(side*.35,y,-1.11+i*.045),V3(side*1.35,y+.65,-.8+i*.02),.065,C.gold,0,Enum.Material.Metal)
            end
        end
        Geo.rod(sword,V3(0,7,-1.14),V3(0,41,-.3),.3,C.red)
        Geo.rod(sword,V3(0,7,1.14),V3(0,41,.3),.3,C.red)
        sword.WorldPivot=CF()
        S.sword.scale=CONFIG.GiantHeight/52
        sword:ScaleTo(S.sword.scale)
        S.sword.length=47*S.sword.scale
        local anchor=make("Part",{Name="BladeMotion",Size=V3(.1,.1,.1),Transparency=1,
            Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false},sword)
        local a=make("Attachment",{Position=V3(0,7*S.sword.scale,0)},anchor)
        local b=make("Attachment",{Position=V3(0,S.sword.length,0)},anchor)
        S.sword.trail=make("Trail",{Attachment0=a,Attachment1=b,Lifetime=.22,MinLength=.1,
            FaceCamera=true,Texture=TEX.plasma,LightEmission=1,Color=ColorSequence.new(WHITE,GOLD),
            Transparency=seq({{0,.25},{.4,.5},{1,1}}),WidthScale=NumberSequence.new(1,0),Enabled=false},anchor)
        for _,p in ipairs(sword:GetDescendants()) do
            if p:IsA("BasePart") then S.sword.parts[p]=p.Transparency; p.Transparency=1 end
        end
        S.sword.anchor=anchor
        S.sword.charge=emitter(anchor,"spark",GOLD,3,45,1.4,45)
        S.sword.energy={}
        for i=1,4 do S.sword.energy[i]=plasma(GOLD,4) end
    end

    local function buildWeaponAction()
        S.grips={}
        for _,side in ipairs({"Right","Left"}) do
            local hand=S.giant.model:FindFirstChild(side.."Hand") or S.giant.model:FindFirstChild(side.." Arm")
            if hand then
                local model=make("Model",{Name=side.."ArticulatedGauntlet"},S.giant.model)
                local grip={hand=hand,model=model,fingers={},parts={},side=side}
                local w,h,d=hand.Size.X,hand.Size.Y,hand.Size.Z
                local plate=make("Model",{Name="ForgedHandPlate"},model)
                Geo.plate(plate,CF(0,-h*.08,-d*.53),w*1.04,h*.86,d*.14,C.dark)
                plate.WorldPivot=CF();grip.plate=plate
                for finger=1,4 do
                    local root=make("Model",{Name="Finger"..finger},model)
                    local tip=make("Model",{Name="FingerTip"..finger},model)
                    local length=h*.38
                    Geo.loft(root,CF(),{{0,w*.064,d*.09},{-length*.4,w*.07,d*.10},{-length,w*.055,d*.07}},C.armor,8)
                    Geo.loft(tip,CF(),{{0,w*.054,d*.07},{-h*.2,w*.045,d*.065},{-h*.34,w*.014,d*.025,-d*.05}},C.dark,8)
                    Geo.rod(root,V3(0,-length*.12,-d*.1),V3(0,-length*.8,-d*.08),w*.018,GOLD,.16)
                    root.WorldPivot=CF();tip.WorldPivot=CF()
                    grip.fingers[#grip.fingers+1]={root=root,tip=tip,length=length,
                        rest=CF((finger-2.5)*w*.2,-h*.24,-d*.22),index=finger}
                end
                for _,p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") then
                    grip.parts[#grip.parts+1]={p,p.Transparency};p.Transparency=1
                end end
                S.grips[#S.grips+1]=grip
            end
        end
        S.weaponCradle=make("Model",{Name="FracturedSwordSocket"},scene)
        local right=armData(S.giant,"Right")
        local reach=right and right.reach or CONFIG.GiantHeight*.3
        local shoulderHeight=S.giant.height+(right.start-S.giant.root.Position).Y
        local ratio=clamp((shoulderHeight+reach*.15-.6)/S.sword.length,.32,.98)
        S.swordRestAngle=math.acos(-ratio)
        S.swordRestDirection=base:VectorToWorldSpace(V3(0,-ratio,math.sqrt(1-ratio*ratio)))
        S.swordRestGrip=world(-reach*.45,.6+ratio*S.sword.length,-600+reach*.13)
        S.swordRestTip=S.swordRestGrip+S.swordRestDirection*S.sword.length
        local center=S.swordRestTip
        for i=1,5 do
            local a=i*2.39996
            Geo.shard(S.weaponCradle,CF(center+base:VectorToWorldSpace(V3(math.cos(a)*24,-15,math.sin(a)*22)))
                *angles(0,i*52,0),V3(34+i%2*12,38+i%3*9,29+i%3*7),Color3.fromRGB(62,47,66))
        end
        S.weaponCradleParts={}
        for _,p in ipairs(S.weaponCradle:GetDescendants()) do if p:IsA("BasePart") then
            S.weaponCradleParts[#S.weaponCradleParts+1]=p;p.Transparency=1
        end end
    end

    local function updateGrips(t,alpha)
        for _,g in ipairs(S.grips) do
            local close=g.side=="Right" and phase(t,19.85,20.3) or phase(t,22.1,22.7)*(1-phase(t,29,30.5))
            g.plate:PivotTo(g.hand.CFrame)
            for _,f in ipairs(g.fingers) do
                local curl=close*(1-(f.index-1)*.025)
                local frame=g.hand.CFrame*f.rest*angles(curl*72,0,(f.index-2.5)*3*(1-close))
                f.root:PivotTo(frame)
                f.tip:PivotTo(frame*CF(0,-f.length,0)*angles(curl*82,0,0))
            end
            for _,p in ipairs(g.parts) do p[1].Transparency=1-(1-p[2])*alpha end
        end
    end

    local function animateSword(t,giantAlpha)
        local appear=phase(t,18.2,19.2)*(1-phase(t,34,38))
        updateGrips(t,giantAlpha)
        for _,p in ipairs(S.weaponCradleParts) do
            p.Transparency=1-phase(t,18.1,18.7)*(1-phase(t,21.7,22.7))
        end
        if t<18.2 or t>38 then
            for p in pairs(S.sword.parts) do p.Transparency=1 end
            for _,p in ipairs(S.sword.energy) do
                p.beam.Transparency=NumberSequence.new(1);p.halo.Transparency=NumberSequence.new(1);p.core.Transparency=NumberSequence.new(1)
            end
            S.sword.trail.Enabled=false;S.sword.charge.Enabled=false
            S.handPos=S.giant.root.Position
            return
        end
        local r,l=armData(S.giant,"Right"),armData(S.giant,"Left")
        local reach=r and r.reach or CONFIG.GiantHeight*.3
        local middle=l and r.start:Lerp(l.start,.5) or r.start
        local pull=phase(t,20.25,21.65)
        local raise=phase(t,21.7,26.35)
        local cut=clamp((t-26.4)/1.2,0,1)^2.65
        local restGrip=S.swordRestGrip
        local lifted=restGrip+V3(0,reach*.36,0)
        local overhead=middle+V3(0,reach*.64,0)+base:VectorToWorldSpace(V3(0,0,-reach*.08))
        local impactGrip=middle+base:VectorToWorldSpace(V3(0,-reach*.25,reach*.55))
        local grip=restGrip:Lerp(lifted,pull):Lerp(overhead,raise):Lerp(impactGrip,cut)
        local angle=mix(S.swordRestAngle,0,phase(t,21.1,24.8))
        local up=base:VectorToWorldSpace(V3(0,math.cos(angle),math.sin(angle)))
        local target=world(0,.6,-160)
        if cut>.001 then
            up=up:Lerp((target-grip).Unit,cut).Unit
            local axis=target-r.start;local distance=axis.Magnitude
            local radius=reach*.79
            local along=(distance*distance+radius*radius-S.sword.length*S.sword.length)/(2*distance)
            if math.abs(along)<radius then
                local direction=axis.Unit
                local side=grip-r.start-direction*(grip-r.start):Dot(direction)
                if side.Magnitude<.001 then side=base.RightVector end
                local contact=r.start+direction*along+side.Unit*math.sqrt(radius*radius-along*along)
                grip=grip:Lerp(contact,cut);up=up:Lerp((target-grip).Unit,cut).Unit
            else grip=grip:Lerp(target-up*S.sword.length,cut) end
        end
        local ref=base.LookVector
        if math.abs(up:Dot(ref))>.96 then ref=base.RightVector end
        local right=up:Cross(ref).Unit
        local frame=CFrame.fromMatrix(grip,right,up,right:Cross(up))
        if t>=27.6 and t<29.4 then
            local age=t-27.6;frame=frame*angles(0,math.sin(age*24)*math.exp(-age*3.6)*1.6,0)
        end
        local rightOffset=angles(0,0,90)*CF(0,r.hand.Size.Y*.1,r.hand.Size.Z*.32)
        local error=solveActorArm(S.giant,"Right",frame*rightOffset,phase(t,18.65,20))
        if t>=20.25 then
            frame=CF(-error)*frame
            solveActorArm(S.giant,"Right",frame*rightOffset,1)
        end
        if l then
            local leftOffset=CF(0,-2.3*S.sword.scale,0)*angles(0,0,-90)*CF(0,l.hand.Size.Y*.1,-l.hand.Size.Z*.32)
            solveActorArm(S.giant,"Left",frame*leftOffset,phase(t,21.4,22.5)*(1-phase(t,29,30.5)))
        end
        updateGrips(t,giantAlpha)
        S.sword.model:PivotTo(frame)
        S.swordCF=frame;S.bladeTip=frame*V3(0,S.sword.length,0);S.handPos=frame.Position
        S.swordGrasp=phase(t,18.65,20);S.swordHeld=t>=20.25
        for p,a in pairs(S.sword.parts) do p.Transparency=1-(1-a)*appear*giantAlpha end
        S.sword.trail.Enabled=(t>20.4 and t<24.8) or (t>26.35 and t<27.9)
        S.sword.charge.Enabled=t>19.8 and t<27.7
        for i,p in ipairs(S.sword.energy) do
            local sign=i%2==0 and 1 or -1
            drawPlasma(p,frame*V3(sign*S.sword.scale*2,9*S.sword.scale,0),
                frame*V3(0,(36+i)*S.sword.scale,0),1.2+raise*2,appear*giantAlpha*(.22+raise*.42),sign*(8+raise*11))
        end
    end

    local updateArrivalStage
    local function buildLandscape()
        S.ground={}
        for _,side in ipairs({-1,1}) do
            local m=make("Model",{Name=side<0 and "EarthLeft" or "EarthRight"},scene)
            local function seam(z) return math.sin(z*.008)*14+math.sin(z*.027)*4 end
            for column=0,1 do
                for row=0,2 do
                    Geo.surface(m,CF(),4,14,function(u,v)
                        local z=-2300+(row+v)/3*3900
                        local x=seam(z)+side*(column+u)/2*2300
                        local rough=math.sin(x*.014+z*.009)*math.sin(z*.021)*5
                        local clear=phase(math.abs(x),180,380)
                        return V3(x,rough*clear,z)
                    end,Color3.fromRGB(60,68,86),Enum.Material.Slate)
                end
            end
            for i=0,41 do
                local z=-2300+i/42*3900; local nextZ=-2300+(i+1)/42*3900
                local a,b=V3(seam(z),0,z),V3(seam(nextZ),0,nextZ)
                local lowerA=a+V3(side*30,-280,0); local lowerB=b+V3(side*30,-280,0)
                Geo.triangle(m,a,b,lowerB,Color3.fromRGB(44,37,53),.1,Enum.Material.Rock)
                Geo.triangle(m,a,lowerB,lowerA,Color3.fromRGB(65,43,56),.1,Enum.Material.Rock)
            end
            m.WorldPivot=CF(); m:PivotTo(base)
            S.ground[#S.ground+1]={model=m,side=side}
        end
        S.fault={}
        for i=1,32 do
            local z=-1250+(i-1)*70
            local a=world(math.sin(z*.008)*14,1,z)
            local b=world(math.sin((z+70)*.008)*14,1,z+70)
            S.fault[i]=plasma(GOLD,9)
            S.fault[i].originA=a; S.fault[i].originB=b; S.fault[i].z=z
        end
        S.horizon={}
        for i=1,30 do
            local a=i*2.39996; local distance=2000+(i%4)*230
            local x,z=math.cos(a)*distance,math.sin(a)*distance-450
            local rock=Geo.shard(scene,base*CF(x,100,z),V3(260+i%3*80,250+i%5*90,240+i%4*40),Color3.fromRGB(54,65,88))
            S.horizon[#S.horizon+1]=rock
        end
        local anchor=part("FaultRadiance",GOLD)
        anchor.CFrame=CF(world(0,-60,-180))
        S.faultLight=make("PointLight",{Color=GOLD,Range=60,Brightness=0,Shadows=false},anchor)

        S.finalArcs={}
        for i=1,8 do S.finalArcs[i]=plasma(GOLD,.12) end
        S.finalStones={}
        for i=1,16 do S.finalStones[i]=crystal("FloatingBasalt",Color3.fromRGB(81,54,70)) end
    end

    local function updateLandscape(t)
        local split=phase(t,27.6,31.4)
        for _,half in ipairs(S.ground) do
            half.model:PivotTo(base*CF(half.side*split*108,-split*12,0)*angles(0,0,-half.side*split*2))
        end
        S.faultLight.Brightness=split*3
        for i,p in ipairs(S.fault) do
            local arrival=27.6+math.abs(p.z+160)/2300
            local a=phase(t,arrival,arrival+.16)
            local pulse=.58+math.sin(t*4+i)*.15
            drawPlasma(p,p.originA-V3(0,split*12,0),p.originB-V3(0,split*12,0),
                7+split*20,a*pulse,0)
        end
        local on=phase(t,35,37)*(1-phase(t,61.5,64))
        local heroGround=world(0,0,-100)
        updateArrivalStage(t)
        local charge=phase(t,46,48.2)
        local after=phase(t,48.2,49.5)
        for i,p in ipairs(S.finalArcs) do
            local a=i*2.39996+t*.28
            local radius=3.1+(i%3)*.45
            local from=heroGround+base:VectorToWorldSpace(V3(math.cos(a)*radius,.2,math.sin(a)*radius))
            local to=heroGround+base:VectorToWorldSpace(V3(math.cos(a+.6)*radius*.85,5.5+(i%3)*1.4,math.sin(a+.6)*radius*.85))
            local alpha=on*(.12+charge*.48-after*.26)*(0.8+.2*math.sin(t*3+i))
            drawPlasma(p,from,to,.13+charge*.17,alpha,math.sin(t*2+i)*1.4)
        end
        for i,c in ipairs(S.finalStones) do
            local a=i*2.39996+t*(.17+(i%3)*.025)
            local radius=6+(i%4)*2+after*2
            local f=base*CF(math.cos(a)*radius,1.4+(i%5)*1.1+math.sin(t+i)*.4,-100+math.sin(a)*radius)*angles(t*19+i*23,t*22,0)
            drawCrystal(c,f,.25+i%3*.15,.8+i%4*.25,on*.85,true)
        end
    end

    local function installAura(actor,permanent)
        local head=actor:FindFirstChild("Head")
        local torso=actor:FindFirstChild("UpperTorso") or actor:FindFirstChild("Torso")
        if not head or not torso then return end
        local aura={objects={},layers={},eyes={},ribbons={}}
        local function own(obj) aura.objects[#aura.objects+1]=obj; return obj end
        local folder=own(make("Folder",{Name="CrimsonComebackAura"},actor))
        for _,side in ipairs({-1,1}) do
            local relative=CF(side*head.Size.X*CONFIG.EyeSeparation,head.Size.Y*CONFIG.EyeHeight,-head.Size.Z*CONFIG.EyeForward)
            local eye=part("CrimsonEye",GOLD,V3(head.Size.X*.11,head.Size.Y*.075,.065),folder)
            eye.Shape=Enum.PartType.Ball; eye.Anchored=false; eye.Massless=true
            eye.CFrame=head.CFrame*relative
            make("Weld",{Part0=head,Part1=eye,C0=relative},eye)
            aura.eyes[#aura.eyes+1]={part=eye,relative=relative}
            local a=own(make("Attachment",{CFrame=relative},head))
            local b=own(make("Attachment",{CFrame=relative*CF(0,head.Size.Y*.07,0)},head))
            local e=emitter(a,"spark",GOLD,.07,.5,.3,8)
            e.Acceleration=V3(0,1.6,0); aura.layers[#aura.layers+1]={e=e,rate=8}
            local trail=make("Trail",{Attachment0=a,Attachment1=b,Lifetime=.18,FaceCamera=true,
                LightEmission=1,Texture=TEX.plasma,Color=ColorSequence.new(WHITE,GOLD),
                Transparency=NumberSequence.new(.1,1),WidthScale=NumberSequence.new(1,0),Enabled=permanent},a)
            aura.eyes[#aura.eyes].trail=trail
            make("PointLight",{Color=GOLD,Brightness=.75,Range=4,Shadows=false},eye)
        end
        for _,side in ipairs({-1,1}) do
            local anchor=own(make("Attachment",{Position=V3(side*torso.Size.X*.65,-torso.Size.Y*.4,.1)},torso))
            local fire=emitter(anchor,"fire",GOLD,1.18,1.8,.85,18)
            fire.Color=ColorSequence.new(GOLD,Color3.fromRGB(120,0,24))
            fire.Acceleration=V3(side*.3,4,0); fire.SpreadAngle=Vector2.new(12,12)
            fire.Transparency=seq({{0,1},{.2,.42},{1,1}})
            aura.layers[#aura.layers+1]={e=fire,rate=18}
            local smoke=emitter(anchor,"mist",GOLD,1.5,.7,1.5,5)
            smoke.Acceleration=V3(side*.5,2.7,0);smoke.LightEmission=.2
            smoke.Color=ColorSequence.new(Color3.fromRGB(147,3,26),Color3.fromRGB(41,4,17))
            smoke.Transparency=seq({{0,1},{.25,.85},{1,1}})
            aura.layers[#aura.layers+1]={e=smoke,rate=5}
            local embers=emitter(anchor,"spark",GOLD,.1,3,1.1,18)
            embers.Acceleration=V3(0,5,0); aura.layers[#aura.layers+1]={e=embers,rate=18}
        end
        for _,side in ipairs({-1,1}) do
            local a=own(make("Attachment",{Position=V3(side*torso.Size.X*.64,-torso.Size.Y*.52,torso.Size.Z*.62)},torso))
            local b=own(make("Attachment",{Position=V3(side*torso.Size.X*.8,torso.Size.Y*.78,torso.Size.Z*.7)},torso))
            local beam=make("Beam",{Name="BodyFlameRibbon",Attachment0=a,Attachment1=b,
                Width0=.34,Width1=.025,FaceCamera=true,Segments=16,Texture=TEX.fire,
                TextureMode=Enum.TextureMode.Stretch,TextureSpeed=1.6,LightEmission=1,
                Color=ColorSequence.new(GOLD),Transparency=NumberSequence.new(1)},a)
            aura.ribbons[#aura.ribbons+1]={beam=beam,side=side}
        end
        function aura.update(power,time)
            local now=time or os.clock()
            local breathing=.94+.06*math.sin(now*2.3)
            for _,ribbon in ipairs(aura.ribbons) do
                ribbon.beam.CurveSize0=ribbon.side*(.38+math.sin(now*2.9+ribbon.side)*.22)
                ribbon.beam.CurveSize1=-ribbon.side*(.25+math.sin(now*3.3)*.14)
                ribbon.beam.Transparency=seq({{0,1},{.2,1-clamp(power*.32,0,.6)},
                    {.68,1-clamp(power*.2,0,.5)},{1,1}})
            end
            for _,eye in ipairs(aura.eyes) do
                eye.part.Transparency=1-clamp(power*1.8,0,1)
                if not permanent then eye.part.CFrame=head.CFrame*eye.relative end
                eye.trail.Enabled=power>.1
            end
            for _,entry in ipairs(aura.layers) do entry.e.Enabled=power>.01; entry.e.Rate=entry.rate*power*breathing end
        end
        aura.update(permanent and 1 or 0)
        if permanent then
            for _,obj in ipairs(aura.objects) do persistent[#persistent+1]=obj end
            persistentConnections[#persistentConnections+1]=RunService.Heartbeat:Connect(function()
                if not actor.Parent or humanoid.Health<=0 then clearPersistent();return end
                aura.update(1,os.clock())
            end)
            persistentConnections[#persistentConnections+1]=humanoid.Died:Connect(clearPersistent)
            persistentConnections[#persistentConnections+1]=player.CharacterRemoving:Connect(clearPersistent)
        end
        return aura
    end

    local function buildArrivalAction()
        local model=make("Model",{Name="FracturedArrivalPlatform"},scene)
        local rim,lower={},{}
        for i=1,13 do
            local angle=i/13*2*PI
            local radius=8.2+.65*math.sin(i*7.3)+.35*math.sin(i*17.1)
            rim[i]=V3(math.cos(angle)*radius,0,math.sin(angle)*radius)
            lower[i]=V3(rim[i].X*(.58+(i%3)*.1),-4.5-(i%4)*.65,rim[i].Z*(.64+(i%2)*.12))
        end
        for i=1,13 do
            local j=i%13+1
            Geo.triangle(model,V3(),rim[i],rim[j],Color3.fromRGB(71,61,80),.1,Enum.Material.Slate)
            Geo.triangle(model,rim[i],lower[i],lower[j],Color3.fromRGB(46,36,53),.08,Enum.Material.Rock)
            Geo.triangle(model,rim[i],lower[j],rim[j],Color3.fromRGB(59,42,62),.08,Enum.Material.Rock)
            Geo.triangle(model,V3(.4,-8,-.3),lower[j],lower[i],Color3.fromRGB(36,30,45),.08,Enum.Material.Rock)
        end
        S.arrivalVeins={}
        for branch=1,7 do
            local angle=branch*2.39996
            local previous=V3(math.cos(angle)*1.1,.12,math.sin(angle)*1.1)
            for segment=1,5 do
                local radius=1.1+segment*1.18
                local a=angle+math.sin(segment*2.1+branch)*.13
                local point=V3(math.cos(a)*radius,.12,math.sin(a)*radius)
                local p=Geo.rod(model,previous,point,.045,GOLD,1)
                S.arrivalVeins[#S.arrivalVeins+1]={part=p,step=segment,branch=branch}
                previous=point
            end
        end
        model.WorldPivot=CF();S.arrivalPlatform=model
        S.arrivalPlatformParts={}
        for _,p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") then
            S.arrivalPlatformParts[#S.arrivalPlatformParts+1]={p,p.Transparency};p.Transparency=1
        end end
        model:PivotTo(base*CF(0,-8,-100))
        S.arrivalFragments={}
        for i=1,5 do
            local a=i*2.39996
            local stone=Geo.shard(scene,CF(),V3(1.9+i%2,2.4+i%3*.4,2.5),Color3.fromRGB(67,43,66))
            local parts={}
            for _,p in ipairs(stone:GetDescendants()) do if p:IsA("BasePart") then parts[#parts+1]=p;p.Transparency=1 end end
            S.arrivalFragments[i]={model=stone,parts=parts,angle=a}
        end
        S.heroEchoes={}
        for i=1,2 do
            local copy=cloneCharacter()
            for _,obj in ipairs(copy:GetDescendants()) do
                if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic")
                    or obj:IsA("SurfaceAppearance") or obj:IsA("Decal") or obj:IsA("Texture") then obj:Destroy() end
            end
            local rig=prepareRig(copy,nil,"CrimsonMotionEcho"..i,GOLD)
            for p in pairs(rig.parts) do
                if p:IsA("BasePart") then
                    p.Material=Enum.Material.Neon;p.Color=GOLD
                    if p:IsA("MeshPart") then p.TextureID="" end
                    for _,child in ipairs(p:GetChildren()) do if child:IsA("SpecialMesh") then child.TextureId="" end end
                end
            end
            rig.echoDelay=.09*i
            S.heroEchoes[i]=rig
        end
        S.heroChargeCrystal=crystal("CrimsonPalmCharge",GOLD)
        S.heroChargeStreams={}
        for i=1,4 do S.heroChargeStreams[i]=plasma(GOLD,.08) end
        S.arrivalWake={}
        for i=1,3 do S.arrivalWake[i]=plasma(GOLD,.12) end
    end

    updateArrivalStage=function(t)
        local visible=phase(t,35,36.2)*(1-phase(t,63.2,64))
        local rise=phase(t,35,36.6)
        S.arrivalPlatform:PivotTo(base*CF(0,-8*(1-rise),-100))
        for _,p in ipairs(S.arrivalPlatformParts) do p[1].Transparency=1-(1-p[2])*visible end
        for _,v in ipairs(S.arrivalVeins) do
            local on=phase(t,36.8+v.step*.055,37.2+v.step*.055)
            local pulse=phase(t,46,48.2)*(1-phase(t,49,51))
            v.part.Transparency=1-visible*on*(.35+pulse*.55)
        end
        for i,f in ipairs(S.arrivalFragments) do
            local move=phase(t,35.1+i*.035,36.65+i*.025)
            local radius=mix(17,8.2,move)
            local cf=base*CF(math.cos(f.angle)*radius,mix(4+(i%3),-1.5,move),-100+math.sin(f.angle)*radius)
                *angles((1-move)*t*25+i*31,(1-move)*t*33+i*42,0)
            f.model:PivotTo(cf)
            for _,p in ipairs(f.parts) do p.Transparency=1-visible end
        end
    end

    local function arrivalMotion(t)
        local fall=clamp((t-36)/1.1,0,1)^2
        local land=phase(t,37,37.18)*(1-phase(t,38.1,39.45))
        local advance=phase(t,39.7,41.8)
        local x=math.sin(fall*PI)*.8
        local z=-104+advance*6.5-(1-fall)*3
        local y=S.actor.height+(1-fall)*13-land*.28
        return base*CF(x,y,z)*angles(0,180,0),land
    end

    local function updateHero(t)
        if t<8.5 then return end
        local visible=phase(t,35.65,36.15)
        if visible<=0 then visibility(S.actor,0);return end
        local frame,land=arrivalMotion(t)
        poseRig(S.actor,frame,"arrival",land,t,t>=37.1 and base.Position.Y+.02 or nil)
        if land>.1 then
            local hand=base*CF(.9,.18,-103.1)*angles(-90,180,0)
            solveActorArm(S.actor,"Right",hand,land)
        end
        visibility(S.actor,visible)
        S.heroPos=S.actor.root.Position
        local charge=phase(t,46,48.2)*(1-phase(t,48.2,50))
        S.heroAura.update(visible*(.75+charge*.85+phase(t,48.2,49)*.3),t)
        local dash=phase(t,39.8,40.1)*(1-phase(t,41.65,42.05))
        for i,echo in ipairs(S.heroEchoes) do
            local cf,weight=arrivalMotion(t-echo.echoDelay)
            poseRig(echo,cf,"arrival",weight,t-echo.echoDelay,base.Position.Y+.02)
            visibility(echo,dash*(.2-i*.045))
        end
        local wake=phase(t,35.8,36.1)*(1-phase(t,37.1,37.4))
        for i,p in ipairs(S.arrivalWake) do
            local a=S.heroPos+base:VectorToWorldSpace(V3((i-2)*.35,1+(i%2)*.5,-.3))
            local b=a+V3((i-2)*.45,4+(i%2)*2,0)+base.LookVector*1.2
            drawPlasma(p,a,b,.12,wake*.7,math.sin(t*7+i)*.5)
        end
        local right=S.actor.model:FindFirstChild("RightHand") or S.actor.model:FindFirstChild("Right Arm")
        local left=S.actor.model:FindFirstChild("LeftHand") or S.actor.model:FindFirstChild("Left Arm")
        local center=right and left and right.Position:Lerp(left.Position,.5) or S.heroPos+V3(0,1,0)
        drawCrystal(S.heroChargeCrystal,CF(center)*angles(t*90,t*120,0),.22+charge*.45,.5+charge*.85,charge*.9)
        for i,p in ipairs(S.heroChargeStreams) do
            local a=base*V3(math.cos(i*2.399)*4,.3,-97.5+math.sin(i*2.399)*4)
            drawPlasma(p,a,center,.06+charge*.08,charge*.7,math.sin(t*5+i)*1.5)
        end
    end

    local function trailOn(part0,color,width)
        local a=make("Attachment",{Position=V3(-width*0.5,0,0)},part0)
        local b=make("Attachment",{Position=V3(width*0.5,0,0)},part0)
        return make("Trail",{Attachment0=a,Attachment1=b,Lifetime=0.8,MinLength=0.1,
            FaceCamera=true,LightEmission=1,Texture=TEX.plasma,TextureLength=20,
            Color=ColorSequence.new(WHITE,color),Transparency=seq({{0,0.1},{0.6,0.4},{1,1}}),
            WidthScale=NumberSequence.new(1,0),Enabled=false},part0)
    end
    -- Capas que pulen los golpes existentes; no introducen escenas nuevas.
    local function pressureFront(position,radius,life)
        local group=make("Model",{Name="TexturedPressureFront"},scene)
        local fx={obj=group,pressure=true,born=elapsed,life=life,radius=radius,pos=position,rays={}}
        for i=1,19 do
            local angle=i*2.39996+rng:NextNumber(-.18,.18)
            local direction=base:VectorToWorldSpace(V3(math.cos(angle),0,math.sin(angle)))
            fx.rays[i]={p=plasma(GOLD,1,group),dir=direction,
                reach=radius*rng:NextNumber(.65,1.1),seed=i,
                width=math.max(.08,radius*rng:NextNumber(.012,.023))}
        end
        effects[#effects+1]=fx
    end

    local function bladeAfterimage(previousBase,previousTip,currentBase,currentTip)
        if (previousTip-currentTip).Magnitude<.2 then return end
        local m=make("Model",{Name="BladeSweptPlasma"},scene)
        Geo.triangle(m,previousBase,previousTip,currentTip,GOLD,.035,Enum.Material.Neon)
        Geo.triangle(m,previousBase,currentTip,currentBase,GOLD,.035,Enum.Material.Neon)
        local parts={}
        for _,p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") then
            p.Transparency=.72; parts[#parts+1]=p
        end end
        local edge=plasma(CYAN,3,m)
        drawPlasma(edge,previousTip,currentTip,3,.45,0)
        effects[#effects+1]={obj=m,sweep=true,born=elapsed,life=.24,parts=parts,edge=edge}
    end

    local function buildDetailVFX()
        S.starFilaments={}
        for i=1,5 do S.starFilaments[i]=plasma(GOLD,8) end
        S.faultJets={}
        for i=1,11 do
            local z=-1050+(i-1)*145
            local holder=part("FaultFlameVent",GOLD)
            holder.CFrame=CF(world(0,2,z))
            local fire=emitter(holder,"fire",GOLD,42+(i%3)*15,120,1.1,19)
            fire.Acceleration=V3(0,70,0); fire.Drag=1.8
            fire.SpreadAngle=Vector2.new(12,18); fire.EmissionDirection=Enum.NormalId.Top
            fire.Color=ColorSequence.new(GOLD,Color3.fromRGB(114,0,26))
            fire.Transparency=seq({{0,.35},{.15,.18},{.75,.6},{1,1}})
            S.faultJets[i]={e=fire,z=z,index=i}
        end
        S.bladePreviousBase,S.bladePreviousTip,S.bladeSample=nil,nil,-1
    end

    local function updateDetailVFX(t)
        local starOn=phase(t,6,7.5)*(1-phase(t,13.3,16.5))
        local grow=.25+.75*out((t-6)/2.6)
        local starCF=base*CF(0,950,-780)*angles(0,0,8*math.sin(t*.3))
        for i,p in ipairs(S.starFilaments) do
            local a=(i-1)*2*PI/5+PI/2
            local pulse=.62+.22*math.sin(t*8+i*1.7)
            local from=starCF*V3(math.cos(a)*42*grow,math.sin(a)*42*grow,35*grow)
            local to=starCF*V3(math.cos(a)*370*grow,math.sin(a)*370*grow,0)
            drawPlasma(p,from,to,(4+3*pulse)*grow,starOn*pulse,math.sin(t*4+i)*12)
        end
        for _,jet in ipairs(S.faultJets) do
            local reveal=27.6+math.abs(jet.z+160)/2300
            local on=phase(t,reveal,reveal+.4)*(1-phase(t,31.3,34))
            jet.e.Enabled=on>.02
            jet.e.Rate=19*on*(.75+.25*math.sin(t*5+jet.index))
        end
        if S.swordCF and ((t>=21.4 and t<24.2) or (t>=26.35 and t<27.85)) then
            local currentBase=S.swordCF*V3(0,7*S.sword.scale,0)
            local currentTip=S.bladeTip
            if S.bladePreviousBase and t-S.bladeSample>.025 then
                bladeAfterimage(S.bladePreviousBase,S.bladePreviousTip,currentBase,currentTip)
                S.bladeSample=t
            end
            S.bladePreviousBase,S.bladePreviousTip=currentBase,currentTip
        else
            S.bladePreviousBase,S.bladePreviousTip=nil,nil
        end
    end

    local function hidePlasma(p)
        p.beam.Transparency=NumberSequence.new(1)
        p.core.Transparency=NumberSequence.new(1)
        p.halo.Transparency=NumberSequence.new(1)
    end

    makeGroundShard=function(color,parent)
        local dimensions=V3(rng:NextNumber(.72,1.2),rng:NextNumber(1.35,2.3),rng:NextNumber(.65,1.1))
        local model=Geo.shard(parent,CF(),dimensions,color)
        model.Name="RoughFracturedBasalt"
        local rock={model=model,rough=true,parts={}}
        for _,p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then rock.parts[#rock.parts+1]=p;p.Transparency=1 end
        end
        return rock
    end

    local function buildPolishedVFX()
        S.motionStreaks={}
        for i=1,17 do
            S.motionStreaks[i]={p=plasma(GOLD,.055),angle=i*2.39996,
                radius=1+(i%4)*.12,phase=i*.137,length=4+(i%5)*1.3}
        end
        S.surfaceVeins,S.hotEdges={},{ }
        for _,half in ipairs(S.ground) do
            local side=half.side
            for branch=1,9 do
                local z=-1120+(branch-1)*170
                local seam=math.sin(z*.008)*14+math.sin(z*.027)*4
                local previous=V3(seam+side*3,.32,z)
                local reach=65+(branch%4)*24
                for segment=1,5 do
                    local f=segment/5
                    local point=V3(seam+side*(3+reach*f),.32,
                        z+math.sin(segment*2.1+branch)*reach*.12+f*reach*.28)
                    local vein={p=plasma(GOLD,1),a=previous,b=point,half=half,
                        time=27.6+math.abs(z+160)/2300+segment*.045,
                        width=(1.4-f*.85),seed=branch+side*11}
                    S.surfaceVeins[#S.surfaceVeins+1]=vein
                    previous=point
                end
            end
            for section=0,41 do
                local z=-2300+section/42*3900
                local nextZ=-2300+(section+1)/42*3900
                local a=V3(math.sin(z*.008)*14+math.sin(z*.027)*4,-3,z)
                local b=V3(math.sin(nextZ*.008)*14+math.sin(nextZ*.027)*4,-3,nextZ)
                local line=Geo.rod(half.model,a,b,.75,GOLD,1)
                line.Name="IncandescentFaultLip"
                line.CFrame=base*line.CFrame
                S.hotEdges[#S.hotEdges+1]={part=line,z=z}
            end
        end
    end

    local function updatePolishedVFX(t)
        -- Solo se activa durante los impulsos que ya existen en el montaje.
        local launch=phase(t,3.35,3.48)*(1-phase(t,3.8,4.15))
        local nova=phase(t,8.45,8.56)*(1-phase(t,8.95,9.35))
        local slash=phase(t,26.65,27.45)*(1-phase(t,27.6,27.9))
        local aura=phase(t,48.2,48.3)*(1-phase(t,48.6,49.05))
        local speed=math.max(launch,nova,slash,aura)
        for _,line in ipairs(S.motionStreaks) do
            if speed<.002 then hidePlasma(line.p)
            else
                local travel=(t*2.1+line.phase)%1
                local x=math.cos(line.angle)*line.radius*(13+travel*8)
                local y=math.sin(line.angle)*line.radius*(8+travel*5)
                local near=cam.CFrame*V3(x,y,-28-travel*12)
                local far=cam.CFrame*V3(x*.94,y*.94,-28-travel*12-line.length)
                drawPlasma(line.p,near,far,.045+speed*.055,speed*.48,0)
                -- Estos trazos conservan el rojo; el nucleo blanco permanece muy tenue.
                line.p.core.Transparency=NumberSequence.new(1-speed*.06)
            end
        end
        local split=phase(t,27.6,31.4)
        for _,vein in ipairs(S.surfaceVeins) do
            local frame=base*CF(vein.half.side*split*108,-split*12,0)*angles(0,0,-vein.half.side*split*2)
            local on=phase(t,vein.time,vein.time+.22)
            local pulse=.42+.12*math.sin(t*3.7+vein.seed)
            drawPlasma(vein.p,frame*vein.a,frame*vein.b,vein.width,on*pulse,0)
        end
        for _,edge in ipairs(S.hotEdges) do
            local on=phase(t,27.6+math.abs(edge.z+160)/2300,28.2+math.abs(edge.z+160)/2300)
            edge.part.Transparency=1-on*(.38+.1*math.sin(t*3+edge.z*.01))
        end
        if t>6 and t<16.5 then
            local pulse=.5+.5*math.sin(t*6.5)
            S.star.sparks.Rate=72+34*pulse
            S.star.glints.Rate=23+15*pulse
        end
    end


    local function bladeContactSparks(position,scale)
        local group=make("Model",{Name="DirectionalBladeContact"},scene)
        for _,side in ipairs({-1,1}) do
            local direction=(base.RightVector*side+base.LookVector*.24+V3(0,.46,0)).Unit
            local holder=part("ContactSparkSource",GOLD,V3(.1,.1,.1),group)
            holder.CFrame=CFrame.lookAt(position,position+direction)
            local e=emitter(holder,"spark",GOLD,scale*1.4,scale*480,.95,0)
            e.EmissionDirection=Enum.NormalId.Front;e.SpreadAngle=Vector2.new(14,21)
            e.Acceleration=V3(0,-scale*150,0);e.Drag=1.2
            e.Size=seq({{0,scale*.9},{.12,scale*1.5},{1,0}})
            e:Emit(90)
            local smoke=emitter(holder,"mist",Color3.fromRGB(114,106,120),scale*28,scale*95,1.8,0)
            smoke.EmissionDirection=Enum.NormalId.Front;smoke.SpreadAngle=Vector2.new(4,10)
            smoke.Acceleration=V3(0,scale*2,0);smoke.Drag=2.4;smoke.LightEmission=.12
            smoke.Color=ColorSequence.new(Color3.fromRGB(135,124,133),Color3.fromRGB(51,44,60))
            smoke.Transparency=seq({{0,1},{.18,.72},{1,1}})
            smoke:Emit(16)
        end
        effects[#effects+1]={obj=group,born=elapsed,life=2.2}
    end

    local function buildScene()
        S.actor=prepareRig(cloneCharacter(),nil,player.Name.."_Witness",GOLD)
        local giantAvatar=loadGiantAvatar()
        if dead or not giantAvatar then return end
        S.giant=prepareRig(giantAvatar,CONFIG.GiantHeight,"mygame43_CrimsonSovereign",GOLD)

        S.star={core=crystal("FivePointStar_Heart",WHITE),spikes={},rays={},plasma={}}
        for i=1,5 do
            S.star.spikes[i]={outer=crystal("SolarPoint_"..i,GOLD),inner=crystal("WhiteHotPoint_"..i,WHITE)}
        end
        for i=1,low and 16 or 32 do S.star.rays[i]=crystal("CoronalBlade",i%3==0 and CYAN or GOLD) end
        for i=1,5 do S.star.plasma[i]=plasma(i%2==0 and CYAN or GOLD,30) end
        S.star.anchor=part("StarRadiance",GOLD)
        S.star.sparks=emitter(S.star.anchor,"spark",GOLD,14,180,3,90)
        S.star.glints=emitter(S.star.anchor,"glint",WHITE,60,100,2,35)
        S.star.vapor=emitter(S.star.anchor,"mist",GOLD,180,90,4,8)
        S.star.vapor.Transparency=seq({{0,1},{0.25,0.82},{1,1}})
        S.star.light=make("PointLight",{Color=GOLD,Brightness=0,Range=60,Shadows=false},S.star.anchor)
    
        S.charge={core=crystal("GenesisCrystal",WHITE),shards={},streamers={}}
        for i=1,low and 8 or 14 do S.charge.shards[i]=crystal("GatheringCrystal",i%2==0 and CYAN or GOLD) end
        for i=1,6 do S.charge.streamers[i]=plasma(i%2==0 and CYAN or GOLD,1.5) end
        S.beam={core=part("HeavenSplitterCore",WHITE),mid=part("HeavenSplitterInner",CYAN),outer=part("HeavenSplitterCorona",PURPLE),plasma={},bolts={}}
        for i=1,4 do S.beam.plasma[i]=plasma(i%2==0 and GOLD or CYAN,42); S.beam.bolts[i]=bolt(CYAN) end
        S.levitation={}
        for i=1,28 do
            S.levitation[i]=crystal("LevitatingBasalt",Color3.fromRGB(57,49,69))
        end


        S.back={}
        for i=1,8 do S.back[i]=plasma(i%2==0 and GOLD or CYAN,32) end
        S.shoulders={}
        for i=1,6 do S.shoulders[i]=crystal("SolarShoulderFacet",i%3==0 and WHITE or GOLD) end
        S.wristTrails={}
        for _,name in ipairs({"RightHand","LeftHand","Right Arm","Left Arm","RightFoot","LeftFoot"}) do
            local p=S.giant.model:FindFirstChild(name)
            if p then S.wristTrails[#S.wristTrails+1]=trailOn(p,GOLD,p.Size.X*0.8) end
        end
        S.bodyEmitters={}
        for _,name in ipairs({"UpperTorso","Torso","RightHand","LeftHand","Right Arm","Left Arm"}) do
            local p=S.giant.model:FindFirstChild(name)
            if p then
                local e=emitter(p,"glint",GOLD,14,18,2.5,8)
                S.bodyEmitters[#S.bodyEmitters+1]=e
            end
        end
        S.dust={}
        for i=1,low and 8 or 18 do
            local anchor=part("AtmosphericEmbers",GOLD)
            local a=i*2.399
            anchor.CFrame=CF(world(math.cos(a)*370,20+(i%6)*80,-500+math.sin(a)*300))
            local e=emitter(anchor,"spark",i%2==0 and CYAN or GOLD,4,12,4,8)
            S.dust[i]=e
        end

        S.meteors={}
        for i=1,low and 12 or 24 do S.meteors[i]=crystal("SolarEjecta",i%2==0 and GOLD or CYAN) end

        buildSword()
        buildWeaponAction()
        buildLandscape()
        buildArrivalAction()
        S.heroAura=installAura(S.actor.model,false)
        buildDetailVFX()
        buildPolishedVFX()
        S.heroPos=world(0,S.actor.height+15,-100)
        S.fade=make("Frame",{Name="ExitFade",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(0,0,0),
            BackgroundTransparency=1,BorderSizePixel=0},gui)
        S.audio={impact=sound(CONFIG.Impact,1.1),roar=sound(CONFIG.Roar,0.8),rumble=sound(CONFIG.Rumble,0.45,true),
            snap=sound("rbxasset://sounds/switch.wav",1.4),music=sound(CONFIG.Music,0.7)}
    end
    

    local function updateEffects()
        for i=#effects,1,-1 do
            local e=effects[i]; local age=elapsed-e.born; local t=age/e.life
            if t>=1 then
                if e.obj then e.obj:Destroy() end; if e.core then e.core:Destroy() end
                table.remove(effects,i)
            elseif e.pressure then
                local advance=1-(1-t)^3
                for _,ray in ipairs(e.rays) do
                    local a=e.pos+ray.dir*ray.reach*advance+V3(0,.2,0)
                    local b=a+ray.dir*(e.radius*.055+e.radius*.18*(1-t))
                        +V3(0,e.radius*.014*math.sin(t*PI),0)
                    local alpha=(1-t)^1.1*(.65+.2*math.sin(ray.seed+t*10))
                    drawPlasma(ray.p,a,b,ray.width*(1-t*.75),alpha,math.sin(t*8+ray.seed)*e.radius*.012)
                end
            elseif e.sweep then
                for _,p in ipairs(e.parts) do p.Transparency=1-.28*(1-t)^1.5 end
                e.edge.beam.Transparency=NumberSequence.new(1-.45*(1-t))
                e.edge.core.Transparency=NumberSequence.new(1-.2*(1-t))
                e.edge.halo.Transparency=NumberSequence.new(1-.08*(1-t))
            elseif e.fracture then
                local alpha=1-phase(t,0.45,1)
                for j,s in ipairs(e.shards) do
                    local distance=s.speed*age*(e.ground and 1 or (0.55+t*0.8))
                    local pos=s.origin+s.direction*distance
                    if e.ground then
                        pos=pos-V3(0,e.radius*0.12*age*age,0)
                        pos=V3(pos.X,math.max(e.pos.Y+s.width*0.5,pos.Y),pos.Z)
                    end
                    local f=CFrame.lookAt(pos,pos+s.direction)*angles(90+s.spin.X*age,s.spin.Y*age,s.spin.Z*age)
                    drawCrystal(s.c,f,s.width*(1-t*0.35),s.length*(1-t*0.25),alpha,e.ground)
                    local tail=pos-s.direction*math.min(distance,s.length*(2+t*3))
                    drawPlasma(s.wake,tail,pos,s.width*(e.ground and 0.2 or 0.5),alpha*0.7,0)
                end
                for _,crack in ipairs(e.cracks) do
                    for j,p in ipairs(crack.beams) do
                        local reveal=phase(t,0.025*(j-1),0.025*j+0.06)
                        drawPlasma(p,crack.points[j],crack.points[j+1],math.max(0.5,e.radius*0.004),reveal*alpha*0.85,0)
                    end
                end
            elseif e.body then
                e.obj.CFrame=(e.origin+e.velocity*age+V3(0,20*age*age,0))*angles(t*150,t*220,0)
                e.obj.Size=e.size*math.max(0.02,1-t*0.94)
                e.obj.Transparency=t^0.55
            end
        end
    end
    
    -- Camara: cortes deliberados, orbitas, contrapicados y cambios de velocidad.
    -- Camera.Value+10 gana a la camara normal; no se acumula error de interpolacion.
    local function cinematicCamera(t,dt)
        local position,focus,fov,roll
        roll=0
        if t<3.35 then
            local p=clamp(t/3.35,0,1); local a=-1.4+p*3.7
            local r=15-5*p
            position=world(math.sin(a)*r,3+7*p,math.cos(a)*r)
            focus=world(0,5+p*3,0); fov=74-p*16; roll=math.sin(p*PI)*-9
        elseif t<6 then
            local p=out((t-3.35)/2.65)
            position=world(mix(6,95,p),mix(8,160,p),mix(12,130,p))
            focus=world(0,mix(10,820,p),0); fov=mix(58,100,p); roll=mix(-10,6,p)
        elseif t<8.4 then
            local p=(t-6)/2.4; local a=-0.5+p*1.9
            position=world(math.sin(a)*390,650+p*180, -760+math.cos(a)*480)
            focus=S.starPos; fov=94-20*p; roll=10-20*p
        elseif t<11.6 then
            local p=clamp((t-8.4)/3.2,0,1); local retreat=out(p)
            position=world(mix(25,900,retreat),mix(780,460,retreat),mix(-340,1250,retreat))
            focus=world(0,mix(850,520,p),-650); fov=62+32*retreat; roll=-12*(1-p)
        elseif t<16 then
            -- Media orbita completa: el mundo y las estelas pasan junto a la lente.
            local p=(t-11.6)/4.4; local a=0.48+p*2.65
            position=world(math.sin(a)*1000,mix(550,125,p),-600+math.cos(a)*1000)
            focus=S.giantPos+V3(0,75,0); fov=84+6*math.sin(p*PI); roll=math.sin(p*PI)*9
        elseif t<18.5 then
            -- Los pies ocupan el primer plano; el craneo sube centenares de studs.
            local p=phase(t,16,18.5)
            position=world(mix(-210,210,p),mix(14,90,p),mix(-330,-180,p))
            focus=world(0,mix(95,300,p),-600); fov=100-16*p; roll=-6+9*p
        elseif t<20.4 then
            local p=phase(t,18.5,20.4)
            position=world(mix(-500,-320,p),mix(240,320,p),mix(150,-50,p))
            focus=S.swordCF and S.swordCF.Position:Lerp(S.giantPos,.18) or S.giantPos
            fov=72-10*p;roll=-3*math.sin(p*PI)
        elseif t<22 then
            local p=phase(t,20.4,22)
            position=world(mix(-320,480,p),mix(320,270,p),mix(-50,340,p))
            focus=S.swordCF.Position:Lerp(S.bladeTip,.3);fov=62+18*p;roll=5*math.sin(p*PI)

        elseif t<26.4 then
            local p=phase(t,22,26.4)
            position=world(mix(620,480,p),mix(200,410,p),mix(300,420,p))
            focus=S.swordCF.Position:Lerp(S.bladeTip,.55); fov=80+6*p; roll=-5*math.sin(p*PI)
        elseif t<27.6 then
            local p=clamp((t-26.4)/1.2,0,1)
            position=world(-650+90*p,320-110*p,500+120*p)
            focus=S.swordCF.Position:Lerp(S.bladeTip,.68); fov=86+14*p; roll=8-15*p
        elseif t<31.2 then
            local p=out((t-27.6)/3.6)
            position=world(mix(490,1150,p),mix(190,780,p),mix(410,1250,p))
            focus=world(0,12,-170); fov=90+8*p; roll=7*(1-p)
        elseif t<35 then
            local p=phase(t,31.2,35)
            position=world(mix(-410,-120,p),mix(90,38,p),mix(50,-20,p))
            focus=world(0,mix(290,20,p),mix(-570,-100,p)); fov=84-22*p
            roll=-4*math.sin(p*PI)
        elseif t<37.1 then
            local p=phase(t,35,37.1)
            position=world(mix(15,7,p),mix(9,2.3,p),mix(-66,-86,p))
            focus=S.actor.root.Position+V3(0,.9,0);fov=64+8*p;roll=4*(1-p)
        elseif t<39.7 then
            local p=phase(t,37.1,39.7)
            position=world(mix(-7,-5,p),mix(1.4,3.5,p),mix(-86,-88,p))
            focus=S.actor.root.Position+V3(0,.8,0);fov=64-12*p;roll=-3*(1-p)
        elseif t<44 then
            local p=phase(t,39.7,44)
            position=S.actor.root.Position+base:VectorToWorldSpace(V3(mix(-5.5,-3,p),mix(1.2,1.5,p),mix(12,11,p)))
            focus=S.actor.root.Position+V3(0,1,0);fov=56-12*p;roll=-2*math.sin(p*PI)

        elseif t<46 then
            local p=phase(t,44,46)
            local h=S.actor.model:FindFirstChild("Head") or S.actor.root
            local scale=math.max(.7,h.Size.X/2)
            position=h.Position+base:VectorToWorldSpace(V3(mix(-.65,.7,p),.06,mix(3.7,4.1,p))*scale)
            focus=h.Position; fov=35+3*p; roll=-1.5+3*p
        elseif t<48.2 then
            local p=phase(t,46,48.2)
            position=world(mix(4.6,3.6,p),mix(2.4,2,p),mix(-88,-89,p))
            focus=S.actor.root.Position+V3(0,.8,0); fov=50-5*p; roll=-4*p
        elseif t<50.4 then
            local p=out((t-48.2)/2.2)
            position=world(mix(3.6,17,p),mix(2,5.5,p),mix(-89,-70,p))
            focus=S.actor.root.Position+V3(0,1,0); fov=45+22*p; roll=-4*(1-p)
        elseif t<58 then
            local p=(t-50.4)/7.6; local a=.52-p*2.05
            position=world(math.sin(a)*21,3.5+3*math.sin(p*PI),-97.5+math.cos(a)*21)
            focus=S.actor.root.Position+V3(0,1,0); fov=63-5*p; roll=2*math.sin(p*PI)
        else
            local p=phase(t,58,63.5)
            position=world(mix(-21,-7,p),mix(4.5,3.5,p),mix(-96.4,-80,p))
            focus=S.actor.root.Position+V3(0,1.15,0); fov=mix(58,53,p)
        end
        local movingShake=shake+(t>3.35 and t<8.4 and .9 or 0)
        local n=V3(math.noise(t*28,5),math.noise(7,t*31),math.noise(t*25,11))*movingShake
        cam.CameraType=Enum.CameraType.Scriptable
        cam.CFrame=CFrame.lookAt(position,focus)*angles(0,0,roll)*CF(n)
        cam.Focus=CF(focus); cam.FieldOfView=fov+flashPower*4
        shake=math.max(0,shake-dt*8)
    end

    local function animate(dt)
        if dead then return end
        if not scene or not scene.Parent or not root.Parent or humanoid.Health<=0 or Workspace.CurrentCamera~=cam then stop("cancelled"); return end
        elapsed=(os.clock()-started)*64/CONFIG.Duration
        local t=elapsed
        if t>=64 then
            stop("finished")
            if CONFIG.KeepAura and character.Parent and humanoid.Health>0 then installAura(character,true) end
            return
        end
        local fade=1-phase(t,34,39)
        flashPower=math.max(0,flashPower-dt*4.8)
        screenFlash.BackgroundTransparency=1
        S.bloom.Intensity=.95+flashPower*.55
        S.grade.Brightness=.025+flashPower*.035
        S.grade.Contrast=.16+flashPower*.08
        S.fade.BackgroundTransparency=1-phase(t,63.45,64)

                local charge=phase(t,0,1.5)*(1-phase(t,4.5,6))
        poseRig(S.actor,base*CF(0,S.actor.height+phase(t,1.5,3.5)*2*(1-phase(t,5,6)),0),"invoke",1-phase(t,4.5,6),t)
        visibility(S.actor,1)
        local heroHand=S.actor.model:FindFirstChild("RightHand") or S.actor.model:FindFirstChild("Right Arm") or S.actor.root
        local genesis=heroHand.Position+V3(0,3,0)
        drawCrystal(S.charge.core,CF(genesis)*angles(t*130,t*160,15),1+3*charge,2+7*charge,charge)
        for i,c in ipairs(S.charge.shards) do
            local travel=(t*(0.45+i%3*0.1)+i*0.37)%1
            local scatter=V3(math.sin(i*4.7)*26,math.cos(i*2.3)*17+5,math.sin(i*7.1)*23)
            local p=genesis+scatter*(1-travel)^1.5
            drawCrystal(c,CF(p)*angles(t*140,i*30,t*100),0.5+charge,2+charge*3,charge*0.95)
        end
        for i,p in ipairs(S.charge.streamers) do
            local from=world(math.sin(i*5.3)*25,1+(i%3)*4,math.cos(i*3.7)*23)
            drawPlasma(p,from,genesis,0.6+charge*2,charge*0.8,8*math.sin(t*2+i))
        end
        for i,c in ipairs(S.levitation) do
            local a=i*2.399+t*.25; local rise=phase(t,.5,3.35)
            local f=base*CF(math.cos(a)*(15+i%7*3),rise*(3+i%6*3),math.sin(a)*(15+i%7*3))*angles(t*35+i*17,t*25,0)
            drawCrystal(c,f,1+i%3*.4,2+i%4*.7,charge*.9,true)
        end
    
        -- Rayo de 1.800 studs con nucleo, corona, 4 capas de plasma y rayos fractales.
        local firing=phase(t,3.3,3.42)*(1-phase(t,7.3,8.5))
        local beamA=world(0,9,0); local beamB=world(0,9+1800*phase(t,3.3,3.6),0)
        tube(S.beam.core,beamA,beamB,10+firing*13,firing*0.97)
        tube(S.beam.mid,beamA,beamB,35+firing*22,firing*0.28)
        tube(S.beam.outer,beamA,beamB,65+firing*20,firing*0.1)
        for i,p in ipairs(S.beam.plasma) do
            local a=i*PI/2+t*3; local offset=V3(math.cos(a)*24,0,math.sin(a)*24)
            drawPlasma(p,beamA+offset,beamB-offset,42,firing*0.8,80*math.sin(t*2+i))
            drawBolt(S.beam.bolts[i],beamA+offset*2,beamB-offset*3,1.3,firing,i*7)
        end
    
        -- Estrella 3D: cinco puntas con ocho facetas, fotosfera y eyecciones.
        local starAlpha=phase(t,6,7.5)*(1-phase(t,13.3,16.5))
        local starGrow=0.25+0.75*out((t-6)/2.6)
        local starFrame=base*CF(0,950,-780)*angles(0,0,8*math.sin(t*0.3))
        S.starPos=starFrame.Position
        drawCrystal(S.star.core,starFrame*angles(t*18,t*23,0),240*starGrow,360*starGrow,starAlpha)
        for i,point in ipairs(S.star.spikes) do
            local a=(i-1)*2*PI/5+PI/2
            local f=starFrame*CF(math.cos(a)*170*starGrow,math.sin(a)*170*starGrow,0)*angles(0,0,math.deg(a)-90)
            drawCrystal(point.outer,f,100*starGrow,450*starGrow,starAlpha*0.95)
            drawCrystal(point.inner,f*CF(0,15,0),43*starGrow,370*starGrow,starAlpha)
            local tip=starFrame*V3(math.cos(a)*390*starGrow,math.sin(a)*390*starGrow,0)
            local to=starFrame*V3(math.cos(a)*(650+math.sin(t*4+i)*80),math.sin(a)*(650+math.sin(t*4+i)*80),-30)
            drawPlasma(S.star.plasma[i],tip,to,35*starGrow,starAlpha*0.75,60)
        end
        for i,c in ipairs(S.star.rays) do
            local a=i*2.399+t*0.07; local r=390+(i%5)*20
            local f=starFrame*CF(math.cos(a)*r,math.sin(a)*r,math.sin(i*7)*90)*angles(0,0,math.deg(a)-90)
            drawCrystal(c,f,9+(i%3)*4,65+(i%6)*18,starAlpha*0.75)
        end
        S.star.anchor.CFrame=CF(S.starPos)
        S.star.sparks.Enabled=starAlpha>0.1; S.star.glints.Enabled=starAlpha>0.1; S.star.vapor.Enabled=starAlpha>0.1
        S.star.light.Brightness=starAlpha*10
    


        local emergence=phase(t,8.5,11.6)
        local descent=phase(t,11.8,17.4)
        local landing=phase(t,17.05,17.45)*(1-phase(t,17.5,18.6))
        local kneel=phase(t,31.2,35)
        local giantY=mix(960,S.giant.height,descent)-landing*18-kneel*CONFIG.GiantHeight*.24
        local giantZ=mix(-770,-600,emergence)
        S.giantPos=world(0,giantY,giantZ)
        local turn=mix(155,180,phase(t,8.5,13))
        local giantFrame=base*CF(0,giantY,giantZ)*angles(0,turn,0)
        local mode,amount="emerge",1-phase(t,13.5,17)
        if t>=17 and t<18.5 then mode,amount="land",landing
        elseif t>=18.5 and t<31.2 then mode,amount="weapon",phase(t,22,26.35)
        elseif t>=31.2 then mode,amount="kneel",kneel end
        poseRig(S.giant,giantFrame,mode,amount,t,base.Position.Y)
        local giantAlpha=phase(t,8.55,9.9)*fade
        visibility(S.giant,giantAlpha)
        animateSword(t,giantAlpha)
        for _,e in ipairs(S.bodyEmitters) do e.Enabled=giantAlpha>.1 end
        for _,trail in ipairs(S.wristTrails) do trail.Enabled=giantAlpha>.1 and t<32 end
        for _,e in ipairs(S.dust) do e.Enabled=t>8.5 and t<39 end


        local torso=S.giant.model:FindFirstChild("UpperTorso") or S.giant.model:FindFirstChild("Torso") or S.giant.root
        for i,p in ipairs(S.back) do
            local side=i%2==0 and 1 or -1; local level=math.ceil(i/2)
            local a=torso.CFrame*V3(side*torso.Size.X*0.42,torso.Size.Y*0.2,torso.Size.Z*0.55)
            local b=torso.CFrame*V3(side*(90+level*30+math.sin(t*1.4+i)*25),-80-level*55,120+level*30)
            drawPlasma(p,a,b,18+level*8,giantAlpha*0.65,side*(80+math.sin(t*1.8+i)*40))
        end
        for i,c in ipairs(S.shoulders) do
            local side=i<=3 and -1 or 1; local tier=(i-1)%3
            local f=torso.CFrame*CF(side*(torso.Size.X*0.5+8+tier*11),torso.Size.Y*0.4,0)*angles(0,0,-side*(20+tier*12))
            drawCrystal(c,f,14,65-tier*9,giantAlpha*0.92)
        end
    


        updateLandscape(t)
        updateHero(t)
        updateDetailVFX(t)
        for i,c in ipairs(S.meteors) do
            local direction=V3(math.cos(i*2.399)*.8,math.sin(i*1.7)*.65,math.sin(i*2.399)).Unit
            local start=t<20 and 8.45 or 27.6
            local travel=clamp((t-start)/(t<20 and 4.5 or 3.8),0,1)
            local center=t<20 and S.starPos or world(0,10,-160)
            local pos=center+direction*(40+travel*1500)
            local alpha=phase(t,start,start+.15)*(1-travel)
            drawCrystal(c,CFrame.lookAt(pos,pos+direction)*angles(90,t*130,0),12,60,alpha)
        end
        event("charge",.8,function() spray(genesis,GOLD,1.2,60,20); play(S.audio.rumble) end)
        event("fire",3.35,function()
            flash(.75,2.5); play(S.audio.impact)
            detonation(world(0,.3,0),100,GOLD,1.3,"ground"); mist(world(0,1,0),22,WHITE,8)
        end)
        event("starIgnition",6.05,function()
            flash(.3,1.5); spray(S.starPos,GOLD,18,260,320,"glint")
        end)
        event("supernova",8.45,function()
            flash(.88,6); play(S.audio.impact); play(S.audio.roar)
            detonation(S.starPos,900,GOLD,3); mist(S.starPos,70,WHITE,8)
        end)
        event("touchdown",17.4,function()
            flash(.5,8); play(S.audio.impact)
            detonation(world(-65,.3,-600),380,GOLD,2.1,"ground")
            detonation(world(65,.3,-590),350,GOLD,1.9,"ground")
            pressureFront(world(0,.8,-600),460,2.2)
        end)
        event("swordBirth",18.55,function()
            flash(.2,1.4); spray(S.handPos,GOLD,12,200,160,"glint")
            mist(S.handPos,55,GOLD,5)
        end)
        event("gripContact",20.15,function()
            spray(S.handPos,GOLD,2.5,65,30,"spark")
        end)
        event("bladeExtract",21.2,function()
            detonation(S.swordRestTip,95,GOLD,1.7,"ground")
            pressureFront(S.swordRestTip,120,1.5);flash(.25,1.3)
        end)
        event("bladeCharge",25.75,function()
            flash(.25,2); spray(S.bladeTip,WHITE,14,170,250,"glint")
        end)
        event("worldsplit",27.6,function()
            flash(.95,11); play(S.audio.impact); play(S.audio.roar)
            detonation(world(0,1,-160),1100,GOLD,4,"ground")
            pressureFront(world(0,1,-160),1050,2.4)
            bladeContactSparks(S.bladeTip,CONFIG.GiantHeight/650)
            mist(world(-100,3,-160),110,GOLD,10); mist(world(100,3,-160),110,GOLD,10)
        end)
        for i=1,7 do
            event("fault"..i,27.65+i*.095,function()
                detonation(world(0,1,-160-i*130),120+i*10,GOLD,1.8,"ground")
            end)
        end
        event("transfer",35.1,function()
            spray(world(0,14,-100),GOLD,.7,100,15,"glint")
            mist(world(0,8,-100),4,GOLD,6)
        end)
        event("heroLanding",37.1,function()
            detonation(world(0,.2,-100),12,GOLD,1.7,"ground")
            spray(world(0,.7,-100),GOLD,.16,70,9,"spark"); flash(.18,.12)
            pressureFront(world(0,.25,-100),14,1.7)
        end)
        event("heroPush",39.1,function()
            spray(world(0,.3,-103),GOLD,.12,45,6,"spark")
        end)
        event("heroDash",40.05,function()
            pressureFront(world(0,.22,-102),8,1.1)
            spray(world(0,.2,-102),GOLD,.1,40,8,"spark")
        end)
        event("eyes",44.2,function()
            local h=S.actor.model:FindFirstChild("Head") or S.actor.root
            spray(h.Position,GOLD,.07,18,1.2,"spark")
        end)
        event("auraRelease",48.2,function()
            detonation(world(0,.3,-97.5),24,GOLD,2.2,"ground")
            spray(S.heroPos,GOLD,.18,170,13,"spark"); flash(.45,.3)
            pressureFront(world(0,.3,-97.5),30,2)
        end)
        event("auraAftershock",53.5,function()
            spray(world(0,1,-97.5),GOLD,.12,80,8,"spark")
        end)
        if t>3.35 and t<7.5 then every("rayDust",.32,function() spray(beamA,GOLD,3,35,100,"spark") end) end
        if t>9 and t<17 then every("solarDust",.8,function() mist(S.giantPos+V3(0,-60,0),85,GOLD,6) end) end
        if t>31.2 and t<35.8 then every("transferArc",.28,function()
            local head=S.giant.model:FindFirstChild("Head") or S.giant.root
            local ray=plasma(GOLD,2)
            drawPlasma(ray,head.Position,world(0,14,-100),2,.45,80*math.sin(t*4))
            effects[#effects+1]={obj=ray.a,born=elapsed,life=.23}
            effects[#effects+1]={obj=ray.b,born=elapsed,life=.23}
        end) end
        if S.audio.music and t>60 then S.audio.music.Volume=.7*(1-phase(t,60,64)) end
        if S.audio.rumble and t>32 then S.audio.rumble.Volume=0 end
        cinematicCamera(t,dt)
        updatePolishedVFX(t)
        updateEffects()
    end

    local function prepareLighting()
        saved.lighting={}; saved.atmospheres={}; saved.postFX={}
        for _,key in ipairs({"ClockTime","Brightness","Ambient","OutdoorAmbient","FogStart","FogEnd","FogColor","ExposureCompensation"}) do saved.lighting[key]=Lighting[key] end
        -- Evita que el postprocesado del mapa o de otra animacion apague los VFX.
        for _,o in ipairs(Lighting:GetChildren()) do
            if o:IsA("PostEffect") then saved.postFX[o]=o.Enabled; o.Enabled=false end
            if o:IsA("Atmosphere") then
                saved.atmospheres[o]={Density=o.Density,Haze=o.Haze,Glare=o.Glare}
                o.Density=0.12; o.Haze=0.3; o.Glare=0.4
            end
        end
        Lighting.ClockTime=16.65; Lighting.Brightness=3.2
        Lighting.Ambient=Color3.fromRGB(123,131,170); Lighting.OutdoorAmbient=Color3.fromRGB(161,172,206)
        Lighting.ExposureCompensation=0.12; Lighting.FogStart=7000; Lighting.FogEnd=24000
        Lighting.FogColor=Color3.fromRGB(177,169,202)
        S.bloom=keep(make("BloomEffect",{Name="SovereignBloom",Intensity=.95,Size=42,Threshold=1.05},Lighting))
        S.grade=keep(make("ColorCorrectionEffect",{Name="SovereignGrade",Brightness=.025,Contrast=.16,Saturation=.26,TintColor=Color3.fromRGB(255,255,255)},Lighting))
        keep(make("SunRaysEffect",{Name="SovereignSun",Intensity=.13,Spread=.85},Lighting))
    end
    local function setup()
        character=player.Character or player.CharacterAdded:Wait()
        if dead then return end
        root=character:WaitForChild("HumanoidRootPart",8)
        humanoid=character:FindFirstChildOfClass("Humanoid")
        local playerGui=player:WaitForChild("PlayerGui",8)
        cam=Workspace.CurrentCamera
        if dead then return end
        if not root or not humanoid or humanoid.Health<=0 or not playerGui or not cam then error("Espera a aparecer antes de ejecutar.") end
        scene=keep(make("Folder",{Name="DarlingSovereign_Local"},Workspace))
        gui=keep(make("ScreenGui",{Name="SovereignFullScreenVFX",IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=999999},playerGui))
        -- Unico elemento 2D: pulso de luz blanca. Nada de bandas, texto o botones.
        screenFlash=make("Frame",{Name="LightPulse",Size=UDim2.fromScale(1,1),BorderSizePixel=0,
            BackgroundColor3=WHITE,BackgroundTransparency=1},gui)
        connect(UserInputService.InputBegan,function(input,processed)
            if not processed and (input.KeyCode==Enum.KeyCode.X or input.KeyCode==Enum.KeyCode.Backspace) then api.Stop() end
        end)
        connect(player.CharacterRemoving,function(c) if c==character then api.Stop() end end)
        connect(humanoid.Died,api.Stop)
    
        -- Los assets de la plantilla se precargan sin bloquear la escena.
        task.spawn(function()
            pcall(function() ContentProvider:PreloadAsync({"rbxassetid://9756362"},function(_,status)
                S.diamondReady=status==Enum.AssetFetchStatus.Success
            end) end)
            S.meshPreloaded=true
            local fallbacks={spark="rbxasset://textures/particles/fire_sparks_main.dds",mist="rbxasset://textures/particles/smoke_main.dds",glint="rbxasset://textures/particles/sparkles_main.dds",plasma="rbxasset://textures/particles/fire_main.dds"}
            for key,id in pairs(TEX) do
                pcall(function() ContentProvider:PreloadAsync({id},function(_,status)
                    if status==Enum.AssetFetchStatus.Failure and fallbacks[key] then TEX[key]=fallbacks[key] end
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
        base=CFrame.lookAt(ground+V3(0,10000,0),ground+V3(0,10000,0)+look.Unit)
        S.starPos=world(0,950,-780)
        buildScene()
        if dead then return end
    
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
        prepareLighting()
        cam.CameraType=Enum.CameraType.Scriptable
        play(S.audio.music)
        started=os.clock(); bound=true; api.Status="playing"
        RunService:BindToRenderStep(bindName,Enum.RenderPriority.Camera.Value+10,function(dt)
            local ok,err=xpcall(function() animate(dt) end,debug.traceback)
            if not ok then stop(err) end
        end)
        task.delay(CONFIG.Duration+3,function() if not dead then stop("finished") end end)
    end
    local ok,err=xpcall(setup,debug.traceback)
    if not ok then stop(err) end
    return api
    

end


function ComebackCinematic.play(customConfig, onComplete)
    ComebackCinematic.stop()
    local session = runAnimation(customConfig, onComplete)
    ComebackCinematic.ActiveSession = session
    return session
end

function ComebackCinematic.enable()
    return ComebackCinematic.play()
end

function ComebackCinematic.stop()
    if ComebackCinematic.ActiveSession and type(ComebackCinematic.ActiveSession.Stop) == "function" then
        pcall(ComebackCinematic.ActiveSession.Stop)
        ComebackCinematic.ActiveSession = nil
    end
    local env = (getgenv and getgenv()) or _G
    if env.DarlingSovereign and type(env.DarlingSovereign.Stop) == "function" then
        pcall(env.DarlingSovereign.Stop)
    end
    if _G.DarlingSovereign and type(_G.DarlingSovereign.Stop) == "function" then
        pcall(_G.DarlingSovereign.Stop)
    end
    if _G.RedEclipseComeback and type(_G.RedEclipseComeback.Stop) == "function" then
        pcall(_G.RedEclipseComeback.Stop)
    end
end

function ComebackCinematic.dismiss()
    ComebackCinematic.stop()
end

function ComebackCinematic.destroy()
    ComebackCinematic.stop()
end

function ComebackCinematic.isPlaying()
    if ComebackCinematic.ActiveSession and ComebackCinematic.ActiveSession.IsPlaying then
        return true
    end
    local env = (getgenv and getgenv()) or _G
    return (env.DarlingSovereign and env.DarlingSovereign.IsPlaying) or false
end

_G.ComebackCinematic = ComebackCinematic
return ComebackCinematic
