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

-- 1. Kamui Camera Swirl Animation (Blox Fruits Native or Smooth FOV Pulse)
local function playKamuiCameraEffect()
    task.spawn(function()
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

        -- Safe client camera FOV pulsation without messing up orientation
        pcall(function()
            local camera = Workspace.CurrentCamera
            if not camera then return end
            local origFov = camera.FieldOfView
            local tIn = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local tOut = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            local tw1 = TweenService:Create(camera, tIn, { FieldOfView = math.clamp(origFov - 25, 20, 120) })
            tw1:Play()
            tw1.Completed:Wait()
            local tw2 = TweenService:Create(camera, tOut, { FieldOfView = origFov })
            tw2:Play()
        end)
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
    local char = LocalPlayer.Character
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
    local myPos = hrp and hrp.Position or Vector3.new(0, 0, 0)

    -- 1. Check mouse ray hit on PC ONLY if aiming at a real target/ground (not sky)
    if mouse and mouse.Target and mouse.Hit and mouse.Hit.Position then
        local p = mouse.Hit.Position
        if (p - myPos).Magnitude <= 800 then
            return p
        end
    end

    -- 2. Raycast forward from camera center (Essential for Mobile touch screens)
    if camera then
        local ray = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        if char then
            raycastParams.FilterDescendantsInstances = { char }
        end
        local hit = Workspace:Raycast(ray.Origin, ray.Direction * 600, raycastParams)
        if hit and hit.Position then
            return hit.Position
        end
    end

    -- 3. Safe Fallback: 35 studs forward in LookVector with ground snapping
    if hrp then
        local forwardPos = hrp.Position + (hrp.CFrame.LookVector * 35)
        local downParams = RaycastParams.new()
        downParams.FilterType = Enum.RaycastFilterType.Exclude
        if char then downParams.FilterDescendantsInstances = { char } end
        local groundHit = Workspace:Raycast(forwardPos + Vector3.new(0, 10, 0), Vector3.new(0, -60, 0), downParams)
        if groundHit and groundHit.Position then
            return groundHit.Position
        end
        return forwardPos
    end
    return nil
end

-- 4. Execute Full Kamui Warp (Origin Vortex + Camera + Teleport + Exit Vortex)
function KamuiVisuals.Warp(name, targetPos)
    local char = LocalPlayer.Character
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
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

    -- Reset velocity to prevent flinging or sliding into void
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)

    -- Teleport slightly above target surface
    task.wait(0.08)
    local look = hrp.CFrame.LookVector
    hrp.CFrame = CFrame.new(dest + Vector3.new(0, 3.5, 0), dest + Vector3.new(0, 3.5, 0) + look)

    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)

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

        -- Protective safety barrier perimeter
        local barrierNorth = Instance.new("Part", model)
        barrierNorth.Size = Vector3.new(160, 8, 2)
        barrierNorth.Position = centerPos + Vector3.new(0, 4, 80)
        barrierNorth.Anchored = true
        barrierNorth.Transparency = 0.6
        barrierNorth.Material = Enum.Material.Neon
        barrierNorth.Color = pColor

        local barrierSouth = Instance.new("Part", model)
        barrierSouth.Size = Vector3.new(160, 8, 2)
        barrierSouth.Position = centerPos + Vector3.new(0, 4, -80)
        barrierSouth.Anchored = true
        barrierSouth.Transparency = 0.6
        barrierSouth.Material = Enum.Material.Neon
        barrierSouth.Color = pColor

        local barrierEast = Instance.new("Part", model)
        barrierEast.Size = Vector3.new(2, 8, 160)
        barrierEast.Position = centerPos + Vector3.new(80, 4, 0)
        barrierEast.Anchored = true
        barrierEast.Transparency = 0.6
        barrierEast.Material = Enum.Material.Neon
        barrierEast.Color = pColor

        local barrierWest = Instance.new("Part", model)
        barrierWest.Size = Vector3.new(2, 8, 160)
        barrierWest.Position = centerPos + Vector3.new(-80, 4, 0)
        barrierWest.Anchored = true
        barrierWest.Transparency = 0.6
        barrierWest.Material = Enum.Material.Neon
        barrierWest.Color = pColor

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

        -- Teleport character safely to dimension platform
        local char = LocalPlayer.Character
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
        if hrp then
            pcall(function()
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
            KamuiVisuals.Warp(dimName:lower(), centerPos + Vector3.new(0, 5, 0))
        end
    end)
end

_G.DarlingX_KamuiVisuals = KamuiVisuals
return KamuiVisuals
