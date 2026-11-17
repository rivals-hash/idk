-- ============================================================
-- SACRED AHK VERSION 12.5 | KEYLESS ANNOUNCEMENT
-- ============================================================
local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players:WaitForChildOfClass("Player")
local playerGui = player:WaitForChild("PlayerGui", 15)

if not playerGui then return end

-- Limpiar UI vieja
for _, old in ipairs(playerGui:GetChildren()) do
    if old.Name:match("SacredKeyUI") then old:Destroy() end
end

-- Detectar idioma
local isSpanish = false
pcall(function()
    local loc = game:GetService("LocalizationService").RobloxLocaleId
    if loc and string.find(string.lower(loc), "es") then isSpanish = true end
end)

-- Señal para esperar el click
local continueEvent = Instance.new("BindableEvent")

-- Crear ScreenGui
local launcherGui = Instance.new("ScreenGui")
launcherGui.Name = "SacredKeyUI"
launcherGui.ResetOnSpawn = false
launcherGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
launcherGui.Parent = playerGui

-- POPUP FRAME
local popFrame = Instance.new("Frame", launcherGui)
popFrame.Name = "SacredUpdatePopup"
popFrame.AutomaticSize = Enum.AutomaticSize.XY
popFrame.Size = UDim2.new(0, 0, 0, 0)
popFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
popFrame.AnchorPoint = Vector2.new(0.5, 0.5)
popFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 20)
popFrame.BorderSizePixel = 0
popFrame.Active = true
popFrame.Draggable = true

Instance.new("UICorner", popFrame).CornerRadius = UDim.new(0, 16)
local popStroke = Instance.new("UIStroke", popFrame)
popStroke.Color = Color3.fromRGB(148, 50, 255)
popStroke.Thickness = 1.2

local popPadding = Instance.new("UIPadding", popFrame)
popPadding.PaddingTop = UDim.new(0, 12)
popPadding.PaddingBottom = UDim.new(0, 12)
popPadding.PaddingLeft = UDim.new(0, 14)
popPadding.PaddingRight = UDim.new(0, 14)

local popLayout = Instance.new("UIListLayout", popFrame)
popLayout.SortOrder = Enum.SortOrder.LayoutOrder
popLayout.Padding = UDim.new(0, 6)
popLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- BOTÓN IDIOMA
local langBtn = Instance.new("TextButton", popFrame)
langBtn.Size = UDim2.new(0, 50, 0, 20)
langBtn.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
langBtn.Text = isSpanish and "ES 🌐" or "EN 🌐"
langBtn.Font = Enum.Font.GothamBold
langBtn.TextSize = 9
langBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
langBtn.LayoutOrder = 0
Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0, 6)

-- TÍTULO
local popTitle = Instance.new("TextLabel", popFrame)
popTitle.AutomaticSize = Enum.AutomaticSize.XY
popTitle.BackgroundTransparency = 1
popTitle.Text = "✨ Update 12.5"
popTitle.Font = Enum.Font.GothamBlack
popTitle.TextSize = 15
popTitle.TextColor3 = Color3.fromRGB(148, 50, 255)
popTitle.LayoutOrder = 1

-- WARNING
local popWarning = Instance.new("TextLabel", popFrame)
popWarning.AutomaticSize = Enum.AutomaticSize.Y
popWarning.Size = UDim2.new(0, 230, 0, 0)
popWarning.BackgroundTransparency = 1
popWarning.Font = Enum.Font.GothamBlack
popWarning.TextSize = 8.5
popWarning.TextColor3 = Color3.fromRGB(255, 255, 0)
popWarning.TextWrapped = true
popWarning.TextXAlignment = Enum.TextXAlignment.Center
popWarning.LayoutOrder = 2
popWarning.Text = isSpanish and "⚠️ NO USEN ESTA VERSIÓN DEL SCRIPT EN PC, UNA VERSIÓN PARA PC ESTARÁ DISPONIBLE PRONTO ⚠️" or "⚠️ DO NOT USE THIS SCRIPT VERSION ON PC, A PC VERSION WILL BE AVAILABLE SOON ⚠️"

-- CONTENIDO
local popContent = Instance.new("TextLabel", popFrame)
popContent.AutomaticSize = Enum.AutomaticSize.Y
popContent.Size = UDim2.new(0, 230, 0, 0)
popContent.BackgroundTransparency = 1
popContent.Font = Enum.Font.GothamBold
popContent.TextSize = 8.5
popContent.TextColor3 = Color3.fromRGB(200, 200, 200)
popContent.TextWrapped = true
popContent.TextXAlignment = Enum.TextXAlignment.Left
popContent.TextYAlignment = Enum.TextYAlignment.Top
popContent.LayoutOrder = 3

if isSpanish then
    popContent.Text = "Sanguine Z sin cooldown, Aimbot arreglado, Hitbox/Stun (Beta), Macro Config, Wallpapers, Songs y más.\n\n🟣 ¡El script ahora es SIN KEY! Solo presiona Empezar."
else
    popContent.Text = "Sanguine Z no cooldown, Aimbot fixed, Hitbox/Stun (Beta), Macro Config, Wallpapers, Songs & more.\n\n🟣 The script is now KEYLESS! Just click Get Started."
end

-- BOTÓN GET STARTED
local getStartedBtn = Instance.new("TextButton", popFrame)
getStartedBtn.Size = UDim2.new(0, 120, 0, 28)
getStartedBtn.BackgroundColor3 = Color3.fromRGB(148, 50, 255)
getStartedBtn.Text = isSpanish and "Empezar" or "Get Started"
getStartedBtn.Font = Enum.Font.GothamBlack
getStartedBtn.TextSize = 10
getStartedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
getStartedBtn.LayoutOrder = 4
Instance.new("UICorner", getStartedBtn).CornerRadius = UDim.new(0, 8)

-- FUNCIONES DE LOS BOTONES
langBtn.MouseButton1Click:Connect(function()
    isSpanish = not isSpanish
    langBtn.Text = isSpanish and "ES 🌐" or "EN 🌐"
    getStartedBtn.Text = isSpanish and "Empezar" or "Get Started"
    popWarning.Text = isSpanish and "⚠️ NO USEN ESTA VERSIÓN DEL SCRIPT EN PC, UNA VERSIÓN PARA PC ESTARÁ DISPONIBLE PRONTO ⚠️" or "⚠️ DO NOT USE THIS SCRIPT VERSION ON PC, A PC VERSION WILL BE AVAILABLE SOON ⚠️"
    if isSpanish then
        popContent.Text = "Sanguine Z sin cooldown, Aimbot arreglado, Hitbox/Stun (Beta), Macro Config, Wallpapers, Songs y más.\n\n🟣 ¡El script ahora es SIN KEY! Solo presiona Empezar."
    else
        popContent.Text = "Sanguine Z no cooldown, Aimbot fixed, Hitbox/Stun (Beta), Macro Config, Wallpapers, Songs & more.\n\n🟣 The script is now KEYLESS! Just click Get Started."
    end
end)

getStartedBtn.MouseButton1Click:Connect(function()
    launcherGui:Destroy()
    continueEvent:Fire()
end)

-- ESPERAR A QUE PRESIONEN GET STARTED
continueEvent.Event:Wait()
continueEvent:Destroy()

-- ============================================================
-- 👇 PON TU SCRIPT AQUÍ ABAJO - SE EJECUTA AL PRESIONAR GET STARTED
-- ============================================================



-- ============================================================
-- SACRED AHK VERSION 12.5 | LOCAL DEV STANDALONE
-- ============================================================

-- OPEN SOURCE SCRIPT 

-- OPEN SOURCE SCRIPT

-- OPEN SOURCE SCRIPT 

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

local player = Players.LocalPlayer or Players:FindFirstChildOfClass("Player")

local camera = workspace.CurrentCamera
local mouse = nil
pcall(function() mouse = player and player:GetMouse() end)

local playerGui = nil
pcall(function() 
    if player then
        playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 5)
    end
end)

function _decodeUrl(b)
    local s = {}
    for i = 1, #b do
        local a, k = b[i], 0x5A
        local r, p = 0, 1
        while a > 0 or k > 0 do
            local ra, rk = a % 2, k % 2
            if ra ~= rk then r = r + p end
            a, k, p = (a - ra) / 2, (k - rk) / 2, p * 2
        end
        s[i] = string.char(r)
    end
    return table.concat(s)
end

-- Tracking Variables
scriptStartTime = os.time()
totalExecutions = 0
startBounty = 0
accumulatedBountyGained = 0

-- Cargar Bounty Local Guardado
pcall(function()
    if isfile and readfile and isfile("SacredAHK_Bounty.json") then
        local bData = HttpService:JSONDecode(readfile("SacredAHK_Bounty.json"))
        if bData and bData.Gained then accumulatedBountyGained = bData.Gained end
    end
end)

function SaveLocalBounty(gained)
    accumulatedBountyGained = gained
    pcall(function()
        if writefile then
            writefile("SacredAHK_Bounty.json", HttpService:JSONEncode({Gained = gained}))
        end
    end)
end

-- Estado
SoruInfinitoEnabled = false
SoruAimbotEnabled = false
soruMaxDist = 1000 -- Distancia normal por defecto
AimlockPlayerEnabled = false
AimlockNpcEnabled = false
SilentAimPlayersEnabled = false
SilentAimNPCsEnabled = false
PlayerWidgetActive = false
NpcWidgetActive = false
SelectedSoruTarget = "Nearest"
maxRange = 2500
PlayersPosition = nil
NPCPosition = nil

-- Config Aimbot & Dragon Gun M1
_G.G_DragonGunM1 = false
_G.G_AttackMobs = true
_G.G_AttackPlayers = true

_G.G_SilentAimSkill = false
_G.G_SilentAimShowFOV = false
_G.G_SilentAimFOV = 150
_G.G_SilentAimPart = "HumanoidRootPart"
_G.G_SilentAimFOVThickness = 2
_G.G_SilentAimFOVTransparency = 1
_G.G_SilentAimTargetPlayers = false
_G.G_SilentAimTargetMobs = false
_G.G_TargetRainbowBodyESP = false
_G.G_SilentAimFOVMode = "Screen Center"
_G.G_SilentAimTeamCheck = false
_G.G_SilentAimSelectedPlayer = ""
_G.G_AimbotMelee = false
_G.G_AimbotFruit = false
_G.G_AimbotSword = false
_G.G_AimbotGun = false

-- Granular Exclusions per Category & Skill Key (Todas desactivadas por defecto; el usuario controla libremente)
_G.G_Ex_Fruit_M1 = false; _G.G_Ex_Fruit_Z = false; _G.G_Ex_Fruit_X = false; _G.G_Ex_Fruit_C = false; _G.G_Ex_Fruit_V = false; _G.G_Ex_Fruit_F = false
_G.G_Ex_Melee_M1 = false; _G.G_Ex_Melee_Z = false; _G.G_Ex_Melee_X = false; _G.G_Ex_Melee_C = false; _G.G_Ex_Melee_V = false; _G.G_Ex_Melee_F = false
_G.G_Ex_Sword_M1 = false; _G.G_Ex_Sword_Z = false; _G.G_Ex_Sword_X = false; _G.G_Ex_Sword_C = false; _G.G_Ex_Sword_V = false; _G.G_Ex_Sword_F = false
_G.G_Ex_Gun_M1 = false;   _G.G_Ex_Gun_Z = false;   _G.G_Ex_Gun_X = false;   _G.G_Ex_Gun_C = false;   _G.G_Ex_Gun_V = false;   _G.G_Ex_Gun_F = false

-- Variables
SuperJumpEnabled = false 
SuperJumpPower = 500 
SanguineAutoEnabled = false
SanguineWidgetVisible = false 
SanguineAutoConnection = nil
SanguineAutoDropDuration = 2.0
SanguineAutoCooldown = false
SanguineNoCDEnabled = false
noCDCharConnection = nil
SoulGuitarJumpEnabled = false
SoulGuitarWidgetVisible = false
SoulGuitarDashLength = 121 
soulGuitarBusy = false
fflagsThread = nil

-- NUEVAS Variables
PortalSoruEnabled = false
PortalSoruWidgetVisible = false
BlacklistedPlayers = {}
FakeKorbloxEnabled = false
FakeHeadlessEnabled = false
ActiveAura = nil
AuraObjects = {}
FPSPingOverlayEnabled = false
currentFPS = 0
currentPing = 0
currentLang = "EN"


-- Variables Dash
DashEnabled = false
DashLengthDist = 1
DashRunning = false
prevDashLength = 1 
prevDashEnabled = false 

-- -- ============================================================
-- PERSISTENCIA TOTAL DE CONFIGURACIÓN (SAVE CONFIG & LOAD CONFIG)
-- ============================================================
UI_Toggle_Refreshes = {}
ToggleRegistryMap = {}

function SaveConfig()
    local conf = {
        -- ESP Settings
        ESPMaster = _G.G_ESPEnabled,
        ESPName = _G.G_ESP_Name,
        ESPLevel = _G.G_ESP_Level,
        ESPBounty = _G.G_ESP_Bounty,
        ESPFruit = _G.G_ESP_Fruit,
        ESPDist = _G.G_ESP_Distance,
        ESPHealth = _G.G_ESP_HP,
        ESPHighlight = _G.G_ESP_Highlight,
        ESPTextSize = _G.G_ESP_TextSize,

        -- Combat & Movement
        FastAttack = FastAttackEnabled,
        WalkSpeed = WalkSpeedEnabled,
        WSpeedVal = WalkSpeedValue,
        Dash = DashEnabled,
        DashDist = DashLengthDist,
        Noclip = NoclipEnabled,
        WalkOnWater = WalkOnWaterEnabled,
        SmartV4 = SmartAutoV4Enabled,

        -- Glitches & Specials
        SanguineManual = SanguineManualEnabled,
        SanguineAuto = SanguineAutoEnabled,
        SanguineDrop = SanguineAutoDropDuration,
        SanguineNoCD = SanguineNoCDEnabled,
        AntiStunHitbox = AntiStunHitboxEnabled,
        SuperJump = SuperJumpEnabled,
        SuperPower = SuperJumpPower,
        SoulGuitar = SoulGuitarJumpEnabled,
        SoulDash = SoulGuitarDashLength,
        NoAnim = NoAnimEnabled,
        AntiLava = antiLavaActive,
        DeleteShip = deleteShipActive,

        -- Silent Aim / Aimbot
        TargetPlayers = _G.G_SilentAimTargetPlayers,
        TargetMobs = _G.G_SilentAimTargetMobs,
        SkillAimbot = _G.G_SilentAimSkill,
        DragonM1 = _G.G_DragonGunM1,
        TeamCheck = _G.G_SilentAimTeamCheck,
        ShowFOV = _G.G_SilentAimShowFOV,
        ShowLine = _G.G_SilentAimShowLine,
        FOVRadius = _G.G_SilentAimFOV,
        AimbotMaxDist = maxRange,

        -- Aimlock / Widgets
        AimlockPlayers = AimlockPlayerEnabled,
        AimlockNPCs = AimlockNpcEnabled,
        PlayerWidgetActive = PlayerWidgetActive,
        NpcWidgetActive = NpcWidgetActive,
        SanguineWidgetVisible = SanguineWidgetVisible,
        SanguineManualWidgetVisible = SanguineManualWidgetVisible,
        SoulGuitarWidgetVisible = SoulGuitarWidgetVisible,
        PortalSoruWidgetVisible = PortalSoruWidgetVisible,
        SuperJumpWidgetVisible = SuperJumpWidgetVisible,

        -- Soru & Combos
        InfSoru = SoruInfinitoEnabled,
        SoruAimbot = SoruAimbotEnabled,
        PortalSoru = PortalSoruEnabled,
        PortalSanguineC = PortalSanguineCEnabled,
        PortalSanguineCTriggerMode = PortalSanguineCTriggerMode,

        -- Misc & Appearance
        FakeKorblox = FakeKorbloxEnabled,
        FakeHeadless = FakeHeadlessEnabled,
        FPSPing = FPSPingOverlayEnabled,
        MacroBeta = MacroEnabled,
        MacroMode = MacroMode,
        MacroSlot1 = MacroSlot1,
        MacroKey1 = MacroKey1,
        MacroSlot2 = MacroSlot2,
        MacroKey2 = MacroKey2,
        MacroSlot3 = MacroSlot3,
        MacroKey3 = MacroKey3,
        MacroSlot4 = MacroSlot4,
        MacroKey4 = MacroKey4,
        MacroSlot5 = MacroSlot5,
        MacroKey5 = MacroKey5,
        MacroSlot6 = MacroSlot6,
        MacroKey6 = MacroKey6,
        MacroDelay1 = MacroDelay1,
        MacroDelay2 = MacroDelay2,
        MacroDelay3 = MacroDelay3,
        MacroDelay4 = MacroDelay4,
        MacroDelay5 = MacroDelay5,
        MacroDelay6 = MacroDelay6,
        AutoV4 = AutoV4Enabled,
        ThemeName = currentThemeName,
        Language = currentLang
    }
    pcall(function()
        if writefile then
            writefile("SacredAHK_Config.json", HttpService:JSONEncode(conf))
            print("💾 Sacred AHK Config Saved Successfully!")
        end
    end)
end

function LoadConfig()
    pcall(function()
        if isfile and readfile and isfile("SacredAHK_Config.json") then
            local str = readfile("SacredAHK_Config.json")
            local conf = HttpService:JSONDecode(str)
            if not conf then return end

            -- 1. Restaurar Toggles registrados
            for id, val in pairs(conf) do
                if val ~= nil and ToggleRegistryMap[id] ~= nil then
                    pcall(function() ToggleRegistryMap[id](val) end)
                end
            end

            -- 2. Restaurar ESP
            if conf.ESPMaster ~= nil then 
                _G.G_ESPEnabled = conf.ESPMaster 
                if conf.ESPMaster then EnableESP() else DisableESP() end
            end
            if conf.ESPName ~= nil then _G.G_ESP_Name = conf.ESPName end
            if conf.ESPLevel ~= nil then _G.G_ESP_Level = conf.ESPLevel end
            if conf.ESPBounty ~= nil then _G.G_ESP_Bounty = conf.ESPBounty end
            if conf.ESPFruit ~= nil then _G.G_ESP_Fruit = conf.ESPFruit end
            if conf.ESPDist ~= nil then _G.G_ESP_Distance = conf.ESPDist end
            if conf.ESPHealth ~= nil then _G.G_ESP_HP = conf.ESPHealth end
            if conf.ESPHighlight ~= nil then _G.G_ESP_Highlight = conf.ESPHighlight end
            if conf.ESPTextSize ~= nil then _G.G_ESP_TextSize = conf.ESPTextSize end

            -- 3. Restaurar Valores Numéricos y Variables de Combate
            if conf.WSpeedVal ~= nil then WalkSpeedValue = conf.WSpeedVal end
            if conf.DashDist ~= nil then DashLengthDist = conf.DashDist end
            if conf.SuperPower ~= nil then SuperJumpPower = conf.SuperPower end
            if conf.SanguineDrop ~= nil then SanguineAutoDropDuration = conf.SanguineDrop end
            if conf.SanguineNoCD ~= nil then SanguineNoCDEnabled = conf.SanguineNoCD end
            if conf.AntiStunHitbox ~= nil then AntiStunHitboxEnabled = conf.AntiStunHitbox end
            if conf.SoulDash ~= nil then SoulGuitarDashLength = conf.SoulDash end
            if conf.FOVRadius ~= nil then 
                _G.G_SilentAimFOV = conf.FOVRadius 
                if FOVCircle then FOVCircle.Radius = conf.FOVRadius end
            end
            if conf.AimbotMaxDist ~= nil then maxRange = conf.AimbotMaxDist end

            -- 4. Restaurar Sanguine Manual
            if conf.SanguineManual ~= nil then
                SanguineManualEnabled = conf.SanguineManual
            end
            if conf.SanguineManualWidgetVisible ~= nil then
                SanguineManualWidgetVisible = conf.SanguineManualWidgetVisible
            end

            -- 5. Restaurar Visibilidad de Widgets Flotantes
            if conf.PlayerWidgetActive ~= nil then PlayerWidgetActive = conf.PlayerWidgetActive end
            if conf.NpcWidgetActive ~= nil then NpcWidgetActive = conf.NpcWidgetActive end
            if conf.SanguineWidgetVisible ~= nil then SanguineWidgetVisible = conf.SanguineWidgetVisible end
            if conf.SoulGuitarWidgetVisible ~= nil then SoulGuitarWidgetVisible = conf.SoulGuitarWidgetVisible end
            if conf.PortalSoruWidgetVisible ~= nil then PortalSoruWidgetVisible = conf.PortalSoruWidgetVisible end
            if conf.SuperJumpWidgetVisible ~= nil then SuperJumpWidgetVisible = conf.SuperJumpWidgetVisible end

            -- 6. Aplicar Sincronizaciones Visuales
            if FOVCircle then FOVCircle.Visible = (_G.G_SilentAimShowFOV == true) end
            if conf.ThemeName and applyNewTheme then applyNewTheme(conf.ThemeName) end
            if updateWidgetsVisuals then updateWidgetsVisuals() end

            if conf.MacroBeta ~= nil then MacroEnabled = conf.MacroBeta end
            if conf.MacroMode ~= nil then MacroMode = conf.MacroMode end
            if conf.MacroSlot1 ~= nil then MacroSlot1 = conf.MacroSlot1 end
            if conf.MacroKey1 ~= nil then MacroKey1 = conf.MacroKey1 end
            if conf.MacroSlot2 ~= nil then MacroSlot2 = conf.MacroSlot2 end
            if conf.MacroKey2 ~= nil then MacroKey2 = conf.MacroKey2 end
            if conf.MacroSlot3 ~= nil then MacroSlot3 = conf.MacroSlot3 end
            if conf.MacroKey3 ~= nil then MacroKey3 = conf.MacroKey3 end
            if conf.MacroSlot4 ~= nil then MacroSlot4 = conf.MacroSlot4 end
            if conf.MacroKey4 ~= nil then MacroKey4 = conf.MacroKey4 end
            if conf.MacroSlot5 ~= nil then MacroSlot5 = conf.MacroSlot5 end
            if conf.MacroKey5 ~= nil then MacroKey5 = conf.MacroKey5 end
            if conf.MacroSlot6 ~= nil then MacroSlot6 = conf.MacroSlot6 end
            if conf.MacroKey6 ~= nil then MacroKey6 = conf.MacroKey6 end
            if conf.MacroDelay1 ~= nil then MacroDelay1 = conf.MacroDelay1 end
            if conf.MacroDelay2 ~= nil then MacroDelay2 = conf.MacroDelay2 end
            if conf.MacroDelay3 ~= nil then MacroDelay3 = conf.MacroDelay3 end
            if conf.MacroDelay4 ~= nil then MacroDelay4 = conf.MacroDelay4 end
            if conf.MacroDelay5 ~= nil then MacroDelay5 = conf.MacroDelay5 end
            if conf.MacroDelay6 ~= nil then MacroDelay6 = conf.MacroDelay6 end
            if conf.AutoV4 ~= nil then 
                AutoV4Enabled = conf.AutoV4 
                if AutoV4Enabled then startAutoV4Loop() end
            end

            if conf.Language ~= nil then 
                currentLang = conf.Language 
                if updateLangBtnColors then updateLangBtnColors() end
                if updateLanguageUI then updateLanguageUI() end
            end

            print("✅ Sacred AHK Config Loaded & Applied Successfully!")
        end
    end)
end

pcall(function()
    local targetFolder = parentGui or playerGui
    if targetFolder then
        for _, old in ipairs(targetFolder:GetChildren()) do
            if old and old.Name and old.Name:match("SacredUI") then 
                pcall(function() old:Destroy() end) 
            end
        end
    end
end)

-- ============================================================
-- DRAGON GUN M1 FAST ATTACK (LÓGICA RJR / FLOATING BUTTON)
-- ============================================================
local DragonModules, DragonNet, ShootGunEvent, Validator2
task.spawn(function()
    pcall(function()
        DragonModules = ReplicatedStorage:WaitForChild("Modules", 3)
        if DragonModules then
            DragonNet = DragonModules:WaitForChild("Net", 3)
            if DragonNet then
                ShootGunEvent = DragonNet:WaitForChild("RE/ShootGunEvent", 3)
            end
        end
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 3)
        if remotes then
            Validator2 = remotes:WaitForChild("Validator2", 3)
        end
    end)
end)

local getupval = debug.getupvalue or getupvalue
local setupval = debug.setupvalue or setupvalue
local getupvals = debug.getupvalues or getupvalues

local ShootFunction
local V_Idx = { v26 = 12, v22 = 13, v25 = 14, v21 = 15, v23 = 16, v24 = 17, v27 = 18 }

function InitDragonGun()
    local success, result = pcall(require, ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("CombatController"))
    if success and type(result) == "table" and result.Attack then
        ShootFunction = getupval(result.Attack, 9)
    end
end

function GetNextValidator()
    if not ShootFunction then InitDragonGun() end
    if not ShootFunction then return 0, 0 end
    local upvals = getupvals(ShootFunction)
    if not upvals then return 0, 0 end
    if upvals[V_Idx.v21] ~= 727595 then
        for i, v in pairs(upvals) do
            if v == 727595 then
                local offset = i - 15
                V_Idx.v21 = i; V_Idx.v22 = 13 + offset; V_Idx.v23 = 16 + offset
                V_Idx.v24 = 17 + offset; V_Idx.v26 = 12 + offset; V_Idx.v25 = 14 + offset
                V_Idx.v27 = 18 + offset
                break
            end
        end
    end
    local v1 = getupval(ShootFunction, V_Idx.v21)
    local v2 = getupval(ShootFunction, V_Idx.v22)
    local v3 = getupval(ShootFunction, V_Idx.v23)
    local v4 = getupval(ShootFunction, V_Idx.v24)
    local v5 = getupval(ShootFunction, V_Idx.v25)
    local v6 = getupval(ShootFunction, V_Idx.v26)
    local v7 = getupval(ShootFunction, V_Idx.v27)
    if not (v1 and v2 and v3 and v4 and v5 and v6 and v7) then return 0, 0 end
    local v8 = v6 * v2
    local v9 = (v5 * v2 + v6 * v1) % v3
    v9 = (v9 * v3 + v8) % v4
    v5 = math.floor(v9 / v3)
    v6 = v9 - v5 * v3
    v7 = v7 + 1
    setupval(ShootFunction, V_Idx.v25, v5)
    setupval(ShootFunction, V_Idx.v26, v6)
    setupval(ShootFunction, V_Idx.v27, v7)
    return math.floor(v9 / v4 * 16777215), v7
end

function GetClosestDragonTarget()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, dist = nil, math.huge
    local myPos = root.Position

    if _G.G_AttackMobs or _G.G_SilentAimTargetMobs or SilentAimNPCsEnabled then
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, enemy in pairs(enemies:GetChildren()) do
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                local r = enemy:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and r then
                    local d = (r.Position - myPos).Magnitude
                    if d < dist then dist = d; closest = r end
                end
            end
        end
    end

    if _G.G_AttackPlayers or _G.G_SilentAimTargetPlayers or SilentAimPlayersEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and r then
                    local d = (r.Position - myPos).Magnitude
                    if d < dist then dist = d; closest = r end
                end
            end
        end
    end
    return closest
end

-- Bucle Principal Dragon Gun M1
task.spawn(function()
    while true do
        task.wait(0.085)
        if _G.G_DragonGunM1 then
            pcall(function()
                local char = player.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if not tool or tool.ToolTip ~= "Gun" then return end
                local target = GetClosestDragonTarget()
                if not target then return end
                local code, count = GetNextValidator()
                if code ~= 0 then Validator2:FireServer(code, count) end
                tool:SetAttribute("LocalOverheat", 0)
                tool:SetAttribute("LocalTotalShots", (tool:GetAttribute("LocalTotalShots") or 0) + 1)
                ShootGunEvent:FireServer(target.Position, { target })
            end)
        end
    end
end)

-- Botón Flotante Dragon M1 Eliminado (Sincronizado directamente con la UI)
function UpdateDragonButton()
    -- Sincronización directa con el toggle de la UI sin botón flotante externo
end



if player:FindFirstChild("Backpack") then
    player.Backpack.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.1)
            applyCustomFruitIcon()
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(1.5)
        applyCustomFruitIcon()
    end
end)

-- ============================================================
-- AUTO RACE V4 ENGINE
-- ============================================================
AutoV4Enabled = false
local autoV4Thread = nil

