--[[
    Darling Hub - Tracers Module
    Hardware 3D Beam (Nameless standard) and 2D Line (Drawing API / ScreenGui fallback).
    Renders visual links from LocalPlayer to active combat targets.
]]--

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Tracers = {}
local isEnabled = false
local renderConnection = nil

-- Configuration State
local currentThickness = 2
local currentColor = Color3.fromRGB(255, 255, 255)
local currentOrigin = "Player" -- "Player", "Center", "Bottom", "Mouse"
local currentType = "Both"     -- "3D Beam", "2D Line", "Both"
local rainbowEnabled = true

local function makeRainbowSequence(offset)
    offset = offset or 0
    local kps = {}
    for i = 0, 6 do
        local h = ((i / 6) + offset) % 1
        kps[#kps + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(h, 0.85, 1))
    end
    return ColorSequence.new(kps)
end

-- 3D Beam Assets (Nameless implementation)
local tracerModel = nil
local tracerAttachment0 = nil
local tracerAttachment1 = nil
local tracerBeam = nil

-- Drawing API Reference
local drawingLine = nil
local hasDrawing = (typeof(Drawing) == "table" or typeof(Drawing) == "userdata") and (typeof(Drawing.new) == "function")

-- ScreenGui References (Rotated frame fallback)
local overlayGui = nil
local guiLine = nil

local function safeParentGui(gui)
    if not gui then return false end
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h and typeof(h) == "Instance" then
            local okP = pcall(function() gui.Parent = h end)
            if okP and gui.Parent == h then return true end
        end
    end
    local lp = Players.LocalPlayer
    if lp then
        local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui")
        if pg then
            local okP = pcall(function() gui.Parent = pg end)
            if okP and gui.Parent == pg then return true end
        end
    end
    if CoreGui then
        local okP = pcall(function() gui.Parent = CoreGui end)
        if okP and gui.Parent == CoreGui then return true end
    end
    return gui.Parent ~= nil
end

local function getOverlayGui()
    if overlayGui and overlayGui.Parent then return overlayGui end
    local gui = Instance.new("ScreenGui")
    gui.Name = "Monody_Tracers_Overlay"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 2147483647
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Enabled = true
    pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
    safeParentGui(gui)
    overlayGui = gui
    return overlayGui
end

local function ensureGuiLine()
    if guiLine and guiLine.Parent then return guiLine end
    local overlay = getOverlayGui()
    if not overlay then return nil end

    local line = Instance.new("Frame")
    line.Name = "TracerLine"
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BorderSizePixel = 0
    line.BackgroundColor3 = currentColor
    line.BackgroundTransparency = 0
    line.ZIndex = 10000
    line.Visible = false
    line.Parent = overlay

    guiLine = line
    return guiLine
end

local function ensureDrawingLine()
    if not hasDrawing then return nil end
    if drawingLine then return drawingLine end
    local ok, l = pcall(function()
        local line = Drawing.new("Line")
        line.Thickness = currentThickness
        line.Color = currentColor
        line.Transparency = 1
        line.Visible = false
        return line
    end)
    if ok and l then
        drawingLine = l
        _G.DarlingDrawingTracerLine = l
        return drawingLine
    end
    return nil
end

local function createBeamTracer()
    if tracerModel and tracerModel.Parent then return end
    pcall(function()
        local parentFolder = Workspace:FindFirstChild("DarlingVisuals")
        if not parentFolder then
            parentFolder = Instance.new("Folder")
            parentFolder.Name = "DarlingVisuals"
            parentFolder.Parent = Workspace
        end

        local part = Instance.new("Part")
        part.Name = "TracerAnchor"
        part.Size = Vector3.zero
        part.Transparency = 1
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Anchored = true
        part.Parent = parentFolder

        local att0 = Instance.new("Attachment")
        att0.Name = "SourceAttachment"
        att0.Parent = part

        local att1 = Instance.new("Attachment")
        att1.Name = "TargetAttachment"
        att1.Parent = part

        local beam = Instance.new("Beam")
        beam.Name = "TracerBeam"
        beam.Attachment0 = att0
        beam.Attachment1 = att1
        beam.Width0 = math.clamp(currentThickness * 0.08, 0.1, 0.6)
        beam.Width1 = math.clamp(currentThickness * 0.08, 0.1, 0.6)
        beam.FaceCamera = true
        beam.Segments = 1
        beam.LightEmission = 1
        beam.LightInfluence = 0
        beam.Color = ColorSequence.new(currentColor)
        beam.Transparency = NumberSequence.new(0)
        beam.Enabled = false
        beam.Parent = part

        tracerModel = part
        tracerAttachment0 = att0
        tracerAttachment1 = att1
        tracerBeam = beam
    end)
end

local function destroyBeamTracer()
    if tracerModel then
        pcall(function() tracerModel:Destroy() end)
        tracerModel = nil
        tracerAttachment0 = nil
        tracerAttachment1 = nil
        tracerBeam = nil
    end
end

local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0
end

local function resolveTargetPart()
    local env = (getgenv and getgenv()) or _G
    local core = env.MonodyCombatCore or env.DarlingCombatCore or _G.MonodyCombatCore or _G.DarlingCombatCore
    local silentAim = env.MonodySilentAim or _G.MonodySilentAim

    -- 1. Shared Aimbot or Core Target Part (NPC or Player)
    if core and core.CurrentTargetPart and core.CurrentTargetPart.Parent then
        if isAlive(core.CurrentTargetPart.Parent) then
            return core.CurrentTargetPart
        end
    end

    -- 2. Silent Aim Target
    if silentAim and silentAim.getTarget then
        local st = silentAim.getTarget()
        if st and st.Parent and isAlive(st.Parent) then
            return st
        end
    end

    if _G.currentSilentAimTarget and _G.currentSilentAimTarget.Parent then
        local parentChar = _G.currentSilentAimTarget.Parent
        if isAlive(parentChar) then
            return _G.currentSilentAimTarget
        end
    end

    -- 3. Fallback: Find closest player on screen/world
    local lp = Players.LocalPlayer or LocalPlayer
    local lpChar = lp and lp.Character
    local lpHRP = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
    if lpHRP then
        local nearest = nil
        local minDist = math.huge
        local teamCheck = (core and core.TeamCheck == true)
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= lp and pl.Character and isAlive(pl.Character) then
                local isEnemy = true
                if teamCheck and pl.Team and lp.Team and pl.Team == lp.Team then
                    isEnemy = false
                end
                if isEnemy then
                    local hrp = pl.Character:FindFirstChild("HumanoidRootPart") or pl.Character:FindFirstChild("Head")
                    if hrp then
                        local d = (hrp.Position - lpHRP.Position).Magnitude
                        if d < minDist then
                            minDist = d
                            nearest = hrp
                        end
                    end
                end
            end
        end
        if nearest then return nearest end

        -- 4. Fallback: Check nearest NPC in Workspace
        local folders = {
            Workspace:FindFirstChild("Enemies"),
            Workspace:FindFirstChild("Characters"),
        }
        for _, f in ipairs(folders) do
            if f then
                for _, ent in ipairs(f:GetChildren()) do
                    if ent:IsA("Model") and isAlive(ent) and not Players:GetPlayerFromCharacter(ent) then
                        local hrp = ent:FindFirstChild("HumanoidRootPart") or ent:FindFirstChild("Head")
                        if hrp then
                            local d = (hrp.Position - lpHRP.Position).Magnitude
                            if d < minDist and d <= 1200 then
                                minDist = d
                                nearest = hrp
                            end
                        end
                    end
                end
            end
        end
        return nearest
    end

    return nil
end

local function getOriginPosition(lpHRP)
    local camera = Workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)

    if currentOrigin == "Mouse" and not UserInputService.TouchEnabled then
        local m = UserInputService:GetMouseLocation()
        if m.X > 0 and m.Y > 0 then return m end
    elseif currentOrigin == "Bottom" then
        return Vector2.new(viewport.X / 2, viewport.Y - 10)
    elseif currentOrigin == "Player" and lpHRP and camera then
        local sPos, onScreen = camera:WorldToViewportPoint(lpHRP.Position)
        if onScreen and sPos.Z > 0 then
            return Vector2.new(sPos.X, sPos.Y)
        end
    end
    return Vector2.new(viewport.X / 2, viewport.Y / 2)
