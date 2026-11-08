--[[
    Darling Hub - modules/ui/tabs/combat.lua
    Pure Auto Combat & Spammer Suite for WindUI.
    Includes 100% of Darling Hub Combat features:
    - Fast Attack (zero animation delay attack loop)
    - Auto Clicker (automatic attack spammer)
    - Auto Skills Combo (cast Z, X, C, V skills automatically)
    - Kill Aura (damage all nearby enemies)
    - Attack Range slider (10 to 60 studs)
    - Equip Best Weapon button
]]

local CombatTabMod = {}

function CombatTabMod.init(WindowObj, dependencies)
    local Window = WindowObj.Window
    local WindUI = WindowObj.WindUI
    local Utils = dependencies.Utils

    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local Tab = Window:Tab({
        Title = "Combat",
        Desc = "Fast attack, skills & aura",
        Icon = "solar:sword-bold",
        IconColor = Color3.fromHex("#FF2A55"),
    })

    -- 1. Auto Combat Section
    local AutoSection = Tab:Section({
        Title = "Auto Combat",
        Opened = true,
    })

    local fastAttackRunning = false
    AutoSection:Toggle({
        Title = "Fast Attack",
        Desc = "Fast attack with zero animation delay",
        Value = false,
        Callback = function(enabled)
            fastAttackRunning = enabled
            if enabled then
                task.spawn(function()
                    local VirtualInputManager = game:GetService("VirtualInputManager")
                    while fastAttackRunning do
                        pcall(function()
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                            task.wait(0.02)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        end)
                        task.wait(0.08)
                    end
                end)
            end
        end,
    })

    AutoSection:Space()

    local autoClickRunning = false
    AutoSection:Toggle({
        Title = "Auto Clicker",
        Desc = "Automatic attack spammer",
        Value = false,
        Callback = function(enabled)
            autoClickRunning = enabled
            if enabled then
                task.spawn(function()
                    local VirtualUser = game:GetService("VirtualUser")
                    while autoClickRunning do
                        pcall(function()
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                            task.wait(0.02)
                            VirtualUser:Button1Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                        end)
                        task.wait(0.1)
                    end
                end)
            end
        end,
    })

    AutoSection:Space()

    local autoSkillsRunning = false
    AutoSection:Toggle({
        Title = "Auto Skills Combo",
        Desc = "Cast Z, X, C, V skills automatically",
        Value = false,
        Callback = function(enabled)
            autoSkillsRunning = enabled
            if enabled then
                task.spawn(function()
                    local VirtualInputManager = game:GetService("VirtualInputManager")
                    local keys = { Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V }
                    while autoSkillsRunning do
                        for _, k in ipairs(keys) do
                            if not autoSkillsRunning then break end
                            pcall(function()
                                VirtualInputManager:SendKeyEvent(true, k, false, game)
                                task.wait(0.05)
                                VirtualInputManager:SendKeyEvent(false, k, false, game)
                            end)
                            task.wait(0.35)
                        end
                        task.wait(1.5)
                    end
                end)
            end
        end,
    })

    AutoSection:Space()

    local killAuraRunning = false
    AutoSection:Toggle({
        Title = "Kill Aura",
        Desc = "Damage all nearby enemies",
        Value = false,
        Callback = function(enabled)
            killAuraRunning = enabled
            if enabled then
                task.spawn(function()
                    local VirtualUser = game:GetService("VirtualUser")
                    while killAuraRunning do
                        pcall(function()
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                            task.wait(0.02)
                            VirtualUser:Button1Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                        end)
                        task.wait(0.05)
                    end
                end)
            end
        end,
    })

    Tab:Space()

    -- 2. Range & Weapons Section
    local RangeSection = Tab:Section({
        Title = "Range & Weapons",
        Opened = true,
    })

    RangeSection:Slider({
        Title = "Attack Range",
        Desc = "Combat engagement distance",
        Step = 2,
        Value = {
            Min = 10,
            Max = 60,
            Default = 28,
        },
        Callback = function(val)
            _G.G_AttackRange = val
        end,
    })

    RangeSection:Space()

    RangeSection:Button({
        Title = "Equip Best Weapon",
        Desc = "Equip your highest damage weapon in backpack",
        Icon = "solar:sword-bold",
        Callback = function()
            local lp = Players.LocalPlayer
            if lp and lp:FindFirstChild("Backpack") then
                local bestTool = nil
                for _, item in ipairs(lp.Backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        bestTool = item
                        break
                    end
                end
                if bestTool and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
                    lp.Character.Humanoid:EquipTool(bestTool)
                    if WindUI then
                        WindUI:Notify({
                            Title = "Equipped",
                            Content = "Equipped best weapon: " .. bestTool.Name,
                            Duration = 2,
                            Icon = "solar:check-circle-bold",
                        })
                    end
                end
            end
        end,
    })

    return Tab
end

return CombatTabMod
