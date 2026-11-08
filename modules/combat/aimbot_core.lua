-- aimbot core

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

local Core = {
    -- Master Toggles
    AimbotEnabled = false,
    CamLock = false,
    PlayerAimEnabled = false,
    NPCAimEnabled = false,
    TeamCheck = false,
    PvPCheck = true,
    SafeZoneCheck = true,

    -- Settings (360 degrees default)
    AimMode = "360", -- "360", "FOV", "180"
    TargetPriority = "Nearest", -- "Nearest", "Low HP", "Looking At Me"
    TargetPart = "Head", -- "Head", "HumanoidRootPart"
    MaxRange = 1000,
    PredictionEnabled = true,
    PredictionAmount = 0.12,

    -- FOV Settings
    FOV = {
        Visible = false,
        Radius = 100,
        Mode = "Center", -- "Center", "Mouse"
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1.5,
    },

    -- Tracer Settings
    Tracers = {
        Visible = false,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1.5,
    },

    -- resolved targets
    CurrentTargetPart = nil,
    CurrentTargetRawPosition = nil,
    CurrentTargetPosition = nil,
    CurrentTargetCharacter = nil,
    CurrentTargetIsPlayer = false,
    LockPlayer = false,
    LockedTargetPlayer = nil,

    -- tool & skill tracking
    CurrentTool = nil,
    CurrentToolCategory = "Melee",
    CurrentSkillKey = nil,
    LastSkillTime = 0,

    -- skill blacklist
    BlacklistedKeys = {
        Melee = { Z = false, X = false, C = false },
        Sword = { Z = false, X = false },
        Fruit = { Z = false, X = false, C = false, V = false, F = false, TAP = false },
        Gun   = { Z = false, X = false },
    },
    BlacklistedPlayers = {},

    -- internal hooks & lifecycle
    IsHooked = false,
    RenderConnection = nil,
    CharConnections = {},
    LastVelocity = nil,
    LastDirection = nil,
}

local SKILL_KEYS = { "Z", "X", "C", "V", "F", "TAP" }

-- tool categorization
function Core.getToolCategory(tool)
    if not tool or not tool:IsA("Tool") then return "Melee" end
    pcall(function()
        local tip = string.lower(tool.ToolTip or "")
        if string.find(tip, "melee") then return "Melee" end
        if string.find(tip, "sword") then return "Sword" end
        if string.find(tip, "fruit") then return "Fruit" end
        if string.find(tip, "gun") then return "Gun" end
    end)
    local name = string.lower(tool.Name)

    local gunNames = { "guitar", "rifle", "cannon", "gun", "slingshot", "kabucha", "bow" }
    for _, g in ipairs(gunNames) do
        if string.find(name, g) then return "Gun" end
    end

    local meleeNames = { "claw", "godhuman", "superhuman", "talon", "step", "karate", "breath", "kung fu", "combat", "fist", "sanguine" }
    for _, m in ipairs(meleeNames) do
        if string.find(name, m) then return "Melee" end
    end

    if tool.ToolTip == "Blox Fruit" or string.find(name, "fruit") or string.find(name, "-") then
        return "Fruit"
    end

    return "Sword"
end

-- blacklist checks
function Core.isKeyBlacklisted(category, key)
    if not key then return false end
    category = category or Core.CurrentToolCategory or "Melee"
    if Core.BlacklistedKeys[category] and Core.BlacklistedKeys[category][key] ~= nil then
        if Core.BlacklistedKeys[category][key] == true then return true end
    end
    if (key == "V" or key == "F" or key == "TAP") and Core.BlacklistedKeys.Fruit and Core.BlacklistedKeys.Fruit[key] == true then
        return true
    end
    -- Fallback to global blacklist table if configured via dropdown
    if _G.DarlingHub and _G.DarlingHub.Settings and _G.DarlingHub.Settings.Blacklist then
        local b = _G.DarlingHub.Settings.Blacklist[category]
        if b and b[key] == true then return true end
    end
    return false
end

function Core.isPlayerPvPEnabled(player)
    if not player or player == LocalPlayer then return false end
    local ok, enabled = pcall(function()
        if player:GetAttribute("PvpDisabled") == true then return false end
        local char = player.Character
        if char then
            if char:FindFirstChildOfClass("ForceField") then return false end
            if char:GetAttribute("PvpDisabled") == true then return false end
        end
        return true
    end)
    return not ok or enabled
end

function Core.isPlayerInSafeZone(player)
    if not player or player == LocalPlayer then return false end
    local ok, inZone = pcall(function()
        local char = player.Character
        if not char then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Sit == true then return true end
        if char:FindFirstChildOfClass("ForceField") then return true end
        if char:GetAttribute("SafeZone") == true or player:GetAttribute("SafeZone") == true then return true end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local hrpPos = hrp.Position

        local function checkFolder(folder)
            if not folder then return false end
            for _, zone in ipairs(folder:GetChildren()) do
                if zone:IsA("BasePart") then
                    local mesh = zone:FindFirstChild("Mesh")
                    local radius = (mesh and mesh:IsA("SpecialMesh") and (zone.Size.X * mesh.Scale.X) / 2) or (math.min(zone.Size.X, zone.Size.Z) / 2)
                    if radius > 500 or radius <= 0 then radius = 350 end
                    if (zone.Position - hrpPos).Magnitude <= radius then return true end

                    local localPos = zone.CFrame:PointToObjectSpace(hrpPos)
                    local halfSize = zone.Size / 2
                    if math.abs(localPos.X) <= halfSize.X and math.abs(localPos.Y) <= halfSize.Y + 25 and math.abs(localPos.Z) <= halfSize.Z then
                        return true
                    end
                end
            end
            return false
        end

        local wo = Workspace:FindFirstChild("_WorldOrigin")
        if wo and checkFolder(wo:FindFirstChild("SafeZones")) then return true end
        if wo and checkFolder(wo:FindFirstChild("TempSafeZones")) then return true end
        if checkFolder(Workspace:FindFirstChild("SafeZones")) then return true end
        local map = Workspace:FindFirstChild("Map")
        if map and checkFolder(map:FindFirstChild("SafeZones")) then return true end
        return false
    end)
    return ok and inZone
