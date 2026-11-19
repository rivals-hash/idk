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

-- Helper: Get Kamui Theme Colors
local function getKamuiColors(name)
    local n = tostring(name):lower()
    if n:find("rip") then
        return Color3.fromRGB(40, 0, 70), Color3.fromRGB(255, 30, 80)
    elseif n:find("arena") then
        return Color3.fromRGB(80, 10, 20), Color3.fromRGB(255, 120, 30)
    elseif n:find("heaven") then
        return Color3.fromRGB(255, 230, 160), Color3.fromRGB(255, 255, 255)
    elseif n:find("pakistan") then
        return Color3.fromRGB(0, 140, 60), Color3.fromRGB(240, 255, 240)
    else
        return Color3.fromRGB(20, 15, 35), Color3.fromRGB(160, 50, 240)
    end
end

-- 1. Kamui Camera Swirl Animation (Blox Fruits Native or Smooth Swirl)
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
        local tInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
        TweenService:Create(camera, tInfo, { FieldOfView = math.clamp(origFov - 30, 15, 120) }):Play()

        local t0 = tick()
        while tick() - t0 < 0.35 do
            RunService.RenderStepped:Wait()
            local elapsed = tick() - t0
            camera.CFrame = camera.CFrame * CFrame.Angles(0, 0, math.rad(18 * (elapsed * 60)))
        end

        local tOut = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TweenService:Create(camera, tOut, { FieldOfView = origFov }):Play()
    end)
end

-- 2. Spawn Visual Vortex / Particles at Position
local function spawnKamuiVortex(pos, color1, color2)
    pcall(function()
        local part = Instance.new("Part")
        part.Name = "KamuiVortex"
        part.Size = Vector3.new(2, 2, 2)
        part.Position = pos
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.2
        part.Color = color1 or Color3.fromRGB(20, 15, 35)
        part.Material = Enum.Material.Neon
        part.Parent = Workspace

        local meshPart = Instance.new("SpecialMesh", part)
        meshPart.MeshType = Enum.MeshType.Sphere

        local tween = TweenService:Create(part, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = Vector3.new(16, 16, 16),
            Transparency = 1
        })
        tween:Play()

        local snd = Instance.new("Sound", part)
        snd.SoundId = "rbxassetid://9114223180"
        snd.Volume = 0.8
        snd:Play()

        Debris:AddItem(part, 1.0)
    end)
end

-- 3. Universal Destination Finder (PC Mouse & Mobile Touch Screen)
local function getTeleportTarget(mouse)
    local camera = Workspace.CurrentCamera

    -- Check mouse ray hit on PC
    if mouse and mouse.Hit and mouse.Hit.Position then
        local p = mouse.Hit.Position
        if p.Magnitude > 1 and p.Magnitude < 20000 then
            return p
        end
    end

    -- Raycast forward from camera center (Essential for Mobile touch screens)
    if camera then
        local ray = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        if LocalPlayer.Character then
            raycastParams.FilterDescendantsInstances = { LocalPlayer.Character }
        end
        local hit = Workspace:Raycast(ray.Origin, ray.Direction * 1500, raycastParams)
        if hit and hit.Position then
            return hit.Position
        end
    end

    -- Fallback: 50 studs forward in LookVector
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        return hrp.Position + (hrp.CFrame.LookVector * 50)
    end
    return nil
end

-- 4. Execute Full Kamui Warp (Origin Vortex + Camera + Teleport + Exit Vortex)
function KamuiVisuals.Warp(name, targetPos)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local c1, c2 = getKamuiColors(name)
    local origin = hrp.Position

    -- Find destination if not explicitly passed
    local dest = targetPos
    if not dest then
        local mouse = LocalPlayer:GetMouse()
        dest = getTeleportTarget(mouse)
    end
    if not dest then return false end

    -- Origin suction vortex & sound
    spawnKamuiVortex(origin, c1, c2)
    playKamuiCameraEffect()

    -- Teleport slightly above target surface
    task.wait(0.12)
    local look = hrp.CFrame.LookVector
    hrp.CFrame = CFrame.new(dest + Vector3.new(0, 3.5, 0), dest + Vector3.new(0, 3.5, 0) + look)

    -- Destination exit vortex
    spawnKamuiVortex(dest + Vector3.new(0, 3.5, 0), c2, c1)
    return true
end

function KamuiVisuals.PlayKamui(name)
    return KamuiVisuals.Warp(name, nil)
end

-- 5. Give Kamui Tool to Backpack (Mobile & PC Multi-Touch Compatible)
function KamuiVisuals.GiveKamuiTool(kamuiName, itemId)
    local cleanName = kamuiName or "kamui"
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end

    local existing = backpack:FindFirstChild(cleanName) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(cleanName))
    if existing then existing:Destroy() end

    local tool = Instance.new("Tool")
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.Name = cleanName
    tool.ToolTip = "Kamui Warp (" .. cleanName .. ")"
    tool:SetAttribute("ItemId", itemId or 1173)

    tool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        local dest = getTeleportTarget(mouse)
        KamuiVisuals.Warp(cleanName, dest)
    end)

    tool.Parent = backpack
    return tool
end

-- 6. Equip and Give Specific Kamui Tool Immediately
function KamuiVisuals.EquipKamui(kamuiName, itemId)
    local tool = KamuiVisuals.GiveKamuiTool(kamuiName, itemId)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if tool and hum then
        task.spawn(function()
            task.wait(0.05)
            hum:EquipTool(tool)
        end)
    end
    -- Also warp forward on initial button press!
    KamuiVisuals.Warp(kamuiName, nil)
end

-- 7. Give All Kamui Tools
function KamuiVisuals.GiveAllKamuis()
    KamuiVisuals.GiveKamuiTool("kamui", 1173)
    KamuiVisuals.GiveKamuiTool("rip kamui", 1191)
    KamuiVisuals.GiveKamuiTool("arena kamui", 1235)
    KamuiVisuals.GiveKamuiTool("heaven kamui", 1236)
    KamuiVisuals.GiveKamuiTool("pakistan kamui", 1173)
end

-- 8. Summon Dimension Platforms (Explicitly called on button click, NEVER on boot)
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
            KamuiVisuals.Warp(dimName:lower(), centerPos + Vector3.new(0, 6, 0))
        end
    end)
end

_G.DarlingX_KamuiVisuals = KamuiVisuals
return KamuiVisuals
