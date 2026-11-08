--[[
    Monody Premium - modules/ui/tab_views.lua
    Interactive feature suites for all Monody categories:
    Aimbot, Combat, Players, Soru, Macro, VFX, Skins, and Settings.
    Features:
    - Pixel-perfect alignment with 02_Aimbot screenshot (aimbot_settings_panel.png & aimbot_header.png)
    - Glowing purple neon aesthetic & icons in rounded dark squares
    - Modern purple pill switches (exact match to toggle_on.png / toggle_off.png)
    - Complete live Players tab with HP, Race, Hotbar tool, Spectate, Tween To, and Aimbot Blacklist
]]

local TabViews = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local task = task or {
    defer = function(fn) fn() end,
    delay = function(sec, fn) if delay then delay(sec, fn) else fn() end end,
    spawn = function(fn) coroutine.wrap(fn)() end
}

local clamp = math.clamp or function(val, minVal, maxVal)
    if val < minVal then return minVal end
    if val > maxVal then return maxVal end
    return val
end

-- Default Icon mapping for settings rows
local ICON_MAP = {
    Aimbot = "rbxassetid://134242818164054",
    ["NPC Aimbot"] = "rbxassetid://10734887900",
    Aimlock = "rbxassetid://10734950309",
    ["PvP Check"] = "rbxassetid://81872698913435",
    ["Safe Zone Check"] = "rbxassetid://10734951847",
    ["Team Check"] = "rbxassetid://115398113982385",
    ["Aim Mode"] = "rbxassetid://134242818164054",
    ["Target Priority"] = "rbxassetid://10734898144",
    ["Max Range"] = "rbxassetid://10734951847",
    ["Player Silent Aim"] = "rbxassetid://134242818164054",
    ["NPC Silent Aim"] = "rbxassetid://10734887900",
    ["Silent Aim Range"] = "rbxassetid://10734951847",
    ["FOV Circle"] = "rbxassetid://10734898144",
    ["FOV Radius"] = "rbxassetid://10734898144",
    ["Show Tracers"] = "rbxassetid://134242818164054",
    Mode = "rbxassetid://10734898144",
    Origin = "rbxassetid://10734898144",
    ["Fast Attack"] = "rbxassetid://81872698913435",
    ["Auto Clicker"] = "rbxassetid://81872698913435",
    ["Auto Skills Combo"] = "rbxassetid://81872698913435",
    ["Kill Aura"] = "rbxassetid://81872698913435",
    ["Player ESP"] = "rbxassetid://115398113982385",
    ["Box ESP"] = "rbxassetid://10734898144",
    Tracers = "rbxassetid://134242818164054",
    WalkSpeed = "rbxassetid://10734951847",
    JumpPower = "rbxassetid://10734951847",
    ["Toggle Soru Cooldown (1s)"] = "rbxassetid://130551565616516",
    ["Instant Soru Cooldown (1s)"] = "rbxassetid://130551565616516",
    ["Infinite Soru"] = "rbxassetid://130551565616516",
    ["Soru Aimbot"] = "rbxassetid://130551565616516",
    ["Auto Farm Level"] = "rbxassetid://80451686744860",
    ["Clear Sky (No Fog)"] = "rbxassetid://100033680381365",
    ["Fullbright Mode"] = "rbxassetid://100033680381365",
}

-- Track exact card heights deterministically
local cardHeights = {}

local function addCardHeight(parent, h)
    local card = parent
    if card and card.Name == "Content" and card.Parent then
        card = card.Parent
    end
    if not card or not cardHeights[card] then return end
    local cur = cardHeights[card]
    local newH = cur + h + 6
    cardHeights[card] = newH
    card.Size = UDim2.new(0, 396, 0, newH)
end

-- Helper: Create interactive Toggle (Glassmorphic Darling X Style)
local function createToggle(parent, title, desc, defaultState, onToggle, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent
    local state = defaultState or false

    local row = Instance.new("Frame")
    row.Name = "Toggle_" .. title:gsub("%s+", "")
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = Color3.fromRGB(24, 16, 22)
    row.BackgroundTransparency = 0.55
    row.BorderSizePixel = 0
    row.ZIndex = 3
    row.Parent = targetContainer

    addCardHeight(parent, 42)

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = Color3.fromRGB(255, 255, 255)
    rowStroke.Transparency = 0.92
    rowStroke.Thickness = 1
    rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    rowStroke.Parent = row

    -- Left Text (Title + Short Desc)
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -60, 1, 0)
    textContainer.Position = UDim2.new(0, 10, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.ZIndex = 3
    textContainer.Parent = row

    local hasDesc = (desc and #desc > 0)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, hasDesc and 19 or 24)
    titleLbl.Position = UDim2.new(0, 0, 0, hasDesc and 3 or 9)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = textContainer

    if hasDesc then
        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, 0, 0, 15)
        descLbl.Position = UDim2.new(0, 0, 0, 21)
        descLbl.BackgroundTransparency = 1
        descLbl.Font = Enum.Font.GothamMedium
        descLbl.Text = desc
        descLbl.TextColor3 = Color3.fromRGB(180, 170, 185)
        descLbl.TextSize = 9.5
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex = 4
        descLbl.Parent = textContainer
    end

    -- Pill Switch Visual (Crimson Red / Clean White)
    local switchBtn = Instance.new("Frame")
    switchBtn.Name = "SwitchVisual"
    switchBtn.Size = UDim2.new(0, 40, 0, 22)
    switchBtn.Position = UDim2.new(1, -48, 0.5, -11)
    switchBtn.BackgroundColor3 = state and Color3.fromRGB(220, 35, 60) or Color3.fromRGB(44, 34, 42)
    switchBtn.BorderSizePixel = 0
    switchBtn.ZIndex = 4
    switchBtn.Parent = row

    local swCorner = Instance.new("UICorner")
    swCorner.CornerRadius = UDim.new(1, 0)
    swCorner.Parent = switchBtn

    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    thumb.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 170, 185)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 5
    thumb.Parent = switchBtn

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb

    local function updateVisual(anim)
        local dur = anim and 0.15 or 0
        local targetBg = state and Color3.fromRGB(220, 35, 60) or Color3.fromRGB(44, 34, 42)
        local targetThumbBg = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 170, 185)
        local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)

        if anim then
            TweenService:Create(switchBtn, TweenInfo.new(dur), { BackgroundColor3 = targetBg }):Play()
            TweenService:Create(thumb, TweenInfo.new(dur), { BackgroundColor3 = targetThumbBg, Position = targetPos }):Play()
        else
            switchBtn.BackgroundColor3 = targetBg
            thumb.BackgroundColor3 = targetThumbBg
            thumb.Position = targetPos
        end
    end

    -- Full-row Touch / Click Hitbox Button
    local hitboxBtn = Instance.new("TextButton")
    hitboxBtn.Name = "HitboxBtn"
    hitboxBtn.Size = UDim2.new(1, 0, 1, 0)
    hitboxBtn.Position = UDim2.new(0, 0, 0, 0)
    hitboxBtn.BackgroundTransparency = 1
    hitboxBtn.Text = ""
    hitboxBtn.AutoButtonColor = false
    hitboxBtn.Active = true
    hitboxBtn.ZIndex = 10
    hitboxBtn.Parent = row

    hitboxBtn.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.4 }):Play()
        TweenService:Create(rowStroke, TweenInfo.new(0.12), { Transparency = 0.82 }):Play()
    end)
    hitboxBtn.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.55 }):Play()
        TweenService:Create(rowStroke, TweenInfo.new(0.12), { Transparency = 0.92 }):Play()
    end)

    local lastToggleTick = 0
    local function toggle()
        local now = tick()
        if lastToggleTick > 0 and (now - lastToggleTick < 0.25) then return end
        lastToggleTick = now

        state = not state
        updateVisual(true)
        if onToggle then pcall(onToggle, state) end
    end

    hitboxBtn.Activated:Connect(toggle)
    hitboxBtn.MouseButton1Click:Connect(toggle)

    return row
end

-- Helper: Create interactive Dropdown with chevron pill (Glassmorphic Darling X Style)
local function createDropdown(parent, title, desc, optionsList, defaultIndex, onSelect, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent
    local curIdx = defaultIndex or 1
    optionsList = (optionsList and #optionsList > 0) and optionsList or { "Default" }

    local row = Instance.new("Frame")
    row.Name = "Dropdown_" .. title:gsub("%s+", "")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(24, 16, 22)
    row.BackgroundTransparency = 0.55
    row.BorderSizePixel = 0
    row.ZIndex = 3
    row.Parent = targetContainer

    addCardHeight(parent, 44)

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = Color3.fromRGB(255, 255, 255)
    rowStroke.Transparency = 0.92
    rowStroke.Thickness = 1
    rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    rowStroke.Parent = row

    -- Left Text
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -125, 1, 0)
    textContainer.Position = UDim2.new(0, 10, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.ZIndex = 3
    textContainer.Parent = row

    local hasDesc = (desc and #desc > 0)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, hasDesc and 19 or 24)
    titleLbl.Position = UDim2.new(0, 0, 0, hasDesc and 3 or 10)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = textContainer

    if hasDesc then
        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, 0, 0, 15)
        descLbl.Position = UDim2.new(0, 0, 0, 21)
        descLbl.BackgroundTransparency = 1
        descLbl.Font = Enum.Font.GothamMedium
        descLbl.Text = desc
        descLbl.TextColor3 = Color3.fromRGB(180, 170, 185)
        descLbl.TextSize = 9.5
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex = 4
        descLbl.Parent = textContainer
    end

    -- Right Pill Button with Option Text and Down Chevron
    local pillBtn = Instance.new("TextButton")
    pillBtn.Name = "PillBtn"
    pillBtn.Size = UDim2.new(0, 104, 0, 26)
    pillBtn.Position = UDim2.new(1, -112, 0.5, -13)
    pillBtn.BackgroundColor3 = Color3.fromRGB(36, 20, 28)
    pillBtn.BackgroundTransparency = 0.4
    pillBtn.BorderSizePixel = 0
    pillBtn.Text = ""
    pillBtn.AutoButtonColor = false
    pillBtn.Active = true
    pillBtn.ZIndex = 5
    pillBtn.Parent = row

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(0, 6)
    pillCorner.Parent = pillBtn

    local pillStroke = Instance.new("UIStroke")
    pillStroke.Color = Color3.fromRGB(255, 255, 255)
    pillStroke.Transparency = 0.94
    pillStroke.Thickness = 1
    pillStroke.Parent = pillBtn

    local pillText = Instance.new("TextLabel")
    pillText.Name = "PillText"
    pillText.Size = UDim2.new(1, -22, 1, 0)
    pillText.Position = UDim2.new(0, 8, 0, 0)
    pillText.BackgroundTransparency = 1
    pillText.Font = Enum.Font.GothamBold
    pillText.Text = optionsList[curIdx] or ""
    pillText.TextColor3 = Color3.fromRGB(255, 255, 255)
    pillText.TextSize = 11.5
    pillText.TextXAlignment = Enum.TextXAlignment.Left
    pillText.ZIndex = 6
    pillText.Parent = pillBtn

    local chevron = Instance.new("TextLabel")
    chevron.Name = "Chevron"
    chevron.Size = UDim2.new(0, 16, 1, 0)
    chevron.Position = UDim2.new(1, -18, 0, 0)
    chevron.BackgroundTransparency = 1
    chevron.Font = Enum.Font.GothamBold
    chevron.Text = "▼"
    chevron.TextSize = 9
    chevron.TextColor3 = Color3.fromRGB(255, 85, 105)
    chevron.ZIndex = 6
    chevron.Parent = pillBtn

    pillBtn.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.4 }):Play()
        TweenService:Create(rowStroke, TweenInfo.new(0.12), { Transparency = 0.82 }):Play()
        TweenService:Create(pillBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(48, 26, 38) }):Play()
    end)
    pillBtn.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.55 }):Play()
        TweenService:Create(rowStroke, TweenInfo.new(0.12), { Transparency = 0.92 }):Play()
        TweenService:Create(pillBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(36, 20, 28) }):Play()
    end)

    local lastCycle = 0
    local function cycleOption()
        local now = tick()
        if lastCycle > 0 and (now - lastCycle < 0.25) then return end
        lastCycle = now

        curIdx = curIdx + 1
        if curIdx > #optionsList then curIdx = 1 end
        local chosen = optionsList[curIdx]
        pillText.Text = chosen

        TweenService:Create(pillBtn, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(65, 28, 45) }):Play()
        task.delay(0.1, function()
            TweenService:Create(pillBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(36, 20, 28) }):Play()
        end)

        if onSelect then pcall(onSelect, chosen, curIdx) end
    end

    pillBtn.Activated:Connect(cycleOption)
    pillBtn.MouseButton1Click:Connect(cycleOption)

    return row
