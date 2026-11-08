--[[
    Monody - modules/combat/silent_aim.lua
    Silent Aim Engine (Mouse.Hit / Target redirection with Soru Silent support).
    Redirects camera/mouse aim directly towards target enemies.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

local SilentAim = {
    Enabled = false,
    SoruSilent = false,
    MaxDistance = 1000,
    TeamCheck = true,
    TargetPartName = "HumanoidRootPart", -- or "Head"
    CurrentTarget = nil,
    CurrentTargetPart = nil,
    CurrentTargetPosition = nil,
    IsHooked = false,
    RenderConn = nil,
}

local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0
end

local function getEnemyPlayers()
    local enemies = {}
    local lp = Players.LocalPlayer or LocalPlayer
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= lp and pl.Character and isAlive(pl.Character) then
            local isTeam = false
            if SilentAim.TeamCheck and pl.Team and lp.Team and pl.Team == lp.Team then
                isTeam = true
            end
            if not isTeam then
                table.insert(enemies, pl)
            end
        end
    end
    return enemies
end

-- Find nearest enemy within MaxDistance to Screen Center or Mouse
function SilentAim.findTarget()
    local lp = Players.LocalPlayer or LocalPlayer
    local lpChar = lp and lp.Character
    local lpHRP = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
    if not lpHRP then return nil, nil end

    local enemies = getEnemyPlayers()
    local nearestPl = nil
    local nearestPart = nil
    local shortestDist = SilentAim.MaxDistance

    for _, pl in ipairs(enemies) do
        local char = pl.Character
        local part = char:FindFirstChild(SilentAim.TargetPartName) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        if part then
            local worldDist = (part.Position - lpHRP.Position).Magnitude
            if worldDist <= shortestDist then
                shortestDist = worldDist
                nearestPl = pl
                nearestPart = part
            end
        end
    end

    return nearestPl, nearestPart
end

-- Target update cycle
local function updateTarget()
    if not SilentAim.Enabled and not SilentAim.SoruSilent then
        SilentAim.CurrentTarget = nil
        SilentAim.CurrentTargetPart = nil
        SilentAim.CurrentTargetPosition = nil
        return
    end

    local pl, part = SilentAim.findTarget()
    SilentAim.CurrentTarget = pl
    SilentAim.CurrentTargetPart = part
    if part then
        SilentAim.CurrentTargetPosition = part.Position
        _G.currentSilentAimTarget = part
        pcall(function()
            local RS = game:GetService("ReplicatedStorage")
            local mm = RS:FindFirstChild("Mouse")
            if mm and mm:IsA("ModuleScript") then
                local m = require(mm)
                if type(m) == "table" then
                    m.Hit = CFrame.new(part.Position)
                    m.Target = part
                end
            end
        end)
    else
        SilentAim.CurrentTargetPosition = nil
    end
end

-- Safe redirection without metamethod interception
function SilentAim.installHook()
    SilentAim.IsHooked = true
end

function SilentAim.start()
    SilentAim.installHook()
    if not SilentAim.RenderConn then
        SilentAim.RenderConn = RunService.RenderStepped:Connect(updateTarget)
    end
end

function SilentAim.stop()
    if not SilentAim.Enabled and not SilentAim.SoruSilent then
        if SilentAim.RenderConn then
            pcall(function() SilentAim.RenderConn:Disconnect() end)
            SilentAim.RenderConn = nil
        end
        SilentAim.CurrentTarget = nil
        SilentAim.CurrentTargetPart = nil
        SilentAim.CurrentTargetPosition = nil
        if _G.currentSilentAimTarget == SilentAim.CurrentTargetPart then
            _G.currentSilentAimTarget = nil
        end
    end
end

function SilentAim.setEnabled(state)
    SilentAim.Enabled = (state == true)
    if SilentAim.Enabled then
        SilentAim.start()
    else
        SilentAim.stop()
    end
end

function SilentAim.setSoruSilent(state)
    SilentAim.SoruSilent = (state == true)
    if SilentAim.SoruSilent then
        SilentAim.start()
    else
        SilentAim.stop()
    end
end

function SilentAim.setMaxDistance(dist)
    if type(dist) == "number" then
        SilentAim.MaxDistance = dist
    end
end

function SilentAim.setTeamCheck(state)
    SilentAim.TeamCheck = (state == true)
end

function SilentAim.getTarget()
    return SilentAim.CurrentTargetPart
end

_G.MonodySilentAim = SilentAim
if getgenv then
    pcall(function() getgenv().MonodySilentAim = SilentAim end)
end

return SilentAim
