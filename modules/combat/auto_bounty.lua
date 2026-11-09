--[[
    Darling Hub - Auto Bounty Engine (Version 1.3)
    Darling Hub combat engine
    Features: Smooth linear tween flight, RunService noclip, SafeZone & PvP detection,
    Auto Buso, FastAttack M1, weapon equipping, auto soru, low HP flee, and target skip.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    local startW = tick()
    while not LocalPlayer and tick() - startW < 3 do
        task.wait(0.05)
        LocalPlayer = Players.LocalPlayer
    end
end

local lastCombatActionTime = 0

local AutoBounty = {
    Enabled = false,
    Running = false,
    CurrentTarget = nil,
    ReachedTarget = false,
    Status = "Idle",
    SkippedTargets = {},

    -- Fast Mode & Team Selection
    AutoBountyMode = false,
    AutoTeam = "Pirates",

    -- Movement & Dual Tween Settings
    StartWait = 2,
    StopDistance = 6,
    FlySpeed = 200,
    NearTweenSpeed = 310,
    FarTweenSpeed = 200,
    TweenThreshold = 1000,
    MaxDistance = 100000,
    NoSafeZone = false,
    NoMarineAlly = false,

    -- Soru & Skills & Attacks
    AutoSoru = false,
    AutoSkills = false,
    AutoAttack = false,
    FastAttack = false,
    AutoBuso = false,
    AutoKen = false,
    AutoEnablePvp = false,
    AutoV4 = false,

    -- Fast Attack Speed Configuration
    FastAttackSpeed = "Medium (0.10s)",
    AttackDelay = 0.10,
    HitDelay = 0.10,

    -- Excluded Skills (Fruit F excluded by default)
    DisabledSkills = {
        ["Fruit F"] = true,
    },

    -- Auto Flee & Cancel Health
    AutoFlee = false,
    CancelHealth = false,
    FleeHP = 30, -- percentage
    ReturnHP = 50, -- percentage to resume attacking
    FleeHeight = 1500,

    -- Combat Enhancements: Aimbot Lock & Orbit
    AimbotLock = false,
    CombatDistance = 5.5,
    Orbit = false,
    OrbitDistance = 3,
    OrbitSpeed = 12.0,

    -- Auto Hop & Target Player Count
    AutoHop = false,
    HopIfEmpty = true,
    TargetPlayerCount = 8,

    -- Weapon preferences
    Weapons = {
        Melee = false,
        Sword = false,
        Fruit = false,
        Gun = false,
    },
    UseMelee = false,
    UseSword = false,
    UseFruit = false,
    UseGun = false,
}

local currentTween = nil
local noclipConn = nil
local stickyConn = nil
local bountyLoopThread = nil
local isFleeing = false

-- Anti-Seat: helper function to disable seat triggers if encountered
local function disableSeat(seat)
    if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
        pcall(function()
            seat.CanTouch = false
            seat.Disabled = true
        end)
    end
end

-- SafeZone & PvP State Verifier
local function readPvPState(target)
    if not target then return false end
    local ok, pvpOn = pcall(function()
        if target:IsA("Player") and target:GetAttribute("PvpDisabled") == true then
            return false
        end
        local char = target.Character or (target:IsA("Model") and target)
        if char then
            if char:FindFirstChildOfClass("ForceField") then
                return false
            end
            if char:GetAttribute("PvpDisabled") == true then
                return false
            end
        end
        return true
    end)
    return ok and pvpOn
end

local function inSafeZone(target)
    if not target then return false end
    local ok, inZone = pcall(function()
        local char = target.Character or (target:IsA("Model") and target)
        if not char then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Sit == true then return true end
        if char:FindFirstChildOfClass("ForceField") then return true end
        if char:GetAttribute("SafeZone") == true then return true end
        if target:IsA("Player") and target:GetAttribute("SafeZone") == true then return true end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local hrpPos = hrp.Position

        local function checkFolder(folder)
            if not folder then return false end
            for _, zone in ipairs(folder:GetChildren()) do
                if zone:IsA("BasePart") then
                    local mesh = zone:FindFirstChild("Mesh")
                    local radius = 0
                    if mesh and mesh:IsA("SpecialMesh") then
                        radius = (zone.Size.X * mesh.Scale.X) / 2
                    else
                        radius = math.min(zone.Size.X, zone.Size.Z) / 2
                    end
                    if radius > 500 then radius = 350 end
                    if radius <= 0 then radius = 350 end
                    if (zone.Position - hrpPos).Magnitude <= radius then
                        return true
                    end

                    -- Box bounds check
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
    return ok and inZone == true
end

local function isLocalPvpDisabled()
    local ok, dis = pcall(function()
        if LocalPlayer:GetAttribute("PvpDisabled") == true then return true end
        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local main = pGui and pGui:FindFirstChild("Main")
        if not main then return false end
        local bList = main:FindFirstChild("BottomHUDList")
        if bList and bList:FindFirstChild("PvpDisabled") and bList.PvpDisabled.Visible == true then
            return true
        end
        if main:FindFirstChild("PvpDisabled") and main.PvpDisabled.Visible == true then
            return true
        end
        return false
    end)
    return ok and dis == true
end

local lastPvpCheckTick = 0
local function autoEnablePvp()
    if not AutoBounty.AutoEnablePvp then return end
    local now = os.clock()
    if (now - lastPvpCheckTick) < 0.5 then return end
    lastPvpCheckTick = now

    pcall(function()
        if isLocalPvpDisabled() then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local commF = remotes and remotes:FindFirstChild("CommF_")
            if commF then
                commF:InvokeServer("EnablePvp")
            end
        end
    end)
end

AutoBounty.autoEnablePvp = autoEnablePvp

local function isEnemy(targetplayer)
    if not targetplayer or targetplayer == LocalPlayer then return false end
    if AutoBounty.SkippedTargets[targetplayer.UserId] or AutoBounty.SkippedTargets[targetplayer.Name] then return false end
    if _G.DarlingBlacklistedPlayers and (_G.DarlingBlacklistedPlayers[targetplayer.UserId] or _G.DarlingBlacklistedPlayers[targetplayer.Name]) then return false end

    local myTeam = LocalPlayer.Team
    local targetTeam = targetplayer.Team
    if myTeam and targetTeam then
        if myTeam.Name == "Marines" and targetTeam.Name == "Marines" and AutoBounty.NoMarineAlly then
            return false
        end
    end
    return true
end

local function isPlayerAlive(p)
    if not (p and p.Character) then return false end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    return (hum and hum.Health > 0 and hrp ~= nil)
end

-- Combat Status Check (Prevents logging penalty during server hops)
local function checkInCombat()
    -- 1. Official Blox Fruits PvP Combat Tag check in PlayerGui (BottomHUDList.InCombat or Main.InCombat)
    local inCombatGui = false
    pcall(function()
        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
        local main = pGui and pGui:FindFirstChild("Main")
        if main then
            local bottom = main:FindFirstChild("BottomHUDList")
            local el = (bottom and bottom:FindFirstChild("InCombat")) or main:FindFirstChild("InCombat")
            if el and el.Visible == true then
                local txt = tostring(el:IsA("TextLabel") and el.Text or ""):lower()
                if txt == "" or txt:find("risk", 1, true) or txt:find("combat", 1, true) then
                    inCombatGui = true
                else
                    inCombatGui = true
                end
            end
        end
    end)
    if inCombatGui then
        return true
    end

    -- 2. Character attribute and state check
    local char = LocalPlayer.Character
    if char then
        if char:GetAttribute("InCombat") == true or char:GetAttribute("Busy") == true or char:FindFirstChild("InCombat") ~= nil then
            return true
        end
    end

    -- 3. Local combat action timestamp debounce (at least 6.0 seconds after combat activity)
    if (os.clock() - lastCombatActionTime) < 6.0 then
        return true
    end
    return false
end
AutoBounty.checkInCombat = checkInCombat

-- RunService Stepped Noclip (Phases through walls and obstacles without physics collision)
local function ensureNoclip()
    if not noclipConn then
        noclipConn = RunService.Stepped:Connect(function()
            if not (AutoBounty.Enabled or isHoppingActive or currentTween ~= nil or isFleeing) then
                return
            end
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end)
    end
end

local function disableNoclip()
    if noclipConn then
        pcall(function() noclipConn:Disconnect() end)
        noclipConn = nil
    end
end

-- In-combat hysteresis state to prevent oscillation between tween flight and melee stick
local inCombatRange = false

local function ensureNotSeated()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        end)
        if hum.Sit or hum.SeatPart then
            hum.Sit = false
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            pcall(function()
                for _, d in ipairs(char:GetDescendants()) do
                    if d:IsA("Weld") and d.Name == "SeatWeld" then
                        d:Destroy()
                    end
                end
            end)
        end
    end
end

-- Continuous Sticky Tracking
-- Glues local player position right next to target 60 times/sec, never stuttering or stopping
local function ensureStickyFollow()
    if stickyConn then return end
    stickyConn = RunService.Heartbeat:Connect(function(dt)
        if not AutoBounty.Enabled or isFleeing then return end
        ensureNotSeated()
        local target = AutoBounty.CurrentTarget
        if not (target and isPlayerAlive(target)) then return end

        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local tChar = target.Character
        local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if not (myHRP and tHRP) then return end

        local dist = (tHRP.Position - myHRP.Position).Magnitude
        local tPos = tHRP.Position

        -- In engagement range (<= 85 studs), stick permanently to the target
        if inCombatRange or dist <= 85 then
            AutoBounty.ReachedTarget = true
            if currentTween then
                pcall(function() currentTween:Cancel() end)
                currentTween = nil
                lastTweenGoal = nil
            end

            local followCF = nil
            local distOffset = AutoBounty.CombatDistance or AutoBounty.OrbitDistance or 10.0
            if AutoBounty.Orbit then
                local orbitAngle = (tick() * (AutoBounty.OrbitSpeed or 6.0)) % (2 * math.pi)
                local r = distOffset
                local h = 2.0
                local orbitPos = tPos + Vector3.new(math.cos(orbitAngle) * r, h, math.sin(orbitAngle) * r)
                followCF = CFrame.lookAt(orbitPos, tPos)
            else
                local behindOffset = tHRP.CFrame * CFrame.new(0, 2.0, distOffset)
                followCF = CFrame.lookAt(behindOffset.Position, tPos)
            end

            pcall(function()
                myHRP.CFrame = followCF
                myHRP.AssemblyLinearVelocity = Vector3.zero
                myHRP.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end)
end

local function disableStickyFollow()
    if stickyConn then
        pcall(function() stickyConn:Disconnect() end)
        stickyConn = nil
    end
end

local function getHub()
    return _G.DarlingHub or (getgenv and getgenv().DarlingHub)
end

local enableStickyFollow = ensureStickyFollow

local speedPresets = {
    ["Instant (0s)"] = 0,
    ["Turbo (0.03s)"] = 0.03,
    ["Fast (0.06s)"] = 0.06,
    ["Medium (0.10s)"] = 0.10,
    ["Safe (0.15s)"] = 0.15,
    ["Normal (0.25s)"] = 0.25,
}

function AutoBounty.setAttackSpeed(val)
    if type(val) == "number" then
        AutoBounty.AttackDelay = math.clamp(val, 0, 1)
        AutoBounty.FastAttackSpeed = tostring(val) .. "s"
    elseif type(val) == "string" then
        if speedPresets[val] ~= nil then
            AutoBounty.AttackDelay = speedPresets[val]
            AutoBounty.FastAttackSpeed = val
        else
            local num = tonumber(val:match("[%d%.]+"))
            if num then
                AutoBounty.AttackDelay = num
                AutoBounty.FastAttackSpeed = val
            end
        end
    end
end

-- FastAttack execution is handled in controlled rhythm inside the combat loop to prioritize skills
local performFastAttack = nil
local fastAttackThread = nil
local function startFastAttackLoop()
    -- Controlled rhythm inside runBountyLoop; no runaway background thread
end

local function stopFastAttackLoop()
    if fastAttackThread then
        pcall(function() task.cancel(fastAttackThread) end)
        fastAttackThread = nil
    end
end

local function removeHoldVelocity()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, child in ipairs(hrp:GetChildren()) do
            if child.Name == "DarlingBountyHold" or child.Name == "Hold" or child:IsA("BodyVelocity") then
                pcall(function() child:Destroy() end)
            end
        end
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
    end
end

local function ensureHoldVelocity()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and not hrp:FindFirstChild("DarlingBountyHold") then
        local hold = Instance.new("BodyVelocity")
        hold.Name = "DarlingBountyHold"
        hold.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        hold.Velocity = Vector3.zero
        hold.Parent = hrp
    end
end

-- Stop Tween and Reset Movement cleanly
local lastTweenGoal = nil

local function stopTween()
    if currentTween then
        pcall(function() currentTween:Cancel() end)
        currentTween = nil
    end
    lastTweenGoal = nil
    removeHoldVelocity()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
    if hrp then
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end
end

-- Smooth linear tweening to target position
local function tweenTo(targetCF)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then
        stopTween()
        return false
    end

    if hum.Sit then hum.Sit = false end
    ensureHoldVelocity()

    local dist = (targetCF.Position - hrp.Position).Magnitude
    if dist <= (AutoBounty.StopDistance or 6) then
        stopTween()
        hrp.CFrame = targetCF
        lastTweenGoal = nil
        return true
    end

    -- If already tweening to near this goal, let it continue smoothly
    if currentTween and lastTweenGoal and (lastTweenGoal - targetCF.Position).Magnitude < 8 then
        return true
    end

    local speed = AutoBounty.FlySpeed or 350
    if AutoBounty.NearTweenSpeed and AutoBounty.FarTweenSpeed then
        speed = (dist > 1000) and AutoBounty.FarTweenSpeed or AutoBounty.NearTweenSpeed
    end
    speed = math.clamp(tonumber(speed) or 350, 50, 500)
    local duration = math.clamp(dist / speed, 0.05, 120)

    if currentTween then
        pcall(function() currentTween:Cancel() end)
    end

    lastTweenGoal = targetCF.Position
    pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)

    currentTween = TweenService:Create(
        hrp,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        { CFrame = targetCF }
    )
    currentTween:Play()
    return true
end

-- Auto Buso Haki (Armament Haki / Aura)
local lastBusoTick = 0

local function isBusoActive()
    local char = LocalPlayer.Character
    if not char then return false end

    -- Check Character only (Blox Fruits standard HasBuso presence check)
    if char:FindFirstChild("HasBuso") or char:GetAttribute("HasBuso") == true then
        return true
    end
    if char:FindFirstChild("Buso") or char:GetAttribute("Buso") == true then
        return true
    end

    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and (part:FindFirstChild("Buso") or part:FindFirstChild("Aura")) then
            return true
        end
    end

    return false
end

local function autoBuso(force)
    if not AutoBounty.AutoBuso then return end
    local char = LocalPlayer.Character
    if not char then return end
    if isBusoActive() and not force then return end

    local now = os.clock()
    if (now - lastBusoTick) < 1.2 and not force then return end
    lastBusoTick = now

    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local commF = (remotes and remotes:FindFirstChild("CommF_")) or ReplicatedStorage:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("Buso")
        end
    end)
end

-- Auto Ken Haki (Observation Haki / Instinct)
-- Authentic multi-layer activator matching Native MobileContextButtons and getrenv()._G.OM
local kenDaemonThread = nil
local lastKenTick = 0

local function isObservationActive()
    local char = LocalPlayer.Character
    if not char then return false end

    -- 1. Game environment OM (ObservationManager) active flag (definitive truth)
    local renvG = (getrenv and getrenv()._G) or _G
    local om = renvG and renvG.OM
    if om and type(om) == "table" and type(om.active) == "boolean" then
        if om.active == false then
            local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
            if pGui then
                local mcb = pGui:FindFirstChild("MobileContextButtons")
                local cbf = mcb and mcb:FindFirstChild("ContextButtonFrame")
                local kenBtn = cbf and (cbf:FindFirstChild("BoundActionKen") or cbf:FindFirstChild("Instinct") or cbf:FindFirstChild("Ken"))
                if kenBtn and kenBtn:GetAttribute("Selected") == true then
                    pcall(function() kenBtn:SetAttribute("Selected", false) end)
                end
            end
        end
        return om.active == true
    end

    -- 2. Visual aura / screen effects
    local lighting = game:GetService("Lighting")
    if lighting and (lighting:FindFirstChild("ObservationEffect") or lighting:FindFirstChild("KenEffect")) then
        return true
    end

    -- 3. Character tags / attributes for active Ken (not baseline ability tag)
    if CollectionService and (CollectionService:HasTag(char, "KenActive") or CollectionService:HasTag(char, "ObservationActive")) then
        return true
    end
    if char:GetAttribute("KenActive") == true or char:GetAttribute("ObservationActive") == true then
        return true
    end

    -- 4. Mobile button fallback only if OM was not found
    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        local mcb = pGui:FindFirstChild("MobileContextButtons")
        local cbf = mcb and mcb:FindFirstChild("ContextButtonFrame")
        local kenBtn = cbf and (cbf:FindFirstChild("BoundActionKen") or cbf:FindFirstChild("Instinct") or cbf:FindFirstChild("Ken"))
        if kenBtn and kenBtn:GetAttribute("Selected") == true then
            return true
        end
    end

    return false
end

local function autoKenHaki(force)
    if not AutoBounty.AutoKen then return end
    if not force and isObservationActive() then return end

    local now = os.clock()
    if (now - lastKenTick) < 1.5 and not force then return end
    lastKenTick = now

    pcall(function()
        -- 1. MobileContextButtons Activated signal (trigger real game handler without forcing attribute)
        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then
            local mcb = pGui:FindFirstChild("MobileContextButtons")
            local cbf = mcb and mcb:FindFirstChild("ContextButtonFrame")
            local kenBtn = cbf and (cbf:FindFirstChild("BoundActionKen") or cbf:FindFirstChild("Instinct") or cbf:FindFirstChild("Ken"))
            if kenBtn and firesignal then
                pcall(firesignal, kenBtn.Activated)
            end
        end

        -- 2. ObservationManager via game environment (getrenv) and server Comm remotes
        local renvG = (getrenv and getrenv()._G) or _G
        local om = renvG and renvG.OM
        if om and not om.active then
            pcall(function()
                om.radius = 0
                om:setActive(true)
            end)
        end

        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local commE = (remotes and remotes:FindFirstChild("CommE")) or ReplicatedStorage:FindFirstChild("CommE")
        if commE then
            pcall(function() commE:FireServer("Ken", true) end)
        end
        local commF = (remotes and remotes:FindFirstChild("CommF_")) or ReplicatedStorage:FindFirstChild("CommF_")
        if commF then
            pcall(function() commF:InvokeServer("Ken") end)
        end

        -- 3. PC VirtualInputManager KeyCode.E with HumanoidRootPart target
        if VirtualInputManager and not isObservationActive() then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, hrp or game)
            task.delay(0.08, function()
                pcall(function()
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, hrp or game)
                end)
            end)
        end
    end)