function startAutoV4Loop()
    if autoV4Thread then return end
    autoV4Thread = task.spawn(function()
        while AutoV4Enabled do
            task.wait(0.5)
            pcall(function()
                local char = player.Character
                if not char then return end
                local raceEnergy = char:GetAttribute("RaceEnergy")
                if raceEnergy and raceEnergy >= 100 then
                    local awk = player.Backpack:FindFirstChild("Awakening") or char:FindFirstChild("Awakening")
                    if awk and awk:FindFirstChild("RemoteFunction") then
                        awk.RemoteFunction:InvokeServer(true)
                    else
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        if remotes and remotes:FindFirstChild("CommF_") then
                            remotes.CommF_:InvokeServer("Awakening", true)
                        end
                    end
                end
            end)
        end
        autoV4Thread = nil
    end)
end

function stopAutoV4Loop()
    AutoV4Enabled = false
    autoV4Thread = nil
end
AntiStunHitboxEnabled = false
antiStunHeartbeatConn = nil
antiStunInputConn = nil
antiStunCharConn = nil

function enableAntiStunHitbox()
    AntiStunHitboxEnabled = true
    
    if antiStunHeartbeatConn then antiStunHeartbeatConn:Disconnect() end
    antiStunHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not AntiStunHitboxEnabled then return end
        pcall(function()
            local char = player.Character
            if not char then return end
            char:SetAttribute("AllCooldown", 0)
            char:SetAttribute("FlashstepCooldown", 1)
            char:SetAttribute("UsingSkill", false)
            char:SetAttribute("isUsingSkill", false)
            char:SetAttribute("Busy", false)
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if hum and hum.WalkSpeed < 16 then hum.WalkSpeed = 16 end
            if root then
                for _, v in ipairs(root:GetChildren()) do
                    if v:IsA("BodyVelocity") or v:IsA("BodyPosition") then
                        v:Destroy()
                    end
                end
            end
            local pgui = player:FindFirstChild("PlayerGui")
            if pgui and pgui:FindFirstChild("Main") then
                local skills = pgui.Main:FindFirstChild("Skills")
                if skills then
                    local dbSkills = skills:FindFirstChild("Dark Blade")
                    if dbSkills then
                        for _, skillFrame in ipairs(dbSkills:GetChildren()) do
                            local cd = skillFrame:FindFirstChild("Cooldown")
                            if cd and cd:IsA("Frame") then
                                cd.Size = UDim2.new(0, 0, 1, 0)
                                cd.Visible = false
                            end
                        end
                    end
                end
            end
        end)
    end)
    
    if antiStunInputConn then antiStunInputConn:Disconnect() end
    antiStunInputConn = UserInputService.InputBegan:Connect(function(input, gp)
        if not AntiStunHitboxEnabled or gp then return end
        local char = player.Character
        if not char then return end
        local darkBlade = char:FindFirstChild("Dark Blade")
        if not darkBlade or not darkBlade:FindFirstChild("RemoteEvent") then return end
        if input.KeyCode == Enum.KeyCode.Z then
            darkBlade.RemoteEvent:FireServer("Z")
        elseif input.KeyCode == Enum.KeyCode.X then
            darkBlade.RemoteEvent:FireServer("X")
        end
    end)
    
    if antiStunCharConn then antiStunCharConn:Disconnect() end
    antiStunCharConn = player.CharacterAdded:Connect(function(char)
        if AntiStunHitboxEnabled then
            task.wait(1)
            pcall(function()
                char:SetAttribute("AllCooldown", 0)
                char:SetAttribute("FlashstepCooldown", 1)
            end)
        end
    end)
end

function disableAntiStunHitbox()
    AntiStunHitboxEnabled = false
    if antiStunHeartbeatConn then antiStunHeartbeatConn:Disconnect(); antiStunHeartbeatConn = nil end
    if antiStunInputConn then antiStunInputConn:Disconnect(); antiStunInputConn = nil end
    if antiStunCharConn then antiStunCharConn:Disconnect(); antiStunCharConn = nil end
    pcall(function()
        local char = player.Character
        if char then
            char:SetAttribute("AllCooldown", nil)
            char:SetAttribute("FlashstepCooldown", nil)
            char:SetAttribute("UsingSkill", nil)
            char:SetAttribute("isUsingSkill", nil)
            char:SetAttribute("Busy", nil)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
            end
        end
    end)
end
RegisterHit, RegisterAttack = nil, nil
FastAttackEnabled = false
FastAttackRange = 2500
FastAttackRunning = false

spawn(function()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name == "RE/RegisterHit" then RegisterHit = v end
        if v:IsA("RemoteEvent") and v.Name == "RE/RegisterAttack" then RegisterAttack = v end
    end
end)

function AttackMultipleTargets(targets)
    if not RegisterHit or not RegisterAttack then return end
    pcall(function()
        if not targets or #targets == 0 then return end
        local allTargets = {}
        for _, char in pairs(targets) do
            local head = char:FindFirstChild("Head")
            if head then table.insert(allTargets, {char, head}) end
        end
        if #allTargets == 0 then return end
        RegisterAttack:FireServer(0)
        RegisterHit:FireServer(allTargets[1][2], allTargets)
    end)
end

function StartFastAttack()
    if FastAttackRunning then return end
    FastAttackRunning = true
    spawn(function()
        while FastAttackEnabled do
            RunService.Stepped:Wait()
            local myChar = player.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHRP then
                local targets = {}
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and not BlacklistedPlayers[p.Name] then
                        local hum = p.Character:FindFirstChild("Humanoid")
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hum and hrp and hum.Health > 0 and (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                            table.insert(targets, p.Character)
                        end
                    end
                end
                local enemies = workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, npc in pairs(enemies:GetChildren()) do
                        local hum = npc:FindFirstChild("Humanoid")
                        local hrp = npc:FindFirstChild("HumanoidRootPart")
                        if hum and hrp and hum.Health > 0 and (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                            table.insert(targets, npc)
                        end
                    end
                end
                if #targets > 0 then AttackMultipleTargets(targets) end
            end
        end
        FastAttackRunning = false
    end)
end

-- ============================================================
-- WALK SPEED
-- ============================================================
WalkSpeedEnabled = false
WalkSpeedValue = 16

spawn(function()
    while true do
        wait(0.2)
        if WalkSpeedEnabled then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= WalkSpeedValue then hum.WalkSpeed = WalkSpeedValue end
        end
    end
end)

-- ============================================================
-- DASH DISTANCE
-- ============================================================
function startDashLoop()
    if DashRunning then return end
    DashRunning = true
    spawn(function()
        while DashEnabled do
            wait(0.1)
            pcall(function()
                local char = player.Character
                if char then
                    if char:GetAttribute("DashLength") ~= DashLengthDist then char:SetAttribute("DashLength", DashLengthDist) end
                    if char:GetAttribute("DashLengthAir") ~= DashLengthDist then char:SetAttribute("DashLengthAir", DashLengthDist) end
                end
            end)
        end
        DashRunning = false
    end)
end

function stopDashLoop()
    DashEnabled = false
    pcall(function()
        local char = player.Character
        if char then
            char:SetAttribute("DashLength", 1)
            char:SetAttribute("DashLengthAir", 1)
        end
    end)
end

function applyDashInstantly()
    pcall(function()
        local char = player.Character
        if char then
            char:SetAttribute("DashLength", DashLengthDist)
            char:SetAttribute("DashLengthAir", DashLengthDist)
        end
    end)
end

-- ============================================================
-- NOCLIP
-- ============================================================
NoclipEnabled = false
NoclipConn = nil

function SetNoclip(state)
    NoclipEnabled = state
    if state then
        NoclipConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if char and NoclipEnabled then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

player.CharacterAdded:Connect(function()
    if NoclipEnabled then wait(0.5); SetNoclip(true) end
end)

-- ============================================================
-- DETENER ANIMACIONES (FIX BUG DE LADO + NO ROMPER M1)
-- ============================================================
ATTACK_KEYWORDS = {"attack", "slash", "punch", "m1", "combo", "hit", "tool", "ability", "skill", "kamehameha", "bullet", "gun", "sword", "melee", "fruit"}

function isAttackAnim(track)
    local name = string.lower(track.Name)
    for _, kw in ipairs(ATTACK_KEYWORDS) do
        if string.find(name, kw) then return true end
    end
    if track.Priority == Enum.AnimationPriority.Action then return true end
    return false
end

function StopPlayerAnimations()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChild("Animator")
    if not animator then return end
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
        if not isAttackAnim(track) then
            track:Stop(0)
        end
    end
end

-- ============================================================
-- SUPER JUMP (DIRECTO, SIN TOCAR JUMPPOWER NATURAL)
-- ============================================================
function doSuperJump()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    
    StopPlayerAnimations()
    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, SuperJumpPower, hrp.AssemblyLinearVelocity.Z)
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    if SuperJumpWidget then
        SuperJumpWidget.Visible = true
    end
end

-- ============================================================
-- SOUL GUITAR GLITCH
-- ============================================================
function executeSoulGuitarJump()
    if soulGuitarBusy then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local tool = char:FindFirstChild("Skull Guitar") or player.Backpack:FindFirstChild("Skull Guitar")
    if not tool then return end

    soulGuitarBusy = true

    if tool.Parent == player.Backpack then
        hum:EquipTool(tool)
        task.wait(0.15)
    end

    pcall(function()
        local equipEvent = tool:FindFirstChild("EquipEvent")
        if equipEvent then equipEvent:FireServer(true) end

        local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
        if remotesFolder then
            local validator = remotesFolder:FindFirstChild("Validator2")
            if validator then validator:FireServer(15627583, 1) end
        end

        local remoteEvent = tool:FindFirstChild("RemoteEvent")
        if remoteEvent then
            remoteEvent:FireServer("TAP", mouse.Hit.Position)
        end
    end)

    StopPlayerAnimations()
    local lookVector = hrp.CFrame.LookVector
    local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z)
    if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
    
    local soulAtt = Instance.new("Attachment")
    soulAtt.Parent = hrp
    local soulLV = Instance.new("LinearVelocity")
    soulLV.MaxForce = math.huge
    soulLV.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    soulLV.VectorVelocity = Vector3.new(flatLook.X * 180, 80, flatLook.Z * 180)
    soulLV.Attachment0 = soulAtt
    soulLV.Parent = hrp
    
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    
    task.delay(0.7, function()
        if soulLV and soulLV.Parent then soulLV:Destroy() end
        if soulAtt and soulAtt.Parent then soulAtt:Destroy() end
    end)

    local tempNoAnimConn
    tempNoAnimConn = RunService.Stepped:Connect(function()
        if not char or not char.Parent or not hum or not hum.Parent then
            if tempNoAnimConn then tempNoAnimConn:Disconnect() end
            return
        end
        hum.AutoRotate = true -- FIX BUG DE LADO
        local animator = hum:FindFirstChild("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                if not isAttackAnim(track) then
                    track:Stop(0)
                end
            end
        end
        if hum.FloorMaterial ~= Enum.Material.Air then
            if tempNoAnimConn then tempNoAnimConn:Disconnect() end
        end
    end)
    
    task.wait(0.6) 
    soulGuitarBusy = false
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and SoulGuitarJumpEnabled then
        executeSoulGuitarJump()
    end
end)

-- ============================================================
-- PORTAL COMBOS (XZ & SANGUINE C AUTO-EQUIP)
-- ============================================================
PortalSanguineCEnabled = false
PortalSanguineCTriggerMode = "PortalF" -- "PortalF" o "Soru"

function isHoldingPortalFruit()
    local char = player.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local tName = string.lower(tool.Name)
        if string.find(tName, "portal") or string.find(tName, "door") then return true end
    end
    return false
end

function equipSanguineArt()
    local char = player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    
    local tool = char:FindFirstChild("Sanguine Art") or char:FindFirstChild("Sanguine")
    if not tool then
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                local name = string.lower(t.Name)
                if string.find(name, "sanguine") then
                    hum:EquipTool(t)
                    tool = t
                    task.wait(0.1)
                    break
                end
            end
        end
    end
    return tool
end

function equipPortalFruit()
    local char = player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    
    local tool = char:FindFirstChild("Portal-Portal") or char:FindFirstChild("Portal Fruit") or char:FindFirstChild("Portal") or char:FindFirstChild("Door")
    if not tool then
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                local name = string.lower(t.Name)
                if string.find(name, "portal") or string.find(name, "door") then
                    hum:EquipTool(t)
                    tool = t
                    task.wait(0.1)
                    break
                end
            end
        end
    end
    return tool
end

function doPortalCombo()
    if not isHoldingPortalFruit() then
        equipPortalFruit()
        task.wait(0.08)
    end
    if not isHoldingPortalFruit() then return end

    local function pressKey(kc)
        VirtualInputManager:SendKeyEvent(true, kc, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, kc, false, game)
    end
    pressKey(Enum.KeyCode.X)
    task.wait(0.15)
    pressKey(Enum.KeyCode.Z)
end

function doPortalSanguineCCombo()
    task.wait(0.25)
    equipSanguineArt()
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game)
    task.wait(0.15)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
end

FLASH_NAMES = {"FlashStepRegular","FlashStepDraco","FlashStep","Flashstep","Soru"}
FLASH_IDS = {"17555632156","18461649274","616006778","616010882","5403485593","5403491911"}

function isFlashstep(track)
    for _,n in ipairs(FLASH_NAMES) do
        if string.find(string.lower(track.Name), string.lower(n)) then return true end
    end
    local id = track.Animation and track.Animation.AnimationId:match("%d+") or ""
    for _,fid in ipairs(FLASH_IDS) do
        if id == fid then return true end
    end
    return false
end

function monitorCharPortal(char)
    local h = char:WaitForChild("Humanoid", 5) 
    if not h then return end
    h.AnimationPlayed:Connect(function(track)
        local animName = string.lower(track.Name)
        local animId = tostring(track.Animation and track.Animation.AnimationId or "")
        
        local isPortalF = string.find(animName, "portal") or string.find(animName, "teleport") or string.find(animName, "warp") or string.find(animName, "door") or string.find(animName, "world")
        local isSoru = isFlashstep(track)

        -- Portal Soru Combo (XZ)
        if PortalSoruEnabled and isSoru then
            task.spawn(doPortalCombo)
        end
        
        -- Portal Sanguine C Combo via Animation
        if PortalSanguineCEnabled then
            if (PortalSanguineCTriggerMode == "PortalF" and isPortalF) or (PortalSanguineCTriggerMode == "Soru" and isSoru) then
                task.spawn(doPortalSanguineCCombo)
            end
        end
    end)
end

-- Listener directo de teclado/pantalla para la tecla F (Portal F skill)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        if PortalSanguineCEnabled and PortalSanguineCTriggerMode == "PortalF" then
            if isHoldingPortalFruit() then
                task.spawn(doPortalSanguineCCombo)
            end
        end
    end
end)

player.CharacterAdded:Connect(monitorCharPortal)
if player.Character then monitorCharPortal(player.Character) end

-- ============================================================
-- ANTI LAVA (Extraído de tu script)
-- ============================================================
antiLavaActive = false
antiLavaConnection = nil

function startAntiLava()
    if antiLavaConnection then antiLavaConnection:Disconnect() end
    local antiLavaTimer = 0
    antiLavaConnection = RunService.Stepped:Connect(function(_, dt)
        antiLavaTimer = antiLavaTimer + dt
        if antiLavaTimer < 0.2 then return end
        antiLavaTimer = 0
        local char = player.Character
        if not (char and antiLavaActive) then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart"
            and part.Name ~= "Torso" and part.Name ~= "UpperTorso"
            and part.Name ~= "LowerTorso" and part.Name ~= "Head" then
                part.CanTouch = false
            end
        end
    end)
end

function stopAntiLava()
    if antiLavaConnection then antiLavaConnection:Disconnect(); antiLavaConnection = nil end
end

-- ============================================================
-- DELETE GHOST SHIP (Extraído de tu script)
-- ============================================================
deleteShipActive = false
deleteShipRunning = false

function deleteShipStructure()
    if not deleteShipActive then return end
    task.spawn(function()
        local shipNames = {"CursedShip","Cursed Ship","Ship"}
        local exteriorNames = {"Wall","Floor","Ceiling","Base","Hull","Window","DoorFrame"}
        for _, obj in pairs(workspace:GetDescendants()) do
            for _, sName in pairs(shipNames) do
                if obj.Name:find(sName) and (obj:IsA("Model") or obj:IsA("Folder")) then
                    for _, child in pairs(obj:GetDescendants()) do
                        if child:IsA("BasePart") and not child.Parent:FindFirstChild("Humanoid") then
                            local isExterior = false
                            for _, ext in pairs(exteriorNames) do
                                if child.Name:find(ext) then isExterior = true; break end
                            end
                            if not isExterior then child:Destroy() end
                        end
                    end
                end
            end
        end
    end)
end

function startDeleteShipLoop()
    if deleteShipRunning then return end
    deleteShipRunning = true
    task.spawn(function()
        while deleteShipActive do
            deleteShipStructure()
            task.wait(3)
        end
        deleteShipRunning = false
    end)
end

-- ============================================================
-- WALK ON WATER
-- ============================================================
WalkOnWaterEnabled = false

spawn(function()
    local waterPart = nil
    local function getWaterPart()
        if not waterPart or not waterPart.Parent then
            waterPart = Instance.new("Part")
            waterPart.Size = Vector3.new(200, 1, 200)
            waterPart.Transparency = 1
            waterPart.Anchored = true
            waterPart.CanCollide = false
            waterPart.Name = "SacredWaterPlatform"
            waterPart.Parent = workspace
        end
        return waterPart
    end
    while true do
        wait(0.15)
        if WalkOnWaterEnabled then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local wp = getWaterPart()
            if hrp and hrp.Position.Y >= 9.5 then
                wp.Position = Vector3.new(hrp.Position.X, 9.2, hrp.Position.Z)
                wp.CanCollide = true
            else
                wp.CanCollide = false
            end
        elseif waterPart and waterPart.Parent then
            waterPart.CanCollide = false
        end
    end
end)

-- ============================================================
-- SMART AUTO V4
-- ============================================================
SmartAutoV4Enabled = false

