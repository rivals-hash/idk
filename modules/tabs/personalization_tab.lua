--[[
    Darling Hub - personalization_tab.lua (Version 1.3)
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
    local triggerAutoSave = context.triggerAutoSave or (DarlingHub and DarlingHub.TriggerAutoSave) or function() end
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
    local setCurrentBackgroundTransparency = context.setCurrentBackgroundTransparency or (DarlingHub and DarlingHub.SetBackgroundTransparency)
    local getCurrentBackgroundTransparency = context.getCurrentBackgroundTransparency or (DarlingHub and DarlingHub.GetBackgroundTransparency) or function() return 0.25 end
    local setLastEnteredBackgroundInput = context.setLastEnteredBackgroundInput or (DarlingHub and DarlingHub.SetBackgroundInput)
    local getLastEnteredBackgroundInput = context.getLastEnteredBackgroundInput or (DarlingHub and DarlingHub.GetBackgroundInput) or function() return "" end
    local lastEnteredBackgroundInput = getLastEnteredBackgroundInput()
    local currentBackgroundTransparency = getCurrentBackgroundTransparency()
    local updateVideoRenderSize = context.updateVideoRenderSize
    local safeResolveUserIdentifier = context.safeResolveUserIdentifier
    local allowFloatingWidget = context.allowFloatingWidget
    local toggleHub = context.toggleHub
    local currentToggleKey = context.currentToggleKey
    local WindUI = context.WindUI
    local TabTranslations = context.TabTranslations
    local Translations = context.Translations
    local isMobile = context.isMobile

    local exIsFile = isfile or (syn and syn.isfile) or context.exIsFile
    local exReadFile = readfile or (syn and syn.readfile) or context.exReadFile
    local exWriteFile = writefile or (syn and syn.writefile) or context.exWriteFile
    local exMakeFolder = makefolder or (syn and syn.makefolder) or context.exMakeFolder
    local exGetCustomAsset = getcustomasset or getsynasset or context.exGetCustomAsset

-- 9. PERSONALIZATION TAB
-- ========================================================================
local PersonalizationTab = Window:Tab({
    Title = "Personalization",
    Icon = "brush"
})
enhanceTabScrolling(PersonalizationTab)

-- Register exclusive Darling theme
pcall(function()
    WindUI:AddTheme({
        Name = "Darling",
        Accent = Color3.fromHex("#FF4B91"),
        Background = Color3.fromHex("#141416"),
        Outline = Color3.fromHex("#28282D"),
        Text = Color3.fromHex("#FFFFFF"),
        Placeholder = Color3.fromHex("#888890"),
        Button = Color3.fromHex("#1F1F24"),
        Icon = Color3.fromHex("#FF76CE"),
    })
end)

local availableThemes = {}
local gotThemes, themesTable = pcall(function()
    return WindUI:GetThemes()
end)

if gotThemes and type(themesTable) == "table" then
    for k, v in pairs(themesTable) do
        local name = (type(k) == "string" and not tonumber(k)) and k or tostring(v)
        if not table.find(availableThemes, name) then
            table.insert(availableThemes, name)
        end
    end
    table.sort(availableThemes)
end

if #availableThemes == 0 then
    availableThemes = { "Amber", "Ember", "Halloween", "Normal / Dark", "Darling", "Dark", "Rose", "Purple", "Midnight", "Emerald", "Crimson", "Violet", "Sky", "Light" }
else
    if not table.find(availableThemes, "Amber") then table.insert(availableThemes, 1, "Amber") end
    if not table.find(availableThemes, "Ember") then table.insert(availableThemes, 2, "Ember") end
end

local currentSelectedTheme = "Normal / Dark"
local ThemeDropdown = nil

PersonalizationTab:Paragraph({
    Title = "Theme Quick Switcher",
    Desc = "Switch themes with exclusive intro cinematics and styled icons",
    Image = "sparkles"
})

PersonalizationTab:Button({
    Title = tr("Normal Theme", "Tema Normal"),
    Desc = tr("Plays The Aureate Sanctuary cinematic, sets Normal/Dark theme and purple icon"),
    Callback = function()
        pcall(function()
            WindUI:SetTheme("Dark")
            darlingIcon = darlingLogoNormal
            if DarlingHub.UpdateToggleTheme then
                DarlingHub.UpdateToggleTheme("Dark")
            elseif DarlingHub.StyleOpenButtonBorder then
                DarlingHub.StyleOpenButtonBorder(nil, darlingLogoNormal)
            end
            if ThemeDropdown and ThemeDropdown.Set then
                ThemeDropdown:Set("Normal / Dark")
            end
            if DarlingHub.HideUI then
                DarlingHub:HideUI()
            end
            local sc = DarlingHub:Require("modules/special/sanctuary_cinematic.lua")
            if sc and sc.play then
                sc.play(function()
                    if DarlingHub.ShowUI then
                        DarlingHub:ShowUI()
                    end
                end)
            else
                if DarlingHub.ShowUI then
                    DarlingHub:ShowUI()
                end
            end
        end)
    end
})

PersonalizationTab:Button({
    Title = tr("Halloween Theme", "Tema Halloween"),
    Desc = tr("Plays The Hollow Lantern cinematic, sets Halloween/Amber theme and orange icon"),
    Callback = function()
        pcall(function()
            WindUI:SetTheme("Amber")
            darlingIcon = darlingLogoHalloween
            if DarlingHub.UpdateToggleTheme then
                DarlingHub.UpdateToggleTheme("Amber")
            elseif DarlingHub.StyleOpenButtonBorder then
                DarlingHub.StyleOpenButtonBorder(nil, darlingLogoHalloween)
            end
            if ThemeDropdown and ThemeDropdown.Set then
                ThemeDropdown:Set("Halloween")
            end
            if DarlingHub.HideUI then
                DarlingHub:HideUI()
            end
            local hl = DarlingHub:Require("modules/special/halloween_cinematic.lua")
            if hl and hl.play then
                hl.play(function()
                    if DarlingHub.ShowUI then
                        DarlingHub:ShowUI()
                    end
                end)
            else
                if DarlingHub.ShowUI then
                    DarlingHub:ShowUI()
                end
            end
        end)
    end
})

PersonalizationTab:Divider()

ThemeDropdown = PersonalizationTab:Dropdown({
    Title = "UI Color Theme",
    Values = availableThemes,
    Default = "Normal / Dark",
    Callback = function(themeName)
        currentSelectedTheme = themeName
        pcall(function()
            if themeName == "Halloween" or themeName == "Amber" or themeName == "Ember" then
                WindUI:SetTheme(themeName)
                darlingIcon = darlingLogoHalloween
            elseif themeName == "Normal / Dark" then
                WindUI:SetTheme("Dark")
                darlingIcon = darlingLogoNormal
            else
                WindUI:SetTheme(themeName)
                darlingIcon = darlingLogoNormal
            end
            if DarlingHub.UpdateToggleTheme then
                DarlingHub.UpdateToggleTheme(themeName)
            elseif DarlingHub.StyleOpenButtonBorder then
                DarlingHub.StyleOpenButtonBorder(nil, darlingIcon)
            end
            WindUI:Notify({
                Title = "Theme Updated",
                Content = "Applied: " .. tostring(themeName),
                Duration = 2,
                Icon = "palette"
            })
        end)
        if autoSaveConfig and saveHubConfig then
            saveHubConfig()
        end
    end
})
DarlingHub.UIElements["UITheme"] = ThemeDropdown
DarlingHub.DefaultValues["UITheme"] = "Normal / Dark"

PersonalizationTab:Divider()

-- Background Presets Dropdown (Static Images)
PersonalizationTab:Paragraph({
    Title = "Window Background Media",
    Desc = "Choose a static background wallpaper preset or input custom asset IDs",
    Image = "image"
})

local BACKGROUND_PRESETS = {
    ["None / Cleared"] = "",
    ["2000s Hacker Room"] = "hacker_room.jpg",
    ["Lycoris Monochrome"] = "lycoris_monochrome.jpg",
    ["Cyan Neko"] = "cyan_neko.jpg",
    ["Frieren Beyond Journey"] = "frieren.jpg",
    ["Cyberpunk Megalopolis"] = "cyberpunk_megalopolis.jpg",
    ["Green Night Driving"] = "green_night_driving.jpg",
    ["Monika Lonely"] = "monika_lonely.jpg",
    ["Neon Purple Midnight"] = "purple_midnight.jpg",
    ["Persona 5 Rainy Tokyo"] = "persona_5_rainy.jpg",
    ["Rainy Tokyo"] = "rainy_tokyo.jpg",
    ["Shorekeeper Blue Sea"] = "shorekeeper.jpg",
    ["Skirk Neko Genshin"] = "skirk_neko.jpg",
    ["Snowy Cozy Bedroom"] = "snowy_bedroom.jpg",
    ["Snowy Forest"] = "snowy_forest.jpg",
    ["Dark River Forest"] = "dark_river_forest.jpg",
    ["Witch Cauldron Halloween"] = "witch_cauldron.jpg",
    ["Deepseek Chan"] = "deepseek_chan.jpg",
    ["Yuta Cursed Blade"] = "yuta_blade.jpg",
    ["Zankou Neverness"] = "zankou_nte.jpg",
}

local bgPresetNames = {
    "None / Cleared",
    "2000s Hacker Room",
    "Lycoris Monochrome",
    "Cyan Neko",
    "Frieren Beyond Journey",
    "Cyberpunk Megalopolis",
    "Green Night Driving",
    "Monika Lonely",
    "Neon Purple Midnight",
    "Persona 5 Rainy Tokyo",
    "Rainy Tokyo",
    "Shorekeeper Blue Sea",
    "Skirk Neko Genshin",
    "Snowy Cozy Bedroom",
    "Snowy Forest",
    "Dark River Forest",
    "Witch Cauldron Halloween",
    "Deepseek Chan",
    "Yuta Cursed Blade",
    "Zankou Neverness"
}

local function getHidamariCustomAsset(fileName)
    local rawUrl = "https://raw.githubusercontent.com/rivals-hash/idk/main/assets/backgrounds/" .. fileName
    local cachePath = "DarlingHub/cache/" .. fileName

    local getAsset = exGetCustomAsset or getcustomasset or getsynasset or (getgenv and (getgenv().getcustomasset or getgenv().getsynasset)) or (syn and syn.get_custom_asset)
    local exists = exIsFile or isfile or is_file or (getgenv and getgenv().isfile) or (syn and syn.isfile)
    local write = exWriteFile or writefile or (getgenv and getgenv().writefile) or (syn and syn.writefile)
    local makeDir = exMakeFolder or makefolder or make_folder or (getgenv and getgenv().makefolder) or (syn and syn.makefolder)
    local read = exReadFile or readfile or (getgenv and getgenv().readfile) or (syn and syn.readfile)

    -- 1. Check local files in workspace first
    if type(getAsset) == "function" and type(exists) == "function" then
        for _, p in ipairs({ cachePath, fileName, "assets/backgrounds/" .. fileName, "Darling-hub/assets/backgrounds/" .. fileName }) do
            if exists(p) then
                local isValid = true
                if type(read) == "function" then
                    local okR, body = pcall(read, p)
                    if okR and (not body or #body < 100) then
                        isValid = false
                    end
                end
                if isValid then
                    local ok, asset = pcall(getAsset, p)
                    if ok and type(asset) == "string" and #asset > 0 then
                        return asset
                    end
                end
            end
        end
    end

    -- 2. Try loadCustomMediaAsset if available from context
    if loadCustomMediaAsset then
        local loaded = loadCustomMediaAsset(rawUrl, fileName, 12)
        if loaded and type(loaded) == "string" and #loaded > 0 then
            return loaded
        end
    end

    -- 3. Download from GitHub raw if not in local cache
    local content = nil
    if universalHttpGet then
        content = universalHttpGet(rawUrl, 12)
    end
    if not content and game and game.HttpGet then
        pcall(function() content = game:HttpGet(rawUrl, true) end)
    end

    if content and #content > 50 and type(write) == "function" and type(getAsset) == "function" then
        pcall(function()
            if type(makeDir) == "function" then
                pcall(makeDir, "DarlingHub")
                pcall(makeDir, "DarlingHub/cache")
            end
            write(cachePath, content)
        end)
        local okA, assetA = pcall(getAsset, cachePath)
        if okA and type(assetA) == "string" and #assetA > 0 then
            return assetA
        end

        pcall(write, fileName, content)
        local okB, assetB = pcall(getAsset, fileName)
        if okB and type(assetB) == "string" and #assetB > 0 then
            return assetB
        end
    end

    return nil
end

local bgPresetDropdown = PersonalizationTab:Dropdown({
    Title = "Background Preset",
    Desc = "Select a static background wallpaper preset",
    Values = bgPresetNames,
    Default = "None / Cleared",
    Callback = function(presetName)
        if type(presetName) == "table" then
            presetName = presetName[1] or presetName.Value or presetName.Title
        end
        DarlingHub.FeatureStates["BackgroundPreset"] = presetName
        local fileName = BACKGROUND_PRESETS[presetName]
        if fileName and fileName ~= "" then
            task.spawn(function()
                WindUI:Notify({
                    Title = "Wallpaper",
                    Content = "Loading " .. tostring(presetName) .. "...",
                    Duration = 1.5,
                    Icon = "image"
                })
                local customAssetId = getHidamariCustomAsset(fileName)
                if customAssetId and customAssetId ~= "" then
                    if setLastEnteredBackgroundInput then
                        setLastEnteredBackgroundInput(customAssetId)
                    end
                    lastEnteredBackgroundInput = customAssetId
                    if setBackgroundImage then
                        setBackgroundImage(customAssetId)
                    elseif processAndApplyMediaInput then
                        processAndApplyMediaInput(customAssetId)
                    end
                    WindUI:Notify({
                        Title = "Wallpaper Applied",
                        Content = tostring(presetName),
                        Duration = 2.5,
                        Icon = "check"
                    })
                else
                    WindUI:Notify({
                        Title = "Wallpaper Error",
                        Content = "Failed to load preset: " .. tostring(presetName),
                        Duration = 3,
                        Icon = "alert-circle"
                    })
                end
                triggerAutoSave()
            end)
        else
            if setLastEnteredBackgroundInput then
                setLastEnteredBackgroundInput("")
            end
            lastEnteredBackgroundInput = ""
            if clearActiveMedia then
                clearActiveMedia()
            end
            triggerAutoSave()
        end
    end
})
DarlingHub.UIElements["BackgroundPreset"] = bgPresetDropdown
DarlingHub.DefaultValues["BackgroundPreset"] = "None / Cleared"

PersonalizationTab:Divider()

local bgInputObj = PersonalizationTab:Input({
    Title = "Custom Media URL or ID",
        Icon = "link",
    Desc = "Paste custom video link, slot ID, or loadstring command",
    Placeholder = "Enter URL or ID...",
    Value = "",
    ClearTextOnFocus = false,
    Callback = function(text)
        if text and #text > 0 then
            lastEnteredBackgroundInput = text
        end
    end
})

task.spawn(function()
    task.wait(0.2)
    pcall(function()
        local frame = bgInputObj.InputFrame or (bgInputObj.UIElements and bgInputObj.UIElements.Main)
        if frame then
            for _, desc in ipairs(frame:GetDescendants()) do
                if desc:IsA("TextBox") then
                    desc:GetPropertyChangedSignal("Text"):Connect(function()
                        lastEnteredBackgroundInput = desc.Text
                    end)
                    break
                end
            end
        end
    end)
end)

PersonalizationTab:Button({
    Title = "Apply Custom Background",
    Callback = function()
        local textToUse = lastEnteredBackgroundInput
        if not textToUse or #textToUse:gsub("%s+", "") == 0 then
            pcall(function()
                local frame = bgInputObj.InputFrame or (bgInputObj.UIElements and bgInputObj.UIElements.Main)
                if frame then
                    for _, desc in ipairs(frame:GetDescendants()) do
                        if desc:IsA("TextBox") and #desc.Text > 0 then
                            textToUse = desc.Text
                            lastEnteredBackgroundInput = desc.Text
                            break
                        end
                    end
                end
            end)
        end

        if not textToUse or #textToUse:gsub("%s+", "") == 0 then
            WindUI:Notify({
                Title = "Background Error",
                Content = "Please enter or paste a valid link or ID.",
                Duration = 3,
                Icon = "alert-circle"
            })
            return
        end

        processAndApplyMediaInput(textToUse)
        triggerAutoSave()
    end
})

PersonalizationTab:Button({
    Title = "Remove Background",
    Callback = function()
        if setLastEnteredBackgroundInput then
            setLastEnteredBackgroundInput("")
        end
        lastEnteredBackgroundInput = ""
        if clearActiveMedia then
            clearActiveMedia()
        end
        DarlingHub.FeatureStates["BackgroundPreset"] = "None / Cleared"
        if bgPresetDropdown and bgPresetDropdown.Select then
            pcall(function() bgPresetDropdown:Select("None / Cleared") end)
        end
        if bgInputObj and bgInputObj.Set then
            pcall(function() bgInputObj:Set("") end)
        end
        triggerAutoSave()
        WindUI:Notify({
            Title = "Background Cleared",
            Content = "Background media has been removed.",
            Duration = 2,
            Icon = "trash-2"
        })
    end
})

PersonalizationTab:Divider()

local bgDimmingSlider = PersonalizationTab:Slider({
    Title = "Background Dimming",
        Icon = "sun",
    Desc = "Adjusts dark overlay opacity over background media",
    Width = 200,
    Value = {
        Min = 0,
        Max = 90,
        Default = 25,
    },
    Step = 5,
    Callback = function(val)
        local trans = val / 100
        currentBackgroundTransparency = trans
        currentBgDimming = val
        if setCurrentBackgroundTransparency then
            pcall(setCurrentBackgroundTransparency, trans)
        end
        if Window.SetBackgroundImageTransparency then
            pcall(function() Window:SetBackgroundImageTransparency(trans) end)
        end
        DarlingHub.FeatureStates["BackgroundDimming"] = val
        triggerAutoSave()
    end
})
DarlingHub.UIElements["BackgroundDimming"] = bgDimmingSlider
DarlingHub.DefaultValues["BackgroundDimming"] = 25
DarlingHub.FeatureStates["BackgroundDimming"] = 25

PersonalizationTab:Dropdown({
    Title = "Media Scale Mode",
        Icon = "maximize-2",
    Values = { "Crop (Original)", "Stretch (Fill Window)", "Fit (Contain)" },
    Default = "Crop (Original)",
    Callback = function(mode)
        if mode:find("Fit") then
            currentScaleType = Enum.ScaleType.Fit
        elseif mode:find("Stretch") then
            currentScaleType = Enum.ScaleType.Stretch
        else
            currentScaleType = Enum.ScaleType.Crop
        end

        pcall(function()
            local main = (Window.UIElements and Window.UIElements.Main) or Window.Frame
            local bg = main and main:FindFirstChild("Background")
            local wp = (bg and bg:FindFirstChild("DarlingWallpaper")) or (main and main:FindFirstChild("DarlingWallpaper"))
            local img = wp and wp:FindFirstChild("WallpaperImage")
            if img then img.ScaleType = currentScaleType end
        end)
    end
})

PersonalizationTab:Divider()

local function enforceBlackOpenButtonBorder()
    pcall(function()
        if DarlingHub and DarlingHub.StyleOpenButtonBorder then
            DarlingHub.StyleOpenButtonBorder(nil, darlingIcon)
        end
    end)
end

local function alignTopbarButtonsRight()
    pcall(function()
        local topbar = Window and Window.UIElements and Window.UIElements.Topbar
        if not topbar then return end
        local buttons = topbar:FindFirstChild("Buttons") or topbar:FindFirstChild("ButtonsContainer")
        if buttons and buttons:IsA("GuiObject") then
            buttons.AnchorPoint = Vector2.new(1, 0.5)
            buttons.Position = UDim2.new(1, -10, 0.5, 0)
        end
    end)
end

PersonalizationTab:Toggle({
    Title = "Top Floating Toggle Widget",
        Icon = "layout-grid",
    Desc = "Displays WindUI open button when minimized",
    Value = true,
    Callback = function(state)
        allowFloatingWidget = state
        pcall(function()
            if Window.EditOpenButton then
                Window:EditOpenButton({
                    Enabled = state,
                    OnlyMobile = false,
                    Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0))
                })
            end
            enforceBlackOpenButtonBorder()
        end)
    end
})

PersonalizationTab:Divider()

local defaultScaleRatio = (DarlingHub.GetOptimalUIScale and DarlingHub.GetOptimalUIScale())
    or DarlingHub.DefaultUIScale
    or context.initialScale
    or (context.isMobile and 0.65 or 1.0)
if (context.isMobile or UserInputService.TouchEnabled) and defaultScaleRatio > 0.70 then
    defaultScaleRatio = 0.65
end
local defaultScalePercent = math.clamp(math.floor((defaultScaleRatio * 100) / 5 + 0.5) * 5, 50, 130)

local uiScaleSlider = PersonalizationTab:Slider({
    Title = "UI Scale",
        Icon = "maximize-2",
    Width = 200,
    Value = {
        Min = 50,
        Max = 130,
        Default = defaultScalePercent,
    },
    Step = 5,
    Callback = function(val)
        local scaleValue = val / 100
        pcall(function()
            if Window.SetUIScale then
                Window:SetUIScale(scaleValue)
            end
            if WindUI.UIScaleObj then
                WindUI.UIScaleObj.Scale = scaleValue
            end
            WindUI.UIScale = scaleValue
        end)
    end
})
DarlingHub.UIElements["UIScale"] = uiScaleSlider
DarlingHub.UIElements["UI Scale"] = uiScaleSlider
DarlingHub.DefaultValues["UI Scale"] = defaultScalePercent
DarlingHub.DefaultValues["UIScale"] = defaultScalePercent
DarlingHub.FeatureStates["UI Scale"] = defaultScalePercent
DarlingHub.FeatureStates["UIScale"] = defaultScalePercent

PersonalizationTab:Toggle({
    Title = "Align Topbar Buttons Right",
        Icon = "align-right",
    Value = true,
    Callback = function(state)
        if state then
            alignTopbarButtonsRight()
        end
    end
})

-- ========================================================================

    return PersonalizationTab
end
