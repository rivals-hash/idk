--[[
    Darling Hub - Fast Attack (Fruits Too)
    High-performance attack bursts with full Fruit LeftClickRemote, Swords & Melee support
    All-black theme, zero emojis, zero Aurora branding
]]

local cloneref = cloneref or function(o) return o end
local function service(name) return cloneref(game:GetService(name)) end

local Players = service("Players")
local RunService = service("RunService")
local ReplicatedStorage = service("ReplicatedStorage")
local UserInputService = service("UserInputService")
local TweenService = service("TweenService")
local CoreGui = service("CoreGui")
local Workspace = service("Workspace")

local LocalPlayer = Players.LocalPlayer

getgenv().FastAttack_FruitsToo = getgenv().FastAttack_FruitsToo or {
    Enabled = false,
    AttackDelay = 0.08,
    AttackRange = 85,
    MaxTargets = 4,
}
local Config = getgenv().FastAttack_FruitsToo

local RegisterHit = nil
local RegisterAttack = nil
local lastRemoteCheck = 0
local lastFastAttackTime = 0
local lastHeartbeatTick = 0
local heartbeatConn = nil

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

        -- Blacklist check
        local p = Players:GetPlayerFromCharacter(model)
        if p and _G.DarlingBlacklistedPlayers and (_G.DarlingBlacklistedPlayers[p.UserId] or _G.DarlingBlacklistedPlayers[p.Name]) then
            return
        end

        local hum = model:FindFirstChildOfClass("Humanoid")
        local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
        local head = model:FindFirstChild("Head") or hrp
        if hum and hum.Health > 0 and hrp and head and (hrp.Position - myPos).Magnitude <= Config.AttackRange then
            table.insert(hitList, { model, head })
        end
    end

    local enemies = Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, npc in ipairs(enemies:GetChildren()) do
            checkEnemy(npc)
            if #hitList >= Config.MaxTargets then break end
        end
    end

    local chars = Workspace:FindFirstChild("Characters")
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

-- Floating Widget Integration (Universal UI)
local FastAttack = {
    Enabled = false,
    AttackDelay = 0.08,
    AttackRange = 85,
    MaxTargets = 4,
    Widget = nil,
}

local function getFloatingWidgetMod()
    local hub = _G.DarlingHub or (getgenv and getgenv().DarlingHub)
    if hub and hub.Require then
        local m = hub:Require("modules/pvp/floating_widget.lua")
        if m then return m end
    end
    return nil
end

local function getOrCreateWidget()
    if FastAttack.Widget then return FastAttack.Widget end
    local FW = getFloatingWidgetMod()
    if not FW then return nil end

    FastAttack.Widget = FW.create({
        Id = "FastAttackWidget",
        UIElementKey = "FastAttack",
        Label = "FAST ATK",
        Type = "Toggle",
        Visible = false,
        Default = Config.Enabled,
        Position = UDim2.new(0.5, -50, 0.16, 0),
        Callback = function(state)
            FastAttack.toggle(state)
        end
    })
    return FastAttack.Widget
end

local function toggleFastAttack(forceState)
    if forceState ~= nil then
        Config.Enabled = forceState
    else
        Config.Enabled = not Config.Enabled
    end
    FastAttack.Enabled = Config.Enabled

    local w = getOrCreateWidget()
    if w then
        w:SetState(Config.Enabled)
        w:SetVisible(Config.Enabled)
    end

    if _G.DarlingHub and _G.DarlingHub.UIElements and _G.DarlingHub.UIElements["FastAttack"] then
        pcall(function()
            _G.DarlingHub.UIElements["FastAttack"]:Set(Config.Enabled)
        end)
    end

    pcall(function()
        local WindUI = _G.DarlingHub and _G.DarlingHub.WindUI
        if WindUI and WindUI.Notify then
            WindUI:Notify({
                Title = "Fast Attack (Fruits Too)",
                Content = Config.Enabled and "Enabled (Fruits and Weapons active)" or "Disabled",
                Duration = 4,
            })
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        toggleFastAttack()
    end
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

local function startHeartbeatLoop()
    if heartbeatConn then return end
    heartbeatConn = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        local now = tick()
        if now - lastHeartbeatTick < Config.AttackDelay then return end
        lastHeartbeatTick = now
        executeFastAttackBurst()
    end)
end

local function stopHeartbeatLoop()
    if heartbeatConn then
        pcall(function() heartbeatConn:Disconnect() end)
        heartbeatConn = nil
    end
end

function FastAttack.enable()
    if FastAttack.Enabled then return end
    FastAttack.Enabled = true
    Config.Enabled = true
    resolveAttackRemotes()
    startHeartbeatLoop()
    local w = getOrCreateWidget()
    if w then
        w:SetState(true)
    end
    if _G.DarlingHub and _G.DarlingHub.UIElements and _G.DarlingHub.UIElements["FastAttack"] then
        pcall(function()
            _G.DarlingHub.UIElements["FastAttack"]:Set(true)
        end)
    end
end

function FastAttack.disable()
    if not FastAttack.Enabled and not Config.Enabled then return end
    FastAttack.Enabled = false
    Config.Enabled = false
    stopHeartbeatLoop()
    if FastAttack.Widget then
        FastAttack.Widget:SetState(false)
    end
    if _G.DarlingHub and _G.DarlingHub.UIElements and _G.DarlingHub.UIElements["FastAttack"] then
        pcall(function()
            _G.DarlingHub.UIElements["FastAttack"]:Set(false)
        end)
    end
end

function FastAttack.toggle(state)
    if state == nil then state = not Config.Enabled end
    if state then
        FastAttack.enable()
    else
        FastAttack.disable()
    end
    return Config.Enabled
end

function FastAttack.setFloatingVisible(visible)
    local w = getOrCreateWidget()
    if w and w.SetVisible then
        w:SetVisible(visible == true)
    end
end

return FastAttack