spawn(function()
    while true do
        wait(1)
        if SmartAutoV4Enabled then
            pcall(function()
                local char = player.Character
                if char and char:GetAttribute("RaceEnergy") and char:GetAttribute("RaceEnergy") >= 100 then
                    local awakening = player.Backpack:FindFirstChild("Awakening")
                    if awakening and awakening:FindFirstChild("RemoteFunction") then
                        awakening.RemoteFunction:InvokeServer(true)
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- NUEVO ESP DE ALTO RENDIMIENTO (FRUTA, BOUNTY, LEVEL, PVP, HP, HIGHLIGHT)
-- ============================================================
_G.G_ESPEnabled       = false
_G.G_ESP_Name         = true
_G.G_ESP_Level        = true
_G.G_ESP_Bounty       = true
_G.G_ESP_Fruit        = true
_G.G_ESP_Distance     = true
_G.G_ESP_HP           = true
_G.G_ESP_TextSize     = 12
_G.G_ESP_Highlight    = false
_G.G_ESP_HighlightColor = "FF0000"

local ESPRunning = false
local espObjects = {}
local lastESPUpdate = 0
local ESP_UPDATE_INTERVAL = 0.1
local playerCache = {}

function getTeamInfo(targetP)
    if not targetP or not targetP.Team then
        return "Unknown", Color3.fromRGB(255,255,255)
    end
    if targetP.Team.Name == "Marines" then
        return "Marines", Color3.fromRGB(0,170,255)
    else
        return "Pirates", Color3.fromRGB(255,70,70)
    end
end

function hexToColor3(hex)
    local r = tonumber(hex:sub(1,2), 16) / 255 or 0
    local g = tonumber(hex:sub(3,4), 16) / 255 or 1
    local b = tonumber(hex:sub(5,6), 16) / 255 or 0
    return Color3.new(r, g, b)
end

function removeESP(targetP)
    if espObjects[targetP] then
        pcall(function()
            if espObjects[targetP].gui then espObjects[targetP].gui:Destroy() end
            if espObjects[targetP].highlight then espObjects[targetP].highlight:Destroy() end
        end)
        espObjects[targetP] = nil
    end
end

function createESP(targetP)
    if not targetP or targetP == player then return end
    if targetP:GetAttribute("IsAuthor") or 
       targetP.Name == "Mas_Yes" or 
       targetP.Name == "sjqgduf" or 
       targetP.Name == "huha123444" or 
       targetP.Name == "ksxrcm111" or
       targetP.Name == "Dddyy5" then 
        return 
    end
    local char = targetP.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local team, color = getTeamInfo(targetP)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SacredESP_Billboard"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 75)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextScaled = false
    text.TextSize = _G.G_ESP_TextSize or 12
    text.RichText = true
    text.Font = Enum.Font.SourceSansBold
    text.TextStrokeTransparency = 0
    text.TextColor3 = color
    text.Parent = billboard

    local highlight = nil
    if _G.G_ESP_Highlight then
        local hlColor = hexToColor3(_G.G_ESP_HighlightColor or "FF0000")
        highlight = Instance.new("Highlight")
        highlight.Name = "ESP_PlayerHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = hlColor
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = hlColor
        highlight.OutlineTransparency = 0
        highlight.Parent = char
    end

    espObjects[targetP] = {
        gui = billboard,
        label = text,
        char = char,
        highlight = highlight
    }
end

function getPlayerData(targetP)
    if not playerCache[targetP] then
        playerCache[targetP] = {
            level = "?",
            fruit = "None",
            bounty = 0,
            team = "Unknown",
            color = Color3.fromRGB(255, 255, 255),
            lastUpdate = 0
        }
    end
    local data = playerCache[targetP]
    local now = tick()
    if now - data.lastUpdate > 5 then
        pcall(function() data.level = targetP.Data.Level.Value end)
        pcall(function() data.fruit = targetP.Data.DevilFruit.Value end)
        pcall(function() data.bounty = targetP.leaderstats["Bounty/Honor"].Value end)
        data.team, data.color = getTeamInfo(targetP)
        data.lastUpdate = now
    end
    return data
end

function updateESP()
    if not _G.G_ESPEnabled then
        DisableESP()
        return
    end
    local anySubActive = _G.G_ESP_Name or _G.G_ESP_Level or _G.G_ESP_Bounty or _G.G_ESP_Fruit or _G.G_ESP_Distance or _G.G_ESP_HP or _G.G_ESP_Highlight
    if not anySubActive then
        DisableESP()
        return
    end

    local now = tick()
    if now - lastESPUpdate < ESP_UPDATE_INTERVAL then return end
    lastESPUpdate = now

    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos = myRoot.Position

    for _, targetP in ipairs(Players:GetPlayers()) do
        if targetP ~= player then
            local isSpecial = targetP:GetAttribute("IsAuthor") or 
               targetP.Name == "Mas_Yes" or 
               targetP.Name == "sjqgdu6" or 
               targetP.Name == "huha124444" or 
               targetP.Name == "ksxrcn111" or
               targetP.Name == "Dddyy5"

            if isSpecial then
                if espObjects[targetP] then removeESP(targetP) end
            else
                local char = targetP.Character
                local head = char and char:FindFirstChild("Head")
                local data = espObjects[targetP]
                if char and head then
                    if not data or data.char ~= char or not data.gui.Parent then
                        removeESP(targetP)
                        createESP(targetP)
                        data = espObjects[targetP]
                    end

                    if data then
                        local hum = char:FindFirstChild("Humanoid")
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if hum and root then
                            local distance = math.floor((root.Position - myPos).Magnitude)
                            local hp = math.floor((hum.Health / math.max(hum.MaxHealth, 1)) * 100)
                            local pData = getPlayerData(targetP)
                            local level = pData.level
                            local fruit = pData.fruit
                            local bounty = pData.bounty
                            local team = pData.team
                            local color = pData.color

                            local warnTag = ""
                            if type(bounty) == "number" and bounty > 10000000 then
                                warnTag = "⚠ "
                            end
                            local pvpState = "PVP Enabled "
                            local pvpIcon = "🔴 "
                            local isPvpDisabled = false
                            if targetP:GetAttribute("PvpDisabled") == true then
                                pvpState = "PvP Disabled "
                                pvpIcon = "🟢 "
                                isPvpDisabled = true
                            end

                            data.label.TextColor3 = color
                            if data.label.TextSize ~= _G.G_ESP_TextSize then
                                data.label.TextSize = _G.G_ESP_TextSize or 12
                            end

                            local parts = {}
                            if _G.G_ESP_Name then parts[#parts+1] = warnTag .. "[" .. team .. "] <font color=\"rgb(255,255,0)\">" .. targetP.Name .. "</font>" end
                            if _G.G_ESP_Level then parts[#parts+1] = " [Lv." .. level .. "]" end
                            if _G.G_ESP_Bounty then 
                                local bM = type(bounty) == "number" and math.floor(bounty / 1000000) or 0
                                if isPvpDisabled then
                                    parts[#parts+1] = "\n<font color=\"rgb(0,255,0)\">" .. pvpIcon .. pvpState .. "</font> | Bounty: " .. bM .. "M\n"
                                else
                                    parts[#parts+1] = "\n" .. pvpIcon .. pvpState .. "| Bounty: " .. bM .. "M\n"
                                end
                            end
                            if _G.G_ESP_Fruit then parts[#parts+1] = "Fruit: " .. tostring(fruit) .. "\n" end
                            if _G.G_ESP_Distance then parts[#parts+1] = distance .. "m | " end
                            if _G.G_ESP_HP then parts[#parts+1] = "HP " .. hp .. "%" end
                            data.label.Text = table.concat(parts)

                            if _G.G_ESP_Highlight then
                                local hlColor = hexToColor3(_G.G_ESP_HighlightColor or "FF0000")
                                pcall(function()
                                    for _, child in ipairs(char:GetChildren()) do
                                        if child:IsA("Highlight") and child.Name ~= "ESP_PlayerHighlight" then
                                            child.FillColor = hlColor
                                            child.OutlineColor = hlColor
                                            child.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                        end
                                    end
                                end)
                                if not data.highlight or not data.highlight.Parent then
                                    local hl = Instance.new("Highlight")
                                    hl.Name = "ESP_PlayerHighlight"
                                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    hl.FillColor = hlColor
                                    hl.FillTransparency = 0.5
                                    hl.OutlineColor = hlColor
                                    hl.OutlineTransparency = 0
                                    hl.Parent = char
                                    data.highlight = hl
                                else
                                    data.highlight.FillColor = hlColor
                                    data.highlight.OutlineColor = hlColor
                                    data.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                end
                            else
                                if data.highlight then
                                    data.highlight:Destroy()
                                    data.highlight = nil
                                end
                            end
                        end
                    end
                else
                    if data then removeESP(targetP) end
                end
            end
        end
    end
end

function EnableESP()
    if ESPRunning then return end
    ESPRunning = true
    for _, targetP in ipairs(Players:GetPlayers()) do
        createESP(targetP)
    end
    task.spawn(function()
        while ESPRunning do
            pcall(updateESP)
            task.wait(ESP_UPDATE_INTERVAL)
        end
    end)
end

function DisableESP()
    ESPRunning = false
    for targetP, _ in pairs(espObjects) do
        removeESP(targetP)
    end
    espObjects = {}
end
ClearESP = DisableESP

if not _G.ESP_Initialized then
    _G.ESP_Initialized = true
    Players.PlayerRemoving:Connect(function(targetP)
        removeESP(targetP)
        playerCache[targetP] = nil
    end)
end

-- ============================================================
-- SORU INFINITO
-- ============================================================
function enforceSoru(char)
    if not char then return end
    if SoruInfinitoEnabled then char:SetAttribute("FlashstepCooldown", 1) end
    char.AttributeChanged:Connect(function(attr)
        if attr == "FlashstepCooldown" and SoruInfinitoEnabled and char:GetAttribute("FlashstepCooldown") ~= 1 then
            char:SetAttribute("FlashstepCooldown", 1)
        end
    end)
end

player.CharacterAdded:Connect(enforceSoru)
if player.Character then enforceSoru(player.Character) end

spawn(function()
    while true do
        wait(0.5)
        if SoruInfinitoEnabled and player.Character then
            pcall(function() player.Character:SetAttribute("FlashstepCooldown", 1) end)
        end
    end
end)

-- ============================================================
-- NO ANIMATIONS (FIX BUG DE LADO)
-- ============================================================
NoAnimEnabled = false
NoAnimConnection = nil

function StartNoAnimLoop()
    if NoAnimConnection then NoAnimConnection:Disconnect() end
    NoAnimConnection = RunService.Stepped:Connect(function()
        if not NoAnimEnabled then return end
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum then return end
        hum.AutoRotate = true 
        local animator = hum:FindFirstChild("Animator")
        if not animator then return end
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            if not isAttackAnim(track) then
                track:Stop(0)
            end
        end
    end)
end

-- ============================================================
-- SANGUINE Z AUTO
-- ============================================================
sanguineLagBusy = false
function dropFPS(duration)
    if sanguineLagBusy then return end
    sanguineLagBusy = true
    local DROP_TO_FPS = 20
    local stop = tick() + duration
    local interval = 1 / DROP_TO_FPS
    local con
    con = RunService.RenderStepped:Connect(function()
        if tick() > stop then
            if con then con:Disconnect() end
            sanguineLagBusy = false
            return
        end
        local now = tick()
        while tick() - now < interval do end
    end)
end

function dropFPSManual()
    if sanguineLagBusy then return end
    sanguineLagBusy = true
    local DROP_TO_FPS = 20
    local LAG_DURATION = 0.43
    local stop = tick() + LAG_DURATION
    local interval = 1 / DROP_TO_FPS
    local con
    con = RunService.RenderStepped:Connect(function()
        if tick() > stop then
            if con then con:Disconnect() end
            return
        end
        local now = tick()
        while tick() - now < interval do end
    end)
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dir = camera.CFrame.LookVector
            local att = Instance.new("Attachment")
            att.Parent = hrp
            local lv = Instance.new("LinearVelocity")
            lv.MaxForce = math.huge
            lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
            lv.VectorVelocity = dir * 400
            lv.Attachment0 = att
            lv.Parent = hrp
            task.delay(0.9, function()
                if lv and lv.Parent then lv:Destroy() end
                if att and att.Parent then att:Destroy() end
            end)
        end
    end
    task.wait(0.10)
    sanguineLagBusy = false
end

function startSanguineAutoWatcher()
    if SanguineAutoConnection then SanguineAutoConnection:Disconnect() end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    SanguineAutoConnection = hum.AnimationPlayed:Connect(function(animTrack)
        if not SanguineAutoEnabled or SanguineAutoCooldown then return end
        
        -- Verificar que el usuario tenga Sanguine Art en mano
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool or not (string.find(string.lower(tool.Name), "sanguine") or string.find(string.lower(tool.Name), "art")) then
            return
        end

        local animId = tostring(animTrack.Animation and animTrack.Animation.AnimationId or "")
        -- Solamente se activa con la habilidad Z de Sanguine
        if animId:find("14586872029") or animId:find("14418367908") or animId:find("14418370048") then
            SanguineAutoCooldown = true
            dropFPS(SanguineAutoDropDuration)
            local char2 = player.Character
            if char2 then
                local hrp2 = char2:FindFirstChild("HumanoidRootPart")
                if hrp2 then
                    local dir2 = camera.CFrame.LookVector
                    local att2 = Instance.new("Attachment")
                    att2.Parent = hrp2
                    local lv2 = Instance.new("LinearVelocity")
                    lv2.MaxForce = math.huge
                    lv2.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
                    lv2.VectorVelocity = dir2 * 400
                    lv2.Attachment0 = att2
                    lv2.Parent = hrp2
                    task.delay(0.9, function()
                        if lv2 and lv2.Parent then lv2:Destroy() end
                        if att2 and att2.Parent then att2:Destroy() end
                    end)
                end
            end
            task.delay(SanguineAutoDropDuration + 0.5, function()
                SanguineAutoCooldown = false
            end)
        end
    end)
end

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if SanguineAutoEnabled then
        startSanguineAutoWatcher()
    end
end)

-- ============================================================
-- TARGET HELPERS
-- ============================================================
function getClosestPlayer(overrideMaxDist)
    local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end

    local searchDist = overrideMaxDist or soruMaxDist or 3500

    -- Si hay un objetivo fijo seleccionado en el Selector de Aimlock
    if AimlockTargetPlayer ~= "Nearest" and AimlockTargetPlayer ~= nil then
        local targetP = Players:FindFirstChild(AimlockTargetPlayer)
        if targetP and targetP.Character and targetP.Character:FindFirstChild("HumanoidRootPart") then
            local hum = targetP.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then return targetP.Character end
        end
    end

    local closest, closestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and not BlacklistedPlayers[p.Name] and p:GetAttribute("PvpDisabled") ~= true and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local dist = (p.Character.HumanoidRootPart.Position - myHrp.Position).Magnitude
                if dist < closestDist and dist <= searchDist then
                    closestDist = dist
                    closest = p.Character
                end
            end
        end
    end
    return closest
end

function getClosestNPC()
    local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    local container = workspace:FindFirstChild("Enemies") or workspace
    local closest, closestDist = nil, math.huge
    for _, npc in pairs(container:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(npc) then
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local dist = (npc.HumanoidRootPart.Position - myHrp.Position).Magnitude
                if dist < closestDist and dist < maxRange then
                    closestDist = dist
                    closest = npc
                end
            end
        end
    end
    return closest
end

-- ============================================================
-- AIMLOCK PLAYER & NPC SUAVE Y PRECISO (SMOOTH AIMLOCK)
-- ============================================================
_G.lockedPlayerTarget = nil
_G.lockedNpcTarget = nil

RunService.RenderStepped:Connect(function()
    -- AIMLOCK PLAYER SUAVE Y CONTINUO
    if PlayerWidgetActive and AimlockPlayerEnabled then
        if not _G.lockedPlayerTarget or not _G.lockedPlayerTarget:FindFirstChild("HumanoidRootPart") then
            _G.lockedPlayerTarget = getClosestPlayer()
        end
        local targetChar = _G.lockedPlayerTarget
        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            local hum = targetChar:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local targetPos = targetChar.HumanoidRootPart.Position + Vector3.new(0, 0.5, 0)
                camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, targetPos), 0.4)
            else
                _G.lockedPlayerTarget = nil
            end
        else
            _G.lockedPlayerTarget = nil
        end
    else
        _G.lockedPlayerTarget = nil
    end

    -- AIMLOCK NPC SUAVE Y CONTINUO
    if NpcWidgetActive and AimlockNpcEnabled then
        if not _G.lockedNpcTarget or not _G.lockedNpcTarget:FindFirstChild("HumanoidRootPart") then
            _G.lockedNpcTarget = getClosestNPC()
        end
        local targetNPC = _G.lockedNpcTarget
        if targetNPC and targetNPC:FindFirstChild("HumanoidRootPart") then
            local hum = targetNPC:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local targetPos = targetNPC.HumanoidRootPart.Position + Vector3.new(0, 0.5, 0)
                camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, targetPos), 0.4)
            else
                _G.lockedNpcTarget = nil
            end
        else
            _G.lockedNpcTarget = nil
        end
    else
        _G.lockedNpcTarget = nil
    end
end)

-- ============================================================
-- VISUALS & EFFECTS
-- ============================================================
function applyFakeKorblox(char)
    if not char then return end
    pcall(function()
        local rUpper = char:FindFirstChild("RightUpperLeg")
        local rLower = char:FindFirstChild("RightLowerLeg")
        local rFoot = char:FindFirstChild("RightFoot")
        if rUpper and rUpper:IsA("BasePart") then rUpper.Transparency = 1 end
        if rLower and rLower:IsA("BasePart") then rLower.Transparency = 1 end
        if rFoot and rFoot:IsA("BasePart") then rFoot.Transparency = 1 end
    end)
end

function removeFakeKorblox(char)
    if not char then return end
    pcall(function()
        local rUpper = char:FindFirstChild("RightUpperLeg")
        local rLower = char:FindFirstChild("RightLowerLeg")
        local rFoot = char:FindFirstChild("RightFoot")
        if rUpper and rUpper:IsA("BasePart") then rUpper.Transparency = 0 end
        if rLower and rLower:IsA("BasePart") then rLower.Transparency = 0 end
        if rFoot and rFoot:IsA("BasePart") then rFoot.Transparency = 0 end
    end)
end

function applyFakeHeadless(char)
    if not char then return end
    pcall(function()
        local head = char:FindFirstChild("Head")
        if head then
            head.Transparency = 1
            for _, child in pairs(head:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") then child.Transparency = 1 end
            end
        end
        -- Ocultar TODOS los accesorios conectados a la cabeza (Sombreros, cabellos, gafas, mascaras, etc)
        for _, acc in pairs(char:GetChildren()) do
            if acc:IsA("Accessory") then
                local handle = acc:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    local isHeadAcc = false
                    -- Buscar si tiene un attachment de cabeza o esta unido a la cabeza
                    for _, child in pairs(handle:GetChildren()) do
                        if child:IsA("Attachment") then
                            local aName = string.lower(child.Name)
                            if string.find(aName, "hat") or string.find(aName, "hair") or string.find(aName, "face") or string.find(aName, "head") then
                                isHeadAcc = true
                                break
                            end
                        end
                    end
                    if not isHeadAcc then
                        for _, weld in pairs(handle:GetChildren()) do
                            if weld:IsA("Weld") or weld:IsA("Motor6D") or weld:IsA("WeldConstraint") then
                                if weld.Part0 == head or weld.Part1 == head then
                                    isHeadAcc = true
                                    break
                                end
                            end
                        end
                    end
                    -- Si es accesorio de cabeza o tipo sombrero/pelo/cara/desconocido
                    if isHeadAcc or acc.AccessoryType == Enum.AccessoryType.Hat or acc.AccessoryType == Enum.AccessoryType.Hair or acc.AccessoryType == Enum.AccessoryType.Face or acc.AccessoryType == Enum.AccessoryType.Unknown then
                        handle.Transparency = 1
                        for _, sub in pairs(handle:GetDescendants()) do
                            if sub:IsA("BasePart") or sub:IsA("MeshPart") or sub:IsA("Decal") or sub:IsA("Texture") then
                                sub.Transparency = 1
                            end
                        end
                    end
                end
            end
        end
    end)
end

function removeFakeHeadless(char)
    if not char then return end
    pcall(function()
        local head = char:FindFirstChild("Head")
        if head then
            head.Transparency = 0
            for _, child in pairs(head:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") then child.Transparency = 0 end
            end
        end
        for _, acc in pairs(char:GetChildren()) do
            if acc:IsA("Accessory") then
                local handle = acc:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    handle.Transparency = 0
                    for _, sub in pairs(handle:GetDescendants()) do
                        if sub:IsA("BasePart") or sub:IsA("MeshPart") or sub:IsA("Decal") or sub:IsA("Texture") then
                            sub.Transparency = 0
                        end
                    end
                end
            end
        end
    end)
end

AURA_DEFS = {
    Inferno = {
        Color = ColorSequence.new(Color3.fromRGB(255, 80, 0), Color3.fromRGB(255, 0, 0)),
        LightColor = Color3.fromRGB(255, 80, 0),
        Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.5, 2.5), NumberSequenceKeypoint.new(1, 0)}),
        Rate = 80,
        Speed = NumberRange.new(3, 8),
        Lifetime = NumberRange.new(0.5, 1.2),
        SpreadAngle = Vector2.new(25, 25),
        LightEmission = 1,
        RotSpeed = NumberRange.new(-90, 90),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)}),
    },
    Electric = {
        Color = ColorSequence.new(Color3.fromRGB(0, 170, 255), Color3.fromRGB(100, 200, 255)),
        LightColor = Color3.fromRGB(0, 170, 255),
        Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.3, 1.8), NumberSequenceKeypoint.new(1, 0)}),
        Rate = 100,
        Speed = NumberRange.new(5, 15),
        Lifetime = NumberRange.new(0.2, 0.5),
        SpreadAngle = Vector2.new(180, 180),
        LightEmission = 1,
        RotSpeed = NumberRange.new(-360, 360),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)}),
    },
    DarkSpirit = {
        Color = ColorSequence.new(Color3.fromRGB(100, 0, 180), Color3.fromRGB(50, 0, 100)),
        LightColor = Color3.fromRGB(100, 0, 180),
        Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 3), NumberSequenceKeypoint.new(1, 0)}),
        Rate = 40,
        Speed = NumberRange.new(1, 3),
        Lifetime = NumberRange.new(1, 2.5),
        SpreadAngle = Vector2.new(40, 40),
        LightEmission = 0.6,
        RotSpeed = NumberRange.new(-45, 45),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1)}),
    },
    Toxic = {
        Color = ColorSequence.new(Color3.fromRGB(0, 255, 80), Color3.fromRGB(80, 255, 0)),
        LightColor = Color3.fromRGB(0, 255, 80),
        Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.5, 2), NumberSequenceKeypoint.new(1, 0)}),
        Rate = 60,
        Speed = NumberRange.new(2, 5),
        Lifetime = NumberRange.new(0.8, 1.5),
        SpreadAngle = Vector2.new(30, 30),
        LightEmission = 0.8,
        RotSpeed = NumberRange.new(-60, 60),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)}),
    },
    Frost = {
        Color = ColorSequence.new(Color3.fromRGB(200, 230, 255), Color3.fromRGB(150, 200, 255)),
        LightColor = Color3.fromRGB(180, 220, 255),
        Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.5, 1.5), NumberSequenceKeypoint.new(1, 0)}),
        Rate = 50,
        Speed = NumberRange.new(1, 3),
        Lifetime = NumberRange.new(1, 2),
        SpreadAngle = Vector2.new(50, 50),
        LightEmission = 0.7,
        RotSpeed = NumberRange.new(-30, 30),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)}),
    },
}

function ClearAura()
    for _, obj in pairs(AuraObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    AuraObjects = {}
end

function ApplyAura(auraName)
    ClearAura()
    if not auraName then ActiveAura = nil; return end
    local def = AURA_DEFS[auraName]
    if not def then ActiveAura = nil; return end
    ActiveAura = auraName
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function()
        local emitter = Instance.new("ParticleEmitter")
        emitter.Name = "SacredAura"
        emitter.Texture = "rbxassetid://243098098"
        emitter.Color = def.Color
        emitter.Size = def.Size
        emitter.Rate = def.Rate
        emitter.Speed = def.Speed
        emitter.Lifetime = def.Lifetime
        emitter.SpreadAngle = def.SpreadAngle
        emitter.LightEmission = def.LightEmission
        emitter.RotSpeed = def.RotSpeed
        emitter.Transparency = def.Transparency
        emitter.Parent = hrp
        table.insert(AuraObjects, emitter)
        local light = Instance.new("PointLight")
        light.Name = "SacredAuraLight"
        light.Color = def.LightColor
        light.Brightness = 2
        light.Range = 15
        light.Parent = hrp
        table.insert(AuraObjects, light)
    end)
end

player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if FakeKorbloxEnabled then applyFakeKorblox(char) end
    if FakeHeadlessEnabled then applyFakeHeadless(char) end
    if ActiveAura then ApplyAura(ActiveAura) end
end)

-- ============================================================
-- FPS / PING MONITORING
-- ============================================================
spawn(function()
    local frameCount = 0
    local lastTime = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
    end)
    while true do
        wait(1)
        local now = tick()
        local elapsed = now - lastTime
        currentFPS = math.floor(frameCount / elapsed)
        frameCount = 0
        lastTime = now
        pcall(function()
            currentPing = math.floor(player:GetNetworkPing() * 1000)
        end)
    end
end)



function performExtendedSoru(targetPos)
    if not targetPos then return end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local currentPos = hrp.Position
    local fullDist = (targetPos - currentPos).Magnitude

    if fullDist <= 950 then
        pcall(function()
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                commF:InvokeServer("Flashstep", targetPos)
            else
                hrp.CFrame = CFrame.new(targetPos)
            end
        end)
    else
        local steps = math.ceil(fullDist / 900)
        local dir = (targetPos - currentPos).Unit
        for i = 1, steps do
            local nextDist = math.min(i * 900, fullDist)
            local nextPos = currentPos + (dir * nextDist)
            pcall(function()
                local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                if commF then
                    commF:InvokeServer("Flashstep", nextPos)
                else
                    hrp.CFrame = CFrame.new(nextPos)
                end
            end)
            task.wait(0.015)
        end
    end
end

-- ==========================================-- ============================================================
-- METAMETHODS (Silent Aim + Soru Aimbot) - PATRÓN AHK MOBILE
-- ============================================================
local oldIndex = nil
local oldNamecall = nil

if hookmetamethod then
    pcall(function()
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if not checkcaller() then
                if self == mouse and (key == "Hit" or key == "Target") then
                    if SoruAimbotEnabled then
                        local targetName = SelectedSoruTarget
                        if targetName == "Nearest" then
                            local cl = getClosestPlayer(soruMaxDist)
                            local p  = cl and Players:GetPlayerFromCharacter(cl)
                            targetName = p and p.Name or nil
                        end
                        if targetName then
                            local tObj = Players:FindFirstChild(targetName)
                            local eHRP = tObj and tObj.Character and tObj.Character:FindFirstChild("HumanoidRootPart")
                            if eHRP then
                                local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if myHRP and (myHRP.Position - eHRP.Position).Magnitude <= (soruMaxDist or 3500) then
                                    if key == "Hit"    then return CFrame.new(eHRP.Position) end
                                    if key == "Target" then return eHRP end
                                end
                            end
                        end
                    end

                    if _G.G_SilentAimSkill and currentSilentAimTarget and IsCurrentToolAimbotAllowed() and IsCurrentSlotAimbotAllowed() then
                        if key == "Hit"    then return CFrame.new(currentSilentAimTarget.Position) end
                        if key == "Target" then return currentSilentAimTarget end
                    end
                end
            end
            return oldIndex(self, key)
        end))
    end)

    pcall(function()
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local args = {...}
            local ncm = getnamecallmethod and getnamecallmethod()
            local method = ncm and tostring(ncm):lower() or ""

            if not checkcaller() then
                if (method == "fireserver" or method == "invokeserver") then
                    local calledSkill = nil
                    for _, arg in ipairs(args) do
                        if typeof(arg) == "string" then
                            local sUpper = string.upper(arg)
                            if sUpper == "Z" or sUpper == "X" or sUpper == "C" or sUpper == "V" or sUpper == "F" then
                                calledSkill = sUpper
                                break
                            end
                        end
                    end

                    if _G.G_SilentAimSkill and currentSilentAimTarget and IsCurrentToolAimbotAllowed() and IsCurrentSlotAimbotAllowed(calledSkill) then
                        local activePos = currentSilentAimTarget.Position

                        if self.Name == "RE/RegisterHit" or self.Name == "RegisterHit" or self.Name:find("RegisterHit") then
                            local targetChar = currentSilentAimTarget.Parent
                            local targetHead = targetChar and (targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")) or currentSilentAimTarget
                            if targetHead and targetChar then
                                args[1] = targetHead
                                args[2] = { { targetChar, targetHead } }
                                return oldNamecall(self, unpack(args))
                            end
                        end

                        if self.Name == "RE/ShootGunEvent" or self.Name == "ShootGunEvent" or self.Name:find("ShootGunEvent") then
                            args[1] = activePos
                            if currentSilentAimTarget.Parent then
                                args[2] = { currentSilentAimTarget.Parent }
                            end
                            return oldNamecall(self, unpack(args))
                        end

                        for i, arg in ipairs(args) do
                            if typeof(arg) == "Vector3" then 
                                args[i] = activePos
                            elseif typeof(arg) == "CFrame" then 
                                args[i] = CFrame.new(activePos)
                            end
                        end
                        return oldNamecall(self, unpack(args))
                    end
                elseif (method == "raycast" or method == "findpartonray" or method == "findpartonraywithignorelist" or method == "findpartonraywithwhitelist") then
                    if _G.G_SilentAimSkill and currentSilentAimTarget and IsCurrentToolAimbotAllowed() and IsCurrentSlotAimbotAllowed() then
                        if method == "raycast" then
                            return {
                                Instance = currentSilentAimTarget,
                                Position = currentSilentAimTarget.Position,
                                Hit = currentSilentAimTarget.Position,
                                Normal = Vector3.new(0, 1, 0),
                                Material = Enum.Material.SmoothPlastic
                            }
                        else
                            return currentSilentAimTarget, currentSilentAimTarget.Position, Vector3.new(0, 1, 0), Enum.Material.SmoothPlastic
                        end
                    end
                end
            end

            return oldNamecall(self, ...)
        end))
    end)
else
    pcall(function()
        local mt = getrawmetatable and getrawmetatable(game)
        if mt then
            oldIndex = mt.__index
            oldNamecall = mt.__namecall
            if setreadonly then pcall(setreadonly, mt, false) end

            mt.__index = newcclosure(function(self, key)
                if not checkcaller() and self == mouse and (key == "Hit" or key == "Target") then
                    if _G.G_SilentAimSkill and currentSilentAimTarget and IsCurrentToolAimbotAllowed() and IsCurrentSlotAimbotAllowed() then
                        if key == "Hit"    then return CFrame.new(currentSilentAimTarget.Position) end
                        if key == "Target" then return currentSilentAimTarget end
                    end
                end
                return oldIndex(self, key)
            end)

            mt.__namecall = newcclosure(function(self, ...)
                local args = {...}
                local ncm = getnamecallmethod and getnamecallmethod()
                local method = ncm and tostring(ncm):lower() or ""

                if not checkcaller() and (method == "fireserver" or method == "invokeserver") then
                    local calledSkill = nil
                    for _, arg in ipairs(args) do
                        if typeof(arg) == "string" then
                            local sUpper = string.upper(arg)
                            if sUpper == "Z" or sUpper == "X" or sUpper == "C" or sUpper == "V" or sUpper == "F" then
                                calledSkill = sUpper
                                break
                            end
                        end
                    end

                    if _G.G_SilentAimSkill and currentSilentAimTarget and IsCurrentToolAimbotAllowed() and IsCurrentSlotAimbotAllowed(calledSkill) then
                        local activePos = currentSilentAimTarget.Position

                        if self.Name == "RE/RegisterHit" or self.Name == "RegisterHit" or self.Name:find("RegisterHit") then
                            local targetChar = currentSilentAimTarget.Parent
                            local targetHead = targetChar and (targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")) or currentSilentAimTarget
                            if targetHead and targetChar then
                                args[1] = targetHead
                                args[2] = { { targetChar, targetHead } }
                                return oldNamecall(self, unpack(args))
                            end
                        end

                        if self.Name == "RE/ShootGunEvent" or self.Name == "ShootGunEvent" or self.Name:find("ShootGunEvent") then
                            args[1] = activePos
                            if currentSilentAimTarget.Parent then
                                args[2] = { currentSilentAimTarget.Parent }
                            end
                            return oldNamecall(self, unpack(args))
                        end

                        for i, arg in ipairs(args) do
                            if typeof(arg) == "Vector3" then 
                                args[i] = activePos
                            elseif typeof(arg) == "CFrame" then 
                                args[i] = CFrame.new(activePos)
                            end
                        end
                        return oldNamecall(self, unpack(args))
                    end
                end

                return oldNamecall(self, ...)
            end)
            if setreadonly then pcall(setreadonly, mt, true) end
        end
    end)
end

-- ============================================================
-- FOV CIRCLE & LOCK LINE DRAWING & SKILL AIMBOT HOOK
-- ============================================================
local FOVCircle = nil
local LockLine = nil

pcall(function()
    if Drawing and Drawing.new then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = _G.G_SilentAimShowFOV
        FOVCircle.Color = Color3.fromRGB(255, 0, 0)
        FOVCircle.Radius = _G.G_SilentAimFOV
        FOVCircle.Thickness = _G.G_SilentAimFOVThickness
        FOVCircle.Filled = false

        LockLine = Drawing.new("Line")
        LockLine.Thickness = 2
        LockLine.Color = Color3.fromRGB(255, 0, 0)
        LockLine.Transparency = 1
        LockLine.Visible = false
    end
end)

local currentSilentAimTarget = nil

function IsSilentAimAlly(p)
    local main = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Main")
    local frame = main and main:FindFirstChild("Allies")
        and main.Allies:FindFirstChild("Container")
        and main.Allies.Container:FindFirstChild("Allies")
        and main.Allies.Container.Allies:FindFirstChild("ScrollingFrame")
        and main.Allies.Container.Allies.ScrollingFrame:FindFirstChild("Frame")
    if not frame then return false end
    return frame:FindFirstChild(p.Name) ~= nil
end

function IsSilentAimEnemy(p)
    if not p or p == player then return false end
    if IsSilentAimAlly(p) then return false end
    local myTeam, targetTeam = player.Team, p.Team
    if myTeam and targetTeam and myTeam.Name == "Marines" and targetTeam.Name == "Marines" then
        return false
    end
    return true
end

function AX_ReadPvPState(target)
    local ok, on = pcall(function()
        local attr = target:GetAttribute("PvpDisabled")
        if attr ~= nil then return attr ~= true end
        local main = target.PlayerGui and target.PlayerGui:FindFirstChild("Main")
        if main then
            local dis = main:FindFirstChild("PvpDisabled")
            if dis then return not dis.Visible end
            local pvp = main:FindFirstChild("Pvp")
            if pvp then
                local frame = pvp:FindFirstChild("Frame")
                if frame then
                    local btn = frame:FindFirstChild("PvpButton") or frame:FindFirstChildOfClass("TextButton")
                    if btn and btn:IsA("TextButton") then
                        local txt = tostring(btn.Text or ""):upper()
                        if txt:find("OFF") then return false end
                        if txt:find("ON") then return true end
                    end
                end
            end
        end
        return true
    end)
    return not ok or on
end

function AX_InSafeZone(target)
    local ok, inZone = pcall(function()
        local char = target.Character
        if not char then return false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local wo = workspace:FindFirstChild("_WorldOrigin")
        if not wo then return false end

        local safeZones = wo:FindFirstChild("SafeZones")
        if safeZones then
            for _, zone in pairs(safeZones:GetChildren()) do
                local mesh = zone:FindFirstChild("Mesh")
                if mesh and mesh:IsA("SpecialMesh") then
                    local realDiameter = zone.Size.X * mesh.Scale.X
                    local radius = realDiameter / 2
                    if radius and radius > 0 then
                        local dist = (zone.Position - hrp.Position).Magnitude
                        if dist <= radius then return true end
                    end
                end
            end
        end

        local spawns = wo:FindFirstChild("PlayerSpawns")
        if spawns then
            local folder = spawns:FindFirstChild(tostring(target.Team)) or spawns:FindFirstChild("Pirates")
            if folder then
                for _, sp in pairs(folder:GetChildren()) do
                    local part = sp:FindFirstChild("Part")
                    if part and (hrp.Position - part.Position).Magnitude <= 400 then
                        return true
                    end
                end
            end
        end
        return false
    end)
    return ok and inZone
end

_G.G_AimbotSafeZoneCheck = true
_G.G_AimbotPvPCheck = true

local GuiService = game:GetService("GuiService")

function GetClosestTargetToCenter()
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local maxDist3D = maxRange or 3500

    if _G.G_SilentAimSelectedPlayer and _G.G_SilentAimSelectedPlayer ~= "" and _G.G_SilentAimSelectedPlayer ~= "Nearest" then
        local targetP = Players:FindFirstChild(_G.G_SilentAimSelectedPlayer)
        if targetP and targetP ~= player and targetP.Character and not BlacklistedPlayers[targetP.Name] then
            if _G.G_AimbotPvPCheck and not AX_ReadPvPState(targetP) then return nil end
            if _G.G_AimbotSafeZoneCheck and AX_InSafeZone(targetP) then return nil end
            if not _G.G_SilentAimTeamCheck or IsSilentAimEnemy(targetP) then
                local hum = targetP.Character:FindFirstChildOfClass("Humanoid")
                local hrp = targetP.Character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp then
                    return targetP.Character:FindFirstChild(_G.G_SilentAimPart) or hrp
                end
            end
        end
        return nil
    end

    local closestPart = nil
    local shortest3DDist = maxDist3D

    local function checkTargetPart(character)
        if not character or character == myChar then return end

        local p = Players:GetPlayerFromCharacter(character)
        if p then
            if p == player or BlacklistedPlayers[p.Name] then return end
            if _G.G_AimbotPvPCheck and not AX_ReadPvPState(p) then return end
            if _G.G_AimbotSafeZoneCheck and AX_InSafeZone(p) then return end
            if _G.G_SilentAimTeamCheck and not IsSilentAimEnemy(p) then return end
        end

        local hum = character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local part = character:FindFirstChild(_G.G_SilentAimPart) or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
        if not part then return end

        local worldDist = (part.Position - myHRP.Position).Magnitude
        if worldDist <= shortest3DDist then
            shortest3DDist = worldDist
            closestPart = part
        end
    end

    local wantPlayers = _G.G_SilentAimTargetPlayers
    local wantMobs = _G.G_SilentAimTargetMobs

    if wantPlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                checkTargetPart(p.Character)
            end
        end
    end

    if wantMobs then
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, enemy in ipairs(enemies:GetChildren()) do
                checkTargetPart(enemy)
            end
        end
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj ~= myChar and obj:FindFirstChildOfClass("Humanoid") then
                checkTargetPart(obj)
            end
        end
    end

    return closestPart
end

local activeSkillKey = nil
UserInputService.InputBegan:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isM1Pressed = true
    end
    if input.KeyCode == Enum.KeyCode.Z then activeSkillKey = "Z"
    elseif input.KeyCode == Enum.KeyCode.X then activeSkillKey = "X"
    elseif input.KeyCode == Enum.KeyCode.C then activeSkillKey = "C"
    elseif input.KeyCode == Enum.KeyCode.V then activeSkillKey = "V"
    elseif input.KeyCode == Enum.KeyCode.F then activeSkillKey = "F"
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isM1Pressed = false
    end
    if input.KeyCode == Enum.KeyCode.Z and activeSkillKey == "Z" then activeSkillKey = nil
    elseif input.KeyCode == Enum.KeyCode.X and activeSkillKey == "X" then activeSkillKey = nil
    elseif input.KeyCode == Enum.KeyCode.C and activeSkillKey == "C" then activeSkillKey = nil
    elseif input.KeyCode == Enum.KeyCode.V and activeSkillKey == "V" then activeSkillKey = nil
    elseif input.KeyCode == Enum.KeyCode.F and activeSkillKey == "F" then activeSkillKey = nil
    end
end)