end

function Core.setPlayerBlacklisted(playerOrName, isBlacklisted)
    local name = (typeof(playerOrName) == "Instance" and playerOrName.Name) or tostring(playerOrName)
    Core.BlacklistedPlayers = Core.BlacklistedPlayers or {}
    Core.BlacklistedPlayers[name] = (isBlacklisted == true)
    _G.MonodyBlacklistedPlayers = _G.MonodyBlacklistedPlayers or {}
    _G.MonodyBlacklistedPlayers[name] = (isBlacklisted == true)
end

function Core.isPlayerExplicitlyBlacklisted(playerOrName)
    local name = (typeof(playerOrName) == "Instance" and playerOrName.Name) or tostring(playerOrName)
    if Core.BlacklistedPlayers and Core.BlacklistedPlayers[name] == true then
        return true
    end
    if _G.MonodyBlacklistedPlayers and _G.MonodyBlacklistedPlayers[name] == true then
        return true
    end
    if _G.DarlingBlacklistedPlayers and _G.DarlingBlacklistedPlayers[name] == true then
        return true
    end
    return false
end

function Core.isPlayerBlacklisted(player)
    if not player then return false end
    if Core.isPlayerExplicitlyBlacklisted(player) then
        return true
    end
    if Core.PvPCheck and not Core.isPlayerPvPEnabled(player) then
        return true
    end
    if Core.SafeZoneCheck and Core.isPlayerInSafeZone(player) then
        return true
    end
    return false
end

-- ============================================================================
-- HEALTH & HITBOX UTILITIES
-- ============================================================================
local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getEntityPart(char)
    if not char then return nil end
    local hubSettings = (_G.DarlingHub and _G.DarlingHub.Settings and _G.DarlingHub.Settings.Aim)
    local prefPart = (hubSettings and hubSettings.Hitbox) or Core.TargetHitbox or Core.TargetPart or "HumanoidRootPart"
    return char:FindFirstChild(prefPart)
        or char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("Head")
        or char:FindFirstChildWhichIsA("BasePart")
end