end

local function onRender()
    if not isEnabled then
        if tracerBeam then tracerBeam.Enabled = false end
        if drawingLine then drawingLine.Visible = false end
        if guiLine then guiLine.Visible = false end
        return
    end

    local lp = Players.LocalPlayer or LocalPlayer
    local lpChar = lp and lp.Character
    local lpHRP = lpChar and lpChar:FindFirstChild("HumanoidRootPart")

    local targetPart = resolveTargetPart()
    if not targetPart or not lpHRP then
        if tracerBeam then tracerBeam.Enabled = false end
        if drawingLine then drawingLine.Visible = false end
        if guiLine then guiLine.Visible = false end
        return
    end

    local want3D = (currentType == "3D Beam" or currentType == "Both")
    local want2D = (currentType == "2D Line" or currentType == "Both")

    -- 1. Nameless 3D Beam Update
    if want3D then
        if not tracerBeam or not tracerBeam.Parent then
            createBeamTracer()
        end
        if tracerBeam and tracerAttachment0 and tracerAttachment1 then
            tracerAttachment0.WorldPosition = lpHRP.Position
            tracerAttachment1.WorldPosition = targetPart.Position
            if rainbowEnabled then
                tracerBeam.Color = makeRainbowSequence((os.clock() * 0.5) % 1)
            else
                tracerBeam.Color = ColorSequence.new(currentColor)
            end
            tracerBeam.Enabled = true
        end
    elseif tracerBeam then
        tracerBeam.Enabled = false
    end

    -- 2. 2D SnapLine Update
    if want2D then
        local camera = Workspace.CurrentCamera
        if not camera then return end

        local sPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen or sPos.Z <= 0 then
            if drawingLine then drawingLine.Visible = false end
            if guiLine then guiLine.Visible = false end
            return
        end

        local fromPos = getOriginPosition(lpHRP)
        local toPos = Vector2.new(sPos.X, sPos.Y)
        local dynColor = rainbowEnabled and Color3.fromHSV((os.clock() * 0.5) % 1, 0.85, 1) or currentColor

        local dLine = ensureDrawingLine()
        if dLine then
            local ok = pcall(function()
                dLine.From = fromPos
                dLine.To = toPos
                dLine.Color = dynColor
                dLine.Thickness = currentThickness
                dLine.Visible = true
            end)
            if ok then
                if guiLine then guiLine.Visible = false end
                return
            end
        end

        local frame = ensureGuiLine()
        if frame then
            local delta = toPos - fromPos
            local dist = delta.Magnitude
            local angle = math.atan2(delta.Y, delta.X)
            local overlay = getOverlayGui()
            local origin = (overlay and overlay.AbsolutePosition) or Vector2.zero

            frame.Size = UDim2.fromOffset(dist, currentThickness)
            frame.Position = UDim2.fromOffset((fromPos.X + toPos.X) / 2 - origin.X, (fromPos.Y + toPos.Y) / 2 - origin.Y)
            frame.Rotation = math.deg(angle)
            frame.BackgroundColor3 = dynColor
            frame.Visible = true
        end
    else
        if drawingLine then drawingLine.Visible = false end
        if guiLine then guiLine.Visible = false end
    end
