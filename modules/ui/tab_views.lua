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

-- Helper: Create interactive Toggle (Pure Native UI matching reference IMG_9181.jpeg)
local function createToggle(parent, title, desc, defaultState, onToggle, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent
    local state = defaultState or false

    local row = Instance.new("Frame")
    row.Name = "Toggle_" .. title:gsub("%s+", "")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundTransparency = 1
    row.ZIndex = 3
    row.Parent = targetContainer

    addCardHeight(parent, 44)

    -- Left Text (Title + Short Desc matching IMG_9181.jpeg)
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -56, 1, 0)
    textContainer.Position = UDim2.new(0, 8, 0, 0)
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
    titleLbl.TextSize = 12.5
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = textContainer

    if hasDesc then
        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, 0, 0, 15)
        descLbl.Position = UDim2.new(0, 0, 0, 22)
        descLbl.BackgroundTransparency = 1
        descLbl.Font = Enum.Font.Gotham
        descLbl.Text = desc
        descLbl.TextColor3 = Color3.fromRGB(180, 175, 205)
        descLbl.TextSize = 9.5
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex = 4
        descLbl.Parent = textContainer
    end

    -- Pill Switch Visual (Clean styling matching reference crop_toggles.png without purple borders)
    -- When ON: Pure clean white capsule with dark circular thumb
    -- When OFF: Sleek dark slate capsule with soft light-grey circular thumb
    local switchBtn = Instance.new("Frame")
    switchBtn.Name = "SwitchVisual"
    switchBtn.Size = UDim2.new(0, 42, 0, 22)
    switchBtn.Position = UDim2.new(1, -46, 0.5, -11)
    switchBtn.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(46, 44, 56)
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
    thumb.BackgroundColor3 = state and Color3.fromRGB(26, 24, 32) or Color3.fromRGB(182, 180, 196)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 5
    thumb.Parent = switchBtn

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb

    local function updateVisual(anim)
        local dur = anim and 0.15 or 0
        local targetBg = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(46, 44, 56)
        local targetThumbBg = state and Color3.fromRGB(26, 24, 32) or Color3.fromRGB(182, 180, 196)
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

-- Helper: Create interactive Dropdown with icon and chevron (e.g. Aim Mode -> Closest v)
-- Helper: Create interactive Dropdown with chevron pill (e.g. Aim Mode -> Closest v)
local function createDropdown(parent, title, desc, optionsList, defaultIndex, onSelect, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent
    local curIdx = defaultIndex or 1
    optionsList = (optionsList and #optionsList > 0) and optionsList or { "Default" }

    local row = Instance.new("Frame")
    row.Name = "Dropdown_" .. title:gsub("%s+", "")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundTransparency = 1
    row.ZIndex = 3
    row.Parent = targetContainer

    addCardHeight(parent, 44)

    -- Left Text
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -120, 1, 0)
    textContainer.Position = UDim2.new(0, 8, 0, 0)
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
    titleLbl.TextSize = 12.5
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = textContainer

    if hasDesc then
        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, 0, 0, 15)
        descLbl.Position = UDim2.new(0, 0, 0, 22)
        descLbl.BackgroundTransparency = 1
        descLbl.Font = Enum.Font.Gotham
        descLbl.Text = desc
        descLbl.TextColor3 = Color3.fromRGB(180, 175, 205)
        descLbl.TextSize = 9.5
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex = 4
        descLbl.Parent = textContainer
    end

    -- Right Pill Button with Option Text and Down Chevron
    local pillBtn = Instance.new("TextButton")
    pillBtn.Name = "PillBtn"
    pillBtn.Size = UDim2.new(0, 104, 0, 26)
    pillBtn.Position = UDim2.new(1, -108, 0.5, -13)
    pillBtn.BackgroundColor3 = Color3.fromRGB(26, 20, 38)
    pillBtn.BorderSizePixel = 0
    pillBtn.Text = ""
    pillBtn.AutoButtonColor = false
    pillBtn.Active = true
    pillBtn.ZIndex = 5
    pillBtn.Parent = row

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(0, 6)
    pillCorner.Parent = pillBtn

    local pillText = Instance.new("TextLabel")
    pillText.Name = "PillText"
    pillText.Size = UDim2.new(1, -22, 1, 0)
    pillText.Position = UDim2.new(0, 8, 0, 0)
    pillText.BackgroundTransparency = 1
    pillText.Font = Enum.Font.GothamBold
    pillText.Text = optionsList[curIdx] or ""
    pillText.TextColor3 = Color3.fromRGB(255, 255, 255)
    pillText.TextSize = 11
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
    chevron.TextColor3 = Color3.fromRGB(225, 175, 255)
    chevron.ZIndex = 6
    chevron.Parent = pillBtn

    local lastCycle = 0
    local function cycleOption()
        local now = tick()
        if lastCycle > 0 and (now - lastCycle < 0.25) then return end
        lastCycle = now

        curIdx = curIdx + 1
        if curIdx > #optionsList then curIdx = 1 end
        local chosen = optionsList[curIdx]
        pillText.Text = chosen

        TweenService:Create(pillBtn, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(48, 36, 70) }):Play()
        task.delay(0.1, function()
            TweenService:Create(pillBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(26, 20, 38) }):Play()
        end)

        if onSelect then pcall(onSelect, chosen, curIdx) end
    end

    pillBtn.Activated:Connect(cycleOption)
    pillBtn.MouseButton1Click:Connect(cycleOption)

    return row