local function getHRP(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("Head")
end

-- ============================================================================
-- ENEMY & TARGET FILTER
-- ============================================================================
local function isSilentAimAlly(player)
    if not player then return false end
    local main = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main")
    local frame = main and main:FindFirstChild("Allies")
        and main.Allies:FindFirstChild("Container")
        and main.Allies.Container:FindFirstChild("Allies")
        and main.Allies.Container.Allies:FindFirstChild("ScrollingFrame")
        and main.Allies.Container.Allies.ScrollingFrame:FindFirstChild("Frame")
    if frame and frame:FindFirstChild(player.Name) then return true end
    return false
end

local function isEnemy(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return false end
    if Core.isPlayerBlacklisted(targetPlayer) then return false end

    if Core.TeamCheck then
        if isSilentAimAlly(targetPlayer) then return false end
        local myTeam = LocalPlayer and LocalPlayer.Team
        local targetTeam = targetPlayer.Team
        if myTeam and targetTeam then
            if myTeam == targetTeam then return false end
            if myTeam.Name == "Marines" and targetTeam.Name == "Marines" then return false end
        end
    end
    return true
end

-- ============================================================================
-- FOV & ANGLE VALIDATION
-- ============================================================================
function Core.getFOVCenter()
    Camera = Workspace.CurrentCamera or Camera
    local mode = "Center"
    local fovMod = _G.MonodyFOV
    if fovMod and fovMod.getMode then
        mode = fovMod.getMode()
    else
        local hubSettings = (_G.DarlingHub and _G.DarlingHub.Settings and _G.DarlingHub.Settings.FOV) or Core.FOV
        mode = hubSettings.Mode or Core.FOV.Mode or "Center"
    end
    if mode == "Mouse" then
        local p = UserInputService:GetMouseLocation()
        if p.X > 0 and p.Y > 0 then return p end
    end
    if Camera and Camera.ViewportSize then
        return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
    return Vector2.new(400, 300)
end

function Core.getFOVRadius()
    local fovMod = _G.MonodyFOV
    if fovMod and fovMod.getRadius then
        return fovMod.getRadius()
    end
    local hubSettings = (_G.DarlingHub and _G.DarlingHub.Settings and _G.DarlingHub.Settings.FOV) or Core.FOV
    return hubSettings.Radius or Core.FOV.Radius or 120
end

-- ============================================================================
-- PREDICTION ENGINE
-- ============================================================================
function Core.predictPosition(targetPart)
    if not targetPart then return nil end
    local char = targetPart.Parent
    if not isAlive(char) then return targetPart.Position end

    -- Hitscan weapons (swords / Buddy Sword) do not lead with velocity prediction
    local isSword = (Core.CurrentToolCategory == "Sword") or (Core.CurrentTool and (string.find(Core.CurrentTool.Name, "Sword") or string.find(Core.CurrentTool.Name, "Buddy")))
    if isSword then
        return targetPart.Position
    end

    local hubSettings = (_G.DarlingHub and _G.DarlingHub.Settings and _G.DarlingHub.Settings.Aim) or Core
    if hubSettings.Prediction == false or Core.PredictionEnabled == false then
        return targetPart.Position
    end

    local hrp = char:FindFirstChild("HumanoidRootPart") or targetPart
    local vel = hrp.Velocity
    local speed = vel.Magnitude

    if speed < 4 then
        Core.LastVelocity = nil
        Core.LastDirection = nil
        return targetPart.Position
    end

    local currentDir = vel.Unit
    if Core.LastDirection then
        local dot = Core.LastDirection:Dot(currentDir)
        if dot < 0.65 then
            Core.LastVelocity = nil
            Core.LastDirection = nil
            return targetPart.Position
        end
    end

    Core.LastDirection = currentDir
    Core.LastVelocity = vel

    local ping = 0
    pcall(function()
        local serverStats = Stats.Network:FindFirstChild("ServerStatsItem")
        if serverStats and serverStats:FindFirstChild("Data Ping") then
            ping = serverStats["Data Ping"]:GetValue() / 1000
        end
    end)
    ping = math.clamp(ping, 0, 0.25)

    local factor = (hubSettings.PredictionAmount or Core.PredictionAmount or 0.12) + ping
    if speed > 100 then factor = math.min(factor, 0.14) end

    return targetPart.Position + (vel * factor)
end

-- target selection
local function resolvePlayerTarget(lpHRP)
    if not lpHRP then return nil, nil, nil end
    Camera = Workspace.CurrentCamera or Camera

    local hubSettings = (_G.DarlingHub and _G.DarlingHub.Settings and _G.DarlingHub.Settings.Aim) or Core
    local maxRange = hubSettings.MaxRange or Core.MaxRange or 1000
    local aimMode = hubSettings.Mode or Core.AimMode or "360"
    local fovCenter = Core.getFOVCenter()
    local fovRadius = Core.getFOVRadius()
    local priority = hubSettings.Priority or Core.TargetPriority or "Nearest"
    local myPos = lpHRP.Position

    -- 1. Explicit selected player override (from Player List tab)
    if Core.SelectedPlayer and Core.SelectedPlayer ~= LocalPlayer and Core.SelectedPlayer.Character and isAlive(Core.SelectedPlayer.Character) then
        local part = getEntityPart(Core.SelectedPlayer.Character)
        if part and (part.Position - myPos).Magnitude <= maxRange then
            local predPos = Core.predictPosition(part)
            return part, predPos, Core.SelectedPlayer.Character
        end
    end

    -- 2. Lock Player feature: keep target locked onto the acquired player
    if (Core.LockPlayer or Core.AimbotEnabled) and Core.LockedTargetPlayer and Core.LockedTargetPlayer ~= LocalPlayer and Core.LockedTargetPlayer.Character and isAlive(Core.LockedTargetPlayer.Character) and not Core.isPlayerBlacklisted(Core.LockedTargetPlayer) then
        local part = getEntityPart(Core.LockedTargetPlayer.Character)
        if part and (part.Position - myPos).Magnitude <= maxRange then
            local predPos = Core.predictPosition(part)
            return part, predPos, Core.LockedTargetPlayer.Character
        else
            Core.LockedTargetPlayer = nil
        end
    end

    local bestPart = nil
    local bestScore = math.huge
    local bestChar = nil
    local bestPlayer = nil

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and isEnemy(pl) and not Core.isPlayerBlacklisted(pl) and pl.Character and isAlive(pl.Character) then
            local part = getEntityPart(pl.Character)
            if part then
                local worldDist = (part.Position - myPos).Magnitude
                if worldDist <= maxRange then
                    local allowed = false
                    local distScore = worldDist

                    if aimMode == "FOV" then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - fovCenter).Magnitude
                            if screenDist <= fovRadius then
                                allowed = true
                                distScore = screenDist
                            end
                        end
                    elseif aimMode == "180" then
                        local dir = (part.Position - myPos).Unit
                        if lpHRP.CFrame.LookVector:Dot(dir) >= 0 then
                            allowed = true
                            distScore = worldDist
                        end
                    else -- "360" (DEFAULT)
                        allowed = true
                        distScore = worldDist
                    end

                    if allowed then
                        local score = distScore
                        if priority == "Low HP" then
                            local hum = pl.Character:FindFirstChildOfClass("Humanoid")
                            score = hum and hum.Health or distScore
                        elseif priority == "Looking At Me" then
                            local plHRP = getHRP(pl.Character)
                            if plHRP then
                                local toMe = (myPos - plHRP.Position).Unit
                                local dot = plHRP.CFrame.LookVector:Dot(toMe)
                                score = 1 - dot
                            end
                        end

                        if score < bestScore then
                            bestScore = score
                            bestPart = part
                            bestChar = pl.Character
                            bestPlayer = pl
                        end
                    end
                end
            end
        end
    end

    if bestPart then
        if (Core.LockPlayer or Core.AimbotEnabled) and not Core.LockedTargetPlayer then
            Core.LockedTargetPlayer = bestPlayer
        end
        local predPos = Core.predictPosition(bestPart)
        return bestPart, predPos, bestChar
    end
    return nil, nil, nil
end

local function resolveNPCTarget(lpHRP)
    if not lpHRP then return nil, nil, nil end
    Camera = Workspace.CurrentCamera or Camera

    local hubSettings = (_G.DarlingHub and _G.DarlingHub.Settings and _G.DarlingHub.Settings.Aim) or Core
    local maxRange = hubSettings.MaxRange or Core.MaxRange or 1000
    local aimMode = hubSettings.Mode or Core.AimMode or "360"
    local fovCenter = Core.getFOVCenter()
    local fovRadius = Core.getFOVRadius()

    local closestPart = nil
    local shortestDist = math.huge
    local targetChar = nil
    local myPos = lpHRP.Position

    local function isAttackableEnemy(entity)
        if not entity or not entity:IsA("Model") then return false end
        if Players:GetPlayerFromCharacter(entity) then return false end
        if not isAlive(entity) then return false end
        if entity:FindFirstChildWhichIsA("Dialog") or entity:FindFirstChildWhichIsA("ClickDetector") then return false end
        if entity:FindFirstChild("Quest") or entity:FindFirstChild("QuestGiver") or entity:FindFirstChild("Dialogue") then return false end
        local name = string.lower(entity.Name)
        local nonCombat = { "quest", "dealer", "shop", "spawn", "trainer", "boat", "blacksmith", "recruiter", "hunter", "luxury", "garrick" }
        for _, kw in ipairs(nonCombat) do
            if string.find(name, kw) then return false end
        end
        return true
    end

    local function checkEntity(entity)
        if isAttackableEnemy(entity) then
            local part = getEntityPart(entity)
            if part then
                local worldDist = (part.Position - myPos).Magnitude
                if worldDist <= maxRange then
                    if aimMode == "FOV" then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - fovCenter).Magnitude
                            if screenDist <= fovRadius and screenDist < shortestDist then
                                shortestDist = screenDist
                                closestPart = part
                                targetChar = entity
                            end
                        end
                    elseif aimMode == "180" then
                        local dir = (part.Position - myPos).Unit
                        if lpHRP.CFrame.LookVector:Dot(dir) >= 0 and worldDist < shortestDist then
                            shortestDist = worldDist
                            closestPart = part
                            targetChar = entity
                        end
                    else -- "360" (DEFAULT)
                        if worldDist < shortestDist then
                            shortestDist = worldDist
                            closestPart = part
                            targetChar = entity
                        end
                    end
                end
            end
        end
    end

    local folders = {
        Workspace:FindFirstChild("Enemies"),
        Workspace:FindFirstChild("Characters"),
    }
    for _, f in ipairs(folders) do
        if f then
            for _, child in ipairs(f:GetChildren()) do
                checkEntity(child)
            end
        end
    end

    if closestPart then
        local predPos = Core.predictPosition(closestPart)
        return closestPart, predPos, targetChar
    end
    return nil, nil, nil
