--[[
    Monody Premium - modules/combat/fov.lua
    FOV Circle Visualizer (Darling X Edition)
    Dual-layer rendering: ScreenGui (100% mobile compatibility) + Drawing API.
    Supports dynamic colors (Rainbow, White, Red, Green, Blue, Yellow, Purple),
    radius scaling, and Center / Touch positioning.
]]

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local FOV = {}

-- State
local isEnabled = false
local isRainbow = true
local currentColor = Color3.fromRGB(255, 255, 255)
local currentRadius = 120
local currentThickness = 1.5
local currentMode = "Center" -- "Center" or "Mouse"
local renderConnection = nil

-- Colors Palette (Darling X Standard)
FOV.ColorMap = {
    Rainbow = nil,
    White = Color3.fromRGB(255, 255, 255),
    Red = Color3.fromRGB(255, 60, 60),
    Green = Color3.fromRGB(60, 255, 120),
    Blue = Color3.fromRGB(60, 160, 255),
    Yellow = Color3.fromRGB(255, 225, 60),
    Purple = Color3.fromRGB(180, 80, 255),
    Cyan = Color3.fromRGB(60, 240, 255),
    Orange = Color3.fromRGB(255, 140, 40),
}
FOV.ColorNames = { "Rainbow", "White", "Red", "Green", "Blue", "Yellow", "Purple", "Cyan", "Orange" }

-- GUI Elements
local overlayGui = nil
local guiFrame = nil
local guiStroke = nil

-- Drawing API Reference
local drawingCircle = nil
local hasDrawing = (typeof(Drawing) == "table" and typeof(Drawing.new) == "function")

local function getOverlayGui()
    if overlayGui and overlayGui.Parent then return overlayGui end
    local gui = Instance.new("ScreenGui")
    gui.Name = "Monody_FOV_Overlay"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 2147483000

    if syn and syn.protect_gui then
        pcall(syn.protect_gui, gui)
    end

    local parented = false
    if gethui then
        parented = pcall(function() gui.Parent = gethui() end)
    end
    if not parented then
        parented = pcall(function() gui.Parent = CoreGui end)
    end
    if not parented and LocalPlayer then
        pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end

    overlayGui = gui
    return overlayGui
end

local function ensureGuiCircle()
    if guiFrame and guiFrame.Parent and guiStroke and guiStroke.Parent then
        return guiFrame
    end
    local overlay = getOverlayGui()
    if not overlay then return nil end

    local frame = Instance.new("Frame")
    frame.Name = "FOVCircle"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = overlay

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = currentThickness
    stroke.Color = currentColor
    stroke.Parent = frame

    guiFrame = frame
    guiStroke = stroke
    return guiFrame
end

local function ensureDrawingCircle()
    if not hasDrawing then return nil end
    if drawingCircle then return drawingCircle end
    local ok, c = pcall(function()
        local circle = Drawing.new("Circle")
        circle.Thickness = currentThickness
        circle.NumSides = 64
        circle.Filled = false
        circle.Transparency = 1
        circle.Color = currentColor
        circle.Visible = false
        return circle
    end)
    if ok and c then
        drawingCircle = c
        return drawingCircle
    end
    return nil
end

local function onRender()
    if not isEnabled then return end

    local camera = Workspace.CurrentCamera
    if not camera then return end

    local center
    if currentMode == "Mouse" then
        center = UserInputService:GetMouseLocation()
    else
        center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    end

    local color = currentColor
    if isRainbow then
        color = Color3.fromHSV((tick() * 0.35) % 1, 0.85, 1)
    end

    -- 1. ScreenGui Circle (Guaranteed visible on mobile touch screens)
    local frame = ensureGuiCircle()
    if frame and guiStroke then
        frame.Position = UDim2.fromOffset(center.X, center.Y)
        frame.Size = UDim2.fromOffset(currentRadius * 2, currentRadius * 2)
        guiStroke.Color = color
        guiStroke.Thickness = currentThickness
        frame.Visible = true
    end

    -- 2. Drawing API Circle (if executor supports it)
    if hasDrawing then
        local dCircle = ensureDrawingCircle()
        if dCircle then
            dCircle.Position = center
            dCircle.Radius = currentRadius
            dCircle.Color = color
            dCircle.Thickness = currentThickness
            dCircle.Visible = true
        end
    end
end

function FOV.enable()
    isEnabled = true
    ensureGuiCircle()
    if hasDrawing then ensureDrawingCircle() end

    if not renderConnection then
        renderConnection = RunService.RenderStepped:Connect(onRender)
    end
    return true
end

function FOV.disable()
    isEnabled = false
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end

    if guiFrame then
        guiFrame.Visible = false
    end
    if drawingCircle then
        drawingCircle.Visible = false
    end
end

function FOV.setVisible(state)
    if state then
        FOV.enable()
    else
        FOV.disable()
    end
end

function FOV.setRadius(radius)
    currentRadius = tonumber(radius) or 120
end

function FOV.setColor(colorNameOrColor3)
    if typeof(colorNameOrColor3) == "Color3" then
        isRainbow = false
        currentColor = colorNameOrColor3
    elseif type(colorNameOrColor3) == "string" then
        if colorNameOrColor3 == "Rainbow" then
            isRainbow = true
        elseif FOV.ColorMap[colorNameOrColor3] then
            isRainbow = false
            currentColor = FOV.ColorMap[colorNameOrColor3]
        end
    end
end

function FOV.setRainbow(state)
    isRainbow = (state == true)
end

function FOV.setMode(mode)
    if mode == "Mouse" or mode == "Touch" then
        currentMode = "Mouse"
    else
        currentMode = "Center"
    end
end

function FOV.setThickness(thickness)
    currentThickness = tonumber(thickness) or 1.5
end

function FOV.getRadius()
    return currentRadius
end

function FOV.getMode()
    return currentMode
end

function FOV.getState()
    return {
        enabled = isEnabled,
        rainbow = isRainbow,
        radius = currentRadius,
        mode = currentMode,
        thickness = currentThickness,
    }
end

function FOV.destroy()
    FOV.disable()
    if guiFrame then
        pcall(function() guiFrame:Destroy() end)
        guiFrame = nil
        guiStroke = nil
    end
    if drawingCircle then
        pcall(function() drawingCircle:Remove() end)
        drawingCircle = nil
    end
    if overlayGui then
        pcall(function() overlayGui:Destroy() end)
        overlayGui = nil
    end
end

_G.MonodyFOV = FOV
if getgenv then
    pcall(function() getgenv().MonodyFOV = FOV end)
end

return FOV