function GetEquippedToolCategory()
    local char = player.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool then return "Melee" end

    local tName = string.lower(tool.Name)
    local tt = ""
    pcall(function() tt = string.lower(tool.ToolTip or tool:GetAttribute("Type") or "") end)

    local isFruit = string.find(tName, "fruit") or string.find(tt, "fruit") or string.find(tt, "bloxfruit") or tool:FindFirstChild("Fruit") ~= nil
    if not isFruit and string.find(tName, "-") then
        local firstPart, secondPart = tName:match("^([%w%s]+)%-(%w+)$")
        if firstPart and secondPart and (firstPart:find(secondPart) or secondPart:find(firstPart)) then
            isFruit = true
        end
    end

    local fruitKeywords = {"portal", "dough", "dragon", "leopard", "kitsune", "buddha", "t-rex", "trex", "mammoth", "sound", "blizzard", "spirit", "venom", "shadow", "control", "gravity", "rumble", "paw", "spider", "love", "quake", "magma", "light", "ice", "flame", "dark", "sand", "falcon", "diamond", "rubber", "barrier", "ghost", "spin", "chop", "spring", "bomb", "smoke", "rocket"}
    if not isFruit then
        for _, kw in ipairs(fruitKeywords) do
            if string.find(tName, kw) and not string.find(tName, "sword") and not string.find(tName, "blade") and not string.find(tName, "gun") then
                isFruit = true
                break
            end
        end
    end

    if isFruit then
        return "Fruit"
    elseif string.find(tName, "blade") or string.find(tName, "sword") or string.find(tName, "katana") or string.find(tName, "yoru") or string.find(tName, "cursed") or string.find(tName, "scythe") or string.find(tName, "saber") or string.find(tName, "pole") or string.find(tName, "bisento") or string.find(tName, "trident") or string.find(tName, "dagger") or string.find(tt, "sword") then
        return "Sword"
    elseif string.find(tName, "gun") or string.find(tName, "rifle") or string.find(tName, "flintlock") or string.find(tName, "kabucha") or string.find(tName, "slingshot") or string.find(tName, "bazooka") or string.find(tName, "cannon") or string.find(tName, "guitar") or string.find(tt, "gun") then
        return "Gun"
    end
    return "Melee"
end

function IsCurrentToolAimbotAllowed()
    return true
end

function IsCurrentSlotAimbotAllowed(explicitSkillKey)
    return true
end

local MouseModuleInstance = ReplicatedStorage:FindFirstChild("Mouse")
local MouseModule = nil
if MouseModuleInstance then
    pcall(function() MouseModule = require(MouseModuleInstance) end)
end
if MouseModule and typeof(MouseModule) == "table" then
    pcall(function()
        local realStore = { Hit = rawget(MouseModule, "Hit"), Target = rawget(MouseModule, "Target") }
        local mmt = getrawmetatable(MouseModule)
        if mmt then setreadonly(mmt, false) else mmt = {}; setmetatable(MouseModule, mmt) end
        rawset(MouseModule, "Hit", nil); rawset(MouseModule, "Target", nil)
        mmt.__index = function(self, key)
            if key == "Hit" then
                if _G.G_SilentAimSkill and currentSilentAimTarget and IsCurrentToolAimbotAllowed() and IsCurrentSlotAimbotAllowed() then return CFrame.new(currentSilentAimTarget.Position) end
                return realStore.Hit
            elseif key == "Target" then
                if _G.G_SilentAimSkill and currentSilentAimTarget and IsCurrentToolAimbotAllowed() and IsCurrentSlotAimbotAllowed() then return currentSilentAimTarget end
                return realStore.Target
            end
        end
        mmt.__newindex = function(self, key, value)
            if key == "Hit" or key == "Target" then realStore[key] = value else rawset(self, key, value) end
        end
        setreadonly(mmt, true)
    end)
end

function GetRainbowTargetChar()
    local targetPart = currentSilentAimTarget or GetClosestTargetToCenter()
    if targetPart and targetPart:IsA("BasePart") and targetPart.Parent then
        local hum = targetPart.Parent:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            return targetPart.Parent
        end
    end
    return nil
end

local activeTargetHighlight = nil

local function updateRainbowTargetHighlight(targetChar)
    if not targetChar or not targetChar:IsA("Model") then
        if activeTargetHighlight then
            activeTargetHighlight:Destroy()
            activeTargetHighlight = nil
        end
        return
    end

    if not activeTargetHighlight or activeTargetHighlight.Parent ~= targetChar then
        if activeTargetHighlight then activeTargetHighlight:Destroy() end
        activeTargetHighlight = Instance.new("Highlight")
        activeTargetHighlight.Name = "SacredRainbowTargetBody"
        activeTargetHighlight.Adornee = targetChar
        activeTargetHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        activeTargetHighlight.FillTransparency = 0.2
        activeTargetHighlight.OutlineTransparency = 0
        activeTargetHighlight.Parent = targetChar
    end

    -- Smooth Rainbow Color Shift (Hue Cycle)
    local hue = (tick() * 0.7) % 1
    local rainbowColor = Color3.fromHSV(hue, 1, 1)
    activeTargetHighlight.FillColor = rainbowColor
    activeTargetHighlight.OutlineColor = Color3.fromHSV((hue + 0.25) % 1, 1, 1)
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        local cam = workspace.CurrentCamera
        local screenCenter = cam and Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2) or Vector2.new(0, 0)

        if _G.G_SilentAimShowFOV and FOVCircle then
            pcall(function()
                FOVCircle.Visible = true
                FOVCircle.Radius = _G.G_SilentAimFOV or 150
                FOVCircle.Color = currentThemeColor
                FOVCircle.Position = screenCenter
            end)
        else
            if FOVCircle then pcall(function() FOVCircle.Visible = false end) end
        end

        -- Evaluar objetivo del Aimbot siempre que Aimbot o Rainbow ESP estén activos
        currentSilentAimTarget = GetClosestTargetToCenter()

        if _G.G_TargetRainbowBodyESP then
            local targetChar = GetRainbowTargetChar()
            if targetChar then
                updateRainbowTargetHighlight(targetChar)
            else
                updateRainbowTargetHighlight(nil)
            end
        else
            updateRainbowTargetHighlight(nil)
        end
    end)
end)


-- ============================================================
-- INTERFAZ VISUAL
-- ============================================================
local THEMES = {
    ["Rainbow RGB"] = Color3.fromRGB(255, 0, 128),
    ["Snow White"] = Color3.fromRGB(255, 255, 255),
    ["Neon Purple"] = Color3.fromRGB(170, 0, 255),
    ["Electric Blue"] = Color3.fromRGB(0, 150, 255),
    ["Crimson Red"] = Color3.fromRGB(255, 0, 50),
    ["Toxic Green"] = Color3.fromRGB(0, 255, 100),
    ["Hot Pink"] = Color3.fromRGB(255, 0, 255),
    ["Gold Yellow"] = Color3.fromRGB(255, 215, 0),
    ["Cyan"] = Color3.fromRGB(0, 255, 255),
    ["Orange"] = Color3.fromRGB(255, 140, 0),
}
local currentThemeColor = THEMES["Neon Purple"] -- Color por defecto Morado
local COLORS = {
    Background = Color3.fromRGB(0, 0, 0), -- Pure Transparent
    PanelBG = Color3.fromRGB(0, 0, 0), -- Pure Transparent
    TextWhite = Color3.fromRGB(255, 255, 255),
    TextGray = Color3.fromRGB(200, 200, 210),
    ToggleOff = Color3.fromRGB(0, 0, 0), -- Pure Transparent
}
local themeStrokes, themeTexts, themeFrames = {}, {}, {}

local parentGui = nil
pcall(function() if gethui then parentGui = gethui() end end)
if not parentGui then
    pcall(function() parentGui = game:GetService("CoreGui") end)
end
if not parentGui and player then
    pcall(function() parentGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 3) end)
end

local function safeParent(gui)
    if not gui then return end
    local ok = pcall(function() gui.Parent = parentGui end)
    if (not ok or not gui.Parent) and player then
        pcall(function() gui.Parent = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 3) end)
    end
end

GuiStore = {
    screenGui = Instance.new("ScreenGui"),
    toggleIconGui = Instance.new("ScreenGui"),
    playerWidgetGui = Instance.new("ScreenGui"),
    npcWidgetGui = Instance.new("ScreenGui"),
    superJumpWidgetGui = Instance.new("ScreenGui"),
    sanguineManualWidgetGui = Instance.new("ScreenGui"),
    sanguineAutoWidgetGui = Instance.new("ScreenGui"),
    soulGuitarWidgetGui = Instance.new("ScreenGui"),
    portalSoruWidgetGui = Instance.new("ScreenGui"),
    grokAIWidgetGui = Instance.new("ScreenGui")
}

GuiStore.screenGui.Name = "SacredUI_UltimateUI"
GuiStore.screenGui.ResetOnSpawn = false
safeParent(GuiStore.screenGui)

GuiStore.toggleIconGui.Name = "SacredUI_ToggleIcon"
GuiStore.toggleIconGui.ResetOnSpawn = false
safeParent(GuiStore.toggleIconGui)

GuiStore.playerWidgetGui.Name = "SacredUI_PlayerWidget"
GuiStore.playerWidgetGui.ResetOnSpawn = false
GuiStore.playerWidgetGui.DisplayOrder = 99999
GuiStore.playerWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.playerWidgetGui)

GuiStore.npcWidgetGui.Name = "SacredUI_NpcWidget"
GuiStore.npcWidgetGui.ResetOnSpawn = false
GuiStore.npcWidgetGui.DisplayOrder = 99999
GuiStore.npcWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.npcWidgetGui)

GuiStore.superJumpWidgetGui.Name = "SacredUI_SuperJumpWidget"
GuiStore.superJumpWidgetGui.ResetOnSpawn = false
GuiStore.superJumpWidgetGui.DisplayOrder = 99999
GuiStore.superJumpWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.superJumpWidgetGui)

GuiStore.sanguineManualWidgetGui.Name = "SacredUI_SanguineManualWidget"
GuiStore.sanguineManualWidgetGui.ResetOnSpawn = false
GuiStore.sanguineManualWidgetGui.DisplayOrder = 99999
GuiStore.sanguineManualWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.sanguineManualWidgetGui)

GuiStore.sanguineAutoWidgetGui.Name = "SacredUI_SanguineAutoWidget"
GuiStore.sanguineAutoWidgetGui.ResetOnSpawn = false
GuiStore.sanguineAutoWidgetGui.DisplayOrder = 99999
GuiStore.sanguineAutoWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.sanguineAutoWidgetGui)

GuiStore.soulGuitarWidgetGui.Name = "SacredUI_SoulGuitarWidget"
GuiStore.soulGuitarWidgetGui.ResetOnSpawn = false
GuiStore.soulGuitarWidgetGui.DisplayOrder = 99999
GuiStore.soulGuitarWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.soulGuitarWidgetGui)

GuiStore.portalSoruWidgetGui.Name = "SacredUI_PortalSoruWidget"
GuiStore.portalSoruWidgetGui.ResetOnSpawn = false
GuiStore.portalSoruWidgetGui.DisplayOrder = 99999
GuiStore.portalSoruWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.portalSoruWidgetGui)

GuiStore.grokAIWidgetGui.Name = "SacredUI_GrokAIWidget"
GuiStore.grokAIWidgetGui.ResetOnSpawn = false
GuiStore.grokAIWidgetGui.DisplayOrder = 99999
GuiStore.grokAIWidgetGui.IgnoreGuiInset = true
safeParent(GuiStore.grokAIWidgetGui)

local screenGui = GuiStore.screenGui
local toggleIconGui = GuiStore.toggleIconGui
local playerWidgetGui = GuiStore.playerWidgetGui
local npcWidgetGui = GuiStore.npcWidgetGui
local superJumpWidgetGui = GuiStore.superJumpWidgetGui
local sanguineManualWidgetGui = GuiStore.sanguineManualWidgetGui
local sanguineAutoWidgetGui = GuiStore.sanguineAutoWidgetGui
local soulGuitarWidgetGui = GuiStore.soulGuitarWidgetGui
local portalSoruWidgetGui = GuiStore.portalSoruWidgetGui
local grokAIWidgetGui = GuiStore.grokAIWidgetGui

-- ============================================================
-- CREAR WIDGETS FLOTANTES Y SINCRONIZACIÓN
-- ============================================================
function updateWidgetsVisuals()
    local isLight = isColorLight(currentThemeColor)
    local darkTxt = Color3.fromRGB(15, 10, 20)
    local lightTxt = Color3.fromRGB(255, 255, 255)

    if PlayerWidgetBtn then
        PlayerWidgetBtn.Visible = PlayerWidgetActive
        PlayerWidgetBtn.BackgroundColor3 = AimlockPlayerEnabled and currentThemeColor or Color3.fromRGB(0, 0, 0)
        PlayerWidgetBtn.BackgroundTransparency = AimlockPlayerEnabled and 0 or 1
        PlayerWidgetBtn.TextColor3 = AimlockPlayerEnabled and (isLight and darkTxt or lightTxt) or lightTxt
        PlayerWidgetBtn.Text = AimlockPlayerEnabled and "🔒 PLAYER: ON" or "🔓 PLAYER: OFF"
    end
    if NpcWidgetBtn then
        NpcWidgetBtn.Visible = NpcWidgetActive
        NpcWidgetBtn.BackgroundColor3 = AimlockNpcEnabled and currentThemeColor or Color3.fromRGB(0, 0, 0)
        NpcWidgetBtn.BackgroundTransparency = AimlockNpcEnabled and 0 or 1
        NpcWidgetBtn.TextColor3 = AimlockNpcEnabled and (isLight and darkTxt or lightTxt) or lightTxt
        NpcWidgetBtn.Text = AimlockNpcEnabled and "🔒 NPC: ON" or "🔓 NPC: OFF"
    end
    if SuperJumpWidget then
        SuperJumpWidget.Visible = SuperJumpWidgetVisible
        SuperJumpWidget.BackgroundColor3 = currentThemeColor
        SuperJumpWidget.BackgroundTransparency = 0
        SuperJumpWidget.TextColor3 = isLight and darkTxt or lightTxt
        SuperJumpWidget.Text = "⬆ JUMP"
    end
    if SanguineManualWidget then
        SanguineManualWidget.Visible = SanguineManualWidgetVisible
        SanguineManualWidget.BackgroundColor3 = currentThemeColor
        SanguineManualWidget.BackgroundTransparency = 0
        SanguineManualWidget.TextColor3 = isLight and darkTxt or lightTxt
        SanguineManualWidget.Text = "🩸 SANGUINE Z"
    end
    if SanguineAutoWidget then
        SanguineAutoWidget.Visible = SanguineWidgetVisible
        SanguineAutoWidget.BackgroundColor3 = SanguineAutoEnabled and currentThemeColor or Color3.fromRGB(0, 0, 0)
        SanguineAutoWidget.BackgroundTransparency = SanguineAutoEnabled and 0 or 1
        SanguineAutoWidget.TextColor3 = SanguineAutoEnabled and (isLight and darkTxt or lightTxt) or lightTxt
        SanguineAutoWidget.Text = SanguineAutoEnabled and "🔴 Auto: ON" or "⚫ Auto: OFF"
    end
end

function makeFloatingWidget(parent, pos, title)
    pcall(function()
        parent.DisplayOrder = 99999
        parent.IgnoreGuiInset = true
        parent.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    end)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 0, 36)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 22) -- Fondo Negro/Gris Nítido
    btn.BackgroundTransparency = 0.25 -- Opaco para máxima legibilidad
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = COLORS.TextWhite
    btn.TextSize = 11.5
    btn.Visible = false
    btn.Active = true
    btn.Draggable = true
    btn.ZIndex = 1000
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local sk = Instance.new("UIStroke", btn)
    sk.Color = currentThemeColor
    sk.Thickness = 1.2
    table.insert(themeStrokes, sk)
    return btn
end

SuperJumpWidget = makeFloatingWidget(superJumpWidgetGui, UDim2.new(0.68, 0, 0.25, 0), "SJUMP")
SuperJumpWidget.Text = "⬆ JUMP"
SuperJumpWidget.MouseButton1Click:Connect(function()
    if doSuperJump then doSuperJump() end
end)

SanguineManualWidget = makeFloatingWidget(sanguineManualWidgetGui, UDim2.new(0.68, 0, 0.33, 0), "SANGUINE MANUAL")
SanguineManualWidget.Text = "🩸 SANGUINE Z"
SanguineManualWidget.MouseButton1Click:Connect(function()
    dropFPSManual()
end)

SanguineAutoWidget = makeFloatingWidget(sanguineAutoWidgetGui, UDim2.new(0.68, 0, 0.41, 0), "SANGUINE AUTO")
SanguineAutoWidget.Text = "🔴 Auto: ON"
SanguineAutoWidget.MouseButton1Click:Connect(function()
    SanguineAutoEnabled = not SanguineAutoEnabled
    updateWidgetsVisuals()
end)

function makeWidget(parent, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 115, 0, 36)
    btn.Position = pos
    btn.BackgroundColor3 = COLORS.ToggleOff
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = COLORS.TextWhite
    btn.TextSize = 10
    btn.Visible = false
    btn.Active = true
    btn.Draggable = true
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local sk = Instance.new("UIStroke", btn)
    sk.Color = currentThemeColor; sk.Thickness = 1.2
    table.insert(themeStrokes, sk)
    return btn
end

PlayerWidgetBtn = makeWidget(playerWidgetGui, UDim2.new(0.82, 0, 0.20, 0))
PlayerWidgetBtn.Text = "🔓 PLAYER: OFF"
PlayerWidgetBtn.MouseButton1Click:Connect(function()
    if setPlayerLockState then setPlayerLockState(not AimlockPlayerEnabled) else AimlockPlayerEnabled = not AimlockPlayerEnabled; updateWidgetsVisuals() end
end)

NpcWidgetBtn = makeWidget(npcWidgetGui, UDim2.new(0.82, 0, 0.27, 0))
NpcWidgetBtn.Text = "🔓 NPC: OFF"
NpcWidgetBtn.MouseButton1Click:Connect(function()
    if setNpcLockState then setNpcLockState(not AimlockNpcEnabled) else AimlockNpcEnabled = not AimlockNpcEnabled; updateWidgetsVisuals() end
end)

-- ============================================================
-- INTERFAZ PRINCIPAL
-- ============================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "SacredMainFrame"
mainFrame.Size = UDim2.new(0, 480, 0, 315)
mainFrame.Position = UDim2.new(0.5, -240, 0.5, -157)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 1 -- 100% transparente para mostrar el anime wallpaper sin fondo negro
mainFrame.Visible = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 24) -- Esquinas extra redondeadas

local mainFrameStroke = Instance.new("UIStroke", mainFrame)
mainFrameStroke.Color = currentThemeColor
mainFrameStroke.Thickness = 1.2
table.insert(themeStrokes, mainFrameStroke)

-- ANIME WALLPAPER (Imagen Fija por Texture Asset ID Nativo de Roblox)
local bgImageFrame = Instance.new("ImageLabel", mainFrame)
bgImageFrame.Name = "AnimeBackground"
bgImageFrame.Size = UDim2.new(1, 0, 1, 0)
bgImageFrame.BackgroundTransparency = 1
bgImageFrame.ImageTransparency = 0 -- Wallpaper 100% Nítido y Cristalino
bgImageFrame.ScaleType = Enum.ScaleType.Crop
bgImageFrame.ZIndex = 0
bgImageFrame.Image = "rbxassetid://132404081379154" -- ID de Textura Anime 8 Nativo Fijo por Defecto
Instance.new("UICorner", bgImageFrame).CornerRadius = UDim.new(0, 24)

-- Pre-carga forzada de la textura para PC y Celular
task.spawn(function()
    pcall(function()
        game:GetService("ContentProvider"):PreloadAsync({bgImageFrame})
    end)
end)

local rainContainer = Instance.new("Frame", mainFrame)
rainContainer.Size = UDim2.new(1, 0, 1, 0)
rainContainer.BackgroundTransparency = 1
rainContainer.ClipsDescendants = true
rainContainer.ZIndex = 1
Instance.new("UICorner", rainContainer).CornerRadius = UDim.new(0, 50)

-- ULTRA-INTENSE THEME-COLORED CYBER NEON RAIN
local activeRainDrops = 0
local MAX_RAIN_DROPS = 12 -- Optimizado para máximo rendimiento y bajo uso de RAM en celular

function createIntenseRainDrop()
    if not mainFrame.Visible or activeRainDrops >= MAX_RAIN_DROPS then return end
    activeRainDrops = activeRainDrops + 1
    
    local drop = Instance.new("Frame", rainContainer)
    drop.Name = "RainDrop"
    drop.Size = UDim2.new(0, 2, 0, math.random(14, 26))
    drop.Position = UDim2.new(math.random(1, 99) / 100, 0, -0.15, 0)
    drop.BackgroundColor3 = currentThemeColor
    drop.BackgroundTransparency = math.random(2, 5) / 10
    drop.BorderSizePixel = 0
    Instance.new("UICorner", drop).CornerRadius = UDim.new(1, 0)

    local targetX = drop.Position.X.Scale - (math.random(3, 8) / 100)
    local duration = math.random(4, 9) / 10

    local tw = TweenService:Create(drop, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Position = UDim2.new(targetX, 0, 1.15, 0),
        BackgroundTransparency = 1
    })
    tw:Play()
    tw.Completed:Connect(function()
        activeRainDrops = activeRainDrops - 1
        drop:Destroy()
    end)
end

task.spawn(function()
    while true do
        task.wait(0.04)
        pcall(createIntenseRainDrop)
    end
end)

function centerAndMaximizeUI()
    mainFrame.Visible = true
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -230, 0.5, -155)
    }):Play()
end

local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 42, 0, 42)
openButton.Position = UDim2.new(0, 15, 0, 15)
openButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
openButton.BackgroundTransparency = 0
openButton.Text = ""
openButton.Visible = false
openButton.Active = true
openButton.Draggable = true
openButton.Parent = toggleIconGui

-- IMAGEN DE FONDO DEL TOGGLE (Muestra la foto del Wallpaper Seleccionado)
local toggleBG = Instance.new("ImageLabel")
toggleBG.Name = "ToggleBackground"
toggleBG.Image = "rbxassetid://132404081379154" -- Wallpaper Anime 8 por Defecto
toggleBG.Size = UDim2.new(1, 0, 1, 0)
toggleBG.Position = UDim2.new(0, 0, 0, 0)
toggleBG.BackgroundTransparency = 1
toggleBG.ScaleType = Enum.ScaleType.Crop
toggleBG.ZIndex = 1 
toggleBG.Parent = openButton

-- BORDES REDONDEADOS PARA LA IMAGEN (Matchea con el botón)
Instance.new("UICorner", toggleBG).CornerRadius = UDim.new(0, 8)

Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 8)
local openStroke = Instance.new("UIStroke", openButton)
openStroke.Thickness = 1.8
openStroke.Transparency = 0
openStroke.Color = currentThemeColor
table.insert(themeStrokes, openStroke)

openButton.MouseButton1Click:Connect(function()
    openButton.Visible = false
    centerAndMaximizeUI()
end)

local topTikTokLabel = Instance.new("TextLabel", mainFrame)
topTikTokLabel.Size = UDim2.new(0, 200, 0, 22)
topTikTokLabel.Position = UDim2.new(0.5, -100, 0, 12)
topTikTokLabel.BackgroundTransparency = 1
topTikTokLabel.Text = "🎵 TikTok: @rivalsxrodx"
topTikTokLabel.Font = Enum.Font.GothamBold
topTikTokLabel.TextSize = 10
topTikTokLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
topTikTokLabel.TextStrokeTransparency = 0
topTikTokLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
topTikTokLabel.TextXAlignment = Enum.TextXAlignment.Center

local controlsContainer = Instance.new("Frame", mainFrame)
controlsContainer.Size = UDim2.new(0, 50, 0, 25)
controlsContainer.Position = UDim2.new(1, -60, 0, 12)
controlsContainer.BackgroundTransparency = 1

function createTopControl(text, xOff, color, cb)
    local btn = Instance.new("TextButton", controlsContainer)
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.Position = UDim2.new(0, xOff, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 1 -- 100% Transparente sin fondo gris feo
    btn.Text = text
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    btn.TextColor3 = color
    btn.TextStrokeTransparency = 0
    btn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local tcStroke = Instance.new("UIStroke", btn)
    tcStroke.Color = color
    tcStroke.Thickness = 1
    btn.MouseButton1Click:Connect(cb)
end

createTopControl("-", 0, Color3.fromRGB(255, 255, 255), function()
    mainFrame.Visible = false
    openButton.Visible = true
end)
createTopControl("X", 26, Color3.fromRGB(255, 75, 75), function()
    screenGui:Destroy(); toggleIconGui:Destroy()
    playerWidgetGui:Destroy(); npcWidgetGui:Destroy()
    superJumpWidgetGui:Destroy(); sanguineAutoWidgetGui:Destroy()
    soulGuitarWidgetGui:Destroy()
    portalSoruWidgetGui:Destroy()
    if fpsOverlayGui then fpsOverlayGui:Destroy() end
    ClearESP()
end)

local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 115, 1, 0)
sidebar.Position = UDim2.new(0, 10, 0, 0)
sidebar.BackgroundTransparency = 1

local mainTitle = Instance.new("TextLabel", sidebar)
mainTitle.Text = "SACRED AHK"
mainTitle.Font = Enum.Font.GothamBlack
mainTitle.TextSize = 17
mainTitle.TextColor3 = currentThemeColor
mainTitle.Size = UDim2.new(0, 110, 0, 20)
mainTitle.Position = UDim2.new(0, 14, 0, 10)
mainTitle.BackgroundTransparency = 1
mainTitle.TextXAlignment = Enum.TextXAlignment.Left
table.insert(themeTexts, mainTitle)

-- Pulsing animation on mainTitle header
task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            if mainTitle and mainTitle.Parent then
                TweenService:Create(mainTitle, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    TextTransparency = 0.35
                }):Play()
                task.wait(0.75)
                TweenService:Create(mainTitle, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    TextTransparency = 0
                }):Play()
            end
        end)
    end
end)

-- TikTok Button Removed

local subTitle = Instance.new("TextLabel", sidebar)
subTitle.Text = "by iSacredRivals"
subTitle.Font = Enum.Font.GothamBold
subTitle.TextSize = 10.5
subTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
subTitle.Size = UDim2.new(1, 0, 0, 14)
subTitle.Position = UDim2.new(0, 14, 0, 31)
subTitle.BackgroundTransparency = 1
subTitle.TextXAlignment = Enum.TextXAlignment.Left

local PagesContainer = Instance.new("Frame", mainFrame)
PagesContainer.Size = UDim2.new(0, 320, 1, -55)
PagesContainer.Position = UDim2.new(0, 125, 0, 45)
PagesContainer.BackgroundTransparency = 1
PagesContainer.ClipsDescendants = false

function createScrollingPage()
    local sf = Instance.new("ScrollingFrame", PagesContainer)
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 4
    sf.CanvasSize = UDim2.new(0, 0, 0, 800) -- Default Canvas Height for Mobile Compatibility
    sf.Visible = false

    local pad = Instance.new("UIPadding", sf)
    pad.PaddingTop = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 15)

    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 45)
    end)
    return sf
end

