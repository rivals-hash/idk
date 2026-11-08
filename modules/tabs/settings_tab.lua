--[[
    Darling Hub - settings_tab.lua (Version 1.3)
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
    local currentBackgroundTransparency = context.currentBackgroundTransparency
    local updateVideoRenderSize = context.updateVideoRenderSize
    local safeResolveUserIdentifier = context.safeResolveUserIdentifier
    local allowFloatingWidget = context.allowFloatingWidget
    local toggleHub = context.toggleHub
    local currentToggleKey = context.currentToggleKey
    local WindUI = context.WindUI
    local TabTranslations = context.TabTranslations
    local Translations = context.Translations

-- 10. SETTINGS TAB (SAVE CONFIG & MULTI-LANGUAGE)
-- ===================================================
local SupportedLanguages = { "English", "Español", "Français", "Tiếng Việt", "Português" }

local function updateElementVisualLabels(el, tTitle, tDesc, reg)
    if not el then return end
    pcall(function()
        if el.SetTitle and tTitle then pcall(function() el:SetTitle(tTitle) end) end
        if el.SetDesc and tDesc then pcall(function() el:SetDesc(tDesc) end) end
        if el.UIElements then
            if tTitle and el.UIElements.Title and el.UIElements.Title:IsA("TextLabel") then
                el.UIElements.Title.Text = tTitle
            end
            if tDesc and el.UIElements.Desc and el.UIElements.Desc:IsA("TextLabel") then
                el.UIElements.Desc.Text = tDesc
            end
        end
        local root = (el.UIElements and el.UIElements.Main) or el.Main or el.Frame or el.Instance or el.Holder
        if root and root:IsA("Instance") then
            for _, desc in ipairs(root:GetDescendants()) do
                if desc:IsA("TextLabel") then
                    if reg and reg.TitleKey and (desc.Text == reg.LastTitle or desc.Text == reg.TitleKey) then
                        if tTitle then desc.Text = tTitle end
                    elseif reg and reg.DescKey and (desc.Text == reg.LastDesc or desc.Text == reg.DescKey) then
                        if tDesc then desc.Text = tDesc end
                    end
                end
            end
        end
    end)
    if reg then
        if tTitle then reg.LastTitle = tTitle end
        if tDesc then reg.LastDesc = tDesc end
    end
end

local function setTabLabel(tab, newTitle)
    if not tab or not newTitle then return end
    tab.Title = newTitle
    pcall(function()
        if tab.SetTitle then
            tab:SetTitle(newTitle)
            return
        end
        local function checkLabels(root)
            if not root then return false end
            for _, desc in ipairs(root:GetDescendants()) do
                if desc:IsA("TextLabel") then
                    if desc.Name == "Title" or desc.Name == "Text" or desc.Name == "Label" then
                        desc.Text = newTitle
                        return true
                    end
                end
            end
            for _, desc in ipairs(root:GetDescendants()) do
                if desc:IsA("TextLabel") then
                    desc.Text = newTitle
                    return true
                end
            end
            return false
        end

        if tab.Button and checkLabels(tab.Button) then return end
        if tab.TabButton and checkLabels(tab.TabButton) then return end
        if tab.UIElements and tab.UIElements.Button and checkLabels(tab.UIElements.Button) then return end
        if tab.UIElements and tab.UIElements.Main and checkLabels(tab.UIElements.Main) then return end
    end)
end

local LanguageDropdown = nil

local function applyLanguage(lang)
    if type(lang) == "table" then
        lang = lang[1] or lang.Value or lang.Title
    end
    if not lang then return end
    currentLanguage = lang
    if getgenv then pcall(function() getgenv().DarlingLanguage = lang end) end
    if _G then pcall(function() _G.DarlingLanguage = lang end) end

    local hub = _G.DarlingHub or (getgenv and getgenv().DarlingHub)
    if hub and hub.ApplyLanguage and hub.ApplyLanguage ~= applyLanguage then
        pcall(hub.ApplyLanguage, lang)
    end
end

local CONFIG_FOLDER = "darling_hub"
local PRIMARY_CONFIG = "darling_hub/config.json"
local FALLBACK_CONFIG = "darling_config.json"

local function ensureConfigFolder()
    pcall(function()
        if makefolder and isfolder and not isfolder(CONFIG_FOLDER) then
            makefolder(CONFIG_FOLDER)
        end
    end)
end

local function serializeTable(tbl)
    if type(tbl) ~= "table" then return tbl end
    local out = {}
    for k, v in pairs(tbl) do
        local vt = typeof(v)
        if vt == "Color3" then
            out[k] = { __type = "Color3", R = v.R, G = v.G, B = v.B }
        elseif vt == "Vector2" then
            out[k] = { __type = "Vector2", X = v.X, Y = v.Y }
        elseif vt == "Vector3" then
            out[k] = { __type = "Vector3", X = v.X, Y = v.Y, Z = v.Z }
        elseif vt == "table" then
            out[k] = serializeTable(v)
        elseif vt == "number" or vt == "string" or vt == "boolean" then
            out[k] = v
        end
    end
    return out
end

local function deserializeTable(tbl)
    if type(tbl) ~= "table" then return tbl end
    if tbl.__type == "Color3" and tbl.R and tbl.G and tbl.B then
        return Color3.new(tbl.R, tbl.G, tbl.B)
    elseif tbl.__type == "Vector2" and tbl.X and tbl.Y then
        return Vector2.new(tbl.X, tbl.Y)
    elseif tbl.__type == "Vector3" and tbl.X and tbl.Y and tbl.Z then
        return Vector3.new(tbl.X, tbl.Y, tbl.Z)
    end
    local out = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            out[k] = deserializeTable(v)
        else
            out[k] = v
        end
    end
    return out
end

saveHubConfig = function()
    ensureConfigFolder()
    local cfg = {
        Language = currentLanguage,
        Keybind = currentToggleKey and currentToggleKey.Name or "F",
        AutoSave = autoSaveConfig,
        AutoLoad = autoLoadConfig,
        Theme = currentSelectedTheme or "Dark",
        BackgroundMedia = lastEnteredBackgroundInput or "",
        BackgroundDimming = currentBgDimming or 25,
        BackgroundBlur = currentBgBlur or 0,
        BackgroundTransparency = currentBackgroundTransparency or 0.25,
        Settings = serializeTable(DarlingHub.Settings or {}),
        Features = (function()
            local sf = serializeTable(DarlingHub.FeatureStates or {})
            for fk, _ in pairs(sf) do
                local lk = string.lower(tostring(fk))
                if lk:find("dragon") or (lk:find("gun") and not lk:find("weapon")) or lk:find("fruitfast") or lk:find("oneshot") or lk:find("floating") then
                    sf[fk] = false
                end
            end
            return sf
        end)(),
        Skins = {
            SelectedCategory = selectedCategory or "Fruits",
            SelectedPreset = selectedSkinPreset or "Purple",
        }
    }
    pcall(function()
        local sMod = DarlingHub.Modules["modules/visuals/skins_system.lua"]
        if sMod then
            cfg.Skins.VFXEnabled = sMod.VFX and sMod.VFX.Enabled
            cfg.Skins.CharacterSkin = sMod.Character and sMod.Character.ActivePreset
            cfg.Skins.AuraEnabled = sMod.Character and sMod.Character.AuraEnabled
        end
    end)
    pcall(function()
        local mMod = DarlingHub.Modules["modules/utility/music_engine.lua"]
        if mMod and mMod.Favorites then
            cfg.MusicFavorites = mMod.Favorites
        end
    end)

    local writeFunc = writefile or exWriteFile or (syn and syn.writefile)
    if writeFunc then
        local okJson, json = pcall(function() return HttpService:JSONEncode(cfg) end)
        if not okJson or not json then
            return false, "JSON encode failed: " .. tostring(json)
        end
        local saveOk = false
        local lastErr = nil

        -- 1. Always write to FALLBACK_CONFIG in root workspace ("darling_config.json")
        local okF, errF = pcall(function()
            writeFunc(FALLBACK_CONFIG, json)
        end)
        if okF then
            saveOk = true
        else
            lastErr = errF
        end

        -- 2. Also write to PRIMARY_CONFIG ("darling_hub/config.json")
        pcall(function()
            if makefolder and isfolder and not isfolder(CONFIG_FOLDER) then
                pcall(makefolder, CONFIG_FOLDER)
            end
            writeFunc(PRIMARY_CONFIG, json)
            saveOk = true
        end)

        return saveOk, lastErr
    end
    return false, "writefile not supported on this executor"
end

loadHubConfig = function(silent)
    local readFunc = readfile or (syn and syn.readfile)
    if not readFunc then
        return false, "readfile not supported on this executor"
    end

    local raw = nil
    for _, path in ipairs({ FALLBACK_CONFIG, PRIMARY_CONFIG, "darling_hub_config.json" }) do
        local okR, content = pcall(function() return readFunc(path) end)
        if okR and type(content) == "string" and #content > 5 then
            raw = content
            break
        end
    end

    if not raw then
        return false, "No saved config found"
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if not ok or type(data) ~= "table" then
        return false, "Invalid config data"
    end

    isLoadingConfig = true
    DarlingHub.IsLoadingConfig = true
    pcall(function()
        if data.Language and Translations[data.Language] then
            applyLanguage(data.Language)
            if LanguageDropdown and LanguageDropdown.Select then
                pcall(function() LanguageDropdown:Select(data.Language) end)
            end
        end
        if data.Keybind and Enum.KeyCode[data.Keybind] then
            currentToggleKey = Enum.KeyCode[data.Keybind]
        end
        if data.AutoSave ~= nil then
            autoSaveConfig = (data.AutoSave == true)
            if DarlingHub.UIElements["AutoSave"] and DarlingHub.UIElements["AutoSave"].Set then
                pcall(function() DarlingHub.UIElements["AutoSave"]:Set(autoSaveConfig) end)
            end
        end
        if data.AutoLoad ~= nil then
            autoLoadConfig = (data.AutoLoad == true)
            if DarlingHub.UIElements["AutoLoad"] and DarlingHub.UIElements["AutoLoad"].Set then
                pcall(function() DarlingHub.UIElements["AutoLoad"]:Set(autoLoadConfig) end)
            end
        end
        if data.Theme and WindUI then
            currentSelectedTheme = data.Theme
            pcall(function() WindUI:SetTheme(data.Theme) end)
            if ThemeDropdown and ThemeDropdown.Select then
                pcall(function() ThemeDropdown:Select(data.Theme) end)
            end
        end
        if data.BackgroundMedia and data.BackgroundMedia ~= "" then
            lastEnteredBackgroundInput = data.BackgroundMedia
            if DarlingHub.SetBackgroundInput then
                pcall(DarlingHub.SetBackgroundInput, data.BackgroundMedia)
            end
            if bgInputObj and bgInputObj.Set then
                pcall(function() bgInputObj:Set(data.BackgroundMedia) end)
            end
            task.spawn(function()
                processAndApplyMediaInput(data.BackgroundMedia)
            end)
        end
        if data.Features and data.Features["BackgroundPreset"] and data.Features["BackgroundPreset"] ~= "" and data.Features["BackgroundPreset"] ~= "None / Cleared" then
            local preset = data.Features["BackgroundPreset"]
            if DarlingHub.UIElements["BackgroundPreset"] and DarlingHub.UIElements["BackgroundPreset"].Select then
                pcall(function() DarlingHub.UIElements["BackgroundPreset"]:Select(preset) end)
            end
        end
        if data.BackgroundDimming ~= nil then
            currentBgDimming = data.BackgroundDimming
            currentBackgroundTransparency = (tonumber(data.BackgroundDimming) or 25) / 100
            if DarlingHub.SetBackgroundTransparency then
                pcall(DarlingHub.SetBackgroundTransparency, currentBackgroundTransparency)
            end
            if Window.SetBackgroundImageTransparency then
                pcall(function() Window:SetBackgroundImageTransparency(currentBackgroundTransparency) end)
            end
            if DarlingHub.UIElements["BackgroundDimming"] and DarlingHub.UIElements["BackgroundDimming"].Set then
                pcall(function() DarlingHub.UIElements["BackgroundDimming"]:Set(tonumber(data.BackgroundDimming) or 25) end)
            end
        end
        if data.Settings and type(data.Settings) == "table" then
            local restored = deserializeTable(data.Settings)
            if DarlingHub.Settings then
                for k, v in pairs(restored) do
                    if type(v) == "table" and type(DarlingHub.Settings[k]) == "table" then
                        for subK, subV in pairs(v) do
                            DarlingHub.Settings[k][subK] = subV
                        end
                    else
                        DarlingHub.Settings[k] = v
                    end
                end
            end
        end
        if data.Features and type(data.Features) == "table" then
            DarlingHub.FeatureStates = DarlingHub.FeatureStates or {}
            local restoredFeatures = deserializeTable(data.Features)
            local optimalScale = (DarlingHub.GetOptimalUIScale and DarlingHub.GetOptimalUIScale()) or 0.65
            if (UserInputService.TouchEnabled or context.isMobile) and optimalScale > 0.70 then
                optimalScale = 0.65
            end
            local maxAllowedPercent = math.clamp(math.floor((optimalScale * 100) / 5 + 0.5) * 5, 50, 130)
            local isTouch = UserInputService.TouchEnabled or context.isMobile

            local function shouldFilterStartupKey(name)
                local s = string.lower(tostring(name))
                if s:find("dragon") or s:find("gun") then return true end
                if s:find("fruit") then return true end
                if s:find("fastattack") or s:find("fast attack") then return true end
                if s:find("oneshot") or s:find("one shot") or s:find("kitsune") then return true end
                if s:find("bounty") or s:find("hunt auto") then return true end
                if s:find("floating") or s:find("widget") then return true end
                return false
            end

            local applyCount = 0
            for k, v in pairs(restoredFeatures) do
                applyCount = applyCount + 1
                if applyCount % 20 == 0 then
                    task.wait()
                end
                if silent == true and shouldFilterStartupKey(k) then
                    v = false
                end
                if k == "UI Scale" or k == "UIScale" then
                    local numV = tonumber(v) or maxAllowedPercent
                    if isTouch then
                        numV = math.min(numV, maxAllowedPercent)
                    end
                    numV = math.clamp(numV, 50, 130)
                    v = numV
                end
                DarlingHub.FeatureStates[k] = v
                if DarlingHub.UIElements and DarlingHub.UIElements[k] then
                    local el = DarlingHub.UIElements[k]
                    pcall(function()
                        if el.Set then
                            el:Set(v)
                        elseif el.Select then
                            el:Select(v)
                        end
                    end)
                elseif DarlingHub.FeatureSetters and DarlingHub.FeatureSetters[k] then
                    pcall(DarlingHub.FeatureSetters[k], v)
                end
            end
        end
        pcall(function()
            if Window and Window.SetToTheCenter then
                Window:SetToTheCenter()
            end
        end)
        if data.Skins and type(data.Skins) == "table" then
            if data.Skins.SelectedCategory then
                selectedCategory = data.Skins.SelectedCategory
            end
            if data.Skins.SelectedPreset then
                selectedSkinPreset = data.Skins.SelectedPreset
            end
        end
    end)
    task.delay(0.2, function()
        isLoadingConfig = false
        DarlingHub.IsLoadingConfig = false
    end)
    return true, data
end

local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "sliders"
})
enhanceTabScrolling(SettingsTab)

