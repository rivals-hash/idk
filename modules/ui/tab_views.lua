--[[
    BestHub - modules/ui/tab_views.lua
    Interactive feature suites for all Monody categories:
    Aimbot, Combat, Players, Soru, Macro, VFX, Skins, and Settings.
    Provides responsive touch-friendly Toggles, Sliders, and Action Buttons.
]]

local TabViews = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Helper: Create interactive Toggle
local function createToggle(parent, title, desc, defaultState, onToggle, Utils)
    local state = defaultState or false

    local row = Instance.new("Frame")
    row.Name = "Toggle_" .. title:gsub("%s+", "")
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -55, 1, 0)
    textContainer.Position = UDim2.new(0, 4, 0, 0)
    textContainer.BackgroundTransparency = 1
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
    descLbl.Parent = textContainer

    -- Pill Switch
    local switchBtn = Instance.new("TextButton")
    switchBtn.Name = "SwitchBtn"
    switchBtn.Size = UDim2.new(0, 40, 0, 22)
    switchBtn.Position = UDim2.new(1, -44, 0.5, -11)
    switchBtn.BackgroundColor3 = state and Color3.fromRGB(240, 240, 255) or Color3.fromRGB(40, 40, 52)
    switchBtn.BorderSizePixel = 0
    switchBtn.Text = ""
    switchBtn.AutoButtonColor = false
    switchBtn.Active = true
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

    local function toggle()
        state = not state
        updateVisual(true)
        if Utils then
            Utils.toast("Monody", title .. ": " .. (state and "Activado" or "Desactivado"), 1.2)
        end
        if onToggle then pcall(onToggle, state) end
    end

    switchBtn.Activated:Connect(toggle)
    switchBtn.MouseButton1Click:Connect(toggle)
    return row
end