end

function Core.resolveAnyTarget()
    Camera = Workspace.CurrentCamera or Camera
    local char = LocalPlayer and LocalPlayer.Character
    local lpHRP = char and getHRP(char)
    if not lpHRP then return nil, nil, nil end

    if Core.PlayerAimEnabled then
        local pPart, pPos, pChar = resolvePlayerTarget(lpHRP)
        if pPart and pPos then return pPart, pPos, pChar end
        if not Core.NPCAimEnabled then
            return nil, nil, nil
        end
    end

    if Core.NPCAimEnabled then
        local nPart, nPos, nChar = resolveNPCTarget(lpHRP)
        if nPart and nPos then return nPart, nPos, nChar end
        return nil, nil, nil
    end

    -- Fallback for Tracers when neither master aimbot toggle is active yet:
    local pPart, pPos, pChar = resolvePlayerTarget(lpHRP)
    if pPart and pPos then return pPart, pPos, pChar end
    return resolveNPCTarget(lpHRP)
end

-- ============================================================================
-- ROTATION TOWARDS TARGET (SAFE ASYNC - NO CRASH)
-- ============================================================================
function Core.faceTarget(targetPos)
    if not targetPos then return end
    pcall(function()
        local char = LocalPlayer and LocalPlayer.Character
        local hrp = char and getHRP(char)
        if not hrp then return end

        local currentPos = hrp.Position
        local look = (Vector3.new(targetPos.X, currentPos.Y, targetPos.Z) - currentPos).Unit
        if look.Magnitude < 0.001 then return end

        hrp.CFrame = CFrame.lookAt(currentPos, currentPos + look, Vector3.new(0, 1, 0))
    end)
end

-- skill tracking
function Core.setCurrentSkillKey(key)
    Core.CurrentSkillKey = key
    Core.LastSkillTime = os.clock()

    if (Core.PlayerAimEnabled or Core.NPCAimEnabled) and Core.CurrentTargetPart then
        local targetPart = Core.CurrentTargetPart
        if targetPart and not Core.isKeyBlacklisted(Core.CurrentToolCategory, key) then
            task.spawn(function() Core.faceTarget(targetPart.Position) end)
        end
    end

    task.spawn(function()
        local capturedTime = Core.LastSkillTime
        task.wait(1.5)
        if Core.LastSkillTime == capturedTime and Core.CurrentSkillKey == key then
            Core.CurrentSkillKey = nil
        end
    end)
end

local function getSkillKeyFromArgs(args)
    for _, arg in ipairs(args) do
        if type(arg) == "string" and table.find(SKILL_KEYS, arg) then
            return arg
        end
    end
    return nil
end

-- Non-destructive Blox Fruits client mouse module access
local mouseModuleData = nil
local mouseModuleResolved = false
local function getMouseModule()
    if not mouseModuleResolved then
        mouseModuleResolved = true
        local mm = ReplicatedStorage:FindFirstChild("Mouse")
        if mm and mm:IsA("ModuleScript") then
            local ok, res = pcall(require, mm)
            if ok and type(res) == "table" then
                mouseModuleData = res
            end
        end
    end
    return mouseModuleData
end

-- Helper to validate that target matches the active aimbot mode (prevents NPC aim shooting players and vice versa)
local function isValidHookTarget(target)
    if not target or not target.Parent then return false end
    if not (Core.LockPlayer or Core.AimbotEnabled or Core.PlayerAimEnabled or Core.NPCAimEnabled or _G.G_Aimbot or _G.G_PlayerAim or _G.G_NPCAimbot or _G.G_SilentAim or _G.G_PlayerSilentAim or _G.G_NPCSilentAim or _G.G_SilentAimM1R or _G.G_SilentAimSkill) then
        return false
    end
    local targetIsPlayer = (Players:GetPlayerFromCharacter(target.Parent) ~= nil)
    local isPlayerActive = (Core.AimbotEnabled or Core.PlayerAimEnabled or Core.LockPlayer or _G.G_Aimbot or _G.G_PlayerAim or _G.G_PlayerSilentAim)
    local isNPCActive = (Core.NPCAimEnabled or _G.G_NPCAimbot or _G.G_NPCSilentAim)

    if isNPCActive and not isPlayerActive and targetIsPlayer then
        return false
    end
    if isPlayerActive and not isNPCActive and not targetIsPlayer then
        return false
    end
    return true
end

