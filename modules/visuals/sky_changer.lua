--[[
    Monody / Darling Hub - Sky Changer & Environment Suite
    Allows seamless switching between 13 custom skies and forces daylight illumination.
]]

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local SkyChanger = {
    Enabled = false,
    CurrentPreset = "Galaxy",
    OriginalSkyData = nil,
    OriginalLighting = nil,
    CustomSkyInstance = nil,
    DayLoopConn = nil,
}

SkyChanger.PresetNames = {
    "Realistic",
    "Cloudy",
    "FPS Boost",
    "Mountains",
    "Midnight",
    "Galaxy",
    "Purple Night",
    "Blue Space",
    "Flaming Sunset",
    "Winter",
    "Beach",
    "Red Night",
    "Nebula"
}

SkyChanger.Presets = {
    Realistic = {
        StarCount = 3000,
        SkyboxUp = "rbxassetid://402560052",
        SkyboxBk = "rbxassetid://402559900",
        SkyboxFt = "rbxassetid://402559953",
        SkyboxDn = "rbxassetid://402559927",
        SkyboxLf = "rbxassetid://402559983",
        SkyboxRt = "rbxassetid://402560019",
        MoonTextureId = "rbxasset://sky/moon.jpg",
        SunTextureId = "rbxasset://sky/sun.jpg",
        SunAngularSize = 21,
        MoonAngularSize = 0
    },
    Cloudy = {
        StarCount = 3000,
        SkyboxUp = "rbxassetid://4495867486",
        SkyboxRt = "rbxassetid://4495866584",
        SkyboxLf = "rbxassetid://4495866035",
        SkyboxDn = "rbxassetid://4495864887",
        SkyboxFt = "rbxassetid://4495865458",
        SkyboxBk = "rbxassetid://4495864450"
    },
    ["FPS Boost"] = {
        StarCount = 3000,
        SkyboxUp = "rbxassetid://11457548274",
        SkyboxBk = "rbxassetid://11457548274",
        SkyboxFt = "rbxassetid://11457548274",
        SkyboxDn = "rbxassetid://11457548274",
        SkyboxLf = "rbxassetid://11457548274",
        SkyboxRt = "rbxassetid://11457548274",
        MoonTextureId = "rbxassetid://6444320592",
        SunTextureId = "rbxassetid://8281961896",
        SunAngularSize = 0,
        MoonAngularSize = 0
    },
    Mountains = {
        StarCount = 3000,
        SkyboxUp = "rbxassetid://15359412677",
        SkyboxDn = "rbxassetid://15359411132",
        SkyboxLf = "rbxassetid://15359411633",
        SkyboxBk = "rbxassetid://15359410490",
        SkyboxFt = "rbxassetid://15359412131",
        SkyboxRt = "rbxassetid://15359417656",
        MoonTextureId = "rbxassetid://6444320592",
        SunTextureId = "rbxassetid://8281961896",
        SunAngularSize = 21,
        MoonAngularSize = 0
    },
    Midnight = {
        StarCount = 3000,
        SkyboxUp = "rbxassetid://154185031",
        SkyboxBk = "rbxassetid://154185004",
        SkyboxFt = "rbxassetid://154185021",
        SkyboxDn = "rbxassetid://154184960",
        SkyboxLf = "rbxassetid://154184943",
        SkyboxRt = "rbxassetid://154184972",
        MoonTextureId = "rbxasset://sky/moon.jpg",
        SunTextureId = "rbxasset://sky/sun.jpg",
        SunAngularSize = 21,
        MoonAngularSize = 0
    },
    Galaxy = {
        StarCount = 3000,
        SkyboxUp = "rbxassetid://159454288",
        SkyboxLf = "rbxassetid://159454293",
        SkyboxFt = "rbxassetid://159454293",
        SkyboxDn = "rbxassetid://159454296",
        SkyboxBk = "rbxassetid://159454299",
        SkyboxRt = "rbxassetid://159454293",
        MoonTextureId = "rbxassetid://6444320592",
        SunTextureId = "rbxassetid://8281961896",
        SunAngularSize = 0,
        MoonAngularSize = 0
    },
    ["Purple Night"] = {
        StarCount = 3000,
        SkyboxUp = "rbxassetid://5084576400",
        SkyboxBk = "rbxassetid://5260808177",
        SkyboxFt = "rbxassetid://5260817288",
        SkyboxDn = "rbxassetid://5260653793",
        SkyboxLf = "rbxassetid://5260800833",
        SkyboxRt = "rbxassetid://5260800833",
        MoonTextureId = "rbxassetid://6444320592",
        SunTextureId = "rbxassetid://8281961896",
        SunAngularSize = 0,
        MoonAngularSize = 0
    },
    ["Blue Space"] = {
        StarCount = 3000,
        SkyboxUp = "rbxassetid://16876552681",
        SkyboxBk = "rbxassetid://16876541778",
        SkyboxLf = "rbxassetid://16876548320",
        SkyboxFt = "rbxassetid://16876546384",
        SkyboxDn = "rbxassetid://16876543880",
        SkyboxRt = "rbxassetid://16876550345",
        MoonTextureId = "rbxassetid://6444320592",
        SunTextureId = "rbxassetid://8281961896",
        SunAngularSize = 21,
        MoonAngularSize = 0
    },
    ["Flaming Sunset"] = {
        StarCount = 3000,
        SkyboxUp = "rbxassetid://415688354",
        SkyboxFt = "rbxassetid://415688242",
        SkyboxBk = "rbxassetid://415688378",
        SkyboxDn = "rbxassetid://415688193",
        SkyboxLf = "rbxassetid://415688310",
        SkyboxRt = "rbxassetid://415688274",
        MoonTextureId = "rbxassetid://6444320592",
        SunTextureId = "rbxassetid://6196665106",
        SunAngularSize = 0,
        MoonAngularSize = 0
    },
    Winter = {
        StarCount = 3000,
        SkyboxUp = "rbxassetid://155674931",
        SkyboxFt = "rbxassetid://155657609",
        SkyboxBk = "rbxassetid://155657655",
        SkyboxLf = "rbxassetid://155657671",
        SkyboxDn = "rbxassetid://155674246",
        SkyboxRt = "rbxassetid://155657619",
        MoonTextureId = "rbxassetid://6444320592",
        SunTextureId = "rbxassetid://8281961896",
        SunAngularSize = 21,
        MoonAngularSize = 11
    },
    Beach = {
        StarCount = 0,
        SkyboxUp = "rbxassetid://173380790",
        SkyboxBk = "rbxassetid://173380597",
        SkyboxDn = "rbxassetid://173380627",
        SkyboxFt = "rbxassetid://173380642",
        SkyboxLf = "rbxassetid://173380671",
        SkyboxRt = "rbxassetid://173380774",
        MoonTextureId = "rbxassetid://6444320592",
        SunTextureId = "rbxassetid://8281961896",
        SunAngularSize = 21,
        MoonAngularSize = 11
    },
    ["Red Night"] = {
        StarCount = 3000,
        SkyboxUp = "rbxassetid://401664936",
        SkyboxFt = "rbxassetid://401664960",
        SkyboxBk = "rbxassetid://401664839",
        SkyboxLf = "rbxassetid://401664881",
        SkyboxDn = "rbxassetid://401664862",
        SkyboxRt = "rbxassetid://401664901",
        MoonTextureId = "rbxassetid://6444320592",
        SunTextureId = "rbxassetid://8281961896",
        SunAngularSize = 0,
        MoonAngularSize = 0
    },
    Nebula = {
        StarCount = 3000,
        SkyboxUp = "rbxassetid://5260824661",
        SkyboxDn = "rbxassetid://5260653793",
        SkyboxLf = "rbxassetid://5260800833",
        SkyboxBk = "rbxassetid://5260808177",
        SkyboxFt = "rbxassetid://5260817288",
        SkyboxRt = "rbxassetid://5260811073",
        MoonTextureId = "rbxassetid://6444320592",
        SunTextureId = "rbxassetid://8281961896",
        SunAngularSize = 0,
        MoonAngularSize = 0
    }
}

