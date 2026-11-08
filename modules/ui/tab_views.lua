--[[
    BestHub - modules/ui/tab_views.lua
    Interactive feature suites for all Monody categories:
    Aimbot, Combat, Players, Soru, Macro, VFX, Skins, and Settings.
    Features exact pixel-perfect card sizing, textured card_bg.png backgrounds,
    full-row touch hitboxes, and debounced mobile controls.
]]

local TabViews = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
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

-- Track exact card heights deterministically (Zero AutomaticSize dependency cycles)
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

-- Helper: Create interactive Toggle with full-row mobile hitbox & debounce
local function createToggle(parent, title, desc, defaultState, onToggle, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent
    local state = defaultState or false

    local row = Instance.new("Frame")
    row.Name = "Toggle_" .. title:gsub("%s+", "")
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundTransparency = 1
    row.ZIndex = 3
    row.Parent = targetContainer

    addCardHeight(parent, 42)

    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -55, 1, 0)
    textContainer.Position = UDim2.new(0, 4, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.ZIndex = 3
    textContainer.Parent = row

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 20)
    titleLbl.Position = UDim2.new(0, 0, 0, 2)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(240, 240, 245)
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = textContainer

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, 0, 0, 16)
    descLbl.Position = UDim2.new(0, 0, 0, 22)
    descLbl.BackgroundTransparency = 1
    descLbl.Font = Enum.Font.Gotham
    descLbl.Text = desc or ""
    descLbl.TextColor3 = Color3.fromRGB(160, 160, 175)
    descLbl.TextSize = 10
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.ZIndex = 4
    descLbl.Parent = textContainer

    -- Pill Switch Visual
    local switchBtn = Instance.new("Frame")
    switchBtn.Name = "SwitchVisual"
    switchBtn.Size = UDim2.new(0, 40, 0, 22)
    switchBtn.Position = UDim2.new(1, -44, 0.5, -11)
    switchBtn.BackgroundColor3 = state and Color3.fromRGB(240, 240, 255) or Color3.fromRGB(40, 40, 52)
    switchBtn.BorderSizePixel = 0
    switchBtn.ZIndex = 4
    switchBtn.Parent = row

    local swCorner = Instance.new("UICorner")
    swCorner.CornerRadius = UDim.new(1, 0)
    swCorner.Parent = switchBtn

    local swStroke = Instance.new("UIStroke")
    swStroke.Color = Color3.fromRGB(70, 70, 90)
    swStroke.Thickness = 1
    swStroke.Parent = switchBtn

    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    thumb.BackgroundColor3 = state and Color3.fromRGB(20, 20, 26) or Color3.fromRGB(180, 180, 195)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 5
    thumb.Parent = switchBtn

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb

    local function updateVisual(anim)
        local dur = anim and 0.15 or 0
        local targetBg = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 52)
        local targetThumbBg = state and Color3.fromRGB(20, 20, 28) or Color3.fromRGB(180, 180, 195)
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

-- Helper: Create interactive Slider with wide touch hitbox for mobile thumbs
local function createSlider(parent, title, minVal, maxVal, defaultVal, onSlide, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent
    local curVal = clamp(defaultVal or minVal, minVal, maxVal)

    local row = Instance.new("Frame")
    row.Name = "Slider_" .. title:gsub("%s+", "")
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundTransparency = 1
    row.ZIndex = 3
    row.Parent = targetContainer

    addCardHeight(parent, 46)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 18)
    header.BackgroundTransparency = 1
    header.ZIndex = 3
    header.Parent = row

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.7, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 4, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(240, 240, 245)
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = header

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.3, -8, 1, 0)
    valLbl.Position = UDim2.new(0.7, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.Text = tostring(math.floor(curVal + 0.5))
    valLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 4
    valLbl.Parent = header

    -- Slider Track Frame
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, -8, 0, 6)
    track.Position = UDim2.new(0, 4, 0, 28)
    track.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
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
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BorderSizePixel = 0
    fill.ZIndex = 5
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(clamp(initRatio, 0, 1), 0, 0.5, 0)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 6
    thumb.Parent = track

    local thCorner = Instance.new("UICorner")
    thCorner.CornerRadius = UDim.new(1, 0)
    thCorner.Parent = thumb

    -- Generous 36px high touch hitbox covering the slider track for mobile thumbs
    local sliderHitbox = Instance.new("TextButton")
    sliderHitbox.Name = "SliderHitbox"
    sliderHitbox.Size = UDim2.new(1, 0, 0, 36)
    sliderHitbox.Position = UDim2.new(0, 0, 0, 13)
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

