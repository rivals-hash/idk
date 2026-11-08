--[[
    Darling Hub - macro_tab.lua (Version 1.3)
    Darling Hub - Smart Macro Suite Interface
    5 Slots with 6 Blocks each, real-time Cooldown HUD tracking,
    Mobile floating button, keybinds, and full slot customization.
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
    local SharedEnv = context.SharedEnv or (getgenv and getgenv()) or _G
    local enhanceTabScrolling = context.enhanceTabScrolling
    local bindToggle = context.bindToggle
    local notifyModuleFail = context.notifyModuleFail
    local tr = context.tr
    local currentLanguage = context.currentLanguage
    local triggerAutoSave = context.triggerAutoSave or (DarlingHub and DarlingHub.TriggerAutoSave) or function() end
    local WindUI = context.WindUI

    -- MACRO TAB
    local MacroTab = Window:Tab({
        Title = "Macro",
        Icon = "cpu"
    })
    enhanceTabScrolling(MacroTab)

    local function getMacroMod()
        return DarlingHub:Require("modules/macro/macro_engine.lua")
    end

    MacroTab:Paragraph({
        Title = "Darling Smart Macro",
        Desc = "Autonomous combo engine: 0.045s taps, real-time cooldown HUD handoff, 5 combo slots with 6 blocks each",
        Image = "terminal"
    })

    local statusParagraph = MacroTab:Paragraph({
        Title = "Macro Status",
        Desc = "Idle",
        Image = "activity"
    })

    local mod = getMacroMod()
    if mod and mod.setStatusCallback then
        mod.setStatusCallback(function(newStatus)
            pcall(function()
                if statusParagraph.SetDesc then
                    statusParagraph:SetDesc(tostring(newStatus))
                elseif statusParagraph.SetTitle then
                    statusParagraph:SetTitle("Macro Status: " .. tostring(newStatus))
                end
            end)
        end)
    end

    local macroToggle = MacroTab:Toggle({
        Title = "Macro Enabled",
        Desc = "Enables keyboard trigger and loop execution for skill macro",
        Value = false,
        Callback = function(state)
            local mod = getMacroMod()
            if mod then mod.toggle(state) end
            triggerAutoSave()
        end
    })
    DarlingHub.UIElements["MacroEnabled"] = macroToggle
    DarlingHub.DefaultValues["MacroEnabled"] = false

    local slotOptions = { "Slot 1", "Slot 2", "Slot 3", "Slot 4", "Slot 5" }
    local slotDropdown = MacroTab:Dropdown({
        Title = "Macro Slot",
        Values = slotOptions,
        Value = "Slot 1",
        Callback = function(choice)
            if type(choice) == "table" then choice = choice[1] or choice.Value end
            local num = tonumber(tostring(choice):match("%d+")) or 1
            local mod = getMacroMod()
            if mod then
                mod.ActiveSlot = num
            end
            WindUI:Notify({
                Title = "Macro Slot",
                Content = "Active slot changed to " .. tostring(choice),
                Duration = 1.5,
                Icon = "layers"
            })
            triggerAutoSave()
        end
    })
    DarlingHub.UIElements["MacroActiveSlot"] = slotDropdown
    DarlingHub.DefaultValues["MacroActiveSlot"] = "Slot 1"

    local macroLoopToggle = MacroTab:Toggle({
        Title = "Loop Sequence",
        Desc = "Repeat sequence continuously until stopped",
        Value = false,
        Callback = function(state)
            local mod = getMacroMod()
            if mod then
                mod.Loop = state
                mod.LoopMode = state
            end
            triggerAutoSave()
        end
    })
    DarlingHub.UIElements["MacroLoop"] = macroLoopToggle
    DarlingHub.DefaultValues["MacroLoop"] = false

    local mobileBtnToggle = MacroTab:Toggle({
        Title = "Macro Floating Widget",
        Desc = "Displays a movable squircle one-touch widget on screen to trigger combo",
        Value = false,
        Callback = function(state)
            local mod = getMacroMod()
            if mod then
                mod.ShowMobileButton = state
                if mod.ensureMobileButton then
                    mod.ensureMobileButton(state)
                end
            end
            triggerAutoSave()
        end
    })
    DarlingHub.UIElements["MacroFloatingWidget"] = mobileBtnToggle
    DarlingHub.UIElements["MacroMobileButton"] = mobileBtnToggle
    DarlingHub.DefaultValues["MacroFloatingWidget"] = false
    DarlingHub.DefaultValues["MacroMobileButton"] = false
    DarlingHub.FeatureSetters["MacroFloatingWidget"] = function(state)
        if mobileBtnToggle and mobileBtnToggle.Set then
            pcall(function() mobileBtnToggle:Set(state) end)
        end
    end
    DarlingHub.FeatureSetters["MacroMobileButton"] = function(state)
        if mobileBtnToggle and mobileBtnToggle.Set then
            pcall(function() mobileBtnToggle:Set(state) end)
        end
    end

    MacroTab:Keybind({
        Title = "Macro Key (PC)",
        Desc = "Click to rebind. Press anywhere in-game to fire combo",
        Value = "F",
        Callback = function(keyName)
            local mod = getMacroMod()
            if mod then
                if typeof(keyName) == "EnumItem" then
                    mod.TriggerKey = keyName
                elseif type(keyName) == "string" and Enum.KeyCode[keyName] then
                    mod.TriggerKey = Enum.KeyCode[keyName]
                end
            end
            triggerAutoSave()
        end
    })

    MacroTab:Button({
        Title = "Start Combo Sequence",
        Desc = "Begins executing active slot sequence",
        Callback = function()
            local mod = getMacroMod()
            if mod then
                mod.Enabled = true
                mod.startMacro()
            end
        end
    })

    MacroTab:Button({
        Title = "Stop Combo Sequence",
        Desc = "Immediately terminates current macro playback",
        Callback = function()
            local mod = getMacroMod()
            if mod then
                mod.stopMacro()
            end
        end
    })

    MacroTab:Divider()

    MacroTab:Paragraph({
        Title = "Combo Sequence (6 Blocks)",
        Desc = "Configure 6 sequential weapon skill blocks with Tap/Hold modes, hold durations, and jumps",
        Image = "swords"
    })

    local weaponOptions = { "Melee", "Sword", "Fruit", "Gun" }
    local skillKeyOptions = { "Z", "X", "C", "V", "F" }
    local modeOptions = { "Tap", "Hold" }

    for bNum = 1, 6 do
        local mInit = getMacroMod()
        local slot = mInit and mInit.Slots and mInit.Slots[1]
        local initBlk = (slot and slot.Blocks and slot.Blocks[bNum]) or {
            Enabled = (bNum <= 3),
            Weapon = (bNum <= 2 and "Melee" or "Sword"),
            Skill = ({"Z", "X", "C", "Z", "V", "X"})[bNum],
            Mode = "Tap",
            Hold = 0,
            Jumps = 0
        }

        MacroTab:Toggle({
            Title = "Block " .. bNum .. " Enabled",
            Desc = "Enable or disable step " .. bNum .. " in the combo sequence",
            Value = initBlk.Enabled,
            Callback = function(st)
                local mod = getMacroMod()
                if mod then mod.setSlot(bNum, nil, nil, st) end
                triggerAutoSave()
            end
        })

        MacroTab:Dropdown({
            Title = "B" .. bNum .. " Weapon",
            Values = weaponOptions,
            Value = initBlk.Weapon,
            Callback = function(w)
                if type(w) == "table" then w = w[1] or w.Value end
                local mod = getMacroMod()
                if mod then mod.setSlot(bNum, w, nil, nil) end
                triggerAutoSave()
            end
        })

        MacroTab:Dropdown({
            Title = "B" .. bNum .. " Skill Key",
            Values = skillKeyOptions,
            Value = initBlk.Skill,
            Callback = function(k)
                if type(k) == "table" then k = k[1] or k.Value end
                local mod = getMacroMod()
                if mod then mod.setSlot(bNum, nil, k, nil) end
                triggerAutoSave()
            end
        })

        MacroTab:Dropdown({
            Title = "B" .. bNum .. " Cast Mode",
            Values = modeOptions,
            Value = initBlk.Mode or "Tap",
            Callback = function(m)
                if type(m) == "table" then m = m[1] or m.Value end
                local mod = getMacroMod()
                if mod then mod.setSlot(bNum, nil, nil, nil, m) end
                triggerAutoSave()
            end
        })

        MacroTab:Slider({
            Title = "B" .. bNum .. " Hold Time (s)",
            Width = 200,
            Value = {
                Min = 0,
                Max = 3,
                Default = tonumber(initBlk.Hold) or 0,
            },
            Step = 0.05,
            Callback = function(v)
                local mod = getMacroMod()
                if mod then mod.setSlot(bNum, nil, nil, nil, nil, v) end
                triggerAutoSave()
            end
        })

        MacroTab:Slider({
            Title = "B" .. bNum .. " Post-Skill Jumps",
            Width = 200,
            Value = {
                Min = 0,
                Max = 3,
                Default = tonumber(initBlk.Jumps) or 0,
            },
            Step = 1,
            Callback = function(j)
                local mod = getMacroMod()
                if mod then mod.setSlot(bNum, nil, nil, nil, nil, nil, j) end
                triggerAutoSave()
            end
        })

        if bNum < 6 then MacroTab:Divider() end
    end

    return MacroTab
end
