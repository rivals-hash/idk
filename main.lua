--[[
    Monody | Modular UI Foundation
    Liquid Glass Theme with Dynamic Themes, Static Wallpapers, and Combat Engine
    Author: Darling
    Repository: https://github.com/rivals-hash/idk
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")

local APP_TITLE = "Monody"
local APP_VERSION = "v3.3"
local APP_AUTHOR = "darling"
local DEFAULT_WALLPAPER_ID = "rbxassetid://103674761222554"
local DEFAULT_LOGO_ID = "rbxassetid://109687263098821"
local GITHUB_REPO_RAW = "https://raw.githubusercontent.com/rivals-hash/idk/main"

local FONT_ORDER = { "Gotham", "GothamBold", "GothamBlack", "SourceSans", "Code" }
local CurrentFontName = "Gotham"
local CurrentFont = Enum.Font.Gotham

local function ConnectButton(button, callback)
    if not button then return end
    pcall(function()
        button.Active = true
        button.Selectable = true
    end)

    local lastActivation = 0
    local function activate()
        local now = os.clock()
        if now - lastActivation < 0.28 then return end
        lastActivation = now
        if callback then
            task.spawn(function()
                local ok, err = pcall(callback)
                if not ok then
                    warn("[Monody] Button callback error: " .. tostring(err))
                end
            end)
        end
    end

    -- Layer 1: Roblox Activated event (PC click, gamepad, native touch tap)
    pcall(function()
        button.Activated:Connect(activate)
    end)

    -- Layer 2: MouseButton1Click (desktop mouse fallback)
    pcall(function()
        button.MouseButton1Click:Connect(activate)
    end)

    -- Layer 3: TouchTap (native mobile tap - only fires on tap, not drag)
    pcall(function()
        button.TouchTap:Connect(activate)
    end)

    -- Layer 4: Universal Synthetic Touch / Tap-vs-Swipe Filter
    -- Guarantees responsiveness on Android executors (Delta, Codex, Arceus X)
    -- while allowing smooth ScrollingFrame swipe gestures without false triggers.
    local touchStartPos = nil
    local touchStartTime = 0

    pcall(function()
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                touchStartPos = input.Position
                touchStartTime = os.clock()
            end
        end)
    end)

    pcall(function()
        button.InputEnded:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and touchStartPos then
                local dt = os.clock() - touchStartTime
                local dist = (input.Position - touchStartPos).Magnitude
                touchStartPos = nil
                if dt < 0.35 and dist < 14 then
                    activate()
                end
            end
        end)
    end)
end

local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera
local ScreenGui

-- Safe parent resolver (gethui / CoreGui / PlayerGui)
local parentGui = nil
pcall(function() if gethui then parentGui = gethui() end end)
if not parentGui then pcall(function() parentGui = CoreGui end) end
if not parentGui and lp then pcall(function() parentGui = lp:WaitForChild("PlayerGui", 5) end) end

-- Clean up any prior DarlingX instances to avoid ghost overlay frames
-- Restore native game HUD & remove any rogue UIScale on TouchGui/Mobile controls
pcall(function()
    local pGui = lp and (lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui"))
    if pGui then
        for _, gui in ipairs(pGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "Monody_UI" then
                for _, s in ipairs(gui:GetDescendants()) do
                    if s:IsA("UIScale") then
                        pcall(function() s:Destroy() end)
                    end
                end
            end
        end
    end
end)

pcall(function()
    local target = parentGui or (lp and lp:FindFirstChild("PlayerGui"))
    if target then
        for _, old in ipairs(target:GetChildren()) do
            if old.Name:find("DarlingX") then
                pcall(function() old:Destroy() end)
            end
        end
    end
end)

-- Global cleanup helper
local IsScriptRunning = true
local ActiveConnections = {}
local function trackConn(conn)
    if conn then table.insert(ActiveConnections, conn) end
    return conn
end

local function FormatNumber(n)
    if not n or type(n) ~= "number" then return tostring(n or "--") end
    if n >= 1000000000 then
        return string.format("%.2fB", n / 1000000000)
    elseif n >= 1000000 then
        return string.format("%.1fM", n / 1000000)
    elseif n >= 1000 then
        return string.format("%.1fK", n / 1000)
    else
        return tostring(math.floor(n))
    end
end

-- ============================================================
-- DYNAMIC THEME SYSTEM
-- ============================================================
local THEMES = {
    ["Purple"]   = Color3.fromRGB(138, 43, 226),
    ["Blue"]     = Color3.fromRGB(59, 130, 246),
    ["Pink"]     = Color3.fromRGB(236, 72, 153),
    ["Green"]    = Color3.fromRGB(16, 185, 129),
    ["Yellow"]   = Color3.fromRGB(234, 179, 8),
    ["Orange"]   = Color3.fromRGB(249, 115, 22),
    ["Red"]      = Color3.fromRGB(239, 68, 68),
    ["Cyan"]     = Color3.fromRGB(6, 182, 212),
    ["White"]    = Color3.fromRGB(255, 255, 255),
    ["Rainbow"]  = Color3.fromRGB(138, 43, 226),
}
local THEME_ORDER = { "Purple", "Blue", "Pink", "Green", "Yellow", "Orange", "Red", "Cyan", "White", "Rainbow" }
local CurrentThemeName = "White"
local CurrentAccent = THEMES.White
local IsRainbowTheme = false
local RainbowSpeed = 0.4

local ThemeStrokes = {}
local ThemeTexts = {}
local ThemeButtons = {}
local ThemeFills = {}
local ThemeImages = {}
local ActiveToggles = {}
local ToggleControls = {}

local function SetActiveToggle(toggle, active)
    if not toggle then return end
    if active then
        ActiveToggles[toggle] = true
        toggle.BackgroundColor3 = CurrentAccent
        toggle.BackgroundTransparency = 0.1
    else
        ActiveToggles[toggle] = nil
        toggle.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
        toggle.BackgroundTransparency = 0.5
    end
end

local function UpdateThemeColors()
    for _, stroke in ipairs(ThemeStrokes) do
        if stroke and stroke.Parent then stroke.Color = CurrentAccent end
    end
    for _, label in ipairs(ThemeTexts) do
        if label and label.Parent then label.TextColor3 = CurrentAccent end
    end
    for _, frame in ipairs(ThemeFills) do
        if frame and frame.Parent then frame.BackgroundColor3 = CurrentAccent end
    end
    for _, img in ipairs(ThemeImages) do
        if img and img.Parent then img.ImageColor3 = CurrentAccent end
    end
    for toggle, _ in pairs(ActiveToggles) do
        if toggle and toggle.Parent then toggle.BackgroundColor3 = CurrentAccent end
    end
end

local function RegisterThemeStroke(stroke)
    if not stroke then return end
    table.insert(ThemeStrokes, stroke)
    stroke.Color = CurrentAccent
    pcall(function() stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
end

local function RegisterThemeText(label)
    table.insert(ThemeTexts, label)
    label.TextColor3 = CurrentAccent
end

local function RegisterThemeFill(frame)
    table.insert(ThemeFills, frame)
    frame.BackgroundColor3 = CurrentAccent
end

local function RegisterThemeImage(img)
    if not img then return end
    table.insert(ThemeImages, img)
    pcall(function() img.ImageColor3 = CurrentAccent end)
end

local function ApplyFont(name)
    CurrentFontName = name
    CurrentFont = Enum.Font[name] or Enum.Font.Gotham
    for _, label in ipairs(ThemeTexts) do
        if label and label.Parent then label.Font = CurrentFont end
    end
end

local function ApplyTheme(name)
    if not THEMES[name] then return end
    CurrentThemeName = name
    IsRainbowTheme = (name == "Rainbow")
    if not IsRainbowTheme then
        CurrentAccent = THEMES[name]
        UpdateThemeColors()
    end
    if TriggerAutoSave then TriggerAutoSave() end
end


local function ResetTheme()
    ApplyTheme("White")
end

trackConn(RunService.Heartbeat:Connect(function()
    if not IsScriptRunning then return end
    if IsRainbowTheme then
        local hue = (os.clock() * RainbowSpeed) % 1
        CurrentAccent = Color3.fromHSV(hue, 0.85, 1)
        UpdateThemeColors()
    end
end))

-- ============================================================
-- ASSET RESOLVER & GETCUSTOMASSET PIPELINE
-- ============================================================
local exGetCustomAsset = getcustomasset or getsynasset or (syn and syn.get_custom_asset)
local exIsFile = isfile or is_file or (syn and syn.isfile)
local exWriteFile = writefile or (syn and syn.writefile)
local exMakeFolder = makefolder or make_folder or (syn and syn.makefolder)
local exRequest = request or http_request or (syn and syn.request) or (http and http.request)

local function SafeHttpGet(url)
    local okHttp, body = pcall(function()
        return game:HttpGet(url, true)
    end)
    if okHttp and type(body) == "string" and #body > 50 then
        return body
    end

    if exRequest then
        local okReq, res = pcall(exRequest, { Url = url, Method = "GET" })
        if okReq and type(res) == "table" then
            local b = res.Body or res.body
            if type(b) == "string" and #b > 50 then
                return b
            end
        end
    end
    return nil
end

local function ResolveCustomAsset(relativePath, fallbackAssetId)
    if not exGetCustomAsset or not exIsFile then
        return fallbackAssetId
    end

    local candidatePaths = {
        relativePath,
        "DarlingX/" .. relativePath,
        "DarlingX/assets/" .. relativePath:gsub("^assets/", ""),
        "assets/" .. relativePath:gsub("^assets/", ""),
        relativePath:gsub(".+/", "")
    }

    for _, path in ipairs(candidatePaths) do
        local okCheck, exists = pcall(exIsFile, path)
        if okCheck and exists then
            local okAsset, asset = pcall(exGetCustomAsset, path)
            if okAsset and type(asset) == "string" and #asset > 0 then
                return asset
            end
        end
    end

    return fallbackAssetId
end

local function ResolveAndBindAsset(filename, fallbackId, imageLabel)
    local localAsset = ResolveCustomAsset("assets/" .. filename, nil)
    if localAsset then
        if imageLabel and imageLabel.Parent then pcall(function() imageLabel.Image = localAsset end) end
        return localAsset
    end

    local cachedPath = "Monody/cache/" .. filename
    if exIsFile and exGetCustomAsset then
        local okC, existsC = pcall(exIsFile, cachedPath)
        if okC and existsC then
            local okA, asset = pcall(exGetCustomAsset, cachedPath)
            if okA and type(asset) == "string" and #asset > 0 then
                if imageLabel and imageLabel.Parent then pcall(function() imageLabel.Image = asset end) end
                return asset
            end
        end
    end

    if fallbackId and #fallbackId > 0 and imageLabel and imageLabel.Parent then
        pcall(function() imageLabel.Image = fallbackId end)
    end

    if exWriteFile and exGetCustomAsset then
        task.spawn(function()
            pcall(function()
                if exMakeFolder then
                    pcall(exMakeFolder, "Monody")
                    pcall(exMakeFolder, "Monody/cache")
                end
                local rawUrl = GITHUB_REPO_RAW .. "/assets/" .. filename
                local body = SafeHttpGet(rawUrl)
                if body and #body > 50 then
                    exWriteFile(cachedPath, body)
                    local okA, asset = pcall(exGetCustomAsset, cachedPath)
                    if okA and type(asset) == "string" and #asset > 0 and imageLabel and imageLabel.Parent then
                        imageLabel.Image = asset
                    end
                end
            end)
        end)
    end

    return fallbackId or ""
end

-- Cached permanent Darling Hub logo asset
local CachedLogoAsset = nil
local function GetLogoAsset()
    if CachedLogoAsset then return CachedLogoAsset end

    -- 1. Try local custom user logo first
    local userCustomLogo = ResolveCustomAsset("assets/logo.jpg", nil)
    if userCustomLogo then
        CachedLogoAsset = userCustomLogo
        return userCustomLogo
    end

    -- 2. Check local executor cache
    local cachedPath = "Monody/cache/user_logo.jpg"
    if exIsFile and exGetCustomAsset then
        local okCheck, exists = pcall(exIsFile, cachedPath)
        if okCheck and exists then
            local okAsset, asset = pcall(exGetCustomAsset, cachedPath)
            if okAsset and type(asset) == "string" and #asset > 0 then
                CachedLogoAsset = asset
                return asset
            end
        end
    end

    -- 3. Download from repository
    if exWriteFile and exGetCustomAsset then
        local logoUrl = GITHUB_REPO_RAW .. "/assets/logo.jpg"
        local body = SafeHttpGet(logoUrl)
        if body and #body > 50 then
            pcall(function()
                if exMakeFolder then
                    pcall(exMakeFolder, "Monody")
                    pcall(exMakeFolder, "Monody/cache")
                end
                exWriteFile(cachedPath, body)
            end)
            local okAsset, asset = pcall(exGetCustomAsset, cachedPath)
            if okAsset and type(asset) == "string" and #asset > 0 then
                CachedLogoAsset = asset
                return asset
            end
        end
    end

    CachedLogoAsset = DEFAULT_LOGO_ID
    return DEFAULT_LOGO_ID
end

local CachedCreatorAsset = nil
local function GetCreatorAsset()
    if CachedCreatorAsset then return CachedCreatorAsset end
    local localAsset = ResolveCustomAsset("assets/darling_creator.png", nil)
    if localAsset then
        CachedCreatorAsset = localAsset
        return localAsset
    end

    local cachedPath = "DarlingX/cache/darling_creator.png"
    if exIsFile and exGetCustomAsset then
        local okCheck, exists = pcall(exIsFile, cachedPath)
        if okCheck and exists then
            local okAsset, asset = pcall(exGetCustomAsset, cachedPath)
            if okAsset and type(asset) == "string" and #asset > 0 then
                CachedCreatorAsset = asset
                return asset
            end
        end
    end

    if exWriteFile and exGetCustomAsset then
        task.spawn(function()
            pcall(function()
                if exMakeFolder then
                    pcall(exMakeFolder, "DarlingX")
                    pcall(exMakeFolder, "DarlingX/cache")
                end
                local rawUrl = GITHUB_REPO_RAW .. "/assets/darling_creator.png"
                local body = SafeHttpGet(rawUrl)
                if body and #body > 50 then
                    exWriteFile(cachedPath, body)
                end
            end)
        end)
    end

    CachedCreatorAsset = DEFAULT_LOGO_ID
    return DEFAULT_LOGO_ID
end

-- ============================================================
-- MODULE LOADER (Remote-First with Disk Fallback)
-- ============================================================
local LoadedModules = {}

pcall(function()
    local delFn = delfile or (syn and syn.delfile)
    local isfileFn = isfile or exIsFile
    if delFn and isfileFn then
        local staleFiles = {
            "DarlingHub/cache/modules_ui_loading_screen.lua",
            "BestHub/cache/modules_ui_loading_screen.lua",
            "DarlingHub/loading_screen.lua",
            "DarlingHub/cache/modules_ui_window.lua",
            "DarlingHub/cache/modules_ui_sidebar.lua",
            "DarlingHub/cache/modules_ui_tab_views.lua",
        }
        for _, p in ipairs(staleFiles) do
            if isfileFn(p) then pcall(delFn, p) end
        end
    end
end)

pcall(function()
    local delFn = delfile or (syn and syn.delfile)
    local isfileFn = isfile or exIsFile
    if delFn and isfileFn then
        local staleFiles = {
            "DarlingX/modules/pvp/fast_attack.lua",
            "DarlingX/modules/pvp/camlock.lua",
            "DarlingX/modules/pvp/extra_widgets.lua"
        }
        for _, f in ipairs(staleFiles) do
            if isfileFn(f) then pcall(delFn, f) end
        end
    end
end)

local function RequireModule(relPath)
    if LoadedModules[relPath] then
        return LoadedModules[relPath]
    end

    -- 1. Fresh remote fetch from GitHub first (guarantees latest updates without stale executor cache)
    local cacheBuster = tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))
    local remoteUrl = GITHUB_REPO_RAW .. "/" .. relPath .. "?t=" .. cacheBuster
    local body = SafeHttpGet(remoteUrl)
    if body and #body > 50 then
        local okCompile, fn = pcall(loadstring, body)
        if okCompile and fn then
            local okRun, result = pcall(fn)
            if okRun and result then
                LoadedModules[relPath] = result
                pcall(function()
                    if exIsFolder and exMakeFolder and not exIsFolder("DarlingX") then exMakeFolder("DarlingX") end
                    if exWriteFile then exWriteFile("DarlingX/" .. relPath, body) end
                end)
                return result
            end
        end
    end

    -- 2. Fallback to local file on disk if offline or in local test environment
    local candidatePaths = {
        relPath,
        "DarlingX/" .. relPath,
        "assets/" .. relPath,
        "modules/" .. relPath:gsub("^modules/", ""),
        "darling-hub/" .. relPath
    }

    local isfileFn = isfile or exIsFile
    local readfileFn = readfile or (syn and syn.readfile)
    if isfileFn and readfileFn then
        for _, path in ipairs(candidatePaths) do
            local okCheck, exists = pcall(isfileFn, path)
            if okCheck and exists then
                local okRead, content = pcall(readfileFn, path)
                if okRead and content and #content > 0 then
                    local okCompile, fn = pcall(loadstring, content)
                    if okCompile and fn then
                        local okRun, result = pcall(fn)
                        if okRun and result then
                            LoadedModules[relPath] = result
                            return result
                        end
                    end
                end
            end
        end
    end

    return nil
end

-- Compatibility bridge for combat modules
_G.DarlingX = {
    Settings = {
        Aim = {
            Priority = "Nearest",
            Mode = "360",
            MaxRange = 1000,
            TargetPart = "HumanoidRootPart"
        },
        FOV = {
            Radius = 100,
            Mode = "Center",
            Color = Color3.fromRGB(255, 255, 255)
        },
        Tracers = {
            Type = "Both",
            Origin = "Player",
            Color = Color3.fromRGB(255, 255, 255)
        },
        Blacklist = {
            Melee = {},
            Sword = {},
            Fruit = {},
            Gun = {}
        }
    },
    Require = function(self, path)
        return RequireModule(path)
    end
}
_G.DarlingHub = _G.DarlingX
_G.RequireModule = RequireModule
if getgenv then
    pcall(function()
        getgenv().DarlingX = _G.DarlingX
        getgenv().DarlingHub = _G.DarlingX
        getgenv().RequireModule = RequireModule
    end)
end

-- ============================================================
-- WINDUI LUCIDE ICONS INTEGRATION
-- ============================================================
local WindUIIcons = nil
task.spawn(function()
    pcall(function()
        local iconSrc = SafeHttpGet("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua")
        if iconSrc and #iconSrc > 50 then
            WindUIIcons = loadstring(iconSrc)()
            task.defer(function()
                if DockButtons and TABS_MANIFEST then
                    for tabId, dbtn in pairs(DockButtons) do
                        if dbtn and dbtn.icon then
                            for _, m in ipairs(TABS_MANIFEST) do
                                if m.id == tabId then
                                    ApplyTabIcon(dbtn.icon, tabId, m.icon)
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

local WINDUI_LUCIDE_FALLBACK = {
    Home          = "rbxassetid://98755624629571",   -- Lucide: house
    Aimbot        = "rbxassetid://134242818164054",  -- Lucide: crosshair
    Players       = "rbxassetid://115398113982385",  -- Lucide: users
    PvP           = "rbxassetid://81872698913435",   -- Lucide: swords
    Soru          = "rbxassetid://130551565616516",  -- Lucide: zap
    AutoBounty    = "rbxassetid://137726256442333",  -- Lucide: skull
    Dungeon       = "rbxassetid://98218034436456",   -- Lucide: flame
    Teleport      = "rbxassetid://84279202219901",   -- Lucide: map-pin
    ControlPeople = "rbxassetid://92483947987410",   -- Lucide: gamepad-2
    StealFruits   = "rbxassetid://104349242902442",  -- Lucide: apple
    apple         = "rbxassetid://104349242902442",
    cherry        = "rbxassetid://104349242902442",
    HUD           = "rbxassetid://139929981863901",  -- Lucide: layout-dashboard
    Macro         = "rbxassetid://80451686744860",   -- Lucide: bot
    Visuals       = "rbxassetid://100033680381365",  -- Lucide: eye
    Esp           = "rbxassetid://100033680381365",  -- Lucide: eye
    ESP           = "rbxassetid://100033680381365",  -- Lucide: eye
    Skins         = "rbxassetid://112904952151156",  -- Lucide: gem (Diamante místico / Skin changer)
    Music         = "rbxassetid://118833729589183",  -- Lucide: headphones (Audífonos gamer modernos)
    Animations    = "rbxassetid://138635884129147",  -- Lucide: sparkles
    Config        = "rbxassetid://85538382643347",   -- Lucide: sliders-horizontal
    Misc          = "rbxassetid://85538382643347",   -- Lucide: sliders-horizontal
    Settings      = "rbxassetid://86350350950064",   -- Lucide: palette
    Themes        = "rbxassetid://86350350950064",   -- Lucide: palette
}

local function ApplyTabIcon(imageLabel, tabKey, lucideName)
    pcall(function()
        local fallbackId = WINDUI_LUCIDE_FALLBACK[tabKey] or "rbxassetid://98755624629571"
        imageLabel.Image = fallbackId

        if WindUIIcons and WindUIIcons.GetIcon then
            local ok, iconData = pcall(function() return WindUIIcons.GetIcon(lucideName, "lucide") end)
            if ok and iconData then
                if type(iconData) == "string" and string.find(iconData, "rbxassetid://") then
                    imageLabel.Image = iconData
                elseif type(iconData) == "table" and iconData[1] then
                    imageLabel.Image = iconData[1]
                    if type(iconData[2]) == "table" and iconData[2].ImageRectSize then
                        imageLabel.ImageRectSize = iconData[2].ImageRectSize
                        imageLabel.ImageRectOffset = iconData[2].ImageRectPosition or Vector2.new(0, 0)
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- WALLPAPERS ENGINE (STATIC DARLING HUB ASSETS)
-- ============================================================
local WALLPAPERS = {
    { name = "Clean Dark Glass (Default)", file = nil, id = "" },
    { name = "Ashen One", file = nil, id = DEFAULT_WALLPAPER_ID },
    { name = "2000s Hacker Room", file = "hacker_room.jpg", id = DEFAULT_WALLPAPER_ID },
    { name = "Lycoris Monochrome", file = "lycoris_monochrome.jpg", id = "rbxassetid://129497751007547" },
    { name = "Cyan Neko", file = "cyan_neko.jpg", id = "rbxassetid://122087867919987" },
    { name = "Frieren Beyond Journey", file = "frieren.jpg", id = "rbxassetid://129497751007547" },
    { name = "Cyberpunk Megalopolis", file = "cyberpunk_megalopolis.jpg", id = "rbxassetid://122087867919987" },
    { name = "Green Night Driving", file = "green_night_driving.jpg", id = "rbxassetid://127123211876541" },
    { name = "Monika Lonely", file = "monika_lonely.jpg", id = DEFAULT_WALLPAPER_ID },
    { name = "Neon Purple Midnight", file = "purple_midnight.jpg", id = "rbxassetid://129497751007547" },
    { name = "Persona 5 Rainy Tokyo", file = "persona_5_rainy.jpg", id = "rbxassetid://122087867919987" },
    { name = "Rainy Tokyo", file = "rainy_tokyo.jpg", id = "rbxassetid://127123211876541" },
    { name = "Shorekeeper Blue Sea", file = "shorekeeper.jpg", id = "rbxassetid://129497751007547" },
    { name = "Skirk Neko Genshin", file = "skirk_neko.jpg", id = "rbxassetid://122087867919987" },
    { name = "Snowy Cozy Bedroom", file = "snowy_bedroom.jpg", id = DEFAULT_WALLPAPER_ID },
    { name = "Snowy Forest", file = "snowy_forest.jpg", id = "rbxassetid://129497751007547" },
    { name = "Dark River Forest", file = "dark_river_forest.jpg", id = "rbxassetid://122087867919987" },
    { name = "Witch Cauldron Halloween", file = "witch_cauldron.jpg", id = "rbxassetid://127123211876541" },
    { name = "Deepseek Chan", file = "deepseek_chan.jpg", id = "rbxassetid://129497751007547" },
    { name = "Yuta Cursed Blade", file = "yuta_blade.jpg", id = "rbxassetid://122087867919987" },
    { name = "Zankou Neverness", file = "zankou_nte.jpg", id = DEFAULT_WALLPAPER_ID },
    { name = "Anime Theme 1", file = nil, id = "rbxassetid://129497751007547" },
    { name = "Anime Theme 3", file = nil, id = "rbxassetid://122087867919987" },
    { name = "Anime Theme 4", file = nil, id = "rbxassetid://127123211876541" },
}
local currentBgIdx = 1
local ResolvedWallpaperCache = {}

local function ResolveWallpaperAsset(wp)
    if not wp then return DEFAULT_WALLPAPER_ID end
    if wp.id == "" then return "" end

    if ResolvedWallpaperCache[wp.name] then
        return ResolvedWallpaperCache[wp.name]
    end

    if wp.file then
        local localAsset = ResolveCustomAsset("assets/backgrounds/" .. wp.file, nil)
        if localAsset then
            ResolvedWallpaperCache[wp.name] = localAsset
            return localAsset
        end

        if exGetCustomAsset and exIsFile then
            local cachedPath = "DarlingX/cache/" .. wp.file
            local okC, existsC = pcall(exIsFile, cachedPath)
            if okC and existsC then
                local okA, asset = pcall(exGetCustomAsset, cachedPath)
                if okA and type(asset) == "string" and #asset > 0 then
                    ResolvedWallpaperCache[wp.name] = asset
                    return asset
                end
            end

            local flatPath = "darling_bg_" .. wp.file
            local okF, existsF = pcall(exIsFile, flatPath)
            if okF and existsF then
                local okA, asset = pcall(exGetCustomAsset, flatPath)
                if okA and type(asset) == "string" and #asset > 0 then
                    ResolvedWallpaperCache[wp.name] = asset
                    return asset
                end
            end
        end

        if exWriteFile and exGetCustomAsset then
            local cachedPath = "DarlingX/cache/" .. wp.file
            pcall(function()
                if exMakeFolder then
                    pcall(exMakeFolder, "DarlingX")
                    pcall(exMakeFolder, "DarlingX/cache")
                end
                local rawUrl = GITHUB_REPO_RAW .. "/assets/backgrounds/" .. wp.file
                local body = SafeHttpGet(rawUrl)
                if body and #body > 50 then
                    exWriteFile(cachedPath, body)
                end
            end)
            local okAsset, asset = pcall(exGetCustomAsset, cachedPath)
            if okAsset and type(asset) == "string" and #asset > 0 then
                ResolvedWallpaperCache[wp.name] = asset
                return asset
            end

            local flatPath = "darling_bg_" .. wp.file
            pcall(function()
                local rawUrl = GITHUB_REPO_RAW .. "/assets/backgrounds/" .. wp.file
                local body = SafeHttpGet(rawUrl)
                if body and #body > 50 then
                    exWriteFile(flatPath, body)
                end
            end)
            local okFlat, flatAsset = pcall(exGetCustomAsset, flatPath)
            if okFlat and type(flatAsset) == "string" and #flatAsset > 0 then
                ResolvedWallpaperCache[wp.name] = flatAsset
                return flatAsset
            end
        end
    end

    local fallback = wp.id or DEFAULT_WALLPAPER_ID
    ResolvedWallpaperCache[wp.name] = fallback
    return fallback
end

local uiReadyToOpen = false

-- ============================================================
-- INLINED BORDERLESS LOADING SCREEN (Zero red borders)
-- ============================================================
local InlineLoader = {
    ScreenGui = nil,
    FillBar = nil,
    StatusLabel = nil,
    PercentLabel = nil,
    LogoImage = nil,
    TrackFrame = nil,
    TitleLabel = nil,
    IsActive = false,
}

function InlineLoader.show(logoAsset)
    if InlineLoader.IsActive and InlineLoader.ScreenGui then return end
    InlineLoader.IsActive = true

    local parent = parentGui or (gethui and gethui()) or (CoreGui) or (lp and lp:FindFirstChildOfClass("PlayerGui"))
    if not parent then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "Monody_LoadingScreen"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)

    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end

    local root = Instance.new("Frame")
    root.Name = "Root"
    root.Size = UDim2.new(1, 0, 1, 0)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.Parent = gui

    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Size = UDim2.new(0, 360, 0, 220)
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.new(0.5, 0, 0.5, 0)
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.Parent = root

    local logoContainer = Instance.new("Frame")
    logoContainer.Name = "LogoContainer"
    logoContainer.Size = UDim2.new(0, 72, 0, 72)
    logoContainer.AnchorPoint = Vector2.new(0.5, 0)
    logoContainer.Position = UDim2.new(0.5, 0, 0, 15)
    logoContainer.BackgroundTransparency = 1
    logoContainer.BorderSizePixel = 0
    logoContainer.Parent = card

    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(1, 0, 1, 0)
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Position = UDim2.new(0.5, 0, 0.5, 0)
    logo.BackgroundTransparency = 1
    logo.ImageTransparency = 1
    logo.BorderSizePixel = 0
    logo.Image = logoAsset or GetLogoAsset()
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = logoContainer

    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 16)
    logoCorner.Parent = logo

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 0, 22)
    title.AnchorPoint = Vector2.new(0.5, 0)
    title.Position = UDim2.new(0.5, 0, 0, 92)
    title.BackgroundTransparency = 1
    title.TextTransparency = 1
    title.BorderSizePixel = 0
    title.Font = Enum.Font.GothamBold
    title.Text = APP_TITLE
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 19
    title.Parent = card

    local subTitle = Instance.new("TextLabel")
    subTitle.Name = "SubTitle"
    subTitle.Size = UDim2.new(1, -40, 0, 14)
    subTitle.AnchorPoint = Vector2.new(0.5, 0)
    subTitle.Position = UDim2.new(0.5, 0, 0, 114)
    subTitle.BackgroundTransparency = 1
    subTitle.TextTransparency = 1
    subTitle.BorderSizePixel = 0
    subTitle.Font = Enum.Font.GothamMedium
    subTitle.Text = "by darling"
    subTitle.TextColor3 = Color3.fromRGB(190, 185, 205)
    subTitle.TextSize = 11
    subTitle.Parent = card

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, -40, 0, 16)
    status.AnchorPoint = Vector2.new(0.5, 0)
    status.Position = UDim2.new(0.5, 0, 0, 130)
    status.BackgroundTransparency = 1
    status.TextTransparency = 1
    status.BorderSizePixel = 0
    status.Font = Enum.Font.GothamMedium
    status.Text = "Starting " .. APP_TITLE .. "..."
    status.TextColor3 = Color3.fromRGB(165, 160, 175)
    status.TextSize = 12
    status.Parent = card

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(0, 240, 0, 4)
    track.AnchorPoint = Vector2.new(0.5, 0)
    track.Position = UDim2.new(0.5, 0, 0, 146)
    track.BackgroundColor3 = Color3.fromRGB(28, 26, 34)
    track.BackgroundTransparency = 1
    track.BorderSizePixel = 0
    track.Parent = card

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(220, 225, 238)
    fill.BackgroundTransparency = 1
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(245, 245, 252)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(175, 180, 195)),
    })
    fillGradient.Parent = fill

    local percent = Instance.new("TextLabel")
    percent.Name = "Percent"
    percent.Size = UDim2.new(1, -40, 0, 16)
    percent.AnchorPoint = Vector2.new(0.5, 0)
    percent.Position = UDim2.new(0.5, 0, 0, 158)
    percent.BackgroundTransparency = 1
    percent.TextTransparency = 1
    percent.BorderSizePixel = 0
    percent.Font = Enum.Font.GothamBold
    percent.Text = "0%"
    percent.TextColor3 = Color3.fromRGB(225, 228, 238)
    percent.TextSize = 12
    percent.Parent = card

    gui.Parent = parent

    InlineLoader.ScreenGui = gui
    InlineLoader.FillBar = fill
    InlineLoader.StatusLabel = status
    InlineLoader.PercentLabel = percent
    InlineLoader.LogoImage = logo
    InlineLoader.TrackFrame = track
    InlineLoader.TitleLabel = title

    local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(logo, tweenInfo, { ImageTransparency = 0 }):Play()
    TweenService:Create(title, tweenInfo, { TextTransparency = 0 }):Play()
    TweenService:Create(subTitle, tweenInfo, { TextTransparency = 0 }):Play()
    TweenService:Create(status, tweenInfo, { TextTransparency = 0 }):Play()
    TweenService:Create(track, tweenInfo, { BackgroundTransparency = 0.45 }):Play()
    TweenService:Create(fill, tweenInfo, { BackgroundTransparency = 0 }):Play()
    TweenService:Create(percent, tweenInfo, { TextTransparency = 0 }):Play()
end

function InlineLoader.update(progress, text)
    if not InlineLoader.IsActive or not InlineLoader.FillBar then return end
    progress = math.clamp(tonumber(progress) or 0, 0, 1)

    if text and InlineLoader.StatusLabel then
        InlineLoader.StatusLabel.Text = tostring(text)
    end
    if InlineLoader.PercentLabel then
        InlineLoader.PercentLabel.Text = tostring(math.floor(progress * 100)) .. "%"
    end
    TweenService:Create(InlineLoader.FillBar, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(progress, 0, 1, 0)
    }):Play()
end

function InlineLoader.finish(callback)
    if not InlineLoader.IsActive then
        if callback then pcall(callback) end
        return
    end

    InlineLoader.update(1.0, "Ready")
    task.wait(0.2)

    local exitInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local tweens = {}
    if InlineLoader.LogoImage then table.insert(tweens, TweenService:Create(InlineLoader.LogoImage, exitInfo, { ImageTransparency = 1 })) end
    if InlineLoader.TitleLabel then table.insert(tweens, TweenService:Create(InlineLoader.TitleLabel, exitInfo, { TextTransparency = 1 })) end
    if InlineLoader.StatusLabel then table.insert(tweens, TweenService:Create(InlineLoader.StatusLabel, exitInfo, { TextTransparency = 1 })) end
    if InlineLoader.TrackFrame then table.insert(tweens, TweenService:Create(InlineLoader.TrackFrame, exitInfo, { BackgroundTransparency = 1 })) end
    if InlineLoader.FillBar then table.insert(tweens, TweenService:Create(InlineLoader.FillBar, exitInfo, { BackgroundTransparency = 1 })) end
    if InlineLoader.PercentLabel then table.insert(tweens, TweenService:Create(InlineLoader.PercentLabel, exitInfo, { TextTransparency = 1 })) end

    for _, tw in ipairs(tweens) do tw:Play() end

    task.delay(0.32, function()
        if InlineLoader.ScreenGui then
            pcall(function() InlineLoader.ScreenGui:Destroy() end)
        end
        InlineLoader.ScreenGui = nil
        InlineLoader.FillBar = nil
        InlineLoader.StatusLabel = nil
        InlineLoader.PercentLabel = nil
        InlineLoader.LogoImage = nil
        InlineLoader.TrackFrame = nil
        InlineLoader.TitleLabel = nil
        InlineLoader.IsActive = false
        if callback then pcall(callback) end
    end)
end

-- ============================================================
-- AURORA X KEY SYSTEM ENGINE (Project: 1b56de61f463fc8d4cd4d1dca6e26660)
-- ============================================================
local function getAuroraX()
    local ok, sdk = pcall(function()
        return loadstring(game:HttpGet("https://dev.aurorax.site/api/sdk/1b56de61f463fc8d4cd4d1dca6e26660.lua", true))()
    end)
    if ok and sdk and type(sdk) == "table" then
        return sdk
    end
    return nil
end

local function showKeyModal(AuroraX, onSuccess)
    local parent = parentGui or (gethui and gethui()) or (CoreGui) or (lp and lp:FindFirstChildOfClass("PlayerGui"))
    if not parent then
        if onSuccess then onSuccess() end
        return
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "Monody_KeySystem"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 10000000
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)

    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end

    -- Backdrop (Deep luxury dark glass overlay)
    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(6, 4, 12)
    backdrop.BackgroundTransparency = 0.3
    backdrop.BorderSizePixel = 0
    backdrop.Parent = gui

    -- Ambient purple glow in center behind modal
    local ambientGlow = Instance.new("ImageLabel", backdrop)
    ambientGlow.Name = "AmbientGlow"
    ambientGlow.Size = UDim2.new(0, 560, 0, 420)
    ambientGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    ambientGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    ambientGlow.BackgroundTransparency = 1
    ambientGlow.Image = "rbxassetid://1316045217"
    ambientGlow.ImageColor3 = Color3.fromRGB(147, 51, 234)
    ambientGlow.ImageTransparency = 0.72

    -- Modal Container (Luxury acrylic glass card with gradient neon stroke)
    local modal = Instance.new("Frame")
    modal.Name = "Modal"
    modal.Size = UDim2.new(0, 360, 0, 230)
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.Position = UDim2.new(0.5, 0, 0.5, 0)
    modal.BackgroundColor3 = Color3.fromRGB(14, 11, 22)
    modal.BackgroundTransparency = 0.15
    modal.BorderSizePixel = 0
    modal.ClipsDescendants = true
    modal.Parent = gui

    local modalCorner = Instance.new("UICorner")
    modalCorner.CornerRadius = UDim.new(0, 16)
    modalCorner.Parent = modal

    -- Gradient Border
    local modalStroke = Instance.new("UIStroke")
    modalStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    modalStroke.Color = Color3.fromRGB(168, 85, 247)
    modalStroke.Thickness = 1.2
    modalStroke.Parent = modal

    local strokeGrad = Instance.new("UIGradient", modalStroke)
    strokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(192, 132, 252)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(147, 51, 234)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(99, 102, 241))
    })
    strokeGrad.Rotation = 45

    -- Top Accent Glow Line
    local topGlow = Instance.new("Frame", modal)
    topGlow.Name = "TopGlow"
    topGlow.Size = UDim2.new(0.65, 0, 0, 2)
    topGlow.AnchorPoint = Vector2.new(0.5, 0)
    topGlow.Position = UDim2.new(0.5, 0, 0, 1)
    topGlow.BackgroundColor3 = Color3.fromRGB(192, 132, 252)
    topGlow.BorderSizePixel = 0
    local topGlowGrad = Instance.new("UIGradient", topGlow)
    topGlowGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1)
    })

    -- Header Icon & Badge
    local logoBadge = Instance.new("Frame", modal)
    logoBadge.Name = "LogoBadge"
    logoBadge.Size = UDim2.new(0, 48, 0, 48)
    logoBadge.AnchorPoint = Vector2.new(0.5, 0)
    logoBadge.Position = UDim2.new(0.5, 0, 0, 16)
    logoBadge.BackgroundColor3 = Color3.fromRGB(24, 18, 38)
    logoBadge.BackgroundTransparency = 0.3
    Instance.new("UICorner", logoBadge).CornerRadius = UDim.new(0, 13)

    local lbStroke = Instance.new("UIStroke", logoBadge)
    lbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    lbStroke.Color = Color3.fromRGB(147, 51, 234)
    lbStroke.Thickness = 1

    local logo = Instance.new("ImageLabel", logoBadge)
    logo.Name = "Logo"
    logo.Size = UDim2.new(1, -10, 1, -10)
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Position = UDim2.new(0.5, 0, 0.5, 0)
    logo.BackgroundTransparency = 1
    logo.Image = GetLogoAsset()
    logo.ScaleType = Enum.ScaleType.Fit
    Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 9)

    -- Title
    local title = Instance.new("TextLabel", modal)
    title.Size = UDim2.new(1, -30, 0, 22)
    title.Position = UDim2.new(0, 15, 0, 70)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = APP_TITLE
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 19
    title.TextXAlignment = Enum.TextXAlignment.Center

    -- Security Pill Subtitle
    local sub = Instance.new("TextLabel", modal)
    sub.Size = UDim2.new(1, -30, 0, 16)
    sub.Position = UDim2.new(0, 15, 0, 94)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.GothamMedium
    sub.Text = "MONODY LICENSE AUTHENTICATION"
    sub.TextColor3 = Color3.fromRGB(192, 132, 252)
    sub.TextSize = 9.5
    sub.TextXAlignment = Enum.TextXAlignment.Center

    -- Key Input Container (Glass Capsule with Key Icon and Paste Button)
    local inputContainer = Instance.new("Frame", modal)
    inputContainer.Size = UDim2.new(1, -40, 0, 38)
    inputContainer.AnchorPoint = Vector2.new(0.5, 0)
    inputContainer.Position = UDim2.new(0.5, 0, 0, 120)
    inputContainer.BackgroundColor3 = Color3.fromRGB(22, 17, 34)
    inputContainer.BackgroundTransparency = 0.35
    Instance.new("UICorner", inputContainer).CornerRadius = UDim.new(0, 9)

    local inStroke = Instance.new("UIStroke", inputContainer)
    inStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    inStroke.Color = Color3.fromRGB(85, 65, 120)
    inStroke.Thickness = 1

    local keyIcon = Instance.new("ImageLabel", inputContainer)
    keyIcon.Size = UDim2.new(0, 18, 0, 18)
    keyIcon.Position = UDim2.new(0, 10, 0.5, -9)
    keyIcon.BackgroundTransparency = 1
    keyIcon.Image = "rbxassetid://130551565616516"
    keyIcon.ImageColor3 = Color3.fromRGB(192, 132, 252)

    local keyBox = Instance.new("TextBox", inputContainer)
    keyBox.Size = UDim2.new(1, -78, 1, 0)
    keyBox.Position = UDim2.new(0, 32, 0, 0)
    keyBox.BackgroundTransparency = 1
    keyBox.Font = Enum.Font.GothamMedium
    keyBox.Text = (AuroraX and AuroraX.GetSavedKey and AuroraX.GetSavedKey()) or ""
    keyBox.PlaceholderText = "Paste your license key here..."
    keyBox.PlaceholderColor3 = Color3.fromRGB(130, 120, 150)
    keyBox.TextColor3 = Color3.fromRGB(245, 245, 255)
    keyBox.TextSize = 11.5
    keyBox.ClearTextOnFocus = false
    keyBox.TextXAlignment = Enum.TextXAlignment.Left

    local pasteBtn = Instance.new("TextButton", inputContainer)
    pasteBtn.Name = "PasteBtn"
    pasteBtn.Size = UDim2.new(0, 42, 0, 24)
    pasteBtn.Position = UDim2.new(1, -48, 0.5, -12)
    pasteBtn.BackgroundColor3 = Color3.fromRGB(35, 26, 52)
    pasteBtn.Text = ""
    pasteBtn.AutoButtonColor = false
    Instance.new("UICorner", pasteBtn).CornerRadius = UDim.new(0, 6)

    local pbStroke = Instance.new("UIStroke", pasteBtn)
    pbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    pbStroke.Color = Color3.fromRGB(120, 90, 170)
    pbStroke.Thickness = 0.8

    local pbLbl = Instance.new("TextLabel", pasteBtn)
    pbLbl.Size = UDim2.new(1, 0, 1, 0)
    pbLbl.BackgroundTransparency = 1
    pbLbl.Font = Enum.Font.GothamBold
    pbLbl.Text = "Paste"
    pbLbl.TextColor3 = Color3.fromRGB(216, 180, 254)
    pbLbl.TextSize = 9.5

    pasteBtn.MouseButton1Click:Connect(function()
        local getcb = getclipboard or get_clipboard
        if getcb then
            local clip = getcb()
            if clip and type(clip) == "string" and #clip > 0 then
                keyBox.Text = clip:gsub("^%s+", ""):gsub("%s+$", "")
            end
        end
    end)

    -- Status Feedback Label
    local feedback = Instance.new("TextLabel", modal)
    feedback.Size = UDim2.new(1, -40, 0, 16)
    feedback.AnchorPoint = Vector2.new(0.5, 0)
    feedback.Position = UDim2.new(0.5, 0, 0, 166)
    feedback.BackgroundTransparency = 1
    feedback.Font = Enum.Font.GothamMedium
    feedback.Text = "Awaiting license key verification..."
    feedback.TextColor3 = Color3.fromRGB(165, 155, 185)
    feedback.TextSize = 10.5
    feedback.TextXAlignment = Enum.TextXAlignment.Center

    -- Buttons Frame
    local btnRow = Instance.new("Frame", modal)
    btnRow.Size = UDim2.new(1, -40, 0, 36)
    btnRow.AnchorPoint = Vector2.new(0.5, 0)
    btnRow.Position = UDim2.new(0.5, 0, 0, 192)
    btnRow.BackgroundTransparency = 1

    -- 1. Get Key Button
    local getKeyBtn = Instance.new("TextButton", btnRow)
    getKeyBtn.Size = UDim2.new(0.48, 0, 1, 0)
    getKeyBtn.Position = UDim2.new(0, 0, 0, 0)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(28, 22, 42)
    getKeyBtn.BackgroundTransparency = 0.25
    getKeyBtn.Text = ""
    getKeyBtn.AutoButtonColor = false
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 9)

    local gkStroke = Instance.new("UIStroke", getKeyBtn)
    gkStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    gkStroke.Color = Color3.fromRGB(105, 80, 150)
    gkStroke.Thickness = 1

    local gkLbl = Instance.new("TextLabel", getKeyBtn)
    gkLbl.Size = UDim2.new(1, 0, 1, 0)
    gkLbl.BackgroundTransparency = 1
    gkLbl.Font = Enum.Font.GothamBold
    gkLbl.Text = "Get Key"
    gkLbl.TextColor3 = Color3.fromRGB(220, 205, 245)
    gkLbl.TextSize = 11.5

    getKeyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if AuroraX and AuroraX.CopyKeyLink then
                AuroraX.CopyKeyLink()
            else
                local setcb = setclipboard or toclipboard or set_clipboard
                if setcb then setcb("https://dev.aurorax.site/getkey/1b56de61f463fc8d4cd4d1dca6e26660") end
            end
        end)
        feedback.TextColor3 = Color3.fromRGB(130, 240, 170)
        feedback.Text = "Link copied! Complete verification in your browser."
    end)

    -- 2. Verify Key Button (Glowing Gradient Button)
    local verifyBtn = Instance.new("TextButton", btnRow)
    verifyBtn.Size = UDim2.new(0.48, 0, 1, 0)
    verifyBtn.Position = UDim2.new(0.52, 0, 0, 0)
    verifyBtn.BackgroundColor3 = Color3.fromRGB(147, 51, 234)
    verifyBtn.Text = ""
    verifyBtn.AutoButtonColor = false
    Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 9)

    local vbGrad = Instance.new("UIGradient", verifyBtn)
    vbGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(168, 85, 247)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(126, 34, 206))
    })

    local vStroke = Instance.new("UIStroke", verifyBtn)
    vStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    vStroke.Color = Color3.fromRGB(216, 180, 254)
    vStroke.Thickness = 1

    local vLbl = Instance.new("TextLabel", verifyBtn)
    vLbl.Size = UDim2.new(1, 0, 1, 0)
    vLbl.BackgroundTransparency = 1
    vLbl.Font = Enum.Font.GothamBold
    vLbl.Text = "Verify Key"
    vLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    vLbl.TextSize = 12

    local isChecking = false
    verifyBtn.MouseButton1Click:Connect(function()
        if isChecking then return end
        isChecking = true
        local entered = keyBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if #entered < 4 then
            feedback.TextColor3 = Color3.fromRGB(255, 120, 120)
            feedback.Text = "Please enter a valid license key."
            isChecking = false
            return
        end

        feedback.TextColor3 = Color3.fromRGB(216, 180, 254)
        feedback.Text = "Verifying with Monody..."

        task.spawn(function()
            local valid = false
            local info = {}
            if AuroraX and AuroraX.CheckKey then
                valid, info = AuroraX.CheckKey(entered)
            else
                valid = true
            end

            if valid then
                feedback.TextColor3 = Color3.fromRGB(100, 230, 150)
                feedback.Text = "Key verified! Starting " .. APP_TITLE .. "..."
                task.wait(0.5)
                TweenService:Create(modal, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1
                }):Play()
                task.wait(0.26)
                pcall(function() gui:Destroy() end)
                if onSuccess then onSuccess() end
            else
                feedback.TextColor3 = Color3.fromRGB(255, 110, 110)
                feedback.Text = (info and info.message) or "Invalid or expired key."
                isChecking = false
            end
        end)
    end)

    gui.Parent = parent

    -- Smooth Spring Entrance Animation
    TweenService:Create(modal, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 410, 0, 250),
        BackgroundTransparency = 0.15
    }):Play()
end

local Main = nil
local maximizeUI = nil
local Notify = nil
local introCompleted = false
local uiOpened = false

local function triggerUIOpen()
    if introCompleted and uiReadyToOpen and not uiOpened then
        uiOpened = true
        pcall(function()
            local oldLoader = (CoreGui and CoreGui:FindFirstChild("Monody_LoadingScreen"))
                or (parentGui and parentGui:FindFirstChild("Monody_LoadingScreen"))
                or (gethui and gethui():FindFirstChild("Monody_LoadingScreen"))
                or (lp and lp:FindFirstChildOfClass("PlayerGui") and lp.PlayerGui:FindFirstChild("Monody_LoadingScreen"))
            if oldLoader then
                local m = oldLoader:FindFirstChild("Modal") or oldLoader:FindFirstChildWhichIsA("Frame")
                if m then
                    TweenService:Create(m, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                        Size = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 1
                    }):Play()
                    task.wait(0.3)
                end
                oldLoader:Destroy()
            end
        end)
        if maximizeUI then
            maximizeUI()
        elseif Main then
            Main.Visible = true
        end
        if Notify then
            Notify(APP_TITLE, "Version " .. APP_VERSION .. " loaded and ready.")
        end
        print("[" .. APP_TITLE .. "] Version " .. APP_VERSION .. " initialized successfully.")
    end
end

local function startMonodyBoot()
    InlineLoader.show(GetLogoAsset())
    InlineLoader.update(0.3, "Checking modules...")

    task.spawn(function()
        local elapsed = 0
        while not uiReadyToOpen and elapsed < 1.0 do
            task.wait(0.04)
            elapsed = elapsed + 0.04
            InlineLoader.update(0.3 + math.min(elapsed / 1.0 * 0.7, 0.7), "Loading components...")
        end

        InlineLoader.update(1.0, "Ready")
        task.wait(0.1)
        InlineLoader.finish(function()
            introCompleted = true
            triggerUIOpen()
        end)
    end)
end

task.spawn(function()
    -- 1. Instant bypass if already verified by AuroraX Sentinel V5 Loader
    local genv = (type(getgenv) == "function" and getgenv()) or _G or {}
    if AX_LinkedDiscordID or genv.AX_USER or genv.AuroraX_Authenticated then
        startMonodyBoot()
        return
    end

    local AuroraX = getAuroraX()
    local providedKey = script_key or genv.script_key or genv.Key
    local savedKey = (AuroraX and AuroraX.GetSavedKey and AuroraX.GetSavedKey()) or ""
    local candidate = (providedKey and #providedKey >= 6 and providedKey) or (savedKey and #savedKey >= 6 and savedKey) or nil

    if candidate and AuroraX and AuroraX.CheckKey then
        local ok, info = AuroraX.CheckKey(candidate)
        if ok then
            startMonodyBoot()
            return
        end
    end

    showKeyModal(AuroraX, function()
        startMonodyBoot()
    end)
end)

-- ============================================================
-- UI FRAMEWORK: LIQUID GLASS COMPACT
-- ============================================================
ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Monody_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 10000
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
    ScreenGui.Parent = parentGui
end)

-- Toast Notification Container
local ToastContainer = Instance.new("Frame", ScreenGui)
ToastContainer.Name = "ToastContainer"
ToastContainer.Size = UDim2.new(0, 220, 1, -40)
ToastContainer.Position = UDim2.new(1, -235, 0, 20)
ToastContainer.BackgroundTransparency = 1
ToastContainer.ZIndex = 500

local ToastList = Instance.new("UIListLayout", ToastContainer)
ToastList.SortOrder = Enum.SortOrder.LayoutOrder
ToastList.VerticalAlignment = Enum.VerticalAlignment.Bottom
ToastList.Padding = UDim.new(0, 8)

local activeToast = nil
local activeToastTimer = nil
Notify = function(titleText, msgText, duration, force)
    if suspendSave and not force then return end
    duration = duration or 2.5

    if activeToastTimer then
        pcall(task.cancel, activeToastTimer)
        activeToastTimer = nil
    end
    if activeToast and activeToast.Parent then
        pcall(function() activeToast:Destroy() end)
        activeToast = nil
    end
    for _, child in ipairs(ToastContainer:GetChildren()) do
        if child:IsA("Frame") then
            pcall(function() child:Destroy() end)
        end
    end

    local toast = Instance.new("Frame", ToastContainer)
    toast.Size = UDim2.new(1, 0, 0, 48)
    toast.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
    toast.BackgroundTransparency = 0.25
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", toast)
    stroke.Color = CurrentAccent
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    RegisterThemeStroke(stroke)

    local tLbl = Instance.new("TextLabel", toast)
    tLbl.Size = UDim2.new(1, -24, 0, 16)
    tLbl.Position = UDim2.new(0, 12, 0, 8)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = titleText
    tLbl.Font = Enum.Font.GothamBold
    tLbl.TextSize = 11
    tLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    tLbl.TextXAlignment = Enum.TextXAlignment.Left

    local mLbl = Instance.new("TextLabel", toast)
    mLbl.Size = UDim2.new(1, -24, 0, 14)
    mLbl.Position = UDim2.new(0, 12, 0, 24)
    mLbl.BackgroundTransparency = 1
    mLbl.Text = msgText
    mLbl.Font = Enum.Font.Gotham
    mLbl.TextSize = 9.5
    mLbl.TextColor3 = Color3.fromRGB(180, 175, 195)
    mLbl.TextXAlignment = Enum.TextXAlignment.Left

    activeToast = toast
    TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quart), { BackgroundTransparency = 0.25 }):Play()
    activeToastTimer = task.delay(duration, function()
        if toast and toast.Parent then
            TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quart), { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0) }):Play()
            task.wait(0.25)
            if toast and toast.Parent then toast:Destroy() end
            if activeToast == toast then activeToast = nil end
        end
    end)
end

-- Top-Left Real-time FPS & Ping Telemetry Overlay
local FPSPingOverlay = Instance.new("Frame", ScreenGui)
FPSPingOverlay.Name = "Monody_FPSPingOverlay"
FPSPingOverlay.Size = UDim2.new(0, 150, 0, 24)
FPSPingOverlay.Position = UDim2.new(0, 15, 0, 55)
FPSPingOverlay.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
FPSPingOverlay.BackgroundTransparency = 0.35
FPSPingOverlay.BorderSizePixel = 0
FPSPingOverlay.Visible = false
FPSPingOverlay.ZIndex = 50
Instance.new("UICorner", FPSPingOverlay).CornerRadius = UDim.new(0, 8)

local fpsStroke = Instance.new("UIStroke", FPSPingOverlay)
fpsStroke.Color = CurrentAccent
fpsStroke.Thickness = 1
fpsStroke.Transparency = 0.4
RegisterThemeStroke(fpsStroke)

local fpsLabel = Instance.new("TextLabel", FPSPingOverlay)
fpsLabel.Size = UDim2.new(1, -8, 1, 0)
fpsLabel.Position = UDim2.new(0, 4, 0, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 10
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.Text = "FPS: -- | PING: --ms"
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center

local fpsPingConn = nil
local function SetFPSPingVisible(state)
    _G.DarlingX_ShowFPS = (state == true)
    FPSPingOverlay.Visible = _G.DarlingX_ShowFPS

    if _G.DarlingX_ShowFPS and not fpsPingConn then
        local lastUpdate = 0
        fpsPingConn = RunService.RenderStepped:Connect(function(dt)
            local now = os.clock()
            if now - lastUpdate < 0.5 then return end
            lastUpdate = now

            local fps = (dt > 0) and math.floor(1 / dt) or 60
            local ping = 0
            pcall(function()
                local s = Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerStatsItem")
                local item = s and s:FindFirstChild("Data Ping")
                if item then ping = math.floor(item:GetValue()) end
            end)
            if ping == 0 and lp then
                pcall(function() ping = math.floor(lp:GetNetworkPing() * 1000) end)
            end
            fpsLabel.Text = string.format("FPS: %d | PING: %dms", fps, ping)
        end)
    elseif not _G.DarlingX_ShowFPS and fpsPingConn then
        pcall(function() fpsPingConn:Disconnect() end)
        fpsPingConn = nil
    end
end

-- Robust Server Rejoin
local function RejoinServer()
    Notify("Server", "Reconnecting to server...", 3, true)

    local qot = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
    if qot then
        pcall(function()
            qot([[
                loadstring(game:HttpGet("https://pastebin.aurorax.site/raw/B5GKSA23"))()
            ]])
        end)
    end

    local ts = game:GetService("TeleportService")
    local pList = Players:GetPlayers()
    local myJobId = tostring(game.JobId or "")

    local failedConn
    failedConn = ts.TeleportInitFailed:Connect(function()
        if failedConn then pcall(function() failedConn:Disconnect() end) failedConn = nil end
        pcall(function() ts:Teleport(game.PlaceId, lp) end)
    end)

    if #pList <= 1 or myJobId == "" then
        pcall(function() ts:Teleport(game.PlaceId, lp) end)
    else
        local ok = pcall(function()
            ts:TeleportToPlaceInstance(game.PlaceId, myJobId, lp)
        end)
        if not ok then
            pcall(function() ts:Teleport(game.PlaceId, lp) end)
        end
    end
end

-- Floating Open Button (Displays Monody White Floating Avatar)
local FloatingOpen = Instance.new("ImageButton", ScreenGui)
FloatingOpen.Name = "FloatingOpen"
FloatingOpen.Size = UDim2.new(0, 44, 0, 44)
FloatingOpen.Position = UDim2.new(0, 15, 0.20, 0)
FloatingOpen.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
FloatingOpen.BackgroundTransparency = 0.2
FloatingOpen.BorderSizePixel = 0
FloatingOpen.Image = ResolveAndBindAsset("floating_avatar_white.png", DEFAULT_LOGO_ID, FloatingOpen)
FloatingOpen.ScaleType = Enum.ScaleType.Crop
FloatingOpen.AutoButtonColor = false
FloatingOpen.Active = true
FloatingOpen.Selectable = true
FloatingOpen.ZIndex = 100
FloatingOpen.Visible = false
Instance.new("UICorner", FloatingOpen).CornerRadius = UDim.new(1, 0)
local floatStroke = Instance.new("UIStroke", FloatingOpen)
floatStroke.Color = Color3.fromRGB(255, 255, 255)
floatStroke.Thickness = 0.8
floatStroke.Transparency = 0.85
RegisterThemeStroke(floatStroke)

-- Main Window (Liquid Glass Compact 440x300)
Main = Instance.new("Frame", ScreenGui)
Main.Name = "Monody_MainWindow"
Main.Visible = false
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Main.BackgroundTransparency = 1
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 22)

local MainScale = Instance.new("UIScale", Main)
MainScale.Scale = 1
local GlassFrames = {}

local function UpdateMobileScale()
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local widthScale = (viewport.X - 24) / 440
    local heightScale = (viewport.Y - 24) / 300
    MainScale.Scale = math.clamp(math.min(widthScale, heightScale), 0.65, 1)
end
UpdateMobileScale()
if camera then
    trackConn(camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateMobileScale))
end

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = CurrentAccent
MainStroke.Thickness = 1.0
MainStroke.Transparency = 0.85
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
RegisterThemeStroke(MainStroke)

-- Static Wallpaper Background
local WallpaperImage = Instance.new("ImageLabel", Main)
WallpaperImage.Name = "WallpaperImage"
WallpaperImage.Size = UDim2.new(1, 0, 1, 0)
WallpaperImage.Position = UDim2.new(0, 0, 0, 0)
WallpaperImage.BackgroundTransparency = 1
WallpaperImage.ImageTransparency = 1
WallpaperImage.Image = ""
WallpaperImage.ScaleType = Enum.ScaleType.Crop
WallpaperImage.Active = false
WallpaperImage.ZIndex = 0
Instance.new("UICorner", WallpaperImage).CornerRadius = UDim.new(0, 22)

-- Darkening Dim Overlay for High Contrast Glass Readability
local WallpaperDimOverlay = Instance.new("Frame", Main)
WallpaperDimOverlay.Name = "WallpaperDimOverlay"
WallpaperDimOverlay.Size = UDim2.new(1, 0, 1, 0)
WallpaperDimOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
WallpaperDimOverlay.BackgroundTransparency = 0.35
WallpaperDimOverlay.BorderSizePixel = 0
WallpaperDimOverlay.Active = false
WallpaperDimOverlay.ZIndex = 1
Instance.new("UICorner", WallpaperDimOverlay).CornerRadius = UDim.new(0, 22)

-- Cyber Neon Rain Animation Layer (High-Performance Recycled Object Pool)
local rainContainer = Instance.new("Frame", Main)
rainContainer.Name = "RainAnimationLayer"
rainContainer.Size = UDim2.new(1, 0, 1, 0)
rainContainer.BackgroundTransparency = 1
rainContainer.ClipsDescendants = true
rainContainer.Active = false
rainContainer.ZIndex = 2
Instance.new("UICorner", rainContainer).CornerRadius = UDim.new(0, 22)

local RainEnabled = false
local MaxRainDrops = 14
local RainPoolCapacity = 30
local rainPool = {}
local dropTweens = {}
local rainActive = false

-- Pre-instantiate pool once; zero runtime Instance.new or Destroy
for i = 1, RainPoolCapacity do
    local drop = Instance.new("Frame", rainContainer)
    drop.Name = "RainDrop_" .. i
    drop.Size = UDim2.new(0, 2, 0, 20)
    drop.Position = UDim2.new(0, 0, -0.2, 0)
    drop.BackgroundColor3 = CurrentAccent
    drop.BackgroundTransparency = 1
    drop.BorderSizePixel = 0
    drop.Active = false
    drop.Visible = false
    Instance.new("UICorner", drop).CornerRadius = UDim.new(1, 0)
    table.insert(rainPool, drop)
end

local function animateDrop(dropIndex)
    if not IsScriptRunning or not Main.Visible or not RainEnabled or dropIndex > MaxRainDrops then
        local drop = rainPool[dropIndex]
        if drop then drop.Visible = false end
        return
    end

    local drop = rainPool[dropIndex]
    if not drop then return end

    local startX = math.random(1, 99) / 100
    local targetX = startX - (math.random(3, 8) / 100)
    local dropLen = math.random(14, 26)
    local startTrans = math.random(2, 5) / 10
    local duration = math.random(4, 9) / 10

    drop.Size = UDim2.new(0, 2, 0, dropLen)
    drop.Position = UDim2.new(startX, 0, -0.15, 0)
    drop.BackgroundColor3 = CurrentAccent
    drop.BackgroundTransparency = startTrans
    drop.Visible = true

    if dropTweens[dropIndex] then
        pcall(function() dropTweens[dropIndex]:Cancel() end)
    end

    local tw = TweenService:Create(drop, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Position = UDim2.new(targetX, 0, 1.15, 0),
        BackgroundTransparency = 1
    })
    dropTweens[dropIndex] = tw

    tw.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed or playbackState == nil then
            if IsScriptRunning and Main.Visible and RainEnabled and dropIndex <= MaxRainDrops then
                task.delay(math.random(1, 5) / 50, function()
                    if IsScriptRunning and Main.Visible and RainEnabled and dropIndex <= MaxRainDrops then
                        animateDrop(dropIndex)
                    else
                        drop.Visible = false
                    end
                end)
            else
                drop.Visible = false
            end
        else
            drop.Visible = false
        end
    end)
    tw:Play()
end

local function StartRainAnimation()
    if rainActive or not IsScriptRunning or not Main.Visible or not RainEnabled then return end
    rainActive = true
    local count = math.clamp(MaxRainDrops, 1, RainPoolCapacity)
    for i = 1, count do
        local stagger = (i - 1) * 0.06
        task.delay(stagger, function()
            if rainActive and Main.Visible and RainEnabled and i <= MaxRainDrops then
                animateDrop(i)
            end
        end)
    end
end

local function StopRainAnimation()
    rainActive = false
    for i, drop in ipairs(rainPool) do
        if dropTweens[i] then
            pcall(function() dropTweens[i]:Cancel() end)
            dropTweens[i] = nil
        end
        drop.Visible = false
    end
end

-- Strictly event-driven: start only when Main is visible and rain is enabled
Main:GetPropertyChangedSignal("Visible"):Connect(function()
    if Main.Visible and RainEnabled then
        StartRainAnimation()
    else
        StopRainAnimation()
    end
end)

if Main.Visible and RainEnabled then
    task.defer(StartRainAnimation)
end

-- Header Bar
local Header = Instance.new("Frame", Main)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundTransparency = 1
Header.ZIndex = 15

-- Logo Badge
local LogoBadge = Instance.new("ImageLabel", Header)
LogoBadge.Name = "HeaderLogo"
LogoBadge.Size = UDim2.new(0, 22, 0, 22)
LogoBadge.Position = UDim2.new(0, 10, 0.5, -11)
LogoBadge.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LogoBadge.BackgroundTransparency = 0
LogoBadge.Image = GetLogoAsset()
LogoBadge.ScaleType = Enum.ScaleType.Crop
LogoBadge.ZIndex = 16
Instance.new("UICorner", LogoBadge).CornerRadius = UDim.new(0, 6)
local lStroke = Instance.new("UIStroke", LogoBadge)
lStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
lStroke.Color = CurrentAccent
lStroke.Thickness = 0.8
lStroke.Transparency = 0.85
RegisterThemeStroke(lStroke)

local Title = Instance.new("TextLabel", Header)
Title.Position = UDim2.new(0, 36, 0, 6)
Title.Size = UDim2.new(0, 48, 0, 16)
Title.BackgroundTransparency = 1
Title.Text = APP_TITLE
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 16

local SubTitle = Instance.new("TextLabel", Header)
SubTitle.Position = UDim2.new(0, 36, 0, 22)
SubTitle.Size = UDim2.new(0, 48, 0, 12)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = APP_VERSION
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.TextSize = 8
SubTitle.TextColor3 = Color3.fromRGB(180, 175, 200)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.ZIndex = 16

-- ============================================================
-- CENTRAL AUDIO CONTROLLER & HEADER MUSIC BAR
-- ============================================================
do
    local soundService = game:GetService("SoundService")

    local MonodyMusic = {
        Sound = nil,
        IsPlaying = false,
        CurrentTrackName = "No Track",
        CurrentSoundId = "",
        Volume = 1.0, -- Default full volume (100%)
        Pitch = 1.0,
        Looped = true,
        TopBarFrame = nil,
        OnStateChanged = nil
    }
    _G.MonodyMusic = MonodyMusic

    local function getSoundParent()
        -- In Roblox, 2D ambient and UI audio MUST be parented to SoundService or Workspace
        -- Parenting to PlayerGui makes sound completely INAUDIBLE/SILENT.
        if soundService then return soundService end
        if Workspace and Workspace.CurrentCamera then return Workspace.CurrentCamera end
        return Workspace
    end

    local function resolveSoundSource(identifier)
        if not identifier or identifier == "" then return nil end
        local str = tostring(identifier):gsub("^%s+", ""):gsub("%s+$", "")
        if str == "" then return nil end

        -- 1. Check if already a custom asset or roblox asset URI (MUST NOT extract digits from custom asset paths!)
        if str:find("^rbxasset://") or str:find("^asset://") or str:find("^rbxthumb://") or str:find("^https?://localhost") then
            return str
        end

        -- 2. Direct rbxassetid://
        if str:find("^rbxassetid://") then
            return str
        end

        -- 3. Check executor local file
        if type(isfile) == "function" and type(getcustomasset) == "function" then
            local candidates = {
                str,
                "darling_hub/" .. str,
                str .. ".mp3",
                "darling_hub/" .. str .. ".mp3",
                str .. ".ogg",
                str .. ".wav"
            }
            for _, path in ipairs(candidates) do
                local okCheck, exists = pcall(function() return isfile(path) end)
                if okCheck and exists then
                    local okAsset, asset = pcall(function() return getcustomasset(path) end)
                    if okAsset and asset and type(asset) == "string" and #asset > 0 then
                        return asset
                    end
                end
            end
        end

        -- 4. Direct web url (.mp3, .ogg)
        if str:find("^https?://") then
            if (str:find("%.mp3") or str:find("%.ogg") or str:find("%.wav")) and type(writefile) == "function" and type(getcustomasset) == "function" then
                local hName = "monody_audio_" .. tostring(#str) .. ".mp3"
                local exIsFile = isfile or is_file
                if type(exIsFile) == "function" and not exIsFile(hName) then
                    local ok, d = pcall(function() return game:HttpGet(str) end)
                    if ok and d and #d > 500 then
                        pcall(writefile, hName, d)
                    end
                end
                if type(exIsFile) == "function" and exIsFile(hName) then
                    local okA, a = pcall(getcustomasset, hName)
                    if okA and a and #a > 0 then return a end
                end
            end
            local d = str:match("(%d%d%d%d+)")
            if d and #d > 0 then return "rbxassetid://" .. d end
        end

        -- 5. Extract numeric ID from string
        local digits = str:match("(%d%d%d%d+)")
        if digits and #digits > 0 then
            return "rbxassetid://" .. digits
        end

        return "rbxassetid://7025810761"
    end

    local function InitMusicSound()
        local parent = getSoundParent()
        local snd = MonodyMusic.Sound
        if not snd or not snd.Parent or snd.Parent ~= parent then
            -- Clean up old silent sounds placed in PlayerGui or Workspace
            pcall(function()
                if lp and lp:FindFirstChildOfClass("PlayerGui") then
                    local oldP = lp.PlayerGui:FindFirstChild("MonodyBGM")
                    if oldP then oldP:Destroy() end
                end
            end)
            local existing = parent:FindFirstChild("MonodyBGM")
            if existing and existing:IsA("Sound") then
                snd = existing
            else
                snd = Instance.new("Sound")
                snd.Name = "MonodyBGM"
                snd.Parent = parent
            end
            snd.Volume = MonodyMusic.Volume or 1.0
            snd.PlaybackSpeed = MonodyMusic.Pitch or 1.0
            snd.Looped = (MonodyMusic.Looped ~= false)
            snd.SoundGroup = nil
            snd.RollOffMaxDistance = 10000000
            snd.RollOffMinDistance = 10000000
            snd.Ended:Connect(function()
                if not MonodyMusic.Looped then
                    MonodyMusic.IsPlaying = false
                    if MonodyMusic.OnStateChanged then pcall(MonodyMusic.OnStateChanged) end
                end
            end)
            MonodyMusic.Sound = snd
        end
        return snd
    end

    function MonodyMusic.Play(soundId, trackName)
        local source = soundId
        if not (type(soundId) == "string" and (soundId:find("^rbxasset://") or soundId:find("^asset://") or soundId:find("^rbxthumb://"))) then
            source = resolveSoundSource(soundId)
        end
        if not source or source == "" then
            return false, "Invalid Sound ID"
        end

        local snd = InitMusicSound()
        pcall(function() snd:Stop() end)
        snd.TimePosition = 0
        snd.SoundId = source
        snd.Volume = MonodyMusic.Volume or 1.0
        snd.PlaybackSpeed = MonodyMusic.Pitch or 1.0
        snd.Looped = (MonodyMusic.Looped ~= false)
        snd.SoundGroup = nil
        snd.RollOffMaxDistance = 10000000

        pcall(function() snd:Play() end)
        pcall(function() snd.Playing = true end)

        MonodyMusic.CurrentSoundId = tostring(soundId)
        MonodyMusic.CurrentTrackName = (trackName and trackName ~= "") and trackName or ("Track " .. tostring(soundId))
        MonodyMusic.IsPlaying = true
        if MonodyMusic.OnStateChanged then pcall(MonodyMusic.OnStateChanged) end

        -- Monitor load state & inform user if Roblox blocked the ID
        task.spawn(function()
            local elapsed = 0
            while MonodyMusic.IsPlaying and snd.SoundId == source and elapsed < 3.5 do
                if snd.IsLoaded and snd.TimeLength > 0 then
                    return
                end
                task.wait(0.2)
                elapsed = elapsed + 0.2
            end
            if MonodyMusic.IsPlaying and snd.SoundId == source and snd.TimeLength == 0 and not snd.IsLoaded then
                pcall(function()
                    Notify("Music Player", "Notice: If inaudible, this ID may be privatized. Use 'Play Montagem Phonk' for local bypass!")
                end)
            end
        end)

        return true, "Playing " .. MonodyMusic.CurrentTrackName
    end

    function MonodyMusic.PlayLocalBypass(url, filename, trackName)
        local exIsFile = isfile or is_file
        local exWriteFile = writefile
        local exGetCustomAsset = getcustomasset

        task.spawn(function()
            if type(exWriteFile) == "function" and type(exGetCustomAsset) == "function" then
                local exists = false
                if type(exIsFile) == "function" then
                    local ok, e = pcall(function() return exIsFile(filename) end)
                    exists = ok and e
                end
                if not exists then
                    Notify("Music Player", "Downloading " .. (trackName or "audio") .. "...")
                    local ok, data = pcall(function() return game:HttpGet(url) end)
                    if ok and data and #data > 500 then
                        pcall(exWriteFile, filename, data)
                        exists = true
                    end
                end
                if exists or (type(exIsFile) == "function" and exIsFile(filename)) then
                    local okAsset, asset = pcall(exGetCustomAsset, filename)
                    if okAsset and asset and #asset > 0 then
                        MonodyMusic.Play(asset, trackName or "Local Track")
                        Notify("Music Player", "Now playing: " .. (trackName or "Local Track"))
                        return
                    end
                end
            end
            -- Fallback to Blox Fruits native OST if getcustomasset is unsupported
            MonodyMusic.Play("7025810761", trackName or "Blox Fruits Theme")
            Notify("Music Player", "Playing Blox Fruits Theme (OST)")
        end)
    end

    function MonodyMusic.Pause()
        if MonodyMusic.Sound then
            pcall(function() MonodyMusic.Sound:Pause() end)
            MonodyMusic.IsPlaying = false
            if MonodyMusic.OnStateChanged then pcall(MonodyMusic.OnStateChanged) end
        end
    end

    function MonodyMusic.Resume()
        if MonodyMusic.Sound and MonodyMusic.Sound.SoundId ~= "" then
            pcall(function() MonodyMusic.Sound:Resume() end)
            MonodyMusic.IsPlaying = true
            if MonodyMusic.OnStateChanged then pcall(MonodyMusic.OnStateChanged) end
        end
    end

    function MonodyMusic.Stop()
        if MonodyMusic.Sound then
            pcall(function() MonodyMusic.Sound:Stop() end)
            MonodyMusic.IsPlaying = false
            if MonodyMusic.OnStateChanged then pcall(MonodyMusic.OnStateChanged) end
        end
    end

    function MonodyMusic.SetVolume(v)
        MonodyMusic.Volume = v
        if MonodyMusic.Sound then MonodyMusic.Sound.Volume = v end
    end

    function MonodyMusic.SetPitch(p)
        MonodyMusic.Pitch = p
        if MonodyMusic.Sound then MonodyMusic.Sound.PlaybackSpeed = p end
    end

    function MonodyMusic.SetLooped(l)
        MonodyMusic.Looped = l
        if MonodyMusic.Sound then MonodyMusic.Sound.Looped = l end
    end

    local PLAYLIST = {
        { title = "MONTAGEM BAILÃO (Phonk)", id = "7025810761", url = "https://raw.githubusercontent.com/rivals-hash/idk/main/assets/audio/phonk.mp3", file = "monody_phonk.mp3" },
        { title = "Blox Fruits Theme", id = "7025810761" },
        { title = "One Piece Overtaken", id = "6948625906" },
        { title = "Spooky Theme", id = "9114223171" }
    }
    local currentTrackIdx = 1

    function MonodyMusic.PlayTrack(idx)
        currentTrackIdx = math.clamp(idx, 1, #PLAYLIST)
        local t = PLAYLIST[currentTrackIdx]
        if t.url and MonodyMusic.PlayLocalBypass then
            MonodyMusic.PlayLocalBypass(t.url, t.file or "monody_phonk.mp3", t.title)
        else
            MonodyMusic.Play(t.id, t.title)
        end
    end

    function MonodyMusic.NextTrack()
        currentTrackIdx = currentTrackIdx + 1
        if currentTrackIdx > #PLAYLIST then currentTrackIdx = 1 end
        MonodyMusic.PlayTrack(currentTrackIdx)
    end

    function MonodyMusic.PrevTrack()
        currentTrackIdx = currentTrackIdx - 1
        if currentTrackIdx < 1 then currentTrackIdx = #PLAYLIST end
        MonodyMusic.PlayTrack(currentTrackIdx)
    end

    function MonodyMusic.ShuffleTrack()
        local nextIdx = math.random(1, #PLAYLIST)
        MonodyMusic.PlayTrack(nextIdx)
    end

    function MonodyMusic.TogglePlay()
        if MonodyMusic.IsPlaying then
            MonodyMusic.Pause()
            return false
        else
            if not MonodyMusic.Sound or MonodyMusic.Sound.SoundId == "" then
                MonodyMusic.PlayTrack(currentTrackIdx)
            else
                MonodyMusic.Resume()
            end
            return true
        end
    end

    function MonodyMusic.Seek(ratio)
        if MonodyMusic.Sound and MonodyMusic.Sound.TimeLength > 0 then
            pcall(function()
                MonodyMusic.Sound.TimePosition = math.clamp(ratio * MonodyMusic.Sound.TimeLength, 0, MonodyMusic.Sound.TimeLength - 0.1)
            end)
        end
    end

    -- Top Music Bar on UI Header (Full Span across header, 24-bar Dynamic Equalizer, 0.7 Pill)
    local TopMusicBar = Instance.new("Frame", Header)
    TopMusicBar.Name = "TopMusicBar"
    TopMusicBar.Size = UDim2.new(1, -150, 0, 24)
    TopMusicBar.Position = UDim2.new(0, 88, 0.5, -12)
    TopMusicBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    TopMusicBar.BackgroundTransparency = 0.65
    TopMusicBar.ZIndex = 16
    Instance.new("UICorner", TopMusicBar).CornerRadius = UDim.new(0.7, 0)
    local topMusicStroke = Instance.new("UIStroke", TopMusicBar)
    topMusicStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    topMusicStroke.Color = CurrentAccent
    topMusicStroke.Thickness = 0.8
    topMusicStroke.Transparency = 0.85
    RegisterThemeStroke(topMusicStroke)
    MonodyMusic.TopBarFrame = TopMusicBar

    -- Animated Multi-Bar Equalizer across the whole width of the bar
    local EqContainer = Instance.new("Frame", TopMusicBar)
    EqContainer.Name = "EqContainer"
    EqContainer.Size = UDim2.new(1, -20, 0, 14)
    EqContainer.Position = UDim2.new(0, 10, 0.5, -7)
    EqContainer.BackgroundTransparency = 1
    EqContainer.ZIndex = 17

    local eqBars = {}
    local totalBars = 24
    for i = 1, totalBars do
        local bar = Instance.new("Frame", EqContainer)
        bar.Name = "EqBar" .. i
        bar.Size = UDim2.new(0, 2.5, 0, 2)
        bar.Position = UDim2.new((i - 1) / totalBars, 0, 1, -2)
        bar.BackgroundColor3 = CurrentAccent
        bar.BackgroundTransparency = 0.8
        bar.ZIndex = 17
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        RegisterThemeFill(bar)
        table.insert(eqBars, bar)
    end

    -- Click TopMusicBar to toggle playback
    local clickOverlay = Instance.new("TextButton", TopMusicBar)
    clickOverlay.Name = "ClickOverlay"
    clickOverlay.Size = UDim2.new(1, 0, 1, 0)
    clickOverlay.BackgroundTransparency = 1
    clickOverlay.Text = ""
    clickOverlay.ZIndex = 19
    ConnectButton(clickOverlay, function()
        if MonodyMusic.IsPlaying then
            MonodyMusic.Pause()
        else
            if MonodyMusic.Sound and MonodyMusic.Sound.SoundId ~= "" then
                MonodyMusic.Resume()
            end
        end
    end)

    local eqAnimStep = 0
    local wasPlaying = false
    RunService.Heartbeat:Connect(function()
        if MonodyMusic.IsPlaying then
            wasPlaying = true
            eqAnimStep = eqAnimStep + 0.16
            for i, bar in ipairs(eqBars) do
                local h = math.clamp(3 + math.abs(math.sin(eqAnimStep + i * 0.45)) * 11, 2, 14)
                bar.Size = UDim2.new(0, 2.5, 0, h)
                bar.Position = UDim2.new((i - 1) / totalBars, 0, 1, -h)
                bar.BackgroundTransparency = 0.35
            end
        elseif wasPlaying then
            wasPlaying = false
            for i, bar in ipairs(eqBars) do
                bar.Size = UDim2.new(0, 2.5, 0, 2)
                bar.Position = UDim2.new((i - 1) / totalBars, 0, 1, -2)
                bar.BackgroundTransparency = 0.85
            end
        end
    end)
end

-- Window Controls (Minimize & Close)
local function createHeaderBtn(symbol, offsetRight, color, callback)
    local btn = Instance.new("TextButton", Header)
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.Position = UDim2.new(1, offsetRight, 0.5, -11)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.92
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Active = true
    btn.ZIndex = 16
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local str = Instance.new("UIStroke", btn)
    str.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    str.Color = color
    str.Thickness = 0.8
    str.Transparency = 0.85
    
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = symbol
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = color
    lbl.Active = false
    lbl.ZIndex = 17

    ConnectButton(btn, callback)
    return btn
end

local function minimizeUI()
    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    task.wait(0.25)
    Main.Visible = false
    FloatingOpen.Visible = true
    Notify(APP_TITLE, "Minimized. Tap floating button to reopen.")
end

local opening = false
maximizeUI = function()
    if opening then return end
    opening = true
    FloatingOpen.Visible = false
    Main.Visible = true
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    local openTween = TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 440, 0, 300), Position = UDim2.new(0.5, -220, 0.5, -150)
    })
    openTween.Completed:Connect(function()
        opening = false
    end)
    openTween:Play()
end

local function fullCloseUI()
    IsScriptRunning = false
    for _, c in ipairs(ActiveConnections) do pcall(function() c:Disconnect() end) end
    pcall(function() ScreenGui:Destroy() end)
    pcall(function()
        local target = parentGui or (lp and lp:FindFirstChild("PlayerGui"))
        if target then
            for _, old in ipairs(target:GetChildren()) do
                if old.Name:find("DarlingX") or old.Name:find("DarlingHub_FOV") or old.Name:find("DarlingHub_Tracers") then
                    old:Destroy()
                end
            end
        end
    end)
    print("[Monody] Closed completely.")
end

createHeaderBtn("-", -54, Color3.fromRGB(255, 255, 255), minimizeUI)
createHeaderBtn("X", -28, Color3.fromRGB(255, 75, 75), fullCloseUI)
ConnectButton(FloatingOpen, maximizeUI)

-- Dragging Support
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

-- Page Container (Right Side Content Area)
local PageContainer = Instance.new("Frame", Main)
PageContainer.Name = "PageContainer"
PageContainer.Size = UDim2.new(1, -120, 1, -52)
PageContainer.Position = UDim2.new(0, 112, 0, 44)
PageContainer.BackgroundTransparency = 1
PageContainer.ZIndex = 10
PageContainer.ClipsDescendants = false
PageContainer.Active = false

-- Side Navigation Dock Capsule (Adaptive ScrollingFrame to prevent clipping on mobile)
local BottomDock = Instance.new("ScrollingFrame", Main)
BottomDock.Name = "BottomDock"
BottomDock.Size = UDim2.new(0, 100, 1, -52)
BottomDock.Position = UDim2.new(0, 8, 0, 44)
BottomDock.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
BottomDock.BackgroundTransparency = 0.65
BottomDock.ZIndex = 15
BottomDock.BorderSizePixel = 0
BottomDock.ScrollBarThickness = 2
BottomDock.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
BottomDock.ScrollBarImageTransparency = 0.65
BottomDock.VerticalScrollBarInset = Enum.ScrollBarInset.None
BottomDock.ScrollingDirection = Enum.ScrollingDirection.Y
BottomDock.AutomaticCanvasSize = Enum.AutomaticSize.Y
BottomDock.CanvasSize = UDim2.new(0, 0, 0, 0)
BottomDock.ClipsDescendants = true
BottomDock.Active = true
Instance.new("UICorner", BottomDock).CornerRadius = UDim.new(0, 14)
table.insert(GlassFrames, BottomDock)

local dockStroke = Instance.new("UIStroke", BottomDock)
dockStroke.Color = CurrentAccent
dockStroke.Thickness = 0.8
dockStroke.Transparency = 0.85
RegisterThemeStroke(dockStroke)

local dockPadding = Instance.new("UIPadding", BottomDock)
dockPadding.PaddingTop = UDim.new(0, 6)
dockPadding.PaddingBottom = UDim.new(0, 6)
dockPadding.PaddingLeft = UDim.new(0, 4)
dockPadding.PaddingRight = UDim.new(0, 4)

local DockLayout = Instance.new("UIListLayout", BottomDock)
DockLayout.SortOrder = Enum.SortOrder.LayoutOrder
DockLayout.FillDirection = Enum.FillDirection.Vertical
DockLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
DockLayout.VerticalAlignment = Enum.VerticalAlignment.Top
DockLayout.Padding = UDim.new(0, 4)
DockLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    BottomDock.CanvasSize = UDim2.new(0, 0, 0, DockLayout.AbsoluteContentSize.Y + 12)
end)

local Pages = {}
local DockButtons = {}
local TabOrderCounter = 0

-- Tab Manifest: Defines all hub tabs up-front for instant batch creation
local TABS_MANIFEST = {
    { id = "Home",          name = "Home",           icon = "house" },
    { id = "Aimbot",        name = "Aimbot",         icon = "crosshair" },
    { id = "Players",       name = "Players",        icon = "users" },
    { id = "Visuals",       name = "ESP",            icon = "eye" },
    { id = "PvP",           name = "PvP",            icon = "swords" },
    { id = "Soru",          name = "Soru",           icon = "zap" },
    { id = "AutoBounty",    name = "AutoBounty",     icon = "skull" },
    { id = "Dungeon",       name = "Dungeon",        icon = "flame" },
    { id = "Teleport",      name = "Teleport",       icon = "map-pin" },
    { id = "ControlPeople", name = "Control People", icon = "gamepad-2" },
    { id = "StealFruits",   name = "Steal Fruits",   icon = "apple" },
    { id = "HUD",           name = "HUD",            icon = "layout-dashboard" },
    { id = "Macro",         name = "Macro",          icon = "bot" },
    { id = "Skins",         name = "Skins",          icon = "gem" },
    { id = "Music",         name = "Music",          icon = "headphones" },
    { id = "Animations",    name = "Animations",     icon = "sparkles" },
    { id = "Config",        name = "Config",         icon = "sliders-horizontal" },
    { id = "Themes",        name = "Themes",         icon = "palette" },
}

local TAB_MIN_CANVAS = {
    Home = 950,
    Aimbot = 1450,
    Players = 600,
    PvP = 1350,
    Soru = 900,
    AutoBounty = 600,
    Dungeon = 600,
    Teleport = 600,
    ControlPeople = 600,
    StealFruits = 600,
    HUD = 600,
    Macro = 1100,
    Visuals = 950,
    Esp = 950,
    Skins = 600,
    Music = 600,
    Animations = 600,
    Config = 1050,
    Misc = 1050,
    Themes = 1500,
    Settings = 1500,
}

local function UpdatePageCanvas(page)
    if not page or not page:IsA("ScrollingFrame") then return end
    local tabKey = page.Name:gsub("Page$", "")
    local minH = TAB_MIN_CANVAS[tabKey] or 600
    local pList = page:FindFirstChildOfClass("UIListLayout")
    local spacing = pList and pList.Padding.Offset or 6

    local computedTotal = 0
    local count = 0
    for _, child in ipairs(page:GetChildren()) do
        if child:IsA("GuiObject") and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            local h = child.Size.Y.Offset
            if h <= 0 then h = child.AbsoluteSize.Y end
            if h > 0 then
                computedTotal = computedTotal + h
                count = count + 1
            end
        end
    end
    if count > 1 then
        computedTotal = computedTotal + (count - 1) * spacing
    end

    local listContent = (pList and pList.AbsoluteContentSize.Y > 0) and pList.AbsoluteContentSize.Y or 0
    local totalHeight = math.max(computedTotal, listContent)
    page.CanvasSize = UDim2.new(0, 0, 0, math.max(totalHeight + 50, minH))
end

local function UpdateCardGeometry(card)
    if not card or not card.Parent then return end
    local list = card:FindFirstChildOfClass("UIListLayout")
    local pad = card:FindFirstChildOfClass("UIPadding")
    local padTop = pad and pad.PaddingTop.Offset or 7
    local padBottom = pad and pad.PaddingBottom.Offset or 7
    local padTotal = padTop + padBottom

    local spacing = list and list.Padding.Offset or 5
    local computedHeight = 0
    local count = 0
    for _, ch in ipairs(card:GetChildren()) do
        if ch:IsA("GuiObject") and not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") and not ch:IsA("UIStroke") and not ch:IsA("UICorner") then
            local h = ch.Size.Y.Offset
            if h <= 0 then h = ch.AbsoluteSize.Y end
            if h > 0 then
                computedHeight = computedHeight + h
                count = count + 1
            end
        end
    end
    if count > 1 then
        computedHeight = computedHeight + (count - 1) * spacing
    end

    local layoutH = (list and list.AbsoluteContentSize.Y > 0) and list.AbsoluteContentSize.Y or 0
    local contentHeight = math.max(computedHeight, layoutH)
    local finalH = math.max(contentHeight + padTotal, 32)
    card.Size = UDim2.new(1, 0, 0, finalH)

    local parentPage = card.Parent
    if parentPage and parentPage:IsA("ScrollingFrame") then
        UpdatePageCanvas(parentPage)
    end
end

local function SelectTabById(targetId)
    if targetId == "Settings" then targetId = "Themes" end
    if targetId == "Misc" then targetId = "Config" end
    for _, tabMeta in ipairs(TABS_MANIFEST) do
        local id = tabMeta.id
        local p = Pages[id]
        if p then
            local isTarget = (id == targetId)
            p.Visible = isTarget
            if isTarget then
                if id == "Players" and _G.Monody_RefreshPlayers then pcall(_G.Monody_RefreshPlayers) end
                p.CanvasPosition = Vector2.new(0, 0)
                for _, card in ipairs(p:GetChildren()) do
                    if card:IsA("GuiObject") and not card:IsA("UIListLayout") and not card:IsA("UIPadding") then
                        UpdateCardGeometry(card)
                    end
                end
                UpdatePageCanvas(p)
                task.defer(function() UpdatePageCanvas(p) end)
                task.delay(0.05, function() UpdatePageCanvas(p) end)
                task.delay(0.15, function() UpdatePageCanvas(p) end)
            end
        end
        local dbtn = DockButtons[id]
        if dbtn then
            local isTarget = (id == targetId)
            dbtn.isSelected = isTarget
            if isTarget then
                TweenService:Create(dbtn.btn, TweenInfo.new(0.18), {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.85
                }):Play()
                TweenService:Create(dbtn.stroke, TweenInfo.new(0.18), {
                    Color = Color3.fromRGB(255, 255, 255),
                    Transparency = 0.65,
                    Thickness = 0.8
                }):Play()
                TweenService:Create(dbtn.pill, TweenInfo.new(0.18), { BackgroundTransparency = 0 }):Play()
                TweenService:Create(dbtn.icon, TweenInfo.new(0.18), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
                TweenService:Create(dbtn.label, TweenInfo.new(0.18), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
            else
                TweenService:Create(dbtn.btn, TweenInfo.new(0.18), {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.96
                }):Play()
                TweenService:Create(dbtn.stroke, TweenInfo.new(0.18), {
                    Color = Color3.fromRGB(255, 255, 255),
                    Transparency = 0.95,
                    Thickness = 0.8
                }):Play()
                TweenService:Create(dbtn.pill, TweenInfo.new(0.18), { BackgroundTransparency = 1 }):Play()
                TweenService:Create(dbtn.icon, TweenInfo.new(0.18), { ImageColor3 = Color3.fromRGB(180, 180, 190) }):Play()
                TweenService:Create(dbtn.label, TweenInfo.new(0.18), { TextColor3 = Color3.fromRGB(180, 180, 190) }):Play()
            end
        end
    end
end

-- ============================================================
-- MULTILINGUAL TRANSLATION ENGINE (DYNAMIC & INSTANT)
-- ============================================================
local TRANSLATIONS_DICT = {
    ["Spanish"] = {
        ["Player Management"] = "Gestion de Jugadores",
        ["Search Player..."] = "Buscar Jugador...",
        ["Refresh Player List"] = "Actualizar Lista",
        ["Blacklist"] = "Lista Negra",
        ["Blacklisted"] = "En Lista Negra",
        ["Spectate"] = "Espectear",
        ["Spectating"] = "Espectando",
        ["Stop Spectating"] = "Dejar de Espectear",
        ["Teleport to Player"] = "Teletransportarse al Jugador",
        ["Total Players"] = "Total de Jugadores",
        ["Auto Dungeon Engine"] = "Motor Auto Dungeon",
        ["Start Auto Dungeon"] = "Iniciar Auto Dungeon",
        ["Auto Buso"] = "Auto Buso",
        ["Selected Weapon"] = "Arma Seleccionada",
        ["Sword"] = "Espada",
        ["Melee"] = "Cuerpo a Cuerpo",
        ["Blox Fruit"] = "Fruta Blox",
        ["Attack Height"] = "Altura de Ataque",
        ["Auto Pass Room"] = "Auto Pasar Sala",
        ["Void M1 Engine"] = "Motor Void M1",
        ["Enable Void M1"] = "Activar Void M1",
        ["Void Only Boss Rooms"] = "Void Solo Salas de Jefe",
        ["Void Interval (s)"] = "Intervalo de Void (s)",
        ["Dungeon Status & Utilities"] = "Estado y Utilidades de Dungeon",
        ["Auto Load Dungeon"] = "Cargar Dungeon Automaticamente",
        ["Current Room"] = "Sala Actual",
        ["Boss Status"] = "Estado del Jefe",
        ["Island Teleport"] = "Teletransporte de Islas",
        ["Select Sea"] = "Seleccionar Mar",
        ["Sea 1"] = "Mar 1",
        ["Sea 2"] = "Mar 2",
        ["Sea 3"] = "Mar 3",
        ["Target Island"] = "Isla de Destino",
        ["Tween Speed"] = "Velocidad de Tween",
        ["Travel Altitude"] = "Altitud de Viaje",
        ["Noclip during Tween"] = "Noclip durante Tween",
        ["Start Teleport"] = "Iniciar Teletransporte",
        ["Stop Teleport"] = "Detener Teletransporte",
        ["Controls Layout Editor"] = "Editor de Controles",
        ["Unlock Drag (Edit HUD)"] = "Desbloquear Arrastre (Editar HUD)",
        ["Controls Global Scale"] = "Escala Global de Controles",
        ["Save Custom Layout"] = "Guardar Disposicion",
        ["Reset Default Layout"] = "Restablecer Disposicion",
        ["HUD Overlays"] = "Superposiciones de HUD",
        ["Performance Watermark"] = "Marca de Rendimiento",
        ["Custom Crosshair"] = "Punto de Mira Personalizado",
        ["Weapon Skins"] = "Skins de Armas",
        ["Select Weapon Skin"] = "Seleccionar Skin de Arma",
        ["Apply Weapon Skin"] = "Aplicar Skin de Arma",
        ["Reset Weapon Skin"] = "Restablecer Skin de Arma",
        ["Haki & Aura Customization"] = "Personalizacion de Haki y Aura",
        ["Haki Color"] = "Color de Haki",
        ["Rainbow Haki"] = "Haki Arcoiris",
        ["Custom Trail VFX"] = "Efectos Visuales de Estela",
        ["Music Player"] = "Reproductor de Musica",
        ["Genre / Category"] = "Genero / Categoria",
        ["Track Preset"] = "Pista Preestablecida",
        ["Custom Sound ID"] = "Sound ID Personalizado",
        ["Volume"] = "Volumen",
        ["Pitch / Speed"] = "Tono / Velocidad",
        ["Loop Track"] = "Repetir Pista",
        ["Show Top Music Bar"] = "Mostrar Barra de Musica Superior",
        ["Play"] = "Reproducir",
        ["Pause"] = "Pausar",
        ["Resume"] = "Reanudar",
        ["Stop"] = "Detener",
        ["Cinematic Animations"] = "Animaciones Cinematicas",
        ["Select Animation"] = "Seleccionar Animacion",
        ["Hide Accessories & Weapons"] = "Ocultar Accesorios y Armas",
        ["Play Animation"] = "Reproducir Animacion",
        ["Stop Animation"] = "Detener Animacion",
        ["Pure White"] = "Blanco Puro",
        ["Crimson Red"] = "Rojo Carmesi",
        ["Midnight Purple"] = "Purpura Medianoche",
        ["Electric Blue"] = "Azul Electrico",
        ["Emerald Green"] = "Verde Esmeralda",
        ["Golden Sun"] = "Sol Dorado",
        ["Default"] = "Por Defecto",
        ["None"] = "Ninguno",
        ["180"] = "180",
        ["2D Boxes"] = "Cajas 2D",
        ["2D Line"] = "Linea 2D",
        ["360"] = "360",
        ["3D Beam"] = "Rayo 3D",
        ["Accent Color & Theme Studio"] = "Estudio de Temas y Colores",
        ["Account & Player Statistics"] = "Estadisticas del Jugador",
        ["Aesthetic Studio Presets"] = "Ajustes Preestablecidos",
        ["Aim Mode"] = "Modo de Punteria",
        ["Aimbot"] = "Aimbot",
        ["Allows continuous mid-air jumping without cooldown"] = "Permite saltar en el aire continuamente sin recarga",
        ["Anti-Lava Damage"] = "Anti-Danio de Lava",
        ["Anti-Lava Immunity"] = "Inmunidad a la Lava",
        ["Apply Fast FFlags"] = "Aplicar Optimizacion FFlags",
        ["Apply Wallpaper"] = "Aplicar Fondo",
        ["Atmosphere Wallpaper"] = "Fondo de Pantalla Atmosferico",
        ["Atmosphere Wallpaper Presets (24 Styles)"] = "Fondos Atmosfericos (24 Estilos)",
        ["Auto Buso Haki"] = "Auto Haki de Armadura",
        ["Auto Combat"] = "Combate Automatico",
        ["Auto Race V3"] = "Auto Race V3",
        ["Auto Race V4"] = "Auto Race V4",
        ["Auto Skill Combo"] = "Auto Combo de Habilidades",
        ["Auto Skill on Soru"] = "Habilidad Automatica con Soru",
        ["Automatically activates Buso Armament Haki (No Ken)"] = "Activa automaticamente Buso Haki de armamento (sin Ken)",
        ["Automatically casts Race V3 ability in combat"] = "Lanza automaticamente la habilidad de Raza V3 en combate",
        ["Automatically triggers Race Awakening V4 when gauge is filled"] = "Activa despertar de Raza V4 cuando se llena la barra",
        ["B"] = "B",
        ["BELI"] = "BELI",
        ["BOUNTY"] = "RECOMPENSA",
        ["Background Dimming (%)"] = "Oscurecimiento de Fondo (%)",
        ["Balanced (65%)"] = "Equilibrado (65%)",
        ["Blue"] = "Azul",
        ["Both"] = "Ambos",
        ["Bottom"] = "Abajo",
        ["Bypasses walkspeed reset with direct physical impulse"] = "Evita el reinicio de velocidad con impulso fisico directo",
        ["C"] = "C",
        ["Calculates lead vector based on enemy velocity and ping"] = "Calcula anticipacion segun velocidad y ping",
        ["Camera FOV"] = "FOV de Camara",
        ["Camlock"] = "Camlock",
        ["Camlock (Combat Camera)"] = "Camlock (Camara de Combate)",
        ["Camlock Floating Widget"] = "Widget Flotante Camlock",
        ["Camlock Keybind"] = "Tecla de Camlock",
        ["Caps client to 22 FPS during Sanguine Z cooldown for physics boost"] = "Limita cliente a 22 FPS en cooldown de Sanguine Z para impulso",
        ["Cast Race V3 when in combat"] = "Activa Race V3 durante el combate",
        ["Cast Race V4 when gauge is full"] = "Activa Race V4 al llenarse la barra",
        ["Center"] = "Centro",
        ["Chams & Tracers"] = "Chams y Lineas",
        ["Chams Highlight Color"] = "Color de Chams",
        ["Clear / Dark Glass"] = "Limpiar / Cristal Oscuro",
        ["Combat Passives & Auto Skills"] = "Pasivas de Combate y Auto Habilidades",
        ["Combat PvP Status"] = "Estado de Combate PvP",
        ["Combat Targeting & Silent Aim"] = "Punteria de Combate y Silent Aim",
        ["Combat Tech"] = "Tecnicas de Combate",
        ["Combo Key"] = "Tecla de Combo",
        ["Combo Weapon"] = "Arma de Combo",
        ["Community"] = "Comunidad",
        ["Compact (80%)"] = "Compacto (80%)",
        ["Config"] = "Configuracion",
        ["Configuration Profiles"] = "Perfiles de Configuracion",
        ["Configuration Reset"] = "Reinicio de Configuracion",
        ["Copy Discord Invite Link"] = "Copiar Enlace de Discord",
        ["Copy Server JobId"] = "Copiar JobId del Servidor",
        ["Credits"] = "Creditos",
        ["Crystal (80%)"] = "Cristal (80%)",
        ["Custom Dash Length"] = "Distancia de Deslizamiento",
        ["Custom WalkSpeed"] = "Velocidad Personalizada",
        ["Custom Wallpaper"] = "Fondo Personalizado",
        ["Custom Wallpaper Studio"] = "Estudio de Fondos Personalizados",
        ["Cyan"] = "Cian",
        ["Dash Distance"] = "Distancia de Impulso",
        ["Destroys environmental lava kill zones and damage parts"] = "Destruye zonas de dano y lava del entorno",
        ["Detects safe zone and in-combat status indicators"] = "Detecta zona segura y estado de combate",
        ["Developer & Content Creator"] = "Desarrollador y Creador",
        ["Development Team & Content Creators"] = "Equipo de Desarrollo y Creadores",
        ["Devil Fruit Tracker"] = "Rastreador de Frutas",
        ["Direct Wallpaper"] = "Fondo Directo",
        ["Disable All Visuals"] = "Desactivar Todos los Visuales",
        ["Display aim boundary circle"] = "Muestra el circulo limite de punteria",
        ["Displays formatted usernames above character heads"] = "Muestra el nombre sobre la cabeza del jugador",
        ["Displays live gradient health bars and HP percentage"] = "Muestra barras de salud y porcentaje de vida",
        ["Displays movable on-screen JUMP button for touch"] = "Muestra un boton tactil movil de SALTO en pantalla",
        ["Displays movable on-screen action button for Sanguine Z"] = "Muestra boton flotante de accion para Sanguine Z",
        ["Displays movable on-screen button to toggle camera lock"] = "Muestra un boton movil en pantalla para alternar bloqueo de camara",
        ["Displays movable on-screen toggle for Dragon Gun M1"] = "Muestra un control movil en pantalla para Dragon Gun M1",
        ["Displays movable on-screen toggle for camera lock"] = "Muestra boton flotante para fijar camara",
        ["Displays player bounty or honor value in millions"] = "Muestra recompensa o valor de honor en millones",
        ["Displays targeting circle boundary on screen"] = "Muestra el limite del circulo de punteria en pantalla",
        ["Distance Indicator"] = "Indicador de Distancia",
        ["Dragon Gun M1"] = "Dragon Gun M1",
        ["Dragon Gun M1 Floating Widget"] = "Widget Flotante Dragon Gun M1",
        ["Draws dynamic bounding boxes around enemy players"] = "Dibuja recuadros dinamicos en enemigos",
        ["Draws line from bottom of screen to tracked players"] = "Dibuja linea desde abajo hacia jugadores",
        ["E"] = "E",
        ["ESP Style"] = "Estilo de ESP",
        ["ESP Text Font Size"] = "Tamano de Fuente ESP",
        ["ESP Visuals"] = "Visuales ESP",
        ["Enable All Visuals"] = "Activar Todos los Visuales",
        ["Enable Target Prediction"] = "Activar Prediccion de Blanco",
        ["Enable player visual highlights"] = "Activa el resaltado de jugadores",
        ["Enables custom movement speed multiplier"] = "Habilita multiplicador de velocidad personalizada",
        ["Enables high-performance player visual tracking"] = "Habilita rastreo visual de jugadores de alto rendimiento",
        ["English"] = "Ingles",
        ["Equipped Tool / Weapon"] = "Arma Equipada",
        ["Equips weapon and casts chosen skill upon Soru animation"] = "Equipa arma y lanza habilidad al hacer Soru",
        ["Esp"] = "Visuales",
        ["Executes rapid melee, sword, and fruit attack bursts"] = "Ejecuta rafagas veloces para melee, espadas y frutas",
        ["Executes rapid primary attacks on all nearby enemies"] = "Ejecuta ataques principales rapidos contra todos los enemigos cercanos",
        ["F"] = "F",
        ["FACTION"] = "FACCION",
        ["FOV"] = "FOV",
        ["FOV Color"] = "Color del FOV",
        ["FOV Position"] = "Posicion del FOV",
        ["FOV Radius"] = "Radio de FOV",
        ["FOV Thickness"] = "Grosor de FOV",
        ["FPS"] = "FPS",
        ["FRUIT"] = "FRUTA",
        ["Fast Attack"] = "Ataque Rapido",
        ["Fast Attack (Melee, Sword, Fruit)"] = "Ataque Rapido (Melee, Espada, Fruta)",
        ["Fast Flags"] = "Optimizacion Rapida",
        ["FFlags 1 (FPS Booster)"] = "FFlags 1 (Mejora de FPS)",
        ["120 FPS cap, smooth plastic textures, removes atmosphere fog, hides debris"] = "Limite de 120 FPS, texturas plasticas, elimina niebla y oculta escombros",
        ["No Animations"] = "Sin Animaciones",
        ["Stops non-attack animations to fix sideways bug and character freezes"] = "Detiene animaciones ajenas al ataque para corregir congelamientos",
        ["Fast Flags & Engine Tuning"] = "Fast Flags y Ajustes de Motor",
        ["Field of View"] = "Campo de Vision",
        ["Field of View (FOV Customization)"] = "Campo de Vision (FOV)",
        ["Forward velocity boost"] = "Impulso de velocidad hacia adelante",
        ["French"] = "Frances",
        ["Fruit"] = "Fruta",
        ["Game Stats"] = "Estadisticas de Juego",
        ["Glass Interface & Visual Effects"] = "Interfaz de Cristal y Efectos",
        ["Glass Transparency"] = "Transparencia de Cristal",
        ["Green"] = "Verde",
        ["Gun"] = "Arma",
        ["Gun Aura (Dragon Gun M1)"] = "Gun Aura (Dragon Gun M1)",
        ["Head"] = "Cabeza",
        ["High jump leap"] = "Salto de gran altura",
        ["High-distance forward velocity boost with keybind Z"] = "Impulso de velocidad frontal de larga distancia con tecla Z",
        ["Home"] = "Inicio",
        ["HumanoidRootPart"] = "HumanoidRootPart",
        ["Identifies equipped Devil Fruit power (Kitsune, Portal, etc.)"] = "Identifica la fruta equipada (Kitsune, Portal, etc.)",
        ["Illuminates full player character models through walls"] = "Ilumina modelos de jugadores a traves de paredes",
        ["Immunity to lava damage"] = "Inmunidad al danio de lava",
        ["In-Game Attributes"] = "Atributos del Juego",
        ["Increase dash distance"] = "Aumenta la distancia del deslizamiento",
        ["Infinite Jump"] = "Salto Infinito",
        ["Infinite Soru"] = "Soru Infinito",
        ["Interface Effects"] = "Efectos Visuales",
        ["Interface Language"] = "Idioma de Interfaz",
        ["Interface Scale"] = "Escala de Interfaz",
        ["Jump continuously in mid-air"] = "Salta continuamente en el aire",
        ["Keep Armament Haki active"] = "Mantiene el Haki de Armadura activo",
        ["LEVEL"] = "NIVEL",
        ["Language"] = "Idioma",
        ["Language & Localization"] = "Idioma y Localizacion",
        ["Large (120%)"] = "Grande (120%)",
        ["Load Configuration Profile"] = "Cargar Perfil de Configuracion",
        ["Load Config"] = "Cargar Configuracion",
        ["Lock camera onto enemy"] = "Fija la camara al enemigo",
        ["Locks camera perspective directly onto focused enemy player"] = "Fija la camara directamente sobre el jugador enemigo enfocado",
        ["Looking At Me"] = "Mirandome",
        ["Low HP"] = "Menor Vida",
        ["Master ESP"] = "ESP Principal",
        ["Master ESP Toggle"] = "Interruptor Maestro de ESP",
        ["Master Visuals & Chams"] = "Visuales Maestros y Chams",
        ["Max Range"] = "Rango Maximo",
        ["Max Soru Range"] = "Rango Maximo de Soru",
        ["Melee"] = "Cuerpo a Cuerpo",
        ["Misc"] = "Varios",
        ["Mouse"] = "Raton",
        ["Move smoothly through structures and physical obstacles"] = "Permite moverse a traves de estructuras y obstaculos",
        ["Movement"] = "Movimiento",
        ["Movement & Agility (PvP Physics)"] = "Movimiento y Agilidad (Fisicas PvP)",
        ["Multiplies dash distance for high-speed repositioning"] = "Multiplica distancia de dash para reposicionamiento rapido",
        ["Multiplies jump impulse for vertical escape and aerial combat"] = "Multiplica impulso de salto para escape vertical y combate",
        ["NPC Silent Aim"] = "Silent Aim en NPCs",
        ["Nearest"] = "Mas Cercano",
        ["Nearest Player"] = "Jugador Mas Cercano",
        ["Neon Rain Layer"] = "Lluvia Cyber Neon",
        ["Next (›)"] = "Siguiente (›)",
        ["Noclip Wallpass"] = "Noclip Traspasar Paredes",
        ["None"] = "Ninguno",
        ["Official Community & Discord"] = "Comunidad Oficial y Discord",
        ["Orange"] = "Naranja",
        ["Overhead Billboard"] = "Rotulo Superior",
        ["PING"] = "LATENCIA",
        ["PLAYERS"] = "JUGADORES",
        ["Pass through walls and objects"] = "Atraviesa paredes y objetos",
        ["Performance"] = "Rendimiento",
        ["Performance & Network"] = "Rendimiento y Red",
        ["Pink"] = "Rosa",
        ["Player"] = "Jugador",
        ["Player 2D Boxes"] = "Cajas 2D de Jugadores",
        ["Player Bounty Tracker"] = "Bounty del Jugador",
        ["Player Chams & Tracers"] = "Chams y Rastreadores",
        ["Player Chams (Highlight)"] = "Chams de Jugador (Highlight)",
        ["Player Health Status"] = "Salud del Jugador",
        ["Player Level Display"] = "Nivel del Jugador",
        ["Player Names"] = "Nombres de Jugadores",
        ["Player Profile"] = "Perfil del Jugador",
        ["Player Profile & Account"] = "Perfil del Jugador y Cuenta",
        ["Player Radar Elements"] = "Elementos de Radar de Jugador",
        ["Player Silent Aim"] = "Silent Aim en Jugadores",
        ["Player Tracer Color"] = "Color de Linea de Jugador",
        ["Player Tracers"] = "Lineas a Jugadores",
        ["Portuguese"] = "Portugues",
        ["Prediction Amount"] = "Cantidad de Prediccion",
        ["Premium User  •  Active Session"] = "Usuario Premium  •  Sesion Activa",
        ["Preset: Crimson Slayer"] = "Estilo: Asesino Carmesi",
        ["Preset: Cyberpunk Violet"] = "Estilo: Violeta Cyberpunk",
        ["Preset: Emerald Forest"] = "Estilo: Bosque Esmeralda",
        ["Preset: Shorekeeper Cyan"] = "Estilo: Shorekeeper Cian",
        ["Previous (‹)"] = "Anterior (‹)",
        ["Purple"] = "Morado",
        ["PvP"] = "PvP",
        ["PvP Tech, Camlock & Universal Keybinds"] = "Tecnologia PvP, Camlock y Teclas",
        ["Q"] = "Q",
        ["Quick Actions"] = "Acciones Rapidas",
        ["R"] = "R",
        ["RACE"] = "RAZA",
        ["Radar Elements"] = "Elementos de Radar",
        ["Rainbow"] = "Arcoiris",
        ["Rainbow Chroma Speed"] = "Velocidad de Chroma Arcoiris",
        ["Raindrop Density"] = "Densidad de Gotas",
        ["Random (Shuffle)"] = "Aleatorio",
        ["Rapid fire M1 gun shots"] = "Disparos M1 ultra rapidos",
        ["Rapid melee and weapon strikes"] = "Golpes rapidos cuerpo a cuerpo",
        ["Rapid weapon hit bursts"] = "Golpes continuos de arma",
        ["Rapid-fire gun attack loop targeting nearest combatant"] = "Ataque rapido con arma de fuego al objetivo mas cercano",
        ["Red"] = "Rojo",
        ["Redirect skills toward enemy players"] = "Redirige habilidades a jugadores enemigos",
        ["Redirect skills toward mobs and bosses"] = "Redirige habilidades a monstruos y jefes",
        ["Redirects Flashstep teleport directly to enemy player"] = "Redirige el teletransporte directamente al jugador enemigo",
        ["Redirects skills and attacks towards enemy players"] = "Redirige habilidades y ataques hacia jugadores enemigos",
        ["Redirects skills and attacks towards mobs and bosses"] = "Redirige habilidades y ataques hacia monstruos y jefes",
        ["Rejoin Current Server"] = "Reconectar al Servidor",
        ["Remove flashstep cooldown"] = "Elimina el enfriamiento del flashstep",
        ["Removes cooldown delay and bypasses stamina limits"] = "Elimina tiempo de recarga y limites de energia",
        ["Renders hardware 3D Beams and 2D lines to target"] = "Dibuja rayos 3D y lineas 2D al objetivo",
        ["Reset All Settings to Factory Defaults"] = "Restablecer Todo de Fabrica",
        ["Reset Configuration Profile"] = "Restablecer Perfil de Configuracion",
        ["Reset Config"] = "Restablecer Configuracion",
        ["Configuration profile reset to defaults."] = "Perfil de configuracion restablecido a valores por defecto.",
        ["Reset Theme to Purple"] = "Restablecer Tema a Purpura",
        ["Sanguine Boost"] = "Sanguine Boost",
        ["Sanguine Boost Floating Widget"] = "Widget Flotante Sanguine Z",
        ["Sanguine Keybind"] = "Tecla de Sanguine",
        ["Save Configuration Profile"] = "Guardar Perfil de Configuracion",
        ["Save Config"] = "Guardar Configuracion",
        ["Selected Player"] = "Jugador Seleccionado",
        ["Server Hop (Fast)"] = "Cambio de Servidor (Rapido)",
        ["Show FOV Circle"] = "Mostrar Circulo FOV",
        ["Show Tracers"] = "Mostrar Lineas de Rastreo",
        ["Shows distance measurement in studs below player feet"] = "Muestra la distancia en studs bajo los pies",
        ["Shows player rank and numerical level tag"] = "Muestra rango y nivel numerico del jugador",
        ["Shows weapon, sword, fruit or gun held by the player"] = "Muestra arma, espada, fruta o pistola equipada",
        ["Silent Aim"] = "Silent Aim",
        ["Skill Blacklist"] = "Lista Negra de Habilidades",
        ["Skill Delay"] = "Retardo de Habilidad",
        ["Skill Redirection Blacklist"] = "Lista Negra de Habilidades",
        ["Soru"] = "Soru",
        ["Soru Aimbot"] = "Soru Aimbot",
        ["Soru Combat Aimbot"] = "Aimbot Soru",
        ["Soru Flashstep Engine"] = "Motor Soru Flashstep",
        ["Soru Skill Combo"] = "Combo de Habilidades Soru",
        ["Soru Skill Combo Automation"] = "Auto Combo de Habilidades Soru",
        ["Soru Target Mode"] = "Modo de Objetivo Soru",
        ["Spanish"] = "Espanol",
        ["Spawns water surface collider allowing sprint across oceans"] = "Crea plataforma acuatica para correr sobre oceanos",
        ["Speed up player movement"] = "Aumenta la velocidad del jugador",
        ["Standard (100%)"] = "Estandar (100%)",
        ["Subtle (50%)"] = "Sutil (50%)",
        ["Super Jump"] = "Super Salto",
        ["Super Jump Floating Widget"] = "Widget Flotante de Super Salto",
        ["Super Jump Force"] = "Fuerza de Super Salto",
        ["Sword"] = "Espada",
        ["System Info"] = "Informacion del Sistema",
        ["T"] = "T",
        ["Target Hitbox"] = "Zona de Impacto",
        ["Target Player Selection"] = "Seleccion de Jugador Objetivo",
        ["Target Priority"] = "Prioridad de Blanco",
        ["Target Selection & Aim Mode"] = "Seleccion de Objetivo y Modo",
        ["Target Tracers"] = "Rastreadores de Objetivo",
        ["Teleport soru directly to enemy"] = "Teletransporta con soru hacia el enemigo",
        ["Theme Presets"] = "Estilos de Tema",
        ["Theme Reset"] = "Restablecer Tema",
        ["Themes"] = "Temas",
        ["Toggle Rainbow Chroma Mode"] = "Activar Modo Chroma Arcoiris",
        ["Toggle animated falling cyber rain streaks"] = "Activa lluvia animada cyber neon",
        ["Tracer Color"] = "Color de Linea",
        ["Tracer Mode"] = "Modo de Linea",
        ["Tracer Origin"] = "Origen de Linea",
        ["Tracer Thickness"] = "Grosor de Linea",
        ["Tracers"] = "Lineas de Rastreo",
        ["Trigger Super Jump"] = "Activar Super Salto",
        ["Typography Font"] = "Fuente Tipografica",
        ["Typography Studio"] = "Estudio de Tipografia",
        ["UPTIME"] = "TIEMPO ACTIVO",
        ["Ultra fast burst firing with CombatController validator"] = "Disparos en rafaga ultra veloces con validador CombatController",
        ["UpperTorso"] = "Torso Superior",
        ["Use skill instantly after Soru"] = "Lanza habilidad al usar Soru",
        ["V"] = "V",
        ["Vietnamese"] = "Vietnamita",
        ["Visuals"] = "Visuales",
        ["Vitality & Energy Status"] = "Estado de Salud y Energia",
        ["Walk on Water"] = "Caminar sobre el Agua",
        ["Walk on ocean surface"] = "Caminar sobre el mar",
        ["WalkSpeed Value"] = "Valor de Velocidad",
        ["Wallpaper"] = "Fondo de Pantalla",
        ["Wallpapers"] = "Fondos de Pantalla",
        ["White"] = "Blanco",
        ["World & Client Optimization"] = "Optimizacion de Mundo y Cliente",
        ["X"] = "X",
        ["Yellow"] = "Amarillo",
        ["Z"] = "Z",
        ["Z Sanguine Boost"] = "Impulso Sanguine Z",
        ["B1 Hold Time (s)"] = "B1 Tiempo de Retencion (s)",
        ["B1 Mode"] = "B1 Modo",
        ["B1 Post Jumps"] = "B1 Saltos Posteriores",
        ["B1 Skill Key"] = "B1 Tecla",
        ["B1 Weapon"] = "B1 Arma",
        ["B2 Hold Time (s)"] = "B2 Tiempo de Retencion (s)",
        ["B2 Mode"] = "B2 Modo",
        ["B2 Post Jumps"] = "B2 Saltos Posteriores",
        ["B2 Skill Key"] = "B2 Tecla",
        ["B2 Weapon"] = "B2 Arma",
        ["B3 Hold Time (s)"] = "B3 Tiempo de Retencion (s)",
        ["B3 Mode"] = "B3 Modo",
        ["B3 Post Jumps"] = "B3 Saltos Posteriores",
        ["B3 Skill Key"] = "B3 Tecla",
        ["B3 Weapon"] = "B3 Arma",
        ["B4 Hold Time (s)"] = "B4 Tiempo de Retencion (s)",
        ["B4 Mode"] = "B4 Modo",
        ["B4 Post Jumps"] = "B4 Saltos Posteriores",
        ["B4 Skill Key"] = "B4 Tecla",
        ["B4 Weapon"] = "B4 Arma",
        ["B5 Hold Time (s)"] = "B5 Tiempo de Retencion (s)",
        ["B5 Mode"] = "B5 Modo",
        ["B5 Post Jumps"] = "B5 Saltos Posteriores",
        ["B5 Skill Key"] = "B5 Tecla",
        ["B5 Weapon"] = "B5 Arma",
        ["B6 Hold Time (s)"] = "B6 Tiempo de Retencion (s)",
        ["B6 Mode"] = "B6 Modo",
        ["B6 Post Jumps"] = "B6 Saltos Posteriores",
        ["B6 Skill Key"] = "B6 Tecla",
        ["B6 Weapon"] = "B6 Arma",
        ["Block 1 Enabled"] = "Bloque 1 Activado",
        ["Block 2 Enabled"] = "Bloque 2 Activado",
        ["Block 3 Enabled"] = "Bloque 3 Activado",
        ["Block 4 Enabled"] = "Bloque 4 Activado",
        ["Block 5 Enabled"] = "Bloque 5 Activado",
        ["Block 6 Enabled"] = "Bloque 6 Activado",
        ["Combo Sequence (6 Blocks)"] = "Secuencia de Combo (6 Bloques)",
        ["Display real-time FPS and ping overlay top-left"] = "Muestra overlay de FPS y ping en tiempo real",
        ["Displays on-screen one-touch button to trigger combo"] = "Muestra boton en pantalla para activar combo",
        ["Do not target allied players"] = "No apuntar a jugadores aliados",
        ["Do not target players inside safe zones"] = "No apuntar a jugadores dentro de zonas seguras",
        ["Do not target players with PvP disabled"] = "No apuntar a jugadores con PvP desactivado",
        ["Enable step 1 in combo"] = "Activa el paso 1 en el combo",
        ["Enable step 2 in combo"] = "Activa el paso 2 en el combo",
        ["Enable step 3 in combo"] = "Activa el paso 3 en el combo",
        ["Enable step 4 in combo"] = "Activa el paso 4 en el combo",
        ["Enable step 5 in combo"] = "Activa el paso 5 en el combo",
        ["Enable step 6 in combo"] = "Activa el paso 6 en el combo",
        ["Enables keyboard trigger and loop execution"] = "Habilita activacion por teclado y bucle",
        ["Fly"] = "Volar",
        ["Fly Speed"] = "Velocidad de Vuelo",
        ["Glide freely through the air"] = "Planea libremente por el aire",
        ["Ignore Allies"] = "Ignorar Aliados",
        ["Ignore PvP Off"] = "Ignorar PvP Desactivado",
        ["Ignore Safe Zone"] = "Ignorar Zona Segura",
        ["Loop Sequence"] = "Secuencia en Bucle",
        ["Macro"] = "Macro",
        ["Macro Controller"] = "Controlador de Macro",
        ["Macro Enabled"] = "Macro Activado",
        ["Macro Floating Widget"] = "Widget Flotante de Macro",
        ["Macro Slot"] = "Ranura de Macro",
        ["Repeat sequence continuously until stopped"] = "Repite la secuencia continuamente hasta detenerla",
        ["Show FPS & Ping"] = "Mostrar FPS y Ping",
        ["Start Combo Sequence"] = "Iniciar Secuencia de Combo",
        ["Stop Combo Sequence"] = "Detener Secuencia de Combo",
        ["Trigger Key (PC)"] = "Tecla de Activacion (PC)",
        ["YouTube & External Players"] = "Reproductores Externos y YouTube",
        ["Launch Universal YouTube Player"] = "Lanzar Reproductor Universal de YouTube",
        ["Launch Audio Library Player"] = "Lanzar Biblioteca de Audio",
        ["Roblox Audio Player"] = "Reproductor de Audio Roblox",
    },
    ["Portuguese"] = {
        ["Player Management"] = "Gerenciamento de Jogadores",
        ["Search Player..."] = "Pesquisar Jogador...",
        ["Refresh Player List"] = "Atualizar Lista",
        ["Blacklist"] = "Lista Negra",
        ["Blacklisted"] = "Na Lista Negra",
        ["Spectate"] = "Espectar",
        ["Spectating"] = "Espectando",
        ["Stop Spectating"] = "Parar de Espectar",
        ["Teleport to Player"] = "Teleportar para o Jogador",
        ["Total Players"] = "Total de Jogadores",
        ["Auto Dungeon Engine"] = "Motor de Auto Dungeon",
        ["Start Auto Dungeon"] = "Iniciar Auto Dungeon",
        ["Auto Buso"] = "Auto Buso",
        ["Selected Weapon"] = "Arma Selecionada",
        ["Sword"] = "Espada",
        ["Melee"] = "Combate",
        ["Blox Fruit"] = "Blox Fruit",
        ["Attack Height"] = "Altura de Ataque",
        ["Auto Pass Room"] = "Auto Passar Sala",
        ["Void M1 Engine"] = "Motor Void M1",
        ["Enable Void M1"] = "Ativar Void M1",
        ["Void Only Boss Rooms"] = "Void Apenas Salas de Chefe",
        ["Void Interval (s)"] = "Intervalo de Void (s)",
        ["Dungeon Status & Utilities"] = "Status e Utilitarios de Dungeon",
        ["Auto Load Dungeon"] = "Auto Carregar Dungeon",
        ["Current Room"] = "Sala Atual",
        ["Boss Status"] = "Status do Chefe",
        ["Island Teleport"] = "Teleporte de Ilhas",
        ["Select Sea"] = "Selecionar Mar",
        ["Sea 1"] = "Mar 1",
        ["Sea 2"] = "Mar 2",
        ["Sea 3"] = "Mar 3",
        ["Target Island"] = "Ilha Alvo",
        ["Tween Speed"] = "Velocidade de Tween",
        ["Travel Altitude"] = "Altitude de Viagem",
        ["Noclip during Tween"] = "Noclip durante Tween",
        ["Start Teleport"] = "Iniciar Teleporte",
        ["Stop Teleport"] = "Parar Teleporte",
        ["Controls Layout Editor"] = "Editor de Layout de Controles",
        ["Unlock Drag (Edit HUD)"] = "Desbloquear Arraste (Editar HUD)",
        ["Controls Global Scale"] = "Escala Global de Controles",
        ["Save Custom Layout"] = "Salvar Layout",
        ["Reset Default Layout"] = "Redefinir Layout",
        ["HUD Overlays"] = "Sobreposicoes de HUD",
        ["Performance Watermark"] = "Marca de Desempenho",
        ["Custom Crosshair"] = "Mira Personalizada",
        ["Weapon Skins"] = "Skins de Armas",
        ["Select Weapon Skin"] = "Selecionar Skin de Arma",
        ["Apply Weapon Skin"] = "Aplicar Skin de Arma",
        ["Reset Weapon Skin"] = "Redefinir Skin de Arma",
        ["Haki & Aura Customization"] = "Personalizacao de Haki e Aura",
        ["Haki Color"] = "Cor do Haki",
        ["Rainbow Haki"] = "Haki Arco-iris",
        ["Custom Trail VFX"] = "Efeitos Visuais de Rastro",
        ["Music Player"] = "Reprodutor de Musica",
        ["Genre / Category"] = "Genero / Categoria",
        ["Track Preset"] = "Faixa Predefinida",
        ["Custom Sound ID"] = "Sound ID Personalizado",
        ["Volume"] = "Volume",
        ["Pitch / Speed"] = "Tom / Velocidade",
        ["Loop Track"] = "Repetir Faixa",
        ["Show Top Music Bar"] = "Mostrar Barra de Musica Superior",
        ["Play"] = "Tocar",
        ["Pause"] = "Pausar",
        ["Resume"] = "Retomar",
        ["Stop"] = "Parar",
        ["Cinematic Animations"] = "Animacoes Cinematicas",
        ["Select Animation"] = "Selecionar Animacao",
        ["Hide Accessories & Weapons"] = "Ocultar Acessorios e Armas",
        ["Play Animation"] = "Executar Animacao",
        ["Stop Animation"] = "Parar Animacao",
        ["Pure White"] = "Branco Puro",
        ["Crimson Red"] = "Vermelho Carmesim",
        ["Midnight Purple"] = "Roxo Meia-noite",
        ["Electric Blue"] = "Azul Eletrico",
        ["Emerald Green"] = "Verde Esmeralda",
        ["Golden Sun"] = "Sol Dourado",
        ["Default"] = "Padrao",
        ["None"] = "Nenhum",
        ["180"] = "180",
        ["2D Boxes"] = "Caixas 2D",
        ["2D Line"] = "Linha 2D",
        ["360"] = "360",
        ["3D Beam"] = "Feixe 3D",
        ["Accent Color & Theme Studio"] = "Estudio de Temas e Cores",
        ["Account & Player Statistics"] = "Estatisticas do Jogador",
        ["Aesthetic Studio Presets"] = "Predefinicoes de Estilo",
        ["Aim Mode"] = "Modo de Mira",
        ["Aimbot"] = "Aimbot",
        ["Allows continuous mid-air jumping without cooldown"] = "Permite pular no ar continuamente sem recarga",
        ["Anti-Lava Damage"] = "Anti-Dano de Lava",
        ["Anti-Lava Immunity"] = "Imunidade a Lava",
        ["Apply Fast FFlags"] = "Aplicar Otimizacao FFlags",
        ["Apply Wallpaper"] = "Aplicar Papel de Parede",
        ["Atmosphere Wallpaper"] = "Papel de Parede Atmosferico",
        ["Atmosphere Wallpaper Presets (24 Styles)"] = "Papeis de Parede Atmosfericos (24 Estilos)",
        ["Auto Buso Haki"] = "Auto Haki de Armamento",
        ["Auto Combat"] = "Combate Automatico",
        ["Auto Race V3"] = "Auto Race V3",
        ["Auto Race V4"] = "Auto Race V4",
        ["Auto Skill Combo"] = "Auto Combo de Habilidades",
        ["Auto Skill on Soru"] = "Habilidade Automatica no Soru",
        ["Automatically activates Buso Armament Haki (No Ken)"] = "Ativa automaticamente Buso Haki de armamento (sem Ken)",
        ["Automatically casts Race V3 ability in combat"] = "Usa automaticamente a habilidade de Raca V3 em combate",
        ["Automatically triggers Race Awakening V4 when gauge is filled"] = "Ativa o despertar de Raca V4 quando a barra enche",
        ["B"] = "B",
        ["BELI"] = "BELI",
        ["BOUNTY"] = "RECOMPENSA",
        ["Background Dimming (%)"] = "Escurecimento do Fundo (%)",
        ["Balanced (65%)"] = "Equilibrado (65%)",
        ["Blue"] = "Azul",
        ["Both"] = "Ambos",
        ["Bottom"] = "Inferior",
        ["Bypasses walkspeed reset with direct physical impulse"] = "Ignora reinicio de velocidade com impulso fisico direto",
        ["C"] = "C",
        ["Calculates lead vector based on enemy velocity and ping"] = "Calcula antecipacao com base na velocidade e ping",
        ["Camera FOV"] = "FOV da Camera",
        ["Camlock"] = "Camlock",
        ["Camlock (Combat Camera)"] = "Camlock (Camera de Combate)",
        ["Camlock Floating Widget"] = "Widget Flutuante Camlock",
        ["Camlock Keybind"] = "Tecla do Camlock",
        ["Caps client to 22 FPS during Sanguine Z cooldown for physics boost"] = "Limita cliente a 22 FPS no cooldown de Sanguine Z para impulso",
        ["Cast Race V3 when in combat"] = "Ativa Race V3 durante o combate",
        ["Cast Race V4 when gauge is full"] = "Ativa Race V4 quando a barra encher",
        ["Center"] = "Centro",
        ["Chams & Tracers"] = "Chams e Linhas",
        ["Chams Highlight Color"] = "Cor do Chams",
        ["Clear / Dark Glass"] = "Limpar / Vidro Escuro",
        ["Combat Passives & Auto Skills"] = "Passivas de Combate e Auto Habilidades",
        ["Combat PvP Status"] = "Status de Combate PvP",
        ["Combat Targeting & Silent Aim"] = "Mira de Combate e Silent Aim",
        ["Combat Tech"] = "Tecnicas de Combate",
        ["Combo Key"] = "Tecla de Combo",
        ["Combo Weapon"] = "Arma de Combo",
        ["Community"] = "Comunidade",
        ["Compact (80%)"] = "Compacto (80%)",
        ["Config"] = "Configuracao",
        ["Configuration Profiles"] = "Perfis de Configuracao",
        ["Configuration Reset"] = "Redefinicao de Configuracao",
        ["Copy Discord Invite Link"] = "Copiar Link do Discord",
        ["Copy Server JobId"] = "Copiar JobId do Servidor",
        ["Credits"] = "Creditos",
        ["Crystal (80%)"] = "Cristal (80%)",
        ["Custom Dash Length"] = "Distancia de Deslize",
        ["Custom WalkSpeed"] = "Velocidade Personalizada",
        ["Custom Wallpaper"] = "Papel de Parede Personalizado",
        ["Custom Wallpaper Studio"] = "Estudio de Papel de Parede Personalizado",
        ["Cyan"] = "Ciano",
        ["Dash Distance"] = "Distancia do Impulso",
        ["Destroys environmental lava kill zones and damage parts"] = "Destroi zonas de dano e partes de lava do ambiente",
        ["Detects safe zone and in-combat status indicators"] = "Detecta zona segura e status de combate",
        ["Developer & Content Creator"] = "Desenvolvedor e Criador",
        ["Development Team & Content Creators"] = "Equipe de Desenvolvimento e Criadores",
        ["Devil Fruit Tracker"] = "Rastreador de Frutas",
        ["Direct Wallpaper"] = "Papel de Parede Direto",
        ["Disable All Visuals"] = "Desativar Todos os Visuais",
        ["Display aim boundary circle"] = "Exibe o circulo limite de mira",
        ["Displays formatted usernames above character heads"] = "Exibe o nome sobre a cabeca do jogador",
        ["Displays live gradient health bars and HP percentage"] = "Exibe barras de vida e porcentagem de HP",
        ["Displays movable on-screen JUMP button for touch"] = "Exibe um botao movel de PULO na tela para toque",
        ["Displays movable on-screen action button for Sanguine Z"] = "Exibe botao de acao flutuante para Sanguine Z",
        ["Displays movable on-screen button to toggle camera lock"] = "Exibe um botao movel na tela para alternar o bloqueio de camera",
        ["Displays movable on-screen toggle for Dragon Gun M1"] = "Exibe um controle movel na tela para Dragon Gun M1",
        ["Displays movable on-screen toggle for camera lock"] = "Exibe botao flutuante para travar camera",
        ["Displays player bounty or honor value in millions"] = "Exibe a recompensa ou valor de honra em milhoes",
        ["Displays targeting circle boundary on screen"] = "Exibe o limite do circulo de mira na tela",
        ["Distance Indicator"] = "Indicador de Distancia",
        ["Dragon Gun M1"] = "Dragon Gun M1",
        ["Dragon Gun M1 Floating Widget"] = "Widget Flutuante Dragon Gun M1",
        ["Draws dynamic bounding boxes around enemy players"] = "Desenha caixas dinamicas ao redor de inimigos",
        ["Draws line from bottom of screen to tracked players"] = "Desenha linha da parte inferior ate os jogadores",
        ["E"] = "E",
        ["ESP Style"] = "Estilo de ESP",
        ["ESP Text Font Size"] = "Tamanho da Fonte ESP",
        ["ESP Visuals"] = "Visuais ESP",
        ["Enable All Visuals"] = "Ativar Todos os Visuais",
        ["Enable Target Prediction"] = "Ativar Predicao de Alvo",
        ["Enable player visual highlights"] = "Ativa o destaque visual dos jogadores",
        ["Enables custom movement speed multiplier"] = "Habilita multiplicador de velocidade personalizada",
        ["Enables high-performance player visual tracking"] = "Habilita rastreamento visual de alta performance",
        ["English"] = "Ingles",
        ["Equipped Tool / Weapon"] = "Arma Equipada",
        ["Equips weapon and casts chosen skill upon Soru animation"] = "Equipa arma e lanca habilidade ao usar Soru",
        ["Esp"] = "Visuais",
        ["Executes rapid melee, sword, and fruit attack bursts"] = "Executa rajadas rapidas para melee, espadas e frutas",
        ["Executes rapid primary attacks on all nearby enemies"] = "Executa ataques primarios rapidos em todos os inimigos proximos",
        ["F"] = "F",
        ["FACTION"] = "FACAO",
        ["FOV"] = "FOV",
        ["FOV Color"] = "Cor do FOV",
        ["FOV Position"] = "Posicao do FOV",
        ["FOV Radius"] = "Raio do FOV",
        ["FOV Thickness"] = "Espessura do FOV",
        ["FPS"] = "FPS",
        ["FRUIT"] = "FRUTA",
        ["Fast Attack"] = "Ataque Rapido",
        ["Fast Attack (Melee, Sword, Fruit)"] = "Ataque Rapido (Melee, Espada, Fruta)",
        ["Fast Flags"] = "Otimizacao Rapida",
        ["FFlags 1 (FPS Booster)"] = "FFlags 1 (Reforco de FPS)",
        ["120 FPS cap, smooth plastic textures, removes atmosphere fog, hides debris"] = "Limite de 120 FPS, texturas plasticas, remove nevoeiro e oculta detritos",
        ["No Animations"] = "Sem Animacoes",
        ["Stops non-attack animations to fix sideways bug and character freezes"] = "Para animacoes fora de ataque para corrigir travamentos",
        ["Fast Flags & Engine Tuning"] = "Fast Flags e Otimizacao do Motor",
        ["Field of View"] = "Campo de Visao",
        ["Field of View (FOV Customization)"] = "Campo de Visao (FOV)",
        ["Forward velocity boost"] = "Impulso de velocidade para frente",
        ["French"] = "Frances",
        ["Fruit"] = "Fruta",
        ["Game Stats"] = "Estatisticas de Jogo",
        ["Glass Interface & Visual Effects"] = "Interface de Vidro e Efeitos",
        ["Glass Transparency"] = "Transparencia do Vidro",
        ["Green"] = "Verde",
        ["Gun"] = "Arma de Fogo",
        ["Gun Aura (Dragon Gun M1)"] = "Gun Aura (Dragon Gun M1)",
        ["Head"] = "Cabeca",
        ["High jump leap"] = "Salto de grande altura",
        ["High-distance forward velocity boost with keybind Z"] = "Impulso de velocidade para frente a longa distancia com tecla Z",
        ["Home"] = "Inicio",
        ["HumanoidRootPart"] = "HumanoidRootPart",
        ["Identifies equipped Devil Fruit power (Kitsune, Portal, etc.)"] = "Identifica a fruta equipada (Kitsune, Portal, etc.)",
        ["Illuminates full player character models through walls"] = "Ilumina modelos de jogadores atraves de paredes",
        ["Immunity to lava damage"] = "Imunidade ao dano de lava",
        ["In-Game Attributes"] = "Atributos do Jogo",
        ["Increase dash distance"] = "Aumenta a distancia do deslize",
        ["Infinite Jump"] = "Salto Infinito",
        ["Infinite Soru"] = "Soru Infinito",
        ["Interface Effects"] = "Efeitos Visuais",
        ["Interface Language"] = "Idioma da Interface",
        ["Interface Scale"] = "Escala da Interface",
        ["Jump continuously in mid-air"] = "Pule continuamente no ar",
        ["Keep Armament Haki active"] = "Mantem o Haki de Armamento ativo",
        ["LEVEL"] = "NIVEL",
        ["Language"] = "Idioma",
        ["Language & Localization"] = "Idioma e Localizacao",
        ["Large (120%)"] = "Grande (120%)",
        ["Load Configuration Profile"] = "Carregar Perfil de Configuracao",
        ["Load Config"] = "Carregar Configuracao",
        ["Lock camera onto enemy"] = "Fixa a camera no inimigo",
        ["Locks camera perspective directly onto focused enemy player"] = "Trava a camera diretamente no jogador inimigo focado",
        ["Looking At Me"] = "Olhando Para Mim",
        ["Low HP"] = "Menor Vida",
        ["Master ESP"] = "ESP Principal",
        ["Master ESP Toggle"] = "Interruptor Mestre de ESP",
        ["Master Visuals & Chams"] = "Visuais Mestres e Chams",
        ["Max Range"] = "Alcance Maximo",
        ["Max Soru Range"] = "Alcance Maximo do Soru",
        ["Melee"] = "Corpo a Corpo",
        ["Misc"] = "Diversos",
        ["Mouse"] = "Mouse",
        ["Move smoothly through structures and physical obstacles"] = "Permite mover atraves de estruturas e obstaculos",
        ["Movement"] = "Movimento",
        ["Movement & Agility (PvP Physics)"] = "Movimento e Agilidade (Fisicas PvP)",
        ["Multiplies dash distance for high-speed repositioning"] = "Multiplica distancia de dash para reposicionamento veloz",
        ["Multiplies jump impulse for vertical escape and aerial combat"] = "Multiplica impulso de pulo para fuga vertical e combate",
        ["NPC Silent Aim"] = "Silent Aim em NPCs",
        ["Nearest"] = "Mais Proximo",
        ["Nearest Player"] = "Jogador Mais Proximo",
        ["Neon Rain Layer"] = "Chuva Cyber Neon",
        ["Next (›)"] = "Proximo (›)",
        ["Noclip Wallpass"] = "Noclip Atravessar Paredes",
        ["None"] = "Nenhum",
        ["Official Community & Discord"] = "Comunidade Oficial e Discord",
        ["Orange"] = "Laranja",
        ["Overhead Billboard"] = "Rotulo Superior",
        ["PING"] = "LATENCIA",
        ["PLAYERS"] = "JOGADORES",
        ["Pass through walls and objects"] = "Atravessa paredes e objetos",
        ["Performance"] = "Desempenho",
        ["Performance & Network"] = "Desempenho e Rede",
        ["Pink"] = "Rosa",
        ["Player"] = "Jogador",
        ["Player 2D Boxes"] = "Caixas 2D de Jogadores",
        ["Player Bounty Tracker"] = "Bounty do Jogador",
        ["Player Chams & Tracers"] = "Chams e Rastreadores",
        ["Player Chams (Highlight)"] = "Chams de Jogador (Highlight)",
        ["Player Health Status"] = "Vida dos Jogadores",
        ["Player Level Display"] = "Nivel do Jogador",
        ["Player Names"] = "Nomes dos Jogadores",
        ["Player Profile"] = "Perfil do Jogador",
        ["Player Profile & Account"] = "Perfil do Jogador e Conta",
        ["Player Radar Elements"] = "Elementos do Radar de Jogador",
        ["Player Silent Aim"] = "Silent Aim em Jogadores",
        ["Player Tracer Color"] = "Cor da Linha do Jogador",
        ["Player Tracers"] = "Linhas para Jogadores",
        ["Portuguese"] = "Portugues",
        ["Prediction Amount"] = "Quantidade de Predicao",
        ["Premium User  •  Active Session"] = "Usuario Premium  •  Sessao Ativa",
        ["Preset: Crimson Slayer"] = "Estilo: Assassino Carmesim",
        ["Preset: Cyberpunk Violet"] = "Estilo: Violeta Cyberpunk",
        ["Preset: Emerald Forest"] = "Estilo: Floresta Esmeralda",
        ["Preset: Shorekeeper Cyan"] = "Estilo: Shorekeeper Ciano",
        ["Previous (‹)"] = "Anterior (‹)",
        ["Purple"] = "Roxo",
        ["PvP"] = "PvP",
        ["PvP Tech, Camlock & Universal Keybinds"] = "Tecnologia PvP, Camlock e Teclas",
        ["Q"] = "Q",
        ["Quick Actions"] = "Acoes Rapidas",
        ["R"] = "R",
        ["RACE"] = "RACA",
        ["Radar Elements"] = "Elementos do Radar",
        ["Rainbow"] = "Arco-iris",
        ["Rainbow Chroma Speed"] = "Velocidade do Chroma",
        ["Raindrop Density"] = "Densidade de Gotas",
        ["Random (Shuffle)"] = "Aleatorio",
        ["Rapid fire M1 gun shots"] = "Disparos M1 ultra rapidos",
        ["Rapid melee and weapon strikes"] = "Golpes rapidos corpo a corpo",
        ["Rapid weapon hit bursts"] = "Golpes continuos de arma",
        ["Rapid-fire gun attack loop targeting nearest combatant"] = "Ataque rapido de arma de fogo no alvo mais proximo",
        ["Red"] = "Vermelho",
        ["Redirect skills toward enemy players"] = "Redireciona habilidades para jogadores inimigos",
        ["Redirect skills toward mobs and bosses"] = "Redireciona habilidades para monstros e chefes",
        ["Redirects Flashstep teleport directly to enemy player"] = "Redireciona teletransporte diretamente ao jogador inimigo",
        ["Redirects skills and attacks towards enemy players"] = "Redireciona habilidades e ataques para jogadores inimigos",
        ["Redirects skills and attacks towards mobs and bosses"] = "Redireciona habilidades e ataques para monstros e chefes",
        ["Rejoin Current Server"] = "Reconectar ao Servidor",
        ["Remove flashstep cooldown"] = "Remove o tempo de recarga do flashstep",
        ["Removes cooldown delay and bypasses stamina limits"] = "Remove tempo de recarga e limites de energia",
        ["Renders hardware 3D Beams and 2D lines to target"] = "Renderiza raios 3D e linhas 2D para o alvo",
        ["Reset All Settings to Factory Defaults"] = "Restaurar Padroes de Fabrica",
        ["Reset Configuration Profile"] = "Redefinir Perfil de Configuracao",
        ["Reset Config"] = "Redefinir Configuracao",
        ["Configuration profile reset to defaults."] = "Perfil de configuracao redefinido para os padroes.",
        ["Reset Theme to Purple"] = "Redefinir Tema para Roxo",
        ["Sanguine Boost"] = "Sanguine Boost",
        ["Sanguine Boost Floating Widget"] = "Widget Flutuante Sanguine Z",
        ["Sanguine Keybind"] = "Tecla do Sanguine",
        ["Save Configuration Profile"] = "Salvar Perfil de Configuracao",
        ["Save Config"] = "Salvar Configuracao",
        ["Selected Player"] = "Jogador Selecionado",
        ["Server Hop (Fast)"] = "Trocar Servidor (Rapido)",
        ["Show FOV Circle"] = "Mostrar Circulo FOV",
        ["Show Tracers"] = "Mostrar Linhas de Rastreamento",
        ["Shows distance measurement in studs below player feet"] = "Mostra a distancia em studs sob os pes",
        ["Shows player rank and numerical level tag"] = "Mostra o rank e nivel numerico do jogador",
        ["Shows weapon, sword, fruit or gun held by the player"] = "Mostra arma, espada, fruta ou pistola equipada",
        ["Silent Aim"] = "Silent Aim",
        ["Skill Blacklist"] = "Lista Negra de Habilidades",
        ["Skill Delay"] = "Atraso de Habilidade",
        ["Skill Redirection Blacklist"] = "Lista Negra de Habilidades",
        ["Soru"] = "Soru",
        ["Soru Aimbot"] = "Soru Aimbot",
        ["Soru Combat Aimbot"] = "Aimbot Soru",
        ["Soru Flashstep Engine"] = "Motor Soru Flashstep",
        ["Soru Skill Combo"] = "Combo de Habilidades Soru",
        ["Soru Skill Combo Automation"] = "Auto Combo de Habilidades Soru",
        ["Soru Target Mode"] = "Modo de Alvo do Soru",
        ["Spanish"] = "Espanhol",
        ["Spawns water surface collider allowing sprint across oceans"] = "Cria plataforma aquatica para correr sobre os oceanos",
        ["Speed up player movement"] = "Aumenta a velocidade do jogador",
        ["Standard (100%)"] = "Padrao (100%)",
        ["Subtle (50%)"] = "Sutil (50%)",
        ["Super Jump"] = "Super Salto",
        ["Super Jump Floating Widget"] = "Widget Flutuante de Super Pulo",
        ["Super Jump Force"] = "Forca do Super Salto",
        ["Sword"] = "Espada",
        ["System Info"] = "Informacoes do Sistema",
        ["T"] = "T",
        ["Target Hitbox"] = "Regiao de Impacto",
        ["Target Player Selection"] = "Selecao de Jogador Alvo",
        ["Target Priority"] = "Prioridade de Alvo",
        ["Target Selection & Aim Mode"] = "Selecao de Alvo e Modo",
        ["Target Tracers"] = "Linhas Rastreadoras de Alvo",
        ["Teleport soru directly to enemy"] = "Teletransporta com soru para o inimigo",
        ["Theme Presets"] = "Predefinicoes de Tema",
        ["Theme Reset"] = "Redefinir Tema",
        ["Themes"] = "Temas",
        ["Toggle Rainbow Chroma Mode"] = "Ativar Modo Chroma Arco-iris",
        ["Toggle animated falling cyber rain streaks"] = "Ativa chuva animada cyber neon",
        ["Tracer Color"] = "Cor da Linha",
        ["Tracer Mode"] = "Modo de Linha",
        ["Tracer Origin"] = "Origem da Linha",
        ["Tracer Thickness"] = "Espessura da Linha",
        ["Tracers"] = "Linhas de Rastreamento",
        ["Trigger Super Jump"] = "Ativar Super Pulo",
        ["Typography Font"] = "Fonte Tipografica",
        ["Typography Studio"] = "Estudio de Tipografia",
        ["UPTIME"] = "TEMPO ATIVO",
        ["Ultra fast burst firing with CombatController validator"] = "Disparos ultra rapidos em rajada com validador CombatController",
        ["UpperTorso"] = "Torso Superior",
        ["Use skill instantly after Soru"] = "Lanca habilidade logo apos o Soru",
        ["V"] = "V",
        ["Vietnamese"] = "Vietnamita",
        ["Visuals"] = "Visuais",
        ["Vitality & Energy Status"] = "Estado de Saude e Energia",
        ["Walk on Water"] = "Andar sobre a Agua",
        ["Walk on ocean surface"] = "Andar sobre o oceano",
        ["WalkSpeed Value"] = "Valor de Velocidade",
        ["Wallpaper"] = "Papel de Parede",
        ["Wallpapers"] = "Papeis de Parede",
        ["White"] = "Branco",
        ["World & Client Optimization"] = "Otimizacao de Mundo e Cliente",
        ["X"] = "X",
        ["Yellow"] = "Amarelo",
        ["Z"] = "Z",
        ["Z Sanguine Boost"] = "Impulso Sanguine Z",
        ["B1 Hold Time (s)"] = "B1 Tempo de Retencao (s)",
        ["B1 Mode"] = "B1 Modo",
        ["B1 Post Jumps"] = "B1 Pulos Posteriores",
        ["B1 Skill Key"] = "B1 Tecla",
        ["B1 Weapon"] = "B1 Arma",
        ["B2 Hold Time (s)"] = "B2 Tempo de Retencao (s)",
        ["B2 Mode"] = "B2 Modo",
        ["B2 Post Jumps"] = "B2 Pulos Posteriores",
        ["B2 Skill Key"] = "B2 Tecla",
        ["B2 Weapon"] = "B2 Arma",
        ["B3 Hold Time (s)"] = "B3 Tempo de Retencao (s)",
        ["B3 Mode"] = "B3 Modo",
        ["B3 Post Jumps"] = "B3 Pulos Posteriores",
        ["B3 Skill Key"] = "B3 Tecla",
        ["B3 Weapon"] = "B3 Arma",
        ["B4 Hold Time (s)"] = "B4 Tempo de Retencao (s)",
        ["B4 Mode"] = "B4 Modo",
        ["B4 Post Jumps"] = "B4 Pulos Posteriores",
        ["B4 Skill Key"] = "B4 Tecla",
        ["B4 Weapon"] = "B4 Arma",
        ["B5 Hold Time (s)"] = "B5 Tempo de Retencao (s)",
        ["B5 Mode"] = "B5 Modo",
        ["B5 Post Jumps"] = "B5 Pulos Posteriores",
        ["B5 Skill Key"] = "B5 Tecla",
        ["B5 Weapon"] = "B5 Arma",
        ["B6 Hold Time (s)"] = "B6 Tempo de Retencao (s)",
        ["B6 Mode"] = "B6 Modo",
        ["B6 Post Jumps"] = "B6 Pulos Posteriores",
        ["B6 Skill Key"] = "B6 Tecla",
        ["B6 Weapon"] = "B6 Arma",
        ["Block 1 Enabled"] = "Bloco 1 Ativado",
        ["Block 2 Enabled"] = "Bloco 2 Ativado",
        ["Block 3 Enabled"] = "Bloco 3 Ativado",
        ["Block 4 Enabled"] = "Bloco 4 Ativado",
        ["Block 5 Enabled"] = "Bloco 5 Ativado",
        ["Block 6 Enabled"] = "Bloco 6 Ativado",
        ["Combo Sequence (6 Blocks)"] = "Sequencia de Combo (6 Blocos)",
        ["Display real-time FPS and ping overlay top-left"] = "Exibe overlay de FPS e ping em tempo real",
        ["Displays on-screen one-touch button to trigger combo"] = "Exibe botao na tela para ativar combo",
        ["Do not target allied players"] = "Nao mirar em jogadores aliados",
        ["Do not target players inside safe zones"] = "Nao mirar em jogadores dentro da zona segura",
        ["Do not target players with PvP disabled"] = "Nao mirar em jogadores com PvP desativado",
        ["Enable step 1 in combo"] = "Ativar passo 1 no combo",
        ["Enable step 2 in combo"] = "Ativar passo 2 no combo",
        ["Enable step 3 in combo"] = "Ativar passo 3 no combo",
        ["Enable step 4 in combo"] = "Ativar passo 4 no combo",
        ["Enable step 5 in combo"] = "Ativar passo 5 no combo",
        ["Enable step 6 in combo"] = "Ativar passo 6 no combo",
        ["Enables keyboard trigger and loop execution"] = "Ativa gatilho por teclado e execucao em loop",
        ["Fly"] = "Voar",
        ["Fly Speed"] = "Velocidade de Voo",
        ["Glide freely through the air"] = "Planeje livremente pelo ar",
        ["Ignore Allies"] = "Ignorar Aliados",
        ["Ignore PvP Off"] = "Ignorar PvP Desativado",
        ["Ignore Safe Zone"] = "Ignorar Zona Segura",
        ["Loop Sequence"] = "Sequencia em Loop",
        ["Macro"] = "Macro",
        ["Macro Controller"] = "Controlador de Macro",
        ["Macro Enabled"] = "Macro Ativado",
        ["Macro Floating Widget"] = "Widget Flutuante de Macro",
        ["Macro Slot"] = "Slot de Macro",
        ["Repeat sequence continuously until stopped"] = "Repete a sequencia continuamente ate parar",
        ["Show FPS & Ping"] = "Mostrar FPS e Ping",
        ["Start Combo Sequence"] = "Iniciar Sequencia de Combo",
        ["Stop Combo Sequence"] = "Parar Sequencia de Combo",
        ["Trigger Key (PC)"] = "Tecla de Ativacao (PC)",
        ["YouTube & External Players"] = "Players Externos e YouTube",
        ["Launch Universal YouTube Player"] = "Inicie o Reprodutor Universal do YouTube",
        ["Launch Audio Library Player"] = "Iniciar Biblioteca de Áudio",
        ["Roblox Audio Player"] = "Reprodutor de Áudio Roblox",
    },
    ["French"] = {
        ["Player Management"] = "Gestion des Joueurs",
        ["Search Player..."] = "Rechercher Joueur...",
        ["Refresh Player List"] = "Rafraichir la Liste",
        ["Blacklist"] = "Liste Noire",
        ["Blacklisted"] = "Sur Liste Noire",
        ["Spectate"] = "Spectateur",
        ["Spectating"] = "En Observation",
        ["Stop Spectating"] = "Arreter d'Observer",
        ["Teleport to Player"] = "Teleporter vers le Joueur",
        ["Total Players"] = "Nombre de Joueurs",
        ["Auto Dungeon Engine"] = "Moteur Auto Dungeon",
        ["Start Auto Dungeon"] = "Demarrer Auto Dungeon",
        ["Selected Weapon"] = "Arme Selectionnee",
        ["Sword"] = "Epee",
        ["Melee"] = "Corps a Corps",
        ["Blox Fruit"] = "Fruit Blox",
        ["Attack Height"] = "Hauteur d'Attaque",
        ["Auto Pass Room"] = "Passage Auto de Salle",
        ["Void M1 Engine"] = "Moteur Void M1",
        ["Enable Void M1"] = "Activer Void M1",
        ["Void Only Boss Rooms"] = "Void Uniquement Salles de Boss",
        ["Void Interval (s)"] = "Intervalle Void (s)",
        ["Dungeon Status & Utilities"] = "Statut et Utilitaires Dungeon",
        ["Auto Load Dungeon"] = "Chargement Auto Dungeon",
        ["Current Room"] = "Salle Actuelle",
        ["Boss Status"] = "Statut du Boss",
        ["Island Teleport"] = "Teleportation d'Iles",
        ["Select Sea"] = "Selectionner la Mer",
        ["Sea 1"] = "Mer 1",
        ["Sea 2"] = "Mer 2",
        ["Sea 3"] = "Mer 3",
        ["Target Island"] = "Ile Cible",
        ["Tween Speed"] = "Vitesse de Tween",
        ["Travel Altitude"] = "Altitude de Vol",
        ["Noclip during Tween"] = "Noclip pendant Tween",
        ["Start Teleport"] = "Demarrer Teleportation",
        ["Stop Teleport"] = "Arreter Teleportation",
        ["Controls Layout Editor"] = "Editeur de Disposition",
        ["Unlock Drag (Edit HUD)"] = "Deverrouiller Deplacement",
        ["Controls Global Scale"] = "Echelle Globale des Controles",
        ["Save Custom Layout"] = "Enregistrer Disposition",
        ["Reset Default Layout"] = "Reinitialiser Disposition",
        ["HUD Overlays"] = "Superpositions HUD",
        ["Performance Watermark"] = "Filigrane de Performance",
        ["Custom Crosshair"] = "Reticule Personnalise",
        ["Weapon Skins"] = "Skins d'Armes",
        ["Select Weapon Skin"] = "Selectionner Skin d'Arme",
        ["Apply Weapon Skin"] = "Appliquer Skin d'Arme",
        ["Reset Weapon Skin"] = "Reinitialiser Skin d'Arme",
        ["Haki & Aura Customization"] = "Personnalisation de Haki et Aura",
        ["Haki Color"] = "Couleur du Haki",
        ["Rainbow Haki"] = "Haki Arc-en-ciel",
        ["Custom Trail VFX"] = "VFX de Trainee Personnalise",
        ["Music Player"] = "Lecteur de Musique",
        ["Genre / Category"] = "Genre / Categorie",
        ["Track Preset"] = "Piste Prereglee",
        ["Custom Sound ID"] = "Sound ID Personnalise",
        ["Volume"] = "Volume",
        ["Pitch / Speed"] = "Hauteur / Vitesse",
        ["Loop Track"] = "Repeter la Piste",
        ["Show Top Music Bar"] = "Afficher la Barre de Musique",
        ["Play"] = "Jouer",
        ["Pause"] = "Pause",
        ["Resume"] = "Reprendre",
        ["Stop"] = "Arreter",
        ["Cinematic Animations"] = "Animations Cinematiques",
        ["Select Animation"] = "Selectionner l'Animation",
        ["Hide Accessories & Weapons"] = "Masquer Accessoires et Armes",
        ["Play Animation"] = "Lancer l'Animation",
        ["Stop Animation"] = "Arreter l'Animation",
        ["Pure White"] = "Blanc Pur",
        ["Crimson Red"] = "Rouge Cramoisi",
        ["Midnight Purple"] = "Pourpre Minuit",
        ["Electric Blue"] = "Bleu Electrique",
        ["Emerald Green"] = "Vert Emeraude",
        ["Golden Sun"] = "Soleil Dore",
        ["Default"] = "Par Defaut",
        ["None"] = "Aucun",
        ["180"] = "180",
        ["2D Boxes"] = "Boites 2D",
        ["2D Line"] = "Ligne 2D",
        ["360"] = "360",
        ["3D Beam"] = "Faisceau 3D",
        ["Accent Color & Theme Studio"] = "Studio de Themes et Couleurs",
        ["Account & Player Statistics"] = "Statistiques du Joueur",
        ["Aesthetic Studio Presets"] = "Prereglages d Ambiance",
        ["Aim Mode"] = "Mode de Visee",
        ["Aimbot"] = "Aimbot",
        ["Allows continuous mid-air jumping without cooldown"] = "Permet de sauter en l air continuellement sans rechargement",
        ["Anti-Lava Damage"] = "Anti-Degats de Lave",
        ["Anti-Lava Immunity"] = "Immunite a la Lave",
        ["Apply Fast FFlags"] = "Appliquer Optimisation FFlags",
        ["Apply Wallpaper"] = "Appliquer le Fond",
        ["Atmosphere Wallpaper"] = "Fond d ecran Atmospherique",
        ["Atmosphere Wallpaper Presets (24 Styles)"] = "Fonds Atmospheriques (24 Styles)",
        ["Auto Buso Haki"] = "Auto Haki de l'Armement",
        ["Auto Combat"] = "Combat Automatique",
        ["Auto Race V3"] = "Auto Race V3",
        ["Auto Race V4"] = "Auto Race V4",
        ["Auto Skill Combo"] = "Auto Combo de Competences",
        ["Auto Skill on Soru"] = "Competence Auto au Soru",
        ["Automatically activates Buso Armament Haki (No Ken)"] = "Active automatiquement le Haki de l armement (sans Ken)",
        ["Automatically casts Race V3 ability in combat"] = "Lance automatiquement la competence Race V3 en combat",
        ["Automatically triggers Race Awakening V4 when gauge is filled"] = "Active l eveil Race V4 lorsque la jauge est pleine",
        ["B"] = "B",
        ["BELI"] = "BELI",
        ["BOUNTY"] = "PRIME",
        ["Background Dimming (%)"] = "Assombrissement Fond (%)",
        ["Balanced (65%)"] = "Equilibre (65%)",
        ["Blue"] = "Bleu",
        ["Both"] = "Les deux",
        ["Bottom"] = "Bas",
        ["Bypasses walkspeed reset with direct physical impulse"] = "Contourne la reinitialisation de vitesse par impulsion physique directe",
        ["C"] = "C",
        ["Calculates lead vector based on enemy velocity and ping"] = "Calcule l'anticipation selon vitesse et ping",
        ["Camera FOV"] = "FOV Camera",
        ["Camlock"] = "Verrouillage Camera",
        ["Camlock (Combat Camera)"] = "Camlock (Camera de Combat)",
        ["Camlock Floating Widget"] = "Widget Flottant Camlock",
        ["Camlock Keybind"] = "Touche Camlock",
        ["Caps client to 22 FPS during Sanguine Z cooldown for physics boost"] = "Limite a 22 FPS pendant le cooldown de Sanguine Z pour boost",
        ["Cast Race V3 when in combat"] = "Active Race V3 en plein combat",
        ["Cast Race V4 when gauge is full"] = "Active Race V4 quand la jauge est pleine",
        ["Center"] = "Centre",
        ["Chams & Tracers"] = "Chams et Traceurs",
        ["Chams Highlight Color"] = "Couleur des Chams",
        ["Clear / Dark Glass"] = "Effacer / Verre Fume",
        ["Combat Passives & Auto Skills"] = "Passifs de Combat et Auto Competences",
        ["Combat PvP Status"] = "Statut de Combat PvP",
        ["Combat Targeting & Silent Aim"] = "Visee de Combat et Silent Aim",
        ["Combat Tech"] = "Techniques de Combat",
        ["Combo Key"] = "Touche de Combo",
        ["Combo Weapon"] = "Arme de Combo",
        ["Community"] = "Communaute",
        ["Compact (80%)"] = "Compact (80%)",
        ["Config"] = "Configuration",
        ["Configuration Profiles"] = "Profils de Configuration",
        ["Configuration Reset"] = "Reinitialisation de la Configuration",
        ["Copy Discord Invite Link"] = "Copier le Lien Discord",
        ["Copy Server JobId"] = "Copier le JobId Serveur",
        ["Credits"] = "Credits",
        ["Crystal (80%)"] = "Cristal (80%)",
        ["Custom Dash Length"] = "Portee du Dash",
        ["Custom WalkSpeed"] = "Vitesse Personnalisee",
        ["Custom Wallpaper"] = "Fond Personnalise",
        ["Custom Wallpaper Studio"] = "Studio de Fond Personnalise",
        ["Cyan"] = "Cyan",
        ["Dash Distance"] = "Distance du Dash",
        ["Destroys environmental lava kill zones and damage parts"] = "Detruit les zones de degats et de lave de l environnement",
        ["Detects safe zone and in-combat status indicators"] = "Detecte la zone de securite et le statut de combat",
        ["Developer & Content Creator"] = "Developpeur et Createur",
        ["Development Team & Content Creators"] = "Equipe de Developpement et Createurs",
        ["Devil Fruit Tracker"] = "Traqueur de Fruits",
        ["Direct Wallpaper"] = "Fond Direct",
        ["Disable All Visuals"] = "Desactiver Tous les Visuels",
        ["Display aim boundary circle"] = "Affiche le cercle limite de visee",
        ["Displays formatted usernames above character heads"] = "Affiche le nom au-dessus du joueur",
        ["Displays live gradient health bars and HP percentage"] = "Affiche barres de vie et pourcentage de PV",
        ["Displays movable on-screen JUMP button for touch"] = "Affiche un bouton de SAUT mobile a l ecran pour le tactile",
        ["Displays movable on-screen action button for Sanguine Z"] = "Affiche un bouton d action flottant pour Sanguine Z",
        ["Displays movable on-screen button to toggle camera lock"] = "Affiche un bouton mobile a l ecran pour verrouiller la camera",
        ["Displays movable on-screen toggle for Dragon Gun M1"] = "Affiche un commutateur mobile a l ecran pour Dragon Gun M1",
        ["Displays movable on-screen toggle for camera lock"] = "Affiche un bouton flottant pour verrouiller la camera",
        ["Displays player bounty or honor value in millions"] = "Affiche la prime ou l'honneur en millions",
        ["Displays targeting circle boundary on screen"] = "Affiche le cercle de visee a l ecran",
        ["Distance Indicator"] = "Indicateur de Distance",
        ["Dragon Gun M1"] = "Dragon Gun M1",
        ["Dragon Gun M1 Floating Widget"] = "Widget Flottant Dragon Gun M1",
        ["Draws dynamic bounding boxes around enemy players"] = "Dessine des boites dynamiques autour des ennemis",
        ["Draws line from bottom of screen to tracked players"] = "Trace une ligne depuis le bas vers les joueurs",
        ["E"] = "E",
        ["ESP Style"] = "Style d'ESP",
        ["ESP Text Font Size"] = "Taille Police ESP",
        ["ESP Visuals"] = "Visuels ESP",
        ["Enable All Visuals"] = "Activer Tous les Visuels",
        ["Enable Target Prediction"] = "Activer la Prediction de Cible",
        ["Enable player visual highlights"] = "Active la surbrillance des joueurs",
        ["Enables custom movement speed multiplier"] = "Active le multiplicateur de vitesse personnalisee",
        ["Enables high-performance player visual tracking"] = "Active le suivi visuel des joueurs a haute performance",
        ["English"] = "Anglais",
        ["Equipped Tool / Weapon"] = "Arme Equipee",
        ["Equips weapon and casts chosen skill upon Soru animation"] = "Equipe l arme et lance la competence choisie pendant Soru",
        ["Esp"] = "Visuels",
        ["Executes rapid melee, sword, and fruit attack bursts"] = "Execute des rafales rapides pour melee, epees et fruits",
        ["Executes rapid primary attacks on all nearby enemies"] = "Execute des attaques principales rapides sur tous les ennemis proches",
        ["F"] = "F",
        ["FACTION"] = "FACTION",
        ["FOV"] = "FOV",
        ["FOV Color"] = "Couleur du FOV",
        ["FOV Position"] = "Position du FOV",
        ["FOV Radius"] = "Rayon du FOV",
        ["FOV Thickness"] = "Epaisseur du FOV",
        ["FPS"] = "IPS",
        ["FRUIT"] = "FRUIT",
        ["Fast Attack"] = "Attaque Rapide",
        ["Fast Attack (Melee, Sword, Fruit)"] = "Attaque Rapide (Melee, Epee, Fruit)",
        ["Fast Flags"] = "Optimisation Rapide",
        ["FFlags 1 (FPS Booster)"] = "FFlags 1 (Booster FPS)",
        ["120 FPS cap, smooth plastic textures, removes atmosphere fog, hides debris"] = "Limite de 120 FPS, textures plastiques, supprime le brouillard et cache les debris",
        ["No Animations"] = "Sans Animations",
        ["Stops non-attack animations to fix sideways bug and character freezes"] = "Arrete les animations hors attaque pour corriger les blocages",
        ["Fast Flags & Engine Tuning"] = "Fast Flags et Optimisation Moteur",
        ["Field of View"] = "Champ de Vision",
        ["Field of View (FOV Customization)"] = "Champ de Vision (FOV)",
        ["Forward velocity boost"] = "Boost de vitesse vers l'avant",
        ["French"] = "Francais",
        ["Fruit"] = "Fruit",
        ["Game Stats"] = "Statistiques de Jeu",
        ["Glass Interface & Visual Effects"] = "Interface de Verre et Effets",
        ["Glass Transparency"] = "Transparence du Verre",
        ["Green"] = "Vert",
        ["Gun"] = "Arme a feu",
        ["Gun Aura (Dragon Gun M1)"] = "Aura d Arme (Dragon Gun M1)",
        ["Head"] = "Tete",
        ["High jump leap"] = "Saut a haute elevation",
        ["High-distance forward velocity boost with keybind Z"] = "Boost de vitesse frontale longue distance avec touche Z",
        ["Home"] = "Accueil",
        ["HumanoidRootPart"] = "HumanoidRootPart",
        ["Identifies equipped Devil Fruit power (Kitsune, Portal, etc.)"] = "Identifie le fruit demoniaque equipe",
        ["Illuminates full player character models through walls"] = "Illumine les modeles de joueurs a travers les murs",
        ["Immunity to lava damage"] = "Immunite aux degats de lave",
        ["In-Game Attributes"] = "Attributs en Jeu",
        ["Increase dash distance"] = "Augmente la portee du dash",
        ["Infinite Jump"] = "Saut Infini",
        ["Infinite Soru"] = "Soru Infini",
        ["Interface Effects"] = "Effets Visuels",
        ["Interface Language"] = "Langue de l'Interface",
        ["Interface Scale"] = "Echelle de l'Interface",
        ["Jump continuously in mid-air"] = "Sautez en l'air sans limite",
        ["Keep Armament Haki active"] = "Maintient le Haki de l'Armement actif",
        ["LEVEL"] = "NIVEAU",
        ["Language"] = "Langue",
        ["Language & Localization"] = "Langue et Localisation",
        ["Large (120%)"] = "Grand (120%)",
        ["Load Configuration Profile"] = "Charger la Configuration",
        ["Load Config"] = "Charger Configuration",
        ["Lock camera onto enemy"] = "Verrouille la camera sur l'ennemi",
        ["Locks camera perspective directly onto focused enemy player"] = "Verrouille la camera directement sur le joueur ennemi cible",
        ["Looking At Me"] = "Me regarde",
        ["Low HP"] = "Points de vie bas",
        ["Master ESP"] = "ESP Principal",
        ["Master ESP Toggle"] = "Interrupteur Maitre ESP",
        ["Master Visuals & Chams"] = "Visuels Maitres et Chams",
        ["Max Range"] = "Portee Maximale",
        ["Max Soru Range"] = "Portee Maximale du Soru",
        ["Melee"] = "Corps a corps",
        ["Misc"] = "Divers",
        ["Mouse"] = "Souris",
        ["Move smoothly through structures and physical obstacles"] = "Permet de traverser les structures et obstacles",
        ["Movement"] = "Mouvement",
        ["Movement & Agility (PvP Physics)"] = "Mouvement et Agilite (Physique PvP)",
        ["Multiplies dash distance for high-speed repositioning"] = "Multiplie la distance de dash pour un repositionnement rapide",
        ["Multiplies jump impulse for vertical escape and aerial combat"] = "Multiplie l impulsion de saut pour fuite verticale et combat",
        ["NPC Silent Aim"] = "Silent Aim sur PNJs",
        ["Nearest"] = "Le plus proche",
        ["Nearest Player"] = "Joueur le plus proche",
        ["Neon Rain Layer"] = "Pluie Cyber Neon",
        ["Next (›)"] = "Suivant (›)",
        ["Noclip Wallpass"] = "Noclip Passe-Muraille",
        ["None"] = "Aucun",
        ["Official Community & Discord"] = "Communaute Officielle et Discord",
        ["Orange"] = "Orange",
        ["Overhead Billboard"] = "Bandeau Superieur",
        ["PING"] = "LATENCE",
        ["PLAYERS"] = "JOUEURS",
        ["Pass through walls and objects"] = "Traverse les murs et les objets",
        ["Performance"] = "Performance",
        ["Performance & Network"] = "Performances et Reseau",
        ["Pink"] = "Rose",
        ["Player"] = "Joueur",
        ["Player 2D Boxes"] = "Boites 2D Joueurs",
        ["Player Bounty Tracker"] = "Prime du Joueur",
        ["Player Chams & Tracers"] = "Chams et Traceurs",
        ["Player Chams (Highlight)"] = "Chams Joueur (Surbrillance)",
        ["Player Health Status"] = "Sante des Joueurs",
        ["Player Level Display"] = "Niveau du Joueur",
        ["Player Names"] = "Noms des Joueurs",
        ["Player Profile"] = "Profil du Joueur",
        ["Player Profile & Account"] = "Profil Joueur et Compte",
        ["Player Radar Elements"] = "Elements du Radar Joueur",
        ["Player Silent Aim"] = "Silent Aim sur Joueurs",
        ["Player Tracer Color"] = "Couleur Ligne Joueur",
        ["Player Tracers"] = "Traceurs vers Joueurs",
        ["Portuguese"] = "Portugais",
        ["Prediction Amount"] = "Quantite de Prediction",
        ["Premium User  •  Active Session"] = "Utilisateur Premium  •  Session Active",
        ["Preset: Crimson Slayer"] = "Style: Tueur Cramoisi",
        ["Preset: Cyberpunk Violet"] = "Style: Violet Cyberpunk",
        ["Preset: Emerald Forest"] = "Style: Foret Emeraude",
        ["Preset: Shorekeeper Cyan"] = "Style: Shorekeeper Cyan",
        ["Previous (‹)"] = "Precedent (‹)",
        ["Purple"] = "Violet",
        ["PvP"] = "PvP",
        ["PvP Tech, Camlock & Universal Keybinds"] = "Technologie PvP, Camlock et Raccourcis",
        ["Q"] = "Q",
        ["Quick Actions"] = "Actions Rapides",
        ["R"] = "R",
        ["RACE"] = "RACE",
        ["Radar Elements"] = "Elements du Radar",
        ["Rainbow"] = "Arc-en-ciel",
        ["Rainbow Chroma Speed"] = "Vitesse Chroma Arc-en-ciel",
        ["Raindrop Density"] = "Densite des Gouttes",
        ["Random (Shuffle)"] = "Aleatoire",
        ["Rapid fire M1 gun shots"] = "Tirs M1 ultra rapides",
        ["Rapid melee and weapon strikes"] = "Frappes rapides au corps a corps",
        ["Rapid weapon hit bursts"] = "Attaques continues a l'arme",
        ["Rapid-fire gun attack loop targeting nearest combatant"] = "Attaque rapide a l arme a feu sur la cible la plus proche",
        ["Red"] = "Rouge",
        ["Redirect skills toward enemy players"] = "Redirige les competences vers les joueurs",
        ["Redirect skills toward mobs and bosses"] = "Redirige les competences vers les monstres et boss",
        ["Redirects Flashstep teleport directly to enemy player"] = "Redirige la teleportation directement vers le joueur ennemi",
        ["Redirects skills and attacks towards enemy players"] = "Redirige les competences et attaques vers les joueurs ennemis",
        ["Redirects skills and attacks towards mobs and bosses"] = "Redirige les competences et attaques vers les monstres et boss",
        ["Rejoin Current Server"] = "Rejoindre le Serveur",
        ["Remove flashstep cooldown"] = "Supprime le temps de recharge du pas eclair",
        ["Removes cooldown delay and bypasses stamina limits"] = "Supprime le temps de recharge et limites d endurance",
        ["Renders hardware 3D Beams and 2D lines to target"] = "Genere des faisceaux 3D et lignes 2D vers la cible",
        ["Reset All Settings to Factory Defaults"] = "Reinitialiser aux Valeurs Usine",
        ["Reset Configuration Profile"] = "Reinitialiser la Configuration",
        ["Reset Config"] = "Reinitialiser Configuration",
        ["Configuration profile reset to defaults."] = "Profil de configuration reinitialise par defaut.",
        ["Reset Theme to Purple"] = "Reinitialiser le Theme en Violet",
        ["Sanguine Boost"] = "Boost Sanguin",
        ["Sanguine Boost Floating Widget"] = "Widget Flottant Sanguine Z",
        ["Sanguine Keybind"] = "Touche Sanguine",
        ["Save Configuration Profile"] = "Sauvegarder la Configuration",
        ["Save Config"] = "Sauvegarder Configuration",
        ["Selected Player"] = "Joueur selectionne",
        ["Server Hop (Fast)"] = "Changer de Serveur (Rapide)",
        ["Show FOV Circle"] = "Afficher Cercle FOV",
        ["Show Tracers"] = "Afficher Lignes de Traceurs",
        ["Shows distance measurement in studs below player feet"] = "Affiche la distance en studs sous les pieds",
        ["Shows player rank and numerical level tag"] = "Affiche le rang et le niveau numerique du joueur",
        ["Shows weapon, sword, fruit or gun held by the player"] = "Affiche l'arme, epee, fruit ou pistolet tenu",
        ["Silent Aim"] = "Visee Silencieuse",
        ["Skill Blacklist"] = "Liste Noire de Competences",
        ["Skill Delay"] = "Delai de Competence",
        ["Skill Redirection Blacklist"] = "Liste Noire de Competences",
        ["Soru"] = "Soru",
        ["Soru Aimbot"] = "Soru Aimbot",
        ["Soru Combat Aimbot"] = "Aimbot Soru",
        ["Soru Flashstep Engine"] = "Moteur Soru Flashstep",
        ["Soru Skill Combo"] = "Combo de Competences Soru",
        ["Soru Skill Combo Automation"] = "Auto Combo de Competences Soru",
        ["Soru Target Mode"] = "Mode Cible Soru",
        ["Spanish"] = "Espagnol",
        ["Spawns water surface collider allowing sprint across oceans"] = "Cree une plateforme aquatique pour courir sur les oceans",
        ["Speed up player movement"] = "Augmente la vitesse du joueur",
        ["Standard (100%)"] = "Standard (100%)",
        ["Subtle (50%)"] = "Subtil (50%)",
        ["Super Jump"] = "Super Saut",
        ["Super Jump Floating Widget"] = "Widget Flottant de Super Saut",
        ["Super Jump Force"] = "Force du Super Saut",
        ["Sword"] = "Epee",
        ["System Info"] = "Infos Systeme",
        ["T"] = "T",
        ["Target Hitbox"] = "Zone d'Impact",
        ["Target Player Selection"] = "Selection du Joueur Cible",
        ["Target Priority"] = "Priorite de Cible",
        ["Target Selection & Aim Mode"] = "Selection de Cible et Mode",
        ["Target Tracers"] = "Traceurs de Cible",
        ["Teleport soru directly to enemy"] = "Teleporte en soru directement vers l'ennemi",
        ["Theme Presets"] = "Styles Predefinis",
        ["Theme Reset"] = "Reinitialiser le Theme",
        ["Themes"] = "Themes",
        ["Toggle Rainbow Chroma Mode"] = "Mode Chroma Arc-en-ciel",
        ["Toggle animated falling cyber rain streaks"] = "Active la pluie cyber animee",
        ["Tracer Color"] = "Couleur de Ligne",
        ["Tracer Mode"] = "Mode de Ligne",
        ["Tracer Origin"] = "Origine de Ligne",
        ["Tracer Thickness"] = "Epaisseur de Ligne",
        ["Tracers"] = "Lignes de Traceurs",
        ["Trigger Super Jump"] = "Declencher Super Saut",
        ["Typography Font"] = "Police Typographique",
        ["Typography Studio"] = "Studio de Typographie",
        ["UPTIME"] = "DUREE",
        ["Ultra fast burst firing with CombatController validator"] = "Tir en rafale ultra rapide avec validateur CombatController",
        ["UpperTorso"] = "Torse Superieur",
        ["Use skill instantly after Soru"] = "Lance une competence immediatement apres le Soru",
        ["V"] = "V",
        ["Vietnamese"] = "Vietnamien",
        ["Visuals"] = "Visuels",
        ["Vitality & Energy Status"] = "Etat de Sante et Energie",
        ["Walk on Water"] = "Marcher sur l'Eau",
        ["Walk on ocean surface"] = "Marcher sur la surface de l'ocean",
        ["WalkSpeed Value"] = "Valeur de Vitesse",
        ["Wallpaper"] = "Fond d'ecran",
        ["Wallpapers"] = "Fonds d'ecran",
        ["White"] = "Blanc",
        ["World & Client Optimization"] = "Optimisation Monde et Client",
        ["X"] = "X",
        ["Yellow"] = "Jaune",
        ["Z"] = "Z",
        ["Z Sanguine Boost"] = "Boost Sanguine Z",
        ["B1 Hold Time (s)"] = "B1 Temps de Maintien (s)",
        ["B1 Mode"] = "B1 Mode",
        ["B1 Post Jumps"] = "B1 Sauts Posterieurs",
        ["B1 Skill Key"] = "B1 Touche",
        ["B1 Weapon"] = "B1 Arme",
        ["B2 Hold Time (s)"] = "B2 Temps de Maintien (s)",
        ["B2 Mode"] = "B2 Mode",
        ["B2 Post Jumps"] = "B2 Sauts Posterieurs",
        ["B2 Skill Key"] = "B2 Touche",
        ["B2 Weapon"] = "B2 Arme",
        ["B3 Hold Time (s)"] = "B3 Temps de Maintien (s)",
        ["B3 Mode"] = "B3 Mode",
        ["B3 Post Jumps"] = "B3 Sauts Posterieurs",
        ["B3 Skill Key"] = "B3 Touche",
        ["B3 Weapon"] = "B3 Arme",
        ["B4 Hold Time (s)"] = "B4 Temps de Maintien (s)",
        ["B4 Mode"] = "B4 Mode",
        ["B4 Post Jumps"] = "B4 Sauts Posterieurs",
        ["B4 Skill Key"] = "B4 Touche",
        ["B4 Weapon"] = "B4 Arme",
        ["B5 Hold Time (s)"] = "B5 Temps de Maintien (s)",
        ["B5 Mode"] = "B5 Mode",
        ["B5 Post Jumps"] = "B5 Sauts Posterieurs",
        ["B5 Skill Key"] = "B5 Touche",
        ["B5 Weapon"] = "B5 Arme",
        ["B6 Hold Time (s)"] = "B6 Temps de Maintien (s)",
        ["B6 Mode"] = "B6 Mode",
        ["B6 Post Jumps"] = "B6 Sauts Posterieurs",
        ["B6 Skill Key"] = "B6 Touche",
        ["B6 Weapon"] = "B6 Arme",
        ["Block 1 Enabled"] = "Bloc 1 Active",
        ["Block 2 Enabled"] = "Bloc 2 Active",
        ["Block 3 Enabled"] = "Bloc 3 Active",
        ["Block 4 Enabled"] = "Bloc 4 Active",
        ["Block 5 Enabled"] = "Bloc 5 Active",
        ["Block 6 Enabled"] = "Bloc 6 Active",
        ["Combo Sequence (6 Blocks)"] = "Sequence de Combo (6 Blocs)",
        ["Display real-time FPS and ping overlay top-left"] = "Affiche l'overlay FPS et ping en temps reel",
        ["Displays on-screen one-touch button to trigger combo"] = "Affiche un bouton a l'ecran pour lancer le combo",
        ["Do not target allied players"] = "Ne pas cibler les allies",
        ["Do not target players inside safe zones"] = "Ne pas cibler les joueurs en zone sure",
        ["Do not target players with PvP disabled"] = "Ne pas cibler les joueurs sans PvP",
        ["Enable step 1 in combo"] = "Activer l'etape 1 du combo",
        ["Enable step 2 in combo"] = "Activer l'etape 2 du combo",
        ["Enable step 3 in combo"] = "Activer l'etape 3 du combo",
        ["Enable step 4 in combo"] = "Activer l'etape 4 du combo",
        ["Enable step 5 in combo"] = "Activer l'etape 5 du combo",
        ["Enable step 6 in combo"] = "Activer l'etape 6 du combo",
        ["Enables keyboard trigger and loop execution"] = "Active le declencheur clavier et l'execution en boucle",
        ["Fly"] = "Voler",
        ["Fly Speed"] = "Vitesse de Vol",
        ["Glide freely through the air"] = "Glissez librement dans les airs",
        ["Ignore Allies"] = "Ignorer les Allies",
        ["Ignore PvP Off"] = "Ignorer PvP Desactive",
        ["Ignore Safe Zone"] = "Ignorer Zone Sure",
        ["Loop Sequence"] = "Sequence en Boucle",
        ["Macro"] = "Macro",
        ["Macro Controller"] = "Controleur de Macro",
        ["Macro Enabled"] = "Macro Active",
        ["Macro Floating Widget"] = "Widget Flottant de Macro",
        ["Macro Slot"] = "Emplacement Macro",
        ["Repeat sequence continuously until stopped"] = "Repete la sequence en boucle jusqu'a l'arret",
        ["Show FPS & Ping"] = "Afficher FPS et Ping",
        ["Start Combo Sequence"] = "Demarrer Sequence de Combo",
        ["Stop Combo Sequence"] = "Arreter Sequence de Combo",
        ["Trigger Key (PC)"] = "Touche d'Activation (PC)",
        ["YouTube & External Players"] = "Lecteurs Externes et YouTube",
        ["Launch Universal YouTube Player"] = "Lancez le Lecteur YouTube Universel",
        ["Launch Audio Library Player"] = "Lancer la Bibliothèque Audio",
        ["Roblox Audio Player"] = "Lecteur Audio Roblox",
    },
    ["Vietnamese"] = {
        ["Player Management"] = "Quan ly Nguoi choi",
        ["Search Player..."] = "Tim kiem Nguoi choi...",
        ["Refresh Player List"] = "Lam moi danh sach",
        ["Blacklist"] = "Danh sach den",
        ["Blacklisted"] = "Da vao danh sach den",
        ["Spectate"] = "Theo doi",
        ["Spectating"] = "Dang theo doi",
        ["Stop Spectating"] = "Dung theo doi",
        ["Teleport to Player"] = "Dich chuyen den Nguoi choi",
        ["Total Players"] = "Tong so nguoi choi",
        ["Auto Dungeon Engine"] = "Dong co Auto Dungeon",
        ["Start Auto Dungeon"] = "Bat dau Auto Dungeon",
        ["Selected Weapon"] = "Vu khi da chon",
        ["Sword"] = "Kiem",
        ["Melee"] = "Can chien",
        ["Blox Fruit"] = "Trai ac quy",
        ["Attack Height"] = "Do cao tan cong",
        ["Auto Pass Room"] = "Tu dong qua phong",
        ["Void M1 Engine"] = "Dong co Void M1",
        ["Enable Void M1"] = "Bat Void M1",
        ["Void Only Boss Rooms"] = "Void chi phong Boss",
        ["Void Interval (s)"] = "Khoang cach Void (giay)",
        ["Dungeon Status & Utilities"] = "Trang thai & Tien ich Dungeon",
        ["Auto Load Dungeon"] = "Tu dong tai Dungeon",
        ["Current Room"] = "Phong hien tai",
        ["Boss Status"] = "Trang thai Boss",
        ["Island Teleport"] = "Dich chuyen Dao",
        ["Select Sea"] = "Chon Bien",
        ["Sea 1"] = "Bien 1",
        ["Sea 2"] = "Bien 2",
        ["Sea 3"] = "Bien 3",
        ["Target Island"] = "Dao muc tieu",
        ["Tween Speed"] = "Toc do Tween",
        ["Travel Altitude"] = "Do cao di chuyen",
        ["Noclip during Tween"] = "Di xuyen tuong khi Tween",
        ["Start Teleport"] = "Bat dau Dich chuyen",
        ["Stop Teleport"] = "Dung Dich chuyen",
        ["Controls Layout Editor"] = "Trinh chinh sua bo tri",
        ["Unlock Drag (Edit HUD)"] = "Mo khoa keo (Sua HUD)",
        ["Controls Global Scale"] = "Ty le tong the dieu khien",
        ["Save Custom Layout"] = "Luu bo tri",
        ["Reset Default Layout"] = "Dat lai bo tri mac dinh",
        ["HUD Overlays"] = "Lop phu HUD",
        ["Performance Watermark"] = "Chi so hieu nang",
        ["Custom Crosshair"] = "Tam ngam tuy chinh",
        ["Weapon Skins"] = "Skin Vu khi",
        ["Select Weapon Skin"] = "Chon Skin Vu khi",
        ["Apply Weapon Skin"] = "Ap dung Skin Vu khi",
        ["Reset Weapon Skin"] = "Dat lai Skin Vu khi",
        ["Haki & Aura Customization"] = "Tuy chinh Haki va Hao quang",
        ["Haki Color"] = "Mau Haki",
        ["Rainbow Haki"] = "Haki cau vong",
        ["Custom Trail VFX"] = "Hieu ung vet chem tuy chinh",
        ["Music Player"] = "Trinh phat Nhac",
        ["Genre / Category"] = "The loai / Danh muc",
        ["Track Preset"] = "Ban nhac co san",
        ["Custom Sound ID"] = "ID Am thanh tuy chinh",
        ["Volume"] = "Am luong",
        ["Pitch / Speed"] = "Cao do / Toc do",
        ["Loop Track"] = "Lap lai ban nhac",
        ["Show Top Music Bar"] = "Hien thanh nhac phia tren",
        ["Play"] = "Phat",
        ["Pause"] = "Tam dung",
        ["Resume"] = "Tiep tuc",
        ["Stop"] = "Dung",
        ["Cinematic Animations"] = "Hoat anh Dien anh",
        ["Select Animation"] = "Chon Hoat anh",
        ["Hide Accessories & Weapons"] = "An Phu kien va Vu khi",
        ["Play Animation"] = "Chay Hoat anh",
        ["Stop Animation"] = "Dung Hoat anh",
        ["Pure White"] = "Trang Tinh Khiet",
        ["Crimson Red"] = "Do Tham",
        ["Midnight Purple"] = "Tim Dem",
        ["Electric Blue"] = "Xanh Lam Tia Chop",
        ["Emerald Green"] = "Xanh Luc Bao",
        ["Golden Sun"] = "Vang Mat Troi",
        ["Default"] = "Mac dinh",
        ["None"] = "Khong co",
        ["180"] = "180",
        ["2D Boxes"] = "Khung 2D",
        ["2D Line"] = "Duong 2D",
        ["360"] = "360",
        ["3D Beam"] = "Tia 3D",
        ["Accent Color & Theme Studio"] = "Tuy chinh mau sac va Chu de",
        ["Account & Player Statistics"] = "Thong ke Nguoi choi",
        ["Aesthetic Studio Presets"] = "Mau giao dien co san",
        ["Aim Mode"] = "Che do ngam",
        ["Aimbot"] = "Aimbot",
        ["Allows continuous mid-air jumping without cooldown"] = "Cho phep nhay lien tuc tren khong khong hoi chieu",
        ["Anti-Lava Damage"] = "Chong sat thuong dung nham",
        ["Anti-Lava Immunity"] = "Mien nhiem dung nham",
        ["Apply Fast FFlags"] = "Ap dung toi uu FFlags",
        ["Apply Wallpaper"] = "Ap dung hinh nen",
        ["Atmosphere Wallpaper"] = "Hinh nen Khong gian",
        ["Atmosphere Wallpaper Presets (24 Styles)"] = "Hinh nen khong gian (24 Kieu)",
        ["Auto Buso Haki"] = "Tu dong bat Haki Vu Trang",
        ["Auto Combat"] = "Chien dau tu dong",
        ["Auto Race V3"] = "Tu dong bat Toc V3",
        ["Auto Race V4"] = "Tu dong bat Toc V4",
        ["Auto Skill Combo"] = "Tu dong Combo ky nang",
        ["Auto Skill on Soru"] = "Tu dong dung chieu khi Soru",
        ["Automatically activates Buso Armament Haki (No Ken)"] = "Tu dong bat Buso Haki vu trang (khong bat Ken)",
        ["Automatically casts Race V3 ability in combat"] = "Tu dong dung ky nang Toc V3 trong chien dau",
        ["Automatically triggers Race Awakening V4 when gauge is filled"] = "Tu dong thuc tinh Toc V4 khi thanh nang luong day",
        ["B"] = "B",
        ["BELI"] = "TIEN BELI",
        ["BOUNTY"] = "TIEN THUONG",
        ["Background Dimming (%)"] = "Do toi nen (%)",
        ["Balanced (65%)"] = "Can bang (65%)",
        ["Blue"] = "Xanh duong",
        ["Both"] = "Ca hai",
        ["Bottom"] = "Duoi cung",
        ["Bypasses walkspeed reset with direct physical impulse"] = "Bo qua dat lai toc do chay bang xung luc vat ly truc tiep",
        ["C"] = "C",
        ["Calculates lead vector based on enemy velocity and ping"] = "Tinh toan huong don dua tren toc do va ping",
        ["Camera FOV"] = "FOV goc nhin",
        ["Camlock"] = "Khoa goc nhin",
        ["Camlock (Combat Camera)"] = "Camlock (Camera chien dau)",
        ["Camlock Floating Widget"] = "Nut noi Camlock",
        ["Camlock Keybind"] = "Phim tat Camlock",
        ["Caps client to 22 FPS during Sanguine Z cooldown for physics boost"] = "Gioi han 22 FPS trong hoi chieu Sanguine Z de day vat ly",
        ["Cast Race V3 when in combat"] = "Kich hoat Toc V3 khi giao tranh",
        ["Cast Race V4 when gauge is full"] = "Kich hoat Toc V4 khi day thanh no",
        ["Center"] = "Trung tam",
        ["Chams & Tracers"] = "Chams va Dan huong",
        ["Chams Highlight Color"] = "Mau Chams",
        ["Clear / Dark Glass"] = "Xoa / Kinh toi mau",
        ["Combat Passives & Auto Skills"] = "Noi tai chien dau va Tu dong ky nang",
        ["Combat PvP Status"] = "Trang thai giao tranh PvP",
        ["Combat Targeting & Silent Aim"] = "Khoa muc tieu va Silent Aim",
        ["Combat Tech"] = "Ky thuat chien dau",
        ["Combo Key"] = "Phim tat Combo",
        ["Combo Weapon"] = "Vu khi Combo",
        ["Community"] = "Cong dong",
        ["Compact (80%)"] = "Gon gang (80%)",
        ["Config"] = "Cau hinh",
        ["Configuration Profiles"] = "Cau hinh da luu",
        ["Configuration Reset"] = "Dat lai cau hinh",
        ["Copy Discord Invite Link"] = "Sao chep lien ket Discord",
        ["Copy Server JobId"] = "Sao chep JobId may chu",
        ["Credits"] = "Tac gia",
        ["Crystal (80%)"] = "Trong suot (80%)",
        ["Custom Dash Length"] = "Khoang cach luot",
        ["Custom WalkSpeed"] = "Toc do chay tuy chon",
        ["Custom Wallpaper"] = "Hinh nen tuy chon",
        ["Custom Wallpaper Studio"] = "Tuy chinh hinh nen rieng",
        ["Cyan"] = "Xanh lo",
        ["Dash Distance"] = "Khoang cach luot",
        ["Destroys environmental lava kill zones and damage parts"] = "Pha huy cac vung dung nham gay sat thuong trong moi truong",
        ["Detects safe zone and in-combat status indicators"] = "Phat hien khu vuc an toan va trang thai chien dau",
        ["Developer & Content Creator"] = "Nha phat trien va Sang tao noi dung",
        ["Development Team & Content Creators"] = "Doi ngu phat trien va Sang tao",
        ["Devil Fruit Tracker"] = "Dinh vi trai ac quy",
        ["Direct Wallpaper"] = "Hinh nen truc tiep",
        ["Disable All Visuals"] = "Tat tat ca hien thi",
        ["Display aim boundary circle"] = "Hien thi vong tron gioi han tam ngam",
        ["Displays formatted usernames above character heads"] = "Hien thi ten tren dau nhan vat",
        ["Displays live gradient health bars and HP percentage"] = "Hien thi thanh mau va phan tram mau",
        ["Displays movable on-screen JUMP button for touch"] = "Hien thi nut NHAY di dong tren man hinh cho cam ung",
        ["Displays movable on-screen action button for Sanguine Z"] = "Hien thi nut noi hanh dong cho chieu Sanguine Z",
        ["Displays movable on-screen button to toggle camera lock"] = "Hien thi nut di dong tren man hinh de khoa camera",
        ["Displays movable on-screen toggle for Dragon Gun M1"] = "Hien thi nut chuyen di dong tren man hinh cho Dragon Gun M1",
        ["Displays movable on-screen toggle for camera lock"] = "Hien thi nut noi di chuyen duoc de bat tat khoa camera",
        ["Displays player bounty or honor value in millions"] = "Hien thi tien truy na hoac danh du theo trieu",
        ["Displays targeting circle boundary on screen"] = "Hien thi vong tron ngam muc tieu tren man hinh",
        ["Distance Indicator"] = "Khoang cach",
        ["Dragon Gun M1"] = "Dragon Gun M1",
        ["Dragon Gun M1 Floating Widget"] = "Tien ich noi Dragon Gun M1",
        ["Draws dynamic bounding boxes around enemy players"] = "Ve khung bao quanh nguoi choi dich",
        ["Draws line from bottom of screen to tracked players"] = "Ve duong dan tu duoi man hinh den muc tieu",
        ["E"] = "E",
        ["ESP Style"] = "Kieu ESP",
        ["ESP Text Font Size"] = "Co chu ESP",
        ["ESP Visuals"] = "Hien thi ESP",
        ["Enable All Visuals"] = "Bat tat ca hien thi",
        ["Enable Target Prediction"] = "Bat doan huong muc tieu",
        ["Enable player visual highlights"] = "Bat lam noi bat nguoi choi",
        ["Enables custom movement speed multiplier"] = "Bat he so nhan toc do di chuyen tuy chinh",
        ["Enables high-performance player visual tracking"] = "Bat theo doi nguoi choi hieu nang cao",
        ["English"] = "English",
        ["Equipped Tool / Weapon"] = "Vu khi trang bi",
        ["Equips weapon and casts chosen skill upon Soru animation"] = "Trang bi vu khi va tung chieu ngay khi dung Soru",
        ["Esp"] = "Hien thi",
        ["Executes rapid melee, sword, and fruit attack bursts"] = "Thuc hien chuoi danh cuc nhanh cho can chien, kiem va trai",
        ["Executes rapid primary attacks on all nearby enemies"] = "Thuc hien danh don co ban cuc nhanh vao moi ke dich xung quanh",
        ["F"] = "F",
        ["FACTION"] = "PHE PHAI",
        ["FOV"] = "FOV",
        ["FOV Color"] = "Mau vong FOV",
        ["FOV Position"] = "Vi tri tam FOV",
        ["FOV Radius"] = "Ban kinh FOV",
        ["FOV Thickness"] = "Do day vong FOV",
        ["FPS"] = "KHUNG HINH",
        ["FRUIT"] = "TRAI AC QUY",
        ["Fast Attack"] = "Tan cong nhanh",
        ["Fast Attack (Melee, Sword, Fruit)"] = "Tan cong nhanh (Can chien, Kiem, Trai)",
        ["Fast Flags"] = "Toi uu hoa nhanh",
        ["FFlags 1 (FPS Booster)"] = "FFlags 1 (Tang cuong FPS)",
        ["120 FPS cap, smooth plastic textures, removes atmosphere fog, hides debris"] = "Gioi han 120 FPS, ket cau nhua min, xoa suong mu va an manh vo",
        ["No Animations"] = "Khong Hoat Anh",
        ["Stops non-attack animations to fix sideways bug and character freezes"] = "Dung cac hoat anh khong tan cong de sua loi bi dung hinh",
        ["Fast Flags & Engine Tuning"] = "Fast Flags va Toi uu he thong",
        ["Field of View"] = "Vung tam nhin",
        ["Field of View (FOV Customization)"] = "Goc nhin (Tuy chinh FOV)",
        ["Forward velocity boost"] = "Day van toc ve phia truoc",
        ["French"] = "Tieng Phap",
        ["Fruit"] = "Trai quy",
        ["Game Stats"] = "Thong so tro choi",
        ["Glass Interface & Visual Effects"] = "Hieu ung kinh va Giao dien",
        ["Glass Transparency"] = "Do trong suot cua kinh",
        ["Green"] = "Xanh la",
        ["Gun"] = "Sung",
        ["Gun Aura (Dragon Gun M1)"] = "Gun Aura (Dragon Gun M1)",
        ["Head"] = "Dau",
        ["High jump leap"] = "Cu nhay vao khong trung",
        ["High-distance forward velocity boost with keybind Z"] = "Tang toc tien ve phia truoc khoang cach xa bang phim Z",
        ["Home"] = "Trang chu",
        ["HumanoidRootPart"] = "HumanoidRootPart",
        ["Identifies equipped Devil Fruit power (Kitsune, Portal, etc.)"] = "Nhan dien trai ac quy dang dung",
        ["Illuminates full player character models through walls"] = "Chieu sang mo hinh nguoi choi qua tuong",
        ["Immunity to lava damage"] = "Mien nhiem sat thuong nham thach",
        ["In-Game Attributes"] = "Chi so trong Game",
        ["Increase dash distance"] = "Tang khoang cach luot",
        ["Infinite Jump"] = "Nhay vo han",
        ["Infinite Soru"] = "Soru vo han",
        ["Interface Effects"] = "Hieu ung giao dien",
        ["Interface Language"] = "Ngon ngu giao dien",
        ["Interface Scale"] = "Ti le giao dien",
        ["Jump continuously in mid-air"] = "Nhay lien tuc tren khong",
        ["Keep Armament Haki active"] = "Tu dong kich hoat Haki Vu Trang",
        ["LEVEL"] = "CAP DO",
        ["Language"] = "Ngon ngu",
        ["Language & Localization"] = "Ngon ngu va Ban dia hoa",
        ["Large (120%)"] = "Lon (120%)",
        ["Load Configuration Profile"] = "Tai cau hinh",
        ["Load Config"] = "Tai Cau hinh",
        ["Lock camera onto enemy"] = "Khoa camera vao muc tieu",
        ["Locks camera perspective directly onto focused enemy player"] = "Khoa goc nhin camera truc tiep vao nguoi choi doi thu",
        ["Looking At Me"] = "Dang nhin toi",
        ["Low HP"] = "Mau thap nhat",
        ["Master ESP"] = "Tong the ESP",
        ["Master ESP Toggle"] = "Bat tat ESP chinh",
        ["Master Visuals & Chams"] = "Hinh anh chinh va Chams",
        ["Max Range"] = "Tam xa toi da",
        ["Max Soru Range"] = "Tam xa Soru toi da",
        ["Melee"] = "Can chien",
        ["Misc"] = "Khac",
        ["Mouse"] = "Con tro chuot",
        ["Move smoothly through structures and physical obstacles"] = "Di chuyen muot ma qua cac cong trinh va vat can",
        ["Movement"] = "Di chuyen",
        ["Movement & Agility (PvP Physics)"] = "Di chuyen va Linh hoat (Vat ly PvP)",
        ["Multiplies dash distance for high-speed repositioning"] = "Nhan khoang cach luot de thay doi vi tri nhanh chong",
        ["Multiplies jump impulse for vertical escape and aerial combat"] = "Nhan luc nhay de thoat hiem tren cao va khong chien",
        ["NPC Silent Aim"] = "Silent Aim NPC",
        ["Nearest"] = "Gan nhat",
        ["Nearest Player"] = "Nguoi choi gan nhat",
        ["Neon Rain Layer"] = "Hieu ung mua Neon Cyber",
        ["Next (›)"] = "Tiep theo (›)",
        ["Noclip Wallpass"] = "Noclip di xuyen tuong",
        ["None"] = "Khong co",
        ["Official Community & Discord"] = "Cong dong chinh thuc va Discord",
        ["Orange"] = "Cam",
        ["Overhead Billboard"] = "Bang ten tren dau",
        ["PING"] = "DO TRE",
        ["PLAYERS"] = "NGUOI CHOI",
        ["Pass through walls and objects"] = "Di xuyen qua tuong va vat the",
        ["Performance"] = "Hieu nang",
        ["Performance & Network"] = "Hieu nang va Mang",
        ["Pink"] = "Hong",
        ["Player"] = "Nguoi choi",
        ["Player 2D Boxes"] = "Khung 2D nguoi choi",
        ["Player Bounty Tracker"] = "Tien thuong nguoi choi",
        ["Player Chams & Tracers"] = "Chams va Duong ke nguoi choi",
        ["Player Chams (Highlight)"] = "Chams nguoi choi (Highlight)",
        ["Player Health Status"] = "Mau nguoi choi",
        ["Player Level Display"] = "Cap do nguoi choi",
        ["Player Names"] = "Ten nguoi choi",
        ["Player Profile"] = "Ho so nguoi choi",
        ["Player Profile & Account"] = "Ho so nguoi choi va Tai khoan",
        ["Player Radar Elements"] = "Phan tu radar nguoi choi",
        ["Player Silent Aim"] = "Silent Aim nguoi choi",
        ["Player Tracer Color"] = "Mau duong dan nguoi choi",
        ["Player Tracers"] = "Duong dan den nguoi choi",
        ["Portuguese"] = "Tieng Bo Dao Nha",
        ["Prediction Amount"] = "Muc doan truoc",
        ["Premium User  •  Active Session"] = "Nguoi dung Premium  •  Phien hoat dong",
        ["Preset: Crimson Slayer"] = "Mau: Sat Thu Do Tham",
        ["Preset: Cyberpunk Violet"] = "Mau: Tim Cyberpunk",
        ["Preset: Emerald Forest"] = "Mau: Rung Ngoc Luc Bao",
        ["Preset: Shorekeeper Cyan"] = "Mau: Shorekeeper Xanh Lo",
        ["Previous (‹)"] = "Truoc do (‹)",
        ["Purple"] = "Tim",
        ["PvP"] = "PvP",
        ["PvP Tech, Camlock & Universal Keybinds"] = "Cong nghe PvP, Camlock va Phim tat",
        ["Q"] = "Q",
        ["Quick Actions"] = "Hanh dong nhanh",
        ["R"] = "R",
        ["RACE"] = "CHUNG TOC",
        ["Radar Elements"] = "Thanh phan Radar",
        ["Rainbow"] = "Cau vong",
        ["Rainbow Chroma Speed"] = "Toc do cau vong Chroma",
        ["Raindrop Density"] = "Mat do hat mua",
        ["Random (Shuffle)"] = "Ngau nhien",
        ["Rapid fire M1 gun shots"] = "Ban dan M1 sieu toc",
        ["Rapid melee and weapon strikes"] = "Tan cong can chien toc do cao",
        ["Rapid weapon hit bursts"] = "Danh lien hoan vu khi",
        ["Rapid-fire gun attack loop targeting nearest combatant"] = "Vong lap ban sung toc do cao vao muc tieu gan nhat",
        ["Red"] = "Do",
        ["Redirect skills toward enemy players"] = "Chuyen huong chieu thuc toi nguoi choi",
        ["Redirect skills toward mobs and bosses"] = "Chuyen huong chieu thuc toi quai va trum",
        ["Redirects Flashstep teleport directly to enemy player"] = "Dich chuyen Soru truc tiep toi nguoi choi muc tieu",
        ["Redirects skills and attacks towards enemy players"] = "Dinh huong ky nang va don danh ve phia nguoi choi dich",
        ["Redirects skills and attacks towards mobs and bosses"] = "Dinh huong ky nang va don danh ve phia quai va trum",
        ["Rejoin Current Server"] = "Vao lai may chu hien tai",
        ["Remove flashstep cooldown"] = "Xoa thoi gian hoi chieu toc bien",
        ["Removes cooldown delay and bypasses stamina limits"] = "Xoa thoi gian hoi chieu va khong ton the luc",
        ["Renders hardware 3D Beams and 2D lines to target"] = "Ve tia 3D va duong 2D den muc tieu",
        ["Reset All Settings to Factory Defaults"] = "Khoi phuc mac dinh goc",
        ["Reset Configuration Profile"] = "Khoi phuc cau hinh goc",
        ["Reset Config"] = "Dat lai Cau hinh",
        ["Configuration profile reset to defaults."] = "Ho so cau hinh da duoc dat lai ve mac dinh.",
        ["Reset Theme to Purple"] = "Dat lai giao dien mau tim",
        ["Sanguine Boost"] = "Tang toc Sanguine",
        ["Sanguine Boost Floating Widget"] = "Nut noi Sanguine Z",
        ["Sanguine Keybind"] = "Phim tat Sanguine",
        ["Save Configuration Profile"] = "Luu cau hinh",
        ["Save Config"] = "Luu Cau hinh",
        ["Selected Player"] = "Nguoi choi da chon",
        ["Server Hop (Fast)"] = "Chuyen may chu (Nhanh)",
        ["Show FOV Circle"] = "Hien thi vong FOV",
        ["Show Tracers"] = "Hien thi duong dan huong",
        ["Shows distance measurement in studs below player feet"] = "Hien thi khoang cach bang studs duoi chan",
        ["Shows player rank and numerical level tag"] = "Hien thi thu hang va cap do nguoi choi",
        ["Shows weapon, sword, fruit or gun held by the player"] = "Hien thi vu khi, kiem, sung hoac trai dang cam",
        ["Silent Aim"] = "Ban tu dong",
        ["Skill Blacklist"] = "Danh sach ky nang chan",
        ["Skill Delay"] = "Do tre ky nang",
        ["Skill Redirection Blacklist"] = "Danh sach den ky nang",
        ["Soru"] = "Soru",
        ["Soru Aimbot"] = "Soru Aimbot",
        ["Soru Combat Aimbot"] = "Aimbot Soru",
        ["Soru Flashstep Engine"] = "Dong co Soru Flashstep",
        ["Soru Skill Combo"] = "Combo ky nang Soru",
        ["Soru Skill Combo Automation"] = "Tu dong Combo ky nang Soru",
        ["Soru Target Mode"] = "Che do muc tieu Soru",
        ["Spanish"] = "Tieng Tay Ban Nha",
        ["Spawns water surface collider allowing sprint across oceans"] = "Tao mat san nuoc cho phep chay tren bien",
        ["Speed up player movement"] = "Tang toc do di chuyen nguoi choi",
        ["Standard (100%)"] = "Tieu chuan (100%)",
        ["Subtle (50%)"] = "Tinh te (50%)",
        ["Super Jump"] = "Sieu nhay",
        ["Super Jump Floating Widget"] = "Tien ich noi Sieu Nhay",
        ["Super Jump Force"] = "Luc sieu nhay",
        ["Sword"] = "Kiem",
        ["System Info"] = "Thong tin he thong",
        ["T"] = "T",
        ["Target Hitbox"] = "Vung va cham muc tieu",
        ["Target Player Selection"] = "Chon nguoi choi muc tieu",
        ["Target Priority"] = "Uu tien muc tieu",
        ["Target Selection & Aim Mode"] = "Chon muc tieu va Che do ngam",
        ["Target Tracers"] = "Duong ke chi muc tieu",
        ["Teleport soru directly to enemy"] = "Dich chuyen soru thang vao ke thu",
        ["Theme Presets"] = "Mau giao dien san",
        ["Theme Reset"] = "Dat lai giao dien",
        ["Themes"] = "Giao dien",
        ["Toggle Rainbow Chroma Mode"] = "Bat che do mau cau vong Chroma",
        ["Toggle animated falling cyber rain streaks"] = "Bat tat hieu ung mua cong nghe chuyen dong",
        ["Tracer Color"] = "Mau duong dan huong",
        ["Tracer Mode"] = "Che do duong dan huong",
        ["Tracer Origin"] = "Diem bat dau duong dan",
        ["Tracer Thickness"] = "Do day duong dan huong",
        ["Tracers"] = "Duong dan huong",
        ["Trigger Super Jump"] = "Kich hoat Sieu nhay",
        ["Typography Font"] = "Kieu phong chu",
        ["Typography Studio"] = "Phong chu hien thi",
        ["UPTIME"] = "THOI GIAN CHAY",
        ["Ultra fast burst firing with CombatController validator"] = "Ban lien thanh sieu nhanh voi trinh xac thuc CombatController",
        ["UpperTorso"] = "Than tren",
        ["Use skill instantly after Soru"] = "Tung ky nang ngay lap tuc sau Soru",
        ["V"] = "V",
        ["Vietnamese"] = "Tieng Viet",
        ["Visuals"] = "Hien thi",
        ["Vitality & Energy Status"] = "Trang thai Mau va Nang luong",
        ["Walk on Water"] = "Di tren mat nuoc",
        ["Walk on ocean surface"] = "Di chuyen tren mat bien",
        ["WalkSpeed Value"] = "Gia tri toc do",
        ["Wallpaper"] = "Hinh nen",
        ["Wallpapers"] = "Danh sach hinh nen",
        ["White"] = "Trang",
        ["World & Client Optimization"] = "Toi uu hoa the gioi va ung dung",
        ["X"] = "X",
        ["Yellow"] = "Vang",
        ["Z"] = "Z",
        ["Z Sanguine Boost"] = "Tang toc Sanguine Z",
        ["B1 Hold Time (s)"] = "B1 Thoi gian giu (s)",
        ["B1 Mode"] = "B1 Che do",
        ["B1 Post Jumps"] = "B1 Buoc nhay phu",
        ["B1 Skill Key"] = "B1 Phim chieu",
        ["B1 Weapon"] = "B1 Vu khi",
        ["B2 Hold Time (s)"] = "B2 Thoi gian giu (s)",
        ["B2 Mode"] = "B2 Che do",
        ["B2 Post Jumps"] = "B2 Buoc nhay phu",
        ["B2 Skill Key"] = "B2 Phim chieu",
        ["B2 Weapon"] = "B2 Vu khi",
        ["B3 Hold Time (s)"] = "B3 Thoi gian giu (s)",
        ["B3 Mode"] = "B3 Che do",
        ["B3 Post Jumps"] = "B3 Buoc nhay phu",
        ["B3 Skill Key"] = "B3 Phim chieu",
        ["B3 Weapon"] = "B3 Vu khi",
        ["B4 Hold Time (s)"] = "B4 Thoi gian giu (s)",
        ["B4 Mode"] = "B4 Che do",
        ["B4 Post Jumps"] = "B4 Buoc nhay phu",
        ["B4 Skill Key"] = "B4 Phim chieu",
        ["B4 Weapon"] = "B4 Vu khi",
        ["B5 Hold Time (s)"] = "B5 Thoi gian giu (s)",
        ["B5 Mode"] = "B5 Che do",
        ["B5 Post Jumps"] = "B5 Buoc nhay phu",
        ["B5 Skill Key"] = "B5 Phim chieu",
        ["B5 Weapon"] = "B5 Vu khi",
        ["B6 Hold Time (s)"] = "B6 Thoi gian giu (s)",
        ["B6 Mode"] = "B6 Che do",
        ["B6 Post Jumps"] = "B6 Buoc nhay phu",
        ["B6 Skill Key"] = "B6 Phim chieu",
        ["B6 Weapon"] = "B6 Vu khi",
        ["Block 1 Enabled"] = "Bat Khoi 1",
        ["Block 2 Enabled"] = "Bat Khoi 2",
        ["Block 3 Enabled"] = "Bat Khoi 3",
        ["Block 4 Enabled"] = "Bat Khoi 4",
        ["Block 5 Enabled"] = "Bat Khoi 5",
        ["Block 6 Enabled"] = "Bat Khoi 6",
        ["Combo Sequence (6 Blocks)"] = "Chuoi Combo (6 Khoi)",
        ["Display real-time FPS and ping overlay top-left"] = "Hien thong so FPS va ping o goc tren ben trai",
        ["Displays on-screen one-touch button to trigger combo"] = "Hien nut mot cham tren man hinh de kich hoat combo",
        ["Do not target allied players"] = "Khong ngam vao dong doi",
        ["Do not target players inside safe zones"] = "Khong ngam vao nguoi trong vung an toan",
        ["Do not target players with PvP disabled"] = "Khong ngam vao nguoi choi tat PvP",
        ["Enable step 1 in combo"] = "Kich hoat buoc 1 trong combo",
        ["Enable step 2 in combo"] = "Kich hoat buoc 2 trong combo",
        ["Enable step 3 in combo"] = "Kich hoat buoc 3 trong combo",
        ["Enable step 4 in combo"] = "Kich hoat buoc 4 trong combo",
        ["Enable step 5 in combo"] = "Kich hoat buoc 5 trong combo",
        ["Enable step 6 in combo"] = "Kich hoat buoc 6 trong combo",
        ["Enables keyboard trigger and loop execution"] = "Kich hoat phim tat va chay vong lap",
        ["Fly"] = "Bay",
        ["Fly Speed"] = "Toc do bay",
        ["Glide freely through the air"] = "Luon tu do tren khong trung",
        ["Ignore Allies"] = "Bo qua dong doi",
        ["Ignore PvP Off"] = "Bo qua nguoi tat PvP",
        ["Ignore Safe Zone"] = "Bo qua Vung an toan",
        ["Loop Sequence"] = "Lap lai chuoi",
        ["Macro"] = "Macro",
        ["Macro Controller"] = "Bo dieu khien Macro",
        ["Macro Enabled"] = "Bat Macro",
        ["Macro Floating Widget"] = "Nut Macro noi tren man hinh",
        ["Macro Slot"] = "O chua Macro",
        ["Repeat sequence continuously until stopped"] = "Lap lai lien tuc cho den khi dung",
        ["Show FPS & Ping"] = "Hien FPS va Ping",
        ["Start Combo Sequence"] = "Bat dau chuoi Combo",
        ["Stop Combo Sequence"] = "Dung chuoi Combo",
        ["Trigger Key (PC)"] = "Phim kich hoat (PC)",
        ["YouTube & External Players"] = "Trình phát Ngoài & YouTube",
        ["Launch Universal YouTube Player"] = "Khởi chạy Trình phát YouTube Phổ quát",
        ["Launch Audio Library Player"] = "Khởi chạy Thư viện Âm thanh",
        ["Roblox Audio Player"] = "Trình phát Âm thanh Roblox",
    },
}local TranslatableLabels = {}
local CurrentLanguage = "English"

local function RegisterTranslatable(label, englishText)
    if not label or not englishText then return end
    table.insert(TranslatableLabels, {
        label = label,
        original = englishText
    })
    if CurrentLanguage ~= "English" then
        local langDict = TRANSLATIONS_DICT[CurrentLanguage]
        if langDict and langDict[englishText] then
            pcall(function() label.Text = langDict[englishText] end)
        end
    end
end

local function ApplyLanguage(lang)
    CurrentLanguage = lang
    local langDict = TRANSLATIONS_DICT[lang]
    for _, item in ipairs(TranslatableLabels) do
        if item.label and item.label.Parent then
            if lang == "English" or not langDict then
                pcall(function() item.label.Text = item.original end)
            else
                pcall(function() item.label.Text = langDict[item.original] or item.original end)
            end
        end
    end
    for _, ref in ipairs(ChoiceRefresherList) do
        pcall(ref)
    end
    if TriggerAutoSave then TriggerAutoSave() end
end

local CONFIG_PATHS = {
    "Monody_Config.json",
    "darling_config.json",
    "darling_hub_config.json",
    "darling_hub/config.json"
}
local CONFIG_FILE = "Monody_Config.json"
local CONFIG_FALLBACK = "darling_config.json"
local autoSaveThread = nil
local suspendSave = false

local function getExecutorFunc(name)
    local candidates = {
        name,
        name:lower(),
        (name:sub(1,1):lower() .. name:sub(2)),
    }
    for _, n in ipairs(candidates) do
        if type(rawget(_G, n)) == "function" then return rawget(_G, n) end
        if getgenv then
            local ok, g = pcall(getgenv)
            if ok and type(g) == "table" and type(rawget(g, n)) == "function" then
                return rawget(g, n)
            end
        end
        if syn and type(syn) == "table" and type(rawget(syn, n)) == "function" then
            return rawget(syn, n)
        end
        if fluxus and type(fluxus) == "table" and type(rawget(fluxus, n)) == "function" then
            return rawget(fluxus, n)
        end
        local ok, val = pcall(function() return getfenv()[n] end)
        if ok and type(val) == "function" then return val end
    end
    return nil
end

local function safeWriteFile(arg1, arg2)
    local content = arg2 or arg1
    local specifiedPath = (arg2 and arg1) or nil
    local fn = (type(writefile) == "function" and writefile) or getExecutorFunc("writefile") or getExecutorFunc("writeFile")
    if not fn then return false, "writefile not supported" end

    pcall(function()
        local mkf = (type(makefolder) == "function" and makefolder) or getExecutorFunc("makefolder")
        local isf = (type(isfolder) == "function" and isfolder) or getExecutorFunc("isfolder")
        if mkf and isf and not isf("darling_hub") then
            pcall(mkf, "darling_hub")
        end
    end)

    local targetPaths = {}
    if specifiedPath then table.insert(targetPaths, specifiedPath) end
    for _, p in ipairs(CONFIG_PATHS) do
        if p ~= specifiedPath then table.insert(targetPaths, p) end
    end

    local anySuccess = false
    local lastErr = nil
    for _, p in ipairs(targetPaths) do
        local ok, err = pcall(fn, p, content)
        if ok then
            anySuccess = true
        else
            lastErr = err
        end
    end
    return anySuccess, lastErr
end

local function safeReadFile(specifiedPath)
    local fn = (type(readfile) == "function" and readfile) or getExecutorFunc("readfile") or getExecutorFunc("readFile")
    if not fn then return nil end

    local targetPaths = {}
    if specifiedPath then table.insert(targetPaths, specifiedPath) end
    for _, p in ipairs(CONFIG_PATHS) do
        if p ~= specifiedPath then table.insert(targetPaths, p) end
    end

    for _, p in ipairs(targetPaths) do
        local ok, content = pcall(fn, p)
        if ok and type(content) == "string" and #content > 1 then
            local decOk, decData = pcall(function() return HttpService:JSONDecode(content) end)
            if decOk and type(decData) == "table" then
                return content, decData
            end
        end
    end
    return nil
end


local SaveConfigProfile = nil
local TriggerAutoSave = nil
local LoadConfigProfile = nil
local ResetConfigProfile = nil

local UI_TOGGLES = {}
local UI_SLIDERS = {}
local UI_CHOICES = {}
local UI_INPUTS = {}
local ChoiceRefresherList = {}


local function BuildTabEntity(tabId, tabName, lucideName, orderIndex)
    local minH = TAB_MIN_CANVAS[tabId] or 600
    local page = Instance.new("ScrollingFrame", PageContainer)
    page.Name = tabId .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 5
    page.ScrollBarImageColor3 = CurrentAccent
    page.ScrollBarImageTransparency = 0.2
    page.AutomaticCanvasSize = Enum.AutomaticSize.None
    page.CanvasSize = UDim2.new(0, 0, 0, minH)
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.ElasticBehavior = Enum.ElasticBehavior.Always
    page.ClipsDescendants = true
    page.Active = true
    page.ScrollingEnabled = true
    page.Visible = false
    page.ZIndex = 10

    local pList = Instance.new("UIListLayout", page)
    pList.SortOrder = Enum.SortOrder.LayoutOrder
    pList.Padding = UDim.new(0, 6)
    Instance.new("UIPadding", page).PaddingRight = UDim.new(0, 4)

    pList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        UpdatePageCanvas(page)
    end)

    -- Dock Button (Luxury Glass Pill Capsule)
    local dockBtn = Instance.new("TextButton", BottomDock)
    dockBtn.Name = "DockBtn_" .. tabId
    dockBtn.LayoutOrder = orderIndex
    dockBtn.Size = UDim2.new(1, -4, 0, 26)
    dockBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dockBtn.BackgroundTransparency = 0.96
    dockBtn.AutoButtonColor = false
    dockBtn.Text = ""
    dockBtn.Active = true
    dockBtn.Selectable = true
    dockBtn.ZIndex = 16
    Instance.new("UICorner", dockBtn).CornerRadius = UDim.new(0, 8)

    local btnStroke = Instance.new("UIStroke", dockBtn)
    btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Thickness = 0.8
    btnStroke.Transparency = 0.95

    -- Left Active Pill Indicator
    local activePill = Instance.new("Frame", dockBtn)
    activePill.Size = UDim2.new(0, 3, 0, 14)
    activePill.Position = UDim2.new(0, 2, 0.5, -7)
    activePill.BackgroundColor3 = CurrentAccent
    activePill.BackgroundTransparency = 1
    activePill.Active = false
    activePill.ZIndex = 17
    Instance.new("UICorner", activePill).CornerRadius = UDim.new(1, 0)
    RegisterThemeFill(activePill)

    local iconImg = Instance.new("ImageLabel", dockBtn)
    iconImg.Size = UDim2.new(0, 14, 0, 14)
    iconImg.Position = UDim2.new(0, 7, 0.5, -7)
    iconImg.BackgroundTransparency = 1
    iconImg.ImageColor3 = Color3.fromRGB(180, 180, 190)
    iconImg.Active = false
    iconImg.ZIndex = 17
    ApplyTabIcon(iconImg, tabId, lucideName)

    local tabLabel = Instance.new("TextLabel", dockBtn)
    tabLabel.Size = UDim2.new(1, -26, 1, 0)
    tabLabel.Position = UDim2.new(0, 25, 0, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = tabName
    RegisterTranslatable(tabLabel, tabName)
    tabLabel.Font = Enum.Font.GothamBold
    tabLabel.TextSize = 9
    tabLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.TextTruncate = Enum.TextTruncate.AtEnd
    tabLabel.Active = false
    tabLabel.ZIndex = 17

    dockBtn.MouseEnter:Connect(function()
        if not (DockButtons[tabId] and DockButtons[tabId].isSelected) then
            TweenService:Create(dockBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.88 }):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.8 }):Play()
        end
    end)
    dockBtn.MouseLeave:Connect(function()
        if not (DockButtons[tabId] and DockButtons[tabId].isSelected) then
            TweenService:Create(dockBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.96 }):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.95 }):Play()
        end
    end)

    local function handleSelect()
        SelectTabById(tabId)
    end

    ConnectButton(dockBtn, handleSelect)

    Pages[tabId] = page
    DockButtons[tabId] = {
        btn = dockBtn,
        stroke = btnStroke,
        pill = activePill,
        icon = iconImg,
        label = tabLabel,
        select = handleSelect,
        isSelected = false
    }
    return page
end

-- Upfront Batch Creation of All Tabs in Manifest
for _, tabMeta in ipairs(TABS_MANIFEST) do
    TabOrderCounter = TabOrderCounter + 1
    BuildTabEntity(tabMeta.id, tabMeta.name, tabMeta.icon, TabOrderCounter)
end

if Pages["Config"] then Pages["Misc"] = Pages["Config"] end
if Pages["Themes"] then Pages["Settings"] = Pages["Themes"] end
if Pages["Visuals"] then Pages["Esp"] = Pages["Visuals"] end
if Pages["Esp"] then Pages["Visuals"] = Pages["Esp"] end

_G.DarlingX.Pages = Pages
_G.DarlingX.SelectTab = SelectTabById

-- Registration Helper (returns pre-built page, safe against runtime ordering)
local function RegisterTab(tabId, tabName, lucideName)
    if tabId == "Settings" then tabId = "Themes" end
    if tabId == "Misc" then tabId = "Config" end
    if tabId == "Esp" then tabId = "Visuals" end
    if Pages[tabId] then
        return Pages[tabId]
    end
    TabOrderCounter = TabOrderCounter + 1
    return BuildTabEntity(tabId, tabName or tabId, lucideName, TabOrderCounter)
end

-- ============================================================
-- LUXURY GLASS UI COMPONENTS
-- ============================================================
local PageCardCounters = {}
local CardElementCounters = {}

local function CreateCard(parentPage, cardTitle)
    local cCount = (PageCardCounters[parentPage] or 0) + 1
    PageCardCounters[parentPage] = cCount
    local card = Instance.new("Frame", parentPage)
    card.Name = "Card_" .. (cardTitle and cardTitle:gsub("[^%w_]+", "_") or tostring(cCount))
    card.LayoutOrder = cCount
    card.Size = UDim2.new(1, 0, 0, 36)
    card.AutomaticSize = Enum.AutomaticSize.None
    card.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    card.BackgroundTransparency = 0.65
    card.ClipsDescendants = false
    card.Active = false
    card.ZIndex = 10
    CardElementCounters[card] = 0
    table.insert(GlassFrames, card)
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", card)
    stroke.Color = CurrentAccent
    stroke.Thickness = 0.8
    stroke.Transparency = 0.88
    RegisterThemeStroke(stroke)

    local pad = Instance.new("UIPadding", card)
    pad.PaddingTop = UDim.new(0, 7)
    pad.PaddingBottom = UDim.new(0, 7)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)

    local list = Instance.new("UIListLayout", card)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 5)

    if cardTitle then
        local eCount = (CardElementCounters[card] or 0) + 1
        CardElementCounters[card] = eCount
        local header = Instance.new("TextLabel", card)
        header.Name = "CardHeader"
        header.LayoutOrder = eCount
        header.Size = UDim2.new(1, 0, 0, 14)
        header.BackgroundTransparency = 1
        header.Text = cardTitle
        RegisterTranslatable(header, cardTitle)
        header.Font = Enum.Font.GothamBold
        header.TextSize = 9.5
        header.TextColor3 = CurrentAccent
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Active = false
        header.ZIndex = 11
        RegisterThemeText(header)
    end

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        UpdateCardGeometry(card)
    end)
    card.ChildAdded:Connect(function()
        task.defer(function() UpdateCardGeometry(card) end)
    end)

    task.defer(function() UpdateCardGeometry(card) end)
    return card
end

-- Premium Interactive Glass Button
local function AddButton(parentCard, btnText, callback)
    local eCount = (CardElementCounters[parentCard] or 0) + 1
    CardElementCounters[parentCard] = eCount
    local btn = Instance.new("TextButton", parentCard)
    btn.Name = "Btn_" .. (btnText and btnText:sub(1, 16):gsub("[^%w_]+", "_") or "Button")
    btn.LayoutOrder = eCount
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.92
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Active = true
    btn.Selectable = true
    btn.ZIndex = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local bStroke = Instance.new("UIStroke", btn)
    bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    bStroke.Color = CurrentAccent
    bStroke.Thickness = 0.8
    bStroke.Transparency = 0.85
    RegisterThemeStroke(bStroke)

    local btnLbl = Instance.new("TextLabel", btn)
    btnLbl.Name = "Label"
    btnLbl.Size = UDim2.new(1, 0, 1, 0)
    btnLbl.BackgroundTransparency = 1
    btnLbl.Text = btnText
    RegisterTranslatable(btnLbl, btnText)
    btnLbl.Font = Enum.Font.GothamBold
    btnLbl.TextSize = 9.5
    btnLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnLbl.Active = false
    btnLbl.ZIndex = 13

    ConnectButton(btn, function()
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundTransparency = 0.80 }):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.1), { Transparency = 0.6 }):Play()
        task.delay(0.12, function()
            TweenService:Create(btn, TweenInfo.new(0.18), { BackgroundTransparency = 0.92 }):Play()
            TweenService:Create(bStroke, TweenInfo.new(0.18), { Transparency = 0.85 }):Play()
        end)
        if callback then pcall(callback) end
    end)
    UpdateCardGeometry(parentCard)
    return btn
end

-- Premium Interactive Glass Toggle
local function AddToggle(parentCard, titleText, descText, defaultState, callback)
    local state = defaultState or false
    if UI_TOGGLES[titleText] and UI_TOGGLES[titleText].get then
        state = UI_TOGGLES[titleText].get()
    end
    local eCount = (CardElementCounters[parentCard] or 0) + 1
    CardElementCounters[parentCard] = eCount

    local row = Instance.new("TextButton", parentCard)
    row.Name = "Toggle_" .. (titleText and titleText:sub(1, 16):gsub("[^%w_]+", "_") or "Toggle")
    row.LayoutOrder = eCount
    row.Size = UDim2.new(1, 0, 0, descText and 36 or 28)
    row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    row.BackgroundTransparency = 0.92
    row.Text = ""
    row.AutoButtonColor = false
    row.Active = true
    row.Selectable = true
    row.ZIndex = 12
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local rStroke = Instance.new("UIStroke", row)
    rStroke.Color = Color3.fromRGB(255, 255, 255)
    rStroke.Thickness = 0.8
    rStroke.Transparency = 0.88

    local pad = Instance.new("UIPadding", row)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)

    local tLbl = Instance.new("TextLabel", row)
    tLbl.Size = UDim2.new(1, -44, 0, 14)
    tLbl.Position = UDim2.new(0, 0, 0, descText and 4 or 7)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = titleText
    tLbl.Font = Enum.Font.GothamBold
    tLbl.TextSize = 9.5
    tLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Active = false
    tLbl.ZIndex = 13
    RegisterTranslatable(tLbl, titleText)

    if descText then
        local dLbl = Instance.new("TextLabel", row)
        dLbl.Size = UDim2.new(1, -44, 0, 12)
        dLbl.Position = UDim2.new(0, 0, 0, 19)
        dLbl.BackgroundTransparency = 1
        dLbl.Text = descText
        RegisterTranslatable(dLbl, descText)
        dLbl.Font = Enum.Font.Gotham
        dLbl.TextSize = 8
        dLbl.TextColor3 = Color3.fromRGB(150, 145, 170)
        dLbl.TextXAlignment = Enum.TextXAlignment.Left
        dLbl.Active = false
        dLbl.ZIndex = 13
    end

    local switch = Instance.new("Frame", row)
    switch.Size = UDim2.new(0, 34, 0, 18)
    switch.Position = UDim2.new(1, -34, 0.5, -9)
    switch.BackgroundColor3 = state and CurrentAccent or Color3.fromRGB(38, 38, 44)
    switch.BackgroundTransparency = state and 0.1 or 0.5
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
    switch.Active = false
    switch.ZIndex = 13

    local swStroke = Instance.new("UIStroke", switch)
    swStroke.Color = Color3.fromRGB(255, 255, 255)
    swStroke.Thickness = 0.8
    swStroke.Transparency = 0.82

    SetActiveToggle(switch, state)

    local knob = Instance.new("Frame", switch)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = state and Color3.fromRGB(20, 20, 25) or Color3.fromRGB(220, 220, 220)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    knob.Active = false
    knob.ZIndex = 14

    local function setState(nextState, runCallback)
        if state == nextState then return end
        state = nextState
        SetActiveToggle(switch, state)
        TweenService:Create(switch, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            BackgroundColor3 = state and CurrentAccent or Color3.fromRGB(38, 38, 44),
            BackgroundTransparency = state and 0.1 or 0.5
        }):Play()
        TweenService:Create(swStroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
            BackgroundColor3 = state and Color3.fromRGB(20, 20, 25) or Color3.fromRGB(220, 220, 220)
        }):Play()
        if runCallback and callback then pcall(callback, state) end
        if not suspendSave and TriggerAutoSave then TriggerAutoSave() end
    end

    if not UI_TOGGLES[titleText] then
        UI_TOGGLES[titleText] = {
            handlers = {},
            default = defaultState or false,
            get = function() return state end,
            set = function(nextVal, runCb)
                for _, h in ipairs(UI_TOGGLES[titleText].handlers) do
                    h(nextVal, runCb)
                end
            end
        }
    end
    table.insert(UI_TOGGLES[titleText].handlers, function(nextVal, runCb)
        setState(nextVal, runCb)
    end)
    UI_TOGGLES[titleText].get = function() return state end

    table.insert(ToggleControls, function(nextState)
        setState(nextState, true)
    end)

    local control = setmetatable({
        Instance = row,
        SetState = function(nextState, runCallback)
            setState(nextState, runCallback)
        end
    }, {
        __index = row,
        __newindex = function(_, k, v)
            row[k] = v
        end
    })

    ConnectButton(row, function()
        UI_TOGGLES[titleText].set(not state, true)
    end)
    UpdateCardGeometry(parentCard)
    return control
end

-- Premium Interactive Glass Slider with Glowing Track and Numeric Pill Badge
local function AddSlider(parentCard, titleText, minVal, maxVal, defaultVal, stepVal, callback)
    local currentVal = defaultVal or minVal
    stepVal = stepVal or 1
    local eCount = (CardElementCounters[parentCard] or 0) + 1
    CardElementCounters[parentCard] = eCount

    local container = Instance.new("Frame", parentCard)
    container.Name = "Slider_" .. (titleText and titleText:sub(1, 16):gsub("[^%w_]+", "_") or "Slider")
    container.LayoutOrder = eCount
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    container.BackgroundTransparency = 0.92
    container.Active = false
    container.ZIndex = 12
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local cStroke = Instance.new("UIStroke", container)
    cStroke.Color = Color3.fromRGB(255, 255, 255)
    cStroke.Thickness = 0.8
    cStroke.Transparency = 0.88

    local pad = Instance.new("UIPadding", container)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)

    local tLbl = Instance.new("TextLabel", container)
    tLbl.Size = UDim2.new(1, -56, 0, 16)
    tLbl.Position = UDim2.new(0, 0, 0, 4)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = titleText
    tLbl.Font = Enum.Font.GothamBold
    tLbl.TextSize = 9.5
    tLbl.TextColor3 = Color3.fromRGB(240, 235, 255)
    RegisterTranslatable(tLbl, titleText)
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Active = false
    tLbl.ZIndex = 13

    -- Value Pill Badge
    local vPill = Instance.new("Frame", container)
    vPill.Size = UDim2.new(0, 46, 0, 16)
    vPill.Position = UDim2.new(1, -46, 0, 4)
    vPill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    vPill.BackgroundTransparency = 0.88
    vPill.Active = false
    vPill.ZIndex = 13
    Instance.new("UICorner", vPill).CornerRadius = UDim.new(0, 6)
    local vpStroke = Instance.new("UIStroke", vPill)
    vpStroke.Color = CurrentAccent
    vpStroke.Thickness = 0.8
    vpStroke.Transparency = 0.85
    RegisterThemeStroke(vpStroke)

    local vLbl = Instance.new("TextLabel", vPill)
    vLbl.Size = UDim2.new(1, 0, 1, 0)
    vLbl.BackgroundTransparency = 1
    vLbl.Text = tostring(currentVal)
    vLbl.Font = Enum.Font.GothamBold
    vLbl.TextSize = 8.5
    vLbl.TextColor3 = CurrentAccent
    vLbl.TextXAlignment = Enum.TextXAlignment.Center
    vLbl.Active = false
    vLbl.ZIndex = 14
    RegisterThemeText(vLbl)

    -- Track
    local track = Instance.new("TextButton", container)
    track.Size = UDim2.new(1, 0, 0, 8)
    track.Position = UDim2.new(0, 0, 0, 26)
    track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    track.BackgroundTransparency = 0.85
    track.AutoButtonColor = false
    track.Text = ""
    track.Active = true
    track.ZIndex = 13
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local trkStroke = Instance.new("UIStroke", track)
    trkStroke.Color = Color3.fromRGB(255, 255, 255)
    trkStroke.Thickness = 0.8
    trkStroke.Transparency = 0.85

    local fill = Instance.new("Frame", track)
    local initialFrac = math.clamp((currentVal - minVal) / (maxVal - minVal), 0, 1)
    fill.Size = UDim2.new(initialFrac, 0, 1, 0)
    fill.BackgroundColor3 = CurrentAccent
    fill.BackgroundTransparency = 0.15
    fill.Active = false
    fill.ZIndex = 13
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    RegisterThemeFill(fill)

    local knob = Instance.new("Frame", fill)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(1, -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Active = false
    knob.ZIndex = 14
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local knbStroke = Instance.new("UIStroke", knob)
    knbStroke.Color = Color3.fromRGB(200, 200, 200)
    knbStroke.Thickness = 1.0
    knbStroke.Transparency = 0.8

    local function updateValue(inputX)
        local absPos = track.AbsolutePosition.X
        local absSize = track.AbsoluteSize.X
        if absSize <= 0 then return end
        local frac = math.clamp((inputX - absPos) / absSize, 0, 1)
        local rawVal = minVal + (maxVal - minVal) * frac
        local stepped = math.floor((rawVal / stepVal) + 0.5) * stepVal
        currentVal = math.clamp(stepped, minVal, maxVal)

        local visualFrac = (currentVal - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(visualFrac, 0, 1, 0)
        vLbl.Text = tostring(currentVal)
        if callback then pcall(callback, currentVal) end
    end

    local function setValue(newVal, runCallback)
        local rawVal = math.clamp(newVal, minVal, maxVal)
        local stepped = math.floor((rawVal / stepVal) + 0.5) * stepVal
        currentVal = math.clamp(stepped, minVal, maxVal)
        local visualFrac = (currentVal - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(visualFrac, 0, 1, 0)
        vLbl.Text = tostring(currentVal)
        if runCallback and callback then pcall(callback, currentVal) end
        if not suspendSave and TriggerAutoSave then TriggerAutoSave() end
    end

    local control = setmetatable({
        Instance = container,
        SetValue = setValue
    }, {
        __index = container,
        __newindex = function(_, k, v)
            container[k] = v
        end
    })

    local sliding = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateValue(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if sliding and not suspendSave and TriggerAutoSave then
                TriggerAutoSave()
            end
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input.Position.X)
        end
    end)

    UI_SLIDERS[titleText] = {
        default = defaultVal or minVal,
        set = function(newVal, runCb)
            setValue(newVal, runCb)
        end,
        get = function()
            return currentVal
        end
    }

    UpdateCardGeometry(parentCard)
    return control
end

-- Premium Choice Selector with Value Badge
local function AddChoice(parentCard, label, values, defaultIndex, callback)
    local index = defaultIndex or 1
    local eCount = (CardElementCounters[parentCard] or 0) + 1
    CardElementCounters[parentCard] = eCount

    local container = Instance.new("TextButton", parentCard)
    container.Name = "Choice_" .. (label and label:sub(1, 16):gsub("[^%w_]+", "_") or "Choice")
    container.LayoutOrder = eCount
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    container.BackgroundTransparency = 0.92
    container.Text = ""
    container.AutoButtonColor = false
    container.Active = true
    container.Selectable = true
    container.ZIndex = 12
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", container)
    stroke.Thickness = 0.8
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.88

    local pad = Instance.new("UIPadding", container)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    RegisterTranslatable(lbl, label)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 9.5
    lbl.TextColor3 = Color3.fromRGB(240, 235, 255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Active = false
    lbl.ZIndex = 13

    local badge = Instance.new("Frame", container)
    badge.Size = UDim2.new(0.5, -4, 0, 20)
    badge.Position = UDim2.new(0.5, 4, 0.5, -10)
    badge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    badge.BackgroundTransparency = 0.88
    badge.Active = false
    badge.ZIndex = 13
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)
    local bStroke = Instance.new("UIStroke", badge)
    bStroke.Color = CurrentAccent
    bStroke.Thickness = 0.8
    bStroke.Transparency = 0.82
    RegisterThemeStroke(bStroke)

    local valLbl = Instance.new("TextLabel", badge)
    valLbl.Size = UDim2.new(1, 0, 1, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 8.5
    valLbl.TextColor3 = CurrentAccent
    valLbl.TextXAlignment = Enum.TextXAlignment.Center
    valLbl.Active = false
    valLbl.ZIndex = 14
    RegisterThemeText(valLbl)

    local function refresh()
        local rawVal = tostring(values[index])
        local displayVal = rawVal
        if CurrentLanguage ~= "English" and label ~= "Interface Language" then
            local langDict = TRANSLATIONS_DICT[CurrentLanguage]
            if langDict and langDict[rawVal] then
                displayVal = langDict[rawVal]
            end
        end
        valLbl.Text = displayVal .. "  ›"
    end
    refresh()
    table.insert(ChoiceRefresherList, refresh)

    local function setIndex(newIdxOrVal, runCallback)
        if type(newIdxOrVal) == "string" then
            for i, v in ipairs(values) do
                if tostring(v) == tostring(newIdxOrVal) then
                    index = i
                    break
                end
            end
        elseif type(newIdxOrVal) == "number" then
            index = math.clamp(math.floor(newIdxOrVal), 1, #values)
        end
        refresh()
        if runCallback and callback then pcall(callback, values[index], index) end
        if not suspendSave and TriggerAutoSave then TriggerAutoSave() end
    end

    UI_CHOICES[label] = {
        default = defaultIndex or 1,
        set = function(newIdxOrVal, runCb)
            setIndex(newIdxOrVal, runCb)
        end,
        get = function()
            return values[index], index
        end
    }

    local function setValues(newVals, newIndex, runCb)
        if type(newVals) == "table" and #newVals > 0 then
            values = newVals
            index = math.clamp(newIndex or 1, 1, #values)
            refresh()
            if runCb and callback then pcall(callback, values[index], index) end
        end
    end

    local control = setmetatable({
        Instance = container,
        SetIndex = setIndex,
        SetValues = setValues,
        Refresh = setValues
    }, {
        __index = container,
        __newindex = function(_, k, v)
            container[k] = v
        end
    })

    ConnectButton(container, function()
        index = (index % #values) + 1
        refresh()
        if callback then callback(values[index], index) end
        if not suspendSave and TriggerAutoSave then TriggerAutoSave() end
    end)
    UpdateCardGeometry(parentCard)
    return control
end

-- Premium Interactive Glass Text Input
local function AddInput(parentCard, titleText, placeholderText, defaultVal, callback)
    local eCount = (CardElementCounters[parentCard] or 0) + 1
    CardElementCounters[parentCard] = eCount
    local container = Instance.new("Frame", parentCard)
    container.Name = "Input_" .. (titleText and titleText:sub(1, 16):gsub("[^%w_]+", "_") or "Input")
    container.LayoutOrder = eCount
    container.Size = UDim2.new(1, 0, 0, 48)
    container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    container.BackgroundTransparency = 0.92
    container.Active = false
    container.ZIndex = 12
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", container)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 0.8
    stroke.Transparency = 0.88

    local pad = Instance.new("UIPadding", container)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.Position = UDim2.new(0, 0, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = titleText
    RegisterTranslatable(lbl, titleText)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 9.5
    lbl.TextColor3 = Color3.fromRGB(240, 235, 255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Active = false
    lbl.ZIndex = 13

    local inputFrame = Instance.new("Frame", container)
    inputFrame.Size = UDim2.new(1, 0, 0, 20)
    inputFrame.Position = UDim2.new(0, 0, 0, 22)
    inputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    inputFrame.BackgroundTransparency = 0.88
    inputFrame.Active = false
    inputFrame.ZIndex = 13
    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 6)
    local ifStroke = Instance.new("UIStroke", inputFrame)
    ifStroke.Color = CurrentAccent
    ifStroke.Thickness = 0.8
    ifStroke.Transparency = 0.85
    RegisterThemeStroke(ifStroke)

    local tb = Instance.new("TextBox", inputFrame)
    tb.Size = UDim2.new(1, -8, 1, 0)
    tb.Position = UDim2.new(0, 4, 0, 0)
    tb.BackgroundTransparency = 1
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 9
    tb.TextColor3 = Color3.fromRGB(255, 255, 255)
    tb.PlaceholderText = placeholderText or "Enter ID or URL..."
    tb.PlaceholderColor3 = Color3.fromRGB(140, 135, 160)
    tb.Text = defaultVal or ""
    tb.ClearTextOnFocus = false
    tb.TextXAlignment = Enum.TextXAlignment.Left
    tb.Active = true
    tb.ZIndex = 14

    UI_INPUTS[titleText] = {
        default = defaultVal or "",
        set = function(val) tb.Text = tostring(val or "") end,
        get = function() return tb.Text end
    }

    pcall(function()
        tb:GetPropertyChangedSignal("Text"):Connect(function()
            if callback then
                pcall(callback, tb.Text, false)
            end
        end)
        tb.FocusLost:Connect(function(enterPressed)
            if callback then
                callback(tb.Text, enterPressed)
            end
            if not suspendSave and TriggerAutoSave then
                TriggerAutoSave()
            end
        end)
    end)

    UpdateCardGeometry(parentCard)
    return {
        Container = container,
        TextBox = tb,
        GetText = function() return tb.Text end,
        SetText = function(val) tb.Text = tostring(val or "") end
    }
end

-- Persistent Configuration Engine (Full UI & State Synchronization)
SaveConfigProfile = function(force)
    if suspendSave and not force then return false, "Saving suspended" end
    local ok, err = pcall(function()
        local cfg = {
            Version = APP_VERSION,
            Theme = CurrentThemeName,
            WallpaperIdx = currentBgIdx,
            Language = CurrentLanguage,
            Toggles = {},
            Sliders = {},
            Choices = {},
            Inputs = {},
            Features = {}
        }
        for key, entry in pairs(UI_TOGGLES) do
            local val = (entry.get and entry.get()) or false
            cfg.Toggles[key] = val
            cfg.Features[key] = val
        end
        for key, entry in pairs(UI_SLIDERS) do
            cfg.Sliders[key] = entry.get and entry.get()
        end
        for key, entry in pairs(UI_CHOICES) do
            local val, idx = entry.get()
            cfg.Choices[key] = { index = idx, value = val }
        end
        for key, entry in pairs(UI_INPUTS) do
            cfg.Inputs[key] = entry.get and entry.get()
        end

        -- Backward compatibility flat keys
        cfg.FastAttack = cfg.Toggles["Fast Attack"]
        cfg.AutoBuso = cfg.Toggles["Auto Buso Haki"]
        cfg.AutoV3 = cfg.Toggles["Auto Race V3"]
        cfg.AutoV4 = cfg.Toggles["Auto Race V4"]
        cfg.DragonGunM1 = cfg.Toggles["Dragon Gun M1"]
        cfg.Camlock = cfg.Toggles["Camlock"]
        cfg.SanguineBoost = cfg.Toggles["Sanguine Boost"]
        cfg.CustomWalkSpeed = cfg.Toggles["Custom WalkSpeed"]
        cfg.SuperJump = cfg.Toggles["Super Jump"]
        cfg.InfiniteJump = cfg.Toggles["Infinite Jump"]
        cfg.Noclip = cfg.Toggles["Noclip Wallpass"]
        cfg.WalkOnWater = cfg.Toggles["Walk on Water"]
        cfg.AntiLava = cfg.Toggles["Anti-Lava Damage"]
        cfg.DashLengthEnabled = cfg.Toggles["Custom Dash Length"]
        cfg.FFlags1 = cfg.Toggles["FFlags 1 (FPS Booster)"]
        cfg.Fly = cfg.Toggles["Fly"]
        cfg.FlySpeed = cfg.Sliders["Fly Speed"]
        cfg.ShowFPS = cfg.Toggles["Show FPS & Ping"]
        cfg.IgnoreAllies = cfg.Toggles["Ignore Allies"]
        cfg.IgnorePvPOff = cfg.Toggles["Ignore PvP Off"]
        cfg.IgnoreSafeZone = cfg.Toggles["Ignore Safe Zone"]
        cfg.MacroEnabled = cfg.Toggles["Macro Enabled"]
        cfg.MacroLoop = cfg.Toggles["Loop Sequence"]
        cfg.MacroWidget = cfg.Toggles["Macro Floating Widget"]
        
        -- Additional Features Sync
        cfg.StartAutoDungeon = cfg.Toggles["Start Auto Dungeon"]
        cfg.AutoBuso = cfg.Toggles["Auto Buso"]
        cfg.AutoRaceV4 = cfg.Toggles["Auto Race V4"]
        cfg.AutoPassRoom = cfg.Toggles["Auto Pass Room"]
        cfg.EnableVoidM1 = cfg.Toggles["Enable Void M1"]
        cfg.VoidOnlyBoss = cfg.Toggles["Void Only Boss Rooms"]
        cfg.AutoLoadDungeon = cfg.Toggles["Auto Load Dungeon"]
        cfg.AttackHeight = cfg.Sliders["Attack Height"]
        cfg.VoidInterval = cfg.Sliders["Void Interval (s)"]
        if cfg.Choices["Selected Weapon"] then cfg.SelectedWeapon = cfg.Choices["Selected Weapon"].value end

        cfg.TweenSpeed = cfg.Sliders["Tween Speed"]
        cfg.TravelAltitude = cfg.Sliders["Travel Altitude"]
        cfg.NoclipTween = cfg.Toggles["Noclip during Tween"]
        if cfg.Choices["Select Sea"] then cfg.SelectSea = cfg.Choices["Select Sea"].value end
        if cfg.Choices["Target Island"] then cfg.TargetIsland = cfg.Choices["Target Island"].value end

        cfg.ControlsScale = cfg.Sliders["Controls Global Scale"]
        cfg.Watermark = cfg.Toggles["Performance Watermark"]
        cfg.Crosshair = cfg.Toggles["Custom Crosshair"]

        if cfg.Choices["Select Weapon Skin"] then cfg.WeaponSkin = cfg.Choices["Select Weapon Skin"].value end
        if cfg.Choices["Haki Color"] then cfg.HakiColor = cfg.Choices["Haki Color"].value end
        cfg.RainbowHaki = cfg.Toggles["Rainbow Haki"]
        cfg.TrailVFX = cfg.Toggles["Custom Trail VFX"]

        cfg.MusicVolume = cfg.Sliders["Volume"]
        cfg.MusicPitch = cfg.Sliders["Pitch / Speed"]
        cfg.MusicLoop = cfg.Toggles["Loop Track"]
        cfg.TopMusicBar = cfg.Toggles["Show Top Music Bar"]
        if cfg.Choices["Genre / Category"] then cfg.MusicGenre = cfg.Choices["Genre / Category"].value end
        if cfg.Choices["Track Preset"] then cfg.MusicTrack = cfg.Choices["Track Preset"].value end

        cfg.HideAccessories = cfg.Toggles["Hide Accessories & Weapons"]
        if cfg.Choices["Select Animation"] then cfg.SelectedAnimation = cfg.Choices["Select Animation"].value end
        if cfg.Sliders["WalkSpeed Value"] then cfg.WalkSpeedVal = cfg.Sliders["WalkSpeed Value"] end
        if cfg.Sliders["Super Jump Force"] then cfg.SuperJumpForce = cfg.Sliders["Super Jump Force"] end
        if cfg.Sliders["Dash Distance"] then cfg.DashLength = cfg.Sliders["Dash Distance"] end

        local json = HttpService:JSONEncode(cfg)
        local wOk, wErr = safeWriteFile(json)
        if wOk then
            print("[Monody] Config auto-saved successfully.")
        else
            warn("[Monody] Config save notice: " .. tostring(wErr))
        end
    end)
    return ok, err
end

TriggerAutoSave = function()
    if suspendSave then return end
    if autoSaveThread then
        pcall(task.cancel, autoSaveThread)
        autoSaveThread = nil
    end
    autoSaveThread = task.delay(0.25, function()
        if suspendSave then return end
        SaveConfigProfile(true)
    end)
end

LoadConfigProfile = function()
    suspendSave = true
    local ok, err = pcall(function()
        local content, cfg = safeReadFile()
        if not cfg or type(cfg) ~= "table" then
            return false, "No valid config data found"
        end

        -- 1. Restore Theme
        if cfg.Theme and THEMES[cfg.Theme] then
            pcall(ApplyTheme, cfg.Theme)
        end

        -- 2. Restore Wallpaper
        if cfg.WallpaperIdx and WALLPAPERS[cfg.WallpaperIdx] then
            pcall(SetWallpaper, cfg.WallpaperIdx)
        end

        -- 3. Restore Language
        if cfg.Language and TRANSLATIONS_DICT[cfg.Language] then
            pcall(ApplyLanguage, cfg.Language)
        end

        -- 4. Restore Toggles (Source from Toggles or Features)
        local togglesSource = cfg.Toggles or cfg.Features
        if type(togglesSource) == "table" then
            for key, val in pairs(togglesSource) do
                if UI_TOGGLES[key] then
                    pcall(function()
                        UI_TOGGLES[key].set(val == true, true)
                    end)
                end
            end
        end

        -- Backward compatibility flat keys
        if cfg.FastAttack ~= nil and UI_TOGGLES["Fast Attack"] then
            pcall(function() UI_TOGGLES["Fast Attack"].set(cfg.FastAttack == true, true) end)
        end
        if cfg.AutoBuso ~= nil and UI_TOGGLES["Auto Buso Haki"] then
            pcall(function() UI_TOGGLES["Auto Buso Haki"].set(cfg.AutoBuso == true, true) end)
        end
        if cfg.AutoV3 ~= nil and UI_TOGGLES["Auto Race V3"] then
            pcall(function() UI_TOGGLES["Auto Race V3"].set(cfg.AutoV3 == true, true) end)
        end
        if cfg.AutoV4 ~= nil and UI_TOGGLES["Auto Race V4"] then
            pcall(function() UI_TOGGLES["Auto Race V4"].set(cfg.AutoV4 == true, true) end)
        end
        if cfg.DragonGunM1 ~= nil and UI_TOGGLES["Dragon Gun M1"] then
            pcall(function() UI_TOGGLES["Dragon Gun M1"].set(cfg.DragonGunM1 == true, true) end)
        end
        if cfg.Camlock ~= nil and UI_TOGGLES["Camlock"] then
            pcall(function() UI_TOGGLES["Camlock"].set(cfg.Camlock == true, true) end)
        end
        if cfg.SanguineBoost ~= nil and UI_TOGGLES["Sanguine Boost"] then
            pcall(function() UI_TOGGLES["Sanguine Boost"].set(cfg.SanguineBoost == true, true) end)
        end
        if cfg.CustomWalkSpeed ~= nil and UI_TOGGLES["Custom WalkSpeed"] then
            pcall(function() UI_TOGGLES["Custom WalkSpeed"].set(cfg.CustomWalkSpeed == true, true) end)
        end
        if cfg.SuperJump ~= nil and UI_TOGGLES["Super Jump"] then
            pcall(function() UI_TOGGLES["Super Jump"].set(cfg.SuperJump == true, true) end)
        end
        if cfg.InfiniteJump ~= nil and UI_TOGGLES["Infinite Jump"] then
            pcall(function() UI_TOGGLES["Infinite Jump"].set(cfg.InfiniteJump == true, true) end)
        end
        if cfg.Noclip ~= nil and UI_TOGGLES["Noclip Wallpass"] then
            pcall(function() UI_TOGGLES["Noclip Wallpass"].set(cfg.Noclip == true, true) end)
        end
        if cfg.WalkOnWater ~= nil and UI_TOGGLES["Walk on Water"] then
            pcall(function() UI_TOGGLES["Walk on Water"].set(cfg.WalkOnWater == true, true) end)
        end
        if cfg.AntiLava ~= nil and UI_TOGGLES["Anti-Lava Damage"] then
            pcall(function() UI_TOGGLES["Anti-Lava Damage"].set(cfg.AntiLava == true, true) end)
        end
        if cfg.DashLengthEnabled ~= nil and UI_TOGGLES["Custom Dash Length"] then
            pcall(function() UI_TOGGLES["Custom Dash Length"].set(cfg.DashLengthEnabled == true, true) end)
        end
        if cfg.FFlags1 ~= nil and UI_TOGGLES["FFlags 1 (FPS Booster)"] then
            pcall(function() UI_TOGGLES["FFlags 1 (FPS Booster)"].set(cfg.FFlags1 == true, true) end)
        end
        if cfg.Fly ~= nil and UI_TOGGLES["Fly"] then
            pcall(function() UI_TOGGLES["Fly"].set(cfg.Fly == true, true) end)
        end
        if cfg.FlySpeed ~= nil and UI_SLIDERS["Fly Speed"] then
            pcall(function() UI_SLIDERS["Fly Speed"].set(tonumber(cfg.FlySpeed), true) end)
        end
        if cfg.ShowFPS ~= nil and UI_TOGGLES["Show FPS & Ping"] then
            pcall(function() UI_TOGGLES["Show FPS & Ping"].set(cfg.ShowFPS == true, true) end)
        end
        if cfg.IgnoreAllies ~= nil and UI_TOGGLES["Ignore Allies"] then
            pcall(function() UI_TOGGLES["Ignore Allies"].set(cfg.IgnoreAllies == true, true) end)
        end
        if cfg.IgnorePvPOff ~= nil and UI_TOGGLES["Ignore PvP Off"] then
            pcall(function() UI_TOGGLES["Ignore PvP Off"].set(cfg.IgnorePvPOff == true, true) end)
        end
        if cfg.IgnoreSafeZone ~= nil and UI_TOGGLES["Ignore Safe Zone"] then
            pcall(function() UI_TOGGLES["Ignore Safe Zone"].set(cfg.IgnoreSafeZone == true, true) end)
        end
        if cfg.MacroEnabled ~= nil and UI_TOGGLES["Macro Enabled"] then
            pcall(function() UI_TOGGLES["Macro Enabled"].set(cfg.MacroEnabled == true, true) end)
        end
        if cfg.MacroLoop ~= nil and UI_TOGGLES["Loop Sequence"] then
            pcall(function() UI_TOGGLES["Loop Sequence"].set(cfg.MacroLoop == true, true) end)
        end
        if cfg.MacroWidget ~= nil and UI_TOGGLES["Macro Floating Widget"] then
            pcall(function() UI_TOGGLES["Macro Floating Widget"].set(cfg.MacroWidget == true, true) end)
        end
        if cfg.StartAutoDungeon ~= nil and UI_TOGGLES["Start Auto Dungeon"] then
            pcall(function() UI_TOGGLES["Start Auto Dungeon"].set(cfg.StartAutoDungeon == true, true) end)
        end
        if cfg.AutoBuso ~= nil and UI_TOGGLES["Auto Buso"] then
            pcall(function() UI_TOGGLES["Auto Buso"].set(cfg.AutoBuso == true, true) end)
        end
        if cfg.AutoRaceV4 ~= nil and UI_TOGGLES["Auto Race V4"] then
            pcall(function() UI_TOGGLES["Auto Race V4"].set(cfg.AutoRaceV4 == true, true) end)
        end
        if cfg.AutoPassRoom ~= nil and UI_TOGGLES["Auto Pass Room"] then
            pcall(function() UI_TOGGLES["Auto Pass Room"].set(cfg.AutoPassRoom == true, true) end)
        end
        if cfg.EnableVoidM1 ~= nil and UI_TOGGLES["Enable Void M1"] then
            pcall(function() UI_TOGGLES["Enable Void M1"].set(cfg.EnableVoidM1 == true, true) end)
        end
        if cfg.VoidOnlyBoss ~= nil and UI_TOGGLES["Void Only Boss Rooms"] then
            pcall(function() UI_TOGGLES["Void Only Boss Rooms"].set(cfg.VoidOnlyBoss == true, true) end)
        end
        if cfg.AutoLoadDungeon ~= nil and UI_TOGGLES["Auto Load Dungeon"] then
            pcall(function() UI_TOGGLES["Auto Load Dungeon"].set(cfg.AutoLoadDungeon == true, true) end)
        end
        if cfg.NoclipTween ~= nil and UI_TOGGLES["Noclip during Tween"] then
            pcall(function() UI_TOGGLES["Noclip during Tween"].set(cfg.NoclipTween == true, true) end)
        end
        if cfg.Watermark ~= nil and UI_TOGGLES["Performance Watermark"] then
            pcall(function() UI_TOGGLES["Performance Watermark"].set(cfg.Watermark == true, true) end)
        end
        if cfg.Crosshair ~= nil and UI_TOGGLES["Custom Crosshair"] then
            pcall(function() UI_TOGGLES["Custom Crosshair"].set(cfg.Crosshair == true, true) end)
        end
        if cfg.RainbowHaki ~= nil and UI_TOGGLES["Rainbow Haki"] then
            pcall(function() UI_TOGGLES["Rainbow Haki"].set(cfg.RainbowHaki == true, true) end)
        end
        if cfg.TrailVFX ~= nil and UI_TOGGLES["Custom Trail VFX"] then
            pcall(function() UI_TOGGLES["Custom Trail VFX"].set(cfg.TrailVFX == true, true) end)
        end
        if cfg.MusicLoop ~= nil and UI_TOGGLES["Loop Track"] then
            pcall(function() UI_TOGGLES["Loop Track"].set(cfg.MusicLoop == true, true) end)
        end
        if cfg.TopMusicBar ~= nil and UI_TOGGLES["Show Top Music Bar"] then
            pcall(function() UI_TOGGLES["Show Top Music Bar"].set(cfg.TopMusicBar == true, true) end)
        end
        if cfg.HideAccessories ~= nil and UI_TOGGLES["Hide Accessories & Weapons"] then
            pcall(function() UI_TOGGLES["Hide Accessories & Weapons"].set(cfg.HideAccessories == true, true) end)
        end

        -- 5. Restore Sliders
        if type(cfg.Sliders) == "table" then
            for key, val in pairs(cfg.Sliders) do
                local num = tonumber(val)
                if UI_SLIDERS[key] and num then
                    pcall(function() UI_SLIDERS[key].set(num, true) end)
                end
            end
        end
        if cfg.WalkSpeedVal and UI_SLIDERS["WalkSpeed Value"] then
            pcall(function() UI_SLIDERS["WalkSpeed Value"].set(tonumber(cfg.WalkSpeedVal), true) end)
        end
        if cfg.SuperJumpForce and UI_SLIDERS["Super Jump Force"] then
            pcall(function() UI_SLIDERS["Super Jump Force"].set(tonumber(cfg.SuperJumpForce), true) end)
        end
        if cfg.DashLength and UI_SLIDERS["Dash Distance"] then
            pcall(function() UI_SLIDERS["Dash Distance"].set(tonumber(cfg.DashLength), true) end)
        end

        -- 6. Restore Choices
        if type(cfg.Choices) == "table" then
            for key, entry in pairs(cfg.Choices) do
                if UI_CHOICES[key] then
                    local target = nil
                    if type(entry) == "table" then
                        target = entry.index or entry.value
                    else
                        target = entry
                    end
                    if target ~= nil then
                        pcall(function() UI_CHOICES[key].set(target, true) end)
                    end
                end
            end
        end

        -- 7. Restore Inputs
        if type(cfg.Inputs) == "table" then
            for key, val in pairs(cfg.Inputs) do
                if UI_INPUTS[key] and type(val) == "string" then
                    pcall(function() UI_INPUTS[key].set(val, true) end)
                end
            end
        end

        print("[Monody] Config profile fully loaded.")
        return true
    end)
    suspendSave = false
    return ok, err
end

local DEFAULT_TOGGLES = {
    ["Fast Attack"] = false,
    ["Dragon Gun M1"] = false,
    ["Camlock"] = false,
    ["Sanguine Boost"] = false,
    ["Super Jump"] = false,
    ["Custom WalkSpeed"] = false,
    ["FFlags 1 (FPS Booster)"] = false,
    ["Player Silent Aim"] = false,
    ["NPC Silent Aim"] = false,
    ["Show FOV Circle"] = false,
    ["Enable Target Prediction"] = false,
    ["Show Tracers"] = false,
    ["Auto Buso Haki"] = false,
    ["Auto Race V3"] = false,
    ["Auto Race V4"] = false,
    ["Custom Dash Length"] = false,
    ["Infinite Jump"] = false,
    ["Noclip Wallpass"] = false,
    ["Walk on Water"] = false,
    ["Anti-Lava Damage"] = false,
    ["No Animations"] = false,
    ["Infinite Soru"] = false,
    ["Soru Aimbot"] = false,
    ["Auto Skill on Soru"] = false,
    ["Master ESP"] = false,
    ["Player 2D Boxes"] = false,
    ["Player Names"] = false,
    ["Player Health Status"] = false,
    ["Distance Indicator"] = false,
    ["Equipped Tool / Weapon"] = false,
    ["Devil Fruit Tracker"] = false,
    ["Player Bounty Tracker"] = false,
    ["Player Level Display"] = false,
    ["Combat PvP Status"] = false,
    ["Player Chams (Highlight)"] = false,
    ["Player Tracers"] = false,
    ["Neon Rain Layer"] = false,
    ["Show FPS & Ping"] = false,
    ["Ignore Allies"] = false,
    ["Ignore PvP Off"] = false,
    ["Ignore Safe Zone"] = false,
    ["Fly"] = false,
    ["Macro Enabled"] = false,
    ["Loop Sequence"] = false,
    ["Macro Floating Widget"] = false,
    ["Block 1 Enabled"] = false,
    ["Block 2 Enabled"] = false,
    ["Block 3 Enabled"] = false,
    ["Block 4 Enabled"] = false,
    ["Block 5 Enabled"] = false,
    ["Block 6 Enabled"] = false,
}

local DEFAULT_SLIDERS = {
    ["Max Range"] = 1000,
    ["Prediction Amount"] = 12,
    ["FOV Radius"] = 100,
    ["FOV Thickness"] = 2,
    ["Tracer Thickness"] = 2,
    ["Camera FOV"] = 70,
    ["Fly Speed"] = 70,
    ["WalkSpeed Value"] = 150,
    ["Dash Distance"] = 30,
    ["Super Jump Force"] = 216,
    ["Max Soru Range"] = 2000,
    ["Skill Delay"] = 300,
    ["ESP Text Font Size"] = 13,
    ["Rainbow Chroma Speed"] = 4,
    ["Background Dimming (%)"] = 35,
    ["Raindrop Density"] = 14,
}

local DEFAULT_CHOICES = {
    ["Target Priority"] = 1,
    ["Aim Mode"] = 1,
    ["Target Hitbox"] = 1,
    ["FOV Position"] = 1,
    ["FOV Color"] = 1,
    ["Tracer Mode"] = 1,
    ["Tracer Origin"] = 1,
    ["Tracer Color"] = 1,
    ["Camlock Keybind"] = 1,
    ["Sanguine Keybind"] = 1,
    ["Soru Target Mode"] = 1,
    ["Combo Weapon"] = 1,
    ["Combo Key"] = 1,
    ["ESP Style"] = 1,
    ["Chams Highlight Color"] = 1,
    ["Player Tracer Color"] = 1,
    ["Interface Language"] = 1,
    ["Glass Transparency"] = 2,
    ["Interface Scale"] = 2,
    ["Direct Wallpaper"] = 1,
    ["Typography Font"] = 1,
    ["Target Player Selection"] = 1,
    ["Macro Slot"] = 1,
    ["Trigger Key (PC)"] = 1,
    ["B1 Weapon"] = 1,
    ["B1 Skill Key"] = 1,
    ["B1 Mode"] = 1,
    ["B2 Weapon"] = 2,
    ["B2 Skill Key"] = 2,
    ["B2 Mode"] = 1,
    ["B3 Weapon"] = 1,
    ["B3 Skill Key"] = 3,
    ["B3 Mode"] = 1,
    ["B4 Weapon"] = 4,
    ["B4 Skill Key"] = 1,
    ["B4 Mode"] = 1,
    ["B5 Weapon"] = 3,
    ["B5 Skill Key"] = 4,
    ["B5 Mode"] = 1,
    ["B6 Weapon"] = 1,
    ["B6 Skill Key"] = 2,
    ["B6 Mode"] = 1,
}

ResetConfigProfile = function()
    suspendSave = true
    if autoSaveThread then
        pcall(task.cancel, autoSaveThread)
        autoSaveThread = nil
    end

    local ok, err = pcall(function()
        -- 1. Reset all Toggles to registered default state
        for key, entry in pairs(UI_TOGGLES) do
            local def = entry.default
            if def == nil then
                def = DEFAULT_TOGGLES[key]
            end
            if def == nil then
                def = false
            end
            pcall(function()
                entry.set(def == true, true)
            end)
        end

        -- 2. Reset all Sliders to default value
        for key, entry in pairs(UI_SLIDERS) do
            local def = entry.default or DEFAULT_SLIDERS[key]
            if def ~= nil then
                pcall(function()
                    entry.set(def, true)
                end)
            end
        end

        -- 3. Reset all Choices to default index
        for key, entry in pairs(UI_CHOICES) do
            local def = entry.default or DEFAULT_CHOICES[key] or 1
            pcall(function()
                entry.set(def, true)
            end)
        end

        -- 4. Reset all Inputs to default
        for key, entry in pairs(UI_INPUTS) do
            local def = entry.default or ""
            pcall(function()
                entry.set(def)
            end)
        end

        -- 5. Reset Theme and Wallpaper
        pcall(function()
            if THEMES and THEMES["White"] then
                ApplyTheme("White")
            end
            if SetWallpaper then
                SetWallpaper(1)
            end
        end)

        -- 6. Reset modular subsystems to game defaults
        local moveMod = RequireModule("modules/mobility/movement_engine.lua")
        if moveMod and moveMod.ResetAll then pcall(moveMod.ResetAll) end

        local autoCombat = RequireModule("modules/pvp/auto_combat.lua")
        if autoCombat and autoCombat.ResetAll then pcall(autoCombat.ResetAll) end

        local camlockMod = RequireModule("modules/pvp/camlock.lua")
        if camlockMod and camlockMod.ResetAll then pcall(camlockMod.ResetAll) end

        local clientTweaks = nil
local function getClientTweaks()
    if not clientTweaks then
        clientTweaks = RequireModule("modules/misc/client_tweaks.lua")
    end
    return clientTweaks
end
task.spawn(function() pcall(getClientTweaks) end)
        if clientTweaks and clientTweaks.ResetAll then pcall(clientTweaks.ResetAll) end

        local ew = _G.DarlingX_ExtraWidgets
        if ew then
            pcall(function()
                ew.SetSuperJumpWidgetVisible(false)
                ew.SetCamlockWidgetVisible(false)
                ew.SetDragonM1WidgetVisible(false)
                ew.SetSanguineWidgetVisible(false)
            end)
        end

        local macroMod = RequireModule("modules/macro/macro_engine.lua")
        if macroMod then
            pcall(function()
                if macroMod.toggle then macroMod.toggle(false) end
                if macroMod.stopMacro then macroMod.stopMacro() end
                if macroMod.ensureMobileButton then macroMod.ensureMobileButton(false) end
            end)
        end

        if SetFPSPingVisible then
            pcall(SetFPSPingVisible, false)
        end

        _G.DarlingX_Fly = false
        _G.DarlingX_ShowFPS = false
        _G.DarlingX_IgnoreAllies = false
        _G.DarlingX_IgnorePvPOff = false
        _G.DarlingX_IgnoreSafeZone = false

        -- 7. Reset files on disk (write clean defaults to ALL config paths without deleting)
        local sOk, sErr = false, nil
        if SaveConfigProfile then
            sOk, sErr = SaveConfigProfile(true)
        end
        if not sOk then
            local fn = (type(writefile) == "function" and writefile) or getExecutorFunc("writefile") or getExecutorFunc("writeFile")
            if fn then
                for _, p in ipairs(CONFIG_PATHS) do
                    pcall(fn, p, "{}")
                end
            end
        end

        Notify("Config", "Configuration profile reset to defaults.", 2.5, true)
        print("[Monody] Configuration profile completely reset to defaults.")
        return true
    end)

    suspendSave = false
    return ok, err
end

-- ========================================================================
-- CLIENT TWEAKS & PERFORMANCE MODULE DELEGATION
-- ========================================================================
local clientTweaks = nil
local function getClientTweaks()
    if not clientTweaks then
        clientTweaks = RequireModule("modules/misc/client_tweaks.lua")
    end
    return clientTweaks
end
task.spawn(function() pcall(getClientTweaks) end)

local function SetFFlags1(state)
    local ct = getClientTweaks()
    if ct and ct.SetFFlags1 then
        ct.SetFFlags1(state)
    end
end

local function ApplyFastFFlags()
    if UI_TOGGLES["FFlags 1 (FPS Booster)"] then
        UI_TOGGLES["FFlags 1 (FPS Booster)"].set(true, true)
    else
        local ct = getClientTweaks()
        if ct and ct.ApplyFastFFlags then
            ct.ApplyFastFFlags()
        end
    end
end

local function SetNoAnimations(state)
    local ct = getClientTweaks()
    if ct and ct.SetNoAnimations then
        ct.SetNoAnimations(state)
    end
end

_G.DarlingX.UI_TOGGLES = UI_TOGGLES
_G.DarlingX.UI_SLIDERS = UI_SLIDERS
_G.DarlingX.UI_CHOICES = UI_CHOICES
_G.DarlingX.UI_INPUTS = UI_INPUTS
_G.DarlingX.SaveConfig = function(...) if SaveConfigProfile then return SaveConfigProfile(...) end end
_G.DarlingX.LoadConfig = function(...) if LoadConfigProfile then return LoadConfigProfile(...) end end
_G.DarlingX.ResetConfig = function(...) if ResetConfigProfile then return ResetConfigProfile(...) end end
_G.DarlingX.ApplyFastFFlags = ApplyFastFFlags
_G.DarlingX.SetFFlags1 = SetFFlags1
_G.DarlingX.SetNoAnimations = SetNoAnimations

local WallpaperListeners = {}
local function RegisterWallpaperListener(fn)
    table.insert(WallpaperListeners, fn)
end

-- Wallpaper Switcher: ONLY changes WallpaperImage, NEVER the LogoBadge or FloatingOpen!
local function SetWallpaper(index, button)
    currentBgIdx = ((index - 1) % #WALLPAPERS) + 1
    local selectedWallpaper = WALLPAPERS[currentBgIdx]
    if button then button.Text = "Background: " .. selectedWallpaper.name end

    for _, fn in ipairs(WallpaperListeners) do
        pcall(fn, currentBgIdx, selectedWallpaper)
    end
    if TriggerAutoSave then TriggerAutoSave() end

    if selectedWallpaper.id == "" or selectedWallpaper.name:find("None") then
        WallpaperImage.Image = ""
        WallpaperImage.ImageTransparency = 1
        Notify("Background", "Wallpaper removed (Clean Dark Glass)")
        return
    end

    -- Immediate visual switch to fallback/preset decal
    if selectedWallpaper.id and selectedWallpaper.id ~= "" then
        WallpaperImage.Image = selectedWallpaper.id
        WallpaperImage.ImageTransparency = 0
    end

    task.spawn(function()
        Notify("Background", "Loading: " .. selectedWallpaper.name)
        local asset = ResolveWallpaperAsset(selectedWallpaper)
        if asset and asset ~= "" then
            WallpaperImage.Image = asset
            WallpaperImage.ImageTransparency = 0
            pcall(function() ContentProvider:PreloadAsync({ WallpaperImage }) end)
            Notify("Background", "Applied: " .. selectedWallpaper.name)
        end
    end)
end

local function ApplyCustomWallpaper(input)
    if not input or type(input) ~= "string" then return end
    local clean = input:gsub("^%s+", ""):gsub("%s+$", "")
    if #clean == 0 or clean:lower() == "none" or clean:lower() == "clear" then
        WallpaperImage.Image = ""
        WallpaperImage.ImageTransparency = 1
        Notify("Wallpaper", "Wallpaper removed (Clean Glass Mode)")
        return
    end

    if clean:match("^%d+$") then
        local assetId = "rbxassetid://" .. clean
        WallpaperImage.Image = assetId
        WallpaperImage.ImageTransparency = 0
        pcall(function() ContentProvider:PreloadAsync({ WallpaperImage }) end)
        Notify("Wallpaper", "Applied Asset ID: " .. clean)
        return
    elseif clean:match("^rbxassetid://") then
        WallpaperImage.Image = clean
        WallpaperImage.ImageTransparency = 0
        pcall(function() ContentProvider:PreloadAsync({ WallpaperImage }) end)
        Notify("Wallpaper", "Applied Custom Asset")
        return
    elseif clean:match("^https?://") then
        task.spawn(function()
            Notify("Wallpaper", "Downloading custom media...")
            local body = SafeHttpGet(clean)
            if body and #body > 50 and exWriteFile and exGetCustomAsset then
                local ext = clean:match("%.(%w+)%??") or "png"
                local fileName = "custom_bg_" .. tostring(#clean) .. "." .. ext
                pcall(exWriteFile, fileName, body)
                local ok, asset = pcall(exGetCustomAsset, fileName)
                if ok and type(asset) == "string" and #asset > 0 then
                    WallpaperImage.Image = asset
                    WallpaperImage.ImageTransparency = 0
                    pcall(function() ContentProvider:PreloadAsync({ WallpaperImage }) end)
                    Notify("Wallpaper", "Custom wallpaper downloaded and applied")
                    return
                end
            end
            Notify("Wallpaper", "Could not load custom URL asset")
        end)
    else
        Notify("Wallpaper", "Invalid Asset ID or URL format")
    end
end

local function ResetUIConfig()
    ApplyFont("Gotham")
    SetWallpaper(1)
    UpdateMobileScale()
    if WallpaperDimOverlay then WallpaperDimOverlay.BackgroundTransparency = 0.35 end
    MaxRainDrops = 14
    RainEnabled = false
    RainbowSpeed = 0.4
    ResetTheme()
    for _, frame in ipairs(GlassFrames) do
        if frame and frame.Parent then frame.BackgroundTransparency = 0.65 end
    end
    for _, setToggle in ipairs(ToggleControls) do setToggle(true) end
end

-- ============================================================
-- GLOBAL MODULE GETTERS & UI SYNCHRONIZATION
-- ============================================================
local M = { cache = {} }
function M.get(path)
    if not M.cache[path] then M.cache[path] = RequireModule(path) end
    return M.cache[path]
end
function M.getFastAttack() return M.get("modules/pvp/fast_attack.lua") end
function M.getDragonGun() return M.get("modules/pvp/dragon_gun_m1.lua") end
function M.getSanguineBoost() return M.get("modules/pvp/sanguine_boost.lua") end
function M.getExtraWidgets() return M.get("modules/pvp/extra_widgets.lua") end
function M.getAutoCombat() return M.get("modules/pvp/auto_combat.lua") end
function M.getCamlock() return M.get("modules/pvp/camlock.lua") end
function M.getMoveMod() return M.get("modules/mobility/movement_engine.lua") end
function M.getAutoBounty() return M.get("modules/combat/auto_bounty.lua") end

_G.DarlingX_SyncCamlockUI = function(active)
    if UI_TOGGLES and UI_TOGGLES["Camlock"] and UI_TOGGLES["Camlock"].set then
        pcall(function()
            UI_TOGGLES["Camlock"].set(active == true, false)
        end)
    end
end

-- ============================================================
-- MODULAR TAB REGISTRATION
-- ============================================================

-- ============================================================
-- AUTO BOUNTY TAB (DARLING HUB COMBAT ENGINE)
-- ============================================================
do
    pcall(function()
        local BountyPage = RegisterTab("AutoBounty", "AutoBounty", "skull")

        -- SECTION 1: CORE AUTO BOUNTY CONTROL
        local bCard1 = CreateCard(BountyPage, "Auto Bounty Engine")

        local statusPara = Instance.new("TextLabel", bCard1)
        statusPara.Size = UDim2.new(1, 0, 0, 20)
        statusPara.BackgroundTransparency = 1
        statusPara.Font = Enum.Font.GothamBold
        statusPara.TextSize = 9.5
        statusPara.TextColor3 = CurrentAccent
        statusPara.TextXAlignment = Enum.TextXAlignment.Left
        statusPara.Text = "Status: Idle | Targets: Monitoring"
        statusPara.LayoutOrder = 1
        RegisterThemeText(statusPara)
        task.spawn(function()
            local lastText = ""
            while true do
                task.wait(1.0)
                pcall(function()
                    local mod = M.cache["modules/combat/auto_bounty.lua"]
                    if mod and mod.Enabled then
                        local st = tostring(mod.Status or "Idle")
                        local tgt = mod.CurrentTarget
                        local tgtName = tgt and tgt.Name or "None"
                        local newText = "Status: " .. st .. " | Target: " .. tgtName
                        if newText ~= lastText then
                            lastText = newText
                            statusPara.Text = newText
                        end
                    end
                end)
            end
        end)

        AddToggle(bCard1, "Hunt Auto", "Autonomous target scanning, tween flight pathing, and skill bursts", false, function(v)
            local mod = M.getAutoBounty()
            if mod and mod.toggle then
                mod.toggle(v)
            end
            Notify("Auto Bounty", "Hunt Auto: " .. (v and "Enabled" or "Disabled"))
        end)

        AddToggle(bCard1, "Fast Hop Mode", "Ultra-fast server hopping with streamlined combat engine", false, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.AutoBountyMode = v end
            _G.DarlingFastBountyMode = v
            Notify("Auto Bounty", "Fast Hop Mode: " .. (v and "Enabled" or "Disabled"))
        end)

        AddChoice(bCard1, "Auto Join Team", {"Pirates", "Marines"}, 1, function(v)
            local mod = M.getAutoBounty()
            if mod then
                mod.AutoTeam = v
                if mod.joinTeam then mod.joinTeam(v) end
            end
        end)

        AddButton(bCard1, "Skip Current Target", function()
            local mod = M.getAutoBounty()
            if mod and mod.skipCurrentTarget then
                mod.skipCurrentTarget()
                Notify("Auto Bounty", "Skipping current target...")
            end
        end)

        -- SECTION 2: FLIGHT & TWEEN SPEEDS
        local bCard2 = CreateCard(BountyPage, "Movement & Tween Settings")
        AddSlider(bCard2, "Near Tween Speed (<=1000 studs)", 100, 500, 310, 10, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.NearTweenSpeed = v end
        end)
        AddSlider(bCard2, "Far Tween Speed (>1000 studs)", 100, 500, 200, 10, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.FarTweenSpeed = v end
        end)
        AddSlider(bCard2, "Combat Distance", 5, 40, 15, 1, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.StopDistance = v end
        end)
        AddToggle(bCard2, "Auto Soru", "Instantly Soru behind target during combat", false, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.AutoSoru = v end
        end)

        -- SECTION 3: COMBAT & WEAPON EXECUTION
        local bCard3 = CreateCard(BountyPage, "Combat & Skill Rotations")
        AddToggle(bCard3, "Auto Attack (FastAttack M1)", "Rapid automated weapon attacks", false, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.AutoAttack = v; mod.FastAttack = v end
        end)
        AddChoice(bCard3, "Fast Attack Speed", {"Slow (0.15s)", "Medium (0.10s)", "Fast (0.05s)", "Ultra (0.02s)"}, 2, function(v)
            local mod = M.getAutoBounty()
            if mod and mod.setAttackSpeed then mod.setAttackSpeed(v) end
        end)
        AddToggle(bCard3, "Auto Skills Rotation", "Casts equipped weapon and fruit special abilities", false, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.AutoSkills = v end
        end)
        AddToggle(bCard3, "Use Melee Weapons", "Allows fighting style attacks in rotation", false, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.UseMelee = v end
        end)
        AddToggle(bCard3, "Use Sword Weapons", "Allows sword attacks in rotation", false, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.UseSword = v end
        end)
        AddToggle(bCard3, "Use Fruit Skills", "Allows fruit attacks in rotation", false, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.UseFruit = v end
        end)
        AddToggle(bCard3, "Use Gun Weapons", "Allows gun attacks in rotation", false, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.UseGun = v end
        end)
        AddToggle(bCard3, "Auto Buso Haki", "Maintains active Armament Haki", false, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.AutoBuso = v end
        end)
        AddToggle(bCard3, "Auto Observation Haki (Ken)", "Maintains active Observation Haki", false, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.AutoKen = v end
        end)
        AddToggle(bCard3, "Auto Race V4", "Awakens Race V4 whenever gauge is full", false, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.AutoV4 = v end
        end)

        -- SECTION 4: SURVIVABILITY & SERVER HOP
        local bCard4 = CreateCard(BountyPage, "Survivability & Server Hop")
        AddToggle(bCard4, "Auto Flee Low HP", "Safely flees to high sky when health is critical", false, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.FleeLowHealth = v end
        end)
        AddSlider(bCard4, "Flee Health Threshold (%)", 10, 50, 25, 5, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.FleeThreshold = v end
        end)
        AddToggle(bCard4, "Skip SafeZone Players", "Ignores players protected by safezones", false, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.NoSafeZone = v end
        end)
        AddToggle(bCard4, "Ignore Marine Allies", "Do not attack allied players on same faction", false, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.NoMarineAlly = v end
        end)
        AddToggle(bCard4, "Auto Server Hop", "Hops to another server when no targets remain", false, function(v)
            local mod = M.getAutoBounty()
            if mod then mod.AutoHop = v end
        end)
        AddButton(bCard4, "Server Hop Now", function()
            local mod = M.getAutoBounty()
            if mod and mod.hopServer then
                mod.hopServer()
            end
        end)
    end)
end

-- ============================================================
-- CONTROL PEOPLE TAB (CLEAN EMPTY AS REQUESTED)
-- ============================================================
do
    pcall(function()
        local ControlPage = RegisterTab("ControlPeople", "Control People", "gamepad-2")
    end)
end

-- ============================================================
-- STEAL FRUITS TAB (CLEAN EMPTY AS REQUESTED)
-- ============================================================
do
    pcall(function()
        local FruitPage = RegisterTab("StealFruits", "Steal Fruits", "apple")
    end)
end

local HomePage = RegisterTab("Home", "Home", "house")
pcall(function()
    HomePage.CanvasSize = UDim2.new(0, 0, 0, 226)
    HomePage.ScrollBarThickness = 2
    HomePage.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    HomePage.ScrollBarImageTransparency = 0.7

    local pList = HomePage:FindFirstChildOfClass("UIListLayout")
    if pList then
        pList.Padding = UDim.new(0, 8)
        pList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    end

    local function createWhiteCard(name, height, layoutOrder, bgFilename, fallbackId)
        local frame = Instance.new("Frame", HomePage)
        frame.Name = name
        frame.Size = UDim2.new(1, -6, 0, height)
        frame.LayoutOrder = layoutOrder
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        frame.BackgroundTransparency = 0.12
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

        local cStroke = Instance.new("UIStroke", frame)
        cStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        cStroke.Color = Color3.fromRGB(255, 255, 255)
        cStroke.Thickness = 0.8
        cStroke.Transparency = 0.88
        RegisterThemeStroke(cStroke)

        local bg = Instance.new("ImageLabel", frame)
        bg.Name = "Bg"
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundTransparency = 1
        bg.BorderSizePixel = 0
        bg.ScaleType = Enum.ScaleType.Stretch
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)
        ResolveAndBindAsset(bgFilename, fallbackId, bg)

        return frame, bg
    end

    ----------------------------------------------------------------------------
    -- 1. CARD 1: TOP PROFILE & BRAND CARD (header_profile_panel_white.png, 96h)
    ----------------------------------------------------------------------------
    local card1, bg1 = createWhiteCard("TopBrandCard", 96, 1, "header_profile_panel_white.png", "rbxassetid://109687263098821")

    -- Discord Hitbox Button
    local discordHitbox = Instance.new("TextButton", card1)
    discordHitbox.Name = "DiscordHitbox"
    discordHitbox.Size = UDim2.new(0, 22, 0, 22)
    discordHitbox.Position = UDim2.new(0, 14, 0, 70)
    discordHitbox.BackgroundTransparency = 1
    discordHitbox.Text = ""
    discordHitbox.Active = true
    discordHitbox.ZIndex = 12

    ConnectButton(discordHitbox, function()
        pcall(function()
            if setclipboard then
                setclipboard("https://discord.gg/besthub")
            elseif toclipboard then
                toclipboard("https://discord.gg/besthub")
            end
        end)
        Notify("Monody", "Discord link copied to clipboard!", 2.0)
    end)

    -- TikTok Hitbox Button
    local tiktokHitbox = Instance.new("TextButton", card1)
    tiktokHitbox.Name = "TikTokHitbox"
    tiktokHitbox.Size = UDim2.new(0, 22, 0, 22)
    tiktokHitbox.Position = UDim2.new(0, 38, 0, 70)
    tiktokHitbox.BackgroundTransparency = 1
    tiktokHitbox.Text = ""
    tiktokHitbox.Active = true
    tiktokHitbox.ZIndex = 12

    ConnectButton(tiktokHitbox, function()
        pcall(function()
            if setclipboard then
                setclipboard("https://www.tiktok.com/@besthub")
            elseif toclipboard then
                toclipboard("https://www.tiktok.com/@besthub")
            end
        end)
        Notify("Monody", "TikTok link copied to clipboard!", 2.0)
    end)

    -- Key Time Display Label
    local keyTimeLbl = Instance.new("TextLabel", card1)
    keyTimeLbl.Name = "KeyTimeLabel"
    keyTimeLbl.Size = UDim2.new(0, 140, 0, 16)
    keyTimeLbl.Position = UDim2.new(1, -145, 0, 73)
    keyTimeLbl.BackgroundTransparency = 1
    keyTimeLbl.Font = Enum.Font.GothamMedium
    keyTimeLbl.TextSize = 8.5
    keyTimeLbl.TextColor3 = Color3.fromRGB(250, 250, 255)
    keyTimeLbl.TextXAlignment = Enum.TextXAlignment.Right
    keyTimeLbl.ZIndex = 12

    local function updateKeyTime()
        local remaining = "Key: Verified"
        pcall(function()
            local genv = (type(getgenv) == "function" and getgenv()) or _G or {}
            local exp = genv.AX_KeyExpires or (genv.AX_USER and genv.AX_USER.ExpiresAt) or _G.AX_KeyExpires or (_G.AX_USER and _G.AX_USER.ExpiresAt) or (AX_KeyExpires)
            if exp ~= nil then
                local expNum = tonumber(exp)
                if expNum == 0 then
                    remaining = "Key: Lifetime Access"
                elseif expNum and expNum > 0 then
                    local diff = expNum - os.time()
                    if diff > 86400 * 365 then
                        remaining = "Key: Lifetime Access"
                    elseif diff > 86400 then
                        local days = math.floor(diff / 86400)
                        local hrs = math.floor((diff % 86400) / 3600)
                        local mins = math.floor((diff % 3600) / 60)
                        remaining = string.format("Key: %dd %dh %dm Left", days, hrs, mins)
                    elseif diff > 3600 then
                        local hrs = math.floor(diff / 3600)
                        local mins = math.floor((diff % 3600) / 60)
                        local secs = math.floor(diff % 60)
                        remaining = string.format("Key: %dh %dm %ds Left", hrs, mins, secs)
                    elseif diff > 0 then
                        local mins = math.floor(diff / 60)
                        local secs = math.floor(diff % 60)
                        remaining = string.format("Key: %dm %ds Left", mins, secs)
                    else
                        remaining = "Key: Expired"
                    end
                end
            end
        end)
        keyTimeLbl.Text = remaining
    end
    updateKeyTime()

    ----------------------------------------------------------------------------
    -- 2. CARD 2: REAL LIVE STATS CARD (stats_panel_white.png, 116h)
    ----------------------------------------------------------------------------
    local card2, bg2 = createWhiteCard("CenterStatsCard", 116, 2, "stats_panel_white.png", "rbxassetid://109687263098821")

    local function createStatRow(name, initialText, yPos, xPos, width)
        local lbl = Instance.new("TextLabel", card2)
        lbl.Name = name
        lbl.Size = UDim2.new(0, width, 0, 16)
        lbl.Position = UDim2.new(0, xPos, 0, yPos)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.Text = initialText
        lbl.TextSize = 8.5
        lbl.TextColor3 = Color3.fromRGB(245, 245, 250)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.ZIndex = 12
        return lbl
    end

    -- Left 4 stats (Player, Game, Bounty, Level) aligned to icons at x=50
    local statPlayer = createStatRow("StatPlayer", "- " .. (lp and lp.DisplayName or "Player"), 18, 50, 75)
    local statGame   = createStatRow("StatGame", "- Blox Fruits", 42, 50, 75)
    local statBounty = createStatRow("StatBounty", "- Bounty 4M", 66, 50, 75)
    local statLevel  = createStatRow("StatLevel", "- Level 2800", 90, 50, 75)

    -- Right 4 stats (Session, Ping, FPS, Server Clock) aligned to icons at x=246
    local statSession = createStatRow("StatSession", "- 0:00", 18, 246, 58)
    local statPing    = createStatRow("StatPing", "- 50ms", 42, 246, 58)
    local statFps     = createStatRow("StatFps", "- 60Fps", 66, 246, 58)
    local statClock   = createStatRow("StatClock", "- 00:00", 90, 246, 58)

    -- Real-time stats updater (throttled to 0.4s)
    local scriptStart = tick()
    local lastStatUpdate = 0
    local smoothedFps = 60
    local lastFrameTick = tick()

    RunService.Heartbeat:Connect(function()
        local now = tick()
        local dt = now - lastFrameTick
        lastFrameTick = now
        if dt > 0 then
            smoothedFps = math.floor(smoothedFps * 0.9 + (1 / dt) * 0.1)
        end

        if now - lastStatUpdate < 0.4 then return end
        lastStatUpdate = now

        -- Update Key Time live countdown
        updateKeyTime()

        -- Session stopwatch
        local elapsed = math.floor(now - scriptStart)
        local mins = math.floor(elapsed / 60)
        local secs = elapsed % 60
        statSession.Text = string.format("- %d:%02d", mins, secs)

        -- Ping
        local ping = 50
        pcall(function()
            local s = Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerStatsItem")
            local item = s and s:FindFirstChild("Data Ping")
            if item then ping = math.floor(item:GetValue()) end
        end)
        if ping == 0 and lp then
            pcall(function() ping = math.floor(lp:GetNetworkPing() * 1000) end)
        end
        statPing.Text = string.format("- %dms", ping)

        -- FPS
        statFps.Text = string.format("- %dFps", math.clamp(smoothedFps, 15, 240))

        -- Clock
        statClock.Text = "- " .. os.date("%H:%M")

        -- Live Bounty & Level
        pcall(function()
            if lp then
                local ls = lp:FindFirstChild("leaderstats")
                if ls then
                    local b = ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Bounty") or ls:FindFirstChild("Honor")
                    if b then
                        local v = tonumber(b.Value) or 0
                        if v >= 1000000 then
                            statBounty.Text = string.format("- Bounty %.1fM", v / 1000000)
                        elseif v >= 1000 then
                            statBounty.Text = string.format("- Bounty %.1fK", v / 1000)
                        else
                            statBounty.Text = "- Bounty " .. tostring(v)
                        end
                    end
                end
                local data = lp:FindFirstChild("Data")
                if data and data:FindFirstChild("Level") then
                    statLevel.Text = "- Level " .. tostring(data.Level.Value)
                end
            end
        end)
    end)
end)

-- 2. AIMBOT TAB (MODULAR COMBAT ENGINE)
local AimbotPage = RegisterTab("Aimbot", "Aimbot", "crosshair")
local okAimbot, errAimbot = pcall(function()
    local function isPlayerAlly(player)
        if not player or player == lp then return false end
        local ok, ally = pcall(function()
            local main = lp and lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main")
            local frame = main and main:FindFirstChild("Allies")
                and main.Allies:FindFirstChild("Container")
                and main.Allies.Container:FindFirstChild("Allies")
                and main.Allies.Container.Allies:FindFirstChild("ScrollingFrame")
                and main.Allies.Container.Allies.ScrollingFrame:FindFirstChild("Frame")
            if frame and frame:FindFirstChild(player.Name) then return true end

            local myTeam = lp and lp.Team
            local targetTeam = player.Team
            if myTeam and targetTeam and myTeam == targetTeam then return true end
            if myTeam and targetTeam and myTeam.Name == "Marines" and targetTeam.Name == "Marines" then return true end
            return false
        end)
        return ok and ally
    end

    local function isPlayerPvPEnabled(player)
        if not player or player == lp then return false end
        local ok, enabled = pcall(function()
            if player:GetAttribute("PvpDisabled") == true then return false end
            local char = player.Character
            if char then
                if char:FindFirstChildOfClass("ForceField") then return false end
                if char:GetAttribute("PvpDisabled") == true then return false end
            end
            return true
        end)
        return not ok or enabled
    end

    local function isPlayerInSafeZone(player)
        if not player or player == lp then return false end
        local ok, inZone = pcall(function()
            local char = player.Character
            if not char then return false end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Sit == true then return true end
            if char:FindFirstChildOfClass("ForceField") then return true end
            if char:GetAttribute("SafeZone") == true then return true end
            if player:GetAttribute("SafeZone") == true then return true end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return false end
            local hrpPos = hrp.Position

            local function checkFolder(folder)
                if not folder then return false end
                for _, zone in ipairs(folder:GetChildren()) do
                    if zone:IsA("BasePart") then
                        local mesh = zone:FindFirstChild("Mesh")
                        local radius = 0
                        if mesh and mesh:IsA("SpecialMesh") then
                            radius = (zone.Size.X * mesh.Scale.X) / 2
                        else
                            radius = math.min(zone.Size.X, zone.Size.Z) / 2
                        end
                        if radius > 500 then radius = 350 end
                        if radius <= 0 then radius = 350 end
                        if (zone.Position - hrpPos).Magnitude <= radius then return true end

                        local localPos = zone.CFrame:PointToObjectSpace(hrpPos)
                        local halfSize = zone.Size / 2
                        if math.abs(localPos.X) <= halfSize.X and math.abs(localPos.Y) <= halfSize.Y + 25 and math.abs(localPos.Z) <= halfSize.Z then
                            return true
                        end
                    end
                end
                return false
            end

            local wo = Workspace:FindFirstChild("_WorldOrigin")
            if wo and checkFolder(wo:FindFirstChild("SafeZones")) then return true end
            if wo and checkFolder(wo:FindFirstChild("TempSafeZones")) then return true end
            if checkFolder(Workspace:FindFirstChild("SafeZones")) then return true end
            local map = Workspace:FindFirstChild("Map")
            if map and checkFolder(map:FindFirstChild("SafeZones")) then return true end
            return false
        end)
        return ok and inZone
    end

    local function hookAimbotTargetFilter()
        pcall(function()
            local core = RequireModule("modules/combat/aimbot_core.lua")
            if core and not core._DarlingFilterHooked then
                core._DarlingFilterHooked = true
                local origBlacklisted = core.isPlayerBlacklisted
                core.isPlayerBlacklisted = function(player)
                    if not player then return false end
                    if origBlacklisted and origBlacklisted(player) then return true end

                    if _G.DarlingX_IgnoreAllies and isPlayerAlly(player) then
                        return true
                    end
                    if _G.DarlingX_IgnorePvPOff and not isPlayerPvPEnabled(player) then
                        return true
                    end
                    if _G.DarlingX_IgnoreSafeZone and isPlayerInSafeZone(player) then
                        return true
                    end
                    return false
                end
            end
        end)
    end
    task.spawn(hookAimbotTargetFilter)

    -- 1. Silent Aim & Combat Lock System (Top Card for Direct Access)
    local aimCard = CreateCard(AimbotPage, "Silent Aim")

    AddToggle(aimCard, "Player Silent Aim", "Redirect skills toward enemy players", false, function(state)
        local mod = RequireModule("modules/combat/player_aimbot.lua")
        if mod then
            if state then mod.enable() else mod.disable() end
        end
        Notify("Aimbot", "Player Silent Aim: " .. (state and "Enabled" or "Disabled"))
    end)

    AddToggle(aimCard, "NPC Silent Aim", "Redirect skills toward mobs and bosses", false, function(state)
        local mod = RequireModule("modules/combat/npc_aimbot.lua")
        if mod then
            if state then mod.enable() else mod.disable() end
        end
        Notify("Aimbot", "NPC Silent Aim: " .. (state and "Enabled" or "Disabled"))
    end)

    AddToggle(aimCard, "Show FOV Circle", "Display aim boundary circle", false, function(state)
        local fovMod = RequireModule("modules/combat/fov.lua")
        if fovMod then
            if state then fovMod.enable() else fovMod.disable() end
        end
        Notify("FOV", "FOV Circle: " .. (state and "Visible" or "Hidden"))
    end)

    AddToggle(aimCard, "Ignore Allies", "Do not target allied players", false, function(state)
        _G.DarlingX_IgnoreAllies = state
        hookAimbotTargetFilter()
        Notify("Aimbot", "Ignore Allies: " .. (state and "Enabled" or "Disabled"))
    end)

    AddToggle(aimCard, "Ignore PvP Off", "Do not target players with PvP disabled", false, function(state)
        _G.DarlingX_IgnorePvPOff = state
        hookAimbotTargetFilter()
        Notify("Aimbot", "Ignore PvP Off: " .. (state and "Enabled" or "Disabled"))
    end)

    AddToggle(aimCard, "Ignore Safe Zone", "Do not target players inside safe zones", false, function(state)
        _G.DarlingX_IgnoreSafeZone = state
        hookAimbotTargetFilter()
        Notify("Aimbot", "Ignore Safe Zone: " .. (state and "Enabled" or "Disabled"))
    end)



    AddChoice(aimCard, "Target Priority", { "Nearest", "Low HP", "Looking At Me" }, 1, function(val)
        local core = RequireModule("modules/combat/aimbot_core.lua")
        if core then core.TargetPriority = val end
        _G.DarlingX.Settings.Aim.Priority = val
    end)

    AddChoice(aimCard, "Aim Mode", { "360", "FOV", "180" }, 1, function(val)
        local core = RequireModule("modules/combat/aimbot_core.lua")
        if core then core.AimMode = val end
        _G.DarlingX.Settings.Aim.Mode = val
        local fovMod = RequireModule("modules/combat/fov.lua")
        if fovMod and fovMod.setAimMode then
            fovMod.setAimMode(val)
        end
    end)

    AddChoice(aimCard, "Target Hitbox", { "HumanoidRootPart", "Head", "UpperTorso" }, 1, function(val)
        local core = RequireModule("modules/combat/aimbot_core.lua")
        if core then
            core.TargetHitbox = val
            core.TargetPart = val
        end
        _G.DarlingX.Settings.Aim.TargetPart = val
    end)

    AddSlider(aimCard, "Max Range", 100, 3000, 1000, 50, function(val)
        local core = RequireModule("modules/combat/aimbot_core.lua")
        if core then core.MaxRange = val end
        _G.DarlingX.Settings.Aim.MaxRange = val
    end)

    AddToggle(aimCard, "Enable Target Prediction", "Calculates lead vector based on enemy velocity and ping", false, function(state)
        local core = RequireModule("modules/combat/aimbot_core.lua")
        if core then core.PredictionEnabled = state end
        _G.DarlingX.Settings.Aim.Prediction = state
    end)

    AddSlider(aimCard, "Prediction Amount", 5, 30, 12, 1, function(val)
        local core = RequireModule("modules/combat/aimbot_core.lua")
        local factor = val / 100
        if core then core.PredictionAmount = factor end
        _G.DarlingX.Settings.Aim.PredictionAmount = factor
    end)

    -- 2. FOV Circle Customization Card
    local fovCard = CreateCard(AimbotPage, "Field of View")

    AddSlider(fovCard, "FOV Radius", 20, 600, 100, 5, function(val)
        local fovMod = RequireModule("modules/combat/fov.lua")
        if fovMod and fovMod.setRadius then fovMod.setRadius(val) end
        local core = RequireModule("modules/combat/aimbot_core.lua")
        if core and core.setFOVRadius then core.setFOVRadius(val) end
        _G.DarlingX.Settings.FOV.Radius = val
    end)

    AddChoice(fovCard, "FOV Position", { "Center", "Mouse" }, 1, function(val)
        local fovMod = RequireModule("modules/combat/fov.lua")
        if fovMod and fovMod.setMode then fovMod.setMode(val) end
        _G.DarlingX.Settings.FOV.Mode = val
    end)

    AddChoice(fovCard, "FOV Color", { "Rainbow", "Purple", "Blue", "Pink", "Green", "Yellow", "Orange", "Red", "Cyan", "White" }, 1, function(val)
        local fovMod = RequireModule("modules/combat/fov.lua")
        if fovMod then
            if val == "Rainbow" then
                if fovMod.setRainbow then fovMod.setRainbow(true) end
            else
                if fovMod.setRainbow then fovMod.setRainbow(false) end
                local col = THEMES[val] or Color3.fromRGB(255, 255, 255)
                if fovMod.setColor then fovMod.setColor(col) end
            end
        end
    end)

    AddSlider(fovCard, "FOV Thickness", 1, 8, 2, 1, function(val)
        local fovMod = RequireModule("modules/combat/fov.lua")
        if fovMod and fovMod.setThickness then fovMod.setThickness(val) end
    end)

    -- 3. Tracers Card (Hardware 3D Beams & 2D Lines)
    local tracersCard = CreateCard(AimbotPage, "Tracers")

    AddToggle(tracersCard, "Show Tracers", "Renders hardware 3D Beams and 2D lines to target", false, function(state)
        local mod = RequireModule("modules/combat/tracers.lua")
        if mod then
            if state then mod.enable() else mod.disable() end
        end
        Notify("Tracers", "Tracers: " .. (state and "Enabled" or "Disabled"))
    end)

    AddChoice(tracersCard, "Tracer Mode", { "Both", "3D Beam", "2D Line" }, 1, function(val)
        local mod = RequireModule("modules/combat/tracers.lua")
        if mod and mod.setType then mod.setType(val) end
        _G.DarlingX.Settings.Tracers.Type = val
    end)

    AddChoice(tracersCard, "Tracer Origin", { "Player", "Bottom", "Center", "Mouse" }, 1, function(val)
        local mod = RequireModule("modules/combat/tracers.lua")
        if mod and mod.setOrigin then mod.setOrigin(val) end
        _G.DarlingX.Settings.Tracers.Origin = val
    end)

    AddChoice(tracersCard, "Tracer Color", { "Rainbow", "Purple", "Blue", "Pink", "Green", "Yellow", "Orange", "Red", "Cyan", "White" }, 1, function(val)
        local mod = RequireModule("modules/combat/tracers.lua")
        if mod then
            if val == "Rainbow" then
                if mod.setRainbow then mod.setRainbow(true) end
            else
                if mod.setRainbow then mod.setRainbow(false) end
                local col = THEMES[val] or Color3.fromRGB(255, 255, 255)
                if mod.setColor then mod.setColor(col) end
            end
        end
    end)

    AddSlider(tracersCard, "Tracer Thickness", 1, 6, 2, 1, function(val)
        local mod = RequireModule("modules/combat/tracers.lua")
        if mod and mod.setThickness then mod.setThickness(val) end
    end)

    -- 4. Skill Blacklist Card
    local blCard = CreateCard(AimbotPage, "Skill Blacklist")
    local blSkills = {
        { name = "Melee Z", cat = "Melee", key = "Z" },
        { name = "Melee X", cat = "Melee", key = "X" },
        { name = "Melee C", cat = "Melee", key = "C" },
        { name = "Sword Z", cat = "Sword", key = "Z" },
        { name = "Sword X", cat = "Sword", key = "X" },
        { name = "Fruit Z", cat = "Fruit", key = "Z" },
        { name = "Fruit X", cat = "Fruit", key = "X" },
        { name = "Fruit C", cat = "Fruit", key = "C" },
        { name = "Fruit V", cat = "Fruit", key = "V" },
        { name = "Fruit F", cat = "Fruit", key = "F" },
        { name = "Fruit TAP", cat = "Fruit", key = "TAP" },
        { name = "Gun Z", cat = "Gun", key = "Z" },
        { name = "Gun X", cat = "Gun", key = "X" },
    }

    local blGrid = Instance.new("Frame", blCard)
    blGrid.Name = "BlacklistGrid"
    blGrid.Size = UDim2.new(1, 0, 0, 225)
    blGrid.BackgroundTransparency = 1
    blGrid.ZIndex = 11
    local blLayout = Instance.new("UIGridLayout", blGrid)
    blLayout.CellSize = UDim2.new(0.5, -4, 0, 26)
    blLayout.CellPadding = UDim2.new(0, 8, 0, 5)
    blLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        blGrid.Size = UDim2.new(1, 0, 0, math.max(blLayout.AbsoluteContentSize.Y, 225))
        UpdateCardGeometry(blCard)
    end)

    for _, s in ipairs(blSkills) do
        local isBlacklisted = false
        local bBtn = Instance.new("TextButton", blGrid)
        bBtn.Name = "BL_" .. s.name:gsub("%s+", "_")
        bBtn.BackgroundColor3 = Color3.fromRGB(22, 18, 30)
        bBtn.BackgroundTransparency = 0.5
        bBtn.Text = ""
        bBtn.AutoButtonColor = false
        bBtn.Active = true
        bBtn.Selectable = true
        bBtn.ZIndex = 12
        Instance.new("UICorner", bBtn).CornerRadius = UDim.new(0, 6)
        local stroke = Instance.new("UIStroke", bBtn)
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Thickness = 0.8
        stroke.Color = Color3.fromRGB(55, 50, 75)

        local bLbl = Instance.new("TextLabel", bBtn)
        bLbl.Size = UDim2.new(1, 0, 1, 0)
        bLbl.BackgroundTransparency = 1
        bLbl.Font = Enum.Font.GothamBold
        bLbl.TextSize = 8
        bLbl.TextColor3 = Color3.fromRGB(200, 195, 215)
        bLbl.Text = s.name .. ": ALLOWED"
        bLbl.ZIndex = 13

        ConnectButton(bBtn, function()
            isBlacklisted = not isBlacklisted
            bLbl.Text = s.name .. ": " .. (isBlacklisted and "EXCLUDED" or "ALLOWED")
            bLbl.TextColor3 = isBlacklisted and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(200, 195, 215)
            stroke.Color = isBlacklisted and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(55, 50, 75)

            local blMod = RequireModule("modules/combat/blacklist.lua")
            if blMod then
                if isBlacklisted then
                    blMod.add(s.cat, s.key)
                else
                    blMod.remove(s.cat, s.key)
                end
            end
        end)
    end
    UpdateCardGeometry(blCard)
end)
if not okAimbot then
    warn("[Monody] Failed to initialize AimbotPage: " .. tostring(errAimbot))
end

-- 3. PVP COMBAT & MOVEMENT TAB
local PvPPage = RegisterTab("PvP", "PvP", "swords")
local okPvP, errPvP = pcall(function()
    -- 1. Combat Passives & Auto Skills
    local combatCard = CreateCard(PvPPage, "Auto Combat")

    AddToggle(combatCard, "Fast Attack", "Rapid melee and weapon strikes", false, function(state)
        _G.DarlingX_FastAttack = state
        local fa = M.getFastAttack(); if fa then
            if state then fa.enable() else fa.disable() end
        end
        Notify("PvP", "Fast Attack: " .. (state and "Enabled" or "Disabled"))
    end)

    AddToggle(combatCard, "Auto Buso Haki", "Keep Armament Haki active", false, function(state)
        local ac = M.getAutoCombat(); if ac then ac.SetAutoBuso(state) end
        Notify("PvP", "Auto Buso: " .. (state and "Enabled" or "Disabled"))
    end)

    AddToggle(combatCard, "Auto Race V3", "Cast Race V3 when in combat", false, function(state)
        local ac = M.getAutoCombat(); if ac then ac.SetAutoV3(state) end
        Notify("PvP", "Auto V3: " .. (state and "Enabled" or "Disabled"))
    end)

    AddToggle(combatCard, "Auto Race V4", "Cast Race V4 when gauge is full", false, function(state)
        local ac = M.getAutoCombat(); if ac then ac.SetAutoV4(state) end
        Notify("PvP", "Auto V4: " .. (state and "Enabled" or "Disabled"))
    end)

    AddToggle(combatCard, "Dragon Gun M1", "Rapid fire M1 gun shots", false, function(state)
        _G.DarlingX_DragonM1Enabled = state
        local dg = M.getDragonGun(); if dg then dg.SetEnabled(state) end
        local ew = M.getExtraWidgets(); if ew then ew.SetDragonM1WidgetVisible(state); ew.UpdateDragonM1Visual(state) end
        Notify("PvP", "Dragon Gun M1: " .. (state and "Enabled" or "Disabled"))
    end)

    -- 2. PvP Tech, Camlock & Universal Keybinds
    local techCard = CreateCard(PvPPage, "Combat Tech")

    AddToggle(techCard, "Camlock", "Lock camera onto enemy", false, function(state)
        local cl = M.getCamlock(); if cl then cl.SetEnabled(state) end
    end)

    AddToggle(techCard, "Sanguine Boost", "Forward velocity boost", false, function(state)
        _G.DarlingX_SanguineBoost = state
        local sb = M.getSanguineBoost(); if sb then sb.SetEnabled(state) end
        local ew = M.getExtraWidgets(); if ew then ew.SetSanguineWidgetVisible(state) end
        Notify("PvP", "Sanguine Boost: " .. (state and "Active" or "Inactive"))
    end)

    local sanguineKey = "None"
    AddChoice(techCard, "Camlock Keybind", { "C", "Q", "E", "R", "T", "X", "V", "B", "None" }, 1, function(val)
        local cl = M.getCamlock(); if cl then cl.SetKeybind(val) end
    end)

    AddChoice(techCard, "Sanguine Keybind", { "None", "Z", "Q", "E", "R", "T", "X", "C", "V", "B" }, 1, function(val)
        sanguineKey = val
    end)

    AddSlider(techCard, "Camera FOV", 70, 120, 70, 5, function(val)
        local cl = M.getCamlock(); if cl then cl.SetCameraFOV(val) end
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local key = input.KeyCode.Name
        if sanguineKey ~= "None" and key == sanguineKey then
            local sb = M.getSanguineBoost(); if sb then sb.Trigger() end
        end
    end)

    -- 3. Movement & Agility (PvP Physics)
    local moveCard = CreateCard(PvPPage, "Movement")

    AddToggle(moveCard, "Custom WalkSpeed", "Speed up player movement", false, function(state)
        local mm = M.getMoveMod(); if mm then mm.SetWalkSpeed(state) end
        Notify("PvP", "WalkSpeed: " .. (state and "Enabled" or "Disabled"))
    end)

    AddSlider(moveCard, "WalkSpeed Value", 16, 500, 150, 5, function(val)
        local mm = M.getMoveMod(); if mm then mm.SetWalkSpeedValue(val) end
    end)

    AddToggle(moveCard, "Custom Dash Length", "Increase dash distance", false, function(state)
        local mm = M.getMoveMod(); if mm then mm.SetDashLength(state) end
        Notify("PvP", "Dash Length: " .. (state and "Enabled" or "Disabled"))
    end)

    AddSlider(moveCard, "Dash Distance", 15, 150, 30, 5, function(val)
        local mm = M.getMoveMod(); if mm then mm.SetDashDistance(val) end
    end)

    AddToggle(moveCard, "Super Jump", "High jump leap", false, function(state)
        local mm = M.getMoveMod(); if mm then mm.SetSuperJump(state) end
        Notify("PvP", "Super Jump: " .. (state and "Enabled" or "Disabled"))
    end)

    AddSlider(moveCard, "Super Jump Force", 50, 350, 216, 5, function(val)
        local mm = M.getMoveMod(); if mm then mm.SetSuperJumpPower(val) end
    end)

    AddToggle(moveCard, "Infinite Jump", "Jump continuously in mid-air", false, function(state)
        local mm = M.getMoveMod(); if mm then mm.SetInfiniteJump(state) end
        Notify("PvP", "Infinite Jump: " .. (state and "Enabled" or "Disabled"))
    end)

    AddToggle(moveCard, "Noclip Wallpass", "Pass through walls and objects", false, function(state)
        local mm = M.getMoveMod(); if mm then mm.SetNoclip(state) end
        Notify("PvP", "Noclip: " .. (state and "Enabled" or "Disabled"))
    end)

    AddToggle(moveCard, "Walk on Water", "Walk on ocean surface", false, function(state)
        local mm = M.getMoveMod(); if mm then mm.SetWalkOnWater(state) end
        Notify("PvP", "Walk on Water: " .. (state and "Enabled" or "Disabled"))
    end)

    AddToggle(moveCard, "Anti-Lava Damage", "Immunity to lava damage", false, function(state)
        local mm = M.getMoveMod(); if mm then mm.SetAntiLava(state) end
        Notify("PvP", "Anti-Lava: " .. (state and "Active" or "Disabled"))
    end)

    AddToggle(moveCard, "Fly", "Glide freely through the air", false, function(state)
        local mm = M.getMoveMod(); if mm then mm.SetFly(state) end
        Notify("PvP", "Fly: " .. (state and "Enabled" or "Disabled"))
    end)

    AddSlider(moveCard, "Fly Speed", 20, 500, 70, 5, function(val)
        local mm = M.getMoveMod(); if mm then mm.SetFlySpeed(val) end
    end)

    -- 4. Fast Flags & Engine Tuning
    local fflagCard = CreateCard(PvPPage, "Fast Flags")

    AddToggle(fflagCard, "FFlags 1 (FPS Booster)", "120 FPS cap, smooth plastic textures, removes atmosphere fog, hides debris", false, function(state)
        SetFFlags1(state)
    end)

    AddToggle(fflagCard, "No Animations", "Stops non-attack animations to fix sideways bug and character freezes", false, function(state)
        SetNoAnimations(state)
    end)

    AddButton(fflagCard, "Apply Fast FFlags", function()
        ApplyFastFFlags()
    end)
end)
if not okPvP then
    warn("[Monody] Failed to initialize PvPPage: " .. tostring(errPvP))
end
-- 4. MACRO TAB (SMART COMBO SUITE)
local MacroPage = RegisterTab("Macro", "Macro", "bot")
local okMacro, errMacro = pcall(function()
    local macroTabMod = RequireModule("modules/macro/macro_tab.lua")
    if macroTabMod and macroTabMod.Build then
        macroTabMod.Build(MacroPage, {
            CreateCard = CreateCard,
            AddToggle = AddToggle,
            AddChoice = AddChoice,
            AddButton = AddButton,
            Notify = Notify,
            RequireModule = RequireModule
        })
    end
end)
if not okMacro then
    warn("[Monody] Failed to initialize MacroPage: " .. tostring(errMacro))
end

-- 5. SORU TAB (FLASHSTEP INTEGRATION)
local SoruPage = RegisterTab("Soru", "Soru", "zap")
local okSoru, errSoru = pcall(function()
    local soruMod = nil
    local function getSoruMod()
        if not soruMod then soruMod = RequireModule("modules/soru/soru_controller.lua") end
        return soruMod
    end
    task.spawn(function() pcall(getSoruMod) end)

    -- 1. Soru Flashstep Engine
    local cdCard = CreateCard(SoruPage, "Infinite Soru")

    AddToggle(cdCard, "Infinite Soru", "Remove flashstep cooldown", false, function(state)
        local sm = getSoruMod(); if sm and sm.setInfinite then sm.setInfinite(state) end
        Notify("Soru", "Infinite Soru: " .. (state and "Enabled" or "Disabled"))
    end)

    -- 2. Soru Combat Aimbot
    local aimCard = CreateCard(SoruPage, "Soru Aimbot")

    AddToggle(aimCard, "Soru Aimbot", "Teleport soru directly to enemy", false, function(state)
        local sm = getSoruMod(); if sm and sm.setAimbot then sm.setAimbot(state) end
        Notify("Soru", "Soru Aimbot: " .. (state and "Enabled" or "Disabled"))
    end)

    AddChoice(aimCard, "Soru Target Mode", { "Nearest Player", "Selected Player" }, 1, function(val)
        local sm = getSoruMod(); if sm then sm.TargetMode = val end
    end)

    local playerList = { "None" }
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then table.insert(playerList, p.Name) end
        end
    end)
    AddChoice(aimCard, "Target Player Selection", playerList, 1, function(val)
        local sm = getSoruMod(); if sm then sm.SelectedPlayer = (val ~= "None" and val or nil) end
    end)

    AddSlider(aimCard, "Max Soru Range", 200, 3000, 2000, 100, function(val)
        local sm = getSoruMod(); if sm then sm.MaxDistance = val end
    end)

    -- 3. Soru Skill Combo Automation
    local comboCard = CreateCard(SoruPage, "Soru Skill Combo")

    AddToggle(comboCard, "Auto Skill on Soru", "Use skill instantly after Soru", false, function(state)
        local sm = getSoruMod(); if sm and sm.setSkillCombo then sm.setSkillCombo(state) end
        Notify("Soru", "Skill Combo: " .. (state and "Enabled" or "Disabled"))
    end)

    AddChoice(comboCard, "Combo Weapon", { "Fruit", "Melee", "Sword", "Gun" }, 1, function(val)
        local sm = getSoruMod(); if sm then sm.SkillWeapon = val end
    end)

    AddChoice(comboCard, "Combo Key", { "Z", "X", "C", "V", "F" }, 1, function(val)
        local sm = getSoruMod(); if sm then sm.SkillKey = val end
    end)

    AddSlider(comboCard, "Skill Delay", 50, 800, 300, 25, function(val)
        local sm = getSoruMod(); if sm then sm.SkillDelay = val / 1000 end
    end)
end)
if not okSoru then
    warn("[Monody] Failed to initialize SoruPage: " .. tostring(errSoru))
end

-- 6. ESP TAB (STRICTLY PVP COMBAT RADAR)
local ESPPage = RegisterTab("Esp", "Visuals", "eye")
local okESP, errESP = pcall(function()
    local espMod = nil
    local function getEspMod()
        if not espMod then espMod = RequireModule("modules/esp/esp_pvp.lua") end
        return espMod
    end
    task.spawn(function() pcall(getEspMod) end)
    local espControls = {}

    -- 1. Master Visuals & Chams
    local radarCard = CreateCard(ESPPage, "ESP Visuals")

    local masterToggle = AddToggle(radarCard, "Master ESP", "Enable player visual highlights", false, function(state)
        local em = getEspMod(); if em and em.toggle then em.toggle(state) end
        Notify("ESP", "Player ESP: " .. (state and "Enabled" or "Disabled"))
    end)

    AddChoice(radarCard, "ESP Style", { "2D Boxes", "Overhead Billboard" }, 1, function(val)
        local em = getEspMod(); if em then em.Style = val:find("Billboard") and "Overhead Billboard" or "2D Boxes" end
        Notify("ESP", "Style: " .. val)
    end)

    -- Quick Action Row: Enable All / Disable All
    local quickRow = Instance.new("Frame", radarCard)
    quickRow.Size = UDim2.new(1, 0, 0, 26)
    quickRow.BackgroundTransparency = 1
    local qLayout = Instance.new("UIGridLayout", quickRow)
    qLayout.CellSize = UDim2.new(0.5, -4, 1, 0)
    qLayout.CellPadding = UDim2.new(0, 8, 0, 0)

    local function makeQuickBtn(txt, callback)
        local btn = Instance.new("TextButton", quickRow)
        btn.BackgroundColor3 = Color3.fromRGB(22, 18, 32)
        btn.BackgroundTransparency = 0.45
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Active = true
        btn.Selectable = true
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local bStr = Instance.new("UIStroke", btn)
        bStr.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        bStr.Color = CurrentAccent
        bStr.Thickness = 0.8
        bStr.Transparency = 0.5
        RegisterThemeStroke(bStr)

        local bLbl = Instance.new("TextLabel", btn)
        bLbl.Size = UDim2.new(1, 0, 1, 0)
        bLbl.BackgroundTransparency = 1
        bLbl.Font = Enum.Font.GothamBold
        bLbl.TextSize = 8.5
        bLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        bLbl.Text = txt
        RegisterTranslatable(bLbl, txt)

        ConnectButton(btn, callback)
        return btn
    end

    makeQuickBtn("Enable All Visuals", function()
        if espMod and espMod.toggle then espMod.toggle(true) end
        if masterToggle and masterToggle.SetState then masterToggle.SetState(true, false) end
        for name, ctrl in pairs(espControls) do
            if ctrl and ctrl.SetState then ctrl.SetState(true, true) end
        end
        Notify("ESP", "All Player ESP Visuals: Enabled")
    end)

    makeQuickBtn("Disable All Visuals", function()
        if espMod and espMod.toggle then espMod.toggle(false) end
        if masterToggle and masterToggle.SetState then masterToggle.SetState(false, false) end
        for name, ctrl in pairs(espControls) do
            if ctrl and ctrl.SetState then ctrl.SetState(false, true) end
        end
        Notify("ESP", "All Player ESP Visuals: Disabled")
    end)

    -- 2. Player Radar Elements
    local elementsCard = CreateCard(ESPPage, "Radar Elements")

    espControls.Boxes = AddToggle(elementsCard, "Player 2D Boxes", "Draws dynamic bounding boxes around enemy players", false, function(state)
        if espMod then espMod.Boxes = state end
    end)

    espControls.Names = AddToggle(elementsCard, "Player Names", "Displays formatted usernames above character heads", false, function(state)
        if espMod then espMod.Names = state end
    end)

    espControls.Health = AddToggle(elementsCard, "Player Health Status", "Displays live gradient health bars and HP percentage", false, function(state)
        if espMod then espMod.Health = state end
    end)

    espControls.Distance = AddToggle(elementsCard, "Distance Indicator", "Shows distance measurement in studs below player feet", false, function(state)
        if espMod then espMod.Distance = state end
    end)

    espControls.Tool = AddToggle(elementsCard, "Equipped Tool / Weapon", "Shows weapon, sword, fruit or gun held by the player", false, function(state)
        if espMod then espMod.Tool = state end
    end)

    espControls.Fruit = AddToggle(elementsCard, "Devil Fruit Tracker", "Identifies equipped Devil Fruit power (Kitsune, Portal, etc.)", false, function(state)
        if espMod then espMod.Fruit = state end
    end)

    espControls.Bounty = AddToggle(elementsCard, "Player Bounty Tracker", "Displays player bounty or honor value in millions", false, function(state)
        if espMod then espMod.Bounty = state end
    end)

    espControls.Level = AddToggle(elementsCard, "Player Level Display", "Shows player rank and numerical level tag", false, function(state)
        if espMod then espMod.Level = state end
    end)

    espControls.PvPStatus = AddToggle(elementsCard, "Combat PvP Status", "Detects safe zone and in-combat status indicators", false, function(state)
        if espMod then espMod.PvPStatus = state end
    end)

    -- 3. Chams & Tracers
    local chamsCard = CreateCard(ESPPage, "Chams & Tracers")

    espControls.Chams = AddToggle(chamsCard, "Player Chams (Highlight)", "Illuminates full player character models through walls", false, function(state)
        if espMod then espMod.Chams = state end
        Notify("ESP", "Chams: " .. (state and "Enabled" or "Disabled"))
    end)

    AddChoice(chamsCard, "Chams Highlight Color", { "Red", "Purple", "Pink", "Blue", "Green", "Cyan", "Yellow", "White" }, 1, function(val)
        if espMod then
            local col = THEMES[val] or Color3.fromRGB(244, 63, 94)
            espMod.ChamsColor = col
        end
    end)

    espControls.Tracers = AddToggle(chamsCard, "Player Tracers", "Draws line from bottom of screen to tracked players", false, function(state)
        if espMod then espMod.Tracers = state end
        Notify("ESP", "Tracers: " .. (state and "Enabled" or "Disabled"))
    end)

    AddChoice(chamsCard, "Player Tracer Color", { "White", "Red", "Purple", "Pink", "Blue", "Green", "Cyan", "Yellow" }, 1, function(val)
        if espMod then
            local col = THEMES[val] or Color3.fromRGB(255, 255, 255)
            espMod.TracerColor = col
        end
    end)

    AddSlider(chamsCard, "ESP Text Font Size", 10, 22, 13, 1, function(val)
        if espMod then espMod.TextSize = val end
    end)
end)
if not okESP then
    warn("[Monody] Failed to initialize ESPPage: " .. tostring(errESP))
end
-- ============================================================
-- 3. PLAYERS TAB (TRANSPARENT CARDS, LIVE HEALTH, BLACKLIST & SPECTATE)
-- ============================================================
do
    pcall(function()
        local PlayersPage = RegisterTab("Players", "Players", "users")
        local pCard = CreateCard(PlayersPage, "Player Management")
        
        local filterText = ""

        local SpectateGui = Instance.new("ScreenGui")
        SpectateGui.Name = "MonodySpectateGui"
        SpectateGui.ResetOnSpawn = false
        SpectateGui.DisplayOrder = 999
        pcall(function() SpectateGui.Parent = parentGui or (lp and lp:FindFirstChild("PlayerGui")) or CoreGui end)

        local StopSpecBtn = Instance.new("TextButton", SpectateGui)
        StopSpecBtn.Name = "StopSpectateBtn"
        StopSpecBtn.Size = UDim2.new(0, 140, 0, 30)
        StopSpecBtn.Position = UDim2.new(0.5, -70, 0, 15)
        StopSpecBtn.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
        StopSpecBtn.BackgroundTransparency = 0.3
        StopSpecBtn.Text = ""
        StopSpecBtn.AutoButtonColor = false
        StopSpecBtn.Visible = false
        Instance.new("UICorner", StopSpecBtn).CornerRadius = UDim.new(0, 8)
        local specStroke = Instance.new("UIStroke", StopSpecBtn)
        specStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        specStroke.Color = Color3.fromRGB(255, 90, 90)
        specStroke.Thickness = 1

        local specLbl = Instance.new("TextLabel", StopSpecBtn)
        specLbl.Size = UDim2.new(1, 0, 1, 0)
        specLbl.BackgroundTransparency = 1
        specLbl.Font = Enum.Font.GothamBold
        specLbl.TextSize = 10
        specLbl.TextColor3 = Color3.fromRGB(255, 90, 90)
        specLbl.Text = "Stop Spectating"
        RegisterTranslatable(specLbl, "Stop Spectating")

        local currentSpectating = nil
        local function StopSpectate()
            currentSpectating = nil
            StopSpecBtn.Visible = false
            pcall(function()
                local char = lp.Character or lp.CharacterAdded:Wait()
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then Workspace.CurrentCamera.CameraSubject = hum end
            end)
        end
        ConnectButton(StopSpecBtn, StopSpectate)

        local function RenderPlayers()
            for _, ch in ipairs(pCard:GetChildren()) do
                if ch.Name:find("^PlayerRow_") then
                    ch:Destroy()
                end
            end

            local allPlayers = Players:GetPlayers()
            for idx, p in ipairs(allPlayers) do
                local pName = p.Name
                local pDisp = p.DisplayName
                if filterText == "" or pName:lower():find(filterText:lower(), 1, true) or pDisp:lower():find(filterText:lower(), 1, true) then
                    local pRow = Instance.new("Frame", pCard)
                    pRow.Name = "PlayerRow_" .. p.UserId
                    pRow.Size = UDim2.new(1, 0, 0, 48)
                    pRow.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
                    pRow.BackgroundTransparency = 0.75
                    pRow.BorderSizePixel = 0
                    pRow.LayoutOrder = 10 + idx
                    Instance.new("UICorner", pRow).CornerRadius = UDim.new(0, 8)
                    local rStroke = Instance.new("UIStroke", pRow)
                    rStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    rStroke.Color = Color3.fromRGB(45, 40, 60)
                    rStroke.Thickness = 0.8
                    rStroke.Transparency = 0.6

                    local avatarImg = Instance.new("ImageLabel", pRow)
                    avatarImg.Size = UDim2.new(0, 32, 0, 32)
                    avatarImg.Position = UDim2.new(0, 8, 0.5, -16)
                    avatarImg.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
                    avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=150&h=150"
                    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)

                    local nameLbl = Instance.new("TextLabel", pRow)
                    nameLbl.Size = UDim2.new(1, -178, 0, 15)
                    nameLbl.Position = UDim2.new(0, 46, 0, 6)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Font = Enum.Font.GothamBold
                    nameLbl.TextSize = 10
                    nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    nameLbl.Text = pDisp .. (p == lp and " (You)" or "")

                    local uLbl = Instance.new("TextLabel", pRow)
                    uLbl.Size = UDim2.new(1, -178, 0, 11)
                    uLbl.Position = UDim2.new(0, 46, 0, 20)
                    uLbl.BackgroundTransparency = 1
                    uLbl.Font = Enum.Font.GothamMedium
                    uLbl.TextSize = 8
                    uLbl.TextColor3 = Color3.fromRGB(180, 175, 200)
                    uLbl.TextXAlignment = Enum.TextXAlignment.Left
                    uLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    uLbl.Text = "@" .. pName

                    local hpTrack = Instance.new("Frame", pRow)
                    hpTrack.Size = UDim2.new(0, 75, 0, 4)
                    hpTrack.Position = UDim2.new(0, 46, 0, 33)
                    hpTrack.BackgroundColor3 = Color3.fromRGB(30, 26, 42)
                    Instance.new("UICorner", hpTrack).CornerRadius = UDim.new(1, 0)

                    local hpFill = Instance.new("Frame", hpTrack)
                    hpFill.Size = UDim2.new(1, 0, 1, 0)
                    hpFill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)

                    local hpLbl = Instance.new("TextLabel", pRow)
                    hpLbl.Size = UDim2.new(0, 35, 0, 10)
                    hpLbl.Position = UDim2.new(0, 125, 0, 30)
                    hpLbl.BackgroundTransparency = 1
                    hpLbl.Font = Enum.Font.GothamMedium
                    hpLbl.TextSize = 7.5
                    hpLbl.TextColor3 = Color3.fromRGB(210, 205, 225)
                    hpLbl.TextXAlignment = Enum.TextXAlignment.Left
                    hpLbl.Text = "100%"

                    local function UpdateHealth()
                        local char = p.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.MaxHealth > 0 then
                            local frac = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                            hpFill.Size = UDim2.new(frac, 0, 1, 0)
                            hpLbl.Text = math.floor(hum.Health) .. " (" .. math.floor(frac * 100) .. "%)"
                            if frac > 0.5 then
                                hpFill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                            elseif frac > 0.25 then
                                hpFill.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
                            else
                                hpFill.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
                            end
                        else
                            hpFill.Size = UDim2.new(0, 0, 1, 0)
                            hpLbl.Text = "0%"
                        end
                    end
                    UpdateHealth()

                    if p.Character then
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if hum then hum.HealthChanged:Connect(UpdateHealth) end
                    end
                    p.CharacterAdded:Connect(function(char)
                        task.wait(0.2)
                        local hum = char:WaitForChild("Humanoid", 3)
                        if hum then hum.HealthChanged:Connect(UpdateHealth) end
                        UpdateHealth()
                    end)

                    if p ~= lp then
                        local btnBox = Instance.new("Frame", pRow)
                        btnBox.Name = "ActionBox"
                        btnBox.Size = UDim2.new(0, 124, 0, 24)
                        btnBox.Position = UDim2.new(1, -128, 0.5, -12)
                        btnBox.BackgroundTransparency = 1

                        local bList = Instance.new("UIListLayout", btnBox)
                        bList.FillDirection = Enum.FillDirection.Horizontal
                        bList.HorizontalAlignment = Enum.HorizontalAlignment.Right
                        bList.VerticalAlignment = Enum.VerticalAlignment.Center
                        bList.Padding = UDim.new(0, 5)

                        local blBtn = Instance.new("TextButton", btnBox)
                        blBtn.Size = UDim2.new(0, 58, 0, 24)
                        local isBl = _G.DarlingBlacklistedPlayers and _G.DarlingBlacklistedPlayers[p.UserId]
                        blBtn.BackgroundColor3 = isBl and Color3.fromRGB(231, 76, 60) or Color3.fromRGB(255, 255, 255)
                        blBtn.BackgroundTransparency = isBl and 0.25 or 0.92
                        blBtn.Text = ""
                        blBtn.AutoButtonColor = false
                        Instance.new("UICorner", blBtn).CornerRadius = UDim.new(0, 6)
                        local blStroke = Instance.new("UIStroke", blBtn)
                        blStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                        blStroke.Color = CurrentAccent
                        blStroke.Thickness = 0.8
                        blStroke.Transparency = 0.85
                        RegisterThemeStroke(blStroke)

                        local blLbl = Instance.new("TextLabel", blBtn)
                        blLbl.Size = UDim2.new(1, 0, 1, 0)
                        blLbl.BackgroundTransparency = 1
                        blLbl.Font = Enum.Font.GothamBold
                        blLbl.TextSize = 8
                        blLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                        blLbl.Text = isBl and "Blacklisted" or "Blacklist"
                        RegisterTranslatable(blLbl, blLbl.Text)

                        ConnectButton(blBtn, function()
                            _G.DarlingBlacklistedPlayers = _G.DarlingBlacklistedPlayers or {}
                            local nextState = not _G.DarlingBlacklistedPlayers[p.UserId]
                            _G.DarlingBlacklistedPlayers[p.UserId] = nextState
                            _G.DarlingBlacklistedPlayers[p.Name] = nextState
                            blBtn.BackgroundColor3 = nextState and Color3.fromRGB(231, 76, 60) or Color3.fromRGB(255, 255, 255)
                            blBtn.BackgroundTransparency = nextState and 0.25 or 0.92
                            blLbl.Text = nextState and "Blacklisted" or "Blacklist"
                            RegisterTranslatable(blLbl, blLbl.Text)
                            Notify("Blacklist", (nextState and "Added " or "Removed ") .. pName)
                        end)

                        local specBtn = Instance.new("TextButton", btnBox)
                        specBtn.Size = UDim2.new(0, 58, 0, 24)
                        specBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        specBtn.BackgroundTransparency = 0.92
                        specBtn.Text = ""
                        specBtn.AutoButtonColor = false
                        Instance.new("UICorner", specBtn).CornerRadius = UDim.new(0, 6)
                        local spStroke = Instance.new("UIStroke", specBtn)
                        spStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                        spStroke.Color = CurrentAccent
                        spStroke.Thickness = 0.8
                        spStroke.Transparency = 0.85
                        RegisterThemeStroke(spStroke)

                        local spLbl = Instance.new("TextLabel", specBtn)
                        spLbl.Size = UDim2.new(1, 0, 1, 0)
                        spLbl.BackgroundTransparency = 1
                        spLbl.Font = Enum.Font.GothamBold
                        spLbl.TextSize = 8
                        spLbl.TextColor3 = CurrentAccent
                        spLbl.Text = "Spectate"
                        RegisterTranslatable(spLbl, "Spectate")

                        ConnectButton(specBtn, function()
                            if currentSpectating == p then
                                StopSpectate()
                            else
                                local char = p.Character
                                local hum = char and char:FindFirstChildOfClass("Humanoid")
                                if hum then
                                    currentSpectating = p
                                    Workspace.CurrentCamera.CameraSubject = hum
                                    StopSpecBtn.Visible = true
                                    Notify("Spectate", "Observing " .. pName)
                                else
                                    Notify("Spectate", "Player character not available.")
                                end
                            end
                        end)
                    end
                end
            end
            UpdateCardGeometry(pCard)
            UpdatePageCanvas(PlayersPage)
        end

        AddInput(pCard, "Search Player...", "Search player...", "", function(val)
            filterText = tostring(val or "")
            RenderPlayers()
        end)
        AddButton(pCard, "Refresh Player List", RenderPlayers)

        Players.PlayerAdded:Connect(function() task.wait(0.5); RenderPlayers() end)
        Players.PlayerRemoving:Connect(function(rem)
            if currentSpectating == rem then StopSpectate() end
            task.wait(0.2)
            RenderPlayers()
        end)

        _G.Monody_RefreshPlayers = RenderPlayers
        task.defer(RenderPlayers)
    end)
end

-- ============================================================
-- 4. DUNGEON TAB (AUTO DUNGEON & VOID M1 ENGINE)
-- ============================================================
do
    pcall(function()
        local DungeonPage = RegisterTab("Dungeon", "Dungeon", "flame")

        local Players = game:GetService("Players")
        local Workspace = game:GetService("Workspace")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local VirtualInputManager = game:GetService("VirtualInputManager")
        local TweenService = game:GetService("TweenService")
        local localPlayer = lp or Players.LocalPlayer

        local character = localPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

        local justDied = false
        localPlayer.CharacterAdded:Connect(function(newCharacter)
            character = newCharacter
            humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart", 5)
            justDied = true
        end)

        local netFolder = ReplicatedStorage:WaitForChild("Modules", 5)
        netFolder = netFolder and netFolder:WaitForChild("Net", 5)
        local registerAttack = netFolder and netFolder:WaitForChild("RE/RegisterAttack", 5)
        local registerHit = netFolder and netFolder:WaitForChild("RE/RegisterHit", 5)
        local enemiesFolder = Workspace:FindFirstChild("Enemies") or Workspace
        local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5)
        local commF = remotesFolder and remotesFolder:WaitForChild("CommF_", 5)

        local BOSS_ROOMS = { [5] = true, [10] = true, [15] = true, [20] = true }

        local function GetDungeonRooms()
            local mapFolder = Workspace:FindFirstChild("Map")
            if not mapFolder then return {} end
            local dungeonFolder = mapFolder:FindFirstChild("Dungeon")
            if not dungeonFolder then return {} end
            local rooms = dungeonFolder:GetChildren()
            table.sort(rooms, function(a, b)
                local numA = tonumber(string.match(a.Name, "%d+")) or 0
                local numB = tonumber(string.match(b.Name, "%d+")) or 0
                return numA < numB
            end)
            return rooms
        end

        local function GetCurrentRoomNumber()
            local hrp = humanoidRootPart or (localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart"))
            if not hrp then return 0 end
            local rooms = GetDungeonRooms()
            if #rooms == 0 then return 0 end
            local myPos = hrp.Position
            local currentRoomIdx = 1
            local minDist = math.huge
            for i, room in ipairs(rooms) do
                local roomPart = room:FindFirstChildOfClass("Part")
                    or room:FindFirstChildOfClass("MeshPart")
                    or room:FindFirstChild("Floor")
                if roomPart then
                    local dist = (roomPart.Position - myPos).Magnitude
                    if dist < minDist then
                        minDist = dist
                        currentRoomIdx = i
                    end
                end
            end
            local room = rooms[currentRoomIdx]
            if not room then return currentRoomIdx end
            return tonumber(string.match(room.Name, "%d+")) or currentRoomIdx
        end

        local function IsBossModel(obj)
            if not obj then return false end
            local n = string.lower(obj.Name or "")
            if string.find(n, "shadow", 1, true) or string.find(n, "sombra", 1, true) then return false end
            if string.find(n, "buddy", 1, true) or string.find(n, "clone", 1, true) then return false end
            if string.find(n, "fruit", 1, true) then return false end
            if string.find(n, "summon", 1, true) or string.find(n, "ally", 1, true) then return false end
            if string.find(n, "ancient beast", 1, true) then return true end
            if string.find(n, "ancient", 1, true) and string.find(n, "beast", 1, true) then return true end
            if string.find(n, "kitsune lord", 1, true) then return true end
            if string.find(n, "kitsune", 1, true) and string.find(n, "lord", 1, true) then return true end
            if string.find(n, "gas knight", 1, true) then return true end
            if string.find(n, "gas", 1, true) and string.find(n, "knight", 1, true) then return true end
            if n == "zero" or string.find(n, "zero", 1, true) then return true end
            if string.find(n, "boss", 1, true) then return true end
            return false
        end

        local function GetAliveBoss()
            local sourceFolder = Workspace:FindFirstChild("Enemies") or enemiesFolder
            if not sourceFolder then return nil end
            local best, bestDist = nil, math.huge
            local hrp = humanoidRootPart or (localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart"))
            if not hrp then return nil end
            for _, obj in ipairs(sourceFolder:GetChildren()) do
                if obj:IsA("Model") and IsBossModel(obj) then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                    if hum and hum.Health > 0 and root then
                        local d = (root.Position - hrp.Position).Magnitude
                        if d < bestDist then
                            bestDist = d
                            best = obj
                        end
                    end
                end
            end
            return best
        end

        local function HasAliveBoss()
            return GetAliveBoss() ~= nil
        end

        local currentTarget = nil
        local lastTarget = nil

        local VoidConfig = {
            Enabled = false,
            Interval = 0.08,
            VoidOnlyBossRoom = true,
        }

        local AutoLoad = false

        local function GetPlayerFruit()
            local char = localPlayer.Character
            if char then
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") and tool.ToolTip == "Blox Fruit" then
                        return tool
                    end
                end
            end
            local backpack = localPlayer:FindFirstChildOfClass("Backpack") or localPlayer:FindFirstChild("Backpack")
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.ToolTip == "Blox Fruit" then
                        return tool
                    end
                end
            end
            return nil
        end

        local function GetMaxCombo(tool)
            if not tool then return 5 end
            local n = tool.Name
            if n == "T-Rex-T-Rex" then return 4 end
            if n == "Blade-Blade" then return 2 end
            if n == "Pain-Pain" then return 4 end
            if n == "Control-Control" then return 4 end
            if n == "Gas-Gas" then return 5 end
            if n == "Kitsune-Kitsune" then return 5 end
            if n == "Magma-Magma" then return 5 end
            if n == "Dragon-Dragon" then
                local char = localPlayer.Character
                return (char and char:FindFirstChild("DragonHybrid")) and 5 or 3
            end
            return 5
        end

        local voidRunning = false
        local lastRoomNum = -1

        local function IsAllyModel_Safe(object)
            if not object then return true end
            local n = string.lower(object.Name or "")
            if string.find(n, "shadow", 1, true) or string.find(n, "sombra", 1, true) then return true end
            if string.find(n, "buddy", 1, true) or string.find(n, "clone", 1, true) then return true end
            if string.find(n, "summon", 1, true) or string.find(n, "ally", 1, true) then return true end
            if Players:GetPlayerFromCharacter(object) then return true end
            return false
        end

        local function CanUseVoidNow()
            if not VoidConfig.Enabled then return false end

            local roomNum = GetCurrentRoomNumber()
            if VoidConfig.VoidOnlyBossRoom then
                if not BOSS_ROOMS[roomNum] then
                    return false
                end
            end

            if HasAliveBoss() then
                return true
            end

            if BOSS_ROOMS[roomNum] then
                local folder = Workspace:FindFirstChild("Enemies") or enemiesFolder
                if folder then
                    for _, obj in ipairs(folder:GetChildren()) do
                        if obj:IsA("Model") and not IsAllyModel_Safe(obj) then
                            local hum = obj:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 and hum.MaxHealth >= 50000 then
                                return true
                            end
                        end
                    end
                end
            end
            return false
        end

        local function VoidLoop()
            if voidRunning then return end
            voidRunning = true
            task.spawn(function()
                while VoidConfig.Enabled do
                    pcall(function()
                        local roomNum = GetCurrentRoomNumber()
                        if roomNum ~= lastRoomNum then
                            lastRoomNum = roomNum
                        end

                        if not CanUseVoidNow() then return end

                        local fruit = GetPlayerFruit()
                        if not fruit then return end
                        local remote = fruit:FindFirstChild("LeftClickRemote")
                        if not remote then return end

                        local char = localPlayer.Character
                        if char and fruit.Parent ~= char then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then pcall(function() hum:EquipTool(fruit) end) end
                        end

                        local maxCombo = GetMaxCombo(fruit)
                        remote:FireServer(Vector3.new(9e30, 9e30, 9e30), maxCombo, true)
                    end)
                    task.wait(tonumber(VoidConfig.Interval) or 0.08)
                end
                voidRunning = false
                lastRoomNum = -1
            end)
        end

        local attackHeight = 40
        local selectedWeapon = "Sword"
        local weaponOptions = { "Sword", "Melee", "Blox Fruit" }
        local autoDungeonActive = false
        local autoV4Active = false
        local autoBusoActive = false
        local autoPassActive = true

        local function GetWeaponInBackpack(weaponName)
            local backpack = localPlayer:FindFirstChildOfClass("Backpack") or localPlayer:FindFirstChild("Backpack")
            if not backpack then return nil end
            for _, tool in ipairs(backpack:GetChildren()) do
                if string.find(string.lower(tool.Name), string.lower(weaponName), 1, true) or tool.ToolTip == weaponName then
                    return tool
                end
            end
            return nil
        end

        local function EquipSelectedWeapon()
            local char = localPlayer.Character
            if not char or not autoDungeonActive then return end
            if VoidConfig.Enabled and CanUseVoidNow() then
                local fruit = GetPlayerFruit()
                if fruit then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and fruit.Parent ~= char then
                        pcall(function() hum:EquipTool(fruit) end)
                    end
                    return
                end
            end
            local currentTool = char:FindFirstChildOfClass("Tool")
            if currentTool and (string.find(string.lower(currentTool.Name), string.lower(selectedWeapon), 1, true) or currentTool.ToolTip == selectedWeapon) then
                return
            end
            local toolToEquip = GetWeaponInBackpack(selectedWeapon)
            if toolToEquip then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid:EquipTool(toolToEquip) end
            end
        end

        local function hasBusoActive(char)
            if not char then return false end
            if char:FindFirstChild("HasBuso") or char:FindFirstChild("Buso") or char:FindFirstChild("Aura") then
                return true
            end
            if char:GetAttribute("HasBuso") == true or char:GetAttribute("Buso") == true or char:GetAttribute("Aura") == true then
                return true
            end
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") and (part:FindFirstChild("Buso") or part:FindFirstChild("Aura")) then
                    return true
                end
            end
            return false
        end

        local function ForceActivateHaki()
            local char = localPlayer.Character
            if not char or not autoDungeonActive or not autoBusoActive then return end
            if not hasBusoActive(char) then
                pcall(function()
                    if commF then commF:InvokeServer("Buso") end
                end)
            end
        end

        local function TriggerRaceV4()
            if not autoV4Active or not autoDungeonActive then return end
            pcall(function()
                local commE = remotesFolder and remotesFolder:FindFirstChild("CommE")
                if commE and commE:IsA("RemoteEvent") then commE:FireServer("ActivateAwakening", true) end
                local events = ReplicatedStorage:FindFirstChild("Events")
                local v4Event = events and events:FindFirstChild("ActivateRaceV4")
                if v4Event and v4Event:IsA("BindableEvent") then v4Event:Fire() end
                local awk = remotesFolder and remotesFolder:FindFirstChild("Awakening")
                if awk and awk:IsA("RemoteFunction") then awk:InvokeServer(true) end
            end)
            local uis = game:GetService("UserInputService")
            -- NEVER send keyboard events on touch devices to avoid switching HUD to PC mode!
            if not uis.TouchEnabled and uis.KeyboardEnabled then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                    task.wait(0.04)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
                end)
            end
        end

        local function StartAutoBuffs()
            task.spawn(function()
                while autoDungeonActive do
                    EquipSelectedWeapon()
                    task.wait(0.3)
                end
            end)
            task.spawn(function()
                while autoDungeonActive do
                    if autoBusoActive then
                        ForceActivateHaki()
                    end
                    task.wait(0.5)
                end
            end)
            task.spawn(function()
                while autoDungeonActive do
                    if autoV4Active then
                        TriggerRaceV4()
                    end
                    task.wait(1.5)
                end
            end)
        end

        local function IsAllyModel(object)
            return IsAllyModel_Safe(object)
        end

        local function IsValidEnemy(object, currentCharacter, jefeVivo)
            if not object or not object:IsA("Model") then return false end
            if object == currentCharacter then return false end
            if IsAllyModel(object) then return false end
            if object.Name == "PropHitboxPlaceholder" and not jefeVivo then return false end
            local humanoid = object:FindFirstChildOfClass("Humanoid")
            local root = object:FindFirstChild("HumanoidRootPart") or object:FindFirstChild("Head")
            if not humanoid or humanoid.Health <= 0 or not root or not object.Parent then return false end
            return true
        end

        local function GetClosestEnemy()
            if justDied then return nil end
            local currentCharacter = localPlayer.Character
            if not currentCharacter or not currentCharacter:FindFirstChild("HumanoidRootPart") then return nil end

            local myPos = currentCharacter.HumanoidRootPart.Position
            local sourceFolder = Workspace:FindFirstChild("Enemies") or enemiesFolder
            if not sourceFolder then return nil end

            local jefeVivo = HasAliveBoss()

            local closestEnemy, shortestDistance = nil, math.huge
            for _, object in ipairs(sourceFolder:GetChildren()) do
                if IsValidEnemy(object, currentCharacter, jefeVivo) then
                    local root = object:FindFirstChild("HumanoidRootPart") or object:FindFirstChild("Head")
                    local distance = (root.Position - myPos).Magnitude
                    if IsBossModel(object) then
                        distance = distance - 80
                    end
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestEnemy = object
                    end
                end
            end
            return closestEnemy
        end

        local function EnemyStillAlive(enemy)
            if not enemy or not enemy.Parent then return false end
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            return hum and hum.Health > 0
        end

        local TP_BYPASS_RANGE = 320
        local TWEEN_SPEED = 900
        local lastHpWatch = {}

        local function TweenNearEnemy(enemyRoot)
            local char = localPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp or not enemyRoot then return end
            local dest = enemyRoot.Position + Vector3.new(0, attackHeight, 0)
            local dist = (hrp.Position - dest).Magnitude
            if dist <= 35 then
                hrp.CFrame = CFrame.new(dest)
                return
            end
            local approach = math.min(dist, TP_BYPASS_RANGE * 0.85)
            local alpha = math.clamp(approach / dist, 0.35, 0.92)
            local mid = hrp.Position:Lerp(dest, alpha)
            mid = Vector3.new(mid.X, dest.Y, mid.Z)
            local t = math.clamp(dist / TWEEN_SPEED, 0.04, 0.55)
            local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {
                CFrame = CFrame.new(mid)
            })
            tw:Play()
            tw.Completed:Wait()
            if enemyRoot.Parent and hrp.Parent then
                pcall(function()
                    hrp.CFrame = enemyRoot.CFrame * CFrame.new(0, attackHeight, 0)
                end)
            end
        end

        local function TeleportToEnemy(enemy)
            local char = localPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not enemy or not enemy.Parent or not hrp then return false end
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Head")
            if not enemyRoot then return false end

            local dist = (hrp.Position - enemyRoot.Position).Magnitude
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            local key = tostring(enemy)
            local prevHp = lastHpWatch[key]
            local curHp = hum and hum.Health or nil
            local noDamage = false
            if prevHp and curHp and curHp >= prevHp - 0.5 and dist > 55 then
                noDamage = true
            end
            if curHp then lastHpWatch[key] = curHp end

            if dist > TP_BYPASS_RANGE or noDamage then
                TweenNearEnemy(enemyRoot)
                return true
            end

            local success = pcall(function()
                hrp.CFrame = enemyRoot.CFrame * CFrame.new(0, attackHeight, 0)
            end)
            if not success then
                TweenNearEnemy(enemyRoot)
            end
            return true
        end

        local function AttackEnemy(enemy)
            if not enemy or not enemy.Parent then return end
            local enemyHead = enemy:FindFirstChild("Head") or enemy:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")
            if not enemyHead or not enemyHumanoid then return end
            local char = localPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
            pcall(function()
                if registerAttack then registerAttack:FireServer(0) end
                if registerHit then registerHit:FireServer(enemyHead, { { enemy, enemyHead } }) end
            end)
        end

        local function AutoPassRoom()
            local rooms = GetDungeonRooms()
            if #rooms == 0 then return false end
            local currentRoomIdx = 1
            local char = localPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local myPos = hrp.Position
                local minDistanceToRoomCenter = math.huge
                for i, room in ipairs(rooms) do
                    local roomPart = room:FindFirstChildOfClass("Part")
                        or room:FindFirstChildOfClass("MeshPart")
                        or room:FindFirstChild("Floor")
                    if roomPart then
                        local dist = (roomPart.Position - myPos).Magnitude
                        if dist < minDistanceToRoomCenter then
                            minDistanceToRoomCenter = dist
                            currentRoomIdx = i
                        end
                    end
                end
            end
            local activeRoom = rooms[currentRoomIdx]
            if not activeRoom then return false end
            local teleporter = activeRoom:FindFirstChild("ExitTeleporter")
            if not teleporter then return false end
            local rootPart = teleporter:FindFirstChild("Root")
            if not rootPart or not rootPart:IsA("BasePart") or not hrp then return false end
            hrp.CFrame = rootPart.CFrame
            task.wait(0.12)
            if firetouchinterest then
                pcall(function()
                    firetouchinterest(hrp, rootPart, 0)
                    task.wait(0.1)
                    firetouchinterest(hrp, rootPart, 1)
                end)
            end
            if justDied then justDied = false end
            return true
        end

        local function RotateTargets()
            while autoDungeonActive do
                -- Safeguard mobile HUD from switching to PC
                local uis = game:GetService("UserInputService")
                if uis.TouchEnabled then
                    local pGui = localPlayer:FindFirstChildOfClass("PlayerGui")
                    if pGui then
                        local tg = pGui:FindFirstChild("TouchGui")
                        if tg and not tg.Enabled then tg.Enabled = true end
                        local main = pGui:FindFirstChild("Main")
                        if main then
                            local pcSkills = main:FindFirstChild("Skills")
                            if pcSkills and pcSkills.Visible and pGui:FindFirstChild("ContextActionGui") then
                                pcSkills.Visible = false
                            end
                        end
                    end
                end

                if justDied then
                    local attempts = 0
                    while autoDungeonActive and justDied and attempts < 10 do
                        if AutoPassRoom() then
                            justDied = false
                            break
                        end
                        attempts = attempts + 1
                        task.wait(0.5)
                    end
                    if attempts >= 10 then justDied = false end
                else
                    if not EnemyStillAlive(currentTarget) or IsAllyModel(currentTarget) then
                        currentTarget = nil
                        local roomNum = GetCurrentRoomNumber()
                        if BOSS_ROOMS[roomNum] then
                            currentTarget = GetAliveBoss() or GetClosestEnemy()
                        else
                            currentTarget = GetClosestEnemy()
                        end
                        lastTarget = currentTarget
                    end

                    if currentTarget and EnemyStillAlive(currentTarget) and not IsAllyModel(currentTarget) then
                        while autoDungeonActive and not justDied
                            and EnemyStillAlive(currentTarget) and not IsAllyModel(currentTarget) do
                            TeleportToEnemy(currentTarget)
                            AttackEnemy(currentTarget)
                            task.wait(0.03)
                        end
                        currentTarget = nil
                    else
                        task.wait(0.4)
                        if autoPassActive then
                            if not AutoPassRoom() then
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end
        end

        local dCard1 = CreateCard(DungeonPage, "Auto Dungeon Engine")
        AddToggle(dCard1, "Start Auto Dungeon", "Automatically clears dungeon mobs and bosses", false, function(v)
            autoDungeonActive = v
            autoPassActive = v
            if v then
                justDied = false
                currentTarget = nil
                lastTarget = nil
                EquipSelectedWeapon()
                StartAutoBuffs()
                task.spawn(RotateTargets)
            else
                currentTarget = nil
                lastTarget = nil
                justDied = false
            end
        end)
        AddChoice(dCard1, "Selected Weapon", weaponOptions, 1, function(v)
            selectedWeapon = v
            EquipSelectedWeapon()
            Notify("Dungeon Weapon", "Equipped " .. tostring(v))
        end)
        AddSlider(dCard1, "Attack Height", 10, 100, 40, 5, function(v)
            attackHeight = v
        end)
        AddToggle(dCard1, "Auto Buso", "Automatically activates Buso Haki", false, function(v)
            autoBusoActive = v
            if v and autoDungeonActive then
                ForceActivateHaki()
            end
        end)
        AddToggle(dCard1, "Auto Race V4", "Activates Race Awakening automatically without affecting HUD", false, function(v)
            autoV4Active = v
            if v and autoDungeonActive then
                TriggerRaceV4()
            end
        end)
        AddToggle(dCard1, "Auto Pass Room", "Automatically navigates to next room when cleared", false, function(v)
            autoPassActive = v
        end)

        local dCard2 = CreateCard(DungeonPage, "Void M1 Engine")
        AddToggle(dCard2, "Enable Void M1", "Executes high-speed fruit attack loop", false, function(v)
            VoidConfig.Enabled = v and true or false
            if VoidConfig.Enabled then
                voidRunning = false
                VoidLoop()
            end
        end)
        AddToggle(dCard2, "Void Only Boss Rooms", "Restricts Void M1 to rooms 5, 10, 15, 20", true, function(v)
            VoidConfig.VoidOnlyBossRoom = v and true or false
            lastRoomNum = -1
            if VoidConfig.Enabled and not voidRunning then
                VoidLoop()
            end
        end)
        AddSlider(dCard2, "Void Interval (s)", 0.05, 0.50, 0.08, 0.01, function(v)
            VoidConfig.Interval = v
        end)

        local dCard3 = CreateCard(DungeonPage, "Dungeon Status & Utilities")
        AddToggle(dCard3, "Auto Load Dungeon", "Automatically begins dungeon on script load", false, function(v)
            AutoLoad = v
        end)

        local roomPill = Instance.new("TextLabel", dCard3)
        roomPill.Size = UDim2.new(1, 0, 0, 18)
        roomPill.BackgroundTransparency = 1
        roomPill.Font = Enum.Font.GothamMedium
        roomPill.TextSize = 9
        roomPill.TextColor3 = Color3.fromRGB(200, 195, 215)
        roomPill.TextXAlignment = Enum.TextXAlignment.Left
        roomPill.Text = "Current Room: Detecting..."
        roomPill.LayoutOrder = 10

        local bossPill = Instance.new("TextLabel", dCard3)
        bossPill.Size = UDim2.new(1, 0, 0, 18)
        bossPill.BackgroundTransparency = 1
        bossPill.Font = Enum.Font.GothamMedium
        bossPill.TextSize = 9
        bossPill.TextColor3 = Color3.fromRGB(200, 195, 215)
        bossPill.TextXAlignment = Enum.TextXAlignment.Left
        bossPill.Text = "Boss Status: Searching..."
        bossPill.LayoutOrder = 11

        task.spawn(function()
            while task.wait(1.5) do
                pcall(function()
                    local rNum = GetCurrentRoomNumber()
                    roomPill.Text = "Current Room: " .. (rNum > 0 and tostring(rNum) or "Outside / Lobby")
                    local boss = GetAliveBoss()
                    bossPill.Text = "Boss Status: " .. (boss and (boss.Name .. " (Alive)") or "None / Defeated")
                end)
            end
        end)

        task.defer(function()
            task.wait(1)
            if AutoLoad and autoDungeonActive then
                StartAutoBuffs()
                task.spawn(RotateTargets)
            end
        end)
    end)
end
-- ============================================================
-- 5. TELEPORT TAB (49 ISLANDS & SPOOKY TWEEN CONTROLLER)
-- ============================================================
do
    pcall(function()
        local TeleportPage = RegisterTab("Teleport", "Teleport", "map-pin")
        
        local IslandsData = {
            ["Sea 1"] = {
                ["WindMill"] = CFrame.new(979.79, 16.51, 1429.04),
                ["Marine"] = CFrame.new(-2566.42, 6.85, 2045.25),
                ["Middle Town"] = CFrame.new(-690.33, 15.09, 1582.23),
                ["Jungle"] = CFrame.new(-1612.79, 36.85, 149.12),
                ["Pirate Village"] = CFrame.new(-1181.30, 4.75, 3803.54),
                ["Desert"] = CFrame.new(894.48, 6.43, 4392.43),
                ["Snow Island"] = CFrame.new(1347.80, 104.66, -1319.73),
                ["MarineFord"] = CFrame.new(-4914.82, 50.96, 4281.02),
                ["Colosseum"] = CFrame.new(-1427.62, 7.28, -2792.77),
                ["Sky 1"] = CFrame.new(-4922.39, 717.70, -2622.35),
                ["Sky 2"] = CFrame.new(-4607.82, 872.54, -1667.55),
                ["Sky 3"] = CFrame.new(-7894.61, 5547.14, -380.29),
                ["Prison"] = CFrame.new(4875.33, 5.65, 734.85),
                ["Magma Village"] = CFrame.new(-5234.07, 8.59, 8467.06),
                ["Underwater"] = CFrame.new(61163.85, 11.67, 1819.78),
                ["Fountain City"] = CFrame.new(5127.12, 59.50, 4105.44),
                ["Shank Room"] = CFrame.new(-1442.16, 29.87, -28.35),
                ["Mob Island"] = CFrame.new(-2850.20, 7.39, 5354.99)
            },
            ["Sea 2"] = {
                ["The Cafe"] = CFrame.new(-380.47, 77.22, 255.82),
                ["First Spot"] = CFrame.new(-11.31, 29.27, 2771.52),
                ["Dark Area"] = CFrame.new(3780.03, 22.65, -3498.58),
                ["Flamingo Mansion"] = CFrame.new(-435.39, 332.21, 597.57),
                ["Flamingo Room"] = CFrame.new(2284.91, 15.15, 905.48),
                ["Green Zone"] = CFrame.new(-2448.53, 73.01, -3210.63),
                ["Factory"] = CFrame.new(424.12, 211.16, -429.45),
                ["Colosseum"] = CFrame.new(-1503.62, 219.79, 1369.31),
                ["Zombie Island"] = CFrame.new(-5622.03, 492.19, -781.78),
                ["Two Snow Mountain"] = CFrame.new(753.14, 408.23, -5274.61),
                ["Punk Hazard"] = CFrame.new(-6127.65, 15.95, -5040.28),
                ["Cursed Ship"] = CFrame.new(923.21, 125.05, 32852.83),
                ["Ice Castle"] = CFrame.new(6148.41, 294.38, -6741.11),
                ["Forgotten Island"] = CFrame.new(-3032.76, 237.78, -10175.69),
                ["Ussop Island"] = CFrame.new(4816.86, 8.45, 2863.81),
                ["Mini Sky"] = CFrame.new(-260.65, 49.32, -895.90)
            },
            ["Sea 3"] = {
                ["Mansion"] = CFrame.new(-12463.87, 374.91, -7523.77),
                ["Port Town"] = CFrame.new(-290.07, 6.72, 5343.55),
                ["Great Tree"] = CFrame.new(2281.54, 15.15, 905.48),
                ["Castle On The Sea"] = CFrame.new(-5085.23, 314.51, -3156.20),
                ["MiniSky"] = CFrame.new(-260.65, 49.32, -895.90),
                ["Hydra Island"] = CFrame.new(5749.34, 610.42, -267.78),
                ["Floating Turtle"] = CFrame.new(-13274.52, 531.82, -7579.22),
                ["Haunted Castle"] = CFrame.new(-9516.99, 142.13, 5534.54),
                ["Ice Cream"] = CFrame.new(-902.58, 65.81, -10965.78),
                ["Peanut"] = CFrame.new(-2010.46, 38.00, -10255.74),
                ["Cake"] = CFrame.new(-1914.85, 38.14, -12849.95),
                ["Cocoa"] = CFrame.new(169.11, 24.96, -12073.41),
                ["Candy"] = CFrame.new(-1149.28, 13.56, -14445.67),
                ["Tiki Outpost"] = CFrame.new(-16234.36, 9.38, 437.07),
                ["Dragon Dojo"] = CFrame.new(5832.83, 1277.24, 77.24)
            }
        }

        local detectedSea = "Sea 1"
        local pId = game.PlaceId
        if pId == 4442272183 then detectedSea = "Sea 2"
        elseif pId == 7449423635 then detectedSea = "Sea 3" end

        local currentSea = detectedSea
        local currentIsland = "WindMill"
        local tweenSpeed = 350
        local travelAltitude = 250
        local noclipEnabled = true

        local activeTween = nil
        local noclipConn = nil
        local isTweening = false

        local function StopTween()
            isTweening = false
            if activeTween then
                pcall(function() activeTween:Cancel() end)
                activeTween = nil
            end
            if noclipConn then
                pcall(function() noclipConn:Disconnect() end)
                noclipConn = nil
            end
            pcall(function()
                local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, v in ipairs(root:GetChildren()) do
                        if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v.Name == "Monody_TweenBV" then v:Destroy() end
                    end
                end
            end)
            Notify("Teleport", "Teleport cancelled.")
        end

        local function StartTween(targetCF)
            StopTween()
            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root or not targetCF then return end

            isTweening = true

            -- Safe Sky Altitude to clear all terrain, mountains, barriers
            local safeY = math.max(root.Position.Y, math.max(targetCF.Position.Y + 220, 500))

            -- Anti-gravity & Anti-fling BodyVelocity during flight
            local bv = Instance.new("BodyVelocity")
            bv.Name = "Monody_TweenBV"
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
            bv.Parent = root

            -- Continuous Multi-Part Noclip on Stepped
            noclipConn = RunService.Stepped:Connect(function()
                if not isTweening or not lp.Character then return end
                for _, part in ipairs(lp.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)

            task.spawn(function()
                -- Phase 1: Vertical ascent to clear obstacles
                local ascendCF = CFrame.new(root.Position.X, safeY, root.Position.Z)
                local dist1 = math.abs(safeY - root.Position.Y)
                local dur1 = math.clamp(dist1 / math.max(tweenSpeed, 80), 0.3, 3)
                activeTween = TweenService:Create(root, TweenInfo.new(dur1, Enum.EasingStyle.Linear), { CFrame = ascendCF })
                activeTween:Play()
                activeTween.Completed:Wait()

                if not isTweening then return end

                -- Phase 2: High altitude cruise across ocean
                local cruiseCF = CFrame.new(targetCF.Position.X, safeY, targetCF.Position.Z)
                local dist2 = (Vector3.new(ascendCF.Position.X, 0, ascendCF.Position.Z) - Vector3.new(cruiseCF.Position.X, 0, cruiseCF.Position.Z)).Magnitude
                local dur2 = math.max(dist2 / math.max(tweenSpeed, 80), 0.5)
                activeTween = TweenService:Create(root, TweenInfo.new(dur2, Enum.EasingStyle.Linear), { CFrame = cruiseCF })
                activeTween:Play()
                activeTween.Completed:Wait()

                if not isTweening then return end

                -- Phase 3: Smooth descent to island destination
                local dur3 = math.clamp(math.abs(safeY - targetCF.Position.Y) / math.max(tweenSpeed, 80), 0.4, 3)
                local landTween = TweenService:Create(root, TweenInfo.new(dur3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = targetCF })
                activeTween = landTween
                landTween:Play()
                landTween.Completed:Wait()

                StopTween()
                Notify("Teleport", "Arrived at " .. currentIsland)
            end)
        end

        local tpCard = CreateCard(TeleportPage, "Island Teleport")

        local islandChoice = nil
        local function GetIslandsForSea(sea)
            local list = {}
            for name in pairs(IslandsData[sea] or IslandsData["Sea 1"]) do
                table.insert(list, name)
            end
            table.sort(list)
            if #list == 0 then table.insert(list, "None") end
            return list
        end

        local function UpdateIslands(sea)
            currentSea = sea
            local newList = GetIslandsForSea(sea)
            currentIsland = newList[1] or "None"
            if islandChoice and islandChoice.SetValues then
                islandChoice.SetValues(newList, 1)
            end
        end

        AddChoice(tpCard, "Select Sea", {"Sea 1", "Sea 2", "Sea 3"}, detectedSea == "Sea 2" and 2 or (detectedSea == "Sea 3" and 3 or 1), function(v)
            UpdateIslands(v)
        end)

        local initialIslands = GetIslandsForSea(currentSea)
        currentIsland = initialIslands[1] or "WindMill"
        islandChoice = AddChoice(tpCard, "Target Island", initialIslands, 1, function(v)
            currentIsland = v
        end)
        AddSlider(tpCard, "Tween Speed", 150, 800, 350, 25, function(v)
            tweenSpeed = v
        end)
        AddSlider(tpCard, "Travel Altitude", 50, 500, 250, 25, function(v)
            travelAltitude = v
        end)
        AddToggle(tpCard, "Noclip during Tween", "Prevents getting stuck in terrain or barriers", false, function(v)
            noclipEnabled = v
        end)
        AddButton(tpCard, "Start Teleport", function()
            local seaData = IslandsData[currentSea] or IslandsData["Sea 1"]
            local cf = seaData[currentIsland]
            if cf then
                Notify("Teleport", "Teleporting to " .. currentIsland)
                StartTween(cf)
            else
                Notify("Teleport", "Island location not found.")
            end
        end)
        AddButton(tpCard, "Stop Teleport", StopTween)
    end)
end

-- ============================================================
-- 6. HUD TAB (DARLING HUB CONTROLS LAYOUT ENGINE)
-- ============================================================
do
    pcall(function()
        local HUDPage = RegisterTab("HUD", "HUD", "layout-dashboard")
        local hudCard1 = CreateCard(HUDPage, "Blox Fruits Controls HUD")

        local hudMod = nil
        local function getHUDMod()
            if not hudMod then
                hudMod = RequireModule("modules/ui/controls_hud.lua")
            end
            return hudMod
        end

        local editToggle = nil
        editToggle = AddToggle(hudCard1, "Unlock Dragging (Edit Controls)", "Allows dragging skill buttons (Z, X, C, V, F), dash, jump, and hotbar", false, function(v)
            local mod = getHUDMod()
            if mod then
                mod.SetEditMode(v)
            end
        end)

        local mod = getHUDMod()
        if mod then
            mod.OnModeChanged = function(active, reason)
                if editToggle and editToggle.set then
                    pcall(function() editToggle.set(active == true, true) end)
                end
            end
        end

        AddButton(hudCard1, "Save & Lock Custom Layout", function()
            local m = getHUDMod()
            if m then
                m.SetEditMode(false)
                Notify("HUD Editor", "Controls layout saved successfully.")
            end
        end)

        AddButton(hudCard1, "Discard Changes", function()
            local m = getHUDMod()
            if m then
                m.CancelEdit()
                Notify("HUD Editor", "Changes discarded. Restored last layout.")
            end
        end)

        AddButton(hudCard1, "Reset to Default Layout", function()
            local m = getHUDMod()
            if m then
                m.ResetLayout()
                Notify("HUD Editor", "Controls restored to default game positions.")
            end
        end)
    end)
end

-- ============================================================
-- 7. SKINS TAB (DARLING HUB ENGINE: MONODY VFX, TOOL SKINS, AVATAR CLONER)
-- ============================================================
do
    pcall(function()
        local SkinsPage = RegisterTab("Skins", "Skins", "gem")

        local skinsMod = nil
        local function getSkinsMod()
            if not skinsMod then
                skinsMod = RequireModule("modules/visuals/skins_system.lua")
            end
            return skinsMod
        end

        local VFX_PRESET_NAMES = {
            "Purple", "Red", "Blue", "Cyan", "Green", "Gold",
            "Pink", "Magenta", "White", "Black", "Midnight", "Orange",
            "Crimson", "Lime", "Silver", "Teal", "Ice Blue"
        }

        local TOOL_CATALOG_NAMES = {
            "Purple", "Red", "Blue", "Cyan", "Green", "Gold",
            "Pink", "White", "Black", "Crimson", "Lime", "Magenta",
            "Midnight", "Silver", "Orange"
        }

        local CHAR_TONE_NAMES = {
            "Darling Pink", "White", "Black", "Gold", "Cyan",
            "Crimson", "Green", "Purple", "Silver", "Orange"
        }

        local CHAR_MATERIALS = { "SmoothPlastic", "Neon", "ForceField", "Glass" }
        local TOOL_CATEGORIES = { "Fruits", "Swords", "Guns", "Melee" }

        local selectedVFXPreset = "Purple"
        local selectedToolCategory = "Fruits"
        local selectedToolPreset = "Purple"
        local selectedCharTone = "Darling Pink"
        local selectedCharMaterial = "SmoothPlastic"
        local avatarCloneInput = ""

        -- ----------------------------------------------------
        -- SECTION 1: MONODY VFX ENGINE
        -- ----------------------------------------------------
        local vfxCard = CreateCard(SkinsPage, "Monody VFX Engine")
        AddToggle(vfxCard, "Monody VFX Engine", "Dynamically recolors combat particles, fruit emitters and slashes", false, function(v)
            local mod = getSkinsMod()
            if mod then
                mod.setVFXEnabled(v)
                Notify("VFX Engine", v and "Monody VFX Enabled" or "Monody VFX Disabled")
            end
        end)

        AddChoice(vfxCard, "VFX Color Preset", VFX_PRESET_NAMES, 1, function(preset)
            selectedVFXPreset = preset
            local mod = getSkinsMod()
            if mod then
                local col = mod.Presets and mod.Presets[preset] or Color3.fromRGB(165, 80, 235)
                mod.setVFXColor(col)
                Notify("VFX Color", "VFX Color set to " .. preset)
            end
        end)

        AddToggle(vfxCard, "Affect Skills", "Recolors fruit and fighting style particle emitters", false, function(v)
            local mod = getSkinsMod()
            if mod then
                mod.VFX.AffectSkills = v
                if mod.VFX.Enabled then mod.refreshAllVFX() end
            end
        end)

        AddToggle(vfxCard, "Affect Swords", "Recolors sword slash highlights and trails", false, function(v)
            local mod = getSkinsMod()
            if mod then
                mod.VFX.AffectSwords = v
                if mod.VFX.Enabled then mod.refreshAllVFX() end
            end
        end)

        AddToggle(vfxCard, "Affect Transform", "Recolors Buddha, Dragon and Race V4 auras", false, function(v)
            local mod = getSkinsMod()
            if mod then
                mod.VFX.AffectTransform = v
                if mod.VFX.Enabled then mod.refreshAllVFX() end
            end
        end)

        AddToggle(vfxCard, "Affect Environment", "Recolors world origin ground and ambient effects", false, function(v)
            local mod = getSkinsMod()
            if mod then
                mod.VFX.AffectEnvironment = v
                if mod.VFX.Enabled then mod.refreshAllVFX() end
            end
        end)

        AddButton(vfxCard, "Reset Original VFX", function()
            local mod = getSkinsMod()
            if mod then
                mod.setVFXEnabled(false)
                mod.resetOriginalVFX()
                Notify("VFX Engine", "All combat particles restored to default colors.")
            end
        end)

        -- ----------------------------------------------------
        -- SECTION 2: TOOL SKINS & HOTBAR
        -- ----------------------------------------------------
        local toolCard = CreateCard(SkinsPage, "Tool Skins & Hotbar")

        AddChoice(toolCard, "Equipment Category", TOOL_CATEGORIES, 1, function(cat)
            selectedToolCategory = cat
            local mod = getSkinsMod()
            if mod then mod.Tools.SelectedCategory = cat end
        end)

        AddChoice(toolCard, "Skin Preset Catalog", TOOL_CATALOG_NAMES, 1, function(preset)
            selectedToolPreset = preset
        end)

        AddInput(toolCard, "Custom Asset ID (Optional)", "rbxassetid://... or image asset", "", function(val)
            local mod = getSkinsMod()
            if mod then mod.Tools.CustomAssetId = val or "" end
        end)

        AddButton(toolCard, "Apply Skin to Category", function()
            local mod = getSkinsMod()
            if mod then
                local cat = tostring(selectedToolCategory or "Fruits")
                local pr = tostring(selectedToolPreset or "Purple")
                mod.applyToolSkin(cat, pr)
                Notify(cat .. " Skin", pr .. " applied to " .. cat .. " and hotbar!")
            end
        end)

        AddButton(toolCard, "Apply Skin to All Hotbar Slots & Tools", function()
            local mod = getSkinsMod()
            if mod then
                local pr = tostring(selectedToolPreset or "Purple")
                local count = mod.recolorAllHotbarSlots(pr)
                Notify("Hotbar & Tools Skin", pr .. " applied to " .. tostring(count) .. " slots and inventory!")
            end
        end)

        AddButton(toolCard, "Reset Category Skin", function()
            local mod = getSkinsMod()
            if mod then
                mod.resetCategoryToolSkin(selectedToolCategory)
                Notify(selectedToolCategory .. " Skin", selectedToolCategory .. " skin reset to default.")
            end
        end)

        AddButton(toolCard, "Reset All Tool Skins", function()
            local mod = getSkinsMod()
            if mod then
                mod.resetAllToolSkins()
                Notify("Skins Reset", "All weapon skins and hotbar slots reset to default.")
            end
        end)

        -- ----------------------------------------------------
        -- SECTION 3: CHARACTER APPEARANCE
        -- ----------------------------------------------------
        local charCard = CreateCard(SkinsPage, "Character Appearance")

        AddToggle(charCard, "Enable Character Skin Changer", "Recolors avatar body parts with the selected skin preset", false, function(v)
            local mod = getSkinsMod()
            if mod then
                if v then
                    mod.applyCharacterSkin(selectedCharTone)
                    Notify("Character Skin", "Skin applied: " .. tostring(selectedCharTone))
                else
                    mod.resetCharacterSkin()
                    Notify("Character Skin", "Character appearance restored.")
                end
            end
        end)

        AddChoice(charCard, "Character Tone Preset", CHAR_TONE_NAMES, 1, function(preset)
            selectedCharTone = preset
            local mod = getSkinsMod()
            if mod and mod.Character and mod.Character.Enabled then
                mod.applyCharacterSkin(preset)
            end
        end)

        AddChoice(charCard, "Character Material", CHAR_MATERIALS, 1, function(matName)
            selectedCharMaterial = matName
            local mod = getSkinsMod()
            if mod then
                mod.Character.Material = Enum.Material[matName] or Enum.Material.SmoothPlastic
                if mod.Character.Enabled then
                    mod.applyCharacterSkin(selectedCharTone)
                end
            end
        end)

        AddToggle(charCard, "Character Particle Aura", "Adds holographic glowing outline aura to avatar", false, function(v)
            local mod = getSkinsMod()
            if mod then
                mod.setAuraEnabled(v)
            end
        end)

        AddButton(charCard, "Reset Character Appearance", function()
            local mod = getSkinsMod()
            if mod then
                mod.resetCharacterSkin()
                Notify("Character Skin", "Appearance restored to original game character.")
            end
        end)

        -- ----------------------------------------------------
        -- SECTION 4: AVATAR CLONER (CHARACTER SKIN / ASSET / USER)
        -- ----------------------------------------------------
        local clonerCard = CreateCard(SkinsPage, "Avatar Cloner (Character Changer)")

        AddButton(clonerCard, "Clone Nearest Player", function()
            local mod = getSkinsMod()
            if mod then
                local ok, msg = mod.cloneNearestPlayer()
                Notify("Avatar Cloner", msg or (ok and "Cloned nearest player avatar!" or "Failed to clone avatar"))
            end
        end)

        AddInput(clonerCard, "Player Name or User ID", "e.g. 12345678 or Roblox username...", "", function(val)
            avatarCloneInput = val or ""
        end)

        AddButton(clonerCard, "Clone by Name / User ID", function()
            if avatarCloneInput == "" then
                Notify("Avatar Cloner", "Please enter a valid Username or User ID first.")
                return
            end
            local mod = getSkinsMod()
            if mod then
                local ok, msg = mod.cloneByUserId(avatarCloneInput)
                Notify("Avatar Cloner", msg or (ok and "Target avatar applied!" or "Failed to load avatar"))
            end
        end)

        AddButton(clonerCard, "Restore Original Avatar", function()
            local mod = getSkinsMod()
            if mod and mod.resetClonedAvatar then
                local ok, msg = mod.resetClonedAvatar()
                Notify("Avatar Cloner", msg or (ok and "Restored original avatar appearance!" or "Avatar restored"))
            end
        end)
    end)
end

-- 8. MUSIC TAB (AUDIO CONTROLS & DARLING YOUTUBE MUSIC)
-- ============================================================
do
    pcall(function()
        local MusicPage = RegisterTab("Music", "Music", "headphones")

        -- 1. YouTube & External Players (Darling Hub Suite)
        local ytCard = CreateCard(MusicPage, "YouTube & External Players")

        AddButton(ytCard, "Launch Universal YouTube Player", function()
            Notify("YouTube Player", "Launching Universal YouTube Music Player...")
            task.spawn(function()
                local ok, err = pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua", true))()
                end)
                if not ok then
                    Notify("YouTube Player", "Failed to launch: " .. tostring(err))
                end
            end)
        end)

        -- 2. Roblox Audio Player & Visualizer Controls
        local mCard1 = CreateCard(MusicPage, "Roblox Audio Player")
        local customIdInput = "7025810761"

        local soundInputObj = AddInput(mCard1, "Custom Sound ID", "Enter Roblox Asset ID (e.g. 7025810761)...", "7025810761", function(v)
            customIdInput = tostring(v or "")
        end)

        AddButton(mCard1, "Play", function()
            local raw = (soundInputObj and soundInputObj.GetText and soundInputObj.GetText()) or customIdInput or "7025810761"
            local trimmed = tostring(raw):gsub("^%s+", ""):gsub("%s+$", "")
            if _G.MonodyMusic then
                if #trimmed > 0 then
                    _G.MonodyMusic.Play(trimmed, "")
                    Notify("Music Player", "Playing audio: " .. trimmed)
                else
                    _G.MonodyMusic.Play("7025810761", "Blox Fruits Main Theme")
                    Notify("Music Player", "Playing Blox Fruits Theme (7025810761)")
                end
            end
        end)

        AddButton(mCard1, "Pause", function()
            if _G.MonodyMusic then
                _G.MonodyMusic.Pause()
                Notify("Music Player", "Playback paused")
            end
        end)

        AddButton(mCard1, "Resume", function()
            if _G.MonodyMusic then
                _G.MonodyMusic.Resume()
                Notify("Music Player", "Playback resumed")
            end
        end)

        AddButton(mCard1, "Stop", function()
            if _G.MonodyMusic then
                _G.MonodyMusic.Stop()
                Notify("Music Player", "Playback stopped")
            end
        end)

        -- Quick Guaranteed & Local Bypass Audio Tracks
        AddButton(mCard1, "Play Montagem Phonk (Local Bypass)", function()
            if soundInputObj and soundInputObj.SetText then soundInputObj.SetText("https://raw.githubusercontent.com/rivals-hash/idk/main/assets/audio/phonk.mp3") end
            if _G.MonodyMusic and _G.MonodyMusic.PlayLocalBypass then
                _G.MonodyMusic.PlayLocalBypass("https://raw.githubusercontent.com/rivals-hash/idk/main/assets/audio/phonk.mp3", "monody_phonk.mp3", "Montagem Phonk")
            elseif _G.MonodyMusic then
                _G.MonodyMusic.Play("7025810761", "Montagem Phonk")
            end
        end)

        AddButton(mCard1, "Play Blox Fruits Theme (7025810761)", function()
            if soundInputObj and soundInputObj.SetText then soundInputObj.SetText("7025810761") end
            if _G.MonodyMusic then
                _G.MonodyMusic.Play("7025810761", "Blox Fruits Main Theme")
                Notify("Music Player", "Now playing: Blox Fruits Theme")
            end
        end)

        AddButton(mCard1, "Play One Piece Overtaken (6948625906)", function()
            if soundInputObj and soundInputObj.SetText then soundInputObj.SetText("6948625906") end
            if _G.MonodyMusic then
                _G.MonodyMusic.Play("6948625906", "One Piece Overtaken")
                Notify("Music Player", "Now playing: One Piece Overtaken")
            end
        end)

        AddButton(mCard1, "Play Spooky Theme (9114223171)", function()
            if soundInputObj and soundInputObj.SetText then soundInputObj.SetText("9114223171") end
            if _G.MonodyMusic then
                _G.MonodyMusic.Play("9114223171", "Spooky Theme")
                Notify("Music Player", "Now playing: Spooky Theme")
            end
        end)

        AddSlider(mCard1, "Volume", 0, 100, 100, 5, function(v)
            if _G.MonodyMusic then _G.MonodyMusic.SetVolume(v / 100) end
        end)

        AddSlider(mCard1, "Pitch / Speed", 0.5, 2.0, 1.0, 0.1, function(v)
            if _G.MonodyMusic then _G.MonodyMusic.SetPitch(v) end
        end)

        AddToggle(mCard1, "Loop Track", "Repeats the current song automatically", true, function(v)
            if _G.MonodyMusic then _G.MonodyMusic.SetLooped(v) end
        end)

        -- Mute Game Audio Feature
        local isGameMuted = false
        local originalSoundVolumes = setmetatable({}, { __mode = "k" })
        local muteConns = {}

        AddToggle(mCard1, "Mute Game Audio", "Silences ambient game SFX so only your music plays", false, function(v)
            isGameMuted = v
            if v then
                local targets = { game:GetService("SoundService"), Workspace }
                local pGui = lp:FindFirstChildOfClass("PlayerGui")
                if pGui then table.insert(targets, pGui) end
                for _, container in ipairs(targets) do
                    for _, obj in ipairs(container:GetDescendants()) do
                        if obj:IsA("Sound") and obj ~= (_G.MonodyMusic and _G.MonodyMusic.Sound) and obj.Name ~= "MonodyBGM" then
                            if originalSoundVolumes[obj] == nil then
                                originalSoundVolumes[obj] = obj.Volume
                            end
                            obj.Volume = 0
                        end
                    end
                    local conn = container.DescendantAdded:Connect(function(obj)
                        if isGameMuted and obj:IsA("Sound") and obj ~= (_G.MonodyMusic and _G.MonodyMusic.Sound) and obj.Name ~= "MonodyBGM" then
                            task.defer(function()
                                if isGameMuted and obj and obj.Parent then
                                    if originalSoundVolumes[obj] == nil then
                                        originalSoundVolumes[obj] = obj.Volume
                                    end
                                    obj.Volume = 0
                                end
                            end)
                        end
                    end)
                    table.insert(muteConns, conn)
                end
                Notify("Music Player", "Game audio muted.")
            else
                for _, conn in ipairs(muteConns) do
                    pcall(function() conn:Disconnect() end)
                end
                table.clear(muteConns)
                for obj, vol in pairs(originalSoundVolumes) do
                    if obj and obj.Parent then
                        pcall(function() obj.Volume = vol end)
                    end
                end
                table.clear(originalSoundVolumes)
                Notify("Music Player", "Game audio restored.")
            end
        end)

        AddToggle(mCard1, "Show Top Music Bar", "Displays the audio player on the top header", true, function(v)
            if _G.MonodyMusic and _G.MonodyMusic.TopBarFrame then
                _G.MonodyMusic.TopBarFrame.Visible = v
            end
        end)
    end)
end

-- ============================================================
-- 8. ANIMATIONS TAB (ORIGINAL DARLING HUB CINEMATIC ENGINES)
-- ============================================================
do
    pcall(function()
        local AnimationsPage = RegisterTab("Animations", "Animations", "sparkles")
        local aCard = CreateCard(AnimationsPage, "Darling Hub Cinematics")

        local CINEMATIC_NAMES = {
            "Worldbreaker", "King's Throne", "The Aureate Sanctuary", "Admin Cinematic"
        }
        local CINEMATIC_MODULES = {
            ["Worldbreaker"] = "modules/special/worldbreaker.lua",
            ["King's Throne"] = "modules/special/kings_throne.lua",
            ["The Aureate Sanctuary"] = "modules/special/sanctuary_cinematic.lua",
            ["Admin Cinematic"] = "modules/special/admin_cinematic.lua",
        }

        local selectedCinematic = "Worldbreaker"
        local activeCinematicMod = nil

        local function StopAllAnimations()
            if activeCinematicMod then
                pcall(function()
                    if activeCinematicMod.stop then
                        activeCinematicMod.stop()
                    elseif activeCinematicMod.dismiss then
                        activeCinematicMod.dismiss()
                    elseif activeCinematicMod.dismount then
                        activeCinematicMod.dismount()
                    end
                end)
                activeCinematicMod = nil
            end
            pcall(function()
                local char = lp.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then Workspace.CurrentCamera.CameraSubject = hum end
            end)
            Notify("Animations", "Cinematic cutscene stopped.")
        end

        local function PlayCinematic(name)
            StopAllAnimations()
            local relPath = CINEMATIC_MODULES[name]
            if not relPath then return end

            Notify("Cinematic", "Loading " .. name .. " engine...")
            local cinematic = RequireModule(relPath)
            if not cinematic then
                Notify("Cinematic", "Failed to load " .. name .. " module.")
                return
            end

            activeCinematicMod = cinematic
            Notify("Cinematic", "Now playing: " .. name)

            task.spawn(function()
                pcall(function()
                    if name == "King's Throne" then
                        if cinematic.play then
                            cinematic.play(StopAllAnimations)
                        elseif cinematic.mount then
                            cinematic.mount()
                        end
                    elseif name == "Admin Cinematic" then
                        if cinematic.play then
                            cinematic.play(nil, StopAllAnimations)
                        end
                    elseif name == "Worldbreaker" then
                        if cinematic.play then
                            cinematic.play(StopAllAnimations)
                        end
                    elseif name == "The Aureate Sanctuary" then
                        if cinematic.play then
                            cinematic.play(StopAllAnimations)
                        end
                    end
                end)
            end)
        end

        AddChoice(aCard, "Select Cinematic", CINEMATIC_NAMES, 1, function(v)
            selectedCinematic = v
        end)

        AddButton(aCard, "Play Cinematic", function()
            PlayCinematic(selectedCinematic)
        end)

        AddButton(aCard, "Skip Cinematic", StopAllAnimations)
    end)
end

-- 6. CONFIG TAB
do
local ConfigPage = RegisterTab("Config", "Config", "sliders-horizontal")
local MiscPage = ConfigPage
Pages["Misc"] = ConfigPage
Pages["Config"] = ConfigPage
local okMisc, errMisc = pcall(function()
    -- 1. Player Profile & Account Identity
    local playerCard = CreateCard(ConfigPage, "Player Profile")

    local playerRow = Instance.new("Frame", playerCard)
    playerRow.Name = "PlayerInfoRow"
    playerRow.Size = UDim2.new(1, 0, 0, 68)
    playerRow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    playerRow.BackgroundTransparency = 0.92
    playerRow.ZIndex = 12
    Instance.new("UICorner", playerRow).CornerRadius = UDim.new(0, 8)
    local plStroke = Instance.new("UIStroke", playerRow)
    plStroke.Color = Color3.fromRGB(255, 255, 255)
    plStroke.Thickness = 0.8
    plStroke.Transparency = 0.88

    local pAvatar = Instance.new("ImageLabel", playerRow)
    pAvatar.Name = "PlayerAvatar"
    pAvatar.Size = UDim2.new(0, 48, 0, 48)
    pAvatar.Position = UDim2.new(0, 10, 0.5, -24)
    pAvatar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    pAvatar.BackgroundTransparency = 0.88
    pAvatar.ZIndex = 13
    Instance.new("UICorner", pAvatar).CornerRadius = UDim.new(0, 8)
    local paStroke = Instance.new("UIStroke", pAvatar)
    paStroke.Color = CurrentAccent
    paStroke.Thickness = 0.8
    paStroke.Transparency = 0.85
    RegisterThemeStroke(paStroke)

    pcall(function()
        if lp and lp.UserId then
            pAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(lp.UserId) .. "&width=150&height=150&format=png"
        end
    end)

    local pInfo = Instance.new("Frame", playerRow)
    pInfo.Name = "PlayerDetails"
    pInfo.Size = UDim2.new(1, -72, 1, 0)
    pInfo.Position = UDim2.new(0, 68, 0, 0)
    pInfo.BackgroundTransparency = 1
    pInfo.ZIndex = 13

    local pName = Instance.new("TextLabel", pInfo)
    pName.Name = "DisplayName"
    pName.Size = UDim2.new(1, 0, 0, 20)
    pName.Position = UDim2.new(0, 0, 0, 8)
    pName.BackgroundTransparency = 1
    pName.Text = (lp and lp.DisplayName) and (lp.DisplayName .. " (@" .. lp.Name .. ")") or "Player"
    pName.TextColor3 = Color3.fromRGB(255, 255, 255)
    pName.Font = Enum.Font.GothamBold
    pName.TextSize = 12.5
    pName.TextXAlignment = Enum.TextXAlignment.Left
    pName.ZIndex = 13

    local pSub = Instance.new("TextLabel", pInfo)
    pSub.Name = "AccountMeta"
    pSub.Size = UDim2.new(1, 0, 0, 16)
    pSub.Position = UDim2.new(0, 0, 0, 28)
    pSub.BackgroundTransparency = 1
    local accAge = (lp and lp.AccountAge) and tostring(lp.AccountAge) .. " days" or "Unknown"
    local uid = (lp and lp.UserId) and tostring(lp.UserId) or "0"
    pSub.Text = "Account Age: " .. accAge .. "  •  UID: " .. uid
    pSub.TextColor3 = CurrentAccent
    pSub.Font = Enum.Font.GothamMedium
    pSub.TextSize = 9
    pSub.TextXAlignment = Enum.TextXAlignment.Left
    pSub.ZIndex = 13
    RegisterThemeText(pSub)

    local pRank = Instance.new("TextLabel", pInfo)
    pRank.Name = "StatusRank"
    pRank.Size = UDim2.new(1, 0, 0, 14)
    pRank.Position = UDim2.new(0, 0, 0, 44)
    pRank.BackgroundTransparency = 1
    pRank.Text = "Premium User  •  Active Session"
    RegisterTranslatable(pRank, "Premium User  •  Active Session")
    pRank.TextColor3 = Color3.fromRGB(180, 175, 200)
    pRank.Font = Enum.Font.Gotham
    pRank.TextSize = 8.5
    pRank.TextXAlignment = Enum.TextXAlignment.Left
    pRank.ZIndex = 13

    UpdateCardGeometry(playerCard)

    -- 2. Official Community & Discord
    local communityCard = CreateCard(ConfigPage, "Community")

    AddButton(communityCard, "Copy Discord Invite Link", function()
        local discordUrl = "https://discord.gg/DyG2BSMfVg"
        local copied = false
        if setclipboard then
            pcall(setclipboard, discordUrl)
            copied = true
        elseif toclipboard then
            pcall(toclipboard, discordUrl)
            copied = true
        end
        Notify("Discord", copied and "Link copied to clipboard!" or discordUrl)
    end)

    -- 3. Language & Localization
    local langCard = CreateCard(ConfigPage, "Language")
    AddChoice(langCard, "Interface Language", { "English", "Spanish", "Portuguese", "French", "Vietnamese" }, 1, function(val)
        ApplyLanguage(val)
        Notify("Language", "Language set to " .. val)
    end)

    -- 4. World & Client Optimization
    local clientCard = CreateCard(ConfigPage, "Performance")

    AddToggle(clientCard, "FFlags 1 (FPS Booster)", "120 FPS cap, smooth plastic textures, removes atmosphere fog, hides debris", false, function(state)
        SetFFlags1(state)
    end)

    AddToggle(clientCard, "No Animations", "Stops non-attack animations to fix sideways bug and character freezes", false, function(state)
        SetNoAnimations(state)
    end)

    AddButton(clientCard, "Apply Fast FFlags", function()
        ApplyFastFFlags()
    end)

    AddButton(clientCard, "Rejoin Current Server", function()
        RejoinServer()
    end)

    -- 5. Configuration Profiles
    local configCard = CreateCard(ConfigPage, "Config")

    AddButton(configCard, "Reset Config", function()
        if ResetConfigProfile then
            ResetConfigProfile()
        end
    end)

    -- 6. Development Team & Content Creators
    local creditsCard = CreateCard(ConfigPage, "Credits")

    local creatorRow = Instance.new("Frame", creditsCard)
    creatorRow.Size = UDim2.new(1, 0, 0, 70)
    creatorRow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    creatorRow.BackgroundTransparency = 0.92
    Instance.new("UICorner", creatorRow).CornerRadius = UDim.new(0, 8)
    local crStroke = Instance.new("UIStroke", creatorRow)
    crStroke.Color = Color3.fromRGB(255, 255, 255)
    crStroke.Thickness = 0.8
    crStroke.Transparency = 0.88

    local avatarImg = Instance.new("ImageLabel", creatorRow)
    avatarImg.Size = UDim2.new(0, 50, 0, 50)
    avatarImg.Position = UDim2.new(0, 10, 0.5, -25)
    avatarImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    avatarImg.BackgroundTransparency = 0.88
    avatarImg.Image = GetCreatorAsset()
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(0, 8)
    local avStroke = Instance.new("UIStroke", avatarImg)
    avStroke.Color = CurrentAccent
    avStroke.Thickness = 0.8
    avStroke.Transparency = 0.85
    RegisterThemeStroke(avStroke)

    local infoContainer = Instance.new("Frame", creatorRow)
    infoContainer.Size = UDim2.new(1, -75, 1, 0)
    infoContainer.Position = UDim2.new(0, 70, 0, 0)
    infoContainer.BackgroundTransparency = 1

    local nameLbl = Instance.new("TextLabel", infoContainer)
    nameLbl.Size = UDim2.new(1, 0, 0, 22)
    nameLbl.Position = UDim2.new(0, 0, 0, 10)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = "Darling"
    nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left

    local roleLbl1 = Instance.new("TextLabel", infoContainer)
    roleLbl1.Size = UDim2.new(1, 0, 0, 20)
    roleLbl1.Position = UDim2.new(0, 0, 0, 32)
    roleLbl1.BackgroundTransparency = 1
    roleLbl1.Text = "Developer & Content Creator"
    roleLbl1.TextColor3 = CurrentAccent
    roleLbl1.Font = Enum.Font.GothamMedium
    roleLbl1.TextSize = 9.5
    roleLbl1.TextXAlignment = Enum.TextXAlignment.Left
    RegisterThemeText(roleLbl1)
    RegisterTranslatable(roleLbl1, "Developer & Content Creator")

    UpdateCardGeometry(creditsCard)
end)
if not okMisc then
    warn("[Monody] Failed to initialize MiscPage: " .. tostring(errMisc))
end
end
-- 7. THEMES & CUSTOMIZATION STUDIO (FULL LUXURY ENGINE)
do
local ThemesPage = RegisterTab("Themes", "Themes", "palette")
local SettingsPage = ThemesPage
local okThemes, errThemes = pcall(function()
    -- 1. Palette Studio (Presets & Accents)
    local themeCard = CreateCard(ThemesPage, "Themes")

    local tGrid = Instance.new("Frame", themeCard)
    tGrid.Name = "ThemeColorGrid"
    tGrid.Size = UDim2.new(1, 0, 0, 60)
    tGrid.BackgroundTransparency = 1
    tGrid.ZIndex = 11
    local tgLayout = Instance.new("UIGridLayout", tGrid)
    tgLayout.CellSize = UDim2.new(0, 60, 0, 26)
    tgLayout.CellPadding = UDim2.new(0, 5, 0, 4)
    tgLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tGrid.Size = UDim2.new(1, 0, 0, math.max(tgLayout.AbsoluteContentSize.Y, 60))
        UpdateCardGeometry(themeCard)
    end)

    for _, name in ipairs(THEME_ORDER) do
        local col = THEMES[name]
        local tBtn = Instance.new("TextButton", tGrid)
        tBtn.Name = "ThemeBtn_" .. name
        tBtn.BackgroundColor3 = col
        tBtn.Text = ""
        tBtn.AutoButtonColor = false
        tBtn.Active = true
        tBtn.Selectable = true
        tBtn.ZIndex = 12
        Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 6)
        local btnStr = Instance.new("UIStroke", tBtn)
        btnStr.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        btnStr.Color = (name == CurrentThemeName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 35, 55)
        btnStr.Thickness = (name == CurrentThemeName) and 1.5 or 0.8

        local tLbl = Instance.new("TextLabel", tBtn)
        tLbl.Size = UDim2.new(1, 0, 1, 0)
        tLbl.BackgroundTransparency = 1
        tLbl.Font = Enum.Font.GothamBold
        tLbl.TextSize = 7.5
        tLbl.TextColor3 = (name == "White") and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        tLbl.Text = name
        tLbl.ZIndex = 13

        ThemeButtons[name] = tBtn
        ConnectButton(tBtn, function()
            ApplyTheme(name)
            for btnName, b in pairs(ThemeButtons) do
                local s = b:FindFirstChildOfClass("UIStroke")
                if s then
                    s.Color = (btnName == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 35, 55)
                    s.Thickness = (btnName == name) and 1.5 or 0.8
                end
            end
            Notify("Theme", "Theme updated to " .. name)
        end)
    end
    UpdateThemeColors()
    UpdateCardGeometry(themeCard)

    AddButton(themeCard, "Toggle Rainbow Chroma Mode", function()
        ApplyTheme("Rainbow")
        Notify("Theme", "Rainbow theme enabled")
    end)

    AddButton(themeCard, "Reset Theme to White", function()
        ResetTheme()
        Notify("Theme", "Theme reset to White")
    end)

    AddSlider(themeCard, "Rainbow Chroma Speed", 1, 20, math.floor(RainbowSpeed * 10), 1, function(val)
        RainbowSpeed = val / 10
    end)

    -- 2. Custom Wallpaper Studio (Asset ID or URL)
    local wpCustomCard = CreateCard(ThemesPage, "Custom Wallpaper")

    local customInput = AddInput(wpCustomCard, "Roblox Asset ID or Media URL", "e.g. 103674761222554 or rbxassetid://...", "", function(val)
        ApplyCustomWallpaper(val)
    end)

    local btnRow = Instance.new("Frame", wpCustomCard)
    btnRow.Name = "CustomWpBtnRow"
    btnRow.Size = UDim2.new(1, 0, 0, 28)
    btnRow.BackgroundTransparency = 1
    btnRow.ZIndex = 11
    local bLayout = Instance.new("UIGridLayout", btnRow)
    bLayout.CellSize = UDim2.new(0.5, -4, 1, 0)
    bLayout.CellPadding = UDim2.new(0, 8, 0, 0)

    local applyBtn = Instance.new("TextButton", btnRow)
    applyBtn.Name = "ApplyWpBtn"
    applyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    applyBtn.BackgroundTransparency = 0.92
    applyBtn.Text = ""
    applyBtn.AutoButtonColor = false
    applyBtn.Active = true
    applyBtn.Selectable = true
    applyBtn.ZIndex = 12
    Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 6)
    local aStr = Instance.new("UIStroke", applyBtn)
    aStr.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    aStr.Color = CurrentAccent
    aStr.Thickness = 0.8
    aStr.Transparency = 0.85
    RegisterThemeStroke(aStr)

    local aLbl = Instance.new("TextLabel", applyBtn)
    aLbl.Size = UDim2.new(1, 0, 1, 0)
    aLbl.BackgroundTransparency = 1
    aLbl.Font = Enum.Font.GothamBold
    aLbl.TextSize = 8.5
    aLbl.TextColor3 = CurrentAccent
    aLbl.Text = "Apply Wallpaper"
    aLbl.ZIndex = 13
    RegisterThemeText(aLbl)
    RegisterTranslatable(aLbl, "Apply Wallpaper")

    ConnectButton(applyBtn, function()
        ApplyCustomWallpaper(customInput.GetText())
    end)

    local clearBtn = Instance.new("TextButton", btnRow)
    clearBtn.Name = "ClearWpBtn"
    clearBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.BackgroundTransparency = 0.92
    clearBtn.Text = ""
    clearBtn.AutoButtonColor = false
    clearBtn.Active = true
    clearBtn.Selectable = true
    clearBtn.ZIndex = 12
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)
    local cStr = Instance.new("UIStroke", clearBtn)
    cStr.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cStr.Color = Color3.fromRGB(255, 255, 255)
    cStr.Thickness = 0.8
    cStr.Transparency = 0.88

    local cLbl = Instance.new("TextLabel", clearBtn)
    cLbl.Size = UDim2.new(1, 0, 1, 0)
    cLbl.BackgroundTransparency = 1
    cLbl.Font = Enum.Font.GothamBold
    cLbl.TextSize = 8.5
    cLbl.TextColor3 = Color3.fromRGB(200, 195, 215)
    cLbl.Text = "Clear / Dark Glass"
    cLbl.ZIndex = 13
    RegisterTranslatable(cLbl, "Clear / Dark Glass")

    ConnectButton(clearBtn, function()
        ApplyCustomWallpaper("none")
    end)
    UpdateCardGeometry(wpCustomCard)

    -- 3. Wallpaper Atmosphere Presets (Full 24 Styles)
    local wpCard = CreateCard(ThemesPage, "Wallpapers")

    local wpStatus = Instance.new("TextLabel", wpCard)
    wpStatus.Size = UDim2.new(1, 0, 0, 20)
    wpStatus.BackgroundTransparency = 1
    wpStatus.Text = string.format("Active: [%02d/%02d] %s", currentBgIdx, #WALLPAPERS, WALLPAPERS[currentBgIdx].name)
    wpStatus.Font = Enum.Font.GothamBold
    wpStatus.TextSize = 9
    wpStatus.TextColor3 = CurrentAccent
    wpStatus.TextXAlignment = Enum.TextXAlignment.Left
    wpStatus.Active = false
    wpStatus.ZIndex = 11
    RegisterThemeText(wpStatus)

    local wpNamesList = {}
    for i, wp in ipairs(WALLPAPERS) do
        table.insert(wpNamesList, string.format("[%02d] %s", i, wp.name))
    end

    local wpChoice = AddChoice(wpCard, "Direct Wallpaper", wpNamesList, currentBgIdx, function(val, idx)
        SetWallpaper(idx)
    end)

    RegisterWallpaperListener(function(idx, wp)
        if wpStatus and wpStatus.Parent then
            wpStatus.Text = string.format("Active: [%02d/%02d] %s", idx, #WALLPAPERS, wp.name)
        end
        if wpChoice and wpChoice.SetIndex then
            wpChoice.SetIndex(idx, false)
        end
    end)

    -- Navigation row
    local navRow = Instance.new("Frame", wpCard)
    navRow.Name = "WpNavRow"
    navRow.Size = UDim2.new(1, 0, 0, 28)
    navRow.BackgroundTransparency = 1
    navRow.ZIndex = 11

    local nLayout = Instance.new("UIGridLayout", navRow)
    nLayout.CellSize = UDim2.new(0.333, -5, 1, 0)
    nLayout.CellPadding = UDim.new(0, 7, 0, 0)

    local function makeNavBtn(txt, callback)
        local btn = Instance.new("TextButton", navRow)
        btn.Name = "NavBtn_" .. txt:sub(1, 6):gsub("[^%w_]+", "_")
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundTransparency = 0.92
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Active = true
        btn.Selectable = true
        btn.ZIndex = 12
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local bStr = Instance.new("UIStroke", btn)
        bStr.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        bStr.Color = Color3.fromRGB(255, 255, 255)
        bStr.Thickness = 0.8
        bStr.Transparency = 0.85
        RegisterThemeStroke(bStr)

        local bLbl = Instance.new("TextLabel", btn)
        bLbl.Size = UDim2.new(1, 0, 1, 0)
        bLbl.BackgroundTransparency = 1
        bLbl.Font = Enum.Font.GothamBold
        bLbl.TextSize = 8.5
        bLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        bLbl.Text = txt
        bLbl.ZIndex = 13
        RegisterTranslatable(bLbl, txt)

        ConnectButton(btn, callback)
        return btn
    end

    makeNavBtn("Previous (‹)", function()
        local prevIdx = currentBgIdx - 1
        if prevIdx < 1 then prevIdx = #WALLPAPERS end
        SetWallpaper(prevIdx)
    end)

    makeNavBtn("Random (Shuffle)", function()
        local randIdx = math.random(1, #WALLPAPERS)
        SetWallpaper(randIdx)
    end)

    makeNavBtn("Next (›)", function()
        local nextIdx = currentBgIdx + 1
        if nextIdx > #WALLPAPERS then nextIdx = 1 end
        SetWallpaper(nextIdx)
    end)

    -- Direct Preset Grid Selector
    local presetGrid = Instance.new("Frame", wpCard)
    presetGrid.Name = "WallpaperPresetGrid"
    presetGrid.Size = UDim2.new(1, 0, 0, 340)
    presetGrid.BackgroundTransparency = 1
    presetGrid.ZIndex = 11
    local pGLayout = Instance.new("UIGridLayout", presetGrid)
    pGLayout.CellSize = UDim2.new(0.5, -4, 0, 24)
    pGLayout.CellPadding = UDim.new(0, 8, 0, 4)
    pGLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        presetGrid.Size = UDim2.new(1, 0, 0, math.max(pGLayout.AbsoluteContentSize.Y, 340))
        UpdateCardGeometry(wpCard)
    end)

    for i, wp in ipairs(WALLPAPERS) do
        local pBtn = Instance.new("TextButton", presetGrid)
        pBtn.Name = "WpBtn_" .. tostring(i)
        pBtn.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
        pBtn.BackgroundTransparency = 0.55
        pBtn.Text = ""
        pBtn.AutoButtonColor = false
        pBtn.Active = true
        pBtn.Selectable = true
        pBtn.ZIndex = 12
        Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 5)
        local pStr = Instance.new("UIStroke", pBtn)
        pStr.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        pStr.Color = (i == currentBgIdx) and CurrentAccent or Color3.fromRGB(45, 40, 60)
        pStr.Thickness = 0.8

        local pLbl = Instance.new("TextLabel", pBtn)
        pLbl.Size = UDim2.new(1, 0, 1, 0)
        pLbl.BackgroundTransparency = 1
        pLbl.Font = Enum.Font.GothamBold
        pLbl.TextSize = 7.5
        pLbl.TextColor3 = Color3.fromRGB(220, 215, 240)
        pLbl.Text = string.format("[%02d] %s", i, wp.name:sub(1, 16))
        pLbl.TextXAlignment = Enum.TextXAlignment.Center
        pLbl.ZIndex = 13

        ConnectButton(pBtn, function()
            SetWallpaper(i)
        end)
    end
    UpdateCardGeometry(wpCard)

    AddSlider(wpCard, "Background Dimming (%)", 0, 85, math.floor(WallpaperDimOverlay.BackgroundTransparency * 100), 5, function(val)
        WallpaperDimOverlay.BackgroundTransparency = val / 100
    end)

    -- 3. Glass Interface & Visual Effects
    local vfxCard = CreateCard(ThemesPage, "Interface Effects")

    AddToggle(vfxCard, "Neon Rain Layer", "Toggle animated falling cyber rain streaks", RainEnabled, function(state)
        RainEnabled = state
        if RainEnabled and Main.Visible then
            StartRainAnimation()
        else
            StopRainAnimation()
        end
    end)

    AddSlider(vfxCard, "Raindrop Density", 4, 30, MaxRainDrops, 2, function(val)
        MaxRainDrops = val
        if RainEnabled and Main.Visible then
            StopRainAnimation()
            StartRainAnimation()
        end
    end)

    AddChoice(vfxCard, "Glass Transparency", { "Subtle (50%)", "Balanced (65%)", "Crystal (80%)" }, 2, function(val, index)
        local transparency = ({ 0.50, 0.65, 0.80 })[index]
        for _, frame in ipairs(GlassFrames) do
            if frame and frame.Parent then frame.BackgroundTransparency = transparency end
        end
    end)

    AddChoice(vfxCard, "Typography Font", FONT_ORDER, 1, function(val)
        ApplyFont(val)
    end)

    AddChoice(vfxCard, "Interface Scale", { "Compact (80%)", "Standard (100%)", "Large (120%)" }, 2, function(val, index)
        MainScale.Scale = ({ 0.8, 1, 1.2 })[index]
    end)

    -- 4. Aesthetic Presets Studio
    local presetCard = CreateCard(ThemesPage, "Theme Presets")

    local function applyPreset(themeName, wpIdx, dimPct)
        ApplyTheme(themeName)
        SetWallpaper(wpIdx)
        WallpaperDimOverlay.BackgroundTransparency = dimPct / 100
        Notify("Preset", "Applied " .. themeName .. " preset")
    end

    AddButton(presetCard, "Preset: Cyberpunk Violet", function()
        applyPreset("Purple", 9, 35)
    end)

    AddButton(presetCard, "Preset: Crimson Slayer", function()
        applyPreset("Red", 7, 40)
    end)

    AddButton(presetCard, "Preset: Emerald Forest", function()
        applyPreset("Green", 15, 35)
    end)

    AddButton(presetCard, "Preset: Shorekeeper Cyan", function()
        applyPreset("Cyan", 12, 30)
    end)

    -- 5. Factory Reset Card
    local resetCard = CreateCard(ThemesPage, "Theme Reset")
    AddButton(resetCard, "Reset All Settings to Factory Defaults", function()
        ResetUIConfig()
        Notify(APP_TITLE, "All UI settings reset to defaults")
    end)
end)
if not okThemes then
    warn("[Monody] Failed to initialize ThemesPage: " .. tostring(errThemes))
end
end

-- ============================================================
-- INITIALIZATION
-- ============================================================
SelectTabById("Home")

if LoadConfigProfile then
    LoadConfigProfile()
end
suspendSave = false

uiReadyToOpen = true
if introCompleted then
    triggerUIOpen()
end
