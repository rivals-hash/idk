--[[
    ============================================================
    MONODY - OFFICIAL CLIENT KEY LOADER (AuroraX Protected)
    Project: Monody (7c5669e64021da7e13601d7cc9913ee9)
    ============================================================
]]--

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer

local APP_TITLE = "Monody"
local APP_VERSION = "v1.4"
local function GetPlayerThumbnail(size)
    local s = size or 150
    local uid = (lp and lp.UserId and lp.UserId > 0 and lp.UserId) or 1
    return string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=%d&h=%d", uid, s, s)
end

local DEFAULT_LOGO_ID = GetPlayerThumbnail(150)
local GITHUB_REPO_RAW = "https://raw.githubusercontent.com/rivals-hash/idk/main"

local exIsFile = isfile or is_file
local exWriteFile = writefile or write_file
local exMakeFolder = makefolder or make_folder
local exGetCustomAsset = getcustomasset or getsynasset

local function SafeHttpGet(url)
    local okHttp, body = pcall(function() return game:HttpGet(url, true) end)
    if okHttp and type(body) == "string" and #body > 50 then return body end
    return nil
end

local function ResolveCustomAsset(relativePath, fallbackAssetId)
    if not exGetCustomAsset or not exIsFile then return fallbackAssetId end
    local candidatePaths = {
        relativePath,
        "Monody/" .. relativePath,
        "DarlingX/" .. relativePath,
        "assets/" .. relativePath:gsub("^assets/", ""),
        relativePath:gsub(".+/", "")
    }
    for _, path in ipairs(candidatePaths) do
        local okCheck, exists = pcall(exIsFile, path)
        if okCheck and exists then
            local okAsset, asset = pcall(exGetCustomAsset, path)
            if okAsset and type(asset) == "string" and #asset > 0 then return asset end
        end
    end
    return fallbackAssetId
end

local function EnsureCustomAsset(filename)
    if not (exWriteFile and exGetCustomAsset) then return nil end
    local candidatePaths = {
        "Monody/cache/" .. filename,
        filename,
        "assets/" .. filename,
        "Monody/" .. filename,
        "DarlingX/" .. filename
    }
    for _, p in ipairs(candidatePaths) do
        if exIsFile then
            local okCheck, exists = pcall(exIsFile, p)
            if okCheck and exists then
                local okAsset, asset = pcall(exGetCustomAsset, p)
                if okAsset and type(asset) == "string" and #asset > 0 then
                    return asset
                end
            end
        end
    end

    local body = SafeHttpGet(GITHUB_REPO_RAW .. "/assets/" .. filename)
    if body and #body > 50 then
        pcall(function()
            if exMakeFolder then
                pcall(exMakeFolder, "Monody")
                pcall(exMakeFolder, "Monody/cache")
            end
            pcall(exWriteFile, "Monody/cache/" .. filename, body)
            pcall(exWriteFile, filename, body)
        end)
        local okAsset, asset = pcall(exGetCustomAsset, "Monody/cache/" .. filename)
        if okAsset and type(asset) == "string" and #asset > 0 then return asset end
        local okAsset2, asset2 = pcall(exGetCustomAsset, filename)
        if okAsset2 and type(asset2) == "string" and #asset2 > 0 then return asset2 end
    end
    return nil
end

local function BindPhoto(imgLabel, customFilename)
    if not imgLabel then return end
    -- Immediately set player avatar headshot (Roblox C++ engine, NEVER blank)
    imgLabel.Image = GetPlayerThumbnail(150)

    -- Check if custom anime photo is already cached
    local fn = customFilename or "floating_avatar_white.png"
    if exIsFile and exGetCustomAsset then
        local quickPaths = { "Monody/cache/" .. fn, fn, "assets/" .. fn }
        for _, p in ipairs(quickPaths) do
            local okCheck, exists = pcall(exIsFile, p)
            if okCheck and exists then
                local okAsset, asset = pcall(exGetCustomAsset, p)
                if okAsset and type(asset) == "string" and #asset > 0 then
                    imgLabel.Image = asset
                    return
                end
            end
        end
    end

    -- Asynchronously download and bind custom anime photo
    task.spawn(function()
        local asset = EnsureCustomAsset(fn)
        if asset and imgLabel and imgLabel.Parent then
            imgLabel.Image = asset
        end
    end)