end

local function startKenDaemon()
    if kenDaemonThread then return end
    kenDaemonThread = task.spawn(function()
        while AutoBounty.Enabled do
            task.wait(0.5)
            if AutoBounty.AutoKen and not isFleeing and not isObservationActive() then
                autoKenHaki(false)
            end
        end
        kenDaemonThread = nil
    end)
end

AutoBounty.isBusoActive = isBusoActive
AutoBounty.autoBuso = autoBuso
AutoBounty.isObservationActive = isObservationActive
AutoBounty.autoKenHaki = autoKenHaki

-- Reset Ken and Buso state and reactivate on character spawn with multi-step retry loop
local lastCharHealth = 100
LocalPlayer.CharacterAdded:Connect(function(char)
    if not AutoBounty.Enabled then return end
    inCombatRange = false
    isFleeing = false
    lastCharHealth = 100

    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        end)
        lastCharHealth = hum.Health
        hum.HealthChanged:Connect(function(newHealth)
            if not AutoBounty.Enabled then return end
            if newHealth < lastCharHealth then
                lastCombatActionTime = os.clock()
            end
            lastCharHealth = newHealth
        end)
    end

    task.spawn(function()
        local hrp = char:WaitForChild("HumanoidRootPart", 10)
        local h = char:WaitForChild("Humanoid", 10)
        if not (hrp and h) then return end

        -- Post-respawn delay for invulnerability and black screen animation
        task.wait(2.2)

        for attempt = 1, 6 do
            if not AutoBounty.Enabled then break end
            if not LocalPlayer.Character or LocalPlayer.Character ~= char then break end
            if h.Health <= 0 then break end

            if AutoBounty.AutoBuso and not isBusoActive() then
                autoBuso(true)
            end
            if AutoBounty.AutoKen and not isObservationActive() then
                autoKenHaki(true)
            end
            if AutoBounty.AutoEnablePvp then
                autoEnablePvp()
            end

            if isBusoActive() and isObservationActive() then
                break
            end
            task.wait(1.2)
        end
    end)
