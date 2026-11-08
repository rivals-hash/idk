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
    FlySpeed = 350,
    NearTweenSpeed = 350,
    FarTweenSpeed = 350,
    TweenThreshold = 1000,
    MaxDistance = 100000,
    NoSafeZone = false,
    NoMarineAlly = false,

    -- Soru & Skills & Attacks (all OFF by default until Auto Bounty is activated)
    AutoSoru = false,
    AutoSkills = false,
    AutoAttack = false,
    AutoBuso = false,
    AutoKen = false,
    AutoEnablePvp = false,
    AutoV4 = false,

    -- Fast Attack Speed Configuration
    FastAttackSpeed = "Medium (0.10s)",
    AttackDelay = 0.10,

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
    Orbit = false,
    OrbitDistance = 10,
    OrbitSpeed = 6.0,

    -- Auto Hop & Target Player Count
    AutoHop = false,
    HopIfEmpty = true,
    TargetPlayerCount = 8,

    -- Weapon preferences
    Weapons = {
        Melee = true,
        Sword = true,
        Fruit = true,
        Gun = false,
    },
}

local currentTween = nil
local noclipConn = nil
local stickyConn = nil
local bountyLoopThread = nil

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
    local char = LocalPlayer.Character
    if char then
        if char:GetAttribute("InCombat") == true or char:GetAttribute("Busy") == true or char:FindFirstChild("InCombat") ~= nil then
            return true
        end
    end
    if (os.clock() - lastCombatActionTime) < 4.0 then
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

