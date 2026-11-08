--[[
    Darling Hub - mode_selector.lua (Version 1.4)
    Interactive startup screen to select between Fast Mode and Full Mode.
    Follows exact UI layout, typography, and styling provided by user.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local function resolveCustomAsset(providedAsset, fallbackId, filename)
    if providedAsset and type(providedAsset) == "string" and #providedAsset > 0 and not providedAsset:match("^https?://") then
        return providedAsset
    end
    local getAsset = getcustomasset or getsynasset or (getgenv and (getgenv().getcustomasset or getgenv().getsynasset)) or (syn and syn.get_custom_asset)
    local isFile = isfile or (getgenv and getgenv().isfile)
    if type(getAsset) == "function" and type(isFile) == "function" and filename then
        local candidates = {
            filename,
            "assets/" .. filename,
            "DarlingHub/media_cache/" .. filename,
            "darling-hub/assets/" .. filename
        }
        for _, path in ipairs(candidates) do
            local okF, exists = pcall(isFile, path)
            if okF and exists then
                local okA, asset = pcall(getAsset, path)
                if okA and type(asset) == "string" and #asset > 0 then
                    return asset
                end
            end
        end
    end
    return fallbackId
end

local function safeParentGui(gui, preferredParent)
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
    return false
end

local ModeSelector = {}

function ModeSelector.show(options)
    options = options or {}
    local onSelect = options.onSelect or function() end
    local isFastConfigured = options.isFastConfigured == true
    local parentTarget = options.parent

    local fastAsset = resolveCustomAsset(options.fastAsset, "rbxassetid://98223928022309", "darling_logo_v14_halloween.png")
    local fullAsset = resolveCustomAsset(options.fullAsset, "rbxassetid://109687263098821", "darling_logo_v14_anime.png")

    -- Clean up any existing mode selector modal
    local existing = nil
    if gethui then
        pcall(function() existing = gethui():FindFirstChild("DarlingHub_ModeSelector") end)
    end
    if not existing and LocalPlayer then
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
        if pg then existing = pg:FindFirstChild("DarlingHub_ModeSelector") end
    end
    if not existing and CoreGui then
        pcall(function() existing = CoreGui:FindFirstChild("DarlingHub_ModeSelector") end)
    end
    if existing then
        pcall(function() existing:Destroy() end)
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DarlingHub_ModeSelector"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = false
    ScreenGui.DisplayOrder = 100000
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
    ScreenGui.ClipToDeviceSafeArea = true

    if syn and syn.protect_gui then
        pcall(syn.protect_gui, ScreenGui)
    end

    -- Main Container Frame (400x229)
    local Frame = Instance.new("Frame")
    Frame.Name = "Frame"
    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(0, 400, 0, 229)
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.ClipsDescendants = false

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.Name = "UICorner"
    FrameCorner.CornerRadius = UDim.new(0, 8)
    FrameCorner.Parent = Frame

    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Name = "FrameStroke"
    FrameStroke.Parent = Frame
    FrameStroke.Thickness = 1.2
    FrameStroke.Color = Color3.fromRGB(45, 45, 45)
    FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Responsive UIScale for small mobile displays
    local UiScale = Instance.new("UIScale")
    UiScale.Name = "UIScale"
    UiScale.Parent = Frame

    local function updateScale()
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam and cam.ViewportSize then
                local vpH = cam.ViewportSize.Y
                local vpW = cam.ViewportSize.X
                local scale = 1
                if vpH < 360 or vpW < 480 then
                    scale = math.clamp(math.min(vpH / 360, vpW / 480), 0.65, 1)
                end
                UiScale.Scale = scale
            end
        end)
    end
    updateScale()

    -- Title: "Choose A Mode"
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = Frame
    TitleLabel.Size = UDim2.new(0, 193, 0, 25)
    TitleLabel.Position = UDim2.new(0.2575, 0, 0.048, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Michroma
    TitleLabel.Text = "Choose A Mode"
    TitleLabel.TextSize = 25
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    TitleLabel.TextYAlignment = Enum.TextYAlignment.Center

    -- Close Button "X"
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = Frame
    CloseButton.Size = UDim2.new(0, 39, 0, 27)
    CloseButton.Position = UDim2.new(0.87, 0, 0.048, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Font = Enum.Font.Michroma
    CloseButton.Text = "X"
    CloseButton.TextSize = 25
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.AutoButtonColor = false

    -- Fast Mode Card (Left)
    local FastButton = Instance.new("ImageButton")
    FastButton.Name = "FastModeButton"
    FastButton.Parent = Frame
    FastButton.Size = UDim2.new(0, 125, 0, 120)
    FastButton.Position = UDim2.new(0.12133483588695526, 0, 0.24242417514324188, 0)
    FastButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    FastButton.BackgroundTransparency = 0
    FastButton.BorderSizePixel = 0
    FastButton.ScaleType = Enum.ScaleType.Fit
    FastButton.Image = fastAsset
    FastButton.AutoButtonColor = false

    local FastCorner = Instance.new("UICorner")
    FastCorner.Name = "UICorner"
    FastCorner.CornerRadius = UDim.new(0, 8)
    FastCorner.Parent = FastButton

    local FastStroke = Instance.new("UIStroke")
    FastStroke.Name = "UIStroke"
    FastStroke.Parent = FastButton
    FastStroke.Thickness = isFastConfigured and 2 or 1
    FastStroke.Color = isFastConfigured and Color3.fromRGB(255, 140, 40) or Color3.fromRGB(60, 60, 60)
    FastStroke.Transparency = isFastConfigured and 0 or 0.4

    -- Fast Mode Label (Interactive TextButton)
    local FastLabel = Instance.new("TextButton")
    FastLabel.Name = "FastModeLabel"
    FastLabel.Parent = Frame
    FastLabel.Size = UDim2.new(0, 193, 0, 25)
    FastLabel.Position = UDim2.new(0.035, 0, 0.8166, 0)
    FastLabel.BackgroundTransparency = 1
    FastLabel.Font = Enum.Font.Michroma
    FastLabel.Text = "Fast Mode"
    FastLabel.TextSize = 17
    FastLabel.TextColor3 = isFastConfigured and Color3.fromRGB(255, 160, 50) or Color3.fromRGB(255, 255, 255)
    FastLabel.TextXAlignment = Enum.TextXAlignment.Center
    FastLabel.TextYAlignment = Enum.TextYAlignment.Center
    FastLabel.AutoButtonColor = false

    -- Full Mode Card (Right)
    local FullButton = Instance.new("ImageButton")
    FullButton.Name = "FullModeButton"
    FullButton.Parent = Frame
    FullButton.Size = UDim2.new(0, 125, 0, 120)
    FullButton.Position = UDim2.new(0.5596493482589722, 0, 0.2380952090024948, 0)
    FullButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    FullButton.BackgroundTransparency = 0
    FullButton.BorderSizePixel = 0
    FullButton.ScaleType = Enum.ScaleType.Fit
    FullButton.Image = fullAsset
    FullButton.AutoButtonColor = false

    local FullCorner = Instance.new("UICorner")
    FullCorner.Name = "UICorner"
    FullCorner.CornerRadius = UDim.new(0, 8)
    FullCorner.Parent = FullButton

    local FullStroke = Instance.new("UIStroke")
    FullStroke.Name = "UIStroke"
    FullStroke.Parent = FullButton
    FullStroke.Thickness = (not isFastConfigured) and 2 or 1
    FullStroke.Color = (not isFastConfigured) and Color3.fromRGB(180, 70, 255) or Color3.fromRGB(60, 60, 60)
    FullStroke.Transparency = (not isFastConfigured) and 0 or 0.4

    -- Full Mode Label (Interactive TextButton)
    local FullLabel = Instance.new("TextButton")
    FullLabel.Name = "FullModeLabel"
    FullLabel.Parent = Frame
    FullLabel.Size = UDim2.new(0, 193, 0, 25)
    FullLabel.Position = UDim2.new(0.485, 0, 0.8166, 0)
    FullLabel.BackgroundTransparency = 1
    FullLabel.Font = Enum.Font.Michroma
    FullLabel.Text = "Full Mode"
    FullLabel.TextSize = 17
    FullLabel.TextColor3 = (not isFastConfigured) and Color3.fromRGB(200, 130, 255) or Color3.fromRGB(255, 255, 255)
    FullLabel.TextXAlignment = Enum.TextXAlignment.Center
    FullLabel.TextYAlignment = Enum.TextYAlignment.Center
    FullLabel.AutoButtonColor = false

    -- Subtle AFK auto-select notification label
    local CountdownLabel = Instance.new("TextLabel")
    CountdownLabel.Name = "CountdownLabel"
    CountdownLabel.Parent = Frame
    CountdownLabel.Size = UDim2.new(1, 0, 0, 16)
    CountdownLabel.Position = UDim2.new(0, 0, 0.93, 0)
    CountdownLabel.BackgroundTransparency = 1
    CountdownLabel.Font = Enum.Font.Michroma
    CountdownLabel.TextSize = 10
    CountdownLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    CountdownLabel.TextTransparency = 0.3
    CountdownLabel.Text = ""

    -- Hover Animations
    local function setupHover(button, label, stroke, activeColor, origPos, origSize)
        local hoverSize = UDim2.new(0, origSize.X.Offset + 4, 0, origSize.Y.Offset + 4)
        local hoverPos = UDim2.new(origPos.X.Scale, origPos.X.Offset - 2, origPos.Y.Scale, origPos.Y.Offset - 2)

        local function enter()
            pcall(function()
                TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
                    Size = hoverSize,
                    Position = hoverPos
                }):Play()
                TweenService:Create(stroke, TweenInfo.new(0.12), {
                    Color = activeColor,
                    Transparency = 0,
                    Thickness = 2
                }):Play()
                TweenService:Create(label, TweenInfo.new(0.12), {
                    TextColor3 = activeColor
                }):Play()
            end)
        end

        local function leave()
            pcall(function()
                TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
                    Size = origSize,
                    Position = origPos
                }):Play()
                local isDef = (button == FastButton and isFastConfigured) or (button == FullButton and not isFastConfigured)
                TweenService:Create(stroke, TweenInfo.new(0.12), {
                    Color = isDef and activeColor or Color3.fromRGB(60, 60, 60),
                    Transparency = isDef and 0 or 0.4,
                    Thickness = isDef and 2 or 1
                }):Play()
                TweenService:Create(label, TweenInfo.new(0.12), {
                    TextColor3 = isDef and activeColor or Color3.fromRGB(255, 255, 255)
                }):Play()
            end)
        end

        button.MouseEnter:Connect(enter)
        button.MouseLeave:Connect(leave)
        label.MouseEnter:Connect(enter)
        label.MouseLeave:Connect(leave)
    end

    setupHover(
        FastButton,
        FastLabel,
        FastStroke,
        Color3.fromRGB(255, 140, 40),
        UDim2.new(0.12133483588695526, 0, 0.24242417514324188, 0),
        UDim2.new(0, 125, 0, 120)
    )

    setupHover(
        FullButton,
        FullLabel,
        FullStroke,
        Color3.fromRGB(180, 70, 255),
        UDim2.new(0.5596493482589722, 0, 0.2380952090024948, 0),
        UDim2.new(0, 125, 0, 120)
    )

    CloseButton.MouseEnter:Connect(function()
        pcall(function()
            TweenService:Create(CloseButton, TweenInfo.new(0.1), { TextColor3 = Color3.fromRGB(255, 80, 80) }):Play()
        end)
    end)
    CloseButton.MouseLeave:Connect(function()
        pcall(function()
            TweenService:Create(CloseButton, TweenInfo.new(0.1), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
        end)
    end)

    -- Dragging Handler for Frame (Mouse and Touch)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and dragStart and startPos then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Selection Callback
    local isResolved = false
    local function selectMode(mode)
        if isResolved then return end
        isResolved = true

        pcall(function()
            TweenService:Create(Frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1,
                Position = UDim2.new(Frame.Position.X.Scale, Frame.Position.X.Offset, Frame.Position.Y.Scale, Frame.Position.Y.Offset - 18)
            }):Play()
            TweenService:Create(FastButton, TweenInfo.new(0.15), { ImageTransparency = 1, BackgroundTransparency = 1 }):Play()
            TweenService:Create(FullButton, TweenInfo.new(0.15), { ImageTransparency = 1, BackgroundTransparency = 1 }):Play()
            TweenService:Create(TitleLabel, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
            TweenService:Create(FastLabel, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
            TweenService:Create(FullLabel, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
            TweenService:Create(CloseButton, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
            TweenService:Create(CountdownLabel, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
        end)

        task.delay(0.22, function()
            pcall(function() ScreenGui:Destroy() end)
            onSelect(mode)
        end)
    end

    FastButton.MouseButton1Click:Connect(function() selectMode("fast") end)
    FastLabel.MouseButton1Click:Connect(function() selectMode("fast") end)
    FullButton.MouseButton1Click:Connect(function() selectMode("full") end)
    FullLabel.MouseButton1Click:Connect(function() selectMode("full") end)
    CloseButton.MouseButton1Click:Connect(function()
        selectMode("fast")
    end)

    -- AFK Auto-Selection Countdown (Defaults to Fast Mode in 10s)
    task.spawn(function()
        local totalSeconds = 10
        local targetMode = "fast"
        local targetLabel = "Fast Mode"

        for remaining = totalSeconds, 1, -1 do
            if isResolved then break end
            CountdownLabel.Text = "Auto-selecting " .. targetLabel .. " in " .. tostring(remaining) .. "s..."
            task.wait(1)
        end

        if not isResolved then
            selectMode(targetMode)
        end
    end)

    safeParentGui(ScreenGui, parentTarget)
    return ScreenGui
end

return ModeSelector
