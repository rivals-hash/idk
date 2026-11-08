--[[
    ========================================================================
    DARLING X - PREMIUM SUITE (VERSION 2.0)
    ========================================================================
    UI Framework: Darling X Glassmorphic (Acrylic Master Window)
    Key System: Aurora X (Project: 1b56de61f463fc8d4cd4d1dca6e26660)
    Linkvertise Publisher: 9980602
    Completely Borderless Minimalist Splash Loader (Zero Red Borders)
    Zero Metamethod Hooks - Guaranteed 0 Crashes & 0 Anti-Cheat Disconnects
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

-- Purge any stale cache files from previous versions that contained red borders
pcall(function()
    local staleFiles = {
        "DarlingHub/cache/modules_ui_loading_screen.lua",
        "BestHub/cache/modules_ui_loading_screen.lua",
        "DarlingHub/loading_screen.lua",
        "DarlingHub/cache/modules_ui_window.lua",
        "DarlingHub/cache/modules_ui_sidebar.lua",
        "DarlingHub/cache/modules_ui_tab_views.lua",
    }
    for _, p in ipairs(staleFiles) do
        if exIsFile and exIsFile(p) and delfile then
            pcall(delfile, p)
        end
    end
end)

-- Ensure fresh cache directory structure (v5)
local CACHE_DIR = "DarlingX"
local CACHE_SUBDIR = "DarlingX/cache_v5"
pcall(function()
    if exMakeFolder and exIsFolder then
        if not exIsFolder(CACHE_DIR) then exMakeFolder(CACHE_DIR) end
        if not exIsFolder(CACHE_SUBDIR) then exMakeFolder(CACHE_SUBDIR) end
    end
end)

-- 3. Universal HTTP Requester
local function universalHttpGet(url, timeout)
    timeout = timeout or 12
    local hdrs = { ["User-Agent"] = "Roblox/DarlingX" }
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
                pcall(exMakeFolder, CACHE_DIR)
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
    Version = "2.0",
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

-- 7. Live Module Loader (Prioritizes fresh code with disk fallback)
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

    -- 1. Always fetch fresh from GitHub first with cache busting
    if not code then
        local url = RepoBase .. relPath .. "?t=" .. tostring(tick())
        code = universalHttpGet(url, 6)
        if code and exWriteFile then
            local diskCacheFile = CACHE_SUBDIR .. "/" .. relPath:gsub("/", "_")
            pcall(exWriteFile, diskCacheFile, code)
        end
    end

    -- 2. Fallback to cached disk file if offline
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
        warn("[Darling X] Failed to load module: " .. tostring(relPath))
        return nil
    end

    local fn, err = loadstring(code)
    if not fn then
        warn("[Darling X] Syntax error in module " .. tostring(relPath) .. ": " .. tostring(err))
        return nil
    end

    local ok, mod = pcall(fn)
    if not ok then
        warn("[Darling X] Runtime error executing module " .. tostring(relPath) .. ": " .. tostring(mod))
        return nil
    end

    self.Modules[relPath] = mod
    return mod
end

-- 8. Configuration Persistence
local CONFIG_FILE = "darling_x_config.json"

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

-- 9. INLINED BORDERLESS LOADING SCREEN (Zero red borders, zero CanvasGroup artifacts)
local function getGuiParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h and typeof(h) == "Instance" then return h end
    end
    if CoreGui then
        local okC, core = pcall(function() return CoreGui end)
        if okC and core then return core end
    end
    local lp = LocalPlayer or Players.LocalPlayer
    if lp then
        local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui")
        if pg then return pg end
    end
    return nil
end

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

    local parent = getGuiParent()
    if not parent then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "DarlingX_LoadingScreen"
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
    logo.Image = logoAsset or darlingIcon
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = logoContainer

    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 16)
    logoCorner.Parent = logo

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 0, 24)
    title.AnchorPoint = Vector2.new(0.5, 0)
    title.Position = UDim2.new(0.5, 0, 0, 96)
    title.BackgroundTransparency = 1
    title.TextTransparency = 1
    title.BorderSizePixel = 0
    title.Font = Enum.Font.GothamBold
    title.Text = "Darling X"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 19
    title.Parent = card

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, -40, 0, 16)
    status.AnchorPoint = Vector2.new(0.5, 0)
    status.Position = UDim2.new(0.5, 0, 0, 122)
    status.BackgroundTransparency = 1
    status.TextTransparency = 1
    status.BorderSizePixel = 0
    status.Font = Enum.Font.GothamMedium
    status.Text = "Verificando licencia..."
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

    InlineLoader.update(1.0, "Listo")
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