end

function Tracers.enable()
    isEnabled = true
    _G.G_SilentAimShowLine = true
    _G.DarlingTracersVisible = true
    createBeamTracer()
    if currentType == "2D Line" or currentType == "Both" then
        ensureDrawingLine()
        ensureGuiLine()
    end
    if not renderConnection then
        renderConnection = RunService.RenderStepped:Connect(onRender)
    end
    return true
end

function Tracers.disable()
    isEnabled = false
    _G.G_SilentAimShowLine = false
    _G.DarlingTracersVisible = false
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
    if tracerBeam then tracerBeam.Enabled = false end
    if drawingLine then drawingLine.Visible = false end
    if guiLine then guiLine.Visible = false end
end

function Tracers.setVisible(state)
    if state then Tracers.enable() else Tracers.disable() end
end

function Tracers.setColor(c)
    if c == "Rainbow" or (typeof(c) == "string" and c:lower() == "rainbow") then
        Tracers.setRainbow(true)
    elseif typeof(c) == "Color3" then
        rainbowEnabled = false
        currentColor = c
        if tracerBeam then tracerBeam.Color = ColorSequence.new(c) end
        if drawingLine then drawingLine.Color = c end
        if guiLine then guiLine.BackgroundColor3 = c end
    end
end

function Tracers.setRainbow(state)
    rainbowEnabled = (state == true)
    if not rainbowEnabled and tracerBeam then
        tracerBeam.Color = ColorSequence.new(currentColor)
    end
end

function Tracers.setThickness(t)
    local th = tonumber(t) or 2
    currentThickness = th
    if tracerBeam then
        local w = math.clamp(th * 0.08, 0.1, 0.6)
        tracerBeam.Width0 = w
        tracerBeam.Width1 = w
    end
    if drawingLine then drawingLine.Thickness = th end
    if guiLine then guiLine.Size = UDim2.fromOffset(guiLine.Size.X.Offset, th) end
end

function Tracers.setType(t)
    if t == "3D Beam" or t == "2D Line" or t == "Both" then
        currentType = t
    end
end

function Tracers.setOrigin(orig)
    if orig == "Player" or orig == "Mouse" or orig == "Bottom" or orig == "Center" then
        currentOrigin = orig
    else
        currentOrigin = "Player"
    end
end

function Tracers.destroy()
    Tracers.disable()
    destroyBeamTracer()
    if drawingLine then
        pcall(function() drawingLine:Remove() end)
        drawingLine = nil
    end
    if guiLine then
        pcall(function() guiLine:Destroy() end)
        guiLine = nil
    end
    if overlayGui then
        pcall(function() overlayGui:Destroy() end)
        overlayGui = nil
    end
end

return Tracers
