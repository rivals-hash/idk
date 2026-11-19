--[[
    Darling Hub / Spooky Tracker Module
    Provides back-sticking player lock at 3.5 studs with velocity synchronization.
    Features draggable floating widget and PvP toggle integration.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Tracker = {
    Enabled = false,
    WidgetVisible = false,
    StickEnabled = false,
    Distance = 3.5,
    MaxRange = 650,
}

local trackerGui = nil
local floatBtn = nil
local fStroke = nil
local trackerConn = nil
local trackerLockedChar = nil

local function isPlayerBlacklisted(player)
    if not player then return false end
    if _G.DarlingBlacklistedPlayers then
        if _G.DarlingBlacklistedPlayers[player.UserId] or _G.DarlingBlacklistedPlayers[player.Name] then
            return true
        end
    end
    if _G.PlayerBlacklist then
        if _G.PlayerBlacklist[player.UserId] or _G.PlayerBlacklist[player.Name] then
            return true
        end
    end
    return false
end

local function makeDraggable(targetFrame, dragHandle, onClick)
    dragHandle = dragHandle or targetFrame
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local isDrag = false
    local moveConn = nil
    local endConn = nil

    local function cleanupDrag()
        if moveConn then moveConn:Disconnect(); moveConn = nil end
        if endConn then endConn:Disconnect(); endConn = nil end
        dragging = false
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            cleanupDrag()

            local isLocked = (_G.DarlingX and _G.DarlingX.LockWidgets) == true
            if isLocked then
                if onClick then onClick() end
                return
            end

            dragging = true
            isDrag = false
            dragStart = input.Position
            startPos = targetFrame.Position

            moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                if dragging and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then
                    if dragStart and startPos then
                        local delta = moveInput.Position - dragStart
                        if delta.Magnitude > 6 then
                            isDrag = true
                            targetFrame.Position = UDim2.new(
                                startPos.X.Scale,
                                startPos.X.Offset + delta.X,
                                startPos.Y.Scale,
                                startPos.Y.Offset + delta.Y
                            )
                        end
                    end
                end
            end)

            endConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    if dragging then
                        local wasDrag = isDrag
                        cleanupDrag()
                        if not wasDrag and onClick then
                            onClick()
                        end
                    end
                end
            end)
        end
    end)
end

local function stopTracker()
    Tracker.StickEnabled = false
    trackerLockedChar = nil
    if trackerConn then
        trackerConn:Disconnect()
        trackerConn = nil
    end
    if fStroke then
        fStroke.Color = Color3.fromRGB(48, 48, 55)
    end
    if floatBtn then
        floatBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end

local function startTrackingLoop()
    if trackerConn then trackerConn:Disconnect(); trackerConn = nil end

    trackerConn = RunService.Stepped:Connect(function()
        if not Tracker.StickEnabled then
            stopTracker()
            return
        end

        local char = LocalPlayer.Character
        local myHRP = char and char:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        myHRP.CanCollide = false

        local targetChar = nil
        if trackerLockedChar and trackerLockedChar.Parent and trackerLockedChar:FindFirstChild("HumanoidRootPart") then
            local hum = trackerLockedChar:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                targetChar = trackerLockedChar
            end
        end

        if not targetChar then
            local closest = nil
            local closestDist = Tracker.MaxRange or 650

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if not isPlayerBlacklisted(p) then
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            local d = (p.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude
                            if d < closestDist then
                                closest = p.Character
                                closestDist = d
                            end
                        end
                    end
                end
            end

            trackerLockedChar = closest
            targetChar = closest
        end

        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            local tHrp = targetChar.HumanoidRootPart
            local tHum = targetChar:FindFirstChildOfClass("Humanoid")
            if tHum and tHum.Health > 0 and (myHRP.Position - tHrp.Position).Magnitude <= 700 then
                local dist = Tracker.Distance or 3.5
                myHRP.CFrame = tHrp.CFrame * CFrame.new(0, 0, dist)
                myHRP.AssemblyLinearVelocity = tHrp.AssemblyLinearVelocity
            else
                trackerLockedChar = nil
            end
        end
    end)
end

function Tracker.CreateWidget()
    if trackerGui then
        trackerGui:Destroy()
        trackerGui = nil
    end

    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    if not playerGui then return end

    local existing = playerGui:FindFirstChild("SpookyTrackerWidget")
    if existing then existing:Destroy() end

    trackerGui = Instance.new("ScreenGui")
    trackerGui.Name = "SpookyTrackerWidget"
    trackerGui.ResetOnSpawn = false
    trackerGui.DisplayOrder = 9999
    trackerGui.IgnoreGuiInset = true
    trackerGui.Parent = playerGui

    floatBtn = Instance.new("TextButton")
    floatBtn.Name = "TrackerToggle"
    floatBtn.Size = UDim2.new(0, 76, 0, 32)
    floatBtn.Position = UDim2.new(0, 20, 0.42, 0)
    floatBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    floatBtn.BackgroundTransparency = 0.15
    floatBtn.Text = "TRACKER"
    floatBtn.TextSize = 11
    floatBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.Active = true
    floatBtn.ZIndex = 100
    floatBtn.Parent = trackerGui

    Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0, 8)

    fStroke = Instance.new("UIStroke")
    fStroke.Color = Color3.fromRGB(48, 48, 55)
    fStroke.Thickness = 1.5
    fStroke.Parent = floatBtn

    makeDraggable(floatBtn, floatBtn, function()
        Tracker.StickEnabled = not Tracker.StickEnabled
        if fStroke then
            fStroke.Color = Tracker.StickEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(48, 48, 55)
        end
        if floatBtn then
            floatBtn.TextColor3 = Tracker.StickEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
        end

        if Tracker.StickEnabled then
            startTrackingLoop()
        else
            stopTracker()
        end
    end)
end

function Tracker.RemoveWidget()
    stopTracker()
    if trackerGui then
        trackerGui:Destroy()
        trackerGui = nil
        floatBtn = nil
        fStroke = nil
    end
end

function Tracker.SetEnabled(state)
    Tracker.Enabled = (state == true)
    if Tracker.Enabled then
        Tracker.CreateWidget()
    else
        Tracker.RemoveWidget()
    end
end

_G.DarlingX_Tracker = Tracker
return Tracker