end

-- Parent GUI selector
local parentGui = nil
pcall(function() if gethui then parentGui = gethui() end end)
if not parentGui then pcall(function() parentGui = CoreGui end) end
if not parentGui and lp then pcall(function() parentGui = lp:WaitForChild("PlayerGui", 5) end) end

-- Remove any old loader if running
pcall(function()
    local old = (parentGui and parentGui:FindFirstChild("Monody_LoadingScreen"))
        or (CoreGui and CoreGui:FindFirstChild("Monody_LoadingScreen"))
        or (lp and lp:FindFirstChildOfClass("PlayerGui") and lp.PlayerGui:FindFirstChild("Monody_LoadingScreen"))
    if old then old:Destroy() end
end)

-- ScreenGui Container
local gui = Instance.new("ScreenGui")
gui.Name = "Monody_LoadingScreen"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 10000000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)
if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end

-- Backdrop blur/dim overlay
local backdrop = Instance.new("Frame", gui)
backdrop.Name = "Backdrop"
backdrop.Size = UDim2.new(1, 0, 1, 0)
backdrop.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
backdrop.BackgroundTransparency = 0.4
backdrop.BorderSizePixel = 0

-- Radial Glow
local glow = Instance.new("ImageLabel", backdrop)
glow.Name = "AmbientGlow"
glow.Size = UDim2.new(0, 520, 0, 360)
glow.AnchorPoint = Vector2.new(0.5, 0.5)
glow.Position = UDim2.new(0.5, 0, 0.5, 0)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://1316045217"
glow.ImageColor3 = Color3.fromRGB(255, 255, 255)
glow.ImageTransparency = 0.88

-- Central Card Modal
local modal = Instance.new("Frame", gui)
modal.Name = "Modal"
modal.Size = UDim2.new(0, 0, 0, 0)
modal.AnchorPoint = Vector2.new(0.5, 0.5)
modal.Position = UDim2.new(0.5, 0, 0.5, 0)
modal.BackgroundColor3 = Color3.fromRGB(12, 11, 18)
modal.BackgroundTransparency = 0.12
modal.BorderSizePixel = 0
modal.ClipsDescendants = true
Instance.new("UICorner", modal).CornerRadius = UDim.new(0, 14)

local modalStroke = Instance.new("UIStroke", modal)
modalStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
modalStroke.Color = Color3.fromRGB(255, 255, 255)
modalStroke.Thickness = 1.0
modalStroke.Transparency = 0.82

-- Top Header
local header = Instance.new("Frame", modal)
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 56)
header.BackgroundTransparency = 1

local avatarFrame = Instance.new("Frame", header)
avatarFrame.Size = UDim2.new(0, 42, 0, 42)
avatarFrame.Position = UDim2.new(0, 16, 0, 7)
avatarFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
avatarFrame.BackgroundTransparency = 0.92
Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1, 0)
local aStroke = Instance.new("UIStroke", avatarFrame)
aStroke.Color = Color3.fromRGB(255, 255, 255)
aStroke.Thickness = 1.0
aStroke.Transparency = 0.75

local avatarImg = Instance.new("ImageLabel", avatarFrame)
avatarImg.Size = UDim2.new(1, 0, 1, 0)
avatarImg.BackgroundTransparency = 1
avatarImg.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)

-- Guaranteed instant photo from frame 1 + async anime upgrade
BindPhoto(avatarImg, "floating_avatar_white.png")

local titleLbl = Instance.new("TextLabel", header)
titleLbl.Size = UDim2.new(0, 180, 0, 20)
titleLbl.Position = UDim2.new(0, 68, 0, 10)
titleLbl.BackgroundTransparency = 1
titleLbl.Font = Enum.Font.GothamBold
titleLbl.Text = APP_TITLE
titleLbl.TextSize = 15
titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLbl.TextXAlignment = Enum.TextXAlignment.Left

