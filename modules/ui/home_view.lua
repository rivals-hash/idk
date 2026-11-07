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

    -- Title: "Monody - Premium" (Unificado para que quede pegado correctamente)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -125, 0, 32)
    titleLabel.Position = UDim2.new(0, 112, 0, 14)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.Kalam
    titleLabel.Text = "Monody - Premium"
    titleLabel.TextSize = 28
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = card1

    -- Subtitle: "By Darling"
    local authorLabel = Instance.new("TextLabel")
    authorLabel.Name = "AuthorLabel"
    authorLabel.Size = UDim2.new(0, 140, 0, 24)
    authorLabel.Position = UDim2.new(0, 112, 0, 48)
    authorLabel.BackgroundTransparency = 1
    authorLabel.Font = Enum.Font.Kalam
    authorLabel.Text = "By Darling"
    authorLabel.TextSize = 20
    authorLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
    authorLabel.TextXAlignment = Enum.TextXAlignment.Left
    authorLabel.Parent = card1

    -- Key Time: "Key Time: 25 Hours Left"
    local keyTimeLabel = Instance.new("TextLabel")
    keyTimeLabel.Name = "KeyTimeLabel"
    keyTimeLabel.Size = UDim2.new(0, 200, 0, 22)
    keyTimeLabel.Position = UDim2.new(1, -14, 1, -26)
    keyTimeLabel.AnchorPoint = Vector2.new(1, 0)
    keyTimeLabel.BackgroundTransparency = 1
    keyTimeLabel.Font = Enum.Font.Kalam
    keyTimeLabel.Text = "Key Time: 25 Hours Left"
    keyTimeLabel.TextSize = 17
    keyTimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
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

    -- Left & Right Stats Labels
    local function createStatLabel(name, text, yPos, isLeft)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(0, 130, 0, 26)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Kalam
        lbl.Text = text
        lbl.TextSize = 18
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.TextXAlignment = isLeft and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left

        if isLeft then
            lbl.Position = UDim2.new(0.5, -60 - 130, 0, yPos)
        else
            lbl.Position = UDim2.new(0.5, 60, 0, yPos)
        end
        lbl.Parent = card2
        return lbl
    end

    local statDarling = createStatLabel("StatDarling", "- ???", 10, true)
    local statGame = createStatLabel("StatGame", "- ???", 46, true)
    local statBounty = createStatLabel("StatBounty", "- ???", 82, true)
    local statLevel = createStatLabel("StatLevel", "- ???", 118, true)

    -- Right Stats Labels
    local statClock = createStatLabel("StatClock", "- 0:00", 10, false)
    local statPing = createStatLabel("StatPing", "- 60ms", 46, false)
    local statFps = createStatLabel("StatFps", "- 60Fps", 82, false)
    local statServerTime = createStatLabel("StatServerTime", "- 00:00", 118, false)

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
