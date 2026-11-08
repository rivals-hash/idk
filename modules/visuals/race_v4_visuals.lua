--[[
    Darling Hub - Race V4 Visual System (Client-Side)
    Full client-side visual awakening, 3D accessories, auras, skills VFX, and awakening HUD.
    Zero emojis, zero external hub branding.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local EffectModule = nil
pcall(function()
    EffectModule = require(ReplicatedStorage:WaitForChild("Effect", 3))
end)

local RaceV4Visuals = {
    CurrentSelectedRace = "Human",
    IsV4Active = false,
    PermanentAura = false,
    Enable3DModels = true,
    EnableSound = true,
    UseCustomColor = false,
    CustomColor = Color3.fromRGB(255, 255, 255),
    WingsScale = 1.0,
}

local RaceConfig = {
    ["Human"] = {
        DisplayName = "Humano V4 (Psycho Berserker)",
        RaceName = "Human",
        Color1 = Color3.fromRGB(255, 30, 30),
        Color2 = Color3.fromRGB(110, 5, 5),
        Color3 = Color3.fromRGB(255, 140, 140),
        AuraSound = "RaceAura5",
        EyeColor = Color3.fromRGB(255, 0, 0),
        Description = "Aura berserker roja, ojos brillantes carmesi y estelas de velocidad psycho."
    },
    ["Mink"] = {
        DisplayName = "Mink V4 (Torbellino Electrico)",
        RaceName = "Mink",
        Color1 = Color3.fromRGB(255, 230, 20),
        Color2 = Color3.fromRGB(190, 140, 0),
        Color3 = Color3.fromRGB(255, 255, 210),
        AuraSound = "RaceAura2",
        EyeColor = Color3.fromRGB(255, 240, 50),
        Description = "Orejas de conejo, relampagos constantes, chispas doradas y anillo en los pies."
    },
    ["Fishman"] = {
        DisplayName = "Fishman / Shark V4 (Cuerpo de Agua)",
        RaceName = "Fishman",
        Color1 = Color3.fromRGB(0, 200, 255),
        Color2 = Color3.fromRGB(0, 45, 150),
        Color3 = Color3.fromRGB(190, 245, 255),
        AuraSound = "RaceAura6",
        EyeColor = Color3.fromRGB(0, 220, 255),
        Description = "Aletas de tiburon en espalda y brazos, cola marina, remolino y anillo de agua."
    },
    ["Skypiea"] = {
        DisplayName = "Skypiea / Angel V4 (Soberania Divina)",
        RaceName = "Skypiea",
        Color1 = Color3.fromRGB(255, 255, 230),
        Color2 = Color3.fromRGB(230, 185, 35),
        Color3 = Color3.fromRGB(255, 255, 255),
        AuraSound = "RaceAura3",
        EyeColor = Color3.fromRGB(255, 255, 180),
        Description = "Alas celestiales animadas, halo dorado resplandeciente y juicio celestial."
    },
    ["Ghoul"] = {
        DisplayName = "Ghoul V4 (Expansion de Dominio)",
        RaceName = "Ghoul",
        Color1 = Color3.fromRGB(180, 20, 255),
        Color2 = Color3.fromRGB(60, 0, 95),
        Color3 = Color3.fromRGB(235, 150, 255),
        AuraSound = "RaceAura1",
        EyeColor = Color3.fromRGB(255, 0, 80),
        Description = "Cuernos demoniacos, tentaculos Kagune, niebla de sangre y enjambre de cuervos."
    },
    ["Cyborg"] = {
        DisplayName = "Cyborg V4 (Sobrecarga de Energia)",
        RaceName = "Cyborg",
        Color1 = Color3.fromRGB(0, 245, 255),
        Color2 = Color3.fromRGB(0, 90, 160),
        Color3 = Color3.fromRGB(200, 255, 255),
        AuraSound = "RaceAura4",
        EyeColor = Color3.fromRGB(0, 255, 255),
        Description = "Alas tecnologicas neon, nucleo de reactor en pecho y descargas de dron."
    },
    ["Draco"] = {
        DisplayName = "Draco V4 (Furia Volcanica)",
        RaceName = "Draco",
        Color1 = Color3.fromRGB(255, 85, 0),
        Color2 = Color3.fromRGB(140, 15, 0),
        Color3 = Color3.fromRGB(255, 220, 60),
        AuraSound = "RaceAura7",
        EyeColor = Color3.fromRGB(255, 100, 0),
        Description = "Alas de dragon en llamas, cuernos de dragon, estelas de magma y rugido de fuego."
    }
}
RaceV4Visuals.RaceConfig = RaceConfig

local ActiveAccessories = {}
local ActiveEmitters = {}
local ActiveSounds = {}

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRoot()
    local char = getCharacter()
    return char:WaitForChild("HumanoidRootPart", 5)
end

local function getGuiParent()
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and h then return h end
    local ok2, c = pcall(function() return CoreGui end)
    if ok2 and c then return c end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- 3D ACCESSORIES
local function clearAccessories()
    for _, obj in pairs(ActiveAccessories) do
        if obj and obj.Parent then
            pcall(function() obj:Destroy() end)
        end
    end
    ActiveAccessories = {}
end

local function createAccessoryPart(name, meshId, textureId, size, offset, rotation, weldToPart, color, material)
    local part = Instance.new("MeshPart")
    part.Name = name
    part.MeshId = meshId
    if textureId and textureId ~= "" then
        part.TextureID = textureId
    end
    part.Size = size * RaceV4Visuals.WingsScale
    part.CanCollide = false
    part.Massless = true
    if color then
        part.Color = color
    end
    part.Material = material or Enum.Material.Neon

    local weld = Instance.new("WeldConstraint")
    part.CFrame = weldToPart.CFrame * offset * rotation
    weld.Part0 = weldToPart
    weld.Part1 = part
    weld.Parent = part

    part.Parent = weldToPart.Parent
    table.insert(ActiveAccessories, part)
    return part
end

local function spawnRaceAccessories(raceKey)
    if not RaceV4Visuals.Enable3DModels then return end
    local char = getCharacter()
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    local head = char:FindFirstChild("Head")
    local rightArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
    local leftArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
    if not torso or not head then return end

    clearAccessories()
    local info = RaceConfig[raceKey]
    if not info then return end
    local primaryColor = RaceV4Visuals.UseCustomColor and RaceV4Visuals.CustomColor or info.Color1

    if raceKey == "Skypiea" then
        local wings = createAccessoryPart(
            "AngelWingsV4",
            "rbxassetid://10470900574",
            "",
            Vector3.new(2.2, 3.8, 6.0),
            CFrame.new(0, 0.5, 0.7),
            CFrame.Angles(0, math.rad(180), 0),
            torso,
            primaryColor,
            Enum.Material.Neon
        )

        local flapTween = TweenService:Create(wings, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            CFrame = torso.CFrame * CFrame.new(0, 0.6, 0.65) * CFrame.Angles(math.rad(8), math.rad(180), math.rad(12))
        })
        pcall(function() flapTween:Play() end)

        local halo = Instance.new("Part")
        halo.Name = "AngelHalo"
        halo.Shape = Enum.PartType.Cylinder
        halo.Size = Vector3.new(0.15, 2.2, 2.2) * RaceV4Visuals.WingsScale
        halo.Color = Color3.fromRGB(255, 235, 120)
        halo.Material = Enum.Material.Neon
        halo.CanCollide = false
        halo.Massless = true
        halo.CFrame = head.CFrame * CFrame.new(0, 1.6, 0) * CFrame.Angles(math.rad(90), 0, 0)

        local haloWeld = Instance.new("WeldConstraint")
        haloWeld.Part0 = head
        haloWeld.Part1 = halo
        haloWeld.Parent = halo
        halo.Parent = char
        table.insert(ActiveAccessories, halo)

    elseif raceKey == "Cyborg" then
        createAccessoryPart(
            "CyborgWingsV4",
            "rbxassetid://10430660325",
            "",
            Vector3.new(1.6, 3.5, 2.6),
            CFrame.new(0, 0.3, 0.65),
            CFrame.Angles(0, math.rad(180), 0),
            torso,
            primaryColor,
            Enum.Material.Neon
        )

        local core = Instance.new("Part")
        core.Name = "CyborgCore"
        core.Shape = Enum.PartType.Ball
        core.Size = Vector3.new(0.7, 0.7, 0.7) * RaceV4Visuals.WingsScale
        core.Color = Color3.fromRGB(0, 240, 255)
        core.Material = Enum.Material.Neon
        core.CanCollide = false
        core.Massless = true
        core.CFrame = torso.CFrame * CFrame.new(0, 0.3, -0.6)

        local coreWeld = Instance.new("WeldConstraint")
        coreWeld.Part0 = torso
        coreWeld.Part1 = core
        coreWeld.Parent = core
        core.Parent = char
        table.insert(ActiveAccessories, core)

    elseif raceKey == "Fishman" then
        createAccessoryPart(
            "SharkFinBack",
            "rbxassetid://113668647992739",
            "rbxassetid://94213816729974",
            Vector3.new(1.5, 2.5, 2.2),
            CFrame.new(0, 0.2, 0.65),
            CFrame.Angles(0, math.rad(180), 0),
            torso,
            primaryColor,
            Enum.Material.SmoothPlastic
        )

        if leftArm then
            createAccessoryPart("SharkFinL", "rbxassetid://84360153678346", "rbxassetid://140447138573990", Vector3.new(0.8, 1.4, 0.8), CFrame.new(-0.2, 0, 0.1), CFrame.Angles(0, 0, 0), leftArm, primaryColor, Enum.Material.SmoothPlastic)
        end
        if rightArm then
            createAccessoryPart("SharkFinR", "rbxassetid://100600122168173", "rbxassetid://140447138573990", Vector3.new(0.8, 1.4, 0.8), CFrame.new(0.2, 0, 0.1), CFrame.Angles(0, 0, 0), rightArm, primaryColor, Enum.Material.SmoothPlastic)
        end

    elseif raceKey == "Mink" then
        createAccessoryPart(
            "MinkBunnyEars",
            "rbxassetid://227430350",
            "",
            Vector3.new(1.4, 1.8, 1.2),
            CFrame.new(0, 1.1, 0),
            CFrame.Angles(0, math.rad(180), 0),
            head,
            Color3.fromRGB(250, 250, 245),
            Enum.Material.SmoothPlastic
        )

    elseif raceKey == "Ghoul" then
        local function makeHorn(offsetX, rotZ)
            local horn = Instance.new("Part")
            horn.Size = Vector3.new(0.3, 1.1, 0.3) * RaceV4Visuals.WingsScale
            horn.Color = Color3.fromRGB(30, 0, 40)
            horn.Material = Enum.Material.Neon
            horn.CanCollide = false
            horn.Massless = true
            horn.CFrame = head.CFrame * CFrame.new(offsetX, 0.9, -0.2) * CFrame.Angles(math.rad(25), 0, math.rad(rotZ))
            local w = Instance.new("WeldConstraint")
            w.Part0 = head
            w.Part1 = horn
            w.Parent = horn
            horn.Parent = char
            table.insert(ActiveAccessories, horn)
        end
        makeHorn(-0.5, -25)
        makeHorn(0.5, 25)

    elseif raceKey == "Draco" then
        createAccessoryPart(
            "DragonWings",
            "rbxassetid://10470900574",
            "",
            Vector3.new(2.5, 3.8, 6.2),
            CFrame.new(0, 0.4, 0.7),
            CFrame.Angles(0, math.rad(180), 0),
            torso,
            Color3.fromRGB(255, 60, 0),
            Enum.Material.Neon
        )
    end
end

-- AURAS & EYE GLOW
local function clearAuras()
    for _, emit in pairs(ActiveEmitters) do
        if emit and emit.Parent then
            pcall(function() emit:Destroy() end)
        end
    end
    ActiveEmitters = {}

    for _, snd in pairs(ActiveSounds) do
        if snd and snd.Parent then
            pcall(function()
                snd:Stop()
                snd:Destroy()
            end)
        end
    end
    ActiveSounds = {}
end

local function attachBodyAura(raceKey)
    local char = getCharacter()
    local root = char:FindFirstChild("HumanoidRootPart")
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    local head = char:FindFirstChild("Head")
    if not root or not torso then return end

    clearAuras()
    local info = RaceConfig[raceKey] or RaceConfig["Human"]
    local col1 = RaceV4Visuals.UseCustomColor and RaceV4Visuals.CustomColor or info.Color1
    local col2 = info.Color2

    local attachment = Instance.new("Attachment")
    attachment.Name = "V4AuraAttachment"
    attachment.Parent = torso
    table.insert(ActiveEmitters, attachment)

    local fire = Instance.new("ParticleEmitter")
    fire.Texture = "rbxassetid://2917185051"
    fire.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, col1),
        ColorSequenceKeypoint.new(0.7, col2),
        ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
    })
    fire.LightEmission = 0.85
    fire.LightInfluence = 0
    fire.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.2),
        NumberSequenceKeypoint.new(0.6, 2.5),
        NumberSequenceKeypoint.new(1, 0)
    })
    fire.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.8, 0.4),
        NumberSequenceKeypoint.new(1, 1)
    })
    fire.Lifetime = NumberRange.new(0.6, 1.2)
    fire.Rate = 45
    fire.Speed = NumberRange.new(2, 5)
    fire.SpreadAngle = Vector2.new(45, 45)
    fire.EmissionDirection = Enum.NormalId.Top
    fire.LockedToPart = true
    fire.Parent = attachment
    table.insert(ActiveEmitters, fire)

    local sparks = Instance.new("ParticleEmitter")
    sparks.Texture = "rbxassetid://258129523"
    sparks.Color = ColorSequence.new(col1)
    sparks.LightEmission = 1
    sparks.Size = NumberSequence.new(0.6, 0.1)
    sparks.Lifetime = NumberRange.new(0.3, 0.7)
    sparks.Rate = 35
    sparks.Speed = NumberRange.new(4, 9)
    sparks.SpreadAngle = Vector2.new(180, 180)
    sparks.Parent = attachment
    table.insert(ActiveEmitters, sparks)

    local light = Instance.new("PointLight")
    light.Color = col1
    light.Range = 18
    light.Brightness = 2.5
    light.Shadows = false
    light.Parent = torso
    table.insert(ActiveEmitters, light)

    if head then
        local eyeAttach = Instance.new("Attachment")
        eyeAttach.Position = Vector3.new(0, 0.2, -0.6)
        eyeAttach.Parent = head
        table.insert(ActiveEmitters, eyeAttach)

        local eyeGlow = Instance.new("ParticleEmitter")
        eyeGlow.Texture = "rbxassetid://258129523"
        eyeGlow.Color = ColorSequence.new(info.EyeColor)
        eyeGlow.LightEmission = 1
        eyeGlow.Size = NumberSequence.new(0.4, 0.1)
        eyeGlow.Lifetime = NumberRange.new(0.15, 0.3)
        eyeGlow.Rate = 20
        eyeGlow.Speed = NumberRange.new(0.5, 1)
        eyeGlow.LockedToPart = true
        eyeGlow.Parent = eyeAttach
        table.insert(ActiveEmitters, eyeGlow)
    end

    if RaceV4Visuals.EnableSound then
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://18605584930"
        sound.Volume = 1.2
        sound.Looped = true
        sound.RollOffMaxDistance = 100
        sound.RollOffMinDistance = 15
        sound.Parent = root
        sound:Play()
        table.insert(ActiveSounds, sound)
    end
