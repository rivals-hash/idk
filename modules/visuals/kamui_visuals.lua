--[[
    Darling X - Kamui Visuals & Dimension Engine
    Provides Blox Fruits Kamui camera effects, dimension summoning, and custom Kamui tools:
      - kamui (ItemId: 1173)
      - rip kamui (ItemId: 1191)
      - arena kamui (ItemId: 1235)
      - heaven kamui (ItemId: 1236)
      - pakistan kamui (Custom Emerald/White Void)
]]

local cloneref = cloneref or function(o) return o end
local function service(name) return cloneref(game:GetService(name)) end

local Players = service("Players")
local Workspace = service("Workspace")
local TweenService = service("TweenService")
local RunService = service("RunService")
local ReplicatedStorage = service("ReplicatedStorage")
local Debris = service("Debris")

local LocalPlayer = Players.LocalPlayer
local KamuiVisuals = {}

-- 1. Kamui Camera Swirl Animation (Blox Fruits Native or Fallback)
local function playKamuiCameraEffect()
    local ok, camFn = pcall(function()
        local cont = ReplicatedStorage:FindFirstChild("Effect")
            and ReplicatedStorage.Effect:FindFirstChild("Container")
        local kCam = cont and cont:FindFirstChild("KamuiCam")
        if kCam then return require(kCam) end
    end)
    if ok and type(camFn) == "function" then
        pcall(camFn)
        return
    end

    -- Smooth fallback camera swirl
    pcall(function()
        local camera = Workspace.CurrentCamera
        if not camera then return end

        local origFov = camera.FieldOfView
        local tInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
        TweenService:Create(camera, tInfo, { FieldOfView = 8 }):Play()

        local t0 = tick()
        while tick() - t0 < 0.45 do
            RunService.RenderStepped:Wait()
            local elapsed = tick() - t0
            camera.CFrame = camera.CFrame * CFrame.Angles(0, 0, math.rad(28 * (elapsed * 60)))
        end

        local tOut = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TweenService:Create(camera, tOut, { FieldOfView = origFov }):Play()
    end)
end

-- 2. Spawn Visual Particles / Vortex at Position
local function spawnKamuiVortex(pos, color1, color2)
    pcall(function()
        local part = Instance.new("Part")
        part.Name = "KamuiVortex"
        part.Size = Vector3.new(1, 1, 1)
        part.Position = pos
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 1
        part.Parent = Workspace

        -- Sphere ring
        local meshPart = Instance.new("SpecialMesh", part)
        meshPart.MeshType = Enum.MeshType.Sphere
        meshPart.Scale = Vector3.new(1, 1, 1)
        part.Transparency = 0.3
        part.Color = color1 or Color3.fromRGB(15, 10, 25)
        part.Material = Enum.Material.Neon

        local tween = TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = Vector3.new(14, 14, 14),
            Transparency = 0.95
        })
        tween:Play()

        -- Sound
        local snd = Instance.new("Sound", part)
        snd.SoundId = "rbxassetid://9114223180"
        snd.Volume = 0.8
        snd:Play()

        Debris:AddItem(part, 1.2)
    end)
end

-- 3. Execute Individual Kamui Animations
function KamuiVisuals.PlayKamui(name)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local pos = hrp and hrp.Position or Vector3.new(0, 50, 0)

    local c1 = Color3.fromRGB(20, 15, 30)
    local c2 = Color3.fromRGB(160, 40, 240)

    if name == "rip kamui" then
        c1 = Color3.fromRGB(40, 0, 70)
        c2 = Color3.fromRGB(220, 20, 80)
    elseif name == "arena kamui" then
        c1 = Color3.fromRGB(90, 10, 10)
        c2 = Color3.fromRGB(255, 100, 20)
    elseif name == "heaven kamui" then
        c1 = Color3.fromRGB(255, 230, 150)
        c2 = Color3.fromRGB(255, 255, 255)
    elseif name == "pakistan kamui" then
        c1 = Color3.fromRGB(0, 140, 60)
        c2 = Color3.fromRGB(240, 255, 240)
    end

    spawnKamuiVortex(pos, c1, c2)
    playKamuiCameraEffect()
