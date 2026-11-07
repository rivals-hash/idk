--[[
    BestHub - modules/core/utils.lua
    Universal utilities: device detection, touch/mouse dragging,
    toast notifications, clipboard, and stats formatters.
]]

local Utils = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Device detection
Utils.IsTouch = UserInputService.TouchEnabled
Utils.IsMobile = UserInputService.TouchEnabled and (not UserInputService.MouseEnabled or not UserInputService.KeyboardEnabled)

-- Safe Parent GUI helper
function Utils.safeParent(gui, preferredParent)
    if preferredParent and typeof(preferredParent) == "Instance" then
        local ok = pcall(function() gui.Parent = preferredParent end)
        if ok and gui.Parent == preferredParent then return true end
    end
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h and typeof(h) == "Instance" then
            local okP = pcall(function() gui.Parent = h end)
            if okP and gui.Parent == h then return true end
        end
    end
    if LocalPlayer then
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
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

-- Clipboard helper
function Utils.setClipboard(text)
    if not text then return false end
    local fn = setclipboard or toclipboard or (Clipboard and Clipboard.set) or (syn and syn.write_clipboard)
    if fn then
        local ok = pcall(fn, tostring(text))
        return ok
    end
    return false
end

-- Number formatter (e.g. 30000000 -> "30M", 2500000 -> "2.5M", 50000 -> "50K")
function Utils.formatNumber(n)
    n = tonumber(n) or 0
    if n >= 1000000000 then
        return string.format("%.1fB", n / 1000000000):gsub("%.0B", "B")
    elseif n >= 1000000 then
        return string.format("%.1fM", n / 1000000):gsub("%.0M", "M")
    elseif n >= 1000 then
        return string.format("%.1fK", n / 1000):gsub("%.0K", "K")
    end
    return tostring(math.floor(n))
end

-- Comma separated number (e.g. 30000000 -> "30,000,000")
function Utils.formatCommas(n)
    local left, num, right = string.match(tostring(n), '^([^%d]*%d)(%d*)(.-)$')
    if not left then return tostring(n) end
    return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

-- Format seconds into mm:ss
function Utils.formatTime(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    return string.format("%02d:%02d", m, s)
end

-- Toast Notification System
local toastContainer = nil
function Utils.getToastContainer()
    if toastContainer and toastContainer.Parent then return toastContainer end
    local sg = Instance.new("ScreenGui")
    sg.Name = "Monody_ToastGui"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999999
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Utils.safeParent(sg)

    local holder = Instance.new("Frame")
    holder.Name = "ToastHolder"
    holder.Size = UDim2.new(0, 320, 1, 0)
    holder.Position = UDim2.new(0.5, -160, 0, 20)
    holder.BackgroundTransparency = 1
    holder.Parent = sg

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = holder

    toastContainer = holder
    return toastContainer
end

function Utils.toast(title, message, duration, iconId)
    duration = duration or 3
    local holder = Utils.getToastContainer()
    if not holder then return end

    local card = Instance.new("Frame")
    card.Name = "ToastCard"
    card.Size = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = holder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 95)
    stroke.Thickness = 1
    stroke.Parent = card

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 26, 0, 26)
    icon.Position = UDim2.new(0, 10, 0.5, -13)
    icon.BackgroundTransparency = 1
    icon.Image = iconId or "rbxassetid://98755624629571"
    icon.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "Title"
    titleLbl.Size = UDim2.new(1, -50, 0, 18)
    titleLbl.Position = UDim2.new(0, 44, 0, 6)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = title or "Monody"
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Name = "Message"
    msgLbl.Size = UDim2.new(1, -50, 0, 16)
    msgLbl.Position = UDim2.new(0, 44, 0, 24)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.Text = message or ""
    msgLbl.TextColor3 = Color3.fromRGB(185, 185, 200)
    msgLbl.TextSize = 11
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextTruncate = Enum.TextTruncate.AtEnd
    msgLbl.Parent = card

    -- Animate in
    card.BackgroundTransparency = 1
    titleLbl.TextTransparency = 1
    msgLbl.TextTransparency = 1
    icon.ImageTransparency = 1
    stroke.Transparency = 1

    TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.15
    }):Play()
    TweenService:Create(stroke, TweenInfo.new(0.25), { Transparency = 0 }):Play()
    TweenService:Create(titleLbl, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
    TweenService:Create(msgLbl, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
    TweenService:Create(icon, TweenInfo.new(0.25), { ImageTransparency = 0 }):Play()

    task.delay(duration, function()
        if card and card.Parent then
            local tw = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0)
            })
            TweenService:Create(stroke, TweenInfo.new(0.2), { Transparency = 1 }):Play()
            TweenService:Create(titleLbl, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
            TweenService:Create(msgLbl, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
            TweenService:Create(icon, TweenInfo.new(0.2), { ImageTransparency = 1 }):Play()
            tw:Play()
            tw.Completed:Connect(function()
                pcall(function() card:Destroy() end)
            end)
        end
    end)
end

-- Universal Draggable Implementation (Touch & Mouse)
function Utils.makeDraggable(targetFrame, handle)
    handle = handle or targetFrame
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and dragStart and startPos then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Responsive UIScale Calculator
function Utils.getOptimalScale()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize
    if not vp or vp.X < 100 then
        vp = Utils.IsTouch and Vector2.new(800, 390) or Vector2.new(1280, 720)
    end
    -- Target window dimensions: 760 x 590
    local scaleW = (vp.X - 20) / 780
    local scaleH = (vp.Y - 20) / 600
    local fit = math.clamp(math.min(scaleW, scaleH), 0.40, 1.0)
    if Utils.IsTouch or Utils.IsMobile then
        fit = math.clamp(fit, 0.45, 0.80)
    end
    return fit
end

return Utils
