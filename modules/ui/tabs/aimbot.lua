--[[
    Darling Hub - modules/ui/tabs/aimbot.lua
    Aimbot & Silent Aim Suite for WindUI.
    Includes 100% of Darling Hub features:
    - Player Aimbot, NPC Aimbot, and Aimlock
    - Silent Aim engine with bone selector & range slider
    - Target priority & Aim Mode (Closest, 360°, FOV, 180°)
    - FOV Circle visualizer (radius, color, center/mouse)
    - 3D Beam and 2D Line Tracers (origin, color, type)
    - Safe zone, team check, and pvp filters
    - Skill Blacklist multi-selector (Fruit, Melee, Sword, Gun)
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
    local Blacklist = dependencies.Blacklist

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
        Desc = "Automatically aims camera and attacks at target",
        Value = (AimbotCore and AimbotCore.PlayerAimEnabled) or false,
        Callback = function(enabled)
            if AimbotCore and AimbotCore.setAimbot then AimbotCore.setAimbot(enabled) end
            if AimbotCore and AimbotCore.setLockPlayer then AimbotCore.setLockPlayer(enabled) end
            if PlayerAimbot then
                if enabled then PlayerAimbot.enable() else PlayerAimbot.disable() end
            elseif AimbotCore then
                AimbotCore.PlayerAimEnabled = enabled
                if enabled then AimbotCore.startLoop() else AimbotCore.stopLoop() end
            end
            _G.G_Aimbot = enabled
            _G.G_PlayerAim = enabled
        end,
    })

    TargetSection:Space()

    TargetSection:Toggle({
        Title = "NPC / Mob Aimbot",
        Desc = "Lock and aim towards monsters and bosses",
        Value = (AimbotCore and AimbotCore.NPCAimEnabled) or false,
        Callback = function(enabled)
            if NPCAimbot then
                if enabled then NPCAimbot.enable() else NPCAimbot.disable() end
            elseif AimbotCore then
                AimbotCore.NPCAimEnabled = enabled
                if enabled then AimbotCore.startLoop() else AimbotCore.stopLoop() end
            end
            _G.G_NPCAimbot = enabled
        end,
    })

    TargetSection:Space()

    TargetSection:Toggle({
        Title = "Aimlock",
        Desc = "Lock and maintain a target lock during combat",
        Value = false,
        Callback = function(enabled)
            if AimbotCore and AimbotCore.setLockPlayer then
                AimbotCore.setLockPlayer(enabled)
            end
        end,
    })

    TargetSection:Space()

    TargetSection:Toggle({
        Title = "Player Silent Aim",
        Desc = "Redirect attacks to players without camera lock",
        Value = (SilentAim and SilentAim.Enabled) or false,
        Callback = function(enabled)
            if SilentAim then
                SilentAim.Enabled = enabled
                _G.G_PlayerSilentAim = enabled
                _G.G_SilentAim = enabled
            end
        end,
    })

    TargetSection:Space()

    TargetSection:Toggle({
        Title = "NPC Silent Aim",
        Desc = "Redirect attacks to mobs without camera lock",
        Value = false,
        Callback = function(enabled)
            _G.G_NPCSilentAim = enabled
        end,
    })

    TargetSection:Space()

    TargetSection:Dropdown({
        Title = "Aim Mode",
        Desc = "Target search trajectory angle",
        Values = { "360°", "Closest", "FOV", "180°" },
        Value = "360°",
        Callback = function(opt)
            local mode = "360"
            if opt:find("FOV") then mode = "FOV"
            elseif opt:find("180") then mode = "180" end
            if PlayerAimbot and PlayerAimbot.setAimMode then PlayerAimbot.setAimMode(mode) end
            if AimbotCore then AimbotCore.AimMode = mode end
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
        Title = "PvP Check",
        Desc = "Ignore players with PvP disabled",
        Value = (AimbotCore and AimbotCore.PvPCheck) or true,
        Callback = function(enabled)
            if AimbotCore then AimbotCore.PvPCheck = enabled end
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
        Title = "Team Check",
        Desc = "Ignore friendly / allied players or crew",
        Value = (AimbotCore and AimbotCore.TeamCheck) or false,
        Callback = function(enabled)
            if AimbotCore then AimbotCore.TeamCheck = enabled end
            if SilentAim then SilentAim.TeamCheck = enabled end
        end,
    })

    Tab:Space()

    -- 3. FOV Circle Section
    local FovSection = Tab:Section({
        Title = "FOV Visualizer",
    })

    local fovState = FOV and FOV.getState and FOV.getState() or {}

    FovSection:Toggle({
        Title = "FOV Circle",
        Desc = "Draw field of view circle on screen",
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
            Min = 20,
            Max = 600,
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
        Title = "Position",
        Desc = "Position circle at screen center or cursor",
        Values = { "Center", "Cursor" },
        Value = (fovState.mode == "Mouse" and "Cursor") or "Center",
        Callback = function(mode)
            local m = mode == "Cursor" and "Mouse" or "Center"
            if FOV and FOV.setMode then
                FOV.setMode(m)
            end
        end,
    })

    FovSection:Space()

    FovSection:Dropdown({
        Title = "FOV Color Preset",
        Desc = "Select color preset or rainbow animation",
        Values = { "Rainbow", "White", "Red", "Green", "Blue", "Yellow", "Purple", "Cyan", "Orange" },
        Value = "Rainbow",
        Callback = function(colorName)
            if FOV and FOV.setColor then
                FOV.setColor(colorName)
            end
        end,
    })

    Tab:Space()

    -- 4. Tracers Section
    local TracerSection = Tab:Section({
        Title = "Tracers",
    })

    TracerSection:Toggle({
        Title = "Show Tracers",
        Desc = "Draw indicator lines towards enemies",
        Value = false,
        Callback = function(enabled)
            if Tracers then
                if enabled then Tracers.enable() else Tracers.disable() end
            end
        end,
    })

    TracerSection:Space()

    TracerSection:Dropdown({
        Title = "Tracer Mode",
        Desc = "Hardware 3D beam or 2D screen overlay",
        Values = { "Both (3D + 2D)", "3D Beam", "2D Line" },
        Value = "Both (3D + 2D)",
        Callback = function(opt)
            local m = "Both"
            if opt:find("3D") and not opt:find("2D") then m = "3D Beam"
            elseif opt:find("2D") and not opt:find("3D") then m = "2D Line" end
            if Tracers and Tracers.setType then Tracers.setType(m) end
        end,
    })

    TracerSection:Space()

    TracerSection:Dropdown({
        Title = "Tracer Origin",
        Desc = "Starting anchor point of the tracer line",
        Values = { "Player", "Bottom", "Center" },
        Value = "Player",
        Callback = function(orig)
            if Tracers and Tracers.setOrigin then Tracers.setOrigin(orig) end
        end,
    })

    TracerSection:Space()

    TracerSection:Dropdown({
        Title = "Tracer Color Preset",
        Desc = "Select tracer color scheme",
        Values = { "Rainbow", "White", "Red", "Green", "Blue", "Yellow", "Purple" },
        Value = "Rainbow",
        Callback = function(colorName)
            if Tracers then
                if colorName == "Rainbow" then
                    if Tracers.setRainbow then Tracers.setRainbow(true) end
                else
                    local cMap = {
                        White = Color3.fromRGB(255, 255, 255),
                        Red = Color3.fromRGB(255, 60, 60),
                        Green = Color3.fromRGB(60, 255, 120),
                        Blue = Color3.fromRGB(60, 160, 255),
                        Yellow = Color3.fromRGB(255, 225, 60),
                        Purple = Color3.fromRGB(180, 80, 255),
                    }
                    if Tracers.setColor then Tracers.setColor(cMap[colorName] or Color3.fromRGB(255, 255, 255)) end
                end
            end
        end,
    })

    Tab:Space()

    -- 5. Skill Blacklist Section
    local BlacklistSection = Tab:Section({
        Title = "Skill Blacklist",
    })

    local allSkills = {
        "Melee Z", "Melee X", "Melee C",
        "Sword Z", "Sword X",
        "Fruit Z", "Fruit X", "Fruit C", "Fruit V", "Fruit F", "Fruit TAP",
        "Gun Z", "Gun X"
    }

    BlacklistSection:Dropdown({
        Title = "Exclude Skills from Aimbot",
        Desc = "Selected skills will be blacklisted from auto-targeting",
        Values = allSkills,
        Multi = true,
        Callback = function(selectedItems)
            local selectedMap = {}
            if type(selectedItems) == "table" then
                for _, itm in ipairs(selectedItems) do
                    local name = (type(itm) == "table" and itm.Title) or tostring(itm)
                    selectedMap[name] = true
                end
            end

            for _, skill in ipairs(allSkills) do
                local cat, key = skill:match("^(%a+)%s+(%a+)$")
                if cat and key then
                    local isBl = selectedMap[skill] == true
                    if Blacklist and Blacklist.set then
                        Blacklist.set(cat, key, isBl)
                    elseif AimbotCore and AimbotCore.BlacklistedKeys and AimbotCore.BlacklistedKeys[cat] then
                        AimbotCore.BlacklistedKeys[cat][key] = isBl
                    end
                end
            end
        end,
    })

    return Tab
end

return AimbotTabMod