end

-- SCREEN HUD (REMOVED)
local function toggleScreenHUD(enabled, raceKey, duration)
    -- Intentionally removed: screen HUD is disabled
end

local function setRaceValues(active, raceKey)
    local char = getCharacter()
    local info = RaceConfig[raceKey] or RaceConfig["Human"]

    pcall(function()
        if LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Race") then
            LocalPlayer.Data.Race.Value = info.RaceName
        end
    end)

    local trans = char:FindFirstChild("RaceTransformed")
    if not trans then
        trans = Instance.new("BoolValue")
        trans.Name = "RaceTransformed"
        trans.Parent = char
    end
    trans.Value = active
    if active then
        trans:SetAttribute("A", 1)
        trans:SetAttribute("B", 0)
        trans:SetAttribute("C", 1)
        trans:SetAttribute("Race", info.RaceName)
    else
        trans:SetAttribute("A", 0)
        trans:SetAttribute("B", 0)
        trans:SetAttribute("C", 0)
    end

    local energy = char:FindFirstChild("RaceEnergy")
    if not energy then
        energy = Instance.new("IntValue")
        energy.Name = "RaceEnergy"
        energy.Parent = char
    end
    energy.Value = active and 100 or 0

    return trans
end

local function cleanupAll()
    local char = getCharacter()
    RaceV4Visuals.IsV4Active = false
    RaceV4Visuals.PermanentAura = false

    setRaceValues(false, RaceV4Visuals.CurrentSelectedRace)
    clearAccessories()
    clearAuras()
    toggleScreenHUD(false)

    if char:FindFirstChild("sparksRing") then
        pcall(function() char.sparksRing:Destroy() end)
    end
    if char:FindFirstChild("splashRing") then
        pcall(function() char.splashRing:Destroy() end)
    end

    if Lighting:FindFirstChild("Blur") then
        pcall(function() Lighting.Blur:Destroy() end)
    end
    if Lighting:FindFirstChild("CC1") then
        pcall(function() Lighting.CC1:Destroy() end)
    end

    Camera.FieldOfView = 70
