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

    -- Card 1 has its complete artwork in header_profile_panel.png:
    -- Anime girl with headphones, glowing avatar box, title "Monody - Premium" 👑, "By Darling",
    -- Discord/TikTok/Premium badges, and "Key Time: 25 Hours Left".
    -- To prevent visual double-rendering (ghost text), we bind invisible click hitboxes
    -- for the interactive Discord and TikTok buttons over their exact pixel coordinates.
    local discordHitbox = Instance.new("TextButton")
    discordHitbox.Name = "DiscordHitbox"
    discordHitbox.Size = UDim2.new(0, 26, 0, 26)
    discordHitbox.Position = UDim2.new(0, 14, 0, 92)
    discordHitbox.BackgroundTransparency = 1
    discordHitbox.Text = ""
    discordHitbox.Active = true
    discordHitbox.ZIndex = 10
    discordHitbox.Parent = card1

    discordHitbox.MouseButton1Click:Connect(function()
        local discordLink = "https://discord.gg/besthub"
        Utils.setClipboard(discordLink)
        Utils.toast("Monody", "Discord link copied to clipboard!", 2.0, discordAsset)
    end)

    local tiktokHitbox = Instance.new("TextButton")
    tiktokHitbox.Name = "TikTokHitbox"
    tiktokHitbox.Size = UDim2.new(0, 26, 0, 26)
    tiktokHitbox.Position = UDim2.new(0, 42, 0, 92)
    tiktokHitbox.BackgroundTransparency = 1
    tiktokHitbox.Text = ""
    tiktokHitbox.Active = true
    tiktokHitbox.ZIndex = 10
    tiktokHitbox.Parent = card1

    tiktokHitbox.MouseButton1Click:Connect(function()
        local tiktokLink = "https://www.tiktok.com/@besthub"
        Utils.setClipboard(tiktokLink)
        Utils.toast("Monody", "TikTok link copied to clipboard!", 2.0, tiktokAsset)
    end)

    ----------------------------------------------------------------------------
    -- 2. CARD 2: STATS CARD (stats_panel.png)
    ----------------------------------------------------------------------------
    local card2, bg2 = createCard("CenterStatsCard", 154, 2, statsBgAsset)

    -- The center circle and anime girl are already baked into stats_panel.png.
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
    local statDarling = createStatRow("StatDarling", "👤", "- ???", 14, true)
    local statGame = createStatRow("StatGame", "🎮", "- ???", 46, true)
    local statBounty = createStatRow("StatBounty", "⚔️", "- ???", 78, true)
    local statLevel = createStatRow("StatLevel", "📊", "- ???", 110, true)

    -- Right 4 stats (Session, Ping, FPS, Clock)
    local statClock = createStatRow("StatClock", "▶️", "- 0:00", 14, false)
    local statPing = createStatRow("StatPing", "📶", "- 60ms", 46, false)
    local statFps = createStatRow("StatFps", "🖥️", "- 60Fps", 78, false)
    local statServerTime = createStatRow("StatServerTime", "🕒", "- 00:00", 110, false)

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
    end, 0.4)

    ----------------------------------------------------------------------------
    -- 3. CARD 3: BOTTOM MUSIC VISUALIZER CARD
    ----------------------------------------------------------------------------
    -- Clean dark card container to allow MusicVisualizer to animate without static image ghosting
    local card3, bg3 = createCard("BottomMusicCard", 78, 3, nil)
    if bg3 then bg3.ImageTransparency = 1 end
    MusicVisualizer.create(card3, MusicEngine, Utils, AssetManager)

    return {
        ScrollFrame = homeScroll,
        TopCard = card1,
        CenterCard = card2,
        BottomCard = card3
    }
end

return HomeView