end

-- Helper: Create interactive Text Input (Glassmorphic Darling X Style)
local function createTextInput(parent, title, desc, placeholder, defaultVal, onSubmit, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent
    local val = defaultVal or ""

    local row = Instance.new("Frame")
    row.Name = "Input_" .. title:gsub("%s+", "")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(24, 16, 22)
    row.BackgroundTransparency = 0.55
    row.BorderSizePixel = 0
    row.ZIndex = 3
    row.Parent = targetContainer

    addCardHeight(parent, 44)

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = Color3.fromRGB(255, 255, 255)
    rowStroke.Transparency = 0.92
    rowStroke.Thickness = 1
    rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    rowStroke.Parent = row

    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -140, 1, 0)
    textContainer.Position = UDim2.new(0, 10, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.ZIndex = 3
    textContainer.Parent = row

    local hasDesc = (desc and #desc > 0)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, hasDesc and 19 or 24)
    titleLbl.Position = UDim2.new(0, 0, 0, hasDesc and 3 or 10)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = textContainer

    if hasDesc then
        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, 0, 0, 15)
        descLbl.Position = UDim2.new(0, 0, 0, 21)
        descLbl.BackgroundTransparency = 1
        descLbl.Font = Enum.Font.GothamMedium
        descLbl.Text = desc
        descLbl.TextColor3 = Color3.fromRGB(180, 170, 185)
        descLbl.TextSize = 9.5
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex = 4
        descLbl.Parent = textContainer
    end

    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(0, 120, 0, 26)
    inputContainer.Position = UDim2.new(1, -128, 0.5, -13)
    inputContainer.BackgroundColor3 = Color3.fromRGB(36, 20, 28)
    inputContainer.BackgroundTransparency = 0.4
    inputContainer.BorderSizePixel = 0
    inputContainer.ZIndex = 4
    inputContainer.Parent = row

    local icCorner = Instance.new("UICorner")
    icCorner.CornerRadius = UDim.new(0, 6)
    icCorner.Parent = inputContainer

    local icStroke = Instance.new("UIStroke")
    icStroke.Color = Color3.fromRGB(220, 35, 60)
    icStroke.Transparency = 0.7
    icStroke.Thickness = 1
    icStroke.Parent = inputContainer

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -12, 1, 0)
    box.Position = UDim2.new(0, 6, 0, 0)
    box.BackgroundTransparency = 1
    box.Text = val
    box.PlaceholderText = placeholder or "Type here..."
    box.PlaceholderColor3 = Color3.fromRGB(150, 140, 160)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 10.5
    box.ClearTextOnFocus = false
    box.ZIndex = 5
    box.Parent = inputContainer

    box.FocusLost:Connect(function(enterPressed)
        val = box.Text
        if onSubmit then pcall(onSubmit, val, enterPressed) end
    end)

    return row
end

-- Helper: Create interactive Slider with Cyber HUD Badge & Glowing Neon Fill (Glassmorphic Darling X Style)
local function createSlider(parent, title, minVal, maxVal, defaultVal, onSlide, Utils, customIcon)
    local targetContainer = parent:FindFirstChild("Content") or parent
    local curVal = clamp(defaultVal or minVal, minVal, maxVal)

    local row = Instance.new("Frame")
    row.Name = "Slider_" .. title:gsub("%s+", "")
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = Color3.fromRGB(24, 16, 22)
    row.BackgroundTransparency = 0.55
    row.BorderSizePixel = 0
    row.ZIndex = 3
    row.Parent = targetContainer

    addCardHeight(parent, 50)

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = Color3.fromRGB(255, 255, 255)
    rowStroke.Transparency = 0.92
    rowStroke.Thickness = 1
    rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    rowStroke.Parent = row

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 20)
    header.BackgroundTransparency = 1
    header.ZIndex = 3
    header.Parent = row

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -70, 1, 0)
    titleLbl.Position = UDim2.new(0, 10, 0, 2)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = header

    -- Value Badge [ 120 ]
    local valBadge = Instance.new("Frame")
    valBadge.Name = "ValBadge"
    valBadge.Size = UDim2.new(0, 52, 0, 18)
    valBadge.Position = UDim2.new(1, -60, 0, 3)
    valBadge.BackgroundColor3 = Color3.fromRGB(40, 20, 30)
    valBadge.BackgroundTransparency = 0.35
    valBadge.BorderSizePixel = 0
    valBadge.ZIndex = 4
    valBadge.Parent = header

    local vbCorner = Instance.new("UICorner")
    vbCorner.CornerRadius = UDim.new(0, 5)
    vbCorner.Parent = valBadge

    local vbStroke = Instance.new("UIStroke")
    vbStroke.Color = Color3.fromRGB(255, 255, 255)
    vbStroke.Transparency = 0.94
    vbStroke.Thickness = 1
    vbStroke.Parent = valBadge

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(1, 0, 1, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.Text = tostring(math.floor(curVal + 0.5))
    valLbl.TextColor3 = Color3.fromRGB(255, 215, 225)
    valLbl.TextSize = 11
    valLbl.ZIndex = 5
    valLbl.Parent = valBadge

    -- Slider Track Frame with Glowing Crimson/Ruby Gradient Fill
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 32)
    track.BackgroundColor3 = Color3.fromRGB(16, 10, 16)
    track.BackgroundTransparency = 0.2
    track.BorderSizePixel = 0
    track.ZIndex = 4
    track.Parent = row

    local trCorner = Instance.new("UICorner")
    trCorner.CornerRadius = UDim.new(1, 0)
    trCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    local initRatio = (curVal - minVal) / math.max(1, (maxVal - minVal))
    fill.Size = UDim2.new(clamp(initRatio, 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(220, 35, 60)
    fill.BorderSizePixel = 0
    fill.ZIndex = 5
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    pcall(function()
        if ColorSequence and ColorSequence.new then
            local fillGrad = Instance.new("UIGradient")
            fillGrad.Color = ColorSequence.new(Color3.fromRGB(220, 35, 60), Color3.fromRGB(255, 95, 120))
            fillGrad.Parent = fill
        end
    end)

    -- Clean Pure White Circular Thumb Knob
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(clamp(initRatio, 0, 1), 0, 0.5, 0)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 6
    thumb.Parent = track

    local thCorner = Instance.new("UICorner")
    thCorner.CornerRadius = UDim.new(1, 0)
    thCorner.Parent = thumb

    local sliderHitbox = Instance.new("TextButton")
    sliderHitbox.Name = "SliderHitbox"
    sliderHitbox.Size = UDim2.new(1, 0, 0, 32)
    sliderHitbox.Position = UDim2.new(0, 0, 0, 16)
    sliderHitbox.BackgroundTransparency = 1
    sliderHitbox.Text = ""
    sliderHitbox.AutoButtonColor = false
    sliderHitbox.Active = true
    sliderHitbox.ZIndex = 10
    sliderHitbox.Parent = row

    local sliding = false
    sliderHitbox.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.4 }):Play()
        TweenService:Create(rowStroke, TweenInfo.new(0.12), { Transparency = 0.82 }):Play()
    end)
    sliderHitbox.MouseLeave:Connect(function()
        if not sliding then
            TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.55 }):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.12), { Transparency = 0.92 }):Play()
        end
    end)

    local function setRatio(ratio)
        ratio = clamp(ratio, 0, 1)
        curVal = minVal + (ratio * (maxVal - minVal))
        valLbl.Text = tostring(math.floor(curVal + 0.5))
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        thumb.Position = UDim2.new(ratio, 0, 0.5, 0)
        if onSlide then pcall(onSlide, curVal) end
    end

    local function updateFromInput(input)
        local trackAbsPos = track.AbsolutePosition.X
        local trackAbsSize = track.AbsoluteSize.X
        if trackAbsSize > 0 then
            local relX = input.Position.X - trackAbsPos
            setRatio(relX / trackAbsSize)
        end
    end

    sliderHitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateFromInput(input)
        end
    end)

    local connChanged = UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)

    local connEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    row.Destroying:Connect(function()
        pcall(function() connChanged:Disconnect() end)
        pcall(function() connEnded:Disconnect() end)
    end)

    return row
end

-- Helper: Create Action Button with red accent hover (Glassmorphic Darling X Style)
local function createActionButton(parent, title, desc, onClick, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent

    local btn = Instance.new("TextButton")
    btn.Name = "Btn_" .. title:gsub("%s+", "")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(30, 18, 24)
    btn.BackgroundTransparency = 0.5
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Active = true
    btn.ZIndex = 4
    btn.Parent = targetContainer

    addCardHeight(parent, 38)

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 8)
    bCorner.Parent = btn

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(255, 255, 255)
    bStroke.Transparency = 0.92
    bStroke.Thickness = 1
    bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    bStroke.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(56, 24, 34), BackgroundTransparency = 0.35 }):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.12), { Transparency = 0.8 }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(30, 18, 24), BackgroundTransparency = 0.5 }):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.12), { Transparency = 0.92 }):Play()
    end)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(255, 245, 245)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 5
    lbl.Parent = btn

    local lastPress = 0
    local function onPress()
        local now = tick()
        if lastPress > 0 and (now - lastPress < 0.25) then return end
        lastPress = now

        TweenService:Create(btn, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(205, 30, 55) }):Play()
        task.delay(0.1, function()
            TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(30, 18, 24) }):Play()
        end)
        if onClick then pcall(onClick) end
    end

    btn.Activated:Connect(onPress)
    btn.MouseButton1Click:Connect(onPress)
    return btn
end