end

local function playAwakeningAnimation()
    local char = getCharacter()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://10122845177"
    local track = hum:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track:Play()
end

function RaceV4Visuals.triggerTransformation(raceKey, isFast)
    raceKey = raceKey or RaceV4Visuals.CurrentSelectedRace
    local char = getCharacter()
    local root = getRoot()
    local hum = char:WaitForChild("Humanoid", 5)
    if not root or not hum then return end

    cleanupAll()
    RaceV4Visuals.IsV4Active = true
    local info = RaceConfig[raceKey] or RaceConfig["Human"]
    local col1 = RaceV4Visuals.UseCustomColor and RaceV4Visuals.CustomColor or info.Color1
    local col2 = info.Color2
    local col3 = info.Color3

    pcall(playAwakeningAnimation)
    setRaceValues(true, raceKey)
    spawnRaceAccessories(raceKey)

    local successEffect = false
    if EffectModule then
        local success = pcall(function()
            EffectModule.new("RaceTransformation.Main"):play({
                Character = char,
                player = LocalPlayer,
                Race = info.RaceName,
                Color1 = col1,
                Color2 = col2,
                Color3 = col3,
                Mastery = isFast or false
            })
        end)
        successEffect = success
    end

    if not successEffect then
        task.spawn(function()
            local sStart = Instance.new("Sound")
            sStart.SoundId = "rbxassetid://9114223175"
            sStart.Volume = 2
            sStart.Parent = root
            sStart:Play()
            Debris:AddItem(sStart, 4)

            local tweenFOV1 = TweenService:Create(Camera, TweenInfo.new(isFast and 0.8 or 1.5, Enum.EasingStyle.Sine), {FieldOfView = 58})
            tweenFOV1:Play()

            local chargeAttach = Instance.new("Attachment")
            chargeAttach.CFrame = root.CFrame * CFrame.new(0, -2.5, 0)
            chargeAttach.Parent = root
            Debris:AddItem(chargeAttach, isFast and 1.6 or 3.2)

            local chargeEmitter = Instance.new("ParticleEmitter")
            chargeEmitter.Texture = "rbxassetid://2917185051"
            chargeEmitter.Color = ColorSequence.new(col1, col2)
            chargeEmitter.Size = NumberSequence.new(1, 4)
            chargeEmitter.Speed = NumberRange.new(10, 25)
            chargeEmitter.EmissionDirection = Enum.NormalId.Top
            chargeEmitter.Lifetime = NumberRange.new(0.4, 0.8)
            chargeEmitter.Rate = 80
            chargeEmitter.Parent = chargeAttach

            task.wait(isFast and 1.5 or 3.0)
            if not RaceV4Visuals.IsV4Active then return end

            local sExplode = Instance.new("Sound")
            sExplode.SoundId = "rbxassetid://9114223594"
            sExplode.Volume = 3
            sExplode.Parent = root
            sExplode:Play()
            Debris:AddItem(sExplode, 5)

            Camera.FieldOfView = 105
            TweenService:Create(Camera, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {FieldOfView = 70}):Play()

            local cc = Instance.new("ColorCorrectionEffect")
            cc.TintColor = col3
            cc.Brightness = 0.2
            cc.Parent = Lighting
            TweenService:Create(cc, TweenInfo.new(0.5), {Brightness = 0, TintColor = Color3.fromRGB(255, 255, 255)}):Play()
            Debris:AddItem(cc, 0.6)
        end)
    end

    task.delay(isFast and 1.6 or 3.2, function()
        if not RaceV4Visuals.IsV4Active then return end
        attachBodyAura(raceKey)

        if raceKey == "Mink" and EffectModule then
            pcall(function() EffectModule.new("RaceAwakenings.LightningRing"):play({ Character = char }) end)
        elseif raceKey == "Fishman" and EffectModule then
            pcall(function() EffectModule.new("RaceAwakenings.SplashRing"):play({ Character = char }) end)
        end
    end)
