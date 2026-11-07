--[[
    BestHub - modules/ui/home_view.lua
    Faithful recreation and responsive conversion of the Monody Home Screen:
    - Card 1 (Top): Monody - Premium / By Darling / Avatar / Discord & TikTok / Key Time
    - Card 2 (Center): Avatar circle with live real stats (Level, Bounty, FPS, Ping, Time)
    - Card 3 (Bottom): White vertical music visualizer bars & player
    Uses AssetManager with getcustomasset for 100% reliable image loading.
]]

local HomeView = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

function HomeView.create(parentContainer, dependencies)
    local Utils = dependencies.Utils
    local StatsService = dependencies.StatsService
    local MusicEngine = dependencies.MusicEngine
    local MusicVisualizer = dependencies.MusicVisualizer
    local AssetManager = dependencies.AssetManager

    local bgAsset = AssetManager.get("card_bg.png", "rbxassetid://139820186687064")
    local avatarAsset = AssetManager.get("avatar.png", "rbxassetid://93891873418133")
    local discordAsset = "rbxassetid://16584754883"
    local tiktokAsset = "rbxassetid://84157643184125"

    local homeScroll = Instance.new("ScrollingFrame")
    homeScroll.Name = "HomeView"
    homeScroll.Size = UDim2.new(1, 0, 1, 0)
    homeScroll.BackgroundTransparency = 1
    homeScroll.BorderSizePixel = 0
    homeScroll.ScrollBarThickness = 3
    homeScroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
    homeScroll.CanvasSize = UDim2.new(0, 0, 0, 600)
    homeScroll.Parent = parentContainer

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = homeScroll

    -- Helper to create card frame with texture and solid fallback
    local function createCard(name, height, layoutOrder)
        local frame = Instance.new("Frame")
        frame.Name = name
        frame.Size = UDim2.new(0, 520, 0, height)
        frame.LayoutOrder = layoutOrder
        frame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
        frame.BackgroundTransparency = 0.25
        frame.BorderSizePixel = 0
        frame.Parent = homeScroll

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame

        local bg = Instance.new("ImageLabel")
        bg.Name = "Bg"
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundTransparency = 1
        bg.Image = bgAsset
        bg.ScaleType = Enum.ScaleType.Stretch
        bg.Parent = frame

        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 8)
        bgCorner.Parent = bg

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(65, 65, 80)
        stroke.Thickness = 1
        stroke.Transparency = 0.4
        stroke.Parent = frame

        return frame, bg
    end

    ----------------------------------------------------------------------------
    -- 1. CARD 1: TOP BRAND & SOCIALS CARD
    ----------------------------------------------------------------------------
    local card1, bg1 = createCard("TopBrandCard", 200, 1)

    -- Left Avatar Box
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Name = "AvatarBox"
    avatarFrame.Size = UDim2.new(0, 124, 0, 121)
    avatarFrame.Position = UDim2.new(0.048, 0, 0.11, 0)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    avatarFrame.BackgroundTransparency = 0
    avatarFrame.BorderSizePixel = 0
    avatarFrame.Parent = card1

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 8)
    avatarCorner.Parent = avatarFrame

    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = Color3.fromRGB(255, 255, 255)
    avatarStroke.Thickness = 1.2
    avatarStroke.Transparency = 0.3
    avatarStroke.Parent = avatarFrame

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "AvatarImage"
    avatarImg.Size = UDim2.new(0, 114, 0, 111)
    avatarImg.Position = UDim2.new(0.5, -57, 0.5, -55)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = avatarAsset
    avatarImg.ScaleType = Enum.ScaleType.Crop
    avatarImg.Parent = avatarFrame

    local imgCorner = Instance.new("UICorner")
    imgCorner.CornerRadius = UDim.new(0, 7)
    imgCorner.Parent = avatarImg

    -- Socials Buttons under Avatar
    -- Discord Button
    local discordBtn = Instance.new("ImageButton")
    discordBtn.Name = "DiscordButton"
    discordBtn.Size = UDim2.new(0, 39, 0, 37)
    discordBtn.Position = UDim2.new(0.04, 0, 1.12, 0)
    discordBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    discordBtn.BackgroundTransparency = 0.3
    discordBtn.Image = discordAsset
    discordBtn.AutoButtonColor = false
    discordBtn.Parent = avatarFrame

    local dCorner = Instance.new("UICorner")
    dCorner.CornerRadius = UDim.new(0, 8)
    dCorner.Parent = discordBtn

    discordBtn.MouseButton1Click:Connect(function()
        local discordLink = "https://discord.gg/besthub"
        Utils.setClipboard(discordLink)
        Utils.toast("Discord Copied", "Invite link copied to clipboard!", 2.5, discordAsset)
    end)

    -- TikTok Button
    local tiktokBtn = Instance.new("ImageButton")
    tiktokBtn.Name = "TikTokButton"
    tiktokBtn.Size = UDim2.new(0, 39, 0, 37)
    tiktokBtn.Position = UDim2.new(0.5, 0, 1.12, 0)
    tiktokBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    tiktokBtn.BackgroundTransparency = 0.3
    tiktokBtn.Image = tiktokAsset
    tiktokBtn.AutoButtonColor = false
    tiktokBtn.Parent = avatarFrame

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 8)
    tCorner.Parent = tiktokBtn

    tiktokBtn.MouseButton1Click:Connect(function()
        local tiktokLink = "https://www.tiktok.com/@besthub"
        Utils.setClipboard(tiktokLink)
        Utils.toast("TikTok Copied", "Profile link copied to clipboard!", 2.5, tiktokAsset)
    end)

    -- Hover animations for socials
    local function setupHoverSocial(btn)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), { Size = UDim2.new(0, 42, 0, 40) }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), { Size = UDim2.new(0, 39, 0, 37) }):Play()
        end)
    end
    setupHoverSocial(discordBtn)
    setupHoverSocial(tiktokBtn)

    -- Title: "Monody - "
    local titlePrefix = Instance.new("TextLabel")
    titlePrefix.Name = "TitlePrefix"
    titlePrefix.Size = UDim2.new(0, 130, 0, 36)
    titlePrefix.Position = UDim2.new(0.317, 0, 0.138, 0)
    titlePrefix.BackgroundTransparency = 1
    titlePrefix.Font = Enum.Font.Kalam
    titlePrefix.Text = "Monody - "
    titlePrefix.TextSize = 36
    titlePrefix.TextColor3 = Color3.fromRGB(255, 255, 255)
    titlePrefix.TextXAlignment = Enum.TextXAlignment.Left
    titlePrefix.Parent = card1

    -- Title: "Premium"
    local titleSuffix = Instance.new("TextLabel")
    titleSuffix.Name = "TitleSuffix"
    titleSuffix.Size = UDim2.new(0, 130, 0, 36)
    titleSuffix.Position = UDim2.new(0.53, 0, 0.138, 0)
    titleSuffix.BackgroundTransparency = 1
    titleSuffix.Font = Enum.Font.Kalam
    titleSuffix.Text = "Premium"
    titleSuffix.TextSize = 36
    titleSuffix.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleSuffix.TextXAlignment = Enum.TextXAlignment.Left
    titleSuffix.Parent = card1

    -- Subtitle: "By Darling"
    local authorLabel = Instance.new("TextLabel")
    authorLabel.Name = "AuthorLabel"
    authorLabel.Size = UDim2.new(0, 150, 0, 30)
    authorLabel.Position = UDim2.new(0.317, 0, 0.32, 0)
    authorLabel.BackgroundTransparency = 1
    authorLabel.Font = Enum.Font.Kalam
    authorLabel.Text = "By Darling"
    authorLabel.TextSize = 28
    authorLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
    authorLabel.TextXAlignment = Enum.TextXAlignment.Left
    authorLabel.Parent = card1

    -- Key Time: "Key Time: 25 Hours Left"
    local keyTimeLabel = Instance.new("TextLabel")
    keyTimeLabel.Name = "KeyTimeLabel"
    keyTimeLabel.Size = UDim2.new(0, 230, 0, 24)
    keyTimeLabel.Position = UDim2.new(0.53, 0, 0.82, 0)
    keyTimeLabel.BackgroundTransparency = 1
    keyTimeLabel.Font = Enum.Font.Kalam
    keyTimeLabel.Text = "Key Time: 25 Hours Left"
    keyTimeLabel.TextSize = 24
    keyTimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyTimeLabel.TextXAlignment = Enum.TextXAlignment.Right
    keyTimeLabel.Parent = card1

    ----------------------------------------------------------------------------
    -- 2. CARD 2: CENTER STATS & AVATAR CARD
    ----------------------------------------------------------------------------
    local card2, bg2 = createCard("CenterStatsCard", 256, 2)

    -- Center Circular Avatar Box
    local centerAvatarBox = Instance.new("Frame")
    centerAvatarBox.Name = "CenterAvatarBox"
    centerAvatarBox.Size = UDim2.new(0, 155, 0, 150)
    centerAvatarBox.Position = UDim2.new(0.5, -77, 0.5, -75)
    centerAvatarBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    centerAvatarBox.BackgroundTransparency = 0
    centerAvatarBox.BorderSizePixel = 0
    centerAvatarBox.Parent = card2

    local cAvCorner = Instance.new("UICorner")
    cAvCorner.CornerRadius = UDim.new(0.7, 0)
    cAvCorner.Parent = centerAvatarBox

    local centerAvatarImg = Instance.new("ImageLabel")
    centerAvatarImg.Name = "CenterAvatarImage"
    centerAvatarImg.Size = UDim2.new(1, 0, 1, 0)
    centerAvatarImg.BackgroundTransparency = 0
    centerAvatarImg.Image = "rbxassetid://10039618734"
    centerAvatarImg.ScaleType = Enum.ScaleType.Stretch
    centerAvatarImg.Parent = centerAvatarBox

    local cImgCorner = Instance.new("UICorner")
    cImgCorner.CornerRadius = UDim.new(0.7, 0)
    cImgCorner.Parent = centerAvatarImg

    -- Left Stats Labels
    local function createStatLabel(name, text, yPos, isLeft)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(0, 160, 0, 28)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Kalam
        lbl.Text = text
        lbl.TextSize = 25
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.TextXAlignment = isLeft and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left

        if isLeft then
            lbl.Position = UDim2.new(0.5, -95 - 160, yPos, 0)
        else
            lbl.Position = UDim2.new(0.5, 95, yPos, 0)
        end
        lbl.Parent = card2
        return lbl
    end

    local statDarling = createStatLabel("StatDarling", "- Darling", 0.08, true)
    local statGame = createStatLabel("StatGame", "- Blox Fruits", 0.32, true)
    local statBounty = createStatLabel("StatBounty", "- Bounty 30M", 0.56, true)
    local statLevel = createStatLabel("StatLevel", "- Level 2800", 0.80, true)

    -- Right Stats Labels
    local statClock = createStatLabel("StatClock", "- 2:39", 0.08, false)
    local statPing = createStatLabel("StatPing", "- 70ms", 0.32, false)
    local statFps = createStatLabel("StatFps", "- 60Fps", 0.56, false)
    local statServerTime = createStatLabel("StatServerTime", "- 14:40", 0.80, false)

    -- Hook dynamic real-time stats updates from StatsService
    StatsService.bind(function(snap)
        statDarling.Text = snap.PlayerStr
        statGame.Text = snap.GameStr
        statBounty.Text = snap.BountyStr
        statLevel.Text = snap.LevelStr
        statClock.Text = snap.SessionTimeStr
        statPing.Text = snap.PingStr
        statFps.Text = snap.FpsStr
        statServerTime.Text = snap.TimeStr
        keyTimeLabel.Text = snap.KeyTimeStr
    end, 0.4)

    ----------------------------------------------------------------------------
    -- 3. CARD 3: BOTTOM MUSIC VISUALIZER CARD (IN WHITE)
    ----------------------------------------------------------------------------
    local card3, bg3 = createCard("BottomMusicCard", 117, 3)
    MusicVisualizer.create(card3, MusicEngine, Utils, AssetManager)

    return {
        ScrollFrame = homeScroll,
        TopCard = card1,
        CenterCard = card2,
        BottomCard = card3
    }
end

return HomeView
