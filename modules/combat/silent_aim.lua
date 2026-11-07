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
    else
        SilentAim.CurrentTargetPosition = nil
    end
end

-- Metamethod Hook for Mouse.Hit and Mouse.Target (Unified with Core)
local inHook = false
function SilentAim.installHook()
    if SilentAim.IsHooked then return end
    SilentAim.IsHooked = true

    -- If AimbotCore is active, let it handle the single unified hook
    local core = _G.MonodyCombatCore or _G.DarlingCombatCore
    if core and core.installHooks then
        pcall(core.installHooks)
        return
    end

    local mouse = LocalPlayer and LocalPlayer:GetMouse()
    if not mouse then return end

    if hookmetamethod then
        local oldIndex = nil
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if inHook then return oldIndex(self, key) end
            if (checkcaller and checkcaller()) then return oldIndex(self, key) end

            if self == mouse and (key == "Hit" or key == "Target") then
                inHook = true
                local target = SilentAim.CurrentTargetPart or _G.currentSilentAimTarget
                if (SilentAim.Enabled or SilentAim.SoruSilent) and target and target.Parent then
                    local tp = SilentAim.CurrentTargetPosition or target.Position
                    if tp and typeof(tp) == "Vector3" then
                        if key == "Hit" then
                            inHook = false
                            local cam = Workspace.CurrentCamera
                            local cp = cam and cam.CFrame.Position
                            if cp then
                                local look = (tp - cp)
                                if look.Magnitude > 0.001 then
                                    return CFrame.lookAt(tp, tp + look.Unit)
                                end
                            end
                            return CFrame.new(tp)
                        elseif key == "Target" then
                            inHook = false
                            return target
                        end
                    end
                end
                inHook = false
            end
            return oldIndex(self, key)
        end))
    end
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
