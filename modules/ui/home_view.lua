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
        frame.Size = UDim2.new(0, 406, 0, height)
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
    local card1, bg1 = createCard("TopBrandCard", 136, 1)

    -- Left Avatar Box
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Name = "AvatarBox"
    avatarFrame.Size = UDim2.new(0, 84, 0, 84)
    avatarFrame.Position = UDim2.new(0, 14, 0, 10)
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
    avatarImg.Size = UDim2.new(0, 78, 0, 78)
    avatarImg.Position = UDim2.new(0.5, -39, 0.5, -39)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = avatarAsset
    avatarImg.ScaleType = Enum.ScaleType.Crop
    avatarImg.Parent = avatarFrame

    local imgCorner = Instance.new("UICorner")
    imgCorner.CornerRadius = UDim.new(0, 7)
    imgCorner.Parent = avatarImg

    -- Socials Buttons under Avatar (Inside Card 1)
    local discordBtn = Instance.new("ImageButton")
    discordBtn.Name = "DiscordButton"
    discordBtn.Size = UDim2.new(0, 30, 0, 30)
    discordBtn.Position = UDim2.new(0, 14, 0, 98)
    discordBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    discordBtn.BackgroundTransparency = 0.2
    discordBtn.Image = discordAsset
    discordBtn.AutoButtonColor = false
    discordBtn.Parent = card1

    local dCorner = Instance.new("UICorner")
    dCorner.CornerRadius = UDim.new(0, 6)
    dCorner.Parent = discordBtn

    discordBtn.MouseButton1Click:Connect(function()
        local discordLink = "https://discord.gg/besthub"
        Utils.setClipboard(discordLink)
        Utils.toast("Monody", "Discord link copied to clipboard!", 2.5, discordAsset)
    end)

    local tiktokBtn = Instance.new("ImageButton")
    tiktokBtn.Name = "TikTokButton"
    tiktokBtn.Size = UDim2.new(0, 30, 0, 30)
    tiktokBtn.Position = UDim2.new(0, 50, 0, 98)
    tiktokBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    tiktokBtn.BackgroundTransparency = 0.2
    tiktokBtn.Image = tiktokAsset
    tiktokBtn.AutoButtonColor = false
    tiktokBtn.Parent = card1

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 6)
    tCorner.Parent = tiktokBtn

    tiktokBtn.MouseButton1Click:Connect(function()
        local tiktokLink = "https://www.tiktok.com/@besthub"
        Utils.setClipboard(tiktokLink)
        Utils.toast("Monody", "TikTok link copied to clipboard!", 2.5, tiktokAsset)
    end)

    local function setupHoverSocial(btn)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), { Size = UDim2.new(0, 32, 0, 32) }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), { Size = UDim2.new(0, 30, 0, 30) }):Play()
        end)
    end
    setupHoverSocial(discordBtn)
    setupHoverSocial(tiktokBtn)

    -- Title: "Monody" in clean GothamBold
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0, 92, 0, 26)
    titleLabel.Position = UDim2.new(0, 126, 0, 14)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "Monody"
    titleLabel.TextSize = 22
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = card1

    -- Distinct Premium Badge (Vibrant Golden-Amber)
    local premBadge = Instance.new("Frame")
    premBadge.Name = "PremiumBadge"
    premBadge.Size = UDim2.new(0, 66, 0, 18)
    premBadge.Position = UDim2.new(0, 222, 0, 18)
    premBadge.BackgroundColor3 = Color3.fromRGB(255, 190, 40)
    premBadge.BorderSizePixel = 0
    premBadge.Parent = card1

    local premCorner = Instance.new("UICorner")
    premCorner.CornerRadius = UDim.new(0, 4)
    premCorner.Parent = premBadge

    local premText = Instance.new("TextLabel")
    premText.Name = "PremText"
    premText.Size = UDim2.new(1, 0, 1, 0)
    premText.BackgroundTransparency = 1
    premText.Font = Enum.Font.GothamBold
    premText.Text = "PREMIUM"
    premText.TextSize = 9
    premText.TextColor3 = Color3.fromRGB(24, 24, 30)
    premText.Parent = premBadge

    -- Subtitle: "By Darling" (Moved higher and more to the right)
    local authorLabel = Instance.new("TextLabel")
    authorLabel.Name = "AuthorLabel"
    authorLabel.Size = UDim2.new(0, 140, 0, 20)
    authorLabel.Position = UDim2.new(0, 134, 0, 42)
    authorLabel.BackgroundTransparency = 1
    authorLabel.Font = Enum.Font.GothamMedium
    authorLabel.Text = "By Darling"
    authorLabel.TextSize = 13
    authorLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    authorLabel.TextXAlignment = Enum.TextXAlignment.Left
    authorLabel.Parent = card1

    -- Key Time: "Key Time: 25 Hours Left"
    local keyTimeLabel = Instance.new("TextLabel")
    keyTimeLabel.Name = "KeyTimeLabel"
    keyTimeLabel.Size = UDim2.new(0, 200, 0, 20)
    keyTimeLabel.Position = UDim2.new(1, -14, 1, -24)
    keyTimeLabel.AnchorPoint = Vector2.new(1, 0)
    keyTimeLabel.BackgroundTransparency = 1
    keyTimeLabel.Font = Enum.Font.GothamMedium
    keyTimeLabel.Text = "Key Time: 25 Hours Left"
    keyTimeLabel.TextSize = 12
    keyTimeLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
    keyTimeLabel.TextXAlignment = Enum.TextXAlignment.Right
    keyTimeLabel.Parent = card1

    ----------------------------------------------------------------------------
    -- 2. CARD 2: CENTER STATS & AVATAR CARD
    ----------------------------------------------------------------------------
    local card2, bg2 = createCard("CenterStatsCard", 168, 2)

    -- Center Circular Avatar Box
    local centerAvatarBox = Instance.new("Frame")
    centerAvatarBox.Name = "CenterAvatarBox"
    centerAvatarBox.Size = UDim2.new(0, 106, 0, 106)
    centerAvatarBox.Position = UDim2.new(0.5, -53, 0.5, -53)
    centerAvatarBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    centerAvatarBox.BackgroundTransparency = 0
    centerAvatarBox.BorderSizePixel = 0
    centerAvatarBox.Parent = card2

    local cAvCorner = Instance.new("UICorner")
    cAvCorner.CornerRadius = UDim.new(1, 0)
    cAvCorner.Parent = centerAvatarBox

    local centerAvatarImg = Instance.new("ImageLabel")
    centerAvatarImg.Name = "CenterAvatarImage"
    centerAvatarImg.Size = UDim2.new(1, 0, 1, 0)
    centerAvatarImg.BackgroundTransparency = 0
    centerAvatarImg.Image = "rbxassetid://10039618734"
    centerAvatarImg.ScaleType = Enum.ScaleType.Stretch
    centerAvatarImg.Parent = centerAvatarBox

    local cImgCorner = Instance.new("UICorner")
    cImgCorner.CornerRadius = UDim.new(1, 0)
    cImgCorner.Parent = centerAvatarImg

    -- Left & Right Stats Labels (Separated from avatar to utilize outer card space)
    local function createStatLabel(name, text, yPos, isLeft)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(0, 115, 0, 24)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.Text = text
        lbl.TextSize = 12
        lbl.TextColor3 = Color3.fromRGB(245, 245, 250)
        lbl.TextXAlignment = isLeft and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right

        if isLeft then
            lbl.Position = UDim2.new(0, 16, 0, yPos)
        else
            lbl.Position = UDim2.new(1, -16 - 115, 0, yPos)
        end
        lbl.Parent = card2
        return lbl
    end

    local statDarling = createStatLabel("StatDarling", "- ???", 12, true)
    local statGame = createStatLabel("StatGame", "- ???", 46, true)
    local statBounty = createStatLabel("StatBounty", "- ???", 80, true)
    local statLevel = createStatLabel("StatLevel", "- ???", 114, true)

    -- Right Stats Labels
    local statClock = createStatLabel("StatClock", "- 0:00", 12, false)
    local statPing = createStatLabel("StatPing", "- 60ms", 46, false)
    local statFps = createStatLabel("StatFps", "- 60Fps", 80, false)
    local statServerTime = createStatLabel("StatServerTime", "- 00:00", 114, false)

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
    local card3, bg3 = createCard("BottomMusicCard", 78, 3)
    MusicVisualizer.create(card3, MusicEngine, Utils, AssetManager)

    return {
        ScrollFrame = homeScroll,
        TopCard = card1,
        CenterCard = card2,
        BottomCard = card3
    }
end

return HomeView
