--[[
    Monody Premium - modules/ui/home_view.lua
    Pixel-perfect Home View aligned with reference screenshot (01_Home):
    - Card 1: Header profile panel with glowing avatar box, Discord/TikTok/Premium buttons,
              "Monody - Premium" title with crown icon, and Key Time.
    - Card 2: Center stats card with stats_panel.png, circular glowing center avatar,
              and symmetrical left/right live stats.
    - Card 3: Music player card with album art, animated visualizer bars, and controls.
]]

local HomeView = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

function HomeView.create(parentContainer, dependencies)
    local Utils = dependencies.Utils
    local StatsService = dependencies.StatsService
    local MusicEngine = dependencies.MusicEngine
    local MusicVisualizer = dependencies.MusicVisualizer
    local AssetManager = dependencies.AssetManager

    local headerBgAsset = (AssetManager and (AssetManager.get("header_profile_panel_red.png") or AssetManager.get("header_profile_panel.png"))) or ""
    local statsBgAsset = (AssetManager and (AssetManager.get("stats_panel_red.png") or AssetManager.get("stats_panel_v2.png"))) or ""
    local headerAvatarAsset = (AssetManager and AssetManager.get("header_avatar.png")) or ""
    local statsAvatarAsset = (AssetManager and AssetManager.get("stats_center_avatar.png")) or ""
    local discordAsset = "rbxassetid://16584754883"
    local tiktokAsset = "rbxassetid://84157643184125"

    local homeScroll = Instance.new("ScrollingFrame")
    homeScroll.Name = "HomeView"
    homeScroll.Size = UDim2.new(1, 0, 1, 0)
    homeScroll.BackgroundTransparency = 1
    homeScroll.BorderSizePixel = 0
    homeScroll.ScrollBarThickness = 0
    homeScroll.CanvasSize = UDim2.new(0, 0, 0, 398)
    homeScroll.Parent = parentContainer

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = homeScroll

    -- Helper to create card frame with texture and solid fallback
    local function createCard(name, height, layoutOrder)
        local frame = Instance.new("Frame")
        frame.Name = name
        frame.Size = UDim2.new(0, 474, 0, height)
        frame.LayoutOrder = layoutOrder
        frame.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Parent = homeScroll

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = frame

        local bg = Instance.new("ImageLabel")
        bg.Name = "Bg"
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
        bg.BackgroundTransparency = 0
        bg.BorderSizePixel = 0
        bg.Image = (AssetManager and AssetManager.get("card_bg.png")) or ""
        bg.ScaleType = Enum.ScaleType.Stretch
        bg.Parent = frame

        if AssetManager and AssetManager.bindImage then
            AssetManager.bindImage(bg, "card_bg.png")
        end

        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 12)
        bgCorner.Parent = bg

        return frame, bg
    end

    ----------------------------------------------------------------------------
    -- 1. CARD 1: TOP PROFILE & BRAND CARD (474px wide, clean native silk glass)
    ----------------------------------------------------------------------------
    local card1, bg1 = createCard("TopBrandCard", 100, 1)

    -- Left Avatar Box with clean white stroke (matching reference)
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Name = "AvatarFrame"
    avatarFrame.Size = UDim2.new(0, 68, 0, 68)
    avatarFrame.Position = UDim2.new(0, 16, 0.5, -34)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(24, 25, 34)
    avatarFrame.BorderSizePixel = 0
    avatarFrame.ZIndex = 4
    avatarFrame.Parent = card1

    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(0, 10)
    avCorner.Parent = avatarFrame

    local avStroke = Instance.new("UIStroke")
    avStroke.Color = Color3.fromRGB(255, 255, 255)
    avStroke.Thickness = 1.2
    avStroke.Transparency = 0.2
    avStroke.Parent = avatarFrame

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "AvatarImage"
    avatarImg.Size = UDim2.new(1, 0, 1, 0)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = (AssetManager and (AssetManager.get("header_avatar.png") or AssetManager.get("avatar.png"))) or ""
    avatarImg.ScaleType = Enum.ScaleType.Crop
    avatarImg.ZIndex = 5
    avatarImg.Parent = avatarFrame

    if AssetManager and AssetManager.bindImage then
        AssetManager.bindImage(avatarImg, "header_avatar.png", "avatar.png")
    end

    local avImgCorner = Instance.new("UICorner")
    avImgCorner.CornerRadius = UDim.new(0, 10)
    avImgCorner.Parent = avatarImg

    -- Brand Titles
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "BrandTitle"
    titleLbl.Size = UDim2.new(0, 240, 0, 24)
    titleLbl.Position = UDim2.new(0, 96, 0, 22)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = "Monody - Premium"
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize = 18
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 5
    titleLbl.Parent = card1

    local subLbl = Instance.new("TextLabel")
    subLbl.Name = "BrandSubtitle"
    subLbl.Size = UDim2.new(0, 240, 0, 18)
    subLbl.Position = UDim2.new(0, 96, 0, 48)
    subLbl.BackgroundTransparency = 1
    subLbl.Font = Enum.Font.GothamMedium
    subLbl.Text = "By Darling"
    subLbl.TextColor3 = Color3.fromRGB(200, 205, 220)
    subLbl.TextSize = 12.5
    subLbl.TextXAlignment = Enum.TextXAlignment.Left
    subLbl.ZIndex = 5
    subLbl.Parent = card1

    -- Social Buttons (Discord & TikTok)
    local socialFrame = Instance.new("Frame")
    socialFrame.Name = "SocialButtons"
    socialFrame.Size = UDim2.new(0, 60, 0, 24)
    socialFrame.Position = UDim2.new(0, 96, 0, 70)
    socialFrame.BackgroundTransparency = 1
    socialFrame.ZIndex = 5
    socialFrame.Parent = card1

    local function createSocialBtn(name, iconId, xPos, url, toastMsg)
        local btn = Instance.new("ImageButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 22, 0, 22)
        btn.Position = UDim2.new(0, xPos, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
        btn.BackgroundTransparency = 0.2
        btn.Image = iconId
        btn.ImageColor3 = Color3.fromRGB(255, 255, 255)
        btn.ScaleType = Enum.ScaleType.Fit
        btn.ZIndex = 6
        btn.Parent = socialFrame

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn

        btn.MouseButton1Click:Connect(function()
            if Utils and Utils.setClipboard then Utils.setClipboard(url) end
            if Utils and Utils.toast then Utils.toast("Monody", toastMsg, 1.5, iconId) end
        end)
        return btn
    end

    createSocialBtn("DiscordBtn", discordAsset, 0, "https://discord.gg/besthub", "Discord link copied!")
    createSocialBtn("TikTokBtn", tiktokAsset, 28, "https://www.tiktok.com/@besthub", "TikTok link copied!")

    -- Key Time Badge on Right (matching media_1794158198928.jpg)
    local keyTimeLbl = Instance.new("TextLabel")
    keyTimeLbl.Name = "KeyTimeBadge"
    keyTimeLbl.Size = UDim2.new(0, 160, 0, 20)
    keyTimeLbl.Position = UDim2.new(1, -170, 1, -26)
    keyTimeLbl.BackgroundTransparency = 1
    keyTimeLbl.Font = Enum.Font.GothamMedium
    keyTimeLbl.Text = "Key Time: 25 Hours Left"
    keyTimeLbl.TextColor3 = Color3.fromRGB(180, 185, 205)
    keyTimeLbl.TextSize = 11
    keyTimeLbl.TextXAlignment = Enum.TextXAlignment.Right
    keyTimeLbl.ZIndex = 5
    keyTimeLbl.Parent = card1

    ----------------------------------------------------------------------------
    -- 2. CARD 2: REAL LIVE STATS CARD (474px wide, Symmetrical stats & center avatar)
    ----------------------------------------------------------------------------
    local card2, bg2 = createCard("CenterStatsCard", 126, 2)

    -- Circular Avatar in Center (matching media_1794158198928.jpg)
    local centerAvatar = Instance.new("ImageLabel")
    centerAvatar.Name = "CenterAvatar"
    centerAvatar.Size = UDim2.new(0, 76, 0, 76)
    centerAvatar.Position = UDim2.new(0.5, -38, 0.5, -38)
    centerAvatar.BackgroundColor3 = Color3.fromRGB(24, 25, 34)
    centerAvatar.BorderSizePixel = 0
    centerAvatar.Image = (AssetManager and (AssetManager.get("stats_center_avatar.png") or AssetManager.get("avatar.png"))) or ""
    centerAvatar.ScaleType = Enum.ScaleType.Crop
    centerAvatar.ZIndex = 5
    centerAvatar.Parent = card2

    if AssetManager and AssetManager.bindImage then
        AssetManager.bindImage(centerAvatar, "stats_center_avatar.png", "avatar.png")
    end

    local caCorner = Instance.new("UICorner")
    caCorner.CornerRadius = UDim.new(1, 0)
    caCorner.Parent = centerAvatar

    local caStroke = Instance.new("UIStroke")
    caStroke.Color = Color3.fromRGB(255, 255, 255)
    caStroke.Thickness = 1.2
    caStroke.Transparency = 0.25
    caStroke.Parent = centerAvatar

    -- Helper for Left & Right Stats Rows
    local function createStatRow(name, text, yPos, xPos, width, align)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(0, width, 0, 20)
        lbl.Position = UDim2.new(0, xPos, 0, yPos)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.Text = text
        lbl.TextSize = 12
        lbl.TextColor3 = Color3.fromRGB(235, 240, 250)
        lbl.TextXAlignment = align or Enum.TextXAlignment.Left
        lbl.ZIndex = 5
        lbl.Parent = card2

        return lbl
    end

    -- Left 4 stats (Darling, Blox Fruits, Bounty, Level)
    local statDarling = createStatRow("StatDarling", "- Darling", 14, 24, 150)
    local statGame = createStatRow("StatGame", "- Blox Fruits", 39, 24, 150)
    local statBounty = createStatRow("StatBounty", "- Bounty 4M", 65, 24, 150)
    local statLevel = createStatRow("StatLevel", "- Level 2800", 91, 24, 150)

    -- Right 4 stats (Session, Ping, FPS, Server Clock)
    local statClock = createStatRow("StatClock", "- 0:18", 14, 305, 145)
    local statPing = createStatRow("StatPing", "- 233ms", 39, 305, 145)
    local statFps = createStatRow("StatFps", "- 49Fps", 65, 305, 145)
    local statServerTime = createStatRow("StatServerTime", "- 19:11", 91, 305, 145)

    -- Hook dynamic real-time stats updates from StatsService
    if StatsService and StatsService.bind then
        StatsService.bind(function(snap)
            statDarling.Text = snap.PlayerStr or "- Darling"
            statGame.Text = snap.GameStr or "- Blox Fruits"
            statBounty.Text = snap.BountyStr or "- Bounty 4M"
            statLevel.Text = snap.LevelStr or "- Level 2800"
            statClock.Text = "- " .. (snap.SessionTimeStr or "0:00")
            statPing.Text = "- " .. (snap.PingStr or "50ms")
            statFps.Text = "- " .. (snap.FpsStr or "60Fps")
            statServerTime.Text = "- " .. (snap.TimeStr or "00:00")
        end, 0.4)
    end

    ----------------------------------------------------------------------------
    -- 3. CARD 3: REAL INTERACTIVE MUSIC PLAYER (474px wide)
    ----------------------------------------------------------------------------
    local card3, bg3 = createCard("BottomMusicCard", 80, 3)

    -- Mount Real Native Interactive Music Player widget inside Card 3!
    if MusicVisualizer and MusicVisualizer.create then
        MusicVisualizer.create(card3, MusicEngine, Utils, AssetManager)
    end

    return {
        ScrollFrame = homeScroll,
        TopCard = card1,
        CenterCard = card2,
        BottomCard = card3
    }
end

return HomeView