-- ============================================================================
-- AUTHENTIC 3-TIER HOOK SYSTEM (DARLING X / DARLING HUB / BBG PANEL STANDARD)
-- 100% crash-proof with recursion guards and dual hookmetamethod/rawmetatable support
-- ============================================================================
local inHook = false
function Core.installHooks()
    if Core.IsHooked then return end
    Core.IsHooked = true

    local mouse = LocalPlayer and LocalPlayer:GetMouse()

    -- ------------------------------------------------------------------------
    -- Hook 1: Mouse.__index (Hit, Target, UnitRay, Origin, Direction)
    -- ------------------------------------------------------------------------
    local function handleMouseIndex(oldIndex, self, key)
        if inHook then return oldIndex(self, key) end
        if (checkcaller and checkcaller()) then return oldIndex(self, key) end

        if self == mouse and (key == "Hit" or key == "Target" or key == "UnitRay" or key == "Origin" or key == "Direction") then
            inHook = true
            local ok, res = pcall(function()
                local isAllowed = (Core.LockPlayer or Core.AimbotEnabled or Core.PlayerAimEnabled or Core.NPCAimEnabled or _G.G_Aimbot or _G.G_PlayerAim or _G.G_NPCAimbot or _G.G_SilentAim or _G.G_PlayerSilentAim or _G.G_NPCSilentAim or _G.G_SilentAimM1R or _G.G_SilentAimSkill)
                if not isAllowed and _G.MonodySilentAim and _G.MonodySilentAim.Enabled then
                    isAllowed = true
                end
                if not isAllowed then return nil end

                local target = Core.CurrentTargetPart or _G.currentSilentAimTarget or _G.DarlingSilentAimTarget
                if not target or not target.Parent then return nil end

                local activeKey = Core.CurrentSkillKey
                if activeKey and Core.isKeyBlacklisted(Core.CurrentToolCategory, activeKey) then
                    return nil
                end

                local isSword = (Core.CurrentToolCategory == "Sword") or (Core.CurrentTool and (string.find(Core.CurrentTool.Name, "Sword") or string.find(Core.CurrentTool.Name, "Buddy")))
                local tp = (isSword and Core.CurrentTargetRawPosition) or (target and target.Position) or Core.CurrentTargetPosition or Core.CurrentTargetRawPosition
                if not tp or typeof(tp) ~= "Vector3" or (tp.X ~= tp.X) then return nil end

                local cam = Workspace.CurrentCamera or Camera
                local cp = cam and cam.CFrame.Position

                if key == "Hit" then
                    if cp then
                        local look = (tp - cp)
                        if look.Magnitude > 0.001 then
                            return CFrame.lookAt(tp, tp + look.Unit)
                        end
                    end
                    return CFrame.new(tp)
                elseif key == "Target" then
                    return target
                elseif key == "UnitRay" and cp then
                    local dir = (tp - cp)
                    if dir.Magnitude > 0.001 then
                        return Ray.new(cp, dir.Unit)
                    end
                elseif key == "Origin" and cp then
                    return CFrame.new(cp, tp)
                elseif key == "Direction" and cp then
                    local dir = (tp - cp)
                    if dir.Magnitude > 0.001 then
                        return dir.Unit
                    end
                end
                return nil
            end)
            inHook = false

            if ok and res ~= nil then
                return res
            end
        end

        return oldIndex(self, key)
    end

    if mouse then
        local okHook = false
        if hookmetamethod then
            pcall(function()
                local oldIndex
                oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
                    return handleMouseIndex(oldIndex, self, key)
                end))
                okHook = true
            end)
        end

        if not okHook then
            local rawMt = getrawmetatable(game)
            if rawMt then
                local oldIndex = rawMt.__index
                pcall(setreadonly, rawMt, false)
                rawMt.__index = newcclosure(function(t, k)
                    return handleMouseIndex(oldIndex, t, k)
                end)
                pcall(setreadonly, rawMt, true)
            end
        end
    end

    -- ------------------------------------------------------------------------
    -- Hook 2: ReplicatedStorage.Mouse module (Blox Fruits skill targeting)
    -- ------------------------------------------------------------------------
    local function hookMouseModule()
        local mouseModInstance = ReplicatedStorage:FindFirstChild("Mouse")
        if not mouseModInstance then
            pcall(function() mouseModInstance = ReplicatedStorage:WaitForChild("Mouse", 2) end)
        end
        if mouseModInstance and mouseModInstance:IsA("ModuleScript") then
            local ok, mouseMod = pcall(require, mouseModInstance)
            if ok and typeof(mouseMod) == "table" then
                local realStore = { Hit = rawget(mouseMod, "Hit"), Target = rawget(mouseMod, "Target") }
                local mmt = getrawmetatable(mouseMod) or {}
                pcall(setreadonly, mmt, false)
                rawset(mouseMod, "Hit", nil)
                rawset(mouseMod, "Target", nil)
                mmt.__index = function(self, key)
                    local isAllowed = (Core.LockPlayer or Core.AimbotEnabled or Core.PlayerAimEnabled or Core.NPCAimEnabled or _G.G_Aimbot or _G.G_PlayerAim or _G.G_NPCAimbot or _G.G_SilentAim or _G.G_PlayerSilentAim or _G.G_NPCSilentAim or _G.G_SilentAimSkill)
                    local target = Core.CurrentTargetPart or _G.currentSilentAimTarget or _G.DarlingSilentAimTarget
                    if isAllowed and target and target.Parent then
                        local activeKey = Core.CurrentSkillKey
                        if activeKey and Core.isKeyBlacklisted(Core.CurrentToolCategory, activeKey) then
                            return realStore[key] or rawget(self, key)
                        end
                        local isSword = (Core.CurrentToolCategory == "Sword") or (Core.CurrentTool and (string.find(Core.CurrentTool.Name, "Sword") or string.find(Core.CurrentTool.Name, "Buddy")))
                        local tp = (isSword and Core.CurrentTargetRawPosition) or (target and target.Position) or Core.CurrentTargetPosition or Core.CurrentTargetRawPosition
                        if tp and (tp.X == tp.X) then
                            if key == "Hit" then return CFrame.new(tp) end
                            if key == "Target" then return target end
                        end
                    end
                    return realStore[key] or rawget(self, key)
                end
                mmt.__newindex = function(self, key, value)
                    if key == "Hit" or key == "Target" then
                        realStore[key] = value
                    else
                        rawset(self, key, value)
                    end
                end
                setmetatable(mouseMod, mmt)
                pcall(setreadonly, mmt, true)
            end
        end
    end
    hookMouseModule()
    task.spawn(function()
        task.wait(1)
        hookMouseModule()
    end)

    -- ------------------------------------------------------------------------
    -- Hook 3: Remote interception (__namecall for FireServer & InvokeServer)
    -- Intercepts Blox Fruits projectile / skill remotes & redirects Vector3 args
    -- ------------------------------------------------------------------------
    local function handleNamecall(oldNamecall, self, ...)
        local method = getnamecallmethod()
        local args = { ... }

        if args[1] == "TAP" then
            return oldNamecall(self, ...)
        end

        local skillKey = getSkillKeyFromArgs(args)
        if skillKey then
            Core.setCurrentSkillKey(skillKey)
        end

        local activeKey = skillKey or Core.CurrentSkillKey
        local isBlacklisted = false
        if activeKey and Core.isKeyBlacklisted(Core.CurrentToolCategory, activeKey) then
            isBlacklisted = true
        end

        local isAllowed = (Core.LockPlayer or Core.AimbotEnabled or Core.PlayerAimEnabled or Core.NPCAimEnabled or _G.G_Aimbot or _G.G_PlayerAim or _G.G_NPCAimbot or _G.G_SilentAim or _G.G_PlayerSilentAim or _G.G_NPCSilentAim)
        if not isBlacklisted and isAllowed then
            local target = Core.CurrentTargetPart or _G.currentSilentAimTarget or _G.DarlingSilentAimTarget
            if target and target.Parent then
                local isSword = (Core.CurrentToolCategory == "Sword") or (Core.CurrentTool and (string.find(Core.CurrentTool.Name, "Sword") or string.find(Core.CurrentTool.Name, "Buddy")))
                local targetPos = (isSword and Core.CurrentTargetRawPosition) or (target and target.Position) or Core.CurrentTargetPosition or Core.CurrentTargetRawPosition
                if targetPos and (targetPos.X == targetPos.X) then
                    local mLower = method and string.lower(method) or ""
                    if mLower == "fireserver" or mLower == "invokeserver" then
                        local sName = tostring(self)
                        if sName == "RemoteEvent" or sName == "CommE" or sName == "RemoteFunction" or sName == "CommF_" then
                            for i, v in ipairs(args) do
                                if typeof(v) == "Vector3" then
                                    args[i] = targetPos
                                end
                            end

                            -- sword / skill invokeserver redirection
                            if mLower == "invokeserver" and (type(args[1]) == "string" and table.find(SKILL_KEYS, args[1])) then
                                args[2] = targetPos
                            end
                        end
                    end
                end
            end
        end

        return oldNamecall(self, unpack(args))
    end

    local okNamecall = false
    if hookmetamethod then
        pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                return handleNamecall(oldNamecall, self, ...)
            end))
            okNamecall = true
        end)
    end

    if not okNamecall then
        local rawMt = getrawmetatable(game)
        if rawMt then
            local oldNamecall = rawMt.__namecall
            pcall(setreadonly, rawMt, false)
            rawMt.__namecall = newcclosure(function(self, ...)
                return handleNamecall(oldNamecall, self, ...)
            end)
            pcall(setreadonly, rawMt, true)
        end
    end