end)

-- Persistent Haki Loop (started when AutoBounty is enabled)
local hakiLoopThread = nil
local function startHakiLoop()
    if hakiLoopThread then return end
    hakiLoopThread = task.spawn(function()
        while AutoBounty.Enabled do
            task.wait(2.5)
            if AutoBounty.AutoBuso and not isBusoActive() then
                autoBuso(false)
            end
            if AutoBounty.AutoKen and not isObservationActive() then
                autoKenHaki(false)
            end
        end
        hakiLoopThread = nil
    end)
end

-- Auto Race V4 (Combat Awakening)
local lastV4CheckTick = 0
local function autoRaceV4()
    if not AutoBounty.AutoV4 then return end
    local now = os.clock()
    if (now - lastV4CheckTick) < 0.35 then return end
    lastV4CheckTick = now

    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end

        local energy = char:FindFirstChild("RaceEnergy")
        local transformed = char:FindFirstChild("RaceTransformed")
        local stun = char:FindFirstChild("Stun")
        local busy = char:FindFirstChild("Busy")

        local hasEnergy = energy and tonumber(energy.Value) and tonumber(energy.Value) >= 1
        local notTransformed = not transformed or (transformed.Value ~= true)
        local notStunned = not stun or (tonumber(stun.Value) or 0) <= 0
        local notBusy = not busy or (busy.Value ~= true)

        if hasEnergy and notTransformed and notStunned and notBusy then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local commE = remotes and remotes:FindFirstChild("CommE")
            if commE and commE:IsA("RemoteEvent") then
                commE:FireServer("ActivateAwakening", true)
            end

            local events = ReplicatedStorage:FindFirstChild("Events")
            local v4Event = events and events:FindFirstChild("ActivateRaceV4")
            if v4Event and v4Event:IsA("BindableEvent") then
                v4Event:Fire()
            end

            local bp = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:FindFirstChild("Backpack")
            local awk = bp and bp:FindFirstChild("Awakening")
            if awk then
                local rf = awk:FindFirstChild("RemoteFunction")
                if rf and rf:IsA("RemoteFunction") then pcall(function() rf:InvokeServer(true) end) end
                local re = awk:FindFirstChild("RemoteEvent")
                if re and re:IsA("RemoteEvent") then pcall(function() re:FireServer(true) end) end
            end

            if VirtualInputManager then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                task.wait(0.04)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
            end
        end
    end)
end

-- Net remotes resolution for instant hit registration
local RegisterHit = nil
local RegisterAttack = nil

local function resolveNetRemotes()
    if RegisterHit and RegisterAttack then return true end
    pcall(function()
        local net = (ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net"))
            or ReplicatedStorage:FindFirstChild("Net")
        if net then
            RegisterHit = net:FindFirstChild("RE/RegisterHit") or net:FindFirstChild("RegisterHit") or net["RE/RegisterHit"]
            RegisterAttack = net:FindFirstChild("RE/RegisterAttack") or net:FindFirstChild("RegisterAttack") or net["RE/RegisterAttack"]
        end
        if not (RegisterHit and RegisterAttack) then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then
                RegisterHit = RegisterHit or remotes:FindFirstChild("RE/RegisterHit") or remotes:FindFirstChild("RegisterHit")
                RegisterAttack = RegisterAttack or remotes:FindFirstChild("RE/RegisterAttack") or remotes:FindFirstChild("RegisterAttack")
            end
        end
        if not (RegisterHit and RegisterAttack) then
            local common = ReplicatedStorage:FindFirstChild("Common")
            if common then
                RegisterHit = RegisterHit or common:FindFirstChild("RE/RegisterHit") or common:FindFirstChild("RegisterHit")
                RegisterAttack = RegisterAttack or common:FindFirstChild("RE/RegisterAttack") or common:FindFirstChild("RegisterAttack")
            end
        end
    end)
    return (RegisterHit ~= nil and RegisterAttack ~= nil)
end

-- Auto Click / FastAttack (Real attack delay, full Net remotes & LeftClickRemote)
local lastFastAttackTick = 0
performFastAttack = function(targetChar)
    lastCombatActionTime = os.clock()
    if not AutoBounty.AutoAttack then return end
    local now = os.clock()
    local delay = AutoBounty.AttackDelay or 0.03
    if delay > 0 and (now - lastFastAttackTick) < delay then return end
    lastFastAttackTick = now

    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char and char:FindFirstChildOfClass("Tool")
        if not tool or tool.ToolTip == "Gun" then return end

        local tHRP = targetChar and (targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("UpperTorso"))
        if not tHRP then return end

        -- 1. Net remote hit registration
        resolveNetRemotes()
        if RegisterAttack and RegisterHit then
            local othersEnemies = { { targetChar, tHRP } }
            RegisterAttack:FireServer(delay)
            RegisterHit:FireServer(tHRP, othersEnemies)
        end

        -- 2. Tool LeftClickRemote for fruit / sword / melee
        if tool:FindFirstChild("LeftClickRemote") then
            local myHRP = char:FindFirstChild("HumanoidRootPart")
            local myPos = (myHRP and myHRP.Position) or char:GetPivot().Position
            local dir = (tHRP.Position - myPos).Unit
            tool.LeftClickRemote:FireServer(dir, 1)
        end

        -- 3. Tool activation & input click
        tool:Activate()
        if VirtualUser then
            VirtualUser:Button1Down(Vector2.new(500, 500))
            task.wait(0.005)
            VirtualUser:Button1Up(Vector2.new(500, 500))
        elseif VirtualInputManager then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.005)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
    end)
end

-- Weapon category matching for Blox Fruits (Melee, Sword, Fruit, Gun)
local function getToolCategory(tool)
    if not (tool and tool:IsA("Tool")) then return nil end
    local wtype = tool:GetAttribute("WeaponType")
    if wtype == "Demon Fruit" or wtype == "Fruit" or wtype == "Blox Fruit" then
        return "Fruit"
    elseif wtype == "Sword" then
        return "Sword"
    elseif wtype == "Melee" then
        return "Melee"
    elseif wtype == "Gun" then
        return "Gun"
    end
    local tip = string.lower(tool.ToolTip or "")
    local name = string.lower(tool.Name or "")
    if tip:find("gun") or name:find("guitar") or name:find("rifle") or name:find("cannon") or name:find("bow") or name:find("kabucha") or name:find("slingshot") or name:find("bazooka") or name:find("musket") or name:find("flintlock") then
        return "Gun"
    elseif tip:find("sword") or name:find("blade") or name:find("katana") or name:find("saber") or name:find("scythe") or name:find("anchor") or name:find("trident") or name:find("dagger") or name:find("cutlass") or name:find("pole") or name:find("bisento") or name:find("yama") or name:find("tushita") then
        return "Sword"
    elseif tip:find("melee") or name:find("godhuman") or name:find("superhuman") or name:find("karate") or name:find("claw") or name:find("talon") or name:find("step") or name:find("sanguine") or name:find("combat") or name:find("breath") or name:find("kung fu") then
        return "Melee"
    end
    -- In Blox Fruits, any other weapon tool is a Fruit (Portal, Buddha, Kitsune, Rumble, etc.)
    return "Fruit"
end

local function matchesWeaponType(tool, category)
    if not (tool and tool:IsA("Tool")) then return false end
    local cat = getToolCategory(tool)
    return cat == category
end

-- Weapon Equip from Backpack or Character (returns false if no matching tool is available)
local function equipWeapon(category)
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool and matchesWeaponType(currentTool, category) then
        return true
    end

    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and matchesWeaponType(item, category) then
                hum:EquipTool(item)
                return true
            end
        end
    end

    return false
end

-- Robust verification for excluded / disabled skills (supports dict, array, and category/tool candidate names)
local function isSkillDisabled(tool, skillKey, explicitCategory)
    if not AutoBounty.DisabledSkills or type(AutoBounty.DisabledSkills) ~= "table" then
        return false
    end
    local sKey = (typeof(skillKey) == "string") and skillKey or (skillKey and skillKey.Name) or ""
    if sKey == "" then return false end

    local cat = explicitCategory or (tool and getToolCategory(tool))
    local toolName = tool and tool.Name or ""
    local isGodhuman = toolName:lower():find("godhuman") ~= nil

    local candidates = {}
    table.insert(candidates, sKey)
    table.insert(candidates, sKey:upper())
    table.insert(candidates, sKey:lower())

    if cat then
        table.insert(candidates, cat .. " " .. sKey)
        table.insert(candidates, cat .. " " .. sKey:upper())
        table.insert(candidates, cat:lower() .. " " .. sKey:lower())
        table.insert(candidates, cat .. "-" .. sKey)
    end
    if toolName ~= "" then
        table.insert(candidates, toolName .. " " .. sKey)
        table.insert(candidates, toolName .. " " .. sKey:upper())
        table.insert(candidates, toolName:lower() .. " " .. sKey:lower())
    end
    if isGodhuman and sKey:upper() == "Z" then
        table.insert(candidates, "Godhuman Z")
        table.insert(candidates, "God Human Z")
        table.insert(candidates, "godhuman z")
        table.insert(candidates, "god human z")
    end

    for _, cand in ipairs(candidates) do
        if AutoBounty.DisabledSkills[cand] == true then
            return true
        end
    end

    for k, v in pairs(AutoBounty.DisabledSkills) do
        local vStr = (type(v) == "string") and v or (v == true and tostring(k)) or nil
        if vStr then
            local vClean = vStr:lower():gsub("[%s%-_]+", "")
            for _, cand in ipairs(candidates) do
                local candClean = cand:lower():gsub("[%s%-_]+", "")
                if vClean == candClean then
                    return true
                end
            end
        end
    end

    return false
end

-- Real-time Blox Fruits UI Cooldown & Skill Verification
local function isSkillReady(tool, skillKey)
    if not tool or not skillKey then return false end
    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local main = pGui and pGui:FindFirstChild("Main")
    local skills = main and main:FindFirstChild("Skills")
    if not skills then return true end

    local toolSkills = skills:FindFirstChild(tool.Name)
    if not toolSkills then
        local cleanToolName = string.lower(tool.Name):gsub("[%s%-_]", "")
        for _, child in ipairs(skills:GetChildren()) do
            local cleanChild = string.lower(child.Name):gsub("[%s%-_]", "")
            if cleanChild == cleanToolName or cleanChild:find(cleanToolName, 1, true) then
                toolSkills = child
                break
            end
        end
    end
    if not toolSkills then return true end

    local skillFrame = toolSkills:FindFirstChild(skillKey)
    if not skillFrame then return false end

    local cd = skillFrame:FindFirstChild("Cooldown")
    if not cd then return true end

    -- AbsoluteSize.X <= 0 or Offset <= 0 confirms the skill is ready to fire
    if cd.AbsoluteSize and cd.AbsoluteSize.X > 0 then
        return false
    end
    if cd.Size and cd.Size.X.Offset > 0 then
        return false
    end
    return true