SettingsTab:Paragraph({
    Title = "Configuration & Localization",
    Desc = "Save all settings across sessions and change the interface language",
    Image = "settings"
})

LanguageDropdown = SettingsTab:Dropdown({
    Title = "Interface Language",
    Desc = "Select language: English, Español, Français, Tiếng Việt, Português",
    Values = SupportedLanguages,
    Default = "English",
    Callback = function(lang)
        if type(lang) == "table" then
            lang = lang[1] or lang.Value or lang.Title
        end
        if type(lang) == "string" and #lang > 0 then
            applyLanguage(lang)
            local hub = _G.DarlingHub or (getgenv and getgenv().DarlingHub)
            if hub and hub.ApplyLanguage then
                pcall(hub.ApplyLanguage, lang)
            end
            if not (isLoadingConfig or DarlingHub.IsLoadingConfig) then
                WindUI:Notify({
                    Title = tr("Language", lang),
                    Content = tr("LanguageChanged", lang),
                    Duration = 2.5,
                    Icon = darlingIcon
                })
                if autoSaveConfig then
                    saveHubConfig()
                end
            end
        end
    end
})

SettingsTab:Button({
    Title = "Save Configuration",
    Desc = "Saves all Darling Hub settings, themes, skins, and binds to darling_hub/config.json",
    Callback = function()
        local ok, err = saveHubConfig()
        if ok then
            WindUI:Notify({
                Title = tr("SaveConfig"),
                Content = tr("ConfigSaved"),
                Duration = 3,
                Icon = "check"
            })
        else
            WindUI:Notify({
                Title = tr("SaveConfig"),
                Content = "Failed to save: " .. tostring(err),
                Duration = 3,
                Icon = "alert-triangle"
            })
        end
    end
})

