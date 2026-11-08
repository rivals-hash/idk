--[[
    Darling Hub - Dungeon Engine
    Exact logic from Sam Premium Blox Fruits Dungeon script.
    Features: Auto Dungeon, room auto-pass via ExitTeleporter touch,
    Gas Knight and Kitsune boss prioritization, hover teleport above enemies,
    weapon auto-equip, Buso Haki auto-buff, and Auto Race V4.
]]--

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer and LocalPlayer.Character
local HumanoidRootPart = Character and (Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart)

local function getCharacter()
    if not Character or not Character.Parent then
        Character = LocalPlayer and LocalPlayer.Character
    end
    return Character
end

local function getHrp()
    local char = getCharacter()
    if not HumanoidRootPart or not HumanoidRootPart.Parent or (char and HumanoidRootPart.Parent ~= char) then
        HumanoidRootPart = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char.PrimaryPart)
    end
    return HumanoidRootPart
end

local DungeonEngine = {
    Active = false,
    AutoV4 = false,
    AttackHeight = 40,
    SelectedWeapon = "Sword",
    WeaponOptions = { "Sword", "Melee", "Blox Fruit" },
    CurrentTarget = nil,
    LastTarget = nil,
    JustDied = false,
    Status = "Idle",
}

local enemiesFolder = Workspace:FindFirstChild("Enemies") or Workspace

local function getRegisterAttack()
    local repMods = ReplicatedStorage:FindFirstChild("Modules")
    local net = repMods and repMods:FindFirstChild("Net")
    return (net and net:FindFirstChild("RE/RegisterAttack")) or ReplicatedStorage:FindFirstChild("RE/RegisterAttack")
end

local function getRegisterHit()
    local repMods = ReplicatedStorage:FindFirstChild("Modules")
    local net = repMods and repMods:FindFirstChild("Net")
    return (net and net:FindFirstChild("RE/RegisterHit")) or ReplicatedStorage:FindFirstChild("RE/RegisterHit")
end

local function getCommF()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    return (remotes and remotes:FindFirstChild("CommF_")) or ReplicatedStorage:FindFirstChild("CommF_")
end

if LocalPlayer then
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        HumanoidRootPart = newCharacter:FindFirstChild("HumanoidRootPart") or newCharacter.PrimaryPart
        DungeonEngine.JustDied = true
        task.spawn(function()
            if not HumanoidRootPart then
                HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart", 3)
            end
        end)
    end)
end

local function GetWeaponInBackpack(weaponName)
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if string.find(string.lower(tool.Name), string.lower(weaponName)) or tool.ToolTip == weaponName then
                return tool
            end
        end
    end
    return nil
end

local function EquipSelectedWeapon()
    if not Character or not DungeonEngine.Active then return end
    local currentTool = Character:FindFirstChildOfClass("Tool")
    if currentTool and (string.find(string.lower(currentTool.Name), string.lower(DungeonEngine.SelectedWeapon)) or currentTool.ToolTip == DungeonEngine.SelectedWeapon) then
        return
    end
    local toolToEquip = GetWeaponInBackpack(DungeonEngine.SelectedWeapon)
    if toolToEquip then
        local humanoid = Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:EquipTool(toolToEquip) end
    end
end

local function ForceActivateHaki()
    if not Character or not DungeonEngine.Active then return end
    if not Character:FindFirstChild("HasBuso") then
        pcall(function()
            local commF = getCommF()
            if commF then commF:InvokeServer("Buso") end
        end)
    end
end

-- Auto V4 Background Thread
task.spawn(function()
    while true do
        task.wait(DungeonEngine.Active and 0.5 or 2.0)
        if DungeonEngine.AutoV4 and DungeonEngine.Active and Character then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
            end)
        end
    end
end)

local function StartAutoBuffs()
    task.spawn(function()
        while DungeonEngine.Active do
            EquipSelectedWeapon()
            task.wait(0.3)
        end
    end)
    task.spawn(function()
        while DungeonEngine.Active do
            ForceActivateHaki()
            task.wait(0.1)
        end
    end)
end