end

local function isSkillOnCooldown(tool, skillKey)
    return not isSkillReady(tool, skillKey)
end

-- Cast skill key with cooldown check, torso aim lock, mobile UI activation, and HumanoidRootPart dispatch
local function castSkillKey(keyCode, tool, targetHRP, explicitCategory)
    local skillKey = (typeof(keyCode) == "string") and keyCode or keyCode.Name
    if isSkillDisabled(tool, skillKey, explicitCategory) then
        return false
    end
    if tool and not isSkillReady(tool, skillKey) then
        return false
    end

    local codeEnum = (typeof(keyCode) == "string") and (Enum.KeyCode[keyCode] or Enum.KeyCode[skillKey]) or keyCode
    _G.DarlingIsCastingSkill = true
    pcall(function()
        -- Sync active skill key with aimbot core for accurate remote redirection
        local hub = getHub()
        local core = hub and hub.Require and hub:Require("modules/combat/aimbot_core.lua")
        if core and core.setCurrentSkillKey then
            core.setCurrentSkillKey(skillKey)
        end

        -- Direct camera aim at target torso for projectile and lunge accuracy
        if targetHRP and Workspace.CurrentCamera then
            local aimPos = targetHRP.Position + Vector3.new(0, 1.5, 0)
            Workspace.CurrentCamera.CFrame = CFrame.lookAt(Workspace.CurrentCamera.CFrame.Position, aimPos)
            _G.DarlingSilentAimTarget = targetHRP
            _G.currentSilentAimTarget = targetHRP
        end

        -- Mobile touch button trigger
        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local main = pGui and pGui:FindFirstChild("Main")
        local skills = main and main:FindFirstChild("Skills")
        local toolSkills = tool and skills and (skills:FindFirstChild(tool.Name) or skills:FindFirstChildWhichIsA("Frame"))
        local skillFrame = toolSkills and toolSkills:FindFirstChild(skillKey)
        local mobileBtn = skillFrame and skillFrame:FindFirstChild("Mobile")

        if mobileBtn and mobileBtn:IsA("GuiButton") and mobileBtn.Visible then
            local fired = false
            if firesignal then
                fired = pcall(firesignal, mobileBtn.Activated)
            end
            if not fired and getconnections then
                pcall(function()
                    for _, c in ipairs(getconnections(mobileBtn.Activated)) do
                        if c.Fire then c:Fire() end
                    end
                end)
            end
        end

        -- Dispatch key event targeted at HumanoidRootPart (works reliably on mobile and desktop)
        local char = LocalPlayer.Character
        local myHRP = char and char:FindFirstChild("HumanoidRootPart")
        local sendTarget = myHRP or game
        if VirtualInputManager and codeEnum then
            VirtualInputManager:SendKeyEvent(true, codeEnum, false, sendTarget)
            task.wait(0.04)
            VirtualInputManager:SendKeyEvent(false, codeEnum, false, sendTarget)
        end
    end)
    task.wait(0.06)
    lastCombatActionTime = os.clock()
    _G.DarlingIsCastingSkill = false
    return true
end

-- Find next valid target across entire map
local function findNextTarget()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local bestPlayer = nil
    local bestDist = AutoBounty.MaxDistance or 100000

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isPlayerAlive(p) then
            if isEnemy(p) and readPvPState(p) then
                if not (AutoBounty.NoSafeZone and inSafeZone(p)) then
                    local pHRP = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if pHRP then
                        local dist = (pHRP.Position - myHRP.Position).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            bestPlayer = p
                        end
                    end
                end
            end
        end
    end

    return bestPlayer
end

function AutoBounty.skipCurrentTarget()
    if AutoBounty.CurrentTarget then
        local t = AutoBounty.CurrentTarget
        if t.UserId then AutoBounty.SkippedTargets[t.UserId] = true end
        if t.Name then AutoBounty.SkippedTargets[t.Name] = true end
    end
    stopTween()
    AutoBounty.CurrentTarget = nil
    AutoBounty.Status = "Target skipped. Searching next..."
end

local function hasPlayerChosenTeam()
    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
    local mainGui = pGui and pGui:FindFirstChild("Main")
    local chooseTeam = mainGui and mainGui:FindFirstChild("ChooseTeam")
    if chooseTeam and chooseTeam.Visible then
        return false
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and hrp and hum.Health > 0 then
        return true
    end
    local team = LocalPlayer.Team
    local teamName = team and team.Name
    if teamName == "Pirates" or teamName == "Marines" then
        return true
    end
    return false
end

function AutoBounty.joinTeam(teamName)
    teamName = teamName or AutoBounty.AutoTeam or "Pirates"
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local commF = remotes and remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("SetTeam", teamName)
            commF:InvokeServer("SetTeam2", teamName)
        end
    end)

    -- Detect and dismiss Blox Fruits ChooseTeam GUI on initial join
    pcall(function()
        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
        local mainGui = pGui and pGui:FindFirstChild("Main")
        local chooseTeam = mainGui and mainGui:FindFirstChild("ChooseTeam")
        if chooseTeam and chooseTeam.Visible then
            local container = chooseTeam:FindFirstChild("Container")
            local targetFolder = container and (container:FindFirstChild(teamName) or (teamName == "Pirates" and container:FindFirstChild("Pirates")) or container:FindFirstChild("Marines"))
            if targetFolder then
                for _, desc in ipairs(targetFolder:GetDescendants()) do
                    if desc:IsA("TextButton") or desc:IsA("ImageButton") then
                        if firesignal then
                            pcall(firesignal, desc.Activated)
                            pcall(firesignal, desc.MouseButton1Click)
                        end
                        if VirtualInputManager then
                            pcall(function()
                                local pos = desc.AbsolutePosition + desc.AbsoluteSize / 2
                                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                                task.wait(0.04)
                                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                            end)
                        end
                    end
                end
            end
            chooseTeam.Visible = false
        end
    end)
end

-- Guaranteed Auto Join Team Daemon (runs when AutoBounty is enabled)
local autoTeamThread = nil
function AutoBounty.startAutoTeamDaemon()
    if autoTeamThread then return end
    autoTeamThread = task.spawn(function()
        if not game:IsLoaded() then
            pcall(function() game.Loaded:Wait() end)
        end

        local targetTeam = AutoBounty.AutoTeam or "Pirates"
        for _ = 1, 150 do -- 75 seconds monitoring window
            if not AutoBounty.Enabled then break end
            if hasPlayerChosenTeam() then
                break
            end

            local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
            local chooseTeam = pGui and pGui:FindFirstChild("Main") and pGui.Main:FindFirstChild("ChooseTeam")
            if chooseTeam and chooseTeam.Visible then
                AutoBounty.joinTeam(targetTeam)
            else
                -- Even if GUI not visible yet, attempt remote selection if team is not yet set
                local currentTeam = LocalPlayer.Team
                local currentTeamName = currentTeam and currentTeam.Name
                if currentTeamName ~= "Pirates" and currentTeamName ~= "Marines" then
                    pcall(function()
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        local commF = remotes and remotes:FindFirstChild("CommF_")
                        if commF then
                            commF:InvokeServer("SetTeam", targetTeam)
                        end
                    end)
                end
            end
            task.wait(0.5)
        end
        autoTeamThread = nil
    end)
end

local AUTO_BOUNTY_CONFIG_PATH = "darling_hub/auto_bounty_config.json"
local AUTO_BOUNTY_FALLBACK_PATH = "darling_auto_bounty_config.json"

local saveDebounceThread = nil
function AutoBounty.saveConfig(immediate)
    local hub = getHub()
    if hub and hub.IsLoadingConfig then return false end
    local writeFunc = writefile or (syn and syn.writefile)
    if not writeFunc then return false end

    local function doSave()
        local cfg = {
            AutoBountyMode = AutoBounty.AutoBountyMode == true,
            AutoTeam = AutoBounty.AutoTeam or "Pirates",
            NearTweenSpeed = AutoBounty.NearTweenSpeed or 310,
            FarTweenSpeed = AutoBounty.FarTweenSpeed or 200,
            FlySpeed = AutoBounty.FlySpeed or 200,
            TweenThreshold = AutoBounty.TweenThreshold or 1000,
            Orbit = AutoBounty.Orbit ~= false,
            OrbitDistance = AutoBounty.OrbitDistance or 3,
            CombatDistance = AutoBounty.CombatDistance or 3,
            OrbitSpeed = AutoBounty.OrbitSpeed or 6.0,
            TargetPlayerCount = AutoBounty.TargetPlayerCount or 8,
            AutoHop = AutoBounty.AutoHop ~= false,
            AutoAttack = AutoBounty.AutoAttack ~= false,
            FastAttackSpeed = AutoBounty.FastAttackSpeed or "Normal (0.25s)",
            AttackDelay = AutoBounty.AttackDelay or 0.25,
            AutoSkills = AutoBounty.AutoSkills ~= false,
            DisabledSkills = AutoBounty.DisabledSkills or { ["Fruit F"] = true },
            AimbotLock = AutoBounty.AimbotLock ~= false,
            AutoBuso = AutoBounty.AutoBuso ~= false,
            AutoKen = AutoBounty.AutoKen ~= false,
            AutoV4 = AutoBounty.AutoV4 ~= false,
            AutoEnablePvp = AutoBounty.AutoEnablePvp ~= false,
            AutoFlee = AutoBounty.AutoFlee ~= false,
            CancelHealth = AutoBounty.CancelHealth == true,
            FleeHP = AutoBounty.FleeHP or 30,
            ReturnHP = AutoBounty.ReturnHP or 50,
            FleeHeight = AutoBounty.FleeHeight or 1500,
            NoSafeZone = AutoBounty.NoSafeZone ~= false,
            NoMarineAlly = AutoBounty.NoMarineAlly ~= false,
            AutoSoru = AutoBounty.AutoSoru == true,
            Weapons = AutoBounty.Weapons or { Melee = true, Sword = true, Fruit = true, Gun = true },
        }

        local okJson, json = pcall(function() return HttpService:JSONEncode(cfg) end)
        if not okJson or not json then return false end

        pcall(function()
            local makeFolderFunc = makefolder or (syn and syn.makefolder)
            local isFolderFunc = isfolder or (syn and syn.isfolder)
            if makeFolderFunc and isFolderFunc and not isFolderFunc("darling_hub") then
                makeFolderFunc("darling_hub")
            end
            writeFunc(AUTO_BOUNTY_CONFIG_PATH, json)
        end)
        pcall(function()
            writeFunc(AUTO_BOUNTY_FALLBACK_PATH, json)
        end)
        return true
    end

    if immediate then
        if saveDebounceThread then
            pcall(function() task.cancel(saveDebounceThread) end)
            saveDebounceThread = nil
        end
        return doSave()
    end

    if saveDebounceThread then
        pcall(function() task.cancel(saveDebounceThread) end)
        saveDebounceThread = nil
    end
    saveDebounceThread = task.delay(0.35, function()
        saveDebounceThread = nil
        doSave()
    end)
    return true
