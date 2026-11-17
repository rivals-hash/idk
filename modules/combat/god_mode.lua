--[[
    Monody / Darling Hub - God Mode & Desync Suite (Blox Fruits)
    ============================================================
    Modular invulnerability engine based on reverse-engineered Blox Fruits client systems:
    1. Boat Desync: Exploits ShipServiceEvent to anchor client position in the void
       to all other players, making all incoming player attacks miss hitbox checks.
    2. Physics Desync: Heartbeat/RenderStepped position desynchronization.
    3. Safe Zone Desync: Positions replicated coordinates inside safe zones.
    4. Anti-Stun: Zeros Stun/Busy values, unlocks walkspeed and clears sit/freeze locks.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local GodMode = {
    -- Master / Method Toggles
    BoatDesync = false,
    PhysicsDesync = false,
    SafeZoneDesync = false,
    AntiStun = false,

    -- Settings
    DesyncOffset = 2000,
    PrioritizeOwnBoat = true,

    -- Runtime References
    Connections = {},
    ActiveBoat = nil,
    CachedSafeZones = {},
    LastRealCFrame = nil,
    IsDesynced = false,
}

-- Notification helper
local function Notify(title, text, dur)
    pcall(function()
        if _G.WindUI and _G.WindUI.Notify then
            _G.WindUI:Notify({ Title = title, Content = text, Duration = dur or 3 })
        elseif _G.DarlingNotify then
            _G.DarlingNotify(title, text, dur or 3)
        end
    end)
end

-- ============================================================
-- 1. BOAT DESYNC ENGINE (EXPLOITS ShipServiceEvent)
-- ============================================================
-- How it works: Blox Fruits ShipService.lua listens to ShipServiceEvent
-- When any client fires ShipServiceEvent(boat, relativeCFrame), the server broadcasts
-- it to all other clients. Other clients overwrite that player's root CFrame to
-- (boat.Pivot * relativeCFrame) every Heartbeat.
-- By sending a deep void offset (e.g. 2000 studs down), other players see and check
-- your hitbox in the void, making every attack miss completely.

function GodMode.FindTargetBoat()
    local boatsFolder = Workspace:FindFirstChild("Boats")
    if not boatsFolder then return nil end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = hrp and hrp.Position or Vector3.zero

    local ownBoat = nil
    local nearestBoat = nil
    local shortestDist = math.huge

    for _, boat in ipairs(boatsFolder:GetChildren()) do
        if boat:IsA("Model") then
            -- Check ownership markers used by Blox Fruits
            local isMine = false
            local ownerVal = boat:FindFirstChild("Owner")
            if ownerVal and (ownerVal.Value == LocalPlayer or ownerVal.Value == LocalPlayer.Name) then
                isMine = true
            elseif boat:GetAttribute("Owner") == LocalPlayer.Name or boat:GetAttribute("Owner") == LocalPlayer.UserId then
                isMine = true
            elseif string.find(boat.Name, LocalPlayer.Name) then
                isMine = true
            end

            if isMine then
                ownBoat = boat
                break
            end

            local pivot = boat:GetPivot()
            local dist = (pivot.Position - myPos).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                nearestBoat = boat
            end
        end
    end

    if GodMode.PrioritizeOwnBoat and ownBoat then
        return ownBoat
    end
    return ownBoat or nearestBoat
end

local function sendBoatDesyncPacket(boat, offset)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local shipEvent = remotes and remotes:FindFirstChild("ShipServiceEvent")
    if not shipEvent then return false end

    if boat and boat.Parent == Workspace:FindFirstChild("Boats") then
        local relCFrame = CFrame.new(0, -offset, 0)
        pcall(function()
            shipEvent:FireServer(boat, relCFrame)
        end)
        return true
    end
    return false
end

local function clearBoatDesync()
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local shipEvent = remotes and remotes:FindFirstChild("ShipServiceEvent")
        if shipEvent then
            -- Firing with no arguments clears boat tracking in ShipService.lua
            shipEvent:FireServer()
        end
    end)
end

function GodMode.StartBoatDesync()
    if GodMode.Connections.BoatDesync then return end

    local targetBoat = GodMode.FindTargetBoat()
    if not targetBoat then
        Notify("God Mode", "No boat found! Spawn or get near a boat first.", 3.5)
    else
        GodMode.ActiveBoat = targetBoat
        Notify("God Mode", "Boat Desync active with: " .. targetBoat.Name, 3)
    end

    local lastSend = 0
    GodMode.Connections.BoatDesync = RunService.Heartbeat:Connect(function()
        local now = os.clock()
        -- Send every 0.25 seconds to keep the 5-second lease fresh on all clients
        if now - lastSend >= 0.25 then
            lastSend = now
            local boat = GodMode.ActiveBoat
            if not boat or boat.Parent ~= Workspace:FindFirstChild("Boats") then
                boat = GodMode.FindTargetBoat()
                GodMode.ActiveBoat = boat
            end

            if boat then
                sendBoatDesyncPacket(boat, GodMode.DesyncOffset)
            end
        end
    end)
end

function GodMode.StopBoatDesync()
    if GodMode.Connections.BoatDesync then
        GodMode.Connections.BoatDesync:Disconnect()
        GodMode.Connections.BoatDesync = nil
    end
    clearBoatDesync()
    GodMode.ActiveBoat = nil
end

-- ============================================================
-- 2. PHYSICS DESYNC (Heartbeat / RenderStepped)
-- ============================================================
-- Temporarily offsets position during physics simulation (Heartbeat)
-- and restores it before local render (RenderStepped) so movement stays smooth.

function GodMode.StartPhysicsDesync()
    if GodMode.Connections.PhysicsHeartbeat then return end

    GodMode.Connections.PhysicsHeartbeat = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            GodMode.LastRealCFrame = hrp.CFrame
            hrp.CFrame = GodMode.LastRealCFrame * CFrame.new(0, -GodMode.DesyncOffset, 0)
            GodMode.IsDesynced = true
        end
    end)

    GodMode.Connections.PhysicsRender = RunService.RenderStepped:Connect(function()
        if GodMode.IsDesynced and GodMode.LastRealCFrame then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = GodMode.LastRealCFrame
            end
            GodMode.IsDesynced = false
        end
    end)
