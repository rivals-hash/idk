--[[
    Darling Hub - hud_tab.lua (Version 1.5)
    Blox Fruits On-Screen Controls Customization Tab
    Allows players to freely rearrange, drag, scale, lock, and save skill buttons
    (Z, X, C, V, F), Jump, Dash, and Hotbar on mobile and PC.
    Zero Emojis standard across all interface elements.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

return function(context)
    local Window = context.Window
    local DarlingHub = context.DarlingHub
    local enhanceTabScrolling = context.enhanceTabScrolling
    local triggerAutoSave = context.triggerAutoSave or function() if DarlingHub.TriggerAutoSave then pcall(DarlingHub.TriggerAutoSave) end end
    local darlingIcon = context.darlingIcon
    local WindUI = context.WindUI

    local HudTab = Window:Tab({
        Title = "HUD",
        Icon = "layout"
    })
    enhanceTabScrolling(HudTab)

    local function getHUDMod()
        return DarlingHub:Require("modules/ui/controls_hud.lua")
    end

    local hudMod = getHUDMod()

    HudTab:Paragraph({
        Title = "Blox Fruits Controls HUD Editor",
        Desc = "Customise on-screen skill buttons (Z, X, C, V, F, Dash, Jump, Hotbar) with drag-and-drop repositioning and scaling for mobile and PC.",
        Image = "layout"
    })

    local detectedCount = 0
    if hudMod and hudMod.GetButtons then
        local btns = hudMod.GetButtons()
        detectedCount = #btns
    end

    local statusPara = HudTab:Paragraph({
        Title = "HUD Editor Status",
        Desc = "Status: Locked | Detected Buttons: " .. tostring(detectedCount) .. " | Scale: " .. tostring(math.floor(((hudMod and hudMod.GlobalScale) or 1.0) * 100)) .. "%",
        Image = "sliders"
    })

    if hudMod then
        hudMod.OnModeChanged = function(active, reason)
            if statusPara and statusPara.SetDesc then
                pcall(function()
                    local btns = hudMod.GetButtons and hudMod.GetButtons() or {}
                    local scalePct = math.floor(((hudMod and hudMod.GlobalScale) or 1.0) * 100)
                    if active then
                        statusPara:SetDesc("Status: Drag Active (Touch / Mouse) | Editing: " .. tostring(#btns) .. " buttons")
                    elseif reason == "saved" then
                        statusPara:SetDesc("Status: Locked & Saved | Buttons: " .. tostring(#btns) .. " | Scale: " .. tostring(scalePct) .. "%")
                    elseif reason == "discarded" then
                        statusPara:SetDesc("Status: Edit Discarded | Locked | Scale: " .. tostring(scalePct) .. "%")
                    elseif reason == "reset" then
                        statusPara:SetDesc("Status: Default Layout Restored | Scale: 100%")
                    else
                        statusPara:SetDesc("Status: Locked | Buttons: " .. tostring(#btns) .. " | Scale: " .. tostring(scalePct) .. "%")
                    end
                end)
            end
        end
    end

    local editToggleBtn = HudTab:Button({
        Title = "Unlock Dragging (Edit Controls)",
        Desc = "Displays movable bounding boxes over game buttons so you can drag them freely",
        Callback = function()
            local mod = getHUDMod()
            if mod then
                local nextState = not mod.IsEditing
                mod.SetEditMode(nextState)
                WindUI:Notify({
                    Title = "HUD Controls",
                    Content = nextState and "Controls unlocked. Drag buttons freely across your screen." or "Controls locked and saved.",
                    Duration = 2.5,
                    Icon = darlingIcon
                })
            end
        end
    })

    HudTab:Button({
        Title = "Save & Lock Layout",
        Desc = "Locks button positions and writes custom layout to file",
        Callback = function()
            local mod = getHUDMod()
            if mod then
                mod.SetEditMode(false)
                WindUI:Notify({
                    Title = "HUD Controls",
                    Content = "Layout locked and saved successfully.",
                    Duration = 2.0,
                    Icon = darlingIcon
                })
            end
        end
    })

    HudTab:Button({
        Title = "Discard Changes",
        Desc = "Reverts button positions back to previous saved state",
        Callback = function()
            local mod = getHUDMod()
            if mod then
                mod.CancelEdit()
                WindUI:Notify({
                    Title = "HUD Controls",
                    Content = "Edits discarded. Reverted to previous layout.",
                    Duration = 2.0,
                    Icon = darlingIcon
                })
            end
        end
    })

    HudTab:Divider()

    local initialScalePct = math.floor(((hudMod and hudMod.GlobalScale) or 1.0) * 100)
    local scaleSlider = HudTab:Slider({
        Title = "Controls Scale",
        Desc = "Adjust size of all on-screen control buttons (50% - 200%)",
        Width = 200,
        Value = { Min = 50, Max = 200, Default = math.clamp(initialScalePct, 50, 200) },
        Step = 5,
        Callback = function(val)
            local mod = getHUDMod()
            if mod then
                local mult = val / 100
                mod.SetScale(mult)
                DarlingHub.FeatureStates["HUDControlsScale"] = val
                triggerAutoSave()
                if statusPara and statusPara.SetDesc then
                    pcall(function()
                        local btns = mod.GetButtons and mod.GetButtons() or {}
                        statusPara:SetDesc("Status: Locked | Buttons: " .. tostring(#btns) .. " | Scale: " .. tostring(val) .. "%")
                    end)
                end
            end
        end
    })
    DarlingHub.UIElements["HUDControlsScale"] = scaleSlider
    DarlingHub.DefaultValues["HUDControlsScale"] = 100

    HudTab:Divider()

    HudTab:Button({
        Title = "Reset to Default Layout",
        Desc = "Restores original Roblox and Blox Fruits button positions and clears saved layout",
        Callback = function()
            local mod = getHUDMod()
            if mod then
                mod.ResetLayout()
                if scaleSlider and scaleSlider.Set then
                    pcall(scaleSlider.Set, scaleSlider, 100)
                end
                WindUI:Notify({
                    Title = "HUD Controls",
                    Content = "Controls layout and scale restored to game defaults.",
                    Duration = 2.5,
                    Icon = darlingIcon
                })
            end
        end
    })

    return HudTab
end
