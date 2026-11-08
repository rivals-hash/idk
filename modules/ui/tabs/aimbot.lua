--[[
    Darling Hub - modules/ui/tabs/aimbot.lua
    Aimbot & Silent Aim Suite for WindUI.
    Includes:
    - Player & NPC aimbot toggles
    - Silent Aim engine with hit redirection
    - Target bone & priority selection
    - Interactive FOV Circle visualizer (radius, color, center/mouse)
    - 3D Beam and 2D Line Tracers
    - Safe zone, team check, and pvp filters
]]

local AimbotTabMod = {}

function AimbotTabMod.init(WindowObj, dependencies)
    local Window = WindowObj.Window
    local WindUI = WindowObj.WindUI
    local AimbotCore = dependencies.AimbotCore
    local PlayerAimbot = dependencies.PlayerAimbot
    local NPCAimbot = dependencies.NPCAimbot
    local SilentAim = dependencies.SilentAim
    local FOV = dependencies.FOV
    local Tracers = dependencies.Tracers

    local Tab = Window:Tab({
        Title = "Aimbot",
        Desc = "Combat assist, silent aim & FOV",
        Icon = "solar:target-bold",
        IconColor = Color3.fromHex("#FF2A55"),
    })

    -- 1. Master Targeting Section
    local TargetSection = Tab:Section({
        Title = "Master Targeting",
        Opened = true,
    })

    TargetSection:Toggle({
        Title = "Player Aimbot",
        Desc = "Automatically targets enemy players",
        Value = (AimbotCore and AimbotCore.PlayerAimEnabled) or false,
        Callback = function(enabled)
            if PlayerAimbot then
                if enabled then
                    PlayerAimbot.enable()
                else
                    PlayerAimbot.disable()
                end
            end
        end,
    })

    TargetSection:Space()

    TargetSection:Toggle({
        Title = "NPC / Mob Aimbot",
        Desc = "Locks onto nearest hostile NPCs & bosses",
        Value = (AimbotCore and AimbotCore.NPCAimEnabled) or false,
        Callback = function(enabled)
            if NPCAimbot then
                if enabled then
                    NPCAimbot.enable()
                else
                    NPCAimbot.disable()
                end
            end
        end,
    })

    TargetSection:Space()

    TargetSection:Toggle({
        Title = "Silent Aim",
        Desc = "Redirects weapon attacks without rotating camera",
        Value = (SilentAim and SilentAim.Enabled) or false,
        Callback = function(enabled)
            if SilentAim then
                SilentAim.Enabled = enabled
                _G.G_PlayerSilentAim = enabled
                _G.G_NPCSilentAim = enabled
            end
        end,
    })

    TargetSection:Space()

    TargetSection:Dropdown({
        Title = "Target Bone",
        Desc = "Body part targeted by Aimbot & Silent Aim",
        Values = { "Head", "HumanoidRootPart" },
        Value = (AimbotCore and AimbotCore.TargetPart) or "Head",
        Callback = function(bone)
            if AimbotCore then AimbotCore.TargetPart = bone end
            if SilentAim then SilentAim.TargetPartName = bone end
        end,
    })

    TargetSection:Space()

    TargetSection:Dropdown({
        Title = "Target Priority",
        Desc = "Sorting criteria when multiple targets exist",
        Values = { "Nearest", "Low HP", "Looking At Me" },
        Value = (AimbotCore and AimbotCore.TargetPriority) or "Nearest",
        Callback = function(priority)
            if AimbotCore then AimbotCore.TargetPriority = priority end
        end,
    })

    TargetSection:Space()

    TargetSection:Slider({
        Title = "Max Range (Studs)",
        Desc = "Maximum distance to engage targets",
        Step = 50,
        Value = {
            Min = 100,
            Max = 3000,
            Default = (AimbotCore and AimbotCore.MaxRange) or 1000,
        },
        Callback = function(val)
            if AimbotCore then AimbotCore.MaxRange = val end
            if SilentAim then SilentAim.MaxDistance = val end
        end,
    })

    Tab:Space()

    -- 2. Target Filters Section
    local FilterSection = Tab:Section({
        Title = "Target Filters & Checks",
    })

    FilterSection:Toggle({
        Title = "Team Check",
        Desc = "Ignore players on the same team or crew",
        Value = (AimbotCore and AimbotCore.TeamCheck) or false,
        Callback = function(enabled)
            if AimbotCore then AimbotCore.TeamCheck = enabled end
            if SilentAim then SilentAim.TeamCheck = enabled end
        end,
    })

    FilterSection:Space()

    FilterSection:Toggle({
        Title = "Safe Zone Check",
        Desc = "Ignore players located inside peace/safe zones",
        Value = (AimbotCore and AimbotCore.SafeZoneCheck) or true,
        Callback = function(enabled)
            if AimbotCore then AimbotCore.SafeZoneCheck = enabled end
        end,
    })

    FilterSection:Space()

    FilterSection:Toggle({
        Title = "PvP Check",
        Desc = "Ignore players who have PvP disabled",
        Value = (AimbotCore and AimbotCore.PvPCheck) or true,
        Callback = function(enabled)
            if AimbotCore then AimbotCore.PvPCheck = enabled end
        end,
    })

    Tab:Space()

    -- 3. FOV Circle Section
    local FovSection = Tab:Section({
        Title = "FOV Visualizer",
    })

    local fovState = FOV and FOV.getState and FOV.getState() or {}

    FovSection:Toggle({
        Title = "Show FOV Circle",
        Desc = "Renders field-of-view targeting radius",
        Value = fovState.enabled or false,
        Callback = function(enabled)
            if FOV and FOV.setVisible then
                FOV.setVisible(enabled)
            end
        end,
    })

    FovSection:Space()

    FovSection:Slider({
        Title = "FOV Radius",
        Desc = "Pixel radius around cursor / screen center",
        Step = 5,
        Value = {
            Min = 30,
            Max = 500,
            Default = fovState.radius or 120,
        },
        Callback = function(rad)
            if FOV and FOV.setRadius then
                FOV.setRadius(rad)
            end
        end,
    })

    FovSection:Space()

    FovSection:Dropdown({
        Title = "FOV Position",
        Desc = "Position circle at screen center or mouse cursor",
        Values = { "Center", "Mouse" },
        Value = fovState.mode or "Center",
        Callback = function(mode)
            if FOV and FOV.setMode then
                FOV.setMode(mode)
            end
        end,
    })

    FovSection:Space()

    FovSection:Colorpicker({
        Title = "FOV Color",
        Desc = "Color of the FOV circle ring",
        Default = Color3.fromHex("#FF2A55"),
        Callback = function(color)
            if FOV and FOV.setColor then
                FOV.setColor(color)
            end
        end,
    })

    Tab:Space()

    -- 4. Tracers Section
    local TracerSection = Tab:Section({
        Title = "Target Tracers",
    })

    TracerSection:Toggle({
        Title = "Enable Tracers",
        Desc = "Renders lines/beams to your locked target",
        Value = false,
        Callback = function(enabled)
            if Tracers then
                if enabled then
                    Tracers.enable()
                else
                    Tracers.disable()
                end
            end
        end,
    })

    TracerSection:Space()

    TracerSection:Dropdown({
        Title = "Tracer Origin",
        Desc = "Starting anchor point of the tracer line",
        Values = { "Player", "Center", "Bottom", "Mouse" },
        Value = "Player",
        Callback = function(orig)
            if Tracers and Tracers.setOrigin then
                Tracers.setOrigin(orig)
            end
        end,
    })

    TracerSection:Space()

    TracerSection:Dropdown({
        Title = "Tracer Type",
        Desc = "Hardware 3D beam or 2D screen overlay",
        Values = { "3D Beam", "2D Line", "Both" },
        Value = "Both",
        Callback = function(tp)
            if Tracers and Tracers.setType then
                Tracers.setType(tp)
            end
        end,
    })

    TracerSection:Space()

    TracerSection:Colorpicker({
        Title = "Tracer Color",
        Desc = "Color of the tracer lines and beams",
        Default = Color3.fromHex("#9D00FF"),
        Callback = function(color)
            if Tracers and Tracers.setColor then
                Tracers.setColor(color)
            end
        end,
    })

    return Tab
end

return AimbotTabMod
