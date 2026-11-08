--[[
    Monody Premium - modules/ui/mobile_toggle.lua
    Universal draggable floating toggle widget (FAB) for touchscreens & PC.
    Positioned higher up to prevent obstruction of mobile controls.
]]

local MobileToggle = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

function MobileToggle.create(parentScreenGui, onToggleCallback, Utils)
    -- Main Container Frame for shadow & glow
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = "Monody_MobileToggleContainer"
    toggleContainer.Size = UDim2.new(0, 52, 0, 52)
    -- Positioned higher up near top-left screen margin
    toggleContainer.Position = UDim2.new(0, 18, 0, 48)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.BorderSizePixel = 0
    toggleContainer.ZIndex = 200
    toggleContainer.Parent = parentScreenGui

    local toggleBtn = Instance.new("ImageButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.Position = UDim2.new(0, 0, 0, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    toggleBtn.BackgroundTransparency = 0.15
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Image = "rbxassetid://93891873418133"
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    toggleBtn.AutoButtonColor = false
    toggleBtn.Active = true
    toggleBtn.ZIndex = 201
    toggleBtn.Parent = toggleContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggleBtn

    -- Vibrant Neon Violet Luminous Rim Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(195, 125, 255)
    stroke.Thickness = 2.2
    stroke.Transparency = 0.05
    stroke.Parent = toggleBtn

    -- Subtle Neon Pulse Animation
    pcall(function()
        local pulseInfo = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
        TweenService:Create(stroke, pulseInfo, {
            Color = Color3.fromRGB(245, 190, 255),
            Thickness = 2.6
        }):Play()
    end)

    -- Subtle Live Status Dot (Online / Active Indicator in Neon Emerald)
    local statusDot = Instance.new("Frame")
    statusDot.Name = "StatusDot"
    statusDot.Size = UDim2.new(0, 12, 0, 12)
    statusDot.Position = UDim2.new(1, -12, 1, -12)
    statusDot.BackgroundColor3 = Color3.fromRGB(45, 255, 125)
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 203
    statusDot.Parent = toggleBtn

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = statusDot

    local dotStroke = Instance.new("UIStroke")
    dotStroke.Color = Color3.fromRGB(16, 12, 24)
    dotStroke.Thickness = 1.8
    dotStroke.Parent = statusDot

    -- Make it draggable with Touch and Mouse via container
    if Utils and Utils.makeDraggable then
        Utils.makeDraggable(toggleContainer, toggleBtn)
    end

    -- Click / Tap handler with tap vs drag detection
    local startPos = Vector2.new()
    local startTime = 0

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startPos = Vector2.new(input.Position.X, input.Position.Y)
            startTime = tick()
        end
    end)

    local lastClickTick = 0
    local function onActivated()
        local now = tick()
        if now - lastClickTick < 0.25 then return end
        lastClickTick = now

        -- Tactile spring bounce animation
        TweenService:Create(toggleBtn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 44, 0, 44),
            Position = UDim2.new(0, 4, 0, 4)
        }):Play()

        task.delay(0.08, function()
            TweenService:Create(toggleBtn, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
        end)

        pcall(onToggleCallback)
    end

    toggleBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local endPos = Vector2.new(input.Position.X, input.Position.Y)
            local dist = (endPos - startPos).Magnitude
            local elapsed = tick() - startTime
            -- If user dragged less than 10 pixels and held under 0.4s, consider it a tap
            if dist < 10 and elapsed < 0.45 then
                onActivated()
            end
        end
    end)

    return toggleContainer
end

return MobileToggle
