--[[
    Darling Hub - home_tab.lua (Version 1.3)
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

return function(context)
    local Window = context.Window
    local DarlingHub = context.DarlingHub
    local SharedEnv = context.SharedEnv or (getgenv and getgenv()) or _G
    local enhanceTabScrolling = context.enhanceTabScrolling
    local bindToggle = context.bindToggle
    local notifyModuleFail = context.notifyModuleFail
    local ColorMap = context.ColorMap
    local ColorNames = context.ColorNames
    local tr = context.tr
    local currentLanguage = context.currentLanguage
    local applyLanguage = context.applyLanguage
    local darlingLogoHalloween = context.darlingLogoHalloween
    local darlingLogoNormal = context.darlingLogoNormal
    local darlingIcon = context.darlingIcon
    local saveHubConfig = context.saveHubConfig
    local loadHubConfig = context.loadHubConfig
    local triggerAutoSave = context.triggerAutoSave
    local clearActiveMedia = context.clearActiveMedia
    local setActiveMedia = context.setActiveMedia
    local processAndApplyMediaInput = context.processAndApplyMediaInput
    local setBackgroundImage = context.setBackgroundImage
    local playVideo = context.playVideo
    local stopVideo = context.stopVideo
    local PRESET_FALLBACK_ASSETS = context.PRESET_FALLBACK_ASSETS
    local universalHttpGet = context.universalHttpGet
    local loadCustomMediaAsset = context.loadCustomMediaAsset
    local getCustomAsset = context.getCustomAsset
    local currentBackgroundTransparency = context.currentBackgroundTransparency
    local updateVideoRenderSize = context.updateVideoRenderSize
    local safeResolveUserIdentifier = context.safeResolveUserIdentifier
    local allowFloatingWidget = context.allowFloatingWidget
    local toggleHub = context.toggleHub
    local currentToggleKey = context.currentToggleKey
    local WindUI = context.WindUI
    local TabTranslations = context.TabTranslations
    local Translations = context.Translations

-- 1. HOME TAB
-- ========================================================================
local HomeTab = Window:Tab({
    Title = "Home",
    Icon = "layout-dashboard"
})
enhanceTabScrolling(HomeTab)

local playerDisplayName = (LocalPlayer and LocalPlayer.DisplayName) or (Players.LocalPlayer and Players.LocalPlayer.DisplayName) or "Player"
local playerUsername = (LocalPlayer and LocalPlayer.Name) or (Players.LocalPlayer and Players.LocalPlayer.Name) or "Player"

HomeTab:Paragraph({
    Title = playerDisplayName .. " (@" .. playerUsername .. ")",
    Desc = "Darling Hub - Version 1.5 | Darling X Edition",
    Image = "sparkles"
})

-- 2D Character Profile Card (Crash-Proof, Fast, Cross-Platform)
local profileCard = Instance.new("Frame")
profileCard.Name = "UserProfileCard"
profileCard.Size = UDim2.new(1, 0, 0, 80)
profileCard.BackgroundColor3 = Color3.fromRGB(18, 17, 26)
profileCard.BackgroundTransparency = 0.2
profileCard.BorderSizePixel = 0

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 10)
cardCorner.Parent = profileCard

local avatarBox = Instance.new("Frame")
avatarBox.Name = "AvatarBox"
avatarBox.Size = UDim2.new(0, 60, 0, 60)
avatarBox.Position = UDim2.new(0, 10, 0.5, -30)
avatarBox.BackgroundColor3 = Color3.fromRGB(25, 23, 35)
avatarBox.BorderSizePixel = 0
avatarBox.Parent = profileCard

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(0, 8)
avatarCorner.Parent = avatarBox

local avatarImg = Instance.new("ImageLabel")
avatarImg.Name = "AvatarImage"
avatarImg.Size = UDim2.new(1, 0, 1, 0)
avatarImg.BackgroundTransparency = 1
avatarImg.ScaleType = Enum.ScaleType.Fit
local lpUserId = (LocalPlayer and LocalPlayer.UserId) or (Players.LocalPlayer and Players.LocalPlayer.UserId) or 0
avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(lpUserId) .. "&w=150&h=150"
avatarImg.Parent = avatarBox

local avatarImgCorner = Instance.new("UICorner")
avatarImgCorner.CornerRadius = UDim.new(0, 8)
avatarImgCorner.Parent = avatarImg

local infoFrame = Instance.new("Frame")
infoFrame.Name = "InfoFrame"
infoFrame.Size = UDim2.new(1, -85, 1, -16)
infoFrame.Position = UDim2.new(0, 78, 0, 8)
infoFrame.BackgroundTransparency = 1
infoFrame.Parent = profileCard

local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "DisplayNameLabel"
nameLabel.Size = UDim2.new(1, 0, 0, 20)
nameLabel.Position = UDim2.new(0, 0, 0, 2)
nameLabel.BackgroundTransparency = 1
nameLabel.Font = Enum.Font.GothamBold
nameLabel.Text = playerDisplayName .. " (@" .. playerUsername .. ")"
nameLabel.TextColor3 = Color3.fromRGB(245, 245, 255)
nameLabel.TextSize = 13
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
nameLabel.Parent = infoFrame

local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "StatsLabel"
statsLabel.Size = UDim2.new(1, 0, 0, 18)
statsLabel.Position = UDim2.new(0, 0, 0, 24)
statsLabel.BackgroundTransparency = 1
statsLabel.Font = Enum.Font.Gotham
local teamStr = (LocalPlayer and LocalPlayer.Team and LocalPlayer.Team.Name) or (Players.LocalPlayer and Players.LocalPlayer.Team and Players.LocalPlayer.Team.Name) or "Pirates"
statsLabel.Text = "Team: " .. teamStr .. " | Status: Active"
statsLabel.TextColor3 = Color3.fromRGB(170, 175, 195)
statsLabel.TextSize = 11
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = infoFrame

local badgeLabel = Instance.new("TextLabel")
badgeLabel.Name = "BadgeLabel"
badgeLabel.Size = UDim2.new(1, 0, 0, 16)
badgeLabel.Position = UDim2.new(0, 0, 0, 44)
badgeLabel.BackgroundTransparency = 1
badgeLabel.Font = Enum.Font.Code
badgeLabel.Text = "Blox Fruits Combat & Automation Suite Active"
badgeLabel.TextColor3 = Color3.fromRGB(80, 220, 140)
badgeLabel.TextSize = 10
badgeLabel.TextXAlignment = Enum.TextXAlignment.Left
badgeLabel.Parent = infoFrame

if _G.__DarlingAvatarRotConn then
    pcall(function() _G.__DarlingAvatarRotConn:Disconnect() end)
    _G.__DarlingAvatarRotConn = nil
end

task.spawn(function()
    for _ = 1, 15 do
        task.wait(0.1)
        local cf = (HomeTab.UIElements and HomeTab.UIElements.ContainerFrame)
            or HomeTab.ContainerFrame
            or (HomeTab.UIElements and HomeTab.UIElements.Main)
        if cf then
            profileCard.Parent = cf
            break
        end
    end
end)

HomeTab:Divider()

HomeTab:Paragraph({
    Title = "Status & Experience",
    Desc = "Status: Online | Version: 1.3 | Blox Fruits Combat & Automation Suite Active",
    Image = "check-circle"
})

-- ========================================================================

    return HomeTab
end