end

-- ============================================================================
-- RENDER LOOP (TARGET UPDATES - OPTIMIZED FOR 60-144 FPS)
-- ============================================================================
local lastTargetScanTick = 0
local TARGET_SCAN_INTERVAL = 0.08 -- 12.5 Hz entity re-scan interval

local function isCurrentTargetValid(targetPart, targetChar, lpHRP, maxRange)
    if not targetPart or not targetPart.Parent or not targetChar or not targetChar.Parent then
        return false
    end
    local hum = targetChar:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        return false
    end
    local isPlayer = (Players:GetPlayerFromCharacter(targetChar) ~= nil)
    local isPlayerAimbotActive = (Core.AimbotEnabled or Core.PlayerAimEnabled or Core.LockPlayer)
    local isNPCAimbotActive = Core.NPCAimEnabled

    -- Strict entity separation:
    if isNPCAimbotActive and not (Core.AimbotEnabled or Core.PlayerAimEnabled) and isPlayer then
        return false
    end
    if isPlayerAimbotActive and not isNPCAimbotActive and not isPlayer then
        return false
    end

    if isPlayer then
        local pl = Players:GetPlayerFromCharacter(targetChar)
        if pl and Core.isPlayerBlacklisted(pl) then
            return false
        end
    end

    local dist = (targetPart.Position - lpHRP.Position).Magnitude
    if dist > (maxRange + 50) then
        return false
    end

    -- AIM MODE VALIDATION (360°, FOV, 180°)
    local hubSettings = (_G.DarlingHub and _G.DarlingHub.Settings and _G.DarlingHub.Settings.Aim) or Core
    local aimMode = hubSettings.Mode or Core.AimMode or "360"
    if aimMode == "FOV" then
        Camera = Workspace.CurrentCamera or Camera
        if Camera then
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if not onScreen or screenPos.Z <= 0 then
                return false
            end
            local fovCenter = Core.getFOVCenter()
            local fovRadius = Core.getFOVRadius()
            local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - fovCenter).Magnitude
            if screenDist > fovRadius then
                return false
            end
        end
    elseif aimMode == "180" then
        local myPos = lpHRP.Position
        local dir = (targetPart.Position - myPos)
        if dir.Magnitude > 0.001 then
            if lpHRP.CFrame.LookVector:Dot(dir.Unit) < 0 then
                return false
            end
        end
    end

    return true
end

