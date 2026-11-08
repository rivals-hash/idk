--[[
    Darling Hub - modules/ui/window.lua
    WindUI Window Initializer and Master Container.
    Features:
    - Sleek glassmorphic acrylic window container
    - Responsive floating draggable OpenButton for Mobile & PC
    - Monody Premium crimson/purple gradient accents
    - Graceful unload and destruction lifecycle
]]

local WindowMod = {}

function WindowMod.create(dependencies)
    dependencies = dependencies or {}
    local Utils = dependencies.Utils

    -- 1. Load WindUI Library with fallback
    local WindUI = (getgenv and getgenv().WindUI) or (_G and _G.WindUI)
    if not WindUI then
        local ok, lib = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end)
        if ok and lib then
            WindUI = lib
            if getgenv then pcall(function() getgenv().WindUI = WindUI end) end
            _G.WindUI = WindUI
        else
            warn("[Darling Hub] Failed to fetch WindUI: " .. tostring(lib))
            if Utils and Utils.toast then
                Utils.toast("Darling Hub", "Failed to load WindUI engine!", 4)
            end
            return nil
        end
    end

    -- 2. Clean up any previous WindUI windows if present
    pcall(function()
        if (getgenv and getgenv().DarlingHubWindow) then
            getgenv().DarlingHubWindow:Destroy()
            getgenv().DarlingHubWindow = nil
        end
    end)

    -- 3. Create WindUI Master Window
    local win = WindUI:CreateWindow({
        Title = "Darling Hub | Monody",
        Author = "by Darling",
        Folder = "DarlingHub",
        Icon = "solar:heart-bold",
        Theme = "Dark",
        Transparent = true,
        Acrylic = true,
        NewElements = true,
        HideSearchBar = false,

        OpenButton = {
            Title = "Darling Hub",
            CornerRadius = UDim.new(1, 0),
            StrokeThickness = 2,
            Enabled = true,
            Draggable = true,
            OnlyMobile = false,
            Scale = 0.55,
            Color = ColorSequence.new(
                Color3.fromHex("#FF2A55"),
                Color3.fromHex("#9D00FF")
            ),
        },
        Topbar = {
            Height = 44,
            ButtonsType = "Mac",
        },
    })

    if not win then
        warn("[Darling Hub] WindUI:CreateWindow returned nil!")
        return nil
    end

    -- 4. Status Tag
    pcall(function()
        win:Tag({
            Title = "v2.0 Monody",
            Icon = "solar:star-bold",
            Color = Color3.fromHex("#FF2A55"),
            Border = true,
        })
    end)

    -- 5. Build Wrapper Object
    local WinInstance = {
        Window = win,
        WindUI = WindUI,
        Tabs = {},
        Dependencies = dependencies,
        Cleanups = {},
    }

    function WinInstance:AddCleanup(fn)
        if type(fn) == "function" then
            table.insert(self.Cleanups, fn)
        end
    end

    function WinInstance:Destroy()
        for _, fn in ipairs(self.Cleanups) do
            pcall(fn)
        end
        self.Cleanups = {}
        if self.Window and self.Window.Destroy then
            pcall(function() self.Window:Destroy() end)
        end
        if getgenv then
            getgenv().DarlingHubWindow = nil
        end
    end

    -- Save to global env for hot-reload safety
    if getgenv then
        getgenv().DarlingHubWindow = win
    end
    _G.DarlingHubWindow = win

    -- Metatable delegation to allow direct calls on win (e.g. WinInstance:Tab(...))
    setmetatable(WinInstance, {
        __index = function(t, key)
            if win[key] then
                if type(win[key]) == "function" then
                    return function(_, ...)
                        return win[key](win, ...)
                    end
                end
                return win[key]
            end
            return rawget(t, key)
        end
    })

    return WinInstance
end

return WindowMod