end

function GodMode.StopPhysicsDesync()
    if GodMode.Connections.PhysicsHeartbeat then
        GodMode.Connections.PhysicsHeartbeat:Disconnect()
        GodMode.Connections.PhysicsHeartbeat = nil
    end
    if GodMode.Connections.PhysicsRender then
        GodMode.Connections.PhysicsRender:Disconnect()
        GodMode.Connections.PhysicsRender = nil
    end
    if GodMode.IsDesynced and GodMode.LastRealCFrame then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = GodMode.LastRealCFrame
        end
    end
    GodMode.IsDesynced = false
    GodMode.LastRealCFrame = nil
end

-- ============================================================
-- 3. SAFE ZONE DESYNC (WorldOrigin.SafeZones)
-- ============================================================
-- Projects replicated position into the nearest Safe Zone sphere
-- to trigger server-side InSafeZone protection.

local function getNearestSafeZone()
    local worldOrigin = Workspace:FindFirstChild("_WorldOrigin")
    local szFolder = worldOrigin and worldOrigin:FindFirstChild("SafeZones")
    if not szFolder then return nil end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = hrp and hrp.Position or Vector3.zero

    local nearest = nil
    local minDist = math.huge

    for _, part in ipairs(szFolder:GetChildren()) do
        if part:IsA("BasePart") then
            local dist = (part.Position - myPos).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = part
            end
        end
    end
    return nearest
end

function GodMode.StartSafeZoneDesync()
    if GodMode.Connections.SafeZoneDesync then return end

    local targetSz = getNearestSafeZone()
    if not targetSz then
        Notify("God Mode", "No SafeZone found in current sea/island.", 3)
        return
    end

    GodMode.Connections.SafeZoneDesync = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and targetSz and targetSz.Parent then
            local realCF = hrp.CFrame
            hrp.CFrame = targetSz.CFrame
            RunService.RenderStepped:Wait()
            if hrp and hrp.Parent then
                hrp.CFrame = realCF
            end
        end
    end)
end

function GodMode.StopSafeZoneDesync()
    if GodMode.Connections.SafeZoneDesync then
        GodMode.Connections.SafeZoneDesync:Disconnect()
        GodMode.Connections.SafeZoneDesync = nil
    end