local StatsPage = createScrollingPage()
local CombatPage = createScrollingPage()
local GlitchesPage = createScrollingPage()
local CamLockPage = createScrollingPage()
local SoruPage = createScrollingPage()
local AppearancePage = createScrollingPage()
local SongsPage = createScrollingPage()
local BlacklistPage = createScrollingPage()
local SacredVFXPage = createScrollingPage()
local MiscPage = createScrollingPage()
StatsPage.Visible = true

local RightPanel = Instance.new("Frame", mainFrame)
RightPanel.Size = UDim2.new(0, 160, 1, -55)
RightPanel.Position = UDim2.new(0, 295, 0, 45)
RightPanel.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
RightPanel.BackgroundTransparency = 0.65 -- Cristal oscuro sutil que permite ver el wallpaper y hace 100% legibles los nombres de la lista!
RightPanel.Visible = false
Instance.new("UICorner", RightPanel).CornerRadius = UDim.new(0, 8)
local rpStroke = Instance.new("UIStroke", RightPanel)
rpStroke.Color = currentThemeColor
rpStroke.Thickness = 1
table.insert(themeStrokes, rpStroke)

local ListScroll = Instance.new("ScrollingFrame", RightPanel)
ListScroll.Size = UDim2.new(1, -10, 1, -30)
ListScroll.Position = UDim2.new(0, 5, 0, 24)
ListScroll.BackgroundTransparency = 1
ListScroll.BorderSizePixel = 0
ListScroll.ScrollBarThickness = 3
ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", ListScroll).Padding = UDim.new(0, 4)

local DropLabel = Instance.new("TextButton", ListScroll)
DropLabel.Name = "DropLabel"
DropLabel.Size = UDim2.new(1, 0, 0, 24)
DropLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DropLabel.BackgroundTransparency = 1
DropLabel.Text = "🎯 Selector: Nearest"
DropLabel.Font = Enum.Font.GothamBold
DropLabel.TextColor3 = currentThemeColor
DropLabel.TextSize = 8.5
Instance.new("UICorner", DropLabel).CornerRadius = UDim.new(0, 4)
local dlStroke = Instance.new("UIStroke", DropLabel)
dlStroke.Color = currentThemeColor
dlStroke.Thickness = 1
table.insert(themeStrokes, dlStroke)
table.insert(themeTexts, DropLabel)

langBtn = nil
copyBtn = nil
copyTikTokBtn = nil
saveBtn = nil
resetBtn = nil

TRANSLATIONS = {
    EN = {
        -- Sidebar Categories
        ["Stats"] = "Player Stats",
        ["Combat"] = "Combat Main",
        ["Glitches"] = "Glitches",
        ["ESP"] = "ESP & Visuals",
        ["Soru"] = "Soru Engine",
        ["Appearance"] = "Appearance",
        ["VFX"] = "Sacred VFX",
        ["Misc"] = "Misc",

        -- Cards
        ["Player Profile"] = "Player Profile",
        ["Combat Main"] = "Combat Main",
        ["Aimbot Modules"] = "Aimbot Modules",
        ["Fast Attack & Combat"] = "Fast Attack & Combat",
        ["Movement"] = "Movement",
        ["Sanguine Z Manual"] = "Sanguine Z Manual",
        ["Sanguine Z Auto"] = "Sanguine Z Auto",
        ["Sanguine Z TP Escape"] = "Sanguine Z TP Escape",
        ["Flashstep Skill Combo"] = "Flashstep Skill Combo",
        ["No Animations"] = "No Animations",
        ["Súper Jump"] = "Super Jump Glitch",
        ["Soul Guitar Glitch (Beta)"] = "Soul Guitar Glitch",
        ["Anti Lava"] = "Anti Lava Protection",
        ["Delete Ghost Ship (Sea 2)"] = "Delete Ghost Ship (Sea 2)",
        ["FFlags 1"] = "FFlags 1",
        ["Bloxstrap (For Mobile)"] = "Bloxstrap (Mobile)",
        ["Macro Beta"] = "Macro Beta",
        ["ESP / Visuales (Jugadores y Mundo)"] = "ESP & Visuals",
        ["ESP & Visuals"] = "ESP & Visuals",
        ["Camera Aimlock"] = "Camera Aimlock",
        ["Soru & Bypass"] = "Soru & Bypass Engine",
        ["Soru Engine"] = "Soru Engine",
        ["UI Background Selector"] = "UI Background Selector",
        ["UI Theme Colors"] = "UI Theme Colors",
        ["Aura VFX"] = "Aura VFX",
        ["Fake Body"] = "Fake Body",
        ["Ambient Lights"] = "Ambient Lights",
        ["Sacred VFX"] = "Sacred VFX",
        ["Performance"] = "Performance",
        ["Socials & Settings"] = "Socials & Settings",
        ["Language"] = "Language",
        ["Songs"] = "Songs & Music",
        ["Auto Race V4"] = "Auto Race V4 (Awakening)",
        ["Silent Aim Blacklist"] = "Silent Aim Blacklist",
        ["Sanguine Z No Cooldown"] = "Sanguine Z No Cooldown",
        ["Anti Stun and Hitbox Attack [Beta]"] = "Anti Stun and Hitbox Attack [Beta]",

        -- Toggles
        ["General ESP"] = "General ESP",
        ["Show Player Name"] = "Show Player Name",
        ["Show Player Level"] = "Show Player Level",
        ["Show Bounty/Honor"] = "Show Bounty/Honor",
        ["Show Devil Fruit"] = "Show Devil Fruit",
        ["Show Distance"] = "Show Distance",
        ["Show HP %"] = "Show HP %",
        ["Highlight Players"] = "Highlight Players",
        ["Aimbot Skills"] = "Aimbot Skills",
        ["Aimbot M1 (Dragon Gun) ⚠️ BAN RISK"] = "Aimbot M1 (Dragon Gun)",
        ["Target Players"] = "Target Players",
        ["Target NPCs"] = "Target NPCs",
        ["Team Check"] = "Team Check",
        ["Ignore Safe Zone (No SafeZone)"] = "Ignore Safe Zone (No SafeZone)",
        ["Ignore PvP OFF Players"] = "Ignore PvP OFF Players",
        ["Target Rainbow Body ESP"] = "Target Rainbow Body ESP",
        ["Fast Attack"] = "Fast Attack (3000 CPS)",
        ["Walk Speed"] = "Walk Speed Boost",
        ["Dash Distance"] = "Dash Distance Boost",
        ["Noclip"] = "Noclip (Through Walls)",
        ["Walk on Water"] = "Walk on Water",
        ["Sanguine Z Manual"] = "Sanguine Z Manual",
        ["Sanguine Z Auto"] = "Sanguine Z Auto",
        ["Sanguine Z TP Widget"] = "Sanguine Z TP Widget",
        ["Flashstep Skill Combo"] = "Flashstep Skill Combo",
        ["No Animations"] = "No Animations",
        ["Activar SJump"] = "Enable Super Jump",
        ["Soul Guitar Glitch (Beta)"] = "Soul Guitar Glitch",
        ["Anti Lava"] = "Anti Lava Protection",
        ["Delete Ghost Ship"] = "Delete Ghost Ship Structures",
        ["Activar FFlags1"] = "Activate FFlags 1",
        ["Activar Macro Beta"] = "Enable Macro Beta",
        ["Aimlock Target Players"] = "Aimlock Target Players",
        ["Aimlock Target NPCs"] = "Aimlock Target NPCs",
        ["Infinite Soru"] = "Infinite Soru (No Cooldown)",
        ["Soru Aimbot (TP)"] = "Soru Auto TP Aimbot",
        ["Portal Soru Combo"] = "Portal Soru Combo",
        ["Portal Sanguine C Combo"] = "Portal Sanguine C Combo",
        ["Fake Korblox"] = "Fake Korblox",
        ["Fake Headless"] = "Fake Headless",
        ["FPS & Ping Overlay"] = "FPS & Ping Overlay",

        -- Steppers
        ["Portal Soru Delay:"] = "Portal Soru Delay:",
        ["Sanguine C Delay:"] = "Sanguine C Delay:",
        ["Skill Delay:"] = "Skill Delay:",
        ["TP Distance:"] = "TP Distance:",

        -- Buttons & Labels
        ["Copy Discord Link"] = "💬 Copy Discord Link",
        ["Copy TikTok"] = "🎵 TikTok: @rivalsxrodx",
        ["Save Config"] = "💾 Save Config",
        ["Reset Config"] = "🔄 Reset Config",
        ["LangBtn"] = "🌐 Language: English (EN)",
    },
    ES = {
        -- Sidebar Categories
        ["Stats"] = "Estadísticas",
        ["Combat"] = "Combate",
        ["Glitches"] = "Trucos",
        ["ESP"] = "ESP / Visuales",
        ["Soru"] = "Motor Soru",
        ["Appearance"] = "Apariencia",
        ["VFX"] = "Efectos VFX",
        ["Misc"] = "Varios",

        -- Cards
        ["Player Profile"] = "Perfil del Jugador",
        ["Combat Main"] = "Combate Principal",
        ["Aimbot Modules"] = "Módulos Aimbot",
        ["Fast Attack & Combat"] = "Ataque Rápido & Combate",
        ["Movement"] = "Movimiento y Física",
        ["Sanguine Z Manual"] = "Sanguine Z Manual",
        ["Sanguine Z Auto"] = "Sanguine Z Automático",
        ["Sanguine Z TP Escape"] = "Escape TP Sanguine Z",
        ["Flashstep Skill Combo"] = "Combo Habilidad Flashstep",
        ["No Animations"] = "Sin Animaciones",
        ["Súper Jump"] = "Glitch Súper Salto",
        ["Soul Guitar Glitch (Beta)"] = "Glitch Guitarra Alma",
        ["Anti Lava"] = "Protección Anti Lava",
        ["Delete Ghost Ship (Sea 2)"] = "Borrar Barco Fantasma (Mar 2)",
        ["FFlags 1"] = "FFlags 1",
        ["Bloxstrap (For Mobile)"] = "Bloxstrap (Celular)",
        ["Macro Beta"] = "Macro Beta",
        ["ESP / Visuales (Jugadores y Mundo)"] = "ESP y Visuales",
        ["ESP & Visuals"] = "ESP y Visuales",
        ["Camera Aimlock"] = "Aimlock de Cámara",
        ["Soru & Bypass"] = "Motor Soru y Bypass",
        ["Soru Engine"] = "Motor Soru y Bypass",
        ["UI Background Selector"] = "Selector de Fondo UI",
        ["UI Theme Colors"] = "Color de Tema UI",
        ["Aura VFX"] = "Aura VFX",
        ["Fake Body"] = "Cuerpo Falso",
        ["Ambient Lights"] = "Luces Ambientes",
        ["Sacred VFX"] = "Efectos Visuales Sacred",
        ["Performance"] = "Rendimiento",
        ["Socials & Settings"] = "Social y Ajustes",
        ["Language"] = "Idioma",
        ["Songs"] = "Canciones y Música",
        ["Auto Race V4"] = "Auto Raza V4 (Despertar)",
        ["Silent Aim Blacklist"] = "Lista Negra Silent Aim",
        ["Sanguine Z No Cooldown"] = "Sanguine Z Sin Cooldown",
        ["Anti Stun and Hitbox Attack [Beta]"] = "Anti Aturdimiento y Ataque Hitbox [Beta]",

        -- Toggles
        ["General ESP"] = "ESP General",
        ["Show Player Name"] = "Mostrar Nombres",
        ["Show Player Level"] = "Mostrar Nivel",
        ["Show Bounty/Honor"] = "Mostrar Recompensa",
        ["Show Devil Fruit"] = "Mostrar Fruta",
        ["Show Distance"] = "Mostrar Distancia",
        ["Show HP %"] = "Mostrar Salud %",
        ["Highlight Players"] = "Resaltar Jugadores",
        ["Aimbot Skills"] = "Aimbot en Habilidades",
        ["Aimbot M1 (Dragon Gun) ⚠️ BAN RISK"] = "Aimbot M1 (Arma Dragón)",
        ["Target Players"] = "Apuntar a Jugadores",
        ["Target NPCs"] = "Apuntar a NPCs",
        ["Team Check"] = "Verificar Equipo (Team Check)",
        ["Ignore Safe Zone (No SafeZone)"] = "Ignorar Zona Segura",
        ["Ignore PvP OFF Players"] = "Ignorar Jugadores PvP OFF",
        ["Target Rainbow Body ESP"] = "Cuerpo Arcoíris en Objetivo",
        ["Fast Attack"] = "Ataque Rápido (3000 CPS)",
        ["Walk Speed"] = "Velocidad de Caminado",
        ["Dash Distance"] = "Distancia de Impulso",
        ["Noclip"] = "Atravesar Paredes (Noclip)",
        ["Walk on Water"] = "Caminar Sobre Agua",
        ["Sanguine Z Manual"] = "Sanguine Z Manual",
        ["Sanguine Z Auto"] = "Sanguine Z Automático",
        ["Sanguine Z TP Widget"] = "Widget TP Sanguine Z",
        ["Flashstep Skill Combo"] = "Combo Habilidad Flashstep",
        ["No Animations"] = "Sin Animaciones",
        ["Activar SJump"] = "Activar Súper Salto",
        ["Soul Guitar Glitch (Beta)"] = "Glitch Guitarra Alma",
        ["Anti Lava"] = "Protección Anti Lava",
        ["Delete Ghost Ship"] = "Eliminar Barco Fantasma",
        ["Activar FFlags1"] = "Activar FFlags 1",
        ["Activar Macro Beta"] = "Activar Macro Beta",
        ["Aimlock Target Players"] = "Fijar Cámara en Jugadores",
        ["Aimlock Target NPCs"] = "Fijar Cámara en NPCs",
        ["Infinite Soru"] = "Soru Infinito (Sin Cooldown)",
        ["Soru Aimbot (TP)"] = "Aimbot Teletransporte Soru",
        ["Portal Soru Combo"] = "Combo Portal Soru",
        ["Portal Sanguine C Combo"] = "Combo Portal Sanguine C",
        ["Fake Korblox"] = "Korblox Falso",
        ["Fake Headless"] = "Sin Cabeza Falso",
        ["FPS & Ping Overlay"] = "Contador FPS y Ping",

        -- Steppers
        ["Portal Soru Delay:"] = "Retraso Portal Soru:",
        ["Sanguine C Delay:"] = "Retraso Sanguine C:",
        ["Skill Delay:"] = "Retraso Habilidad:",
        ["TP Distance:"] = "Distancia TP:",

        -- Buttons & Labels
        ["Copy Discord Link"] = "💬 Copiar Enlace de Discord",
        ["Copy TikTok"] = "🎵 TikTok: @rivalsxrodx",
        ["Save Config"] = "💾 Guardar Configuración",
        ["Reset Config"] = "🔄 Restablecer Configuración",
        ["LangBtn"] = "🌐 Idioma: Español (ES)",
    }
}

currentLang = "EN"

local categories = {
    { key = "Stats", page = StatsPage, y = 54 },
    { key = "Combat", page = CombatPage, y = 84 },
    { key = "Glitches", page = GlitchesPage, y = 114 },
    { key = "ESP", page = CamLockPage, y = 144 },
    { key = "Soru", page = SoruPage, y = 174 },
    { key = "Appearance", page = AppearancePage, y = 204 },
    { key = "Songs", page = SongsPage, y = 234 },
    { key = "VFX", page = SacredVFXPage, y = 264 },
    { key = "Misc", page = MiscPage, y = 294 },
}

local sidebarScroll = Instance.new("ScrollingFrame", sidebar)
sidebarScroll.Size = UDim2.new(1, 0, 1, -55)
sidebarScroll.Position = UDim2.new(0, 0, 0, 48)
sidebarScroll.BackgroundTransparency = 1
sidebarScroll.BorderSizePixel = 0
sidebarScroll.ScrollBarThickness = 2
sidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local sidebarLayout = Instance.new("UIListLayout", sidebarScroll)
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

local sidebarPadding = Instance.new("UIPadding", sidebarScroll)
sidebarPadding.PaddingLeft = UDim.new(0, 10)

function updateUILanguage(lang)
    currentLang = lang or currentLang
    local dict = TRANSLATIONS[currentLang] or TRANSLATIONS.EN

    for _, cat in ipairs(categories) do
        if cat.btn and cat.key then
            cat.btn.Text = dict[cat.key] or cat.key
        end
    end

    for _, item in ipairs(uiCardsRegistry) do
        if item.label and item.rawName then
            local trans = dict[item.rawName] or item.rawName
            item.label.Text = "[ " .. string.upper(trans) .. " ]"
        end
    end

    for _, item in ipairs(uiTogglesRegistry) do
        if item.label and item.rawName then
            local trans = dict[item.rawName] or item.rawName
            item.label.Text = trans
        end
    end

    for _, item in ipairs(uiSteppersRegistry) do
        if item.label and item.rawName then
            local trans = dict[item.rawName] or item.rawName
            item.label.Text = trans
        end
    end

    if songNoticeLbl then
        songNoticeLbl.Text = (currentLang == "ES" and "⚠️ Aviso: Las canciones tienen sonidos raros al principio" or "⚠️ Notice: Songs may have strange sounds at the beginning")
    end

    if langBtn then langBtn.Text = dict["LangBtn"] or (currentLang == "ES" and "🌐 Idioma: Español (ES)" or "🌐 Language: English (EN)") end
    if copyBtn then copyBtn.Text = dict["Copy Discord Link"] or "💬 Copy Discord Link" end
    if copyTikTokBtn then copyTikTokBtn.Text = dict["Copy TikTok"] or "🎵 TikTok: @rivalsxrodx" end
    if saveBtn then saveBtn.Text = dict["Save Config"] or "💾 Save Config" end
    if resetBtn then resetBtn.Text = dict["Reset Config"] or "🔄 Reset Config" end
end

local activeTabBtn = nil
for _, cat in ipairs(categories) do
    local btn = Instance.new("TextButton", sidebarScroll)
    btn.Text = TRANSLATIONS[currentLang][cat.key] or cat.key
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = (cat.page == StatsPage) and currentThemeColor or COLORS.TextGray
    btn.Size = UDim2.new(1, -12, 0, 24)
    btn.BackgroundTransparency = 1
    btn.TextXAlignment = Enum.TextXAlignment.Left
    cat.btn = btn

    if cat.page == StatsPage then
        activeTabBtn = btn
        table.insert(themeTexts, btn)
    end

    btn.MouseButton1Click:Connect(function()
        if activeTabBtn then
            activeTabBtn.TextColor3 = COLORS.TextGray
            local idx = table.find(themeTexts, activeTabBtn)
            if idx then table.remove(themeTexts, idx) end
        end
        activeTabBtn = btn
        table.insert(themeTexts, btn)
        btn.TextColor3 = currentThemeColor
        StatsPage.Visible = false; CombatPage.Visible = false; GlitchesPage.Visible = false
        CamLockPage.Visible = false; SoruPage.Visible = false
        AppearancePage.Visible = false; SongsPage.Visible = false; BlacklistPage.Visible = false
        SacredVFXPage.Visible = false; MiscPage.Visible = false
        cat.page.Visible = true
        if cat.key == "Soru" then
            RightPanel.Visible = true
            PagesContainer.Size = UDim2.new(0, 165, 1, -55)
        else
            RightPanel.Visible = false
            PagesContainer.Size = UDim2.new(0, 320, 1, -55)
        end
    end)
end

-- ============================================================
-- HELPERS DE UI
-- ============================================================
uiCardsRegistry = {}
uiTogglesRegistry = {}
uiSteppersRegistry = {}

function createModuleCard(name, height, targetPage)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -8, 0, height)
    card.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    card.BackgroundTransparency = 0.65 -- Cristal oscuro sutil que permite ver el wallpaper y hace 100% legibles las letras sobre cualquier fondo!
    card.BorderSizePixel = 0
    card.Parent = targetPage
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)
    local cStroke = Instance.new("UIStroke", card)
    cStroke.Color = currentThemeColor
    cStroke.Thickness = 1
    cStroke.Transparency = 0.4
    table.insert(themeStrokes, cStroke)
    
    local title = Instance.new("TextLabel", card)
    title.Text = "[ " .. string.upper(name) .. " ]"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 11
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextStrokeTransparency = 0
    title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    title.Size = UDim2.new(1, 0, 0, 22)
    title.Position = UDim2.new(0, 0, 0, 2)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Center

    table.insert(uiCardsRegistry, { label = title, rawName = name })
    return card
end

ToggleRegistry = {}

function addToggleElement(parent, labelText, defaultState, yPos, callback, configKey)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -12, 0, 20)
    frame.Position = UDim2.new(0, 6, 0, yPos)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Text = labelText
    label.Font = Enum.Font.GothamBold
    label.TextSize = 9.5
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    table.insert(uiTogglesRegistry, { label = label, rawName = labelText })

    local clickBtn = Instance.new("TextButton", frame)
    clickBtn.Size = UDim2.new(0, 36, 0, 16)
    clickBtn.Position = UDim2.new(1, -38, 0.5, -8)
    clickBtn.BackgroundColor3 = defaultState and currentThemeColor or Color3.fromRGB(25, 25, 30)
    clickBtn.BackgroundTransparency = defaultState and 0.2 or 0.5
    clickBtn.Text = defaultState and "ON" or "OFF"
    clickBtn.Font = Enum.Font.GothamBold
    clickBtn.TextSize = 8.5
    clickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clickBtn.TextStrokeTransparency = 0
    clickBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Instance.new("UICorner", clickBtn).CornerRadius = UDim.new(0, 6)
    local tStroke = Instance.new("UIStroke", clickBtn)
    tStroke.Color = currentThemeColor
    tStroke.Thickness = 1
    table.insert(themeStrokes, tStroke)

    local state = defaultState
    local function refresh()
        if state then
            clickBtn.BackgroundColor3 = currentThemeColor
            clickBtn.BackgroundTransparency = 0.2
            clickBtn.Text = "ON"
            clickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            clickBtn.TextStrokeTransparency = 0
            clickBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        else
            clickBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            clickBtn.BackgroundTransparency = 0.5
            clickBtn.Text = "OFF"
            clickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            clickBtn.TextStrokeTransparency = 0
            clickBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        end
    end

    local function setExternalState(newState)
        state = newState
        refresh()
        callback(state)
        updateWidgetsVisuals()
    end

    table.insert(UI_Toggle_Refreshes, setExternalState)
    ToggleRegistryMap[labelText] = setExternalState
    if configKey then ToggleRegistryMap[configKey] = setExternalState end

    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        refresh()
        callback(state)
        updateWidgetsVisuals()
        if state then totalExecutions = totalExecutions + 1 end
    end)
    
    return setExternalState, clickBtn
end

local function formatStepperVal(v)
    if type(v) == "number" then
        v = math.floor(v * 100 + 0.5) / 100
        if v % 1 == 0 then
            return string.format("%d", v)
        else
            local s = string.format("%.2f", v)
            s = s:gsub("0+$", ""):gsub("%.$", "")
            return s
        end
    end
    return tostring(v)
end

function addStepper(parent, labelText, yPos, minVal, maxVal, step, getter, setter, suffix)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -12, 0, 22)
    frame.Position = UDim2.new(0, 6, 0, yPos)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Text = labelText
    label.Font = Enum.Font.GothamBold
    label.TextSize = 8.5
    label.TextColor3 = COLORS.TextWhite
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Size = UDim2.new(1, -95, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ClipsDescendants = true
    label.TextTruncate = Enum.TextTruncate.AtEnd

    table.insert(uiSteppersRegistry, { label = label, rawName = labelText })

    local minus = Instance.new("TextButton", frame)
    minus.Size = UDim2.new(0, 18, 0, 18)
    minus.Position = UDim2.new(1, -90, 0.5, -9)
    minus.Text = "-"
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 11
    minus.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    minus.BackgroundTransparency = 1
    minus.TextColor3 = COLORS.TextWhite
    minus.TextStrokeTransparency = 0
    minus.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 4)
    local mStroke = Instance.new("UIStroke", minus)
    mStroke.Color = currentThemeColor
    mStroke.Thickness = 1.2
    table.insert(themeStrokes, mStroke)

    local valueLabel = Instance.new("TextLabel", frame)
    valueLabel.Size = UDim2.new(0, 44, 0, 18)
    valueLabel.Position = UDim2.new(1, -68, 0.5, -9)
    valueLabel.Text = formatStepperVal(getter()) .. (suffix or "")
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 8.5
    valueLabel.TextColor3 = COLORS.TextWhite
    valueLabel.TextStrokeTransparency = 0
    valueLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center

    local plus = Instance.new("TextButton", frame)
    plus.Size = UDim2.new(0, 18, 0, 18)
    plus.Position = UDim2.new(1, -20, 0.5, -9)
    plus.Text = "+"
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 11
    plus.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    plus.BackgroundTransparency = 1
    plus.TextColor3 = COLORS.TextWhite
    plus.TextStrokeTransparency = 0
    plus.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 4)
    local pStroke = Instance.new("UIStroke", plus)
    pStroke.Color = currentThemeColor
    pStroke.Thickness = 1.2
    table.insert(themeStrokes, pStroke)

    minus.MouseButton1Click:Connect(function()
        local raw = getter() - step
        raw = math.floor(raw * 100 + 0.5) / 100
        local v = math.max(raw, minVal)
        setter(v)
        valueLabel.Text = formatStepperVal(v) .. (suffix or "")
    end)
    plus.MouseButton1Click:Connect(function()
        local raw = getter() + step
        raw = math.floor(raw * 100 + 0.5) / 100
        local v = math.min(raw, maxVal)
        setter(v)
        valueLabel.Text = formatStepperVal(v) .. (suffix or "")
    end)

    return valueLabel
end

-- ============================================================
-- POBLAR PESTAÑAS
-- ============================================================

-- PLAYER STATS TAB
do
local statsCard = createModuleCard("Player Profile", 245, StatsPage)

local profileImg = Instance.new("ImageLabel", statsCard)
profileImg.Size = UDim2.new(0, 60, 0, 60)
profileImg.Position = UDim2.new(0.5, -30, 0, 30)
profileImg.BackgroundColor3 = COLORS.Background
profileImg.ScaleType = Enum.ScaleType.Crop
profileImg.BorderSizePixel = 0
Instance.new("UICorner", profileImg).CornerRadius = UDim.new(0, 30) -- Círculo perfecto
local pStroke = Instance.new("UIStroke", profileImg)
pStroke.Color = currentThemeColor; pStroke.Thickness = 2
table.insert(themeStrokes, pStroke)

local nameLabel = Instance.new("TextLabel", statsCard)
nameLabel.Text = player.Name
nameLabel.Font = Enum.Font.GothamBlack
nameLabel.TextSize = 15
nameLabel.TextColor3 = currentThemeColor
nameLabel.TextStrokeTransparency = 0.3
nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
nameLabel.Size = UDim2.new(1, 0, 0, 18)
nameLabel.Position = UDim2.new(0, 0, 0, 96)
nameLabel.BackgroundTransparency = 1
table.insert(themeTexts, nameLabel)

local levelLabel = Instance.new("TextLabel", statsCard)
levelLabel.Text = "Level: Loading..."
levelLabel.Font = Enum.Font.GothamBold
levelLabel.TextSize = 11
levelLabel.TextColor3 = COLORS.TextWhite
levelLabel.TextStrokeTransparency = 0.3
levelLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
levelLabel.Size = UDim2.new(1, 0, 0, 16)
levelLabel.Position = UDim2.new(0, 0, 0, 116)
levelLabel.BackgroundTransparency = 1

local bountyLabel = Instance.new("TextLabel", statsCard)
bountyLabel.Text = "Bounty: Loading..."
bountyLabel.Font = Enum.Font.GothamBold
bountyLabel.TextSize = 11
bountyLabel.TextColor3 = COLORS.TextWhite
bountyLabel.TextStrokeTransparency = 0.3
bountyLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
bountyLabel.Size = UDim2.new(1, 0, 0, 16)
bountyLabel.Position = UDim2.new(0, 0, 0, 134)
bountyLabel.BackgroundTransparency = 1

-- Divider Removed

local statsTitle = Instance.new("TextLabel", statsCard)
statsTitle.Text = "Script Usage Stats"
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextSize = 10.5
statsTitle.TextColor3 = currentThemeColor
statsTitle.TextStrokeTransparency = 0.3
statsTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
statsTitle.Size = UDim2.new(1, 0, 0, 16)
statsTitle.Position = UDim2.new(0, 10, 0, 162)
statsTitle.BackgroundTransparency = 1
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
table.insert(themeTexts, statsTitle)

