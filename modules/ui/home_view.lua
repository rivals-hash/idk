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

    local headerBgAsset = (AssetManager and AssetManager.get("header_profile_panel.png", "rbxassetid://139820186687064")) or "rbxassetid://139820186687064"
    local statsBgAsset = (AssetManager and AssetManager.get("stats_panel.png", "rbxassetid://139820186687064")) or "rbxassetid://139820186687064"
    local headerAvatarAsset = (AssetManager and AssetManager.get("header_avatar.png", "rbxassetid://93891873418133")) or "rbxassetid://93891873418133"
    local statsAvatarAsset = (AssetManager and AssetManager.get("stats_center_avatar.png", "rbxassetid://10039618734")) or "rbxassetid://10039618734"
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
    local function createCard(name, height, layoutOrder, customBg)
        local frame = Instance.new("Frame")
        frame.Name = name
        frame.Size = UDim2.new(0, 406, 0, height)
        frame.LayoutOrder = layoutOrder
        frame.BackgroundColor3 = Color3.fromRGB(16, 12, 24)
        frame.BackgroundTransparency = 0.1
        frame.BorderSizePixel = 0
        frame.Parent = homeScroll

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame

        local bg = Instance.new("ImageLabel")
        bg.Name = "Bg"
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundTransparency = 0
        bg.Image = customBg or headerBgAsset
        bg.ScaleType = Enum.ScaleType.Stretch
        bg.Parent = frame

        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 10)
        bgCorner.Parent = bg

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(145, 90, 225)
        stroke.Thickness = 1.2
        stroke.Transparency = 0.35
        stroke.Parent = frame

        return frame, bg
    end

    ----------------------------------------------------------------------------
    -- 1. CARD 1: TOP PROFILE & BRAND CARD (header_profile_panel.png)
    ----------------------------------------------------------------------------
    local card1, bg1 = createCard("TopBrandCard", 126, 1, headerBgAsset)

    -- Left Avatar Box with Purple Neon Glow
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Name = "AvatarBox"
    avatarFrame.Size = UDim2.new(0, 72, 0, 72)
    avatarFrame.Position = UDim2.new(0, 14, 0, 10)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
    avatarFrame.BackgroundTransparency = 0
    avatarFrame.BorderSizePixel = 0
    avatarFrame.Parent = card1

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 10)
    avatarCorner.Parent = avatarFrame

    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = Color3.fromRGB(180, 115, 255)
    avatarStroke.Thickness = 1.8
    avatarStroke.Transparency = 0.2
    avatarStroke.Parent = avatarFrame

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "AvatarImage"
    avatarImg.Size = UDim2.new(1, -6, 1, -6)
    avatarImg.Position = UDim2.new(0, 3, 0, 3)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = headerAvatarAsset
    avatarImg.ScaleType = Enum.ScaleType.Crop
    avatarImg.Parent = avatarFrame

    local imgCorner = Instance.new("UICorner")
    imgCorner.CornerRadius = UDim.new(0, 8)
    imgCorner.Parent = avatarImg

    -- Socials & Premium Buttons under Avatar
    local discordBtn = Instance.new("ImageButton")
    discordBtn.Name = "DiscordButton"
    discordBtn.Size = UDim2.new(0, 24, 0, 24)
    discordBtn.Position = UDim2.new(0, 14, 0, 90)
    discordBtn.BackgroundColor3 = Color3.fromRGB(24, 20, 34)
    discordBtn.BackgroundTransparency = 0.2
    discordBtn.Image = discordAsset
    discordBtn.AutoButtonColor = false
    discordBtn.Parent = card1

    local dCorner = Instance.new("UICorner")
    dCorner.CornerRadius = UDim.new(0, 6)
    dCorner.Parent = discordBtn

    local dStroke = Instance.new("UIStroke")
    dStroke.Color = Color3.fromRGB(90, 65, 130)
    dStroke.Thickness = 1
    dStroke.Parent = discordBtn

    discordBtn.MouseButton1Click:Connect(function()
        local discordLink = "https://discord.gg/besthub"
        Utils.setClipboard(discordLink)
        Utils.toast("Monody", "Discord link copied to clipboard!", 2.0, discordAsset)
    end)

    local tiktokBtn = Instance.new("ImageButton")
    tiktokBtn.Name = "TikTokButton"
    tiktokBtn.Size = UDim2.new(0, 24, 0, 24)
    tiktokBtn.Position = UDim2.new(0, 42, 0, 90)
    tiktokBtn.BackgroundColor3 = Color3.fromRGB(24, 20, 34)
    tiktokBtn.BackgroundTransparency = 0.2
    tiktokBtn.Image = tiktokAsset
    tiktokBtn.AutoButtonColor = false
    tiktokBtn.Parent = card1

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 6)
    tCorner.Parent = tiktokBtn

    local tStroke = Instance.new("UIStroke")
    tStroke.Color = Color3.fromRGB(90, 65, 130)
    tStroke.Thickness = 1
    tStroke.Parent = tiktokBtn

    tiktokBtn.MouseButton1Click:Connect(function()
        local tiktokLink = "https://www.tiktok.com/@besthub"
        Utils.setClipboard(tiktokLink)
        Utils.toast("Monody", "TikTok link copied to clipboard!", 2.0, tiktokAsset)
    end)

    -- Pill Button: "Premium" under avatar
    local premPill = Instance.new("Frame")
    premPill.Name = "PremiumPill"
    premPill.Size = UDim2.new(0, 68, 0, 24)
    premPill.Position = UDim2.new(0, 70, 0, 90)
    premPill.BackgroundColor3 = Color3.fromRGB(115, 55, 185)
    premPill.BackgroundTransparency = 0.15
    premPill.BorderSizePixel = 0
    premPill.Parent = card1

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(1, 0)
    pCorner.Parent = premPill

    local pStroke = Instance.new("UIStroke")
    pStroke.Color = Color3.fromRGB(195, 125, 255)
    pStroke.Thickness = 1.2
    pStroke.Transparency = 0.2
    pStroke.Parent = premPill

    local premLabel = Instance.new("TextLabel")
    premLabel.Name = "PremLabel"
    premLabel.Size = UDim2.new(1, 0, 1, 0)
    premLabel.BackgroundTransparency = 1
    premLabel.Font = Enum.Font.GothamBold
    premLabel.Text = "Premium"
    premLabel.TextSize = 10.5
    premLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    premLabel.Parent = premPill

    -- Title: "Monody - Premium" with Crown Icon
    local titleContainer = Instance.new("Frame")
    titleContainer.Name = "TitleContainer"
    titleContainer.Size = UDim2.new(0, 240, 0, 26)
    titleContainer.Position = UDim2.new(0, 98, 0, 14)
    titleContainer.BackgroundTransparency = 1
    titleContainer.Parent = card1

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0, 160, 1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "Monody - Premium"
    titleLabel.TextSize = 17
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleContainer

    local crownIcon = Instance.new("TextLabel")
    crownIcon.Name = "CrownIcon"
    crownIcon.Size = UDim2.new(0, 22, 1, 0)
    crownIcon.Position = UDim2.new(0, 162, 0, -1)
    crownIcon.BackgroundTransparency = 1
    crownIcon.Font = Enum.Font.GothamBold
    crownIcon.Text = "👑"
    crownIcon.TextSize = 15
    crownIcon.TextColor3 = Color3.fromRGB(215, 160, 255)
    crownIcon.Parent = titleContainer

    -- Subtitle: "By Darling" in pink/lavender
    local authorLabel = Instance.new("TextLabel")
    authorLabel.Name = "AuthorLabel"
    authorLabel.Size = UDim2.new(0, 140, 0, 18)
    authorLabel.Position = UDim2.new(0, 98, 0, 40)
    authorLabel.BackgroundTransparency = 1
    authorLabel.Font = Enum.Font.GothamMedium
    authorLabel.Text = "By Darling"
    authorLabel.TextSize = 12
    authorLabel.TextColor3 = Color3.fromRGB(220, 150, 245)
    authorLabel.TextXAlignment = Enum.TextXAlignment.Left
    authorLabel.Parent = card1

    -- Key Time: "Key Time: 25 Hours Left" with clock icon
    local keyTimeLabel = Instance.new("TextLabel")
    keyTimeLabel.Name = "KeyTimeLabel"
    keyTimeLabel.Size = UDim2.new(0, 180, 0, 18)
    keyTimeLabel.Position = UDim2.new(1, -12, 1, -22)
    keyTimeLabel.AnchorPoint = Vector2.new(1, 0)
    keyTimeLabel.BackgroundTransparency = 1
    keyTimeLabel.Font = Enum.Font.GothamMedium
    keyTimeLabel.Text = "⏱ Key Time: 25 Hours Left"
    keyTimeLabel.TextSize = 11
    keyTimeLabel.TextColor3 = Color3.fromRGB(240, 235, 250)
    keyTimeLabel.TextXAlignment = Enum.TextXAlignment.Right
    keyTimeLabel.Parent = card1

    ----------------------------------------------------------------------------
    -- 2. CARD 2: STATS CARD (stats_panel.png)
    ----------------------------------------------------------------------------
    local card2, bg2 = createCard("CenterStatsCard", 154, 2, statsBgAsset)

    -- Center Circular Avatar Box with Glowing Purple Neon Ring & Crown
    local centerAvatarBox = Instance.new("Frame")
    centerAvatarBox.Name = "CenterAvatarBox"
    centerAvatarBox.Size = UDim2.new(0, 98, 0, 98)
    centerAvatarBox.Position = UDim2.new(0.5, -49, 0.5, -45)
    centerAvatarBox.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
    centerAvatarBox.BackgroundTransparency = 0
    centerAvatarBox.BorderSizePixel = 0
    centerAvatarBox.Parent = card2

    local cAvCorner = Instance.new("UICorner")
    cAvCorner.CornerRadius = UDim.new(1, 0)
    cAvCorner.Parent = centerAvatarBox

    local cAvStroke = Instance.new("UIStroke")
    cAvStroke.Color = Color3.fromRGB(180, 115, 255)
    cAvStroke.Thickness = 2.2
    cAvStroke.Transparency = 0.15
    cAvStroke.Parent = centerAvatarBox

    local centerAvatarImg = Instance.new("ImageLabel")
    centerAvatarImg.Name = "CenterAvatarImage"
    centerAvatarImg.Size = UDim2.new(1, -4, 1, -4)
    centerAvatarImg.Position = UDim2.new(0, 2, 0, 2)
    centerAvatarImg.BackgroundTransparency = 1
    centerAvatarImg.Image = statsAvatarAsset
    centerAvatarImg.ScaleType = Enum.ScaleType.Crop
    centerAvatarImg.Parent = centerAvatarBox

    local cImgCorner = Instance.new("UICorner")
    cImgCorner.CornerRadius = UDim.new(1, 0)
    cImgCorner.Parent = centerAvatarImg

    -- Crown floating on top of avatar
    local centerCrown = Instance.new("TextLabel")
    centerCrown.Name = "CenterCrown"
    centerCrown.Size = UDim2.new(0, 20, 0, 20)
    centerCrown.Position = UDim2.new(0.5, -10, 0, -14)
    centerCrown.BackgroundTransparency = 1
    centerCrown.Font = Enum.Font.GothamBold
    centerCrown.Text = "👑"
    centerCrown.TextSize = 14
    centerCrown.TextColor3 = Color3.fromRGB(225, 175, 255)
    centerCrown.Parent = centerAvatarBox

    -- Left & Right Stats Labels with subtle icons matching reference
    local function createStatRow(name, iconText, text, yPos, isLeft)
        local row = Instance.new("Frame")
        row.Name = name
        row.Size = UDim2.new(0, 126, 0, 22)
        row.BackgroundTransparency = 1
        if isLeft then
            row.Position = UDim2.new(0.5, -60 - 126, 0, yPos)
        else
            row.Position = UDim2.new(0.5, 60, 0, yPos)
        end
        row.Parent = card2

        local icon = Instance.new("TextLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 18, 1, 0)
        icon.Position = isLeft and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
        icon.BackgroundTransparency = 1
        icon.Font = Enum.Font.GothamMedium
        icon.Text = iconText
        icon.TextSize = 11.5
        icon.TextColor3 = Color3.fromRGB(215, 175, 255)
        icon.TextXAlignment = Enum.TextXAlignment.Center
        icon.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Name = "Label"
        lbl.Size = UDim2.new(1, -22, 1, 0)
        lbl.Position = UDim2.new(0, 22, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.Text = text
        lbl.TextSize = 11.5
        lbl.TextColor3 = Color3.fromRGB(240, 235, 250)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        return lbl
    end

    -- Left 4 stats (Player, Game, Bounty, Level)
    local statDarling = createStatRow("StatDarling", "👤", "- ???", 12, true)
    local statGame = createStatRow("StatGame", "🎮", "- ???", 44, true)
    local statBounty = createStatRow("StatBounty", "⚔️", "- ???", 76, true)
    local statLevel = createStatRow("StatLevel", "📊", "- ???", 108, true)

    -- Right 4 stats (Session, Ping, FPS, Clock)
    local statClock = createStatRow("StatClock", "▶️", "- 0:00", 12, false)
    local statPing = createStatRow("StatPing", "📶", "- 60ms", 44, false)
    local statFps = createStatRow("StatFps", "🖥️", "- 60Fps", 76, false)
    local statServerTime = createStatRow("StatServerTime", "🕒", "- 00:00", 108, false)

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
        keyTimeLabel.Text = "⏱ " .. snap.KeyTimeStr
    end, 0.4)

    ----------------------------------------------------------------------------
    -- 3. CARD 3: BOTTOM MUSIC VISUALIZER CARD (music_player.png)
    ----------------------------------------------------------------------------
    local card3, bg3 = createCard("BottomMusicCard", 78, 3, (AssetManager and AssetManager.get("music_player.png", "rbxassetid://139820186687064")) or "rbxassetid://139820186687064")
    MusicVisualizer.create(card3, MusicEngine, Utils, AssetManager)

    return {
        ScrollFrame = homeScroll,
        TopCard = card1,
        CenterCard = card2,
        BottomCard = card3
    }
end

return HomeView
