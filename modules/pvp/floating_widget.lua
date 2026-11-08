--[[
    Darling Hub - Floating Widget Framework
    Supports Action (tap) and Toggle (on/off) widgets with seamless two-way WindUI synchronization
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local FloatingWidget = {
    Locked = false,
    AllWidgets = {},
}
FloatingWidget.__index = FloatingWidget

local function getGuiContainer()
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and h then return h end
    local ok2, c = pcall(function() return CoreGui end)
    if ok2 and c then return c end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local SharedScreenGui = nil

local function getSharedScreenGui()
    if SharedScreenGui and SharedScreenGui.Parent then
        return SharedScreenGui
    end

    local parent = getGuiContainer()
    local existing = parent:FindFirstChild("DarlingFloatingWidgets")
    if existing then
        SharedScreenGui = existing
        return SharedScreenGui
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "DarlingFloatingWidgets"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 2147482000
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
    gui.Parent = parent
    SharedScreenGui = gui
    return SharedScreenGui
end

function FloatingWidget.LockAll(locked)
    FloatingWidget.Locked = (locked == true)
end

function FloatingWidget.create(config)
    config = config or {}
    local id = config.Id or ("Widget_" .. tostring(os.clock()))
    local label = config.Label or config.Title or "ACT"
    local widgetType = config.Type or "Toggle"
    local enabled = config.Default == true
    local accentColor = config.AccentColor or Color3.fromRGB(192, 132, 252)
    local defaultPos = config.Position or UDim2.new(0.4, 0, 0.25, 0)
    local callback = config.Callback or function() end
    local uiElementKey = config.UIElementKey or id

    local screenGui = getSharedScreenGui()

    local oldPill = screenGui:FindFirstChild(id)
    if oldPill then oldPill:Destroy() end

    local pill = Instance.new("TextButton")
    pill.Name = id
    pill.Size = UDim2.fromOffset(66, 38)
    pill.AutomaticSize = Enum.AutomaticSize.X
    pill.Position = defaultPos
    pill.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    pill.BackgroundTransparency = 0.2
    pill.BorderSizePixel = 0
    pill.AutoButtonColor = false
    pill.Text = ""
    pill.Active = true
    pill.Visible = (config.Visible == true)
    pill.Parent = screenGui

    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MinSize = Vector2.new(66, 38)
    sizeConstraint.MaxSize = Vector2.new(200, 38)
    sizeConstraint.Parent = pill

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, (widgetType == "Toggle" and 20 or 12))
    padding.PaddingTop = UDim.new(0, 2)
    padding.PaddingBottom = UDim.new(0, 2)
    padding.Parent = pill

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(0, 11)
    pillCorner.Parent = pill

    local pillStroke = Instance.new("UIStroke")
    pillStroke.Name = "BorderStroke"
    pillStroke.Thickness = 1.2
    pillStroke.Color = Color3.fromRGB(180, 180, 210)
    pillStroke.Transparency = 0.4
    pillStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    pillStroke.Parent = pill

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "MainText"
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.AutomaticSize = Enum.AutomaticSize.X
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 13
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextTruncate = Enum.TextTruncate.AtEnd
    textLabel.Text = label
    textLabel.Parent = pill

    local statusDot = nil
    if widgetType == "Toggle" then
        statusDot = Instance.new("Frame")
        statusDot.Name = "StatusDot"
        statusDot.Size = UDim2.fromOffset(7, 7)
        statusDot.AnchorPoint = Vector2.new(1, 0)
        statusDot.Position = UDim2.new(1, -5, 0, 5)
        statusDot.BackgroundColor3 = enabled and Color3.fromRGB(74, 222, 128) or Color3.fromRGB(239, 68, 68)
        statusDot.BorderSizePixel = 0
        statusDot.Parent = pill

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = statusDot
    end

    local self = setmetatable({
        Id = id,
        UIElementKey = uiElementKey,
        Type = widgetType,
        Enabled = enabled,
        Pill = pill,
        Stroke = pillStroke,
        TextLabel = textLabel,
        StatusDot = statusDot,
        AccentColor = accentColor,
        BaseLabel = label,
        Callback = callback,
        Cooldown = false,
        Connections = {},
    }, FloatingWidget)

    table.insert(FloatingWidget.AllWidgets, self)
    FloatingWidget.AllWidgets[id] = self

    local function updateVisuals()
        if self.Type == "Toggle" then
            if self.Enabled then
                pillStroke.Color = Color3.fromRGB(74, 222, 128)
                pillStroke.Transparency = 0.15
                if self.StatusDot then self.StatusDot.BackgroundColor3 = Color3.fromRGB(74, 222, 128) end
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                pillStroke.Color = Color3.fromRGB(239, 68, 68)
                pillStroke.Transparency = 0.25
                if self.StatusDot then self.StatusDot.BackgroundColor3 = Color3.fromRGB(239, 68, 68) end
                textLabel.TextColor3 = Color3.fromRGB(248, 113, 113)
            end
        else
            pillStroke.Color = Color3.fromRGB(180, 180, 210)
            pillStroke.Transparency = 0.35
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end

    self.UpdateVisuals = updateVisuals
    updateVisuals()

    function self:TriggerAction()
        if self.Cooldown then return end
        self.Cooldown = true

        if self.Callback then
            self.Callback(true)
        end

        pcall(function()
            pill.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
            textLabel.Text = "!"
            pillStroke.Transparency = 0.05
        end)

        task.delay(0.35, function()
            pcall(function()
                if pill and pill.Parent then
                    pill.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
                    textLabel.Text = self.BaseLabel
                    pillStroke.Transparency = 0.35
                end
            end)
            self.Cooldown = false
        end)
    end

    local isInteracting = false
    local currentInput = nil
    local dragStart = nil
    local startPos = nil
    local hasMoved = false

    table.insert(self.Connections, pill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isInteracting = true
            currentInput = input
            dragStart = input.Position
            startPos = pill.Position
            hasMoved = false
        end
    end))

    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
        if isInteracting and input == currentInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            if dragStart and startPos then
                local delta = input.Position - dragStart
                if delta.Magnitude > 6 then
                    hasMoved = true
                    if not FloatingWidget.Locked then
                        pill.Position = UDim2.new(
                            startPos.X.Scale,
                            startPos.X.Offset + delta.X,
                            startPos.Y.Scale,
                            startPos.Y.Offset + delta.Y
                        )
                    end
                end
            end
        end
    end))

    table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input)
        if isInteracting and input == currentInput then
            isInteracting = false
            currentInput = nil
            local wasDrag = hasMoved
            hasMoved = false
            dragStart = nil
            startPos = nil

            if not wasDrag then
                if self.Type == "Action" then
                    self:TriggerAction()
                else
                    self:Toggle()
                end
            end
        end
    end))

    return self