-- Continuous Sticky Tracking
-- Glues local player position right next to target 60 times/sec, never stuttering or stopping
local function ensureStickyFollow()
    if stickyConn then return end
    stickyConn = RunService.Heartbeat:Connect(function(dt)
        if not AutoBounty.Enabled or isFleeing then return end
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
            if AutoBounty.Orbit then
                local orbitAngle = (tick() * (AutoBounty.OrbitSpeed or 6.0)) % (2 * math.pi)
                local r = AutoBounty.OrbitDistance or 4.5
                local h = 1.2
                local orbitPos = tPos + Vector3.new(math.cos(orbitAngle) * r, h, math.sin(orbitAngle) * r)
                followCF = CFrame.lookAt(orbitPos, tPos)
            else
                local behindOffset = tHRP.CFrame * CFrame.new(0, 1.2, 4.0)
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

-- Throttled Background FastAttack Loop (Uses actual AttackDelay)
local performFastAttack = nil
local fastAttackThread = nil
local function startFastAttackLoop()
    if fastAttackThread then return end
    fastAttackThread = task.spawn(function()
        while AutoBounty.Enabled do
            local delay = AutoBounty.AttackDelay or 0.03
            if AutoBounty.AutoAttack and not isFleeing then
                local target = AutoBounty.CurrentTarget
                if target and isPlayerAlive(target) then
                    local myChar = LocalPlayer.Character
                    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local tChar = target.Character
                    local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    if myHRP and tHRP then
                        local dist = (tHRP.Position - myHRP.Position).Magnitude
                        if dist <= 55 then
                            performFastAttack(tChar)
                        end
                    end
                end
            end
            if delay <= 0 then
                task.wait(0.02)
            else
                task.wait(math.max(delay, 0.02))
            end
        end
        fastAttackThread = nil
    end)
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
local busoActiveOnCharacter = false

local function isBusoActive()
    local char = LocalPlayer.Character
    if not char then return false end

    -- Check Character only (do NOT check LocalPlayer which records unlocked ownership!)
    if char:FindFirstChild("HasBuso") or char:GetAttribute("HasBuso") == true then
        busoActiveOnCharacter = true
        return true
    end
    if char:FindFirstChild("Buso") or char:GetAttribute("Buso") == true then
        busoActiveOnCharacter = true
        return true
    end

    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and (part:FindFirstChild("Buso") or part:FindFirstChild("Aura")) then
            busoActiveOnCharacter = true
            return true
        end
    end

    if busoActiveOnCharacter then return true end
    return false
end

local function autoBuso(force)
    if not AutoBounty.AutoBuso then return end
    if busoActiveOnCharacter and not force then return end
    local now = os.clock()
    if (now - lastBusoTick) < 1.2 and not force then return end
    lastBusoTick = now

    pcall(function()
        local char = LocalPlayer.Character
        if char and not isBusoActive() then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local commF = (remotes and remotes:FindFirstChild("CommF_")) or ReplicatedStorage:FindFirstChild("CommF_")
            if commF then
                commF:InvokeServer("Buso")
                task.wait(0.3)
                if isBusoActive() then
                    busoActiveOnCharacter = true
                end
            end
        end
    end)
end

-- Auto Ken Haki (Observation Haki / Vision) exact detection and multi-path activation
local lastKenTick = 0

local function isObservationActive()
    local char = LocalPlayer.Character
    if not char then return false end

    if CollectionService:HasTag(char, "Ken") or CollectionService:HasTag(char, "Observation") then
        return true
    end
    if char:GetAttribute("Ken") == true or char:GetAttribute("Observation") == true or char:GetAttribute("Vision") == true or char:GetAttribute("Instinct") == true then
        return true
    end

    local renvG = getrenv and getrenv()._G
    local om = renvG and renvG.OM
    if om and (om.active == true or om.Active == true) then
        return true
    end

    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        local cag = pGui:FindFirstChild("ContextActionGui")
        if cag then
            local kenBtn = cag:FindFirstChild("BoundActionKen", true)
            if kenBtn and (kenBtn:GetAttribute("Selected") == true or (kenBtn:FindFirstChild("Selected") and kenBtn.Selected.Visible)) then
                return true
            end
        end
    end

    return false
end

local function autoKenHaki(force)
    if not AutoBounty.AutoKen then return end
    local now = os.clock()
    if (now - lastKenTick) < 1.5 and not force then return end
    if not force and isObservationActive() then return end
    lastKenTick = now

    pcall(function()
        local renvG = getrenv and getrenv()._G
        local om = renvG and renvG.OM
        if om and not om.active then
            pcall(function()
                om.radius = 0
                om:setActive(true)
            end)
        end

        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then
            local kenBtn = pGui:FindFirstChild("BoundActionKen", true)
            if kenBtn and kenBtn:IsA("GuiButton") and firesignal then
                pcall(firesignal, kenBtn.Activated)
            end
        end

        if VirtualInputManager then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.delay(0.08, function()
                pcall(function()
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end)
            end)
        end
    end)
end

AutoBounty.isBusoActive = isBusoActive
AutoBounty.autoBuso = autoBuso
AutoBounty.isObservationActive = isObservationActive
AutoBounty.autoKenHaki = autoKenHaki

-- Reset Ken and Buso state and reactivate on character spawn with multi-step retry loop
local lastCharHealth = 100
LocalPlayer.CharacterAdded:Connect(function(char)
    inCombatRange = false
    isFleeing = false
    lastCharHealth = 100
    busoActiveOnCharacter = false

    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        lastCharHealth = hum.Health
        hum.HealthChanged:Connect(function(newHealth)
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

            if (isBusoActive() or busoActiveOnCharacter) and isObservationActive() then
                break
            end
            task.wait(1.2)
        end
        if AutoBounty.AutoBuso then
            busoActiveOnCharacter = true
        end
    end)
end)

-- Persistent Haki Background Loop (checks periodically when AutoBounty is enabled)
task.spawn(function()
    while true do
        task.wait(2.5)
        if AutoBounty.Enabled then
            if AutoBounty.AutoBuso and not isBusoActive() then
                autoBuso(false)
            end
            if AutoBounty.AutoKen and not isObservationActive() then
                autoKenHaki(false)
            end
        end
    end
end)

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
local function matchesWeaponType(tool, category)
    if not (tool and tool:IsA("Tool")) then return false end
    local tip = string.lower(tool.ToolTip or "")
    local name = string.lower(tool.Name or "")
    if category == "Melee" then
        return tip:find("melee") or name:find("godhuman") or name:find("superhuman") or name:find("karate") or name:find("claw") or name:find("talon") or name:find("step") or name:find("sanguine") or name:find("combat") or name:find("breath") or name:find("kung fu")
    elseif category == "Sword" then
        return tip:find("sword") or name:find("blade") or name:find("katana") or name:find("saber") or name:find("scythe") or name:find("anchor") or name:find("trident") or name:find("dagger") or name:find("cutlass")
    elseif category == "Fruit" then
        return tip:find("fruit") or tip:find("blox") or name:find("-") or name:find("fruit")
    elseif category == "Gun" then
        return tip:find("gun") or name:find("guitar") or name:find("rifle") or name:find("cannon") or name:find("bow") or name:find("kabucha") or name:find("slingshot") or name:find("bazooka")
    end
    return false
end

-- Weapon Equip from Backpack or Character
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

    -- If no specific tool found for category, keep whatever tool is equipped or equip first available
    if not currentTool and bp then
        local first = bp:FindFirstChildOfClass("Tool")
        if first then
            hum:EquipTool(first)
            return true
        end
    end
    return currentTool ~= nil
end

-- Real-time Blox Fruits UI Cooldown Verifier
local function isSkillOnCooldown(tool, skillKey)
    if not tool or not skillKey then return false end
    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local main = pGui and pGui:FindFirstChild("Main")
    local skills = main and main:FindFirstChild("Skills")
    if not skills then return false end

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
    if not toolSkills then return false end

    local skillFrame = toolSkills:FindFirstChild(skillKey)
    local cd = skillFrame and skillFrame:FindFirstChild("Cooldown")
    if not cd then return false end

    local scale = cd.Size.X.Scale
    return cd.Visible == true and scale > 0.05
end

-- Cast skill key with cooldown check, direct aim at target torso & mobile touch execution
local function castSkillKey(keyCode, tool, targetHRP)
    local skillKey = keyCode.Name
    if tool and isSkillOnCooldown(tool, skillKey) then
        return false -- Skip immediately if on cooldown
    end

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

        if VirtualInputManager then
            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
            task.wait(0.08)
            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
        end
    end)
    task.wait(0.25)
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
    local team = LocalPlayer.Team
    local teamName = team and team.Name
    if teamName == "Pirates" or teamName == "Marines" then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            return true
        end
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