local subTitleLbl = Instance.new("TextLabel", header)
subTitleLbl.Size = UDim2.new(0, 200, 0, 14)
subTitleLbl.Position = UDim2.new(0, 68, 0, 30)
subTitleLbl.BackgroundTransparency = 1
subTitleLbl.Font = Enum.Font.GothamMedium
subTitleLbl.Text = "PREMIUM EDITION • BLOX FRUITS"
subTitleLbl.TextSize = 8.5
subTitleLbl.TextColor3 = Color3.fromRGB(180, 180, 205)
subTitleLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Version badge
local vBadge = Instance.new("Frame", header)
vBadge.Size = UDim2.new(0, 48, 0, 20)
vBadge.Position = UDim2.new(1, -66, 0, 18)
vBadge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
vBadge.BackgroundTransparency = 0.90
Instance.new("UICorner", vBadge).CornerRadius = UDim.new(1, 0)
local vbStroke = Instance.new("UIStroke", vBadge)
vbStroke.Color = Color3.fromRGB(255, 255, 255)
vbStroke.Thickness = 0.8
vbStroke.Transparency = 0.85

local vLbl = Instance.new("TextLabel", vBadge)
vLbl.Size = UDim2.new(1, 0, 1, 0)
vLbl.BackgroundTransparency = 1
vLbl.Font = Enum.Font.GothamBold
vLbl.Text = APP_VERSION
vLbl.TextSize = 9
vLbl.TextColor3 = Color3.fromRGB(240, 240, 255)

-- Loading Container (Container for progress bar & step status)
local loadContainer = Instance.new("Frame", modal)
loadContainer.Name = "LoadContainer"
loadContainer.Size = UDim2.new(1, 0, 1, -56)
loadContainer.Position = UDim2.new(0, 0, 0, 56)
loadContainer.BackgroundTransparency = 1

local stepTitleLbl = Instance.new("TextLabel", loadContainer)
stepTitleLbl.Name = "StepTitle"
stepTitleLbl.Size = UDim2.new(1, -110, 0, 18)
stepTitleLbl.Position = UDim2.new(0, 20, 0, 18)
stepTitleLbl.BackgroundTransparency = 1
stepTitleLbl.Font = Enum.Font.GothamBold
stepTitleLbl.Text = "Starting Monody Bootloader..."
stepTitleLbl.TextSize = 11
stepTitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
stepTitleLbl.TextXAlignment = Enum.TextXAlignment.Left

local percentLbl = Instance.new("TextLabel", loadContainer)
percentLbl.Name = "PercentLabel"
percentLbl.Size = UDim2.new(0, 60, 0, 18)
percentLbl.Position = UDim2.new(1, -80, 0, 18)
percentLbl.BackgroundTransparency = 1
percentLbl.Font = Enum.Font.GothamBold
percentLbl.Text = "0%"
percentLbl.TextSize = 12
percentLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
percentLbl.TextXAlignment = Enum.TextXAlignment.Right

local stepDetailLbl = Instance.new("TextLabel", loadContainer)
stepDetailLbl.Name = "StepDetail"
stepDetailLbl.Size = UDim2.new(1, -40, 0, 14)
stepDetailLbl.Position = UDim2.new(0, 20, 0, 40)
stepDetailLbl.BackgroundTransparency = 1
stepDetailLbl.Font = Enum.Font.GothamMedium
stepDetailLbl.Text = "Initializing runtime components..."
stepDetailLbl.TextSize = 8.5
stepDetailLbl.TextColor3 = Color3.fromRGB(155, 155, 180)
stepDetailLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Progress Bar Track
local track = Instance.new("Frame", loadContainer)
track.Name = "ProgressBarTrack"
track.Size = UDim2.new(1, -40, 0, 7)
track.Position = UDim2.new(0, 20, 0, 62)
track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
track.BackgroundTransparency = 0.90
Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
local trackStroke = Instance.new("UIStroke", track)
trackStroke.Color = Color3.fromRGB(255, 255, 255)
trackStroke.Thickness = 0.8
trackStroke.Transparency = 0.88

