--[[
    Darling Hub - skins_tab.lua (Version 1.3)
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

-- 6. SKINS TAB
-- ========================================================================
local SkinsTab = Window:Tab({
    Title = "Skins",
    Icon = "shirt"
})
enhanceTabScrolling(SkinsTab)

local SkinsMod = nil
local function getSkinsMod()
    if not SkinsMod then
        SkinsMod = DarlingHub:Require("modules/visuals/skins_system.lua")
    end
    return SkinsMod
end

-- ------------------------------------------------------------------------
-- SECTION 1: VFX & SKILL COLORS
-- ------------------------------------------------------------------------
SkinsTab:Paragraph({
    Title = "VFX & Skill Colors",
    Desc = "Recolor Blox Fruits combat effects, sword slashes, aura highlights, and ground particles",
    Image = "sparkles"
})

SkinsTab:Toggle({
    Title = "Darling VFX Engine",
    Desc = "Master switch to dynamically recolor combat particles",
    Value = false,
    Callback = function(state)
        local mod = getSkinsMod()
        if mod then
            mod.setVFXEnabled(state)
            WindUI:Notify({
                Title = "VFX Engine",
                Content = state and "Darling VFX Enabled" or "Darling VFX Disabled",
                Duration = 2,
                Icon = darlingIcon
            })
        end
    end
})

SkinsTab:Dropdown({
    Title = "VFX Color Preset",
    Values = {
        "Purple", "Red", "Blue", "Cyan", "Green", "Gold",
        "Pink", "Magenta", "White", "Black", "Midnight", "Orange",
        "Crimson", "Lime", "Silver", "Teal", "Ice Blue"
    },
    Default = "Purple",
    Callback = function(preset)
        local mod = getSkinsMod()
        if mod then
            local col = mod.Presets[preset] or Color3.fromRGB(165, 80, 235)
            mod.setVFXColor(col)
            WindUI:Notify({
                Title = "VFX Color",
                Content = "VFX color set to " .. preset,
                Duration = 2,
                Icon = darlingIcon
            })
        end
    end
})

SkinsTab:Toggle({
    Title = "Affect Skills",
    Desc = "Recolors fruit and fighting style particle emitters",
    Value = true,
    Callback = function(state)
        local mod = getSkinsMod()
        if mod then
            mod.VFX.AffectSkills = state
            if mod.VFX.Enabled then mod.refreshAllVFX() end
        end
    end
})

SkinsTab:Toggle({
    Title = "Affect Swords",
    Desc = "Recolors sword slash highlights and trails",
    Value = true,
    Callback = function(state)
        local mod = getSkinsMod()
        if mod then
            mod.VFX.AffectSwords = state
            if mod.VFX.Enabled then mod.refreshAllVFX() end
        end
    end
})

SkinsTab:Toggle({
    Title = "Affect Transform",
    Desc = "Recolors Buddha, Dragon, and V4 aura highlights",
    Value = true,
    Callback = function(state)
        local mod = getSkinsMod()
        if mod then
            mod.VFX.AffectTransform = state
            if mod.VFX.Enabled then mod.refreshAllVFX() end
        end
    end
})

SkinsTab:Toggle({
    Title = "Affect Environment",
    Desc = "Recolors world origin ground effects",
    Value = false,
    Callback = function(state)
        local mod = getSkinsMod()
        if mod then
            mod.VFX.AffectEnvironment = state
            if mod.VFX.Enabled then mod.refreshAllVFX() end
        end
    end
})

SkinsTab:Button({
    Title = "Reset Original VFX",
    Desc = "Restores all skill and combat particles back to default colors",
    Callback = function()
        local mod = getSkinsMod()
        if mod then
            mod.setVFXEnabled(false)
            WindUI:Notify({
                Title = "VFX Reset",
                Content = "All particles restored to original colors",
                Duration = 2,
                Icon = darlingIcon
            })
        end
    end
})

SkinsTab:Divider()

-- ------------------------------------------------------------------------
-- SECTION 2: TOOL SKINS & HOTBAR
-- ------------------------------------------------------------------------
SkinsTab:Paragraph({
    Title = "Tool Skins & Hotbar",
    Desc = "Custom cosmetics for Fruits, Swords, Guns, Melee and Hotbar icons",
    Image = "swords"
})

local selectedCategory = "Fruits"
local selectedSkinPreset = "Purple"

SkinsTab:Dropdown({
    Title = "Equipment Category",
    Values = { "Fruits", "Swords", "Guns", "Melee" },
    Default = "Fruits",
    Callback = function(cat)
        selectedCategory = cat
        local mod = getSkinsMod()
        if mod then mod.Tools.SelectedCategory = cat end
    end
})

SkinsTab:Dropdown({
    Title = "Skin Preset Catalog",
    Values = {
        "White", "Black", "Purple", "Red", "Blue", "Cyan",
        "Green", "Gold", "Pink", "Orange", "Crimson", "Lime",
        "Magenta", "Midnight", "Silver"
    },
    Default = "Purple",
    Callback = function(preset)
        selectedSkinPreset = preset
    end
})

SkinsTab:Input({
    Title = "Custom Asset ID (Optional)",
    Desc = "Override tool or hotbar icon with custom asset",
    Placeholder = "e.g. rbxassetid://106579555405966",
    Value = "",
    Callback = function(val)
        local mod = getSkinsMod()
        if mod then mod.Tools.CustomAssetId = val or "" end
    end
})

SkinsTab:Button({
    Title = "Apply Skin to Category",
    Desc = "Applies chosen skin to hotbar icon and held weapon mesh",
    Callback = function()
        local mod = getSkinsMod()
        if mod then
            local cat = tostring(selectedCategory or "Category")
            local pr = tostring(selectedSkinPreset or "Preset")
            mod.applyToolSkin(cat, pr)
            WindUI:Notify({
                Title = cat .. " Skin",
                Content = pr .. " applied to " .. cat .. " and hotbar!",
                Duration = 2.5,
                Icon = darlingIcon
            })
        end
    end
})

SkinsTab:Button({
    Title = "Apply Skin to All Hotbar Slots & Tools",
    Desc = "Recolors every slot in your hotbar and all weapons in inventory",
    Callback = function()
        local mod = getSkinsMod()
        if mod then
            local pr = tostring(selectedSkinPreset or "Preset")
            local count = mod.recolorAllHotbarSlots(pr)
            WindUI:Notify({
                Title = "Hotbar & Tools Skin",
                Content = pr .. " applied to " .. tostring(count) .. " slots and inventory!",
                Duration = 2.5,
                Icon = darlingIcon
            })
        end
    end
})

SkinsTab:Button({
    Title = "Reset Category Skin",
    Desc = "Removes custom skin and restores default hotbar icon for selected category",
    Callback = function()
        local mod = getSkinsMod()
        if mod then
            mod.resetCategoryToolSkin(selectedCategory)
            WindUI:Notify({
                Title = selectedCategory .. " Skin",
                Content = selectedCategory .. " skin reset to default",
                Duration = 2,
                Icon = darlingIcon
            })
        end
    end
})

SkinsTab:Button({
    Title = "Reset All Tool Skins",
    Desc = "Restores all weapon skins and hotbar slots back to default",
    Callback = function()
        local mod = getSkinsMod()
        if mod then
            mod.resetAllToolSkins()
            WindUI:Notify({
                Title = "Skins Reset",
                Content = "All categories and hotbar slots reset",
                Duration = 2,
                Icon = darlingIcon
            })
        end
    end
})

SkinsTab:Divider()

-- ------------------------------------------------------------------------
-- SECTION 3: CHARACTER SKIN CHANGER
-- ------------------------------------------------------------------------
SkinsTab:Paragraph({
    Title = "Character Skin Changer",
    Desc = "Recolor character body parts, limb materials, and glowing particle auras",
    Image = "user"
})

local selectedCharPreset = "Darling Pink"

SkinsTab:Toggle({
    Title = "Enable Character Skin Changer",
    Desc = "Overrides character body parts with chosen skin color and styling",
    Value = false,
    Callback = function(state)
        local mod = getSkinsMod()
        if mod then
            if state then
                mod.applyCharacterSkin(selectedCharPreset)
                WindUI:Notify({
                    Title = "Character Skin",
                    Content = "Character skin applied (" .. tostring(selectedCharPreset or "Default") .. ")",
                    Duration = 2,
                    Icon = darlingIcon
                })
            else
                mod.resetCharacterSkin()
                WindUI:Notify({
                    Title = "Character Skin",
                    Content = "Character appearance restored",
                    Duration = 2,
                    Icon = darlingIcon
                })
            end
        end
    end
})

SkinsTab:Dropdown({
    Title = "Character Tone Preset",
    Values = {
        "Darling Pink", "White", "Black", "Gold", "Cyan",
        "Crimson", "Green", "Purple", "Silver", "Orange"
    },
    Default = "Darling Pink",
    Callback = function(preset)
        selectedCharPreset = preset
        local mod = getSkinsMod()
        if mod and mod.Character.Enabled then
            mod.applyCharacterSkin(preset)
        end
    end
})

SkinsTab:Dropdown({
    Title = "Character Material",
    Values = { "SmoothPlastic", "Neon", "ForceField", "Glass" },
    Default = "SmoothPlastic",
    Callback = function(matName)
        local mod = getSkinsMod()
        if mod then
            mod.Character.Material = Enum.Material[matName] or Enum.Material.SmoothPlastic
            if mod.Character.Enabled then
                mod.applyCharacterSkin(selectedCharPreset)
            end
        end
    end
})

SkinsTab:Toggle({
    Title = "Character Particle Aura",
    Desc = "Generates a glowing aura highlight matching your active character skin",
    Value = false,
    Callback = function(state)
        local mod = getSkinsMod()
        if mod then
            mod.setAuraEnabled(state)
        end
    end
})

SkinsTab:Button({
    Title = "Reset Character Appearance",
    Desc = "Restores your original character appearance and limb colors",
    Callback = function()
        local mod = getSkinsMod()
        if mod then
            mod.resetCharacterSkin()
            WindUI:Notify({
                Title = "Character Skin",
                Content = "Character restored to original appearance",
                Duration = 2,
                Icon = darlingIcon
            })
        end
    end
})

SkinsTab:Divider()

SkinsTab:Paragraph({
    Title = "Avatar Cloner",
    Desc = "Clone the avatar appearance, accessories, and clothes of players",
    Image = "users"
})

SkinsTab:Button({
    Title = "Clone Nearest Player",
    Desc = "Finds closest player in server and clones their avatar",
    Callback = function()
        local mod = getSkinsMod()
        if mod then
            local ok, msg = mod.cloneNearestPlayer()
            WindUI:Notify({
                Title = "Avatar Cloner",
                Content = msg or (ok and "Cloned nearest player avatar!" or "Failed to clone avatar"),
                Duration = 3,
                Icon = darlingIcon
            })
        end
    end
})

local cloneTargetInput = ""
SkinsTab:Input({
    Title = "Player Name or ID",
    Desc = "Enter Roblox username or numeric User ID to clone",
    Placeholder = "e.g. 12345678 or PlayerName",
    Value = "",
    Callback = function(val)
        cloneTargetInput = val or ""
    end
})

SkinsTab:Button({
    Title = "Clone Player",
    Desc = "Loads and clones the avatar for the specified User ID or Name",
    Callback = function()
        if cloneTargetInput == "" then
            WindUI:Notify({
                Title = "Avatar Cloner",
                Content = "Please enter a valid Username or User ID first.",
                Duration = 2.5,
                Icon = darlingIcon
            })
            return
        end
        local mod = getSkinsMod()
        if mod then
            local ok, msg = mod.cloneByUserId(cloneTargetInput)
            WindUI:Notify({
                Title = "Avatar Cloner",
                Content = msg or (ok and "Applied target avatar!" or "Failed to load avatar"),
                Duration = 3,
                Icon = darlingIcon
            })
        end
    end
})

SkinsTab:Button({
    Title = "Reset Avatar",
    Desc = "Restores your original avatar appearance",
    Callback = function()
        local mod = getSkinsMod()
        if mod and mod.resetClonedAvatar then
            local ok, msg = mod.resetClonedAvatar()
            WindUI:Notify({
                Title = "Avatar Cloner",
                Content = msg or (ok and "Original avatar restored!" or "Failed to reset avatar"),
                Duration = 2.5,
                Icon = darlingIcon
            })
        end
    end
})


-- ========================================================================

    return SkinsTab
end
