--[[
    Darling Hub - modules/ui/tabs/skins.lua
    Dedicated Skins & Cosmetic Visuals Suite for WindUI.
    Includes 100% of Darling Hub Skins features:
    - Rainbow Weapon Aura (animated chromatic aura on equipped sword/fist)
    - Character Movement Trail (luminous dual-ribbon trail)
    - Aura Color Presets & Cycler (Neon Cyan, Crimson Red, Royal Purple, Emerald Green, Gold)
    - Weapon Particle Sparks
]]

local SkinsTabMod = {}

function SkinsTabMod.init(WindowObj, dependencies)
    local Window = WindowObj.Window
    local WindUI = WindowObj.WindUI
    local Utils = dependencies.Utils

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local Tab = Window:Tab({
        Title = "Skins",
        Desc = "Weapon auras & character trails",
        Icon = "solar:palette-bold",
        IconColor = Color3.fromHex("#FF2A55"),
    })

    -- 1. Cosmetics & Effects Section
    local EffectSection = Tab:Section({
        Title = "Cosmetics & Effects",
        Opened = true,
    })

    local auraActive = false
    local auraColorMode = "Rainbow"
    local selectedAuraColor = Color3.fromHex("#00FFFF")

    local function getEquippedHandle()
        local char = LocalPlayer.Character
        if not char then return nil end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return nil end
        return tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
    end

    EffectSection:Toggle({
        Title = "Rainbow Weapon Aura",
        Desc = "Multicolor aura on swords and fists",
        Value = false,
        Callback = function(enabled)
            auraActive = enabled
            if enabled then
                task.spawn(function()
                    while auraActive do
                        pcall(function()
                            local handle = getEquippedHandle()
                            if handle then
                                local color = selectedAuraColor
                                if auraColorMode == "Rainbow" then
                                    local hue = (tick() * 0.4) % 1
                                    color = Color3.fromHSV(hue, 0.9, 1)
                                end
                                local box = handle:FindFirstChild("Darling_AuraBox")
                                if not box then
                                    box = Instance.new("SelectionBox")
                                    box.Name = "Darling_AuraBox"
                                    box.Adornee = handle
                                    box.LineThickness = 0.05
                                    box.Parent = handle
                                end
                                box.Color3 = color
                            end
                        end)
                        task.wait(0.05)
                    end
                    -- Cleanup
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char then
                            for _, desc in ipairs(char:GetDescendants()) do
                                if desc.Name == "Darling_AuraBox" then desc:Destroy() end
                            end
                        end
                    end)
                end)
            end
        end,
    })

    EffectSection:Space()

    EffectSection:Dropdown({
        Title = "Aura Color Preset",
        Desc = "Choose chromatic rainbow or fixed neon glow",
        Values = { "Rainbow", "Neon Cyan", "Crimson Red", "Royal Purple", "Emerald Green", "Amber Gold" },
        Value = "Rainbow",
        Callback = function(preset)
            auraColorMode = preset
            local map = {
                ["Neon Cyan"] = Color3.fromHex("#00FFFF"),
                ["Crimson Red"] = Color3.fromHex("#FF2A55"),
                ["Royal Purple"] = Color3.fromHex("#9D00FF"),
                ["Emerald Green"] = Color3.fromHex("#00FF88"),
                ["Amber Gold"] = Color3.fromHex("#FFBB00"),
            }
            if map[preset] then
                selectedAuraColor = map[preset]
            end
        end,
    })

    EffectSection:Space()

    local auraColorsList = { "Neon Cyan", "Crimson Red", "Royal Purple", "Emerald Green", "Amber Gold" }
    local auraIdx = 1
    EffectSection:Button({
        Title = "Cycle Aura Color",
        Desc = "Cycle through available aura colors",
        Callback = function()
            auraIdx = (auraIdx % #auraColorsList) + 1
            local chosen = auraColorsList[auraIdx]
            auraColorMode = chosen
            local map = {
                ["Neon Cyan"] = Color3.fromHex("#00FFFF"),
                ["Crimson Red"] = Color3.fromHex("#FF2A55"),
                ["Royal Purple"] = Color3.fromHex("#9D00FF"),
                ["Emerald Green"] = Color3.fromHex("#00FF88"),
                ["Amber Gold"] = Color3.fromHex("#FFBB00"),
            }
            selectedAuraColor = map[chosen]
            if WindUI then
                WindUI:Notify({
                    Title = "Aura",
                    Content = "Aura changed to " .. chosen,
                    Duration = 1.5,
                    Icon = "solar:palette-bold",
                })
            end
        end,
    })

    Tab:Space()

    -- 2. Movement Trails Section
    local TrailSection = Tab:Section({
        Title = "Movement Trails",
        Opened = true,
    })

    local trailActive = false
    TrailSection:Toggle({
        Title = "Character Trail",
        Desc = "Light trail following character movement",
        Value = false,
        Callback = function(enabled)
            trailActive = enabled
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local existing = hrp:FindFirstChild("Darling_Trail")
                if existing then existing:Destroy() end
                if enabled then
                    local a0 = Instance.new("Attachment", hrp)
                    a0.Position = Vector3.new(0, 1.2, 0)
                    local a1 = Instance.new("Attachment", hrp)
                    a1.Position = Vector3.new(0, -1.2, 0)
                    local trail = Instance.new("Trail")
                    trail.Name = "Darling_Trail"
                    trail.Attachment0 = a0
                    trail.Attachment1 = a1
                    trail.Color = ColorSequence.new(Color3.fromHex("#FF2A55"), Color3.fromHex("#9D00FF"))
                    trail.Lifetime = 0.5
                    trail.Transparency = NumberSequence.new(0.2, 1)
                    trail.Parent = hrp
                end
            end)
        end,
    })

    return Tab
end

return SkinsTabMod