end

-- ============================================================
-- 4. ANTI-STUN & COMBO BREAKER
-- ============================================================
-- Cleanses combat stun values, busy flags, unfreezes speed and cancels stun locks.

local function processAntiStun(char)
    if not char then return end

    -- 1. Clear Blox Fruits Stun NumberValue
    local stun = char:FindFirstChild("Stun")
    if stun and stun:IsA("NumberValue") and stun.Value > 0 then
        stun.Value = 0
    end

    -- 2. Clear Blox Fruits Busy BoolValue
    local busy = char:FindFirstChild("Busy")
    if busy and busy:IsA("BoolValue") and busy.Value then
        busy.Value = false
    end

    -- 3. Reset Humanoid constraints
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if hum.WalkSpeed < 16 and hum.WalkSpeed >= 0 then
            hum.WalkSpeed = 16
        end
        if hum.PlatformStand then
            hum.PlatformStand = false
        end
        -- Prevent forced sitting unless on a real vehicle seat
        if hum.Sit and not (hum.SeatPart and hum.SeatPart:IsA("VehicleSeat")) then
            hum.Sit = false
        end
    end
end

function GodMode.StartAntiStun()
    if GodMode.Connections.AntiStun then return end

    GodMode.Connections.AntiStun = RunService.Heartbeat:Connect(function()
        processAntiStun(LocalPlayer.Character)
    end)

    local char = LocalPlayer.Character
    if char then
        GodMode.Connections.AntiStunChild = char.ChildAdded:Connect(function(child)
            if child.Name == "Stun" or child.Name == "Busy" then
                task.defer(processAntiStun, char)
            end
        end)
    end
end

function GodMode.StopAntiStun()
    if GodMode.Connections.AntiStun then
        GodMode.Connections.AntiStun:Disconnect()
        GodMode.Connections.AntiStun = nil
    end
    if GodMode.Connections.AntiStunChild then
        GodMode.Connections.AntiStunChild:Disconnect()
        GodMode.Connections.AntiStunChild = nil
    end
end

-- ============================================================
-- MASTER CONTROLLER & REBIND
-- ============================================================

function GodMode.SetMethod(methodName, enabled)
    if methodName == "BoatDesync" then
        GodMode.BoatDesync = enabled
        if enabled then GodMode.StartBoatDesync() else GodMode.StopBoatDesync() end
    elseif methodName == "PhysicsDesync" then
        GodMode.PhysicsDesync = enabled
        if enabled then GodMode.StartPhysicsDesync() else GodMode.StopPhysicsDesync() end
    elseif methodName == "SafeZoneDesync" then
        GodMode.SafeZoneDesync = enabled
        if enabled then GodMode.StartSafeZoneDesync() else GodMode.StopSafeZoneDesync() end
    elseif methodName == "AntiStun" then
        GodMode.AntiStun = enabled
        if enabled then GodMode.StartAntiStun() else GodMode.StopAntiStun() end
    end
end

function GodMode.SetOffset(offset)
    GodMode.DesyncOffset = math.clamp(tonumber(offset) or 2000, 50, 10000)
end

function GodMode.StopAll()
    GodMode.SetMethod("BoatDesync", false)
    GodMode.SetMethod("PhysicsDesync", false)
    GodMode.SetMethod("SafeZoneDesync", false)
    GodMode.SetMethod("AntiStun", false)
    clearBoatDesync()
    Notify("God Mode", "All God Mode methods disabled.", 2)
end

-- Handle character respawn safely
local function onCharacterAdded(newChar)
    task.wait(0.5)
    if GodMode.BoatDesync then
        GodMode.StopBoatDesync()
        GodMode.StartBoatDesync()
    end
    if GodMode.PhysicsDesync then
        GodMode.StopPhysicsDesync()
        GodMode.StartPhysicsDesync()
    end
    if GodMode.SafeZoneDesync then
        GodMode.StopSafeZoneDesync()
        GodMode.StartSafeZoneDesync()
    end
    if GodMode.AntiStun then
        GodMode.StopAntiStun()
        GodMode.StartAntiStun()
    end
end

if not GodMode.CharAddedConn then
    GodMode.CharAddedConn = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
end

return GodMode
