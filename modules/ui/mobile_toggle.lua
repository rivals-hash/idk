--[[
    BestHub - modules/ui/mobile_toggle.lua
    Floating draggable action button (FAB) designed for mobile devices.
    Enables single-tap opening/closing of the hub on touchscreens.
]]

local MobileToggle = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function MobileToggle.create(parentScreenGui, onToggleCallback, Utils)
    local toggleBtn = Instance.new("ImageButton")
    toggleBtn.Name = "BestHub_MobileToggle"
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 18, 0.45, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    toggleBtn.BackgroundTransparency = 0.2
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Image = "rbxassetid://93891873418133"
    toggleBtn.ScaleType = Enum.ScaleType.Crop
    toggleBtn.AutoButtonColor = false
    toggleBtn.ZIndex = 100
    toggleBtn.Parent = parentScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggleBtn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.8
    stroke.Transparency = 0.3
    stroke.Parent = toggleBtn

    -- Make it draggable with Touch and Mouse
    Utils.makeDraggable(toggleBtn, toggleBtn)

    -- Click to toggle
    local lastClickTick = 0
    toggleBtn.MouseButton1Click:Connect(function()
        if tick() - lastClickTick < 0.2 then return end
        lastClickTick = tick()

        -- Bounce animation
        TweenService:Create(toggleBtn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 44, 0, 44)
        }):Play()
        task.delay(0.08, function()
            TweenService:Create(toggleBtn, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 50, 0, 50)
            }):Play()
        end)

        pcall(onToggleCallback)
    end)

    return toggleBtn
end

return MobileToggle
