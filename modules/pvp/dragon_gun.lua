--[[
    Darling Hub - Dragon Gun M1 (Gun Aura)
    Rapid-fire Dragon Gun M1 bursts with auto-validation and target tracking.
    Exact M1 logic matching user specification.
    Single unified toggle and floating widget, zero startup display, zero emojis.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Variables de estado
_G.G_DragonGunM1 = false
_G.G_AttackMobs = true
_G.G_AttackPlayers = true

local DragonGun = {
    Enabled = false,
    Widget = nil,
    Keybind = Enum.KeyCode.G,
}

------------------ LOGICA M1 ------------------
local Modules = ReplicatedStorage:FindFirstChild("Modules") or ReplicatedStorage:WaitForChild("Modules", 3)
local DragonNet = (Modules and (Modules:FindFirstChild("Net") or Modules:WaitForChild("Net", 3))) or ReplicatedStorage:FindFirstChild("Net")
local ShootGunEvent = DragonNet and (DragonNet:FindFirstChild("RE/ShootGunEvent") or DragonNet:WaitForChild("RE/ShootGunEvent", 3))
local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:WaitForChild("Remotes", 3)
local Validator2 = Remotes and (Remotes:FindFirstChild("Validator2") or Remotes:WaitForChild("Validator2", 3))

local function resolveRemotes()
    if ShootGunEvent and Validator2 then return true end
    pcall(function()
        Modules = Modules or ReplicatedStorage:FindFirstChild("Modules") or ReplicatedStorage:WaitForChild("Modules", 2)
        DragonNet = DragonNet or (Modules and (Modules:FindFirstChild("Net") or Modules:WaitForChild("Net", 2)))
        ShootGunEvent = ShootGunEvent or (DragonNet and (DragonNet:FindFirstChild("RE/ShootGunEvent") or DragonNet:FindFirstChild("ShootGunEvent")))
        Remotes = Remotes or ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:WaitForChild("Remotes", 2)
        Validator2 = Validator2 or (Remotes and (Remotes:FindFirstChild("Validator2") or Remotes:FindFirstChild("Validator")))
    end)
    return (ShootGunEvent ~= nil)
end

local getupval = debug.getupvalue or getupvalue
local setupval = debug.setupvalue or setupvalue
local getupvals = debug.getupvalues or getupvalues

local ShootFunction
local V_Idx = { v26 = 12, v22 = 13, v25 = 14, v21 = 15, v23 = 16, v24 = 17, v27 = 18 }

local function InitDragonGun()
    if ShootFunction then return end
    pcall(function()
        local controllers = ReplicatedStorage:FindFirstChild("Controllers") or ReplicatedStorage:WaitForChild("Controllers", 3)
        local combatCtrl = controllers and (controllers:FindFirstChild("CombatController") or controllers:WaitForChild("CombatController", 3))
        if combatCtrl then
            local success, result = pcall(require, combatCtrl)
            if success and type(result) == "table" and result.Attack then
                ShootFunction = getupval(result.Attack, 9)
            end
        end
    end)
end

local function GetNextValidator()
    if not ShootFunction then InitDragonGun() end
    if not ShootFunction then return 0, 0 end
    local upvals = getupvals(ShootFunction)
    if not upvals then return 0, 0 end
    if upvals[V_Idx.v21] ~= 727595 then
        for i, v in pairs(upvals) do
            if v == 727595 then
                local offset = i - 15
                V_Idx.v21 = i
                V_Idx.v22 = 13 + offset
                V_Idx.v23 = 16 + offset
                V_Idx.v24 = 17 + offset
                V_Idx.v26 = 12 + offset
                V_Idx.v25 = 14 + offset
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

local function GetClosestTarget()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, dist = nil, math.huge
    local myPos = root.Position

    if _G.G_AttackMobs then
        local enemies = Workspace:FindFirstChild("Enemies")
        if enemies then
            for _, enemy in ipairs(enemies:GetChildren()) do
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                local r = enemy:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and r then
                    local d = (r.Position - myPos).Magnitude
                    if d < dist then dist = d; closest = r end
                end
            end
        end
    end

    if _G.G_AttackPlayers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                local r = player.Character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and r then
                    local d = (r.Position - myPos).Magnitude
                    if d < dist then dist = d; closest = r end
                end
            end
        end
    end
    return closest
end

local function isGunTool(item)
    if not (item and item:IsA("Tool")) then return false end
    if item:GetAttribute("WeaponType") == "Gun" then return true end
    local tip = string.lower(item.ToolTip or "")
    local name = string.lower(item.Name or "")
    if tip == "gun" or tip:find("gun") then return true end
    return name:find("gun") ~= nil or name:find("guitar") ~= nil
        or name:find("rifle") ~= nil or name:find("cannon") ~= nil
        or name:find("bow") ~= nil or name:find("kabucha") ~= nil
        or name:find("slingshot") ~= nil or name:find("bazooka") ~= nil
        or name:find("musket") ~= nil or name:find("flintlock") ~= nil
        or name:find("blaster") ~= nil
end

-- Bucle principal de disparo (dispara SOLO si el arma en mano es una pistola, 0.085s activo, 0.5s inactivo)
task.spawn(function()
    while true do
        if not (_G.G_DragonGunM1 or DragonGun.Enabled) then
            task.wait(0.5)
        else
            task.wait(0.085)
            if _G.G_DragonGunM1 or DragonGun.Enabled then
                pcall(function()
                    local char = LocalPlayer.Character
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if not tool or not isGunTool(tool) then return end
                    local target = GetClosestTarget()
                    if not target then return end
                    resolveRemotes()
                    local code, count = GetNextValidator()
                    if code ~= 0 and Validator2 then
                        Validator2:FireServer(code, count)
                    end
                    pcall(function()
                        tool:SetAttribute("LocalOverheat", 0)
                        local cur = tool:GetAttribute("LocalTotalShots") or 0
                        tool:SetAttribute("LocalTotalShots", cur + 1)
                    end)
                    if ShootGunEvent then
                        ShootGunEvent:FireServer(target.Position, { target })
                    end
                end)
            end
        end
    end
end)

------------------ INTEGRACION CON WIDGET Y UI ------------------
local function getFloatingWidgetMod()
    local hub = _G.DarlingHub or (getgenv and getgenv().DarlingHub)
    if hub and hub.Require then
        return hub:Require("modules/pvp/floating_widget.lua")
    end
    return nil
end

local function getOrCreateWidget()
    if DragonGun.Widget then return DragonGun.Widget end
    local FW = getFloatingWidgetMod()
    if not FW then return nil end

    DragonGun.Widget = FW.create({
        Id = "DragonGunM1Widget",
        UIElementKey = "DragonGunM1",
        Label = "DRAGON M1",
        Type = "Toggle",
        Visible = false,
        Default = false,
        Position = UDim2.new(0.04, 0, 0.22, 0),
        Callback = function(state)
            DragonGun.toggle(state)
        end
    })
    return DragonGun.Widget
end

function DragonGun.enable()
    if DragonGun.Enabled then return end
    DragonGun.Enabled = true
    _G.G_DragonGunM1 = true
    _G.G_AttackMobs = true
    _G.G_AttackPlayers = true
    resolveRemotes()
    InitDragonGun()

    local w = getOrCreateWidget()
    if w then
        w:SetState(true)
    end

    if _G.DarlingHub and _G.DarlingHub.UIElements and _G.DarlingHub.UIElements["DragonGunM1"] then
        pcall(function()
            _G.DarlingHub.UIElements["DragonGunM1"]:Set(true)
        end)
    end
end

function DragonGun.disable()
    if not DragonGun.Enabled and not _G.G_DragonGunM1 then return end
    DragonGun.Enabled = false
    _G.G_DragonGunM1 = false
    _G.G_AttackMobs = false
    _G.G_AttackPlayers = false

    if DragonGun.Widget then
        DragonGun.Widget:SetState(false)
    end

    if _G.DarlingHub and _G.DarlingHub.UIElements and _G.DarlingHub.UIElements["DragonGunM1"] then
        pcall(function()
            _G.DarlingHub.UIElements["DragonGunM1"]:Set(false)
        end)
    end
end

function DragonGun.toggle(state)
    if state == nil then
        state = not (_G.G_DragonGunM1 or DragonGun.Enabled)
    end
    if state then
        DragonGun.enable()
    else
        DragonGun.disable()
    end
    return DragonGun.Enabled
end

function DragonGun.setFloatingVisible(visible)
    local w = getOrCreateWidget()
    if w and w.SetVisible then
        w:SetVisible(visible == true)
    end
end

-- Keybind G Hook
if not DragonGun.InputConnection then
    DragonGun.InputConnection = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == DragonGun.Keybind then
            DragonGun.toggle()
        end
    end)
end

task.spawn(function()
    resolveRemotes()
    InitDragonGun()
end)

return DragonGun
