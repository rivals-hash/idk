--[[
    Darling Hub - dungeon_tab.lua (Version 1.0)
    Dedicated Dungeon & Raid automation tab matching Sam Premium logic.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

return function(context)
    local Window = context.Window
    local DarlingHub = context.DarlingHub
    local enhanceTabScrolling = context.enhanceTabScrolling
    local triggerAutoSave = context.triggerAutoSave or function() if DarlingHub.TriggerAutoSave then pcall(DarlingHub.TriggerAutoSave) end end
    local WindUI = context.WindUI

-- 7. DUNGEON TAB
-- ========================================================================
local DungeonTab = Window:Tab({
    Title = "Dungeon",
    Icon = "flame"
})
enhanceTabScrolling(DungeonTab)

local function getDungeonMod()
    return DarlingHub:Require("modules/combat/dungeon_engine.lua")
end

local statusPara = DungeonTab:Paragraph({
    Title = "Dungeon Automation Status",
    Desc = "Status: Idle | Room: Detecting | Target: None",
    Image = "flame"
})

task.spawn(function()
    while true do
        local isEnabled = DarlingHub and DarlingHub.FeatureStates and DarlingHub.FeatureStates["AutoDungeon"]
        if not isEnabled then
            task.wait(2.0)
        else
            task.wait(0.5)
            local mod = getDungeonMod()
            if mod and statusPara and statusPara.SetDesc then
                pcall(function()
                    local tName = (mod.CurrentTarget and mod.CurrentTarget.Name) or "None"
                    statusPara:SetDesc("Status: " .. tostring(mod.Status or "Idle") .. " | Target: " .. tostring(tName))
                end)
            end
        end
    end
end)

local autoDungeonToggle = DungeonTab:Toggle({
    Title = "Auto Dungeon",
    Desc = "Automatically targets enemies, teleports above them, attacks, equips weapon, and passes rooms",
    Value = false,
    Callback = function(state)
        DarlingHub.FeatureStates["AutoDungeon"] = state
        triggerAutoSave()
        local mod = getDungeonMod()
        if mod then
            if state then mod.start() else mod.stop() end
        end
    end
})
DarlingHub.UIElements["AutoDungeon"] = autoDungeonToggle
DarlingHub.DefaultValues["AutoDungeon"] = false
DarlingHub.FeatureSetters["AutoDungeon"] = function(state)
    DarlingHub.FeatureStates["AutoDungeon"] = state
    if autoDungeonToggle and autoDungeonToggle.Set then
        pcall(function() autoDungeonToggle:Set(state) end)
    end
    local mod = getDungeonMod()
    if mod then
        if state then mod.start() else mod.stop() end
    end
end

local function getDragonGunMod()
    return DarlingHub:Require("modules/pvp/dragon_gun.lua")
end

local gunAuraDungeonToggle = DungeonTab:Toggle({
    Title = "Dragon Gun M1 (Gun Aura)",
    Desc = "Auto-shoots nearest enemies or players with rapid Dragon Gun bursts",
    Value = (_G.G_DragonGunM1 == true),
    Callback = function(state)
        local mod = getDragonGunMod()
        if mod and mod.toggle then mod.toggle(state) end
        local pvpToggle = DarlingHub.UIElements["DragonGunM1"]
        if pvpToggle and pvpToggle.Set then
            pcall(pvpToggle.Set, pvpToggle, state)
        end
    end
})
DarlingHub.UIElements["DungeonGunAura"] = gunAuraDungeonToggle
DarlingHub.DefaultValues["DungeonGunAura"] = false

local weaponDropdown = DungeonTab:Dropdown({
    Title = "Selected Weapon",
    Desc = "Weapon type to automatically equip during dungeon combat",
    Values = { "Sword", "Melee", "Blox Fruit" },
    Value = "Sword",
    Callback = function(selected)
        DarlingHub.FeatureStates["DungeonWeapon"] = selected
        triggerAutoSave()
        local mod = getDungeonMod()
        if mod and mod.setWeapon then
            mod.setWeapon(selected)
        end
    end
})
DarlingHub.UIElements["DungeonWeapon"] = weaponDropdown
DarlingHub.DefaultValues["DungeonWeapon"] = "Sword"

local heightSlider = DungeonTab:Slider({
    Title = "Attack Height",
    Desc = "Hover height in studs directly above target enemy",
    Width = 200,
    Value = { Min = 10, Max = 100, Default = 40 },
    Step = 5,
    Callback = function(val)
        local h = tonumber(val) or 40
        DarlingHub.FeatureStates["DungeonHeight"] = h
        triggerAutoSave()
        local mod = getDungeonMod()
        if mod and mod.setHeight then
            mod.setHeight(h)
        end
    end
})
DarlingHub.UIElements["DungeonHeight"] = heightSlider
DarlingHub.DefaultValues["DungeonHeight"] = 40

local autoV4Toggle = DungeonTab:Toggle({
    Title = "Auto Race V4",
    Desc = "Automatically triggers Race V4 awakening by pressing Y repeatedly",
    Value = false,
    Callback = function(state)
        DarlingHub.FeatureStates["DungeonAutoV4"] = state
        triggerAutoSave()
        local mod = getDungeonMod()
        if mod and mod.setAutoV4 then
            mod.setAutoV4(state)
        end
    end
})
DarlingHub.UIElements["DungeonAutoV4"] = autoV4Toggle
DarlingHub.DefaultValues["DungeonAutoV4"] = false

DungeonTab:Divider()

DungeonTab:Button({
    Title = "Auto Pass Room Now",
    Desc = "Manually teleports to active room ExitTeleporter and triggers touch interest",
    Callback = function()
        local mod = getDungeonMod()
        if mod and mod.AutoPassRoom then
            local ok = mod.AutoPassRoom()
            if ok then
                WindUI:Notify({
                    Title = "Dungeon",
                    Content = "ExitTeleporter reached successfully.",
                    Duration = 2.5,
                    Icon = "check"
                })
            else
                WindUI:Notify({
                    Title = "Dungeon",
                    Content = "ExitTeleporter not found in active room.",
                    Duration = 2.5,
                    Icon = "triangle-alert"
                })
            end
        end
    end
})

-- ========================================================================

    return DungeonTab
end