-- NUEVO DISEÑO DE STATS BONITOS Y LIMPIOS (SIN EMOJIS)
function createStatLabel(parent, yPos, symbol, labelText)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 24)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    
    local iconLabel = Instance.new("TextLabel", frame)
    iconLabel.Size = UDim2.new(0, 18, 1, 0)
    iconLabel.Position = UDim2.new(0, 0, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = symbol
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 12
    iconLabel.TextColor3 = currentThemeColor
    iconLabel.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(themeTexts, iconLabel)
    
    local textLbl = Instance.new("TextLabel", frame)
    textLbl.Size = UDim2.new(1, -22, 1, 0)
    textLbl.Position = UDim2.new(0, 18, 0, 0)
    textLbl.BackgroundTransparency = 1
    textLbl.Text = labelText
    textLbl.Font = Enum.Font.GothamSemibold
    textLbl.TextSize = 12
    textLbl.TextColor3 = COLORS.TextWhite
    textLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    return textLbl
end

local timeLbl = createStatLabel(statsCard, 182, "•", "Time Used: 00:00:00")
local execLbl = createStatLabel(statsCard, 206, "•", "Executions: 0")

-- Helper para formatear números (ej: 2800 -> 2,800)
function formatNumber(n)
    if type(n) ~= "number" then return tostring(n) end
    local formatted = tostring(n)
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Busca el valor en leaderstats o Data o Attributes (Fix Blox Fruits)
function getGameStat(statName)
    local val = nil
    -- Chequear leaderstats
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        for _, child in ipairs(ls:GetChildren()) do
            if string.lower(child.Name) == string.lower(statName) or string.find(string.lower(child.Name), string.lower(statName)) then
                val = child.Value
                break
            end
        end
    end
    -- Chequear Data folder
    if val == nil then
        local data = player:FindFirstChild("Data")
        if data then
            for _, child in ipairs(data:GetChildren()) do
                if string.lower(child.Name) == string.lower(statName) or string.find(string.lower(child.Name), string.lower(statName)) then
                    val = child.Value
                    break
                end
            end
        end
    end
    -- Chequear Attributes del Player
    if val == nil then
        local attr = player:GetAttribute(statName)
        if attr ~= nil then val = attr end
    end
    return val
end

-- Devuelve el valor real de Bounty / Honor
function getBountyValue()
    local b = tonumber(getGameStat("Bounty")) or 0
    local h = tonumber(getGameStat("Honor")) or 0
    local val = math.max(b, h)
    if val == 0 then
        -- Fallback directo buscando cualquier objeto con numero mayor a 100 en leaderstats/Data
        local ls = player:FindFirstChild("leaderstats") or player:FindFirstChild("Data")
        if ls then
            for _, child in ipairs(ls:GetChildren()) do
                if child:IsA("ValueBase") and type(child.Value) == "number" and child.Value >= 500 then
                    if string.find(string.lower(child.Name), "bounty") or string.find(string.lower(child.Name), "honor") then
                        return child.Value
                    end
                end
            end
        end
    end
    return val
end

-- Loop para actualizar UI
spawn(function()
    pcall(function()
        local content, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        if content then
            profileImg.Image = content
        end
    end)

    task.wait(1)
    startBounty = getBountyValue()

    while true do
        pcall(function()
            local currBounty = getBountyValue()
            if (startBounty == 0 or startBounty == nil) and currBounty > 0 then
                startBounty = currBounty
            end

            local bountyGained = currBounty - startBounty
            if bountyGained < 0 then bountyGained = 0 end
            
            local elapsed = os.time() - scriptStartTime
            local h = math.floor(elapsed / 3600)
            local m = math.floor((elapsed % 3600) / 60)
            local s = math.floor(elapsed % 60)
            local timeStr = string.format("%02d:%02d:%02d", h, m, s)

            local levelVal = getGameStat("Level") or getGameStat("Nivel") or "..."
            if type(levelVal) == "number" then levelVal = formatNumber(levelVal) end
            
            levelLabel.Text = "Level: " .. tostring(levelVal)
            bountyLabel.Text = "Bounty: " .. (currBounty > 0 and formatNumber(currBounty) or "0")
            
            timeLbl.Text = "Time Used: " .. timeStr
            execLbl.Text = "Executions: " .. tostring(totalExecutions)
        end)
        task.wait(1)
    end
end)




end

-- COMBAT MAIN TAB
do
local c1 = createModuleCard("Aimbot Modules", 270, CombatPage)
addToggleElement(c1, "Aimbot Skills", _G.G_SilentAimSkill, 24, function(v) _G.G_SilentAimSkill = v end, "SkillAimbot")
addToggleElement(c1, "Aimbot M1 (Dragon Gun) ⚠️ BAN RISK", _G.G_DragonGunM1, 48, function(v) 
    _G.G_DragonGunM1 = v
    UpdateDragonButton() 
end, "DragonM1")

local setTeamCheckState

local setTargetPlayersState = addToggleElement(c1, "Target Players", _G.G_SilentAimTargetPlayers, 72, function(v) 
    _G.G_SilentAimTargetPlayers = v
    if v and setTeamCheckState then
        setTeamCheckState(true)
    end
end, "TargetPlayers")

-- Selector de Objetivo en Aimbot (Ubicado justo debajo de Target Players)
local aimbotTargetBtn = Instance.new("TextButton", c1)
aimbotTargetBtn.Size = UDim2.new(1, -12, 0, 20)
aimbotTargetBtn.Position = UDim2.new(0, 6, 0, 96)
aimbotTargetBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
aimbotTargetBtn.BackgroundTransparency = 1
aimbotTargetBtn.Text = "🎯 Target: " .. (_G.G_SilentAimSelectedPlayer ~= "" and _G.G_SilentAimSelectedPlayer or "Nearest")
aimbotTargetBtn.Font = Enum.Font.GothamBold
aimbotTargetBtn.TextSize = 8.5
aimbotTargetBtn.TextColor3 = currentThemeColor
Instance.new("UICorner", aimbotTargetBtn).CornerRadius = UDim.new(0, 4)
local aimStroke = Instance.new("UIStroke", aimbotTargetBtn)
aimStroke.Color = currentThemeColor
aimStroke.Thickness = 1
table.insert(themeStrokes, aimStroke)
table.insert(themeTexts, aimbotTargetBtn)

aimbotTargetBtn.MouseButton1Click:Connect(function()
    local plist = {"Nearest"}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then table.insert(plist, p.Name) end
    end
    local currIdx = table.find(plist, _G.G_SilentAimSelectedPlayer) or 1
    local nextIdx = (currIdx % #plist) + 1
    _G.G_SilentAimSelectedPlayer = plist[nextIdx] == "Nearest" and "" or plist[nextIdx]
    aimbotTargetBtn.Text = "🎯 Target: " .. (plist[nextIdx])
end)

setTargetMobsState = addToggleElement(c1, "Target NPCs", _G.G_SilentAimTargetMobs, 120, function(v) 
    _G.G_SilentAimTargetMobs = v
end, "TargetMobs")

setTeamCheckState = addToggleElement(c1, "Team Check", _G.G_SilentAimTeamCheck, 144, function(v) 
    _G.G_SilentAimTeamCheck = v 
end, "TeamCheck")

addToggleElement(c1, "Ignore Safe Zone (No SafeZone)", _G.G_AimbotSafeZoneCheck, 168, function(v) _G.G_AimbotSafeZoneCheck = v end, "AimbotSafeZone")
addToggleElement(c1, "Ignore PvP OFF Players", _G.G_AimbotPvPCheck, 192, function(v) _G.G_AimbotPvPCheck = v end, "AimbotPvP")

addToggleElement(c1, "Target Rainbow Body ESP", _G.G_TargetRainbowBodyESP, 216, function(v) _G.G_TargetRainbowBodyESP = v end, "RainbowBodyESP")
addStepper(c1, "Aimbot Max Dist:", 240, 100, 5000, 250, function() return maxRange end, function(v) maxRange = v end, "st")

-- Combat: Anti Stun and Hitbox Attack [Beta]
local antiStunCard = createModuleCard("Anti Stun and Hitbox Attack [Beta]", 50, CombatPage)
addToggleElement(antiStunCard, "Anti Stun and Hitbox Attack [Beta]", AntiStunHitboxEnabled, 24, function(v)
    if v then enableAntiStunHitbox() else disableAntiStunHitbox() end
end, "AntiStunHitbox")

local c2 = createModuleCard("Fast Attack & Combat", 50, CombatPage)
addToggleElement(c2, "Fast Attack", FastAttackEnabled, 24, function(v) FastAttackEnabled = v; if v then StartFastAttack() end end, "FastAttack")

local c3 = createModuleCard("Movement", 220, CombatPage)
addToggleElement(c3, "Walk Speed", WalkSpeedEnabled, 24, function(v) WalkSpeedEnabled = v end, "WalkSpeed")
addStepper(c3, "Speed:", 48, 16, 500, 50, function() return WalkSpeedValue end, function(v) WalkSpeedValue = v end, "")

-- Movement Boost Loop (Bypass Blox Fruits Speed Clamp)
RunService.Stepped:Connect(function()
    if WalkSpeedEnabled and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            hum.WalkSpeed = WalkSpeedValue
            if hum.MoveDirection.Magnitude > 0 and WalkSpeedValue > 20 then
                hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (WalkSpeedValue / 100))
            end
        end
    end
end)

local setDashToggleState = addToggleElement(c3, "Dash Distance", DashEnabled, 88, function(v) 
    DashEnabled = v 
    if v then startDashLoop() else stopDashLoop() end 
end, "Dash")
local dashDistLabel = addStepper(c3, "Distance:", 116, 1, 300, 10, function() return DashLengthDist end, function(v) 
    DashLengthDist = v
    if DashEnabled then applyDashInstantly() end
end, "")

addToggleElement(c3, "Noclip", NoclipEnabled, 152, function(v) SetNoclip(v) end, "Noclip")
addToggleElement(c3, "Walk on Water", WalkOnWaterEnabled, 176, function(v) WalkOnWaterEnabled = v end, "WalkOnWater")

-- Combat: Auto Race V4
local autoV4Card = createModuleCard("Auto Race V4", 50, CombatPage)
addToggleElement(autoV4Card, "Auto Race V4", AutoV4Enabled, 24, function(v)
    AutoV4Enabled = v
    if v then startAutoV4Loop() else stopAutoV4Loop() end
end, "AutoV4")



-- Glitches: Sanguine Z No Cooldown
local sanguineNoCDCard = createModuleCard("Sanguine Z No Cooldown", 50, GlitchesPage)
addToggleElement(sanguineNoCDCard, "Sanguine Z No Cooldown", SanguineNoCDEnabled, 24, function(v)
    SanguineNoCDEnabled = v
    if v then
        noCDCharConnection = player.CharacterAdded:Connect(function(character)
            character:SetAttribute("AllCooldown", 3)
        end)
        if player.Character then
            player.Character:SetAttribute("AllCooldown", 3)
        end
    else
        if noCDCharConnection then
            noCDCharConnection:Disconnect()
            noCDCharConnection = nil
        end
        if player.Character then
            player.Character:SetAttribute("AllCooldown", nil)
        end
    end
end, "SanguineNoCD")

-- Glitches: Sanguine Z Manual
local sanguineManualCard = createModuleCard("Sanguine Z Manual", 50, GlitchesPage)
addToggleElement(sanguineManualCard, "Sanguine Z TP Widget", SanguineManualWidgetVisible, 24, function(v)
    SanguineManualWidgetVisible = v
    updateWidgetsVisuals()
end, "SanguineManualWidget")

-- Glitches: Sanguine Z Auto
local sanguineAutoCard = createModuleCard("Sanguine Z Auto", 75, GlitchesPage)
addToggleElement(sanguineAutoCard, "Sanguine Z Auto", SanguineAutoEnabled, 24, function(v)
    SanguineAutoEnabled = v
    SanguineWidgetVisible = v
    if v then startSanguineAutoWatcher() else if SanguineAutoConnection then SanguineAutoConnection:Disconnect(); SanguineAutoConnection = nil end end
    updateWidgetsVisuals()
end, "SanguineAuto")

addStepper(sanguineAutoCard, "Drop Duration:", 48, 0.5, 5.0, 0.5, function() return SanguineAutoDropDuration end, function(v) 
    SanguineAutoDropDuration = v
end, "s")

-- Glitches: No Animations
local noAnimCard = createModuleCard("No Animations", 50, GlitchesPage)
addToggleElement(noAnimCard, "No Animations", NoAnimEnabled, 24, function(v)
    NoAnimEnabled = v
    if v then StartNoAnimLoop() else if NoAnimConnection then NoAnimConnection:Disconnect(); NoAnimConnection = nil end end
end, "NoAnim")

end

-- Glitches: Super Jump
do
local superJumpCard = createModuleCard("Súper Jump", 50, GlitchesPage)
setSuperJumpState = addToggleElement(superJumpCard, "Activar SJump", SuperJumpEnabled, 24, function(v)
    SuperJumpEnabled = v
    SuperJumpWidgetVisible = v
    updateWidgetsVisuals()
end, "SuperJump")

-- Glitches: Soul Guitar Glitch
local soulGuitarCard = createModuleCard("Soul Guitar Glitch (Beta)", 75, GlitchesPage)
setSoulGuitarState, soulGuitarBtn = addToggleElement(soulGuitarCard, "Soul Guitar Glitch (Beta)", SoulGuitarJumpEnabled, 24, function(v)
    SoulGuitarJumpEnabled = v
    if v then
        prevDashLength = DashLengthDist
        DashLengthDist = SoulGuitarDashLength
        DashEnabled = true
        if setDashToggleState then setDashToggleState(true) end
        applyDashInstantly()
    else
        DashLengthDist = prevDashLength or 1
        applyDashInstantly()
    end
    if dashDistLabel then dashDistLabel.Text = tostring(DashLengthDist) end
    updateWidgetsVisuals()
end, "SoulGuitar")

addStepper(soulGuitarCard, "Dash Speed:", 52, 1, 300, 10, function() return SoulGuitarDashLength end, function(v) 
    SoulGuitarDashLength = v
    if SoulGuitarJumpEnabled then
        DashLengthDist = v
        if dashDistLabel then dashDistLabel.Text = tostring(DashLengthDist) end
        if DashEnabled then applyDashInstantly() end
    end
end, "")

-- Glitches: Anti Lava
local antiLavaCard = createModuleCard("Anti Lava", 50, GlitchesPage)
addToggleElement(antiLavaCard, "Anti Lava", antiLavaActive, 24, function(v)
    antiLavaActive = v
    if v then startAntiLava() else stopAntiLava() end
end, "AntiLava")

-- Glitches: Delete Ghost Ship
local deleteShipCard = createModuleCard("Delete Ghost Ship (Sea 2)", 50, GlitchesPage)
addToggleElement(deleteShipCard, "Delete Ghost Ship", deleteShipActive, 24, function(v)
    deleteShipActive = v
    if v then startDeleteShipLoop() end
end, "DeleteShip")

-- FFlags1 (Obfuscado en Bytes)
local fflagsCard = createModuleCard("FFlags 1", 50, GlitchesPage)
addToggleElement(fflagsCard, "Activar FFlags1", false, 24, function(v)
    if v then
        pcall(function()
            fflagsThread = task.spawn(function()
                local u = string.char(104,116,116,112,115,58,47,47,112,97,115,116,101,98,105,110,46,99,111,109,47,114,97,119,47,78,77,122,55,82,120,113,68)
                loadstring(game:HttpGet(u))()
            end)
        end)
    else
        pcall(function()
            if fflagsThread then 
                task.cancel(fflagsThread)
                fflagsThread = nil
            end
        end)
    end
end, "FFlags")

-- Bloxstrap Module Card (Acción de Ejecución Única / Sin botón de apagado)
local bloxstrapCard = createModuleCard("Bloxstrap (For Mobile)", 60, GlitchesPage)
local bloxstrapBtn = Instance.new("TextButton", bloxstrapCard)
bloxstrapBtn.Size = UDim2.new(1, -20, 0, 26)
bloxstrapBtn.Position = UDim2.new(0, 10, 0, 24)
bloxstrapBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bloxstrapBtn.BackgroundTransparency = 1
bloxstrapBtn.Text = "🚀 Activar Bloxstrap"
bloxstrapBtn.Font = Enum.Font.GothamBold
bloxstrapBtn.TextSize = 10
bloxstrapBtn.TextColor3 = currentThemeColor
bloxstrapBtn.TextStrokeTransparency = 0.3
bloxstrapBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Instance.new("UICorner", bloxstrapBtn).CornerRadius = UDim.new(0, 6)
local bloxStroke = Instance.new("UIStroke", bloxstrapBtn)
bloxStroke.Color = currentThemeColor
bloxStroke.Thickness = 1.2
table.insert(themeStrokes, bloxStroke)
table.insert(themeTexts, bloxstrapBtn)

bloxstrapBtn.MouseButton1Click:Connect(function()
    bloxstrapBtn.Text = "⏳ Cargando Bloxstrap..."
    bloxstrapBtn.TextColor3 = Color3.fromRGB(200, 200, 100)
    task.spawn(function()
        pcall(function()
            getgenv().autosetup = {
                path = 'Bloxstrap',
                setup = true
            }
            loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/Initiate.lua'), 'lol')()
        end)
        bloxstrapBtn.Text = "✅ Bloxstrap Activado!"
        bloxstrapBtn.TextColor3 = Color3.fromRGB(0, 255, 120)
    end)
end)

-- Macro Beta Module
local macroCard = createModuleCard("Macro Beta", 155, GlitchesPage)
-- ============================================================
-- SEPARATE MACRO CONFIG FILE SYSTEM (6 HABILIDADES / 4 HOTBAR SLOTS)
-- ============================================================
function SaveMacroConfig()
    local macroConf = {
        MacroBeta = MacroEnabled,
        MacroMode = MacroMode,
        MacroSlot1 = MacroSlot1, MacroKey1 = MacroKey1, MacroDelay1 = MacroDelay1,
        MacroSlot2 = MacroSlot2, MacroKey2 = MacroKey2, MacroDelay2 = MacroDelay2,
        MacroSlot3 = MacroSlot3, MacroKey3 = MacroKey3, MacroDelay3 = MacroDelay3,
        MacroSlot4 = MacroSlot4, MacroKey4 = MacroKey4, MacroDelay4 = MacroDelay4,
        MacroSlot5 = MacroSlot5, MacroKey5 = MacroKey5, MacroDelay5 = MacroDelay5,
        MacroSlot6 = MacroSlot6, MacroKey6 = MacroKey6, MacroDelay6 = MacroDelay6,
    }
    pcall(function()
        if writefile then
            writefile("SacredAHK_MacroConfig.json", HttpService:JSONEncode(macroConf))
            print("💾 Sacred AHK Macro Config Saved to SacredAHK_MacroConfig.json!")
        end
    end)
end

function LoadMacroConfig()
    pcall(function()
        if readfile and isfile and isfile("SacredAHK_MacroConfig.json") then
            local data = readfile("SacredAHK_MacroConfig.json")
            local conf = HttpService:JSONDecode(data)
            if conf then
                if conf.MacroBeta ~= nil then MacroEnabled = conf.MacroBeta end
                if conf.MacroMode ~= nil then MacroMode = conf.MacroMode end
                if conf.MacroSlot1 ~= nil then MacroSlot1 = conf.MacroSlot1 end
                if conf.MacroKey1 ~= nil then MacroKey1 = conf.MacroKey1 end
                if conf.MacroSlot2 ~= nil then MacroSlot2 = conf.MacroSlot2 end
                if conf.MacroKey2 ~= nil then MacroKey2 = conf.MacroKey2 end
                if conf.MacroSlot3 ~= nil then MacroSlot3 = conf.MacroSlot3 end
                if conf.MacroKey3 ~= nil then MacroKey3 = conf.MacroKey3 end
                if conf.MacroSlot4 ~= nil then MacroSlot4 = conf.MacroSlot4 end
                if conf.MacroKey4 ~= nil then MacroKey4 = conf.MacroKey4 end
                if conf.MacroSlot5 ~= nil then MacroSlot5 = conf.MacroSlot5 end
                if conf.MacroKey5 ~= nil then MacroKey5 = conf.MacroKey5 end
                if conf.MacroSlot6 ~= nil then MacroSlot6 = conf.MacroSlot6 end
                if conf.MacroKey6 ~= nil then MacroKey6 = conf.MacroKey6 end
                if conf.MacroDelay1 ~= nil then MacroDelay1 = conf.MacroDelay1 end
                if conf.MacroDelay2 ~= nil then MacroDelay2 = conf.MacroDelay2 end
                if conf.MacroDelay3 ~= nil then MacroDelay3 = conf.MacroDelay3 end
                if conf.MacroDelay4 ~= nil then MacroDelay4 = conf.MacroDelay4 end
                if conf.MacroDelay5 ~= nil then MacroDelay5 = conf.MacroDelay5 end
                if conf.MacroDelay6 ~= nil then MacroDelay6 = conf.MacroDelay6 end
            end
        end
    end)
end

MacroEnabled = false
MacroMode = "Soru" -- "Soru" o "Combo"
MacroSlot1, MacroKey1, MacroDelay1 = 1, "Z", 0.30
MacroSlot2, MacroKey2, MacroDelay2 = 2, "X", 0.30
MacroSlot3, MacroKey3, MacroDelay3 = 3, "C", 0.30
MacroSlot4, MacroKey4, MacroDelay4 = 4, "V", 0.30
MacroSlot5, MacroKey5, MacroDelay5 = 1, "OFF", 0.30
MacroSlot6, MacroKey6, MacroDelay6 = 1, "OFF", 0.30
MacroExecuting = false

-- UI Flotante de Configuración del Macro (Scrollable + 6 Habilidades + Delay Individual)
local macroGui = nil

function showMacroConfigUI()
    if macroGui then macroGui:Destroy() end

    macroGui = Instance.new("ScreenGui")
    macroGui.Name = "Sacred_Macro_Config_UI"
    macroGui.ResetOnSpawn = false
    macroGui.Parent = playerGui

    local main = Instance.new("Frame", macroGui)
    main.Size = UDim2.new(0, 280, 0, 520)
    main.Position = UDim2.new(0.5, -140, 0.05, 0)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    main.BackgroundTransparency = 0.05
    main.Active = true
    main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = currentThemeColor
    stroke.Thickness = 1.5

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, -35, 0, 32)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "MACRO COMBO PRO (6 HABILIDADES)"
    title.TextColor3 = currentThemeColor
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12.5
    title.TextXAlignment = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0, 4)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.MouseButton1Click:Connect(function() macroGui:Destroy(); macroGui = nil end)

    -- Botón de Guardar Pinned Fijo en la parte Superior
    local saveMacroBtn = Instance.new("TextButton", main)
    saveMacroBtn.Size = UDim2.new(1, -20, 0, 34)
    saveMacroBtn.Position = UDim2.new(0, 10, 0, 34)
    saveMacroBtn.BackgroundColor3 = currentThemeColor
    saveMacroBtn.BackgroundTransparency = 0
    saveMacroBtn.Text = "💾 GUARDAR CONFIG MACRO"
    saveMacroBtn.TextColor3 = Color3.fromRGB(15, 10, 20)
    saveMacroBtn.Font = Enum.Font.GothamBold
    saveMacroBtn.TextSize = 11
    saveMacroBtn.ZIndex = 25
    Instance.new("UICorner", saveMacroBtn).CornerRadius = UDim.new(0, 6)
    local saveSt = Instance.new("UIStroke", saveMacroBtn)
    saveSt.Color = Color3.fromRGB(255, 255, 255)
    saveSt.Thickness = 1

    saveMacroBtn.MouseButton1Click:Connect(function()
        pcall(SaveMacroConfig)
        pcall(SaveConfig)
        saveMacroBtn.Text = "✅ MACRO GUARDADO!"
        task.delay(1.2, function()
            if saveMacroBtn and saveMacroBtn.Parent then
                saveMacroBtn.Text = "💾 GUARDAR CONFIG MACRO"
            end
        end)
    end)

    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -12, 1, -80)
    scroll.Position = UDim2.new(0, 6, 0, 74)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 5
    scroll.ScrollBarImageColor3 = currentThemeColor
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
    scroll.CanvasSize = UDim2.new(0, 0, 0, 720)
    local listLayout = Instance.new("UIListLayout", scroll)
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function makeBtn(parent, text, pos, size)
        local b = Instance.new("TextButton", parent)
        b.Size = size
        b.Position = pos
        b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        b.BackgroundTransparency = 1
        b.Text = text
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10.5
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        local bSt = Instance.new("UIStroke", b)
        bSt.Color = currentThemeColor
        bSt.Thickness = 1
        return b
    end

    local function createSlotRow(order, labelText, defaultSlot, defaultKey, defaultDelay, allowOff, onSelect)
        local rowFrame = Instance.new("Frame", scroll)
        rowFrame.Size = UDim2.new(1, -8, 0, 105)
        rowFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        rowFrame.BackgroundTransparency = 0.4
        rowFrame.LayoutOrder = order
        Instance.new("UICorner", rowFrame).CornerRadius = UDim.new(0, 8)
        local rowStroke = Instance.new("UIStroke", rowFrame)
        rowStroke.Color = currentThemeColor
        rowStroke.Thickness = 0.8
        rowStroke.Transparency = 0.5

        local lbl = Instance.new("TextLabel", rowFrame)
        lbl.Size = UDim2.new(1, -12, 0, 20)
        lbl.Position = UDim2.new(0, 8, 0, 4)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10.5
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local selectedSlot = defaultSlot
        local selectedKey = defaultKey
        local selectedDelay = defaultDelay

        local slotBtns = {}
        local xOff = 8
        for _, s in ipairs({1, 2, 3, 4}) do
            local b = makeBtn(rowFrame, tostring(s), UDim2.new(0, xOff, 0, 24), UDim2.new(0, 45, 0, 22))
            slotBtns[s] = b
            if s == selectedSlot then
                b.BackgroundColor3 = currentThemeColor
                b.TextColor3 = Color3.fromRGB(15, 10, 20)
            end
            b.MouseButton1Click:Connect(function()
                selectedSlot = s
                for _, btn in pairs(slotBtns) do
                    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
                b.BackgroundColor3 = currentThemeColor
                b.TextColor3 = Color3.fromRGB(15, 10, 20)
                onSelect(selectedSlot, selectedKey, selectedDelay)
            end)
            xOff = xOff + 50
        end

        local keyBtns = {}
        xOff = 8
        local keyOptions = {"Z", "X", "C", "V"}
        if allowOff then table.insert(keyOptions, "OFF") end

        for _, k in ipairs(keyOptions) do
            local btnWidth = (k == "OFF") and 42 or 38
            local b = makeBtn(rowFrame, k, UDim2.new(0, xOff, 0, 49), UDim2.new(0, btnWidth, 0, 22))
            keyBtns[k] = b
            if k == "OFF" then b.TextColor3 = Color3.fromRGB(255, 80, 80) end
            if k == selectedKey then
                b.BackgroundColor3 = (k == "OFF") and Color3.fromRGB(255, 50, 50) or currentThemeColor
                b.TextColor3 = Color3.fromRGB(15, 10, 20)
            end
            b.MouseButton1Click:Connect(function()
                selectedKey = k
                for keyStr, btn in pairs(keyBtns) do
                    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                    btn.TextColor3 = (keyStr == "OFF") and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 255, 255)
                end
                b.BackgroundColor3 = (k == "OFF") and Color3.fromRGB(255, 50, 50) or currentThemeColor
                b.TextColor3 = Color3.fromRGB(15, 10, 20)
                onSelect(selectedSlot, selectedKey, selectedDelay)
            end)
            xOff = xOff + btnWidth + 6
        end

        -- Delay Per Skill Stepper
        local delayLbl = Instance.new("TextLabel", rowFrame)
        delayLbl.Size = UDim2.new(0, 50, 0, 22)
        delayLbl.Position = UDim2.new(0, 8, 0, 75)
        delayLbl.BackgroundTransparency = 1
        delayLbl.Text = "Delay:"
        delayLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
        delayLbl.Font = Enum.Font.GothamBold
        delayLbl.TextSize = 10
        delayLbl.TextXAlignment = Enum.TextXAlignment.Left

        local minusBtn = makeBtn(rowFrame, "-", UDim2.new(0, 55, 0, 75), UDim2.new(0, 22, 0, 22))
        local valLabel = Instance.new("TextLabel", rowFrame)
        valLabel.Size = UDim2.new(0, 48, 0, 22)
        valLabel.Position = UDim2.new(0, 80, 0, 75)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = string.format("%.2fs", selectedDelay)
        valLabel.TextColor3 = currentThemeColor
        valLabel.Font = Enum.Font.GothamBold
        valLabel.TextSize = 10.5
        local plusBtn = makeBtn(rowFrame, "+", UDim2.new(0, 130, 0, 75), UDim2.new(0, 22, 0, 22))

        minusBtn.MouseButton1Click:Connect(function()
            selectedDelay = math.max(0.05, math.floor((selectedDelay - 0.05) * 100 + 0.5) / 100)
            valLabel.Text = string.format("%.2fs", selectedDelay)
            onSelect(selectedSlot, selectedKey, selectedDelay)
        end)

        plusBtn.MouseButton1Click:Connect(function()
            selectedDelay = math.min(1.50, math.floor((selectedDelay + 0.05) * 100 + 0.5) / 100)
            valLabel.Text = string.format("%.2fs", selectedDelay)
            onSelect(selectedSlot, selectedKey, selectedDelay)
        end)
    end

    createSlotRow(1, "Habilidad 1:", MacroSlot1, MacroKey1, MacroDelay1, false, function(s, k, d) MacroSlot1 = s; MacroKey1 = k; MacroDelay1 = d end)
    createSlotRow(2, "Habilidad 2:", MacroSlot2, MacroKey2, MacroDelay2, true, function(s, k, d) MacroSlot2 = s; MacroKey2 = k; MacroDelay2 = d end)
    createSlotRow(3, "Habilidad 3:", MacroSlot3, MacroKey3, MacroDelay3, true, function(s, k, d) MacroSlot3 = s; MacroKey3 = k; MacroDelay3 = d end)
    createSlotRow(4, "Habilidad 4:", MacroSlot4, MacroKey4, MacroDelay4, true, function(s, k, d) MacroSlot4 = s; MacroKey4 = k; MacroDelay4 = d end)
    createSlotRow(5, "Habilidad 5:", MacroSlot5, MacroKey5, MacroDelay5, true, function(s, k, d) MacroSlot5 = s; MacroKey5 = k; MacroDelay5 = d end)
    createSlotRow(6, "Habilidad 6:", MacroSlot6, MacroKey6, MacroDelay6, true, function(s, k, d) MacroSlot6 = s; MacroKey6 = k; MacroDelay6 = d end)