-- Guaranteed Auto Join Team Daemon (runs early, waits for game load and screen readiness)
task.spawn(function()
    if not game:IsLoaded() then
        pcall(function() game.Loaded:Wait() end)
    end

    local targetTeam = AutoBounty.AutoTeam or "Pirates"
    for _ = 1, 150 do -- 75 seconds monitoring window
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
end)

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
            NearTweenSpeed = AutoBounty.NearTweenSpeed or 350,
            FarTweenSpeed = AutoBounty.FarTweenSpeed or 350,
            FlySpeed = AutoBounty.FlySpeed or 350,
            TweenThreshold = AutoBounty.TweenThreshold or 1000,
            Orbit = AutoBounty.Orbit == true,
            OrbitDistance = AutoBounty.OrbitDistance or 10,
            OrbitSpeed = AutoBounty.OrbitSpeed or 6.0,
            TargetPlayerCount = AutoBounty.TargetPlayerCount or 8,
            AutoHop = AutoBounty.AutoHop == true,
            AutoAttack = AutoBounty.AutoAttack == true,
            FastAttackSpeed = AutoBounty.FastAttackSpeed or "Medium (0.10s)",
            AttackDelay = AutoBounty.AttackDelay or 0.10,
            AutoSkills = AutoBounty.AutoSkills == true,
            DisabledSkills = AutoBounty.DisabledSkills or {},
            AimbotLock = AutoBounty.AimbotLock == true,
            AutoBuso = AutoBounty.AutoBuso == true,
            AutoKen = AutoBounty.AutoKen == true,
            AutoV4 = AutoBounty.AutoV4 == true,
            AutoEnablePvp = AutoBounty.AutoEnablePvp == true,
            AutoFlee = AutoBounty.AutoFlee == true,
            CancelHealth = AutoBounty.CancelHealth == true,
            FleeHP = AutoBounty.FleeHP or 30,
            ReturnHP = AutoBounty.ReturnHP or 50,
            FleeHeight = AutoBounty.FleeHeight or 1500,
            NoSafeZone = AutoBounty.NoSafeZone == true,
            NoMarineAlly = AutoBounty.NoMarineAlly == true,
            AutoSoru = AutoBounty.AutoSoru == true,
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
    AutoBounty.NearTweenSpeed = 350
    AutoBounty.FarTweenSpeed = 350
    AutoBounty.FlySpeed = 350
    AutoBounty.TweenThreshold = 1000
    AutoBounty.Orbit = false
    AutoBounty.OrbitDistance = 10
    AutoBounty.OrbitSpeed = 6.0
    AutoBounty.TargetPlayerCount = 8
    AutoBounty.AutoHop = false
    AutoBounty.AutoAttack = false
    AutoBounty.FastAttackSpeed = "Medium (0.10s)"
    AutoBounty.AttackDelay = 0.10
    AutoBounty.AutoSkills = false
    AutoBounty.DisabledSkills = {}
    AutoBounty.AimbotLock = false
    AutoBounty.AutoBuso = false
    AutoBounty.AutoKen = false
    AutoBounty.AutoV4 = false
    AutoBounty.AutoEnablePvp = false
    AutoBounty.AutoFlee = false
    AutoBounty.CancelHealth = false
    AutoBounty.FleeHP = 30
    AutoBounty.ReturnHP = 50
    AutoBounty.FleeHeight = 1500
    AutoBounty.NoSafeZone = false
    AutoBounty.NoMarineAlly = false
    AutoBounty.AutoSoru = false

    local writeFunc = writefile or (syn and syn.writefile)
    if writeFunc then
        local cfg = {
            AutoBountyMode = false,
            AutoTeam = "Pirates",
            NearTweenSpeed = 350,
            FarTweenSpeed = 350,
            FlySpeed = 350,
            TweenThreshold = 1000,
            Orbit = false,
            OrbitDistance = 10,
            OrbitSpeed = 6.0,
            TargetPlayerCount = 8,
            AutoHop = false,
            AutoAttack = false,
            FastAttackSpeed = "Medium (0.10s)",
            AttackDelay = 0.10,
            AutoSkills = false,
            DisabledSkills = {},
            AimbotLock = false,
            AutoBuso = false,
            AutoKen = false,
            AutoV4 = false,
            AutoEnablePvp = false,
            AutoFlee = false,
            CancelHealth = false,
            FleeHP = 30,
            ReturnHP = 50,
            FleeHeight = 1500,
            NoSafeZone = false,
            NoMarineAlly = false,
            AutoSoru = false,
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
    if data.NearTweenSpeed ~= nil then AutoBounty.NearTweenSpeed = math.clamp(tonumber(data.NearTweenSpeed) or 350, 50, 500) end
    if data.FarTweenSpeed ~= nil then AutoBounty.FarTweenSpeed = math.clamp(tonumber(data.FarTweenSpeed) or 350, 50, 500) end
    if data.FlySpeed ~= nil then AutoBounty.FlySpeed = math.clamp(tonumber(data.FlySpeed) or 350, 50, 500) end
    if data.TweenThreshold ~= nil then AutoBounty.TweenThreshold = tonumber(data.TweenThreshold) or 1000 end
    if data.Orbit ~= nil then AutoBounty.Orbit = (data.Orbit == true) end
    if data.OrbitDistance ~= nil then AutoBounty.OrbitDistance = tonumber(data.OrbitDistance) or 10 end
    if data.OrbitSpeed ~= nil then AutoBounty.OrbitSpeed = tonumber(data.OrbitSpeed) or 6.0 end
    if data.TargetPlayerCount ~= nil then AutoBounty.TargetPlayerCount = tonumber(data.TargetPlayerCount) or 8 end
    if data.AutoHop ~= nil then AutoBounty.AutoHop = (data.AutoHop == true) end
    if data.AutoAttack ~= nil then AutoBounty.AutoAttack = (data.AutoAttack == true) end
    if data.FastAttackSpeed ~= nil then AutoBounty.FastAttackSpeed = data.FastAttackSpeed end
    if data.AttackDelay ~= nil then AutoBounty.AttackDelay = tonumber(data.AttackDelay) or 0.10 end
    if data.AutoSkills ~= nil then AutoBounty.AutoSkills = (data.AutoSkills == true) end
    if data.DisabledSkills ~= nil and type(data.DisabledSkills) == "table" then
        AutoBounty.DisabledSkills = data.DisabledSkills
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

    return true
end
-- Server Hop Routine (Continuous Sky Ascent + Native Browser + Multi-Page Remote Query + HTTP API)
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

        -- Elevate into sky immediately to avoid danger and combat logging
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(hrp.Position.X, math.max(hrp.Position.Y + 300, 1800), hrp.Position.Z)
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end)

        -- Continuous Linear Sky Tween: ascends smoothly at 280 studs/sec into the sky until server transfer completes
        local ascentActive = true
        task.spawn(function()
            local stepTime = 0.35
            local stepDist = 98
            while isHoppingActive and ascentActive do
                pcall(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local currentY = hrp.Position.Y
                        local targetY = math.min(currentY + stepDist, 4500)
                        local targetCF = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z)
                        local tw = TweenService:Create(
                            hrp,
                            TweenInfo.new(stepTime, Enum.EasingStyle.Linear),
                            { CFrame = targetCF }
                        )
                        tw:Play()
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end
                end)
                task.wait(stepTime)
            end
        end)

        -- Wait for combat risk to clear while safely ascending in the sky
        local combatWaitCount = 0
        while checkInCombat() and combatWaitCount < 12 do
            AutoBounty.Status = "Hopping: Waiting for combat risk in sky (" .. tostring(12 - combatWaitCount) .. "s)..."
            combatWaitCount = combatWaitCount + 1
            task.wait(1)
        end

        local placeId = game.PlaceId
        local currentJobId = game.JobId

        -- Auto-re-execute script on new server arrival
        local queueTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
        if queueTeleport then
            pcall(function()
                queueTeleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/rivals-hash/idk/main/main.lua"))()]])
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
                                    AutoBounty.Status = "Hopping: Joining " .. jobStr:sub(1, 8) .. "..."
                                    hopSuccess = true
                                    ascentActive = false
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

                if #candidateJobIds > 0 then
                    local chosenJob = candidateJobIds[math.random(1, #candidateJobIds)]
                    AutoBounty.Status = "Hopping: Joining server (" .. chosenJob:sub(1, 8) .. ")..."
                    hopSuccess = true
                    ascentActive = false
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

            if #candidateJobIds > 0 then
                local chosenId = candidateJobIds[math.random(1, #candidateJobIds)]
                AutoBounty.Status = "Hopping: Joining " .. tostring(chosenId):sub(1, 8) .. "..."
                hopSuccess = true
                ascentActive = false
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(placeId, chosenId, LocalPlayer)
                end)
                task.wait(4.0)
            end
        end

        -- Final fallback: random teleport
        if not hopSuccess and isHoppingActive then
            AutoBounty.Status = "Hopping: Teleporting to random server..."
            ascentActive = false
            pcall(function()
                TeleportService:Teleport(placeId, LocalPlayer)
            end)
        end

        task.delay(12, function()
            isHoppingActive = false
            ascentActive = false
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

                                -- Initial burst of 3 skills to break enemy Ken Haki dodges
                                local targetId = target.UserId or target.Name
                                if not targetBurstDone[targetId] then
                                    AutoBounty.Status = "Breaking Ken Haki: " .. target.DisplayName
                                    local burstCount = 0
                                    local burstWeapons = { "Melee", "Sword", "Fruit", "Gun" }
                                    local burstKeys = { Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C }
                                    for _, bwName in ipairs(burstWeapons) do
                                        if burstCount >= 3 or not AutoBounty.Enabled or not isPlayerAlive(target) or isHoppingActive then break end
                                        if AutoBounty.Weapons[bwName] then
                                            equipWeapon(bwName)
                                            task.wait(0.12)
                                            local cTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                            for _, bk in ipairs(burstKeys) do
                                                if burstCount >= 3 or not AutoBounty.Enabled or not isPlayerAlive(target) or isHoppingActive then break end
                                                local sName = bwName .. " " .. bk.Name
                                                local isGHZ = (cTool and string.find(string.lower(cTool.Name), "godhuman") and bk.Name == "Z")
                                                if not (AutoBounty.DisabledSkills[sName] or (isGHZ and (AutoBounty.DisabledSkills["Godhuman Z"] or AutoBounty.DisabledSkills["God Human Z"]))) then
                                                    if castSkillKey(bk, cTool, tHRP) then
                                                        burstCount = burstCount + 1
                                                        task.wait(0.20)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    targetBurstDone[targetId] = true
                                end

                                local weaponOrder = { "Melee", "Sword", "Fruit", "Gun" }
                                for _, wName in ipairs(weaponOrder) do
                                    if not AutoBounty.Enabled or not isPlayerAlive(target) or isHoppingActive then break end
                                    if AutoBounty.Weapons[wName] then
                                        local curDist = (tHRP.Position - myHRP.Position).Magnitude
                                        if curDist > 95 then break end

                                        -- Wait for previous skill animation to finish before swapping weapon
                                        local ch = LocalPlayer.Character
                                        local busy = ch and ch:FindFirstChild("Busy")
                                        if busy and busy.Value == true then
                                            local waitStart = os.clock()
                                            while busy.Value == true and (os.clock() - waitStart) < 0.4 do
                                                task.wait(0.04)
                                            end
                                        end

                                        equipWeapon(wName)
                                        task.wait(0.12)

                                        local currentTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                        if AutoBounty.AutoAttack then
                                            performFastAttack(tChar)
                                        end

                                        if AutoBounty.AutoSkills then
                                            local keys = { Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.F }
                                            for _, k in ipairs(keys) do
                                                if not AutoBounty.Enabled or not isPlayerAlive(target) or isHoppingActive then break end
                                                local curD = (tHRP.Position - myHRP.Position).Magnitude
                                                if curD > 95 then break end

                                                local skillName = wName .. " " .. k.Name
                                                local isGodhumanZ = (currentTool and string.find(string.lower(currentTool.Name), "godhuman") and k.Name == "Z")
                                                if not (AutoBounty.DisabledSkills[skillName] or (isGodhumanZ and (AutoBounty.DisabledSkills["Godhuman Z"] or AutoBounty.DisabledSkills["God Human Z"]))) then
                                                    if castSkillKey(k, currentTool, tHRP) then
                                                        task.wait(0.18)
                                                        if AutoBounty.AutoAttack then
                                                            performFastAttack(tChar)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    if not AutoBounty.Enabled or isHoppingActive then break end
                                end
                            end
                        end
                    else
                        inCombatRange = false
                        stopTween()
                        ensureHoldVelocity()
                        scanRetryCount = scanRetryCount + 1
                        if scanRetryCount <= 2 then
                            AutoBounty.Status = "Searching targets (" .. scanRetryCount .. "/2)..."
                            task.wait(1.0)
                            AutoBounty.CurrentTarget = findNextTarget()
                        else
                            AutoBounty.Status = "No targets found. Hopping server..."
                            if AutoBounty.AutoHop and not isHoppingActive then
                                AutoBounty.hopServer()
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

function AutoBounty.enable()
    if AutoBounty.Enabled then return end
    AutoBounty.Enabled = true

    -- Turn on the full default combat stack when Auto Bounty is activated
    AutoBounty.AutoSkills = true
    AutoBounty.AutoAttack = true
    AutoBounty.AutoBuso = true
    AutoBounty.AutoKen = true
    AutoBounty.AutoV4 = true
    AutoBounty.AutoEnablePvp = true
    AutoBounty.AimbotLock = true
    AutoBounty.Orbit = true
    AutoBounty.AutoHop = true
    AutoBounty.AutoFlee = true
    AutoBounty.NoSafeZone = true
    AutoBounty.NoMarineAlly = true

    -- Synchronize UI elements in the Auto Bounty tab
    pcall(function()
        local hub = getHub()
        if hub and hub.UIElements then
            local u = hub.UIElements
            if u["AutoBountyAttack"] and u["AutoBountyAttack"].Set then pcall(function() u["AutoBountyAttack"]:Set(true) end) end
            if u["AutoBountySkills"] and u["AutoBountySkills"].Set then pcall(function() u["AutoBountySkills"]:Set(true) end) end
            if u["AutoBountyBuso"] and u["AutoBountyBuso"].Set then pcall(function() u["AutoBountyBuso"]:Set(true) end) end
            if u["AutoBountyKen"] and u["AutoBountyKen"].Set then pcall(function() u["AutoBountyKen"]:Set(true) end) end
            if u["AutoBountyV4"] and u["AutoBountyV4"].Set then pcall(function() u["AutoBountyV4"]:Set(true) end) end
            if u["AutoBountyEnablePvp"] and u["AutoBountyEnablePvp"].Set then pcall(function() u["AutoBountyEnablePvp"]:Set(true) end) end
            if u["AutoBountyAimbotLock"] and u["AutoBountyAimbotLock"].Set then pcall(function() u["AutoBountyAimbotLock"]:Set(true) end) end
            if u["AutoBountyOrbit"] and u["AutoBountyOrbit"].Set then pcall(function() u["AutoBountyOrbit"]:Set(true) end) end
            if u["AutoHop"] and u["AutoHop"].Set then pcall(function() u["AutoHop"]:Set(true) end) end
            if u["AutoFlee"] and u["AutoFlee"].Set then pcall(function() u["AutoFlee"]:Set(true) end) end
            if u["AutoBountyNoSafeZone"] and u["AutoBountyNoSafeZone"].Set then pcall(function() u["AutoBountyNoSafeZone"]:Set(true) end) end
            if u["AutoBountyNoMarineAlly"] and u["AutoBountyNoMarineAlly"].Set then pcall(function() u["AutoBountyNoMarineAlly"]:Set(true) end) end
        end
    end)

    -- Activate ESP
    setAutoBountyESP(true)

    ensureNoclip()
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

    -- Stop all threads
    if bountyLoopThread then
        pcall(function() task.cancel(bountyLoopThread) end)
        bountyLoopThread = nil
    end
    if saveDebounceThread then
        pcall(function() task.cancel(saveDebounceThread) end)
        saveDebounceThread = nil
    end

    if AutoBounty.CurrentTarget then
        pcall(function()
            local hub = getHub()
            local core = hub and hub.Require and hub:Require("modules/combat/aimbot_core.lua")
            if core and core.LockedTargetPlayer == AutoBounty.CurrentTarget then
                core.LockedTargetPlayer = nil
                if not (hub and hub.FeatureStates and hub.FeatureStates["LockPlayer"]) then
                    core.LockPlayer = false
                end
            end
        end)
    end
    AutoBounty.CurrentTarget = nil
    _G.DarlingAutoBountyTarget = nil
    _G.DarlingTarget = nil
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
                "AutoFlee", "AutoBountySoru"
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