SettingsTab:Button({
    Title = "Load Configuration",
    Desc = "Loads previously saved configuration from disk",
    Callback = function()
        local ok, data = loadHubConfig()
        if ok then
            WindUI:Notify({
                Title = tr("LoadConfig"),
                Content = tr("ConfigLoaded"),
                Duration = 3,
                Icon = "check"
            })
        else
            WindUI:Notify({
                Title = tr("LoadConfig"),
                Content = tostring(data or tr("ConfigFailed")),
                Duration = 3,
                Icon = "alert-triangle"
            })
        end
    end
})

local autoSaveToggle = SettingsTab:Toggle({
    Title = "Auto-Save Configuration",
        Icon = "save",
    Desc = "Automatically saves your configuration on changes",
    Value = true,
    Callback = function(state)
        autoSaveConfig = state
        if state and saveHubConfig then
            saveHubConfig()
        end
    end
})
DarlingHub.UIElements["AutoSave"] = autoSaveToggle

local autoLoadToggle = SettingsTab:Toggle({
    Title = "Auto-Load on Startup",
        Icon = "download",
    Desc = "Automatically restores saved configuration when Darling Hub starts",
    Value = true,
    Callback = function(state)
        autoLoadConfig = state
        triggerAutoSave()
    end
})
DarlingHub.UIElements["AutoLoad"] = autoLoadToggle

