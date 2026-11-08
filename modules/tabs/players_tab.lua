--[[
    Darling Hub - players_tab.lua (Version 1.3)
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

-- 3. PLAYERS TAB
-- ========================================================================
local PlayersTab = Window:Tab({
    Title = "Players",
    Icon = "user-search"
})
enhanceTabScrolling(PlayersTab)

local playerHeaderPara = PlayersTab:Paragraph({
    Title = "Server Players",
    Desc = "View player skins, monitor live health, blacklist from aimbot, or spectate",
    Image = "users"
})

local function getTargetContainer()
    if refreshBtn and typeof(refreshBtn) == "table" then
        local btnElem = refreshBtn.Frame or refreshBtn.Instance or refreshBtn.Holder or refreshBtn.Main
        if btnElem and typeof(btnElem) == "Instance" and btnElem.Parent then
            return btnElem.Parent
        end
    end
    if PlayersTab.UIElements and PlayersTab.UIElements.ContainerFrame and typeof(PlayersTab.UIElements.ContainerFrame) == "Instance" then
        return PlayersTab.UIElements.ContainerFrame
    end
    if PlayersTab.ContainerFrame and typeof(PlayersTab.ContainerFrame) == "Instance" and PlayersTab.ContainerFrame:IsA("ScrollingFrame") then
        return PlayersTab.ContainerFrame
    end
    return nil
end

local refreshBtn = PlayersTab:Button({
    Title = "Refresh Player List",
    Desc = "Reloads active players in this server",
    Callback = function()
        local PlayerList = DarlingHub:Require("modules/players/player_list.lua")
        if PlayerList then
            local target = getTargetContainer()
            if target and (not PlayerList.Mounted or PlayerList.Container ~= target) then
                PlayerList.mount(target)
            elseif PlayerList.refresh then
                PlayerList.refresh()
            end
        end
    end
})

PlayersTab:Divider()

local function mountPlayerList()
    pcall(function()
        local PlayerList = DarlingHub:Require("modules/players/player_list.lua")
        if PlayerList and PlayerList.mount then
            local target = getTargetContainer()
            if target then
                PlayerList.mount(target)
            else
                PlayerList.mount(PlayersTab)
            end
        end
    end)
end

if PlayersTab.UIElements and PlayersTab.UIElements.Main and PlayersTab.UIElements.Main:IsA("GuiButton") then
    pcall(function()
        PlayersTab.UIElements.Main.MouseButton1Click:Connect(function()
            task.defer(function()
                local PlayerList = DarlingHub:Require("modules/players/player_list.lua")
                if PlayerList then
                    local target = getTargetContainer()
                    if target and (not PlayerList.Mounted or PlayerList.Container ~= target) then
                        PlayerList.mount(target)
                    elseif PlayerList.refresh then
                        PlayerList.refresh()
                    end
                end
            end)
        end)
    end)
end

task.spawn(function()
    for _ = 1, 40 do
        task.wait(0.1)
        local target = getTargetContainer()
        if target then
            mountPlayerList()
            break
        end
    end
end)

-- ========================================================================

    return PlayersTab
end
