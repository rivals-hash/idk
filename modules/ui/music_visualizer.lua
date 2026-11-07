--[[
    BestHub - modules/ui/music_visualizer.lua
    Interactive white music player & vertical spectrum visualizer.
    Renders inside Card 3 with animated vertical frequency bars.
    Pixel-perfect layout ensuring all playback buttons and bars are fully visible.
]]

local MusicVisualizer = {}

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function MusicVisualizer.create(parentFrame, MusicEngine, Utils, AssetManager)
    local container = Instance.new("Frame")
    container.Name = "MusicVisualizerContainer"
    container.Size = UDim2.new(1, -20, 1, -12)
    container.Position = UDim2.new(0, 10, 0, 6)
    container.BackgroundTransparency = 1
    container.Parent = parentFrame

    -- Row 1: Header (Music icon, Track Title, Playback Time)
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "HeaderFrame"
    headerFrame.Size = UDim2.new(1, 0, 0, 16)
    headerFrame.Position = UDim2.new(0, 0, 0, 0)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = container

    local musicIcon = Instance.new("ImageLabel")
    musicIcon.Name = "MusicIcon"
    musicIcon.Size = UDim2.new(0, 14, 0, 14)
    musicIcon.Position = UDim2.new(0, 0, 0.5, -7)
    musicIcon.BackgroundTransparency = 1
    musicIcon.Image = (AssetManager and AssetManager.get("music.png", "rbxassetid://113343203848535")) or "rbxassetid://113343203848535"
    musicIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    musicIcon.Parent = headerFrame

    local trackTitle = Instance.new("TextLabel")
    trackTitle.Name = "TrackTitle"
    trackTitle.Size = UDim2.new(0.65, -20, 1, 0)
    trackTitle.Position = UDim2.new(0, 20, 0, 0)
    trackTitle.BackgroundTransparency = 1
    trackTitle.Font = Enum.Font.GothamBold
    trackTitle.Text = "MONTAGEM BAILÃO (Phonk)"
    trackTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    trackTitle.TextSize = 11
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
    timeLabel.TextColor3 = Color3.fromRGB(210, 210, 220)
    timeLabel.TextSize = 10
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.Parent = headerFrame

    -- Row 2: Visualizer Bars Container (Center row)
    local barsContainer = Instance.new("Frame")
    barsContainer.Name = "BarsContainer"
    barsContainer.Size = UDim2.new(1, 0, 0, 22)
    barsContainer.Position = UDim2.new(0, 0, 0, 18)
    barsContainer.BackgroundTransparency = 1
    barsContainer.Parent = container

    local barListLayout = Instance.new("UIListLayout")
    barListLayout.FillDirection = Enum.FillDirection.Horizontal
    barListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    barListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    barListLayout.Padding = UDim.new(0, 5)
    barListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    barListLayout.Parent = barsContainer

    -- Create 26 vertical bars in white
    local numBars = 26
    local bars = {}
    for i = 1, numBars do
        local bar = Instance.new("Frame")
        bar.Name = "Bar_" .. i
        bar.LayoutOrder = i
        bar.Size = UDim2.new(0, 3, 0, 8)
        bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        bar.BorderSizePixel = 0
        bar.Parent = barsContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = bar

        table.insert(bars, bar)
    end

    -- Row 3: Progress bar & playback buttons
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "ControlsFrame"
    controlsFrame.Size = UDim2.new(1, 0, 0, 24)
    controlsFrame.Position = UDim2.new(0, 0, 0, 44)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = container

    -- Progress Bar Track
    local progressTrack = Instance.new("Frame")
    progressTrack.Name = "ProgressTrack"
    progressTrack.Size = UDim2.new(1, -115, 0, 4)
    progressTrack.Position = UDim2.new(0, 0, 0.5, -2)
    progressTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    progressTrack.BorderSizePixel = 0
    progressTrack.Parent = controlsFrame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = progressTrack

    local progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressTrack

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = progressFill

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
    btnLayout.Padding = UDim.new(0, 8)
    btnLayout.Parent = btnContainer

    -- Helper to create buttons
    local function createBtn(name, text, size)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = size or UDim2.new(0, 22, 0, 22)
        btn.BackgroundColor3 = (name == "PlayBtn") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 40)
        btn.BackgroundTransparency = (name == "PlayBtn") and 0 or 0.4
        btn.Text = text
        btn.TextColor3 = (name == "PlayBtn") and Color3.fromRGB(15, 15, 20) or Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = (name == "PlayBtn") and 11 or 10
        btn.AutoButtonColor = false
        btn.Parent = btnContainer

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = btn

        local s = Instance.new("UIStroke")
        s.Color = Color3.fromRGB(255, 255, 255)
        s.Thickness = 1
        s.Transparency = (name == "PlayBtn") and 0.5 or 0.8
        s.Parent = btn

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundTransparency = (name == "PlayBtn") and 0.15 or 0.1
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundTransparency = (name == "PlayBtn") and 0 or 0.4
            }):Play()
        end)

        return btn
    end

    local prevBtn = createBtn("PrevBtn", "⏮", UDim2.new(0, 26, 0, 26))
    local playBtn = createBtn("PlayBtn", "▶", UDim2.new(0, 28, 0, 28))
    local nextBtn = createBtn("NextBtn", "⏭", UDim2.new(0, 26, 0, 26))

    -- Wire Music Engine Events
    MusicEngine.onStateChange(function(state)
        trackTitle.Text = state.Track.Title
        playBtn.Text = state.IsPlaying and "⏸" or "▶"
    end)

    playBtn.MouseButton1Click:Connect(function()
        local isPlaying = MusicEngine.togglePlay()
        playBtn.Text = isPlaying and "⏸" or "▶"
    end)

    nextBtn.MouseButton1Click:Connect(function()
        MusicEngine.nextTrack()
    end)

    prevBtn.MouseButton1Click:Connect(function()
        MusicEngine.prevTrack()
    end)

    -- Visualizer Render Loop
    local wavePhase = 0
    RunService.RenderStepped:Connect(function(dt)
        wavePhase = wavePhase + (dt * 6)
        local isPlaying = MusicEngine.IsPlaying
        local loudness = MusicEngine.getLoudness()
        local pct, pos, len = MusicEngine.getProgress()

        -- Update progress bar & time label
        progressFill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
        timeLabel.Text = Utils.formatTime(pos) .. " / " .. Utils.formatTime(len)

        -- Update vertical bars height
        for i, bar in ipairs(bars) do
            local targetHeight = 6
            if isPlaying then
                local freq1 = math.sin(wavePhase + (i * 0.45))
                local freq2 = math.cos((wavePhase * 0.7) + (i * 0.3))
                local wave = math.abs((freq1 + freq2) * 0.5)
                targetHeight = math.clamp(5 + (wave * 15 * loudness), 4, 20)
            else
                -- Idle smooth resting wave
                local idleWave = math.abs(math.sin((wavePhase * 0.4) + (i * 0.25)))
                targetHeight = 4 + (idleWave * 5)
            end
            bar.Size = UDim2.new(0, 3, 0, math.floor(targetHeight))
        end
    end)

    return container
end

return MusicVisualizer
