--[[
    Darling Hub - pvp_tab.lua (Version 1.4)
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

-- 4. PVP TAB
-- ========================================================================
local PvpTab = Window:Tab({
    Title = "Pvp",
    Icon = "swords"
})
enhanceTabScrolling(PvpTab)

local function getPvpMod(path)
    return DarlingHub:Require(path)
end

-- --- Combat Assistance ---
local dragonGunToggle = PvpTab:Toggle({
    Title = "Dragon Gun M1 (Gun Aura)",
    Icon = "crosshair",
    Desc = "Auto-shoots nearest enemies or players with rapid Dragon Gun bursts",
    Value = false,
    Callback = function(state)
        local mod = DarlingHub:Require("modules/pvp/dragon_gun.lua")
        if mod then mod.toggle(state) end
        local dToggle = DarlingHub.UIElements["DungeonGunAura"]
        if dToggle and dToggle.Set then
            pcall(dToggle.Set, dToggle, state)
        end
    end
})
DarlingHub.UIElements["DragonGunM1"] = dragonGunToggle
DarlingHub.DefaultValues["DragonGunM1"] = false
DarlingHub.FeatureSetters["DragonGunM1"] = function(state)
    DarlingHub.FeatureStates["DragonGunM1"] = state
    if dragonGunToggle and dragonGunToggle.Set then
        pcall(dragonGunToggle.Set, dragonGunToggle, state)
    end
    local dToggle = DarlingHub.UIElements["DungeonGunAura"]
    if dToggle and dToggle.Set then
        pcall(dToggle.Set, dToggle, state)
    end
    local mod = DarlingHub:Require("modules/pvp/dragon_gun.lua")
    if mod then mod.toggle(state) end
end

local hitboxExpanderToggle = PvpTab:Toggle({
    Title = "Hitbox Expander",
    Icon = "box-select",
    Desc = "Expands weapon hitboxes using Nameless CombatUtil hook",
    Value = false,
    Callback = function(state)
        local mod = DarlingHub:Require("modules/combat/hitbox_expander.lua")
        if mod then mod.toggle(state) end
    end
})
DarlingHub.UIElements["HitboxExpander"] = hitboxExpanderToggle
DarlingHub.DefaultValues["HitboxExpander"] = false

local hitboxMultiplierSlider = PvpTab:Slider({
    Title = "Hitbox Multiplier",
    Icon = "maximize-2",
    Desc = "Multiplier for weapon hitbox magnitude (Max: 50)",
    Width = 200,
    Value = { Min = 1, Max = 50, Default = 20 },
    Step = 1,
    Callback = function(val)
        local mod = DarlingHub:Require("modules/combat/hitbox_expander.lua")
        if mod then mod.setMultiplier(val) end
    end
})
DarlingHub.UIElements["HitboxMultiplier"] = hitboxMultiplierSlider
DarlingHub.DefaultValues["HitboxMultiplier"] = 20

local lockWidget = nil
local lockPlayerToggle = PvpTab:Toggle({
    Title = "Lock Player",
    Icon = "lock",
    Desc = "Locks target onto current player to maintain aim and attacks during combat",
    Value = false,
    Callback = function(state)
        local core = DarlingHub:Require("modules/combat/aimbot_core.lua")
        if core then core.setLockPlayer(state) end
        if lockWidget and lockWidget.SetState then
            pcall(function() lockWidget:SetState(state) end)
        end
    end
})
DarlingHub.UIElements["LockPlayer"] = lockPlayerToggle
DarlingHub.DefaultValues["LockPlayer"] = false
DarlingHub.FeatureSetters["LockPlayer"] = function(state)
    DarlingHub.FeatureStates["LockPlayer"] = state
    if lockPlayerToggle and lockPlayerToggle.Set then
        pcall(function() lockPlayerToggle:Set(state) end)
    end
    if DarlingHub.UIElements and DarlingHub.UIElements["AimbotLockPlayer"] and DarlingHub.UIElements["AimbotLockPlayer"].Set then
        pcall(function() DarlingHub.UIElements["AimbotLockPlayer"]:Set(state) end)
    end
    local core = DarlingHub:Require("modules/combat/aimbot_core.lua")
    if core then core.setLockPlayer(state) end
    if lockWidget and lockWidget.SetState then
        pcall(function() lockWidget:SetState(state) end)
    end
end

local lockWidgetToggle = PvpTab:Toggle({
    Title = "Lock Player Floating Widget",
    Icon = "layout-grid",
    Desc = "Displays a movable on-screen button to quickly toggle player lock",
    Value = false,
    Callback = function(state)
        if state then
            if not lockWidget then
                local FloatingWidgetMod = DarlingHub:Require("modules/pvp/floating_widget.lua")
                if FloatingWidgetMod then
                    lockWidget = FloatingWidgetMod.create({
                        Id = "LockPlayerFloatingPill",
                        UIElementKey = "LockPlayer",
                        Label = "LOCK",
                        Type = "Toggle",
                        Visible = true,
                        Default = DarlingHub.FeatureStates["LockPlayer"] or false,
                        Position = UDim2.new(0.85, 0, 0.45, 0),
                        Callback = function(wState)
                            if DarlingHub.FeatureSetters and DarlingHub.FeatureSetters["LockPlayer"] then
                                DarlingHub.FeatureSetters["LockPlayer"](wState)
                            else
                                local core = DarlingHub:Require("modules/combat/aimbot_core.lua")
                                if core then core.setLockPlayer(wState) end
                            end
                        end
                    })
                end
            elseif lockWidget.SetVisible then
                lockWidget:SetVisible(true)
            end
        else
            if lockWidget and lockWidget.SetVisible then
                lockWidget:SetVisible(false)
            end
        end
    end
})
DarlingHub.UIElements["LockPlayerWidget"] = lockWidgetToggle
DarlingHub.DefaultValues["LockPlayerWidget"] = false
DarlingHub.FeatureSetters["LockPlayerWidget"] = function(state)
    DarlingHub.FeatureStates["LockPlayerWidget"] = state
    if lockWidgetToggle and lockWidgetToggle.Set then
        pcall(function() lockWidgetToggle:Set(state) end)
    end
    if DarlingHub.UIElements and DarlingHub.UIElements["AimbotLockPlayerWidget"] and DarlingHub.UIElements["AimbotLockPlayerWidget"].Set then
        pcall(function() DarlingHub.UIElements["AimbotLockPlayerWidget"]:Set(state) end)
    end
    if state then
        if not lockWidget then
            local FloatingWidgetMod = DarlingHub:Require("modules/pvp/floating_widget.lua")
            if FloatingWidgetMod then
                lockWidget = FloatingWidgetMod.create({
                    Id = "LockPlayerFloatingPill",
                    UIElementKey = "LockPlayer",
                    Label = "LOCK",
                    Type = "Toggle",
                    Visible = true,
                    Default = DarlingHub.FeatureStates["LockPlayer"] or false,
                    Position = UDim2.new(0.85, 0, 0.45, 0),
                    Callback = function(wState)
                        if DarlingHub.FeatureSetters and DarlingHub.FeatureSetters["LockPlayer"] then
                            DarlingHub.FeatureSetters["LockPlayer"](wState)
                        else
                            local core = DarlingHub:Require("modules/combat/aimbot_core.lua")
                            if core then core.setLockPlayer(wState) end
                        end
                    end
                })
            end
        elseif lockWidget.SetVisible then
            lockWidget:SetVisible(true)
        end
    else
        if lockWidget and lockWidget.SetVisible then
            lockWidget:SetVisible(false)
        end
    end
end

local fastAttackToggle = PvpTab:Toggle({
    Title = "Fast Attack",
    Icon = "zap",
    Desc = "Rapid-fire attack bursts for Swords, Melee, and Fruits",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/pvp/fast_attack.lua")
        if mod then
            if state then mod.enable() else mod.disable() end
        end
    end
})
DarlingHub.UIElements["FastAttack"] = fastAttackToggle
DarlingHub.DefaultValues["FastAttack"] = false

local attackDelaySlider = PvpTab:Slider({
    Title = "Attack Delay",
    Icon = "clock",
    Desc = "Delay between burst hits in seconds",
    Width = 200,
    Value = { Min = 0.01, Max = 0.50, Default = 0.25 },
    Step = 0.01,
    Callback = function(val)
        local mod = getPvpMod("modules/pvp/fast_attack.lua")
        if mod then mod.AttackDelay = tonumber(val) or 0.25 end
    end
})
DarlingHub.UIElements["AttackDelay"] = attackDelaySlider
DarlingHub.DefaultValues["AttackDelay"] = 0.25

local fruitFastAttackToggle = PvpTab:Toggle({
    Title = "Fruit Fast Attack",
    Icon = "flame",
    Desc = "High-speed attack bursts for Demon Fruits, swords and melee",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/pvp/fast_attack.lua")
        if mod then
            if state then mod.enable() else mod.disable() end
        end
    end
})
DarlingHub.UIElements["FruitFastAttack"] = fruitFastAttackToggle
DarlingHub.DefaultValues["FruitFastAttack"] = false

local oneshotKitsuneToggle = PvpTab:Toggle({
    Title = "One shot Kitsune",
    Icon = "sparkles",
    Desc = "High-potency 9e30 projectile burst for Kitsune Demon Fruit",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/pvp/fruits_oneshot.lua")
        if mod then
            if state then mod.enable() else mod.disable() end
        end
    end
})
DarlingHub.UIElements["OneShotKitsune"] = oneshotKitsuneToggle
DarlingHub.DefaultValues["OneShotKitsune"] = false

PvpTab:Toggle({
    Title = "Auto Buso Haki",
    Icon = "shield",
    Desc = "Automatically activates Buso Haki during combat if disabled",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/combat/auto_haki.lua")
        if mod then
            if state then mod.enable() else mod.disable() end
        end
    end
})

PvpTab:Divider()

-- --- Defense & Awakening ---
PvpTab:Toggle({
    Title = "Auto Race V3",
    Icon = "shield-alert",
    Desc = "Automatically activates Race V3 ability in combat when health drops",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/pvp/race_awakening.lua")
        if mod then mod.setAutoV3(state) end
    end
})

PvpTab:Slider({
    Title = "Race V3 Health Threshold",
    Icon = "heart",
    Desc = "Health percentage trigger for Race V3 activation",
    Width = 200,
    Value = { Min = 10, Max = 95, Default = 75 },
    Step = 5,
    Callback = function(val)
        local mod = getPvpMod("modules/pvp/race_awakening.lua")
        if mod then mod.V3HealthThreshold = tonumber(val) or 75 end
    end
})

PvpTab:Toggle({
    Title = "Auto Race V4",
    Icon = "zap",
    Desc = "Automatically triggers Race V4 awakening as soon as awakening meter is full",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/pvp/race_awakening.lua")
        if mod then mod.setAutoV4(state) end
    end
})

PvpTab:Toggle({
    Title = "Anti Stun Hitbox",
    Icon = "shield-check",
    Desc = "Clears enemy stun values and removes hostile body movers that freeze character",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/pvp/race_awakening.lua")
        if mod then mod.setAntiStun(state) end
    end
})

PvpTab:Divider()

-- --- Mobility & Movement Tech ---
PvpTab:Toggle({
    Title = "Sanguine Z Boost",
    Icon = "droplet",
    Desc = "High-velocity directional launch in camera look direction [Key: Z]",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/pvp/sanguine_boost.lua")
        if mod then
            if state then mod.enable() else mod.disable() end
        end
    end
})

PvpTab:Slider({
    Title = "Sanguine Velocity Power",
    Icon = "gauge",
    Desc = "Linear velocity power multiplier",
    Width = 200,
    Value = { Min = 100, Max = 800, Default = 400 },
    Step = 25,
    Callback = function(val)
        local mod = getPvpMod("modules/pvp/sanguine_boost.lua")
        if mod then mod.VelocityPower = tonumber(val) or 400 end
    end
})

PvpTab:Toggle({
    Title = "Ninja Dash (0 Cooldown)",
    Icon = "wind",
    Desc = "Zero-cooldown tactical zigzag dash with camera punch and physics boost [Key: Q]",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/pvp/ninja_dash.lua")
        if mod then
            if state then mod.enable() else mod.disable() end
        end
    end
})

PvpTab:Slider({
    Title = "Ninja Dash Speed",
    Icon = "gauge",
    Desc = "Impulse velocity of the ninja dash",
    Width = 200,
    Value = { Min = 100, Max = 500, Default = 220 },
    Step = 20,
    Callback = function(val)
        local mod = getPvpMod("modules/pvp/ninja_dash.lua")
        if mod then mod.DashSpeed = tonumber(val) or 220 end
    end
})



PvpTab:Toggle({
    Title = "Flight Mode",
    Icon = "plane",
    Desc = "Smooth 3D camera-directed flight [Controls: WASD, Space, Shift]",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/movement/movement_engine.lua")
        if mod then
            if state then mod.startFly() else mod.stopFly() end
        end
    end
})

PvpTab:Slider({
    Title = "Flight Speed",
    Icon = "gauge",
    Desc = "Flight propulsion velocity",
    Width = 200,
    Value = { Min = 20, Max = 350, Default = 70 },
    Step = 5,
    Callback = function(val)
        local mod = getPvpMod("modules/movement/movement_engine.lua")
        if mod then mod.FlySpeed = tonumber(val) or 70 end
    end
})

PvpTab:Toggle({
    Title = "Walk Speed Boost",
    Icon = "footprints",
    Desc = "Bypasses Blox Fruits speed clamp for rapid ground movement",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/movement/movement_engine.lua")
        if mod then mod.setWalkSpeed(state) end
    end
})

PvpTab:Slider({
    Title = "Walk Speed Value",
    Icon = "gauge",
    Desc = "Target movement speed",
    Width = 200,
    Value = { Min = 16, Max = 350, Default = 32 },
    Step = 4,
    Callback = function(val)
        local mod = getPvpMod("modules/movement/movement_engine.lua")
        if mod then mod.setWalkSpeed(mod.WalkSpeedEnabled, tonumber(val) or 32) end
    end
})

PvpTab:Toggle({
    Title = "Dash Distance Boost",
    Icon = "move-right",
    Desc = "Extends the distance of normal character dashes",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/movement/movement_engine.lua")
        if mod then mod.setDashDistance(state) end
    end
})

PvpTab:Slider({
    Title = "Dash Distance Length",
    Icon = "ruler",
    Desc = "Dash length attribute value",
    Width = 200,
    Value = { Min = 1, Max = 300, Default = 50 },
    Step = 5,
    Callback = function(val)
        local mod = getPvpMod("modules/movement/movement_engine.lua")
        if mod then mod.setDashDistance(mod.DashDistanceEnabled, tonumber(val) or 50) end
    end
})

PvpTab:Toggle({
    Title = "Super Jump",
    Icon = "arrow-up-circle",
    Desc = "Instant direct vertical velocity impulse on Space or widget",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/movement/movement_engine.lua")
        if mod then mod.setSuperJump(state) end
    end
})

PvpTab:Slider({
    Title = "Super Jump Power",
    Icon = "gauge",
    Desc = "Upward vertical impulse velocity",
    Width = 200,
    Value = { Min = 100, Max = 1000, Default = 500 },
    Step = 50,
    Callback = function(val)
        local mod = getPvpMod("modules/movement/movement_engine.lua")
        if mod then mod.SuperJumpPower = tonumber(val) or 500 end
    end
})

PvpTab:Toggle({
    Title = "Infinite Air Jump",
    Icon = "chevrons-up",
    Desc = "Resets jump counter allowing unlimited jumps in mid-air",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/movement/movement_engine.lua")
        if mod then mod.setInfiniteJump(state) end
    end
})

PvpTab:Toggle({
    Title = "Walk on Water",
    Icon = "waves",
    Desc = "Enables water walking attribute and dynamic surface platform",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/movement/movement_engine.lua")
        if mod then mod.setWalkOnWater(state) end
    end
})

PvpTab:Toggle({
    Title = "Noclip",
    Icon = "ghost",
    Desc = "Disables character collision allowing you to walk through walls",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/movement/movement_engine.lua")
        if mod then mod.setNoclip(state) end
    end
})

PvpTab:Divider()

-- --- Performance & Client Tweaks ---
PvpTab:Toggle({
    Title = "FFlags 1 (FPS Booster)",
    Icon = "cpu",
    Desc = "120 FPS cap, smooth plastic textures, removes atmosphere fog, hides debris",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/utility/client_tweaks.lua")
        if mod then mod.setFFlags1(state) end
    end
})

PvpTab:Toggle({
    Title = "No Animations",
    Icon = "film",
    Desc = "Stops non-attack animations to fix sideways bug and character freezes",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/utility/client_tweaks.lua")
        if mod then mod.setNoAnimations(state) end
    end
})

PvpTab:Toggle({
    Title = "Anti Lava",
    Icon = "flame",
    Desc = "Disables limb touch detection for complete lava damage immunity",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/utility/client_tweaks.lua")
        if mod then mod.setAntiLava(state) end
    end
})

PvpTab:Toggle({
    Title = "Camera Skew (Rare View)",
    Icon = "video",
    Desc = "Stretches and shears camera projection for wide competitive perspective",
    Value = false,
    Callback = function(state)
        local mod = getPvpMod("modules/utility/client_tweaks.lua")
        if mod then mod.setCameraSkew(state) end
    end
})

PvpTab:Slider({
    Title = "Skew Resolution",
    Icon = "sliders",
    Desc = "Vertical projection factor (lower is more stretched/skewed)",
    Width = 200,
    Value = { Min = 0.05, Max = 1.0, Default = 0.2 },
    Step = 0.05,
    Callback = function(val)
        local mod = getPvpMod("modules/utility/client_tweaks.lua")
        if mod then mod.setCameraSkew(mod.CameraSkewEnabled, tonumber(val) or 0.2) end
    end
})

PvpTab:Divider()

-- --- Floating Widgets Display ---
PvpTab:Toggle({
    Title = "Show Floating Widgets",
    Icon = "layout-grid",
    Desc = "Shows or hides all draggable quick-toggle floating widgets on screen",
    Value = false,
    Callback = function(state)
        local sang = getPvpMod("modules/pvp/sanguine_boost.lua")
        if sang then sang.setFloatingVisible(state) end
        local gun = getPvpMod("modules/pvp/dragon_gun.lua")
        if gun then gun.setFloatingVisible(state) end
        local fast = getPvpMod("modules/pvp/fast_attack.lua")
        if fast then fast.setFloatingVisible(state) end
        local ninja = getPvpMod("modules/pvp/ninja_dash.lua")
        if ninja then ninja.setFloatingVisible(state) end
        local flash = getPvpMod("modules/pvp/flashstep.lua")
        if flash then flash.setFloatingVisible(state) end
        local fruits = getPvpMod("modules/pvp/fruits_m1.lua")
        if fruits then fruits.setFloatingVisible(state) end
        local mov = getPvpMod("modules/movement/movement_engine.lua")
        if mov then
            if mov.FlyWidget then mov.FlyWidget:SetVisible(state) end
            if mov.SuperJumpWidget then mov.SuperJumpWidget:SetVisible(state) end
        end
        local trk = DarlingHub:Require("modules/combat/tracker.lua")
        if trk and trk.setFloatingVisible then trk.setFloatingVisible(state) end
    end
})

PvpTab:Toggle({
    Title = "Lock Widgets Position",
    Icon = "pin",
    Desc = "Locks all floating action and toggle widgets in place to prevent accidental dragging",
    Value = false,
    Callback = function(state)
        local fw = getPvpMod("modules/pvp/floating_widget.lua")
        if fw and fw.LockAll then fw.LockAll(state) end
    end
})

-- ========================================================================

    return PvpTab
end
