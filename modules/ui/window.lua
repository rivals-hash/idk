--[[
    BestHub - modules/ui/window.lua
    Responsive Master Window container with automatic UIScale for Mobile,
    draggability, and dynamic content switching between Home & Tab Views.
]]

local Window = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

function Window.create(dependencies)
    local Utils = dependencies.Utils
    local SidebarMod = dependencies.Sidebar
    local HomeViewMod = dependencies.HomeView
    local StatsService = dependencies.StatsService
    local MusicEngine = dependencies.MusicEngine
    local MusicVisualizer = dependencies.MusicVisualizer
    local MobileToggleMod = dependencies.MobileToggle

    -- Root ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BestHub_ScreenGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = false
    ScreenGui.DisplayOrder = 10000
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() ScreenGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets end)
    pcall(function() ScreenGui.ClipToDeviceSafeArea = true end)
    Utils.safeParent(ScreenGui)

    -- Master Window Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "BestHub_MainWindow"
    mainFrame.Size = UDim2.new(0, 755, 0, 584)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = false
    mainFrame.Parent = ScreenGui

    -- Responsive UIScale for Mobile and Tablet
    local uiScale = Instance.new("UIScale")
    uiScale.Name = "WindowScale"
    uiScale.Parent = mainFrame

    local function updateScale()
        pcall(function()
            uiScale.Scale = Utils.getOptimalScale()
        end)
    end
    updateScale()

    local cam = Workspace.CurrentCamera
    if cam then
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    end

    -- Left Content Area (Contains HomeView or Tab Views)
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(0, 525, 0, 584)
    contentArea.Position = UDim2.new(0, 0, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.ClipsDescendants = true
    contentArea.Parent = mainFrame

    -- Make entire window draggable via content area background or sidebar header
    Utils.makeDraggable(mainFrame, contentArea)

    -- Toggle Hub Visibility Function
    local isVisible = true
    local function setWindowVisible(visible)
        isVisible = visible
        if visible then
            mainFrame.Visible = true
            TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Scale = Utils.getOptimalScale()
            }):Play()
        else
            local tw = TweenService:Create(uiScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Scale = 0.05
            })
            tw:Play()
            tw.Completed:Connect(function()
                if not isVisible then
                    mainFrame.Visible = false
                end
            end)
        end
    end

    -- Tab Views Container
    local tabViews = {}

    -- Initialize Home View
    local homeView = HomeViewMod.create(contentArea, {
        Utils = Utils,
        StatsService = StatsService,
        MusicEngine = MusicEngine,
        MusicVisualizer = MusicVisualizer
    })
    tabViews["Home"] = homeView.ScrollFrame

    -- Generic Tab View Generator for features (Aimbot, Combat, Soru, etc.)
    local function getOrCreateTabView(tabName)
        if tabViews[tabName] then return tabViews[tabName] end

        local tabScroll = Instance.new("ScrollingFrame")
        tabScroll.Name = "TabView_" .. tabName
        tabScroll.Size = UDim2.new(1, 0, 1, 0)
        tabScroll.BackgroundTransparency = 1
        tabScroll.BorderSizePixel = 0
        tabScroll.ScrollBarThickness = 3
        tabScroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
        tabScroll.CanvasSize = UDim2.new(0, 0, 0, 480)
        tabScroll.Visible = false
        tabScroll.Parent = contentArea

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = tabScroll

        -- Tab Header Banner
        local banner = Instance.new("Frame")
        banner.Name = "TabBanner"
        banner.Size = UDim2.new(0, 520, 0, 75)
        banner.BackgroundTransparency = 1
        banner.Parent = tabScroll

        local bannerBg = Instance.new("ImageLabel")
        bannerBg.Size = UDim2.new(1, 0, 1, 0)
        bannerBg.BackgroundTransparency = 1
        bannerBg.Image = "rbxassetid://139820186687064"
        bannerBg.ScaleType = Enum.ScaleType.Stretch
        bannerBg.Parent = banner

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 8)
        bCorner.Parent = bannerBg

        local bTitle = Instance.new("TextLabel")
        bTitle.Size = UDim2.new(1, -20, 0, 30)
        bTitle.Position = UDim2.new(0, 16, 0, 10)
        bTitle.BackgroundTransparency = 1
        bTitle.Font = Enum.Font.GothamBold
        bTitle.Text = tabName:upper() .. " SUITE"
        bTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        bTitle.TextSize = 18
        bTitle.TextXAlignment = Enum.TextXAlignment.Left
        bTitle.Parent = banner

        local bDesc = Instance.new("TextLabel")
        bDesc.Size = UDim2.new(1, -20, 0, 20)
        bDesc.Position = UDim2.new(0, 16, 0, 42)
        bDesc.BackgroundTransparency = 1
        bDesc.Font = Enum.Font.Gotham
        bDesc.Text = "BestHub modular features for " .. tabName .. " | Monody Premium"
        bDesc.TextColor3 = Color3.fromRGB(180, 180, 195)
        bDesc.TextSize = 12
        bDesc.TextXAlignment = Enum.TextXAlignment.Left
        bDesc.Parent = banner

        tabViews[tabName] = tabScroll
        return tabScroll
    end

    -- Switch Active Tab
    local function switchTab(tabName)
        for name, view in pairs(tabViews) do
            view.Visible = (name == tabName)
        end
        if not tabViews[tabName] then
            local newView = getOrCreateTabView(tabName)
            newView.Visible = true
        end
    end

    -- Create Reworked Sidebar
    local sidebar = SidebarMod.create(mainFrame, {
        Utils = Utils,
        onTabSelected = function(tabId)
            switchTab(tabId)
        end,
        onMinimize = function()
            setWindowVisible(not isVisible)
            Utils.toast("BestHub", "Hub minimized. Tap the floating icon to reopen.", 2.5)
        end,
        onClose = function()
            setWindowVisible(false)
            Utils.toast("BestHub", "Hub closed. Tap the floating icon to reopen.", 2.5)
        end
    })

    -- Create Floating Mobile Toggle Button (FAB)
    local mobileToggle = MobileToggleMod.create(ScreenGui, function()
        setWindowVisible(not isVisible)
    end, Utils)

    -- Toggle Hotkey for PC (Key F)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.F then
            setWindowVisible(not isVisible)
        end
    end)

    return {
        ScreenGui = ScreenGui,
        MainFrame = mainFrame,
        ContentArea = contentArea,
        Sidebar = sidebar,
        HomeView = homeView,
        MobileToggle = mobileToggle,
        SetVisible = setWindowVisible,
        SwitchTab = switchTab,
        GetTabView = getOrCreateTabView
    }
end

return Window
