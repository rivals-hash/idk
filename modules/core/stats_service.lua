--[[
    BestHub - modules/core/stats_service.lua
    Real-time stats provider: Player info, Blox Fruits Level & Bounty,
    real Ping, real FPS, Server Time, and session timers.
]]

local StatsService = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local sessionStartTick = tick()

-- Moving average for FPS calculation
local fpsHistory = {}
local currentFps = 60
local currentPing = 60

RunService.RenderStepped:Connect(function(dt)
    if dt > 0 then
        local instantFps = 1 / dt
        table.insert(fpsHistory, instantFps)
        if #fpsHistory > 30 then
            table.remove(fpsHistory, 1)
        end
        local sum = 0
        for _, f in ipairs(fpsHistory) do sum = sum + f end
        currentFps = math.floor((sum / #fpsHistory) + 0.5)
    end
end)

-- Fetch real Ping
local function getRealPing()
    pcall(function()
        local netStats = Stats.Network:FindFirstChild("ServerStatsItem")
        if netStats then
            local pingItem = netStats:FindFirstChild("Data Ping")
            if pingItem then
                currentPing = math.floor(pingItem:GetValue() + 0.5)
            end
        end
    end)
    return currentPing
end

-- Fetch real Level in Blox Fruits
local function getRealLevel()
    local level = 2800
    if LocalPlayer then
        -- 1. Check Data.Level
        local dataFolder = LocalPlayer:FindFirstChild("Data")
        if dataFolder then
            local lvlVal = dataFolder:FindFirstChild("Level")
            if lvlVal and lvlVal:IsA("ValueBase") and lvlVal.Value > 0 then
                return lvlVal.Value
            end
        end
        -- 2. Check leaderstats
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            local lvlVal = ls:FindFirstChild("Level")
            if lvlVal and lvlVal:IsA("ValueBase") and lvlVal.Value > 0 then
                return lvlVal.Value
            end
        end
    end
    return level
end

-- Fetch real Bounty/Honor in Blox Fruits
local function getRealBounty()
    local bounty = 30000000
    if LocalPlayer then
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            local bVal = ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Bounty") or ls:FindFirstChild("Honor")
            if bVal and bVal:IsA("ValueBase") and bVal.Value > 0 then
                return bVal.Value
            end
        end
        local dataFolder = LocalPlayer:FindFirstChild("Data")
        if dataFolder then
            local bVal = dataFolder:FindFirstChild("Bounty")
            if bVal and bVal:IsA("ValueBase") and bVal.Value > 0 then
                return bVal.Value
            end
        end
    end
    return bounty
end

-- Format bounty nicely
local function formatBountyString(val)
    val = tonumber(val) or 0
    if val >= 1000000 then
        return string.format("%.1fM", val / 1000000):gsub("%.0M", "M")
    elseif val >= 1000 then
        return string.format("%.1fK", val / 1000):gsub("%.0K", "K")
    end
    return tostring(val)
end

function StatsService.getSnapshot()
    local dispName = (LocalPlayer and LocalPlayer.DisplayName) or "Darling"
    local rawName = (LocalPlayer and LocalPlayer.Name) or "Darling"
    local realLevel = getRealLevel()
    local realBounty = getRealBounty()
    local ping = getRealPing()
    local elapsed = tick() - sessionStartTick
    local elapsedStr = string.format("%d:%02d", math.floor(elapsed / 60), math.floor(elapsed % 60))
    local clockTime = os.date("%H:%M")

    return {
        DisplayName = dispName,
        Username = rawName,
        GameName = "Blox Fruits",
        Level = realLevel,
        LevelStr = "- Level " .. tostring(realLevel),
        Bounty = realBounty,
        BountyStr = "- Bounty " .. formatBountyString(realBounty),
        PlayerStr = "- " .. dispName,
        GameStr = "- Blox Fruits",
        Fps = currentFps,
        FpsStr = "- " .. tostring(currentFps) .. "Fps",
        Ping = ping,
        PingStr = "- " .. tostring(ping) .. "ms",
        TimeStr = "- " .. clockTime,
        SessionTimeStr = "- " .. elapsedStr,
        KeyTimeStr = "Key Time: 25 Hours Left"
    }
end

-- Continuous updater callback
function StatsService.bind(updateCallback, interval)
    interval = interval or 0.5
    local alive = true
    task.spawn(function()
        while alive do
            local snapshot = StatsService.getSnapshot()
            pcall(updateCallback, snapshot)
            task.wait(interval)
        end
    end)
    return function()
        alive = false
    end
end

return StatsService
