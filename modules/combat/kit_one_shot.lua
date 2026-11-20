--[[
    Darling X - Kit One Shot (Fruits M1 One Shot / Kitsune Void)
    Advanced Fruit Void Fast Attack and remote execution from message(2).txt.
    Supports tap function scanning, upvalue manipulation, combo progression,
    and extreme void coordinates (Vector3.new(9e30, 9e30, 9e30)).
]]

local cloneref = cloneref or function(o) return o end
local function service(name) return cloneref(game:GetService(name)) end

local Players = service("Players")
local Workspace = service("Workspace")
local RunService = service("RunService")
local VirtualUser = service("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local KitOneShot = {
    Enabled = false,
    Delay = 0.05,
    Range = 500,
    LoopRunning = false,
    maxVec = Vector3.new(9e30, 9e30, 9e30),
    AttackPlayers = true,
    AttackMobs = true,
}

_G.DarlingX_KitOneShot = false
_G.FruitsM1Enable = false
_G.FruitsM1DelayValue = 0.05
_G.G_FruitM1 = false
_G.G_VoidFruitM1 = true

-- ==================== Helper: Fruit Detection ====================
function KitOneShot.GetFruit()
    local char = LocalPlayer.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and (tool.ToolTip == "Blox Fruit" or tool:GetAttribute("WeaponType") == "Demon Fruit" or tool:FindFirstChild("LeftClickRemote")) then
                return tool
            end
        end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if backpack and hum then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.ToolTip == "Blox Fruit" or tool:GetAttribute("WeaponType") == "Demon Fruit" or tool:FindFirstChild("LeftClickRemote")) then
                pcall(function() hum:EquipTool(tool) end)
                return tool
            end
        end
    end
    return nil
end

function KitOneShot.IsTrex(tool) return tool ~= nil and tool.Name == "T-Rex-T-Rex" end
function KitOneShot.IsTransformed(tool)
    local rig = tool and tool:FindFirstChild("TransformedRigObject")
    return rig ~= nil and rig.Value ~= nil
end
function KitOneShot.IsDragon(tool) return tool ~= nil and tool.Name == "Dragon-Dragon" end
function KitOneShot.IsBlade(tool) return tool ~= nil and tool.Name == "Blade-Blade" end
function KitOneShot.IsPain(tool) return tool ~= nil and tool.Name == "Pain-Pain" end
function KitOneShot.IsControl(tool) return tool ~= nil and tool.Name == "Control-Control" end
function KitOneShot.IsGas(tool) return tool ~= nil and tool.Name == "Gas-Gas" end

function KitOneShot.MaxCombo(tool)
    if KitOneShot.IsTrex(tool) then return 4 end
    if KitOneShot.IsBlade(tool) then return 2 end
    if KitOneShot.IsPain(tool) then return 4 end
    if KitOneShot.IsControl(tool) then return 4 end
    if KitOneShot.IsGas(tool) then return 5 end
    if KitOneShot.IsDragon(tool) then
        local char = LocalPlayer.Character
        return (char and char:FindFirstChild("DragonHybrid")) and 5 or 3
    end
    return 5
end

function KitOneShot.ScanTapFn(tool, fn)
    if not fn or type(fn) ~= "function" or not debug or not debug.getupvalue then return nil end
    local comboIdx, nextIdx, timerIdx, hasTool
    local stateTable
    for n = 1, 30 do
        local ok2, v = pcall(debug.getupvalue, fn, n)
        if not ok2 then break end
        if v == tool then hasTool = true end
        if type(v) == "number" then
            if not comboIdx and v >= 1 and v <= 5 and v == math.floor(v) then
                comboIdx = n
            elseif not nextIdx and v > 1 then
                nextIdx = n
            end
        elseif type(v) == "thread" and not timerIdx then
            timerIdx = n
        elseif type(v) == "table" and not stateTable then
            local ok3, ability = pcall(function() return v.thisAbility end)
            if ok3 and type(ability) == "number" and type(v.lastUseTime) == "number" then
                stateTable = v
            end
        end
    end
    if stateTable then
        return { tbl = stateTable, fn = fn }
    end
    if hasTool and comboIdx and nextIdx and timerIdx then
        return { fn = fn, combo = comboIdx, next = nextIdx, timer = timerIdx }
    end
    return nil
end