end

-- Helper: Create interactive Slider with Cyber HUD Badge & Glowing Neon Fill
local function createSlider(parent, title, minVal, maxVal, defaultVal, onSlide, Utils, customIcon)
    local targetContainer = parent:FindFirstChild("Content") or parent
    local curVal = clamp(defaultVal or minVal, minVal, maxVal)

    local row = Instance.new("Frame")
    row.Name = "Slider_" .. title:gsub("%s+", "")
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundTransparency = 1
    row.ZIndex = 3
    row.Parent = targetContainer

    addCardHeight(parent, 48)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 20)
    header.BackgroundTransparency = 1
    header.ZIndex = 3
    header.Parent = row

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -60, 1, 0)
    titleLbl.Position = UDim2.new(0, 4, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(245, 240, 255)
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = header

    -- Cyber HUD Glowing Value Badge [ 120 ]
    local valBadge = Instance.new("Frame")
    valBadge.Name = "ValBadge"
    valBadge.Size = UDim2.new(0, 52, 0, 18)
    valBadge.Position = UDim2.new(1, -56, 0, 1)
    valBadge.BackgroundColor3 = Color3.fromRGB(34, 25, 48)
    valBadge.BorderSizePixel = 0
    valBadge.ZIndex = 4
    valBadge.Parent = header

    local vbCorner = Instance.new("UICorner")
    vbCorner.CornerRadius = UDim.new(0, 5)
    vbCorner.Parent = valBadge

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(1, 0, 1, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.Text = tostring(math.floor(curVal + 0.5))
    valLbl.TextColor3 = Color3.fromRGB(245, 220, 255)
    valLbl.TextSize = 11
    valLbl.ZIndex = 5
    valLbl.Parent = valBadge

    -- Slider Track Frame with Glowing Neon Gradient Fill
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, -8, 0, 6)
    track.Position = UDim2.new(0, 4, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(24, 18, 34)
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
    fill.BackgroundColor3 = Color3.fromRGB(165, 75, 245)
    fill.BorderSizePixel = 0
    fill.ZIndex = 5
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    pcall(function()
        if ColorSequence and ColorSequence.new then
            local fillGrad = Instance.new("UIGradient")
            fillGrad.Color = ColorSequence.new(Color3.fromRGB(130, 45, 220), Color3.fromRGB(230, 150, 255))
            fillGrad.Parent = fill
        end
    end)

    -- Clean Pure White Circular Thumb Knob (No purple border)
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

-- Helper: Create Action Button with neon purple hover
local function createActionButton(parent, title, desc, onClick, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent

    local btn = Instance.new("TextButton")
    btn.Name = "Btn_" .. title:gsub("%s+", "")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(28, 22, 42)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Active = true
    btn.ZIndex = 4
    btn.Parent = targetContainer

    addCardHeight(parent, 36)

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 8)
    bCorner.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(42, 30, 65) }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(28, 22, 42) }):Play()
    end)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(250, 245, 255)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 5
    lbl.Parent = btn

    local lastPress = 0
    local function onPress()
        local now = tick()
        if lastPress > 0 and (now - lastPress < 0.25) then return end
        lastPress = now

        TweenService:Create(btn, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(155, 75, 245) }):Play()
        task.delay(0.1, function()
            TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(28, 22, 42) }):Play()
        end)
        if onClick then pcall(onClick) end
    end

    btn.Activated:Connect(onPress)
    btn.MouseButton1Click:Connect(onPress)
    return btn