end

-- Botón Flotante Externo para Hacer Combo
local floatingTriggerGui = nil

function showFloatingComboTrigger(show)
    if floatingTriggerGui then floatingTriggerGui:Destroy(); floatingTriggerGui = nil end
    if not show then return end

    floatingTriggerGui = Instance.new("ScreenGui")
    floatingTriggerGui.Name = "Sacred_Macro_Floating_Combo"
    floatingTriggerGui.ResetOnSpawn = false
    floatingTriggerGui.Parent = playerGui

    local floatBtn = Instance.new("TextButton", floatingTriggerGui)
    floatBtn.Size = UDim2.new(0, 110, 0, 36)
    floatBtn.Position = UDim2.new(0.85, -55, 0.7, 0)
    floatBtn.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
    floatBtn.Text = "💥 COMBO"
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextSize = 12
    floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatBtn.Active = true
    floatBtn.Draggable = true
    Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0, 8)
    local floatStroke = Instance.new("UIStroke", floatBtn)
    floatStroke.Color = Color3.fromRGB(255, 255, 255)
    floatStroke.Thickness = 1.2

    local SLOT_KEYS = { [1] = Enum.KeyCode.One, [2] = Enum.KeyCode.Two, [3] = Enum.KeyCode.Three, [4] = Enum.KeyCode.Four, [5] = Enum.KeyCode.Five, [6] = Enum.KeyCode.Six }
    local function pressKey(kc)
        if not kc then return end
        VirtualInputManager:SendKeyEvent(true, kc, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, kc, false, game)
    end
    local function hasToolEquipped()
        local char = player.Character
        return char and char:FindFirstChildOfClass("Tool") ~= nil
    end
    local function safeEquip(slotNum)
        pressKey(SLOT_KEYS[slotNum])
        task.wait(0.05)
        if not hasToolEquipped() then
            pressKey(SLOT_KEYS[slotNum])
            task.wait(0.05)
        end
    end

    local function executeMacroCombo()
        local slots = {
            {slot = MacroSlot1, key = MacroKey1, delay = MacroDelay1},
            {slot = MacroSlot2, key = MacroKey2, delay = MacroDelay2},
            {slot = MacroSlot3, key = MacroKey3, delay = MacroDelay3},
            {slot = MacroSlot4, key = MacroKey4, delay = MacroDelay4},
            {slot = MacroSlot5, key = MacroKey5, delay = MacroDelay5},
            {slot = MacroSlot6, key = MacroKey6, delay = MacroDelay6},
        }

        local prevSlot = nil
        for _, item in ipairs(slots) do
            if item.key and item.key ~= "OFF" then
                if item.slot ~= prevSlot then safeEquip(item.slot) end
                pressKey(Enum.KeyCode[item.key])
                prevSlot = item.slot
                task.wait(item.delay or 0.3)
            end
        end
    end

    floatBtn.MouseButton1Down:Connect(function()
        if MacroExecuting then return end
        MacroExecuting = true
        task.spawn(function()
            while MacroExecuting do
                executeMacroCombo()
                task.wait(MacroDelay + 0.05)
            end
        end)
    end)
    floatBtn.MouseButton1Up:Connect(function() MacroExecuting = false end)
    floatBtn.MouseLeave:Connect(function() MacroExecuting = false end)
end

-- Toggle Principal Macro Beta en UI
addToggleElement(macroCard, "Activar Macro Beta", MacroEnabled, 24, function(v)
    MacroEnabled = v
    if v then
        showMacroConfigUI()
        if MacroMode == "Combo" then showFloatingComboTrigger(true) else showFloatingComboTrigger(false) end
    else
        if macroGui then macroGui:Destroy(); macroGui = nil end
        showFloatingComboTrigger(false)
    end
end, "MacroBeta")

-- Selector de Modo (Soru / Combo)
local macroModeBtn = Instance.new("TextButton", macroCard)
macroModeBtn.Size = UDim2.new(1, -12, 0, 22)
macroModeBtn.Position = UDim2.new(0, 6, 0, 50)
macroModeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
macroModeBtn.BackgroundTransparency = 1
macroModeBtn.Text = "⚡ Modo Macro: " .. (MacroMode == "Soru" and "Modo Soru (Flashstep)" or "Hacer Combo (Botón Flotante)")
macroModeBtn.Font = Enum.Font.GothamBold
macroModeBtn.TextSize = 8.5
macroModeBtn.TextColor3 = currentThemeColor
Instance.new("UICorner", macroModeBtn).CornerRadius = UDim.new(0, 4)
local mmStroke = Instance.new("UIStroke", macroModeBtn)
mmStroke.Color = currentThemeColor
mmStroke.Thickness = 1
table.insert(themeStrokes, mmStroke)
table.insert(themeTexts, macroModeBtn)

macroModeBtn.MouseButton1Click:Connect(function()
    MacroMode = (MacroMode == "Soru") and "Combo" or "Soru"
    macroModeBtn.Text = "⚡ Modo Macro: " .. (MacroMode == "Soru" and "Modo Soru (Flashstep)" or "Hacer Combo (Botón Flotante)")
    if MacroEnabled then
        if MacroMode == "Combo" then showFloatingComboTrigger(true) else showFloatingComboTrigger(false) end
    end
end)

-- Botón para reabrir la UI de Configuración del Macro
local macroConfigBtn = Instance.new("TextButton", macroCard)
macroConfigBtn.Size = UDim2.new(1, -12, 0, 22)
macroConfigBtn.Position = UDim2.new(0, 6, 0, 78)
macroConfigBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
macroConfigBtn.BackgroundTransparency = 1
macroConfigBtn.Text = "⚙️ Configurar Macro (Slots/Teclas)"
macroConfigBtn.Font = Enum.Font.GothamBold
macroConfigBtn.TextSize = 8.5
macroConfigBtn.TextColor3 = COLORS.TextWhite
Instance.new("UICorner", macroConfigBtn).CornerRadius = UDim.new(0, 4)
local mcStroke = Instance.new("UIStroke", macroConfigBtn)
mcStroke.Color = currentThemeColor
mcStroke.Thickness = 1
table.insert(themeStrokes, mcStroke)

macroConfigBtn.MouseButton1Click:Connect(function()
    showMacroConfigUI()
end)

-- Detección Automática en Modo Soru
function executeSoruCombo()
    if not MacroEnabled or MacroMode ~= "Soru" or MacroExecuting then return end
    MacroExecuting = true

    local SLOT_KEYS = { [1] = Enum.KeyCode.One, [2] = Enum.KeyCode.Two, [3] = Enum.KeyCode.Three, [4] = Enum.KeyCode.Four }
    local function pressKey(kc)
        VirtualInputManager:SendKeyEvent(true, kc, false, game)
        task.wait(0.08)
        VirtualInputManager:SendKeyEvent(false, kc, false, game)
    end
    local function safeEquip(slotNum)
        pressKey(SLOT_KEYS[slotNum])
        task.wait(0.12)
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if not tool then
            pressKey(SLOT_KEYS[slotNum])
            task.wait(0.1)
        end
    end

    pcall(function()
        safeEquip(MacroSlot1)
        task.wait(0.06)
        pressKey(Enum.KeyCode[MacroKey1])
        task.wait(MacroDelay)
        if MacroSlot1 ~= MacroSlot2 then safeEquip(MacroSlot2); task.wait(0.06) end
        pressKey(Enum.KeyCode[MacroKey2])
        task.wait(MacroDelay)
        if MacroSlot2 ~= MacroSlot3 then safeEquip(MacroSlot3); task.wait(0.06) end
        pressKey(Enum.KeyCode[MacroKey3])
        task.wait(MacroDelay)
        if MacroSlot3 ~= MacroSlot4 then safeEquip(MacroSlot4); task.wait(0.06) end
        pressKey(Enum.KeyCode[MacroKey4])
    end)

    MacroExecuting = false
end

_G.G_FlashstepSkillEnabled = false
_G.G_FlashstepSkillWeapon = "Fruit"
_G.G_FlashstepSkillKey = "Z"
_G.G_FlashstepSkillDelay = 0.3
_G.G_PortalSoruDelay = 0.35
_G.G_PortalSanguineCDelay = 0.35

function executeFlashstepSkillCombo()
    if not _G.G_FlashstepSkillEnabled then return end
    task.spawn(function()
        local delayVal = tonumber(_G.G_FlashstepSkillDelay) or 0.3
        task.wait(delayVal)
        if not _G.G_FlashstepSkillEnabled then return end
        
        local slotMap = { Melee = 1, Fruit = 2, Sword = 3, Gun = 4 }
        local slotNum = slotMap[_G.G_FlashstepSkillWeapon or "Fruit"] or 2
        local SLOT_KEYS = { [1] = Enum.KeyCode.One, [2] = Enum.KeyCode.Two, [3] = Enum.KeyCode.Three, [4] = Enum.KeyCode.Four }
        
        local function pressKey(kc)
            VirtualInputManager:SendKeyEvent(true, kc, false, game)
            task.wait(0.06)
            VirtualInputManager:SendKeyEvent(false, kc, false, game)
        end
        
        pressKey(SLOT_KEYS[slotNum])
        task.wait(0.12)
        local keyName = _G.G_FlashstepSkillKey or "Z"
        if Enum.KeyCode[keyName] then
            pressKey(Enum.KeyCode[keyName])
        end
    end)
end

function monitorCharMacro(char)
    local h = char:WaitForChild("Humanoid", 5) 
    if not h then return end
    h.AnimationPlayed:Connect(function(track)
        if isFlashstep(track) then
            if MacroEnabled and MacroMode == "Soru" then
                task.spawn(executeSoruCombo)
            end
            if _G.G_FlashstepSkillEnabled then
                executeFlashstepSkillCombo()
            end
        end
    end)
end

if player.Character then monitorCharMacro(player.Character) end
player.CharacterAdded:Connect(monitorCharMacro)

end

-- ESP / Visuales
do
local espCard = createModuleCard("ESP & Visuals", 260, CamLockPage)

local setESPNameState, setESPLevelState, setESPBountyState, setESPFruitState, setESPDistState, setESPHealthState, setESPHighlightState

local function syncMasterESP()
    local anyActive = _G.G_ESP_Name or _G.G_ESP_Level or _G.G_ESP_Bounty or _G.G_ESP_Fruit or _G.G_ESP_Distance or _G.G_ESP_HP or _G.G_ESP_Highlight
    _G.G_ESPEnabled = anyActive
    if anyActive then EnableESP() else DisableESP() end
end

addToggleElement(espCard, "General ESP", false, 24, function(v) 
    _G.G_ESPEnabled = v
    _G.G_ESP_Name = v
    _G.G_ESP_Level = v
    _G.G_ESP_Bounty = v
    _G.G_ESP_Fruit = v
    _G.G_ESP_Distance = v
    _G.G_ESP_HP = v
    _G.G_ESP_Highlight = v
    if setESPNameState then setESPNameState(v) end
    if setESPLevelState then setESPLevelState(v) end
    if setESPBountyState then setESPBountyState(v) end
    if setESPFruitState then setESPFruitState(v) end
    if setESPDistState then setESPDistState(v) end
    if setESPHealthState then setESPHealthState(v) end
    if setESPHighlightState then setESPHighlightState(v) end
    if v then EnableESP() else DisableESP() end 
end, "ESPMaster")

setESPNameState = addToggleElement(espCard, "Show Player Name", false, 48, function(v) _G.G_ESP_Name = v; syncMasterESP() end, "ESPName")
setESPLevelState = addToggleElement(espCard, "Show Player Level", false, 72, function(v) _G.G_ESP_Level = v; syncMasterESP() end, "ESPLevel")
setESPBountyState = addToggleElement(espCard, "Show Bounty/Honor", false, 96, function(v) _G.G_ESP_Bounty = v; syncMasterESP() end, "ESPBounty")
setESPFruitState = addToggleElement(espCard, "Show Devil Fruit", false, 120, function(v) _G.G_ESP_Fruit = v; syncMasterESP() end, "ESPFruit")
setESPDistState = addToggleElement(espCard, "Show Distance", false, 144, function(v) _G.G_ESP_Distance = v; syncMasterESP() end, "ESPDist")
setESPHealthState = addToggleElement(espCard, "Show HP %", false, 168, function(v) _G.G_ESP_HP = v; syncMasterESP() end, "ESPHealth")
setESPHighlightState = addToggleElement(espCard, "Highlight Players", false, 192, function(v) _G.G_ESP_Highlight = v; syncMasterESP() end, "ESPHighlight")
addStepper(espCard, "ESP Text Size:", 216, 8, 32, 1, function() return _G.G_ESP_TextSize or 12 end, function(v) _G.G_ESP_TextSize = v end, "px")

end

-- Soru Engine
do
local soruCard = createModuleCard("Soru & Bypass", 210, SoruPage)
addToggleElement(soruCard, "Infinite Soru", SoruInfinitoEnabled, 24, function(v)
    SoruInfinitoEnabled = v
    if player.Character then enforceSoru(player.Character) end
end, "InfSoru")
addToggleElement(soruCard, "Soru Aimbot (TP)", SoruAimbotEnabled, 48, function(v) SoruAimbotEnabled = v end, "SoruAimbot")

setPortalSoruState, portalSoruBtn = addToggleElement(soruCard, "Portal Soru Combo", PortalSoruEnabled, 72, function(v)
    PortalSoruEnabled = v
    PortalSoruWidgetVisible = v
    updateWidgetsVisuals()
end, "PortalSoru")
addStepper(soruCard, "Portal Soru Delay:", 94, 0.05, 2.0, 0.35, function() return _G.G_PortalSoruDelay or 0.35 end, function(v) _G.G_PortalSoruDelay = v end, "s")

addToggleElement(soruCard, "Portal Sanguine C Combo", PortalSanguineCEnabled, 122, function(v)
    PortalSanguineCEnabled = v
end, "PortalSanguineC")
addStepper(soruCard, "Sanguine C Delay:", 144, 0.05, 2.0, 0.35, function() return _G.G_PortalSanguineCDelay or 0.35 end, function(v) _G.G_PortalSanguineCDelay = v end, "s")

-- Trigger Selector Button for Portal Sanguine C Combo
local triggerSelectBtn = Instance.new("TextButton", soruCard)
triggerSelectBtn.Size = UDim2.new(1, -16, 0, 24)
triggerSelectBtn.Position = UDim2.new(0, 8, 0, 176)
triggerSelectBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
triggerSelectBtn.BackgroundTransparency = 1 -- 100% Transparente sin recuadro negro!
triggerSelectBtn.Text = "⚡ Trigger: " .. (PortalSanguineCTriggerMode == "PortalF" and "Portal F Skill" or "Soru / Flashstep")
triggerSelectBtn.Font = Enum.Font.GothamBold
triggerSelectBtn.TextSize = 8.5
triggerSelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
triggerSelectBtn.TextStrokeTransparency = 0
triggerSelectBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Instance.new("UICorner", triggerSelectBtn).CornerRadius = UDim.new(0, 6)
local trgStroke = Instance.new("UIStroke", triggerSelectBtn)
trgStroke.Color = currentThemeColor
trgStroke.Thickness = 1
table.insert(themeStrokes, trgStroke)

triggerSelectBtn.MouseButton1Click:Connect(function()
    if PortalSanguineCTriggerMode == "PortalF" then
        PortalSanguineCTriggerMode = "Soru"
        triggerSelectBtn.Text = "⚡ Trigger: Soru / Flashstep"
    else
        PortalSanguineCTriggerMode = "PortalF"
        triggerSelectBtn.Text = "⚡ Trigger: Portal F Skill"
    end
end)

-- Flashstep Skill Combo Module Card
local flashstepCard = createModuleCard("Flashstep Skill Combo", 135, SoruPage)
addToggleElement(flashstepCard, "Flashstep Skill Combo", _G.G_FlashstepSkillEnabled, 24, function(v)
    _G.G_FlashstepSkillEnabled = v
end, "FlashstepSkill")

local weaponSelectBtn = Instance.new("TextButton", flashstepCard)
weaponSelectBtn.Size = UDim2.new(1, -16, 0, 24)
weaponSelectBtn.Position = UDim2.new(0, 8, 0, 48)
weaponSelectBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
weaponSelectBtn.BackgroundTransparency = 1 -- 100% Transparente
weaponSelectBtn.Text = "🗡️ Weapon: " .. (_G.G_FlashstepSkillWeapon or "Fruit")
weaponSelectBtn.Font = Enum.Font.GothamBold
weaponSelectBtn.TextSize = 8.5
weaponSelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
weaponSelectBtn.TextStrokeTransparency = 0
weaponSelectBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Instance.new("UICorner", weaponSelectBtn).CornerRadius = UDim.new(0, 6)
local wSt = Instance.new("UIStroke", weaponSelectBtn)
wSt.Color = currentThemeColor
wSt.Thickness = 1
table.insert(themeStrokes, wSt)

weaponSelectBtn.MouseButton1Click:Connect(function()
    local wList = {"Melee", "Fruit", "Sword", "Gun"}
    local curIdx = table.find(wList, _G.G_FlashstepSkillWeapon) or 2
    local nxtIdx = (curIdx % #wList) + 1
    _G.G_FlashstepSkillWeapon = wList[nxtIdx]
    weaponSelectBtn.Text = "🗡️ Weapon: " .. wList[nxtIdx]
end)

local keySelectBtn = Instance.new("TextButton", flashstepCard)
keySelectBtn.Size = UDim2.new(1, -16, 0, 24)
keySelectBtn.Position = UDim2.new(0, 8, 0, 76)
keySelectBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
keySelectBtn.BackgroundTransparency = 1 -- 100% Transparente
keySelectBtn.Text = "⌨️ Skill Key: " .. (_G.G_FlashstepSkillKey or "Z")
keySelectBtn.Font = Enum.Font.GothamBold
keySelectBtn.TextSize = 8.5
keySelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keySelectBtn.TextStrokeTransparency = 0
keySelectBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Instance.new("UICorner", keySelectBtn).CornerRadius = UDim.new(0, 6)
local kSt = Instance.new("UIStroke", keySelectBtn)
kSt.Color = currentThemeColor
kSt.Thickness = 1
table.insert(themeStrokes, kSt)

keySelectBtn.MouseButton1Click:Connect(function()
    local kList = {"Z", "X", "C", "V", "F"}
    local curIdx = table.find(kList, _G.G_FlashstepSkillKey) or 1
    local nxtIdx = (curIdx % #kList) + 1
    _G.G_FlashstepSkillKey = kList[nxtIdx]
    keySelectBtn.Text = "⌨️ Skill Key: " .. kList[nxtIdx]
end)

addStepper(flashstepCard, "Skill Delay:", 104, 0.05, 2.0, 0.3, function() return _G.G_FlashstepSkillDelay or 0.3 end, function(v) _G.G_FlashstepSkillDelay = v end, "s")

function refreshPlayerListUI()
    for _, item in ipairs(ListScroll:GetChildren()) do
        if item:IsA("TextButton") and item.Name ~= "DropLabel" and item.Name ~= "RefreshBtn" then
            item:Destroy()
        end
    end

    local nearestBtn = Instance.new("TextButton", ListScroll)
    nearestBtn.Name = "NearestBtn"
    nearestBtn.Size = UDim2.new(1, 0, 0, 24)
    nearestBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    nearestBtn.BackgroundTransparency = 1 -- 100% Transparente
    nearestBtn.Text = (currentLang == "ES" and "🎯 Target: Más Cercano" or "🎯 Target: Nearest")
    nearestBtn.Font = Enum.Font.GothamBold
    nearestBtn.TextSize = 10
    nearestBtn.TextColor3 = (SelectedSoruTarget == "Nearest") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 60, 60)
    nearestBtn.TextStrokeTransparency = 0
    nearestBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Instance.new("UICorner", nearestBtn).CornerRadius = UDim.new(0, 5)
    local nSt = Instance.new("UIStroke", nearestBtn)
    nSt.Color = (SelectedSoruTarget == "Nearest") and Color3.fromRGB(255, 255, 255) or currentThemeColor
    nSt.Thickness = 1.2
    table.insert(themeStrokes, nSt)

    nearestBtn.MouseButton1Click:Connect(function()
        SelectedSoruTarget = "Nearest"
        DropLabel.Text = (currentLang == "ES" and "🎯 Target: Más Cercano" or "🎯 Target: Nearest")
        refreshPlayerListUI()
    end)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local isSelected = (SelectedSoruTarget == p.Name)
            local pBtn = Instance.new("TextButton", ListScroll)
            pBtn.Name = "PlayerBtn"
            pBtn.Size = UDim2.new(1, 0, 0, 24)
            pBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            pBtn.BackgroundTransparency = 1 -- 100% Transparente
            pBtn.Text = "👤 " .. p.Name
            pBtn.Font = Enum.Font.GothamBold
            pBtn.TextSize = 10
            pBtn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 60, 60)
            pBtn.TextStrokeTransparency = 0
            pBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 5)
            local pSt = Instance.new("UIStroke", pBtn)
            pSt.Color = isSelected and Color3.fromRGB(255, 255, 255) or currentThemeColor
            pSt.Thickness = 1.2
            table.insert(themeStrokes, pSt)

            pBtn.MouseButton1Click:Connect(function()
                SelectedSoruTarget = p.Name
                DropLabel.Text = "🎯 Target: " .. p.Name
                refreshPlayerListUI()
            end)
        end
    end

    if not ListScroll:FindFirstChild("RefreshBtn") then
        local refreshBtn = Instance.new("TextButton", ListScroll)
        refreshBtn.Name = "RefreshBtn"
        refreshBtn.Size = UDim2.new(1, 0, 0, 24)
        refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        refreshBtn.BackgroundTransparency = 1 -- 100% Transparente
        refreshBtn.Text = (currentLang == "ES" and "⟳ Actualizar Lista" or "⟳ Refresh List")
        refreshBtn.Font = Enum.Font.GothamBold
        refreshBtn.TextSize = 9.5
        refreshBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
        refreshBtn.TextStrokeTransparency = 0
        refreshBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 5)
        local rfSt = Instance.new("UIStroke", refreshBtn)
        rfSt.Color = currentThemeColor
        rfSt.Thickness = 1.2
        table.insert(themeStrokes, rfSt)
        refreshBtn.MouseButton1Click:Connect(refreshPlayerListUI)
    end
end

Players.PlayerAdded:Connect(refreshPlayerListUI)
Players.PlayerRemoving:Connect(refreshPlayerListUI)
DropLabel.MouseButton1Click:Connect(function()
    SelectedSoruTarget = "Nearest"
    DropLabel.Text = "🎯 Selector: Nearest"
    refreshPlayerListUI()
end)
refreshPlayerListUI()

-- ============================================================
-- NUEVAS PÁGINAS (APPEARANCE, BLACKLIST, MISC)
-- ============================================================
-- FPS/Ping Overlay
local fpsOverlayGui = Instance.new("ScreenGui")
fpsOverlayGui.Name = "SacredUI_FPSOverlay"
fpsOverlayGui.ResetOnSpawn = false
fpsOverlayGui.Parent = playerGui

local fpsBar = Instance.new("Frame", fpsOverlayGui)
fpsBar.Size = UDim2.new(0, 180, 0, 22)
fpsBar.Position = UDim2.new(0.5, -90, 0, 0)
fpsBar.BackgroundColor3 = Color3.fromRGB(10, 8, 14)
fpsBar.BackgroundTransparency = 0.3
fpsBar.Visible = false
Instance.new("UICorner", fpsBar).CornerRadius = UDim.new(0, 6)
local fpsStroke = Instance.new("UIStroke", fpsBar)
fpsStroke.Color = currentThemeColor
fpsStroke.Thickness = 1
table.insert(themeStrokes, fpsStroke)

