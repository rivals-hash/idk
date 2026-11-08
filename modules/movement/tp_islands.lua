--[[
    Darling Hub - TP Islands Engine (modules/movement/tp_islands.lua)
    Fast, reliable tween teleportation to all Blox Fruits islands across Sea 1, Sea 2, and Sea 3.
    Features: PartTele anchor tween, noclip during transit, entrance teleporter bypass,
    and real-time speed adjustment.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local TPIslands = {
    TweenSpeed = 350,
    UseTeleporterBypass = true,
    IsTweening = false,
    ActiveTargetName = nil,
    ActiveTargetCF = nil,
    OnStateChanged = nil,
}

local IslandsData = {
    Sea1 = {
        { name = "WindMill",          cf = CFrame.new(979.799, 16.516, 1429.047) },
        { name = "Marine",            cf = CFrame.new(-2566.43, 6.856, 2045.256) },
        { name = "Middle Town",       cf = CFrame.new(-690.331, 15.094, 1582.238) },
        { name = "Jungle",            cf = CFrame.new(-1612.796, 36.852, 149.128) },
        { name = "Pirate Village",    cf = CFrame.new(-1181.309, 4.751, 3803.546) },
        { name = "Desert",            cf = CFrame.new(944.158, 20.92, 4373.3) },
        { name = "Snow Island",       cf = CFrame.new(1347.807, 104.668, -1319.737) },
        { name = "MarineFord",        cf = CFrame.new(-4914.821, 50.964, 4281.028) },
        { name = "Colosseum",         cf = CFrame.new(-11.311, 29.277, 2771.522) },
        { name = "Sky Island 1",      cf = CFrame.new(-483.734, 332.038, 595.327) },
        { name = "Sky Island 2",      cf = CFrame.new(2284.414, 15.152, 875.725) },
        { name = "Sky Island 3",      cf = CFrame.new(-2448.53, 73.016, -3210.631) },
        { name = "Prison",            cf = CFrame.new(4875.33, 5.652, 734.85) },
        { name = "Magma Village",     cf = CFrame.new(-5247.716, 12.884, 8504.969) },
        { name = "Under Water Island",cf = CFrame.new(-2850.201, 7.392, 5354.993) },
        { name = "Fountain City",     cf = CFrame.new(5127.128, 59.501, 4105.446) },
        { name = "Shank Room",        cf = CFrame.new(-1442.166, 29.879, -28.355) },
        { name = "Mob Island",        cf = CFrame.new(-2850.201, 7.392, 5354.993) }
    },
    Sea2 = {
        { name = "The Cafe",          cf = CFrame.new(-380.479, 77.22, 255.826) },
        { name = "Frist Spot",        cf = CFrame.new(-11.311, 29.277, 2771.522) },
        { name = "Dark Area",         cf = CFrame.new(3780.03, 22.652, -3498.586) },
        { name = "Flamingo Mansion",  cf = CFrame.new(-390, 332, 673) },
        { name = "Flamingo Room",     cf = CFrame.new(2285, 15, 905) },
        { name = "Green Zone",        cf = CFrame.new(-2448.53, 73.016, -3210.631) },
        { name = "Factory",           cf = CFrame.new(424.127, 211.162, -427.54) },
        { name = "Colossuim",         cf = CFrame.new(-1503.622, 219.796, 1369.31) },
        { name = "Zombie Island",     cf = CFrame.new(-6509, 83, -133) },
        { name = "Two Snow Mountain", cf = CFrame.new(753.143, 408.236, -5274.615) },
        { name = "Punk Hazard",       cf = CFrame.new(-6127.654, 15.952, -5040.286) },
        { name = "Cursed Ship",       cf = CFrame.new(923, 126, 32852) },
        { name = "Ice Castle",        cf = CFrame.new(5464.31, 28.53, -6248.61) },
        { name = "Forgotten Island",  cf = CFrame.new(-3054.44, 237.21, -10148.12) },
        { name = "Ussop Island",      cf = CFrame.new(4816.862, 8.46, 2863.82) },
        { name = "Mini Sky Island",   cf = CFrame.new(-288.741, 49326.316, -35248.594) }
    },
    Sea3 = {
        { name = "Mansion",           cf = CFrame.new(-12471.17, 374.94, -7551.678) },
        { name = "Port Town",         cf = CFrame.new(-226.751, 20.603, 5538.34) },
        { name = "Great Tree",        cf = CFrame.new(2681.274, 1682.809, -7190.985) },
        { name = "Castle On The Sea", cf = CFrame.new(-5083.26, 314.606, -3175.673) },
        { name = "MiniSky",           cf = CFrame.new(-260.01, 49326.31, -35248.59) },
        { name = "Hydra Island",      cf = CFrame.new(5291.249, 1005.443, 393.762) },
        { name = "Floating Turtle",   cf = CFrame.new(-13274.528, 531.821, -7579.223) },
        { name = "Haunted Castle",    cf = CFrame.new(-9515.372, 164.006, 5786.061) },
        { name = "Ice Cream Island",  cf = CFrame.new(-902.568, 79.932, -10988.848) },
        { name = "Peanut Island",     cf = CFrame.new(-2062.748, 50.474, -10232.568) },
        { name = "Cake Island",       cf = CFrame.new(-1884.775, 19.328, -11666.897) },
        { name = "Cocoa Island",      cf = CFrame.new(87.943, 73.555, -12319.465) },
        { name = "Candy Island",      cf = CFrame.new(-1014.424, 149.111, -14555.963) },
        { name = "Tiki Outpost",      cf = CFrame.new(-16218.683, 9.086, 445.618) },
        { name = "Dragon Dojo",       cf = CFrame.new(5743.319, 1206.91, 936.011) }
    }
}
TPIslands.Data = IslandsData

local currentTween = nil
local noclipConn = nil

function TPIslands.GetCurrentSea()
    local placeId = game.PlaceId
    if placeId == 7449423635 or placeId == 100117331123089 then
        return "Sea3"
    elseif placeId == 4442272183 or placeId == 79091703265657 then
        return "Sea2"
    else
        return "Sea1"
    end
end

function TPIslands.GetIslandNames(sea)
    local list = {}
    local data = IslandsData[sea or TPIslands.GetCurrentSea()]
    if data then
        for _, item in ipairs(data) do
            table.insert(list, item.name)
        end
    end
    return list
end

function TPIslands.GetIslandCFrame(sea, name)
    local data = IslandsData[sea or TPIslands.GetCurrentSea()]
    if data then
        for _, item in ipairs(data) do
            if item.name == name then
                return item.cf
            end
        end
    end
    return nil
end

function TPIslands.CheckNearestTeleporter(targetPos)
    local pos = typeof(targetPos) == "CFrame" and targetPos.Position or targetPos
    local minDist = math.huge
    local nearest = nil
    local placeId = game.PlaceId
    local teleporters = {}

    if placeId == 7449423635 or placeId == 100117331123089 then
        teleporters = {
            ["Floating Turtle"] = Vector3.new(-12462, 375, -7552),
            ["Hydra Island"] = Vector3.new(5657.88, 1013.08, -335.50),
            Mansion = Vector3.new(-12462, 375, -7552),
            Castle = Vector3.new(-5036, 315, -3179),
            ["Temple of Time"] = Vector3.new(28286, 14897, 103)
        }
    elseif placeId == 4442272183 or placeId == 79091703265657 then
        teleporters = {
            ["Swan Mansion"] = Vector3.new(-390, 332, 673),
            ["Swan Room"] = Vector3.new(2285, 15, 905),
            ["Cursed Ship"] = Vector3.new(923, 126, 32852),
            ["Zombie Island"] = Vector3.new(-6509, 83, -133)
        }
    else
        teleporters = {
            Sky3 = Vector3.new(-7894, 5547, -380),
            ["Underwater City"] = Vector3.new(61165.19, 0.19, 1897.38),
            ["Pirate Village"] = Vector3.new(-1242.46, 4.79, 3901.28)
        }
    end

    local char = LocalPlayer and LocalPlayer.Character
    local myHrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    local myPos = myHrp and myHrp.Position or Vector3.zero

    for _, tpPos in pairs(teleporters) do
        local d = (tpPos - pos).Magnitude
        if d < minDist then
            minDist = d
            nearest = tpPos
        end
    end

    if minDist <= (pos - myPos).Magnitude - 150 then
        return nearest
    end
    return nil
end

function TPIslands.StopIslandTween()
    TPIslands.IsTweening = false
    TPIslands.ActiveTargetCF = nil
    TPIslands.ActiveTargetName = nil

    if currentTween then
        pcall(function() currentTween:Cancel() end)
        currentTween = nil
    end

    if noclipConn then
        pcall(function() noclipConn:Disconnect() end)
        noclipConn = nil
    end

    local char = LocalPlayer and LocalPlayer.Character
    if char then
        local pt = char:FindFirstChild("PartTele")
        if pt then pcall(function() pt:Destroy() end) end
        local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    end

    if TPIslands.OnStateChanged then
        pcall(TPIslands.OnStateChanged, false, nil)
    end
end

function TPIslands.UpdateRunningSpeed(newSpeed)
    if newSpeed and type(newSpeed) == "number" then
        TPIslands.TweenSpeed = math.clamp(newSpeed, 100, 600)
    end
    if getgenv then getgenv().IslandTweenSpeed = TPIslands.TweenSpeed end

    if TPIslands.IsTweening and currentTween and TPIslands.ActiveTargetCF then
        local char = LocalPlayer and LocalPlayer.Character
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
        local partTele = char and char:FindFirstChild("PartTele")
        if hrp and partTele then
            pcall(function() currentTween:Cancel() end)
            local dist = (TPIslands.ActiveTargetCF.Position - hrp.Position).Magnitude
            local t = math.max(dist / TPIslands.TweenSpeed, 0.1)
            currentTween = TweenService:Create(partTele, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = TPIslands.ActiveTargetCF })
            currentTween:Play()
            currentTween.Completed:Connect(function(playbackState)
                if playbackState == Enum.PlaybackState.Completed then
                    local name = TPIslands.ActiveTargetName or "Island"
                    TPIslands.StopIslandTween()
                    if TPIslands.OnStateChanged then
                        pcall(TPIslands.OnStateChanged, "arrived", name)
                    end
                end
            end)
        end
    end
end

function TPIslands.StartIslandTween(targetCF, islandName)
    TPIslands.StopIslandTween()
    if not targetCF then return false, "Invalid target CFrame" end

    local char = LocalPlayer and LocalPlayer.Character
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or (type(hum.Health) == "number" and hum.Health <= 0) then
        return false, "Character not ready"
    end

    TPIslands.IsTweening = true
    TPIslands.ActiveTargetCF = targetCF
    TPIslands.ActiveTargetName = islandName or "Island"

    if TPIslands.OnStateChanged then
        pcall(TPIslands.OnStateChanged, true, TPIslands.ActiveTargetName)
    end

    -- Teleporter Bypass
    if TPIslands.UseTeleporterBypass then
        pcall(function()
            local nearest = TPIslands.CheckNearestTeleporter(targetCF)
            if nearest then
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                local commF = remotes and remotes:FindFirstChild("CommF_")
                if commF then
                    commF:InvokeServer("requestEntrance", nearest)
                    task.wait(0.4)
                end
            end
        end)
    end

    if not TPIslands.IsTweening then return false end

    -- Noclip during flight
    noclipConn = RunService.Stepped:Connect(function()
        if not TPIslands.IsTweening then
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            return
        end
        local c = LocalPlayer and LocalPlayer.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)

    -- PartTele anchor
    local partTele = char:FindFirstChild("PartTele")
    if not partTele then
        partTele = Instance.new("Part")
        partTele.Name = "PartTele"
        partTele.Size = Vector3.new(10, 1, 10)
        partTele.Anchored = true
        partTele.Transparency = 1
        partTele.CanCollide = false
        partTele.CFrame = hrp.CFrame
        partTele.Parent = char

        partTele:GetPropertyChangedSignal("CFrame"):Connect(function()
            if TPIslands.IsTweening and char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = partTele.CFrame
                char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            end
        end)
    else
        partTele.CFrame = hrp.CFrame
    end

    local dist = (targetCF.Position - hrp.Position).Magnitude
    local speed = TPIslands.TweenSpeed or 350
    local t = math.max(dist / speed, 0.1)

    currentTween = TweenService:Create(partTele, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = targetCF })
    currentTween:Play()

    currentTween.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            local name = TPIslands.ActiveTargetName or "Island"
            TPIslands.StopIslandTween()
            if TPIslands.OnStateChanged then
                pcall(TPIslands.OnStateChanged, "arrived", name)
            end
        end
    end)

    return true
end

return TPIslands