end

function AutoBounty.resetConfig()
    AutoBounty.AutoBountyMode = false
    AutoBounty.AutoTeam = "Pirates"
    AutoBounty.NearTweenSpeed = 310
    AutoBounty.FarTweenSpeed = 200
    AutoBounty.FlySpeed = 200
    AutoBounty.TweenThreshold = 1000
    AutoBounty.Orbit = true
    AutoBounty.OrbitDistance = 3
    AutoBounty.CombatDistance = 5.5
    AutoBounty.OrbitSpeed = 12.0
    AutoBounty.TargetPlayerCount = 8
    AutoBounty.AutoHop = true
    AutoBounty.AutoAttack = true
    AutoBounty.FastAttackSpeed = "Medium (0.10s)"
    AutoBounty.AttackDelay = 0.10
    AutoBounty.AutoSkills = true
    AutoBounty.DisabledSkills = { ["Fruit F"] = true }
    AutoBounty.AimbotLock = true
    AutoBounty.AutoBuso = true
    AutoBounty.AutoKen = true
    AutoBounty.AutoV4 = true
    AutoBounty.AutoEnablePvp = true
    AutoBounty.AutoFlee = true
    AutoBounty.CancelHealth = false
    AutoBounty.FleeHP = 30
    AutoBounty.ReturnHP = 50
    AutoBounty.FleeHeight = 1500
    AutoBounty.NoSafeZone = true
    AutoBounty.NoMarineAlly = true
    AutoBounty.AutoSoru = false
    AutoBounty.Weapons = { Melee = true, Sword = true, Fruit = true, Gun = true }

    local writeFunc = writefile or (syn and syn.writefile)
    if writeFunc then
        local cfg = {
            AutoBountyMode = false,
            AutoTeam = "Pirates",
            NearTweenSpeed = 310,
            FarTweenSpeed = 200,
            FlySpeed = 200,
            TweenThreshold = 1000,
            Orbit = true,
            OrbitDistance = 3,
            CombatDistance = 5.5,
            OrbitSpeed = 12.0,
            TargetPlayerCount = 8,
            AutoHop = true,
            AutoAttack = true,
            FastAttackSpeed = "Medium (0.10s)",
            AttackDelay = 0.10,
            AutoSkills = true,
            DisabledSkills = { ["Fruit F"] = true },
            AimbotLock = true,
            AutoBuso = true,
            AutoKen = true,
            AutoV4 = true,
            AutoEnablePvp = true,
            AutoFlee = true,
            CancelHealth = false,
            FleeHP = 30,
            ReturnHP = 50,
            FleeHeight = 1500,
            NoSafeZone = true,
            NoMarineAlly = true,
            AutoSoru = false,
            Weapons = { Melee = true, Sword = true, Fruit = true, Gun = true },
        }
        local okJson, json = pcall(function() return HttpService:JSONEncode(cfg) end)
        if okJson and json then
            pcall(function()
                local makeFolderFunc = makefolder or (syn and syn.makefolder)
                local isFolderFunc = isfolder or (syn and syn.isfolder)
                if makeFolderFunc and isFolderFunc and not isFolderFunc("darling_hub") then
                    makeFolderFunc("darling_hub")
                end
                writeFunc(AUTO_BOUNTY_CONFIG_PATH, json)
            end)
            pcall(function()
                writeFunc(AUTO_BOUNTY_FALLBACK_PATH, json)
            end)
        end
    end
end

function AutoBounty.loadConfig()
    local readFunc = readfile or (syn and syn.readfile)
    if not readFunc then return false end

    local raw = nil
    for _, path in ipairs({ AUTO_BOUNTY_CONFIG_PATH, AUTO_BOUNTY_FALLBACK_PATH }) do
        local okR, content = pcall(readFunc, path)
        if okR and type(content) == "string" and #content > 5 then
            raw = content
            break
        end
    end
    if not raw then return false end

    local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok or type(data) ~= "table" then return false end

    if data.AutoBountyMode ~= nil then AutoBounty.AutoBountyMode = (data.AutoBountyMode == true) end
    if data.AutoTeam ~= nil then AutoBounty.AutoTeam = data.AutoTeam end
    if data.NearTweenSpeed ~= nil then AutoBounty.NearTweenSpeed = math.clamp(tonumber(data.NearTweenSpeed) or 310, 50, 500) end
    if data.FarTweenSpeed ~= nil then AutoBounty.FarTweenSpeed = math.clamp(tonumber(data.FarTweenSpeed) or 200, 50, 500) end
    if data.FlySpeed ~= nil then AutoBounty.FlySpeed = math.clamp(tonumber(data.FlySpeed) or 200, 50, 500) end
    if data.TweenThreshold ~= nil then AutoBounty.TweenThreshold = tonumber(data.TweenThreshold) or 1000 end
    if data.Orbit ~= nil then AutoBounty.Orbit = (data.Orbit == true) end
    if data.OrbitDistance ~= nil then AutoBounty.OrbitDistance = tonumber(data.OrbitDistance) or 3 end
    if data.CombatDistance ~= nil then AutoBounty.CombatDistance = tonumber(data.CombatDistance) or 5.5 end
    if data.OrbitSpeed ~= nil then AutoBounty.OrbitSpeed = tonumber(data.OrbitSpeed) or 12.0 end
    if data.TargetPlayerCount ~= nil then AutoBounty.TargetPlayerCount = tonumber(data.TargetPlayerCount) or 8 end
    if data.AutoHop ~= nil then AutoBounty.AutoHop = (data.AutoHop == true) end
    if data.AutoAttack ~= nil then AutoBounty.AutoAttack = (data.AutoAttack == true) end
    if data.FastAttackSpeed ~= nil then AutoBounty.FastAttackSpeed = data.FastAttackSpeed end
    if data.AttackDelay ~= nil then AutoBounty.AttackDelay = tonumber(data.AttackDelay) or 0.10 end
    if data.AutoSkills ~= nil then AutoBounty.AutoSkills = (data.AutoSkills == true) end
    if data.DisabledSkills ~= nil and type(data.DisabledSkills) == "table" then
        local normalized = {}
        for k, v in pairs(data.DisabledSkills) do
            if type(k) == "string" and v == true then
                normalized[k] = true
            elseif type(v) == "string" then
                normalized[v] = true
            end
        end
        AutoBounty.DisabledSkills = normalized
    end
    if data.AimbotLock ~= nil then AutoBounty.AimbotLock = (data.AimbotLock == true) end
    if data.AutoBuso ~= nil then AutoBounty.AutoBuso = (data.AutoBuso == true) end
    if data.AutoKen ~= nil then AutoBounty.AutoKen = (data.AutoKen == true) end
    if data.AutoV4 ~= nil then AutoBounty.AutoV4 = (data.AutoV4 == true) end
    if data.AutoEnablePvp ~= nil then AutoBounty.AutoEnablePvp = (data.AutoEnablePvp == true) end
    if data.AutoFlee ~= nil then AutoBounty.AutoFlee = (data.AutoFlee == true) end
    if data.CancelHealth ~= nil then AutoBounty.CancelHealth = (data.CancelHealth == true) end
    if data.FleeHP ~= nil then AutoBounty.FleeHP = tonumber(data.FleeHP) or 30 end
    if data.ReturnHP ~= nil then AutoBounty.ReturnHP = tonumber(data.ReturnHP) or 50 end
    if data.FleeHeight ~= nil then AutoBounty.FleeHeight = tonumber(data.FleeHeight) or 1500 end
    if data.NoSafeZone ~= nil then AutoBounty.NoSafeZone = (data.NoSafeZone == true) end
    if data.NoMarineAlly ~= nil then AutoBounty.NoMarineAlly = (data.NoMarineAlly == true) end
    if data.AutoSoru ~= nil then AutoBounty.AutoSoru = (data.AutoSoru == true) end
    if data.Weapons ~= nil and type(data.Weapons) == "table" and AutoBounty.Enabled then AutoBounty.Weapons = data.Weapons end

    return true
end
local function enableAntiTeleportFail()
    pcall(function()
        local queue = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
        if queue then
            -- Optional queue on teleport hook
        end
    end)
end

