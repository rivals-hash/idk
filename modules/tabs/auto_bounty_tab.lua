--[[
    Darling Hub - auto_bounty_tab.lua (Version 1.3)
    Reorganized Auto Bounty Management Interface
    Features: Auto Bounty Mode (Fast Hop), Auto Join Team, Dual Tween Speed (Near/Far),
    Combat & Skills Rotation, Target Server Player Count filtering, and Floating Widget.
    Zero Emojis standard across all interface elements.
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
    local tr = context.tr
    local currentLanguage = context.currentLanguage
    local applyLanguage = context.applyLanguage
    local darlingIcon = context.darlingIcon
    local saveHubConfig = context.saveHubConfig
    local triggerAutoSave = context.triggerAutoSave
    local WindUI = context.WindUI

    -- AUTO BOUNTY TAB INITIALIZATION
    -- ========================================================================
    local AutoBountyTab = Window:Tab({
        Title = "Auto Bounty",
        Icon = "trophy"
    })
    enhanceTabScrolling(AutoBountyTab)

    local function getAutoBountyMod()
        return DarlingHub:Require("modules/combat/auto_bounty.lua")
    end

    local autoBountyMod = getAutoBountyMod()

    -- ========================================================================
    -- SECTION 1: AUTO BOUNTY MODE (FAST HOP)
    -- ========================================================================
    local autoBountyModeToggle = AutoBountyTab:Toggle({
        Title = "Auto Bounty Mode (Fast Hop)",
    Icon = "zap",
        Desc = "When enabled, server hop only loads the high-speed Auto Bounty engine to eliminate lag and maximize FPS",
        Value = (DarlingHub.IsFastMode == true) or (autoBountyMod and autoBountyMod.AutoBountyMode == true) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.AutoBountyMode = state
                _G.DarlingFastBountyMode = state
                if getgenv then getgenv().DarlingFastBountyMode = state end
                DarlingHub.IsFastMode = state
                if mod.saveConfig then
                    mod.saveConfig()
                end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyMode"] = autoBountyModeToggle
    DarlingHub.DefaultValues["AutoBountyMode"] = false

    if DarlingHub.IsFastMode or _G.DarlingFastBountyMode then
        AutoBountyTab:Button({
            Title = "Load All Tabs / Full Hub",
    Icon = "maximize-2",
            Desc = "Loads all remaining tabs and modules into this session without rejoining",
            Callback = function()
                if DarlingHub.LoadAllTabs then
                    DarlingHub.LoadAllTabs()
                end
            end
        })
    end

    AutoBountyTab:Divider()

    -- ========================================================================
    -- SECTION 2: HUNTER CONTROL & TEAM SELECTION
    -- ========================================================================
    local bountyStatusPara = AutoBountyTab:Paragraph({
        Title = "Bounty Hunter Status",
        Desc = "Status: Idle | Targets within range: Monitoring",
        Image = "crosshair"
    })

    task.spawn(function()
        while true do
            local mod = getAutoBountyMod()
            if not (mod and mod.Enabled) then
                task.wait(2.0)
            else
                task.wait(0.2)
                if bountyStatusPara and bountyStatusPara.SetDesc then
                    pcall(function()
                        bountyStatusPara:SetDesc("Status: " .. tostring(mod.Status or "Idle"))
                    end)
                end
            end
        end
    end)

    local autoBountyToggle = AutoBountyTab:Toggle({
        Title = "Hunt Auto",
    Icon = "crosshair",
        Desc = "Autonomous target scanning, tween flight pathing, and skill bursts",
        Value = (autoBountyMod and autoBountyMod.Enabled) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.toggle(state)
                if state then
                    if mod.joinTeam then
                        mod.joinTeam(mod.AutoTeam or "Pirates")
                    end
                    mod.AutoHop = true
                    if DarlingHub.UIElements["AutoHop"] and DarlingHub.UIElements["AutoHop"].Set then
                        pcall(function() DarlingHub.UIElements["AutoHop"]:Set(true) end)
                    end
                else
                    mod.AutoHop = false
                    if DarlingHub.UIElements["AutoHop"] and DarlingHub.UIElements["AutoHop"].Set then
                        pcall(function() DarlingHub.UIElements["AutoHop"]:Set(false) end)
                    end
                end
            end
        end
    })
    DarlingHub.UIElements["AutoBounty"] = autoBountyToggle
    DarlingHub.DefaultValues["AutoBounty"] = false

    -- Auto Join Team: placed directly below Hunt Auto toggle
    local autoTeamDropdown = AutoBountyTab:Dropdown({
        Title = "Auto Join Team",
    Icon = "users",
        Desc = "Automatically joins Marines or Pirates upon server hop or execution",
        Values = { "Pirates", "Marines" },
        Value = (autoBountyMod and autoBountyMod.AutoTeam) or "Pirates",
        Callback = function(selected)
            local mod = getAutoBountyMod()
            if mod then
                mod.AutoTeam = selected
                if mod.joinTeam then
                    mod.joinTeam(selected)
                end
                if mod.saveConfig then
                    mod.saveConfig()
                end
            end
        end
    })
    DarlingHub.UIElements["AutoJoinTeam"] = autoTeamDropdown
    DarlingHub.DefaultValues["AutoJoinTeam"] = "Pirates"

    local skipTargetBtn = AutoBountyTab:Button({
        Title = "Skip Current Target",
    Icon = "skip-forward",
        Desc = "Blacklists and skips the current target to immediately acquire a new enemy",
        Callback = function()
            local mod = getAutoBountyMod()
            if mod and mod.skipCurrentTarget then
                mod.skipCurrentTarget()
            end
        end
    })

    AutoBountyTab:Divider()

    -- ========================================================================
    -- SECTION 3: MOVEMENT & DUAL TWEEN SPEED
    -- ========================================================================
    local nearTweenSlider = AutoBountyTab:Slider({
        Title = "Near Tween Speed (<= 1000 studs)",
    Icon = "gauge",
        Desc = "Linear flight speed when near target (1000 studs or less)",
        Width = 200,
        Value = { Min = 100, Max = 450, Default = (autoBountyMod and autoBountyMod.NearTweenSpeed) or 310 },
        Step = 10,
        Callback = function(val)
            local mod = getAutoBountyMod()
            if mod then
                mod.NearTweenSpeed = tonumber(val) or 310
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["NearTweenSpeed"] = nearTweenSlider
    DarlingHub.DefaultValues["NearTweenSpeed"] = 310

    local farTweenSlider = AutoBountyTab:Slider({
        Title = "Far Tween Speed (> 1000 studs)",
    Icon = "gauge",
        Desc = "Linear flight speed when travelling far (over 1000 studs)",
        Width = 200,
        Value = { Min = 80, Max = 450, Default = (autoBountyMod and autoBountyMod.FarTweenSpeed) or 200 },
        Step = 10,
        Callback = function(val)
            local mod = getAutoBountyMod()
            if mod then
                mod.FarTweenSpeed = tonumber(val) or 200
                mod.FlySpeed = tonumber(val) or 200
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["FarTweenSpeed"] = farTweenSlider
    DarlingHub.DefaultValues["FarTweenSpeed"] = 200

    local orbitToggle = AutoBountyTab:Toggle({
        Title = "Orbit While Attacking",
    Icon = "rotate-cw",
        Desc = "Performs circular flight around target during combat to dodge incoming skills",
        Value = (autoBountyMod and autoBountyMod.Orbit) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.Orbit = state
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyOrbit"] = orbitToggle
    DarlingHub.DefaultValues["AutoBountyOrbit"] = false

    local orbitDistSlider = AutoBountyTab:Slider({
        Title = "Orbit Distance",
    Icon = "ruler",
        Desc = "Radius in studs for orbital flight around target",
        Width = 200,
        Value = { Min = 1, Max = 25, Default = (autoBountyMod and autoBountyMod.OrbitDistance) or 3 },
        Step = 0.5,
        Callback = function(val)
            local mod = getAutoBountyMod()
            if mod then
                mod.OrbitDistance = tonumber(val) or 3
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyOrbitDist"] = orbitDistSlider
    DarlingHub.DefaultValues["AutoBountyOrbitDist"] = 3

    local combatDistSlider = AutoBountyTab:Slider({
        Title = "Combat Distance",
    Icon = "ruler",
        Desc = "Distance in studs behind target during combat (default: 5.5 studs)",
        Width = 200,
        Value = { Min = 1, Max = 25, Default = (autoBountyMod and autoBountyMod.CombatDistance) or 5.5 },
        Step = 0.5,
        Callback = function(val)
            local mod = getAutoBountyMod()
            if mod then
                mod.CombatDistance = tonumber(val) or 5.5
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyCombatDist"] = combatDistSlider
    DarlingHub.DefaultValues["AutoBountyCombatDist"] = 5.5

    local orbitSpeedSlider = AutoBountyTab:Slider({
        Title = "Orbit Speed",
    Icon = "gauge",
        Desc = "Speed of circular orbital flight around target during combat",
        Width = 200,
        Value = { Min = 2, Max = 20, Default = (autoBountyMod and autoBountyMod.OrbitSpeed) or 12.0 },
        Step = 0.5,
        Callback = function(val)
            local mod = getAutoBountyMod()
            if mod then
                mod.OrbitSpeed = tonumber(val) or 12.0
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyOrbitSpeed"] = orbitSpeedSlider
    DarlingHub.DefaultValues["AutoBountyOrbitSpeed"] = 12.0

    local autoSoruToggle = AutoBountyTab:Toggle({
        Title = "Auto Soru",
    Icon = "wind",
        Desc = "Uses Flashstep / Soru (Key R) to close long distances rapidly",
        Value = (autoBountyMod and autoBountyMod.AutoSoru) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.AutoSoru = state
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountySoru"] = autoSoruToggle
    DarlingHub.DefaultValues["AutoBountySoru"] = false

    AutoBountyTab:Divider()

    -- ========================================================================
    -- SECTION 4: COMBAT & SKILLS ROTATION
    -- ========================================================================
    local autoAttackToggle = AutoBountyTab:Toggle({
        Title = "Auto Attack (FastAttack M1)",
    Icon = "swords",
        Desc = "Performs rapid primary attacks and clicks on target when in range",
        Value = (autoBountyMod and autoBountyMod.AutoAttack) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.AutoAttack = state
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyAttack"] = autoAttackToggle
    DarlingHub.DefaultValues["AutoBountyAttack"] = false

    local fastAttackSpeedDropdown = AutoBountyTab:Dropdown({
        Title = "Fast Attack Speed",
    Icon = "gauge",
        Desc = "Configures the real hit rate and delay of primary attacks",
        Values = { "Instant (0s)", "Turbo (0.03s)", "Fast (0.06s)", "Medium (0.10s)", "Safe (0.15s)", "Normal (0.25s)" },
        Value = (autoBountyMod and autoBountyMod.FastAttackSpeed) or "Medium (0.10s)",
        Callback = function(selected)
            local mod = getAutoBountyMod()
            if mod and mod.setAttackSpeed then
                mod.setAttackSpeed(selected)
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyAttackSpeed"] = fastAttackSpeedDropdown
    DarlingHub.DefaultValues["AutoBountyAttackSpeed"] = "Medium (0.10s)"

    local autoSkillsToggle = AutoBountyTab:Toggle({
        Title = "Auto Skills",
    Icon = "sparkles",
        Desc = "Automatically casts available weapon skills in burst sequence",
        Value = (autoBountyMod and autoBountyMod.AutoSkills) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.AutoSkills = state
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountySkills"] = autoSkillsToggle
    DarlingHub.DefaultValues["AutoBountySkills"] = false

    -- Skills list with Fruit F excluded by default
    local defaultExcluded = { "Fruit F" }
    local currentExcludedList = {}
    if autoBountyMod and autoBountyMod.DisabledSkills then
        for k, v in pairs(autoBountyMod.DisabledSkills) do
            if v == true then
                table.insert(currentExcludedList, k)
            end
        end
    end
    if #currentExcludedList == 0 then
        currentExcludedList = defaultExcluded
    end

    local excludedSkillsDropdown = AutoBountyTab:Dropdown({
        Title = "Excluded Skills",
    Icon = "shield-alert",
        Desc = "Select skills to exclude from auto bounty attack rotation",
        Multi = true,
        Values = {
            "Fruit F", "Fruit Z", "Fruit X", "Fruit C", "Fruit V",
            "Godhuman Z", "Melee Z", "Melee X", "Melee C",
            "Sword Z", "Sword X", "Gun Z", "Gun X"
        },
        Value = currentExcludedList,
        Callback = function(selected)
            local mod = getAutoBountyMod()
            if mod then
                mod.DisabledSkills = {}
                if type(selected) == "table" then
                    for k, v in pairs(selected) do
                        if type(k) == "string" and (v == true or v == 1) then
                            mod.DisabledSkills[k] = true
                        elseif type(v) == "string" and (type(k) == "number" or v ~= "") then
                            mod.DisabledSkills[v] = true
                        end
                    end
                elseif type(selected) == "string" and selected ~= "" then
                    mod.DisabledSkills[selected] = true
                end
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["ExcludedSkills"] = excludedSkillsDropdown
    DarlingHub.DefaultValues["ExcludedSkills"] = defaultExcluded

    local meleeWeaponToggle = AutoBountyTab:Toggle({
        Title = "Use Melee Weapons",
    Icon = "swords",
        Desc = "Equips and executes combat skills with Melee weapons",
        Value = (autoBountyMod and autoBountyMod.Enabled and autoBountyMod.Weapons and autoBountyMod.Weapons.Melee) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.Weapons = mod.Weapons or {}
                mod.Weapons.Melee = state
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyWeaponMelee"] = meleeWeaponToggle
    DarlingHub.DefaultValues["AutoBountyWeaponMelee"] = false

    local swordWeaponToggle = AutoBountyTab:Toggle({
        Title = "Use Sword Weapons",
    Icon = "sword",
        Desc = "Equips and executes combat skills with Sword weapons",
        Value = (autoBountyMod and autoBountyMod.Enabled and autoBountyMod.Weapons and autoBountyMod.Weapons.Sword) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.Weapons = mod.Weapons or {}
                mod.Weapons.Sword = state
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyWeaponSword"] = swordWeaponToggle
    DarlingHub.DefaultValues["AutoBountyWeaponSword"] = false

    local fruitWeaponToggle = AutoBountyTab:Toggle({
        Title = "Use Fruit Skills",
    Icon = "flame",
        Desc = "Equips and executes combat skills with Demon Fruit weapons",
        Value = (autoBountyMod and autoBountyMod.Enabled and autoBountyMod.Weapons and autoBountyMod.Weapons.Fruit) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.Weapons = mod.Weapons or {}
                mod.Weapons.Fruit = state
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyWeaponFruit"] = fruitWeaponToggle
    DarlingHub.DefaultValues["AutoBountyWeaponFruit"] = false

    local gunWeaponToggle = AutoBountyTab:Toggle({
        Title = "Use Gun Weapons",
    Icon = "crosshair",
        Desc = "Equips and executes combat skills with Gun weapons",
        Value = (autoBountyMod and autoBountyMod.Enabled and autoBountyMod.Weapons and autoBountyMod.Weapons.Gun) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.Weapons = mod.Weapons or {}
                mod.Weapons.Gun = state
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyWeaponGun"] = gunWeaponToggle
    DarlingHub.DefaultValues["AutoBountyWeaponGun"] = false

    local aimbotLockToggle = AutoBountyTab:Toggle({
        Title = "Target Aimbot Lock",
    Icon = "lock",
        Desc = "Locks camera and redirects skills/attacks directly to target so you never miss",
        Value = (autoBountyMod and autoBountyMod.AimbotLock) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.AimbotLock = state
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyAimbotLock"] = aimbotLockToggle
    DarlingHub.DefaultValues["AutoBountyAimbotLock"] = false

    local autoBusoToggle = AutoBountyTab:Toggle({
        Title = "Auto Buso Haki",
    Icon = "shield",
        Desc = "Automatically activates Buso Haki enhancement during combat",
        Value = (autoBountyMod and autoBountyMod.AutoBuso) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.AutoBuso = state
                if state and mod.autoBuso then
                    task.spawn(function() mod.autoBuso(true) end)
                end
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyBuso"] = autoBusoToggle
    DarlingHub.DefaultValues["AutoBountyBuso"] = false

    local autoKenToggle = AutoBountyTab:Toggle({
        Title = "Auto Observation Haki (Ken)",
    Icon = "eye",
        Desc = "Maintains Observation / Vision Haki permanently active with automatic reactivation",
        Value = (autoBountyMod and autoBountyMod.AutoKen) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.AutoKen = state
                if state and mod.autoKenHaki then
                    task.spawn(function() mod.autoKenHaki(true) end)
                end
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyKen"] = autoKenToggle
    DarlingHub.DefaultValues["AutoBountyKen"] = false

    local autoV4Toggle = AutoBountyTab:Toggle({
        Title = "Auto Race V4",
    Icon = "zap",
        Desc = "Automatically activates Race V4 awakening during combat when meter fills",
        Value = (autoBountyMod and autoBountyMod.AutoV4) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.AutoV4 = state
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyV4"] = autoV4Toggle
    DarlingHub.DefaultValues["AutoBountyV4"] = false

    local autoEnablePvpToggle = AutoBountyTab:Toggle({
        Title = "Auto Enable PvP",
    Icon = "swords",
        Desc = "Automatically enables PvP status via game remote after respawning",
        Value = (autoBountyMod and autoBountyMod.AutoEnablePvp) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.AutoEnablePvp = state
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyEnablePvp"] = autoEnablePvpToggle
    DarlingHub.DefaultValues["AutoBountyEnablePvp"] = false

    AutoBountyTab:Divider()

    -- ========================================================================
    -- SECTION 5: HEALTH & SURVIVAL
    -- ========================================================================
    local cancelFleeButton = AutoBountyTab:Button({
        Title = "Cancel Flee HP",
    Icon = "shield-off",
        Desc = "Immediately aborts fleeing and forces character back to attacking target",
        Callback = function()
            local mod = getAutoBountyMod()
            if mod then
                mod.cancelFlee()
            end
        end
    })
    DarlingHub.UIElements["CancelFleeButton"] = cancelFleeButton

    local autoFleeToggle = AutoBountyTab:Toggle({
        Title = "Auto Flee Low HP",
    Icon = "heart-crack",
        Desc = "Flies to sky safety when health drops below threshold to recover",
        Value = (autoBountyMod and autoBountyMod.AutoFlee) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.AutoFlee = state
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoFlee"] = autoFleeToggle
    DarlingHub.DefaultValues["AutoFlee"] = false

    local fleeHPSlider = AutoBountyTab:Slider({
        Title = "Flee Health Threshold (%)",
    Icon = "heart",
        Desc = "Percentage of HP that triggers auto flee",
        Width = 200,
        Value = { Min = 10, Max = 50, Default = (autoBountyMod and autoBountyMod.FleeHP) or 30 },
        Step = 5,
        Callback = function(val)
            local mod = getAutoBountyMod()
            if mod then
                mod.FleeHP = tonumber(val) or 30
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["FleeHP"] = fleeHPSlider
    DarlingHub.DefaultValues["FleeHP"] = 30

    local returnHPSlider = AutoBountyTab:Slider({
        Title = "Return Health Threshold (%)",
    Icon = "heart-pulse",
        Desc = "Percentage of HP required to resume attacking after fleeing",
        Width = 200,
        Value = { Min = 35, Max = 100, Default = (autoBountyMod and autoBountyMod.ReturnHP) or 50 },
        Step = 5,
        Callback = function(val)
            local mod = getAutoBountyMod()
            if mod then
                mod.ReturnHP = tonumber(val) or 50
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["ReturnHP"] = returnHPSlider
    DarlingHub.DefaultValues["ReturnHP"] = 50

    AutoBountyTab:Divider()

    -- ========================================================================
    -- SECTION 6: SERVER HOP & TARGET FILTERS
    -- ========================================================================
    local autoHopToggle = AutoBountyTab:Toggle({
        Title = "Auto Server Hop",
    Icon = "globe",
        Desc = "Automatically hops to another server when no valid targets remain after scanning",
        Value = (autoBountyMod and autoBountyMod.AutoHop) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.AutoHop = state
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoHop"] = autoHopToggle
    DarlingHub.DefaultValues["AutoHop"] = false

    local targetPlayerCountSlider = AutoBountyTab:Slider({
        Title = "Target Server Player Count",
    Icon = "users",
        Desc = "Desired player count when hopping (default: 8, rejects empty servers)",
        Width = 200,
        Value = { Min = 3, Max = 11, Default = (autoBountyMod and autoBountyMod.TargetPlayerCount) or 8 },
        Step = 1,
        Callback = function(val)
            local mod = getAutoBountyMod()
            if mod then
                mod.TargetPlayerCount = tonumber(val) or 8
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["TargetPlayerCount"] = targetPlayerCountSlider
    DarlingHub.DefaultValues["TargetPlayerCount"] = 8

    AutoBountyTab:Button({
        Title = "Server Hop Now",
    Icon = "refresh-cw",
        Desc = "Smoothly ascends into the sky and hops to a new server with ~8 players immediately",
        Callback = function()
            local mod = getAutoBountyMod()
            if mod and mod.hopServer then
                task.spawn(function()
                    mod.hopServer()
                end)
            end
        end
    })

    local noSafeZoneToggle = AutoBountyTab:Toggle({
        Title = "Skip SafeZone Players",
    Icon = "shield-check",
        Desc = "Avoids hunting players who are inside safe zones",
        Value = (autoBountyMod and autoBountyMod.NoSafeZone) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.NoSafeZone = state
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyNoSafeZone"] = noSafeZoneToggle
    DarlingHub.DefaultValues["AutoBountyNoSafeZone"] = false

    local noMarineAllyToggle = AutoBountyTab:Toggle({
        Title = "Ignore Marine Allies",
    Icon = "anchor",
        Desc = "Does not target fellow Marines when playing as Marine",
        Value = (autoBountyMod and autoBountyMod.NoMarineAlly) or false,
        Callback = function(state)
            local mod = getAutoBountyMod()
            if mod then
                mod.NoMarineAlly = state
                if mod.saveConfig then mod.saveConfig() end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyNoMarineAlly"] = noMarineAllyToggle
    DarlingHub.DefaultValues["AutoBountyNoMarineAlly"] = false

    AutoBountyTab:Divider()

    -- ========================================================================
    -- SECTION 7: FLOATING HUD WIDGET
    -- ========================================================================
    local bountyWidget = nil
    local bountyWidgetToggle = AutoBountyTab:Toggle({
        Title = "Auto Bounty Floating Widget",
    Icon = "layout-grid",
        Desc = "Displays a movable on-screen widget to start/stop auto bounty",
        Value = false,
        Callback = function(state)
            if state then
                if not bountyWidget then
                    local FloatingWidgetMod = DarlingHub:Require("modules/pvp/floating_widget.lua")
                    if FloatingWidgetMod then
                        bountyWidget = FloatingWidgetMod.create({
                            Id = "AutoBountyWidget",
                            Label = "BOUNTY",
                            Type = "Toggle",
                            Visible = true,
                            Default = DarlingHub.FeatureStates["AutoBounty"] or false,
                            Position = UDim2.new(0.85, 0, 0.35, 0),
                            Callback = function(wState)
                                if DarlingHub.FeatureSetters["AutoBounty"] then
                                    DarlingHub.FeatureSetters["AutoBounty"](wState)
                                end
                            end
                        })
                    end
                elseif bountyWidget.SetVisible then
                    bountyWidget:SetVisible(true)
                end
            else
                if bountyWidget and bountyWidget.SetVisible then
                    bountyWidget:SetVisible(false)
                end
            end
        end
    })
    DarlingHub.UIElements["AutoBountyWidget"] = bountyWidgetToggle
    DarlingHub.DefaultValues["AutoBountyWidget"] = false
    DarlingHub.FeatureSetters["AutoBountyWidget"] = function(state)
        if bountyWidgetToggle and bountyWidgetToggle.Set then
            pcall(function() bountyWidgetToggle:Set(state) end)
        end
    end

    DarlingHub.FeatureSetters["AutoBounty"] = function(state)
        DarlingHub.FeatureStates["AutoBounty"] = state
        if autoBountyToggle and autoBountyToggle.Set then
            pcall(function() autoBountyToggle:Set(state) end)
        end
        local mod = getAutoBountyMod()
        if mod then
            mod.toggle(state)
            if state then
                if mod.joinTeam then
                    mod.joinTeam(mod.AutoTeam or "Pirates")
                end
                mod.AutoHop = true
                if DarlingHub.UIElements["AutoHop"] and DarlingHub.UIElements["AutoHop"].Set then
                    pcall(function() DarlingHub.UIElements["AutoHop"]:Set(true) end)
                end
            else
                mod.AutoHop = false
                if DarlingHub.UIElements["AutoHop"] and DarlingHub.UIElements["AutoHop"].Set then
                    pcall(function() DarlingHub.UIElements["AutoHop"]:Set(false) end)
                end
            end
        end
        if bountyWidget and bountyWidget.SetState then
            pcall(function() bountyWidget:SetState(state) end)
        end
    end

    return AutoBountyTab
end
