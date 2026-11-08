--[[
    Darling Hub - aimbot_tab.lua (Version 1.3)
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
    local saveHubConfig = context.saveHubConfig or function() if DarlingHub.SaveConfig then pcall(DarlingHub.SaveConfig) end end
    local loadHubConfig = context.loadHubConfig or function() if DarlingHub.LoadConfig then pcall(DarlingHub.LoadConfig) end end
    local triggerAutoSave = context.triggerAutoSave or function() if DarlingHub.TriggerAutoSave then pcall(DarlingHub.TriggerAutoSave) end end
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

-- 2. AIMBOT TAB (MODULAR - BLOX FRUITS)
-- ========================================================================
local AimbotTab = Window:Tab({
    Title = "Aimbot",
    Icon = "target"
})
enhanceTabScrolling(AimbotTab)

local AimSettings = DarlingHub.Settings

local function notifyModuleFail(name)
    if DarlingHub.IsLoadingConfig then return end
    WindUI:Notify({
        Title = "Darling Hub",
        Content = "Failed to load " .. name .. ". Check your connection.",
        Duration = 4,
        Icon = "triangle-alert"
    })
end

local function bindToggle(path, name)
    DarlingHub.FeatureSetters[name] = function(state)
        DarlingHub.FeatureStates[name] = state
        return DarlingHub:Toggle(path, state)
    end
    return function(state)
        DarlingHub.FeatureStates[name] = state
        triggerAutoSave()
        if state then
            if DarlingHub:Toggle(path, true) == false then
                notifyModuleFail(name)
            end
        else
            DarlingHub:Toggle(path, false)
        end
    end
end

local ColorMap = {
    Red = Color3.fromRGB(255, 50, 50),
    Green = Color3.fromRGB(50, 255, 90),
    Blue = Color3.fromRGB(50, 150, 255),
    Yellow = Color3.fromRGB(255, 220, 50),
    Purple = Color3.fromRGB(170, 90, 255),
    White = Color3.fromRGB(255, 255, 255),
}
local ColorNames = { "Rainbow", "White", "Red", "Green", "Blue", "Yellow", "Purple" }

-- Silent Aim
AimbotTab:Toggle({
    Title = "Player Silent Aim",
    Desc = "Redirects skills towards enemy players",
    Value = false,
    Callback = bindToggle("modules/combat/player_aimbot.lua", "Player Silent Aim")
})

AimbotTab:Toggle({
    Title = "NPC Silent Aim",
    Desc = "Redirects skills towards mobs and bosses",
    Value = false,
    Callback = bindToggle("modules/combat/npc_aimbot.lua", "NPC Silent Aim")
})

local aimbotLockPlayerToggle = AimbotTab:Toggle({
    Title = "Lock Player",
    Desc = "Locks target onto current player to maintain aim and attacks during combat",
    Value = false,
    Callback = function(state)
        if DarlingHub.FeatureSetters and DarlingHub.FeatureSetters["LockPlayer"] then
            DarlingHub.FeatureSetters["LockPlayer"](state)
        else
            local core = DarlingHub:Require("modules/combat/aimbot_core.lua")
            if core then core.setLockPlayer(state) end
        end
    end
})
DarlingHub.UIElements["AimbotLockPlayer"] = aimbotLockPlayerToggle

local aimbotLockWidgetToggle = AimbotTab:Toggle({
    Title = "Lock Player Floating Widget",
    Desc = "Displays a movable on-screen button to quickly toggle player lock",
    Value = false,
    Callback = function(state)
        if DarlingHub.FeatureSetters and DarlingHub.FeatureSetters["LockPlayerWidget"] then
            DarlingHub.FeatureSetters["LockPlayerWidget"](state)
        end
    end
})
DarlingHub.UIElements["AimbotLockPlayerWidget"] = aimbotLockWidgetToggle

AimbotTab:Dropdown({
    Title = "Target Priority",
    Values = { "Nearest", "Low HP", "Looking At Me" },
    Value = "Nearest",
    Callback = function(v)
        if type(v) == "string" then AimSettings.Aim.Priority = v end
    end
})

AimbotTab:Dropdown({
    Title = "Aim Mode",
    Desc = "360 = all directions, FOV = circle, 180 = forward only",
    Values = { "360", "FOV", "180" },
    Value = "360",
    Callback = function(v)
        if type(v) == "string" then
            AimSettings.Aim.Mode = v
            local core = (_G.DarlingCombatCore) or (getgenv and getgenv().DarlingCombatCore)
            if core then core.AimMode = v end
        end
    end
})

AimbotTab:Slider({
    Title = "Max Range",
    Width = 200,
    Value = { Min = 100, Max = 3000, Default = 1000 },
    Step = 50,
    Callback = function(v)
        local val = tonumber(v) or 1000
        AimSettings.Aim.MaxRange = val
        local core = (_G.DarlingCombatCore) or (getgenv and getgenv().DarlingCombatCore)
        if core then
            core.MaxRange = val
        end
        local npcAim = DarlingHub:Require("modules/combat/npc_aimbot.lua")
        if npcAim and npcAim.setMaxRange then npcAim.setMaxRange(val) end
        local playerAim = DarlingHub:Require("modules/combat/player_aimbot.lua")
        if playerAim and playerAim.setMaxRange then playerAim.setMaxRange(val) end
    end
})

AimbotTab:Dropdown({
    Title = "Skill Blacklist",
    Desc = "Selected skills are not redirected",
    Values = {
        "Melee Z", "Melee X", "Melee C",
        "Sword Z", "Sword X",
        "Fruit Z", "Fruit X", "Fruit C", "Fruit V", "Fruit F", "Fruit TAP",
        "Gun Z", "Gun X",
    },
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(selection)
        local mod = DarlingHub:Require("modules/combat/blacklist.lua")
        if mod then mod.apply(selection) end
    end
})

AimbotTab:Divider()

-- FOV
AimbotTab:Toggle({
    Title = "Show FOV Circle",
    Value = false,
    Callback = bindToggle("modules/combat/fov.lua", "FOV Circle")
})

AimbotTab:Slider({
    Title = "FOV Radius",
    Width = 200,
    Value = { Min = 20, Max = 600, Default = 100 },
    Step = 5,
    Callback = function(v)
        local val = tonumber(v) or 100
        AimSettings.FOV.Radius = val
        local core = (_G.DarlingCombatCore) or (getgenv and getgenv().DarlingCombatCore)
        if core and core.FOV then
            core.FOV.Radius = val
        end
        local fovMod = DarlingHub:Require("modules/combat/fov.lua")
        if fovMod and fovMod.setRadius then
            fovMod.setRadius(val)
        end
    end
})

AimbotTab:Dropdown({
    Title = "FOV Position",
    Values = { "Center", "Mouse" },
    Value = "Center",
    Callback = function(v)
        if type(v) == "string" then AimSettings.FOV.Mode = v end
    end
})

AimbotTab:Dropdown({
    Title = "FOV Color",
    Values = ColorNames,
    Value = "Rainbow",
    Callback = function(v)
        local fovMod = DarlingHub:Require("modules/combat/fov.lua")
        if v == "Rainbow" then
            if fovMod and fovMod.setRainbow then fovMod.setRainbow(true) end
        elseif ColorMap[v] then
            AimSettings.FOV.Color = ColorMap[v]
            if fovMod and fovMod.setColor then fovMod.setColor(ColorMap[v]) end
        end
    end
})

AimbotTab:Divider()

-- Tracers
local tracersToggle = AimbotTab:Toggle({
    Title = "Show Tracers",
    Desc = "Hardware 3D Beam and 2D SnapLines linking your character directly to enemy",
    Value = false,
    Callback = function(state)
        DarlingHub.FeatureStates["Tracers"] = state
        triggerAutoSave()
        local mod = DarlingHub:Require("modules/combat/tracers.lua")
        if mod then
            if state then mod.enable() else mod.disable() end
        end
    end
})
DarlingHub.UIElements["Tracers"] = tracersToggle
DarlingHub.FeatureSetters["Tracers"] = function(state)
    local mod = DarlingHub:Require("modules/combat/tracers.lua")
    if mod then
        if state then mod.enable() else mod.disable() end
    end
end

AimbotTab:Dropdown({
    Title = "Tracer Mode",
    Values = { "3D Beam", "2D Line", "Both" },
    Value = "Both",
    Callback = function(v)
        AimSettings.Tracers.Type = v
        DarlingHub.FeatureStates["TracerMode"] = v
        triggerAutoSave()
        local mod = DarlingHub:Require("modules/combat/tracers.lua")
        if mod and mod.setType then mod.setType(v) end
    end
})

AimbotTab:Dropdown({
    Title = "Tracer Origin",
    Values = { "Player", "Bottom", "Center" },
    Value = "Player",
    Callback = function(v)
        AimSettings.Tracers.Origin = v
        DarlingHub.FeatureStates["TracerOrigin"] = v
        triggerAutoSave()
        local mod = DarlingHub:Require("modules/combat/tracers.lua")
        if mod and mod.setOrigin then mod.setOrigin(v) end
    end
})

AimbotTab:Dropdown({
    Title = "Tracer Color",
    Values = ColorNames,
    Value = "Rainbow",
    Callback = function(v)
        DarlingHub.FeatureStates["TracerColor"] = v
        triggerAutoSave()
        local mod = DarlingHub:Require("modules/combat/tracers.lua")
        if v == "Rainbow" then
            if mod and mod.setRainbow then mod.setRainbow(true) end
        elseif ColorMap[v] then
            AimSettings.Tracers.Color = ColorMap[v]
            if mod and mod.setColor then mod.setColor(ColorMap[v]) end
        end
    end
})

AimbotTab:Divider()

-- Target Tracker (Sticky Target Tracking)
local trackerToggle = AimbotTab:Toggle({
    Title = "Target Tracker",
    Desc = "Sticky target tracking that glues you behind enemy player",
    Value = false,
    Callback = function(state)
        DarlingHub.FeatureStates["Tracker"] = state
        triggerAutoSave()
        local mod = DarlingHub:Require("modules/combat/tracker.lua")
        if mod then
            if state then
                mod.startTracking()
                if DarlingHub.FeatureStates["TrackerWidget"] then
                    mod.setWidgetVisible(true)
                end
            else
                mod.stopTracking()
                if not DarlingHub.FeatureStates["TrackerWidget"] then
                    mod.setWidgetVisible(false)
                end
            end
        end
    end
})
DarlingHub.UIElements["Tracker"] = trackerToggle
DarlingHub.FeatureSetters["Tracker"] = function(state)
    local mod = DarlingHub:Require("modules/combat/tracker.lua")
    if mod then
        if state then
            mod.startTracking()
            if DarlingHub.FeatureStates["TrackerWidget"] then
                mod.setWidgetVisible(true)
            end
        else
            mod.stopTracking()
            if not DarlingHub.FeatureStates["TrackerWidget"] then
                mod.setWidgetVisible(false)
            end
        end
    end
end

local trackerDistSlider = AimbotTab:Slider({
    Title = "Tracker Distance",
    Desc = "Distance behind target player in studs",
    Width = 200,
    Value = { Min = 1, Max = 15, Default = 3.5 },
    Step = 0.5,
    Callback = function(v)
        DarlingHub.FeatureStates["TrackerDistance"] = v
        triggerAutoSave()
        local mod = DarlingHub:Require("modules/combat/tracker.lua")
        if mod then mod.setDistance(v) end
    end
})
DarlingHub.UIElements["TrackerDistance"] = trackerDistSlider
DarlingHub.FeatureSetters["TrackerDistance"] = function(v)
    local mod = DarlingHub:Require("modules/combat/tracker.lua")
    if mod then mod.setDistance(v) end
end

local trackerWidgetToggle = AimbotTab:Toggle({
    Title = "Tracker Widget",
    Desc = "Shows draggable quick-toggle TRACKER widget on screen",
    Value = false,
    Callback = function(state)
        DarlingHub.FeatureStates["TrackerWidget"] = state
        triggerAutoSave()
        local mod = DarlingHub:Require("modules/combat/tracker.lua")
        if mod then
            mod.setWidgetVisible(state)
        end
    end
})
DarlingHub.UIElements["TrackerWidget"] = trackerWidgetToggle
DarlingHub.FeatureSetters["TrackerWidget"] = function(state)
    local mod = DarlingHub:Require("modules/combat/tracker.lua")
    if mod then
        mod.setWidgetVisible(state)
    end
end

-- ========================================================================

    return AimbotTab
end
