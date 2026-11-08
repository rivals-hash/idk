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

    -- Destroy any previous existing instance of Monody_ScreenGui or Mobile Toggle across all parent targets
    pcall(function()
        local parents = {}
        if gethui then
            local ok, h = pcall(gethui)
            if ok and h and typeof(h) == "Instance" then table.insert(parents, h) end
        end
        local CoreGui = game:GetService("CoreGui")
        if CoreGui then table.insert(parents, CoreGui) end
        local Players = game:GetService("Players")
        if Players.LocalPlayer then
            local pg = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui") or Players.LocalPlayer:FindFirstChild("PlayerGui")
            if pg then table.insert(parents, pg) end
        end
        for _, p in ipairs(parents) do
            for _, child in ipairs(p:GetChildren()) do
                if child.Name == "Monody_ScreenGui" or child.Name == "Monody_MobileToggleContainer" then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end)

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

    -- Cinematic Roblox Lighting Management
    -- Gently dims and tints the 3D game world behind the GUI matching original references (WITHOUT turning the game world pitch black!)
    local Lighting = game:GetService("Lighting")
    local colorCorrection = nil
    local blurEffect = nil

    pcall(function()
        local oldCC = Lighting:FindFirstChild("Monody_ScreenDim")
        if oldCC then oldCC:Destroy() end
        colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Name = "Monody_ScreenDim"
        colorCorrection.Brightness = -0.06
        colorCorrection.Contrast = 0.05
        colorCorrection.Saturation = -0.05
        colorCorrection.TintColor = Color3.fromRGB(235, 225, 250)
        colorCorrection.Enabled = true
        colorCorrection.Parent = Lighting

        local oldBlur = Lighting:FindFirstChild("Monody_ScreenBlur")
        if oldBlur then oldBlur:Destroy() end
        blurEffect = Instance.new("BlurEffect")
        blurEffect.Name = "Monody_ScreenBlur"
        blurEffect.Size = 4 -- Subtle depth of field, 0 FPS lag
        blurEffect.Enabled = true
        blurEffect.Parent = Lighting
    end)

    local function setDarkLighting(enable)
        pcall(function()
            if colorCorrection then
                colorCorrection.Enabled = enable
            end
            if blurEffect then
                blurEffect.Enabled = enable
            end
        end)
    end
    setDarkLighting(true)

    -- Floating references hoisted for cross-closures
    local sidebar = nil
    local mobileToggle = nil

    -- Master Window Frame (Exact fit 356px height, no dead space below music)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Monody_MainWindow"
    mainFrame.Size = UDim2.new(0, 568, 0, 356)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.53, 0, 0.48, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 10
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

    -- Left Content Area (Contains HomeView or Tab Views - tight 356px height)
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(0, 406, 0, 356)
    contentArea.Position = UDim2.new(0, 0, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.ClipsDescendants = true
    contentArea.Parent = mainFrame

    -- Glassmorphic Background for Feature Tabs (Spans behind non-Home tabs)
    local tabContentBg = Instance.new("ImageLabel")
    tabContentBg.Name = "TabContentBackground"
    tabContentBg.Size = UDim2.new(1, 0, 1, 0)
    tabContentBg.Position = UDim2.new(0, 0, 0, 0)
    tabContentBg.BackgroundColor3 = Color3.fromRGB(14, 10, 16)
    tabContentBg.BackgroundTransparency = 0.2
    tabContentBg.BorderSizePixel = 0
    tabContentBg.Image = (AssetManager and (AssetManager.get("sidebar_bg_red.png") or AssetManager.get("sidebar_bg_v2.png"))) or ""
    tabContentBg.ImageTransparency = 0.35
    tabContentBg.ScaleType = Enum.ScaleType.Crop
    tabContentBg.ZIndex = 1
    tabContentBg.Visible = false
    tabContentBg.Parent = contentArea

    if AssetManager and AssetManager.bindImage then
        AssetManager.bindImage(tabContentBg, "sidebar_bg_red.png", "sidebar_bg_v2.png")
    end

    local tcCorner = Instance.new("UICorner")
    tcCorner.CornerRadius = UDim.new(0, 10)
    tcCorner.Parent = tabContentBg

    local tcStroke = Instance.new("UIStroke")
    tcStroke.Color = Color3.fromRGB(220, 35, 60)
    tcStroke.Transparency = 0.8
    tcStroke.Thickness = 1
    tcStroke.Parent = tabContentBg

    -- Toggle Hub Visibility Function with smooth scale and lighting transitions
    local isVisible = true
    local function setWindowVisible(visible)
        isVisible = visible
        if visible then
            mainFrame.Visible = true
            setDarkLighting(true)
            if blurEffect then
                blurEffect.Enabled = true
                TweenService:Create(blurEffect, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = 4
                }):Play()
            end
            TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Scale = Utils.getOptimalScale()
            }):Play()
        else
            setDarkLighting(false)
            if blurEffect then
                local twB = TweenService:Create(blurEffect, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = 0
                })
                twB:Play()
                twB.Completed:Connect(function()
                    if not isVisible and blurEffect then blurEffect.Enabled = false end
                end)
            end
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
            local ok, res = pcall(function()
                return TabViewsMod.build(tabName, contentArea, {
                    Utils = Utils,
                    AssetManager = AssetManager,
                    FOV = dependencies.FOV,
                    AimbotCore = dependencies.AimbotCore,
                    PlayerAimbot = dependencies.PlayerAimbot,
                    NPCAimbot = dependencies.NPCAimbot,
                    Blacklist = dependencies.Blacklist,
                    Tracers = dependencies.Tracers,
                    SilentAim = dependencies.SilentAim,
                    SoruEngine = dependencies.SoruEngine,
                    onClose = function()
                        if sidebar and sidebar.Close then pcall(sidebar.Close) end
                    end,
                    onScaleChange = function(scale)
                        uiScale.Scale = math.clamp(scale, 0.45, 1.2)
                    end,
                    onThemeChange = function(themeData)
                        if themeData.Background then
                            tabContentBg.Image = themeData.Background
                            if sidebar and sidebar.SetBackground then
                                sidebar.SetBackground(themeData.Background)
                            end
                        end
                        if themeData.ImageTransparency then
                            tabContentBg.ImageTransparency = themeData.ImageTransparency
                            if sidebar and sidebar.SetImageTransparency then
                                sidebar.SetImageTransparency(themeData.ImageTransparency)
                            end
                        end
                        if themeData.BackgroundTransparency then
                            tabContentBg.BackgroundTransparency = themeData.BackgroundTransparency
                        end
                        if themeData.BlurSize and blurEffect then
                            blurEffect.Size = themeData.BlurSize
                        end
                        if themeData.DimEnabled ~= nil and colorCorrection then
                            colorCorrection.Enabled = themeData.DimEnabled
                        end
                    end
                })
            end)
            if ok and res then
                tabScroll = res
            else
                warn("[Monody] Error building tab " .. tostring(tabName) .. ": " .. tostring(res))
                if Utils and Utils.toast then
                    Utils.toast("Monody Error", "Error: " .. tostring(res):sub(1, 50), 4)
                end
            end
        else
            warn("[Monody] TabViewsMod is nil or missing build function!")
            if Utils and Utils.toast then
                Utils.toast("Monody Error", "TabViews unavailable", 4)
            end
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
        tabContentBg.Visible = (tabName ~= "Home")
        for name, view in pairs(tabViews) do
            view.Visible = (name == tabName)
        end
        if not tabViews[tabName] then
            local newView = getOrCreateTabView(tabName)
            newView.Visible = true
        end
    end

    -- Create Reworked Sidebar (Compact 316px height with smooth red scrollbar)
    sidebar = SidebarMod.create(mainFrame, {
        Utils = Utils,
        AssetManager = AssetManager,
        onTabSelected = function(tabId)
            switchTab(tabId)
        end,
        onMinimize = function()
            setWindowVisible(not isVisible)
            Utils.toast("Monody", not isVisible and "Minimized. Tap icon to reopen." or "Opened.", 1.5)
        end,
        onClose = function()
            pcall(function() mainFrame.Visible = false end)
            if mobileToggle and mobileToggle.Parent then
                pcall(function() mobileToggle.Visible = false end)
            end
            Utils.toast("Monody", "Closed completely.", 1.5)
            setDarkLighting(false)
            task.delay(0.05, function()
                if mobileToggle and mobileToggle.Parent then
                    pcall(function() mobileToggle:Destroy() end)
                end
                if blurEffect and blurEffect.Parent then
                    pcall(function() blurEffect:Destroy() end)
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
    if AssetManager and mobileToggle then
        local imgBtn = mobileToggle:IsA("ImageButton") and mobileToggle or mobileToggle:FindFirstChild("ToggleBtn")
        if imgBtn then
            imgBtn.BackgroundTransparency = 1
            if AssetManager.bindImage then
                AssetManager.bindImage(imgBtn, "floating_avatar_red.png", AssetManager.get("floating_avatar.png"))
            else
                pcall(function() imgBtn.Image = AssetManager.get("floating_avatar_red.png", AssetManager.get("floating_avatar.png")) end)
            end
        end
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
