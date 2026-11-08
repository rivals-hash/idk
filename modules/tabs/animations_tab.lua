--[[
    Darling Hub - animations_tab.lua (Version 1.3)
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

-- 9. ANIMATIONS TAB
-- ========================================================================
local SummonDragonTab = Window:Tab({
    Title = "Animations",
    Icon = "activity"
})
enhanceTabScrolling(SummonDragonTab)

SummonDragonTab:Paragraph({
    Title = "Cinematic Animations & Companions",
    Desc = "Play epic cutscenes, summon mythical mounts, and manage active animations",
    Image = "sparkles"
})

local selectedAnimationToPlay = "Worldbreaker"
SummonDragonTab:Dropdown({
    Title = "Select Animation",
    Values = { "Worldbreaker", "The Hollow Lantern", "The Aureate Sanctuary", "Transcendence Dragon", "King's Throne", "Admin Cinematic" },
    Value = "Worldbreaker",
    Callback = function(sel)
        selectedAnimationToPlay = sel
    end
})

SummonDragonTab:Button({
    Title = "Play Animation",
    Desc = "Launches the selected cinematic cutscene or mount",
    Callback = function()
        local function onDone()
            if DarlingHub and DarlingHub.ShowUI then
                DarlingHub:ShowUI()
            end
        end

        if selectedAnimationToPlay == "Worldbreaker" then
            if DarlingHub and DarlingHub.HideUI then DarlingHub:HideUI() end
            local mod = DarlingHub:Require("modules/special/worldbreaker.lua")
            if mod and mod.play then mod.play(onDone) else onDone() end
        elseif selectedAnimationToPlay == "The Hollow Lantern" then
            if DarlingHub and DarlingHub.HideUI then DarlingHub:HideUI() end
            local mod = DarlingHub:Require("modules/special/halloween_cinematic.lua")
            if mod and mod.play then mod.play(onDone) else onDone() end
        elseif selectedAnimationToPlay == "The Aureate Sanctuary" then
            if DarlingHub and DarlingHub.HideUI then DarlingHub:HideUI() end
            local mod = DarlingHub:Require("modules/special/sanctuary_cinematic.lua")
            if mod and mod.play then mod.play(onDone) else onDone() end
        elseif selectedAnimationToPlay == "Transcendence Dragon" then
            local mod = DarlingHub:Require("modules/special/transcendence_dragon.lua")
            if mod and mod.play then mod.play() end
        elseif selectedAnimationToPlay == "King's Throne" then
            if DarlingHub and DarlingHub.HideUI then DarlingHub:HideUI() end
            local mod = DarlingHub:Require("modules/special/kings_throne.lua")
            if mod and mod.play then
                mod.play(onDone)
            elseif mod and mod.mount then
                mod.mount()
            end
        elseif selectedAnimationToPlay == "Admin Cinematic" then
            if DarlingHub and DarlingHub.HideUI then DarlingHub:HideUI() end
            local mod = DarlingHub:Require("modules/special/admin_cinematic.lua") or DarlingHub:Require("modules/special/codex_admin.lua")
            if mod and mod.play then mod.play(onDone) else onDone() end
        end
    end
})

SummonDragonTab:Button({
    Title = "Skip Animation",
    Desc = "Stops active cutscene or mount and safely restores character",
    Callback = function()
        if DarlingHub and DarlingHub.StopAllAnimations then
            pcall(function() DarlingHub:StopAllAnimations() end)
        end
        pcall(function()
            local wb = DarlingHub:Require("modules/special/worldbreaker.lua")
            if wb and wb.stop then wb.stop() end
        end)
        pcall(function()
            local hl = DarlingHub:Require("modules/special/halloween_cinematic.lua")
            if hl and hl.stop then hl.stop() end
        end)
        pcall(function()
            local sc = DarlingHub:Require("modules/special/sanctuary_cinematic.lua")
            if sc and sc.stop then sc.stop() end
        end)
        pcall(function()
            local d = DarlingHub:Require("modules/special/transcendence_dragon.lua")
            if d then d.dismiss() end
        end)
        pcall(function()
            local t = DarlingHub:Require("modules/special/kings_throne.lua")
            if t then t.dismiss() end
        end)
        pcall(function()
            local env = (getgenv and getgenv()) or _G
            for _, key in ipairs({"DarlingWorldbreaker", "DarlingIntro", "DarlingSovereign"}) do
                local c = env[key] or _G[key]
                if type(c) == "table" and type(c.Stop) == "function" then pcall(c.Stop) end
            end
        end)
        WindUI:Notify({
            Title = "Animations",
            Content = "Animations stopped and character restored.",
            Duration = 2.5,
            Icon = darlingIcon
        })
    end
})

SummonDragonTab:Toggle({
    Title = "Hide Dragon",
    Desc = "Hides or displays dragon model and visual aura",
    Value = false,
    Callback = function(state)
        local mod = DarlingHub:Require("modules/special/transcendence_dragon.lua")
        if mod then mod.setHidden(state) end
    end
})

SummonDragonTab:Toggle({
    Title = "Hide Throne",
    Desc = "Hides or displays the king's throne model",
    Value = false,
    Callback = function(state)
        local mod = DarlingHub:Require("modules/special/kings_throne.lua")
        if mod and mod.setHidden then
            mod.setHidden(state)
        elseif mod and state and mod.dismiss then
            mod.dismiss()
        end
    end
})

-- ========================================================================

    return SummonDragonTab
end
