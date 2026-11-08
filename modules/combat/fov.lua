--[[
    Darling Hub - FOV Circle Module
    ScreenGui FOV implementation with UIGradient and UIStroke.
    100% reliable across all executors and platforms (PC, Mobile, Console).
]]

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local FOV = {}
local isEnabled = false
local renderConnection = nil

-- Configuration State
local currentRadius = 150
local currentThickness = 2
local currentColor = Color3.fromRGB(255, 255, 255)
local currentMode = "Mouse" -- "Mouse" or "Center"
local rainbowEnabled = true

-- ScreenGui Element References
local overlayGui = nil
local ringFrame = nil
local ringStroke = nil
local ringGradient = nil

local function parentFor()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h and typeof(h) == "Instance" then return h end
    end
    if CoreGui then
        local okC, core = pcall(function() return CoreGui end)
        if okC and core then return core end
    end
    local lp = LocalPlayer or Players.LocalPlayer
    if lp then
        local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui")
        if pg then return pg end
    end
    return nil
end

local function makeRainbowSequence()
    local kps = {}
    for i = 0, 6 do
        kps[#kps + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 0.85, 1))
    end
    return ColorSequence.new(kps)
end

local function makeSolidSequence(color)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, color),
    })
end

local function cleanupGui()
    if renderConnection then
        pcall(function() renderConnection:Disconnect() end)
        renderConnection = nil
    end
    if overlayGui then
        pcall(function() overlayGui:Destroy() end)
        overlayGui = nil
    end
    ringFrame = nil
    ringStroke = nil
    ringGradient = nil
end

local function buildFovGui()
    if overlayGui and overlayGui.Parent and ringFrame and ringFrame.Parent then
        return true
    end

    cleanupGui()

    local parent = parentFor()
    if not parent then return false end

    local gui = Instance.new("ScreenGui")
    gui.Name = "DarlingHub_FOV"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 1000000
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Enabled = true

    if syn and syn.protect_gui then
        pcall(syn.protect_gui, gui)
    end

    local frame = Instance.new("Frame")
    frame.Name = "Ring"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Active = false
    frame.Size = UDim2.fromOffset(currentRadius * 2, currentRadius * 2)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.Visible = true
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = currentThickness
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Transparency = 0
    stroke.Parent = frame

    local gradient = Instance.new("UIGradient")
    if rainbowEnabled then
        gradient.Color = makeRainbowSequence()
    else
        gradient.Color = makeSolidSequence(currentColor)
    end
    gradient.Parent = stroke

    gui.Parent = parent

    overlayGui = gui
    ringFrame = frame
    ringStroke = stroke
    ringGradient = gradient
    return true
end

local function onRender()
    if not isEnabled or not ringFrame or not ringFrame.Parent then return end

    local hub = _G.DarlingHub or (getgenv and getgenv().DarlingHub)
    local aimMode = (hub and hub.Settings and hub.Settings.Aim and hub.Settings.Aim.Mode)
        or (_G.DarlingCombatCore and _G.DarlingCombatCore.AimMode)
        or (getgenv and getgenv().DarlingCombatCore and getgenv().DarlingCombatCore.AimMode)
        or "360"

    if aimMode ~= "FOV" then
        if ringFrame.Visible then
            ringFrame.Visible = false
        end
        return
    end

    if not ringFrame.Visible then
        ringFrame.Visible = true
    end

    if rainbowEnabled and ringGradient then
        ringGradient.Rotation = (os.clock() * 90) % 360
    end

    if UserInputService.TouchEnabled or currentMode == "Center" then
        ringFrame.Position = UDim2.fromScale(0.5, 0.5)
    else
        local mousePos = UserInputService:GetMouseLocation()
        ringFrame.Position = UDim2.fromOffset(mousePos.X, mousePos.Y)
    end
end

function FOV.enable()
    if isEnabled then return end
    isEnabled = true

    buildFovGui()
    if ringFrame then
        ringFrame.Size = UDim2.fromOffset(currentRadius * 2, currentRadius * 2)
        local hub = _G.DarlingHub or (getgenv and getgenv().DarlingHub)
        local aimMode = (hub and hub.Settings and hub.Settings.Aim and hub.Settings.Aim.Mode)
            or (_G.DarlingCombatCore and _G.DarlingCombatCore.AimMode)
            or (getgenv and getgenv().DarlingCombatCore and getgenv().DarlingCombatCore.AimMode)
            or "360"
        ringFrame.Visible = (aimMode == "FOV")
    end

    if not renderConnection then
        renderConnection = RunService.RenderStepped:Connect(onRender)
    end

    -- Sincronizar radio con el core de combate
    pcall(function()
        local hub = _G.DarlingHub or (getgenv and getgenv().DarlingHub)
        local core = (_G.DarlingCombatCore) or (getgenv and getgenv().DarlingCombatCore) or (hub and hub.Require and hub:Require("modules/combat/aimbot_core.lua"))
        if core and core.setFOVRadius then
            core.setFOVRadius(currentRadius)
        end
    end)
end

function FOV.disable()
    isEnabled = false
    cleanupGui()
end

function FOV.toggle(state)
    if state == nil then state = not isEnabled end
    if state then
        FOV.enable()
    else
        FOV.disable()
    end
    return isEnabled
end

function FOV.setRadius(radius)
    currentRadius = math.clamp(tonumber(radius) or 150, 10, 1200)
    if ringFrame then
        ringFrame.Size = UDim2.fromOffset(currentRadius * 2, currentRadius * 2)
    end
    pcall(function()
        local hub = _G.DarlingHub or (getgenv and getgenv().DarlingHub)
        local core = hub and hub.Require and hub:Require("modules/combat/aimbot_core.lua")
        if core and core.setFOVRadius then
            core.setFOVRadius(currentRadius)
        end
    end)
end

function FOV.setColor(color)
    if color == "Rainbow" or (typeof(color) == "string" and color:lower() == "rainbow") then
        FOV.setRainbow(true)
    elseif typeof(color) == "Color3" then
        rainbowEnabled = false
        currentColor = color
        if ringGradient then
            ringGradient.Color = makeSolidSequence(color)
            ringGradient.Rotation = 0
        end
    end
end

function FOV.setThickness(thickness)
    currentThickness = math.clamp(tonumber(thickness) or 2, 1, 10)
    if ringStroke then
        ringStroke.Thickness = currentThickness
    end
end

function FOV.setMode(mode)
    if mode == "Center" or mode == "Mouse" then
        currentMode = mode
    end
end

function FOV.setRainbow(enabled)
    rainbowEnabled = (enabled == true)
    if ringGradient then
        if rainbowEnabled then
            ringGradient.Color = makeRainbowSequence()
        else
            ringGradient.Color = makeSolidSequence(currentColor)
            ringGradient.Rotation = 0
        end
    end
end

function FOV.getRadius()
    return currentRadius
end

function FOV.isEnabled()
    return isEnabled
end

function FOV.destroy()
    FOV.disable()
end

return FOV