-- Helper: Create interactive Slider
local function createSlider(parent, title, minVal, maxVal, defaultVal, onSlide, Utils)
    local curVal = math.clamp(defaultVal or minVal, minVal, maxVal)

    local row = Instance.new("Frame")
    row.Name = "Slider_" .. title:gsub("%s+", "")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 18)
    header.BackgroundTransparency = 1
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
    titleLbl.Parent = header

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.3, -8, 1, 0)
    valLbl.Position = UDim2.new(0.7, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.Text = tostring(math.floor(curVal))
    valLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = header

    -- Slider Bar Track
    local track = Instance.new("TextButton")
    track.Name = "Track"
    track.Size = UDim2.new(1, -8, 0, 6)
    track.Position = UDim2.new(0, 4, 0, 26)
    track.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    track.Active = true
    track.Parent = row

    local trCorner = Instance.new("UICorner")
    trCorner.CornerRadius = UDim.new(1, 0)
    trCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    local initRatio = (curVal - minVal) / math.max(1, (maxVal - minVal))
    fill.Size = UDim2.new(math.clamp(initRatio, 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(math.clamp(initRatio, 0, 1), 0, 0.5, 0)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.Parent = track

    local thCorner = Instance.new("UICorner")
    thCorner.CornerRadius = UDim.new(1, 0)
    thCorner.Parent = thumb

    -- Slider interaction
    local sliding = false
    local function setRatio(ratio)
        ratio = math.clamp(ratio, 0, 1)
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

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateFromInput(input)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    sliding = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)

    return row
end

-- Helper: Create interactive Action Button
local function createActionButton(parent, title, desc, onClick, Utils)
    local btn = Instance.new("TextButton")
    btn.Name = "Btn_" .. title:gsub("%s+", "")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Active = true
    btn.Parent = parent

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
    lbl.Parent = btn

    local function onPress()
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
    local curIdx = defaultIndex or 1
    optionsList = (optionsList and #optionsList > 0) and optionsList or { "Default" }

    local row = Instance.new("Frame")
    row.Name = "Dropdown_" .. title:gsub("%s+", "")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -145, 1, 0)
    textContainer.Position = UDim2.new(0, 4, 0, 0)
    textContainer.BackgroundTransparency = 1
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
    descLbl.Parent = textContainer

    local pillBtn = Instance.new("TextButton")
    pillBtn.Name = "PillBtn"
    pillBtn.Size = UDim2.new(0, 138, 0, 26)
    pillBtn.Position = UDim2.new(1, -142, 0.5, -13)
    pillBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
    pillBtn.BorderSizePixel = 0
    pillBtn.Text = optionsList[curIdx] or ""
    pillBtn.Font = Enum.Font.GothamBold
    pillBtn.TextSize = 10
    pillBtn.TextColor3 = Color3.fromRGB(235, 235, 250)
    pillBtn.AutoButtonColor = false
    pillBtn.Active = true
    pillBtn.Parent = row

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(0, 6)
    pillCorner.Parent = pillBtn

    local pillStroke = Instance.new("UIStroke")
    pillStroke.Color = Color3.fromRGB(70, 70, 90)
    pillStroke.Thickness = 1
    pillStroke.Parent = pillBtn

    local function cycleOption()
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
    return row
end

-- Helper: Create interactive Color Palette Selector (Darling X Standard)
-- Helper: Create interactive Color Palette Selector (Darling X Standard)
local function createColorPicker(parent, title, desc, colorNames, defaultColorName, onSelectColor, Utils)
    local selected = defaultColorName or "Rainbow"
    colorNames = colorNames or { "Rainbow", "White", "Red", "Green", "Blue", "Yellow", "Purple" }
    local hasDesc = (desc and #desc > 0)
    local containerHeight = hasDesc and 76 or 58

    local container = Instance.new("Frame")
    container.Name = "ColorPicker_" .. title:gsub("%s+", "")
    container.Size = UDim2.new(1, 0, 0, containerHeight)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local headerRow = Instance.new("Frame")
    headerRow.Size = UDim2.new(1, 0, 0, 22)
    headerRow.BackgroundTransparency = 1
    headerRow.Parent = container

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -70, 1, 0)
    titleLbl.Position = UDim2.new(0, 4, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(240, 240, 245)
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerRow

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 65, 1, 0)
    valLbl.Position = UDim2.new(1, -69, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.Text = selected
    valLbl.TextColor3 = Color3.fromRGB(210, 210, 255)
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = headerRow

    if hasDesc then
        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, 0, 0, 16)
        descLbl.Position = UDim2.new(0, 4, 0, 22)
        descLbl.BackgroundTransparency = 1
        descLbl.Font = Enum.Font.Gotham
        descLbl.Text = desc
        descLbl.TextColor3 = Color3.fromRGB(160, 160, 175)
        descLbl.TextSize = 10
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.Parent = container
    end

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 0, 30)
    scroll.Position = UDim2.new(0, 0, 0, hasDesc and 42 or 24)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 0
    scroll.CanvasSize = UDim2.new(0, #colorNames * 68, 0, 0)
    scroll.ScrollingDirection = Enum.ScrollingDirection.X
    scroll.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

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
    local blacklisted = {}
    local hasDesc = (desc and #desc > 0)
    local totalHeight = hasDesc and 144 or 126

    local container = Instance.new("Frame")
    container.Name = "ChipGrid_" .. title:gsub("%s+", "")
    container.Size = UDim2.new(1, 0, 0, totalHeight)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 20)
    titleLbl.Position = UDim2.new(0, 4, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(240, 240, 245)
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
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
        descLbl.Parent = container
    end

    local gridFrame = Instance.new("Frame")
    gridFrame.Name = "Grid"
    gridFrame.Size = UDim2.new(1, 0, 0, 92)
    gridFrame.Position = UDim2.new(0, 0, 0, hasDesc and 40 or 24)
    gridFrame.BackgroundTransparency = 1
    gridFrame.Parent = container

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 64, 0, 26)
    gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = gridFrame

    for idx, chipName in ipairs(chipsList) do
        local chip = Instance.new("TextButton")
        chip.Name = "Chip_" .. chipName:gsub("%s+", "")
        chip.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        chip.BorderSizePixel = 0
        chip.Text = chipName
        chip.Font = Enum.Font.GothamMedium
        chip.TextSize = 10
        chip.TextColor3 = Color3.fromRGB(210, 210, 225)
        chip.AutoButtonColor = false
        chip.Active = true
        chip.LayoutOrder = idx
        chip.Parent = gridFrame

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 6)
        cCorner.Parent = chip

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(60, 60, 75)
        cStroke.Thickness = 1
        cStroke.Parent = chip

        local function toggleChip()
            local isBl = not (blacklisted[chipName] == true)
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

-- Helper: Create a styled Feature Card inside a Tab View (Clean solid glass without scale bug)
local function createFeatureCard(parent, title)
    local card = Instance.new("Frame")
    card.Name = "Card_" .. title:gsub("%s+", "")
    card.Size = UDim2.new(1, -12, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    card.BackgroundTransparency = 0.2
    card.BorderSizePixel = 0
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 75)
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = card

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = card

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 20)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.GothamBold
    header.Text = title:upper()
    header.TextColor3 = Color3.fromRGB(220, 220, 235)
    header.TextSize = 11
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = 0
    header.Parent = card

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
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(140, 140, 160)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = false
    scroll.ClipsDescendants = true
    scroll.Parent = parentContainer

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 20)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 6)
    pad.Parent = scroll

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scroll

    -- Ensure ScrollingFrame CanvasSize dynamically adapts
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 28)
    end)

    -- Top Header Banner Card (Simple & clean, no AI fluff)
    local banner = Instance.new("Frame")
    banner.Name = "Banner"
    banner.Size = UDim2.new(1, -12, 0, 46)
    banner.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    banner.BackgroundTransparency = 0.2
    banner.BorderSizePixel = 0
    banner.LayoutOrder = 1
    banner.Parent = scroll

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 8)
    bCorner.Parent = banner

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(60, 60, 75)
    bStroke.Thickness = 1
    bStroke.Transparency = 0.5
    bStroke.Parent = banner

    local bTitle = Instance.new("TextLabel")
    bTitle.Size = UDim2.new(1, -20, 0, 20)
    bTitle.Position = UDim2.new(0, 12, 0, 5)
    bTitle.BackgroundTransparency = 1
    bTitle.Font = Enum.Font.GothamBold
    bTitle.Text = tabName
    bTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    bTitle.TextSize = 16
    bTitle.TextXAlignment = Enum.TextXAlignment.Left
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
    bDesc.Parent = banner

    -- Populate content based on Tab
    if tabName == "Aimbot" then
        local FOVMod = options.FOV

        -- 1. Aimbot
        local c1 = createFeatureCard(scroll, "Aimbot")
        c1.LayoutOrder = 2
        createToggle(c1, "Player Silent Aim", "Redirige ataques hacia jugadores", false, function(state)
            if Utils then Utils.toast("Monody", "Player Silent Aim: " .. (state and "Activado" or "Desactivado"), 1.2) end
        end, Utils)
        createToggle(c1, "NPC Silent Aim", "Redirige ataques hacia NPCs", false, function(state)
            if Utils then Utils.toast("Monody", "NPC Silent Aim: " .. (state and "Activado" or "Desactivado"), 1.2) end
        end, Utils)
        createToggle(c1, "Team Check", "Ignora jugadores aliados", true, nil, Utils)
        createToggle(c1, "Aimlock", "Fija al jugador objetivo", false, function(state)
            if Utils then Utils.toast("Monody", "Aimlock: " .. (state and "Activado" or "Desactivado"), 1.2) end
        end, Utils)
        createToggle(c1, "Aimlock Widget", "Botón táctil flotante", false, function(state)
            if Utils then Utils.toast("Monody", "Aimlock Widget: " .. (state and "Visible" or "Oculto"), 1.2) end
        end, Utils)
        createDropdown(c1, "Modo", "Ángulo de detección", { "360°", "FOV", "180°" }, 1, function(opt)
            if Utils then Utils.toast("Monody", "Modo Aim: " .. opt, 1.2) end
        end, Utils)
        createDropdown(c1, "Prioridad", "Criterio de selección", { "Nearest", "Low HP", "Looking At Me" }, 1, function(opt)
            if Utils then Utils.toast("Monody", "Prioridad: " .. opt, 1.2) end
        end, Utils)
        createSlider(c1, "Rango", 100, 3000, 1000, function(val)
            -- Slider range callback
        end, Utils)

        -- 2. Silent Aim BBG
        local c2 = createFeatureCard(scroll, "Silent Aim BBG")
        c2.LayoutOrder = 3
        createToggle(c2, "BBG Silent Aim", "Redirección clásica Mouse.Hit", false, function(state)
            if Utils then Utils.toast("Monody", "BBG Silent Aim: " .. (state and "Activado" or "Desactivado"), 1.2) end
        end, Utils)
        createToggle(c2, "Soru Silent", "Redirección con flashstep", false, function(state)
            if Utils then Utils.toast("Monody", "Soru Silent: " .. (state and "Activado" or "Desactivado"), 1.2) end
        end, Utils)

        -- 3. FOV
        local c3 = createFeatureCard(scroll, "FOV")
        c3.LayoutOrder = 4
        createToggle(c3, "Círculo FOV", "Dibuja el círculo en pantalla", false, function(state)
            if FOVMod and FOVMod.setVisible then FOVMod.setVisible(state) end
            if Utils then Utils.toast("Monody", "Círculo FOV: " .. (state and "Visible" or "Oculto"), 1.2) end
        end, Utils)
        createSlider(c3, "Radio FOV", 20, 500, 120, function(val)
            if FOVMod and FOVMod.setRadius then FOVMod.setRadius(val) end
        end, Utils)
        createDropdown(c3, "Posición", "Punto de anclaje", { "Centro", "Cursor" }, 1, function(opt)
            if FOVMod and FOVMod.setMode then
                if opt:find("Cursor") then
                    FOVMod.setMode("Mouse")
                else
                    FOVMod.setMode("Center")
                end
            end
        end, Utils)
        createColorPicker(c3, "Color FOV", "Colores Darling X", { "Rainbow", "White", "Red", "Green", "Blue", "Yellow", "Purple", "Cyan", "Orange" }, "Rainbow", function(colorName)
            if FOVMod and FOVMod.setColor then FOVMod.setColor(colorName) end
            if Utils then Utils.toast("Monody", "Color FOV: " .. colorName, 1.2) end
        end, Utils)

        -- 4. Tracers
        local c4 = createFeatureCard(scroll, "Tracers")
        c4.LayoutOrder = 5
        createToggle(c4, "Mostrar Tracers", "Líneas hacia enemigos", false, function(state)
            if Utils then Utils.toast("Monody", "Tracers: " .. (state and "Activados" or "Desactivados"), 1.2) end
        end, Utils)
        createDropdown(c4, "Modo", "Tipo de trazado", { "Ambos (3D + 2D)", "3D Beam", "2D Line" }, 1, function(opt)
            if Utils then Utils.toast("Monody", "Modo Tracer: " .. opt, 1.2) end
        end, Utils)
        createDropdown(c4, "Origen", "Punto de origen", { "Player", "Abajo", "Centro" }, 1, function(opt)
            if Utils then Utils.toast("Monody", "Origen: " .. opt, 1.2) end
        end, Utils)
        createColorPicker(c4, "Color Tracer", "Color de línea", { "Rainbow", "White", "Red", "Green", "Blue", "Yellow", "Purple" }, "White", function(colorName)
            if Utils then Utils.toast("Monody", "Color Tracer: " .. colorName, 1.2) end
        end, Utils)

        -- 5. Blacklist
        local c5 = createFeatureCard(scroll, "Blacklist")
        c5.LayoutOrder = 6
        createChipGrid(c5, "Excluir Habilidades", "Toca una para bloquearla del aimbot", {
            "Melee Z", "Melee X", "Melee C",
            "Sword Z", "Sword X",
            "Fruit Z", "Fruit X", "Fruit C", "Fruit V", "Fruit F", "Fruit TAP",
            "Gun Z", "Gun X"
        }, function(chip, isBlacklisted)
            if Utils then
                Utils.toast("Monody", chip .. ": " .. (isBlacklisted and "Bloqueado" or "Habilitado"), 1.1)
            end
        end, Utils)

    elseif tabName == "Combat" then
        local c1 = createFeatureCard(scroll, "Combate Automático")
        c1.LayoutOrder = 2
        createToggle(c1, "Fast Attack", "Ataque rápido sin retraso de animación", true, nil, Utils)
        createToggle(c1, "Auto Clicker", "Spam de golpes automático", false, nil, Utils)
        createToggle(c1, "Auto Skills Combo", "Lanza habilidades Z, X, C, V automáticamente", false, nil, Utils)
        createToggle(c1, "Kill Aura", "Daña a todos los enemigos cercanos", false, nil, Utils)

        local c2 = createFeatureCard(scroll, "Rango & Armas")
        c2.LayoutOrder = 3
        createSlider(c2, "Rango de Ataque", 10, 60, 28, nil, Utils)
        createActionButton(c2, "Equipar Mejor Arma", "Equipa tu mejor espada o fruta", function()
            Utils.toast("Monody", "Mejor arma equipada", 1.5)
        end, Utils)

    elseif tabName == "Players" then
        local c1 = createFeatureCard(scroll, "Visuales (ESP)")
        c1.LayoutOrder = 2
        createToggle(c1, "Player ESP", "Muestra nombres y distancia de jugadores", true, nil, Utils)
        createToggle(c1, "Box ESP", "Caja 2D alrededor de los personajes", false, nil, Utils)
        createToggle(c1, "Tracers", "Líneas rastreadoras hacia jugadores", false, nil, Utils)

        local c2 = createFeatureCard(scroll, "Movilidad del Jugador")
        c2.LayoutOrder = 3
        createSlider(c2, "Velocidad (WalkSpeed)", 16, 250, 16, function(v)
            pcall(function()
                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = v
                end
            end)
        end, Utils)
        createSlider(c2, "Salto (JumpPower)", 50, 300, 50, function(v)
            pcall(function()
                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.JumpPower = v
                end
            end)
        end, Utils)
        createToggle(c2, "Infinite Jump", "Salta infinitas veces en el aire", false, nil, Utils)
        createToggle(c2, "Modo Vuelo Móvil (Fly)", "Vuela con joystick táctil", false, nil, Utils)

    elseif tabName == "Soru" then
        local c1 = createFeatureCard(scroll, "Habilidades de Soru")
        c1.LayoutOrder = 2
        createToggle(c1, "Infinite Soru", "Soru sin límite de cargas", true, nil, Utils)
        createToggle(c1, "No Cooldown Soru", "Cero enfriamiento en esquivas", true, nil, Utils)
        createSlider(c1, "Multiplicador de Distancia", 1, 5, 2, nil, Utils)

        local c2 = createFeatureCard(scroll, "Teletransporte Rápido")
        c2.LayoutOrder = 3
        createActionButton(c2, "Teleport a Enemigo Cercano", "Teletransporta directamente a la espalda", function()
            Utils.toast("Monody", "Soru instantáneo ejecutado", 1.5)
        end, Utils)
        createActionButton(c2, "Teleport a Zona Segura", "Teletransporta a una zona neutral", function()
            Utils.toast("Monody", "Teletransportado a Zona Segura", 1.5)
        end, Utils)

    elseif tabName == "Macro" then
        local c1 = createFeatureCard(scroll, "Automatización y Farm")
        c1.LayoutOrder = 2
        createToggle(c1, "Auto Farm Nivel", "Acepta misiones y farmea automáticamente", false, nil, Utils)
        createToggle(c1, "Auto Farm Enemigo Cercano", "Ataca los monstruos cercanos", false, nil, Utils)
        createToggle(c1, "Auto Recolectar Cofres", "Vuela a cofres y recoge dinero", false, nil, Utils)

        local c2 = createFeatureCard(scroll, "Velocidad de Tween")
        c2.LayoutOrder = 3
        createSlider(c2, "Velocidad de Vuelo (Tween)", 50, 350, 220, nil, Utils)
        createActionButton(c2, "Detener Macro", "Cancela cualquier ruta en curso", function()
            Utils.toast("Monody", "Macro detenido", 1.5)
        end, Utils)

    elseif tabName == "VFX" then
        local c1 = createFeatureCard(scroll, "Optimización y Gráficos")
        c1.LayoutOrder = 2
        createToggle(c1, "Quitar Niebla (Clear Sky)", "Elimina la niebla ambiental", true, nil, Utils)
        createToggle(c1, "Modo Fullbright", "Iluminación máxima en zonas oscuras", true, nil, Utils)
        createToggle(c1, "FPS Boost Móvil", "Reduce partículas y texturas para más fluidez", false, nil, Utils)
        createToggle(c1, "Desactivar Sombras", "Aumenta la estabilidad en dispositivos gama baja", false, nil, Utils)

    elseif tabName == "Skins" then
        local c1 = createFeatureCard(scroll, "Cosméticos y Efectos")
        c1.LayoutOrder = 2
        createToggle(c1, "Aura Arcoíris de Arma", "Aura multicolor en espadas y puños", false, nil, Utils)
        createToggle(c1, "Estela de Personaje (Trail)", "Rastro de luz al moverte", false, nil, Utils)
        createActionButton(c1, "Cambiar Color de Aura (Cian)", "Ciclar colores de aura", function()
            Utils.toast("Monody", "Aura cambiada a Cian Neón", 1.5)
        end, Utils)

    elseif tabName == "Settings" then
        local c1 = createFeatureCard(scroll, "Configuración de Interfaz")
        c1.LayoutOrder = 2
        createSlider(c1, "Escala UI (%)", 50, 120, 80, function(val)
            if options.onScaleChange then pcall(options.onScaleChange, val / 100) end
        end, Utils)

        local c2 = createFeatureCard(scroll, "Utilidades de Servidor")
        c2.LayoutOrder = 3
        createActionButton(c2, "Reconectar al Servidor", "Reingresa a este mismo servidor", function()
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        end, Utils)
        createActionButton(c2, "Copiar Discord Oficial", "Copia el enlace de invitación", function()
            Utils.setClipboard("https://discord.gg/besthub")
            Utils.toast("Monody", "Discord copiado al portapapeles", 2)
        end, Utils)
        createActionButton(c2, "Cerrar Monody Completamente", "Descarga y destruye todo", function()
            if options.onClose then pcall(options.onClose) end
        end, Utils)
    end

    return scroll
end

return TabViews