local function updateTargetCycle()
    Camera = Workspace.CurrentCamera or Camera
    local char = LocalPlayer and LocalPlayer.Character
    local lpHRP = char and getHRP(char)

    if not lpHRP or (not Core.LockPlayer and not Core.AimbotEnabled and not Core.PlayerAimEnabled and not Core.NPCAimEnabled) then
        Core.CurrentTargetPart = nil
        Core.CurrentTargetRawPosition = nil
        Core.CurrentTargetPosition = nil
        Core.CurrentTargetCharacter = nil
        _G.DarlingSilentAimTarget = nil
        _G.currentSilentAimTarget = nil
        return
    end

    local hubSettings = (_G.DarlingHub and _G.DarlingHub.Settings and _G.DarlingHub.Settings.Aim) or Core
    local maxRange = hubSettings.MaxRange or Core.MaxRange or 1000
    local now = os.clock()

    local isPlayerAimbotActive = (Core.AimbotEnabled or Core.PlayerAimEnabled)
    local isNPCAimbotActive = Core.NPCAimEnabled

    -- Strict filtering between Player and NPC
    local wantPlayers = isPlayerAimbotActive or (Core.LockPlayer and not isNPCAimbotActive)
    local wantNPCs = isNPCAimbotActive
    if isNPCAimbotActive and not isPlayerAimbotActive and not Core.LockPlayer then
        wantPlayers = false
        wantNPCs = true
    end

    -- 0. Lock Player & Real-time CamLock Mode
    if wantPlayers and (Core.LockPlayer or Core.AimbotEnabled) then
        if not Core.LockedTargetPlayer or not isAlive(Core.LockedTargetPlayer.Character) or Core.isPlayerBlacklisted(Core.LockedTargetPlayer) then
            local myPos = lpHRP.Position
            local closestPlayer = nil
            local closestDist = maxRange
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and isEnemy(p) and not Core.isPlayerBlacklisted(p) and p.Character and isAlive(p.Character) then
                    local pHRP = getHRP(p.Character)
                    if pHRP then
                        local d = (pHRP.Position - myPos).Magnitude
                        if d < closestDist then
                            closestDist = d
                            closestPlayer = p
                        end
                    end
                end
            end
            if closestPlayer then
                Core.LockedTargetPlayer = closestPlayer
                pcall(function()
                    local fw = _G.DarlingHub and _G.DarlingHub.Require and _G.DarlingHub:Require("modules/pvp/floating_widget.lua")
                    local widget = fw and fw.GetWidget and fw.GetWidget("LockPlayerFloatingPill")
                    if widget and Core.LockedTargetPlayer then
                        widget:SetLabel("LOCK: " .. tostring(Core.LockedTargetPlayer.DisplayName or Core.LockedTargetPlayer.Name))
                    end
                end)
            end
        end

        if Core.LockedTargetPlayer and isAlive(Core.LockedTargetPlayer.Character) and not Core.isPlayerBlacklisted(Core.LockedTargetPlayer) then
            local tPart = getEntityPart(Core.LockedTargetPlayer.Character)
            if tPart then
                Core.CurrentTargetPart = tPart
                Core.CurrentTargetRawPosition = tPart.Position
                Core.CurrentTargetPosition = Core.predictPosition(tPart)
                Core.CurrentTargetCharacter = Core.LockedTargetPlayer.Character
                Core.CurrentTargetIsPlayer = true
                _G.DarlingSilentAimTarget = tPart
                _G.currentSilentAimTarget = tPart

                -- Real-time CamLock directly tracking target part (NaN safe)
                local cam = Workspace.CurrentCamera or Camera
                if cam and tPart.Position then
                    local camPos = cam.CFrame.Position
                    local aimPos = tPart.Position + Vector3.new(0, 1.2, 0)
                    if (camPos.X == camPos.X) and (aimPos.X == aimPos.X) and (aimPos - camPos).Magnitude > 0.1 then
                        pcall(function()
                            cam.CFrame = CFrame.new(camPos, aimPos)
                        end)
                    end
                end
                Core.faceTarget(Core.CurrentTargetPosition or tPart.Position)

                local mouseMod = getMouseModule()
                if mouseMod then
                    pcall(function()
                        mouseMod.Hit = CFrame.new(Core.CurrentTargetPosition or tPart.Position)
                        mouseMod.Target = tPart
                    end)
                end
                return
            end
        else
            Core.LockedTargetPlayer = nil
        end
    end

    -- 1. Fast path: if current target is still valid and within interval, update lead prediction directly at native FPS
    if Core.CurrentTargetPart and isCurrentTargetValid(Core.CurrentTargetPart, Core.CurrentTargetCharacter, lpHRP, maxRange) then
        if not (wantPlayers and not wantNPCs and not Core.CurrentTargetIsPlayer) and not (wantNPCs and not wantPlayers and Core.CurrentTargetIsPlayer) then
            if (now - lastTargetScanTick) < TARGET_SCAN_INTERVAL then
                Core.CurrentTargetRawPosition = Core.CurrentTargetPart.Position
                Core.CurrentTargetPosition = Core.predictPosition(Core.CurrentTargetPart)
                local mouseMod = getMouseModule()
                if mouseMod and Core.CurrentTargetPosition then
                    pcall(function()
                        mouseMod.Hit = CFrame.new(Core.CurrentTargetPosition)
                        mouseMod.Target = Core.CurrentTargetPart
                    end)
                end

                if (Core.AimbotEnabled or Core.LockPlayer) and Core.CurrentTargetPart then
                    local cam = Workspace.CurrentCamera or Camera
                    if cam and Core.CurrentTargetPart.Position then
                        local camPos = cam.CFrame.Position
                        local aimPos = (Core.CurrentTargetPosition or Core.CurrentTargetPart.Position) + Vector3.new(0, 1.2, 0)
                        if (camPos.X == camPos.X) and (aimPos.X == aimPos.X) and (aimPos - camPos).Magnitude > 0.1 then
                            pcall(function()
                                cam.CFrame = CFrame.new(camPos, aimPos)
                            end)
                        end
                    end
                    Core.faceTarget(Core.CurrentTargetPosition or Core.CurrentTargetPart.Position)
                end
                return
            end
        end
    end

    -- 2. Scan path: periodically or when target is invalid/lost, find the optimal target
    lastTargetScanTick = now
    local targetPart, predictedPos, targetChar = nil, nil, nil

    if wantPlayers then
        targetPart, predictedPos, targetChar = resolvePlayerTarget(lpHRP)
        if targetPart then Core.CurrentTargetIsPlayer = true end
    end

    if not targetPart and wantNPCs then
        targetPart, predictedPos, targetChar = resolveNPCTarget(lpHRP)
        if targetPart then Core.CurrentTargetIsPlayer = false end
    end

    Core.CurrentTargetPart = targetPart
    Core.CurrentTargetRawPosition = targetPart and targetPart.Position or nil
    Core.CurrentTargetPosition = predictedPos
    Core.CurrentTargetCharacter = targetChar
    _G.DarlingSilentAimTarget = targetPart
    _G.currentSilentAimTarget = targetPart

    local mouseMod = getMouseModule()
    if mouseMod then
        if targetPart and (predictedPos or Core.CurrentTargetRawPosition) then
            local aimPos = predictedPos or Core.CurrentTargetRawPosition
            pcall(function()
                mouseMod.Hit = CFrame.new(aimPos)
                mouseMod.Target = targetPart
            end)
        else
            pcall(function()
                mouseMod.Target = nil
            end)
        end
    end

    if (Core.AimbotEnabled or Core.LockPlayer) and targetPart then
        local cam = Workspace.CurrentCamera or Camera
        if cam and targetPart.Position then
            local camPos = cam.CFrame.Position
            local aimPos = (predictedPos or targetPart.Position) + Vector3.new(0, 1.2, 0)
            if (camPos.X == camPos.X) and (aimPos.X == aimPos.X) and (aimPos - camPos).Magnitude > 0.1 then
                pcall(function()
                    cam.CFrame = CFrame.new(camPos, aimPos)
                end)
            end
        end
        Core.faceTarget(predictedPos or targetPart.Position)
    end
