local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local SaishiOneShot = {}
SaishiOneShot.Enabled = false

local screenGui = nil
local frame = nil
local button = nil
local keyConn = nil
local debounce = false

local function TeleportAbove()
    local char = LocalPlayer.Character
    if not char then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local targetCFrame = myRoot.CFrame + Vector3.new(9e909, 9e909, 9e909)
    pcall(function()
        myRoot.CFrame = targetCFrame
        myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end)
end

local function ExecuteAction()
    for i = 5, 20 do
        TeleportAbove()
        task.wait(0)
    end
end

function SaishiOneShot.Execute(skipWait)
    if debounce then return end
    debounce = true

    if button then
        button.Text = "WAIT..."
        button.TextColor3 = Color3.fromRGB(255, 60, 60)
    end

    task.spawn(function()
        if not skipWait then
            task.wait(0.6)
        end
        ExecuteAction()

        task.delay(0.1, function()
            if button then
                button.Text = "SAISHI"
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
            debounce = false
        end)
    end)
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

function SaishiOneShot.CreateUI()
    if screenGui then
        screenGui:Destroy()
        screenGui = nil
    end

    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    if not playerGui then return end

    local existing = playerGui:FindFirstChild("SaishiTeleportUI")
    if existing then existing:Destroy() end

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SaishiTeleportUI"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 100
    screenGui.Parent = playerGui

    frame = Instance.new("Frame")
    frame.Name = "SaishiFrame"
    frame.Size = UDim2.new(0, 56, 0, 56)
    frame.Position = UDim2.new(0.85, -56, 0.65, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.ZIndex = 50
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(180, 100, 255)
    stroke.Thickness = 1.2
    stroke.Transparency = 0.4
    stroke.Parent = frame

    button = Instance.new("TextButton")
    button.Name = "ExecuteButton"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = "SAISHI"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 11
    button.Font = Enum.Font.GothamBold
    button.Active = true
    button.ZIndex = 51
    button.Parent = frame

    makeDraggable(frame, button, function()
        SaishiOneShot.Execute()
    end)
end

function SaishiOneShot.RemoveUI()
    if screenGui then
        screenGui:Destroy()
        screenGui = nil
        frame = nil
        button = nil
    end
end

function SaishiOneShot.SetEnabled(state)
    SaishiOneShot.Enabled = state == true

    if keyConn then
        keyConn:Disconnect()
        keyConn = nil
    end

    if SaishiOneShot.Enabled then
        SaishiOneShot.CreateUI()

        keyConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and (input.KeyCode == Enum.KeyCode.Z or input.KeyCode == Enum.KeyCode.F) then
                SaishiOneShot.Execute()
            end
        end)
    else
        SaishiOneShot.RemoveUI()
    end
end

return SaishiOneShot