-- Server Hop Routine (Continuous Sky Ascent at 160 studs/s + Anti-Fall Hold + Server Browsers)
local isHoppingActive = false
function AutoBounty.hopServer()
    if isHoppingActive then return end
    isHoppingActive = true

    task.spawn(function()
        AutoBounty.Status = "Hopping Server (Ascending smoothly into sky)..."
        stopTween()
        disableStickyFollow()
        stopFastAttackLoop()
        ensureNoclip()
        enableAntiTeleportFail()

        pcall(function()
            if AutoBounty.saveConfig then
                AutoBounty.saveConfig(true)
            end
        end)

        -- Smooth Sky Ascent & Anti-Fall Floating Hold at 160 studs/sec (Zero Instant TP, Zero Falling)
        -- Maintains continuous altitude in sky throughout server search, combat wait, and teleportation
        task.spawn(function()
            local stepTime = 0.25
            local stepDist = 40 -- 40 studs / 0.25s = 160 studs/sec
            while isHoppingActive do
                pcall(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum then
                        hum.PlatformStand = true
                        ensureNoclip()

                        local hold = hrp:FindFirstChild("DarlingHopHold")
                        if not hold or not hold:IsA("BodyVelocity") then
                            if hold then hold:Destroy() end
                            hold = Instance.new("BodyVelocity")
                            hold.Name = "DarlingHopHold"
                            hold.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                            hold.Parent = hrp
                        end

                        local currentY = hrp.Position.Y
                        if currentY < 3500 then
                            local targetY = math.min(currentY + stepDist, 3500)
                            local targetCF = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z)
                            local tw = TweenService:Create(
                                hrp,
                                TweenInfo.new(stepTime, Enum.EasingStyle.Linear),
                                { CFrame = targetCF }
                            )
                            tw:Play()
                            hold.Velocity = Vector3.new(0, 160, 0)
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 160, 0)
                        else
                            hold.Velocity = Vector3.zero
                            hrp.AssemblyLinearVelocity = Vector3.zero
                        end
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end
                end)
                task.wait(stepTime)
            end
        end)

        -- Wait for combat risk to clear completely while safely ascending & floating in the sky
        while checkInCombat() and isHoppingActive do
            AutoBounty.Status = "Hopping: In combat! Waiting safely in sky for risk to clear..."
            task.wait(1)
        end

        local function ensureOutOfCombatBeforeTeleport()
            while checkInCombat() and isHoppingActive do
                AutoBounty.Status = "Hopping: In combat! Waiting safely in sky for risk to clear..."
                task.wait(1)
            end
            return isHoppingActive
        end

        local placeId = game.PlaceId
        local currentJobId = game.JobId

        -- Auto-re-execute script on new server arrival
        local queueTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
        if queueTeleport then
            pcall(function()
                queueTeleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/devdarlingx-dotcom/Darling-hub/main/main.lua"))()]])
            end)
        end

        local hopSuccess = false

        -- Method 1: Native ServerBrowser UI scan
        pcall(function()
            if hopSuccess or not isHoppingActive then return end
            local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
            local sbGui = pGui and pGui:FindFirstChild("ServerBrowser")
            if not sbGui or not sbGui:FindFirstChild("Frame") then return end

            sbGui.Enabled = true
            task.wait(0.15)

            local scrollFrame = sbGui.Frame:FindFirstChild("ScrollingFrame")
            local fakeScroll = sbGui.Frame:FindFirstChild("FakeScroll")
            local inside = fakeScroll and fakeScroll:FindFirstChild("Inside")

            if scrollFrame and inside then
                for _ = 1, 4 do
                    if not isHoppingActive then break end
                    scrollFrame.CanvasPosition = Vector2.new(0, math.random(100, 5000))
                    task.wait(0.15)
                end

                local sbRemote = ReplicatedStorage:FindFirstChild("__ServerBrowser")
                for _, template in ipairs(inside:GetChildren()) do
                    if not isHoppingActive then break end
                    if template.Name == "Template" then
                        local joinBtn = template:FindFirstChild("Join")
                        if joinBtn then
                            local job = joinBtn:GetAttribute("Job")
                            if job and tostring(job):find("-", 1, true) then
                                local jobStr = tostring(job)
                                if jobStr ~= currentJobId then
                                    if not ensureOutOfCombatBeforeTeleport() then return end
                                    AutoBounty.Status = "Hopping: Joining " .. jobStr:sub(1, 8) .. "..."
                                    hopSuccess = true
                                    if sbRemote then
                                        pcall(function() sbRemote:InvokeServer("teleport", jobStr) end)
                                    end
                                    task.wait(0.3)
                                    pcall(function()
                                        TeleportService:TeleportToPlaceInstance(placeId, jobStr, LocalPlayer)
                                    end)
                                    task.wait(4.0)
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end)

        -- Method 2: Multi-Page Remote Query (__ServerBrowser:InvokeServer(page))
        if not hopSuccess and isHoppingActive then
            local sbRemote = ReplicatedStorage:FindFirstChild("__ServerBrowser")
            if sbRemote then
                AutoBounty.Status = "Hopping: Scanning server pages..."
                local candidateJobIds = {}
                for page = 1, 15 do
                    if not isHoppingActive or #candidateJobIds >= 5 then break end
                    local ok, data = pcall(function() return sbRemote:InvokeServer(page) end)
                    if ok and type(data) == "table" then
                        for k, v in pairs(data) do
                            if k ~= currentJobId and type(v) == "table" then
                                local cnt = tonumber(v.Count) or tonumber(v["Count"]) or 0
                                if cnt >= 2 and cnt <= 10 then
                                    table.insert(candidateJobIds, tostring(k))
                                end
                            end
                        end
                    end
                    task.wait(0.08)
                end

                if #candidateJobIds > 0 and isHoppingActive then
                    local chosenJob = candidateJobIds[math.random(1, #candidateJobIds)]
                    if not ensureOutOfCombatBeforeTeleport() then return end
                    AutoBounty.Status = "Hopping: Joining server (" .. chosenJob:sub(1, 8) .. ")..."
                    hopSuccess = true
                    pcall(function()
                        sbRemote:InvokeServer("teleport", chosenJob)
                    end)
                    task.wait(0.3)
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(placeId, chosenJob, LocalPlayer)
                    end)
                    task.wait(4.0)
                end
            end
        end

        -- Method 3: HTTP API Fallback (Public Roblox API + Roproxy)
        if not hopSuccess and isHoppingActive then
            AutoBounty.Status = "Hopping: Querying Roblox API fallback..."
            local candidateJobIds = {}
            local proxyUrls = {
                "https://games.roblox.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true",
                "https://games.roproxy.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
            }

            local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
            for _, pUrl in ipairs(proxyUrls) do
                if #candidateJobIds >= 8 or not isHoppingActive then break end
                local raw = nil
                if req then
                    local ok, res = pcall(req, { Url = pUrl, Method = "GET", Headers = { ["User-Agent"] = "Mozilla/5.0" } })
                    if ok and res and res.Body and #res.Body > 20 then
                        raw = res.Body
                    end
                end

                if not raw and game.HttpGet then
                    pcall(function()
                        raw = game:HttpGet(pUrl)
                    end)
                end

                if raw and #raw > 20 then
                    local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
                    if ok and data and data.data and #data.data > 0 then
                        for _, srv in ipairs(data.data) do
                            if srv.id and srv.id ~= currentJobId and type(srv.playing) == "number" then
                                local maxP = srv.maxPlayers or 12
                                if srv.playing < maxP and srv.playing >= 2 then
                                    table.insert(candidateJobIds, tostring(srv.id))
                                end
                            end
                        end
                    end
                end
            end

            if #candidateJobIds > 0 and isHoppingActive then
                local chosenId = candidateJobIds[math.random(1, #candidateJobIds)]
                if not ensureOutOfCombatBeforeTeleport() then return end
                AutoBounty.Status = "Hopping: Joining " .. tostring(chosenId):sub(1, 8) .. "..."
                hopSuccess = true
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(placeId, chosenId, LocalPlayer)
                end)
                task.wait(4.0)
            end
        end

        -- Final fallback: random teleport
        if not hopSuccess and isHoppingActive then
            if not ensureOutOfCombatBeforeTeleport() then return end
            AutoBounty.Status = "Hopping: Teleporting to random server..."
            pcall(function()
                TeleportService:Teleport(placeId, LocalPlayer)
            end)
        end

        task.delay(15, function()
            isHoppingActive = false
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp then
                    local hold = hrp:FindFirstChild("DarlingHopHold")
                    if hold then hold:Destroy() end
                end
                if hum then
                    hum.PlatformStand = false
                end
            end)
        end)
    end)
end

-- Target Ken Haki burst tracker & fleeing state
local targetBurstDone = {}
local isFleeing = false
local fleeCancelledUntil = 0
local fixedSafeFleeY = 1500

function AutoBounty.cancelFlee()
    isFleeing = false
    fleeCancelledUntil = os.clock() + 25
    stopTween()
    ensureStickyFollow()
    if AutoBounty.CurrentTarget then
        local tName = AutoBounty.CurrentTarget.DisplayName or AutoBounty.CurrentTarget.Name
        AutoBounty.Status = "Flee cancelled. Resuming hunt on: " .. tName
    else
        AutoBounty.Status = "Flee cancelled. Searching targets..."
    end
end

-- Robust Character Spawn & Team Readiness Helper
-- Robust Character Spawn & Team Readiness Helper
local function waitForCharacterSpawn()
    if not game:IsLoaded() then
        pcall(function() game.Loaded:Wait() end)
    end

    local targetTeam = AutoBounty.AutoTeam or "Pirates"
    for _ = 1, 40 do
        if not AutoBounty.Enabled then return false end
        if hasPlayerChosenTeam() then break end
        AutoBounty.joinTeam(targetTeam)
        task.wait(0.35)
    end

    for _ = 1, 60 do
        if not AutoBounty.Enabled then return false end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 and hrp.Position.Y > -100 and hasPlayerChosenTeam() then
            task.wait(0.8)
            return true
        end
        AutoBounty.Status = "Waiting for game & character spawn..."
        task.wait(0.35)
    end
    return false
end