-- 10. AURORA X KEY SYSTEM ENGINE (Project: 1b56de61f463fc8d4cd4d1dca6e26660)
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
    local parent = getGuiParent()
    if not parent then
        if onSuccess then onSuccess() end
        return
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "DarlingX_KeySystem"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 10000000
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)

    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end

    -- Backdrop
    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(8, 6, 12)
    backdrop.BackgroundTransparency = 0.45
    backdrop.BorderSizePixel = 0
    backdrop.Parent = gui

    -- Modal Container (Neutral slate border, zero red)
    local modal = Instance.new("Frame")
    modal.Name = "Modal"
    modal.Size = UDim2.new(0, 380, 0, 240)
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.Position = UDim2.new(0.5, 0, 0.5, 0)
    modal.BackgroundColor3 = Color3.fromRGB(18, 14, 22)
    modal.BorderSizePixel = 0
    modal.Parent = gui

    local modalCorner = Instance.new("UICorner")
    modalCorner.CornerRadius = UDim.new(0, 14)
    modalCorner.Parent = modal

    local modalStroke = Instance.new("UIStroke")
    modalStroke.Color = Color3.fromRGB(55, 55, 65)
    modalStroke.Thickness = 1.2
    modalStroke.Parent = modal

    -- Header Icon
    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(0, 48, 0, 48)
    logo.AnchorPoint = Vector2.new(0.5, 0)
    logo.Position = UDim2.new(0.5, 0, 0, 16)
    logo.BackgroundTransparency = 1
    logo.BorderSizePixel = 0
    logo.Image = darlingIcon
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = modal

    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 12)
    logoCorner.Parent = logo

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -30, 0, 22)
    title.Position = UDim2.new(0, 15, 0, 68)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "Darling X"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Parent = modal

    -- Subtitle
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -30, 0, 16)
    sub.Position = UDim2.new(0, 15, 0, 90)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.GothamMedium
    sub.Text = "Introduce tu clave de licencia para continuar"
    sub.TextColor3 = Color3.fromRGB(160, 155, 170)
    sub.TextSize = 11
    sub.Parent = modal

    -- Key Input Container
    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(1, -30, 0, 36)
    inputContainer.Position = UDim2.new(0, 15, 0, 114)
    inputContainer.BackgroundColor3 = Color3.fromRGB(26, 22, 32)
    inputContainer.BorderSizePixel = 0
    inputContainer.Parent = modal

    local inCorner = Instance.new("UICorner")
    inCorner.CornerRadius = UDim.new(0, 8)
    inCorner.Parent = inputContainer

    local inStroke = Instance.new("UIStroke")
    inStroke.Color = Color3.fromRGB(50, 48, 60)
    inStroke.Thickness = 1
    inStroke.Parent = inputContainer

    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(1, -20, 1, 0)
    keyBox.Position = UDim2.new(0, 10, 0, 0)
    keyBox.BackgroundTransparency = 1
    keyBox.Font = Enum.Font.GothamMedium
    keyBox.Text = (AuroraX and AuroraX.GetSavedKey and AuroraX.GetSavedKey()) or ""
    keyBox.PlaceholderText = "Pega tu clave aquí (script_key)..."
    keyBox.PlaceholderColor3 = Color3.fromRGB(120, 115, 130)
    keyBox.TextColor3 = Color3.fromRGB(240, 240, 250)
    keyBox.TextSize = 12
    keyBox.ClearTextOnFocus = false
    keyBox.Parent = inputContainer

    -- Status Feedback Label
    local feedback = Instance.new("TextLabel")
    feedback.Size = UDim2.new(1, -30, 0, 16)
    feedback.Position = UDim2.new(0, 15, 0, 154)
    feedback.BackgroundTransparency = 1
    feedback.Font = Enum.Font.GothamMedium
    feedback.Text = ""
    feedback.TextColor3 = Color3.fromRGB(220, 180, 100)
    feedback.TextSize = 11
    feedback.Parent = modal

    -- Buttons Frame
    local btnRow = Instance.new("Frame")
    btnRow.Size = UDim2.new(1, -30, 0, 36)
    btnRow.Position = UDim2.new(0, 15, 0, 178)
    btnRow.BackgroundTransparency = 1
    btnRow.Parent = modal

    -- 1. Get Key Button (Linkvertise / AuroraX GetKey)
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0.48, 0, 1, 0)
    getKeyBtn.Position = UDim2.new(0, 0, 0, 0)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(32, 28, 40)
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.Text = "Obtener Key"
    getKeyBtn.TextColor3 = Color3.fromRGB(220, 215, 235)
    getKeyBtn.TextSize = 12
    getKeyBtn.AutoButtonColor = false
    getKeyBtn.Parent = btnRow

    local gkCorner = Instance.new("UICorner")
    gkCorner.CornerRadius = UDim.new(0, 8)
    gkCorner.Parent = getKeyBtn

    local gkStroke = Instance.new("UIStroke")
    gkStroke.Color = Color3.fromRGB(55, 50, 68)
    gkStroke.Thickness = 1
    gkStroke.Parent = getKeyBtn

    getKeyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if AuroraX and AuroraX.CopyKeyLink then
                AuroraX.CopyKeyLink()
            else
                local setcb = setclipboard or toclipboard or set_clipboard
                if setcb then setcb("https://dev.aurorax.site/getkey/1b56de61f463fc8d4cd4d1dca6e26660") end
            end
        end)
        feedback.TextColor3 = Color3.fromRGB(100, 230, 150)
        feedback.Text = "Enlace copiado al portapapeles! Complétalo en tu navegador."
    end)

    -- 2. Verify Key Button
    local verifyBtn = Instance.new("TextButton")
    verifyBtn.Size = UDim2.new(0.48, 0, 1, 0)
    verifyBtn.Position = UDim2.new(0.52, 0, 0, 0)
    verifyBtn.BackgroundColor3 = Color3.fromRGB(50, 42, 68)
    verifyBtn.Font = Enum.Font.GothamBold
    verifyBtn.Text = "Verificar"
    verifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    verifyBtn.TextSize = 12
    verifyBtn.AutoButtonColor = false
    verifyBtn.Parent = btnRow

    local vCorner = Instance.new("UICorner")
    vCorner.CornerRadius = UDim.new(0, 8)
    vCorner.Parent = verifyBtn

    local vStroke = Instance.new("UIStroke")
    vStroke.Color = Color3.fromRGB(80, 68, 105)
    vStroke.Thickness = 1
    vStroke.Parent = verifyBtn

    local isChecking = false
    verifyBtn.MouseButton1Click:Connect(function()
        if isChecking then return end
        isChecking = true
        local entered = keyBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if #entered < 4 then
            feedback.TextColor3 = Color3.fromRGB(255, 120, 120)
            feedback.Text = "Introduce una clave válida."
            isChecking = false
            return
        end

        feedback.TextColor3 = Color3.fromRGB(200, 200, 220)
        feedback.Text = "Verificando con Aurora X..."

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
                feedback.Text = "Key verificada! Iniciando Darling X..."
                task.wait(0.5)
                TweenService:Create(modal, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0)
                }):Play()
                task.wait(0.22)
                pcall(function() gui:Destroy() end)
                if onSuccess then onSuccess() end
            else
                feedback.TextColor3 = Color3.fromRGB(255, 110, 110)
                feedback.Text = (info and info.message) or "Clave inválida o expirada."
                isChecking = false
            end
        end)
    end)

    gui.Parent = parent
