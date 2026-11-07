--[[
    BestHub - modules/core/stats_service.lua
    Real-time stats provider: Player info, Blox Fruits Level & Bounty,
    real Ping, real FPS, Server Time, and session timers.
    Dynamically displays "???" when game data or stats are not found.
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

-- Detect Game Name
local cachedGameName = nil
local function getDetectedGameName()
    if cachedGameName and cachedGameName ~= "???" then return cachedGameName end

    -- Check Blox Fruits Place & Game IDs
    local placeId = game.PlaceId
    local gameId = game.GameId
    if gameId == 994732206 or placeId == 2753915549 or placeId == 4442272183 or placeId == 7449423635 then
        cachedGameName = "Blox Fruits"
        return cachedGameName
    end

    -- Query MarketplaceService for Place Name
    if placeId and placeId > 0 then
        local ok, info = pcall(function()
            return MarketplaceService:GetProductInfo(placeId)
        end)
        if ok and info and type(info.Name) == "string" and #info.Name > 0 then
            local cleanName = info.Name:gsub("%[.-%]", ""):gsub("%(.-%)", ""):match("^%s*(.-)%s*$")
            if cleanName and #cleanName > 0 then
                cachedGameName = cleanName:sub(1, 15)
            else
                cachedGameName = info.Name:sub(1, 15)
            end
            return cachedGameName
        end
    end

    return "???"
end

-- Fetch real Level in Blox Fruits / RPG
local function getRealLevel()
    if not LocalPlayer then return nil end

    -- 1. Check Data.Level (Blox Fruits primary storage)
    local dataFolder = LocalPlayer:FindFirstChild("Data")
    if dataFolder then
        local lvlVal = dataFolder:FindFirstChild("Level")
        if lvlVal and lvlVal.Value and tonumber(lvlVal.Value) and tonumber(lvlVal.Value) > 0 then
            return tonumber(lvlVal.Value)
        end
    end

    -- 2. Check leaderstats
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, child in ipairs(ls:GetChildren()) do
            local nameLower = child.Name:lower()
            if (nameLower:find("level") or nameLower:find("lvl")) and child.Value and tonumber(child.Value) and tonumber(child.Value) > 0 then
                return tonumber(child.Value)
            end
        end
    end

    -- 3. Check PlayerGui HUD in Blox Fruits
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    if pgui then
        local mainGui = pgui:FindFirstChild("Main")
        if mainGui then
            local lvlObj = mainGui:FindFirstChild("Level", true)
            if lvlObj and lvlObj:IsA("TextLabel") and lvlObj.Text then
                local num = lvlObj.Text:match("%d+")
                if num and tonumber(num) and tonumber(num) > 0 then
                    return tonumber(num)
                end
            end
        end
    end

    return nil
end

-- Fetch real Bounty/Honor in Blox Fruits
local function getRealBounty()
    if not LocalPlayer then return nil end

    -- 1. Check leaderstats
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, child in ipairs(ls:GetChildren()) do
            local nameLower = child.Name:lower()
            if (nameLower:find("bounty") or nameLower:find("honor")) and child.Value and tonumber(child.Value) and tonumber(child.Value) > 0 then
                return tonumber(child.Value)
            end
        end
    end

    -- 2. Check Data folder
    local dataFolder = LocalPlayer:FindFirstChild("Data")
    if dataFolder then
        local bVal = dataFolder:FindFirstChild("Bounty") or dataFolder:FindFirstChild("Honor")
        if bVal and bVal.Value and tonumber(bVal.Value) and tonumber(bVal.Value) > 0 then
            return tonumber(bVal.Value)
        end
    end

    return nil
end

-- Format bounty nicely (e.g. 30M, 2.5M, 500K)
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
    local dispName = nil
    if LocalPlayer then
        if LocalPlayer.DisplayName and #LocalPlayer.DisplayName > 0 then
            dispName = LocalPlayer.DisplayName
        elseif LocalPlayer.Name and #LocalPlayer.Name > 0 then
            dispName = LocalPlayer.Name
        end
    end

    local realLevel = getRealLevel()
    local realBounty = getRealBounty()
    local gameName = getDetectedGameName()
    local ping = getRealPing()
    local elapsed = tick() - sessionStartTick
    local elapsedStr = string.format("%d:%02d", math.floor(elapsed / 60), math.floor(elapsed % 60))
    local clockTime = os.date("%H:%M")

    return {
        DisplayName = dispName or "???",
        PlayerStr = dispName and ("- " .. dispName) or "- ???",
        GameName = gameName,
        GameStr = (gameName and gameName ~= "???") and ("- " .. gameName) or "- ???",
        Level = realLevel,
        LevelStr = realLevel and ("- Level " .. tostring(realLevel)) or "- ???",
        Bounty = realBounty,
        BountyStr = realBounty and ("- Bounty " .. formatBountyString(realBounty)) or "- ???",
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