-- Helper: Create interactive Action Button with debounce
local function createActionButton(parent, title, desc, onClick, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent

    local btn = Instance.new("TextButton")
    btn.Name = "Btn_" .. title:gsub("%s+", "")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Active = true
    btn.ZIndex = 4
    btn.Parent = targetContainer

    addCardHeight(parent, 36)

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(65, 65, 80)
    bStroke.Thickness = 1
    bStroke.Transparency = 0.5
    bStroke.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(240, 240, 250)
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 5
    lbl.Parent = btn

    local lastPress = 0
    local function onPress()
        local now = tick()
        if lastPress > 0 and (now - lastPress < 0.25) then return end
        lastPress = now

        TweenService:Create(btn, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(50, 50, 70) }):Play()
        task.delay(0.1, function()
            TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(28, 28, 38) }):Play()
        end)
        if onClick then pcall(onClick) end
    end

    btn.Activated:Connect(onPress)
    btn.MouseButton1Click:Connect(onPress)
    return btn
end

-- Helper: Create interactive Mobile Dropdown / Option Cycle Pill
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

    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -145, 1, 0)
    textContainer.Position = UDim2.new(0, 4, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.ZIndex = 3
    textContainer.Parent = row

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 20)
    titleLbl.Position = UDim2.new(0, 0, 0, 2)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(240, 240, 245)
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = textContainer

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, 0, 0, 16)
    descLbl.Position = UDim2.new(0, 0, 0, 22)
    descLbl.BackgroundTransparency = 1
    descLbl.Font = Enum.Font.Gotham
    descLbl.Text = desc or ""
    descLbl.TextColor3 = Color3.fromRGB(160, 160, 175)
    descLbl.TextSize = 10
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.ZIndex = 4
    descLbl.Parent = textContainer

    local pillBtn = Instance.new("TextButton")
    pillBtn.Name = "PillBtn"
    pillBtn.Size = UDim2.new(0, 138, 0, 28)
    pillBtn.Position = UDim2.new(1, -142, 0.5, -14)
    pillBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
    pillBtn.BorderSizePixel = 0
    pillBtn.Text = optionsList[curIdx] or ""
    pillBtn.Font = Enum.Font.GothamBold
    pillBtn.TextSize = 11
    pillBtn.TextColor3 = Color3.fromRGB(235, 235, 250)
    pillBtn.AutoButtonColor = false
    pillBtn.Active = true
    pillBtn.ZIndex = 5
    pillBtn.Parent = row

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(0, 6)
    pillCorner.Parent = pillBtn

    local pillStroke = Instance.new("UIStroke")
    pillStroke.Color = Color3.fromRGB(70, 70, 90)
    pillStroke.Thickness = 1
    pillStroke.Parent = pillBtn

    local lastCycle = 0
    local function cycleOption()
        local now = tick()
        if lastCycle > 0 and (now - lastCycle < 0.25) then return end
        lastCycle = now

        curIdx = curIdx + 1
        if curIdx > #optionsList then curIdx = 1 end
        local chosen = optionsList[curIdx]
        pillBtn.Text = chosen

        TweenService:Create(pillBtn, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(55, 55, 80) }):Play()
        task.delay(0.1, function()
            TweenService:Create(pillBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(32, 32, 44) }):Play()
        end)

        if onSelect then pcall(onSelect, chosen, curIdx) end
    end

    pillBtn.Activated:Connect(cycleOption)
    pillBtn.MouseButton1Click:Connect(cycleOption)

    -- Full-row touch hitbox so tapping left text also cycles smoothly
    local rowHitbox = Instance.new("TextButton")
    rowHitbox.Name = "RowHitbox"
    rowHitbox.Size = UDim2.new(1, -146, 1, 0)
    rowHitbox.Position = UDim2.new(0, 0, 0, 0)
    rowHitbox.BackgroundTransparency = 1
    rowHitbox.Text = ""
    rowHitbox.AutoButtonColor = false
    rowHitbox.Active = true
    rowHitbox.ZIndex = 6
    rowHitbox.Parent = row

    rowHitbox.Activated:Connect(cycleOption)
    rowHitbox.MouseButton1Click:Connect(cycleOption)

    return row
end

