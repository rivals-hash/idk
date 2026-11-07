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
    sidebarFrame.Size = UDim2.new(0, 220, 0, 584)
    sidebarFrame.Position = UDim2.new(1, -220, 0, 0)
    sidebarFrame.BackgroundTransparency = 1
    sidebarFrame.Parent = parentGui

    -- Background Image with smoky texture
    local bgImg = Instance.new("ImageLabel")
    bgImg.Name = "SidebarBackground"
    bgImg.Size = UDim2.new(1, 0, 1, 0)
    bgImg.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    bgImg.BackgroundTransparency = 0.1
    bgImg.Image = (options.AssetManager and options.AssetManager.get("sidebar_bg.png", "rbxassetid://139820186687064")) or "rbxassetid://139820186687064"
    bgImg.ScaleType = Enum.ScaleType.Stretch
    bgImg.Parent = sidebarFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = bgImg

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 75)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = bgImg

    -- Header with Minimize and Close buttons
    local header = Instance.new("Frame")
    header.Name = "SidebarHeader"
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundTransparency = 1
    header.Parent = sidebarFrame

    local headerTitle = Instance.new("TextLabel")
    headerTitle.Name = "HeaderTitle"
    headerTitle.Size = UDim2.new(1, -80, 1, 0)
    headerTitle.Position = UDim2.new(0, 14, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.Text = "MENU"
    headerTitle.TextColor3 = Color3.fromRGB(220, 220, 235)
    headerTitle.TextSize = 13
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = header

    -- Minimize Button
    local minBtn = Instance.new("ImageButton")
    minBtn.Name = "MinimizeButton"
    minBtn.Size = UDim2.new(0, 20, 0, 20)
    minBtn.Position = UDim2.new(1, -54, 0.5, -10)
    minBtn.BackgroundTransparency = 1
    minBtn.Image = "rbxthumb://type=Asset&id=118026365011536&w=420&h=420"
    minBtn.ImageColor3 = Color3.fromRGB(220, 220, 220)
    minBtn.Parent = header

    -- Close Button
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = "rbxthumb://type=Asset&id=110786993356448&w=420&h=420"
    closeBtn.ImageColor3 = Color3.fromRGB(255, 120, 120)
    closeBtn.Parent = header

    -- Hover animations for top buttons
    local function setupIconBtn(btn, hoverColor, normColor)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), { ImageColor3 = hoverColor }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), { ImageColor3 = normColor }):Play()
        end)
    end
    setupIconBtn(minBtn, Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
    setupIconBtn(closeBtn, Color3.fromRGB(255, 70, 70), Color3.fromRGB(255, 120, 120))

    minBtn.MouseButton1Click:Connect(function()
        pcall(onMinimize)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        pcall(onClose)
    end)

    -- Content layout: Left tabs list (165px wide) + Right utility strip (45px wide)
    local tabsListFrame = Instance.new("Frame")
    tabsListFrame.Name = "TabsListFrame"
    tabsListFrame.Size = UDim2.new(0, 160, 1, -44)
    tabsListFrame.Position = UDim2.new(0, 8, 0, 38)
    tabsListFrame.BackgroundTransparency = 1
    tabsListFrame.Parent = sidebarFrame

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.Padding = UDim.new(0, 6)
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Parent = tabsListFrame

    -- Right Action Strip
    local actionStrip = Instance.new("Frame")
    actionStrip.Name = "ActionStrip"
    actionStrip.Size = UDim2.new(0, 42, 1, -44)
    actionStrip.Position = UDim2.new(1, -48, 0, 38)
    actionStrip.BackgroundTransparency = 1
    actionStrip.Parent = sidebarFrame

    local stripSeparator = Instance.new("Frame")
    stripSeparator.Name = "Separator"
    stripSeparator.Size = UDim2.new(0, 1, 0.94, 0)
    stripSeparator.Position = UDim2.new(0, 0, 0.03, 0)
    stripSeparator.BackgroundColor3 = Color3.fromRGB(65, 65, 80)
    stripSeparator.BackgroundTransparency = 0.5
    stripSeparator.BorderSizePixel = 0
    stripSeparator.Parent = actionStrip

    local actionLayout = Instance.new("UIListLayout")
    actionLayout.Padding = UDim.new(0, 12)
    actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    actionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    actionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    actionLayout.Parent = actionStrip

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

    -- Function to update active visual state
    local function refreshTabStates()
        for id, btnData in pairs(tabButtons) do
            local isActive = (id == activeTabId)
            local targetBgTrans = isActive and 0.85 or 1
            local targetStrokeTrans = isActive and 0.2 or 1
            local targetTextColor = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 195)
            local targetIconColor = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 180)
            local targetPillTrans = isActive and 0 or 1

            TweenService:Create(btnData.Button, TweenInfo.new(0.18), {
                BackgroundTransparency = targetBgTrans
            }):Play()
            TweenService:Create(btnData.Stroke, TweenInfo.new(0.18), {
                Transparency = targetStrokeTrans
            }):Play()
            TweenService:Create(btnData.Label, TweenInfo.new(0.18), {
                TextColor3 = targetTextColor
            }):Play()
            TweenService:Create(btnData.Icon, TweenInfo.new(0.18), {
                ImageColor3 = targetIconColor
            }):Play()
            TweenService:Create(btnData.ActivePill, TweenInfo.new(0.18), {
                BackgroundTransparency = targetPillTrans
            }):Play()
        end
    end

    -- Create Tab Buttons
    for i, tabData in ipairs(tabDefinitions) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "Tab_" .. tabData.Id
        tabBtn.Size = UDim2.new(1, 0, 0, 38)
        tabBtn.LayoutOrder = i
        tabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.BackgroundTransparency = 1
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = ""
        tabBtn.AutoButtonColor = false
        tabBtn.Parent = tabsListFrame

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabBtn

        local tabStroke = Instance.new("UIStroke")
        tabStroke.Color = Color3.fromRGB(255, 255, 255)
        tabStroke.Thickness = 1
        tabStroke.Transparency = 1
        tabStroke.Parent = tabBtn

        -- Left glowing active pill
        local activePill = Instance.new("Frame")
        activePill.Name = "ActivePill"
        activePill.Size = UDim2.new(0, 3, 0.6, 0)
        activePill.Position = UDim2.new(0, 4, 0.2, 0)
        activePill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        activePill.BackgroundTransparency = 1
        activePill.BorderSizePixel = 0
        activePill.Parent = tabBtn

        local pillCorner = Instance.new("UICorner")
        pillCorner.CornerRadius = UDim.new(1, 0)
        pillCorner.Parent = activePill

        -- Tab Icon
        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Name = "TabIcon"
        tabIcon.Size = UDim2.new(0, 22, 0, 22)
        tabIcon.Position = UDim2.new(0, 14, 0.5, -11)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = tabData.Icon
        tabIcon.ImageColor3 = Color3.fromRGB(160, 160, 180)
        tabIcon.Parent = tabBtn

        -- Tab Label
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Name = "TabLabel"
        tabLabel.Size = UDim2.new(1, -44, 1, 0)
        tabLabel.Position = UDim2.new(0, 42, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Font = Enum.Font.GothamMedium
        tabLabel.Text = tabData.Name
        tabLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
        tabLabel.TextSize = 13
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabBtn

        tabButtons[tabData.Id] = {
            Button = tabBtn,
            Stroke = tabStroke,
            Label = tabLabel,
            Icon = tabIcon,
            ActivePill = activePill
        }

        tabBtn.MouseEnter:Connect(function()
            if activeTabId ~= tabData.Id then
                TweenService:Create(tabBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.94 }):Play()
                TweenService:Create(tabLabel, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(230, 230, 240) }):Play()
            end
        end)

        tabBtn.MouseLeave:Connect(function()
            if activeTabId ~= tabData.Id then
                TweenService:Create(tabBtn, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
                TweenService:Create(tabLabel, TweenInfo.new(0.12), { TextColor3 = Color3.fromRGB(180, 180, 195) }):Play()
            end
        end)

        tabBtn.MouseButton1Click:Connect(function()
            activeTabId = tabData.Id
            refreshTabStates()
            pcall(onTabSelected, tabData.Id)
        end)
    end

    -- Right Action Buttons Definition
    local actionDefinitions = {
        { Id = "Gamepad", Icon = "rbxassetid://92483947987410", Action = "Mobile Controls HUD" },
        { Id = "Music", Icon = "rbxassetid://113343203848535", Action = "Music Player" },
        { Id = "Keyboard", Icon = "rbxassetid://121474456068237", Action = "Keybinds" },
        { Id = "Palette", Icon = "rbxassetid://86350350950064", Action = "Themes" },
        { Id = "Folder", Icon = "rbxassetid://85299519462846", Action = "Configs" },
        { Id = "Settings", Icon = "rbxassetid://80758916183665", Action = "Settings" }
    }

    for i, act in ipairs(actionDefinitions) do
        local actBtn = Instance.new("ImageButton")
        actBtn.Name = "Action_" .. act.Id
        actBtn.Size = UDim2.new(0, 26, 0, 26)
        actBtn.LayoutOrder = i
        actBtn.BackgroundTransparency = 1
        actBtn.Image = act.Icon
        actBtn.ImageColor3 = Color3.fromRGB(175, 175, 195)
        actBtn.Parent = actionStrip

        actBtn.MouseEnter:Connect(function()
            TweenService:Create(actBtn, TweenInfo.new(0.12), {
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 28, 0, 28)
            }):Play()
        end)
        actBtn.MouseLeave:Connect(function()
            TweenService:Create(actBtn, TweenInfo.new(0.12), {
                ImageColor3 = Color3.fromRGB(175, 175, 195),
                Size = UDim2.new(0, 26, 0, 26)
            }):Play()
        end)

        actBtn.MouseButton1Click:Connect(function()
            if act.Id == "Settings" then
                activeTabId = "Settings"
                refreshTabStates()
                pcall(onTabSelected, "Settings")
            elseif Utils then
                Utils.toast(act.Action, "Feature shortcut: " .. act.Action, 2, act.Icon)
            end
        end)
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
