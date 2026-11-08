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

-- Sleek Minimalist Toast Notification System (Compact Pill, Non-Intrusive, Debounced)
local toastContainer = nil
local lastToastMessage = nil
local lastToastTick = 0

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
    holder.Size = UDim2.new(0, 260, 0, 200)
    holder.Position = UDim2.new(0.5, -130, 0, 14)
    holder.BackgroundTransparency = 1
    holder.Parent = sg

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = holder

    toastContainer = holder
    return toastContainer
end

function Utils.toast(title, message, duration, iconId)
    local now = tick()
    -- Suppress identical toast spam within 1.5s
    if lastToastMessage == message and (now - lastToastTick) < 1.5 then
        return
    end
    lastToastMessage = message
    lastToastTick = now

    duration = duration or 1.5
    local holder = Utils.getToastContainer()
    if not holder then return end

    -- Keep at most 2 active toasts to avoid clutter
    local children = holder:GetChildren()
    local count = 0
    for _, ch in ipairs(children) do
        if ch:IsA("GuiObject") and ch.Name == "ToastPill" then
            count = count + 1
            if count >= 2 then
                pcall(function() ch:Destroy() end)
            end
        end
    end

    local pill = Instance.new("Frame")
    pill.Name = "ToastPill"
    pill.Size = UDim2.new(0, 240, 0, 32)
    pill.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    pill.BackgroundTransparency = 0.15
    pill.BorderSizePixel = 0
    pill.ClipsDescendants = true
    pill.Parent = holder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = pill

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(75, 75, 95)
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = pill

    local hasIcon = (iconId ~= nil and iconId ~= "")
    local textOffset = hasIcon and 32 or 12

    if hasIcon then
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 18, 0, 18)
        icon.Position = UDim2.new(0, 8, 0.5, -9)
        icon.BackgroundTransparency = 1
        icon.Image = iconId
        icon.Parent = pill
    end

    local textLbl = Instance.new("TextLabel")
    textLbl.Name = "ToastText"
    textLbl.Size = UDim2.new(1, -textOffset - 10, 1, 0)
    textLbl.Position = UDim2.new(0, textOffset, 0, 0)
    textLbl.BackgroundTransparency = 1
    textLbl.Font = Enum.Font.Kalam
    textLbl.Text = (message and message ~= "") and message or (title or "Monody")
    textLbl.TextColor3 = Color3.fromRGB(245, 240, 245)
    textLbl.TextSize = 13.5
    textLbl.TextXAlignment = Enum.TextXAlignment.Left
    textLbl.TextTruncate = Enum.TextTruncate.AtEnd
    textLbl.Parent = pill

    -- Smooth slide-in
    pill.Position = UDim2.new(0, 0, 0, -8)
    pill.BackgroundTransparency = 1
    textLbl.TextTransparency = 1
    stroke.Transparency = 1

    TweenService:Create(pill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.15,
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    TweenService:Create(stroke, TweenInfo.new(0.2), { Transparency = 0.3 }):Play()
    TweenService:Create(textLbl, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()

    task.delay(duration, function()
        if pill and pill.Parent then
            local tw = TweenService:Create(pill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, -8)
            })
            TweenService:Create(stroke, TweenInfo.new(0.18), { Transparency = 1 }):Play()
            TweenService:Create(textLbl, TweenInfo.new(0.18), { TextTransparency = 1 }):Play()
            tw:Play()
            tw.Completed:Connect(function()
                pcall(function() pill:Destroy() end)
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
    -- Target window dimensions: 568 x 400
    local scaleW = (vp.X - 24) / 580
    local scaleH = (vp.Y - 24) / 410
    local fit = math.clamp(math.min(scaleW, scaleH), 0.45, 1.0)
    if Utils.IsTouch or Utils.IsMobile then
        fit = math.clamp(fit, 0.50, 0.95)
    end
    return fit
end

return Utils
