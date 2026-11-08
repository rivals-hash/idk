--[[
    Darling Hub - modules/ui/tabs/home.lua
    Home / Overview Tab for WindUI.
    Includes:
    - Live Player Profile, Blox Fruits Level & Bounty stats
    - Performance monitor (real FPS, real Ping, Session Timer)
    - Integrated Phonk Music Player controls (Play, Pause, Next, Prev, Volume, Track picker)
    - Community links & copy loadstring
]]

local HomeTabMod = {}

function HomeTabMod.init(WindowObj, dependencies)
    local Window = WindowObj.Window
    local WindUI = WindowObj.WindUI
    local StatsService = dependencies.StatsService
    local MusicEngine = dependencies.MusicEngine
    local Utils = dependencies.Utils

    local Tab = Window:Tab({
        Title = "Overview",
        Desc = "Profile, live stats & phonk player",
        Icon = "solar:home-2-bold",
        IconColor = Color3.fromHex("#FF2A55"),
    })

    -- 1. Profile & Live Stats Section
    local StatsSection = Tab:Section({
        Title = "Live Profile & Stats",
        Opened = true,
    })

    local ProfileParagraph = StatsSection:Paragraph({
        Title = "Player: Loading...",
        Desc = "Game: ??? | Level: ??? | Bounty: ???",
        Image = "solar:user-bold",
        Color = Color3.fromHex("#FF2A55"),
    })

    local PerfParagraph = StatsSection:Paragraph({
        Title = "Performance: 60 FPS | 50ms Ping",
        Desc = "Session Time: 0:00 | Key Time: 25h Left",
        Image = "solar:chart-square-bold",
        Color = Color3.fromHex("#9D00FF"),
    })

    -- Helper to safely update paragraph text
    local function updateParagraph(para, title, desc)
        if not para then return end
        pcall(function()
            if para.SetTitle then para:SetTitle(title) end
            if para.SetDesc then para:SetDesc(desc) end
            if para.ParagraphFrame and para.ParagraphFrame.UIElements then
                local ui = para.ParagraphFrame.UIElements
                if ui.Title and title then ui.Title.Text = title end
                if ui.Desc and desc then ui.Desc.Text = desc ui.Desc.Visible = true end
            end
        end)
    end

    -- Continuous live updater
    if StatsService and StatsService.bind then
        local unbind = StatsService.bind(function(s)
            local pTitle = string.format("Player: %s", s.DisplayName or "???")
            local pDesc = string.format("Game: %s  •  Level: %s  •  Bounty: %s",
                s.GameName or "Unknown",
                tostring(s.Level or "???"),
                tostring(s.Bounty or "???")
            )
            updateParagraph(ProfileParagraph, pTitle, pDesc)

            local perfTitle = string.format("Performance: %d FPS  •  %d ms Ping", s.Fps or 60, s.Ping or 50)
            local perfDesc = string.format("Session Elapsed: %s", s.SessionTimeStr or "0:00")
            updateParagraph(PerfParagraph, perfTitle, perfDesc)
        end, 0.75)

        WindowObj:AddCleanup(unbind)
    end

    Tab:Space()

    -- 2. Phonk Music Player Section
    local MusicSection = Tab:Section({
        Title = "Phonk Music Player",
        Opened = true,
    })

    local currentTrack = MusicEngine and MusicEngine.getCurrentTrack and MusicEngine.getCurrentTrack()
    local initialTitle = currentTrack and currentTrack.Title or "Phonk Soundtrack"

    local NowPlayingPara = MusicSection:Paragraph({
        Title = "Now Playing: " .. initialTitle,
        Desc = "Status: Stopped | High-quality audio streaming",
        Image = "solar:music-note-bold",
        Color = Color3.fromHex("#FF2A55"),
    })

    local function refreshMusicDisplay()
        if not MusicEngine then return end
        local t = MusicEngine.getCurrentTrack()
        local status = MusicEngine.IsPlaying and "Playing" or "Paused / Stopped"
        local title = string.format("Now Playing: %s", t and t.Title or "Phonk Soundtrack")
        local desc = string.format("Status: %s  •  Volume: %d%%", status, math.floor((MusicEngine.Volume or 0.5) * 100))
        updateParagraph(NowPlayingPara, title, desc)
    end

    if MusicEngine and MusicEngine.onStateChange then
        MusicEngine.onStateChange(function()
            refreshMusicDisplay()
        end)
    end

    -- Track Selector Dropdown
    if MusicEngine and MusicEngine.Playlist then
        local trackNames = {}
        for _, trk in ipairs(MusicEngine.Playlist) do
            table.insert(trackNames, trk.Title)
        end

        MusicSection:Dropdown({
            Title = "Select Track",
            Desc = "Choose your phonk vibe",
            Values = trackNames,
            Value = trackNames[1] or "MONTAGEM BAILÃO (Phonk)",
            Callback = function(chosen)
                for idx, trk in ipairs(MusicEngine.Playlist) do
                    if trk.Title == chosen then
                        MusicEngine.play(idx)
                        refreshMusicDisplay()
                        if WindUI then
                            WindUI:Notify({
                                Title = "Now Playing",
                                Content = chosen,
                                Duration = 2.5,
                                Icon = "solar:music-note-bold",
                            })
                        end
                        break
                    end
                end
            end,
        })
    end

    MusicSection:Space()

    -- Music Controls Group
    local MusicGroup = MusicSection:Group({})

    MusicGroup:Button({
        Title = "▶ Play / Resume",
        Callback = function()
            if MusicEngine then
                if not MusicEngine.IsPlaying then
                    if MusicEngine.resume then MusicEngine.resume()
                    elseif MusicEngine.play then MusicEngine.play(MusicEngine.CurrentTrackIndex or 1) end
                end
                refreshMusicDisplay()
            end
        end,
    })

    MusicGroup:Space()

    MusicGroup:Button({
        Title = "⏸ Pause",
        Callback = function()
            if MusicEngine and MusicEngine.pause then
                MusicEngine.pause()
                refreshMusicDisplay()
            end
        end,
    })

    MusicGroup:Space()

    MusicGroup:Button({
        Title = "⏭ Next Track",
        Callback = function()
            if MusicEngine and MusicEngine.nextTrack then
                MusicEngine.nextTrack()
                refreshMusicDisplay()
            end
        end,
    })

    MusicGroup:Space()

    MusicGroup:Button({
        Title = "⏮ Previous Track",
        Callback = function()
            if MusicEngine and MusicEngine.previousTrack then
                MusicEngine.previousTrack()
                refreshMusicDisplay()
            end
        end,
    })

    MusicSection:Space()

    -- Volume Slider
    MusicSection:Slider({
        Title = "Volume",
        Desc = "Master soundtrack loudness",
        Step = 5,
        Value = {
            Min = 0,
            Max = 100,
            Default = 50,
        },
        Callback = function(val)
            if MusicEngine and MusicEngine.setVolume then
                MusicEngine.setVolume(val / 100)
                refreshMusicDisplay()
            end
        end,
    })

    Tab:Space()

    -- 3. Community & Utilities Section
    local CommSection = Tab:Section({
        Title = "Community & Support",
    })

    CommSection:Button({
        Title = "Copy Script Loadstring",
        Desc = "Copy latest one-line loader to clipboard",
        Icon = "solar:copy-bold",
        Callback = function()
            local loadstr = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/rivals-hash/idk/main/main.lua"))()'
            if setclipboard then
                setclipboard(loadstr)
                if WindUI then
                    WindUI:Notify({
                        Title = "Clipboard",
                        Content = "Loadstring copied to clipboard!",
                        Duration = 3,
                        Icon = "solar:copy-bold",
                    })
                end
            end
        end,
    })

    CommSection:Space()

    CommSection:Button({
        Title = "Copy Discord Server",
        Desc = "Join Darling Hub official discord",
        Icon = "solar:share-circle-bold",
        Callback = function()
            local discord = "https://discord.gg/darlinghub"
            if setclipboard then
                setclipboard(discord)
                if WindUI then
                    WindUI:Notify({
                        Title = "Discord",
                        Content = "Discord link copied to clipboard!",
                        Duration = 3,
                        Icon = "solar:share-circle-bold",
                    })
                end
            end
        end,
    })

    return Tab
end

return HomeTabMod