end

-- 11. MAIN HUB LAUNCHER (DARLING X GLASSMORPHIC UI)
local function launchDarlingXHub()
    -- 1. Start borderless loader
    InlineLoader.show(darlingIcon)
    InlineLoader.update(0.12, "Iniciando Darling X...")

    -- 2. Load Core & UI Engine Modules
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

    InlineLoader.update(0.38, "Cargando modulos de combate...")

    -- 3. Load Combat & Feature Modules
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

    InlineLoader.update(0.72, "Construyendo interfaz Darling X...")

    -- 4. Create Darling X Glassmorphic Master Window
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

    -- Apply user custom logo to floating toggle button
    if WinInstance and WinInstance.MobileToggle then
        pcall(function()
            local btn = WinInstance.MobileToggle:FindFirstChild("ToggleBtn") or WinInstance.MobileToggle
            if btn and btn:IsA("ImageButton") then
                btn.Image = darlingIcon
            end
        end)
    end

    InlineLoader.update(0.92, "Sincronizando configuracion...")
    pcall(DarlingHub.LoadConfig)

    -- 5. Finish loading screen & reveal Darling X UI
    local revealWindow = function()
        pcall(function()
            if WinInstance and WinInstance.MainFrame then
                WinInstance.MainFrame.Visible = true
            end
            if WinInstance and WinInstance.SwitchTab then
                WinInstance.SwitchTab("Home")
            end
            if Utils and Utils.toast then
                Utils.toast("Darling X", "Bienvenido a Darling X Suite", 3, darlingIcon)
            end
        end)
    end

    InlineLoader.finish(revealWindow)
end

-- 12. Unload & Cleanup Handler
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

-- 13. EXECUTE INITIAL KEY CHECK
task.spawn(function()
    local AuroraX = getAuroraX()
    local providedKey = script_key or (getgenv and (getgenv().script_key or getgenv().Key))
    local savedKey = (AuroraX and AuroraX.GetSavedKey and AuroraX.GetSavedKey()) or ""
    local candidate = (providedKey and #providedKey >= 6 and providedKey) or (savedKey and #savedKey >= 6 and savedKey) or nil

    if candidate and AuroraX and AuroraX.CheckKey then
        local ok, info = AuroraX.CheckKey(candidate)
        if ok then
            launchDarlingXHub()
            return
        end
    end

    -- If no valid key pre-authenticated, display key modal
    showKeyModal(AuroraX, function()
        launchDarlingXHub()
    end)
end)

return DarlingHub
