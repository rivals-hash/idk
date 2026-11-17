--[[
    Aurora X  --  Fast Attack (Fruits Too) [Standalone Edition]
    By Darling  •  Blox Fruits
    Archivo: /home/isacredrivals/.gemini/antigravity/scratch/aurora-x/FastAttack.lua
]]

local cloneref = cloneref or function(o) return o end
local function service(name) return cloneref(game:GetService(name)) end

local Players          = service("Players")
local RunService       = service("RunService")
local ReplicatedStorage= service("ReplicatedStorage")
local UserInputService = service("UserInputService")
local TweenService     = service("TweenService")
local CoreGui          = service("CoreGui")

local LocalPlayer = Players.LocalPlayer

getgenv().FastAttack_FruitsToo = getgenv().FastAttack_FruitsToo or {
    Enabled = true,
    AttackDelay = 0.08,
    AttackRange = 85,
    MaxTargets = 4,
}
local Config = getgenv().FastAttack_FruitsToo

local RegisterHit = nil
local RegisterAttack = nil
local lastRemoteCheck = 0

local function resolveAttackRemotes()
    if RegisterHit and RegisterAttack then return true end
    local now = tick()
    if now - lastRemoteCheck < 1 then return false end
    lastRemoteCheck = now

    pcall(function()
        local net = (ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net"))
            or ReplicatedStorage:FindFirstChild("Net")
        if net then
            RegisterHit = net:FindFirstChild("RE/RegisterHit") or net:FindFirstChild("RegisterHit") or net["RE/RegisterHit"]
            RegisterAttack = net:FindFirstChild("RE/RegisterAttack") or net:FindFirstChild("RegisterAttack") or net["RE/RegisterAttack"]
        end
        if not RegisterHit or not RegisterAttack then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then
                RegisterHit = RegisterHit or remotes:FindFirstChild("RE/RegisterHit") or remotes:FindFirstChild("RegisterHit")
                RegisterAttack = RegisterAttack or remotes:FindFirstChild("RE/RegisterAttack") or remotes:FindFirstChild("RegisterAttack")
            end
        end
        if not RegisterHit or not RegisterAttack then
            local common = ReplicatedStorage:FindFirstChild("Common")
            if common then
                RegisterHit = RegisterHit or common:FindFirstChild("RE/RegisterHit") or common:FindFirstChild("RegisterHit")
                RegisterAttack = RegisterAttack or common:FindFirstChild("RE/RegisterAttack") or common:FindFirstChild("RegisterAttack")
            end
        end
        if not RegisterHit or not RegisterAttack then
            RegisterHit = RegisterHit or ReplicatedStorage:FindFirstChild("RE/RegisterHit") or ReplicatedStorage:FindFirstChild("RegisterHit")
            RegisterAttack = RegisterAttack or ReplicatedStorage:FindFirstChild("RE/RegisterAttack") or ReplicatedStorage:FindFirstChild("RegisterAttack")
        end
    end)
    return (RegisterHit ~= nil and RegisterAttack ~= nil)
end

local lastFastAttackTime = 0
local function executeFastAttackBurst()
    if not Config.Enabled then return end
    local now = tick()
    if now - lastFastAttackTime < Config.AttackDelay then return end
    lastFastAttackTime = now

    local myChar = LocalPlayer.Character
    local myHRP = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar.PrimaryPart)
    if not myHRP then return end

    local currentTool = myChar:FindFirstChildOfClass("Tool")
    if not currentTool or currentTool.ToolTip == "Gun" then return end

    local isCasting = myChar:GetAttribute("isUsingSkill") or myChar:GetAttribute("UsingSkill") or myChar:GetAttribute("Busy")
    if isCasting == true then return end

    pcall(function()
        currentTool:SetAttribute("LocalOverheat", 0)
        currentTool:SetAttribute("Cooldown", 0)
    end)

    local myPos = myHRP.Position
    local hitList = {}

    local function checkEnemy(model)
        if not model or model == myChar then return end
        local hum = model:FindFirstChildOfClass("Humanoid")
        local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
        local head = model:FindFirstChild("Head") or hrp
        if hum and hum.Health > 0 and hrp and head and (hrp.Position - myPos).Magnitude <= Config.AttackRange then
            table.insert(hitList, { model, head })
        end
    end

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, npc in ipairs(enemies:GetChildren()) do
            checkEnemy(npc)
            if #hitList >= Config.MaxTargets then break end
        end
    end

    local chars = workspace:FindFirstChild("Characters")
    if chars and #hitList < Config.MaxTargets then
        for _, c in ipairs(chars:GetChildren()) do
            checkEnemy(c)
            if #hitList >= Config.MaxTargets then break end
        end
    end

    if #hitList < Config.MaxTargets then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                checkEnemy(p.Character)
                if #hitList >= Config.MaxTargets then break end
            end
        end
    end

    if #hitList > 0 then
        local primaryPart = hitList[1][2]
        local myLook = myHRP.CFrame.LookVector
        pcall(function()
            if currentTool:FindFirstChild("LeftClickRemote") then
                currentTool.LeftClickRemote:FireServer(myLook, 1)
            end
            if resolveAttackRemotes() then
                RegisterAttack:FireServer(0)
                RegisterHit:FireServer(primaryPart, hitList)
            end
        end)
    end