local function GetClosestEnemy()
    if DungeonEngine.JustDied then return nil end

    local closestEnemy = nil
    local shortestDistance = math.huge
    local currentCharacter = LocalPlayer.Character

    if not currentCharacter or not currentCharacter:FindFirstChild("HumanoidRootPart") then return nil end

    local myPos = currentCharacter.HumanoidRootPart.Position
    local sourceFolder = Workspace:FindFirstChild("Enemies") or enemiesFolder

    if sourceFolder then
        local jefeVivo = false
        for _, obj in ipairs(sourceFolder:GetChildren()) do
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "gas knight") or string.find(nameLower, "kitsune") then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    jefeVivo = true
                    break
                end
            end
        end

        local children = sourceFolder:GetChildren()
        local primaryCandidates = {}
        local backupCandidates = {}

        for i = 1, #children do
            local object = children[i]

            local canCheck = not (object.Name == "PropHitboxPlaceholder" and not jefeVivo)

            if canCheck and object:IsA("Model") and object ~= currentCharacter and object.Name ~= "Blank Buddy" and object.Name ~= "Sombra" and object.Name ~= "Shadow" then
                local humanoid = object:FindFirstChildOfClass("Humanoid")
                local root = object:FindFirstChild("HumanoidRootPart") or object:FindFirstChild("Head")

                if humanoid and humanoid.Health > 0 and root and object.Parent then
                    local distance = (root.Position - myPos).Magnitude

                    local nameLower = string.lower(object.Name)
                    if string.find(nameLower, "gas knight") or string.find(nameLower, "kitsune") then
                        distance = distance - 1000
                    end

                    if object ~= DungeonEngine.LastTarget then
                        table.insert(primaryCandidates, {model = object, dist = distance})
                    else
                        table.insert(backupCandidates, {model = object, dist = distance})
                    end
                end
            end
        end

        local targetList = #primaryCandidates > 0 and primaryCandidates or backupCandidates
        for i = 1, #targetList do
            local candidate = targetList[i]
            if candidate.dist < shortestDistance then
                shortestDistance = candidate.dist
                closestEnemy = candidate.model
            end
        end
    end
    return closestEnemy
end

local function TeleportToEnemy(enemy)
    local hrp = getHrp()
    local char = getCharacter()
    if not enemy or not enemy.Parent or not hrp then return false end
    local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Head")
    if not enemyRoot then return false end

    local success = pcall(function()
        hrp.CFrame = enemyRoot.CFrame * CFrame.new(0, DungeonEngine.AttackHeight, 0)
    end)

    if not success then
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {char or Character, enemy}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        local raycastResult = Workspace:Raycast(enemyRoot.Position, Vector3.new(0, -100, 0), raycastParams)
        if raycastResult then
            hrp.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
        end
    end
    return true
end

local function AttackEnemy(enemy)
    if not enemy or not enemy.Parent then return end
    local enemyHead = enemy:FindFirstChild("Head")
    local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")
    if not enemyHead or not enemyHumanoid then return end

    local char = getCharacter()
    local tool = char and char:FindFirstChildOfClass("Tool")
    if tool then tool:Activate() end

    pcall(function()
        local ra = getRegisterAttack()
        local rh = getRegisterHit()
        if ra and rh then
            ra:FireServer(0)
            rh:FireServer(enemyHead, {{enemy, enemyHead}})
        end
    end)
end

local function GetCurrentRoomIndex(rooms)
    local hrp = getHrp()
    if not hrp then return 1 end
    local myPos = hrp.Position
    local currentRoomIdx = 1
    local minDistanceToRoomCenter = math.huge

    for i, room in ipairs(rooms) do
        local roomPart = room:FindFirstChildOfClass("Part") or room:FindFirstChildOfClass("MeshPart") or room:FindFirstChild("Floor")
        if roomPart then
            local dist = (roomPart.Position - myPos).Magnitude
            if dist < minDistanceToRoomCenter then
                minDistanceToRoomCenter = dist
                currentRoomIdx = i
            end
        end
    end
    return currentRoomIdx
end

