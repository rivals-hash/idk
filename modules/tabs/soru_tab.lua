--[[
    Darling Hub - soru_tab.lua (Version 1.4)
    Authentic Blox Fruits Soru / Flashstep integration with native animations,
    1s cooldown button, permanent toggle, and Blox Fruits-styled floating action widget.
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
    local WindUI = context.WindUI

-- 5. SORU TAB
-- ========================================================================
local SoruTab = Window:Tab({
    Title = "Soru",
    Icon = "wind"
})
enhanceTabScrolling(SoruTab)

local function getSoruMod()
    return DarlingHub:Require("modules/combat/soru_engine.lua")
end

SoruTab:Paragraph({
    Title = "Flashstep & Soru Mastery",
    Desc = "Authentic Blox Fruits Flashstep with official animations, 1s cooldown toggle, and mobile button.",
    Image = "zap"
})

-- --- Permanent Cooldown Toggle & Instant 1s Button (Top Priority) ---
local soruCooldownToggle = SoruTab:Toggle({
    Title = "Toggle Soru Cooldown",
    Desc = "Enables 1s FlashstepCooldown attribute continuously and auto-binds on character respawn",
    Icon = "zap",
    Value = false,
    Callback = function(state)
        DarlingHub.FeatureStates["SoruCooldownToggle"] = state
        triggerAutoSave()
        local player = game.Players.LocalPlayer
        local function setupCharacter(char)
            if char and state then
                pcall(function() char:SetAttribute("FlashstepCooldown", 1) end)
            end
        end

        if state then
            if player.Character then setupCharacter(player.Character) end
            if not SharedEnv.FlashstepCooldownConn then
                SharedEnv.FlashstepCooldownConn = player.CharacterAdded:Connect(setupCharacter)
            end
            if not DarlingHub.IsLoadingConfig then
                WindUI:Notify({
                    Title = "Soru Cooldown",
                    Content = "Flashstep cooldown toggle active (1s).",
                    Duration = 2,
                    Icon = "zap"
                })
            end
        else
            if SharedEnv.FlashstepCooldownConn then
                pcall(function() SharedEnv.FlashstepCooldownConn:Disconnect() end)
                SharedEnv.FlashstepCooldownConn = nil
            end
        end
    end
})
DarlingHub.UIElements["SoruCooldownToggle"] = soruCooldownToggle
DarlingHub.DefaultValues["SoruCooldownToggle"] = false

local instantSoruBtn = SoruTab:Button({
    Title = "Instant Soru Cooldown (1s)",
    Desc = "Immediately applies FlashstepCooldown 1 attribute to current character",
    Icon = "timer",
    Callback = function()
        local player = game.Players.LocalPlayer
        local function setupCharacter(char)
            if char then
                pcall(function() char:SetAttribute("FlashstepCooldown", 1) end)
            end
        end

        if player.Character then
            setupCharacter(player.Character)
        end

        if not SharedEnv.FlashstepCooldownConn then
            SharedEnv.FlashstepCooldownConn = player.CharacterAdded:Connect(setupCharacter)
        end

        WindUI:Notify({
            Title = "Soru",
            Content = "Flashstep cooldown applied successfully.",
            Duration = 2.0,
            Icon = "zap"
        })
    end
})
DarlingHub.UIElements["InstantSoru"] = instantSoruBtn

SoruTab:Divider()

-- --- Configuration & Features ---
local infSoruToggle = SoruTab:Toggle({
    Title = "Infinite Soru",
    Desc = "Zero cooldown flashstep for continuous rapid teleportation",
    Icon = "infinity",
    Value = false,
    Callback = function(state)
        local mod = getSoruMod()
        if mod then mod.setInfinite(state) end
    end
})
DarlingHub.UIElements["InfiniteSoru"] = infSoruToggle
DarlingHub.DefaultValues["InfiniteSoru"] = false

local soruAimbotToggle = SoruTab:Toggle({
    Title = "Soru Aimbot",
    Desc = "Teleports directly onto target enemy player upon using Flashstep [Key: R]",
    Icon = "crosshair",
    Value = false,
    Callback = function(state)
        local mod = getSoruMod()
        if mod then mod.setAimbot(state) end
    end
})
DarlingHub.UIElements["SoruAimbot"] = soruAimbotToggle
DarlingHub.DefaultValues["SoruAimbot"] = false

local soruModeDropdown = SoruTab:Dropdown({
    Title = "Soru Target Mode",
    Icon = "target",
    Values = { "Nearest Player", "Selected Player" },
    Value = "Nearest Player",
    Callback = function(selected)
        local mod = getSoruMod()
        if mod then mod.TargetMode = selected end
    end
})
DarlingHub.UIElements["SoruTargetMode"] = soruModeDropdown
DarlingHub.DefaultValues["SoruTargetMode"] = "Nearest Player"

local function getSoruPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    if #names == 0 then
        table.insert(names, "None")
    end
    return names
end

local soruInitialNames = getSoruPlayerNames()
local soruTargetDropdown = SoruTab:Dropdown({
    Title = "Selected Player",
    Desc = "Target player for Soru Aimbot when Target Mode is Selected Player",
    Icon = "user",
    Values = soruInitialNames,
    Value = soruInitialNames[1],
    Callback = function(selected)
        local mod = getSoruMod()
        if mod then mod.SelectedPlayer = selected end
    end
})
DarlingHub.UIElements["SoruSelectedPlayer"] = soruTargetDropdown
DarlingHub.DefaultValues["SoruSelectedPlayer"] = soruInitialNames[1]

local function updateSoruPlayerList()
    pcall(function()
        if soruTargetDropdown and soruTargetDropdown.Refresh then
            local updated = getSoruPlayerNames()
            soruTargetDropdown:Refresh(updated)
        end
    end)
end
Players.PlayerAdded:Connect(updateSoruPlayerList)
Players.PlayerRemoving:Connect(updateSoruPlayerList)

local soruDistSlider = SoruTab:Slider({
    Title = "Soru Max Distance",
    Desc = "Maximum distance in studs for Soru TP aimbot",
    Icon = "ruler",
    Width = 200,
    Value = { Min = 200, Max = 3000, Default = 2000 },
    Step = 100,
    Callback = function(val)
        local mod = getSoruMod()
        if mod then mod.MaxDistance = tonumber(val) or 2000 end
    end
})
DarlingHub.UIElements["SoruMaxDistance"] = soruDistSlider
DarlingHub.DefaultValues["SoruMaxDistance"] = 2000

SoruTab:Divider()

-- Sacred AHK v12.5 Flashstep Skill Combo
SoruTab:Paragraph({
    Title = "Soru Skill Combo",
    Desc = "Monitors Flashstep animation and automatically equips weapon & casts skill",
    Image = "swords"
})

local soruSkillToggle = SoruTab:Toggle({
    Title = "Soru Skill Combo",
    Desc = "Executes assigned weapon skill upon triggering Soru / Flashstep",
    Icon = "swords",
    Value = false,
    Callback = function(state)
        local mod = getSoruMod()
        if mod then mod.setSkillCombo(state) end
    end
})
DarlingHub.UIElements["SoruSkillCombo"] = soruSkillToggle
DarlingHub.DefaultValues["SoruSkillCombo"] = false

local soruWeaponDropdown = SoruTab:Dropdown({
    Title = "Soru Skill Weapon",
    Icon = "sword",
    Values = { "Fruit", "Melee", "Sword", "Gun" },
    Value = "Fruit",
    Callback = function(selected)
        local mod = getSoruMod()
        if mod then mod.SkillWeapon = selected end
    end
})
DarlingHub.UIElements["SoruSkillWeapon"] = soruWeaponDropdown
DarlingHub.DefaultValues["SoruSkillWeapon"] = "Fruit"

local soruKeyDropdown = SoruTab:Dropdown({
    Title = "Soru Skill Key",
    Icon = "keyboard",
    Values = { "Z", "X", "C", "V", "F" },
    Value = "Z",
    Callback = function(selected)
        local mod = getSoruMod()
        if mod then mod.SkillKey = selected end
    end
})
DarlingHub.UIElements["SoruSkillKey"] = soruKeyDropdown
DarlingHub.DefaultValues["SoruSkillKey"] = "Z"

local soruDelaySlider = SoruTab:Slider({
    Title = "Skill Cast Delay",
    Desc = "Delay in seconds after Soru before activating skill",
    Icon = "clock",
    Width = 200,
    Value = { Min = 0.05, Max = 1.5, Default = 0.3 },
    Step = 0.05,
    Callback = function(val)
        local mod = getSoruMod()
        if mod then mod.SkillDelay = tonumber(val) or 0.3 end
    end
})
DarlingHub.UIElements["SoruSkillDelay"] = soruDelaySlider
DarlingHub.DefaultValues["SoruSkillDelay"] = 0.3

-- ========================================================================

    return SoruTab
end
