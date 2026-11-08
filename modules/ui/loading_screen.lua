--[[
    Darling Hub - Real Loading Screen Engine (Borderless Minimalist Edition)
    High-performance, non-blocking splash loader with zero borders.
]]

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local LoadingScreen = {
    ScreenGui = nil,
    Card = nil,
    FillBar = nil,
    StatusLabel = nil,
    PercentLabel = nil,
    LogoImage = nil,
    IsActive = false,
}

local function getGuiParent()
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

function LoadingScreen.show(logoAsset)
    if LoadingScreen.IsActive and LoadingScreen.ScreenGui then return end
    LoadingScreen.IsActive = true

    local parent = getGuiParent()
    if not parent then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "DarlingHub_LoadingScreen"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    if syn and syn.protect_gui then
        pcall(syn.protect_gui, gui)
    end

    -- Dark sleek backdrop (Zero borders)
    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(6, 6, 9)
    backdrop.BackgroundTransparency = 0.45
    backdrop.BorderSizePixel = 0
    backdrop.Parent = gui

    -- Central Container (Zero borders)
    local card = Instance.new("CanvasGroup")
    card.Name = "Card"
    card.Size = UDim2.new(0, 360, 0, 220)
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.new(0.5, 0, 0.5, 0)
    card.BackgroundColor3 = Color3.fromRGB(14, 13, 18)
    card.BackgroundTransparency = 0.04
    card.BorderSizePixel = 0
    card.GroupTransparency = 1
    card.Parent = gui

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 18)
    cardCorner.Parent = card

    -- Logo Frame (Zero borders)
    local logoContainer = Instance.new("Frame")
    logoContainer.Name = "LogoContainer"
    logoContainer.Size = UDim2.new(0, 72, 0, 72)
    logoContainer.AnchorPoint = Vector2.new(0.5, 0)
    logoContainer.Position = UDim2.new(0.5, 0, 0, 22)
    logoContainer.BackgroundColor3 = Color3.fromRGB(22, 20, 28)
    logoContainer.BorderSizePixel = 0
    logoContainer.Parent = card

    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 16)
    logoCorner.Parent = logoContainer

    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(1, 0, 1, 0)
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Position = UDim2.new(0.5, 0, 0.5, 0)
    logo.BackgroundTransparency = 1
    logo.BorderSizePixel = 0
    logo.Image = logoAsset or "rbxassetid://109687263098821"
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = logoContainer

    local innerLogoCorner = Instance.new("UICorner")
    innerLogoCorner.CornerRadius = UDim.new(0, 16)
    innerLogoCorner.Parent = logo

    -- Hub Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 0, 24)
    title.AnchorPoint = Vector2.new(0.5, 0)
    title.Position = UDim2.new(0.5, 0, 0, 102)
    title.BackgroundTransparency = 1
    title.BorderSizePixel = 0
    title.Font = Enum.Font.GothamBold
    title.Text = "Darling Hub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 19
    title.Parent = card

    -- Status Text
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, -40, 0, 16)
    status.AnchorPoint = Vector2.new(0.5, 0)
    status.Position = UDim2.new(0.5, 0, 0, 128)
    status.BackgroundTransparency = 1
    status.BorderSizePixel = 0
    status.Font = Enum.Font.GothamMedium
    status.Text = "Iniciando sistema..."
    status.TextColor3 = Color3.fromRGB(165, 160, 175)
    status.TextSize = 12
    status.Parent = card

    -- Progress Track (Minimalist 5px height, Zero borders)
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, -70, 0, 5)
    track.AnchorPoint = Vector2.new(0.5, 0)
    track.Position = UDim2.new(0.5, 0, 0, 154)
    track.BackgroundColor3 = Color3.fromRGB(26, 24, 32)
    track.BorderSizePixel = 0
    track.Parent = card

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    -- Fill Bar (Zero borders, Neutral clean silver/white)
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(210, 215, 228)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 242, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(165, 170, 185)),
    })
    fillGradient.Parent = fill

    -- Percentage Label (Neutral clean text)
    local percent = Instance.new("TextLabel")
    percent.Name = "Percent"
    percent.Size = UDim2.new(1, -40, 0, 16)
    percent.AnchorPoint = Vector2.new(0.5, 0)
    percent.Position = UDim2.new(0.5, 0, 0, 168)
    percent.BackgroundTransparency = 1
    percent.BorderSizePixel = 0
    percent.Font = Enum.Font.GothamBold
    percent.Text = "0%"
    percent.TextColor3 = Color3.fromRGB(225, 228, 238)
    percent.TextSize = 12
    percent.Parent = card

    gui.Parent = parent

    LoadingScreen.ScreenGui = gui
    LoadingScreen.Card = card
    LoadingScreen.FillBar = fill
    LoadingScreen.StatusLabel = status
    LoadingScreen.PercentLabel = percent
    LoadingScreen.LogoImage = logo

    TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        GroupTransparency = 0
    }):Play()
end

function LoadingScreen.update(progress, text)
    if not LoadingScreen.IsActive or not LoadingScreen.FillBar then return end
    progress = math.clamp(tonumber(progress) or 0, 0, 1)

    if text and LoadingScreen.StatusLabel then
        LoadingScreen.StatusLabel.Text = tostring(text)
    end

    if LoadingScreen.PercentLabel then
        LoadingScreen.PercentLabel.Text = tostring(math.floor(progress * 100)) .. "%"
    end

    TweenService:Create(LoadingScreen.FillBar, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(progress, 0, 1, 0)
    }):Play()
end

function LoadingScreen.setLogo(asset)
    if LoadingScreen.LogoImage and asset then
        pcall(function() LoadingScreen.LogoImage.Image = asset end)
    end
end

function LoadingScreen.finish(callback)
    if not LoadingScreen.IsActive then
        if callback then pcall(callback) end
        return
    end

    LoadingScreen.update(1.0, "Listo")
    task.wait(0.2)

    if LoadingScreen.Card then
        local tween = TweenService:Create(LoadingScreen.Card, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            GroupTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            if LoadingScreen.ScreenGui then
                pcall(function() LoadingScreen.ScreenGui:Destroy() end)
            end
            LoadingScreen.ScreenGui = nil
            LoadingScreen.Card = nil
            LoadingScreen.FillBar = nil
            LoadingScreen.StatusLabel = nil
            LoadingScreen.PercentLabel = nil
            LoadingScreen.LogoImage = nil
            LoadingScreen.IsActive = false
            if callback then pcall(callback) end
        end)
    else
        if LoadingScreen.ScreenGui then
            pcall(function() LoadingScreen.ScreenGui:Destroy() end)
        end
        LoadingScreen.IsActive = false
        if callback then pcall(callback) end
    end
end

return LoadingScreen