local SKY_PROPERTIES = {
    "SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp",
    "MoonTextureId", "SunTextureId", "MoonAngularSize", "SunAngularSize", "StarCount"
}

local function saveOriginalEnvironment()
    if not SkyChanger.OriginalLighting then
        SkyChanger.OriginalLighting = {
            ClockTime = Lighting.ClockTime,
            Brightness = Lighting.Brightness,
            OutdoorAmbient = Lighting.OutdoorAmbient,
        }
    end

    if not SkyChanger.OriginalSkyData then
        local foundSky = Lighting:FindFirstChildOfClass("Sky")
        if foundSky and foundSky.Name ~= "MonodySky" then
            local data = {}
            for _, prop in ipairs(SKY_PROPERTIES) do
                pcall(function() data[prop] = foundSky[prop] end)
            end
            SkyChanger.OriginalSkyData = data
        end
    end
end

local function applyDaytime()
    pcall(function()
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end)
end

function SkyChanger.ApplySky(presetName)
    local preset = SkyChanger.Presets[presetName] or SkyChanger.Presets["Galaxy"]
    if not preset then return end

    saveOriginalEnvironment()
    applyDaytime()

    local sky = Lighting:FindFirstChild("MonodySky")
    if not sky or not sky:IsA("Sky") then
        sky = Instance.new("Sky")
        sky.Name = "MonodySky"
        sky.Parent = Lighting
    end
    SkyChanger.CustomSkyInstance = sky

    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") and child ~= sky then
            child.Parent = nil
        end
    end

    for _, prop in ipairs(SKY_PROPERTIES) do
        local val = preset[prop]
        if val ~= nil then
            pcall(function() sky[prop] = val end)
        end
    end
