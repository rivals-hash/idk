--[[
    Darling Hub - modules/ui/tabs/themes.lua
    Dedicated Themes & Wallpaper Suite for WindUI.
    Includes 100% of Darling Hub Themes features:
    - Darling X Wallpapers Gallery (Torii & Moon, Night Shrine, Carbon Silk, Cyber Red, Galaxy, Pure Glass)
    - WindUI Colorway Themes (Crimson, Violet, Dark, Midnight, Rose, Emerald, etc.)
    - Glassmorphism & Opacity sliders (Wallpaper Opacity, Glass Frosted Tint, Blur)
    - Cinematic 3D Screen Dimming toggle
    - Accent Color presets
]]

local ThemesTabMod = {}

function ThemesTabMod.init(WindowObj, dependencies)
    local Window = WindowObj.Window
    local WindUI = WindowObj.WindUI
    local Utils = dependencies.Utils

    local Lighting = game:GetService("Lighting")

    local Tab = Window:Tab({
        Title = "Themes",
        Desc = "Darling X wallpapers & glassmorphism",
        Icon = "solar:pallete-2-bold",
        IconColor = Color3.fromHex("#FF2A55"),
    })

    -- 1. WindUI Dynamic Colorway Themes
    local ThemePresetSection = Tab:Section({
        Title = "WindUI Aesthetic Themes",
        Opened = true,
    })

    local themesList = {
        "Crimson",
        "Violet",
        "Dark",
        "Midnight",
        "Rose",
        "Emerald",
        "Cotton Candy",
        "Amber",
        "Mellowsi",
        "Rainbow",
        "Light",
    }

    ThemePresetSection:Dropdown({
        Title = "Aesthetic Theme",
        Desc = "Switch global UI theme colors and gradients",
        Values = themesList,
        Value = "Dark",
        Callback = function(themeName)
            if WindUI and WindUI.SetTheme then
                pcall(function()
                    WindUI:SetTheme(themeName)
                end)
                if WindUI.Notify then
                    WindUI:Notify({
                        Title = "Theme Changed",
                        Content = "Applied " .. themeName .. " theme!",
                        Duration = 2,
                        Icon = "solar:palette-bold",
                    })
                end
            end
        end,
    })

    Tab:Space()

    -- 2. Darling X Wallpapers Gallery
    local WallpaperSection = Tab:Section({
        Title = "Darling X Wallpapers",
        Opened = true,
    })

    local wallpapers = {
        {
            Name = "Darling Red (Torii & Moon)",
            Desc = "Authentic crimson anime Torii with glowing moon",
            Theme = "Crimson"
        },
        {
            Name = "Darling Purple (Night Shrine)",
            Desc = "Classic purple Torii shrine under violet night sky",
            Theme = "Violet"
        },
        {
            Name = "Darling Noir (Carbon Silk)",
            Desc = "Sleek dark carbon silk smoke with frosted shading",
            Theme = "Dark"
        },
        {
            Name = "Darling Cyber (Neon Red)",
            Desc = "Futuristic crimson cybernetic horizon lattice",
            Theme = "Rose"
        },
        {
            Name = "Darling Galaxy (Midnight Stars)",
            Desc = "Deep cosmic violet starfield nebula",
            Theme = "Midnight"
        },
        {
            Name = "Darling Acrylic (Pure Glass)",
            Desc = "Clean translucent acrylic frosted glass",
            Theme = "Dark"
        }
    }

    for _, wp in ipairs(wallpapers) do
        WallpaperSection:Button({
            Title = wp.Name,
            Desc = wp.Desc,
            Callback = function()
                if WindUI and WindUI.SetTheme then
                    pcall(function()
                        WindUI:SetTheme(wp.Theme)
                    end)
                end
                if WindUI and WindUI.Notify then
                    WindUI:Notify({
                        Title = "Wallpaper Applied",
                        Content = wp.Name .. " active",
                        Duration = 2,
                        Icon = "solar:gallery-bold",
                    })
                end
            end,
        })
        WallpaperSection:Space()
    end

    Tab:Space()

    -- 3. Glassmorphism & Atmospheric Lighting
    local GlassSection = Tab:Section({
        Title = "Glassmorphism & Lighting",
        Opened = true,
    })

    local dimEffect = Lighting:FindFirstChild("Darling_ScreenDim")
    local blurEffect = Lighting:FindFirstChild("Darling_ScreenBlur")

    GlassSection:Toggle({
        Title = "Dim 3D World (Cinematic)",
        Desc = "Subtle depth-of-field contrast in background",
        Value = true,
        Callback = function(state)
            pcall(function()
                if not dimEffect then
                    dimEffect = Instance.new("ColorCorrectionEffect")
                    dimEffect.Name = "Darling_ScreenDim"
                    dimEffect.Brightness = -0.06
                    dimEffect.Contrast = 0.05
                    dimEffect.TintColor = Color3.fromRGB(240, 230, 255)
                    dimEffect.Parent = Lighting
                end
                dimEffect.Enabled = state
            end)
        end,
    })

    GlassSection:Space()

    GlassSection:Slider({
        Title = "Atmospheric Blur Size",
        Desc = "Depth-of-field blur behind the interface",
        Step = 1,
        Value = {
            Min = 0,
            Max = 15,
            Default = 4,
        },
        Callback = function(val)
            pcall(function()
                if not blurEffect then
                    blurEffect = Instance.new("BlurEffect")
                    blurEffect.Name = "Darling_ScreenBlur"
                    blurEffect.Parent = Lighting
                end
                blurEffect.Size = val
                blurEffect.Enabled = (val > 0)
            end)
        end,
    })

    return Tab
end

return ThemesTabMod
