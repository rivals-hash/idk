repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer

local APP_TITLE = "Monody"
local DEFAULT_LOGO_ID = "rbxassetid://109687263098821"

local exIsFile = isfile or is_file
local exWriteFile = writefile or write_file
local exMakeFolder = makefolder or make_folder
local exGetCustomAsset = getcustomasset or getsynasset

local function ResolveCustomAsset(relativePath, fallbackAssetId)
    if not exGetCustomAsset or not exIsFile then
        return fallbackAssetId
    end

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
            if okAsset and type(asset) == "string" and #asset > 0 then
                return asset
            end
        end
    end

    return fallbackAssetId
end

local CachedLogoAsset = nil
local function GetLogoAsset()
    if CachedLogoAsset then return CachedLogoAsset end

    local userCustomLogo = ResolveCustomAsset("assets/logo.jpg", nil)
    if userCustomLogo then
        CachedLogoAsset = userCustomLogo
        return userCustomLogo
    end

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

    CachedLogoAsset = DEFAULT_LOGO_ID
    return DEFAULT_LOGO_ID
end

local parentGui = nil
pcall(function() if gethui then parentGui = gethui() end end)
if not parentGui then pcall(function() parentGui = CoreGui end) end
if not parentGui and lp then pcall(function() parentGui = lp:WaitForChild("PlayerGui", 5) end) end

local okSdk, AuroraX = pcall(function()
    return loadstring(game:HttpGet("https://dev.aurorax.site/api/sdk/1b56de61f463fc8d4cd4d1dca6e26660.lua", true))()
end)

if not okSdk or not AuroraX then
    loadstring(game:HttpGet("https://api.aurorax.site/files/v5/loaders/1b56de61f463fc8d4cd4d1dca6e26660", true))()
    return
end

local genv = (type(getgenv) == "function" and getgenv()) or _G or {}
local providedKey = script_key or genv.script_key or genv.Key
local savedKey = (AuroraX.GetSavedKey and AuroraX.GetSavedKey()) or ""
local candidate = (providedKey and #providedKey >= 6 and providedKey) or (savedKey and #savedKey >= 6 and savedKey) or nil

if candidate then
    local valid, info = AuroraX.CheckKey(candidate)
    if valid then
        AuroraX.LoadScript(candidate)
        return
    end
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

    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(6, 4, 12)
    backdrop.BackgroundTransparency = 0.3
    backdrop.BorderSizePixel = 0
    backdrop.Parent = gui

    local ambientGlow = Instance.new("ImageLabel", backdrop)
    ambientGlow.Name = "AmbientGlow"
    ambientGlow.Size = UDim2.new(0, 560, 0, 420)
    ambientGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    ambientGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    ambientGlow.BackgroundTransparency = 1
    ambientGlow.Image = "rbxassetid://1316045217"
    ambientGlow.ImageColor3 = Color3.fromRGB(147, 51, 234)
    ambientGlow.ImageTransparency = 0.72

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

    local title = Instance.new("TextLabel", modal)
    title.Size = UDim2.new(1, -30, 0, 22)
    title.Position = UDim2.new(0, 15, 0, 70)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = APP_TITLE
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 19
    title.TextXAlignment = Enum.TextXAlignment.Center

    local sub = Instance.new("TextLabel", modal)
    sub.Size = UDim2.new(1, -30, 0, 16)
    sub.Position = UDim2.new(0, 15, 0, 94)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.GothamMedium
    sub.Text = "MONODY LICENSE AUTHENTICATION"
    sub.TextColor3 = Color3.fromRGB(192, 132, 252)
    sub.TextSize = 9.5
    sub.TextXAlignment = Enum.TextXAlignment.Center

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

    local btnRow = Instance.new("Frame", modal)
    btnRow.Size = UDim2.new(1, -40, 0, 36)
    btnRow.AnchorPoint = Vector2.new(0.5, 0)
    btnRow.Position = UDim2.new(0.5, 0, 0, 192)
    btnRow.BackgroundTransparency = 1

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

    TweenService:Create(modal, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 410, 0, 250),
        BackgroundTransparency = 0.15
    }):Play()
end

showKeyModal(AuroraX, function()
    local saved = (AuroraX.GetSavedKey and AuroraX.GetSavedKey()) or candidate
    AuroraX.LoadScript(saved)
end)
