--[[
    Darling X - Macro Tab Module
    Autonomous Smart Cooldown HUD Macro Suite
    Modularized UI construction for high performance, decoupling, and zero bloat.
]]

local MacroTabModule = {}

function MacroTabModule.Build(MacroPage, env)
    local CreateCard = env.CreateCard
    local AddToggle = env.AddToggle
    local AddChoice = env.AddChoice
    local AddButton = env.AddButton
    local Notify = env.Notify
    local RequireModule = env.RequireModule

    local macroMod = RequireModule("modules/macro/macro_engine.lua")

    -- 1. Macro Controller Card
    local ctrlCard = CreateCard(MacroPage, "Macro Controller")

    AddToggle(ctrlCard, "Macro Enabled", "Enables keyboard trigger and loop execution", false, function(state)
        if macroMod then macroMod.toggle(state) end
        Notify("Macro", "Macro: " .. (state and "Enabled" or "Disabled"))
    end)

    local slotChoices = { "Slot 1", "Slot 2", "Slot 3", "Slot 4", "Slot 5" }
    AddChoice(ctrlCard, "Macro Slot", slotChoices, 1, function(choice)
        local num = tonumber(tostring(choice):match("%d+")) or 1
        if macroMod then macroMod.ActiveSlot = num end
        Notify("Macro", "Active slot changed to " .. tostring(choice))
    end)

    AddToggle(ctrlCard, "Loop Sequence", "Repeat sequence continuously until stopped", false, function(state)
        if macroMod then
            macroMod.Loop = state
            macroMod.LoopMode = state
        end
        Notify("Macro", "Loop: " .. (state and "Enabled" or "Disabled"))
    end)

    AddToggle(ctrlCard, "Macro Floating Widget", "Displays on-screen one-touch button to trigger combo", false, function(state)
        if macroMod and macroMod.ensureMobileButton then
            macroMod.ensureMobileButton(state)
        end
        Notify("Macro", "Widget: " .. (state and "Visible" or "Hidden"))
    end)

    local keyChoices = { "F", "Q", "E", "R", "T", "C", "V", "B", "None" }
    AddChoice(ctrlCard, "Trigger Key (PC)", keyChoices, 1, function(key)
        if macroMod then
            if key == "None" then
                macroMod.TriggerKey = Enum.KeyCode.Unknown
            elseif Enum.KeyCode[key] then
                macroMod.TriggerKey = Enum.KeyCode[key]
            end
        end
    end)

    AddButton(ctrlCard, "Toggle Macro (One-Tap Start/Stop)", function()
        if macroMod then
            macroMod.executeCombo()
            local isRunning = macroMod.Running
            Notify("Macro", isRunning and "Macro: Active (Running combo...)" or "Macro: Deactivated (Stopped)")
        end
    end)

    AddButton(ctrlCard, "Stop Macro Immediately", function()
        if macroMod then
            macroMod.stopMacro()
            Notify("Macro", "Macro: Deactivated (Stopped)")
        end
    end)

    AddButton(ctrlCard, "Teleport to Training Dummy", function()
        pcall(function()
            local char = game:GetService("Players").LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Search for training dummy in Workspace
                local dummy = game:GetService("Workspace"):FindFirstChild("Training Dummy") or game:GetService("Workspace"):FindFirstChild("Dummy")
                if not dummy then
                    local enemies = game:GetService("Workspace"):FindFirstChild("Enemies")
                    if enemies then
                        for _, e in ipairs(enemies:GetChildren()) do
                            if e.Name:lower():find("dummy") or e.Name:lower():find("trainer") then
                                dummy = e
                                break
                            end
                        end
                    end
                end
                if dummy and dummy:FindFirstChild("HumanoidRootPart") then
                    hrp.CFrame = dummy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                    Notify("Macro", "Teleported to Training Dummy!")
                else
                    Notify("Macro", "Training Dummy not found in current area.")
                end
            end
        end)
    end)

    -- 2. Combo Sequence (6 Blocks) - Clean Cokeboys Smart Cooldown Selection (Zero Artificial Sliders)
    local seqCard = CreateCard(MacroPage, "Combo Sequence (6 Blocks)")
    local weaponOpts = { "Melee", "Sword", "Fruit", "Gun" }
    local skillKeyOpts = { "Z", "X", "C", "V", "F" }
    local modeOpts = { "Tap", "Hold", "Transform" }
    local backupOpts = { "None", "Z", "X", "C", "V", "F" }

    for b = 1, 6 do
        local defEnabled = (b <= 3)
        local defWeaponIdx = (b <= 2 and 1 or 2)
        local defSkillIdx = ({1, 2, 3, 1, 4, 2})[b]

        AddToggle(seqCard, "Block " .. b .. " Enabled", "Enable step " .. b .. " in combo", defEnabled, function(state)
            if macroMod then macroMod.setSlot(b, nil, nil, state) end
        end)

        AddChoice(seqCard, "B" .. b .. " Weapon", weaponOpts, defWeaponIdx, function(val)
            if macroMod then macroMod.setSlot(b, val, nil, nil) end
        end)

        AddChoice(seqCard, "B" .. b .. " Skill Key", skillKeyOpts, defSkillIdx, function(val)
            if macroMod then macroMod.setSlot(b, nil, val, nil) end
        end)

        AddChoice(seqCard, "B" .. b .. " Mode", modeOpts, 1, function(val)
            if macroMod then macroMod.setSlot(b, nil, nil, nil, val) end
        end)

        AddChoice(seqCard, "B" .. b .. " Backup Skill", backupOpts, 1, function(val)
            if macroMod and macroMod.Slots and macroMod.Slots[macroMod.ActiveSlot or 1] then
                local blk = macroMod.Slots[macroMod.ActiveSlot or 1].Blocks[b]
                if blk then blk.BackupSkill = (val ~= "None" and val or nil) end
            end
        end)
    end

    return ctrlCard
end

return MacroTabModule