local barFill = Instance.new("Frame", track)
barFill.Name = "Fill"
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

-- Bottom Footnote
local footerLbl = Instance.new("TextLabel", loadContainer)
footerLbl.Size = UDim2.new(1, -40, 0, 14)
footerLbl.Position = UDim2.new(0, 20, 1, -26)
footerLbl.BackgroundTransparency = 1
footerLbl.Font = Enum.Font.GothamMedium
footerLbl.Text = "Powered by Monody Engine • AuroraX Protected"
footerLbl.TextSize = 8
footerLbl.TextColor3 = Color3.fromRGB(120, 120, 145)
footerLbl.TextXAlignment = Enum.TextXAlignment.Center

-- Key Input Container (Hidden by default, shown if key is needed)
local keyContainer = Instance.new("Frame", modal)
keyContainer.Name = "KeyContainer"
keyContainer.Size = UDim2.new(1, 0, 1, -56)
keyContainer.Position = UDim2.new(0, 0, 0, 56)
keyContainer.BackgroundTransparency = 1
keyContainer.Visible = false

local keyPromptLbl = Instance.new("TextLabel", keyContainer)
keyPromptLbl.Size = UDim2.new(1, -40, 0, 16)
keyPromptLbl.Position = UDim2.new(0, 20, 0, 8)
keyPromptLbl.BackgroundTransparency = 1
keyPromptLbl.Font = Enum.Font.GothamBold
keyPromptLbl.Text = "License Key Required"
keyPromptLbl.TextSize = 11
keyPromptLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
keyPromptLbl.TextXAlignment = Enum.TextXAlignment.Left

local keyBoxFrame = Instance.new("Frame", keyContainer)
keyBoxFrame.Size = UDim2.new(1, -40, 0, 34)
keyBoxFrame.Position = UDim2.new(0, 20, 0, 28)
keyBoxFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
keyBoxFrame.BackgroundTransparency = 0.92
Instance.new("UICorner", keyBoxFrame).CornerRadius = UDim.new(0, 8)
local kbStroke = Instance.new("UIStroke", keyBoxFrame)
kbStroke.Color = Color3.fromRGB(255, 255, 255)
kbStroke.Thickness = 0.8
kbStroke.Transparency = 0.85

local keyIcon = Instance.new("ImageLabel", keyBoxFrame)
keyIcon.Size = UDim2.new(0, 16, 0, 16)
keyIcon.Position = UDim2.new(0, 10, 0.5, -8)
keyIcon.BackgroundTransparency = 1
keyIcon.Image = "rbxassetid://130551565616516"
keyIcon.ImageColor3 = Color3.fromRGB(190, 190, 220)

local keyBox = Instance.new("TextBox", keyBoxFrame)
keyBox.Size = UDim2.new(1, -38, 1, 0)
keyBox.Position = UDim2.new(0, 30, 0, 0)
keyBox.BackgroundTransparency = 1
keyBox.Font = Enum.Font.GothamMedium
keyBox.Text = ""
keyBox.PlaceholderText = "Paste your license key here..."
keyBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 160)
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.TextSize = 10.5
keyBox.ClearTextOnFocus = false

local keyFeedback = Instance.new("TextLabel", keyContainer)
keyFeedback.Size = UDim2.new(1, -40, 0, 14)
keyFeedback.Position = UDim2.new(0, 20, 0, 66)
keyFeedback.BackgroundTransparency = 1
keyFeedback.Font = Enum.Font.GothamMedium
keyFeedback.Text = "Please obtain a key to access Monody Premium."
keyFeedback.TextSize = 8.5
keyFeedback.TextColor3 = Color3.fromRGB(170, 170, 195)
keyFeedback.TextXAlignment = Enum.TextXAlignment.Left

-- Buttons Row: [Get Key] [Verify Key] [Discord]
local btnRow = Instance.new("Frame", keyContainer)
btnRow.Size = UDim2.new(1, -40, 0, 30)
btnRow.Position = UDim2.new(0, 20, 0, 86)
btnRow.BackgroundTransparency = 1