-- Main Bounty Hunting Loop
local function runBountyLoop()
    while AutoBounty.Enabled do
        AutoBounty.Status = "Checking character readiness..."
        local ready = waitForCharacterSpawn()
        if ready then break end
        if not AutoBounty.Enabled then return end
        task.wait(1.0)
    end
    if not AutoBounty.Enabled then return end

    ensureNoclip()
    ensureStickyFollow()
    startFastAttackLoop()

    local scanRetryCount = 0
    local maxScanRetries = 8

    while AutoBounty.Enabled do
        if not isHoppingActive then
            local myChar = LocalPlayer.Character
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

            if myHum and myHRP and myHum.Health > 0 and hasPlayerChosenTeam() then
                autoEnablePvp()
                autoBuso()
                autoKenHaki()
                autoRaceV4()

                -- Auto Flee check (safely holds in the sky until regenerated to ReturnHP % HP)
                local hpPercent = (myHum.Health / myHum.MaxHealth) * 100
                local fleeTrigger = tonumber(AutoBounty.FleeHP) or 30
                local returnTrigger = tonumber(AutoBounty.ReturnHP) or 50
                local targetFleeY = tonumber(AutoBounty.FleeHeight) or 1500

                if AutoBounty.AutoFlee and (hpPercent < fleeTrigger or (isFleeing and hpPercent < returnTrigger)) then
                    isFleeing = true
                else
                    isFleeing = false
                end

                if isFleeing then
                    inCombatRange = false
                    AutoBounty.ReachedTarget = false
                    disableStickyFollow()
                    AutoBounty.Status = "Fleeing to safe sky (Regenerating: " .. math.floor(hpPercent) .. "% HP)..."
                    if myHRP.Position.Y < (targetFleeY - 40) then
                        tweenTo(CFrame.new(myHRP.Position.X, targetFleeY, myHRP.Position.Z))
                    else
                        stopTween()
                        ensureHoldVelocity()
                        pcall(function()
                            myHRP.CFrame = CFrame.new(myHRP.Position.X, targetFleeY, myHRP.Position.Z)
                        end)
                    end
                    task.wait(0.2)
                else
                    -- Target validation with post-kill stabilization
                    local target = AutoBounty.CurrentTarget
                    if not isPlayerAlive(target) or (AutoBounty.NoSafeZone and inSafeZone(target)) or not readPvPState(target) then
                        local wasValidTarget = (target ~= nil)
                        stopTween()
                        disableStickyFollow()
                        inCombatRange = false
                        AutoBounty.ReachedTarget = false

                        pcall(function()
                            if myHRP then
                                myHRP.AssemblyLinearVelocity = Vector3.zero
                                myHRP.AssemblyAngularVelocity = Vector3.zero
                            end
                        end)

                        if wasValidTarget then
                            AutoBounty.Status = "Target defeated! Claiming bounty..."
                            task.wait(0.6)
                        else
                            AutoBounty.Status = "Searching next target..."
                        end

                        AutoBounty.CurrentTarget = findNextTarget()
                        target = AutoBounty.CurrentTarget
                    end

                    _G.DarlingAutoBountyTarget = target
                    _G.DarlingTarget = target

                    if target and isPlayerAlive(target) then
                        scanRetryCount = 0 -- Valid enemy acquired; reset scan retry counter
                        local tChar = target.Character
                        local tHRP = tChar:FindFirstChild("HumanoidRootPart")

                        if tHRP then
                            local dist = (tHRP.Position - myHRP.Position).Magnitude
                            AutoBounty.Status = "Hunting: " .. target.DisplayName .. " [" .. math.floor(dist) .. "m]"

                            -- Engage Aimbot Lock onto Target
                            if AutoBounty.AimbotLock then
                                pcall(function()
                                    local hub = getHub()
                                    local core = hub and hub.Require and hub:Require("modules/combat/aimbot_core.lua")
                                    if core then
                                        core.LockPlayer = true
                                        core.LockedTargetPlayer = target
                                        core.PlayerAimEnabled = true
                                        if core.startLoop then core.startLoop() end
                                    end
                                    if Workspace.CurrentCamera then
                                        Workspace.CurrentCamera.CFrame = CFrame.lookAt(Workspace.CurrentCamera.CFrame.Position, tHRP.Position + Vector3.new(0, 1.5, 0))
                                    end
                                end)
                            end

                            -- Auto Soru to close large gaps (off by default)
                            if AutoBounty.AutoSoru and dist > 120 then
                                pcall(function()
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                                    task.wait(0.05)
                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                                end)
                            end


                            -- Movement & Attack execution
                            ensureStickyFollow()
                            autoRaceV4()

                            if dist > 85 then
                                inCombatRange = false
                                tweenTo(tHRP.CFrame * CFrame.new(0, 2.5, 4.0))
                            else
                                inCombatRange = true
                                AutoBounty.ReachedTarget = true
                                stopTween()

                                local weaponOrder = { "Melee", "Sword", "Fruit", "Gun" }
                                local anySkillFired = false

                                for _, wName in ipairs(weaponOrder) do
                                    if not AutoBounty.Enabled or not isPlayerAlive(target) or isHoppingActive or isFleeing then break end
                                    local isWepEnabled = AutoBounty.Weapons and AutoBounty.Weapons[wName]
                                    if isWepEnabled then
                                        local curDist = (tHRP.Position - myHRP.Position).Magnitude
                                        if curDist > 95 then break end

                                        -- Wait for previous skill animation to finish before swapping weapon
                                        local ch = LocalPlayer.Character
                                        local busy = ch and ch:FindFirstChild("Busy")
                                        if busy and busy.Value == true then
                                            local waitStart = os.clock()
                                            while busy.Value == true and (os.clock() - waitStart) < 0.08 do
                                                task.wait(0.02)
                                            end
                                        end

                                        if equipWeapon(wName) then
                                            task.wait(0.04)
                                            ensureNotSeated()

                                            local currentTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                            local castedSkillOnTool = false

                                            if AutoBounty.AutoSkills and currentTool and matchesWeaponType(currentTool, wName) then
                                                local keys = { Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.F }
                                                for _, k in ipairs(keys) do
                                                    if not AutoBounty.Enabled or not isPlayerAlive(target) or isHoppingActive or isFleeing then break end
                                                    local curD = (tHRP.Position - myHRP.Position).Magnitude
                                                    if curD > 95 then break end

                                                    if not isSkillDisabled(currentTool, k.Name, wName) then
                                                        if isSkillReady(currentTool, k.Name) then
                                                            if castSkillKey(k, currentTool, tHRP, wName) then
                                                                castedSkillOnTool = true
                                                                anySkillFired = true
                                                                task.wait(0.04)
                                                            end
                                                        end
                                                    end
                                                end
                                            end

                                            -- If no skills were ready for this tool, deliver controlled M1 attacks
                                            if not castedSkillOnTool and AutoBounty.AutoAttack and not _G.DarlingIsCastingSkill and not isFleeing then
                                                performFastAttack(tChar)
                                                task.wait(0.08)
                                            end
                                        end
                                    end
                                    if not AutoBounty.Enabled or isHoppingActive or isFleeing then break end
                                end

                                -- If all weapon skills were on cooldown, sustain pressure with M1
                                if not anySkillFired and AutoBounty.AutoAttack and not _G.DarlingIsCastingSkill and not isFleeing then
                                    performFastAttack(tChar)
                                    task.wait(0.10)
                                end
                            end
                        end
                    else
                        inCombatRange = false
                        stopTween()
                        _G.DarlingIsCastingSkill = false

                        -- Elevate to safe sky immediately to prevent being killed when no targets are acquired
                        pcall(function()
                            local safeSkyY = 1600
                            if myHRP and myHRP.Position.Y < (safeSkyY - 50) then
                                myHRP.CFrame = CFrame.new(myHRP.Position.X, safeSkyY, myHRP.Position.Z)
                                myHRP.AssemblyLinearVelocity = Vector3.zero
                                myHRP.AssemblyAngularVelocity = Vector3.zero
                            end
                        end)
                        ensureHoldVelocity()
                        ensureNoclip()

                        scanRetryCount = scanRetryCount + 1
                        if scanRetryCount <= 6 then
                            AutoBounty.Status = "Searching targets safely in sky (" .. scanRetryCount .. "/6)..."
                            task.wait(0.8)
                            AutoBounty.CurrentTarget = findNextTarget()
                        else
                            if AutoBounty.AutoHop then
                                AutoBounty.Status = "No targets found after scan. Hopping server..."
                                if not isHoppingActive then
                                    AutoBounty.hopServer()
                                end
                                task.wait(1.2)
                                AutoBounty.CurrentTarget = findNextTarget()
                                if AutoBounty.CurrentTarget then
                                    scanRetryCount = 0
                                    isHoppingActive = false
                                end
                            else
                                scanRetryCount = 0
                                task.wait(1.5)
                            end
                        end
                    end
                end
            else
                stopTween()
                AutoBounty.Status = "Respawning..."
                autoEnablePvp()
            end
        else
            task.wait(0.5)
        end

        task.wait(0.1)
    end

    stopTween()
    disableStickyFollow()
    disableNoclip()
    inCombatRange = false
    _G.DarlingIsCastingSkill = false
    AutoBounty.Status = "Stopped"
    AutoBounty.Running = false
end

local function setAutoBountyESP(enabled)
    pcall(function()
        local hub = getHub()
        local espMod = hub and hub.Require and hub:Require("modules/visuals/esp.lua")
        if espMod then
            espMod.setBoxes(enabled)
            espMod.setNames(enabled)
            espMod.setDistance(enabled)
            espMod.setHealth(enabled)
        end
        if hub and hub.UIElements then
            local u = hub.UIElements
            if u["ESPBoxes"] and u["ESPBoxes"].Set then pcall(function() u["ESPBoxes"]:Set(enabled) end) end
            if u["ESPNames"] and u["ESPNames"].Set then pcall(function() u["ESPNames"]:Set(enabled) end) end
            if u["ESPDistance"] and u["ESPDistance"].Set then pcall(function() u["ESPDistance"]:Set(enabled) end) end
            if u["ESPHealth"] and u["ESPHealth"].Set then pcall(function() u["ESPHealth"]:Set(enabled) end) end
        end
    end)
end