local fpsLabel = Instance.new("TextLabel", fpsBar)
fpsLabel.Size = UDim2.new(1, 0, 1, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 0 | Ping: 0ms"
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 10
fpsLabel.TextColor3 = COLORS.TextWhite
table.insert(themeTexts, fpsLabel)

spawn(function()
    while true do
        wait(0.5)
        if FPSPingOverlayEnabled then
            fpsBar.Visible = true
            fpsLabel.Text = "FPS: " .. tostring(currentFPS) .. " | Ping: " .. tostring(currentPing) .. "ms"
        else
            fpsBar.Visible = false
        end
    end
end)

end

-- Appearance Page
do
local bgSelectorCard = createModuleCard("UI Background Selector", 65, AppearancePage)

local bgOptions = {
    { name = "Anime 1 (79345150236270)", id = "rbxassetid://79345150236270" },
    { name = "Anime 2 (91081822837053)", id = "rbxassetid://91081822837053" },
    { name = "Anime 3 (109470605984573)", id = "rbxassetid://109470605984573" },
    { name = "Anime 4 (135204446064109)", id = "rbxassetid://135204446064109" },
    { name = "Anime 5 (133381969265590)", id = "rbxassetid://133381969265590" },
    { name = "Anime 6 (102851043691652)", id = "rbxassetid://102851043691652" },
    { name = "Anime 7 (134915662604167)", id = "rbxassetid://134915662604167" },
    { name = "Anime 8 (132404081379154)", id = "rbxassetid://132404081379154" },
    { name = "None", id = "none" }
}

local currentBgIdx = 8

local bgSelectorBtn = Instance.new("TextButton", bgSelectorCard)
bgSelectorBtn.Size = UDim2.new(1, -16, 0, 26)
bgSelectorBtn.Position = UDim2.new(0, 8, 0, 22)
bgSelectorBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bgSelectorBtn.BackgroundTransparency = 1 -- 100% Transparente sin recuadro negro/gris!
bgSelectorBtn.Text = "📷 Wallpaper: " .. bgOptions[8].name
bgSelectorBtn.Font = Enum.Font.GothamBold
bgSelectorBtn.TextSize = 9
bgSelectorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
bgSelectorBtn.TextStrokeTransparency = 0
bgSelectorBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Instance.new("UICorner", bgSelectorBtn).CornerRadius = UDim.new(0, 6)
local bgBtnStroke = Instance.new("UIStroke", bgSelectorBtn)
bgBtnStroke.Color = currentThemeColor
bgBtnStroke.Thickness = 1
table.insert(themeStrokes, bgBtnStroke)

bgSelectorBtn.MouseButton1Click:Connect(function()
    currentBgIdx = (currentBgIdx % #bgOptions) + 1
    local selected = bgOptions[currentBgIdx]
    bgSelectorBtn.Text = (currentLang == "ES" and "📷 Fondo: " or "📷 Wallpaper: ") .. selected.name
    if selected.id == "none" then
        bgImageFrame.Visible = false
        toggleBG.Visible = false
    else
        bgImageFrame.Visible = true
        bgImageFrame.Image = selected.id
        toggleBG.Visible = true
        toggleBG.Image = selected.id
        pcall(function() game:GetService("ContentProvider"):PreloadAsync({bgImageFrame, toggleBG}) end)
    end
end)

local fakeBodyCard = createModuleCard("Fake Body", 75, AppearancePage)
addToggleElement(fakeBodyCard, "Fake Korblox", FakeKorbloxEnabled, 24, function(v)
    FakeKorbloxEnabled = v
    if v then applyFakeKorblox(player.Character) else removeFakeKorblox(player.Character) end
end, "FakeKorblox")
addToggleElement(fakeBodyCard, "Fake Headless", FakeHeadlessEnabled, 48, function(v)
    FakeHeadlessEnabled = v
    if v then applyFakeHeadless(player.Character) else removeFakeHeadless(player.Character) end
end, "FakeHeadless")

local auraCard = createModuleCard("Aura VFX", 150, AppearancePage)
local auraSetters = {}
local auraNames = {"Inferno", "Electric", "DarkSpirit", "Toxic", "Frost"}
local auraIcons = {"🔥", "⚡", "💜", "💚", "❄️"}

for i, auraName in ipairs(auraNames) do
    local yPos = 24 + (i - 1) * 24
    local setter, btn = addToggleElement(auraCard, auraIcons[i] .. " " .. auraName, false, yPos, function(v)
        if v then
            for j, otherName in ipairs(auraNames) do
                if otherName ~= auraName and auraSetters[otherName] then
                    auraSetters[otherName](false)
                end
            end
            ApplyAura(auraName)
        else
            ClearAura()
        end
    end)
    auraSetters[auraName] = setter
end

-- UI Theme Colors Card (100% Transparent Buttons with Neon Border)
local themeColorsCard = createModuleCard("UI Theme Colors", 125, AppearancePage)

local themeBtnList = {
    { name = "Snow White", label = "White", color = Color3.fromRGB(255, 255, 255) },
    { name = "Neon Purple", label = "Purple", color = Color3.fromRGB(170, 0, 255) },
    { name = "Electric Blue", label = "Blue", color = Color3.fromRGB(0, 150, 255) },
    { name = "Crimson Red", label = "Red", color = Color3.fromRGB(255, 0, 50) },
    { name = "Toxic Green", label = "Toxic", color = Color3.fromRGB(0, 255, 100) },
    { name = "Hot Pink", label = "Pink", color = Color3.fromRGB(255, 0, 255) },
    { name = "Gold Yellow", label = "Gold", color = Color3.fromRGB(255, 215, 0) },
    { name = "Cyan", label = "Cyan", color = Color3.fromRGB(0, 255, 255) },
    { name = "Orange", label = "Orange", color = Color3.fromRGB(255, 140, 0) }
}

for idx, tData in ipairs(themeBtnList) do
    local tBtn = Instance.new("TextButton", themeColorsCard)
    tBtn.Size = UDim2.new(0.29, 0, 0, 22)
    local row = math.floor((idx - 1) / 3)
    local col = (idx - 1) % 3
    tBtn.Position = UDim2.new(0.03 + (col * 0.32), 0, 0, 26 + (row * 28))
    tBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    tBtn.BackgroundTransparency = 1 -- 100% Transparente sin recuadros negros/grises!
    tBtn.ClipsDescendants = true
    tBtn.Text = tData.label
    tBtn.Font = Enum.Font.GothamBold
    tBtn.TextSize = 8.5
    tBtn.TextColor3 = tData.color
    tBtn.TextStrokeTransparency = 0
    tBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 5)
    local tStr = Instance.new("UIStroke", tBtn)
    tStr.Color = tData.color
    tStr.Thickness = 1.2

    tBtn.MouseButton1Click:Connect(function()
        if applyNewTheme then
            applyNewTheme(tData.name)
        else
            currentThemeColor = tData.color
            for _, s in ipairs(themeStrokes) do if s and s.Parent then s.Color = currentThemeColor end end
            for _, t in ipairs(themeTexts) do if t and t.Parent then t.TextColor3 = currentThemeColor end end
            for _, f in ipairs(themeFrames) do if f and f.Parent then f.BackgroundColor3 = currentThemeColor end end
        end
    end)
end

-- Ambient Lights Customizer (Luces Ambientes de Blox Fruits)
local skyCard = createModuleCard("Ambient Lights / Luces Ambientes", 100, AppearancePage)

function setBloxSkyColor(colorName, skyColor, outdoorColor)
    pcall(function()
        local lighting = game:GetService("Lighting")
        local sky = lighting:FindFirstChildOfClass("Sky")
        if not sky then
            sky = Instance.new("Sky", lighting)
        end

        if colorName == "Reset" then
            lighting.Ambient = Color3.fromRGB(120, 120, 120)
            lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
            lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
            return
        end

        lighting.Ambient = skyColor
        lighting.OutdoorAmbient = outdoorColor or skyColor
        lighting.ColorShift_Top = skyColor
    end)
end

local skyBtnGrid = {
    {name = "🌸 Pink", color = Color3.fromRGB(255, 105, 180)},
    {name = "💜 Purple", color = Color3.fromRGB(150, 50, 250)},
    {name = "🔴 Crimson", color = Color3.fromRGB(255, 40, 40)},
    {name = "🌌 Blue", color = Color3.fromRGB(0, 120, 255)},
    {name = "🌅 Gold", color = Color3.fromRGB(255, 180, 0)},
    {name = "🔄 Reset", color = Color3.fromRGB(200, 200, 200)}
}

for idx, item in ipairs(skyBtnGrid) do
    local sBtn = Instance.new("TextButton", skyCard)
    sBtn.Size = UDim2.new(0.3, 0, 0, 22)
    local row = math.floor((idx - 1) / 3)
    local col = (idx - 1) % 3
    sBtn.Position = UDim2.new(0.03 + (col * 0.32), 0, 0, 26 + (row * 28))
    sBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    sBtn.BackgroundTransparency = 1 -- 100% Transparente sin recuadro de color atras!
    sBtn.Text = item.name
    sBtn.Font = Enum.Font.GothamBold
    sBtn.TextSize = 8.5
    sBtn.TextColor3 = item.color
    sBtn.TextStrokeTransparency = 0
    sBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Instance.new("UICorner", sBtn).CornerRadius = UDim.new(0, 5)
    local skyStroke = Instance.new("UIStroke", sBtn)
    skyStroke.Color = item.color
    skyStroke.Thickness = 1.2

    sBtn.MouseButton1Click:Connect(function()
        if item.name:find("Reset") then
            setBloxSkyColor("Reset")
        else
            setBloxSkyColor(item.name, item.color, item.color)
        end
    end)
end
-- Songs Page
do
local songsNoticeCard = createModuleCard("Songs Notice", 50, SongsPage)
songNoticeLbl = Instance.new("TextLabel", songsNoticeCard)
songNoticeLbl.Size = UDim2.new(1, -16, 0, 26)
songNoticeLbl.Position = UDim2.new(0, 8, 0, 18)
songNoticeLbl.BackgroundTransparency = 1
songNoticeLbl.Text = (currentLang == "ES" and "⚠️ Aviso: Las canciones tienen sonidos raros al principio" or "⚠️ Notice: Songs may have strange sounds at the beginning")
songNoticeLbl.Font = Enum.Font.GothamBold
songNoticeLbl.TextSize = 8.5
songNoticeLbl.TextColor3 = Color3.fromRGB(255, 200, 80)
songNoticeLbl.TextWrapped = true

local songsData = {
    { name = "nuts (Original)", id = "139982007364841" }
}

local currentPlayingSound = nil
local activeSongToggles = {}

local function stopCurrentSong()
    if currentPlayingSound then
        pcall(function()
            currentPlayingSound:Stop()
            currentPlayingSound:Destroy()
        end)
        currentPlayingSound = nil
    end
end

for _, sInfo in ipairs(songsData) do
    local card = createModuleCard(sInfo.name, 50, SongsPage)
    local songToggle = addToggleElement(card, sInfo.name, false, 24, function(v)
        if v then
            stopCurrentSong()
            for otherName, toggleFn in pairs(activeSongToggles) do
                if otherName ~= sInfo.name then
                    pcall(function() toggleFn(false) end)
                end
            end
            local snd = Instance.new("Sound")
            snd.Name = "SacredSong_" .. sInfo.name
            snd.SoundId = "rbxassetid://" .. sInfo.id
            snd.Volume = 1
            snd.Looped = true
            snd.Parent = game:GetService("SoundService")
            pcall(function() snd:Play() end)
            currentPlayingSound = snd
        else
            if currentPlayingSound and currentPlayingSound.Name == "SacredSong_" .. sInfo.name then
                stopCurrentSong()
            end
        end
    end, "Song_" .. sInfo.name)
    activeSongToggles[sInfo.name] = songToggle
end
end

do
local blacklistCard = createModuleCard("Silent Aim Blacklist", 30, BlacklistPage)

local refreshListBtn = Instance.new("TextButton", BlacklistPage)
refreshListBtn.Size = UDim2.new(1, -8, 0, 24)
refreshListBtn.Position = UDim2.new(0, 4, 0, 36)
refreshListBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
refreshListBtn.BackgroundTransparency = 1
refreshListBtn.Text = "⟳ Refresh Player List"
refreshListBtn.Font = Enum.Font.GothamBold
refreshListBtn.TextSize = 9.5
refreshListBtn.TextColor3 = currentThemeColor
Instance.new("UICorner", refreshListBtn).CornerRadius = UDim.new(0, 6)
local rfStroke = Instance.new("UIStroke", refreshListBtn)
rfStroke.Color = currentThemeColor
rfStroke.Thickness = 1
table.insert(themeStrokes, rfStroke)
table.insert(themeTexts, refreshListBtn)

local blacklistScroll = Instance.new("ScrollingFrame", BlacklistPage)
blacklistScroll.Size = UDim2.new(1, -8, 1, -70)
blacklistScroll.Position = UDim2.new(0, 4, 0, 64)
blacklistScroll.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blacklistScroll.BackgroundTransparency = 1
blacklistScroll.BorderSizePixel = 0
blacklistScroll.ScrollBarThickness = 4
blacklistScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
blacklistScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", blacklistScroll).CornerRadius = UDim.new(0, 6)
Instance.new("UIListLayout", blacklistScroll).Padding = UDim.new(0, 4)
Instance.new("UIPadding", blacklistScroll).PaddingTop = UDim.new(0, 6)

function refreshBlacklistUI()
    for _, item in ipairs(blacklistScroll:GetChildren()) do
        if item:IsA("Frame") or item:IsA("TextLabel") then item:Destroy() end
    end

    local loadLbl = Instance.new("TextLabel", blacklistScroll)
    loadLbl.Text = "Loading players..."
    loadLbl.Font = Enum.Font.GothamBold
    loadLbl.TextSize = 9
    loadLbl.TextColor3 = COLORS.TextGray
    loadLbl.Size = UDim2.new(1, 0, 0, 20)
    loadLbl.BackgroundTransparency = 1

    task.delay(0.1, function()
        loadLbl:Destroy()
        local count = 0
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                count = count + 1
                local isBlacklisted = BlacklistedPlayers[p.Name] == true
                local row = Instance.new("Frame", blacklistScroll)
                row.Size = UDim2.new(1, -10, 0, 26)
                row.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                row.BackgroundTransparency = 1
                row.BorderSizePixel = 0
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
                Instance.new("UIPadding", row).PaddingLeft = UDim.new(0, 8)
                local rowStroke = Instance.new("UIStroke", row)
                rowStroke.Color = currentThemeColor
                rowStroke.Thickness = 0.8
                rowStroke.Transparency = 0.4
                table.insert(themeStrokes, rowStroke)
                
                local nameL = Instance.new("TextLabel", row)
                nameL.Text = p.Name
                nameL.Font = Enum.Font.GothamSemibold
                nameL.TextSize = 9.5
                nameL.TextColor3 = isBlacklisted and Color3.fromRGB(255, 80, 80) or COLORS.TextWhite
                nameL.Size = UDim2.new(0.7, 0, 1, 0)
                nameL.BackgroundTransparency = 1
                nameL.TextXAlignment = Enum.TextXAlignment.Left
                
                local toggleBtn = Instance.new("TextButton", row)
                toggleBtn.Size = UDim2.new(0, 40, 0, 16)
                toggleBtn.Position = UDim2.new(1, -48, 0.5, -8)
                toggleBtn.BackgroundColor3 = isBlacklisted and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(0, 0, 0)
                toggleBtn.BackgroundTransparency = isBlacklisted and 0 or 1
                toggleBtn.Text = isBlacklisted and "BAN" or "OK"
                toggleBtn.Font = Enum.Font.GothamBold
                toggleBtn.TextSize = 7.5
                toggleBtn.TextColor3 = COLORS.TextWhite
                Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)
                local tRowStroke = Instance.new("UIStroke", toggleBtn)
                tRowStroke.Color = isBlacklisted and Color3.fromRGB(255, 60, 60) or currentThemeColor
                tRowStroke.Thickness = 1
                
                toggleBtn.MouseButton1Click:Connect(function()
                    BlacklistedPlayers[p.Name] = not (BlacklistedPlayers[p.Name] == true)
                    refreshBlacklistUI()
                end)
            end
        end
        if count == 0 then
            local emptyLbl = Instance.new("TextLabel", blacklistScroll)
            emptyLbl.Text = "No other players in server"
            emptyLbl.Font = Enum.Font.GothamSemibold
            emptyLbl.TextSize = 9
            emptyLbl.TextColor3 = COLORS.TextGray
            emptyLbl.Size = UDim2.new(1, 0, 0, 20)
            emptyLbl.BackgroundTransparency = 1
        end
    end)
end

refreshListBtn.MouseButton1Click:Connect(refreshBlacklistUI)
Players.PlayerAdded:Connect(refreshBlacklistUI)
Players.PlayerRemoving:Connect(refreshBlacklistUI)
end

-- Sacred VFX Page
do
local vfxMainCard = createModuleCard("Sacred VFX", 110, SacredVFXPage)

local vfxTitle = Instance.new("TextLabel", vfxMainCard)
vfxTitle.Text = "✨ SACRED VFX ✨"
vfxTitle.Font = Enum.Font.GothamBlack
vfxTitle.TextSize = 16
vfxTitle.TextColor3 = currentThemeColor
vfxTitle.Size = UDim2.new(1, -16, 0, 24)
vfxTitle.Position = UDim2.new(0, 8, 0, 20)
vfxTitle.BackgroundTransparency = 1
table.insert(themeTexts, vfxTitle)

local vfxWarning = Instance.new("TextLabel", vfxMainCard)
vfxWarning.Text = "⚠️ Puede dar lag en celulares de baja gama"
vfxWarning.Font = Enum.Font.GothamSemibold
vfxWarning.TextSize = 9
vfxWarning.TextColor3 = Color3.fromRGB(255, 180, 50)
vfxWarning.Size = UDim2.new(1, -16, 0, 16)
vfxWarning.Position = UDim2.new(0, 8, 0, 44)
vfxWarning.BackgroundTransparency = 1

local vfxActionBtn = Instance.new("TextButton", vfxMainCard)
vfxActionBtn.Size = UDim2.new(1, -20, 0, 28)
vfxActionBtn.Position = UDim2.new(0, 10, 0, 68)
vfxActionBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
vfxActionBtn.BackgroundTransparency = 1
vfxActionBtn.Text = "🚀 Activar Sacred VFX"
vfxActionBtn.Font = Enum.Font.GothamBold
vfxActionBtn.TextSize = 11
vfxActionBtn.TextColor3 = currentThemeColor
vfxActionBtn.TextStrokeTransparency = 0.3
vfxActionBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Instance.new("UICorner", vfxActionBtn).CornerRadius = UDim.new(0, 8)
local vfxActionStroke = Instance.new("UIStroke", vfxActionBtn)
vfxActionStroke.Color = currentThemeColor
vfxActionStroke.Thickness = 1.5
table.insert(themeStrokes, vfxActionStroke)
table.insert(themeTexts, vfxActionBtn)

vfxActionBtn.MouseButton1Click:Connect(function()
    vfxActionBtn.Text = "⏳ Cargando Mod..."
    vfxActionBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/iSacredRivals/API.luarmor.net/main/Filesv3.loader"))()
        end)
        vfxActionBtn.Text = "✅ Sacred VFX Activado!"
        vfxActionBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    end)
end)

-- Grok AI Assistant Module
GrokAIEnabled = false

end

local fontCard = createModuleCard("Fonts", 50, MiscPage)

local fontList = { Enum.Font.GothamBold, Enum.Font.GothamBlack, Enum.Font.GothamSemibold, Enum.Font.Gotham, Enum.Font.SourceSansBold, Enum.Font.SourceSans, Enum.Font.Code, Enum.Font.Arcade }
local fontNames = { "GothamBold", "GothamBlack", "GothamSemibold", "Gotham", "SourceSansBold", "SourceSans", "Code", "Arcade" }
local uiFontIdx = 1

local function applyFontToGui(parentObj, fontEnum)
    if not parentObj then return end
    for _, obj in ipairs(parentObj:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            pcall(function() obj.Font = fontEnum end)
        end
    end
end

local uiFontBtn = Instance.new("TextButton", fontCard)
uiFontBtn.Size = UDim2.new(1, -20, 0, 24)
uiFontBtn.Position = UDim2.new(0, 10, 0, 22)
uiFontBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
uiFontBtn.BackgroundTransparency = 1
uiFontBtn.Text = "🔤 UI Font: " .. fontNames[uiFontIdx]
uiFontBtn.Font = Enum.Font.GothamBold
uiFontBtn.TextSize = 9.5
uiFontBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", uiFontBtn).CornerRadius = UDim.new(0, 6)
local uiFStroke = Instance.new("UIStroke", uiFontBtn)
uiFStroke.Color = currentThemeColor
uiFStroke.Thickness = 1.2
table.insert(themeStrokes, uiFStroke)
table.insert(themeTexts, uiFontBtn)

uiFontBtn.MouseButton1Click:Connect(function()
    uiFontIdx = (uiFontIdx % #fontList) + 1
    uiFontBtn.Text = "🔤 UI Font: " .. fontNames[uiFontIdx]
    local selectedFont = fontList[uiFontIdx]
    applyFontToGui(screenGui, selectedFont)
    applyFontToGui(toggleIconGui, selectedFont)
    applyFontToGui(playerWidgetGui, selectedFont)
    applyFontToGui(npcWidgetGui, selectedFont)
    applyFontToGui(superJumpWidgetGui, selectedFont)
    applyFontToGui(sanguineAutoWidgetGui, selectedFont)
    applyFontToGui(sanguineManualWidgetGui, selectedFont)
    applyFontToGui(soulGuitarWidgetGui, selectedFont)
    applyFontToGui(portalSoruWidgetGui, selectedFont)
end)

local langCard = createModuleCard("Language", 60, MiscPage)
langBtn = Instance.new("TextButton", langCard)
langBtn.Size = UDim2.new(1, -20, 0, 28)
langBtn.Position = UDim2.new(0, 10, 0, 24)
langBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
langBtn.BackgroundTransparency = 1 -- 100% Transparente sin recuadro negro/gris!
langBtn.Text = (currentLang == "ES" and "🌐 Idioma: Español (ES)" or "🌐 Language: English (EN)")
langBtn.Font = Enum.Font.GothamBold
langBtn.TextSize = 9.5
langBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
langBtn.TextStrokeTransparency = 0
langBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0, 6)
local langBtnStroke = Instance.new("UIStroke", langBtn)
langBtnStroke.Color = currentThemeColor
langBtnStroke.Thickness = 1.2
table.insert(themeStrokes, langBtnStroke)

langBtn.MouseButton1Click:Connect(function()
    local targetLang = (currentLang == "ES" and "EN" or "ES")
    updateUILanguage(targetLang)
    langBtn.Text = (currentLang == "ES" and "🌐 Idioma: Español (ES)" or "🌐 Language: English (EN)")
end)

local socialCard = createModuleCard("Socials & Settings", 205, MiscPage)

copyBtn = Instance.new("TextButton", socialCard)
copyBtn.Size = UDim2.new(1, -20, 0, 28)
copyBtn.Position = UDim2.new(0, 10, 0, 26)
copyBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
copyBtn.BackgroundTransparency = 1 -- 100% Transparente sin recuadro negro/gris!
copyBtn.Text = "💬 Copy Discord Link"
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 9.5
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.TextStrokeTransparency = 0
copyBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 8)
local copyStroke = Instance.new("UIStroke", copyBtn)
copyStroke.Color = currentThemeColor
copyStroke.Thickness = 1.2
table.insert(themeStrokes, copyStroke)

copyBtn.MouseButton1Click:Connect(function() 
    pcall(function() setclipboard("https://discord.gg/XuUb9xmpqK") end)
    copyBtn.Text = currentLang == "ES" and "✅ ¡Enlace Copiado!" or "✅ Discord Copied!"
    task.delay(1.5, function()
        copyBtn.Text = currentLang == "ES" and "💬 Copiar Enlace de Discord" or "💬 Copy Discord Link"
    end)
end)

copyTikTokBtn = Instance.new("TextButton", socialCard)
copyTikTokBtn.Size = UDim2.new(1, -20, 0, 28)
copyTikTokBtn.Position = UDim2.new(0, 10, 0, 60)
copyTikTokBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
copyTikTokBtn.BackgroundTransparency = 1 -- 100% Transparente sin recuadro negro/gris!
copyTikTokBtn.Text = "🎵 TikTok: @rivalsxrodx"
copyTikTokBtn.Font = Enum.Font.GothamBold
copyTikTokBtn.TextSize = 9.5
copyTikTokBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyTikTokBtn.TextStrokeTransparency = 0
copyTikTokBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Instance.new("UICorner", copyTikTokBtn).CornerRadius = UDim.new(0, 8)
local ttStroke = Instance.new("UIStroke", copyTikTokBtn)
ttStroke.Color = currentThemeColor
ttStroke.Thickness = 1.2
table.insert(themeStrokes, ttStroke)

copyTikTokBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://www.tiktok.com/@rivalsxrodx") end)
    copyTikTokBtn.Text = currentLang == "ES" and "✅ TikTok Copiado!" or "✅ TikTok Copied!"
    task.delay(1.5, function()
        copyTikTokBtn.Text = "🎵 TikTok: @rivalsxrodx"
    end)
end)

saveBtn = Instance.new("TextButton", socialCard)
saveBtn.Size = UDim2.new(1, -20, 0, 28)
saveBtn.Position = UDim2.new(0, 10, 0, 94)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
saveBtn.BackgroundTransparency = 1 -- 100% Transparente sin recuadro negro/gris!
saveBtn.Text = "💾 Save Config"
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 9.5
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.TextStrokeTransparency = 0
saveBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
local saveStroke = Instance.new("UIStroke", saveBtn)
saveStroke.Color = currentThemeColor
saveStroke.Thickness = 1.2
table.insert(themeStrokes, saveStroke)

saveBtn.MouseButton1Click:Connect(function() 
    pcall(SaveConfig)
    saveBtn.Text = currentLang == "ES" and "✅ Configuración Guardada!" or "✅ Config Saved!"
    task.delay(1.5, function()
        saveBtn.Text = currentLang == "ES" and "💾 Guardar Configuración" or "💾 Save Config"
    end)
end)

resetBtn = Instance.new("TextButton", socialCard)
resetBtn.Size = UDim2.new(1, -20, 0, 28)
resetBtn.Position = UDim2.new(0, 10, 0, 128)
resetBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
resetBtn.BackgroundTransparency = 1 -- 100% Transparente sin recuadro negro/gris!
resetBtn.Text = "🔄 Reset Config"
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 9.5
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.TextStrokeTransparency = 0
resetBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 8)
local resetStroke = Instance.new("UIStroke", resetBtn)
resetStroke.Color = currentThemeColor
resetStroke.Thickness = 1.2
table.insert(themeStrokes, resetStroke)
table.insert(themeTexts, resetBtn)

resetBtn.MouseButton1Click:Connect(function() 
    pcall(function() 
        if isfile and isfile("SacredAHK_Config.json") then delfile("SacredAHK_Config.json") end 
        if isfile and isfile("SacredAHK_Bounty.json") then delfile("SacredAHK_Bounty.json") end
    end)

    -- Restablecer todas las variables internas a defaults
    _G.G_ESPEnabled = false; _G.G_ESP_Name = true; _G.G_ESP_Level = true
    _G.G_ESP_Bounty = true; _G.G_ESP_Fruit = true; _G.G_ESP_Distance = true
    _G.G_ESP_HP = true; _G.G_ESP_Highlight = false; _G.G_ESP_TextSize = 12

    FastAttackEnabled = false; WalkSpeedEnabled = false; WalkSpeedValue = 16
    DashEnabled = false; DashLengthDist = 1; NoclipEnabled = false; WalkOnWaterEnabled = false
    SmartAutoV4Enabled = false; SuperJumpEnabled = false; SuperJumpPower = 500
    SanguineAutoEnabled = false; SanguineAutoDropDuration = 2.0
    if lagGui then lagGui:Destroy(); lagGui = nil end
    SoulGuitarJumpEnabled = false; SoulGuitarDashLength = 121
    _G.G_SilentAimTargetPlayers = false; _G.G_SilentAimTargetMobs = false
    _G.G_SilentAimSkill = false; _G.G_DragonGunM1 = false; _G.G_SilentAimTeamCheck = false
    _G.G_SilentAimShowFOV = false; _G.G_SilentAimShowLine = false
    AimlockPlayerEnabled = false; AimlockNpcEnabled = false
    SoruInfinitoEnabled = false; SoruAimbotEnabled = false; PortalSoruEnabled = false
    FakeKorbloxEnabled = false; FakeHeadlessEnabled = false; FPSPingOverlayEnabled = false
    AntiStunEnabled = false

    PlayerWidgetActive = false; NpcWidgetActive = false
    SanguineWidgetVisible = false; SoulGuitarWidgetVisible = false
    PortalSoruWidgetVisible = false; SuperJumpWidgetVisible = false

    -- Apagar todos los toggles visuales en UI de inmediato
    for _, fn in ipairs(UI_Toggle_Refreshes) do 
        pcall(function() fn(false) end) 
    end
    
    DisableESP()
    updateWidgetsVisuals()

    resetBtn.Text = "✅ Reseteado / Reset Done!"
    task.delay(1.5, function() resetBtn.Text = "🔄 Resetear Config / Reset Config" end)
end)

task.defer(function()
    pcall(updateLanguageUI)
end)
end

-- ============================================================
-- THEME SYSTEM & KEYBINDING HANDLERS
-- ============================================================
do
function isColorLight(c3)
    return (c3.R * 0.299 + c3.G * 0.587 + c3.B * 0.114) > 0.65
end

local rainbowConnection = nil

function applyNewTheme(themeName)
    currentThemeName = themeName
    if rainbowConnection then
        rainbowConnection:Disconnect()
        rainbowConnection = nil
    end

    currentThemeColor = THEMES[themeName] or THEMES["Snow White"]

    local function updateThemeColors(c3)
        currentThemeColor = c3

        for _, s in ipairs(themeStrokes) do 
            if s and s.Parent then s.Color = c3 end 
        end

        for _, f in ipairs(themeFrames) do 
            if f and f.Parent then 
                f.BackgroundColor3 = c3 
            end 
        end

        for _, t in ipairs(themeTexts) do 
            if t and t.Parent then
                t.TextColor3 = Color3.fromRGB(255, 255, 255)
                t.TextStrokeTransparency = 0 -- 100% Borde negro nítido!
                t.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            end 
        end

        if rainContainer then
            for _, drop in ipairs(rainContainer:GetChildren()) do
                if drop and drop:IsA("Frame") and drop.Name == "RainDrop" then
                    pcall(function() drop.BackgroundColor3 = c3 end)
                end
            end
        end
    end

    if string.find(string.lower(themeName), "rainbow") then
        local hue = 0
        rainbowConnection = RunService.Heartbeat:Connect(function(dt)
            hue = (hue + dt * 0.35) % 1
            local rgb = Color3.fromHSV(hue, 0.9, 1)
            updateThemeColors(rgb)
        end)
    else
        updateThemeColors(currentThemeColor)
    end

    updateWidgetsVisuals()
end

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.F4 then
        if mainFrame.Visible then
            mainFrame.Visible = false
            openButton.Visible = true
        else
            openButton.Visible = false
            centerAndMaximizeUI()
        end
    end
end)

updateWidgetsVisuals()
pcall(LoadConfig)
pcall(LoadMacroConfig)
centerAndMaximizeUI()
end


print("✅ SACRED AHK v12.5 LOADED - ALL TOGGLES AND CONFIGS 100% PERSISTENT")
