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

-- Helper: Create a styled Feature Card inside a Tab View
local function createFeatureCard(parent, title, bgAsset)
    local card = Instance.new("Frame")
    card.Name = "Card_" .. title:gsub("%s+", "")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    card.BackgroundTransparency = 0.25
    card.BorderSizePixel = 0
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(65, 65, 80)
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = card

    if bgAsset then
        local bg = Instance.new("ImageLabel")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundTransparency = 1
        bg.Image = bgAsset
        bg.ScaleType = Enum.ScaleType.Stretch
        bg.Parent = card

        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 8)
        bgCorner.Parent = bg
    end

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
    local cardBgAsset = AssetManager and AssetManager.get("card_bg.png", "rbxassetid://139820186687064") or "rbxassetid://139820186687064"

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "TabView_" .. tabName
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = Color3.fromRGB(140, 140, 160)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = false
    scroll.ClipsDescendants = true
    scroll.Parent = parentContainer

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 16)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = scroll

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scroll

    -- Top Header Banner Card (Compact 46px)
    local banner = Instance.new("Frame")
    banner.Name = "Banner"
    banner.Size = UDim2.new(1, 0, 0, 46)
    banner.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    banner.BackgroundTransparency = 0.2
    banner.BorderSizePixel = 0
    banner.LayoutOrder = 1
    banner.Parent = scroll

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 8)
    bCorner.Parent = banner

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(65, 65, 80)
    bStroke.Thickness = 1
    bStroke.Transparency = 0.5
    bStroke.Parent = banner

    local bTitle = Instance.new("TextLabel")
    bTitle.Size = UDim2.new(1, -20, 0, 22)
    bTitle.Position = UDim2.new(0, 12, 0, 4)
    bTitle.BackgroundTransparency = 1
    bTitle.Font = Enum.Font.Kalam
    bTitle.Text = "Monody - " .. tabName
    bTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    bTitle.TextSize = 20
    bTitle.TextXAlignment = Enum.TextXAlignment.Left
    bTitle.Parent = banner

    local bDesc = Instance.new("TextLabel")
    bDesc.Size = UDim2.new(1, -20, 0, 14)
    bDesc.Position = UDim2.new(0, 12, 0, 26)
    bDesc.BackgroundTransparency = 1
    bDesc.Font = Enum.Font.Gotham
    bDesc.Text = "Suite oficial móvil | Por Darling"
    bDesc.TextColor3 = Color3.fromRGB(170, 170, 185)
    bDesc.TextSize = 10
    bDesc.TextXAlignment = Enum.TextXAlignment.Left
    bDesc.Parent = banner

    -- Populate content based on Tab
    if tabName == "Aimbot" then
        local c1 = createFeatureCard(scroll, "Configuración de Apuntado", cardBgAsset)
        c1.LayoutOrder = 2
        createToggle(c1, "Silent Aim", "Redirecciona disparos al objetivo", true, nil, Utils)
        createToggle(c1, "Auto Lock-On", "Fija la cámara al enemigo más cercano", false, nil, Utils)
        createToggle(c1, "Team Check", "Ignora a jugadores del mismo bando", true, nil, Utils)
        createToggle(c1, "Mostrar Círculo FOV", "Dibuja el radio de apuntado en pantalla", true, nil, Utils)

        local c2 = createFeatureCard(scroll, "Ajustes de Aimbot", cardBgAsset)
        c2.LayoutOrder = 3
        createSlider(c2, "Radio FOV", 30, 300, 120, nil, Utils)
        createSlider(c2, "Suavizado (Smooth)", 1, 10, 5, nil, Utils)
        createActionButton(c2, "Parte Objetivo: Cabeza", "Cambiar parte objetivo", function()
            Utils.toast("Monody", "Parte objetivo cambiada a Cabeza", 1.5)
        end, Utils)

    elseif tabName == "Combat" then
        local c1 = createFeatureCard(scroll, "Combate Automático", cardBgAsset)
        c1.LayoutOrder = 2
        createToggle(c1, "Fast Attack", "Ataque rápido sin retraso de animación", true, nil, Utils)
        createToggle(c1, "Auto Clicker", "Spam de golpes automático", false, nil, Utils)
        createToggle(c1, "Auto Skills Combo", "Lanza habilidades Z, X, C, V automáticamente", false, nil, Utils)
        createToggle(c1, "Kill Aura", "Daña a todos los enemigos cercanos", false, nil, Utils)

        local c2 = createFeatureCard(scroll, "Rango & Armas", cardBgAsset)
        c2.LayoutOrder = 3
        createSlider(c2, "Rango de Ataque", 10, 60, 28, nil, Utils)
        createActionButton(c2, "Equipar Mejor Arma", "Equipa tu mejor espada o fruta", function()
            Utils.toast("Monody", "Mejor arma equipada", 1.5)
        end, Utils)

    elseif tabName == "Players" then
        local c1 = createFeatureCard(scroll, "Visuales (ESP)", cardBgAsset)
        c1.LayoutOrder = 2
        createToggle(c1, "Player ESP", "Muestra nombres y distancia de jugadores", true, nil, Utils)
        createToggle(c1, "Box ESP", "Caja 2D alrededor de los personajes", false, nil, Utils)
        createToggle(c1, "Tracers", "Líneas rastreadoras hacia jugadores", false, nil, Utils)

        local c2 = createFeatureCard(scroll, "Movilidad del Jugador", cardBgAsset)
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
        local c1 = createFeatureCard(scroll, "Habilidades de Soru", cardBgAsset)
        c1.LayoutOrder = 2
        createToggle(c1, "Infinite Soru", "Soru sin límite de cargas", true, nil, Utils)
        createToggle(c1, "No Cooldown Soru", "Cero enfriamiento en esquivas", true, nil, Utils)
        createSlider(c1, "Multiplicador de Distancia", 1, 5, 2, nil, Utils)

        local c2 = createFeatureCard(scroll, "Teletransporte Rápido", cardBgAsset)
        c2.LayoutOrder = 3
        createActionButton(c2, "Teleport a Enemigo Cercano", "Teletransporta directamente a la espalda", function()
            Utils.toast("Monody", "Soru instantáneo ejecutado", 1.5)
        end, Utils)
        createActionButton(c2, "Teleport a Zona Segura", "Teletransporta a una zona neutral", function()
            Utils.toast("Monody", "Teletransportado a Zona Segura", 1.5)
        end, Utils)

    elseif tabName == "Macro" then
        local c1 = createFeatureCard(scroll, "Automatización y Farm", cardBgAsset)
        c1.LayoutOrder = 2
        createToggle(c1, "Auto Farm Nivel", "Acepta misiones y farmea automáticamente", false, nil, Utils)
        createToggle(c1, "Auto Farm Enemigo Cercano", "Ataca los monstruos cercanos", false, nil, Utils)
        createToggle(c1, "Auto Recolectar Cofres", "Vuela a cofres y recoge dinero", false, nil, Utils)

        local c2 = createFeatureCard(scroll, "Velocidad de Tween", cardBgAsset)
        c2.LayoutOrder = 3
        createSlider(c2, "Velocidad de Vuelo (Tween)", 50, 350, 220, nil, Utils)
        createActionButton(c2, "Detener Macro", "Cancela cualquier ruta en curso", function()
            Utils.toast("Monody", "Macro detenido", 1.5)
        end, Utils)

    elseif tabName == "VFX" then
        local c1 = createFeatureCard(scroll, "Optimización y Gráficos", cardBgAsset)
        c1.LayoutOrder = 2
        createToggle(c1, "Quitar Niebla (Clear Sky)", "Elimina la niebla ambiental", true, nil, Utils)
        createToggle(c1, "Modo Fullbright", "Iluminación máxima en zonas oscuras", true, nil, Utils)
        createToggle(c1, "FPS Boost Móvil", "Reduce partículas y texturas para más fluidez", false, nil, Utils)
        createToggle(c1, "Desactivar Sombras", "Aumenta la estabilidad en dispositivos gama baja", false, nil, Utils)

    elseif tabName == "Skins" then
        local c1 = createFeatureCard(scroll, "Cosméticos y Efectos", cardBgAsset)
        c1.LayoutOrder = 2
        createToggle(c1, "Aura Arcoíris de Arma", "Aura multicolor en espadas y puños", false, nil, Utils)
        createToggle(c1, "Estela de Personaje (Trail)", "Rastro de luz al moverte", false, nil, Utils)
        createActionButton(c1, "Cambiar Color de Aura (Cian)", "Ciclar colores de aura", function()
            Utils.toast("Monody", "Aura cambiada a Cian Neón", 1.5)
        end, Utils)

    elseif tabName == "Settings" then
        local c1 = createFeatureCard(scroll, "Configuración de Interfaz", cardBgAsset)
        c1.LayoutOrder = 2
        createSlider(c1, "Escala UI (%)", 50, 120, 80, function(val)
            if options.onScaleChange then pcall(options.onScaleChange, val / 100) end
        end, Utils)

        local c2 = createFeatureCard(scroll, "Utilidades de Servidor", cardBgAsset)
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
