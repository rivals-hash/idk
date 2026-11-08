--[[
    Darling Hub - modules/ui/tabs/combat.lua
    Combat & Soru Engine Suite for WindUI.
    Includes:
    - Flashstep / Soru 1-second cooldown modifier
    - Infinite Soru loop without cooldown
    - Soru Aimbot (teleport-strike on [R])
    - Soru Skill Combo automation (Z, X, C, V, F)
    - Fast attack & auto clicker combat utilities
]]

local CombatTabMod = {}

function CombatTabMod.init(WindowObj, dependencies)
    local Window = WindowObj.Window
    local WindUI = WindowObj.WindUI
    local SoruEngine = dependencies.SoruEngine or _G.MonodySoruEngine or _G.DarlingSoruEngine
    local Utils = dependencies.Utils

    local Tab = Window:Tab({
        Title = "Combat",
        Desc = "Fast attack, skills & Soru engine",
        Icon = "solar:sword-bold",
        IconColor = Color3.fromHex("#FF2A55"),
    })

    -- 1. Soru & Flashstep Section
    local SoruSection = Tab:Section({
        Title = "Flashstep / Soru Engine",
        Opened = true,
    })

    SoruSection:Toggle({
        Title = "Soru 1s Cooldown",
        Desc = "Locks Flashstep cooldown to 1 second continuously",
        Value = false,
        Callback = function(enabled)
            if SoruEngine and SoruEngine.setCooldown1s then
                SoruEngine.setCooldown1s(enabled)
            end
        end,
    })

    SoruSection:Space()

    SoruSection:Toggle({
        Title = "Infinite Soru",
        Desc = "Completely eliminates Flashstep cooldown and limits",
        Value = (SoruEngine and SoruEngine.InfiniteEnabled) or false,
        Callback = function(enabled)
            if SoruEngine and SoruEngine.setInfinite then
                SoruEngine.setInfinite(enabled)
            end
        end,
    })

    SoruSection:Space()

    SoruSection:Toggle({
        Title = "Soru Aimbot",
        Desc = "Instantly teleports to enemy target when pressing [R]",
        Value = (SoruEngine and SoruEngine.AimbotEnabled) or false,
        Callback = function(enabled)
            if SoruEngine then
                if SoruEngine.setAimbot then
                    SoruEngine.setAimbot(enabled)
                elseif SoruEngine.setSoruAimbot then
                    SoruEngine.setSoruAimbot(enabled)
                end
            end
        end,
    })

    SoruSection:Space()

    SoruSection:Dropdown({
        Title = "Soru Target Mode",
        Desc = "Determines destination when executing Soru",
        Values = { "Nearest Player", "Mouse Cursor", "Looking At" },
        Value = (SoruEngine and SoruEngine.TargetMode) or "Nearest Player",
        Callback = function(mode)
            if SoruEngine then
                SoruEngine.TargetMode = mode
            end
        end,
    })

    SoruSection:Space()

    SoruSection:Slider({
        Title = "Soru Max Distance",
        Desc = "Maximum distance studs for Soru flashstep",
        Step = 100,
        Value = {
            Min = 200,
            Max = 3000,
            Default = (SoruEngine and SoruEngine.MaxDistance) or 2000,
        },
        Callback = function(val)
            if SoruEngine then
                if SoruEngine.setMaxDistance then
                    SoruEngine.setMaxDistance(val)
                else
                    SoruEngine.MaxDistance = val
                end
            end
        end,
    })

    SoruSection:Space()

    local SoruGroup = SoruSection:Group({})

    SoruGroup:Button({
        Title = "⚡ Execute Soru Now",
        Desc = "Instantly flashsteps towards target",
        Callback = function()
            if SoruEngine and SoruEngine.executeSoru then
                local ok = SoruEngine.executeSoru()
                if ok and WindUI then
                    WindUI:Notify({
                        Title = "Soru",
                        Content = "Flashstep executed successfully!",
                        Duration = 2,
                        Icon = "solar:bolt-bold",
                    })
                end
            end
        end,
    })

    SoruGroup:Space()

    SoruGroup:Button({
        Title = "Reset Cooldown",
        Desc = "Immediately clear flashstep cooldown",
        Callback = function()
            if SoruEngine and SoruEngine.resetCooldown then
                SoruEngine.resetCooldown()
            end
        end,
    })

    Tab:Space()

    -- 2. Soru Skill Combos Section
    local ComboSection = Tab:Section({
        Title = "Soru Auto Skill Combos",
    })

    ComboSection:Toggle({
        Title = "Auto Cast Skill after Soru",
        Desc = "Automatically casts chosen skill immediately upon teleporting",
        Value = (SoruEngine and SoruEngine.SkillComboEnabled) or false,
        Callback = function(enabled)
            if SoruEngine and SoruEngine.setSkillCombo then
                SoruEngine.setSkillCombo(enabled)
            end
        end,
    })

    ComboSection:Space()

    ComboSection:Dropdown({
        Title = "Combo Weapon Slot",
        Desc = "Weapon to equip before skill release",
        Values = { "Fruit", "Melee", "Sword", "Gun" },
        Value = (SoruEngine and SoruEngine.SkillWeapon) or "Fruit",
        Callback = function(wep)
            if SoruEngine then SoruEngine.SkillWeapon = wep end
        end,
    })

    ComboSection:Space()

    ComboSection:Dropdown({
        Title = "Combo Skill Key",
        Desc = "Skill key to trigger on teleport",
        Values = { "Z", "X", "C", "V", "F" },
        Value = (SoruEngine and SoruEngine.SkillKey) or "Z",
        Callback = function(key)
            if SoruEngine then SoruEngine.SkillKey = key end
        end,
    })

    ComboSection:Space()

    ComboSection:Slider({
        Title = "Combo Delay (Seconds)",
        Desc = "Delay after Soru before keypress",
        Step = 0.05,
        Value = {
            Min = 0.05,
            Max = 1.0,
            Default = (SoruEngine and SoruEngine.SkillDelay) or 0.3,
        },
        Callback = function(sec)
            if SoruEngine then SoruEngine.SkillDelay = sec end
        end,
    })

    Tab:Space()

    -- 3. Auto Combat & Attack Automation
    local AutoSection = Tab:Section({
        Title = "Auto Combat & Spammer",
    })

    local fastAttackRunning = false
    AutoSection:Toggle({
        Title = "Fast Attack",
        Desc = "Attacks targets with minimum animation delay",
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
        Desc = "Simulates rapid left clicks",
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

    AutoSection:Button({
        Title = "Equip Best Weapon",
        Desc = "Selects highest damage tool in backpack",
        Icon = "solar:backpack-bold",
        Callback = function()
            local Players = game:GetService("Players")
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
                            Content = bestTool.Name .. " equipped!",
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
