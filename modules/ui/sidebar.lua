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
    stroke.Color = Color3.fromRGB(195, 125, 255)
    stroke.Thickness = 1.6
    stroke.Transparency = 0.15
    stroke.Parent = bgImg

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

            if activeTabId == "Home" then
                -- When Home is active, navigation_panel.png ALREADY renders the authentic glowing purple pill on Home
                -- and clean tab labels below it. Keep all tabs transparent so zero duplicate text or ghosting occurs!
                TweenService:Create(btnData.Button, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(20, 16, 28),
                    BackgroundTransparency = 1
                }):Play()
                TweenService:Create(btnData.Stroke, TweenInfo.new(0.15), {
                    Transparency = 1
                }):Play()
                TweenService:Create(btnData.Label, TweenInfo.new(0.15), {
                    TextTransparency = 1
                }):Play()
                TweenService:Create(btnData.Icon, TweenInfo.new(0.15), {
                    ImageTransparency = 1
                }):Play()
                TweenService:Create(btnData.Chevron, TweenInfo.new(0.15), {
                    TextTransparency = 1
                }):Play()
            else
                -- Another tab is active (Aimbot, Combat, Players, etc.)
                if isActive then
                    -- Active Tab: Luminous Neon Violet Capsule with crisp white text
                    TweenService:Create(btnData.Button, TweenInfo.new(0.15), {
                        BackgroundColor3 = Color3.fromRGB(140, 65, 230),
                        BackgroundTransparency = 0.05
                    }):Play()
                    TweenService:Create(btnData.Stroke, TweenInfo.new(0.15), {
                        Color = Color3.fromRGB(240, 175, 255),
                        Transparency = 0,
                        Thickness = 1.6
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
                    -- Inactive tabs (including Home): Completely transparent so pristine navigation_panel.png shows through cleanly without any black boxes or ghost text
                    TweenService:Create(btnData.Button, TweenInfo.new(0.15), {
                        BackgroundColor3 = Color3.fromRGB(20, 16, 28),
                        BackgroundTransparency = 1
                    }):Play()
                    TweenService:Create(btnData.Stroke, TweenInfo.new(0.15), {
                        Transparency = 1
                    }):Play()
                    TweenService:Create(btnData.Label, TweenInfo.new(0.15), {
                        TextTransparency = 1
                    }):Play()
                    TweenService:Create(btnData.Icon, TweenInfo.new(0.15), {
                        ImageTransparency = 1
                    }):Play()
                    TweenService:Create(btnData.Chevron, TweenInfo.new(0.15), {
                        TextTransparency = 1
                    }):Play()
                end
            end
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
        tabIcon.ImageTransparency = 1
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
        tabLabel.TextTransparency = 1
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
        chevron.TextTransparency = 1
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
                TweenService:Create(tabBtn, TweenInfo.new(0.12), {
                    BackgroundTransparency = 0.65,
                    BackgroundColor3 = Color3.fromRGB(140, 65, 230)
                }):Play()
                TweenService:Create(tabStroke, TweenInfo.new(0.12), {
                    Transparency = 0.35,
                    Color = Color3.fromRGB(195, 125, 255)
                }):Play()
            end
        end)

        tabBtn.MouseLeave:Connect(function()
            if activeTabId ~= tabData.Id then
                local isInactiveHome = (tabData.Id == "Home" and activeTabId ~= "Home")
                local targetTrans = isInactiveHome and 0.15 or 1
                local targetBg = Color3.fromRGB(20, 16, 28)
                TweenService:Create(tabBtn, TweenInfo.new(0.12), {
                    BackgroundTransparency = targetTrans,
                    BackgroundColor3 = targetBg
                }):Play()
                TweenService:Create(tabStroke, TweenInfo.new(0.12), {
                    Transparency = 1
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