function AutoBounty.applyDefaults()
    if AutoBounty.OrbitDistance == nil then AutoBounty.OrbitDistance = 3 end
    if AutoBounty.CombatDistance == nil then AutoBounty.CombatDistance = 5.5 end
    if AutoBounty.OrbitSpeed == nil then AutoBounty.OrbitSpeed = 12.0 end
    if AutoBounty.Orbit == nil then AutoBounty.Orbit = false end
    if AutoBounty.AutoSoru == nil then AutoBounty.AutoSoru = false end
    if AutoBounty.NearTweenSpeed == nil then AutoBounty.NearTweenSpeed = 310 end
    if AutoBounty.FarTweenSpeed == nil then AutoBounty.FarTweenSpeed = 200 end
    if AutoBounty.FlySpeed == nil then AutoBounty.FlySpeed = 200 end
    if AutoBounty.AutoAttack == nil then AutoBounty.AutoAttack = false end
    if AutoBounty.FastAttack == nil then AutoBounty.FastAttack = false end
    if AutoBounty.AttackDelay == nil then AutoBounty.AttackDelay = 0.10 end
    if AutoBounty.HitDelay == nil then AutoBounty.HitDelay = 0.10 end
    if AutoBounty.FastAttackSpeed == nil then AutoBounty.FastAttackSpeed = "Medium (0.10s)" end
    if AutoBounty.AutoSkills == nil then AutoBounty.AutoSkills = false end
    if AutoBounty.DisabledSkills == nil then AutoBounty.DisabledSkills = { ["Fruit F"] = true } end
    if AutoBounty.AimbotLock == nil then AutoBounty.AimbotLock = false end
    if AutoBounty.AutoBuso == nil then AutoBounty.AutoBuso = false end
    if AutoBounty.AutoKen == nil then AutoBounty.AutoKen = false end
    if AutoBounty.AutoV4 == nil then AutoBounty.AutoV4 = false end
    if AutoBounty.AutoEnablePvp == nil then AutoBounty.AutoEnablePvp = false end
    if AutoBounty.AutoFlee == nil then AutoBounty.AutoFlee = false end
    if AutoBounty.FleeHP == nil then AutoBounty.FleeHP = 30 end
    if AutoBounty.ReturnHP == nil then AutoBounty.ReturnHP = 50 end
    if AutoBounty.AutoHop == nil then AutoBounty.AutoHop = false end
    if AutoBounty.NoSafeZone == nil then AutoBounty.NoSafeZone = false end
    if AutoBounty.NoMarineAlly == nil then AutoBounty.NoMarineAlly = false end

    AutoBounty.Weapons = AutoBounty.Weapons or {}
    if AutoBounty.Weapons.Melee == nil then AutoBounty.Weapons.Melee = false end
    if AutoBounty.Weapons.Sword == nil then AutoBounty.Weapons.Sword = false end
    if AutoBounty.Weapons.Fruit == nil then AutoBounty.Weapons.Fruit = false end
    if AutoBounty.Weapons.Gun == nil then AutoBounty.Weapons.Gun = false end
    if AutoBounty.UseMelee == nil then AutoBounty.UseMelee = false end
    if AutoBounty.UseSword == nil then AutoBounty.UseSword = false end
    if AutoBounty.UseFruit == nil then AutoBounty.UseFruit = false end
    if AutoBounty.UseGun == nil then AutoBounty.UseGun = false end

    -- Synchronize UI elements in the Auto Bounty tab
    pcall(function()
        local hub = getHub()
        if hub and hub.UIElements then
            local u = hub.UIElements
            if u["NearTweenSpeed"] and u["NearTweenSpeed"].Set then pcall(function() u["NearTweenSpeed"]:Set(310) end) end
            if u["FarTweenSpeed"] and u["FarTweenSpeed"].Set then pcall(function() u["FarTweenSpeed"]:Set(200) end) end
            if u["AutoBountyOrbit"] and u["AutoBountyOrbit"].Set then pcall(function() u["AutoBountyOrbit"]:Set(true) end) end
            if u["AutoBountyOrbitDist"] and u["AutoBountyOrbitDist"].Set then pcall(function() u["AutoBountyOrbitDist"]:Set(3) end) end
            if u["AutoBountyCombatDist"] and u["AutoBountyCombatDist"].Set then pcall(function() u["AutoBountyCombatDist"]:Set(5.5) end) end
            if u["AutoBountyOrbitSpeed"] and u["AutoBountyOrbitSpeed"].Set then pcall(function() u["AutoBountyOrbitSpeed"]:Set(12) end) end
            if u["AutoBountySoru"] and u["AutoBountySoru"].Set then pcall(function() u["AutoBountySoru"]:Set(false) end) end
            if u["AutoBountyAttack"] and u["AutoBountyAttack"].Set then pcall(function() u["AutoBountyAttack"]:Set(true) end) end
            if u["AutoBountyAttackSpeed"] and u["AutoBountyAttackSpeed"].Set then pcall(function() u["AutoBountyAttackSpeed"]:Set("Medium (0.10s)") end) end
            if u["AutoBountySkills"] and u["AutoBountySkills"].Set then pcall(function() u["AutoBountySkills"]:Set(true) end) end
            if u["ExcludedSkills"] and u["ExcludedSkills"].Set then pcall(function() u["ExcludedSkills"]:Set({ "Fruit F" }) end) end
            if u["AutoBountyWeaponMelee"] and u["AutoBountyWeaponMelee"].Set then pcall(function() u["AutoBountyWeaponMelee"]:Set(true) end) end
            if u["AutoBountyWeaponSword"] and u["AutoBountyWeaponSword"].Set then pcall(function() u["AutoBountyWeaponSword"]:Set(true) end) end
            if u["AutoBountyWeaponFruit"] and u["AutoBountyWeaponFruit"].Set then pcall(function() u["AutoBountyWeaponFruit"]:Set(true) end) end
            if u["AutoBountyWeaponGun"] and u["AutoBountyWeaponGun"].Set then pcall(function() u["AutoBountyWeaponGun"]:Set(true) end) end
            if u["AutoBountyAimbotLock"] and u["AutoBountyAimbotLock"].Set then pcall(function() u["AutoBountyAimbotLock"]:Set(true) end) end
            if u["AutoBountyBuso"] and u["AutoBountyBuso"].Set then pcall(function() u["AutoBountyBuso"]:Set(true) end) end
            if u["AutoBountyKen"] and u["AutoBountyKen"].Set then pcall(function() u["AutoBountyKen"]:Set(true) end) end
            if u["AutoBountyV4"] and u["AutoBountyV4"].Set then pcall(function() u["AutoBountyV4"]:Set(true) end) end
            if u["AutoBountyEnablePvp"] and u["AutoBountyEnablePvp"].Set then pcall(function() u["AutoBountyEnablePvp"]:Set(true) end) end
            if u["AutoFlee"] and u["AutoFlee"].Set then pcall(function() u["AutoFlee"]:Set(true) end) end
            if u["FleeHP"] and u["FleeHP"].Set then pcall(function() u["FleeHP"]:Set(30) end) end
            if u["ReturnHP"] and u["ReturnHP"].Set then pcall(function() u["ReturnHP"]:Set(50) end) end
            if u["AutoHop"] and u["AutoHop"].Set then pcall(function() u["AutoHop"]:Set(true) end) end
            if u["AutoBountyNoSafeZone"] and u["AutoBountyNoSafeZone"].Set then pcall(function() u["AutoBountyNoSafeZone"]:Set(true) end) end
            if u["AutoBountyNoMarineAlly"] and u["AutoBountyNoMarineAlly"].Set then pcall(function() u["AutoBountyNoMarineAlly"]:Set(true) end) end
        end
    end)
end

function AutoBounty.enable()
    if AutoBounty.Enabled then return end
    AutoBounty.Enabled = true

    -- Activate ESP
    setAutoBountyESP(true)

    ensureNoclip()
    startKenDaemon()
    startHakiLoop()
    AutoBounty.startAutoTeamDaemon()
    if not AutoBounty.Running then
        AutoBounty.Running = true
        bountyLoopThread = task.spawn(runBountyLoop)
    end

    task.spawn(function()
        task.wait(0.15)
        if AutoBounty.AutoBuso then autoBuso(true) end
        if AutoBounty.AutoKen then autoKenHaki(true) end
        if AutoBounty.AutoEnablePvp then autoEnablePvp() end
    end)
end

function AutoBounty.disable()
    AutoBounty.Enabled = false
    AutoBounty.Running = false
    isHoppingActive = false
    isFleeing = false
    fleeCancelledUntil = 0
    inCombatRange = false
    targetBurstDone = {}

    -- Clean up sky hold and restore platform stand
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp then
            local hold = hrp:FindFirstChild("DarlingHopHold")
            if hold then hold:Destroy() end
        end
        if hum then
            hum.PlatformStand = false
        end
    end)

    -- Reset all sub-options to false
    AutoBounty.AutoHop = false
    AutoBounty.AutoAttack = false
    AutoBounty.AutoSkills = false
    AutoBounty.AimbotLock = false
    AutoBounty.AutoBuso = false
    AutoBounty.AutoKen = false
    AutoBounty.AutoV4 = false
    AutoBounty.AutoEnablePvp = false
    AutoBounty.AutoFlee = false
    AutoBounty.AutoSoru = false
    AutoBounty.Orbit = false
    AutoBounty.NoSafeZone = false
    AutoBounty.NoMarineAlly = false
    AutoBounty.UseMelee = false
    AutoBounty.UseSword = false
    AutoBounty.UseFruit = false
    AutoBounty.UseGun = false

    -- Stop all threads
    if bountyLoopThread then
        pcall(function() task.cancel(bountyLoopThread) end)
        bountyLoopThread = nil
    end
    if kenDaemonThread then
        pcall(function() task.cancel(kenDaemonThread) end)
        kenDaemonThread = nil
    end
    if hakiLoopThread then
        pcall(function() task.cancel(hakiLoopThread) end)
        hakiLoopThread = nil
    end
    if autoTeamThread then
        pcall(function() task.cancel(autoTeamThread) end)
        autoTeamThread = nil
    end
    if saveDebounceThread then
        pcall(function() task.cancel(saveDebounceThread) end)
        saveDebounceThread = nil
    end

    if AutoBounty.CurrentTarget or AutoBounty.AimbotLock then
        pcall(function()
            local hub = getHub()
            local core = hub and hub.Require and hub:Require("modules/combat/aimbot_core.lua")
            if core then
                core.LockedTargetPlayer = nil
                if not (hub and hub.FeatureStates and hub.FeatureStates["LockPlayer"]) then
                    core.LockPlayer = false
                end
                if not (hub and hub.FeatureStates and hub.FeatureStates["Player Silent Aim"]) then
                    core.PlayerAimEnabled = false
                end
                if not (hub and hub.FeatureStates and hub.FeatureStates["NPC Silent Aim"]) then
                    core.NPCAimEnabled = false
                end
                if core.stopLoop then core.stopLoop() end
            end
        end)
    end
    AutoBounty.CurrentTarget = nil
    _G.DarlingAutoBountyTarget = nil
    _G.DarlingTarget = nil
    _G.DarlingSilentAimTarget = nil
    _G.currentSilentAimTarget = nil
    stopTween()
    disableStickyFollow()
    stopFastAttackLoop()
    disableNoclip()
    _G.DarlingIsCastingSkill = false
    AutoBounty.Status = "Disabled"

    -- Deactivate ESP
    setAutoBountyESP(false)

    -- Synchronize UI elements to false
    pcall(function()
        local hub = getHub()
        if hub and hub.UIElements then
            local u = hub.UIElements
            local togglesToOff = {
                "AutoBounty", "AutoHop", "AutoBountyAttack",
                "AutoBountySkills", "AutoBountyAimbotLock", "AutoBountyBuso",
                "AutoBountyKen", "AutoBountyV4", "AutoBountyEnablePvp",
                "AutoFlee", "AutoBountySoru", "AutoBountyOrbit",
                "AutoBountyWeaponMelee", "AutoBountyWeaponSword",
                "AutoBountyWeaponFruit", "AutoBountyWeaponGun",
                "AutoBountyNoSafeZone", "AutoBountyNoMarineAlly"
            }
            for _, key in ipairs(togglesToOff) do
                if u[key] and u[key].Set then
                    pcall(function() u[key]:Set(false) end)
                end
            end
        end
    end)
end

function AutoBounty.toggle(state)
    if state == nil then state = not AutoBounty.Enabled end
    if state then
        AutoBounty.enable()
    else
        AutoBounty.disable()
    end
    return AutoBounty.Enabled
end

pcall(function()
    AutoBounty.loadConfig()
end)

return AutoBounty