local function createGlassBtn(parent, text, xPos, width, isAccent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, width, 1, 0)
    btn.Position = UDim2.new(0, xPos, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = isAccent and 0.80 or 0.92
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextSize = 9.5
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Thickness = 0.8
    s.Transparency = 0.85
    return btn
end

local getKeyBtn = createGlassBtn(btnRow, "Get Key", 0, 95, false)
local verifyBtn = createGlassBtn(btnRow, "Verify Key", 103, 115, true)
local discordBtn = createGlassBtn(btnRow, "Discord", 226, 85, false)

-- Progress Updater Helper
local function setProgress(pct, title, detail)
    pct = math.clamp(pct, 0, 1)
    percentLbl.Text = string.format("%d%%", math.floor(pct * 100))
    if title then stepTitleLbl.Text = title end
    if detail then stepDetailLbl.Text = detail end
    TweenService:Create(barFill, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(pct, 0, 1, 0)
    }):Play()
end

-- Show GUI
gui.Parent = parentGui
TweenService:Create(modal, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 390, 0, 190)
}):Play()

task.spawn(function()
    setProgress(0.12, "Checking Environment...", "Verifying Roblox executor capabilities...")
    task.wait(0.2)

    -- Step 1: Load AuroraX SDK
    setProgress(0.25, "Connecting to AuroraX...", "Fetching security verification SDK...")
    local okSdk, AuroraX = pcall(function()
        return loadstring(game:HttpGet("https://dev.aurorax.site/api/sdk/7c5669e64021da7e13601d7cc9913ee9.lua", true))()
    end)

    if not okSdk or not AuroraX then
        setProgress(0.35, "Fallback Loader...", "Loading direct AuroraX payload...")
        task.wait(0.3)
        loadstring(game:HttpGet("https://api.aurorax.site/files/v5/loaders/7c5669e64021da7e13601d7cc9913ee9", true))()
        return
    end

    local genv = (type(getgenv) == "function" and getgenv()) or _G or {}
    local providedKey = script_key or genv.script_key or genv.Key
    local savedKey = (AuroraX.GetSavedKey and AuroraX.GetSavedKey()) or ""
    local candidate = (providedKey and #providedKey >= 6 and providedKey) or (savedKey and #savedKey >= 6 and savedKey) or nil

    local function formatRemaining(expNum)
        if not expNum or expNum == 0 then return "Lifetime Access" end
        local diff = expNum - os.time()
        if diff > 86400 * 365 then return "Lifetime Access" end
        if diff > 86400 then
            return string.format("%dd %dh Left", math.floor(diff / 86400), math.floor((diff % 86400) / 3600))
        elseif diff > 3600 then
            return string.format("%dh %dm Left", math.floor(diff / 3600), math.floor((diff % 3600) / 60))
        elseif diff > 0 then
            return string.format("%dm Left", math.floor(diff / 60))
        end
        return "Expired"
    end

    local function runFullBoot(validKey, info)
        local exp = (info and info.expires_at) or 0
        genv.AX_KeyExpires = exp
        genv.AX_USER = { ExpiresAt = exp, Key = validKey, ScriptId = "7c5669e64021da7e13601d7cc9913ee9", ScriptName = "Monody" }
        _G.AX_KeyExpires = exp
        _G.AX_USER = genv.AX_USER

        local keyRemainingText = formatRemaining(exp)
        setProgress(0.50, "License Verified!", "Active Key: " .. keyRemainingText)
        task.wait(0.3)

        -- Step 2: Preload White Assets to local cache
        setProgress(0.70, "Preloading Visual Assets...", "Caching white anime panels into local memory...")
        pcall(function()
            if exMakeFolder then
                pcall(exMakeFolder, "Monody")
                pcall(exMakeFolder, "Monody/cache")
            end
            local assetsToPreload = {
                "header_profile_panel_clean_white.png",
                "stats_panel_clean_white.png",
                "floating_avatar_white.png",
                "header_avatar_white.png",
                "stats_center_avatar_white.png",
                "discord_icon_white.png",
                "tiktok_icon_white.png",
                "clock_icon_white.png",
                "key_icon_white.png",
                "logo.jpg"
            }
            for _, fn in ipairs(assetsToPreload) do
                local cPath = "Monody/cache/" .. fn
                local alreadyCached = false
                if exIsFile then
                    local okF, existsF = pcall(exIsFile, cPath)
                    alreadyCached = okF and existsF
                end
                if not alreadyCached and exWriteFile then
                    local url = GITHUB_REPO_RAW .. "/assets/" .. fn
                    local body = SafeHttpGet(url)
                    if body and #body > 50 then
                        pcall(exWriteFile, cPath, body)
                        pcall(exWriteFile, fn, body)
                    end
                end
            end
        end)

        -- Step 3: Launch Main Script
        setProgress(0.90, "Launching Monody Engine...", "Injecting Blox Fruits combat framework...")
        task.wait(0.3)

        setProgress(1.0, "Ready!", "Welcome, " .. (lp and lp.DisplayName or "Player") .. "!")
        task.wait(0.35)

        -- Execute Main Script (Protected + Direct Fallback)
        task.spawn(function()
            local launched = false
            pcall(function()
                if AuroraX and AuroraX.LoadScript then
                    AuroraX.LoadScript(validKey)
                    launched = true
                end
            end)
            if not launched or not _G.DarlingX then
                task.wait(1.0)
                if not _G.DarlingX then
                    pcall(function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/rivals-hash/idk/main/main.lua", true))()
                    end)
                end
            end
        end)

        -- Smooth dismiss of loading screen after main opens
        task.delay(1.5, function()
            if modal and modal.Parent then
                TweenService:Create(modal, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1
                }):Play()
                task.wait(0.35)
                pcall(function() gui:Destroy() end)
            end
        end)
    end

    -- Check if existing key is valid
    if candidate then
        setProgress(0.35, "Verifying License Key...", "Checking validity with AuroraX API...")
        local valid, info = AuroraX.CheckKey(candidate)
        if valid then
            runFullBoot(candidate, info)
            return
        end
    end

    -- If no key or invalid, display the Key Input Form
    setProgress(0.30, "License Key Required", "Please enter your Monody key to continue.")
    keyBox.Text = savedKey or ""
    task.wait(0.2)
    loadContainer.Visible = false
    keyContainer.Visible = true

    getKeyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local setcb = setclipboard or toclipboard or (syn and syn.set_clipboard)
            if setcb then setcb("https://dev.aurorax.site/getkey/7c5669e64021da7e13601d7cc9913ee9") end
        end)
        keyFeedback.TextColor3 = Color3.fromRGB(160, 220, 255)
        keyFeedback.Text = "Key link copied to clipboard!"
    end)

    discordBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local setcb = setclipboard or toclipboard or (syn and syn.set_clipboard)
            if setcb then setcb("https://discord.gg/besthub") end
        end)
        keyFeedback.TextColor3 = Color3.fromRGB(160, 220, 255)
        keyFeedback.Text = "Discord link copied to clipboard!"
    end)

    local isChecking = false
    verifyBtn.MouseButton1Click:Connect(function()
        if isChecking then return end
        local entered = keyBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if #entered < 6 then
            keyFeedback.TextColor3 = Color3.fromRGB(255, 120, 120)
            keyFeedback.Text = "Please enter a valid license key (min 6 chars)."
            return
        end
        isChecking = true
        keyFeedback.TextColor3 = Color3.fromRGB(255, 230, 140)
        keyFeedback.Text = "Authenticating key..."

        task.spawn(function()
            local valid, info = AuroraX.CheckKey(entered)
            if valid then
                keyFeedback.TextColor3 = Color3.fromRGB(120, 255, 170)
                keyFeedback.Text = "Key verified! Continuing boot..."
                task.wait(0.5)
                keyContainer.Visible = false
                loadContainer.Visible = true
                runFullBoot(entered, info)
            else
                keyFeedback.TextColor3 = Color3.fromRGB(255, 110, 110)
                keyFeedback.Text = (info and info.message) or "Invalid or expired license key."
                isChecking = false
            end
        end)
    end)
end)