end

function SkyChanger.SetPreset(presetName)
    SkyChanger.CurrentPreset = presetName
    if SkyChanger.Enabled then
        SkyChanger.ApplySky(presetName)
    end
end

function SkyChanger.SetEnabled(state)
    local target = (state == true)
    SkyChanger.Enabled = target

    if SkyChanger.Enabled then
        SkyChanger.ApplySky(SkyChanger.CurrentPreset)

        if not SkyChanger.DayLoopConn then
            SkyChanger.DayLoopConn = RunService.Heartbeat:Connect(function()
                if not SkyChanger.Enabled then return end
                if Lighting.ClockTime ~= 14 then
                    Lighting.ClockTime = 14
                end
            end)
        end
    else
        if SkyChanger.DayLoopConn then
            pcall(function() SkyChanger.DayLoopConn:Disconnect() end)
            SkyChanger.DayLoopConn = nil
        end

        local sky = Lighting:FindFirstChild("MonodySky")
        if sky then
            pcall(function() sky:Destroy() end)
            SkyChanger.CustomSkyInstance = nil
        end

        if SkyChanger.OriginalSkyData then
            local restoredSky = Instance.new("Sky")
            restoredSky.Name = "RestoredSky"
            for _, prop in ipairs(SKY_PROPERTIES) do
                local val = SkyChanger.OriginalSkyData[prop]
                if val ~= nil then
                    pcall(function() restoredSky[prop] = val end)
                end
            end
            restoredSky.Parent = Lighting
        end

        if SkyChanger.OriginalLighting then
            pcall(function()
                Lighting.ClockTime = SkyChanger.OriginalLighting.ClockTime or 14
                Lighting.Brightness = SkyChanger.OriginalLighting.Brightness or 2
                Lighting.OutdoorAmbient = SkyChanger.OriginalLighting.OutdoorAmbient or Color3.fromRGB(128, 128, 128)
            end)
        end
    end
end

function SkyChanger.Reset()
    SkyChanger.SetEnabled(false)
end

return SkyChanger
