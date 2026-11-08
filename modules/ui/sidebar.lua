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
    sidebarFrame.Size = UDim2.new(0, 154, 0, 316)
    sidebarFrame.Position = UDim2.new(1, -154, 0, 0)
    sidebarFrame.BackgroundTransparency = 1
    sidebarFrame.Parent = parentGui

    -- Background Image with Torii Gate, Purple Moon & Cherry Blossoms
    local bgImg = Instance.new("ImageLabel")
    bgImg.Name = "SidebarBackground"
    bgImg.Size = UDim2.new(1, 0, 1, 0)
    bgImg.BackgroundColor3 = Color3.fromRGB(16, 12, 24)
    bgImg.BackgroundTransparency = 0.05
    bgImg.Image = (AssetManager and AssetManager.get("navigation_panel.png", "rbxassetid://139820186687064")) or "rbxassetid://139820186687064"
    bgImg.ScaleType = Enum.ScaleType.Stretch
    bgImg.Parent = sidebarFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = bgImg

    -- Luminous Purple Neon Rim
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(145, 90, 225)
    stroke.Thickness = 1.2
    stroke.Transparency = 0.35
    stroke.Parent = bgImg

    -- Top Window Controls: Minimize (-) and Close (X)
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "WindowControls"
    controlsFrame.Size = UDim2.new(0, 64, 0, 26)
    controlsFrame.Position = UDim2.new(1, -68, 0, 6)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.ZIndex = 50
    controlsFrame.Parent = sidebarFrame

    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeButton"
    minBtn.Size = UDim2.new(0, 28, 0, 24)
    minBtn.Position = UDim2.new(0, 0, 0, 0)
    minBtn.BackgroundTransparency = 1
    minBtn.Text = "-"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 20
    minBtn.TextColor3 = Color3.fromRGB(220, 220, 235)
    minBtn.ZIndex = 51
    minBtn.AutoButtonColor = false
    minBtn.Active = true
    minBtn.Parent = controlsFrame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 28, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
    closeBtn.ZIndex = 51
    closeBtn.AutoButtonColor = false
    closeBtn.Active = true
    closeBtn.Parent = controlsFrame

    local function setupIconBtn(btn, hoverColor, normColor)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), { TextColor3 = hoverColor }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), { TextColor3 = normColor }):Play()
        end)
    end
    setupIconBtn(minBtn, Color3.fromRGB(255, 255, 255), Color3.fromRGB(220, 220, 235))
    setupIconBtn(closeBtn, Color3.fromRGB(255, 30, 30), Color3.fromRGB(255, 75, 75))

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
    tabsListFrame.Size = UDim2.new(1, -16, 1, -38)
    tabsListFrame.Position = UDim2.new(0, 8, 0, 32)
    tabsListFrame.BackgroundTransparency = 1
    tabsListFrame.BorderSizePixel = 0
    tabsListFrame.ScrollBarThickness = 0
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
            local targetBg = isActive and Color3.fromRGB(115, 55, 185) or Color3.fromRGB(20, 16, 28)
            local targetBgTrans = isActive and 0.12 or 1
            local targetStrokeColor = isActive and Color3.fromRGB(195, 125, 255) or Color3.fromRGB(60, 45, 80)
            local targetStrokeTrans = isActive and 0.25 or 1
            local targetTextColor = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 215, 235)
            local targetIconColor = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 190, 225)
            local targetChevronColor = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 145, 185)

            TweenService:Create(btnData.Button, TweenInfo.new(0.15), {
                BackgroundColor3 = targetBg,
                BackgroundTransparency = targetBgTrans
            }):Play()
            TweenService:Create(btnData.Stroke, TweenInfo.new(0.15), {
                Color = targetStrokeColor,
                Transparency = targetStrokeTrans
            }):Play()
            TweenService:Create(btnData.Label, TweenInfo.new(0.15), {
                TextColor3 = targetTextColor
            }):Play()
            btnData.Label.Font = isActive and Enum.Font.GothamBold or Enum.Font.GothamMedium
            TweenService:Create(btnData.Icon, TweenInfo.new(0.15), {
                ImageColor3 = targetIconColor
            }):Play()
            TweenService:Create(btnData.Chevron, TweenInfo.new(0.15), {
                TextColor3 = targetChevronColor
            }):Play()
        end
    end

    -- Create Tab Buttons matching reference
    for i, tabData in ipairs(tabDefinitions) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "Tab_" .. tabData.Id
        tabBtn.Size = UDim2.new(1, 0, 0, 31)
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

        local tabStroke = Instance.new("UIStroke")
        tabStroke.Color = Color3.fromRGB(195, 125, 255)
        tabStroke.Thickness = 1.2
        tabStroke.Transparency = 1
        tabStroke.Parent = tabBtn

        -- Tab Icon on Left
        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Name = "TabIcon"
        tabIcon.Size = UDim2.new(0, 16, 0, 16)
        tabIcon.Position = UDim2.new(0, 10, 0.5, -8)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = tabData.Icon
        tabIcon.ImageColor3 = Color3.fromRGB(200, 190, 225)
        tabIcon.Active = false
        tabIcon.ZIndex = 7
        tabIcon.Parent = tabBtn

        -- Tab Label in Gotham font
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Name = "TabLabel"
        tabLabel.Size = UDim2.new(1, -56, 1, 0)
        tabLabel.Position = UDim2.new(0, 32, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Font = Enum.Font.GothamMedium
        tabLabel.Text = tabData.Name
        tabLabel.TextColor3 = Color3.fromRGB(220, 215, 235)
        tabLabel.TextSize = 12
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
        chevron.TextColor3 = Color3.fromRGB(160, 145, 185)
        chevron.Active = false
        chevron.ZIndex = 7
        chevron.Parent = tabBtn

        tabButtons[tabData.Id] = {
            Button = tabBtn,
            Stroke = tabStroke,
            Label = tabLabel,
            Icon = tabIcon,
            Chevron = chevron
        }

        tabBtn.MouseEnter:Connect(function()
            if activeTabId ~= tabData.Id then
                TweenService:Create(tabBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.6 }):Play()
                TweenService:Create(tabLabel, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
                TweenService:Create(tabIcon, TweenInfo.new(0.12), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
                TweenService:Create(chevron, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
            end
        end)

        tabBtn.MouseLeave:Connect(function()
            if activeTabId ~= tabData.Id then
                TweenService:Create(tabBtn, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
                TweenService:Create(tabLabel, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(220, 215, 235) }):Play()
                TweenService:Create(tabIcon, TweenInfo.new(0.12), { ImageColor3 = Color3.fromRGB(200, 190, 225) }):Play()
                TweenService:Create(chevron, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(160, 145, 185) }):Play()
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