end

-- Helper: Create Color Picker Palette
local function createColorPicker(parent, title, desc, colorNames, defaultColorName, onSelectColor, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent
    local selected = defaultColorName or "Rainbow"
    colorNames = colorNames or { "Rainbow", "White", "Red", "Green", "Blue", "Yellow", "Purple" }
    local containerHeight = 64

    local container = Instance.new("Frame")
    container.Name = "ColorPicker_" .. title:gsub("%s+", "")
    container.Size = UDim2.new(1, 0, 0, containerHeight)
    container.BackgroundTransparency = 1
    container.ZIndex = 3
    container.Parent = targetContainer

    addCardHeight(parent, containerHeight)

    local headerRow = Instance.new("Frame")
    headerRow.Size = UDim2.new(1, 0, 0, 20)
    headerRow.BackgroundTransparency = 1
    headerRow.ZIndex = 3
    headerRow.Parent = container

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.6, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 4, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(240, 240, 250)
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = headerRow

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.4, -8, 1, 0)
    valLbl.Position = UDim2.new(0.6, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.Text = selected
    valLbl.TextColor3 = Color3.fromRGB(215, 175, 255)
    valLbl.TextSize = 11.5
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 4
    valLbl.Parent = headerRow

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "PaletteScroll"
    scroll.Size = UDim2.new(1, -8, 0, 30)
    scroll.Position = UDim2.new(0, 4, 0, 26)
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
            pill.Stroke.Color = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(48, 44, 58)
            pill.Stroke.Thickness = isSel and 1.5 or 1
            pill.Frame.BackgroundColor3 = isSel and Color3.fromRGB(115, 55, 185) or Color3.fromRGB(26, 20, 38)
        end
        valLbl.Text = selected
    end

    local lastPickTick = 0
    for idx, cName in ipairs(colorNames) do
        local pill = Instance.new("TextButton")
        pill.Name = "Color_" .. cName
        pill.Size = UDim2.new(0, 70, 0, 24)
        pill.BackgroundColor3 = (cName == selected) and Color3.fromRGB(115, 55, 185) or Color3.fromRGB(26, 20, 38)
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
        pStroke.Color = (cName == selected) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(48, 44, 58)
        pStroke.Thickness = (cName == selected) and 1.5 or 1
        pStroke.Parent = pill

        colorPills[cName] = { Frame = pill, Stroke = pStroke }

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

-- Helper: Create Chip Grid for Blacklist
local function createChipGrid(parent, title, desc, chipsList, onToggleChip, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent
    local blacklisted = {}
    local totalHeight = 136

    local container = Instance.new("Frame")
    container.Name = "ChipGrid_" .. title:gsub("%s+", "")
    container.Size = UDim2.new(1, 0, 0, totalHeight)
    container.BackgroundTransparency = 1
    container.ZIndex = 3
    container.Parent = targetContainer

    addCardHeight(parent, totalHeight)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 18)
    titleLbl.Position = UDim2.new(0, 4, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(240, 240, 250)
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = container

    local gridFrame = Instance.new("Frame")
    gridFrame.Name = "Grid"
    gridFrame.Size = UDim2.new(1, -8, 0, 110)
    gridFrame.Position = UDim2.new(0, 4, 0, 24)
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
        chip.BackgroundColor3 = Color3.fromRGB(26, 20, 38)
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

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(48, 44, 58)
        cStroke.Thickness = 1
        cStroke.Parent = chip

        local isBl = false
        chip.MouseButton1Click:Connect(function()
            isBl = not isBl
            blacklisted[chipName] = isBl
            local targetBg = isBl and Color3.fromRGB(95, 25, 45) or Color3.fromRGB(26, 20, 38)
            local targetStroke = isBl and Color3.fromRGB(255, 75, 95) or Color3.fromRGB(48, 44, 58)
            local targetText = isBl and Color3.fromRGB(255, 180, 190) or Color3.fromRGB(215, 210, 230)

            TweenService:Create(chip, TweenInfo.new(0.12), { BackgroundColor3 = targetBg, TextColor3 = targetText }):Play()
            cStroke.Color = targetStroke
            if onToggleChip then pcall(onToggleChip, chipName, isBl) end
        end)
    end

    return container
end

-- Helper: Create Feature Card with glowing purple header divider (Pure Native UI - No AI Image Slop)
local function createFeatureCard(parent, title, AssetManager)
    local card = Instance.new("Frame")
    card.Name = "Card_" .. title:gsub("%s+", "")
    card.Size = UDim2.new(0, 396, 0, 36)
    card.BackgroundColor3 = Color3.fromRGB(18, 14, 26)
    card.BackgroundTransparency = 0.08
    card.BorderSizePixel = 0
    card.Parent = parent

    cardHeights[card] = 36

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = card

    -- Silky smoke texture from card_bg.png matching reference IMG_9181.jpeg
    local bgImg = Instance.new("ImageLabel")
    bgImg.Name = "CardBg"
    bgImg.Size = UDim2.new(1, 0, 1, 0)
    bgImg.BackgroundTransparency = 1
    bgImg.Image = ""
    if AssetManager and AssetManager.bindImage then
        AssetManager.bindImage(bgImg, "card_bg.png")
    else
        bgImg.Image = (AssetManager and AssetManager.get("card_bg.png")) or ""
    end
    bgImg.ScaleType = Enum.ScaleType.Stretch
    bgImg.ImageTransparency = 0.55
    bgImg.ZIndex = 1
    bgImg.Parent = card

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 10)
    bgCorner.Parent = bgImg

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.ZIndex = 2
    content.Parent = card

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    -- Header row with glowing purple divider line (Matching Screenshot 2)
    local headerRow = Instance.new("Frame")
    headerRow.Name = "HeaderRow"
    headerRow.Size = UDim2.new(1, 0, 0, 20)
    headerRow.BackgroundTransparency = 1
    headerRow.LayoutOrder = 0
    headerRow.ZIndex = 3
    headerRow.Parent = content

    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(0, 80, 1, 0)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.GothamBold
    header.Text = title:upper()
    header.TextColor3 = Color3.fromRGB(225, 215, 245)
    header.TextSize = 11
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.ZIndex = 4
    header.Parent = headerRow

    -- Glowing Purple Horizontal Neon Divider
    local neonLine = Instance.new("Frame")
    neonLine.Name = "NeonLine"
    neonLine.Size = UDim2.new(1, -85, 0, 1.5)
    neonLine.Position = UDim2.new(0, 85, 0.5, 0)
    neonLine.BackgroundColor3 = Color3.fromRGB(195, 125, 255)
    neonLine.BorderSizePixel = 0
    neonLine.ZIndex = 4
    neonLine.Parent = headerRow

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
    scroll.ScrollBarThickness = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 800)
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

    -- Top Header Banner Card with silky texture and neon rim matching IMG_9181.jpeg
    local banner = Instance.new("Frame")
    banner.Name = "Banner"
    banner.Size = UDim2.new(0, 396, 0, 48)
    banner.BackgroundColor3 = Color3.fromRGB(22, 16, 32)
    banner.BackgroundTransparency = 0.08
    banner.BorderSizePixel = 0
    banner.LayoutOrder = 1
    banner.Parent = scroll

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 10)
    bCorner.Parent = banner

    local bBg = Instance.new("ImageLabel")
    bBg.Name = "BannerBg"
    bBg.Size = UDim2.new(1, 0, 1, 0)
    bBg.BackgroundTransparency = 1
    bBg.Image = ""
    if AssetManager and AssetManager.bindImage then
        AssetManager.bindImage(bBg, "card_bg.png")
    else
        bBg.Image = (AssetManager and AssetManager.get("card_bg.png")) or ""
    end
    bBg.ScaleType = Enum.ScaleType.Stretch
    bBg.ImageTransparency = 0.5
    bBg.ZIndex = 1
    bBg.Parent = banner

    local bBgCorner = Instance.new("UICorner")
    bBgCorner.CornerRadius = UDim.new(0, 10)
    bBgCorner.Parent = bBg

    local bTitle = Instance.new("TextLabel")
    bTitle.Size = UDim2.new(1, -28, 0, 20)
    bTitle.Position = UDim2.new(0, 14, 0, 5)
    bTitle.BackgroundTransparency = 1
    bTitle.Font = Enum.Font.GothamBold
    bTitle.Text = tabName
    bTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    bTitle.TextSize = 16
    bTitle.TextXAlignment = Enum.TextXAlignment.Left
    bTitle.ZIndex = 3
    bTitle.Parent = banner

    local bDesc = Instance.new("TextLabel")
    bDesc.Size = UDim2.new(1, -28, 0, 15)
    bDesc.Position = UDim2.new(0, 14, 0, 26)
    bDesc.BackgroundTransparency = 1
    bDesc.Font = Enum.Font.Gotham
    bDesc.Text = tabName:lower()
    bDesc.TextColor3 = Color3.fromRGB(185, 175, 215)
    bDesc.TextSize = 11
    bDesc.TextXAlignment = Enum.TextXAlignment.Left
    bDesc.ZIndex = 3
    bDesc.Parent = banner

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
        local c1 = makeCard("Auto Combat")
        c1.LayoutOrder = 2
        createToggle(c1, "Fast Attack", "Fast attack with zero animation delay.", true, nil, Utils)
        createToggle(c1, "Auto Clicker", "Automatic attack spammer.", false, nil, Utils)
        createToggle(c1, "Auto Skills Combo", "Cast Z, X, C, V skills automatically.", false, nil, Utils)
        createToggle(c1, "Kill Aura", "Damage all nearby enemies.", false, nil, Utils)

        local c2 = makeCard("Range & Weapons")
        c2.LayoutOrder = 3
        createSlider(c2, "Attack Range", 10, 60, 28, nil, Utils)
        createActionButton(c2, "Equip Best Weapon", "Equip your highest damage weapon.", function()
            if Utils then Utils.toast("Monody", "Equipped best weapon", 1.5) end
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
                    pRow.BackgroundColor3 = Color3.fromRGB(24, 18, 38)
                    pRow.BackgroundTransparency = 0.25
                    pRow.BorderSizePixel = 0
                    pRow.Parent = playerListContainer

                    local prCorner = Instance.new("UICorner")
                    prCorner.CornerRadius = UDim.new(0, 8)
                    prCorner.Parent = pRow

                    -- Avatar Headshot
                    local headshot = Instance.new("ImageLabel")
                    headshot.Name = "Headshot"
                    headshot.Size = UDim2.new(0, 42, 0, 42)
                    headshot.Position = UDim2.new(0, 8, 0, 8)
                    headshot.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
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
                    tagsLbl.TextColor3 = Color3.fromRGB(215, 175, 255)
                    tagsLbl.TextSize = 10
                    tagsLbl.TextXAlignment = Enum.TextXAlignment.Left
                    tagsLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    tagsLbl.Parent = pRow

                    -- Health Bar
                    local hpTrack = Instance.new("Frame")
                    hpTrack.Name = "HPTrack"
                    hpTrack.Size = UDim2.new(1, -64, 0, 5)
                    hpTrack.Position = UDim2.new(0, 56, 0, 44)
                    hpTrack.BackgroundColor3 = Color3.fromRGB(40, 32, 54)
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
                    specBtn.BackgroundColor3 = (activeSpectate == plr) and Color3.fromRGB(160, 40, 70) or Color3.fromRGB(45, 35, 68)
                    specBtn.BorderSizePixel = 0
                    specBtn.Text = (activeSpectate == plr) and "Stop" or "Spectate"
                    specBtn.Font = Enum.Font.GothamBold
                    specBtn.TextSize = 10
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
                            specBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 68)
                        else
                            activeSpectate = plr
                            if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
                                cam.CameraSubject = plr.Character:FindFirstChildOfClass("Humanoid")
                            end
                            specBtn.Text = "Stop"
                            specBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 70)
                        end
                    end)

                    -- 2. Tween To Button
                    local tweenBtn = Instance.new("TextButton")
                    tweenBtn.Size = UDim2.new(0, 80, 1, 0)
                    tweenBtn.Position = UDim2.new(0, 86, 0, 0)
                    tweenBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 68)
                    tweenBtn.BorderSizePixel = 0
                    tweenBtn.Text = "Tween To"
                    tweenBtn.Font = Enum.Font.GothamBold
                    tweenBtn.TextSize = 10
                    tweenBtn.TextColor3 = Color3.fromRGB(225, 215, 255)
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
                    blBtn.BackgroundColor3 = isBl and Color3.fromRGB(140, 30, 50) or Color3.fromRGB(45, 35, 68)
                    blBtn.BorderSizePixel = 0
                    blBtn.Text = isBl and "Blacklisted" or "Blacklist"
                    blBtn.Font = Enum.Font.GothamBold
                    blBtn.TextSize = 10
                    blBtn.TextColor3 = isBl and Color3.fromRGB(255, 180, 190) or Color3.fromRGB(225, 215, 255)
                    blBtn.Parent = actionsRow

                    local blbCorner = Instance.new("UICorner")
                    blbCorner.CornerRadius = UDim.new(0, 4)
                    blbCorner.Parent = blBtn

                    blBtn.MouseButton1Click:Connect(function()
                        if AimbotCore and AimbotCore.setPlayerBlacklisted then
                            isBl = not isBl
                            AimbotCore.setPlayerBlacklisted(plr, isBl)
                            blBtn.Text = isBl and "Blacklisted" or "Blacklist"
                            blBtn.BackgroundColor3 = isBl and Color3.fromRGB(140, 30, 50) or Color3.fromRGB(45, 35, 68)
                            blBtn.TextColor3 = isBl and Color3.fromRGB(255, 180, 190) or Color3.fromRGB(225, 215, 255)
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

    elseif tabName == "Macro" then
        local c1 = makeCard("Automation & Farm")
        c1.LayoutOrder = 2
        createToggle(c1, "Auto Farm Level", "Accept quests and farm mobs automatically.", false, nil, Utils)
        createToggle(c1, "Auto Farm Nearest", "Attack nearest enemy mobs.", false, nil, Utils)
        createToggle(c1, "Auto Collect Chests", "Fly to chests and collect cash.", false, nil, Utils)

        local c2 = makeCard("Tween Speed")
        c2.LayoutOrder = 3
        createSlider(c2, "Flight Speed (Tween)", 50, 350, 220, nil, Utils)
        createActionButton(c2, "Stop Macro", "Cancel any active route.", function()
            if Utils then Utils.toast("Monody", "Macro stopped", 1.5) end
        end, Utils)

    elseif tabName == "VFX" then
        local c1 = makeCard("Optimization & Graphics")
        c1.LayoutOrder = 2
        createToggle(c1, "Clear Sky (No Fog)", "Eliminate atmospheric fog.", true, nil, Utils)
        createToggle(c1, "Fullbright Mode", "Maximum ambient lighting in dark areas.", true, nil, Utils)
        createToggle(c1, "Mobile FPS Boost", "Reduce particles and textures for smoothness.", false, nil, Utils)
        createToggle(c1, "Disable Shadows", "Improve performance on low-end devices.", false, nil, Utils)

    elseif tabName == "Skins" then
        local c1 = makeCard("Cosmetics & Effects")
        c1.LayoutOrder = 2
        createToggle(c1, "Rainbow Weapon Aura", "Multicolor aura on swords and fists.", false, nil, Utils)
        createToggle(c1, "Character Trail", "Light trail following character movement.", false, nil, Utils)
        createActionButton(c1, "Cycle Aura Color", "Cycle through available aura colors.", function()
            if Utils then Utils.toast("Monody", "Aura changed to Neon Cyan", 1.5) end
        end, Utils)

    elseif tabName == "Settings" then
        local c1 = makeCard("Interface Settings")
        c1.LayoutOrder = 2
        createSlider(c1, "UI Scale (%)", 50, 120, 80, function(val)
            if options.onScaleChange then pcall(options.onScaleChange, val / 100) end
        end, Utils)

        local c2 = makeCard("Server Utilities")
        c2.LayoutOrder = 3
        createActionButton(c2, "Rejoin Server", "Rejoin the current server instance.", function()
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        end, Utils)
        createActionButton(c2, "Copy Official Discord", "Copy invite link to clipboard.", function()
            Utils.setClipboard("https://discord.gg/besthub")
            if Utils then Utils.toast("Monody", "Discord copied to clipboard", 2) end
        end, Utils)
        createActionButton(c2, "Unload Monody", "Safely unhook and destroy UI.", function()
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
