--[[
    ========================================================================
    BESTHUB - MONODY PREMIUM (BY DARLING)
    ========================================================================
    Official Repository: https://github.com/rivals-hash/idk
    Modular UI Engine with Mobile Touch & Responsive Scaling
    ========================================================================
]]

-- 1. Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    local startWait = tick()
    while not LocalPlayer and tick() - startWait < 3 do
        task.wait(0.05)
        LocalPlayer = Players.LocalPlayer
    end
end
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- 2. Executor Environment & Capabilities
local SharedEnv = (getgenv and getgenv()) or _G
local exRequest = request or http_request or (syn and syn.request) or (http and http.request)
local exWriteFile = writefile or (getgenv and getgenv().writefile) or (syn and syn.writefile)
local exReadFile = readfile or (getgenv and getgenv().readfile) or (syn and syn.readfile)
local exIsFile = isfile or is_file or (getgenv and getgenv().isfile) or (syn and syn.isfile)
local exIsFolder = isfolder or is_folder or (getgenv and getgenv().isfolder) or (syn and syn.isfolder)
local exMakeFolder = makefolder or make_folder or (getgenv and getgenv().makefolder) or (syn and syn.makefolder)

local CACHE_DIR = "BestHub"
local CACHE_SUBDIR = "BestHub/cache"
pcall(function()
    if exMakeFolder and exIsFolder then
        if not exIsFolder(CACHE_DIR) then exMakeFolder(CACHE_DIR) end
        if not exIsFolder(CACHE_SUBDIR) then exMakeFolder(CACHE_SUBDIR) end
    end
end)

-- 3. Unload previous instance
if SharedEnv.BestHub and type(SharedEnv.BestHub.Unload) == "function" then
    pcall(function() SharedEnv.BestHub:Unload() end)
    task.wait(0.1)
end

-- 4. Hub Core State
local BestHub = {
    Version = "2.0 (Mobile UI)",
    Author = "Darling",
    Modules = {},
    RepoBase = "https://raw.githubusercontent.com/rivals-hash/idk/main/"
}
SharedEnv.BestHub = BestHub
_G.BestHub = BestHub

-- 5. Universal HTTP Requester
local function universalHttpGet(url, timeout)
    timeout = timeout or 10
    local hdrs = { ["User-Agent"] = "Roblox/BestHub" }
    if exRequest then
        local ok, res = pcall(exRequest, {
            Url = url,
            Method = "GET",
            Timeout = timeout,
            Headers = hdrs
        })
        if ok and res and type(res) == "table" then
            local code = res.StatusCode or res.statusCode or res.Status or 200
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

-- 6. Dynamic Module Requester
local function readLocalDevModule(relPath)
    if not (exIsFile and exReadFile) then return nil end
    local candidates = {
        relPath,
        "idk/" .. relPath,
        "BestHub/" .. relPath
    }
    for _, p in ipairs(candidates) do
        local okF, exists = pcall(exIsFile, p)
        if okF and exists then
            local okR, content = pcall(exReadFile, p)
            if okR and type(content) == "string" and #content > 0 then
                return content
            end
        end
    end
    return nil
end

function BestHub:Require(relPath)
    if self.Modules[relPath] then
        return self.Modules[relPath]
    end

    -- 1. Fetch fresh code from GitHub with cache-busting
    local url = self.RepoBase .. relPath .. "?v=" .. tostring(os.time())
    local code = universalHttpGet(url) or universalHttpGet(self.RepoBase .. relPath)
    if code and exWriteFile then
        local diskPath = CACHE_SUBDIR .. "/" .. relPath:gsub("/", "_")
        pcall(exWriteFile, diskPath, code)
    end

    -- 2. Fallback to local files if offline
    if not code then
        code = readLocalDevModule(relPath)
    end

    -- 3. Fallback to cached disk file
    if not code and exIsFile and exReadFile then
        local diskPath = CACHE_SUBDIR .. "/" .. relPath:gsub("/", "_")
        local okF, exists = pcall(exIsFile, diskPath)
        if okF and exists then
            local okR, content = pcall(exReadFile, diskPath)
            if okR and type(content) == "string" and #content > 0 then
                code = content
            end
        end
    end

    if not code then
        warn("[BestHub] Failed to locate module: " .. tostring(relPath))
        return nil
    end

    local fn, err = loadstring(code)
    if not fn then
        warn("[BestHub] Syntax error in module " .. tostring(relPath) .. ": " .. tostring(err))
        return nil
    end

    local ok, mod = pcall(fn)
    if not ok then
        warn("[BestHub] Runtime error in module " .. tostring(relPath) .. ": " .. tostring(mod))
        return nil
    end

    self.Modules[relPath] = mod
    return mod
