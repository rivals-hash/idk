--[[
    Darling Hub - modules/ui/tabs/settings.lua
    Themes & Configuration Suite for WindUI.
    Includes:
    - Dynamic WindUI theme switcher (Crimson, Violet, Dark, Midnight, Rose, Emerald, etc.)
    - UI Scale and Glass Acrylic toggles
    - Customizable Open/Close Keybind
    - Safe Hub Unload & Destruction handler
    - Rejoin & Server hop utilities
]]

local SettingsTabMod = {}

function SettingsTabMod.init(WindowObj, dependencies)
    local Window = WindowObj.Window
    local WindUI = WindowObj.WindUI
    local Utils = dependencies.Utils

    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local Tab = Window:Tab({
        Title = "Settings",
        Desc = "Themes, keybinds & script unload",
        Icon = "solar:settings-bold",
        IconColor = Color3.fromHex("#FF2A55"),
    })

    -- 1. Themes & Appearance Section
    local ThemeSection = Tab:Section({
        Title = "Themes & Appearance",
        Opened = true,
    })

    local themesList = {
        "Crimson",
        "Violet",
        "Dark",
        "Midnight",
        "Rose",
        "Emerald",
        "Cotton Candy",
        "Amber",
        "Mellowsi",
        "Rainbow",
        "Light",
    }

    ThemeSection:Dropdown({
        Title = "WindUI Theme",
        Desc = "Select dynamic aesthetic colorway",
        Values = themesList,
        Value = "Dark",
        Callback = function(themeName)
            if WindUI and WindUI.SetTheme then
                pcall(function()
                    WindUI:SetTheme(themeName)
                end)
                if WindUI.Notify then
                    WindUI:Notify({
                        Title = "Theme Changed",
                        Content = "Applied " .. themeName .. " theme!",
                        Duration = 2,
                        Icon = "solar:palette-bold",
                    })
                end
            end
        end,
    })

    ThemeSection:Space()

    ThemeSection:Slider({
        Title = "UI Scale",
        Desc = "Resize window for mobile and tablet displays",
        Step = 5,
        Value = {
            Min = 50,
            Max = 120,
            Default = 100,
        },
        Callback = function(val)
            if Window and Window.SetUIScale then
                pcall(function()
                    Window:SetUIScale(val / 100)
                end)
            end
        end,
    })

    Tab:Space()

    -- 2. Shortcuts & Keybinds Section
    local KeybindSection = Tab:Section({
        Title = "Shortcuts & Keybinds",
        Opened = true,
    })

    KeybindSection:Keybind({
        Title = "Toggle UI Keybind",
        Desc = "Keyboard button to show / hide window",
        Value = "LeftControl",
        Callback = function(keyName)
            if Window and Window.SetToggleKey and Enum.KeyCode[keyName] then
                pcall(function()
                    Window:SetToggleKey(Enum.KeyCode[keyName])
                end)
            end
        end,
    })

    Tab:Space()

    -- 3. Server Utilities Section
    local ServerSection = Tab:Section({
        Title = "Server Utilities",
    })

    local ServerGroup = ServerSection:Group({})

    ServerGroup:Button({
        Title = "🔄 Rejoin Server",
        Desc = "Reconnect to the current Roblox server instance",
        Callback = function()
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end)
        end,
    })

    ServerGroup:Space()

    ServerGroup:Button({
        Title = "🌐 Server Hop",
        Desc = "Join a different public server",
        Callback = function()
            pcall(function()
                local HttpService = game:GetService("HttpService")
                local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=25", tostring(game.PlaceId))
                local raw = game:HttpGet(url)
                local json = HttpService:JSONDecode(raw)
                if json and json.data then
                    for _, s in ipairs(json.data) do
                        if s.playing and s.maxPlayers and s.playing < s.maxPlayers and s.id ~= game.JobId then
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                            return
                        end
                    end
                end
            end)
        end,
    })

    Tab:Space()

    -- 4. Unload & Exit Section
    local ExitSection = Tab:Section({
        Title = "Unload & Exit",
    })

    ExitSection:Button({
        Title = "Unload Darling Hub",
        Desc = "Completely remove GUI, disconnect all loops & restore settings",
        Icon = "solar:close-circle-bold",
        Color = Color3.fromHex("#FF2A55"),
        Callback = function()
            local SharedEnv = (getgenv and getgenv()) or _G
            if SharedEnv.BestHub and SharedEnv.BestHub.Unload then
                SharedEnv.BestHub:Unload()
            elseif WindowObj and WindowObj.Destroy then
                WindowObj:Destroy()
            end
        end,
    })

    return Tab
end

return SettingsTabMod