end

-- 4. Give Kamui Tool to Backpack
function KamuiVisuals.GiveKamuiTool(kamuiName, itemId)
    pcall(function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return end

        local cleanName = kamuiName or "kamui"
        local existing = backpack:FindFirstChild(cleanName) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(cleanName))
        if existing then existing:Destroy() end

        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.CanBeDropped = false
        tool.Name = cleanName
        tool.ToolTip = "Kamui Teleport (" .. cleanName .. ")"
        tool:SetAttribute("ItemId", itemId or 1173)

        tool.Activated:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local mouse = LocalPlayer:GetMouse()

            if hrp and mouse and mouse.Hit then
                KamuiVisuals.PlayKamui(cleanName)
                local dest = mouse.Hit.Position + Vector3.new(0, 3.5, 0)
                task.wait(0.18)
                hrp.CFrame = CFrame.new(dest, dest + hrp.CFrame.LookVector)
            end
        end)

        tool.Parent = backpack
    end)
end

-- 5. Give All Kamui Tools
function KamuiVisuals.GiveAllKamuis()
    KamuiVisuals.GiveKamuiTool("kamui", 1173)
    KamuiVisuals.GiveKamuiTool("rip kamui", 1191)
    KamuiVisuals.GiveKamuiTool("arena kamui", 1235)
    KamuiVisuals.GiveKamuiTool("heaven kamui", 1236)
    KamuiVisuals.GiveKamuiTool("pakistan kamui", 1173)
end

-- 6. Summon Dimension Platforms
local activeDimensionModel = nil
function KamuiVisuals.SummonDimension(dimName)
    pcall(function()
        if activeDimensionModel and activeDimensionModel.Parent then
            activeDimensionModel:Destroy()
        end

        local model = Instance.new("Model")
        model.Name = "Dimension_" .. dimName:gsub("%s+", "_")
        activeDimensionModel = model

        local centerPos = Vector3.new(0, 4500, 0)
        local mat = Enum.Material.SmoothPlastic
        local pColor = Color3.fromRGB(24, 20, 36)

        if dimName == "Heaven Dimension" then
            centerPos = Vector3.new(0, 5500, 0)
            mat = Enum.Material.Neon
            pColor = Color3.fromRGB(250, 240, 200)
        elseif dimName == "Pakistan Dimension" then
            centerPos = Vector3.new(1500, 4800, 1500)
            pColor = Color3.fromRGB(0, 120, 50)
            mat = Enum.Material.SmoothPlastic
        elseif dimName == "Rip Family Arena" then
            centerPos = Vector3.new(-2500, 4200, -2500)
            pColor = Color3.fromRGB(60, 20, 30)
        elseif dimName == "Pocket Dimension" then
            centerPos = Vector3.new(0, 3800, 0)
            pColor = Color3.fromRGB(16, 14, 22)
        end

        -- Main floor platform
        local floor = Instance.new("Part", model)
        floor.Name = "Floor"
        floor.Size = Vector3.new(160, 4, 160)
        floor.Position = centerPos
        floor.Anchored = true
        floor.Material = mat
        floor.Color = pColor
        floor.CastShadow = false

        -- Decorative pillars
        for _, offset in ipairs({
            Vector3.new(70, 16, 70),
            Vector3.new(-70, 16, 70),
            Vector3.new(70, 16, -70),
            Vector3.new(-70, 16, -70),
        }) do
            local pillar = Instance.new("Part", model)
            pillar.Size = Vector3.new(6, 32, 6)
            pillar.Position = centerPos + offset
            pillar.Anchored = true
            pillar.Material = Enum.Material.Neon
            pillar.Color = Color3.fromRGB(255, 255, 255)
            pillar.CastShadow = false
        end

        model.Parent = Workspace

        -- Teleport character to dimension
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            KamuiVisuals.PlayKamui(dimName:lower())
            task.wait(0.2)
            hrp.CFrame = CFrame.new(centerPos + Vector3.new(0, 6, 0))
        end
    end)
end

_G.DarlingX_KamuiVisuals = KamuiVisuals
return KamuiVisuals