end

local lastHeartbeatTick = 0
RunService.Heartbeat:Connect(function()
    if not Config.Enabled then return end
    local now = tick()
    if now - lastHeartbeatTick < Config.AttackDelay then return end
    lastHeartbeatTick = now
    executeFastAttackBurst()
end)

local function hookTool(tool)
    if tool and tool:IsA("Tool") and tool.ToolTip ~= "Gun" then
        tool.Activated:Connect(function()
            if Config.Enabled then executeFastAttackBurst() end
        end)
    end
end

local function hookCharacter(char)
    if not char then return end
    local curTool = char:FindFirstChildOfClass("Tool")
    if curTool then hookTool(curTool) end
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then hookTool(child) end
    end)
end

if LocalPlayer.Character then hookCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hookCharacter)

-- GUI FLOTANTE
local GUI_NAME = "AuroraX_FastAttack_GUI"
local function getGuiParent()
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and h then return h end
    local ok2, c = pcall(function() return CoreGui end)
    if ok2 and c then return c end
    return LocalPlayer:WaitForChild("PlayerGui")
end

pcall(function()
    local old = getGuiParent():FindFirstChild(GUI_NAME)
    if old then old:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getGuiParent()

local Pill = Instance.new("TextButton")
Pill.Name = "FastAttackPill"
Pill.Size = UDim2.fromOffset(164, 38)
Pill.Position = UDim2.new(0.5, -82, 0.16, 0)
Pill.BackgroundColor3 = Color3.fromRGB(16, 12, 18)
Pill.BorderSizePixel = 0
Pill.AutoButtonColor = false
Pill.Text = ""
Pill.Active = true
Pill.Parent = ScreenGui

local PillCorner = Instance.new("UICorner", Pill)
PillCorner.CornerRadius = UDim.new(0, 19)

local PillStroke = Instance.new("UIStroke", Pill)
PillStroke.Color = Color3.fromRGB(60, 220, 110)
PillStroke.Thickness = 1.4

local StatusDot = Instance.new("Frame", Pill)
StatusDot.Name = "StatusDot"
StatusDot.Size = UDim2.fromOffset(10, 10)
StatusDot.Position = UDim2.fromOffset(14, 14)
StatusDot.BackgroundColor3 = Color3.fromRGB(60, 220, 110)
StatusDot.BorderSizePixel = 0
local DotCorner = Instance.new("UICorner", StatusDot)
DotCorner.CornerRadius = UDim.new(1, 0)

local TitleLabel = Instance.new("TextLabel", Pill)
TitleLabel.Name = "TitleLabel"
TitleLabel.Position = UDim2.fromOffset(32, 5)
TitleLabel.Size = UDim2.new(1, -34, 0, 16)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 11
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "Fast Attack: ON"

local SubLabel = Instance.new("TextLabel", Pill)
SubLabel.Name = "SubLabel"
SubLabel.Size = UDim2.new(1, -34, 0, 12)
SubLabel.Position = UDim2.fromOffset(32, 21)
SubLabel.BackgroundTransparency = 1
SubLabel.Font = Enum.Font.GothamMedium
SubLabel.TextSize = 8
SubLabel.TextColor3 = Color3.fromRGB(150, 145, 155)
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Text = "Fruits Too • By Darling"

local function updateButtonVisuals()
    if Config.Enabled then
        PillStroke.Color = Color3.fromRGB(60, 220, 110)
        StatusDot.BackgroundColor3 = Color3.fromRGB(60, 220, 110)
        TitleLabel.Text = "Fast Attack: ON"
        TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    else
        PillStroke.Color = Color3.fromRGB(220, 60, 70)
        StatusDot.BackgroundColor3 = Color3.fromRGB(220, 60, 70)
        TitleLabel.Text = "Fast Attack: OFF"
        TitleLabel.TextColor3 = Color3.fromRGB(180, 175, 185)
    end
end

local function toggleFastAttack()
    Config.Enabled = not Config.Enabled
    updateButtonVisuals()
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Fast Attack (Fruits Too)",
            Text = Config.Enabled and "Enabled (Fruits & Weapons active)" or "Disabled",
            Duration = 2,
        })
    end)
end

do
    local dragging, dragStart, startPos, moved = false, nil, nil, false
    Pill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved = true, false
            dragStart = input.Position
            startPos = Pill.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then moved = true end
            Pill.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                if not moved then toggleFastAttack() end
            end
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        toggleFastAttack()
    end
end)

updateButtonVisuals()
print("[Aurora X] Fast Attack (Fruits Too) Loaded By Darling")
