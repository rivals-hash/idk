--[[
    Darling Hub - tp_islands_tab.lua (Version 1.4)
    Island Teleport tab supporting Sea 1, Sea 2, and Sea 3 islands with
    smooth tween teleportation, teleporter shortcuts, and live tween speed adjustments.
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

    local TeleportTab = Window:Tab({
        Title = "Teleport",
        Icon = "map"
    })
    enhanceTabScrolling(TeleportTab)

    local function getTPMod()
        return DarlingHub:Require("modules/movement/tp_islands.lua")
    end

    local tpMod = getTPMod()
    local detectedSea = (tpMod and tpMod.GetCurrentSea and tpMod.GetCurrentSea()) or "Sea1"
    local selectedSeaKey = detectedSea
    local seaDisplayMap = {
        ["Sea 1"] = "Sea1",
        ["Sea 2"] = "Sea2",
        ["Sea 3"] = "Sea3",
    }
    local seaReverseMap = {
        ["Sea1"] = "Sea 1",
        ["Sea2"] = "Sea 2",
        ["Sea3"] = "Sea 3",
    }
    local initialSeaDisplay = seaReverseMap[detectedSea] or "Sea 1"

    local initialIslandList = (tpMod and tpMod.GetIslandNames and tpMod.GetIslandNames(selectedSeaKey)) or {}
    local selectedIsland = initialIslandList[1] or "WindMill"

    local statusPara = TeleportTab:Paragraph({
        Title = "Island Teleporter",
        Desc = "Status: Idle | Target: None | Current Sea: " .. initialSeaDisplay,
        Image = "compass"
    })

    if tpMod then
        tpMod.OnStateChanged = function(state, targetName)
            if statusPara and statusPara.SetDesc then
                pcall(function()
                    if state == true then
                        statusPara:SetDesc("Status: Flight Active | Target: " .. tostring(targetName) .. " | Speed: " .. tostring(tpMod.TweenSpeed))
                    elseif state == "arrived" then
                        statusPara:SetDesc("Status: Arrived at " .. tostring(targetName) .. " | Idle")
                    else
                        statusPara:SetDesc("Status: Idle | Target: None | Current Sea: " .. (seaReverseMap[selectedSeaKey] or "Sea 1"))
                    end
                end)
            end
        end
    end

    local islandDropdown = nil

    local seaDropdown = TeleportTab:Dropdown({
        Title = "Select Sea",
        Desc = "Choose destination sea archipelago",
        Icon = "compass",
        Values = { "Sea 1", "Sea 2", "Sea 3" },
        Value = initialSeaDisplay,
        Callback = function(displayVal)
            local seaKey = seaDisplayMap[displayVal] or "Sea1"
            selectedSeaKey = seaKey
            DarlingHub.FeatureStates["TPSelectedSea"] = displayVal
            triggerAutoSave()
            if tpMod and islandDropdown then
                local newList = tpMod.GetIslandNames(seaKey)
                if #newList > 0 then
                    selectedIsland = newList[1]
                    if islandDropdown.Refresh then
                        pcall(function() islandDropdown:Refresh(newList) end)
                    end
                    if islandDropdown.Select then
                        pcall(function() islandDropdown:Select(selectedIsland) end)
                    end
                end
            end
        end
    })
    DarlingHub.UIElements["TPSelectedSea"] = seaDropdown
    DarlingHub.DefaultValues["TPSelectedSea"] = initialSeaDisplay

    islandDropdown = TeleportTab:Dropdown({
        Title = "Select Island",
        Desc = "Choose island coordinate to tween to",
        Icon = "map-pin",
        Values = initialIslandList,
        Value = selectedIsland,
        Callback = function(islandName)
            selectedIsland = islandName
            DarlingHub.FeatureStates["TPSelectedIsland"] = islandName
            triggerAutoSave()
        end
    })
    DarlingHub.UIElements["TPSelectedIsland"] = islandDropdown
    DarlingHub.DefaultValues["TPSelectedIsland"] = selectedIsland

    TeleportTab:Button({
        Title = "Teleport to Island",
        Desc = "Initiates smooth noclip tween toward the selected island",
        Icon = "navigation",
        Callback = function()
            local mod = getTPMod()
            if not mod then return end
            local cf = mod.GetIslandCFrame(selectedSeaKey, selectedIsland)
            if not cf then
                WindUI:Notify({
                    Title = "Teleport",
                    Content = "Could not find coordinates for " .. tostring(selectedIsland),
                    Duration = 2,
                    Icon = darlingIcon
                })
                return
            end
            local ok, err = mod.StartIslandTween(cf, selectedIsland)
            if ok then
                WindUI:Notify({
                    Title = "Teleporting",
                    Content = "Tweening toward " .. tostring(selectedIsland) .. "...",
                    Duration = 2,
                    Icon = darlingIcon
                })
            else
                WindUI:Notify({
                    Title = "Teleport Failed",
                    Content = tostring(err or "Unable to start tween"),
                    Duration = 2,
                    Icon = darlingIcon
                })
            end
        end
    })

    TeleportTab:Button({
        Title = "Stop Teleport",
        Desc = "Instantly cancels flight and removes temporary anchor parts",
        Icon = "square",
        Callback = function()
            local mod = getTPMod()
            if mod then
                mod.StopIslandTween()
                WindUI:Notify({
                    Title = "Teleport Stopped",
                    Content = "Flight canceled successfully.",
                    Duration = 1.5,
                    Icon = darlingIcon
                })
            end
        end
    })

    TeleportTab:Divider()

    local speedSlider = TeleportTab:Slider({
        Title = "Tween Speed",
        Desc = "Flight velocity in studs/sec (Adjusts live during running flight)",
        Icon = "gauge",
        Width = 200,
        Value = { Min = 150, Max = 550, Default = 350 },
        Callback = function(val)
            DarlingHub.FeatureStates["TPTweenSpeed"] = val
            triggerAutoSave()
            local mod = getTPMod()
            if mod then
                mod.UpdateRunningSpeed(val)
            end
        end
    })
    DarlingHub.UIElements["TPTweenSpeed"] = speedSlider
    DarlingHub.DefaultValues["TPTweenSpeed"] = 350

    local bypassToggle = TeleportTab:Toggle({
        Title = "Use Teleporter Bypass",
        Desc = "Utilizes nearest entrance teleporters to cut down long travel distance",
        Icon = "zap",
        Value = true,
        Callback = function(state)
            DarlingHub.FeatureStates["TPTeleporterBypass"] = state
            triggerAutoSave()
            local mod = getTPMod()
            if mod then
                mod.UseTeleporterBypass = state
            end
        end
    })
    DarlingHub.UIElements["TPTeleporterBypass"] = bypassToggle
    DarlingHub.DefaultValues["TPTeleporterBypass"] = true

    return TeleportTab
end
