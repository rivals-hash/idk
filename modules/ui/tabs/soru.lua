--[[
    Darling Hub - modules/ui/tabs/soru.lua
    Dedicated Soru / Flashstep Mastery Suite for WindUI.
    Includes 100% of Darling Hub Soru features:
    - Toggle Soru Cooldown (1s)
    - Instant Soru Cooldown (1s)
    - Infinite Soru (no cooldown flashstep)
    - Max Distance slider
    - Soru Aimbot (teleport on [R])
    - Target Mode (Nearest Player, Selected Player, Mouse Cursor)
    - Execute Soru Now button
    - Soru Auto Skill Combo automation (Fruit, Melee, Sword, Gun)
]]

local SoruTabMod = {}

function SoruTabMod.init(WindowObj, dependencies)
    local Window = WindowObj.Window
    local WindUI = WindowObj.WindUI
    local SoruEngine = dependencies.SoruEngine or _G.MonodySoruEngine or _G.DarlingSoruEngine
    local Utils = dependencies.Utils

    local Players = game:GetService("Players")

    local Tab = Window:Tab({
        Title = "Soru",
        Desc = "Flashstep mastery & teleport aimbot",
        Icon = "solar:bolt-bold",
        IconColor = Color3.fromHex("#FF2A55"),
    })

    -- 1. Flashstep & Soru Mastery
    local FlashstepSection = Tab:Section({
        Title = "Flashstep & Soru",
        Opened = true,
    })

    FlashstepSection:Toggle({
        Title = "Toggle Soru Cooldown (1s)",
        Desc = "Maintain 1-second Flashstep cooldown",
        Value = false,
        Callback = function(state)
            if SoruEngine and SoruEngine.setCooldown1s then
                SoruEngine.setCooldown1s(state)
            else
                local player = Players.LocalPlayer
                local function apply(c)
                    if c and state then pcall(function() c:SetAttribute("FlashstepCooldown", 1) end) end
                end
                if player and player.Character then apply(player.Character) end
            end
        end,
    })

    FlashstepSection:Space()

    FlashstepSection:Button({
        Title = "Instant Soru Cooldown (1s)",
        Desc = "Apply 1s cooldown to current character immediately",
        Callback = function()
            local player = Players.LocalPlayer
            if player and player.Character then
                pcall(function() player.Character:SetAttribute("FlashstepCooldown", 1) end)
            end
            if WindUI then
                WindUI:Notify({
                    Title = "Soru",
                    Content = "Flashstep 1s cooldown applied!",
                    Duration = 2,
                    Icon = "solar:bolt-bold",
                })
            end
        end,
    })

    FlashstepSection:Space()

    FlashstepSection:Toggle({
        Title = "Infinite Soru",
        Desc = "Continuous Flashstep without cooldown",
        Value = (SoruEngine and SoruEngine.InfiniteEnabled) or false,
        Callback = function(state)
            if SoruEngine and SoruEngine.setInfinite then
                SoruEngine.setInfinite(state)
            end
        end,
    })

    FlashstepSection:Space()

    FlashstepSection:Slider({
        Title = "Max Distance",
        Desc = "Maximum distance studs for flashstep",
        Step = 50,
        Value = {
            Min = 100,
            Max = 3000,
            Default = (SoruEngine and SoruEngine.MaxDistance) or 1000,
        },
        Callback = function(val)
            if SoruEngine and SoruEngine.setMaxDistance then
                SoruEngine.setMaxDistance(val)
            elseif SoruEngine then
                SoruEngine.MaxDistance = val
            end
        end,
    })

    Tab:Space()

    -- 2. Soru Combat & Aimbot
    local CombatSection = Tab:Section({
        Title = "Soru Combat",
        Opened = true,
    })

    CombatSection:Toggle({
        Title = "Soru Aimbot",
        Desc = "Teleport to target when activating Flashstep [R]",
        Value = (SoruEngine and SoruEngine.AimbotEnabled) or false,
        Callback = function(state)
            if SoruEngine then
                if SoruEngine.setAimbot then SoruEngine.setAimbot(state)
                elseif SoruEngine.setSoruAimbot then SoruEngine.setSoruAimbot(state) end
            end
        end,
    })

    CombatSection:Space()

    CombatSection:Dropdown({
        Title = "Target Mode",
        Desc = "Teleport target selection",
        Values = { "Nearest Player", "Selected Player", "Mouse Cursor" },
        Value = (SoruEngine and SoruEngine.TargetMode) or "Nearest Player",
        Callback = function(opt)
            if SoruEngine then
                SoruEngine.TargetMode = opt
            end
        end,
    })

    CombatSection:Space()

    CombatSection:Button({
        Title = "⚡ Execute Soru Now",
        Desc = "Instantly Flashstep towards target or cursor",
        Icon = "solar:bolt-bold",
        Callback = function()
            if SoruEngine and SoruEngine.executeSoru then
                local ok = SoruEngine.executeSoru()
                if ok and WindUI then
                    WindUI:Notify({
                        Title = "Soru",
                        Content = "Soru executed successfully!",
                        Duration = 1.5,
                        Icon = "solar:check-circle-bold",
                    })
                end
            end
        end,
    })

    Tab:Space()

    -- 3. Soru Skill Combos
    local ComboSection = Tab:Section({
        Title = "Soru Auto Skill Combos",
    })

    ComboSection:Toggle({
        Title = "Auto Cast Skill on Soru",
        Desc = "Cast chosen skill immediately upon teleporting",
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
        Desc = "Weapon equipped on teleport",
        Values = { "Fruit", "Melee", "Sword", "Gun" },
        Value = (SoruEngine and SoruEngine.SkillWeapon) or "Fruit",
        Callback = function(wep)
            if SoruEngine then SoruEngine.SkillWeapon = wep end
        end,
    })

    ComboSection:Space()

    ComboSection:Dropdown({
        Title = "Combo Skill Key",
        Desc = "Skill key executed on arrival",
        Values = { "Z", "X", "C", "V", "F" },
        Value = (SoruEngine and SoruEngine.SkillKey) or "Z",
        Callback = function(key)
            if SoruEngine then SoruEngine.SkillKey = key end
        end,
    })

    ComboSection:Space()

    ComboSection:Slider({
        Title = "Combo Delay (s)",
        Desc = "Pause before activating key",
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

    return Tab
end

return SoruTabMod