SettingsTab:Divider()

SettingsTab:Keybind({
    Title = "Hub Toggle Shortcut",
        Icon = "keyboard",
    Desc = "Click to rebind. Press anywhere to toggle the Hub",
    Value = "F",
    Callback = function(keyName)
        if _G.DarlingIsCastingSkill then return end
        if typeof(keyName) == "EnumItem" then
            currentToggleKey = keyName
        elseif type(keyName) == "string" and Enum.KeyCode[keyName] then
            currentToggleKey = Enum.KeyCode[keyName]
        end
        if autoSaveConfig then
            saveHubConfig()
        end
        local now = tick()
        if now - lastToggleTick >= 0.3 then
            lastToggleTick = now
            toggleHub()
        end
    end
})

SettingsTab:Button({
    Title = "Toggle Visibility Now",
        Icon = "eye",
    Callback = function()
        toggleHub()
    end
})

SettingsTab:Divider()

SettingsTab:Button({
    Title = "Reset Default Settings",
    Callback = function()
        isLoadingConfig = true
        DarlingHub.IsLoadingConfig = true

        -- 1. Reset all registered UI elements to their defaults
        if DarlingHub.UIElements then
            for k, el in pairs(DarlingHub.UIElements) do
                local def = DarlingHub.DefaultValues and DarlingHub.DefaultValues[k]
                if def == nil and el then
                    if el.__darlingDefault ~= nil then
                        def = el.__darlingDefault
                    elseif el.__darlingType == "Toggle" or el.Type == "Toggle" then
                        def = false
                    elseif el.__darlingType == "Slider" or el.Type == "Slider" then
                        def = (el.Value and type(el.Value) == "table" and (el.Value.Default or el.Value.Min)) or 0
                    elseif (el.__darlingType == "Dropdown" or el.Type == "Dropdown" or el.Select) and el.Values then
                        def = el.Values[1]
                    elseif type(el.Value) == "boolean" then
                        def = false
                    elseif type(el.Value) == "number" then
                        def = 0
                    end
                end
                if def ~= nil and el then
                    DarlingHub.FeatureStates[k] = def
                    pcall(function()
                        if el.Set then
                            el:Set(def)
                        elseif el.Select then
                            el:Select(def)
                        end
                    end)
                end
            end
        end

        -- Explicitly enforce the device's optimal responsive UI scale on reset
        local optimalScale = (DarlingHub.GetOptimalUIScale and DarlingHub.GetOptimalUIScale())
            or DarlingHub.DefaultUIScale
            or (context.isMobile and 0.65 or 1.0)
        if (UserInputService.TouchEnabled or context.isMobile) and optimalScale > 0.70 then
            optimalScale = 0.65
        end
        local optimalPercent = math.clamp(math.floor((optimalScale * 100) / 5 + 0.5) * 5, 50, 130)
        DarlingHub.DefaultValues["UI Scale"] = optimalPercent
        DarlingHub.DefaultValues["UIScale"] = optimalPercent
        DarlingHub.FeatureStates["UI Scale"] = optimalPercent
        DarlingHub.FeatureStates["UIScale"] = optimalPercent

        pcall(function()
            if DarlingHub.UIElements["UI Scale"] and DarlingHub.UIElements["UI Scale"].Set then
                DarlingHub.UIElements["UI Scale"]:Set(optimalPercent)
            elseif DarlingHub.UIElements["UIScale"] and DarlingHub.UIElements["UIScale"].Set then
                DarlingHub.UIElements["UIScale"]:Set(optimalPercent)
            end
            if Window.SetUIScale then
                Window:SetUIScale(optimalScale)
            end
            if WindUI.UIScaleObj then
                WindUI.UIScaleObj.Scale = optimalScale
            end
            WindUI.UIScale = optimalScale
            if Window.SetToTheCenter then
                Window:SetToTheCenter()
            end
        end)

        -- 2. Cleanly stop/disable all running modules and reset auto bounty config
        pcall(function() DarlingHub:DisableAllModules() end)
        pcall(function()
            local abMod = DarlingHub.Modules and DarlingHub.Modules["modules/combat/auto_bounty.lua"]
            if abMod and abMod.resetConfig then
                abMod.resetConfig()
            end
        end)

        -- 3. Reset background to default (clean None / Cleared state)
        if DarlingHub.ClearActiveMedia then
            pcall(DarlingHub.ClearActiveMedia)
        elseif clearActiveMedia then
            pcall(clearActiveMedia)
        end
        if DarlingHub.SetBackgroundInput then
            pcall(DarlingHub.SetBackgroundInput, "")
        end
        lastEnteredBackgroundInput = ""
        DarlingHub.FeatureStates["BackgroundPreset"] = "None / Cleared"
        DarlingHub.DefaultValues["BackgroundPreset"] = "None / Cleared"
        if DarlingHub.UIElements["BackgroundPreset"] and DarlingHub.UIElements["BackgroundPreset"].Select then
            pcall(function() DarlingHub.UIElements["BackgroundPreset"]:Select("None / Cleared") end)
        end
        if bgInputObj and bgInputObj.Set then
            pcall(function() bgInputObj:Set("") end)
        end

        -- 4. Reset Theme, Language, Keybind, AutoSave, AutoLoad
        currentLanguage = "English"
        currentToggleKey = Enum.KeyCode.F
        autoSaveConfig = true
        autoLoadConfig = true
        currentSelectedTheme = "Normal / Dark"
        darlingIcon = darlingLogoNormal
        pcall(function() WindUI:SetTheme("Dark") end)
        if ThemeDropdown and ThemeDropdown.Select then
            pcall(function() ThemeDropdown:Select("Normal / Dark") end)
        end
        if LanguageDropdown and LanguageDropdown.Select then
            pcall(function() LanguageDropdown:Select("English") end)
        end
        applyLanguage("English")

        if DarlingHub.UIElements["AutoSave"] and DarlingHub.UIElements["AutoSave"].Set then
            pcall(function() DarlingHub.UIElements["AutoSave"]:Set(true) end)
        end
        if DarlingHub.UIElements["AutoLoad"] and DarlingHub.UIElements["AutoLoad"].Set then
            pcall(function() DarlingHub.UIElements["AutoLoad"]:Set(true) end)
        end
        if DarlingHub.UIElements["Hub Toggle Shortcut"] and DarlingHub.UIElements["Hub Toggle Shortcut"].Set then
            pcall(function() DarlingHub.UIElements["Hub Toggle Shortcut"]:Set("F") end)
        end

        -- 5. Overwrite the saved config on disk with clean default state
        if saveHubConfig then
            saveHubConfig()
        end
        isLoadingConfig = false
        DarlingHub.IsLoadingConfig = false

        WindUI:Notify({
            Title = "Settings Reset",
            Content = tr("ConfigReset"),
            Duration = 3,
            Icon = "rotate-ccw"
        })
    end
})

SettingsTab:Button({
    Title = "Unload Darling Hub",
        Icon = "power",
    Desc = "Closes and completely terminates Darling Hub",
    Callback = function()
        if autoSaveConfig then
            saveHubConfig()
        end
        pcall(function()
            allowFloatingWidget = false
            DarlingHub:UnloadAll()
            clearActiveMedia()
            if Window.EditOpenButton then
                Window:EditOpenButton({ Enabled = false })
            end
            if Window.OpenButtonMain then
                Window.OpenButtonMain:Visible(false)
            end
            if Window.Destroy then
                Window:Destroy()
            end
        end)
    end
})

-- ========================================================================

    DarlingHub.SaveConfig = saveHubConfig
    DarlingHub.LoadConfig = loadHubConfig

    return SettingsTab
end