end

function FloatingWidget:Set(state, suppressCallback)
    self.Enabled = (state == true)
    self.UpdateVisuals()

    if not suppressCallback then
        -- Sync with WindUI element
        local key = self.UIElementKey or self.Id
        if _G.DarlingHub and _G.DarlingHub.UIElements and _G.DarlingHub.UIElements[key] then
            pcall(function()
                local uiEl = _G.DarlingHub.UIElements[key]
                if uiEl and uiEl.Set then
                    uiEl:Set(self.Enabled)
                end
            end)
        end

        if self.Callback then
            self.Callback(self.Enabled)
        end
    end
end

function FloatingWidget:SetState(state)
    self.Enabled = (state == true)
    self.UpdateVisuals()
end

function FloatingWidget:Toggle()
    self:Set(not self.Enabled)
end

function FloatingWidget:SetVisible(visible)
    if self.Pill and self.Pill.Parent then
        self.Pill.Visible = (visible == true)
    end
end

function FloatingWidget:SetLabel(lbl)
    self.BaseLabel = lbl
    if self.TextLabel then
        self.TextLabel.Text = lbl
    end
end

function FloatingWidget:Destroy()
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(self.Connections)
    if self.Pill and self.Pill.Parent then
        self.Pill:Destroy()
    end
end

function FloatingWidget.GetWidget(id)
    return FloatingWidget.AllWidgets[id]
end

return FloatingWidget
