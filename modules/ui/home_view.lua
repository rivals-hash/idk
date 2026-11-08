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

    local headerBgAsset = (AssetManager and AssetManager.get("header_profile_panel.png")) or ""
    local statsBgAsset = (AssetManager and AssetManager.get("stats_panel_v2.png")) or ""
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
    local function createCard(name, height, layoutOrder, customBg)
        local frame = Instance.new("Frame")
        frame.Name = name
        frame.Size = UDim2.new(0, 406, 0, height)
        frame.LayoutOrder = layoutOrder
        frame.BackgroundColor3 = Color3.fromRGB(18, 14, 26)
        frame.BackgroundTransparency = 0.08
        frame.BorderSizePixel = 0
        frame.Parent = homeScroll

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame

        local bg = nil
        if customBg and #customBg > 0 then
            bg = Instance.new("ImageLabel")
            bg.Name = "Bg"
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundTransparency = 1
            bg.Image = customBg
            bg.ScaleType = Enum.ScaleType.Stretch
            bg.Parent = frame

            local bgCorner = Instance.new("UICorner")
            bgCorner.CornerRadius = UDim.new(0, 10)
            bgCorner.Parent = bg
        end

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(195, 125, 255)
        stroke.Thickness = 1.6
        stroke.Transparency = 0.15
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
    -- 2. CARD 2: REAL LIVE STATS CARD WITH AUTHENTIC NEON STATS_PANEL.PNG
    ----------------------------------------------------------------------------
    -- Card 2 renders stats_panel.png with its glowing purple neon crown, glowing ring,
    -- neon corner swooshes, and glowing icons, with clean dynamic live stats.
    local card2, bg2 = createCard("CenterStatsCard", 146, 2, statsBgAsset)

    -- Helper for Left & Right Stats Rows (aligned with glowing icons in stats_panel.png)
    local function createStatRow(name, text, yPos, xPos, width)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(0, width, 0, 20)
        lbl.Position = UDim2.new(0, xPos, 0, yPos)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.Text = text
        lbl.TextSize = 11.5
        lbl.TextColor3 = Color3.fromRGB(245, 240, 255)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 7
        lbl.Parent = card2

        return lbl
    end

    -- Left 4 stats (Player, Game, Bounty, Level) - aligned to icons at x=68
    local statDarling = createStatRow("StatDarling", "- Loading...", 22, 72, 100)
    local statGame = createStatRow("StatGame", "- Blox Fruits", 51, 72, 100)
    local statBounty = createStatRow("StatBounty", "- Bounty 4M", 83, 72, 100)
    local statLevel = createStatRow("StatLevel", "- Level 2800", 115, 72, 100)

    -- Right 4 stats (Session, Ping, FPS, Clock) - aligned to icons at x=316
    local statClock = createStatRow("StatClock", "- 0:00", 22, 320, 75)
    local statPing = createStatRow("StatPing", "- 50ms", 51, 320, 75)
    local statFps = createStatRow("StatFps", "- 60Fps", 83, 320, 75)
    local statServerTime = createStatRow("StatServerTime", "- 00:00", 115, 320, 75)

    -- Hook dynamic real-time stats updates from StatsService
    if StatsService and StatsService.bind then
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
    end

    ----------------------------------------------------------------------------
    -- 3. CARD 3: BOTTOM MUSIC PLAYER CARD (music_player.png)
    ----------------------------------------------------------------------------
    -- Card 3 renders the pristine artwork from music_player.png:
    -- Glowing album art, song title 'MONTAGEM BAILÃO (Phonk)', spectrum waveform,
    -- timeline scrubber, and playback buttons.
    local musicBgAsset = (AssetManager and AssetManager.get("music_player.png")) or ""
    local card3, bg3 = createCard("BottomMusicCard", 78, 3, musicBgAsset)

    -- Bind images safely to ensure they are never blank or grey
    if AssetManager and AssetManager.bindImage then
        if bg1 then AssetManager.bindImage(bg1, "header_profile_panel.png") end
        if bg2 then AssetManager.bindImage(bg2, "stats_panel_v2.png") end
        if bg3 then AssetManager.bindImage(bg3, "music_player.png") end
    end

    -- Interactive Play/Pause Hitbox positioned right over the play button in music_player.png
    local playHitbox = Instance.new("TextButton")
    playHitbox.Name = "PlayPauseHitbox"
    playHitbox.Size = UDim2.new(0, 36, 0, 36)
    playHitbox.Position = UDim2.new(0.5, 42, 0.5, -2)
    playHitbox.AnchorPoint = Vector2.new(0.5, 0.5)
    playHitbox.BackgroundTransparency = 1
    playHitbox.Text = ""
    playHitbox.Active = true
    playHitbox.ZIndex = 10
    playHitbox.Parent = card3

    local isPlaying = false
    playHitbox.MouseButton1Click:Connect(function()
        isPlaying = not isPlaying
        if MusicEngine then
            pcall(function()
                if isPlaying then
                    if MusicEngine.Play then MusicEngine:Play() end
                else
                    if MusicEngine.Pause then MusicEngine:Pause() end
                end
            end)
        end
        if Utils then
            Utils.toast("Monody Music", isPlaying and "Playing: MONTAGEM BAILÃO" or "Music Paused", 1.5)
        end
    end)

    return {
        ScrollFrame = homeScroll,
        TopCard = card1,
        CenterCard = card2,
        BottomCard = card3
    }
end

return HomeView