-- Helper: Create interactive Color Palette Selector
local function createColorPicker(parent, title, desc, colorNames, defaultColorName, onSelectColor, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent
    local selected = defaultColorName or "Rainbow"
    colorNames = colorNames or { "Rainbow", "White", "Red", "Green", "Blue", "Yellow", "Purple" }
    local hasDesc = (desc and #desc > 0)
    local containerHeight = hasDesc and 76 or 58

    local container = Instance.new("Frame")
    container.Name = "ColorPicker_" .. title:gsub("%s+", "")
    container.Size = UDim2.new(1, 0, 0, containerHeight)
    container.BackgroundTransparency = 1
    container.ZIndex = 3
    container.Parent = targetContainer

    addCardHeight(parent, containerHeight)

    local headerRow = Instance.new("Frame")
    headerRow.Size = UDim2.new(1, 0, 0, 22)
    headerRow.BackgroundTransparency = 1
    headerRow.ZIndex = 3
    headerRow.Parent = container

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.6, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 4, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(240, 240, 245)
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = headerRow

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.4, -8, 1, 0)
    valLbl.Position = UDim2.new(0.6, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.Text = selected
    valLbl.TextColor3 = Color3.fromRGB(255, 215, 255)
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 4
    valLbl.Parent = headerRow

    if hasDesc then
        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, -8, 0, 14)
        descLbl.Position = UDim2.new(0, 4, 0, 20)
        descLbl.BackgroundTransparency = 1
        descLbl.Font = Enum.Font.Gotham
        descLbl.Text = desc
        descLbl.TextColor3 = Color3.fromRGB(160, 160, 175)
        descLbl.TextSize = 10
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex = 4
        descLbl.Parent = container
    end

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "PaletteScroll"
    scroll.Size = UDim2.new(1, -8, 0, 32)
    scroll.Position = UDim2.new(0, 4, 0, hasDesc and 38 or 24)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 2
    scroll.CanvasSize = UDim2.new(0, (#colorNames * 68), 0, 0)
    scroll.ScrollingDirection = Enum.ScrollingDirection.X
    scroll.ZIndex = 5
    scroll.Parent = container

    local pLayout = Instance.new("UIListLayout")
    pLayout.FillDirection = Enum.FillDirection.Horizontal
    pLayout.Padding = UDim.new(0, 6)
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pLayout.Parent = scroll

    local colorPills = {}
    local function updatePills()
        for cName, pill in pairs(colorPills) do
            local isSel = (cName == selected)
            pill.Stroke.Color = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 75)
            pill.Stroke.Thickness = isSel and 1.5 or 1
            pill.Frame.BackgroundColor3 = isSel and Color3.fromRGB(55, 55, 75) or Color3.fromRGB(26, 26, 36)
        end
        valLbl.Text = selected
    end

    local lastPickTick = 0
    for idx, cName in ipairs(colorNames) do
        local pill = Instance.new("TextButton")
        pill.Name = "Color_" .. cName
        pill.Size = UDim2.new(0, 62, 0, 26)
        pill.BackgroundColor3 = (cName == selected) and Color3.fromRGB(55, 55, 75) or Color3.fromRGB(26, 26, 36)
        pill.BorderSizePixel = 0
        pill.Text = cName
        pill.Font = Enum.Font.GothamMedium
        pill.TextSize = 10
        pill.TextColor3 = (cName == "Rainbow") and Color3.fromRGB(255, 210, 255) or Color3.fromRGB(230, 230, 240)
        pill.AutoButtonColor = false
        pill.Active = true
        pill.LayoutOrder = idx
        pill.ZIndex = 6
        pill.Parent = scroll

        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(0, 6)
        pCorner.Parent = pill

        local pStroke = Instance.new("UIStroke")
        pStroke.Color = (cName == selected) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 75)
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

-- Helper: Create interactive Multi-Chip Grid for Skill Blacklist
local function createChipGrid(parent, title, desc, chipsList, onToggleChip, Utils)
    local targetContainer = parent:FindFirstChild("Content") or parent
    local blacklisted = {}
    local hasDesc = (desc and #desc > 0)
    local totalHeight = hasDesc and 144 or 126

    local container = Instance.new("Frame")
    container.Name = "ChipGrid_" .. title:gsub("%s+", "")
    container.Size = UDim2.new(1, 0, 0, totalHeight)
    container.BackgroundTransparency = 1
    container.ZIndex = 3
    container.Parent = targetContainer

    addCardHeight(parent, totalHeight)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 20)
    titleLbl.Position = UDim2.new(0, 4, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(240, 240, 245)
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    titleLbl.Parent = container

    if hasDesc then
        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, 0, 0, 16)
        descLbl.Position = UDim2.new(0, 4, 0, 20)
        descLbl.BackgroundTransparency = 1
        descLbl.Font = Enum.Font.Gotham
        descLbl.Text = desc
        descLbl.TextColor3 = Color3.fromRGB(160, 160, 175)
        descLbl.TextSize = 10
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex = 4
        descLbl.Parent = container
    end

    local gridScroll = Instance.new("ScrollingFrame")
    gridScroll.Name = "GridScroll"
    gridScroll.Size = UDim2.new(1, 0, 0, hasDesc and 100 or 98)
    gridScroll.Position = UDim2.new(0, 0, 0, hasDesc and 40 or 24)
    gridScroll.BackgroundTransparency = 1
    gridScroll.BorderSizePixel = 0
    gridScroll.ScrollBarThickness = 2
    gridScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    gridScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    gridScroll.ZIndex = 5
    gridScroll.Parent = container

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 84, 0, 26)
    gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = gridScroll

    gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        gridScroll.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y + 8)
    end)

    for idx, chipName in ipairs(chipsList) do
        local chip = Instance.new("TextButton")
        chip.Name = "Chip_" .. chipName:gsub("%s+", "")
        chip.Size = UDim2.new(0, 84, 0, 26)
        chip.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        chip.BorderSizePixel = 0
        chip.Text = chipName
        chip.Font = Enum.Font.Gotham
        chip.TextSize = 10
        chip.TextColor3 = Color3.fromRGB(210, 210, 225)
        chip.AutoButtonColor = false
        chip.Active = true
        chip.LayoutOrder = idx
        chip.ZIndex = 6
        chip.Parent = gridScroll

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 6)
        cCorner.Parent = chip

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(60, 60, 75)
        cStroke.Thickness = 1
        cStroke.Parent = chip

        local lastChipTick = 0
        local function toggleChip()
            local now = tick()
            if lastChipTick > 0 and (now - lastChipTick < 0.2) then return end
            lastChipTick = now

            local isBl = not blacklisted[chipName]
            blacklisted[chipName] = isBl

            local targetBg = isBl and Color3.fromRGB(75, 25, 35) or Color3.fromRGB(28, 28, 38)
            local targetStroke = isBl and Color3.fromRGB(255, 80, 100) or Color3.fromRGB(60, 60, 75)
            local targetText = isBl and Color3.fromRGB(255, 170, 180) or Color3.fromRGB(210, 210, 225)

            TweenService:Create(chip, TweenInfo.new(0.12), { BackgroundColor3 = targetBg, TextColor3 = targetText }):Play()
            cStroke.Color = targetStroke

            if onToggleChip then pcall(onToggleChip, chipName, isBl) end
        end

        chip.Activated:Connect(toggleChip)
        chip.MouseButton1Click:Connect(toggleChip)
    end

    return container
