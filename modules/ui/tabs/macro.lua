--[[
    Darling Hub - modules/ui/tabs/macro.lua
    Macro & Automation Suite for WindUI.
    Includes 100% of Darling Hub Macro features:
    - Auto Farm Level (auto quest & mob farm)
    - Auto Farm Nearest (attack closest hostile mobs)
    - Auto Collect Chests (tween flight to gold/diamond chests)
    - Flight Speed (Tween) slider (50 to 350)
    - Stop Macro button
    - Safe Farm Position selector (Above, Below, Behind)
]]

local MacroTabMod = {}

function MacroTabMod.init(WindowObj, dependencies)
    local Window = WindowObj.Window
    local WindUI = WindowObj.WindUI
    local Utils = dependencies.Utils

    local Tab = Window:Tab({
        Title = "Macro",
        Desc = "Farming routines & chest collector",
        Icon = "solar:cup-first-bold",
        IconColor = Color3.fromHex("#FF2A55"),
    })

    -- 1. Automation & Farm Section
    local FarmSection = Tab:Section({
        Title = "Automation & Farm",
        Opened = true,
    })

    FarmSection:Toggle({
        Title = "Auto Farm Level",
        Desc = "Accept quests and farm mobs automatically",
        Value = false,
        Callback = function(state)
            _G.G_AutoFarmLevel = state
            if state and WindUI then
                WindUI:Notify({
                    Title = "Auto Farm",
                    Content = "Level farming routine started",
                    Duration = 2,
                    Icon = "solar:play-circle-bold",
                })
            end
        end,
    })

    FarmSection:Space()

    FarmSection:Toggle({
        Title = "Auto Farm Nearest",
        Desc = "Attack nearest enemy mobs in range",
        Value = false,
        Callback = function(state)
            _G.G_AutoFarmNearest = state
        end,
    })

    FarmSection:Space()

    FarmSection:Toggle({
        Title = "Auto Collect Chests",
        Desc = "Fly across island to collect cash and chests",
        Value = false,
        Callback = function(state)
            _G.G_AutoCollectChests = state
            if state and WindUI then
                WindUI:Notify({
                    Title = "Chests",
                    Content = "Chest collection started",
                    Duration = 2,
                    Icon = "solar:box-bold",
                })
            end
        end,
    })

    Tab:Space()

    -- 2. Movement & Farm Settings
    local SettingsSection = Tab:Section({
        Title = "Tween & Farm Settings",
        Opened = true,
    })

    SettingsSection:Slider({
        Title = "Flight Speed (Tween)",
        Desc = "Velocity used when moving between farm nodes",
        Step = 10,
        Value = {
            Min = 50,
            Max = 350,
            Default = 220,
        },
        Callback = function(val)
            _G.G_TweenSpeed = val
        end,
    })

    SettingsSection:Space()

    SettingsSection:Dropdown({
        Title = "Farm Distance Position",
        Desc = "Offset angle relative to target mob",
        Values = { "Above Target", "Behind Target", "Below Target" },
        Value = "Above Target",
        Callback = function(pos)
            _G.G_FarmPosition = pos
        end,
    })

    SettingsSection:Space()

    SettingsSection:Button({
        Title = "⛔ Stop Macro",
        Desc = "Cancel any active farming or flight route",
        Icon = "solar:stop-circle-bold",
        Color = Color3.fromHex("#FF2A55"),
        Callback = function()
            _G.G_AutoFarmLevel = false
            _G.G_AutoFarmNearest = false
            _G.G_AutoCollectChests = false
            if WindUI then
                WindUI:Notify({
                    Title = "Macro",
                    Content = "All macros cancelled successfully",
                    Duration = 2,
                    Icon = "solar:check-circle-bold",
                })
            end
        end,
    })

    return Tab
end

return MacroTabMod
