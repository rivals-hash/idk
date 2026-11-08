-- flashstep

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local FloatingWidget = nil
pcall(function()
    FloatingWidget = (_G.DarlingHub and _G.DarlingHub:Require("modules/pvp/floating_widget.lua"))
end)

local Flashstep = {
    InfiniteEnabled = false,
    AimbotEnabled = false,
    MaxDistance = 2000,
    TargetMode = "Nearest Player", -- "Nearest Player" or specific player name
    SelectedPlayer = nil,
    Widget = nil,
    CharConn = nil,
    AttrConn = nil,
    LoopRunning = false,
    Hooked = false,
}

local function getTarget()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    if Flashstep.TargetMode ~= "Nearest Player" and Flashstep.SelectedPlayer then
        local targetPlayer = Players:FindFirstChild(Flashstep.SelectedPlayer)
        if targetPlayer and targetPlayer.Character then
            local eHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local eHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if eHRP and eHum and eHum.Health > 0 then
                local dist = (myHRP.Position - eHRP.Position).Magnitude
                if dist <= Flashstep.MaxDistance then
                    return targetPlayer, eHRP
                end
            end
        end
    end

    -- Default: Nearest Player
    local closestDist = Flashstep.MaxDistance
    local bestPlayer, bestHRP = nil, nil

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local eHRP = p.Character:FindFirstChild("HumanoidRootPart")
            local eHum = p.Character:FindFirstChildOfClass("Humanoid")
            if eHRP and eHum and eHum.Health > 0 then
                local dist = (myHRP.Position - eHRP.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    bestPlayer = p
                    bestHRP = eHRP
                end
            end
        end
    end

    return bestPlayer, bestHRP
end

-- Safe Soru aimbot redirection without metamethod interception
local function setupMetamethodHook()
    Flashstep.Hooked = true
    if Flashstep.AimbotEnabled then
        local _, targetHRP = getTarget()
        if targetHRP then
            pcall(function()
                local RS = game:GetService("ReplicatedStorage")
                local mm = RS:FindFirstChild("Mouse")
                if mm and mm:IsA("ModuleScript") then
                    local m = require(mm)
                    if type(m) == "table" then
                        m.Hit = CFrame.new(targetHRP.Position)
                        m.Target = targetHRP
                    end
                end
            end)
        end
    end
end

function Flashstep.enforceInfinite(char)
    if not char then return end
    if Flashstep.InfiniteEnabled then
        pcall(function()
            char:SetAttribute("FlashstepCooldown", 1)
        end)
    end
    if Flashstep.AttrConn then
        pcall(function() Flashstep.AttrConn:Disconnect() end)
    end
    Flashstep.AttrConn = char.AttributeChanged:Connect(function(attr)
        if attr == "FlashstepCooldown" and Flashstep.InfiniteEnabled then
            if char:GetAttribute("FlashstepCooldown") ~= 1 then
                pcall(function() char:SetAttribute("FlashstepCooldown", 1) end)
            end
        end
    end)
end

function Flashstep.setInfinite(state)
    Flashstep.InfiniteEnabled = state
    local char = LocalPlayer.Character
    if char then
        Flashstep.enforceInfinite(char)
    end
    if state and not Flashstep.CharConn then
        Flashstep.CharConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
            task.wait(0.5)
            Flashstep.enforceInfinite(newChar)
        end)
    elseif not state and Flashstep.CharConn then
        pcall(function() Flashstep.CharConn:Disconnect() end)
        Flashstep.CharConn = nil
    end

    if state and not Flashstep.LoopRunning then
        Flashstep.LoopRunning = true
        task.spawn(function()
            while Flashstep.InfiniteEnabled do
                task.wait(0.5)
                local c = LocalPlayer.Character
                if c and c:GetAttribute("FlashstepCooldown") ~= 1 then
                    pcall(function() c:SetAttribute("FlashstepCooldown", 1) end)
                end
            end
            Flashstep.LoopRunning = false
        end)
    end
end

function Flashstep.setAimbot(state)
    Flashstep.AimbotEnabled = state
    if state then
        setupMetamethodHook()
        if not Flashstep.Widget and FloatingWidget then
            Flashstep.Widget = FloatingWidget.create({
                Id = "SoruAimbotWidget",
                Label = "TP",
                Type = "Toggle",
                Default = true,
                Position = UDim2.new(0.35, 0, 0.34, 0),
                AccentColor = Color3.fromRGB(56, 189, 248),
                Callback = function(s)
                    Flashstep.setAimbot(s)
                end
            })
        elseif Flashstep.Widget then
            Flashstep.Widget:Set(true, true)
            Flashstep.Widget:SetVisible(true)
        end
    else
        if Flashstep.Widget then
            Flashstep.Widget:Set(false, true)
            Flashstep.Widget:SetVisible(false)
        end
    end
end

function Flashstep.directTeleportToTarget()
    local _, targetHRP = getTarget()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if targetHRP and myHRP then
        -- Teleport slightly behind target
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
        return true
    end
    return false
end

function Flashstep.setFloatingVisible(visible)
    if Flashstep.Widget then
        Flashstep.Widget:SetVisible(visible)
    end
end

return Flashstep
