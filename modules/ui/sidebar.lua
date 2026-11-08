--[[
    Monody Premium - modules/ui/sidebar.lua
    Right Navigation Sidebar with exact visual alignment to navigation_panel.png:
    - Glowing purple active tab capsule
    - Smooth ScrollingFrame supporting infinite future tabs
    - Window controls (Minimize, Close)
    - Clean icons, Gotham typography, and chevron indicators
]]

local Sidebar = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Sidebar.create(parentGui, options)
    options = options or {}
    local onTabSelected = options.onTabSelected or function() end
    local onMinimize = options.onMinimize or function() end
    local onClose = options.onClose or function() end
    local Utils = options.Utils
    local AssetManager = options.AssetManager

    local sidebarFrame = Instance.new("Frame")
    sidebarFrame.Name = "SidebarFrame"
    sidebarFrame.Size = UDim2.new(0, 154, 0, 400)
    sidebarFrame.Position = UDim2.new(1, -154, 0, 0)
    sidebarFrame.BackgroundColor3 = Color3.fromRGB(16, 11, 20)
    sidebarFrame.BackgroundTransparency = 0.5
    sidebarFrame.BorderSizePixel = 0
    sidebarFrame.Parent = parentGui

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(0, 10)
    sCorner.Parent = sidebarFrame

    -- Subtle translucent glass divider stroke
    local sStroke = Instance.new("UIStroke")
    sStroke.Color = Color3.fromRGB(255, 255, 255)
    sStroke.Transparency = 0.94
    sStroke.Thickness = 1
    sStroke.Parent = sidebarFrame

    -- Background Image with Anime Torii Night Sky
    local bgImg = Instance.new("ImageLabel")
    bgImg.Name = "SidebarBackground"
    bgImg.Size = UDim2.new(1, 0, 1, 0)
    bgImg.BackgroundColor3 = Color3.fromRGB(16, 11, 20)
    bgImg.BackgroundTransparency = 1
    bgImg.ImageTransparency = 0.5
    bgImg.Image = (AssetManager and (AssetManager.get("sidebar_bg_red.png") or AssetManager.get("sidebar_bg_v2.png"))) or ""
    bgImg.ScaleType = Enum.ScaleType.Crop
    bgImg.Parent = sidebarFrame

    if AssetManager and AssetManager.bindImage then
        AssetManager.bindImage(bgImg, "sidebar_bg_red.png", "sidebar_bg_v2.png")
    end

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = bgImg

    -- Top Window Controls: Minimize (-) and Close (X)
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "WindowControls"
    controlsFrame.Size = UDim2.new(0, 56, 0, 24)
    controlsFrame.Position = UDim2.new(1, -62, 0, 5)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.ZIndex = 50
    controlsFrame.Parent = sidebarFrame

    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeButton"
    minBtn.Size = UDim2.new(0, 24, 0, 20)
    minBtn.Position = UDim2.new(0, 0, 0, 2)
    minBtn.BackgroundColor3 = Color3.fromRGB(30, 22, 44)
    minBtn.BackgroundTransparency = 1
    minBtn.Text = "-"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 14
    minBtn.TextColor3 = Color3.fromRGB(220, 210, 240)
    minBtn.ZIndex = 51
    minBtn.AutoButtonColor = false
    minBtn.Active = true
    minBtn.Parent = controlsFrame

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minBtn

    local minStroke = Instance.new("UIStroke")
    minStroke.Color = Color3.fromRGB(140, 90, 210)
    minStroke.Thickness = 1
    minStroke.Transparency = 1
    minStroke.Parent = minBtn

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 24, 0, 20)
    closeBtn.Position = UDim2.new(1, -24, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(48, 18, 28)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    closeBtn.TextColor3 = Color3.fromRGB(255, 95, 115)
    closeBtn.ZIndex = 51
    closeBtn.AutoButtonColor = false
    closeBtn.Active = true
    closeBtn.Parent = controlsFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    local closeStroke = Instance.new("UIStroke")
    closeStroke.Color = Color3.fromRGB(255, 75, 95)
    closeStroke.Thickness = 1
    closeStroke.Transparency = 1
    closeStroke.Parent = closeBtn

    local function setupIconBtn(btn, stroke, hoverBg, hoverText, normText)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundTransparency = 0.35, BackgroundColor3 = hoverBg, TextColor3 = hoverText }):Play()
            if stroke then
                TweenService:Create(stroke, TweenInfo.new(0.12), { Transparency = 0.2 }):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundTransparency = 1, TextColor3 = normText }):Play()
            if stroke then
                TweenService:Create(stroke, TweenInfo.new(0.12), { Transparency = 1 }):Play()
            end
        end)
    end
    setupIconBtn(minBtn, minStroke, Color3.fromRGB(60, 40, 90), Color3.fromRGB(255, 255, 255), Color3.fromRGB(220, 210, 240))
    setupIconBtn(closeBtn, closeStroke, Color3.fromRGB(90, 25, 45), Color3.fromRGB(255, 140, 160), Color3.fromRGB(255, 95, 115))

    local lastMinTick = 0
    local function handleMin()
        local now = tick()
        if now - lastMinTick < 0.35 then return end
        lastMinTick = now
        pcall(onMinimize)
    end

    local lastCloseTick = 0
    local function handleClose()
        local now = tick()
        if now - lastCloseTick < 0.35 then return end
        lastCloseTick = now
        pcall(onClose)
    end

    minBtn.Activated:Connect(handleMin)
    minBtn.MouseButton1Click:Connect(handleMin)
    closeBtn.Activated:Connect(handleClose)
    closeBtn.MouseButton1Click:Connect(handleClose)

    -- Navigation Tabs List (ScrollingFrame supporting infinite tabs cleanly)
    local tabsListFrame = Instance.new("ScrollingFrame")
    tabsListFrame.Name = "TabsListFrame"
    tabsListFrame.Size = UDim2.new(1, -12, 1, -38)
    tabsListFrame.Position = UDim2.new(0, 6, 0, 32)
    tabsListFrame.BackgroundTransparency = 1
    tabsListFrame.BorderSizePixel = 0
    tabsListFrame.ScrollBarThickness = 4
    tabsListFrame.ScrollBarImageColor3 = Color3.fromRGB(220, 35, 60)
    tabsListFrame.ScrollBarImageTransparency = 0
    tabsListFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
    tabsListFrame.VerticalScrollBarInset = Enum.ScrollBarInset.None
    tabsListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabsListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabsListFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    tabsListFrame.ZIndex = 5
    tabsListFrame.Parent = sidebarFrame

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.Padding = UDim.new(0, 3)
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Parent = tabsListFrame

    -- Tab definition data with exact icons from reference screenshot
    local tabDefinitions = {
        { Id = "Home", Name = "Home", Icon = "rbxassetid://10723407389" },
        { Id = "Aimbot", Name = "Aimbot", Icon = "rbxassetid://134242818164054" },
        { Id = "Combat", Name = "Combat", Icon = "rbxassetid://81872698913435" },
        { Id = "Players", Name = "Players", Icon = "rbxassetid://115398113982385" },
        { Id = "Soru", Name = "Soru", Icon = "rbxassetid://130551565616516" },
        { Id = "Macro", Name = "Macro", Icon = "rbxassetid://80451686744860" },
        { Id = "VFX", Name = "VFX", Icon = "rbxassetid://100033680381365" },
        { Id = "Skins", Name = "Skins", Icon = "rbxassetid://106579555405966" },
    }

    local activeTabId = "Home"
    local tabButtons = {}

    local function refreshTabStates()
        for id, btnData in pairs(tabButtons) do
            local isActive = (id == activeTabId)

            if isActive then
                -- Active Tab: Luminous Crimson Red Capsule with white text/icon (no border)
                TweenService:Create(btnData.Button, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(205, 30, 55),
                    BackgroundTransparency = 0.1
                }):Play()
                btnData.Label.Font = Enum.Font.GothamBold
                TweenService:Create(btnData.Label, TweenInfo.new(0.15), {
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextTransparency = 0
                }):Play()
                TweenService:Create(btnData.Icon, TweenInfo.new(0.15), {
                    ImageColor3 = Color3.fromRGB(255, 255, 255),
                    ImageTransparency = 0
                }):Play()
                TweenService:Create(btnData.Chevron, TweenInfo.new(0.15), {
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextTransparency = 0
                }):Play()
            else
                -- Inactive Tab: Transparent sleek background with soft text and icon
                TweenService:Create(btnData.Button, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(20, 14, 18),
                    BackgroundTransparency = 1
                }):Play()
                btnData.Label.Font = Enum.Font.GothamMedium
                TweenService:Create(btnData.Label, TweenInfo.new(0.15), {
                    TextColor3 = Color3.fromRGB(205, 195, 205),
                    TextTransparency = 0
                }):Play()
                TweenService:Create(btnData.Icon, TweenInfo.new(0.15), {
                    ImageColor3 = Color3.fromRGB(190, 175, 185),
                    ImageTransparency = 0
                }):Play()
                TweenService:Create(btnData.Chevron, TweenInfo.new(0.15), {
                    TextColor3 = Color3.fromRGB(160, 130, 140),
                    TextTransparency = 0
                }):Play()
            end
        end
    end

    -- Create Tab Buttons matching reference
    for i, tabData in ipairs(tabDefinitions) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "Tab_" .. tabData.Id
        tabBtn.Size = UDim2.new(1, -6, 0, 31)
        tabBtn.LayoutOrder = i
        tabBtn.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
        tabBtn.BackgroundTransparency = 1
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = ""
        tabBtn.AutoButtonColor = false
        tabBtn.Active = true
        tabBtn.ZIndex = 6
        tabBtn.Parent = tabsListFrame

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabBtn

        -- Tab Icon on Left
        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Name = "TabIcon"
        tabIcon.Size = UDim2.new(0, 16, 0, 16)
        tabIcon.Position = UDim2.new(0, 10, 0.5, -8)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = tabData.Icon
        tabIcon.ImageColor3 = Color3.fromRGB(180, 170, 210)
        tabIcon.ImageTransparency = 0
        tabIcon.Active = false
        tabIcon.ZIndex = 7
        tabIcon.Parent = tabBtn

        -- Tab Label in GothamMedium font
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Name = "TabLabel"
        tabLabel.Size = UDim2.new(1, -56, 1, 0)
        tabLabel.Position = UDim2.new(0, 32, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Font = Enum.Font.GothamMedium
        tabLabel.Text = tabData.Name
        tabLabel.TextColor3 = Color3.fromRGB(205, 195, 205)
        tabLabel.TextTransparency = 0
        tabLabel.TextSize = 12.5
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Active = false
        tabLabel.ZIndex = 7
        tabLabel.Parent = tabBtn

        -- Chevron ">" on Right
        local chevron = Instance.new("TextLabel")
        chevron.Name = "Chevron"
        chevron.Size = UDim2.new(0, 14, 1, 0)
        chevron.Position = UDim2.new(1, -18, 0, 0)
        chevron.BackgroundTransparency = 1
        chevron.Font = Enum.Font.GothamBold
        chevron.Text = ">"
        chevron.TextSize = 11
        chevron.TextColor3 = Color3.fromRGB(160, 130, 140)
        chevron.TextTransparency = 0
        chevron.Active = false
        chevron.ZIndex = 7
        chevron.Parent = tabBtn

        tabButtons[tabData.Id] = {
            Button = tabBtn,
            Label = tabLabel,
            Icon = tabIcon,
            Chevron = chevron
        }

        tabBtn.MouseEnter:Connect(function()
            if activeTabId ~= tabData.Id then
                TweenService:Create(tabBtn, TweenInfo.new(0.12), {
                    BackgroundTransparency = 0.65,
                    BackgroundColor3 = Color3.fromRGB(180, 25, 45)
                }):Play()
            end
        end)

        tabBtn.MouseLeave:Connect(function()
            if activeTabId ~= tabData.Id then
                TweenService:Create(tabBtn, TweenInfo.new(0.12), {
                    BackgroundTransparency = 1,
                    BackgroundColor3 = Color3.fromRGB(20, 14, 18)
                }):Play()
            end
        end)

        local function onActivate()
            activeTabId = tabData.Id
            refreshTabStates()
            pcall(onTabSelected, tabData.Id)
        end
        tabBtn.Activated:Connect(onActivate)
        tabBtn.MouseButton1Click:Connect(onActivate)
    end

    -- Initial state
    refreshTabStates()

    return {
        Frame = sidebarFrame,
        SelectTab = function(tabId)
            if tabButtons[tabId] then
                activeTabId = tabId
                refreshTabStates()
                pcall(onTabSelected, tabId)
            end
        end,
        GetActiveTab = function()
            return activeTabId
        end
    }
end

return Sidebar
