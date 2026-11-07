--[[
    Darling Hub - Soru Engine
    Authentic Blox Fruits Soru / Flashstep implementation.
    Includes official animation (FlashStepRegular), sound effect, native cooldown events,
    remote invocation via CommE, Infinite Soru, Soru Aimbot, and Skill Combos.
]]--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local SoruEngine = {
    -- Infinite Soru
    InfiniteEnabled = false,
    AttrConn = nil,
    CharConn = nil,
    InfiniteLoopRunning = false,

    -- Soru Aimbot
    AimbotEnabled = false,
    MaxDistance = 2000,
    TargetMode = "Nearest Player",
    SelectedPlayer = nil,
    Hooked = false,

    -- Soru Skill Combo
    SkillComboEnabled = false,
    SkillWeapon = "Fruit", -- "Melee", "Fruit", "Sword", "Gun"
    SkillKey = "Z",        -- "Z", "X", "C", "V", "F"
    SkillDelay = 0.3,
    AnimConn = nil,

    -- Cooldown State
    IsCoolingDown = false,
    LastUseTimestamp = 0,
}

local FLASH_NAMES = { "FlashStepRegular", "FlashStepDraco", "FlashStep", "Flashstep", "Soru" }
local FLASH_IDS = { "17555632156", "18461649274", "616006778", "616010882", "5403485593", "5403491911" }

local WEAPON_SLOTS = {
    Melee = Enum.KeyCode.One,
    Fruit = Enum.KeyCode.Two,
    Sword = Enum.KeyCode.Three,
    Gun = Enum.KeyCode.Four,
}

local function isFlashstepAnim(track)
    if not track then return false end
    local name = track.Name and track.Name:lower() or ""
    for _, n in ipairs(FLASH_NAMES) do
        if name:find(n:lower(), 1, true) then return true end
    end
    local anim = track.Animation
    local id = anim and anim.AnimationId:match("%d+") or ""
    for _, fid in ipairs(FLASH_IDS) do
        if id == fid then return true end
    end
    return false
end

-- --- Soru Aimbot Target Resolution ---
local function getAimbotTarget()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil, nil end

    -- 1. Explicitly selected player
    if SoruEngine.TargetMode ~= "Nearest Player" and SoruEngine.SelectedPlayer then
        local targetPlayer = Players:FindFirstChild(SoruEngine.SelectedPlayer)
        if not targetPlayer then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name == SoruEngine.SelectedPlayer or p.DisplayName == SoruEngine.SelectedPlayer then
                    targetPlayer = p
                    break
                end
            end
        end
        if targetPlayer and targetPlayer.Character then
            local eHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local eHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if eHRP and eHum and eHum.Health > 0 then
                local dist = (myHRP.Position - eHRP.Position).Magnitude
                if dist <= SoruEngine.MaxDistance then
                    return targetPlayer, eHRP
                end
            end
        end
    end

    -- 2. Target from Shared Combat Core or AutoBounty
    if _G.currentSilentAimTarget and _G.currentSilentAimTarget.Parent then
        local pChar = _G.currentSilentAimTarget.Parent
        local pHum = pChar:FindFirstChildOfClass("Humanoid")
        local pHRP = pChar:FindFirstChild("HumanoidRootPart") or _G.currentSilentAimTarget
        if pHum and pHum.Health > 0 and pHRP then
            local dist = (myHRP.Position - pHRP.Position).Magnitude
            if dist <= SoruEngine.MaxDistance then
                return Players:GetPlayerFromCharacter(pChar), pHRP
            end
        end
    end

    -- 3. Closest enemy player
    local closestDist = SoruEngine.MaxDistance
    local bestPlayer, bestHRP = nil, nil

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local isBlacklisted = false
            if _G.DarlingBlacklistedPlayers and (_G.DarlingBlacklistedPlayers[p.UserId] or _G.DarlingBlacklistedPlayers[p.Name]) then
                isBlacklisted = true
            end

            if not isBlacklisted then
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
    end

    return bestPlayer, bestHRP
end
SoruEngine.getAimbotTarget = getAimbotTarget

local inHook = false
local function setupMetamethodHook()
    if SoruEngine.Hooked then return end
    SoruEngine.Hooked = true

    local core = _G.MonodyCombatCore or _G.DarlingCombatCore
    if core and core.installHooks then
        pcall(core.installHooks)
        return
    end

    if not hookmetamethod then return end

    pcall(function()
        local mouse = LocalPlayer and LocalPlayer:GetMouse()
        if not mouse then return end
        local oldIndex = nil
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if inHook then return oldIndex(self, key) end
            if checkcaller and checkcaller() then return oldIndex(self, key) end

            if self == mouse and (key == "Hit" or key == "Target") then
                if SoruEngine.AimbotEnabled then
                    inHook = true
                    local _, targetHRP = getAimbotTarget()
                    if targetHRP and targetHRP.Parent then
                        local tp = targetHRP.Position
                        local cam = Workspace.CurrentCamera
                        local cp = cam and cam.CFrame.Position
                        if key == "Hit" then
                            inHook = false
                            if cp then
                                local look = (tp - cp)
                                if look.Magnitude > 0.001 then
                                    return CFrame.lookAt(tp, tp + look.Unit)
                                end
                            end
                            return CFrame.new(tp)
                        elseif key == "Target" then
                            inHook = false
                            return targetHRP
                        end
                    end
                    inHook = false
                end
            end
            return oldIndex(self, key)
        end))
    end)
