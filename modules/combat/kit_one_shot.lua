--[[
    Darling X - Kit One Shot (Fruits M1 One Shot / Kitsune Void)
    Exact tested Blox Fruits attack logic.
    Fires Fruit click remote with extreme coordinates (9e30, 9e30, 9e30) for guaranteed one-shot damage.
    Automatically activates Fruit Fast Attack when enabled.
]]

local cloneref = cloneref or function(o) return o end
local function service(name) return cloneref(game:GetService(name)) end

local Players = service("Players")
local Workspace = service("Workspace")
local RunService = service("RunService")
local LocalPlayer = Players.LocalPlayer

local KitOneShot = {
    Enabled = false,
    Delay = 0.15,
    Range = 500,
    LoopRunning = false,
}

_G.DarlingX_KitOneShot = false
_G.FruitsM1Enable = false
_G.FruitsM1DelayValue = 0.15

-- ==================== Helper: Get Fruit Remote (Exact Logic) ====================
local function isDemonFruit(item)
    if not (item and item:IsA("Tool")) then return false end
    if item:GetAttribute("WeaponType") == "Demon Fruit" then return true end
    if item:FindFirstChild("Fruit") or item:FindFirstChild("DemonFruit") then return true end
    if item.ToolTip == "Blox Fruit" then return true end
    local n = item.Name:lower()
    return n:find("fruit") ~= nil or n:find("kitsune") ~= nil
end

local function GetFruitRemote()
    local char = LocalPlayer.Character
    if not char then return nil end

    local fruit = nil

    -- 1. Check currently equipped fruit
    for _, item in ipairs(char:GetChildren()) do
        if isDemonFruit(item) then
            fruit = item
            break
        end
    end

    -- 2. If not equipped, equip from backpack
    if not fruit then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if isDemonFruit(item) then
                    fruit = item
                    break
                end
            end
            if fruit then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:EquipTool(fruit)
                    task.wait(0.1)
                    for _, item in ipairs(char:GetChildren()) do
                        if isDemonFruit(item) then
                            fruit = item
                            break
                        end
                    end
                end
            end
        end
    end

    if not fruit then return nil end

    -- 3. Find click remote
    local remote = fruit:FindFirstChild("LeftClickRemote")
        or fruit:FindFirstChild("ClickRemote")
        or fruit:FindFirstChild("M1Remote")
        or fruit:FindFirstChild("Remote")

    if not remote then
        for _, v in ipairs(fruit:GetChildren()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("click") then
                remote = v
                break
            end
        end
    end

    return remote
end

-- ==================== Attack Loop ====================
local function startAttackLoop()
    if KitOneShot.LoopRunning then return end
    KitOneShot.LoopRunning = true

    task.spawn(function()
        while true do
            if KitOneShot.Enabled or _G.DarlingX_KitOneShot or _G.FruitsM1Enable then
                local char = LocalPlayer.Character
                local curHRP = char and char:FindFirstChild("HumanoidRootPart")
                local remote = GetFruitRemote()

                if curHRP and remote then
                    local myPos = curHRP.Position
                    local maxRange = KitOneShot.Range or 500

                    local function fireVoidRemote(targetHRP, hum)
                        if targetHRP and hum and hum.Health > 0 then
                            if (targetHRP.Position - myPos).Magnitude < maxRange then
                                pcall(function()
                                    remote:FireServer(Vector3.new(9e30, 9e30, 9e30), 5, false)
                                end)
                            end
                        end
                    end

                    -- Target Enemies
                    local enemiesFolder = Workspace:FindFirstChild("Enemies")
                    if enemiesFolder then
                        for _, npc in ipairs(enemiesFolder:GetChildren()) do
                            if npc.Name ~= "Player" then
                                fireVoidRemote(npc:FindFirstChild("HumanoidRootPart"), npc:FindFirstChildOfClass("Humanoid"))
                            end
                        end
                    end

                    -- Target Characters
                    local charsFolder = Workspace:FindFirstChild("Characters")
                    if charsFolder then
                        for _, c in ipairs(charsFolder:GetChildren()) do
                            if c ~= char then
                                fireVoidRemote(c:FindFirstChild("HumanoidRootPart"), c:FindFirstChildOfClass("Humanoid"))
                            end
                        end
                    end

                    -- Target Players
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character ~= char then
                            fireVoidRemote(p.Character:FindFirstChild("HumanoidRootPart"), p.Character:FindFirstChildOfClass("Humanoid"))
                        end
                    end
                end
            end
            task.wait(_G.FruitsM1DelayValue or KitOneShot.Delay or 0.15)
        end
    end)
end

-- ==================== Public Methods ====================
function KitOneShot.toggle(state)
    if state ~= nil then
        KitOneShot.Enabled = (state == true)
    else
        KitOneShot.Enabled = not KitOneShot.Enabled
    end

    _G.DarlingX_KitOneShot = KitOneShot.Enabled
    _G.FruitsM1Enable = KitOneShot.Enabled

    -- Auto-activate Fruit Fast Attack when One Shot is active
    if KitOneShot.Enabled then
        local ffaMod = rawget(_G, "DarlingX_FruitFastAttackMod")
        if ffaMod and ffaMod.toggle then
            ffaMod.toggle(true)
        end
        if _G.DarlingX_SyncFruitFastAttackUI then
            pcall(_G.DarlingX_SyncFruitFastAttackUI, true)
        end
    end

    -- Sync UI Toggle
    if _G.DarlingX_SyncKitOneShotUI then
        pcall(_G.DarlingX_SyncKitOneShotUI, KitOneShot.Enabled)
    end

    -- Sync Floating Widget
    local ew = rawget(_G, "DarlingX_ExtraWidgets")
    if ew then
        if ew.SetKitOneShotWidgetVisible then
            ew.SetKitOneShotWidgetVisible(KitOneShot.Enabled)
        end
        if ew.UpdateKitOneShotVisual then
            ew.UpdateKitOneShotVisual(KitOneShot.Enabled)
        end
    end

    if KitOneShot.Enabled then
        startAttackLoop()
    end

    return KitOneShot.Enabled
end

function KitOneShot.setDelay(val)
    local n = tonumber(val) or 0.15
    KitOneShot.Delay = n
    _G.FruitsM1DelayValue = n
end

function KitOneShot.isEnabled()
    return KitOneShot.Enabled == true or _G.DarlingX_KitOneShot == true or _G.FruitsM1Enable == true
end

_G.DarlingX_KitOneShotMod = KitOneShot
return KitOneShot