local function AutoPassRoom()
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then return false end
    local dungeonFolder = mapFolder:FindFirstChild("Dungeon")
    if not dungeonFolder then return false end

    local rooms = dungeonFolder:GetChildren()
    if #rooms == 0 then return false end

    table.sort(rooms, function(a, b)
        local numA = tonumber(string.match(a.Name, "%d+")) or 0
        local numB = tonumber(string.match(b.Name, "%d+")) or 0
        return numA < numB
    end)

    local currentRoomIdx = GetCurrentRoomIndex(rooms)
    local activeRoom = rooms[currentRoomIdx]

    if activeRoom then
        local teleporter = activeRoom:FindFirstChild("ExitTeleporter")
        if teleporter then
            local rootPart = teleporter:FindFirstChild("Root")
            local hrp = getHrp()
            if rootPart and rootPart:IsA("BasePart") and hrp then
                local touchTransmitter = rootPart:FindFirstChildOfClass("TouchTransmitter")
                if touchTransmitter then
                    hrp.CFrame = rootPart.CFrame
                    task.wait(0.12)
                    if firetouchinterest then
                        firetouchinterest(hrp, rootPart, 0)
                        task.wait(0.1)
                        firetouchinterest(hrp, rootPart, 1)
                    end
                    if DungeonEngine.JustDied then DungeonEngine.JustDied = false end
                    return true
                end
            end
        end
    end
    return false
end
DungeonEngine.AutoPassRoom = AutoPassRoom

local function RotateTargets()
    while DungeonEngine.Active do
        DungeonEngine.CurrentTarget = GetClosestEnemy()

        if DungeonEngine.CurrentTarget and not DungeonEngine.JustDied then
            DungeonEngine.LastTarget = DungeonEngine.CurrentTarget
            local enemyHumanoid = DungeonEngine.CurrentTarget:FindFirstChildOfClass("Humanoid")
            local timer = 0

            DungeonEngine.Status = "Attacking: " .. tostring(DungeonEngine.CurrentTarget.Name)
            while DungeonEngine.Active and DungeonEngine.CurrentTarget and DungeonEngine.CurrentTarget.Parent and enemyHumanoid and enemyHumanoid.Health > 0 and timer < 0.3 and not DungeonEngine.JustDied do
                TeleportToEnemy(DungeonEngine.CurrentTarget)
                AttackEnemy(DungeonEngine.CurrentTarget)
                task.wait()
                timer = timer + 0.01
            end
        else
            if DungeonEngine.JustDied then
                DungeonEngine.Status = "Respawned - Passing room..."
                local passed = false
                local attempts = 0
                while DungeonEngine.Active and DungeonEngine.JustDied and attempts < 10 do
                    passed = AutoPassRoom()
                    if passed then
                        DungeonEngine.JustDied = false
                        break
                    end
                    attempts = attempts + 1
                    task.wait(0.5)
                end
                if attempts >= 10 then DungeonEngine.JustDied = false end
            else
                DungeonEngine.Status = "Searching enemies / Passing room..."
                task.wait(1.0)
                local passed = AutoPassRoom()
                if not passed then task.wait(0.5) end
            end
        end
    end
    DungeonEngine.Status = "Idle"
end

function DungeonEngine.start()
    if DungeonEngine.Active then return end
    DungeonEngine.Active = true
    DungeonEngine.JustDied = false
    StartAutoBuffs()
    task.spawn(RotateTargets)
end

function DungeonEngine.stop()
    DungeonEngine.Active = false
    DungeonEngine.CurrentTarget = nil
    DungeonEngine.LastTarget = nil
    DungeonEngine.JustDied = false
    DungeonEngine.Status = "Idle"
end

function DungeonEngine.toggle(state)
    if state == nil then state = not DungeonEngine.Active end
    if state then
        DungeonEngine.start()
    else
        DungeonEngine.stop()
    end
    return DungeonEngine.Active
end

function DungeonEngine.setWeapon(weaponName)
    DungeonEngine.SelectedWeapon = weaponName or "Sword"
end

function DungeonEngine.setHeight(h)
    DungeonEngine.AttackHeight = tonumber(h) or 40
end

function DungeonEngine.setAutoV4(state)
    DungeonEngine.AutoV4 = (state == true)
end

return DungeonEngine
