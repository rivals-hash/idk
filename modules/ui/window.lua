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
    local AssetManager = dependencies.AssetManager
    local cardBgAsset = AssetManager and AssetManager.get("card_bg.png", "rbxassetid://139820186687064") or "rbxassetid://139820186687064"

    -- Root ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Monody_ScreenGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = false
    ScreenGui.DisplayOrder = 10000
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() ScreenGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets end)
    pcall(function() ScreenGui.ClipToDeviceSafeArea = true end)
    Utils.safeParent(ScreenGui)

    -- Master Window Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Monody_MainWindow"
    mainFrame.Size = UDim2.new(0, 568, 0, 400)
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

    local TabViewsMod = dependencies.TabViews

    -- Left Content Area (Contains HomeView or Tab Views)
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(0, 406, 0, 400)
    contentArea.Position = UDim2.new(0, 0, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.ClipsDescendants = true
    contentArea.Parent = mainFrame

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
        MusicVisualizer = MusicVisualizer,
        AssetManager = AssetManager
    })
    tabViews["Home"] = homeView.ScrollFrame

    -- Make window draggable via HomeView TopCard (safe drag handle that doesn't block touch)
    if homeView and homeView.TopCard then
        Utils.makeDraggable(mainFrame, homeView.TopCard)
    end

    -- Feature Tab View Generator using TabViews module
    local function getOrCreateTabView(tabName)
        if tabViews[tabName] then return tabViews[tabName] end

        local tabScroll = nil
        if TabViewsMod and TabViewsMod.build then
            tabScroll = TabViewsMod.build(tabName, contentArea, {
                Utils = Utils,
                AssetManager = AssetManager,
                onClose = function()
                    if sidebar and sidebar.Close then pcall(sidebar.Close) end
                end,
                onScaleChange = function(scale)
                    uiScale.Scale = math.clamp(scale, 0.45, 1.2)
                end
            })
        end

        if not tabScroll then
            tabScroll = Instance.new("ScrollingFrame")
            tabScroll.Name = "TabView_" .. tabName
            tabScroll.Size = UDim2.new(1, 0, 1, 0)
            tabScroll.BackgroundTransparency = 1
            tabScroll.BorderSizePixel = 0
            tabScroll.Parent = contentArea
        end

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

    -- Floating Mobile Toggle Button reference (hoisted so onClose can destroy it)
    local mobileToggle = nil

    -- Create Reworked Sidebar
    local sidebar = SidebarMod.create(mainFrame, {
        Utils = Utils,
        AssetManager = AssetManager,
        onTabSelected = function(tabId)
            switchTab(tabId)
        end,
        onMinimize = function()
            setWindowVisible(not isVisible)
            Utils.toast("Monody", not isVisible and "Minimizado. Toca el icono para reabrir." or "Abierto.", 1.5)
        end,
        onClose = function()
            pcall(function() mainFrame.Visible = false end)
            if mobileToggle and mobileToggle.Parent then
                pcall(function() mobileToggle.Visible = false end)
            end
            Utils.toast("Monody", "Cerrado por completo.", 1.5)
            task.delay(0.05, function()
                if mobileToggle and mobileToggle.Parent then
                    pcall(function() mobileToggle:Destroy() end)
                end
                if ScreenGui and ScreenGui.Parent then
                    pcall(function() ScreenGui:Destroy() end)
                end
                local env = (getgenv and getgenv()) or _G
                if env.BestHub and type(env.BestHub.Unload) == "function" then
                    pcall(function() env.BestHub:Unload() end)
                end
            end)
        end
    })

    -- Create Floating Mobile Toggle Button (FAB)
    mobileToggle = MobileToggleMod.create(ScreenGui, function()
        setWindowVisible(not isVisible)
    end, Utils)
    if AssetManager then
        pcall(function() mobileToggle.Image = AssetManager.get("avatar.png", mobileToggle.Image) end)
    end

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