end

-- --- Infinite Soru ---
function SoruEngine.enforceInfinite(char)
    if not char then return end
    if SoruEngine.InfiniteEnabled then
        pcall(function() char:SetAttribute("FlashstepCooldown", 1) end)
    end
    if SoruEngine.AttrConn then
        pcall(function() SoruEngine.AttrConn:Disconnect() end)
    end
    SoruEngine.AttrConn = char.AttributeChanged:Connect(function(attr)
        if attr == "FlashstepCooldown" and SoruEngine.InfiniteEnabled then
            if char:GetAttribute("FlashstepCooldown") ~= 1 then
                pcall(function() char:SetAttribute("FlashstepCooldown", 1) end)
            end
        end
    end)
end

function SoruEngine.setInfinite(state)
    SoruEngine.InfiniteEnabled = (state == true)
    local char = LocalPlayer.Character
    if char then SoruEngine.enforceInfinite(char) end

    if state and not SoruEngine.CharConn then
        SoruEngine.CharConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
            task.wait(0.5)
            SoruEngine.enforceInfinite(newChar)
            SoruEngine.bindSkillCombo(newChar)
        end)
    elseif not state and SoruEngine.CharConn then
        pcall(function() SoruEngine.CharConn:Disconnect() end)
        SoruEngine.CharConn = nil
    end

    if state and not SoruEngine.InfiniteLoopRunning then
        SoruEngine.InfiniteLoopRunning = true
        task.spawn(function()
            while SoruEngine.InfiniteEnabled do
                task.wait(0.5)
                local c = LocalPlayer.Character
                if c and c:GetAttribute("FlashstepCooldown") ~= 1 then
                    pcall(function() c:SetAttribute("FlashstepCooldown", 1) end)
                end
            end
            SoruEngine.InfiniteLoopRunning = false
        end)
    end
end

-- --- Soru Aimbot ---
function SoruEngine.setAimbot(state)
    SoruEngine.AimbotEnabled = (state == true)
    if state then setupMetamethodHook() end
end

-- --- Soru Skill Combo Execution ---
local function executeSkillCombo()
    if not SoruEngine.SkillComboEnabled then return end

    task.spawn(function()
        local d = tonumber(SoruEngine.SkillDelay) or 0.3
        task.wait(d)
        if not SoruEngine.SkillComboEnabled then return end

        local myChar = LocalPlayer.Character
        local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        local targetToolName = SoruEngine.SkillWeapon or "Fruit"
        local foundTool = nil

        -- Direct equip from Backpack or Character
        for _, item in ipairs(myChar:GetChildren()) do
            if item:IsA("Tool") and (item:GetAttribute("WeaponType") == targetToolName or item.Name:lower():find(targetToolName:lower())) then
                foundTool = item
                break
            end
        end
        if not foundTool then
            for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if item:IsA("Tool") and (item:GetAttribute("WeaponType") == targetToolName or item.Name:lower():find(targetToolName:lower())) then
                    foundTool = item
                    break
                end
            end
        end

        if foundTool and foundTool.Parent == LocalPlayer.Backpack then
            pcall(function() hum:EquipTool(foundTool) end)
            task.wait(0.1)
        end

        local skillKeyName = SoruEngine.SkillKey or "Z"
        local skillKeyCode = Enum.KeyCode[skillKeyName]

        if skillKeyCode then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, skillKeyCode, false, game)
                task.wait(0.06)
                VirtualInputManager:SendKeyEvent(false, skillKeyCode, false, game)
            end)
        end
    end)
end

function SoruEngine.bindSkillCombo(char)
    if SoruEngine.AnimConn then
        pcall(function() SoruEngine.AnimConn:Disconnect() end)
        SoruEngine.AnimConn = nil
    end
    if not char then return end

    local hum = char:WaitForChild("Humanoid", 4) or char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    SoruEngine.AnimConn = hum.AnimationPlayed:Connect(function(track)
        if isFlashstepAnim(track) then
            if SoruEngine.SkillComboEnabled then
                executeSkillCombo()
            end
        end
    end)
end

function SoruEngine.setSkillCombo(state)
    SoruEngine.SkillComboEnabled = (state == true)
    local char = LocalPlayer.Character
    if char then
        SoruEngine.bindSkillCombo(char)
    end
end