end

function RaceV4Visuals.setPermanentMode(active, raceKey)
    raceKey = raceKey or RaceV4Visuals.CurrentSelectedRace
    if active then
        cleanupAll()
        RaceV4Visuals.IsV4Active = true
        RaceV4Visuals.PermanentAura = true
        setRaceValues(true, raceKey)
        spawnRaceAccessories(raceKey)
        attachBodyAura(raceKey)

        local char = getCharacter()
        if raceKey == "Mink" and EffectModule then
            pcall(function() EffectModule.new("RaceAwakenings.LightningRing"):play({ Character = char }) end)
        elseif raceKey == "Fishman" and EffectModule then
            pcall(function() EffectModule.new("RaceAwakenings.SplashRing"):play({ Character = char }) end)
        end
    else
        cleanupAll()
    end
end

function RaceV4Visuals.executeSkill(skillId)
    local char = getCharacter()
    local root = getRoot()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root then return end

    if skillId == "Human_Flash" then
        local goal = root.CFrame * CFrame.new(0, 0, -45)
        if EffectModule then
            pcall(function()
                EffectModule.new("RaceAwakenings.Human"):play({
                    Root = root,
                    originPos = root.CFrame,
                    goalPos = goal.Position,
                    level = 3
                })
            end)
        end
        local part = Instance.new("Part")
        part.Size = Vector3.new(3, 5, 3)
        part.CFrame = root.CFrame
        part.Color = Color3.fromRGB(255, 20, 20)
        part.Material = Enum.Material.Neon
        part.CanCollide = false
        part.Anchored = true
        part.Parent = workspace
        TweenService:Create(part, TweenInfo.new(0.4), {Transparency = 1, Size = Vector3.new(0, 0, 0)}):Play()
        Debris:AddItem(part, 0.4)
        root.CFrame = goal

    elseif skillId == "Mink_Dash" then
        if EffectModule then
            pcall(function()
                EffectModule.new("RaceAwakenings.Mink"):play({
                    Root = root,
                    CFrame = root.CFrame,
                    position = root.Position
                })
            end)
        end
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://9114223380"
        s.Volume = 2
        s.Parent = root
        s:Play()
        Debris:AddItem(s, 2)
        root.CFrame = root.CFrame * CFrame.new(0, 0, -55)

    elseif skillId == "Cyborg_Jump" then
        if EffectModule then
            pcall(function()
                EffectModule.new("RaceAwakenings.CyborgJump"):play({
                    CFrame = root.CFrame,
                    RootPart = root,
                    Strong = true,
                    Replicated = false
                })
            end)
        end
        root.Velocity = Vector3.new(0, 95, 0)

    elseif skillId == "Cyborg_Drone" then
        if EffectModule then
            pcall(function()
                EffectModule.new("RaceAwakenings.CyborgDrone"):play({
                    Character = char,
                    Root = root,
                    TargetPosition = root.Position + Camera.CFrame.LookVector * 120,
                    Origin = root.Position + Vector3.new(0, 5, 0)
                })
            end)
        end

    elseif skillId == "Skypiea_Heaven" then
        if EffectModule then
            pcall(function()
                EffectModule.new("RaceAwakenings.Skypiean"):play({
                    Index = 3,
                    Operation = 0,
                    Root = root,
                    Humanoid = hum,
                    ID = math.random(1000, 9999)
                })
            end)
        end

    elseif skillId == "Ghoul_Crow" then
        if EffectModule then
            pcall(function()
                EffectModule.new("RaceAwakenings.Ghoul"):play({
                    Character = char,
                    Root = root,
                    Origin = root.Position,
                    Target = root.CFrame * CFrame.new(0, 0, -35)
                })
            end)
        end

    elseif skillId == "Fishman_WaterBody" then
        if EffectModule then
            pcall(function()
                EffectModule.new("RaceAwakenings.SplashRing"):play({
                    Character = char
                })
            end)
        end
    end
end

function RaceV4Visuals.cleanup()
    cleanupAll()
end

RaceV4Visuals.spawnAccessories = spawnRaceAccessories
RaceV4Visuals.clearAccessories = clearAccessories
RaceV4Visuals.attachAura = attachBodyAura
RaceV4Visuals.clearAuras = clearAuras
RaceV4Visuals.toggleHUD = toggleScreenHUD

return RaceV4Visuals