-- Helper: Create Color Picker Palette (Glassmorphic Darling X Style)
local function createColorPicker(parent, title, desc, colorNames, defaultColorName, onSelectColor, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent
    local selected = defaultColorName or "Rainbow"
    colorNames = colorNames or { "Rainbow", "White", "Red", "Green", "Blue", "Yellow", "Purple" }
    local containerHeight = 64

    local container = Instance.new("Frame")
    container.Name = "ColorPicker_" .. title:gsub("%s+", "")
    container.Size = UDim2.new(1, 0, 0, containerHeight)
    container.BackgroundColor3 = Color3.fromRGB(24, 16, 22)
    container.BackgroundTransparency = 0.55
    container.BorderSizePixel = 0
    container.ZIndex = 3
    container.Parent = targetContainer

    addCardHeight(parent, containerHeight)

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = container

    local cStroke = Instance.new("UIStroke")
    cStroke.Color = Color3.fromRGB(255, 255, 255)
    cStroke.Transparency = 0.92
    cStroke.Thickness = 1
    cStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cStroke.Parent = container

    local headerRow = Instance.new("Frame")
    headerRow.Size = UDim2.new(1, 0, 0, 20)
    headerRow.BackgroundTransparency = 1
    headerRow.ZIndex = 3
    headerRow.Parent = container

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.6, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 10, 0, 4)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(245, 240, 250)
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = headerRow

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.4, -12, 1, 0)
    valLbl.Position = UDim2.new(0.6, 0, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamMedium
    valLbl.Text = selected
    valLbl.TextColor3 = Color3.fromRGB(255, 85, 105)
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 4
    valLbl.Parent = headerRow

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "PaletteScroll"
    scroll.Size = UDim2.new(1, -20, 0, 30)
    scroll.Position = UDim2.new(0, 10, 0, 28)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 0
    scroll.CanvasSize = UDim2.new(0, (#colorNames * 76), 0, 0)
    scroll.ScrollingDirection = Enum.ScrollingDirection.X
    scroll.ZIndex = 5
    scroll.Parent = container

    local pLayout = Instance.new("UIListLayout")
    pLayout.FillDirection = Enum.FillDirection.Horizontal
    pLayout.Padding = UDim.new(0, 6)
    pLayout.Parent = scroll

    local colorPills = {}
    local function updatePills()
        for cName, pill in pairs(colorPills) do
            local isSel = (cName == selected)
            pill.Frame.BackgroundColor3 = isSel and Color3.fromRGB(205, 30, 55) or Color3.fromRGB(32, 20, 26)
            pill.Frame.BackgroundTransparency = isSel and 0.1 or 0.35
        end
        valLbl.Text = selected
    end

    local lastPickTick = 0
    for idx, cName in ipairs(colorNames) do
        local pill = Instance.new("TextButton")
        pill.Name = "Color_" .. cName
        pill.Size = UDim2.new(0, 70, 0, 24)
        pill.BackgroundColor3 = (cName == selected) and Color3.fromRGB(205, 30, 55) or Color3.fromRGB(32, 20, 26)
        pill.BackgroundTransparency = (cName == selected) and 0.1 or 0.35
        pill.BorderSizePixel = 0
        pill.Text = cName
        pill.Font = Enum.Font.GothamBold
        pill.TextSize = 10.5
        pill.TextColor3 = Color3.fromRGB(255, 255, 255)
        pill.AutoButtonColor = false
        pill.Active = true
        pill.ZIndex = 6
        pill.Parent = scroll

        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(0, 6)
        pCorner.Parent = pill

        local pStroke = Instance.new("UIStroke")
        pStroke.Color = Color3.fromRGB(255, 255, 255)
        pStroke.Transparency = 0.94
        pStroke.Thickness = 1
        pStroke.Parent = pill

        colorPills[cName] = { Frame = pill }

        local function pick()
            local now = tick()
            if lastPickTick > 0 and (now - lastPickTick < 0.2) then return end
            lastPickTick = now

            selected = cName
            updatePills()
            if onSelectColor then pcall(onSelectColor, cName) end
        end

        pill.Activated:Connect(pick)
        pill.MouseButton1Click:Connect(pick)
    end

    return container
end

-- Helper: Create Chip Grid for Blacklist (Glassmorphic Darling X Style)
local function createChipGrid(parent, title, desc, chipsList, onToggleChip, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent
    local blacklisted = {}
    local totalHeight = 136

    local container = Instance.new("Frame")
    container.Name = "ChipGrid_" .. title:gsub("%s+", "")
    container.Size = UDim2.new(1, 0, 0, totalHeight)
    container.BackgroundColor3 = Color3.fromRGB(24, 16, 22)
    container.BackgroundTransparency = 0.55
    container.BorderSizePixel = 0
    container.ZIndex = 3
    container.Parent = targetContainer

    addCardHeight(parent, totalHeight)

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = container

    local cStroke = Instance.new("UIStroke")
    cStroke.Color = Color3.fromRGB(255, 255, 255)
    cStroke.Transparency = 0.92
    cStroke.Thickness = 1
    cStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cStroke.Parent = container

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 18)
    titleLbl.Position = UDim2.new(0, 10, 0, 4)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(245, 240, 250)
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = container

    local gridFrame = Instance.new("Frame")
    gridFrame.Name = "Grid"
    gridFrame.Size = UDim2.new(1, -20, 0, 104)
    gridFrame.Position = UDim2.new(0, 10, 0, 26)
    gridFrame.BackgroundTransparency = 1
    gridFrame.ZIndex = 4
    gridFrame.Parent = container

    local gLayout = Instance.new("UIGridLayout")
    gLayout.CellSize = UDim2.new(0, 92, 0, 24)
    gLayout.CellPadding = UDim2.new(0, 4, 0, 4)
    gLayout.Parent = gridFrame

    for _, chipName in ipairs(chipsList) do
        local chip = Instance.new("TextButton")
        chip.Name = "Chip_" .. chipName:gsub("%s+", "")
        chip.BackgroundColor3 = Color3.fromRGB(32, 20, 26)
        chip.BackgroundTransparency = 0.35
        chip.BorderSizePixel = 0
        chip.Text = chipName
        chip.Font = Enum.Font.GothamMedium
        chip.TextSize = 9.5
        chip.TextColor3 = Color3.fromRGB(215, 210, 230)
        chip.AutoButtonColor = false
        chip.Active = true
        chip.ZIndex = 5
        chip.Parent = gridFrame

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 6)
        cCorner.Parent = chip

        local cpStroke = Instance.new("UIStroke")
        cpStroke.Color = Color3.fromRGB(255, 255, 255)
        cpStroke.Transparency = 0.94
        cpStroke.Thickness = 1
        cpStroke.Parent = chip

        local isBl = false
        chip.MouseButton1Click:Connect(function()
            isBl = not isBl
            blacklisted[chipName] = isBl
            local targetBg = isBl and Color3.fromRGB(180, 25, 45) or Color3.fromRGB(32, 20, 26)
            local targetTrans = isBl and 0.1 or 0.35
            local targetText = isBl and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(215, 210, 230)

            TweenService:Create(chip, TweenInfo.new(0.12), { BackgroundColor3 = targetBg, BackgroundTransparency = targetTrans, TextColor3 = targetText }):Play()
            if onToggleChip then pcall(onToggleChip, chipName, isBl) end
        end)
    end

    return container
end

-- Helper: Create Feature Card (100% Transparent container with ruby red header)
local function createFeatureCard(parent, title, AssetManager)
    local card = Instance.new("Frame")
    card.Name = "Card_" .. title:gsub("%s+", "")
    card.Size = UDim2.new(0, 396, 0, 36)
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.ClipsDescendants = false
    card.Parent = parent

    cardHeights[card] = 36

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.ZIndex = 2
    content.Parent = card

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    -- Header row in Ruby Red Darling X Aesthetic
    local headerRow = Instance.new("Frame")
    headerRow.Name = "HeaderRow"
    headerRow.Size = UDim2.new(1, 0, 0, 22)
    headerRow.BackgroundTransparency = 1
    headerRow.LayoutOrder = 0
    headerRow.ZIndex = 3
    headerRow.Parent = content

    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 1, 0)
    header.Position = UDim2.new(0, 4, 0, 0)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.GothamBold
    header.Text = title:upper()
    header.TextColor3 = Color3.fromRGB(255, 60, 80)
    header.TextSize = 12
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.ZIndex = 4
    header.Parent = headerRow

    return card
end

-- Main Tab Builder
function TabViews.build(tabName, parentContainer, options)
    options = options or {}
    local Utils = options.Utils
    local AssetManager = options.AssetManager

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "TabView_" .. tabName
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.Position = UDim2.new(0, 0, 0, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(220, 35, 60)
    scroll.ScrollBarImageTransparency = 0.5
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = false
    scroll.ClipsDescendants = true
    scroll.Parent = parentContainer

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 20)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)
    pad.Parent = scroll

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scroll

    -- Top Header Banner Card with sleek translucent glassmorphism
    local banner = Instance.new("Frame")
    banner.Name = "Banner"
    banner.Size = UDim2.new(0, 396, 0, 44)
    banner.BackgroundColor3 = Color3.fromRGB(24, 14, 20)
    banner.BackgroundTransparency = 0.55
    banner.BorderSizePixel = 0
    banner.ClipsDescendants = true
    banner.LayoutOrder = 1
    banner.Parent = scroll

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 10)
    bCorner.Parent = banner

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(255, 255, 255)
    bStroke.Transparency = 0.92
    bStroke.Thickness = 1
    bStroke.Parent = banner

    local bTitle = Instance.new("TextLabel")
    bTitle.Size = UDim2.new(1, -28, 0, 20)
    bTitle.Position = UDim2.new(0, 14, 0, 4)
    bTitle.BackgroundTransparency = 1
    bTitle.Font = Enum.Font.GothamBold
    bTitle.Text = tabName
    bTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    bTitle.TextSize = 15
    bTitle.TextXAlignment = Enum.TextXAlignment.Left
    bTitle.ZIndex = 3
    bTitle.Parent = banner

    local bDesc = Instance.new("TextLabel")
    bDesc.Size = UDim2.new(1, -28, 0, 15)
    bDesc.Position = UDim2.new(0, 14, 0, 24)
    bDesc.BackgroundTransparency = 1
    bDesc.Font = Enum.Font.GothamMedium
    bDesc.Text = tabName:lower()
    bDesc.TextColor3 = Color3.fromRGB(255, 85, 105)
    bDesc.TextSize = 10.5
    bDesc.TextXAlignment = Enum.TextXAlignment.Left
    bDesc.ZIndex = 3
    bDesc.Parent = banner

    pcall(function()
        if Utils and Utils.makeDraggable and parentContainer and parentContainer.Parent then
            Utils.makeDraggable(parentContainer.Parent, banner)
        end
    end)

    local function makeCard(title)
        return createFeatureCard(scroll, title, AssetManager)
    end

    -- Populate content based on Tab
    if tabName == "Aimbot" then
        local FOVMod = options.FOV
        local AimbotCore = options.AimbotCore
        local PlayerAimbot = options.PlayerAimbot
        local NPCAimbot = options.NPCAimbot
        local BlacklistMod = options.Blacklist
        local TracersMod = options.Tracers
        local SilentAimMod = options.SilentAim

        -- 1. Aimbot (Matching Screenshot 2 EXACTLY!)
        local c1 = makeCard("Aimbot")
        c1.LayoutOrder = 2

        createToggle(c1, "Aimbot", "Automatically aims camera and attacks at target.", false, function(state)
            if AimbotCore and AimbotCore.setAimbot then AimbotCore.setAimbot(state) end
            if AimbotCore and AimbotCore.setLockPlayer then AimbotCore.setLockPlayer(state) end
            if PlayerAimbot then
                if state then PlayerAimbot.enable() else PlayerAimbot.disable() end
            elseif AimbotCore then
                AimbotCore.PlayerAimEnabled = state
                if state then AimbotCore.startLoop() else AimbotCore.stopLoop() end
            end
            _G.G_Aimbot = state
            _G.G_PlayerAim = state
        end, Utils, "rbxassetid://134242818164054")

        createToggle(c1, "NPC Aimbot", "Lock and aim towards monsters and bosses.", false, function(state)
            if NPCAimbot then
                if state then NPCAimbot.enable() else NPCAimbot.disable() end
            elseif AimbotCore then
                AimbotCore.NPCAimEnabled = state
                if state then AimbotCore.startLoop() else AimbotCore.stopLoop() end
            end
            _G.G_NPCAimbot = state
        end, Utils, "rbxassetid://10734887900")

        createToggle(c1, "Aimlock", "Lock and maintain a target lock during combat.", false, function(state)
            if AimbotCore and AimbotCore.setLockPlayer then
                AimbotCore.setLockPlayer(state)
            end
        end, Utils, "rbxassetid://10734950309")

        createToggle(c1, "PvP Check", "Ignore players with PvP disabled.", true, function(state)
            if AimbotCore then AimbotCore.PvPCheck = state end
            if _G.MonodyCombatCore then _G.MonodyCombatCore.PvPCheck = state end
        end, Utils, "rbxassetid://81872698913435")

        createToggle(c1, "Safe Zone Check", "Ignore players in safe zone.", true, function(state)
            if AimbotCore then AimbotCore.SafeZoneCheck = state end
            if _G.MonodyCombatCore then _G.MonodyCombatCore.SafeZoneCheck = state end
        end, Utils, "rbxassetid://10734951847")

        createToggle(c1, "Team Check", "Ignore friendly / allied players.", false, function(state)
            if PlayerAimbot and PlayerAimbot.setTeamCheck then PlayerAimbot.setTeamCheck(state)
            elseif AimbotCore then AimbotCore.TeamCheck = state end
            if _G.MonodyCombatCore then _G.MonodyCombatCore.TeamCheck = state end
        end, Utils, "rbxassetid://115398113982385")

        createDropdown(c1, "Aim Mode", nil, { "Closest", "360°", "FOV", "180°" }, 1, function(opt)
            local mode = "360"
            if opt:find("FOV") then mode = "FOV"
            elseif opt:find("180") then mode = "180" end
            if PlayerAimbot and PlayerAimbot.setAimMode then PlayerAimbot.setAimMode(mode) end
            if AimbotCore then AimbotCore.AimMode = mode end
            if _G.MonodyCombatCore then _G.MonodyCombatCore.AimMode = mode end
        end, Utils, "rbxassetid://134242818164054")

        createDropdown(c1, "Target Priority", nil, { "Nearest", "Low HP", "Looking At Me" }, 1, function(opt)
            if PlayerAimbot and PlayerAimbot.setPriority then PlayerAimbot.setPriority(opt) end
            if AimbotCore then AimbotCore.TargetPriority = opt end
            if _G.MonodyCombatCore then _G.MonodyCombatCore.TargetPriority = opt end
        end, Utils, "rbxassetid://10734898144")

        createSlider(c1, "Max Range", 100, 3000, 1000, function(val)
            if NPCAimbot and NPCAimbot.setMaxRange then NPCAimbot.setMaxRange(val) end
            if PlayerAimbot and PlayerAimbot.setMaxRange then PlayerAimbot.setMaxRange(val) end
            if AimbotCore then AimbotCore.MaxRange = val end
        end, Utils)

        -- 2. Silent Aim
        local c2 = makeCard("Silent Aim")
        c2.LayoutOrder = 3
        createToggle(c2, "Player Silent Aim", "Redirect attacks to players without camera lock.", false, function(state)
            if PlayerAimbot then
                if state then PlayerAimbot.enable() else PlayerAimbot.disable() end
            elseif AimbotCore then
                AimbotCore.PlayerAimEnabled = state
                if state then AimbotCore.startLoop() else AimbotCore.stopLoop() end
            end
            if SilentAimMod and SilentAimMod.setEnabled then SilentAimMod.setEnabled(state) end
            if AimbotCore and not _G.G_Aimbot then AimbotCore.AimbotEnabled = false end
            _G.G_PlayerSilentAim = state
            _G.G_SilentAim = state
        end, Utils)
        createToggle(c2, "NPC Silent Aim", "Redirect attacks to mobs without camera lock.", false, function(state)
            if NPCAimbot then
                if state then NPCAimbot.enable() else NPCAimbot.disable() end
            elseif AimbotCore then
                AimbotCore.NPCAimEnabled = state
                if state then AimbotCore.startLoop() else AimbotCore.stopLoop() end
            end
            _G.G_NPCSilentAim = state
        end, Utils)
        createSlider(c2, "Silent Aim Range", 100, 3000, 1000, function(val)
            if SilentAimMod and SilentAimMod.setMaxDistance then SilentAimMod.setMaxDistance(val) end
            if AimbotCore then AimbotCore.MaxRange = val end
        end, Utils)

        -- 3. FOV
        local c3 = makeCard("FOV")
        c3.LayoutOrder = 4
        createToggle(c3, "FOV Circle", "Draw field of view circle on screen.", false, function(state)
            if FOVMod and FOVMod.setVisible then FOVMod.setVisible(state) end
        end, Utils)
        createSlider(c3, "FOV Radius", 20, 600, 120, function(val)
            if FOVMod and FOVMod.setRadius then FOVMod.setRadius(val) end
            if AimbotCore and AimbotCore.FOV then AimbotCore.FOV.Radius = val end
        end, Utils)
        createDropdown(c3, "Position", nil, { "Center", "Cursor" }, 1, function(opt)
            local mode = opt:find("Cursor") and "Mouse" or "Center"
            if FOVMod and FOVMod.setMode then FOVMod.setMode(mode) end
            if AimbotCore and AimbotCore.FOV then AimbotCore.FOV.Mode = mode end
        end, Utils)
        createColorPicker(c3, "FOV Color", nil, { "Rainbow", "White", "Red", "Green", "Blue", "Yellow", "Purple", "Cyan", "Orange" }, "Rainbow", function(colorName)
            if FOVMod and FOVMod.setColor then FOVMod.setColor(colorName) end
        end, Utils)

        -- 4. Tracers
        local c4 = makeCard("Tracers")
        c4.LayoutOrder = 5
        createToggle(c4, "Show Tracers", "Draw indicator lines towards enemies.", false, function(state)
            if TracersMod and TracersMod.setVisible then TracersMod.setVisible(state) end
        end, Utils)
        createDropdown(c4, "Mode", nil, { "Both (3D + 2D)", "3D Beam", "2D Line" }, 1, function(opt)
            local m = "Both"
            if opt:find("3D") and not opt:find("2D") then m = "3D Beam"
            elseif opt:find("2D") and not opt:find("3D") then m = "2D Line" end
            if TracersMod and TracersMod.setType then TracersMod.setType(m) end
        end, Utils)
        createDropdown(c4, "Origin", nil, { "Player", "Bottom", "Center" }, 1, function(opt)
            local orig = "Player"
            if opt:find("Bottom") then orig = "Bottom"
            elseif opt:find("Center") then orig = "Center" end
            if TracersMod and TracersMod.setOrigin then TracersMod.setOrigin(orig) end
        end, Utils)
        createColorPicker(c4, "Tracer Color", nil, { "Rainbow", "White", "Red", "Green", "Blue", "Yellow", "Purple" }, "White", function(colorName)
            if TracersMod then
                if colorName == "Rainbow" then
                    if TracersMod.setRainbow then TracersMod.setRainbow(true) end
                else
                    local cMap = {
                        White = Color3.fromRGB(255, 255, 255),
                        Red = Color3.fromRGB(255, 60, 60),
                        Green = Color3.fromRGB(60, 255, 120),
                        Blue = Color3.fromRGB(60, 160, 255),
                        Yellow = Color3.fromRGB(255, 225, 60),
                        Purple = Color3.fromRGB(180, 80, 255),
                    }
                    if TracersMod.setColor then
                        TracersMod.setColor(cMap[colorName] or Color3.fromRGB(255, 255, 255))
                    end
                end
            end
        end, Utils)

        -- 5. Skill Blacklist
        local c5 = makeCard("Skill Blacklist")
        c5.LayoutOrder = 6
        createChipGrid(c5, "Exclude Skills", "Tap to blacklist skills from aimbot", {
            "Melee Z", "Melee X", "Melee C",
            "Sword Z", "Sword X",
            "Fruit Z", "Fruit X", "Fruit C", "Fruit V", "Fruit F", "Fruit TAP",
            "Gun Z", "Gun X"
        }, function(chip, isBlacklisted)
            local cat, key = chip:match("^(%a+)%s+(%a+)$")
            if cat and key then
                if BlacklistMod and BlacklistMod.set then
                    BlacklistMod.set(cat, key, isBlacklisted)
                elseif AimbotCore and AimbotCore.BlacklistedKeys and AimbotCore.BlacklistedKeys[cat] then
                    AimbotCore.BlacklistedKeys[cat][key] = isBlacklisted
                end
            end
        end, Utils)

    elseif tabName == "Combat" then
        local DarlingHub = options.DarlingHub or _G.DarlingHub
        local function getMod(path)
            if DarlingHub and DarlingHub.Require then return DarlingHub:Require(path) end
            return nil
        end
        local FastAttack = options.FastAttack or getMod("modules/pvp/fast_attack.lua")
        local DragonGun = options.DragonGun or getMod("modules/pvp/dragon_gun.lua")
        local HitboxExpander = options.HitboxExpander or getMod("modules/combat/hitbox_expander.lua")
        local AutoHaki = options.AutoHaki or getMod("modules/combat/auto_haki.lua")
        local RaceAwakening = options.RaceAwakening or getMod("modules/pvp/race_awakening.lua")
        local SanguineBoost = options.SanguineBoost or getMod("modules/pvp/sanguine_boost.lua")
        local NinjaDash = options.NinjaDash or getMod("modules/pvp/ninja_dash.lua")
        local FruitOneShot = options.FruitOneShot or getMod("modules/pvp/fruits_oneshot.lua")
        local MovementEngine = options.MovementEngine or getMod("modules/movement/movement_engine.lua")
        local AimbotCore = options.AimbotCore or getMod("modules/combat/aimbot_core.lua")

        -- 1. Combat & Attacks
        local c1 = makeCard("Combat Assistance")
        c1.LayoutOrder = 2
        createToggle(c1, "Dragon Gun M1 (Gun Aura)", "Auto-shoots nearest enemies with rapid bursts.", false, function(state)
            if DragonGun and DragonGun.toggle then DragonGun.toggle(state) end
        end, Utils)

        createToggle(c1, "Hitbox Expander", "Expands weapon hitboxes for high range hits.", false, function(state)
            if HitboxExpander and HitboxExpander.toggle then HitboxExpander.toggle(state) end
        end, Utils)

        createSlider(c1, "Hitbox Multiplier", 1, 50, 20, function(val)
            if HitboxExpander and HitboxExpander.setMultiplier then HitboxExpander.setMultiplier(val) end
        end, Utils)

        createToggle(c1, "Lock Player", "Maintains combat focus and aim on selected player.", false, function(state)
            if AimbotCore and AimbotCore.setLockPlayer then AimbotCore.setLockPlayer(state) end
        end, Utils)

        createToggle(c1, "Fast Attack", "Rapid attack bursts for Swords, Melee, and Fruits.", false, function(state)
            if FastAttack then if state then FastAttack.enable() else FastAttack.disable() end end
        end, Utils)

        createSlider(c1, "Attack Delay (s)", 1, 50, 25, function(val)
            if FastAttack then FastAttack.AttackDelay = val / 100 end
        end, Utils)

        createToggle(c1, "Fruit Fast Attack", "High-speed attack bursts for Demon Fruits.", false, function(state)
            if FastAttack then if state then FastAttack.enable() else FastAttack.disable() end end
        end, Utils)

        createToggle(c1, "One Shot Kitsune", "High-potency projectile burst for Kitsune.", false, function(state)
            if FruitOneShot then if state then FruitOneShot.enable() else FruitOneShot.disable() end end
        end, Utils)

        createToggle(c1, "Auto Buso Haki", "Automatically activates Buso Haki during combat.", false, function(state)
            if AutoHaki then if state then AutoHaki.enable() else AutoHaki.disable() end end
        end, Utils)

        createToggle(c1, "Auto Race V3", "Activates Race V3 ability in combat.", false, function(state)
            if RaceAwakening and RaceAwakening.setAutoV3 then RaceAwakening.setAutoV3(state) end
        end, Utils)

        createToggle(c1, "Auto Race V4", "Activates Race V4 awakening automatically.", false, function(state)
            if RaceAwakening and RaceAwakening.setAutoV4 then RaceAwakening.setAutoV4(state) end
        end, Utils)

        createToggle(c1, "Sanguine Boost (Z)", "Accelerated cooldown & range boost for Sanguine.", false, function(state)
            if SanguineBoost and SanguineBoost.toggle then SanguineBoost.toggle(state) end
        end, Utils)

        createToggle(c1, "Ninja Dash", "Zero dash cooldown with extended velocity.", false, function(state)
            if NinjaDash and NinjaDash.toggle then NinjaDash.toggle(state) end
        end, Utils)

        -- 2. Movement & Physics
        local c2 = makeCard("Movement & Physics")
        c2.LayoutOrder = 3
        createToggle(c2, "Fly (Flight)", "Smooth aerial flight controlled with move keys.", false, function(state)
            if MovementEngine and MovementEngine.setFly then MovementEngine.setFly(state) end
        end, Utils)

        createSlider(c2, "Flight Speed", 20, 350, 70, function(val)
            if MovementEngine and MovementEngine.setFlySpeed then MovementEngine.setFlySpeed(val) end
        end, Utils)

        createSlider(c2, "WalkSpeed", 16, 300, 16, function(val)
            if MovementEngine and MovementEngine.setWalkSpeed then MovementEngine.setWalkSpeed(val > 16, val) end
        end, Utils)

        createSlider(c2, "Dash Distance", 20, 200, 50, function(val)
            if MovementEngine and MovementEngine.setDashDistance then MovementEngine.setDashDistance(val > 20, val) end
        end, Utils)

        createToggle(c2, "Super Jump", "Massive upward vertical impulse jump.", false, function(state)
            if MovementEngine and MovementEngine.setSuperJump then MovementEngine.setSuperJump(state, 500) end
        end, Utils)

        createToggle(c2, "Infinite Air Jump", "Jump infinitely in mid-air.", false, function(state)
            if MovementEngine and MovementEngine.setInfiniteJump then MovementEngine.setInfiniteJump(state) end
        end, Utils)

        createToggle(c2, "Walk On Water", "Solid platform allowing walking on ocean waters.", false, function(state)
            if MovementEngine and MovementEngine.setWalkOnWater then MovementEngine.setWalkOnWater(state) end
        end, Utils)

        createToggle(c2, "Noclip", "Pass through all solid collidable structures.", false, function(state)
            if MovementEngine and MovementEngine.setNoclip then MovementEngine.setNoclip(state) end
        end, Utils)

    elseif tabName == "Players" then
        local AimbotCore = options.AimbotCore

        -- 1. Players Overview Card
        local cOverview = makeCard("Server Players")
        cOverview.LayoutOrder = 2

        local playerListContainer = nil
        local activeSpectate = nil

        local function getPlayerRace(plr)
            local r = "Human"
            pcall(function()
                if plr.Character and plr.Character:GetAttribute("Race") then
                    r = tostring(plr.Character:GetAttribute("Race"))
                elseif plr:FindFirstChild("Data") and plr.Data:FindFirstChild("Race") then
                    r = tostring(plr.Data.Race.Value)
                end
            end)
            return r
        end

        local function getPlayerTool(plr)
            local tName = "None"
            pcall(function()
                if plr.Character then
                    local tool = plr.Character:FindFirstChildOfClass("Tool")
                    if tool then tName = tool.Name end
                end
                if tName == "None" and plr:FindFirstChild("Backpack") then
                    local bTool = plr.Backpack:FindFirstChildOfClass("Tool")
                    if bTool then tName = bTool.Name end
                end
            end)
            return tName
        end

        local function rebuildPlayerList()
            if not playerListContainer then return end
            playerListContainer:ClearAllChildren()

            local allPlayers = Players:GetPlayers()
            local count = 0

            for _, plr in ipairs(allPlayers) do
                if plr ~= LocalPlayer then
                    count = count + 1
                    local pRow = Instance.new("Frame")
                    pRow.Name = "PlrRow_" .. plr.Name
                    pRow.Size = UDim2.new(1, 0, 0, 78)
                    pRow.BackgroundColor3 = Color3.fromRGB(24, 16, 22)
                    pRow.BackgroundTransparency = 0.55
                    pRow.BorderSizePixel = 0
                    pRow.Parent = playerListContainer

                    local prCorner = Instance.new("UICorner")
                    prCorner.CornerRadius = UDim.new(0, 8)
                    prCorner.Parent = pRow

                    local prStroke = Instance.new("UIStroke")
                    prStroke.Color = Color3.fromRGB(255, 255, 255)
                    prStroke.Transparency = 0.92
                    prStroke.Thickness = 1
                    prStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    prStroke.Parent = pRow

                    -- Avatar Headshot
                    local headshot = Instance.new("ImageLabel")
                    headshot.Name = "Headshot"
                    headshot.Size = UDim2.new(0, 42, 0, 42)
                    headshot.Position = UDim2.new(0, 8, 0, 8)
                    headshot.BackgroundColor3 = Color3.fromRGB(18, 12, 18)
                    headshot.BackgroundTransparency = 0.3
                    headshot.Image = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=100&h=100"
                    headshot.ScaleType = Enum.ScaleType.Crop
                    headshot.Parent = pRow

                    local hsCorner = Instance.new("UICorner")
                    hsCorner.CornerRadius = UDim.new(1, 0)
                    hsCorner.Parent = headshot

                    -- Name + User
                    local nameLbl = Instance.new("TextLabel")
                    nameLbl.Size = UDim2.new(0, 150, 0, 16)
                    nameLbl.Position = UDim2.new(0, 56, 0, 8)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Font = Enum.Font.GothamBold
                    nameLbl.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
                    nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    nameLbl.TextSize = 11.5
                    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    nameLbl.Parent = pRow

                    -- Race & Hotbar Weapon Tags
                    local tagsLbl = Instance.new("TextLabel")
                    tagsLbl.Size = UDim2.new(0, 200, 0, 14)
                    tagsLbl.Position = UDim2.new(0, 56, 0, 26)
                    tagsLbl.BackgroundTransparency = 1
                    tagsLbl.Font = Enum.Font.GothamMedium
                    local race = getPlayerRace(plr)
                    local toolName = getPlayerTool(plr)
                    tagsLbl.Text = "Race: " .. race .. "  |  Tool: " .. toolName
                    tagsLbl.TextColor3 = Color3.fromRGB(255, 185, 200)
                    tagsLbl.TextSize = 10
                    tagsLbl.TextXAlignment = Enum.TextXAlignment.Left
                    tagsLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    tagsLbl.Parent = pRow

                    -- Health Bar
                    local hpTrack = Instance.new("Frame")
                    hpTrack.Name = "HPTrack"
                    hpTrack.Size = UDim2.new(1, -64, 0, 5)
                    hpTrack.Position = UDim2.new(0, 56, 0, 44)
                    hpTrack.BackgroundColor3 = Color3.fromRGB(40, 26, 36)
                    hpTrack.BorderSizePixel = 0
                    hpTrack.Parent = pRow

                    local hptCorner = Instance.new("UICorner")
                    hptCorner.CornerRadius = UDim.new(1, 0)
                    hptCorner.Parent = hpTrack

                    local hpFill = Instance.new("Frame")
                    hpFill.Name = "HPFill"
                    hpFill.Size = UDim2.new(1, 0, 1, 0)
                    hpFill.BackgroundColor3 = Color3.fromRGB(60, 230, 120)
                    hpFill.BorderSizePixel = 0
                    hpFill.Parent = hpTrack

                    local hpfCorner = Instance.new("UICorner")
                    hpfCorner.CornerRadius = UDim.new(1, 0)
                    hpfCorner.Parent = hpFill

                    pcall(function()
                        if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
                            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                            local ratio = clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
                            hpFill.Size = UDim2.new(ratio, 0, 1, 0)
                        end
                    end)

                    -- 3 Action Buttons on Bottom Row
                    local actionsRow = Instance.new("Frame")
                    actionsRow.Size = UDim2.new(1, -16, 0, 20)
                    actionsRow.Position = UDim2.new(0, 8, 0, 54)
                    actionsRow.BackgroundTransparency = 1
                    actionsRow.Parent = pRow

                    -- 1. Spectate Button
                    local specBtn = Instance.new("TextButton")
                    specBtn.Size = UDim2.new(0, 80, 1, 0)
                    specBtn.Position = UDim2.new(0, 0, 0, 0)
                    specBtn.BackgroundColor3 = (activeSpectate == plr) and Color3.fromRGB(180, 25, 45) or Color3.fromRGB(42, 26, 36)
                    specBtn.BorderSizePixel = 0
                    specBtn.Text = (activeSpectate == plr) and "Stop" or "Spectate"
                    specBtn.Font = Enum.Font.GothamBold
                    specBtn.TextSize = 10.5
                    specBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    specBtn.Parent = actionsRow

                    local sbCorner = Instance.new("UICorner")
                    sbCorner.CornerRadius = UDim.new(0, 4)
                    sbCorner.Parent = specBtn

                    specBtn.MouseButton1Click:Connect(function()
                        local cam = Workspace.CurrentCamera
                        if not cam then return end
                        if activeSpectate == plr then
                            activeSpectate = nil
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                                cam.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            end
                            specBtn.Text = "Spectate"
                            specBtn.BackgroundColor3 = Color3.fromRGB(42, 26, 36)
                        else
                            activeSpectate = plr
                            if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
                                cam.CameraSubject = plr.Character:FindFirstChildOfClass("Humanoid")
                            end
                            specBtn.Text = "Stop"
                            specBtn.BackgroundColor3 = Color3.fromRGB(180, 25, 45)
                        end
                    end)

                    -- 2. Tween To Button
                    local tweenBtn = Instance.new("TextButton")
                    tweenBtn.Size = UDim2.new(0, 80, 1, 0)
                    tweenBtn.Position = UDim2.new(0, 86, 0, 0)
                    tweenBtn.BackgroundColor3 = Color3.fromRGB(42, 26, 36)
                    tweenBtn.BorderSizePixel = 0
                    tweenBtn.Text = "Tween To"
                    tweenBtn.Font = Enum.Font.GothamBold
                    tweenBtn.TextSize = 10.5
                    tweenBtn.TextColor3 = Color3.fromRGB(245, 235, 245)
                    tweenBtn.Parent = actionsRow

                    local tbCorner = Instance.new("UICorner")
                    tbCorner.CornerRadius = UDim.new(0, 4)
                    tbCorner.Parent = tweenBtn

                    tweenBtn.MouseButton1Click:Connect(function()
                        pcall(function()
                            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local targetHRP = plr.Character.HumanoidRootPart
                                local lpHRP = LocalPlayer.Character.HumanoidRootPart
                                local dist = (targetHRP.Position - lpHRP.Position).Magnitude
                                local speed = 250
                                local dur = math.clamp(dist / speed, 0.3, 10)
                                TweenService:Create(lpHRP, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
                                    CFrame = targetHRP.CFrame + Vector3.new(0, 4, 0)
                                    }):Play()
                                if Utils then Utils.toast("Monody", "Tweening to " .. plr.DisplayName, 1.5) end
                            end
                        end)
                    end)

                    -- 3. Blacklist Button
                    local blBtn = Instance.new("TextButton")
                    blBtn.Size = UDim2.new(0, 86, 1, 0)
                    blBtn.Position = UDim2.new(0, 172, 0, 0)
                    local isBl = AimbotCore and AimbotCore.isPlayerExplicitlyBlacklisted and AimbotCore.isPlayerExplicitlyBlacklisted(plr)
                    blBtn.BackgroundColor3 = isBl and Color3.fromRGB(180, 25, 45) or Color3.fromRGB(42, 26, 36)
                    blBtn.BorderSizePixel = 0
                    blBtn.Text = isBl and "Blacklisted" or "Blacklist"
                    blBtn.Font = Enum.Font.GothamBold
                    blBtn.TextSize = 10.5
                    blBtn.TextColor3 = isBl and Color3.fromRGB(255, 180, 190) or Color3.fromRGB(245, 235, 245)
                    blBtn.Parent = actionsRow

                    local blbCorner = Instance.new("UICorner")
                    blbCorner.CornerRadius = UDim.new(0, 4)
                    blbCorner.Parent = blBtn

                    blBtn.MouseButton1Click:Connect(function()
                        if AimbotCore and AimbotCore.setPlayerBlacklisted then
                            isBl = not isBl
                            AimbotCore.setPlayerBlacklisted(plr, isBl)
                            blBtn.Text = isBl and "Blacklisted" or "Blacklist"
                            blBtn.BackgroundColor3 = isBl and Color3.fromRGB(180, 25, 45) or Color3.fromRGB(42, 26, 36)
                            blBtn.TextColor3 = isBl and Color3.fromRGB(255, 180, 190) or Color3.fromRGB(245, 235, 245)
                            if Utils then
                                Utils.toast("Monody", plr.DisplayName .. ": " .. (isBl and "Blacklisted from Aim" or "Unblacklisted"), 1.2)
                            end
                        end
                    end)
                end
            end

            cOverview.Size = UDim2.new(0, 396, 0, math.max(100, 44 + (count * 84)))
        end

        createActionButton(cOverview, "Refresh Players List", "Update server player status.", function()
            rebuildPlayerList()
            if Utils then Utils.toast("Monody", "Player list refreshed", 1.2) end
        end, Utils)

        local targetCont = cOverview:FindFirstChild("Content") or cOverview
        playerListContainer = Instance.new("Frame")
        playerListContainer.Name = "PlayersListHolder"
        playerListContainer.Size = UDim2.new(1, 0, 0, 0)
        playerListContainer.AutomaticSize = Enum.AutomaticSize.Y
        playerListContainer.BackgroundTransparency = 1
        playerListContainer.Parent = targetCont

        local plLayout = Instance.new("UIListLayout")
        plLayout.Padding = UDim.new(0, 6)
        plLayout.SortOrder = Enum.SortOrder.LayoutOrder
        plLayout.Parent = playerListContainer

        rebuildPlayerList()

        local connAdd = Players.PlayerAdded:Connect(rebuildPlayerList)
        local connRem = Players.PlayerRemoving:Connect(rebuildPlayerList)
        scroll.Destroying:Connect(function()
            pcall(function() connAdd:Disconnect() end)
            pcall(function() connRem:Disconnect() end)
        end)

    elseif tabName == "AutoBounty" then
        local DarlingHub = options.DarlingHub or _G.DarlingHub
        local autoBountyMod = options.AutoBounty or (DarlingHub and DarlingHub:Require("modules/combat/auto_bounty.lua"))

        -- 1. Mode & Target Status
        local c1 = makeCard("Auto Bounty Hunter")
        c1.LayoutOrder = 2
        createToggle(c1, "Auto Bounty Mode (Fast Hop)", "Engage high-speed bounty hunter loop.", (autoBountyMod and autoBountyMod.AutoBountyMode == true) or false, function(state)
            if autoBountyMod then
                autoBountyMod.AutoBountyMode = state
                _G.DarlingFastBountyMode = state
                if getgenv then getgenv().DarlingFastBountyMode = state end
            end
        end, Utils)

        createDropdown(c1, "Auto Join Team", "Automatic faction team selection.", { "Pirates", "Marines" }, (autoBountyMod and autoBountyMod.AutoTeam == "Marines") and 2 or 1, function(opt)
            if autoBountyMod then autoBountyMod.AutoTeam = opt end
        end, Utils)

        createActionButton(c1, "Skip Target Player", "Discard current hunt target and pick next player.", function()
            if autoBountyMod and autoBountyMod.SkipTarget then
                autoBountyMod:SkipTarget()
                if Utils then Utils.toast("Auto Bounty", "Skipped target", 1.2) end
            end
        end, Utils)

        -- 2. Movement & Tween Speeds
        local c2 = makeCard("Tween Flight & Speeds")
        c2.LayoutOrder = 3
        createSlider(c2, "Near Tween Speed", 100, 450, (autoBountyMod and autoBountyMod.NearTweenSpeed) or 310, function(val)
            if autoBountyMod then autoBountyMod.NearTweenSpeed = val end
        end, Utils)

        createSlider(c2, "Far Tween Speed", 50, 350, (autoBountyMod and autoBountyMod.FarTweenSpeed) or 200, function(val)
            if autoBountyMod then autoBountyMod.FarTweenSpeed = val end
        end, Utils)

        createSlider(c2, "Tween Threshold (Studs)", 300, 3000, (autoBountyMod and autoBountyMod.TweenThreshold) or 1000, function(val)
            if autoBountyMod then autoBountyMod.TweenThreshold = val end
        end, Utils)

        -- 3. Orbit & Combat Attacks
        local c3 = makeCard("Orbit & Combat Rotation")
        c3.LayoutOrder = 4
        createToggle(c3, "Orbit Target", "Circles around victim during attack bursts.", (autoBountyMod and autoBountyMod.Orbit) or false, function(state)
            if autoBountyMod then autoBountyMod.Orbit = state end
        end, Utils)

        createSlider(c3, "Orbit Distance", 1, 20, (autoBountyMod and autoBountyMod.OrbitDistance) or 3, function(val)
            if autoBountyMod then autoBountyMod.OrbitDistance = val end
        end, Utils)

        createSlider(c3, "Orbit Speed", 2, 30, (autoBountyMod and autoBountyMod.OrbitSpeed) or 12, function(val)
            if autoBountyMod then autoBountyMod.OrbitSpeed = val end
        end, Utils)

        createToggle(c3, "Auto Soru Movement", "Uses Soru/Flashstep to close distances instantly.", (autoBountyMod and autoBountyMod.AutoSoru) or false, function(state)
            if autoBountyMod then autoBountyMod.AutoSoru = state end
        end, Utils)

        createToggle(c3, "Auto Skills Rotation", "Casts weapon and fruit skills during combat.", (autoBountyMod and autoBountyMod.AutoSkills) or false, function(state)
            if autoBountyMod then autoBountyMod.AutoSkills = state end
        end, Utils)

        createToggle(c3, "Auto Buso / Ken Haki", "Maintains Buso & Observation Haki buffs.", (autoBountyMod and autoBountyMod.AutoBuso) or false, function(state)
            if autoBountyMod then
                autoBountyMod.AutoBuso = state
                autoBountyMod.AutoKen = state
            end
        end, Utils)

        createToggle(c3, "Auto Race V4", "Awakens Race V4 instantly upon meter charge.", (autoBountyMod and autoBountyMod.AutoV4) or false, function(state)
            if autoBountyMod then autoBountyMod.AutoV4 = state end
        end, Utils)

        -- 4. Low HP Safety & Server Hop
        local c4 = makeCard("Safety & Server Hop")
        c4.LayoutOrder = 5
        createToggle(c4, "Auto Flee Low HP", "Flees to high altitude when health drops.", (autoBountyMod and autoBountyMod.AutoFlee) or false, function(state)
            if autoBountyMod then autoBountyMod.AutoFlee = state end
        end, Utils)

        createSlider(c4, "Flee HP %", 10, 60, (autoBountyMod and autoBountyMod.FleeHP) or 30, function(val)
            if autoBountyMod then autoBountyMod.FleeHP = val end
        end, Utils)

        createSlider(c4, "Return HP %", 30, 90, (autoBountyMod and autoBountyMod.ReturnHP) or 50, function(val)
            if autoBountyMod then autoBountyMod.ReturnHP = val end
        end, Utils)

        createToggle(c4, "Auto Server Hop", "Hops servers when no valid targets remain.", (autoBountyMod and autoBountyMod.AutoHop) or false, function(state)
            if autoBountyMod then autoBountyMod.AutoHop = state end
        end, Utils)

        createToggle(c4, "Hop If Empty Server", "Hops immediately if player count drops.", (autoBountyMod and autoBountyMod.HopIfEmpty) or true, function(state)
            if autoBountyMod then autoBountyMod.HopIfEmpty = state end
        end, Utils)

        createSlider(c4, "Target Player Count", 2, 14, (autoBountyMod and autoBountyMod.TargetPlayerCount) or 8, function(val)
            if autoBountyMod then autoBountyMod.TargetPlayerCount = val end
        end, Utils)

    elseif tabName == "Soru" then
        local SoruEngine = options.SoruEngine or _G.MonodySoruEngine

        -- 1. Flashstep & Soru Mastery
        local c1 = makeCard("Flashstep & Soru")
        c1.LayoutOrder = 2
        createToggle(c1, "Toggle Soru Cooldown (1s)", "Maintain 1-second Flashstep cooldown.", false, function(state)
            if SoruEngine and SoruEngine.setCooldown1s then
                SoruEngine.setCooldown1s(state)
            else
                local player = Players.LocalPlayer
                local function apply(c)
                    if c and state then pcall(function() c:SetAttribute("FlashstepCooldown", 1) end) end
                end
                if player and player.Character then apply(player.Character) end
            end
        end, Utils)

        createActionButton(c1, "Instant Soru Cooldown (1s)", "Apply 1s cooldown to current character immediately.", function()
            local player = Players.LocalPlayer
            if player and player.Character then
                pcall(function() player.Character:SetAttribute("FlashstepCooldown", 1) end)
            end
            if Utils then Utils.toast("Monody", "Flashstep 1s cooldown applied", 1.5) end
        end, Utils)

        createToggle(c1, "Infinite Soru", "Continuous Flashstep without cooldown.", false, function(state)
            if SoruEngine and SoruEngine.setInfinite then
                SoruEngine.setInfinite(state)
            end
        end, Utils)

        createSlider(c1, "Max Distance", 100, 3000, 1000, function(val)
            if SoruEngine and SoruEngine.setMaxDistance then
                SoruEngine.setMaxDistance(val)
            end
        end, Utils)

        -- 2. Soru Combat & Aimbot
        local c2 = makeCard("Soru Combat")
        c2.LayoutOrder = 3
        createToggle(c2, "Soru Aimbot", "Teleport to target when activating Flashstep [R].", false, function(state)
            if SoruEngine and SoruEngine.setAimbot then
                SoruEngine.setAimbot(state)
            end
        end, Utils)

        createDropdown(c2, "Target Mode", "Teleport target selection.", { "Nearest Player", "Selected Player" }, 1, function(opt)
            if SoruEngine then
                SoruEngine.TargetMode = opt
            end
        end, Utils)

        createActionButton(c2, "Execute Soru Now", "Instantly Flashstep towards target or cursor.", function()
            if SoruEngine and SoruEngine.executeSoru then
                local ok = SoruEngine.executeSoru()
                if ok and Utils then
                    Utils.toast("Monody", "Soru executed successfully", 1.2)
                end
            end
        end, Utils)

    elseif tabName == "Dungeon" then
        local DarlingHub = options.DarlingHub or _G.DarlingHub
        local dungeonMod = options.DungeonEngine or (DarlingHub and DarlingHub:Require("modules/combat/dungeon_engine.lua"))
        local dragonGunMod = options.DragonGun or (DarlingHub and DarlingHub:Require("modules/pvp/dragon_gun.lua"))

        local c1 = makeCard("Dungeon Automation")
        c1.LayoutOrder = 2
        createToggle(c1, "Auto Dungeon", "Clears mobs and bosses above enemies automatically.", (dungeonMod and dungeonMod.Active) or false, function(state)
            if dungeonMod then
                if state then dungeonMod:Start() else dungeonMod:Stop() end
            end
        end, Utils)

        createDropdown(c1, "Equipped Weapon", "Weapon category used for clearing waves.", { "Sword", "Melee", "Blox Fruit" }, 1, function(opt)
            if dungeonMod then dungeonMod.SelectedWeapon = opt end
        end, Utils)

        createSlider(c1, "Attack Height (Studs)", 10, 100, (dungeonMod and dungeonMod.AttackHeight) or 40, function(val)
            if dungeonMod then dungeonMod.AttackHeight = val end
        end, Utils)

        createToggle(c1, "Auto Race V4", "Awakens Race V4 during dungeon battles.", (dungeonMod and dungeonMod.AutoV4) or false, function(state)
            if dungeonMod then dungeonMod.AutoV4 = state end
        end, Utils)

        createToggle(c1, "Dungeon Gun Aura", "Dragon Gun rapid fire against dungeon mobs.", false, function(state)
            if dragonGunMod and dragonGunMod.toggle then dragonGunMod.toggle(state) end
        end, Utils)

        createActionButton(c1, "Pass Current Room Now", "Triggers ExitTeleporter touch to jump to next wave.", function()
            if dungeonMod and dungeonMod.passCurrentRoom then
                dungeonMod.passCurrentRoom()
                if Utils then Utils.toast("Dungeon", "Triggered room bypass", 1.2) end
            end
        end, Utils)

    elseif tabName == "Teleport" then
        local DarlingHub = options.DarlingHub or _G.DarlingHub
        local tpMod = options.TpIslands or (DarlingHub and DarlingHub:Require("modules/movement/tp_islands.lua"))
        local detectedSea = (tpMod and tpMod.GetCurrentSea and tpMod.GetCurrentSea()) or "Sea1"
        local selectedSeaKey = detectedSea

        local seaIslands = {
            Sea1 = { "WindMill", "Marine", "Middle Town", "Jungle", "Pirate Village", "Desert", "Snow Island", "MarineFord", "Colosseum", "Sky Island 1", "Prison", "Magma Village", "Under Water Island", "Fountain City" },
            Sea2 = { "The Cafe", "Frist Spot", "Dark Area", "Flamingo Mansion", "Green Zone", "Factory", "Colossuim", "Zombie Island", "Two Snow Mountain", "Punk Hazard", "Cursed Ship", "Ice Castle", "Forgotten Island" },
            Sea3 = { "Mansion", "Port Town", "Great Tree", "Castle On The Sea", "Hydra Island", "Floating Turtle", "Haunted Castle", "Peanut Island", "Ice Cream Island", "Cake Loaf", "Chocolate Island", "Tiki Outpost" }
        }

        local currentIslandList = seaIslands[selectedSeaKey] or seaIslands.Sea1
        local chosenIsland = currentIslandList[1] or "WindMill"

        local c1 = makeCard("Island Navigation")
        c1.LayoutOrder = 2

        createDropdown(c1, "World / Sea", "Select Blox Fruits world sea.", { "Sea 1", "Sea 2", "Sea 3" }, (selectedSeaKey == "Sea2") and 2 or ((selectedSeaKey == "Sea3") and 3 or 1), function(opt)
            selectedSeaKey = (opt == "Sea 2") and "Sea2" or ((opt == "Sea 3") and "Sea3" or "Sea1")
            currentIslandList = seaIslands[selectedSeaKey] or seaIslands.Sea1
            chosenIsland = currentIslandList[1] or ""
        end, Utils)

        createDropdown(c1, "Target Island", "Destination island for flight tween.", currentIslandList, 1, function(opt)
            chosenIsland = opt
        end, Utils)

        createActionButton(c1, "Teleport To Island", "Fly smoothly to target island.", function()
            if tpMod and tpMod.IslandsData and tpMod.IslandsData[selectedSeaKey] then
                for _, item in ipairs(tpMod.IslandsData[selectedSeaKey]) do
                    if item.name == chosenIsland then
                        tpMod.TweenTo(item.cf, item.name)
                        if Utils then Utils.toast("Teleport", "Flying to " .. chosenIsland, 1.5) end
                        return
                    end
                end
            end
        end, Utils)

        createActionButton(c1, "Stop Teleport", "Cancel any active flight immediately.", function()
            if tpMod and tpMod.StopTween then
                tpMod.StopTween()
                if Utils then Utils.toast("Teleport", "Flight stopped", 1.2) end
            end
        end, Utils)

        createSlider(c1, "Tween Flight Speed", 50, 500, (tpMod and tpMod.TweenSpeed) or 350, function(val)
            if tpMod and tpMod.SetSpeed then tpMod.SetSpeed(val) end
        end, Utils)

        createToggle(c1, "Teleporter Bypass", "Uses entrance portal teleporters when available.", (tpMod and tpMod.UseTeleporterBypass) or true, function(state)
            if tpMod then tpMod.UseTeleporterBypass = state end
        end, Utils)

    elseif tabName == "Visuals" or tabName == "VFX" then
        local DarlingHub = options.DarlingHub or _G.DarlingHub
        local espMod = options.VisualsESP or (DarlingHub and DarlingHub:Require("modules/visuals/esp.lua"))
        local shipPainter = options.ShipPainter or (DarlingHub and DarlingHub:Require("modules/visuals/ship_painter.lua"))

        -- 1. Player ESP
        local c1 = makeCard("Player ESP & Wallhacks")
        c1.LayoutOrder = 2
        createToggle(c1, "2D Quad Boxes", "Renders cornered 2D bounding boxes around enemies.", false, function(state)
            if espMod and espMod.setBoxes then espMod.setBoxes(state) end
        end, Utils)

        createToggle(c1, "Player Names", "Displays formatted usernames directly above heads.", false, function(state)
            if espMod and espMod.setNames then espMod.setNames(state) end
        end, Utils)

        createToggle(c1, "Health Bars", "Dynamic health bars on character bounding boxes.", false, function(state)
            if espMod and espMod.setHealth then espMod.setHealth(state) end
        end, Utils)

        createToggle(c1, "Distance Indicator", "Displays distance in studs below player feet.", false, function(state)
            if espMod and espMod.setDistance then espMod.setDistance(state) end
        end, Utils)

        createToggle(c1, "Equipped Tool / Weapon", "Shows weapon or fruit held by enemies.", false, function(state)
            if espMod and espMod.setTool then espMod.setTool(state) end
        end, Utils)

        createToggle(c1, "Chams / Highlights", "Radiant silhouette highlights through walls.", false, function(state)
            if espMod and espMod.setChams then espMod.setChams(state) end
        end, Utils)

        createToggle(c1, "Multi-Tracers (All Players)", "Dynamic snaplines connecting origin to every player.", false, function(state)
            if espMod and espMod.setTracers then espMod.setTracers(state) end
        end, Utils)

        createDropdown(c1, "Tracer Line Color", "Snapline rendering color.", { "White", "Cyan", "Purple", "Green", "Yellow", "Orange", "Red", "Pink" }, 1, function(selected)
            if espMod and espMod.setTracerColor then
                local colors = {
                    ["White"] = Color3.fromRGB(255, 255, 255),
                    ["Cyan"] = Color3.fromRGB(56, 189, 248),
                    ["Purple"] = Color3.fromRGB(192, 132, 252),
                    ["Green"] = Color3.fromRGB(34, 197, 94),
                    ["Yellow"] = Color3.fromRGB(250, 204, 21),
                    ["Orange"] = Color3.fromRGB(251, 146, 60),
                    ["Red"] = Color3.fromRGB(244, 63, 94),
                    ["Pink"] = Color3.fromRGB(244, 114, 182),
                }
                espMod.setTracerColor(colors[selected] or Color3.fromRGB(255, 255, 255))
            end
        end, Utils)

        -- 2. Ship Painter & Resizer
        local c2 = makeCard("Sacred Ship Customizer")
        c2.LayoutOrder = 3
        createActionButton(c2, "Detect Player Ship", "Scans within 500 studs for pirate ship.", function()
            if shipPainter and shipPainter.findPlayerShip then
                local s = shipPainter.findPlayerShip()
                if Utils then Utils.toast("Ship Painter", s and ("Found ship: " .. s.Name) or "No ship within 500 studs", 2) end
            end
        end, Utils)

        local chosenShipColor = "Purple"
        createDropdown(c2, "Ship Paint Color", "Color tint for ship parts.", { "Red", "Blue", "Green", "Purple", "White", "Yellow", "Void (Black)", "Orange" }, 4, function(c)
            chosenShipColor = c
        end, Utils)

        createActionButton(c2, "Apply Ship Color", "Paints current ship model.", function()
            if shipPainter and shipPainter.applyColorName then
                shipPainter.applyColorName(chosenShipColor)
                if Utils then Utils.toast("Ship Painter", "Painted ship " .. chosenShipColor, 1.5) end
            end
        end, Utils)

        createActionButton(c2, "Reset Ship Colors", "Restores default original materials and colors.", function()
            if shipPainter and shipPainter.resetColors then
                shipPainter.resetColors()
                if Utils then Utils.toast("Ship Painter", "Colors reset", 1.2) end
            end
        end, Utils)

        -- 3. Environment & Shaders
        local c3 = makeCard("Shaders & Environment")
        c3.LayoutOrder = 4
        createToggle(c3, "Clear Sky (No Fog)", "Eliminates atmospheric haze and fog.", true, function(state)
            local Lighting = game:GetService("Lighting")
            if state then
                Lighting.FogEnd = 100000
                Lighting.FogStart = 0
            end
        end, Utils)

        createToggle(c3, "Fullbright Mode", "Maximum ambient lighting in dark areas.", true, function(state)
            local Lighting = game:GetService("Lighting")
            if state then
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.GlobalShadows = false
            end
        end, Utils)

    elseif tabName == "HUD" then
        local DarlingHub = options.DarlingHub or _G.DarlingHub
        local hudMod = options.ControlsHUD or (DarlingHub and DarlingHub:Require("modules/ui/controls_hud.lua"))

        local c1 = makeCard("Controls HUD Editor")
        c1.LayoutOrder = 2

        createActionButton(c1, "Unlock & Drag HUD Buttons", "Enables interactive positioning of all skill buttons.", function()
            if hudMod and hudMod.EnableEditMode then
                hudMod.EnableEditMode()
                if Utils then Utils.toast("HUD Editor", "Dragging unlocked! Move buttons freely.", 2) end
            end
        end, Utils)

        createActionButton(c1, "Save & Lock HUD Layout", "Locks button positions and persists layout.", function()
            if hudMod and hudMod.DisableEditMode then
                hudMod.DisableEditMode(true)
                if Utils then Utils.toast("HUD Editor", "Layout saved & locked!", 1.5) end
            end
        end, Utils)

        createActionButton(c1, "Discard Layout Changes", "Cancels unsaved button movements.", function()
            if hudMod and hudMod.DisableEditMode then
                hudMod.DisableEditMode(false)
                if Utils then Utils.toast("HUD Editor", "Changes discarded", 1.2) end
            end
        end, Utils)

        createSlider(c1, "Global Button Scale (%)", 50, 200, 100, function(val)
            if hudMod and hudMod.SetGlobalScale then
                hudMod.SetGlobalScale(val / 100)
            end
        end, Utils)

        createActionButton(c1, "Reset to Default Positions", "Restores native Blox Fruits HUD layout.", function()
            if hudMod and hudMod.ResetToDefaults then
                hudMod.ResetToDefaults()
                if Utils then Utils.toast("HUD Editor", "Reset to defaults", 1.5) end
            end
        end, Utils)

    elseif tabName == "Macro" then
        local DarlingHub = options.DarlingHub or _G.DarlingHub
        local macroMod = options.MacroEngine or (DarlingHub and DarlingHub:Require("modules/macro/macro_engine.lua"))

        local c1 = makeCard("Macro Skills Combo")
        c1.LayoutOrder = 2

        createToggle(c1, "Loop Macro Sequence", "Repeats skill sequence continuously.", (macroMod and macroMod.Loop) or false, function(state)
            if macroMod and macroMod.SetLoop then macroMod.SetLoop(state) end
        end, Utils)

        createActionButton(c1, "Execute Macro Combo", "Executes configured 6-block weapon skill chain.", function()
            if macroMod and macroMod.Execute then
                macroMod.Execute(1)
                if Utils then Utils.toast("Macro", "Executing combo 1", 1.2) end
            end
        end, Utils)

        createActionButton(c1, "Stop Active Macro", "Immediately stops running combo.", function()
            if macroMod and macroMod.Stop then
                macroMod.Stop()
                if Utils then Utils.toast("Macro", "Stopped", 1.2) end
            end
        end, Utils)

        createToggle(c1, "Floating Mobile Button", "On-screen button for quick combo triggering.", false, function(state)
            if macroMod and macroMod.SetShowMobileButton then
                macroMod.SetShowMobileButton(state)
            end
        end, Utils)

        local c2 = makeCard("Automation & Quests")
        c2.LayoutOrder = 3
        createToggle(c2, "Auto Farm Level", "Accepts quests and farms mobs automatically.", false, nil, Utils)
        createToggle(c2, "Auto Collect Chests", "Flies to chests and collects cash.", false, nil, Utils)
        createSlider(c2, "Flight Speed (Tween)", 50, 350, 220, nil, Utils)

    elseif tabName == "Music" then
        local DarlingHub = options.DarlingHub or _G.DarlingHub
        local musicMod = options.MusicEngine or (DarlingHub and DarlingHub:Require("modules/utility/music_engine.lua"))
        local customAudioId = ""

        local c1 = makeCard("Darling Audio Suite")
        c1.LayoutOrder = 2

        local tracks = { "phonk", "Darling Theme - Lo-Fi Chill", "Anime Vibes - Aesthetic Chill", "Synthwave Night Drive", "Combat Anthem" }
        local selectedTrackName = tracks[1]

        createDropdown(c1, "Preset Soundtrack", "Select background music track.", tracks, 1, function(trackName)
            selectedTrackName = trackName
        end, Utils)

        createActionButton(c1, "Play Selected Track", "Plays chosen background music.", function()
            if musicMod and musicMod.PresetTracks then
                for _, trk in ipairs(musicMod.PresetTracks) do
                    if trk.Name == selectedTrackName then
                        musicMod.play(trk)
                        if Utils then Utils.toast("Music Player", "Playing: " .. trk.Name, 1.5) end
                        return
                    end
                end
            end
            if musicMod and musicMod.play then
                musicMod.play({ Name = selectedTrackName, Id = "1843588265" })
            end
        end, Utils)

        createActionButton(c1, "Stop Audio Playback", "Silences active music player.", function()
            if musicMod and musicMod.stop then
                musicMod.stop()
                if Utils then Utils.toast("Music Player", "Audio stopped", 1.2) end
            end
        end, Utils)

        createSlider(c1, "Volume (%)", 0, 100, 50, function(val)
            if musicMod and musicMod.setVolume then musicMod.setVolume(val / 100) end
        end, Utils)

        createSlider(c1, "Pitch / Speed (%)", 50, 200, 100, function(val)
            if musicMod and musicMod.setPlaybackSpeed then musicMod.setPlaybackSpeed(val / 100) end
        end, Utils)

        createTextInput(c1, "Custom Sound ID", "Enter Roblox Audio Asset ID.", "e.g. 1843588265", "", function(text)
            customAudioId = text:gsub("%D+", "")
        end, Utils)

        createActionButton(c1, "Play Custom Sound", "Stream audio from custom ID.", function()
            if #customAudioId > 0 and musicMod and musicMod.play then
                musicMod.play({ Name = "Custom ID: " .. customAudioId, Id = customAudioId })
                if Utils then Utils.toast("Music Player", "Playing custom sound", 1.5) end
            else
                if Utils then Utils.toast("Music Player", "Please enter a valid sound ID", 2) end
            end
        end, Utils)

    elseif tabName == "Skins" then
        local c1 = makeCard("Cosmetics & VFX")
        c1.LayoutOrder = 2
        createToggle(c1, "Rainbow Weapon Aura", "Multicolor cycling aura on swords and fists.", false, nil, Utils)
        createToggle(c1, "Character Trail", "Radiant trail following character movement.", false, nil, Utils)
        createDropdown(c1, "Aura Color Preset", "Aura color styling.", { "Crimson Void", "Cyber Neon", "Galactic Purple", "Golden Sun", "Frost Blue" }, 1, function(c)
            if Utils then Utils.toast("Cosmetics", "Aura preset: " .. c, 1.2) end
        end, Utils)
        createDropdown(c1, "Character Material", "Cosmetic character body material.", { "Default", "Neon", "ForceField", "Glass", "Foil" }, 1, function(mat)
            pcall(function()
                if LocalPlayer.Character and mat ~= "Default" then
                    for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.Material = Enum.Material[mat] end
                    end
                end
            end)
            if Utils then Utils.toast("Cosmetics", "Applied material: " .. mat, 1.2) end
        end, Utils)

    elseif tabName == "Themes" then
        local onThemeChange = options.onThemeChange

        -- 1. Darling X Wallpapers Gallery
        local c1 = makeCard("Darling X Wallpapers")
        c1.LayoutOrder = 2

        local wallpapers = {
            {
                Name = "Darling Red (Torii & Moon)",
                Desc = "Authentic crimson anime Torii with glowing moon.",
                Asset = (AssetManager and AssetManager.get("sidebar_bg_red.png")) or "rbxassetid://16428787723"
            },
            {
                Name = "Darling Purple (Night Shrine)",
                Desc = "Classic purple Torii shrine under violet night sky.",
                Asset = (AssetManager and (AssetManager.get("sidebar_bg_v2.png") or AssetManager.get("sidebar_bg.png"))) or "rbxassetid://14917571120"
            },
            {
                Name = "Darling Noir (Carbon Silk)",
                Desc = "Sleek dark carbon silk smoke with frosted shading.",
                Asset = (AssetManager and AssetManager.get("card_bg.png")) or "rbxassetid://11401839801"
            },
            {
                Name = "Darling Cyber (Neon Red)",
                Desc = "Futuristic crimson cybernetic horizon lattice.",
                Asset = "rbxassetid://15340058564"
            },
            {
                Name = "Darling Galaxy (Midnight Stars)",
                Desc = "Deep cosmic violet starfield nebula.",
                Asset = "rbxassetid://11401839801"
            },
            {
                Name = "Darling Acrylic (Pure Glass)",
                Desc = "Clean translucent acrylic frosted glass (no image).",
                Asset = ""
            }
        }

        for _, wp in ipairs(wallpapers) do
            createActionButton(c1, wp.Name, wp.Desc, function()
                if onThemeChange then
                    onThemeChange({ Background = wp.Asset })
                end
                if Utils then
                    Utils.toast("Darling X Themes", "Applied " .. wp.Name, 1.5)
                end
            end, Utils)
        end

        local customWpUrl = ""
        createTextInput(c1, "Custom Wallpaper URL", "Direct image link (.png / .jpg) or asset ID.", "https://... or rbxassetid://...", "", function(text)
            customWpUrl = text
        end, Utils)

        createActionButton(c1, "Apply Custom Wallpaper", "Sets background to custom image.", function()
            if #customWpUrl > 0 and onThemeChange then
                onThemeChange({ Background = customWpUrl })
                if Utils then Utils.toast("Themes", "Custom wallpaper applied", 1.5) end
            end
        end, Utils)

        -- 2. Glassmorphism & Opacity
        local c2 = makeCard("Glassmorphism & Opacity")
        c2.LayoutOrder = 3

        createSlider(c2, "Wallpaper Opacity (%)", 10, 100, 65, function(val)
            if onThemeChange then
                onThemeChange({ ImageTransparency = 1 - (val / 100) })
            end
        end, Utils)

        createSlider(c2, "Glass Frosted Tint (%)", 0, 90, 45, function(val)
            if onThemeChange then
                onThemeChange({ BackgroundTransparency = (val / 100) })
            end
        end, Utils)

        createSlider(c2, "Atmospheric Blur", 0, 15, 4, function(val)
            if onThemeChange then
                onThemeChange({ BlurSize = val })
            end
        end, Utils)

        createToggle(c2, "Dim 3D World (Cinematic)", "Subtle depth-of-field contrast in background.", true, function(state)
            if onThemeChange then
                onThemeChange({ DimEnabled = state })
            end
        end, Utils)

        -- 3. Accent Color Presets
        local c3 = makeCard("Accent Colors")
        c3.LayoutOrder = 4

        createColorPicker(c3, "Accent Preset", "Select interface accent color", {
            "Crimson", "Ruby", "Purple", "Cyan", "Jade", "White"
        }, "Crimson", function(colorName)
            if Utils then
                Utils.toast("Themes", "Accent preset: " .. colorName, 1.2)
            end
        end, Utils)

    elseif tabName == "Settings" then
        local DarlingHub = options.DarlingHub or _G.DarlingHub
        local c1 = makeCard("Interface Settings")
        c1.LayoutOrder = 2
        createSlider(c1, "UI Scale (%)", 50, 120, 80, function(val)
            if options.onScaleChange then pcall(options.onScaleChange, val / 100) end
        end, Utils)

        createDropdown(c1, "Hub Toggle Keybind", "PC keyboard shortcut to toggle UI.", { "F", "RightShift", "LeftAlt", "Insert" }, 1, function(k)
            if Utils then Utils.toast("Settings", "Toggle keybind set to: " .. k, 1.2) end
        end, Utils)

        createToggle(c1, "Auto-Save Settings", "Persists configuration changes automatically.", true, function(state)
            if DarlingHub then DarlingHub.AutoSaveEnabled = state end
        end, Utils)

        createActionButton(c1, "Save Configuration Now", "Write active settings to disk immediately.", function()
            if DarlingHub and DarlingHub.SaveConfig then
                pcall(DarlingHub.SaveConfig)
                if Utils then Utils.toast("Settings", "Configuration saved!", 1.5) end
            end
        end, Utils)

        local c2 = makeCard("Server Utilities")
        c2.LayoutOrder = 3
        createActionButton(c2, "Rejoin Current Server", "Rejoin the current place instance.", function()
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        end, Utils)

        createActionButton(c2, "Hop Server", "Find and join a different public server.", function()
            if Utils then Utils.toast("Settings", "Searching for server...", 1.5) end
            pcall(function()
                local bMod = DarlingHub and DarlingHub:Require("modules/combat/auto_bounty.lua")
                if bMod and bMod.ServerHop then bMod:ServerHop() end
            end)
        end, Utils)

        createActionButton(c2, "Copy Official Discord", "Copy invite link to clipboard.", function()
            Utils.setClipboard("https://discord.gg/besthub")
            if Utils then Utils.toast("Monody", "Discord copied to clipboard", 2) end
        end, Utils)

        createActionButton(c2, "Unload Monody UI", "Safely unhook and destroy UI.", function()
            if options.onClose then pcall(options.onClose) end
        end, Utils)
    end

    -- Calculate total CanvasSize accurately
    local function updateCanvasSize()
        local total = 50 + 14 -- banner (50) + padding (14)
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("GuiObject") and child.Name:find("^Card_") then
                total = total + child.Size.Y.Offset + 8
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, total + 30)
    end
    updateCanvasSize()
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    scroll:GetPropertyChangedSignal("Visible"):Connect(function()
        if scroll.Visible then
            updateCanvasSize()
            pcall(function() scroll.CanvasPosition = Vector2.new(0, 0) end)
        end
    end)

    return scroll
end

return TabViews