function KitOneShot.GetTapState(tool)
    if not tool or not getconnections then return nil end
    local ok, conns = pcall(getconnections, tool.Activated)
    if not ok or type(conns) ~= "table" then return nil end
    for _, c in ipairs(conns) do
        local fn = c.Function
        if fn then
            local st = KitOneShot.ScanTapFn(tool, fn)
            if st then return st end
            if debug and debug.getupvalue then
                for n = 1, 8 do
                    local ok2, v = pcall(debug.getupvalue, fn, n)
                    if not ok2 then break end
                    if type(v) == "function" then
                        st = KitOneShot.ScanTapFn(tool, v)
                        if st then return st end
                    end
                end
            end
        end
    end
    return nil
end

function KitOneShot.TapInterval(combo, maxCombo)
    if combo and maxCombo and combo >= maxCombo then return 0.5 end
    local char = LocalPlayer.Character
    local cd = 0
    if char then cd = char:GetAttribute("FruitTAPCooldown") or 0 end
    local interval = 0.2 - cd
    if interval < 0.05 then interval = 0.05 end
    return interval
end

-- ==================== Attack Execution Loop ====================
local clickThread = nil
local attackThread = nil

local function startAttackLoop()
    if KitOneShot.LoopRunning then return end
    KitOneShot.LoopRunning = true

    if clickThread then task.cancel(clickThread); clickThread = nil end
    clickThread = task.spawn(function()
        while KitOneShot.Enabled do
            pcall(function() VirtualUser:Button1Down(Vector2.new(1280, 672)) end)
            task.wait(4)
        end
    end)

    if attackThread then task.cancel(attackThread); attackThread = nil end
    attackThread = task.spawn(function()
        local tapTool = nil
        local tapState = nil
        local tapAt = 0
        local fbCombo = 1
        local fbAt = 0

        while KitOneShot.Enabled do
            local fruit = KitOneShot.GetFruit()
            local char = LocalPlayer.Character
            local myHRP = char and char:FindFirstChild("HumanoidRootPart")

            if fruit and myHRP then
                local remote = fruit:FindFirstChild("LeftClickRemote") or fruit:FindFirstChild("ClickRemote")
                if remote then
                    if tapTool ~= fruit or (not tapState and (os.clock() - tapAt) > 1) then
                        tapTool = fruit
                        tapAt = os.clock()
                        tapState = KitOneShot.GetTapState(fruit)
                    end

                    local st = tapState
                    local combo = nil
                    local nextT = nil

                    if st then
                        if st.tbl then
                            if type(st.tbl.thisAbility) == "number" then combo = st.tbl.thisAbility end
                            if type(st.tbl.lastUseTime) == "number" then nextT = st.tbl.lastUseTime end
                        elseif debug and debug.getupvalue then
                            local ok1, c = pcall(debug.getupvalue, st.fn, st.combo)
                            local ok2, n = pcall(debug.getupvalue, st.fn, st.next)
                            if ok1 and type(c) == "number" then combo = c end
                            if ok2 and type(n) == "number" then nextT = n end
                        end
                    end

                    if not combo or not nextT then
                        if os.clock() - fbAt > 1 then fbCombo = 1 end
                        combo = fbCombo or 1
                        nextT = 0
                    end

                    local stun = char:FindFirstChild("Stun")
                    local busy = char:FindFirstChild("Busy")
                    local isDragon = KitOneShot.IsDragon(fruit)
                    local isTrex = KitOneShot.IsTrex(fruit)
                    local isBlade = KitOneShot.IsBlade(fruit)
                    local isGas = KitOneShot.IsGas(fruit)
                    local dragonRig = isDragon and (char:FindFirstChild("EasternBloxfruitsDragon") or char:FindFirstChild("WesternDragonRig"))
                    local blocked = (stun and stun.Value and stun.Value > 0) or (busy and busy.Value) or dragonRig

                    local hit = false
                    local currentTime = os.clock()

                    if combo and nextT and not blocked and (currentTime >= nextT or nextT == 0) then
                        local maxCombo = KitOneShot.MaxCombo(fruit)
                        if maxCombo < 1 then maxCombo = 1 end

                        if st and combo > maxCombo then
                            combo = maxCombo
                            if st.tbl then
                                st.tbl.thisAbility = combo
                            elseif debug and debug.setupvalue then
                                pcall(debug.setupvalue, st.fn, st.combo, combo)
                            end
                        end

                        -- Find target
                        local bestHRP = nil
                        local bestDist = KitOneShot.Range or 500

                        if KitOneShot.AttackPlayers then
                            for _, player in pairs(Players:GetPlayers()) do
                                if player ~= LocalPlayer and player.Character then
                                    local tHRP = player.Character:FindFirstChild("HumanoidRootPart")
                                    local hum = player.Character:FindFirstChild("Humanoid")
                                    if tHRP and hum and hum.Health > 0 then
                                        local dist = (tHRP.Position - myHRP.Position).Magnitude
                                        if dist < bestDist then
                                            bestHRP = tHRP
                                            bestDist = dist
                                        end
                                    end
                                end
                            end
                        end

                        if not bestHRP and KitOneShot.AttackMobs then
                            local enemiesFolder = Workspace:FindFirstChild("Enemies")
                            if enemiesFolder then
                                for _, npc in pairs(enemiesFolder:GetChildren()) do
                                    local tHRP = npc:FindFirstChild("HumanoidRootPart")
                                    local hum = npc:FindFirstChild("Humanoid")
                                    if tHRP and hum and hum.Health > 0 then
                                        local dist = (tHRP.Position - myHRP.Position).Magnitude
                                        if dist < bestDist then
                                            bestHRP = tHRP
                                            bestDist = dist
                                        end
                                    end
                                end
                            end
                        end

                        if bestHRP then
                            local dir = ((bestHRP.Position - myHRP.Position) * Vector3.new(1, 0, 1)).Unit
                            local fireDir = (combo >= maxCombo) and KitOneShot.maxVec or dir

                            if isTrex or isDragon or isBlade or isGas then
                                pcall(function() remote:FireServer(fireDir, combo) end)
                            else
                                pcall(function() remote:FireServer(fireDir, combo, true) end)
                            end

                            if st then
                                local nextCombo = (combo < maxCombo) and (combo + 1) or 1
                                local nextTime = currentTime + KitOneShot.TapInterval(combo, maxCombo)
                                if st.tbl then
                                    st.tbl.thisAbility = nextCombo
                                    st.tbl.lastUseTime = nextTime
                                    if st.tbl.prevTask then pcall(task.cancel, st.tbl.prevTask) end
                                    st.tbl.prevTask = task.delay(1, function()
                                        st.tbl.thisAbility = 1
                                    end)
                                elseif debug and debug.setupvalue then
                                    pcall(debug.setupvalue, st.fn, st.combo, nextCombo)
                                    pcall(debug.setupvalue, st.fn, st.next, nextTime)
                                    local okT, timer = pcall(debug.getupvalue, st.fn, st.timer)
                                    if okT and timer then pcall(task.cancel, timer) end
                                    pcall(debug.setupvalue, st.fn, st.timer, task.delay(1, function()
                                        pcall(debug.setupvalue, st.fn, st.combo, 1)
                                    end))
                                end
                            else
                                fbCombo = (combo < maxCombo) and (combo + 1) or 1
                                fbAt = os.clock()
                            end

                            hit = true
                        end
                    end

                    if hit then
                        task.wait(KitOneShot.Delay or 0.05)
                    else
                        task.wait(0.08)
                    end
                else
                    task.wait(0.1)
                end
            else
                task.wait(0.15)
            end
        end

        KitOneShot.LoopRunning = false
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
    _G.G_FruitM1 = KitOneShot.Enabled
    _G.G_VoidFruitM1 = KitOneShot.Enabled

    if KitOneShot.Enabled then
        local ffaMod = rawget(_G, "DarlingX_FruitFastAttackMod")
        if ffaMod and ffaMod.toggle then
            ffaMod.toggle(true)
        end
        if _G.DarlingX_SyncFruitFastAttackUI then
            pcall(_G.DarlingX_SyncFruitFastAttackUI, true)
        end
        startAttackLoop()
    else
        KitOneShot.LoopRunning = false
        if clickThread then task.cancel(clickThread); clickThread = nil end
        if attackThread then task.cancel(attackThread); attackThread = nil end
    end

    if _G.DarlingX_SyncKitOneShotUI then
        pcall(_G.DarlingX_SyncKitOneShotUI, KitOneShot.Enabled)
    end

    local ew = rawget(_G, "DarlingX_ExtraWidgets")
    if ew and ew.UpdateKitOneShotVisual then
        ew.UpdateKitOneShotVisual(KitOneShot.Enabled)
    end

    return KitOneShot.Enabled
end

function KitOneShot.setDelay(val)
    local n = tonumber(val) or 0.05
    KitOneShot.Delay = n
    _G.FruitsM1DelayValue = n
end

function KitOneShot.isEnabled()
    return KitOneShot.Enabled == true or _G.DarlingX_KitOneShot == true or _G.FruitsM1Enable == true
end

_G.DarlingX_KitOneShotMod = KitOneShot
return KitOneShot
