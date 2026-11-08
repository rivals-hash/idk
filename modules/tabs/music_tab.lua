--[[
    Darling Hub - music_tab.lua (Version 1.3)
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

return function(context)
    local Window = context.Window
    local DarlingHub = context.DarlingHub
    local SharedEnv = context.SharedEnv or (getgenv and getgenv()) or _G
    local enhanceTabScrolling = context.enhanceTabScrolling
    local bindToggle = context.bindToggle
    local notifyModuleFail = context.notifyModuleFail
    local ColorMap = context.ColorMap
    local ColorNames = context.ColorNames
    local tr = context.tr
    local currentLanguage = context.currentLanguage
    local applyLanguage = context.applyLanguage
    local darlingLogoHalloween = context.darlingLogoHalloween
    local darlingLogoNormal = context.darlingLogoNormal
    local darlingIcon = context.darlingIcon
    local saveHubConfig = context.saveHubConfig
    local loadHubConfig = context.loadHubConfig
    local triggerAutoSave = context.triggerAutoSave
    local clearActiveMedia = context.clearActiveMedia
    local setActiveMedia = context.setActiveMedia
    local processAndApplyMediaInput = context.processAndApplyMediaInput
    local setBackgroundImage = context.setBackgroundImage
    local playVideo = context.playVideo
    local stopVideo = context.stopVideo
    local PRESET_FALLBACK_ASSETS = context.PRESET_FALLBACK_ASSETS
    local universalHttpGet = context.universalHttpGet
    local loadCustomMediaAsset = context.loadCustomMediaAsset
    local getCustomAsset = context.getCustomAsset
    local currentBackgroundTransparency = context.currentBackgroundTransparency
    local updateVideoRenderSize = context.updateVideoRenderSize
    local safeResolveUserIdentifier = context.safeResolveUserIdentifier
    local allowFloatingWidget = context.allowFloatingWidget
    local toggleHub = context.toggleHub
    local currentToggleKey = context.currentToggleKey
    local WindUI = context.WindUI
    local TabTranslations = context.TabTranslations
    local Translations = context.Translations

-- 7. MUSIC TAB
-- ========================================================================
local MusicTab = Window:Tab({
    Title = "Music",
    Icon = "music"
})
enhanceTabScrolling(MusicTab)

local MusicMod = nil
local function getMusicMod()
    if not MusicMod then
        MusicMod = DarlingHub:Require("modules/utility/music_engine.lua")
    end
    return MusicMod
end

local customMusicId = ""
local customMusicName = ""

MusicTab:Paragraph({
    Title = "Soundtracks",
    Desc = "Background audio streamer with phonk and custom tracks",
    Image = "music"
})


MusicTab:Button({
    Title = "Audio Library",
    Desc = "Launch external audio loader",
    Callback = function()
        WindUI:Notify({
            Title = "Audio Library",
            Content = "Loading audio player...",
            Duration = 3,
            Icon = "music"
        })
        task.spawn(function()
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/DevAuroraX/DevPlayMusic/refs/heads/aliinax/lua"))()
            end)
        end)
    end
})


MusicTab:Divider()

MusicTab:Paragraph({
    Title = "Playback Controls",
    Desc = "Master volume, pitch, and playback toggle",
    Image = "play"
})

MusicTab:Button({
    Title = "Pause / Resume",
    Desc = "Toggles playback between pause and resume",
    Callback = function()
        local mod = getMusicMod()
        if mod then
            local isPlaying, msg = mod.pauseResume()
            WindUI:Notify({
                Title = "Music Player",
                Content = msg,
                Duration = 2,
                Icon = darlingIcon
            })
        end
    end
})

MusicTab:Button({
    Title = "Stop Track",
    Desc = "Completely stops audio playback",
    Callback = function()
        local mod = getMusicMod()
        if mod then
            mod.stop()
            WindUI:Notify({
                Title = "Music Player",
                Content = "Playback stopped",
                Duration = 2,
                Icon = darlingIcon
            })
        end
    end
})

MusicTab:Slider({
    Title = "Playback Volume",
    Width = 200,
    Value = {
        Min = 0,
        Max = 100,
        Default = 50,
    },
    Step = 5,
    Callback = function(val)
        local mod = getMusicMod()
        if mod then
            mod.setVolume(val)
        end
    end
})

MusicTab:Dropdown({
    Title = "Playback Speed & Pitch",
    Values = {
        "Slow (0.8x)",
        "Normal (1.0x)",
        "Fast (1.25x)",
        "Nightcore (1.5x)"
    },
    Value = "Normal (1.0x)",
    Default = "Normal (1.0x)",
    Callback = function(sel)
        if type(sel) == "table" then
            sel = sel[1] or sel.Value
        end
        if not sel or type(sel) ~= "string" then
            sel = "Normal (1.0x)"
        end
        local mod = getMusicMod()
        if mod then
            local speedMap = {
                ["Slow (0.8x)"] = 0.8,
                ["Normal (1.0x)"] = 1.0,
                ["Fast (1.25x)"] = 1.25,
                ["Nightcore (1.5x)"] = 1.5
            }
            local s = speedMap[sel] or 1.0
            mod.setSpeed(s)
            WindUI:Notify({
                Title = "Playback Speed",
                Content = "Speed set to " .. tostring(sel),
                Duration = 2,
                Icon = darlingIcon
            })
        end
    end
})

MusicTab:Toggle({
    Title = "Loop Track",
    Desc = "Automatically loops playback when the song ends",
    Value = true,
    Callback = function(state)
        local mod = getMusicMod()
        if mod then
            mod.setLooped(state)
        end
    end
})

MusicTab:Divider()

MusicTab:Paragraph({
    Title = "Custom Sound ID & Favorites",
    Desc = "Enter any numeric Sound ID or file name and save to favorites",
    Image = "bookmark"
})

MusicTab:Input({
    Title = "Custom Sound ID / File",
    Desc = "Numeric Roblox Asset ID or local MP3 file",
    Placeholder = "e.g. 1843588265 or song.mp3",
    Value = "",
    Callback = function(val)
        customMusicId = val or ""
    end
})

MusicTab:Input({
    Title = "Track Name (For Favorites)",
    Desc = "Display name for your custom track",
    Placeholder = "e.g. My Favorite Phonk",
    Value = "",
    Callback = function(val)
        customMusicName = val or ""
    end
})

MusicTab:Button({
    Title = "Play Custom ID",
    Desc = "Plays the entered Sound ID or asset immediately",
    Callback = function()
        if customMusicId == "" then
            WindUI:Notify({
                Title = "Music Player",
                Content = "Please enter a valid Sound ID first.",
                Duration = 2.5,
                Icon = darlingIcon
            })
            return
        end
        local mod = getMusicMod()
        if mod then
            local name = (customMusicName ~= "") and customMusicName or ("Track #" .. customMusicId)
            local ok, msg = mod.play(customMusicId, name)
            WindUI:Notify({
                Title = "Music Player",
                Content = msg or "Playing custom track",
                Duration = 2.5,
                Icon = darlingIcon
            })
        end
    end
})

MusicTab:Button({
    Title = "Save to Favorites",
    Desc = "Saves the entered track to your persistent favorites list",
    Callback = function()
        if customMusicId == "" then
            WindUI:Notify({
                Title = "Favorites",
                Content = "Enter a Sound ID before saving.",
                Duration = 2.5,
                Icon = darlingIcon
            })
            return
        end
        local mod = getMusicMod()
        if mod then
            local name = (customMusicName ~= "") and customMusicName or ("Track #" .. customMusicId)
            local ok, msg = mod.addFavorite(name, customMusicId)
            WindUI:Notify({
                Title = "Favorites",
                Content = msg or "Saved to favorites!",
                Duration = 2.5,
                Icon = darlingIcon
            })
        end
    end
})

MusicTab:Divider()

MusicTab:Paragraph({
    Title = "External Players",
    Desc = "Universal YouTube Player integration",
    Image = "sparkles"
})

MusicTab:Button({
    Title = "Launch Universal YouTube Player",
    Desc = "Opens the external floating YouTube Music Player GUI",
    Callback = function()
        local mod = getMusicMod()
        if mod then
            WindUI:Notify({
                Title = "YouTube Player",
                Content = "Launching Universal YouTube Music Player...",
                Duration = 3,
                Icon = darlingIcon
            })
            mod.launchYoutubePlayer()
        end
    end
})


-- (Using central Translations and tr() engine declared above)

-- ========================================================================
-- ========================================================================

    return MusicTab
end
