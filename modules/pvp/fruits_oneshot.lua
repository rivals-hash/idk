--[[
    Darling Hub - Fruits M1 One Shot (Kitsune / Demon Fruits)
    High-potency 9e30 projectile burst for Demon Fruits and Kitsune.
    Unified FloatingWidget integration, zero startup display, zero emojis.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Global state synchronization
_G.FruitsM1Enable = false
_G.FruitsM1DelayValue = 0.15
_G.FruitsOneShotEnable = false

local FruitsOneShot = {
    Enabled = false,
    DelayValue = 0.15,
    Widget = nil,
    LoopRunning = false,
}

local function GetFruitRemote()
    local char = LocalPlayer.Character
    if not char then return nil end

    local fruit = nil

    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and item:GetAttribute("WeaponType") == "Demon Fruit" then
            fruit = item
            break
        end
    end

    if not fruit then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") and item:GetAttribute("WeaponType") == "Demon Fruit" then
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
                        if item:IsA("Tool") and item:GetAttribute("WeaponType") == "Demon Fruit" then
                            fruit = item
                            break
                        end
                    end
                end
            end
        end
    end

    if not fruit then return nil end

    local remote = fruit:FindFirstChild("LeftClickRemote")
        or fruit:FindFirstChild("ClickRemote")
        or fruit:FindFirstChild("M1Remote")

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

FruitsOneShot.GetFruitRemote = GetFruitRemote

local function startAttackLoop()
    if FruitsOneShot.LoopRunning then return end
    FruitsOneShot.LoopRunning = true

    task.spawn(function()
        while _G.FruitsM1Enable or _G.FruitsOneShotEnable or FruitsOneShot.Enabled do
            local delayTime = _G.FruitsM1DelayValue or FruitsOneShot.DelayValue or 0.15
            task.wait(delayTime)

            if not (_G.FruitsM1Enable or _G.FruitsOneShotEnable or FruitsOneShot.Enabled) then
                break
            end

            pcall(function()
                local char = LocalPlayer.Character
                local curHRP = char and char:FindFirstChild("HumanoidRootPart")
                local remote = GetFruitRemote()

                if curHRP and remote then
                    local myPos = curHRP.Position

                    -- NPCs attack
                    local enemiesFolder = Workspace:FindFirstChild("Enemies")
                    if enemiesFolder then
                        for _, npc in ipairs(enemiesFolder:GetChildren()) do
                            if npc.Name ~= "Player" then
                                local targetHRP = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                                local hum = npc:FindFirstChildOfClass("Humanoid")
                                if targetHRP and hum and hum.Health > 0 then
                                    if (targetHRP.Position - myPos).Magnitude < 500 then
                                        pcall(function()
                                            remote:FireServer(Vector3.new(9e30, 9e30, 9e30), 5, false)
                                        end)
                                    end
                                end
                            end
                        end
                    end

                    -- Player attack (with friendly blacklist filter)
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            local isBlacklisted = false
                            if _G.DarlingBlacklistedPlayers and (_G.DarlingBlacklistedPlayers[p.UserId] or _G.DarlingBlacklistedPlayers[p.Name]) then
                                isBlacklisted = true
                            end

                            if not isBlacklisted then
                                local targetHRP = p.Character:FindFirstChild("HumanoidRootPart") or p.Character.PrimaryPart
                                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                                if targetHRP and hum and hum.Health > 0 then
                                    if (targetHRP.Position - myPos).Magnitude < 500 then
                                        pcall(function()
                                            remote:FireServer(Vector3.new(9e30, 9e30, 9e30), 5, false)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        FruitsOneShot.LoopRunning = false
    end)
end

local function getFloatingWidgetMod()
    local hub = _G.DarlingHub or (getgenv and getgenv().DarlingHub)
    if hub and hub.Require then
        local m = hub:Require("modules/pvp/floating_widget.lua")
        if m then return m end
    end
    return nil
end

local function getOrCreateWidget()
    if FruitsOneShot.Widget then return FruitsOneShot.Widget end
    local FW = getFloatingWidgetMod()
    if not FW then return nil end

    FruitsOneShot.Widget = FW.create({
        Id = "FruitsOneShotWidget",
        UIElementKey = "OneShotKitsune",
        Label = "FRUIT 1SHOT",
        Type = "Toggle",
        Visible = false,
        Default = false,
        Position = UDim2.new(0.04, 0, 0.30, 0),
        Callback = function(state)
            FruitsOneShot.toggle(state)
        end
    })
    return FruitsOneShot.Widget
end

function FruitsOneShot.enable()
    if FruitsOneShot.Enabled then return end
    FruitsOneShot.Enabled = true
    _G.FruitsM1Enable = true
    _G.FruitsOneShotEnable = true

    local w = getOrCreateWidget()
    if w then
        w:SetState(true)
        w:SetVisible(true)
    end

    startAttackLoop()

    if _G.DarlingHub and _G.DarlingHub.UIElements and _G.DarlingHub.UIElements["OneShotKitsune"] then
        pcall(function()
            _G.DarlingHub.UIElements["OneShotKitsune"]:Set(true)
        end)
    end
end

function FruitsOneShot.disable()
    if not FruitsOneShot.Enabled and not _G.FruitsM1Enable and not _G.FruitsOneShotEnable then return end
    FruitsOneShot.Enabled = false
    _G.FruitsM1Enable = false
    _G.FruitsOneShotEnable = false

    if FruitsOneShot.Widget then
        FruitsOneShot.Widget:SetState(false)
    end

    if _G.DarlingHub and _G.DarlingHub.UIElements and _G.DarlingHub.UIElements["OneShotKitsune"] then
        pcall(function()
            _G.DarlingHub.UIElements["OneShotKitsune"]:Set(false)
        end)
    end
end

function FruitsOneShot.toggle(state)
    if state == nil then
        state = not (_G.FruitsM1Enable or _G.FruitsOneShotEnable or FruitsOneShot.Enabled)
    end
    if state then
        FruitsOneShot.enable()
    else
        FruitsOneShot.disable()
    end
    return FruitsOneShot.Enabled
end

function FruitsOneShot.setDelay(val)
    local n = tonumber(val)
    if n and n >= 0 then
        FruitsOneShot.DelayValue = n
        _G.FruitsM1DelayValue = n
    end
end

function FruitsOneShot.setFloatingVisible(visible)
    local w = getOrCreateWidget()
    if w and w.SetVisible then
        w:SetVisible(visible == true)
    end
end

function FruitsOneShot.destroy()
    FruitsOneShot.disable()
end

return FruitsOneShot
