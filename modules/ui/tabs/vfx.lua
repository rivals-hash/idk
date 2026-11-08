--[[
    Darling Hub - modules/ui/tabs/vfx.lua
    Dedicated VFX & Optimization Suite for WindUI.
    Includes 100% of Darling Hub VFX features:
    - Clear Sky (No Fog)
    - Fullbright Mode (night vision)
    - Mobile FPS Boost (reduce particles/textures)
    - Disable Shadows (improve performance)
    - Clear Memory Cache (clean garbage and executor memory)
]]

local VFXTabMod = {}

function VFXTabMod.init(WindowObj, dependencies)
    local Window = WindowObj.Window
    local WindUI = WindowObj.WindUI
    local Utils = dependencies.Utils

    local Lighting = game:GetService("Lighting")
    local Workspace = game:GetService("Workspace")

    local Tab = Window:Tab({
        Title = "VFX",
        Desc = "Optimization, graphics & lighting",
        Icon = "solar:sun-bold",
        IconColor = Color3.fromHex("#FF2A55"),
    })

    local origBrightness = Lighting.Brightness
    local origClockTime = Lighting.ClockTime
    local origFogEnd = Lighting.FogEnd
    local origOutdoorAmbient = Lighting.OutdoorAmbient

    -- 1. Optimization & Graphics Section
    local OptSection = Tab:Section({
        Title = "Optimization & Graphics",
        Opened = true,
    })

    OptSection:Toggle({
        Title = "Clear Sky (No Fog)",
        Desc = "Eliminate atmospheric fog and distance haze",
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

    OptSection:Space()

    local fullbrightConn = nil
    OptSection:Toggle({
        Title = "Fullbright Mode",
        Desc = "Maximum ambient lighting in dark areas",
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

    OptSection:Space()

    OptSection:Toggle({
        Title = "Mobile FPS Boost",
        Desc = "Reduce particles and textures for smoothness",
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
                        Title = "FPS Boost",
                        Content = "Mobile rendering optimized!",
                        Duration = 2,
                        Icon = "solar:bolt-bold",
                    })
                end
            end
        end,
    })

    OptSection:Space()

    OptSection:Toggle({
        Title = "Disable Shadows",
        Desc = "Improve performance on low-end devices",
        Value = false,
        Callback = function(enabled)
            pcall(function()
                Lighting.GlobalShadows = not enabled
            end)
        end,
    })

    Tab:Space()

    -- 2. Memory & Cleanup Section
    local CleanSection = Tab:Section({
        Title = "Memory Cleaner",
    })

    CleanSection:Button({
        Title = "⚡ Clear Memory Cache",
        Desc = "Force garbage collection to reduce lag spikes",
        Icon = "solar:trash-bin-trash-bold",
        Callback = function()
            pcall(function() collectgarbage("collect") end)
            if WindUI then
                WindUI:Notify({
                    Title = "Memory",
                    Content = "Garbage collected successfully",
                    Duration = 2,
                    Icon = "solar:check-circle-bold",
                })
            end
        end,
    })

    return Tab
end

return VFXTabMod
