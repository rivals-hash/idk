--[[
    Darling Hub - visuals_tab.lua (Version 1.3)
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

-- 8. VISUALS TAB
-- ========================================================================
local VisualsTab = Window:Tab({
    Title = "Visuals",
    Icon = "eye"
})
enhanceTabScrolling(VisualsTab)

local function getVisualsMod(path)
    return DarlingHub:Require(path)
end

-- --- Player ESP & Multi-Tracers ---
VisualsTab:Toggle({
    Title = "2D Quad Boxes",
    Desc = "Renders cornered 2D bounding boxes around all enemy players",
    Value = false,
    Callback = function(state)
        local mod = getVisualsMod("modules/visuals/esp.lua")
        if mod then mod.setBoxes(state) end
    end
})

VisualsTab:Toggle({
    Title = "Player Names",
    Desc = "Displays formatted usernames directly above player heads",
    Value = false,
    Callback = function(state)
        local mod = getVisualsMod("modules/visuals/esp.lua")
        if mod then mod.setNames(state) end
    end
})

VisualsTab:Toggle({
    Title = "Health Bars",
    Desc = "Dynamic color-coded health status bar on the side of character bounding boxes",
    Value = false,
    Callback = function(state)
        local mod = getVisualsMod("modules/visuals/esp.lua")
        if mod then mod.setHealth(state) end
    end
})

VisualsTab:Toggle({
    Title = "Distance Indicator",
    Desc = "Displays live distance measurement in studs below player feet",
    Value = false,
    Callback = function(state)
        local mod = getVisualsMod("modules/visuals/esp.lua")
        if mod then mod.setDistance(state) end
    end
})

VisualsTab:Toggle({
    Title = "Equipped Tool / Weapon",
    Desc = "Shows current weapon, fruit, melee, or gun held by the player",
    Value = false,
    Callback = function(state)
        local mod = getVisualsMod("modules/visuals/esp.lua")
        if mod then mod.setTool(state) end
    end
})

VisualsTab:Toggle({
    Title = "Chams / Highlights",
    Desc = "Applies radiant silhouette highlights through walls over enemy models",
    Value = false,
    Callback = function(state)
        local mod = getVisualsMod("modules/visuals/esp.lua")
        if mod then mod.setChams(state) end
    end
})

VisualsTab:Toggle({
    Title = "Multi-Tracers (All Players)",
    Desc = "Draws dynamic snaplines connecting viewport origin to every player on the map",
    Value = false,
    Callback = function(state)
        local mod = getVisualsMod("modules/visuals/esp.lua")
        if mod then mod.setTracers(state) end
    end
})

VisualsTab:Dropdown({
    Title = "Tracer Line Color",
    Values = { "White", "Cyan", "Purple", "Green", "Yellow", "Orange", "Red", "Pink" },
    Value = "White",
    Callback = function(selected)
        local mod = getVisualsMod("modules/visuals/esp.lua")
        if mod then
            local colors = {
                ["White"] = Color3.fromRGB(255, 255, 255),
                ["Cyan"] = Color3.fromRGB(56, 189, 248),
                ["Purple"] = Color3.fromRGB(192, 132, 252),
                ["Green"] = Color3.fromRGB(34, 197, 94),
                ["Yellow"] = Color3.fromRGB(250, 204, 21),
                ["Orange"] = Color3.fromRGB(251, 146, 60),
                ["Red"] = Color3.fromRGB(244, 63, 94),
                ["Pink"] = Color3.fromRGB(244, 114, 182),
            }
            mod.setTracerColor(colors[selected] or Color3.fromRGB(255, 255, 255))
        end
    end
})

VisualsTab:Divider()

-- --- Sacred Ship Painter ---
VisualsTab:Button({
    Title = "Detect Player Ship",
    Desc = "Scans within 500 studs for your vehicle seat or pirate ship",
    Callback = function()
        local mod = getVisualsMod("modules/visuals/ship_painter.lua")
        if mod then
            local ship = mod.findPlayerShip()
            if ship then
                WindUI:Notify({
                    Title = "Ship Painter",
                    Content = "Ship detected successfully: " .. tostring(ship.Name),
                    Duration = 3,
                    Icon = darlingIcon
                })
            else
                WindUI:Notify({
                    Title = "Ship Painter",
                    Content = "No ship found within 500 studs. Sit in a vehicle seat first.",
                    Duration = 4,
                    Icon = darlingIcon
                })
            end
        end
    end
})

VisualsTab:Dropdown({
    Title = "Ship Color",
    Values = { "Red", "Blue", "Green", "Purple", "White", "Yellow", "Void (Black)", "Orange" },
    Value = "Purple",
    Callback = function(selected)
        local mod = getVisualsMod("modules/visuals/ship_painter.lua")
        if mod then
            local colors = {
                ["Red"] = Color3.fromRGB(244, 63, 94),
                ["Blue"] = Color3.fromRGB(59, 130, 246),
                ["Green"] = Color3.fromRGB(34, 197, 94),
                ["Purple"] = Color3.fromRGB(192, 132, 252),
                ["White"] = Color3.fromRGB(255, 255, 255),
                ["Yellow"] = Color3.fromRGB(250, 204, 21),
                ["Void (Black)"] = Color3.fromRGB(15, 15, 18),
                ["Orange"] = Color3.fromRGB(251, 146, 60),
            }
            local c = colors[selected] or Color3.fromRGB(192, 132, 252)
            mod.paintShip(c)
        end
    end
})

VisualsTab:Toggle({
    Title = "Rainbow Ship Mode",
    Desc = "Continuously cycles ship material hue across full RGB spectrum",
    Value = false,
    Callback = function(state)
        local mod = getVisualsMod("modules/visuals/ship_painter.lua")
        if mod then mod.setRainbow(state) end
    end
})

VisualsTab:Button({
    Title = "Reset Original Ship Colors",
    Desc = "Restores all ship part materials and original default colors",
    Callback = function()
        local mod = getVisualsMod("modules/visuals/ship_painter.lua")
        if mod then
            local ok = mod.resetShip()
            if ok then
                WindUI:Notify({
                    Title = "Ship Painter",
                    Content = "Ship colors restored to original.",
                    Duration = 3,
                    Icon = darlingIcon
                })
            end
        end
    end
})

VisualsTab:Divider()

-- --- Sacred Ship Resizer ---
VisualsTab:Slider({
    Title = "Ship Scale Multiplier",
    Desc = "Scales your ship size up to 20x with heartbeat anti-reversion",
    Width = 200,
    Value = { Min = 1, Max = 20, Default = 1 },
    Step = 1,
    Callback = function(val)
        local mod = getVisualsMod("modules/visuals/ship_resizer.lua")
        if mod then mod.setShipSize(tonumber(val) or 1) end
    end
})

VisualsTab:Button({
    Title = "Reset Ship Size (1x)",
    Desc = "Returns ship scale back to default dimensions",
    Callback = function()
        local mod = getVisualsMod("modules/visuals/ship_resizer.lua")
        if mod then
            mod.resetShipSize()
            WindUI:Notify({
                Title = "Ship Resizer",
                Content = "Ship size restored to default (1x).",
                Duration = 3,
                Icon = darlingIcon
            })
        end
    end
})

VisualsTab:Divider()

-- --- Shaders & Skybox Environment ---
VisualsTab:Toggle({
    Title = "RTX Shaders",
    Desc = "High-fidelity Bloom, ColorCorrection, and atmospheric lighting filters",
    Value = false,
    Callback = function(state)
        local mod = getVisualsMod("modules/visuals/shaders_skybox.lua")
        if mod then mod.setShaders(state) end
    end
})

VisualsTab:Dropdown({
    Title = "RTX Preset",
    Values = { "RTX ULTRA", "RTX REFLECT", "REALISTIC", "CINEMATIC", "VIBRANT", "SUNSET", "NIGHT", "GOLDEN" },
    Value = "RTX ULTRA",
    Callback = function(selected)
        local mod = getVisualsMod("modules/visuals/shaders_skybox.lua")
        if mod then mod.setShaders(mod.ShadersEnabled, selected) end
    end
})

VisualsTab:Toggle({
    Title = "Custom Skybox",
    Desc = "Replaces default sky with high-resolution space, nebula, or fantasy skybox",
    Value = false,
    Callback = function(state)
        local mod = getVisualsMod("modules/visuals/shaders_skybox.lua")
        if mod then mod.setSkybox(state) end
    end
})

VisualsTab:Dropdown({
    Title = "Skybox Selection",
    Values = {
        "Galaxy", "Purple Night", "Blue Space", "Flaming Sunset", "Nebula",
        "Evening Glow", "Sci-Fi Stars", "Pink Cloud", "Space Nebula",
        "Red Planet", "Arctic Dawn", "Deep Void", "Cloudscape", "Dark Space"
    },
    Value = "Galaxy",
    Callback = function(selected)
        local mod = getVisualsMod("modules/visuals/shaders_skybox.lua")
        if mod then mod.setSkybox(mod.SkyboxEnabled, selected) end
    end
})

VisualsTab:Toggle({
    Title = "Throne Shaders",
    Desc = "King's Throne cinematic lighting, deep purple atmosphere, and bloom",
    Value = false,
    Callback = function(state)
        local mod = getVisualsMod("modules/visuals/throne_shaders.lua")
        if mod then
            if state then mod.enable() else mod.disable() end
        end
    end
})

VisualsTab:Divider()

-- --- Dragon M1 Transformed Visual Effect ---
VisualsTab:Button({
    Title = "Dragon M1 VFX (Transformed)",
    Desc = "Plays cinematic Dragon Transformed M1 breath visual effect",
    Callback = function()
        pcall(function()
            local RS = game:GetService("ReplicatedStorage")
            local EffectModule = require(RS:WaitForChild("Effect", 3))
            local player = LocalPlayer
            local char = player.Character
            local root = char and char:WaitForChild("HumanoidRootPart", 3)
            local camera = Workspace.CurrentCamera
            if not root or not camera then return end

            local holdValue = Instance.new("BoolValue")
            holdValue.Value = true

            local mousePos = Instance.new("Vector3Value")
            mousePos.Value = root.CFrame.Position + camera.CFrame.LookVector * 100

            local aimPos = Instance.new("Vector3Value")
            aimPos.Value = mousePos.Value

            local fakeChar = {
                ["FindFirstChild"] = function(_, name) 
                    return root 
                end
            }

            EffectModule.new("Dragon2.Transformed.M1"):play({
                ["MaxDistance"] = 15000000,
                ["Lifetime"] = 5,
                ["FadeIn"] = 0.005,
                ["FadeOut"] = 2,
                ["percentageofMax"] = 2,
                ["realMaxDistance"] = 15000000,
                ["player"] = player,
                ["Character"] = fakeChar, 
                ["Head"] = root,          
                ["position"] = root.Position,
                ["Mouse"] = mousePos,
                ["Holding"] = holdValue,
                ["headAim"] = aimPos
            })

            task.delay(3, function() 
                holdValue.Value = false 
            end)

            WindUI:Notify({
                Title = "Dragon M1 VFX",
                Content = "Dragon Transformed M1 visual breath effect played.",
                Duration = 3,
                Icon = darlingIcon
            })
        end)
    end
})

VisualsTab:Divider()

-- --- Race V4 Client-Side Visual Suite ---
local raceV4Mod = getVisualsMod("modules/visuals/race_v4_visuals.lua")

VisualsTab:Dropdown({
    Title = "Select Race V4 Visual",
    Values = { "Human", "Mink", "Fishman", "Skypiea", "Ghoul", "Cyborg", "Draco" },
    Value = "Human",
    Callback = function(val)
        if raceV4Mod and val then
            raceV4Mod.CurrentSelectedRace = val
            local cfg = raceV4Mod.RaceConfig[val]
            if cfg then
                WindUI:Notify({
                    Title = "Race: " .. cfg.DisplayName,
                    Content = cfg.Description,
                    Duration = 4,
                    Icon = darlingIcon
                })
                if raceV4Mod.IsV4Active then
                    raceV4Mod.setPermanentMode(true, val)
                end
            end
        end
    end
})

VisualsTab:Button({
    Title = "Awaken V4 (Full Cinematic 3s)",
    Desc = "Triggers complete awakening animation and aura burst",
    Callback = function()
        if raceV4Mod then
            WindUI:Notify({
                Title = "Awaken V4 Visual",
                Content = "Awakening " .. tostring(raceV4Mod.CurrentSelectedRace) .. " V4...",
                Duration = 3,
                Icon = darlingIcon
            })
            raceV4Mod.triggerTransformation(raceV4Mod.CurrentSelectedRace, false)
        end
    end
})

VisualsTab:Button({
    Title = "Awaken V4 (Fast Mastery 1.5s)",
    Desc = "Triggers quick mastery awakening burst with aura",
    Callback = function()
        if raceV4Mod then
            raceV4Mod.triggerTransformation(raceV4Mod.CurrentSelectedRace, true)
        end
    end
})

VisualsTab:Toggle({
    Title = "Permanent V4 Mode",
    Desc = "Maintains persistent V4 aura, 3D wings, accessories, and glowing eyes",
    Value = false,
    Callback = function(state)
        if raceV4Mod then
            raceV4Mod.setPermanentMode(state, raceV4Mod.CurrentSelectedRace)
        end
    end
})

VisualsTab:Toggle({
    Title = "Show 3D Accessories",
    Desc = "Renders real 3D mesh wings, halo, horns, shark fins, and mink ears",
    Value = true,
    Callback = function(state)
        if raceV4Mod then
            raceV4Mod.Enable3DModels = state
            if raceV4Mod.IsV4Active then
                if state then
                    raceV4Mod.spawnAccessories(raceV4Mod.CurrentSelectedRace)
                else
                    raceV4Mod.clearAccessories()
                end
            end
        end
    end
})

VisualsTab:Button({
    Title = "Execute Race Visual Skill",
    Desc = "Casts race-specific visual skill (Psycho Flash, Mink Dash, Cyborg Jump, etc.)",
    Callback = function()
        if raceV4Mod then
            local r = raceV4Mod.CurrentSelectedRace
            local skillMap = {
                ["Human"] = "Human_Flash",
                ["Mink"] = "Mink_Dash",
                ["Cyborg"] = "Cyborg_Jump",
                ["Skypiea"] = "Skypiea_Heaven",
                ["Ghoul"] = "Ghoul_Crow",
                ["Fishman"] = "Fishman_WaterBody",
                ["Draco"] = "Human_Flash",
            }
            local skillId = skillMap[r] or "Human_Flash"
            raceV4Mod.executeSkill(skillId)
        end
    end
})

VisualsTab:Toggle({
    Title = "Use Custom Aura Color",
    Desc = "Overrides default race aura color with selected custom color palette",
    Value = false,
    Callback = function(state)
        if raceV4Mod then
            raceV4Mod.UseCustomColor = state
            if raceV4Mod.IsV4Active then
                raceV4Mod.attachAura(raceV4Mod.CurrentSelectedRace)
                raceV4Mod.spawnAccessories(raceV4Mod.CurrentSelectedRace)
            end
        end
    end
})

VisualsTab:Dropdown({
    Title = "Custom Aura Color Preset",
    Values = { "Cyan", "Red", "Gold", "Purple", "Green", "White", "Orange" },
    Value = "Cyan",
    Callback = function(val)
        if raceV4Mod and val then
            local colorMap = {
                ["Cyan"] = Color3.fromRGB(0, 245, 255),
                ["Red"] = Color3.fromRGB(255, 30, 30),
                ["Gold"] = Color3.fromRGB(255, 215, 0),
                ["Purple"] = Color3.fromRGB(180, 20, 255),
                ["Green"] = Color3.fromRGB(34, 197, 94),
                ["White"] = Color3.fromRGB(255, 255, 255),
                ["Orange"] = Color3.fromRGB(255, 85, 0),
            }
            raceV4Mod.CustomColor = colorMap[val] or Color3.fromRGB(0, 245, 255)
            if raceV4Mod.IsV4Active and raceV4Mod.UseCustomColor then
                raceV4Mod.attachAura(raceV4Mod.CurrentSelectedRace)
                raceV4Mod.spawnAccessories(raceV4Mod.CurrentSelectedRace)
            end
        end
    end
})

VisualsTab:Slider({
    Title = "Wings & Accessories Scale",
    Desc = "Adjusts dimensions and scale of 3D wings, halos, and accessories",
    Width = 200,
    Value = { Min = 0.5, Max = 2.0, Default = 1.0 },
    Step = 0.1,
    Callback = function(val)
        if raceV4Mod then
            raceV4Mod.WingsScale = tonumber(val) or 1.0
            if raceV4Mod.IsV4Active and raceV4Mod.Enable3DModels then
                raceV4Mod.spawnAccessories(raceV4Mod.CurrentSelectedRace)
            end
        end
    end
})

VisualsTab:Toggle({
    Title = "Looped Aura Sound",
    Desc = "Plays immersive ambient aura audio while V4 transformation is active",
    Value = true,
    Callback = function(state)
        if raceV4Mod then
            raceV4Mod.EnableSound = state
        end
    end
})

VisualsTab:Button({
    Title = "Clean / Remove All V4 Visuals",
    Desc = "Restores normal camera, removes all client-side auras and accessories",
    Callback = function()
        if raceV4Mod then
            raceV4Mod.cleanup()
            WindUI:Notify({
                Title = "V4 Visuals",
                Content = "All V4 visual effects restored to normal.",
                Duration = 3,
                Icon = darlingIcon
            })
        end
    end
})


-- ========================================================================

    return VisualsTab
end
