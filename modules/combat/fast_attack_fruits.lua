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
    local isEnabled = Config.Enabled or (_G.DarlingX_FruitFastAttack == true)
    if not isEnabled then return end
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
    local isEnabled = Config.Enabled or (_G.DarlingX_FruitFastAttack == true)
    if not isEnabled then return end
    local now = tick()
    if now - lastHeartbeatTick < Config.AttackDelay then return end
    lastHeartbeatTick = now
    executeFastAttackBurst()
end)

local function hookTool(tool)
    if tool and tool:IsA("Tool") and tool.ToolTip ~= "Gun" then
        tool.Activated:Connect(function()
            local isEnabled = Config.Enabled or (_G.DarlingX_FruitFastAttack == true)
            if isEnabled then executeFastAttackBurst() end
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

local FruitFastAttack = {}

function FruitFastAttack.enable()
    Config.Enabled = true
    _G.DarlingX_FruitFastAttack = true
    local ew = rawget(_G, "DarlingX_ExtraWidgets")
    if ew and ew.SetFruitFastAttackWidgetVisible then
        ew.SetFruitFastAttackWidgetVisible(true)
        ew.UpdateFruitFastAttackVisual(true)
    end
    if _G.DarlingX_SyncFruitFastAttackUI then
        pcall(_G.DarlingX_SyncFruitFastAttackUI, true)
    end
end

function FruitFastAttack.disable()
    Config.Enabled = false
    _G.DarlingX_FruitFastAttack = false
    local ew = rawget(_G, "DarlingX_ExtraWidgets")
    if ew and ew.SetFruitFastAttackWidgetVisible then
        ew.SetFruitFastAttackWidgetVisible(false)
        ew.UpdateFruitFastAttackVisual(false)
    end
    if _G.DarlingX_SyncFruitFastAttackUI then
        pcall(_G.DarlingX_SyncFruitFastAttackUI, false)
    end
end

function FruitFastAttack.toggle(state)
    if state ~= nil then
        Config.Enabled = (state == true)
    else
        Config.Enabled = not Config.Enabled
    end
    _G.DarlingX_FruitFastAttack = Config.Enabled
    local ew = rawget(_G, "DarlingX_ExtraWidgets")
    if ew and ew.SetFruitFastAttackWidgetVisible then
        ew.SetFruitFastAttackWidgetVisible(Config.Enabled)
        ew.UpdateFruitFastAttackVisual(Config.Enabled)
    end
    if _G.DarlingX_SyncFruitFastAttackUI then
        pcall(_G.DarlingX_SyncFruitFastAttackUI, Config.Enabled)
    end
    return Config.Enabled
end

function FruitFastAttack.isEnabled()
    return Config.Enabled == true or _G.DarlingX_FruitFastAttack == true
end

-- Keybind listener (RightControl)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        FruitFastAttack.toggle()
    end
end)

_G.DarlingX_FruitFastAttackMod = FruitFastAttack
return FruitFastAttack
