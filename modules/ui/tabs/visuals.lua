--[[
    Darling Hub - modules/ui/tabs/visuals.lua
    Visuals, Optimization & VFX Suite for WindUI.
    Includes:
    - Fullbright mode (night vision in dark zones)
    - Clear Sky & Fog remover
    - Mobile FPS Booster & Low Graphics mode
    - Global Shadows toggle
    - Rainbow Weapon Aura & Character movement trails
]]

local VisualsTabMod = {}

function VisualsTabMod.init(WindowObj, dependencies)
    local Window = WindowObj.Window
    local WindUI = WindowObj.WindUI
    local Utils = dependencies.Utils

    local Lighting = game:GetService("Lighting")
    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local Tab = Window:Tab({
        Title = "Visuals",
        Desc = "Fullbright, FPS boost & VFX",
        Icon = "solar:eye-bold",
        IconColor = Color3.fromHex("#FF2A55"),
    })

    -- Store original lighting state for restoration
    local origBrightness = Lighting.Brightness
    local origClockTime = Lighting.ClockTime
    local origFogEnd = Lighting.FogEnd
    local origGlobalShadows = Lighting.GlobalShadows
    local origOutdoorAmbient = Lighting.OutdoorAmbient

    -- 1. Lighting & Atmosphere Section
    local LightingSection = Tab:Section({
        Title = "Lighting & Atmosphere",
        Opened = true,
    })

    local fullbrightConn = nil
    LightingSection:Toggle({
        Title = "Fullbright Mode",
        Desc = "Maximum ambient visibility everywhere",
        Value = false,
        Callback = function(enabled)
            if enabled then
                fullbrightConn = Lighting.LightingChanged:Connect(function()
                    Lighting.Brightness = 2
                    Lighting.ClockTime = 14
                    Lighting.FogEnd = 100000
                    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                end)
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            else
                if fullbrightConn then
                    fullbrightConn:Disconnect()
                    fullbrightConn = nil
                end
                Lighting.Brightness = origBrightness
                Lighting.ClockTime = origClockTime
                Lighting.FogEnd = origFogEnd
                Lighting.OutdoorAmbient = origOutdoorAmbient
            end
        end,
    })

    LightingSection:Space()

    LightingSection:Toggle({
        Title = "Clear Sky (No Fog)",
        Desc = "Removes atmospheric fog and distance haze",
        Value = true,
        Callback = function(enabled)
            pcall(function()
                if enabled then
                    Lighting.FogEnd = 100000
                    for _, v in ipairs(Lighting:GetDescendants()) do
                        if v:IsA("Atmosphere") then
                            v.Density = 0
                            v.Haze = 0
                            v.Glare = 0
                        end
                    end
                else
                    Lighting.FogEnd = origFogEnd
                end
            end)
        end,
    })

    LightingSection:Space()

    LightingSection:Toggle({
        Title = "Disable Shadows",
        Desc = "Turns off real-time shadows for smoother FPS",
        Value = false,
        Callback = function(enabled)
            pcall(function()
                Lighting.GlobalShadows = not enabled
            end)
        end,
    })

    Tab:Space()

    -- 2. Performance & Optimization Section
    local OptSection = Tab:Section({
        Title = "Performance Optimization",
        Opened = true,
    })

    OptSection:Toggle({
        Title = "Mobile FPS Booster",
        Desc = "Simplifies heavy materials, particles, and decals",
        Value = false,
        Callback = function(enabled)
            if enabled then
                pcall(function()
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and not obj:IsA("MeshPart") then
                            obj.Material = Enum.Material.SmoothPlastic
                        elseif obj:IsA("Decal") or obj:IsA("Texture") then
                            obj.Transparency = 0.5
                        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                            obj.Lifetime = NumberRange.new(0)
                        end
                    end
                end)
                if WindUI then
                    WindUI:Notify({
                        Title = "FPS Booster",
                        Content = "Optimized environment rendering!",
                        Duration = 2,
                        Icon = "solar:bolt-bold",
                    })
                end
            end
        end,
    })

    OptSection:Space()

    OptSection:Button({
        Title = "⚡ Clear Memory Cache",
        Desc = "Collect garbage and free unused executor assets",
        Callback = function()
            pcall(function()
                collectgarbage("collect")
            end)
            if WindUI then
                WindUI:Notify({
                    Title = "Memory",
                    Content = "Garbage collection completed!",
                    Duration = 2,
                    Icon = "solar:trash-bin-trash-bold",
                })
            end
        end,
    })

    Tab:Space()

    -- 3. Cosmetics & Weapon Auras Section
    local SkinSection = Tab:Section({
        Title = "Cosmetics & Weapon Auras",
    })

    local auraActive = false
    SkinSection:Toggle({
        Title = "Rainbow Weapon Aura",
        Desc = "Animated chromatic glow on equipped weapon",
        Value = false,
        Callback = function(enabled)
            auraActive = enabled
            if enabled then
                task.spawn(function()
                    local RunService = game:GetService("RunService")
                    while auraActive do
                        pcall(function()
                            local char = LocalPlayer.Character
                            if char then
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then
                                    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
                                    if handle then
                                        local hue = (tick() * 0.4) % 1
                                        local color = Color3.fromHSV(hue, 0.9, 1)
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
                                end
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

    SkinSection:Space()

    local trailActive = false
    SkinSection:Toggle({
        Title = "Character Movement Trail",
        Desc = "Luminous ribbons following character movement",
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

return VisualsTabMod
