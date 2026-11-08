--[[
    BestHub - modules/ui/sidebar.lua
    Reworked modern navigation sidebar:
    - Glowing active tab indicators & slick typography
    - Window control buttons (Minimize, Close)
    - Right quick-action utility strip (Gamepad, Music, Keyboard, Theme, Folder, Settings)
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

    local sidebarFrame = Instance.new("Frame")
    sidebarFrame.Name = "SidebarFrame"
    sidebarFrame.Size = UDim2.new(0, 154, 0, 312)
    sidebarFrame.Position = UDim2.new(1, -154, 0, 0)
    sidebarFrame.BackgroundTransparency = 1
    sidebarFrame.Parent = parentGui

    -- Background Image with smoky texture
    local bgImg = Instance.new("ImageLabel")
    bgImg.Name = "SidebarBackground"
    bgImg.Size = UDim2.new(1, 0, 1, 0)
    bgImg.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    bgImg.BackgroundTransparency = 0.12
    bgImg.Image = (options.AssetManager and options.AssetManager.get("sidebar_bg.png", "rbxassetid://139820186687064")) or "rbxassetid://139820186687064"
    bgImg.ScaleType = Enum.ScaleType.Stretch
    bgImg.Parent = sidebarFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = bgImg

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(65, 65, 80)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = bgImg

    -- Top Window Controls: Minimize (-) and Close (X) with high ZIndex & large touch hitboxes
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "WindowControls"
    controlsFrame.Size = UDim2.new(0, 68, 0, 28)
    controlsFrame.Position = UDim2.new(1, -72, 0, 4)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.ZIndex = 50
    controlsFrame.Parent = sidebarFrame

    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeButton"
    minBtn.Size = UDim2.new(0, 32, 0, 28)
    minBtn.Position = UDim2.new(0, 0, 0, 0)
    minBtn.BackgroundTransparency = 1
    minBtn.Text = "-"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 22
    minBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    minBtn.ZIndex = 51
    minBtn.AutoButtonColor = false
    minBtn.Active = true
    minBtn.Parent = controlsFrame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 32, 0, 28)
    closeBtn.Position = UDim2.new(1, -32, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
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
    setupIconBtn(minBtn, Color3.fromRGB(255, 255, 255), Color3.fromRGB(220, 220, 220))
    setupIconBtn(closeBtn, Color3.fromRGB(255, 40, 40), Color3.fromRGB(255, 80, 80))

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

    -- Left Navigation Tabs List (ScrollingFrame supporting infinite tabs cleanly)
    local tabsListFrame = Instance.new("ScrollingFrame")
    tabsListFrame.Name = "TabsListFrame"
    tabsListFrame.Size = UDim2.new(0, 84, 1, -14)
    tabsListFrame.Position = UDim2.new(0, 6, 0, 7)
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

    -- Tab definition data
    local tabDefinitions = {
        { Id = "Home", Name = "Home", Icon = "rbxthumb://type=Asset&id=98755624629571&w=420&h=420" },
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
            local targetBgTrans = isActive and 0.88 or 1
            local targetStrokeTrans = isActive and 0.35 or 1
            local targetTextColor = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(195, 195, 210)
            local targetIconColor = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 195)

            TweenService:Create(btnData.Button, TweenInfo.new(0.15), {
                BackgroundTransparency = targetBgTrans
            }):Play()
            TweenService:Create(btnData.Stroke, TweenInfo.new(0.15), {
                Transparency = targetStrokeTrans
            }):Play()
            TweenService:Create(btnData.Label, TweenInfo.new(0.15), {
                TextColor3 = targetTextColor
            }):Play()
            TweenService:Create(btnData.Icon, TweenInfo.new(0.15), {
                ImageColor3 = targetIconColor
            }):Play()
        end
    end

    -- Create Tab Buttons
    for i, tabData in ipairs(tabDefinitions) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "Tab_" .. tabData.Id
        tabBtn.Size = UDim2.new(1, 0, 0, 31)
        tabBtn.LayoutOrder = i
        tabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.BackgroundTransparency = 1
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = ""
        tabBtn.AutoButtonColor = false
        tabBtn.Active = true
        tabBtn.ZIndex = 6
        tabBtn.Parent = tabsListFrame

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabBtn

        local tabStroke = Instance.new("UIStroke")
        tabStroke.Color = Color3.fromRGB(255, 255, 255)
        tabStroke.Thickness = 1
        tabStroke.Transparency = 1
        tabStroke.Parent = tabBtn

        -- Tab Icon
        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Name = "TabIcon"
        tabIcon.Size = UDim2.new(0, 16, 0, 16)
        tabIcon.Position = UDim2.new(0, 6, 0.5, -8)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = tabData.Icon
        tabIcon.ImageColor3 = Color3.fromRGB(180, 180, 195)
        tabIcon.Active = false
        tabIcon.ZIndex = 7
        tabIcon.Parent = tabBtn

        -- Tab Label in Gotham font
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Name = "TabLabel"
        tabLabel.Size = UDim2.new(1, -26, 1, 0)
        tabLabel.Position = UDim2.new(0, 26, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Font = Enum.Font.GothamMedium
        tabLabel.Text = tabData.Name
        tabLabel.TextColor3 = Color3.fromRGB(195, 195, 210)
        tabLabel.TextSize = 12
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Active = false
        tabLabel.ZIndex = 7
        tabLabel.Parent = tabBtn

        tabButtons[tabData.Id] = {
            Button = tabBtn,
            Stroke = tabStroke,
            Label = tabLabel,
            Icon = tabIcon
        }

        tabBtn.MouseEnter:Connect(function()
            if activeTabId ~= tabData.Id then
                TweenService:Create(tabBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.94 }):Play()
                TweenService:Create(tabLabel, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
                TweenService:Create(tabIcon, TweenInfo.new(0.12), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
            end
        end)

        tabBtn.MouseLeave:Connect(function()
            if activeTabId ~= tabData.Id then
                TweenService:Create(tabBtn, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
                TweenService:Create(tabLabel, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(195, 195, 210) }):Play()
                TweenService:Create(tabIcon, TweenInfo.new(0.12), { ImageColor3 = Color3.fromRGB(180, 180, 195) }):Play()
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

    -- Right Action Strip (Aligned with reference screenshot)
    local actionStrip = Instance.new("Frame")
    actionStrip.Name = "ActionStrip"
    actionStrip.Size = UDim2.new(0, 32, 1, 0)
    actionStrip.Position = UDim2.new(1, -34, 0, 0)
    actionStrip.BackgroundTransparency = 1
    actionStrip.Parent = sidebarFrame

    -- Action Buttons aligned with tabs (Gamepad at Aimbot, Music at Combat, etc.)
    local actionDefinitions = {
        { Id = "Gamepad", Icon = "rbxassetid://92483947987410", Action = "Mobile Controls HUD", Y = 46 },
        { Id = "Music", Icon = "rbxassetid://113343203848535", Action = "Music Player", Y = 82 },
        { Id = "Keyboard", Icon = "rbxassetid://121474456068237", Action = "Keybinds", Y = 118 },
        { Id = "Palette", Icon = "rbxassetid://86350350950064", Action = "Themes", Y = 154 },
        { Id = "Folder", Icon = "rbxassetid://85299519462846", Action = "Configs", Y = 190 },
        { Id = "Settings", Icon = "rbxassetid://80758916183665", Action = "Settings", Y = 226 }
    }

    for _, act in ipairs(actionDefinitions) do
        local actBtn = Instance.new("ImageButton")
        actBtn.Name = "Action_" .. act.Id
        actBtn.Size = UDim2.new(0, 20, 0, 20)
        actBtn.Position = UDim2.new(0.5, -10, 0, act.Y)
        actBtn.BackgroundTransparency = 1
        actBtn.Image = act.Icon
        actBtn.ImageColor3 = Color3.fromRGB(180, 180, 195)
        actBtn.AutoButtonColor = false
        actBtn.Parent = actionStrip

        actBtn.MouseEnter:Connect(function()
            TweenService:Create(actBtn, TweenInfo.new(0.12), {
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 22, 0, 22),
                Position = UDim2.new(0.5, -11, 0, act.Y - 1)
            }):Play()
        end)
        actBtn.MouseLeave:Connect(function()
            TweenService:Create(actBtn, TweenInfo.new(0.12), {
                ImageColor3 = Color3.fromRGB(180, 180, 195),
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0.5, -10, 0, act.Y)
            }):Play()
        end)

        local function onAct()
            if act.Id == "Settings" then
                activeTabId = "Settings"
                refreshTabStates()
                pcall(onTabSelected, "Settings")
            elseif Utils then
                Utils.toast("Monody", act.Action, 2, act.Icon)
            end
        end
        actBtn.Activated:Connect(onAct)
        actBtn.MouseButton1Click:Connect(onAct)
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
