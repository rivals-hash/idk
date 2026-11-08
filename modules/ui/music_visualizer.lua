--[[
    BestHub - modules/ui/music_visualizer.lua
    Interactive touchable music player & live spectrum visualizer.
    Renders inside Card 3 with animated vertical frequency bars,
    scrubbable timeline track, and responsive touch controls.
]]

local MusicVisualizer = {}

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function MusicVisualizer.create(parentFrame, MusicEngine, Utils, AssetManager)
    local container = Instance.new("Frame")
    container.Name = "MusicVisualizerContainer"
    container.Size = UDim2.new(1, -24, 1, -12)
    container.Position = UDim2.new(0, 12, 0, 6)
    container.BackgroundTransparency = 1
    container.Parent = parentFrame

    -- Row 1: Header (Music icon, Track Title, Playback Time)
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "HeaderFrame"
    headerFrame.Size = UDim2.new(1, 0, 0, 16)
    headerFrame.Position = UDim2.new(0, 0, 0, 0)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = container

    local musicIcon = Instance.new("TextLabel")
    musicIcon.Name = "MusicIcon"
    musicIcon.Size = UDim2.new(0, 16, 0, 16)
    musicIcon.Position = UDim2.new(0, 0, 0.5, -8)
    musicIcon.BackgroundTransparency = 1
    musicIcon.Font = Enum.Font.GothamBold
    musicIcon.Text = "♫"
    musicIcon.TextColor3 = Color3.fromRGB(255, 95, 120)
    musicIcon.TextSize = 14
    musicIcon.Parent = headerFrame

    local trackTitle = Instance.new("TextLabel")
    trackTitle.Name = "TrackTitle"
    trackTitle.Size = UDim2.new(0.65, -20, 1, 0)
    trackTitle.Position = UDim2.new(0, 20, 0, 0)
    trackTitle.BackgroundTransparency = 1
    trackTitle.Font = Enum.Font.GothamBold
    local curTrack = MusicEngine and MusicEngine.getCurrentTrack and MusicEngine.getCurrentTrack()
    trackTitle.Text = curTrack and curTrack.Title or "MONTAGEM BAILÃO (Phonk)"
    trackTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    trackTitle.TextSize = 11.5
    trackTitle.TextXAlignment = Enum.TextXAlignment.Left
    trackTitle.TextTruncate = Enum.TextTruncate.AtEnd
    trackTitle.Parent = headerFrame

    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.Size = UDim2.new(0.35, 0, 1, 0)
    timeLabel.Position = UDim2.new(0.65, 0, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Font = Enum.Font.GothamMedium
    timeLabel.Text = "00:00 / 02:25"
    timeLabel.TextColor3 = Color3.fromRGB(215, 205, 220)
    timeLabel.TextSize = 10.5
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.Parent = headerFrame

    -- Row 2: Visualizer Bars Container (Center row)
    local barsContainer = Instance.new("Frame")
    barsContainer.Name = "BarsContainer"
    barsContainer.Size = UDim2.new(1, 0, 0, 20)
    barsContainer.Position = UDim2.new(0, 0, 0, 18)
    barsContainer.BackgroundTransparency = 1
    barsContainer.Parent = container

    local barListLayout = Instance.new("UIListLayout")
    barListLayout.FillDirection = Enum.FillDirection.Horizontal
    barListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    barListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    barListLayout.Padding = UDim.new(0, 4)
    barListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    barListLayout.Parent = barsContainer

    -- Create 28 vertical frequency bars with radiant crimson gradient
    local numBars = 28
    local bars = {}
    for i = 1, numBars do
        local bar = Instance.new("Frame")
        bar.Name = "Bar_" .. i
        bar.LayoutOrder = i
        bar.Size = UDim2.new(0, 3, 0, 6)
        bar.BackgroundColor3 = Color3.fromRGB(220, 35, 60)
        bar.BorderSizePixel = 0
        bar.Parent = barsContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = bar

        table.insert(bars, bar)
    end

    -- Row 3: Progress bar scrubber & playback buttons
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "ControlsFrame"
    controlsFrame.Size = UDim2.new(1, 0, 0, 24)
    controlsFrame.Position = UDim2.new(0, 0, 0, 42)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = container

    -- Interactive Progress Bar Track (Scrubbable with touch & mouse)
    local progressTrack = Instance.new("Frame")
    progressTrack.Name = "ProgressTrack"
    progressTrack.Size = UDim2.new(1, -115, 0, 4)
    progressTrack.Position = UDim2.new(0, 0, 0.5, -2)
    progressTrack.BackgroundColor3 = Color3.fromRGB(38, 28, 38)
    progressTrack.BorderSizePixel = 0
    progressTrack.Parent = controlsFrame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = progressTrack

    local progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(220, 35, 60)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressTrack

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = progressFill

    local pGrad = Instance.new("UIGradient")
    pGrad.Color = ColorSequence.new(Color3.fromRGB(220, 35, 60), Color3.fromRGB(255, 95, 120))
    pGrad.Parent = progressFill

    -- Clean circular scrubber thumb
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, 10, 0, 10)
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(0, 0, 0.5, 0)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 6
    thumb.Parent = progressTrack

    local thCorner = Instance.new("UICorner")
    thCorner.CornerRadius = UDim.new(1, 0)
    thCorner.Parent = thumb

    -- Scrubber touch/click hitbox
    local scrubHitbox = Instance.new("TextButton")
    scrubHitbox.Name = "ScrubHitbox"
    scrubHitbox.Size = UDim2.new(1, 0, 0, 24)
    scrubHitbox.Position = UDim2.new(0, 0, 0.5, -12)
    scrubHitbox.BackgroundTransparency = 1
    scrubHitbox.Text = ""
    scrubHitbox.AutoButtonColor = false
    scrubHitbox.Active = true
    scrubHitbox.ZIndex = 10
    scrubHitbox.Parent = progressTrack

    local scrubbing = false
    local function seekFromInput(input)
        local absX = progressTrack.AbsolutePosition.X
        local absW = progressTrack.AbsoluteSize.X
        if absW > 0 then
            local ratio = math.clamp((input.Position.X - absX) / absW, 0, 1)
            progressFill.Size = UDim2.new(ratio, 0, 1, 0)
            thumb.Position = UDim2.new(ratio, 0, 0.5, 0)
            if MusicEngine and MusicEngine.seek then
                MusicEngine.seek(ratio)
            end
        end
    end

    scrubHitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            scrubbing = true
            seekFromInput(input)
        end
    end)

    local connChanged = UserInputService.InputChanged:Connect(function(input)
        if scrubbing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            seekFromInput(input)
        end
    end)

    local connEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            scrubbing = false
        end
    end)

    controlsFrame.Destroying:Connect(function()
        pcall(function() connChanged:Disconnect() end)
        pcall(function() connEnded:Disconnect() end)
    end)

    -- Buttons Container on right
    local btnContainer = Instance.new("Frame")
    btnContainer.Name = "ButtonsContainer"
    btnContainer.Size = UDim2.new(0, 105, 1, 0)
    btnContainer.Position = UDim2.new(1, -105, 0, 0)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = controlsFrame

    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    btnLayout.Padding = UDim.new(0, 6)
    btnLayout.Parent = btnContainer

    -- Helper to create buttons
    local function createBtn(name, text, size)
        local isPlay = (name == "PlayBtn")
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = size or UDim2.new(0, 22, 0, 22)
        btn.BackgroundColor3 = isPlay and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(36, 24, 34)
        btn.BackgroundTransparency = 0
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = isPlay and Color3.fromRGB(20, 14, 20) or Color3.fromRGB(255, 240, 245)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = isPlay and 12 or 10.5
        btn.AutoButtonColor = false
        btn.Active = true
        btn.ZIndex = 5
        btn.Parent = btnContainer

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = btn

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundColor3 = isPlay and Color3.fromRGB(255, 215, 225) or Color3.fromRGB(56, 30, 45)
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundColor3 = isPlay and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(36, 24, 34)
            }):Play()
        end)

        return btn
    end

    local prevBtn = createBtn("PrevBtn", "<<", UDim2.new(0, 24, 0, 20))
    local playBtn = createBtn("PlayBtn", "▶", UDim2.new(0, 24, 0, 24))
    local nextBtn = createBtn("NextBtn", ">>", UDim2.new(0, 24, 0, 20))

    -- Wire Music Engine Events
    if MusicEngine and MusicEngine.onStateChange then
        MusicEngine.onStateChange(function(state)
            if state and state.Track then
                trackTitle.Text = state.Track.Title
                playBtn.Text = state.IsPlaying and "||" or "▶"
            end
        end)
    end

    local function animatePress(btn)
        TweenService:Create(btn, TweenInfo.new(0.06), { Size = UDim2.new(0, btn.AbsoluteSize.X - 3, 0, btn.AbsoluteSize.Y - 3) }):Play()
        task.delay(0.07, function()
            if btn and btn.Parent then
                local origW = (btn.Name == "PlayBtn") and 24 or 24
                local origH = (btn.Name == "PlayBtn") and 24 or 20
                TweenService:Create(btn, TweenInfo.new(0.1), { Size = UDim2.new(0, origW, 0, origH) }):Play()
            end
        end)
    end

    local function handleTogglePlay()
        animatePress(playBtn)
        if MusicEngine then
            local isPlaying = MusicEngine.togglePlay()
            playBtn.Text = isPlaying and "||" or "▶"
            local t = MusicEngine.getCurrentTrack()
            if Utils then
                Utils.toast("Monody Music", isPlaying and ("Playing: " .. (t and t.Title or "Phonk")) or "Music Paused", 1.2)
            end
        end
    end
    playBtn.Activated:Connect(handleTogglePlay)
    playBtn.MouseButton1Click:Connect(handleTogglePlay)

    local function handleNext()
        animatePress(nextBtn)
        if MusicEngine then
            MusicEngine.nextTrack()
            local t = MusicEngine.getCurrentTrack()
            if Utils then
                Utils.toast("Monody Music", "Next: " .. (t and t.Title or "Phonk"), 1.2)
            end
        end
    end
    nextBtn.Activated:Connect(handleNext)
    nextBtn.MouseButton1Click:Connect(handleNext)

    local function handlePrev()
        animatePress(prevBtn)
        if MusicEngine then
            MusicEngine.prevTrack()
            local t = MusicEngine.getCurrentTrack()
            if Utils then
                Utils.toast("Monody Music", "Prev: " .. (t and t.Title or "Phonk"), 1.2)
            end
        end
    end
    prevBtn.Activated:Connect(handlePrev)
    prevBtn.MouseButton1Click:Connect(handlePrev)

    -- Visualizer Render Loop
    local wavePhase = 0
    RunService.RenderStepped:Connect(function(dt)
        wavePhase = wavePhase + (dt * 6)
        local isPlaying = MusicEngine and MusicEngine.IsPlaying
        local loudness = (MusicEngine and MusicEngine.getLoudness and MusicEngine.getLoudness()) or 0.1
        local pct, pos, len = 0, 0, 150
        if MusicEngine and MusicEngine.getProgress then
            pct, pos, len = MusicEngine.getProgress()
        end

        -- Update progress bar & time label
        if not scrubbing then
            progressFill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
            thumb.Position = UDim2.new(math.clamp(pct, 0, 1), 0, 0.5, 0)
        end
        if Utils and Utils.formatTime then
            timeLabel.Text = Utils.formatTime(pos) .. " / " .. Utils.formatTime(len)
        else
            timeLabel.Text = string.format("%02d:%02d / %02d:%02d", math.floor(pos/60), math.floor(pos%60), math.floor(len/60), math.floor(len%60))
        end

        -- Update vertical bars height
        for i, bar in ipairs(bars) do
            local targetHeight = 5
            if isPlaying then
                local freq1 = math.sin(wavePhase + (i * 0.45))
                local freq2 = math.cos((wavePhase * 0.7) + (i * 0.3))
                local wave = math.abs((freq1 + freq2) * 0.5)
                targetHeight = math.clamp(4 + (wave * 14 * loudness), 3, 18)
            else
                -- Idle smooth resting wave
                local idleWave = math.abs(math.sin((wavePhase * 0.35) + (i * 0.22)))
                targetHeight = 3 + (idleWave * 4)
            end
            bar.Size = UDim2.new(0, 3, 0, math.floor(targetHeight))
        end
    end)

    return container
end

return MusicVisualizer