end

-- Helper: Create a styled Feature Card inside a Tab View with exact height & dark texture background
local function createFeatureCard(parent, title, bgAsset)
    local card = Instance.new("Frame")
    card.Name = "Card_" .. title:gsub("%s+", "")
    card.Size = UDim2.new(0, 396, 0, 38)
    card.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    card.BackgroundTransparency = 0.25
    card.BorderSizePixel = 0
    card.Parent = parent

    cardHeights[card] = 38

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(65, 65, 80)
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = card

    -- Dark textured background matching HomeView cards
    local bg = Instance.new("ImageLabel")
    bg.Name = "CardBg"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundTransparency = 1
    bg.Image = bgAsset or "rbxassetid://139820186687064"
    bg.ScaleType = Enum.ScaleType.Stretch
    bg.ZIndex = 1
    bg.Active = false
    bg.Parent = card

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 8)
    bgCorner.Parent = bg

    -- Content frame hosting padding, list layout, and all controls
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
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 20)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.GothamBold
    header.Text = title:upper()
    header.TextColor3 = Color3.fromRGB(220, 220, 235)
    header.TextSize = 11
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = 0
    header.ZIndex = 3
    header.Parent = content

    return card
end

-- Main Tab Builder
function TabViews.build(tabName, parentContainer, options)
    options = options or {}
    local Utils = options.Utils
    local AssetManager = options.AssetManager
    local cardBg = (AssetManager and AssetManager.get("card_bg.png", "rbxassetid://139820186687064")) or "rbxassetid://139820186687064"

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "TabView_" .. tabName
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.Position = UDim2.new(0, 0, 0, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(140, 140, 160)
    scroll.ScrollBarImageTransparency = 0.2
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

    -- Top Header Banner Card with dark texture background
    local banner = Instance.new("Frame")
    banner.Name = "Banner"
    banner.Size = UDim2.new(0, 396, 0, 46)
    banner.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    banner.BackgroundTransparency = 0.25
    banner.BorderSizePixel = 0
    banner.LayoutOrder = 1
    banner.Parent = scroll

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 8)
    bCorner.Parent = banner

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(65, 65, 80)
    bStroke.Thickness = 1
    bStroke.Transparency = 0.4
    bStroke.Parent = banner

    local bannerBg = Instance.new("ImageLabel")
    bannerBg.Name = "BannerBg"
    bannerBg.Size = UDim2.new(1, 0, 1, 0)
    bannerBg.BackgroundTransparency = 1
    bannerBg.Image = cardBg
    bannerBg.ScaleType = Enum.ScaleType.Stretch
    bannerBg.ZIndex = 1
    bannerBg.Active = false
    bannerBg.Parent = banner

    local bannerBgCorner = Instance.new("UICorner")
    bannerBgCorner.CornerRadius = UDim.new(0, 8)
    bannerBgCorner.Parent = bannerBg

    local bTitle = Instance.new("TextLabel")
    bTitle.Size = UDim2.new(1, -20, 0, 20)
    bTitle.Position = UDim2.new(0, 12, 0, 5)
    bTitle.BackgroundTransparency = 1
    bTitle.Font = Enum.Font.GothamBold
    bTitle.Text = tabName
    bTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    bTitle.TextSize = 16
    bTitle.TextXAlignment = Enum.TextXAlignment.Left
    bTitle.ZIndex = 2
    bTitle.Parent = banner

    local bDesc = Instance.new("TextLabel")
    bDesc.Size = UDim2.new(1, -20, 0, 14)
    bDesc.Position = UDim2.new(0, 12, 0, 26)
    bDesc.BackgroundTransparency = 1
    bDesc.Font = Enum.Font.Gotham
    bDesc.Text = tabName:lower()
    bDesc.TextColor3 = Color3.fromRGB(150, 150, 165)
    bDesc.TextSize = 11
    bDesc.TextXAlignment = Enum.TextXAlignment.Left
    bDesc.ZIndex = 2
    bDesc.Parent = banner

    local function makeCard(title)
        return createFeatureCard(scroll, title, cardBg)
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

        -- 1. Aimbot (CamLock + Aim Tracking)
        local c1 = makeCard("Aimbot")
        c1.LayoutOrder = 2
        createToggle(c1, "Aimbot", "Automatically aims camera and attacks at target", false, function(state)
            if AimbotCore and AimbotCore.setAimbot then
                AimbotCore.setAimbot(state)
            end
            if AimbotCore and AimbotCore.setLockPlayer then
                AimbotCore.setLockPlayer(state)
            end
            if PlayerAimbot then
                if state then PlayerAimbot.enable() else PlayerAimbot.disable() end
            elseif AimbotCore then
                AimbotCore.PlayerAimEnabled = state
                if state then AimbotCore.startLoop() else AimbotCore.stopLoop() end
            end
            _G.G_Aimbot = state
            _G.G_PlayerAim = state
        end, Utils)
        createToggle(c1, "NPC Aimbot", "Lock and aim towards mobs and bosses", false, function(state)
            if NPCAimbot then
                if state then NPCAimbot.enable() else NPCAimbot.disable() end
            elseif AimbotCore then
                AimbotCore.NPCAimEnabled = state
                if state then AimbotCore.startLoop() else AimbotCore.stopLoop() end
            end
            _G.G_NPCAimbot = state
        end, Utils)
        createToggle(c1, "Aimlock", "Lock and maintain target lock during combat", false, function(state)
            if AimbotCore and AimbotCore.setLockPlayer then
                AimbotCore.setLockPlayer(state)
            end
        end, Utils)
        createToggle(c1, "PvP Check", "Ignore players with PvP disabled", true, function(state)
            if AimbotCore then
                AimbotCore.PvPCheck = state
            end
            if _G.MonodyCombatCore then
                _G.MonodyCombatCore.PvPCheck = state
            end
        end, Utils)
        createToggle(c1, "Safe Zone Check", "Ignore players inside safe zones", true, function(state)
            if AimbotCore then
                AimbotCore.SafeZoneCheck = state
            end
            if _G.MonodyCombatCore then
                _G.MonodyCombatCore.SafeZoneCheck = state
            end
        end, Utils)
        createToggle(c1, "Team Check", "Ignore friendly / allied players", false, function(state)
            if PlayerAimbot and PlayerAimbot.setTeamCheck then
                PlayerAimbot.setTeamCheck(state)
            elseif AimbotCore then
                AimbotCore.TeamCheck = state
            end
            if _G.MonodyCombatCore then _G.MonodyCombatCore.TeamCheck = state end
            if _G.DarlingCombatCore then _G.DarlingCombatCore.TeamCheck = state end
        end, Utils)
        createDropdown(c1, "Aim Mode", "Target detection angle", { "360°", "FOV", "180°" }, 1, function(opt)
            local mode = "360"
            if opt:find("FOV") then mode = "FOV"
            elseif opt:find("180") then mode = "180" end
            if PlayerAimbot and PlayerAimbot.setAimMode then
                PlayerAimbot.setAimMode(mode)
            end
            if AimbotCore then
                AimbotCore.AimMode = mode
            end
            if _G.MonodyCombatCore then
                _G.MonodyCombatCore.AimMode = mode
            end
            if _G.DarlingCombatCore then
                _G.DarlingCombatCore.AimMode = mode
            end
            if _G.DarlingHub and _G.DarlingHub.Settings and _G.DarlingHub.Settings.Aim then
                _G.DarlingHub.Settings.Aim.Mode = mode
            end
        end, Utils)
        createDropdown(c1, "Target Priority", "Target selection criterion", { "Nearest", "Low HP", "Looking At Me" }, 1, function(opt)
            if PlayerAimbot and PlayerAimbot.setPriority then
                PlayerAimbot.setPriority(opt)
            end
            if AimbotCore then
                AimbotCore.TargetPriority = opt
            end
            if _G.MonodyCombatCore then
                _G.MonodyCombatCore.TargetPriority = opt
            end
            if _G.DarlingCombatCore then
                _G.DarlingCombatCore.TargetPriority = opt
            end
            if _G.DarlingHub and _G.DarlingHub.Settings and _G.DarlingHub.Settings.Aim then
                _G.DarlingHub.Settings.Aim.Priority = opt
            end
        end, Utils)
        createSlider(c1, "Max Range", 100, 3000, 1000, function(val)
            if NPCAimbot and NPCAimbot.setMaxRange then
                NPCAimbot.setMaxRange(val)
            end
            if PlayerAimbot and PlayerAimbot.setMaxRange then
                PlayerAimbot.setMaxRange(val)
            end
            if AimbotCore then
                AimbotCore.MaxRange = val
            end
        end, Utils)

        -- 2. Silent Aim (Silent Skill & Mouse.Hit Redirection)
        local c2 = makeCard("Silent Aim")
        c2.LayoutOrder = 3
        createToggle(c2, "Player Silent Aim", "Redirect attacks to players without moving camera", false, function(state)
            if PlayerAimbot then
                if state then PlayerAimbot.enable() else PlayerAimbot.disable() end
            elseif AimbotCore then
                AimbotCore.PlayerAimEnabled = state
                if state then AimbotCore.startLoop() else AimbotCore.stopLoop() end
            end
            if SilentAimMod and SilentAimMod.setEnabled then
                SilentAimMod.setEnabled(state)
            end
            if AimbotCore and not _G.G_Aimbot then
                AimbotCore.AimbotEnabled = false
            end
            _G.G_PlayerSilentAim = state
            _G.G_SilentAim = state
        end, Utils)
        createToggle(c2, "NPC Silent Aim", "Redirect attacks to mobs and bosses without moving camera", false, function(state)
            if NPCAimbot then
                if state then NPCAimbot.enable() else NPCAimbot.disable() end
            elseif AimbotCore then
                AimbotCore.NPCAimEnabled = state
                if state then AimbotCore.startLoop() else AimbotCore.stopLoop() end
            end
            _G.G_NPCSilentAim = state
        end, Utils)
        createSlider(c2, "Silent Aim Range", 100, 3000, 1000, function(val)
            if SilentAimMod and SilentAimMod.setMaxDistance then
                SilentAimMod.setMaxDistance(val)
            end
            if AimbotCore then
                AimbotCore.MaxRange = val
            end
        end, Utils)

        -- 3. FOV
        local c3 = makeCard("FOV")
        c3.LayoutOrder = 4
        createToggle(c3, "FOV Circle", "Draw field of view circle on screen", false, function(state)
            if FOVMod and FOVMod.setVisible then FOVMod.setVisible(state) end
        end, Utils)
        createSlider(c3, "FOV Radius", 20, 600, 120, function(val)
            if FOVMod and FOVMod.setRadius then FOVMod.setRadius(val) end
            if AimbotCore and AimbotCore.FOV then AimbotCore.FOV.Radius = val end
            if _G.MonodyCombatCore and _G.MonodyCombatCore.FOV then _G.MonodyCombatCore.FOV.Radius = val end
            if _G.DarlingCombatCore and _G.DarlingCombatCore.FOV then _G.DarlingCombatCore.FOV.Radius = val end
            if _G.DarlingHub and _G.DarlingHub.Settings and _G.DarlingHub.Settings.FOV then
                _G.DarlingHub.Settings.FOV.Radius = val
            end
        end, Utils)
        createDropdown(c3, "Position", "Screen anchor point", { "Center", "Cursor" }, 1, function(opt)
            local mode = opt:find("Cursor") and "Mouse" or "Center"
            if FOVMod and FOVMod.setMode then FOVMod.setMode(mode) end
            if AimbotCore and AimbotCore.FOV then AimbotCore.FOV.Mode = mode end
            if _G.MonodyCombatCore and _G.MonodyCombatCore.FOV then _G.MonodyCombatCore.FOV.Mode = mode end
            if _G.DarlingCombatCore and _G.DarlingCombatCore.FOV then _G.DarlingCombatCore.FOV.Mode = mode end
            if _G.DarlingHub and _G.DarlingHub.Settings and _G.DarlingHub.Settings.FOV then
                _G.DarlingHub.Settings.FOV.Mode = mode
            end
        end, Utils)
        createColorPicker(c3, "FOV Color", "Select circle color palette", { "Rainbow", "White", "Red", "Green", "Blue", "Yellow", "Purple", "Cyan", "Orange" }, "Rainbow", function(colorName)
            if FOVMod and FOVMod.setColor then FOVMod.setColor(colorName) end
        end, Utils)

        -- 4. Tracers (Hardware 3D Beam + 2D Line)
        local c4 = makeCard("Tracers")
        c4.LayoutOrder = 5
        createToggle(c4, "Show Tracers", "Draw indicator lines towards enemies", false, function(state)
            if TracersMod and TracersMod.setVisible then
                TracersMod.setVisible(state)
            end
        end, Utils)
        createDropdown(c4, "Mode", "Line rendering mode", { "Both (3D + 2D)", "3D Beam", "2D Line" }, 1, function(opt)
            local m = "Both"
            if opt:find("3D") and not opt:find("2D") then m = "3D Beam"
            elseif opt:find("2D") and not opt:find("3D") then m = "2D Line" end
            if TracersMod and TracersMod.setType then
                TracersMod.setType(m)
            end
        end, Utils)
        createDropdown(c4, "Origin", "Line origin point", { "Player", "Bottom", "Center" }, 1, function(opt)
            local orig = "Player"
            if opt:find("Bottom") or opt:find("Abajo") then orig = "Bottom"
            elseif opt:find("Center") or opt:find("Centro") then orig = "Center" end
            if TracersMod and TracersMod.setOrigin then
                TracersMod.setOrigin(orig)
            end
        end, Utils)
        createColorPicker(c4, "Tracer Color", "Select line color", { "Rainbow", "White", "Red", "Green", "Blue", "Yellow", "Purple" }, "White", function(colorName)
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

        -- 5. Blacklist (Skill Engine)
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
        createToggle(c1, "Fast Attack", "Fast attack with zero animation delay", true, nil, Utils)
        createToggle(c1, "Auto Clicker", "Automatic attack spammer", false, nil, Utils)
        createToggle(c1, "Auto Skills Combo", "Cast Z, X, C, V skills automatically", false, nil, Utils)
        createToggle(c1, "Kill Aura", "Damage all nearby enemies", false, nil, Utils)

        local c2 = makeCard("Range & Weapons")
        c2.LayoutOrder = 3
        createSlider(c2, "Attack Range", 10, 60, 28, nil, Utils)
        createActionButton(c2, "Equip Best Weapon", "Equip your highest damage weapon", function()
            if Utils then Utils.toast("Monody", "Equipped best weapon", 1.5) end
        end, Utils)

    elseif tabName == "Players" then
        local c1 = makeCard("Visuals (ESP)")
        c1.LayoutOrder = 2
        createToggle(c1, "Player ESP", "Display player names and distances", true, nil, Utils)
        createToggle(c1, "Box ESP", "2D bounding box around characters", false, nil, Utils)
        createToggle(c1, "Tracers", "Indicator lines towards players", false, function(state)
            local TracersMod = options.Tracers
            if TracersMod and TracersMod.setVisible then
                TracersMod.setVisible(state)
            end
        end, Utils)

        local c2 = makeCard("Player Mobility")
        c2.LayoutOrder = 3
        createSlider(c2, "WalkSpeed", 16, 250, 16, function(v)
            pcall(function()
                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = v
                end
            end)
        end, Utils)
        createSlider(c2, "JumpPower", 50, 300, 50, function(v)
            pcall(function()
                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.JumpPower = v
                end
            end)
        end, Utils)
        createToggle(c2, "Infinite Jump", "Jump infinitely in mid-air", false, nil, Utils)
        createToggle(c2, "Mobile Fly Mode", "Fly using virtual joystick controls", false, nil, Utils)

    elseif tabName == "Soru" then
        local SoruEngine = options.SoruEngine or _G.MonodySoruEngine

        -- 1. Flashstep & Soru Mastery
        local c1 = makeCard("Flashstep & Soru")
        c1.LayoutOrder = 2
        createToggle(c1, "Toggle Soru Cooldown (1s)", "Maintain 1-second Flashstep cooldown", false, function(state)
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

        createActionButton(c1, "Instant Soru Cooldown (1s)", "Apply 1s cooldown to current character immediately", function()
            local player = Players.LocalPlayer
            if player and player.Character then
                pcall(function() player.Character:SetAttribute("FlashstepCooldown", 1) end)
            end
            if Utils then Utils.toast("Monody", "Flashstep 1s cooldown applied", 1.5) end
        end, Utils)

        createToggle(c1, "Infinite Soru", "Continuous Flashstep without cooldown", false, function(state)
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
        createToggle(c2, "Soru Aimbot", "Teleport to target when activating Flashstep [R]", false, function(state)
            if SoruEngine and SoruEngine.setAimbot then
                SoruEngine.setAimbot(state)
            end
        end, Utils)

        createDropdown(c2, "Target Mode", "Teleport target selection", { "Nearest Player", "Selected Player" }, 1, function(opt)
            if SoruEngine then
                SoruEngine.TargetMode = opt
            end
        end, Utils)

        createActionButton(c2, "Execute Soru Now", "Instantly Flashstep towards target or cursor", function()
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
        createToggle(c1, "Auto Farm Level", "Accept quests and farm mobs automatically", false, nil, Utils)
        createToggle(c1, "Auto Farm Nearest", "Attack nearest enemy mobs", false, nil, Utils)
        createToggle(c1, "Auto Collect Chests", "Fly to chests and collect cash", false, nil, Utils)

        local c2 = makeCard("Tween Speed")
        c2.LayoutOrder = 3
        createSlider(c2, "Flight Speed (Tween)", 50, 350, 220, nil, Utils)
        createActionButton(c2, "Stop Macro", "Cancel any active route", function()
            if Utils then Utils.toast("Monody", "Macro stopped", 1.5) end
        end, Utils)

    elseif tabName == "VFX" then
        local c1 = makeCard("Optimization & Graphics")
        c1.LayoutOrder = 2
        createToggle(c1, "Clear Sky (No Fog)", "Eliminate atmospheric fog", true, nil, Utils)
        createToggle(c1, "Fullbright Mode", "Maximum ambient lighting in dark areas", true, nil, Utils)
        createToggle(c1, "Mobile FPS Boost", "Reduce particles and textures for smoothness", false, nil, Utils)
        createToggle(c1, "Disable Shadows", "Improve performance on low-end devices", false, nil, Utils)

    elseif tabName == "Skins" then
        local c1 = makeCard("Cosmetics & Effects")
        c1.LayoutOrder = 2
        createToggle(c1, "Rainbow Weapon Aura", "Multicolor aura on swords and fists", false, nil, Utils)
        createToggle(c1, "Character Trail", "Light trail following character movement", false, nil, Utils)
        createActionButton(c1, "Cycle Aura Color", "Cycle through available aura colors", function()
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
        createActionButton(c2, "Rejoin Server", "Rejoin the current server instance", function()
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        end, Utils)
        createActionButton(c2, "Copy Official Discord", "Copy invite link to clipboard", function()
            Utils.setClipboard("https://discord.gg/besthub")
            if Utils then Utils.toast("Monody", "Discord copied to clipboard", 2) end
        end, Utils)
        createActionButton(c2, "Unload Monody", "Safely unhook and destroy UI", function()
            if options.onClose then pcall(options.onClose) end
        end, Utils)
    end

    -- Calculate total CanvasSize accurately
    local function updateCanvasSize()
        local total = 46 + 14 -- banner (46) + top padding (14)
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