local function spawnFlashstepSmoke(cf)
    pcall(function()
        local part = Instance.new("Part")
        part.Name = "SoruSmokeEmitterPart"
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 1
        part.Size = Vector3.new(1, 1, 1)
        part.CFrame = cf
        part.Parent = Workspace

        local pe = Instance.new("ParticleEmitter")
        pe.Name = "SmokeEffect"
        pe.Texture = "rbxassetid://258129598"
        pe.Rate = 0
        pe.Speed = NumberRange.new(6, 14)
        pe.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 2),
            NumberSequenceKeypoint.new(0.5, 4.5),
            NumberSequenceKeypoint.new(1, 6.5)
        })
        pe.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.25),
            NumberSequenceKeypoint.new(0.7, 0.65),
            NumberSequenceKeypoint.new(1, 1)
        })
        pe.Lifetime = NumberRange.new(0.35, 0.6)
        pe.Color = ColorSequence.new(Color3.fromRGB(230, 230, 240))
        pe.SpreadAngle = Vector2.new(180, 180)
        pe.Drag = 3
        pe.Parent = part
        pe:Emit(30)

        Debris:AddItem(part, 1)
    end)
end

-- --- Authentic Native Blox Fruits Soru Execution ---
function SoruEngine.executeSoru()
    local now = os.clock()
    if not SoruEngine.InfiniteEnabled and (now - SoruEngine.LastUseTimestamp < 1.0) then
        return false
    end
    SoruEngine.LastUseTimestamp = now
    SoruEngine.IsCoolingDown = true

    local myChar = LocalPlayer.Character
    if not myChar then return false end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    local hum = myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not hum or hum.Health <= 0 then return false end

    local startCF = myHRP.CFrame
    local targetPos = nil

    -- 1. Soru Aimbot target resolution
    if SoruEngine.AimbotEnabled or _G.currentSilentAimTarget then
        local _, targetHRP = getAimbotTarget()
        if targetHRP then
            targetPos = targetHRP.Position + Vector3.new(0, hum.HipHeight or 2, 0)
        end
    end

    -- 2. Mouse / Viewport Raycast fallback
    if not targetPos then
        local mouse = LocalPlayer:GetMouse()
        if mouse and mouse.Hit then
            local dist = (mouse.Hit.Position - myHRP.Position).Magnitude
            if dist > 350 then
                targetPos = myHRP.Position + (mouse.Hit.Position - myHRP.Position).Unit * 200
            else
                targetPos = mouse.Hit.Position + Vector3.new(0, hum.HipHeight or 2, 0)
            end
        else
            targetPos = myHRP.Position + myHRP.CFrame.LookVector * 100
        end
    end

    local lookRot = startCF - startCF.Position
    local endCF = CFrame.new(targetPos) * lookRot
    local randomId = math.random(1, 999999999)
    local serverTime = workspace:GetServerTimeNow()

    -- Spawn Flashstep smoke at origin
    spawnFlashstepSmoke(startCF)

    -- 1. Fire Blox Fruits CommE Remote
    pcall(function()
        local remotes = game.ReplicatedStorage:FindFirstChild("Remotes")
        local commE = remotes and remotes:FindFirstChild("CommE")
        if commE then
            commE:FireServer("Soru", startCF, endCF, serverTime, randomId)
        end
    end)

    -- 2. Teleport Character
    myHRP.CFrame = endCF

    -- Spawn Flashstep smoke at arrival
    spawnFlashstepSmoke(endCF)

    -- 3. Play Official FlashStepRegular Animation (rbxassetid://17555632156)
    pcall(function()
        local animator = hum:FindFirstChildOfClass("Animator") or hum
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://17555632156"
        local track = animator:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action4
        track:Play(0, 1, 1.8)
    end)

    -- 4. Play FlashStep Sound Effect (rbxassetid://616010882)
    pcall(function()
        local sound = Instance.new("Sound")
        sound.Name = "FlashStepSoruSound"
        sound.SoundId = "rbxassetid://616010882"
        sound.Volume = 1.5
        sound.Parent = myHRP
        sound:Play()
        Debris:AddItem(sound, 2)
    end)

    -- 5. Trigger Native Blox Fruits UI Cooldown Animation
    pcall(function()
        local events = game.ReplicatedStorage:FindFirstChild("Events")
        local cdEvent = events and events:FindFirstChild("PlaySkillCooldownAnimation")
        if cdEvent then
            cdEvent:Fire("BoundActionSoru", "none", SoruEngine.InfiniteEnabled and 0.1 or 1)
        end
    end)

    -- 6. Enforce FlashstepCooldown attribute
    if SoruEngine.InfiniteEnabled then
        pcall(function() myChar:SetAttribute("FlashstepCooldown", 1) end)
    end

    task.delay(SoruEngine.InfiniteEnabled and 0.1 or 1.0, function()
        SoruEngine.IsCoolingDown = false
    end)

    return true
end

function SoruEngine.disable()
    SoruEngine.setInfinite(false)
    SoruEngine.setAimbot(false)
    SoruEngine.setSkillCombo(false)
end
SoruEngine.stop = SoruEngine.disable

-- Initial bind
if LocalPlayer and LocalPlayer.Character then
    SoruEngine.bindSkillCombo(LocalPlayer.Character)
end

_G.MonodySoruEngine = SoruEngine
if getgenv then
    pcall(function() getgenv().MonodySoruEngine = SoruEngine end)
end

return SoruEngine