end

function Core.startLoop()
    if Core.RenderConnection then return end
    Core.installHooks()
    lastTargetScanTick = 0
    Core.RenderConnection = RunService.RenderStepped:Connect(updateTargetCycle)
end

function Core.stopLoop()
    if Core.PlayerAimEnabled or Core.NPCAimEnabled or Core.LockPlayer or Core.AimbotEnabled then return end
    if Core.RenderConnection then
        pcall(function() Core.RenderConnection:Disconnect() end)
        Core.RenderConnection = nil
    end
    lastTargetScanTick = 0
    Core.CurrentTargetPart = nil
    Core.CurrentTargetRawPosition = nil
    Core.CurrentTargetPosition = nil
    Core.CurrentTargetCharacter = nil
    _G.DarlingSilentAimTarget = nil
    _G.currentSilentAimTarget = nil

    local mouseMod = getMouseModule()
    if mouseMod then
        pcall(function()
            mouseMod.Target = nil
        end)
    end
end

-- ============================================================================
-- INPUT AND CHARACTER HOOKS
-- ============================================================================
local function setupCharacter(char)
    for _, c in ipairs(Core.CharConnections) do pcall(function() c:Disconnect() end) end
    Core.CharConnections = {}

    local function checkTool(child)
        if child:IsA("Tool") then
            Core.CurrentTool = child
            Core.CurrentToolCategory = Core.getToolCategory(child)
            Core.CurrentSkillKey = nil
            table.insert(Core.CharConnections, child.AncestryChanged:Connect(function(_, parent)
                if not parent then Core.CurrentTool = nil end
            end))
        end
    end

    for _, child in ipairs(char:GetChildren()) do checkTool(child) end
    table.insert(Core.CharConnections, char.ChildAdded:Connect(checkTool))
    table.insert(Core.CharConnections, char.ChildRemoved:Connect(function(child)
        if child == Core.CurrentTool then Core.CurrentTool = nil end
    end))
end

if LocalPlayer then
    LocalPlayer.CharacterAdded:Connect(setupCharacter)
    if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
end

if UserInputService and UserInputService.InputBegan then
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        local keyMap = {
            [Enum.KeyCode.Z] = "Z",
            [Enum.KeyCode.X] = "X",
            [Enum.KeyCode.C] = "C",
            [Enum.KeyCode.V] = "V",
            [Enum.KeyCode.F] = "F",
        }
        local mapped = input and input.KeyCode and keyMap[input.KeyCode]
        if mapped then Core.setCurrentSkillKey(mapped) end
    end)
end

-- Mobile buttons hook
task.spawn(function()
    while not LocalPlayer or not LocalPlayer:FindFirstChild("PlayerGui") do task.wait(0.5) end
    local pGui = LocalPlayer.PlayerGui
    local main = pGui:WaitForChild("Main", 10)
    if main then
        local skills = main:WaitForChild("Skills", 10)
        if skills then
            local function hookBtn(b)
                if (b:IsA("ImageButton") or b:IsA("TextButton")) and table.find(SKILL_KEYS, b.Name) then
                    b.Activated:Connect(function() Core.setCurrentSkillKey(b.Name) end)
                end
            end
            for _, wf in ipairs(skills:GetChildren()) do
                if wf:IsA("GuiObject") then
                    for _, b in ipairs(wf:GetChildren()) do hookBtn(b) end
                end
            end
        end
    end
end)

function Core.setLockPlayer(state)
    Core.LockPlayer = (state == true)
    if state then
        local lp = Players.LocalPlayer
        local char = lp and lp.Character
        local lpHRP = char and char:FindFirstChild("HumanoidRootPart")
        if lpHRP then
            local myPos = lpHRP.Position
            local closestPlayer = nil
            local closestDist = 2000
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and isEnemy(p) and not Core.isPlayerBlacklisted(p) and p.Character and isAlive(p.Character) then
                    local pHRP = getHRP(p.Character)
                    if pHRP then
                        local d = (pHRP.Position - myPos).Magnitude
                        if d < closestDist then
                            closestDist = d
                            closestPlayer = p
                        end
                    end
                end
            end
            Core.LockedTargetPlayer = closestPlayer
        end
        Core.startLoop()
    else
        Core.LockedTargetPlayer = nil
        if not Core.PlayerAimEnabled and not Core.NPCAimEnabled and not Core.AimbotEnabled then
            Core.stopLoop()
        end
    end

    pcall(function()
        local fw = _G.DarlingHub and _G.DarlingHub.Require and _G.DarlingHub:Require("modules/pvp/floating_widget.lua")
        local widget = fw and fw.GetWidget and fw.GetWidget("LockPlayerFloatingPill")
        if widget then
            if state and Core.LockedTargetPlayer then
                widget:SetLabel("LOCK: " .. tostring(Core.LockedTargetPlayer.DisplayName or Core.LockedTargetPlayer.Name))
            else
                widget:SetLabel("LOCK")
            end
        end
    end)
end

function Core.setAimbot(state)
    Core.AimbotEnabled = (state == true)
    if not state then
        Core.LockedTargetPlayer = nil
    end
    if state then
        Core.startLoop()
    else
        if not Core.PlayerAimEnabled and not Core.NPCAimEnabled and not Core.LockPlayer then
            Core.stopLoop()
        end
    end
end

function Core.toggleLockPlayer()
    return Core.setLockPlayer(not Core.LockPlayer)
end

-- Global exposure across both _G and getgenv()
_G.MonodyCombatCore = Core
_G.DarlingCombatCore = Core
if getgenv then
    pcall(function()
        getgenv().MonodyCombatCore = Core
        getgenv().DarlingCombatCore = Core
    end)
end

return Core