end

-- 7. Initialize UI Components
local Utils = BestHub:Require("modules/core/utils.lua")
local AssetManager = BestHub:Require("modules/core/asset_manager.lua")
if AssetManager and AssetManager.preload then
    pcall(function()
        AssetManager.preload({
            "header_profile_panel.png",
            "stats_panel_v2.png",
            "music_player.png",
            "sidebar_bg_v2.png",
            "sidebar_bg.png",
            "floating_avatar.png"
        })
    end)
end
local StatsService = BestHub:Require("modules/core/stats_service.lua")
local MusicEngine = BestHub:Require("modules/utility/music_engine.lua")
local MusicVisualizer = BestHub:Require("modules/ui/music_visualizer.lua")
local Sidebar = BestHub:Require("modules/ui/sidebar.lua")
local HomeView = BestHub:Require("modules/ui/home_view.lua")
local TabViews = BestHub:Require("modules/ui/tab_views.lua")
local MobileToggle = BestHub:Require("modules/ui/mobile_toggle.lua")
local FOV = BestHub:Require("modules/combat/fov.lua")
local AimbotCore = BestHub:Require("modules/combat/aimbot_core.lua")
local PlayerAimbot = BestHub:Require("modules/combat/player_aimbot.lua")
local NPCAimbot = BestHub:Require("modules/combat/npc_aimbot.lua")
local Blacklist = BestHub:Require("modules/combat/blacklist.lua")
local Tracers = BestHub:Require("modules/combat/tracers.lua")
local SilentAim = BestHub:Require("modules/combat/silent_aim.lua")
local SoruEngine = BestHub:Require("modules/combat/soru_engine.lua")
local Window = BestHub:Require("modules/ui/window.lua")

if not Window then
    warn("[BestHub] Critical: Could not load Window module.")
    return
end

local WinInstance = Window.create({
    Utils = Utils,
    StatsService = StatsService,
    MusicEngine = MusicEngine,
    MusicVisualizer = MusicVisualizer,
    Sidebar = Sidebar,
    HomeView = HomeView,
    TabViews = TabViews,
    MobileToggle = MobileToggle,
    AssetManager = AssetManager,
    FOV = FOV,
    AimbotCore = AimbotCore,
    PlayerAimbot = PlayerAimbot,
    NPCAimbot = NPCAimbot,
    Blacklist = Blacklist,
    Tracers = Tracers,
    SilentAim = SilentAim,
    SoruEngine = SoruEngine,
})
BestHub.Window = WinInstance

-- 8. Unload & Cleanup Handler
function BestHub:Unload()
    for _, mod in pairs(self.Modules) do
        if type(mod) == "table" then
            if mod.destroy then pcall(mod.destroy)
            elseif mod.disable then pcall(mod.disable)
            elseif mod.stop then pcall(mod.stop) end
        end
    end
    if MusicEngine and MusicEngine.stop then
        pcall(MusicEngine.stop)
    end
    if self.Window then
        if self.Window.MobileToggle and self.Window.MobileToggle.Parent then
            pcall(function() self.Window.MobileToggle:Destroy() end)
        end
        if self.Window.ScreenGui and self.Window.ScreenGui.Parent then
            pcall(function() self.Window.ScreenGui:Destroy() end)
        end
    end
    self.Modules = {}
end

-- 9. Welcome Toast
Utils.toast("Monody Premium", "Successfully loaded | By Darling", 3.0, AssetManager and AssetManager.get("avatar.png", "rbxassetid://93891873418133"))

return BestHub
