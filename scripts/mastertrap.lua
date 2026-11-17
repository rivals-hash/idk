-- This file was generated at discord.gg/syncrypt

local t1 = {}
local t2 = {}
local v3 = unpack or table.unpack
if not game:IsLoaded() then
    game.Loaded:Wait()
end
if setfpscap then
    setfpscap(999)
end
pcall(function()
    local v36 = setfflag or set_fflag

    if v36 then
        v36("FFlagDebugDisableTelemetry", "True")
        v36("DFFlagDisableTelemetry", "True")
        v36("FFlagDebugDisableCrashReporting", "True")
        v36("FFlagDisableCrashUpload", "True")
        v36("DFFlagCrashUploadFullDumps", "False")
        v36("FFlagGoogleAnalytics", "False")
        v36("FFlagRbxAnalyticsDisable", "True")
        v36("FFlagRobloxAnalyticsActive", "False")
        v36("FFlagDisableRobloxTelemetry", "True")
        v36("FFlagEnableTelemetryV2", "False")
        v36("FFlagTaskSchedulerLimitTargetFpsToScreen", "False")
        v36("DFFlagVariableMaxFpsEnabled", "True")
        v36("DFIntTaskSchedulerTargetFps", "999")
        v36("FIntFRMMaxFPS", "999")
    end
end)
pcall(function()
    local v37 = getgenv and getgenv()
    local v38 = v37

    if v38 then
        v38 = v37.MasterstrapScriptErrorConnection
    end

    if v38 then
        pcall(function()
            v37.MasterstrapScriptErrorConnection:Disconnect()
        end)
        v37.MasterstrapScriptErrorConnection = nil
    end

    local connection = game:GetService("ScriptContext").Error:Connect(function(_, _, _)
    end)

    if v37 then
        v37.MasterstrapScriptErrorConnection = connection
    end
end)
pcall(function()
    local v40 = getgenv and getgenv()
    local v41 = v40

    if v40 then
        v41 = v40.MasterstrapAntiAfkConnection
    end

    if v41 then
        pcall(function()
            v40.MasterstrapAntiAfkConnection:Disconnect()
        end)
        v40.MasterstrapAntiAfkConnection = nil
    end

    local VirtualUser = game:GetService("VirtualUser")
    local connection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)

    if v40 then
        v40.MasterstrapAntiAfkConnection = connection
    end
end)

if writefile then
    pcall(function()
        if makefolder then
            pcall(function()
                makefolder("autoexec")
            end)
        end

        writefile("autoexec/masterstrap_loader.lua", [[            -- Masterstrap Auto-Execute Bootstrapper
            task.spawn(function()
                repeat task.wait() until game:IsLoaded()
                if isfile and isfile("bridge.lua") then
                    local status, err = pcall(function()
                        loadstring(readfile("bridge.lua"))()
                    end)
                    if not status then
                        warn("Masterstrap Loader Error: " .. tostring(err))
                    end
                end
            end)
        ]])
    end)
end
t2.value1 = game:GetService("HttpService")
t2.value2 = game:GetService("Players")

local LocalPlayer = t2.value2.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = t2.value2.LocalPlayer
end
while true do
    t1.value1 = not LocalPlayer.UserId or LocalPlayer.UserId == 0

    if not t1.value1 then
        break
    end

    task.wait(0.1)
end
t2.value3 = tostring(LocalPlayer.UserId)
t2.value4 = "Masterstrap_Config_" .. t2.value3 .. ".json"
t2.value5 = "https://masterstrap.org/api"
function t2.value6()
    return {
		t2.value4,
		"Masterstrap/" .. t2.value4,
		"masterstrap/" .. t2.value4
	}
end
pcall(function()
    if t2.value1.HttpEnabled == false then
        t2.value1.HttpEnabled = true
    end
end)

function t2.value7(p4)
    if p4 == nil then
        return nil
    end

    if type(p4) == "string" then
        return p4
    end

    if type(p4) == "table" then
        local Body = p4.Body

        if not Body then
            Body = p4.body

            if not Body then
                Body = p4.Content

                if not Body then
                    Body = p4.content

                    if not Body then
                        Body = p4.Data or p4.data
                    end
                end
            end
        end

        return Body
    end

    return nil
end
function t2.value8(p5)
    if type(p5) ~= "table" then
        return nil
    end

    local StatusCode = p5.StatusCode

    if not StatusCode then
        StatusCode = p5.status_code

        if not StatusCode then
            StatusCode = p5.Status or p5.status
        end
    end

    return StatusCode
end
function t2.value9(p6)
    local v60 = p6 == nil

    if not v60 then
        v60 = p6 >= 200 and p6 < 300 or p6 == 404
    end

    return v60
end
function t2.value10()
    local ok, result = pcall(function()
        return game:GetService("UserInputService"):GetPlatform()
    end)

    if ok then
        ok = result == Enum.Platform.IOS
    end

    return ok
end
function t2.value11(p7)
    if p7 == nil then
        return nil
    end

    local v46 = type(p7)

    if v46 == "boolean" then
        return not p7 and "False" or "True"
    end

    if v46 == "number" then
        local v47 = p7 ~= p7

        if not v47 then
            v47 = p7 == 1e999

            if not v47 then
                v47 = p7 == -1e999
            end
        end

        if v47 then
            return 0
        end

        return p7
    end

    if v46 == "string" then
        return p7
    end

    if v46 == "table" then
        return nil
    end

    local ok, result = pcall(function()
        return (tostring(p7))
    end)

    if ok then
        ok = result and result ~= ""
    end

    if ok then
        return result
    end

    return nil
end
t2.value12 = 4
t2.value13 = nil
function t2.value13(p8, p9)
    local v89 = p9 or 0

    if type(p8) ~= "table" or v89 > t2.value12 then
        return {}
    end

    local t3 = {}

    for k, v in pairs(p8) do
        local v93
        local v94 = k
        if type(v94) == "string" then
            v93 = v94
        elseif type(v94) == "number" then
            v93 = tostring(v94)
        end
        if v93 and v93 ~= "" then
            if type(v) == "table" and v89 < t2.value12 then
                local v95 = t2.value13(v, v89 + 1)

                if next(v95) ~= nil then
                    t3[v93] = v95
                end
            else
                local v96 = t2.value11(v)

                if v96 ~= nil then
                    t3[v93] = v96
                end
            end
        end
    end

    return t3
end
function t2.value14(p10)
    return (tostring(p10):gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t"))
end
function t2.value15(p11)
    return "\"" .. t2.value14(p11) .. "\""
end
function t2.value16(p12)
    local v53 = p12 ~= p12

    if not v53 then
        v53 = p12 == 1e999

        if not v53 then
            v53 = p12 == -1e999
        end
    end

    if v53 then
        return "0"
    end

    local v54 = p12 == math.floor(p12)

    if v54 then
        v54 = math.abs(p12) < 1000000000000000
    end

    if v54 then
        return string.format("%.0f", p12)
    end

    return string.format("%.14g", p12)
end
t2.value17 = nil
function t2.value17(p13, p14)
    local v100 = p14 or 0

    if v100 > 12 then
        return "null"
    end

    local v101 = type(p13)

    if p13 == nil or v101 == "nil" then
        return "null"
    end

    if v101 == "boolean" then
        return not p13 and "false" or "true"
    end

    if v101 == "number" then
        return t2.value16(p13)
    end

    if v101 == "string" then
        return t2.value15(p13)
    end

    if v101 == "table" then
        local t4 = {}

        for k, v in pairs(p13) do
            local v105 = k

            if type(v105) == "string" and v105 ~= "" then
                local v106 = t2.value17(v, v100 + 1)

                t4[#t4 + 1] = t2.value15(v105) .. ":" .. v106
            end
        end

        return "{" .. table.concat(t4, ",") .. "}"
    end

    local v107 = t2.value11(p13)

    if v107 == nil then
        return "null"
    end

    return t2.value17(v107, v100 + 1)
end
function t2.value18(p15)
    if type(p15) ~= "table" then
        return nil, "not a table"
    end

    local ok, result = pcall(function()
        return t2.value1:JSONEncode(p15)
    end)
    local v111 = ok

    if ok then
        v111 = type(result) == "string" and result ~= ""
    end

    if v111 then
        return result, nil
    end

    local v112 = if not ok then tostring(result) else "JSONEncode returned empty"
    local ok2, result2 = pcall(function()
        return t2.value17(p15, 0)
    end)

    if ok2 then
        ok2 = type(result2) == "string" and result2 ~= ""
    end

    if ok2 then
        return result2, nil
    end

    return nil, v112 .. " | fallback: " .. tostring(result2)
end
function t2.value19(p16, p17)
    local t5 = {
		userId = tostring(p16),
		settingsData = p17
	}
    local ok, result = pcall(function()
        return t2.value1:JSONEncode(t5)
    end)

    if ok then
        ok = type(result) == "string" and result ~= ""
    end

    if ok then
        return result
    end

    return "{\"userId\":" .. t2.value15((tostring(p16))) .. ",\"settingsData\":" .. t2.value15(p17) .. "}"
end
function t2.value20(p18, p19, p20, p21)
    local v65 = p21 or {
		["Content-Type"] = "application/json"
	}
    local _request = request
    local s1 = "no transport"

    if not _request then
        _request = http_request

        if not _request then
            _request = syn

            if _request then
                _request = syn.request
            end

            if not _request then
                _request = http

                if _request then
                    _request = http.request
                end

                if not _request then
                    _request = fluxus

                    if _request then
                        _request = fluxus.request
                    end

                    if not _request then
                        local _krnl = krnl

                        if _krnl then
                            _krnl = krnl.request
                        end

                        _request = _krnl or requestInternal
                    end
                end
            end
        end
    end

    local v69 = _request

    if v69 then
        local ok, result = pcall(function()
            return v69({
				Url = p19,
				Method = p18,
				Headers = v65,
				Body = p20
			})
        end)

        if ok and result then
            local v72 = t2.value8(result)
            local v73 = t2.value7(result)

            if t2.value9(v72) then
                return true, v73 or "", v72
            end

            s1 = "executor http status " .. tostring(v72)
        elseif not ok then
            s1 = tostring(result)
        end
    end

    local ok, result = pcall(function()
        return t2.value1:RequestAsync({
			Url = p19,
			Method = p18,
			Headers = v65,
			Body = p20
		})
    end)

    if ok and result then
        local StatusCode = result.StatusCode

        if result.Success or t2.value9(StatusCode) then
            return true, result.Body or "", StatusCode
        end

        s1 = "RequestAsync status " .. tostring(StatusCode)
    elseif not ok then
        s1 = tostring(result)
    end

    if p18 == "GET" then
        local ok3, result3 = pcall(function()
            return game:HttpGet(p19, true)
        end)
        local v79 = not ok3

        if not v79 then
            v79 = not result3 or result3 == ""
        end

        if v79 then
            ok3, result3 = pcall(function()
                return game:HttpGet(p19)
            end)
        end

        local v80 = ok3

        if ok3 then
            v80 = result3 and result3 ~= ""
        end

        if v80 then
            return true, result3, 200
        end

        if not ok3 then
            s1 = tostring(result3)
        end
    elseif p18 == "POST" and p20 then
        local ok4, result4 = pcall(function()
            return game:HttpPost(p19, p20, v65["Content-Type"] or "application/json")
        end)
        local v83 = result4

        if ok4 then
            local v84 = type(v83) == "string"

            if v84 then
                v84 = v83 ~= ""
            end

            if not v84 then
                return true, "", 200
            end

            local ok5, result5 = pcall(function()
                return t2.value1:JSONDecode(v83)
            end)

            if ok5 then
                ok5 = result5 and result5.success == false
            end

            if not ok5 then
                return true, v83, 200
            end

            s1 = result5.error or "cloud save rejected"
        elseif not ok4 then
            s1 = tostring(v83)
        end
    end

    return false, nil, s1
end
task.spawn(function()
    pcall(function()
        local v1084 = (function(p22)
            local _crypt = crypt

            if _crypt then
                _crypt = crypt.hash
            end

            if _crypt then
                return crypt.hash(p22, "sha256")
            end

            local _syn = syn

            if _syn then
                _syn = syn.crypt

                if _syn then
                    _syn = syn.crypt.hash
                end
            end

            if _syn then
                return syn.crypt.hash(p22, "sha256")
            end

            local n1 = 2166136261

            for i = 1, #p22 do
                local v1540 = bit32.bxor(n1, string.byte(p22, i))

                n1 = bit32.imul(v1540, 16777619)
            end

            return tostring(n1)
        end)(t2.value3)
        local json = t2.value1:JSONEncode({
			user_hash = v1084,
			script_id = "bridge"
		})
        local _request = request

        if not _request then
            _request = http_request

            if not _request then
                _request = http

                if _request then
                    _request = http.request
                end

                if not _request then
                    _request = syn

                    if _request then
                        _request = syn.request
                    end
                end
            end
        end

        if _request then
            local t6 = {
				["Content-Type"] = "application/json"
			}

            _request({
				Url = "https://masterstrap.org/api/telemetry-record",
				Method = "POST",
				Headers = t6,
				Body = json
			})

            return
        end

        game:HttpPost("https://masterstrap.org/api/telemetry-record", json, "application/json")
    end)
end)
game:GetService("TweenService")

local t7 = {
	Version = "2.2.0",
	Logo = "rbxassetid://103107746630945"
}
local t8 = {
	applied = 0,
	verified = 0,
	checked = 0
}
local t9 = {
	ultra = false,
	mega = false,
	potato = false,
	descConn = nil,
	freezeConn = nil,
	restored = {},
	texCache = {},
	savedOrigLighting = nil,
	savedCameraFov = nil
}
local t10 = {
	fpsBoost = false,
	antiLag = false,
	antiFreeze = false,
	boostRestored = {},
	conAntiLag = nil,
	conAntiFreeze = nil,
	savedBoostLighting = nil,
	savedBoostQuality = nil,
	savedCameraMaxDist = nil
}
local t11 = {
	IsRunning = true,
	Connections = {},
	IsHooked = false,
	IsInjecting = false,
	CurrentInjectId = 0,
	HookGeneration = 0,
	LastInjectStats = t8,
	Capabilities = {},
	_lifecycleConnected = false,
	VisualStrip = {
		noTextures = false,
		noMeshes = false,
		noLightsParticles = false,
		lowSky = false,
		graySky = false,
		terrainWater = false,
		vulkanRenderer = false,
		conTextures = nil,
		conMeshes = nil,
		conLightsParticles = nil,
		conLowSky = nil,
		conGraySky = nil,
		conGraySkyMaintain = nil,
		conTerrainWater = nil,
		savedTerrainState = nil,
		conVulkan = nil,
		conVulkanLighting = nil,
		conVulkanMaintain = nil,
		savedLighting = nil,
		savedLowGraphicsLighting = nil,
		savedLowSkyLighting = nil,
		savedGraySkyLighting = nil,
		savedGraySkyColorShift = nil,
		savedSkyBox = nil,
		savedGraySkyBox = nil,
		savedGraySkyAtmosphere = nil,
		savedGraySkyHadAtmosphere = false,
		savedGraySkyCreatedAtmosphere = false,
		savedGraySkyClouds = nil,
		savedGraySkyHadClouds = false,
		savedGraySkyPostFx = nil,
		savedGraySkyCC = nil,
		savedGraySkyHadTechnology = nil,
		savedGraySkyFFlag = nil,
		savedGraySkyFog = nil,
		graySkyRestored = {},
		savedLowSkyDisabledFx = nil,
		savedAtmosphereProps = nil,
		savedQuality = nil,
		fpsUnlock = false,
		potatoFps = false,
		conTexturesMaintain = nil,
		noTextureMatCache = {},
		conLowSkyMaintain = nil,
		conLowSkyLighting = nil,
		_lifecycle = false,
		megaPreset = t9,
		megaBoost = t10
	}
}
local t12 = {
	Tabs = {},
	ActiveTab = "Mods"
}
local color3 = Color3.fromRGB(44, 44, 44)
local color3_2 = Color3.fromRGB(27, 27, 27)
local color3_3 = Color3.fromRGB(16, 132, 215)
local color3_4 = Color3.fromRGB(0, 188, 255)
local color3_5 = Color3.fromRGB(46, 46, 46)
local color3_6 = Color3.fromRGB(60, 60, 60)
local color3_7 = Color3.fromRGB(56, 56, 58)
local color3_8 = Color3.fromRGB(175, 175, 180)
local color3_9 = Color3.fromRGB(58, 58, 58)
local color3_10 = Color3.fromRGB(255, 255, 255)
local color3_11 = Color3.fromRGB(160, 160, 160)
local color3_12 = Color3.fromRGB(16, 132, 215)
local color3_13 = Color3.fromRGB(37, 37, 37)
local color3_14 = Color3.fromRGB(122, 232, 255)
local color3_15 = Color3.fromRGB(46, 204, 113)
local color3_16 = Color3.fromRGB(236, 66, 61)
local color3_17 = Color3.fromRGB(74, 74, 74)

t2.value21 = {
	Config = t7,
	ActiveFlags = {},
	InjectCatalog = {},
	NativeFlags = {},
	UIRegistry = {},
	OriginalNames = {},
	Callbacks = {},
	SavedPresets = {},
	LastUsedPreset = nil,
	ConfigFilePath = nil,
	System = t11,
	UI = t12,
	Theme = {
		MainBg = color3,
		SidebarBg = color3_2,
		Accent = color3_3,
		AccentAlt = color3_4,
		Card = color3_5,
		CardHover = color3_6,
		TabActiveBg = color3_7,
		TabActiveBar = color3_8,
		CardBorder = color3_9,
		Text = color3_10,
		Muted = color3_11,
		ToggleOn = color3_12,
		ToggleOff = color3_13,
		Terminal = color3_14,
		Green = color3_15,
		Red = color3_16,
		ScrollBar = color3_17,
		ScrollBarTransparency = 0.3,
		GlowImg = "rbxassetid://8992230677",
		GlowSmall = "rbxassetid://8992230903"
	}
}
function t2.value21.SetTopHUDVisible(p23, p24)
    local UI = p23.UI

    if UI then
        UI = p23.UI.TopHUD
    end

    if UI then
        pcall(function()
            p23.UI.TopHUD.Enabled = p24
        end)
    end
end
function t2.value21.ApplyScrollBarStyle(p25, p26, p27)
    if not p26 then
        return
    end

    p26.ScrollBarThickness = p27 or 4
    p26.ScrollBarImageColor3 = p25.Theme.ScrollBar
    pcall(function()
        p26.ScrollBarImageTransparency = p25.Theme.ScrollBarTransparency or 0.3
    end)
end
t2.value22 = "MasterstrapStretchRes"
function t2.value21.GetStretchResolutionScale(p28)
    local v127 = p28.ActiveFlags.StretchResolution or 100

    return (math.clamp((tonumber(v127) or 100) / 100, 0.01, 1))
end
function t2.value21.IsStretchResolutionEnabled(p29)
    return p29:GetStretchResolutionScale() < 1
end
function t2.value21.StopStretchResolution(p30)
    pcall(function()
        game:GetService("RunService"):UnbindFromRenderStep(t2.value22)
    end)

    if p30.System.stretchResConnection then
        pcall(function()
            p30.System.stretchResConnection:Disconnect()
        end)
        p30.System.stretchResConnection = nil
    end

    local v130 = getgenv and getgenv()
    local v131 = v130

    if v131 then
        v131 = v130.Masterstrap_StretchResConn
    end

    if v131 then
        pcall(function()
            v130.Masterstrap_StretchResConn:Disconnect()
        end)
        v130.Masterstrap_StretchResConn = nil
    end
end
function t2.value21.ApplyStretchResolutionToCamera(p31, p32)
    if not p32 or not p31:IsStretchResolutionEnabled() then
        return
    end

    local StretchResolutionScale = p31:GetStretchResolutionScale()

    p32.CFrame = p32.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, StretchResolutionScale, 0, 0, 0, 1)
end
function t2.value21.StartStretchResolution(p33)
    p33:StopStretchResolution()

    if not p33:IsStretchResolutionEnabled() then
        return
    end

    game:GetService("RunService"):BindToRenderStep(t2.value22, Enum.RenderPriority.Last.Value, function()
        if not p33:IsStretchResolutionEnabled() then
            return
        end

        p33:ApplyStretchResolutionToCamera(workspace.CurrentCamera)
    end)
end
function t2.value21.SyncStretchResolutionFromFlags(p34)
    if p34:IsStretchResolutionEnabled() then
        p34:StartStretchResolution()

        return
    end

    p34:StopStretchResolution()
end
function t2.value21.IsOptimizerEphemeralFlag(_, p36)
    if type(MASTERSTRAP_OPTIMIZER_EPHEMERAL) ~= "table" then
        return false
    end

    return MASTERSTRAP_OPTIMIZER_EPHEMERAL[p36] == true
end
function t2.value21.BuildPersistedActiveFlags(p37)
    local _tostring = tostring
    local _CustomBox = p37.ActiveFlags._CustomBox

    if not _CustomBox then
        _CustomBox = p37.CustomBoxData or ""
    end

    local t13 = {
		_CustomBox = _tostring(_CustomBox)
	}

    for k, _ in pairs(p37.UIRegistry) do
        local v149 = k

        if not p37:IsOptimizerEphemeralFlag(v149) then
            local v150 = p37.ActiveFlags[v149]

            if v150 ~= nil then
                local v151 = type(v150)

                if v151 == "boolean" then
                    t13[v149] = not v150 and "False" or "True"
                elseif v151 == "string" or v151 == "number" then
                    t13[v149] = v150
                end
            end
        end
    end

    return t13
end
function t2.value21.BuildSettingsPayload(p38)
    pcall(function()
        p38:SanitizeSavedPresetsOptimizerFlags()
    end)

    local v153 = p38.SavedPresets or {}
    local _tostring = tostring
    local _CustomBox = p38.ActiveFlags._CustomBox

    if not _CustomBox then
        _CustomBox = p38.CustomBoxData or ""
    end

    local v156 = _tostring(_CustomBox)
    local v157 = p38:BuildPersistedActiveFlags()
    local num = tonumber(os.time())
    local t14 = {
		Presets = v153,
		CustomFlags = v156,
		ActiveFlags = v157,
		Timestamp = num or 0
	}
    local v160 = p38.LastUsedPreset ~= nil

    if v160 then
        v160 = tostring(p38.LastUsedPreset) ~= ""
    end

    if v160 then
        t14.LastUsed = tostring(p38.LastUsedPreset)
    end

    return t14
end
function t2.value21.EncodeSettingsBlob(_, p40)
    local u163 = p40
    local ok, result = pcall(function()
        return t2.value1:JSONEncode(u163)
    end)
    local v166 = ok
    if ok then
        v166 = type(result) == "string" and result ~= ""
    end
    if v166 then
        return result, nil
    end
    local v167 = if not ok then tostring(result) else "JSONEncode returned empty"
    local v168 = t2.value13(u163.Presets or {}, 0)
    local v169 = t2.value11(u163.CustomFlags) or ""
    local v170 = t2.value13(u163.ActiveFlags or {}, 0)
    local v171 = tonumber(u163.Timestamp) or 0
    local t15 = {
		Presets = v168,
		CustomFlags = v169,
		ActiveFlags = v170,
		Timestamp = v171
	}
    if u163.LastUsed then
        t15.LastUsed = tostring(u163.LastUsed)
    end
    local ok6, result6 = pcall(function()
        return t2.value1:JSONEncode(t15)
    end)
    if ok6 then
        ok6 = type(result6) == "string" and result6 ~= ""
    end
    if ok6 then
        return result6, nil
    end
    local v175, v176 = t2.value18(t15)
    if v175 then
        return v175, nil
    end

    return nil, v167 .. " | " .. tostring(v176)
end
function t2.value21.MigrateLegacyActiveFlagsBloat(p41)
    local _CustomBox = p41.ActiveFlags._CustomBox
    if not _CustomBox then
        _CustomBox = p41.CustomBoxData or ""
    end
    if _CustomBox == "" then
        return
    end
    local v179 = p41:ParseCustomFlagsToCatalog(_CustomBox)
    local n2 = 0
    for v183 in pairs(p41.ActiveFlags) do

        if v183 ~= "_CustomBox" and v179[v183] then
            p41.ActiveFlags[v183] = nil
            n2 += 1
        end
    end
    if n2 > 0 then
        p41.InjectCatalog = v179
    end
end
function t2.value21.PurgeInjectBloat(p42)
    local t16 = {
		_CustomBox = true
	}
    for k, _ in pairs(p42.UIRegistry) do
        t16[k] = true
    end
    for v190 in pairs(p42.ActiveFlags) do

        if not t16[v190] then
            p42.ActiveFlags[v190] = nil
        end
    end
    for k, _ in pairs(p42.OriginalNames) do
        local v193 = k
        local v194 = not t16[v193]

        if v194 then
            v194 = not p42.InjectCatalog and p42.InjectCatalog[v193]
        end

        if v194 then
            p42.OriginalNames[v193] = nil
        end
    end
end
function t2.value21.GetFlagOverride(p43, p44)
    local v197 = p43.ActiveFlags[p44]

    if v197 ~= nil then
        return v197
    end

    local v198 = p43.InjectCatalog and p43.InjectCatalog[p44]

    if v198 then
        return v198.val
    end

    return nil
end
function t2.value21.HasLocalFilesystem(_)
    return writefile ~= nil and readfile ~= nil
end
function t2.value21.WriteConfigFile(p46, p47)
    if not writefile or not p47 then
        return false
    end

    if p46.ConfigFilePath and pcall(function()
        writefile(p46.ConfigFilePath, p47)
    end) then
        return true
    end

    for _, v in ipairs(t2.value6()) do
        local v204 = v

        if pcall(function()
            local v1088 = v204:match("^(.+)/[^/]+$")

            if v1088 and makefolder then
                pcall(function()
                    makefolder(v1088)
                end)
            end

            writefile(v204, p47)
        end) then
            p46.ConfigFilePath = v204

            return true
        end
    end

    return false
end
function t2.value21.ReadConfigFile(p48)
    if not readfile then
        return nil
    end
    local t17 = {}
    if p48.ConfigFilePath then
        t17[1] = p48.ConfigFilePath
    end
    for v209, v210 in ipairs(t2.value6()) do

        if v210 ~= p48.ConfigFilePath then
            t17[#t17 + 1] = v210
        end
    end
    for _, v in ipairs(t17) do
        local v213 = v
        local v214 = true

        if isfile then
            v214 = isfile(v213)
        end

        if v214 then
            local ok, result = pcall(function()
                return readfile(v213)
            end)

            if ok then
                ok = result and result ~= ""
            end

            if ok then
                p48.ConfigFilePath = v213

                return result
            end
        end
    end

    return nil
end
function t2.value21.CacheSettingsBlob(_, p50)
    local v219 = getgenv and getgenv()

    if v219 then
        v219.MasterstrapSettingsCache = p50
    end
end
function t2.value21.LoadCachedSettings(_)
    local v221 = getgenv and getgenv()
    local v222 = not v221

    if not v222 then
        v222 = not v221.MasterstrapSettingsCache
    end

    if v222 then
        return nil
    end

    local ok, result = pcall(function()
        return t2.value1:JSONDecode(v221.MasterstrapSettingsCache)
    end)

    if ok and result then
        return result
    end

    return nil
end
function t2.value21.ApplyLoadedSettings(p52, p53, p54)
    if not p53 then
        return false
    end

    p52.SavedPresets = p53.Presets or {}
    p52.LastUsedPreset = p53.LastUsed
    p52.CustomBoxData = p53.CustomFlags or ""

    if p53.ActiveFlags then
        for k, v in pairs(p53.ActiveFlags) do
            p52.ActiveFlags[k] = v
        end
    end

    p52:StripEphemeralOptimizerFlags()
    p52:SanitizeSavedPresetsOptimizerFlags()
    p52:MigrateLegacyActiveFlagsBloat()
    p52:Log("Loaded settings from " .. p54 or "storage")

    return true
end
function t2.value21.CapturePresetConfig(p55)
    local t18 = {}

    for k, v in pairs(p55.UIRegistry) do
        local v234 = k

        if not p55:IsOptimizerEphemeralFlag(v234) then
            local v235 = p55.ActiveFlags[v234]
            local v236 = v235 == nil

            if v236 then
                v236 = type(v) == "table"
            end

            if v236 then
                for _, v2 in ipairs(v) do
                    if v2.Type == "Input" and v2.TextBox then
                        v235 = v2.TextBox.Text
                    elseif v2.Type == "Toggle" and v2.Bg then
                        v235 = v2.Bg.BackgroundColor3 ~= p55.Theme.ToggleOn and "False" or "True"
                    elseif v2.Type == "Slider" and v2.LastValue ~= nil then
                        v235 = v2.LastValue
                    end
                end
            end

            if v235 ~= nil then
                local v239 = type(v235)

                if v239 == "boolean" then
                    t18[v234] = not v235 and "False" or "True"
                else
                    local v240 = v239 == "string"

                    if not v240 then
                        v240 = v239 == "number"
                    end

                    if v240 then
                        t18[v234] = v235
                    end
                end
            end
        end
    end

    return t18
end
function t2.value21.SaveToDisk(p56)
    p56:PurgeInjectBloat()

    local v242, v243 = p56:EncodeSettingsBlob((p56:BuildSettingsPayload()))
    local v244 = v242

    if not v244 then
        warn("[Masterstrap] SaveToDisk: JSON encode failed:", (tostring(v243)))
        p56:Log("Save Error: Failed to encode settings")

        return false
    end

    p56:CacheSettingsBlob(v244)

    local v245 = p56:WriteConfigFile(v244)

    if writefile and not v245 then
        warn("[Masterstrap] writefile failed for all config paths")
    end

    local v246 = false

    if p56:HasLocalFilesystem() and v245 then
        task.spawn(function()
            pcall(function()
                p56:SaveToCloud(v244)
            end)
        end)
    else
        local success, result = pcall(function()
            return p56:SaveToCloud(v244)
        end)
        if success then
            v246 = result == true
        end
    end

    if v245 then
        return true
    end

    if v246 then
        return true
    end

    if not p56:HasLocalFilesystem() and v244 then
        return true
    end

    return false
end
function t2.value21.SaveToCloud(p57, p58)
    if type(p58) ~= "string" or p58 == "" then
        warn("[Masterstrap] SaveToCloud: empty settings blob")

        return false
    end

    local v251 = t2.value19(t2.value3, p58)

    if not v251 or v251 == "" then
        warn("[Masterstrap] SaveToCloud: failed to build request payload")

        return false
    end

    local v252 = t2.value5 .. "/settings/save"
    local v253 = not t2.value10() and 2 or 3

    for i = 1, v253 do
        local v255 = i
        local v256, v257, v258 = t2.value20("POST", v252, v251, {
			["Content-Type"] = "application/json"
		})
        local v259 = v257
        local v260 = v256

        if v256 then
            v260 = v259

            if v260 then
                v260 = v259 ~= ""
            end
        end

        if v260 then
            local ok, result = pcall(function()
                return t2.value1:JSONDecode(v259)
            end)
            local v263 = ok

            if ok then
                v263 = result and result.success
            end

            if v263 then
                p57:Log("Settings saved to cloud")

                return true
            end

            if ok then
                ok = result and result.error
            end

            if ok then
                warn("[Masterstrap] SaveToCloud rejected:", (tostring(result.error)))
            end
        else
            if v256 then
                v256 = v258 == 200

                if not v256 then
                    v256 = v258 == 201 or v258 == 204
                end
            end

            if v256 then
                p57:Log("Settings saved to cloud")

                return true
            end
        end

        if v255 < v253 then
            task.wait(0.35 * v255)
        else
            warn("[Masterstrap] SaveToCloud failed after " .. v253 .. " attempts:", (tostring(v259 or v258)))
        end
    end

    return false
end
function t2.value21.LoadSettingsFromCloud(_)
    local v265 = t2.value5 .. "/settings/load?userId=" .. t2.value3
    local v266 = not t2.value10() and 2 or 3

    for i = 1, v266 do
        local v268 = i
        local v269, v270, v271 = t2.value20("GET", v265, nil, {
			["Content-Type"] = "application/json"
		})
        local v272 = v269
        local v273 = v270

        if v269 then
            v272 = v273

            if v272 then
                v272 = v273 ~= ""
            end
        end

        if v272 then
            local ok, result = pcall(function()
                return t2.value1:JSONDecode(v273)
            end)
            local v276 = result

            if ok and v276 then
                local success = v276.success

                if success then
                    success = v276.settingsData
                end

                if success then
                    local ok7, result7 = pcall(function()
                        local settingsData = v276.settingsData

                        if type(settingsData) == "table" then
                            return settingsData
                        end

                        return t2.value1:JSONDecode(settingsData)
                    end)

                    if ok7 and result7 then
                        return result7
                    end
                else
                    local v280 = v276.success == false

                    if v280 then
                        v280 = v276.error == "Settings not found"
                    end

                    if v280 then
                        return nil
                    end
                end
            end
        elseif v269 and v271 == 404 then
            return nil
        end

        if v268 < v266 then
            task.wait(0.35 * v268)
        end
    end

    return nil
end
function t2.value21.LoadSettings(p60)
    p60.SavedPresets = p60.SavedPresets or {}
    pcall(function()
        local u1090
        local v1091 = p60:HasLocalFilesystem()
        if v1091 then
            local v1092 = p60:ReadConfigFile()

            if v1092 then
                pcall(function()
                    local data = t2.value1:JSONDecode(v1092)

                    if data then
                        u1090 = data
                    end
                end)
            end
        end
        local v1093 = v1091
        local v1094
        local v1095 = p60:LoadSettingsFromCloud()
        local s2
        if v1091 then
            v1093 = u1090 and v1095
        end
        if v1093 then
            if (u1090.Timestamp or 0) < (v1095.Timestamp or 0) then
                v1094 = v1095
                s2 = "cloud (newer)"
            else
                v1094 = u1090
                s2 = "local disk (newer/equal)"
            end
        elseif v1091 and u1090 then
            v1094 = u1090
            s2 = "local disk"
        elseif v1095 then
            v1094 = v1095
            s2 = "cloud"
        else
            local v1097 = p60:LoadCachedSettings()

            if v1097 then
                v1094 = v1097
                s2 = "session cache"
            end
        end
        if v1094 then
            p60:ApplyLoadedSettings(v1094, s2)

            local v1098 = t2.value13(v1094.Presets or {}, 0)
            local v1099 = t2.value11(v1094.CustomFlags) or ""
            local v1100 = t2.value13(v1094.ActiveFlags or {}, 0)
            local v1101 = tonumber(v1094.Timestamp) or 0
            local t20 = {
				Presets = v1098,
				CustomFlags = v1099,
				ActiveFlags = v1100,
				Timestamp = v1101
			}

            if v1094.LastUsed then
                t20.LastUsed = tostring(v1094.LastUsed)
            end

            local v1103 = p60:EncodeSettingsBlob(t20)

            if v1103 then
                p60:CacheSettingsBlob(v1103)
            end
        else
            p60:Log("No saved settings found")
        end
    end)
end
function t2.value23(p61)
    if not p61 then
        return ""
    end

    local v283 = p61:sub(1, 2)
    local v284 = v283 ~= "DF"

    if v284 then
        v284 = v283 ~= "FF"

        if v284 then
            v284 = v283 ~= "FI" and v283 ~= "FS"
        end
    end

    if v284 then
        return p61
    end

    return p61:gsub("^DFInt", ""):gsub("^DFFlag", ""):gsub("^FFlag", ""):gsub("^FInt", ""):gsub("^DFString", ""):gsub("^FString", "")
end
t2.value24 = nil
t2.value24 = {
	"telemetry",
	"analytics",
	"crash",
	"taskscheduler",
	"targetfps",
	"frm",
	"fps",
	"ping",
	"network",
	"raknet",
	"physics",
	"unlock240",
	"variablemaxfps"
}
function t2.value25(p62)
    local lower = string.lower

    if not p62 then
        p62 = ""
    end

    local v287 = lower(p62)

    for i, v in ipairs(t2.value24) do
        if v287:find(v, 1, true) then
            return i
        end
    end

    return 50
end
function t2.value26(p63, p64)
    local t21 = {}
    local t22 = {}
    local v294 = p64
    if p64 then
        v294 = p64 ~= "" and not t21[p64]
    end
    if v294 then
        t21[p64] = true
        t22[#t22 + 1] = p64
    end
    local v295 = p63
    local v296 = p63
    if p63 then
        v296 = p63 ~= "" and not t21[p63]
    end
    if v296 then
        t21[p63] = true
        t22[#t22 + 1] = p63
    end
    if p63 then
        v295 = not p63:match("^FFlag")

        if v295 then
            v295 = not p63:match("^DF")

            if v295 then
                v295 = not p63:match("^FI")
            end
        end
    end
    if v295 then
        local v297 = "FFlag" .. p63
        local v298 = v297

        if v297 then
            v298 = v297 ~= "" and not t21[v297]
        end

        if v298 then
            t21[v297] = true
            t22[#t22 + 1] = v297
        end

        local v299 = "DFFlag" .. p63
        local v300 = v299

        if v299 then
            v300 = v299 ~= "" and not t21[v299]
        end

        if v300 then
            t21[v299] = true
            t22[#t22 + 1] = v299
        end

        local v301 = "DFInt" .. p63
        local v302 = v301

        if v301 then
            v302 = v301 ~= "" and not t21[v301]
        end

        if v302 then
            t21[v301] = true
            t22[#t22 + 1] = v301
        end

        local v303 = "FInt" .. p63
        local v304 = v303

        if v303 then
            v304 = v303 ~= "" and not t21[v303]
        end

        if v304 then
            t21[v303] = true
            t22[#t22 + 1] = v303
        end
    end

    return t22
end
function t2.value27(p65, p66)
    if p66 == nil then
        return false
    end

    local v307 = string.lower((tostring(p65)))
    local v308 = string.lower((tostring(p66)))

    if v307 == v308 then
        return true
    end

    local num = tonumber(v307)
    local num2 = tonumber(v308)
    local v311 = num ~= nil

    if v311 then
        v311 = num2 ~= nil and num == num2
    end

    return v311
end
function t2.value21.SetFlagInternal(p67, p68, p69, p70)
    local v316 = t2.value23(p68)

    if p69 == nil then
        p67.ActiveFlags[v316] = nil
        p67.NativeFlags[v316] = nil
    else
        local v317 = p69

        if type(p69) == "string" then
            if p69:lower() == "true" then
                v317 = "True"
            elseif p69:lower() == "false" then
                v317 = "False"
            end
        end

        p67.ActiveFlags[v316] = v317
        p67.NativeFlags[v316] = v317

        if p68 ~= v316 then
            p67.OriginalNames[v316] = p68
        end
    end

    local v318 = not p70

    if v318 then
        v318 = p67.Callbacks[v316]
    end

    if v318 then
        local v319 = p69
        local u320 = p69
        local _tostring = tostring

        if not p69 then
            v319 = ""
        end

        local v322 = _tostring(v319):lower()
        local v323 = v322 == "true"

        if not v323 then
            v323 = v322 == "1" or v322 == "on"
        end

        if v323 then
            u320 = true
        else
            local v324 = v322 == "false"

            if not v324 then
                v324 = v322 == "0" or v322 == "off"
            end

            if v324 then
                u320 = false
            elseif tonumber(p69) ~= nil then
                u320 = tonumber(p69)
            end
        end

        pcall(function()
            p67.Callbacks[v316](u320)
        end)
    end
end
t2.value28 = {
	OptimizerUltraMode = true,
	OptimizerMegaBoost = true,
	OptimizerPotatoMode = true
}
t2.value29 = {
	NoTexturesEnable = true,
	NoMeshesEnable = true,
	OptimizerVulkanEnable = true,
	FFlagDebugGraphicsPreferVulkan = true,
	OptimizerFpsUnlock = true,
	OptimizerLowSkyEnable = true,
	OptimizerGraySkyEnable = true,
	OptimizerNoLightsParticlesEnable = true,
	OptimizerTerrainWaterEnable = true,
	OptimizerMegaFpsBoost = true,
	OptimizerMegaAntiLag = true,
	OptimizerMegaAntiFreeze = true
}
function t2.value21.SetFlag(p71, p72, p73, p74)
    p71.LastUsedPreset = nil

    local v336 = t2.value23(p72)
    local v337 = tostring(p73 or ""):lower() == "true"

    if t2.value29[v336] and v337 then
        p71:ClearOptimizerPresets(nil)
    end

    if t2.value28[v336] and v337 then
        p71:ClearOptimizerPresets(v336)
    end

    p71:SetFlagInternal(p72, p73, false)

    local v338 = not p74

    if v338 then
        v338 = p73 ~= nil

        if v338 then
            v338 = setfflag or set_fflag
        end
    end

    if v338 then
        local v339 = p72 ~= v336 and p72 or p71.OriginalNames[v336]
        local v340 = t2.value26(v336, v339)

        for _, v in ipairs(v340) do
            local v343 = v

            pcall(function()
                (setfflag or set_fflag)(v343, (tostring(p73)))
            end)
        end
    end

    p71:RefreshUIVisuals(v336)
    p71:SaveToDisk()
end
function t2.value21.RefreshUIVisuals(p75, p76)
    local v346 = p75.UIRegistry[p76]

    if not v346 then
        return
    end

    local v347 = p75.ActiveFlags[p76]
    local v348 = tostring(v347 or ""):lower()

    for _, v in ipairs(v346) do
        if v.Type == "Toggle" then
            local v351 = v348 == "true"

            if not v351 then
                v351 = v348 == "1" or v348 == "on"
            end

            if p76 == "TextureCompositorActiveJobs" then
                v351 = v347 == 0 or v347 == "0"
            end

            local Bg = v.Bg
            local v353 = v351

            if v351 then
                v353 = p75.Theme.ToggleOn
            end

            if not v353 then
                v353 = p75.Theme.ToggleOff
            end

            Bg.BackgroundColor3 = v353

            local Knob = v.Knob

            if v351 then
                v351 = UDim2.new(1, -20, 0.5, -9)
            end

            if not v351 then
                v351 = UDim2.new(0, 2, 0.5, -9)
            end

            Knob:TweenPosition(v351, "Out", "Quad", 0.2, true)
        elseif v.Type == "Input" then
            local TextBox = v.TextBox
            local v356 = v347
            local _tostring = tostring

            if not v347 then
                v356 = ""
            end

            TextBox.Text = _tostring(v356)
        end
    end
end
local function v28(p77)
    local v361 = p77 or 1
    local RunService = game:GetService("RunService")
    local n3 = 0

    while true do
        n3 += 1

        if not (n3 <= v361) then
            break
        end

        RunService.Heartbeat:Wait()
    end
end
function t2.value30(p78)
    local t23 = {
		drip_wait = 0.008,
		variant_wait = 0.004,
		batch_every = 0,
		batch_pause = 0,
		batch_frames = 0,
		verify_limit = 28,
		retry_limit = 12,
		log_each_custom = true
	}

    if p78 >= 500 then
        t23.drip_wait = 0.018
        t23.variant_wait = 0.003
        t23.batch_every = 24
        t23.batch_pause = 0.14
        t23.batch_frames = 2
        t23.verify_limit = 16
        t23.retry_limit = 10
        t23.log_each_custom = false

        return t23
    end

    if p78 >= 300 then
        t23.drip_wait = 0.014
        t23.batch_every = 32
        t23.batch_pause = 0.11
        t23.batch_frames = 1
        t23.verify_limit = 20

        return t23
    end

    if p78 >= 150 then
        t23.drip_wait = 0.012
        t23.batch_every = 50
        t23.batch_pause = 0.08

        return t23
    end

    if p78 >= 80 then
        t23.drip_wait = 0.01
    end

    return t23
end
function t2.value31(p79)
    local t24 = {}
    local t25 = {}

    for _, v in ipairs(p79) do
        local v330 = v[1]
        local v331 = t24[v330]

        if v331 then
            t25[v331] = v
        else
            t25[#t25 + 1] = v
            t24[v330] = #t25
        end
    end

    return t25
end
function t2.value21.ParseCustomFlagsToCatalog(p80, p81)
    local t26 = {}
    if not p81 or p81 == "" then
        return t26
    end
    local function v373(p82, p83)
        local v1109 = not p82

        if not v1109 then
            v1109 = p82 == ""
        end

        if v1109 then
            return
        end

        if p82:match("MacPlayer") or p82:match("WindowsPlayer") then
            return
        end

        if p83 == "null" or p83 == "" then
            return
        end

        local v1110 = t2.value23(p82)

        if p80.UIRegistry[v1110] then
            return
        end

        if type(p83) == "string" then
            if p83:lower() == "true" then
                p83 = "True"
            elseif p83:lower() == "false" then
                p83 = "False"
            end
        end

        t26[v1110] = {
			val = p83,
			orig = p82
		}
        p80.OriginalNames[v1110] = p82
    end
    for v376, v377 in p81:gmatch("\"(.-)\"%s*:%s*\"(.-)\"") do

        v373(v376, v377)
    end
    for match, v379 in p81:gmatch("\"(.-)\"%s*:%s*(%d+)") do
        v373(match, tonumber(v379))
    end
    for v382 in p81:gmatch("\"(.-)\"%s*:%s*(true)") do

        v373(v382, "True")
    end
    for match in p81:gmatch("\"(.-)\"%s*:%s*(false)") do
        v373(match, "False")
    end

    return t26
end
function t2.value32(p84, p85)
    local str = tostring(p85)
    local _setfflag = setfflag
    local _set_fflag = set_fflag
    local _setfastflag = setfastflag
    local _set_fast_flag = set_fast_flag
    local _setfastflagforall = setfastflagforall
    local _getgenv = getgenv

    if _getgenv then
        _getgenv = type(getgenv) == "function"

        if _getgenv then
            _getgenv = getgenv().setfflag
        end
    end

    local _getgenv2 = getgenv

    if _getgenv2 then
        _getgenv2 = type(getgenv) == "function"

        if _getgenv2 then
            _getgenv2 = getgenv().set_fflag
        end
    end

    local _getgenv3 = getgenv

    if _getgenv3 then
        _getgenv3 = type(getgenv) == "function"

        if _getgenv3 then
            _getgenv3 = getgenv().setfastflag
        end
    end

    local _getgenv4 = getgenv

    if _getgenv4 then
        _getgenv4 = type(getgenv) == "function"

        if _getgenv4 then
            _getgenv4 = getgenv().set_fast_flag
        end
    end

    for _, v in ipairs({
		_setfflag,
		_set_fflag,
		_setfastflag,
		_set_fast_flag,
		_setfastflagforall,
		_getgenv,
		_getgenv2,
		_getgenv3,
		_getgenv4
	}) do
        local v398 = v
        local v399 = v398

        if v399 then
            v399 = type(v398) == "function"
        end

        if v399 and pcall(function()
            v398(p84, str)
        end) then
            return true
        end
    end

    return false
end
function t2.value33(p86)
    local _getfflag = getfflag

    if not _getfflag then
        _getfflag = get_fflag

        if not _getfflag then
            _getfflag = getgenv

            if _getfflag then
                _getfflag = type(getgenv) == "function"

                if _getfflag then
                    _getfflag = getgenv().getfflag

                    if not _getfflag then
                        _getfflag = getgenv().get_fflag
                    end
                end
            end
        end
    end

    local v402 = _getfflag

    if not v402 then
        return nil
    end

    local ok, result = pcall(function()
        return v402(p86)
    end)

    if ok then
        return result
    end

    return nil
end
function t2.value34(p87, p88)
    local v366 = tostring(p88):lower()
    local v367 = v366 == "true"

    if not v367 then
        v367 = v366 == "1" or v366 == "on"
    end

    local v368 = v367
    local num = tonumber(p88)

    pcall(function()
        local RenderSettings = settings():GetService("RenderSettings")

        if p87 == "DebugFRMQualityLevelOverride" and num then
            RenderSettings.EditQualityLevel = num
            RenderSettings.QualityLevel = num
        end
    end)
    pcall(function()
        if p87 == "DebugForceDisableShadows" then
            game:GetService("Lighting").GlobalShadows = not v368
        end
    end)
    pcall(function()
        if p87 == "RenderShadowIntensity" and num then
            game:GetService("Lighting").ShadowSoftness = num
        end
    end)
    pcall(function()
        if p87 == "RenderGrassHeightScaler" and num then
            workspace.GrassLength = num
        end
    end)
end
local function v29(p89, p90, p91, p92)
    local v414 = p92 or 0.004
    local v415 = t2.value26(p89, p91)
    local v416 = false

    for i, v in ipairs(v415) do
        if t2.value32(v, p90) then
            v416 = true
        end

        if v414 > 0 and i < #v415 then
            task.wait(v414)
        end
    end

    t2.value34(p89, p90)

    return v416
end
function t2.value35(p93)
    local v406 = t2.value26(p93, nil)

    for _, v in ipairs(v406) do
        local v409 = t2.value33(v)

        if v409 ~= nil then
            return v409, v
        end
    end

    return nil, nil
end
function t2.value21.DetectCapabilities(p94)
    local t27 = {
		setfflag = false,
		getfflag = false,
		hookfunction = false,
		get_module_base = false,
		setfpscap = false,
		clipboard = false,
		filesystem = false,
		platform = "Unknown",
		setfflag = setfflag ~= nil or set_fflag ~= nil
	}
    local v421 = getfflag ~= nil

    if not v421 then
        v421 = get_fflag ~= nil
    end

    t27.getfflag = v421
    t27.hookfunction = hookfunction ~= nil
    t27.get_module_base = get_module_base ~= nil
    t27.setfpscap = setfpscap ~= nil
    t27.clipboard = setclipboard ~= nil or toclipboard ~= nil
    t27.filesystem = writefile ~= nil and readfile ~= nil
    pcall(function()
        t27.platform = tostring(game:GetService("UserInputService"):GetPlatform())
    end)
    p94.System.Capabilities = t27

    return t27
end
function t2.value21.GetCapabilitySummary(p95)
    local Capabilities = p95.System.Capabilities

    if not Capabilities or Capabilities.platform == nil then
        Capabilities = p95:DetectCapabilities()
    end

    local v424 = not p95.System.IsHooked and "OFF" or "ON"

    return string.format("Hook %s | setfflag:%s getfflag:%s | %s", v424, not Capabilities.setfflag and "NO" or "OK", not Capabilities.getfflag and "NO" or "OK", Capabilities.platform)
end
function t2.value21.VerifyInjectedFlags(p96, p97)
    local _getfflag = getfflag

    if not _getfflag then
        _getfflag = get_fflag

        if not _getfflag then
            _getfflag = getgenv

            if _getfflag then
                _getfflag = type(getgenv) == "function"

                if _getfflag then
                    _getfflag = getgenv().getfflag

                    if not _getfflag then
                        _getfflag = getgenv().get_fflag
                    end
                end
            end
        end
    end

    if not _getfflag then
        return nil
    end

    local v428 = p97 or 30
    local n4 = 0
    local n5 = 0
    local n6 = 0
    local t28 = {}

    for k, v in pairs(p96.NativeFlags) do
        local v435 = k

        if v428 <= n5 then
            return {
				checked = n5,
				verified = n6,
				failed = n4,
				failed_names = t28
			}
        end

        local v436 = t2.value35(v435)

        if v436 ~= nil then
            n5 += 1

            if t2.value27(v, v436) then
                n6 += 1
            else
                n4 += 1
                t28[#t28 + 1] = v435
            end
        end
    end

    return {
		checked = n5,
		verified = n6,
		failed = n4,
		failed_names = t28
	}
end
function t2.value21.TrackConnection(p98, p99)
    if not p99 then
        return nil
    end

    local System = p98.System

    if not System then
        return p99
    end

    System.Connections = System.Connections or {}
    table.insert(System.Connections, p99)

    return p99
end
function t2.value21.Shutdown(p100)
    local System = p100.System

    if not System or not System.IsRunning then
        return
    end

    pcall(function()
        p100:DisableNoTextures()
    end)
    pcall(function()
        p100:DisableNoMeshes()
    end)
    pcall(function()
        p100:DisableLowTextureSky()
    end)
    pcall(function()
        p100:DisableGraySky()
    end)
    pcall(function()
        p100:DisableNoLightsParticles()
    end)
    pcall(function()
        p100:DisableTerrainWaterOptimize()
    end)
    pcall(function()
        p100:DisableVulkanRenderer()
    end)
    pcall(function()
        p100:ApplyOptimizerFpsUnlock(false)
    end)
    pcall(function()
        p100:ApplyOptimizerPresetPotato(false)
    end)
    pcall(function()
        p100:ApplyOptimizerPresetMega(false)
    end)
    pcall(function()
        p100:ApplyOptimizerPresetUltra(false)
    end)
    pcall(function()
        p100:ApplyOptimizerMegaAntiFreeze(false)
    end)
    pcall(function()
        p100:ApplyOptimizerMegaAntiLag(false)
    end)
    pcall(function()
        p100:ApplyOptimizerMegaFpsBoost(false)
    end)
    System.IsRunning = false
    System._lifecycleConnected = false

    local v442 = System.Connections or {}

    for i = #v442, 1, -1 do
        local u444 = i
        pcall(function()
            v442[u444]:Disconnect()
        end)
        v442[u444] = nil
    end

    pcall(function()
        local UI = p100.UI

        if UI then
            UI = p100.UI.ScreenGui
        end

        if UI then
            p100.UI.ScreenGui:Destroy()
        end
    end)
    pcall(function()
        local UI = p100.UI

        if UI then
            UI = p100.UI.TopHUD
        end

        if UI then
            p100.UI.TopHUD:Destroy()
        end
    end)

    local v445 = getgenv and getgenv()

    if v445 and p100 == v445.MasterstrapInstance then
        v445.MasterstrapInstance = nil
    end
end
function t2.value21.SetupInjectLifecycle(p101)
    if p101.System._lifecycleConnected then
        return
    end

    p101.System._lifecycleConnected = true

    local function u447()
        task.wait(0.35)
        p101:DetectCapabilities()

        if p101:InitializeHook(true) then
            p101:Log("[Engine] Inject layer refreshed.")
        end
    end

    pcall(function()
        local LocalPlayer2 = game:GetService("Players").LocalPlayer

        p101:TrackConnection(LocalPlayer2.CharacterAdded:Connect(function()
            task.spawn(u447)
        end))
    end)
    pcall(function()
        local JobId = game.JobId

        task.spawn(function()
            while p101.System.IsRunning do
                task.wait(1.25)

                if game.JobId ~= JobId then
                    JobId = game.JobId
                    task.spawn(u447)
                end
            end
        end)
    end)
    pcall(function()
        task.spawn(function()
            while p101.System.IsRunning do
                task.wait(10)

                local v1542 = not p101.System.IsInjecting

                if v1542 then
                    v1542 = p101.NativeFlags
                end

                if v1542 then
                    local t29 = {}
                    for v1546, v1547 in pairs(p101.NativeFlags) do

                        local v1548 = t2.value35(v1546)

                        if v1548 ~= nil and tostring(v1548) ~= tostring(v1547) then
                            table.insert(t29, {
								v1546,
								v1547
							})
                        end
                    end
                    if #t29 > 0 then
                        for _, v in ipairs(t29) do
                            local v1551 = v[1]
                            local v1552 = v[2]
                            local v1553 = p101.OriginalNames[v1551]

                            v29(v1551, tostring(v1552), v1553, 0)
                        end
                    end
                end
            end
        end)
    end)
end
function t2.value21.IsFlagToggleOn(p102, p103)
    local v450 = p102.ActiveFlags[p103]

    if v450 == nil then
        return false
    end

    local v451 = tostring(v450):lower()
    local v452 = v451 == "true"

    if not v452 then
        v452 = v451 == "1" or v451 == "on"
    end

    return v452
end
local function v30(p104)
    while p104 do
        local v454 = p104:IsA("ScreenGui")

        if not v454 then
            v454 = p104:IsA("BillboardGui")

            if not v454 then
                v454 = p104:IsA("SurfaceGui") or p104:IsA("LayerCollector")
            end
        end

        if v454 then
            return true
        end

        p104 = p104.Parent
    end

    return false
end
function t2.value36(p105, p106, p107)
    p107 = p107 or 0
    pcall(function()
        local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        local ScreenGui = Instance.new("ScreenGui")

        ScreenGui.Name = "MasterstrapOptimizerToast_" .. tostring(os.clock())
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.DisplayOrder = 960
        ScreenGui.Parent = PlayerGui

        local Frame = Instance.new("Frame", ScreenGui)

        Frame.AnchorPoint = Vector2.new(1, 1)
        Frame.Position = UDim2.new(1, -10, 1, -118 - p107 * 64)
        Frame.Size = UDim2.new(0, 268, 0, 56)
        Frame.BackgroundColor3 = Color3.fromRGB(52, 56, 34)
        Frame.BackgroundTransparency = 0.12
        Frame.BorderSizePixel = 0
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

        local UIStroke = Instance.new("UIStroke", Frame)

        UIStroke.Color = Color3.fromRGB(90, 95, 55)
        UIStroke.Thickness = 1
        UIStroke.Transparency = 0.35

        local TextLabel = Instance.new("TextLabel", Frame)

        TextLabel.Size = UDim2.new(1, -14, 0, 22)
        TextLabel.Position = UDim2.new(0, 10, 0, 6)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.TextSize = 14
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.TextColor3 = Color3.new(1, 1, 1)
        TextLabel.Text = p105

        local TextLabel2 = Instance.new("TextLabel", Frame)

        TextLabel2.Size = UDim2.new(1, -14, 0, 18)
        TextLabel2.Position = UDim2.new(0, 10, 0, 28)
        TextLabel2.BackgroundTransparency = 1
        TextLabel2.Font = Enum.Font.Gotham
        TextLabel2.TextSize = 11
        TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel2.TextColor3 = Color3.fromRGB(220, 220, 220)
        TextLabel2.Text = p106
        task.delay(4.2, function()
            pcall(function()
                ScreenGui:Destroy()
            end)
        end)
    end)
end
function t2.value21.ShowOptimizerToast(_, p109, p110, p111)
    t2.value36(p109, p110, p111)
end
t2.value37 = {
	"BloomEffect",
	"BlurEffect",
	"ColorCorrectionEffect",
	"DepthOfFieldEffect",
	"SunRaysEffect"
}
t2.value38 = {
	"ParticleEmitter",
	"Fire",
	"Smoke",
	"Sparkles",
	"Beam",
	"Trail",
	"Decal",
	"Texture",
	"SelectionBox",
	"SelectionSphere",
	"BillboardGui"
}
function t2.value21.GetMegaBoostState(p112)
    local VisualStrip = p112.System.VisualStrip

    if not VisualStrip.megaBoost then
        VisualStrip.megaBoost = {
			fpsBoost = false,
			antiLag = false,
			antiFreeze = false,
			boostRestored = {},
			conAntiLag = nil,
			conAntiFreeze = nil,
			savedBoostLighting = nil,
			savedBoostQuality = nil,
			savedCameraMaxDist = nil
		}
    end

    return VisualStrip.megaBoost
end
function t2.value21.MegaBoostPushRestore(_, p114, p115, p116, p117)
    table.insert(p114.boostRestored, {
		obj = p115,
		prop = p116,
		old = p117
	})
end
function t2.value21.MegaBoostRestoreWhere(_, p119, p120)
    for i = #p119.boostRestored, 1, -1 do
        local v474 = i
        local v475 = p119.boostRestored[v474]
        local obj = v475.obj

        if obj then
            obj = p120(v475.obj)
        end

        if obj then
            pcall(function()
                v475.obj[v475.prop] = v475.old
            end)
            table.remove(p119.boostRestored, v474)
        end
    end
end
function t2.value21.ApplyOptimizerMegaFpsBoost(p121, p122)
    local MegaBoostState = p121:GetMegaBoostState()
    local Lighting = game:GetService("Lighting")

    if p122 then
        MegaBoostState.fpsBoost = true
        pcall(function()
            local UserGameSettings = UserSettings():GetService("UserGameSettings")

            if MegaBoostState.savedBoostQuality == nil then
                MegaBoostState.savedBoostQuality = UserGameSettings.SavedQualityLevel
            end

            UserGameSettings.SavedQualityLevel = Enum.QualityLevel.Level01
        end)

        if not MegaBoostState.savedBoostLighting then
            local GlobalShadows = Lighting.GlobalShadows
            local LightingBrightness = Lighting.Brightness
            local LightingAmbient = Lighting.Ambient
            local EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
            local EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale

            MegaBoostState.savedBoostLighting = {
				GlobalShadows = GlobalShadows,
				Brightness = LightingBrightness,
				Ambient = LightingAmbient,
				EnvDiff = EnvironmentDiffuseScale,
				EnvSpec = EnvironmentSpecularScale
			}
        end

        Lighting.GlobalShadows = false
        Lighting.Brightness = 0.7
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0

        for _, descendant in ipairs(Lighting:GetDescendants()) do
            local v488 = descendant

            for _, v in ipairs(t2.value37) do
                local v491 = v488:IsA(v)

                if v491 then
                    v491 = v488.Enabled
                end

                if v491 then
                    p121:MegaBoostPushRestore(MegaBoostState, v488, "Enabled", v488.Enabled)
                    pcall(function()
                        v488.Enabled = false
                    end)

                    break
                end
            end
        end

        return
    end

    MegaBoostState.fpsBoost = false
    pcall(function()
        if MegaBoostState.savedBoostQuality ~= nil then
            UserSettings():GetService("UserGameSettings").SavedQualityLevel = MegaBoostState.savedBoostQuality
            MegaBoostState.savedBoostQuality = nil
        end
    end)

    if MegaBoostState.savedBoostLighting then
        local savedBoostLighting = MegaBoostState.savedBoostLighting

        Lighting.GlobalShadows = savedBoostLighting.GlobalShadows
        Lighting.Brightness = savedBoostLighting.Brightness
        Lighting.Ambient = savedBoostLighting.Ambient
        Lighting.EnvironmentDiffuseScale = savedBoostLighting.EnvDiff
        Lighting.EnvironmentSpecularScale = savedBoostLighting.EnvSpec
        MegaBoostState.savedBoostLighting = nil
    end

    p121:MegaBoostRestoreWhere(MegaBoostState, function(p123)
        for _, v in ipairs(t2.value37) do
            if p123:IsA(v) then
                return true
            end
        end

        return false
    end)
end
function t2.value21.MegaBoostDisableEffObj(p124, p125, p126)
    for _, v in ipairs(t2.value38) do
        if p126:IsA(v) then
            local v504 = p126:IsA("Decal")

            if not v504 then
                v504 = p126:IsA("Texture")
            end

            local v505 = not v504 and "Enabled" or "Transparency"
            local v506 = v505 == "Transparency" and 1

            if v506 == p126[v505] then
                return
            end

            p124:MegaBoostPushRestore(p125, p126, v505, p126[v505])
            pcall(function()
                p126[v505] = v506
            end)

            return
        end
    end
end
function t2.value21.ApplyOptimizerMegaAntiLag(p127, p128)
    local MegaBoostState = p127:GetMegaBoostState()
    local _workspace = workspace

    if p128 then
        MegaBoostState.antiLag = true
        for v518, v519 in ipairs(_workspace:GetDescendants()) do

            p127:MegaBoostDisableEffObj(MegaBoostState, v519)
        end
        if not MegaBoostState.conAntiLag then
            MegaBoostState.conAntiLag = _workspace.DescendantAdded:Connect(function(descendant)
                task.defer(function()
                    if MegaBoostState.antiLag then
                        local v1554 = p127
                        local MegaBoostDisableEffObj = v1554.MegaBoostDisableEffObj
                        local v1556 = descendant

                        MegaBoostDisableEffObj(v1554, MegaBoostState, v1556)
                    end
                end)
            end)
            p127:TrackConnection(MegaBoostState.conAntiLag)

            return
        end
    else
        MegaBoostState.antiLag = false

        if MegaBoostState.conAntiLag then
            pcall(function()
                MegaBoostState.conAntiLag:Disconnect()
            end)
            MegaBoostState.conAntiLag = nil
        end

        p127:MegaBoostRestoreWhere(MegaBoostState, function(p129)
            for _, v in ipairs(t2.value38) do
                if p129:IsA(v) then
                    return true
                end
            end

            return false
        end)
    end
end
function t2.value21.ApplyOptimizerMegaAntiFreeze(p130, p131)
    local MegaBoostState = p130:GetMegaBoostState()
    local CurrentCamera = workspace.CurrentCamera
    local _workspace = workspace

    if p131 then
        MegaBoostState.antiFreeze = true
        pcall(function()
            local v1133 = CurrentCamera

            if v1133 then
                v1133 = MegaBoostState.savedCameraMaxDist == nil
            end

            if v1133 then
                MegaBoostState.savedCameraMaxDist = CurrentCamera.MaxDistance
            end

            if CurrentCamera then
                CurrentCamera.MaxDistance = 512
            end
        end)
        pcall(function()
            _workspace.StreamingMinRadius = 64
            _workspace.StreamingTargetRadius = 128
        end)

        if not MegaBoostState.conAntiFreeze then
            local n7 = 0

            MegaBoostState.conAntiFreeze = game:GetService("RunService").Heartbeat:Connect(function(dt)
                if not MegaBoostState.antiFreeze then
                    return
                end

                n7 += dt

                if n7 > 0.05 then
                    pcall(function()
                        collectgarbage("step", 64)
                    end)
                end
            end)
            p130:TrackConnection(MegaBoostState.conAntiFreeze)

            return
        end
    else
        MegaBoostState.antiFreeze = false
        pcall(function()
            local v1135 = CurrentCamera

            if v1135 then
                v1135 = MegaBoostState.savedCameraMaxDist ~= nil
            end

            if v1135 then
                CurrentCamera.MaxDistance = MegaBoostState.savedCameraMaxDist
                MegaBoostState.savedCameraMaxDist = nil
            end
        end)
        pcall(function()
            _workspace.StreamingMinRadius = 64
            _workspace.StreamingTargetRadius = 512
        end)

        if MegaBoostState.conAntiFreeze then
            pcall(function()
                MegaBoostState.conAntiFreeze:Disconnect()
            end)
            MegaBoostState.conAntiFreeze = nil
        end
    end
end
function t2.value39(p132, p133)
    if not p132:IsA("BasePart") then
        return
    end

    if p132.Material == Enum.Material.SmoothPlastic then
        return
    end

    p133.noTextureMatCache = p133.noTextureMatCache or {}

    local insert = table.insert
    local noTextureMatCache = p133.noTextureMatCache
    local p132Material = p132.Material

    insert(noTextureMatCache, {
		obj = p132,
		old = p132Material
	})
    pcall(function()
        p132.Material = Enum.Material.SmoothPlastic
    end)
end
function t2.value40(p134)
    if v30(p134) then
        return
    end

    pcall(function()
        local v1125 = p134:IsA("SpecialMesh")

        if not v1125 then
            v1125 = p134:IsA("Decal")

            if not v1125 then
                v1125 = p134:IsA("Texture")
            end
        end

        if v1125 then
            p134:Destroy()

            return
        end

        if p134:IsA("BasePart") then
            p134.Color = Color3.fromRGB(255, 255, 255)
        end

        for _, descendant in ipairs(p134:GetDescendants()) do
            local v1128 = descendant:IsA("SpecialMesh")

            if not v1128 then
                v1128 = descendant:IsA("Decal")

                if not v1128 then
                    v1128 = descendant:IsA("Texture")
                end
            end

            if v1128 then
                descendant:Destroy()
            elseif descendant:IsA("BasePart") then
                descendant.Color = Color3.fromRGB(255, 255, 255)
            end
        end
    end)
end
function t2.value21.EnableNoTextures(p135, p136)
    local VisualStrip = p135.System.VisualStrip

    if VisualStrip.noTextures and not p136 then
        return
    end

    VisualStrip.noTextures = true

    if VisualStrip.conTextures then
        pcall(function()
            VisualStrip.conTextures:Disconnect()
        end)
        VisualStrip.conTextures = nil
    end

    if VisualStrip.conTexturesMaintain then
        pcall(function()
            VisualStrip.conTexturesMaintain:Disconnect()
        end)
        VisualStrip.conTexturesMaintain = nil
    end

    VisualStrip.noTextureMatCache = {}
    task.spawn(function()
        for _, descendant in ipairs(workspace:GetDescendants()) do
            if not VisualStrip.noTextures then
                return
            end

            t2.value39(descendant, VisualStrip)
        end
    end)

    if not p136 then
        p135:ShowOptimizerToast("NO TEXTURE", "BasePart → SmoothPlastic · hemat VRAM", 0)
    end
end
function t2.value21.DisableNoTextures(p137)
    local VisualStrip = p137.System.VisualStrip

    VisualStrip.noTextures = false
    VisualStrip._lowGfxTick = 0

    if VisualStrip.conTextures then
        pcall(function()
            VisualStrip.conTextures:Disconnect()
        end)
        VisualStrip.conTextures = nil
    end

    if VisualStrip.conTexturesMaintain then
        pcall(function()
            VisualStrip.conTexturesMaintain:Disconnect()
        end)
        VisualStrip.conTexturesMaintain = nil
    end

    for _, v in ipairs(VisualStrip.noTextureMatCache or {}) do
        local v537 = v

        pcall(function()
            local obj = v537.obj

            if obj then
                obj = v537.obj.Parent
            end

            if obj then
                v537.obj.Material = v537.old
            end
        end)
    end

    VisualStrip.noTextureMatCache = {}
end
function t2.value21.EnableNoMeshes(p138, p139)
    local VisualStrip = p138.System.VisualStrip

    if VisualStrip.noMeshes and not p139 then
        return
    end

    VisualStrip.noMeshes = true

    if VisualStrip.conMeshes then
        pcall(function()
            VisualStrip.conMeshes:Disconnect()
        end)
        VisualStrip.conMeshes = nil
    end

    task.spawn(function()
        for _, descendant in ipairs(game:GetDescendants()) do
            if not VisualStrip.noMeshes then
                return
            end

            t2.value40(descendant)
        end
    end)
    VisualStrip.conMeshes = workspace.DescendantAdded:Connect(function(descendant)
        if VisualStrip.noMeshes then
            t2.value40(descendant)
        end
    end)
end
function t2.value21.DisableNoMeshes(p140)
    local VisualStrip = p140.System.VisualStrip

    VisualStrip.noMeshes = false

    if VisualStrip.conMeshes then
        pcall(function()
            VisualStrip.conMeshes:Disconnect()
        end)
        VisualStrip.conMeshes = nil
    end
end
function t2.value41(p141)
    local SkyboxBk = p141.SkyboxBk
    local SkyboxDn = p141.SkyboxDn
    local SkyboxFt = p141.SkyboxFt
    local SkyboxLf = p141.SkyboxLf
    local SkyboxRt = p141.SkyboxRt
    local SkyboxUp = p141.SkyboxUp
    local SunTextureId = p141.SunTextureId
    local MoonTextureId = p141.MoonTextureId
    local SunAngularSize = p141.SunAngularSize
    local StarCount = p141.StarCount
    local CelestialBodiesShown = p141.CelestialBodiesShown

    return {
		SkyboxBk = SkyboxBk,
		SkyboxDn = SkyboxDn,
		SkyboxFt = SkyboxFt,
		SkyboxLf = SkyboxLf,
		SkyboxRt = SkyboxRt,
		SkyboxUp = SkyboxUp,
		SunTextureId = SunTextureId,
		MoonTextureId = MoonTextureId,
		SunAngularSize = SunAngularSize,
		StarCount = StarCount,
		CelestialBodiesShown = CelestialBodiesShown
	}
end
function t2.value42(p142)
    p142.SkyboxBk = ""
    p142.SkyboxDn = ""
    p142.SkyboxFt = ""
    p142.SkyboxLf = ""
    p142.SkyboxRt = ""
    p142.SkyboxUp = ""
    p142.SunTextureId = ""
    p142.MoonTextureId = ""
    p142.StarCount = 0
    p142.CelestialBodiesShown = false
end
function t2.value43(p143, p144)
    if not p143 or not p144 then
        return
    end

    for k, v in pairs(p144) do
        local v498 = v

        pcall(function()
            p143[k] = v498
        end)
    end
end
function t2.value44(p145)
    local Lighting = game:GetService("Lighting")

    pcall(function()
        if p145.savedSkyBox then
            local Sky = Lighting:FindFirstChildOfClass("Sky")

            t2.value43(Sky, p145.savedSkyBox)
            p145.savedSkyBox = nil
        end

        if p145.savedLowSkyLighting then
            local savedLowSkyLighting = p145.savedLowSkyLighting

            Lighting.GlobalShadows = savedLowSkyLighting.GlobalShadows
            Lighting.FogEnd = savedLowSkyLighting.FogEnd
            Lighting.Brightness = savedLowSkyLighting.Brightness
            p145.savedLowSkyLighting = nil
        end
    end)
end
t2.value45 = nil
t2.value45 = {
	"BloomEffect",
	"BlurEffect",
	"SunRaysEffect",
	"DepthOfFieldEffect",
	"ColorCorrectionEffect"
}
function t2.value46(p146)
    local v570 = p146:IsA("PointLight")

    if not v570 then
        v570 = p146:IsA("SpotLight")

        if not v570 then
            v570 = p146:IsA("SurfaceLight")
        end
    end

    if v570 then
        return true
    end

    local v571 = p146:IsA("ParticleEmitter")

    if not v571 then
        v571 = p146:IsA("Trail")

        if not v571 then
            v571 = p146:IsA("Beam")
        end
    end

    if v571 then
        return true
    end

    local v572 = p146:IsA("Fire")

    if not v572 then
        v572 = p146:IsA("Smoke")

        if not v572 then
            v572 = p146:IsA("Sparkles")
        end
    end

    if v572 then
        return true
    end

    for _, v in ipairs(t2.value45) do
        if p146:IsA(v) then
            return true
        end
    end

    return false
end
function t2.value47(p147)
    if v30(p147) then
        return
    end

    pcall(function()
        local v1157 = p147:IsA("PointLight")

        if not v1157 then
            v1157 = p147:IsA("SpotLight")

            if not v1157 then
                v1157 = p147:IsA("SurfaceLight")
            end
        end

        if v1157 then
            p147.Brightness = 0
            p147.Range = 0
            pcall(function()
                if p147.Shadows ~= nil then
                    p147.Shadows = false
                end
            end)

            return
        end

        local v1158 = p147:IsA("ParticleEmitter")

        if not v1158 then
            v1158 = p147:IsA("Trail")

            if not v1158 then
                v1158 = p147:IsA("Beam")

                if not v1158 then
                    v1158 = p147:IsA("Fire")

                    if not v1158 then
                        v1158 = p147:IsA("Smoke")

                        if not v1158 then
                            v1158 = p147:IsA("Sparkles")
                        end
                    end
                end
            end
        end

        if v1158 then
            p147.Enabled = false

            return
        end

        for _, v in ipairs(t2.value45) do
            if p147:IsA(v) then
                p147.Enabled = false

                return
            end
        end
    end)
end
function t2.value48(p148)
    if p148:IsA("Terrain") then
        return true
    end

    if not p148:IsA("BasePart") then
        return false
    end

    if p148.Material == Enum.Material.Water then
        return true
    end

    local p148Name = p148.Name

    if #p148Name < 4 then
        return false
    end

    return string.find(string.lower(p148Name), "water", 1, true) ~= nil
end
function t2.value49(p149)
    local Terrain = workspace.Terrain

    if not p149.savedTerrainState then
        local Decoration = Terrain.Decoration
        local WaterWaveSize = Terrain.WaterWaveSize
        local WaterWaveSpeed = Terrain.WaterWaveSpeed
        local WaterReflectance = Terrain.WaterReflectance

        p149.savedTerrainState = {
			Decoration = Decoration,
			WaterWaveSize = WaterWaveSize,
			WaterWaveSpeed = WaterWaveSpeed,
			WaterReflectance = WaterReflectance
		}
    end

    pcall(function()
        Terrain.Decoration = false
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
    end)
end
function t2.value50(p150)
    if not p150.savedTerrainState then
        return
    end

    local savedTerrainState = p150.savedTerrainState

    pcall(function()
        local Terrain = workspace.Terrain

        Terrain.Decoration = savedTerrainState.Decoration
        Terrain.WaterWaveSize = savedTerrainState.WaterWaveSize
        Terrain.WaterWaveSpeed = savedTerrainState.WaterWaveSpeed
        Terrain.WaterReflectance = savedTerrainState.WaterReflectance
    end)
    p150.savedTerrainState = nil
end
function t2.value51(p151)
    if v30(p151) then
        return
    end

    pcall(function()
        if p151:IsA("Terrain") then
            p151.Decoration = false

            return
        end

        if p151:IsA("BasePart") then
            local v1161 = p151.Material == Enum.Material.Water

            if not v1161 then
                v1161 = string.find(string.lower(p151.Name), "water", 1, true)
            end

            if v1161 then
                p151.Material = Enum.Material.SmoothPlastic
                p151.Reflectance = 0
                p151.Transparency = 0.2
            end
        end
    end)
end
function t2.value21.EnableLowTextureSky(p152, p153)
    local VisualStrip = p152.System.VisualStrip

    if VisualStrip.lowSky and not p153 then
        return
    end

    VisualStrip.lowSky = true

    if VisualStrip.conLowSky then
        pcall(function()
            VisualStrip.conLowSky:Disconnect()
        end)
        VisualStrip.conLowSky = nil
    end

    if not VisualStrip.graySky then
        local Lighting = game:GetService("Lighting")

        pcall(function()
            if not VisualStrip.savedLowSkyLighting then
                local v1163 = VisualStrip
                local GlobalShadows = Lighting.GlobalShadows
                local FogEnd = Lighting.FogEnd
                local LightingBrightness = Lighting.Brightness

                v1163.savedLowSkyLighting = {
					GlobalShadows = GlobalShadows,
					FogEnd = FogEnd,
					Brightness = LightingBrightness
				}
            end

            local Sky = Lighting:FindFirstChildOfClass("Sky")
            local v1168 = Sky

            if Sky then
                v1168 = not VisualStrip.savedSkyBox
            end

            if v1168 then
                VisualStrip.savedSkyBox = t2.value41(Sky)
            end

            if not Sky then
                Sky = Instance.new("Sky")
                Sky.Parent = Lighting
            end

            t2.value42(Sky)
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9000000000
            Lighting.Brightness = 0
        end)
    end

    VisualStrip.conLowSky = game:GetService("Lighting").ChildAdded:Connect(function(child)
        local v1170 = not VisualStrip.lowSky

        if not v1170 then
            v1170 = VisualStrip.graySky
        end

        if v1170 then
            return
        end

        if child:IsA("Sky") then
            if not VisualStrip.savedSkyBox then
                VisualStrip.savedSkyBox = t2.value41(child)
            end

            pcall(function()
                t2.value42(child)
            end)
        end
    end)

    if not p153 then
        p152:ShowOptimizerToast("No-Texture Sky", "Sky textures removed.", not p152:IsFlagToggleOn("NoTexturesEnable") and 0 or 1)
    end
end
function t2.value21.DisableLowTextureSky(p154)
    local VisualStrip = p154.System.VisualStrip
    local lowSky = VisualStrip.lowSky

    VisualStrip.lowSky = false

    if VisualStrip.conLowSky then
        pcall(function()
            VisualStrip.conLowSky:Disconnect()
        end)
        VisualStrip.conLowSky = nil
    end

    if lowSky then
        t2.value44(VisualStrip)
    end
end
t2.value52 = Color3.fromRGB(160, 160, 168)
t2.value53 = {
	"Density",
	"Haze",
	"Glare",
	"Offset"
}
t2.value54 = {
	"BloomEffect",
	"BlurEffect",
	"SunRaysEffect",
	"DepthOfFieldEffect",
	"ColorCorrectionEffect"
}
function t2.value55(p155, p156, p157, p158)
    p155.graySkyRestored = p155.graySkyRestored or {}
    table.insert(p155.graySkyRestored, {
		obj = p156,
		prop = p157,
		old = p158
	})
end
function t2.value56(p159, p160, p161, p162)
    if p162 == p160[p161] then
        return
    end

    local v601 = p160[p161]

    t2.value55(p159, p160, p161, v601)
    pcall(function()
        p160[p161] = p162
    end)
end
function t2.value57(p163, p164)
    if not p164.savedGraySkyFog then
        local FogEnd = p163.FogEnd
        local FogStart = p163.FogStart
        local FogColor = p163.FogColor

        p164.savedGraySkyFog = {
			FogEnd = FogEnd,
			FogStart = FogStart,
			FogColor = FogColor
		}
    end

    p163.FogEnd = 10000000000
    p163.FogStart = 9000000000

    local color3_18 = Color3.fromRGB(0, 0, 0)
    local GetChildren = p163.GetChildren

    p163.FogColor = color3_18

    for _, v in ipairs(GetChildren(p163)) do
        local v611 = v

        if v611:IsA("Atmosphere") then
            for _, v4 in ipairs(t2.value53) do
                t2.value56(p164, v611, v4, 0)
            end
        elseif v611:IsA("Sky") then
            t2.value56(p164, v611, "MoonTextureId", "")
            t2.value56(p164, v611, "SunTextureId", "")
            t2.value56(p164, v611, "StarCount", 0)
            pcall(function()
                if v611.CelestialBodiesShown then
                    t2.value55(p164, v611, "CelestialBodiesShown", v611.CelestialBodiesShown)
                    v611.CelestialBodiesShown = false
                end
            end)
        end
    end
end
function t2.value58(p165, p166)
    if p166.savedGraySkyFog then
        local savedGraySkyFog = p166.savedGraySkyFog

        p165.FogEnd = savedGraySkyFog.FogEnd
        p165.FogStart = savedGraySkyFog.FogStart
        p165.FogColor = savedGraySkyFog.FogColor
        p166.savedGraySkyFog = nil
    end

    if p166.graySkyRestored then
        for i = #p166.graySkyRestored, 1, -1 do
            local v594 = i
            local v595 = p166.graySkyRestored[v594]
            local obj = v595.obj

            if obj then
                obj = v595.obj.Parent
            end

            if obj then
                pcall(function()
                    v595.obj[v595.prop] = v595.old
                end)
            end

            table.remove(p166.graySkyRestored, v594)
        end
    end
end
t2.value59 = "rbxassetid://11687355"
local function v31(p167, p168)
    local Sky = p167:FindFirstChildOfClass("Sky")

    if not Sky then
        Sky = Instance.new("Sky")
        Sky.Name = "MasterstrapGraySky"
        Sky.Parent = p167
    elseif Sky.Name ~= "MasterstrapGraySky" and not p168.savedGraySkyBox then
        p168.savedGraySkyBox = t2.value41(Sky)
    end

    t2.value42(Sky)

    local value59 = t2.value59

    Sky.SkyboxBk = value59
    Sky.SkyboxDn = value59
    Sky.SkyboxFt = value59
    Sky.SkyboxLf = value59
    Sky.SkyboxRt = value59
    Sky.SkyboxUp = value59
    Sky.SunTextureId = ""
    Sky.MoonTextureId = ""
    Sky.StarCount = 0
    Sky.CelestialBodiesShown = false
    Sky.SunAngularSize = 0
end
local function v32(p169, p170)
    local GetChildren = p169.GetChildren

    for _, v in ipairs(GetChildren(p169)) do
        if v:IsA("PostEffect") then
            if v.Enabled then
                t2.value56(p170, v, "Enabled", false)
            end
        else
            for _, v5 in ipairs(t2.value54) do
                if v:IsA(v5) and v.Enabled then
                    t2.value56(p170, v, "Enabled", false)

                    break
                end
            end
        end
    end
end
function t2.value60(p171, p172)
    local Clouds = p171:FindFirstChildOfClass("Clouds")

    if not Clouds then
        return
    end

    if not p172.savedGraySkyClouds then
        local CloudsEnabled = Clouds.Enabled
        local Cover = Clouds.Cover
        local CloudsDensity = Clouds.Density

        p172.savedGraySkyClouds = {
			Enabled = CloudsEnabled,
			Cover = Cover,
			Density = CloudsDensity
		}
        p172.savedGraySkyHadClouds = true
    end

    Clouds.Enabled = false
end
function t2.value61(p173, p174)
    local v626 = not p174.savedGraySkyHadAtmosphere

    if not v626 then
        v626 = not p174.savedGraySkyAtmosphere
    end

    if v626 then
        return
    end

    if p174.savedGraySkyCreatedAtmosphere then
        pcall(function()
            local MasterstrapGraySkyAtm = p173:FindFirstChild("MasterstrapGraySkyAtm")

            if MasterstrapGraySkyAtm then
                MasterstrapGraySkyAtm:Destroy()
            end

            local Atmosphere = p173:FindFirstChildOfClass("Atmosphere")
            local v1173 = Atmosphere

            if Atmosphere then
                v1173 = Atmosphere.Name == "MasterstrapGraySkyAtm"
            end

            if v1173 then
                Atmosphere:Destroy()
            end
        end)
    else
        local Atmosphere = p173:FindFirstChildOfClass("Atmosphere")

        if not Atmosphere then
            pcall(function()
                Atmosphere = Instance.new("Atmosphere")

                local savedGraySkyAtmosphere = p174.savedGraySkyAtmosphere

                Atmosphere.Density = savedGraySkyAtmosphere.Density
                Atmosphere.Offset = savedGraySkyAtmosphere.Offset
                Atmosphere.Color = savedGraySkyAtmosphere.Color
                Atmosphere.Decay = savedGraySkyAtmosphere.Decay
                Atmosphere.Glare = savedGraySkyAtmosphere.Glare
                Atmosphere.Haze = savedGraySkyAtmosphere.Haze
                Atmosphere.Parent = p173
            end)
        else
            local savedGraySkyAtmosphere = p174.savedGraySkyAtmosphere

            Atmosphere.Density = savedGraySkyAtmosphere.Density
            Atmosphere.Offset = savedGraySkyAtmosphere.Offset
            Atmosphere.Color = savedGraySkyAtmosphere.Color
            Atmosphere.Decay = savedGraySkyAtmosphere.Decay
            Atmosphere.Glare = savedGraySkyAtmosphere.Glare
            Atmosphere.Haze = savedGraySkyAtmosphere.Haze
        end
    end

    p174.savedGraySkyAtmosphere = nil
    p174.savedGraySkyHadAtmosphere = false
    p174.savedGraySkyCreatedAtmosphere = false
end
function t2.value62(p175, p176)
    if not p176.savedGraySkyHadClouds or not p176.savedGraySkyClouds then
        return
    end

    local Clouds = p175:FindFirstChildOfClass("Clouds")

    if Clouds then
        local savedGraySkyClouds = p176.savedGraySkyClouds

        Clouds.Enabled = savedGraySkyClouds.Enabled
        Clouds.Cover = savedGraySkyClouds.Cover
        Clouds.Density = savedGraySkyClouds.Density
    end

    p176.savedGraySkyClouds = nil
    p176.savedGraySkyHadClouds = false
end
function t2.value63(p177, p178, p179)
    local v639 = p177:IsA("Atmosphere")

    if not v639 then
        v639 = p177:IsA("Sky")
    end

    if v639 then
        t2.value57(p178, p179)

        if p177:IsA("Sky") then
            v31(p178, p179)

            return
        end
    else
        if p177:IsA("Clouds") then
            t2.value60(p178, p179)

            return
        end

        if p177:IsA("PostEffect") then
            t2.value56(p179, p177, "Enabled", false)

            return
        end

        for _, v in ipairs(t2.value54) do
            if p177:IsA(v) then
                t2.value56(p179, p177, "Enabled", false)

                return
            end
        end
    end
end
function t2.value21.EnableGraySky(p180, p181)
    local VisualStrip = p180.System.VisualStrip

    if VisualStrip.graySky and not p181 then
        return
    end

    VisualStrip.graySky = true
    VisualStrip.graySkyRestored = {}

    if VisualStrip.conGraySky then
        pcall(function()
            VisualStrip.conGraySky:Disconnect()
        end)
        VisualStrip.conGraySky = nil
    end

    if VisualStrip.conGraySkyMaintain then
        pcall(function()
            VisualStrip.conGraySkyMaintain:Disconnect()
        end)
        VisualStrip.conGraySkyMaintain = nil
    end

    if p180:IsFlagToggleOn("OptimizerLowSkyEnable") then
        p180:DisableLowTextureSky()
    end

    pcall(function()
        if not VisualStrip.savedGraySkyFFlag then
            VisualStrip.savedGraySkyFFlag = t2.value33("FFlagDebugSkyGray")
        end

        t2.value32("FFlagDebugSkyGray", "True")
        p180:SetFlagInternal("FFlagDebugSkyGray", "True")
    end)

    local Lighting = game:GetService("Lighting")
    local Lighting2 = game:GetService("Lighting")

    pcall(function()
        t2.value57(Lighting2, VisualStrip)
        v31(Lighting2, VisualStrip)
        t2.value60(Lighting2, VisualStrip)
        v32(Lighting2, VisualStrip)

        if not VisualStrip.savedGraySkyColorShift then
            local v1185 = VisualStrip
            local ColorShift_Top = Lighting2.ColorShift_Top
            local ColorShift_Bottom = Lighting2.ColorShift_Bottom

            v1185.savedGraySkyColorShift = {
				ColorShift_Top = ColorShift_Top,
				ColorShift_Bottom = ColorShift_Bottom
			}
        end

        local value52 = t2.value52

        Lighting2.ColorShift_Top = value52
        Lighting2.ColorShift_Bottom = value52
    end)
    VisualStrip.conGraySky = Lighting.ChildAdded:Connect(function(child)
        if not VisualStrip.graySky then
            return
        end

        local v1190 = Lighting

        t2.value63(child, v1190, VisualStrip)
    end)
    p180:TrackConnection(VisualStrip.conGraySky)
    VisualStrip.conGraySkyMaintain = game:GetService("RunService").Heartbeat:Connect(function()
        if not VisualStrip.graySky then
            return
        end

        VisualStrip._graySkyTick = (VisualStrip._graySkyTick or 0) + 1

        if VisualStrip._graySkyTick % 120 ~= 0 then
            return
        end

        t2.value57(Lighting, VisualStrip)
    end)
    p180:TrackConnection(VisualStrip.conGraySkyMaintain)

    if not p181 then
        local n8 = 0

        if p180:IsFlagToggleOn("NoTexturesEnable") then
            n8 += 1
        end

        if p180:IsFlagToggleOn("OptimizerLowSkyEnable") then
            n8 += 1
        end

        p180:ShowOptimizerToast("Gray Sky", "FULL FOG OFF + sky FX stripped.", n8)
    end
end
function t2.value21.DisableGraySky(p182)
    local VisualStrip = p182.System.VisualStrip
    local graySky = VisualStrip.graySky

    VisualStrip.graySky = false
    VisualStrip._graySkyTick = 0

    if VisualStrip.conGraySky then
        pcall(function()
            VisualStrip.conGraySky:Disconnect()
        end)
        VisualStrip.conGraySky = nil
    end

    if VisualStrip.conGraySkyMaintain then
        pcall(function()
            VisualStrip.conGraySkyMaintain:Disconnect()
        end)
        VisualStrip.conGraySkyMaintain = nil
    end

    if graySky then
        pcall(function()
            local savedGraySkyFFlag = VisualStrip.savedGraySkyFFlag

            if savedGraySkyFFlag == nil then
                t2.value32("FFlagDebugSkyGray", "False")
                p182:SetFlagInternal("FFlagDebugSkyGray", "False", true)
            else
                t2.value32("FFlagDebugSkyGray", (tostring(savedGraySkyFFlag)))
                p182:SetFlagInternal("FFlagDebugSkyGray", tostring(savedGraySkyFFlag), true)
            end

            VisualStrip.savedGraySkyFFlag = nil
        end)

        local Lighting = game:GetService("Lighting")

        pcall(function()
            t2.value58(Lighting, VisualStrip)

            if VisualStrip.savedGraySkyBox then
                local Sky = Lighting:FindFirstChildOfClass("Sky")

                t2.value43(Sky, VisualStrip.savedGraySkyBox)
                VisualStrip.savedGraySkyBox = nil
            end

            t2.value61(Lighting, VisualStrip)
            t2.value62(Lighting, VisualStrip)
            pcall(function()
                local MasterstrapGraySkyCC = Lighting:FindFirstChild("MasterstrapGraySkyCC")

                if MasterstrapGraySkyCC then
                    MasterstrapGraySkyCC:Destroy()
                end
            end)
            VisualStrip.savedGraySkyCC = nil

            if VisualStrip.savedGraySkyPostFx then
                for _, v in ipairs(VisualStrip.savedGraySkyPostFx) do
                    local v1195 = v

                    pcall(function()
                        local ref = v1195.ref

                        if ref then
                            ref = v1195.ref.Parent
                        end

                        if ref then
                            v1195.ref.Enabled = v1195.enabled
                        end
                    end)
                end

                VisualStrip.savedGraySkyPostFx = nil
            end

            if VisualStrip.savedGraySkyColorShift then
                local savedGraySkyColorShift = VisualStrip.savedGraySkyColorShift

                Lighting.ColorShift_Top = savedGraySkyColorShift.ColorShift_Top
                Lighting.ColorShift_Bottom = savedGraySkyColorShift.ColorShift_Bottom
                VisualStrip.savedGraySkyColorShift = nil
            elseif VisualStrip.savedGraySkyLighting then
                local savedGraySkyLighting = VisualStrip.savedGraySkyLighting

                Lighting.ColorShift_Top = savedGraySkyLighting.ColorShift_Top
                Lighting.ColorShift_Bottom = savedGraySkyLighting.ColorShift_Bottom
                Lighting.Ambient = savedGraySkyLighting.Ambient
                Lighting.OutdoorAmbient = savedGraySkyLighting.OutdoorAmbient
                Lighting.Brightness = savedGraySkyLighting.Brightness
                Lighting.ExposureCompensation = savedGraySkyLighting.ExposureCompensation
                Lighting.FogColor = savedGraySkyLighting.FogColor
                Lighting.FogEnd = savedGraySkyLighting.FogEnd
                Lighting.FogStart = savedGraySkyLighting.FogStart
                Lighting.GlobalShadows = savedGraySkyLighting.GlobalShadows
                Lighting.ClockTime = savedGraySkyLighting.ClockTime
                Lighting.GeographicLatitude = savedGraySkyLighting.GeographicLatitude
                pcall(function()
                    Lighting.EnvironmentDiffuseScale = savedGraySkyLighting.EnvironmentDiffuseScale
                    Lighting.EnvironmentSpecularScale = savedGraySkyLighting.EnvironmentSpecularScale
                end)
                VisualStrip.savedGraySkyLighting = nil
            end

            if VisualStrip.savedGraySkyHadTechnology ~= nil then
                pcall(function()
                    sethiddenproperty(Lighting, "Technology", VisualStrip.savedGraySkyHadTechnology)
                end)
                VisualStrip.savedGraySkyHadTechnology = nil
            end
        end)
    end
end
function t2.value21.GetQueueOnTeleport(_)
    local _syn = syn

    if _syn then
        _syn = syn.queue_on_teleport
    end

    if not _syn then
        _syn = queue_on_teleport

        if not _syn then
            _syn = fluxus

            if _syn then
                _syn = fluxus.queue_on_teleport
            end

            if not _syn then
                _syn = getgenv

                if _syn then
                    _syn = getgenv().queue_on_teleport
                end

                if not _syn then
                    _syn = type(delta) == "table"

                    if _syn then
                        _syn = delta.queue_on_teleport
                    end

                    if not _syn then
                        _syn = type(Delta) == "table"

                        if _syn then
                            _syn = Delta.queue_on_teleport
                        end
                    end
                end
            end
        end
    end

    return _syn
end
function t2.value21.QueueAutoInjectOnTeleport(p184)
    local QueueOnTeleport = p184:GetQueueOnTeleport()

    if not QueueOnTeleport then
        return
    end

    pcall(function()
        QueueOnTeleport("            task.spawn(function()\n                repeat task.wait() until game:IsLoaded()\n                if isfile and isfile(\"bridge.lua\") then\n                    loadstring(readfile(\"bridge.lua\"))()\n                end\n            end)\n        ")
    end)
end
function t2.value21.GetJoinAccessCode(_)
    local AccessCode
    pcall(function()
        local JoinData = game:GetService("Players").LocalPlayer:GetJoinData()
        local v1199 = JoinData

        if JoinData then
            v1199 = type(JoinData.AccessCode) == "string"

            if v1199 then
                v1199 = JoinData.AccessCode ~= ""
            end
        end

        if v1199 then
            AccessCode = JoinData.AccessCode
        end
    end)

    return ""
end
function t2.value21.CaptureRejoinTarget(p186)
    local MasterstrapRejoin
    if getgenv then
        local v664 = getgenv()
        local v665 = v664

        if v664 then
            v665 = type(v664.MasterstrapRejoin) == "table"
        end

        if v665 then
            MasterstrapRejoin = v664.MasterstrapRejoin
        end
    end
    local JoinAccessCode = p186:GetJoinAccessCode()
    local v667 = JoinAccessCode == ""
    if v667 then
        v667 = MasterstrapRejoin

        if MasterstrapRejoin then
            v667 = tonumber(MasterstrapRejoin.PlaceId) == tonumber(game.PlaceId)
        end
    end
    if v667 then
        local str = tostring(MasterstrapRejoin.AccessCode or "")

        if str ~= "" then
            JoinAccessCode = str
        end
    end
    local PlaceId = game.PlaceId
    local str = tostring(game.JobId or "")
    local t30 = {
		PlaceId = PlaceId,
		JobId = str,
		AccessCode = JoinAccessCode
	}
    if getgenv then
        getgenv().MasterstrapRejoin = t30
    end

    return t30
end
function t2.value21.IsPrivateServerSession(p187)
    if p187:GetJoinAccessCode() ~= "" then
        return true
    end

    local u673 = false

    pcall(function()
        local JoinData = t2.value2.LocalPlayer:GetJoinData()

        if type(JoinData) == "table" then
            local str = tostring(JoinData.AccessCode or "")
            local str2 = tostring(JoinData.PrivateServerId or "")

            if str ~= "" then
                u673 = true
            end

            if str2 ~= "" then
                u673 = true
            end
        end

        local v1203 = tonumber(game.PrivateServerOwnerId) or 0
        local v1204 = tonumber(game.VIPServerOwnerId) or 0
        local v1205 = game.PrivateServerId or ""

        if v1203 > 0 then
            u673 = true
        end

        if v1204 > 0 then
            u673 = true
        end

        if v1205 ~= "" then
            u673 = true
        end
    end)

    return u673
end
function t2.value21.TryDeltaNativeRejoin(_)
    local u675 = false

    pcall(function()
        local v1206 = getgenv and getgenv()

        if v1206 then
            local Delta2 = v1206.Delta

            if Delta2 then
                Delta2 = type(v1206.Delta.Rejoin) == "function"
            end

            if Delta2 then
                v1206.Delta.Rejoin()
                u675 = true
            else
                local delta2 = v1206.delta

                if delta2 then
                    delta2 = type(v1206.delta.rejoin) == "function"
                end

                if delta2 then
                    v1206.delta.rejoin()
                    u675 = true
                elseif type(v1206.Rejoin) == "function" then
                    v1206.Rejoin()
                    u675 = true
                elseif type(v1206.rejoin) == "function" then
                    v1206.rejoin()
                    u675 = true
                end
            end
        end

        local v1209 = not u675

        if v1209 then
            v1209 = type(delta) == "table"

            if v1209 then
                v1209 = type(delta.rejoin) == "function"
            end
        end

        if v1209 then
            delta.rejoin()
            u675 = true
        end

        local v1210 = not u675

        if v1210 then
            v1210 = type(Delta) == "table"

            if v1210 then
                v1210 = type(Delta.Rejoin) == "function"
            end
        end

        if v1210 then
            Delta.Rejoin()
            u675 = true
        end
    end)

    return u675
end
function t2.value21.TryTeleportAsyncRejoin(_, p190, p191, p192, p193)
    local TeleportService = game:GetService("TeleportService")
    local LocalPlayer3 = t2.value2.LocalPlayer
    local u683 = false

    pcall(function()
        local v1211 = p193

        if v1211 then
            v1211 = p191

            if v1211 then
                v1211 = p191 ~= ""
            end
        end

        if v1211 then
            local TeleportOptions = Instance.new("TeleportOptions")

            TeleportOptions.ReservedServerAccessCode = p191
            TeleportService:TeleportAsync(p190, { LocalPlayer3 }, TeleportOptions)
            u683 = true

            return
        end

        local v1213 = p192

        if v1213 then
            v1213 = p192 ~= ""
        end

        if v1213 then
            local TeleportOptions = Instance.new("TeleportOptions")

            TeleportOptions.ServerInstanceId = p192
            TeleportService:TeleportAsync(p190, { LocalPlayer3 }, TeleportOptions)
            u683 = true
        end
    end)

    local v684 = not u683

    if v684 then
        v684 = p193

        if v684 then
            v684 = p191

            if v684 then
                v684 = p191 ~= ""
            end
        end
    end

    if v684 then
        pcall(function()
            TeleportService:TeleportToPrivateServer(p190, p191, { LocalPlayer3 })
            u683 = true
        end)
    end

    return u683
end
function t2.value21.GetPrivateLinkCode(_, p195)
    if p195 and p195 ~= "" then
        return p195
    end

    if getgenv then
        local v687 = getgenv()
        local v688 = v687

        if v687 then
            v688 = type(v687.MasterstrapRejoin) == "table"
        end

        if v688 then
            local str = tostring(v687.MasterstrapRejoin.AccessCode or "")

            if str ~= "" then
                return str
            end
        end
    end

    return ""
end
function t2.value21.CopyRejoinUrl(_, p197)
    pcall(function()
        if setclipboard then
            setclipboard(p197)

            return
        end

        if toclipboard then
            toclipboard(p197)

            return
        end

        if writeclipboard then
            writeclipboard(p197)
        end
    end)
end
function t2.value21.TryRejoinViaLinkingService(p198, p199, p200, p201, p202)
    local LinkingService = game:GetService("LinkingService")
    local t31 = {}
    local v699 = p202
    local PrivateLinkCode = p198:GetPrivateLinkCode(p201)

    if p202 then
        v699 = PrivateLinkCode ~= ""
    end

    if v699 then
        t31[#t31 + 1] = string.format("https://www.roblox.com/games/%d?privateServerLinkCode=%s", p199, PrivateLinkCode)
        t31[#t31 + 1] = string.format("roblox://experiences/start?placeId=%d&accessCode=%s", p199, PrivateLinkCode)
        t31[#t31 + 1] = string.format("https://www.roblox.com/games/start?placeId=%d&accessCode=%s", p199, PrivateLinkCode)
    elseif not p202 then
        t31[#t31 + 1] = string.format("https://www.roblox.com/games/%d?serverJobId=%s", p199, p200)
        t31[#t31 + 1] = string.format("roblox://experiences/start?placeId=%d&gameInstanceId=%s", p199, p200)
    end

    for _, v in ipairs(t31) do
        local v703 = v
        local u704 = false
        pcall(function()
            LinkingService:OpenURL(v703)
            u704 = true
        end)
        if u704 then
            p198:CopyRejoinUrl(v703)

            return true, v703
        end
    end

    return false, nil
end
function t2.value21.RejoinSameServer(p203)
    local v706 = p203:CaptureRejoinTarget()
    local PlaceId = v706.PlaceId
    local JobId = v706.JobId
    local v709 = not JobId
    if not v709 then
        v709 = JobId == ""
    end
    if v709 then
        return
    end
    p203:QueueAutoInjectOnTeleport()
    local TeleportService = game:GetService("TeleportService")
    local LocalPlayer4 = t2.value2.LocalPlayer
    local u712 = false
    pcall(function()
        if #t2.value2:GetPlayers() == 1 then
            TeleportService:Teleport(PlaceId, LocalPlayer4)
        else
            TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer4)
        end

        u712 = true
    end)
    if u712 then
        return
    end
    if p203:TryDeltaNativeRejoin() then
        return
    end
    if p203:TryRejoinViaLinkingService(PlaceId, JobId, "", false) then
        return
    end
end
function t2.value21.EnableNoLightsParticles(p204, p205)
    local VisualStrip = p204.System.VisualStrip

    if VisualStrip.noLightsParticles and not p205 then
        return
    end

    VisualStrip.noLightsParticles = true

    if VisualStrip.conLightsParticles then
        pcall(function()
            VisualStrip.conLightsParticles:Disconnect()
        end)
        VisualStrip.conLightsParticles = nil
    end

    local Lighting = game:GetService("Lighting")

    pcall(function()
        for _, child in ipairs(Lighting:GetChildren()) do
            if t2.value46(child) then
                t2.value47(child)
            end
        end

        Lighting.Brightness = 1
        Lighting.ExposureCompensation = 0
    end)
    task.spawn(function()
        local descendants = game:GetDescendants()

        for i = 1, #descendants do
            local v1219 = i

            if not VisualStrip.noLightsParticles then
                return
            end

            local v1220 = descendants[v1219]

            if t2.value46(v1220) then
                t2.value47(v1220)
            end

            if v1219 % 400 == 0 then
                task.wait()
            end
        end
    end)
    VisualStrip.conLightsParticles = game.DescendantAdded:Connect(function(descendant)
        if not VisualStrip.noLightsParticles then
            return
        end

        if not t2.value46(descendant) then
            return
        end

        task.defer(function()
            local noLightsParticles = VisualStrip.noLightsParticles

            if noLightsParticles then
                noLightsParticles = descendant.Parent
            end

            if noLightsParticles then
                local v1562 = descendant

                t2.value47(v1562)
            end
        end)
    end)
    p204:TrackConnection(VisualStrip.conLightsParticles)

    if not p205 then
        p204:ShowOptimizerToast("Lights & Particles", "Stripping in background…", 0)
    end
end
function t2.value21.DisableNoLightsParticles(p206)
    local VisualStrip = p206.System.VisualStrip

    VisualStrip.noLightsParticles = false

    if VisualStrip.conLightsParticles then
        pcall(function()
            VisualStrip.conLightsParticles:Disconnect()
        end)
        VisualStrip.conLightsParticles = nil
    end
end
function t2.value21.EnableTerrainWaterOptimize(p207, p208)
    local VisualStrip = p207.System.VisualStrip

    if VisualStrip.terrainWater and not p208 then
        return
    end

    VisualStrip.terrainWater = true

    if VisualStrip.conTerrainWater then
        pcall(function()
            VisualStrip.conTerrainWater:Disconnect()
        end)
        VisualStrip.conTerrainWater = nil
    end

    pcall(function()
        p207:SetFlagInternal("FFlagDisableTerrainTextures", "True")
        p207:SetFlagInternal("FIntTerrainArraySliceSize", 0)

        if setfflag or set_fflag then
            local v1222 = setfflag or set_fflag

            v1222("FFlagDisableTerrainTextures", "True")
            v1222("FIntTerrainArraySliceSize", "0")
        end
    end)
    t2.value49(VisualStrip)
    task.spawn(function()
        local descendants = game:GetDescendants()

        for i = 1, #descendants do
            local v1225 = i

            if not VisualStrip.terrainWater then
                return
            end

            local v1226 = descendants[v1225]

            if t2.value48(v1226) then
                t2.value51(v1226)
            end

            if v1225 % 400 == 0 then
                task.wait()
            end
        end
    end)
    VisualStrip.conTerrainWater = workspace.DescendantAdded:Connect(function(descendant)
        if not VisualStrip.terrainWater then
            return
        end

        if not t2.value48(descendant) then
            return
        end

        task.defer(function()
            local terrainWater = VisualStrip.terrainWater

            if terrainWater then
                terrainWater = descendant.Parent
            end

            if terrainWater then
                local v1564 = descendant

                t2.value51(v1564)
            end
        end)
    end)
    p207:TrackConnection(VisualStrip.conTerrainWater)

    if not p208 then
        p207:ShowOptimizerToast("Terrain & Water", "Optimizing in background…", 0)
    end
end
function t2.value21.DisableTerrainWaterOptimize(p209)
    local VisualStrip = p209.System.VisualStrip
    local terrainWater = VisualStrip.terrainWater

    VisualStrip.terrainWater = false

    if VisualStrip.conTerrainWater then
        pcall(function()
            VisualStrip.conTerrainWater:Disconnect()
        end)
        VisualStrip.conTerrainWater = nil
    end

    if terrainWater then
        t2.value50(VisualStrip)
        pcall(function()
            p209:SetFlagInternal("FFlagDisableTerrainTextures", "False", true)
            p209:SetFlagInternal("FIntTerrainArraySliceSize", 64, true)

            if setfflag or set_fflag then
                local v1228 = setfflag or set_fflag

                v1228("FFlagDisableTerrainTextures", "False")
                v1228("FIntTerrainArraySliceSize", "64")
            end
        end)
    end
end
function t2.value64(p210)
    local Lighting = game:GetService("Lighting")

    pcall(function()
        if not p210.savedLighting then
            local v1229 = p210
            local GlobalShadows = Lighting.GlobalShadows
            local LightingBrightness = Lighting.Brightness
            local FogEnd = Lighting.FogEnd

            v1229.savedLighting = {
				GlobalShadows = GlobalShadows,
				Brightness = LightingBrightness,
				FogEnd = FogEnd,
				Technology = nil
			}

            if gethiddenproperty and sethiddenproperty then
                local success, result = pcall(function()
                    return gethiddenproperty(Lighting, "Technology")
                end)
                if success then
                    p210.savedLighting.Technology = result
                end
            end
        end

        Lighting.GlobalShadows = false
        Lighting.Brightness = 2
        Lighting.FogEnd = 900000
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0

        if sethiddenproperty then
            pcall(function()
                sethiddenproperty(Lighting, "Technology", Enum.Technology.Compatibility)
            end)
        end

        for _, child in ipairs(Lighting:GetChildren()) do
            local v1237 = child:IsA("BloomEffect")

            if not v1237 then
                v1237 = child:IsA("BlurEffect")

                if not v1237 then
                    v1237 = child:IsA("SunRaysEffect")

                    if not v1237 then
                        v1237 = child:IsA("DepthOfFieldEffect")

                        if not v1237 then
                            v1237 = child:IsA("ColorCorrectionEffect")
                        end
                    end
                end
            end

            if v1237 then
                child:Destroy()
            end
        end
    end)
    pcall(function()
        local UserGameSettings = UserSettings():GetService("UserGameSettings")

        if p210.savedQuality == nil then
            p210.savedQuality = UserGameSettings.SavedQualityLevel
        end

        UserGameSettings.SavedQualityLevel = Enum.QualityLevel.Level01
    end)
end
function t2.value65(p211)
    local Lighting = game:GetService("Lighting")

    if p211.savedLighting then
        pcall(function()
            Lighting.GlobalShadows = p211.savedLighting.GlobalShadows
            Lighting.Brightness = p211.savedLighting.Brightness

            if p211.savedLighting.FogEnd ~= nil then
                Lighting.FogEnd = p211.savedLighting.FogEnd
            end

            if p211.savedLighting.Technology ~= nil and sethiddenproperty then
                sethiddenproperty(Lighting, "Technology", p211.savedLighting.Technology)
            end
        end)
        p211.savedLighting = nil
    end

    if p211.savedQuality ~= nil then
        pcall(function()
            UserSettings():GetService("UserGameSettings").SavedQualityLevel = p211.savedQuality
        end)
        p211.savedQuality = nil
    end
end
function t2.value66(p212)
    if v30(p212) then
        return
    end

    pcall(function()
        local v1151 = p212:IsA("PointLight")

        if not v1151 then
            v1151 = p212:IsA("SpotLight")

            if not v1151 then
                v1151 = p212:IsA("SurfaceLight")
            end
        end

        if v1151 then
            p212:Destroy()

            return
        end

        local v1152 = p212:IsA("ParticleEmitter")

        if not v1152 then
            v1152 = p212:IsA("Trail")

            if not v1152 then
                v1152 = p212:IsA("Beam")

                if not v1152 then
                    v1152 = p212:IsA("Fire")

                    if not v1152 then
                        v1152 = p212:IsA("Smoke")

                        if not v1152 then
                            v1152 = p212:IsA("Sparkles")
                        end
                    end
                end
            end
        end

        if v1152 then
            p212:Destroy()

            return
        end

        if p212:IsA("Terrain") then
            p212.Decoration = false

            return
        end

        if p212:IsA("BasePart") then
            if p212.Material ~= Enum.Material.SmoothPlastic then
                p212.Material = Enum.Material.SmoothPlastic
            end

            p212.CastShadow = false
            p212.Reflectance = 0

            if p212:IsA("MeshPart") then
                p212.TextureID = "rbxassetid://0"
            end

            local SpecialMesh = p212:FindFirstChildOfClass("SpecialMesh")

            if SpecialMesh then
                SpecialMesh.TextureId = "rbxassetid://0"
            end

            for _, child in ipairs(p212:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") then
                    child:Destroy()
                end
            end

            return
        end

        local v1156 = p212:IsA("Decal")

        if not v1156 then
            v1156 = p212:IsA("Texture")
        end

        if v1156 then
            p212:Destroy()
        end
    end)
end
function t2.value21.EnableVulkanRenderer(p213, p214)
    local VisualStrip = p213.System.VisualStrip

    if VisualStrip.vulkanRenderer and not p214 then
        return
    end

    VisualStrip.vulkanRenderer = true

    if VisualStrip.conVulkan then
        pcall(function()
            VisualStrip.conVulkan:Disconnect()
        end)
        VisualStrip.conVulkan = nil
    end

    if VisualStrip.conVulkanLighting then
        pcall(function()
            VisualStrip.conVulkanLighting:Disconnect()
        end)
        VisualStrip.conVulkanLighting = nil
    end

    if VisualStrip.conVulkanMaintain then
        pcall(function()
            VisualStrip.conVulkanMaintain:Disconnect()
        end)
        VisualStrip.conVulkanMaintain = nil
    end

    t2.value64(VisualStrip)

    local function v732(p215)
        if not p215 then
            return false
        end

        if p215:IsA("BasePart") then
            return true
        end

        local v1240 = p215:IsA("Decal")

        if not v1240 then
            v1240 = p215:IsA("Texture")
        end

        if v1240 then
            return true
        end

        if p215:IsA("SurfaceAppearance") then
            return true
        end

        local v1241 = p215:IsA("Shirt")

        if not v1241 then
            v1241 = p215:IsA("Pants")

            if not v1241 then
                v1241 = p215:IsA("ShirtGraphic")

                if not v1241 then
                    v1241 = p215:IsA("PantsGraphic")
                end
            end
        end

        if v1241 then
            return true
        end

        local v1242 = p215:IsA("Sky")

        if not v1242 then
            v1242 = p215:IsA("Clouds")

            if not v1242 then
                v1242 = p215:IsA("Atmosphere")
            end
        end

        if v1242 then
            return true
        end

        local v1243 = p215:IsA("BloomEffect")

        if not v1243 then
            v1243 = p215:IsA("BlurEffect")

            if not v1243 then
                v1243 = p215:IsA("SunRaysEffect")

                if not v1243 then
                    v1243 = p215:IsA("DepthOfFieldEffect")

                    if not v1243 then
                        v1243 = p215:IsA("ColorCorrectionEffect")
                    end
                end
            end
        end

        if v1243 then
            return true
        end

        return false
    end

    task.spawn(function()
        local descendants = game:GetDescendants()

        for i = 1, #descendants do
            local v1246 = i

            if not VisualStrip.vulkanRenderer then
                return
            end

            local v1247 = descendants[v1246]

            if v732(v1247) and not v30(v1247) then
                t2.value66(v1247)
            end

            if v1246 % 120 == 0 then
                task.wait()
            end
        end
    end)
    VisualStrip.conVulkan = game.DescendantAdded:Connect(function(descendant)
        local vulkanRenderer = VisualStrip.vulkanRenderer

        if vulkanRenderer then
            vulkanRenderer = v732(descendant) and not v30(descendant)
        end

        if vulkanRenderer then
            t2.value66(descendant)
        end
    end)
    VisualStrip.conVulkanLighting = game:GetService("Lighting").ChildAdded:Connect(function(child)
        if not VisualStrip.vulkanRenderer then
            return
        end

        local v1251 = child:IsA("BloomEffect")

        if not v1251 then
            v1251 = child:IsA("BlurEffect")

            if not v1251 then
                v1251 = child:IsA("SunRaysEffect")

                if not v1251 then
                    v1251 = child:IsA("DepthOfFieldEffect")

                    if not v1251 then
                        v1251 = child:IsA("ColorCorrectionEffect")
                    end
                end
            end
        end

        if v1251 then
            pcall(function()
                child:Destroy()
            end)
        end
    end)
    VisualStrip.conVulkanMaintain = game:GetService("RunService").Heartbeat:Connect(function()
        if not VisualStrip.vulkanRenderer then
            return
        end

        VisualStrip._vulkanTick = (VisualStrip._vulkanTick or 0) + 1

        if VisualStrip._vulkanTick % 240 == 0 then
            t2.value64(VisualStrip)
        end
    end)
end
function t2.value21.DisableVulkanRenderer(p216)
    local VisualStrip = p216.System.VisualStrip

    VisualStrip.vulkanRenderer = false
    VisualStrip._vulkanTick = 0

    if VisualStrip.conVulkan then
        pcall(function()
            VisualStrip.conVulkan:Disconnect()
        end)
        VisualStrip.conVulkan = nil
    end

    if VisualStrip.conVulkanLighting then
        pcall(function()
            VisualStrip.conVulkanLighting:Disconnect()
        end)
        VisualStrip.conVulkanLighting = nil
    end

    if VisualStrip.conVulkanMaintain then
        pcall(function()
            VisualStrip.conVulkanMaintain:Disconnect()
        end)
        VisualStrip.conVulkanMaintain = nil
    end

    t2.value65(VisualStrip)
end
t2.value67 = nil
t2.value67 = 300
function t2.value68(p217, p218, p219)
    if not p217 then
        return
    end

    local str = tostring((math.floor(tonumber(p218) or t2.value67)))

    if p219 then
        p217("FFlagTaskSchedulerLimitTargetFpsToScreen", "False")
        p217("FFlagTaskSchedulerLimitTargetFpsToScreen2", "False")
        p217("FFlagTaskSchedulerLimitTargetFpsToScreen3", "False")
        p217("FFlagTaskSchedulerLimitTargetFpsToScreen4", "False")
        p217("FFlagTaskSchedulerLimitTargetFpsToScreen5", "False")
        p217("DFFlagVariableMaxFpsEnabled", "True")
        p217("DFIntTaskSchedulerTargetFps", str)
        p217("FIntFRMMaxFPS", str)
        p217("FFlagFrameRateManagerActive", "False")
        p217("FFlagFrameRateManager", "False")
        p217("FFlagFrameRateManager2", "False")
        p217("FFlagFrameRateManager3", "False")

        return
    end

    p217("FFlagTaskSchedulerLimitTargetFpsToScreen", "True")
    p217("FFlagTaskSchedulerLimitTargetFpsToScreen2", "True")
    p217("FFlagTaskSchedulerLimitTargetFpsToScreen3", "True")
    p217("FFlagTaskSchedulerLimitTargetFpsToScreen4", "True")
    p217("FFlagTaskSchedulerLimitTargetFpsToScreen5", "True")
    p217("DFIntTaskSchedulerTargetFps", str)
    p217("FIntFRMMaxFPS", str)
    p217("FFlagFrameRateManagerActive", "True")
    p217("FFlagFrameRateManager", "True")
    p217("FFlagFrameRateManager2", "True")
    p217("FFlagFrameRateManager3", "True")
end
t2.value69 = {
	"BloomEffect",
	"BlurEffect",
	"ColorCorrectionEffect",
	"DepthOfFieldEffect",
	"SunRaysEffect"
}
t2.value70 = {
	"ParticleEmitter",
	"Fire",
	"Smoke",
	"Sparkles",
	"Beam",
	"Trail",
	"Decal",
	"Texture",
	"SelectionBox",
	"SelectionSphere",
	"BillboardGui"
}
function t2.value21.GetMegaPresetState(p220)
    local VisualStrip = p220.System.VisualStrip

    if not VisualStrip.megaPreset then
        VisualStrip.megaPreset = {
			ultra = false,
			mega = false,
			potato = false,
			descConn = nil,
			freezeConn = nil,
			restored = {},
			texCache = {},
			savedOrigLighting = nil,
			savedCameraFov = nil
		}
    end

    return VisualStrip.megaPreset
end
function t2.value21.MegaPresetDisableProp(p221, p222, p223, p224)
    local MegaPresetState = p221:GetMegaPresetState()
    local insert = table.insert
    local restored = MegaPresetState.restored
    local v748 = p222[p223]

    insert(restored, {
		obj = p222,
		prop = p223,
		old = v748
	})
    pcall(function()
        p222[p223] = p224
    end)
end
function t2.value21.MegaPresetRestoreWhere(p225, p226)
    local MegaPresetState = p225:GetMegaPresetState()

    for i = #MegaPresetState.restored, 1, -1 do
        local v753 = i
        local v754 = MegaPresetState.restored[v753]
        local obj = v754.obj

        if obj then
            obj = p226(v754.obj)
        end

        if obj then
            pcall(function()
                v754.obj[v754.prop] = v754.old
            end)
            table.remove(MegaPresetState.restored, v753)
        end
    end
end
function t2.value21.MegaPresetCaptureOrigLighting(p227)
    local MegaPresetState = p227:GetMegaPresetState()

    if MegaPresetState.savedOrigLighting then
        return
    end

    local Lighting = game:GetService("Lighting")
    local GlobalShadows = Lighting.GlobalShadows
    local LightingBrightness = Lighting.Brightness
    local LightingAmbient = Lighting.Ambient
    local FogEnd = Lighting.FogEnd
    local FogStart = Lighting.FogStart
    local FogColor = Lighting.FogColor
    local EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
    local EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
    local ClockTime = Lighting.ClockTime
    local GeographicLatitude = Lighting.GeographicLatitude

    MegaPresetState.savedOrigLighting = {
		GlobalShadows = GlobalShadows,
		Brightness = LightingBrightness,
		Ambient = LightingAmbient,
		FogEnd = FogEnd,
		FogStart = FogStart,
		FogColor = FogColor,
		EnvDiff = EnvironmentDiffuseScale,
		EnvSpec = EnvironmentSpecularScale,
		ClockTime = ClockTime,
		GeoLat = GeographicLatitude
	}

    local CurrentCamera = workspace.CurrentCamera

    if CurrentCamera and MegaPresetState.savedCameraFov == nil then
        MegaPresetState.savedCameraFov = CurrentCamera.FieldOfView
    end
end
function t2.value21.MegaPresetApplyFps(p228, p229)
    local Lighting = game:GetService("Lighting")

    if p229 then
        p228:MegaPresetCaptureOrigLighting()
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        Lighting.GlobalShadows = false
        Lighting.Brightness = 0.7
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.EnvironmentDiffuseScale = 0

        local GetDescendants = Lighting.GetDescendants

        Lighting.EnvironmentSpecularScale = 0

        for _, v in ipairs(GetDescendants(Lighting)) do
            for _, v6 in ipairs(t2.value69) do
                if v:IsA(v6) and v.Enabled then
                    p228:MegaPresetDisableProp(v, "Enabled", false)

                    break
                end
            end
        end

        return
    end

    local MegaPresetState = p228:GetMegaPresetState()

    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    end)

    if MegaPresetState.savedOrigLighting then
        local savedOrigLighting = MegaPresetState.savedOrigLighting

        Lighting.GlobalShadows = savedOrigLighting.GlobalShadows
        Lighting.Brightness = savedOrigLighting.Brightness
        Lighting.Ambient = savedOrigLighting.Ambient
        Lighting.EnvironmentDiffuseScale = savedOrigLighting.EnvDiff
        Lighting.EnvironmentSpecularScale = savedOrigLighting.EnvSpec
    end

    p228:MegaPresetRestoreWhere(function(p230)
        for _, v in ipairs(t2.value69) do
            if p230:IsA(v) then
                return true
            end
        end

        return false
    end)
end
function t2.value21.MegaPresetDisableEffObj(p231, p232)
    for _, v in ipairs(t2.value70) do
        if p232:IsA(v) then
            local v784 = p232:IsA("Decal") or (not p232:IsA("Texture") and "Enabled" or "Transparency")
            local v785 = v784 == "Transparency" and 1

            if v785 == p232[v784] then
                return
            end

            p231:MegaPresetDisableProp(p232, v784, v785)

            return
        end
    end
end
function t2.value21.MegaPresetApplyLag(p233, p234)
    local MegaPresetState = p233:GetMegaPresetState()
    local _workspace = workspace

    if p234 then

        for v792, v793 in ipairs(_workspace:GetDescendants()) do

            p233:MegaPresetDisableEffObj(v793)
        end
        if not MegaPresetState.descConn then
            MegaPresetState.descConn = _workspace.DescendantAdded:Connect(function(descendant)
                task.defer(function()
                    p233:MegaPresetDisableEffObj(descendant)
                end)
            end)
            p233:TrackConnection(MegaPresetState.descConn)

            return
        end
    else
        if MegaPresetState.descConn then
            pcall(function()
                MegaPresetState.descConn:Disconnect()
            end)
            MegaPresetState.descConn = nil
        end

        p233:MegaPresetRestoreWhere(function(p235)
            for _, v in ipairs(t2.value70) do
                if p235:IsA(v) then
                    return true
                end
            end

            return false
        end)
    end
end
function t2.value21.MegaPresetApplyFog(p236, p237)
    local Lighting = game:GetService("Lighting")

    if p237 then
        p236:MegaPresetCaptureOrigLighting()
        Lighting.FogEnd = 10000000000
        Lighting.FogStart = 9000000000
        Lighting.FogColor = Color3.fromRGB(0, 0, 0)

        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Atmosphere") then
                for _, v in ipairs({
					"Density",
					"Haze",
					"Glare",
					"Offset"
				}) do
                    p236:MegaPresetDisableProp(child, v, 0)
                end
            end

            if child:IsA("Sky") then
                p236:MegaPresetDisableProp(child, "MoonTextureId", "")
                p236:MegaPresetDisableProp(child, "SunTextureId", "")
                p236:MegaPresetDisableProp(child, "StarCount", 0)
            end
        end

        return
    end

    local MegaPresetState = p236:GetMegaPresetState()

    if MegaPresetState.savedOrigLighting then
        local savedOrigLighting = MegaPresetState.savedOrigLighting

        Lighting.FogEnd = savedOrigLighting.FogEnd
        Lighting.FogStart = savedOrigLighting.FogStart
        Lighting.FogColor = savedOrigLighting.FogColor
    end

    p236:MegaPresetRestoreWhere(function(p238)
        local v1260 = p238:IsA("Atmosphere")

        if not v1260 then
            v1260 = p238:IsA("Sky")
        end

        return v1260
    end)
end
function t2.value21.MegaPresetApplyTex(p239, p240)
    local MegaPresetState = p239:GetMegaPresetState()
    local _workspace = workspace

    if p240 then
        for _, descendant in ipairs(_workspace:GetDescendants()) do
            local v809 = descendant
            local v810 = v809:IsA("BasePart")

            if v810 then
                v810 = v809.Material ~= Enum.Material.SmoothPlastic
            end

            if v810 then
                local insert = table.insert
                local texCache = MegaPresetState.texCache
                local Material = v809.Material

                insert(texCache, {
					obj = v809,
					old = Material
				})
                pcall(function()
                    v809.Material = Enum.Material.SmoothPlastic
                end)
            end
        end

        return
    end

    for _, v in ipairs(MegaPresetState.texCache) do
        local v816 = v

        pcall(function()
            v816.obj.Material = v816.old
        end)
    end

    table.clear(MegaPresetState.texCache)
end
function t2.value21.MegaPresetApplyAntiFreeze(p241, p242)
    local MegaPresetState = p241:GetMegaPresetState()
    local CurrentCamera = workspace.CurrentCamera
    local _workspace = workspace

    if p242 then
        pcall(function()
            if CurrentCamera then
                CurrentCamera.MaxDistance = 512
            end
        end)
        pcall(function()
            _workspace.StreamingMinRadius = 64
            _workspace.StreamingTargetRadius = 128
        end)

        local n9 = 0

        MegaPresetState.freezeConn = game:GetService("RunService").Heartbeat:Connect(function(dt)
            n9 += dt

            if n9 > 0.05 then
                pcall(function()
                    collectgarbage("step", 64)
                end)
            end
        end)
        p241:TrackConnection(MegaPresetState.freezeConn)

        return
    end

    pcall(function()
        if CurrentCamera then
            CurrentCamera.MaxDistance = 1000
        end
    end)
    pcall(function()
        _workspace.StreamingMinRadius = 64
        _workspace.StreamingTargetRadius = 512
    end)

    if MegaPresetState.freezeConn then
        pcall(function()
            MegaPresetState.freezeConn:Disconnect()
        end)
        MegaPresetState.freezeConn = nil
    end
end
function t2.value21.MegaPresetApplyTerrainCamera(p243, p244, p245, p246)
    local _workspace = workspace
    local CurrentCamera = workspace.CurrentCamera
    local MegaPresetState = p243:GetMegaPresetState()

    if p244 then
        pcall(function()
            _workspace.Terrain.WaterWaveSize = 0
            _workspace.Terrain.WaterWaveSpeed = 0
            _workspace.Terrain.WaterReflectance = 0
            _workspace.Terrain.Decoration = false
        end)
        pcall(function()
            if CurrentCamera then
                if MegaPresetState.savedCameraFov == nil then
                    MegaPresetState.savedCameraFov = CurrentCamera.FieldOfView
                end

                CurrentCamera.FieldOfView = p245 or 60

                if p246 then
                    CurrentCamera.MaxDistance = p246
                end
            end
        end)

        return
    end

    pcall(function()
        _workspace.Terrain.WaterWaveSize = 0.15
        _workspace.Terrain.WaterWaveSpeed = 0.5
        _workspace.Terrain.WaterReflectance = 0.5
        _workspace.Terrain.Decoration = true
    end)
    pcall(function()
        local v1262 = CurrentCamera

        if v1262 then
            v1262 = MegaPresetState.savedCameraFov
        end

        if v1262 then
            CurrentCamera.FieldOfView = MegaPresetState.savedCameraFov
            MegaPresetState.savedCameraFov = nil
        end
    end)
end
function t2.value21.MegaPresetApplyPotatoExtras(p247, p248)
    local Lighting = game:GetService("Lighting")

    if p248 then
        p247:MegaPresetCaptureOrigLighting()
        Lighting.ClockTime = 14
        Lighting.GeographicLatitude = 0
        Lighting.Brightness = 0.5

        for _, child in ipairs(Lighting:GetChildren()) do
            local v835 = child

            if v835:IsA("PostEffect") then
                if v835.Enabled then
                    p247:MegaPresetDisableProp(v835, "Enabled", false)
                end
            else
                local v836 = v835:IsA("Sky")

                if not v836 then
                    v836 = v835:IsA("Atmosphere")
                end

                if v836 then
                    local MegaPresetState = p247:GetMegaPresetState()

                    table.insert(MegaPresetState.restored, {
						obj = v835,
						prop = "Parent",
						old = Lighting
					})
                    pcall(function()
                        v835.Parent = nil
                    end)
                end
            end
        end

        return
    end

    local MegaPresetState = p247:GetMegaPresetState()

    if MegaPresetState.savedOrigLighting then
        local savedOrigLighting = MegaPresetState.savedOrigLighting

        Lighting.ClockTime = savedOrigLighting.ClockTime
        Lighting.GeographicLatitude = savedOrigLighting.GeoLat
        Lighting.Brightness = savedOrigLighting.Brightness
    end

    p247:MegaPresetRestoreWhere(function(p249)
        local v1264 = p249:IsA("PostEffect")

        if not v1264 then
            v1264 = p249:IsA("Sky")

            if not v1264 then
                v1264 = p249:IsA("Atmosphere")
            end
        end

        return v1264
    end)
end
function t2.value21.MegaPresetApplyCore(p250, p251)
    p250:MegaPresetApplyFps(p251)
    p250:MegaPresetApplyLag(p251)
    p250:MegaPresetApplyFog(p251)
    p250:MegaPresetApplyTex(p251)
end
function t2.value21.ClearOptimizerPresets(p252, p253)
    for _, v in ipairs({
		"OptimizerUltraMode",
		"OptimizerMegaBoost",
		"OptimizerPotatoMode"
	}) do
        if v ~= p253 and p252:IsFlagToggleOn(v) then
            p252:SetFlagInternal(v, "False", true)

            if v == "OptimizerUltraMode" then
                p252:ApplyOptimizerPresetUltra(false)
            elseif v == "OptimizerMegaBoost" then
                p252:ApplyOptimizerPresetMega(false)
            else
                p252:ApplyOptimizerPresetPotato(false)
            end

            p252:RefreshUIVisuals(v)
        end
    end
end
function t2.value21.ApplyOptimizerPresetUltra(p254, p255)
    local MegaPresetState = p254:GetMegaPresetState()

    MegaPresetState.ultra = p255

    if p255 then
        MegaPresetState.mega = false
        MegaPresetState.potato = false
    end

    p254:MegaPresetApplyCore(p255)

    if not p255 then
        MegaPresetState.savedOrigLighting = nil
    end

    if p255 then
        p254:Log("Ultra Mode: FPS + Lag + Fog + Tex.")
        p254:ShowOptimizerToast("Ultra Mode", "FPS, lag, fog & texture boost.", 0)
    end
end
function t2.value21.ApplyOptimizerPresetMega(p256, p257)
    local MegaPresetState = p256:GetMegaPresetState()

    MegaPresetState.mega = p257

    if p257 then
        MegaPresetState.ultra = false
        MegaPresetState.potato = false
    end

    p256:MegaPresetApplyCore(p257)
    p256:MegaPresetApplyAntiFreeze(p257)
    p256:MegaPresetApplyTerrainCamera(p257, 60, nil)

    if not p257 then
        p256:MegaPresetApplyAntiFreeze(false)
        p256:MegaPresetApplyTerrainCamera(false)
        MegaPresetState.savedOrigLighting = nil
    end

    if p257 then
        p256:Log("Mega Boost: Ultra + Anti-Freeze + Terrain + Camera.")
        p256:ShowOptimizerToast("Mega Boost", "Ultra stack + stability + terrain.", 0)
    end
end
function t2.value21.ApplyOptimizerPresetPotato(p258, p259)
    local MegaPresetState = p258:GetMegaPresetState()

    MegaPresetState.potato = p259

    if p259 then
        MegaPresetState.ultra = false
        MegaPresetState.mega = false
    end

    local v855 = p259

    if p259 then
        v855 = p258:IsFlagToggleOn("OptimizerGraySkyEnable")
    end

    if v855 then
        p258:SetFlagInternal("OptimizerGraySkyEnable", "False", true)
        p258:DisableGraySky()
        p258:RefreshUIVisuals("OptimizerGraySkyEnable")
    end

    p258:MegaPresetApplyCore(p259)
    p258:MegaPresetApplyAntiFreeze(p259)

    if p259 then
        p258:MegaPresetApplyPotatoExtras(true)
        p258:MegaPresetApplyTerrainCamera(true, 55, 256)
        p258.System.VisualStrip.potatoFps = true
        p258:ApplyFpsCap(t2.value67)
        p258:Log("Potato Mode: max lightweight · FPS cap " .. tostring(t2.value67) .. ".")
        p258:ShowOptimizerToast("Potato Mode", "Lightweight preset · " .. tostring(t2.value67) .. " FPS cap.", 0)

        return
    end

    p258:MegaPresetApplyCore(false)
    p258:MegaPresetApplyPotatoExtras(false)
    p258:MegaPresetApplyAntiFreeze(false)
    p258:MegaPresetApplyTerrainCamera(false)
    pcall(function()
        local CurrentCamera = workspace.CurrentCamera

        if CurrentCamera then
            CurrentCamera.MaxDistance = 1000
        end
    end)
    MegaPresetState.savedOrigLighting = nil
    p258:ReleasePotatoFpsCap()
end
function t2.value21.ApplyOptimizerVulkan(p260, p261)
    if p261 then
        p260:EnableVulkanRenderer(false)

        return
    end

    p260:DisableVulkanRenderer()
end
function t2.value21.ApplyFpsCap(p262, p263)
    local u860 = math.floor(tonumber(p263) or t2.value67)

    if u860 < 1 then
        u860 = t2.value67
    end

    p262:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen", "False", true)
    p262:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen2", "False", true)
    p262:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen3", "False", true)
    p262:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen4", "False", true)
    p262:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen5", "False", true)
    p262:SetFlagInternal("DFFlagVariableMaxFpsEnabled", "True", true)
    p262:SetFlagInternal("DFIntTaskSchedulerTargetFps", u860, true)
    p262:SetFlagInternal("FIntFRMMaxFPS", u860, true)
    p262:SetFlagInternal("FFlagFrameRateManagerActive", "False", true)
    p262:SetFlagInternal("FFlagFrameRateManager", "False", true)
    p262:SetFlagInternal("FFlagFrameRateManager2", "False", true)
    p262:SetFlagInternal("FFlagFrameRateManager3", "False", true)

    if setfflag or set_fflag then
        pcall(function()
            t2.value68(setfflag or set_fflag, u860, true)
        end)
    end

    if setfpscap then
        pcall(function()
            setfpscap(u860)
        end)
    end
end
function t2.value21.RestoreDefaultFpsCap(p264)
    local num = tonumber(p264.ActiveFlags[t2.value23("DFIntTaskSchedulerTargetFps")])

    if not num then
        num = tonumber(p264.ActiveFlags.DFIntTaskSchedulerTargetFps) or 60
    end

    local v863 = num

    p264:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen", "True", true)
    p264:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen2", "True", true)
    p264:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen3", "True", true)
    p264:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen4", "True", true)
    p264:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen5", "True", true)
    p264:SetFlagInternal("DFIntTaskSchedulerTargetFps", v863, true)
    p264:SetFlagInternal("FIntFRMMaxFPS", v863, true)
    p264:SetFlagInternal("FFlagFrameRateManagerActive", "True", true)
    p264:SetFlagInternal("FFlagFrameRateManager", "True", true)
    p264:SetFlagInternal("FFlagFrameRateManager2", "True", true)
    p264:SetFlagInternal("FFlagFrameRateManager3", "True", true)

    if setfflag or set_fflag then
        pcall(function()
            t2.value68(setfflag or set_fflag, v863, false)
        end)
    end

    if setfpscap then
        pcall(function()
            setfpscap(v863)
        end)
    end
end
function t2.value21.ReleasePotatoFpsCap(p265)
    local VisualStrip = p265.System.VisualStrip

    if not VisualStrip then
        return
    end

    VisualStrip.potatoFps = false

    local fpsUnlock = VisualStrip.fpsUnlock

    if not fpsUnlock then
        fpsUnlock = p265:IsFlagToggleOn("OptimizerFpsUnlock")
    end

    if fpsUnlock then
        p265:ApplyFpsCap(9999)
        VisualStrip.fpsUnlock = true

        return
    end

    p265:RestoreDefaultFpsCap()
end
function t2.value21.ApplyOptimizerFpsUnlock(p266, p267)
    local VisualStrip = p266.System.VisualStrip

    if not p267 then
        VisualStrip.fpsUnlock = false

        if VisualStrip.potatoFps then
            return
        end

        p266:RestoreDefaultFpsCap()

        return
    end

    VisualStrip.fpsUnlock = true
    p266:ApplyFpsCap(9999)
end
local s3 = "FFlagDebugGraphicsPreferVulkan"
t2.value71 = {}
for _, v in ipairs({
	"NoTexturesEnable",
	"NoMeshesEnable",
	"OptimizerVulkanEnable",
	s3,
	"OptimizerFpsUnlock",
	"OptimizerLowSkyEnable",
	"OptimizerGraySkyEnable",
	"OptimizerNoLightsParticlesEnable",
	"OptimizerTerrainWaterEnable",
	"OptimizerMegaFpsBoost",
	"OptimizerMegaAntiLag",
	"OptimizerMegaAntiFreeze",
	"OptimizerUltraMode",
	"OptimizerMegaBoost",
	"OptimizerPotatoMode"
}) do
    if v ~= s3 then
        t2.value71[v] = true
    end
end
function t2.value21.StripEphemeralOptimizerFlags(p268)
    for k in pairs(t2.value71) do
        p268.ActiveFlags[k] = "False"
    end
end
function t2.value21.SanitizeSavedPresetsOptimizerFlags(p269)
    for _, v in pairs(p269.SavedPresets or {}) do
        if type(v) == "table" then
            for k in pairs(t2.value71) do
                v[k] = nil
            end
        end
    end
end
function t2.value21.MigrateOptimizerFlags(p270)
    if p270.ActiveFlags.PotatoMode ~= nil then
        p270.ActiveFlags.PotatoMode = nil
    end

    if p270.ActiveFlags.Unlock240FPS ~= nil then
        p270.ActiveFlags.Unlock240FPS = nil
    end

    p270:StripEphemeralOptimizerFlags()
    p270:SanitizeSavedPresetsOptimizerFlags()
end
function t2.value21.FinalizeOptimizerTab(p271)
    p271:SyncVisualStripFromFlags()
end
function t2.value21.SyncVisualStripFromFlags(p272)
    local VisualStrip = p272.System.VisualStrip
    local v880 = p272:IsFlagToggleOn("OptimizerUltraMode")

    if not v880 then
        v880 = p272:IsFlagToggleOn("OptimizerMegaBoost")

        if not v880 then
            v880 = p272:IsFlagToggleOn("OptimizerPotatoMode")
        end
    end

    if p272:IsFlagToggleOn("OptimizerUltraMode") then
        p272:ApplyOptimizerPresetUltra(true)
    elseif p272:IsFlagToggleOn("OptimizerMegaBoost") then
        p272:ApplyOptimizerPresetMega(true)
    elseif p272:IsFlagToggleOn("OptimizerPotatoMode") then
        p272:ApplyOptimizerPresetPotato(true)
    else
        p272:ApplyOptimizerPresetUltra(false)
        p272:ApplyOptimizerPresetMega(false)
        p272:ApplyOptimizerPresetPotato(false)
    end

    if v880 then
        return
    end

    if p272:IsFlagToggleOn("NoTexturesEnable") then
        p272:EnableNoTextures(true)
    elseif VisualStrip.noTextures then
        p272:DisableNoTextures()
    end

    if p272:IsFlagToggleOn("NoMeshesEnable") then
        p272:EnableNoMeshes(true)
    elseif VisualStrip.noMeshes then
        p272:DisableNoMeshes()
    end

    if p272:IsFlagToggleOn("OptimizerLowSkyEnable") then
        p272:EnableLowTextureSky(true)
    elseif VisualStrip.lowSky then
        p272:DisableLowTextureSky()
    end

    if p272:IsFlagToggleOn("OptimizerGraySkyEnable") then
        p272:EnableGraySky(true)
    elseif VisualStrip.graySky then
        p272:DisableGraySky()
    end

    if p272:IsFlagToggleOn("OptimizerNoLightsParticlesEnable") then
        p272:EnableNoLightsParticles(true)
    elseif VisualStrip.noLightsParticles then
        p272:DisableNoLightsParticles()
    end

    if p272:IsFlagToggleOn("OptimizerTerrainWaterEnable") then
        p272:EnableTerrainWaterOptimize(true)
    elseif VisualStrip.terrainWater then
        p272:DisableTerrainWaterOptimize()
    end

    if p272:IsFlagToggleOn("OptimizerVulkanEnable") then
        p272:EnableVulkanRenderer(true)
    elseif VisualStrip.vulkanRenderer then
        p272:DisableVulkanRenderer()
    end

    if p272:IsFlagToggleOn("OptimizerFpsUnlock") then
        p272:ApplyOptimizerFpsUnlock(true)
    elseif VisualStrip.fpsUnlock then
        p272:ApplyOptimizerFpsUnlock(false)
    end

    local megaBoost = VisualStrip.megaBoost

    if p272:IsFlagToggleOn("OptimizerMegaFpsBoost") then
        p272:ApplyOptimizerMegaFpsBoost(true)
    elseif megaBoost and megaBoost.fpsBoost then
        p272:ApplyOptimizerMegaFpsBoost(false)
    end

    if p272:IsFlagToggleOn("OptimizerMegaAntiLag") then
        p272:ApplyOptimizerMegaAntiLag(true)
    elseif megaBoost and megaBoost.antiLag then
        p272:ApplyOptimizerMegaAntiLag(false)
    end

    if p272:IsFlagToggleOn("OptimizerMegaAntiFreeze") then
        p272:ApplyOptimizerMegaAntiFreeze(true)

        return
    end

    if megaBoost and megaBoost.antiFreeze then
        p272:ApplyOptimizerMegaAntiFreeze(false)
    end
end
function t2.value21.ReapplyVisualStripAfterJoin(p273)
    task.spawn(function()
        if not game:IsLoaded() then
            pcall(function()
                game.Loaded:Wait()
            end)
        end

        task.wait(0.65)

        local v1266 = not p273.System

        if not v1266 then
            v1266 = not p273.System.VisualStrip
        end

        if v1266 then
            return
        end

        p273:SyncVisualStripFromFlags()
    end)
end
function t2.value21.SetupVisualStripLifecycle(p274)
    local VisualStrip = p274.System.VisualStrip

    if VisualStrip._lifecycle then
        return
    end

    VisualStrip._lifecycle = true
    pcall(function()
        local LocalPlayer5 = game:GetService("Players").LocalPlayer

        p274:TrackConnection(LocalPlayer5.CharacterAdded:Connect(function()
            p274:ReapplyVisualStripAfterJoin()
        end))
    end)
    pcall(function()
        local JobId = game.JobId

        task.spawn(function()
            while p274.System.IsRunning do
                task.wait(1.25)

                if game.JobId ~= JobId then
                    JobId = game.JobId
                    p274:ReapplyVisualStripAfterJoin()
                end
            end
        end)
    end)
end
function t2.value21.InjectAll(p275)
    if p275.System.IsInjecting then
        p275:Log("Already injecting...")

        return
    end

    p275.System.IsInjecting = true
    p275.System.CurrentInjectId = (p275.System.CurrentInjectId or 0) + 1

    local CurrentInjectId = p275.System.CurrentInjectId

    p275:PurgeInjectBloat()

    if p275.UI.InjectBtn then
        if p275.UI.InjectBg then
            p275.UI.InjectBg.BackgroundColor3 = p275.Theme.ToggleOff
        end

        if p275.UI.InjectText then
            p275.UI.InjectText.Text = "INJECTING..."
        else
            p275.UI.InjectBtn.Text = "INJECTING..."
        end
    end

    p275:DetectCapabilities()

    local Capabilities = p275.System.Capabilities

    p275:Log("[Engine] Inject ready · setfflag:" .. (not Capabilities.setfflag and "NO" or "OK") .. " · " .. Capabilities.platform)

    local v888 = not Capabilities.setfflag

    if v888 then
        v888 = not p275.System.IsHooked
    end

    if v888 then
        p275:Log("[Engine] Warning: Limited executor — few flags may apply.")
    end

    p275:InitializeHook(false)
    p275.NativeFlags = {}

    for k, _ in pairs(p275.UIRegistry) do
        local v891 = p275.ActiveFlags[k]

        if v891 ~= nil then
            p275.NativeFlags[k] = v891

            if p275.Callbacks[k] then
                local v892 = tostring(v891):lower()
                local u893 = v892
                pcall(function()
                    local v1269 = p275.Callbacks[k]
                    local v1270 = u893 == "true"

                    if not v1270 then
                        v1270 = u893 == "1"

                        if not v1270 then
                            v1270 = u893 == "on"
                        end
                    end

                    v1269(v1270)
                end)
            end
        end
    end

    p275:Log("[Engine] Runtime callbacks synced.")

    local t33 = {}

    for k, v in pairs(p275.NativeFlags) do
        local v897 = p275.OriginalNames[k]

        t33[#t33 + 1] = {
			k,
			tostring(v),
			v897,
			false
		}
    end

    local _CustomBox = p275.ActiveFlags._CustomBox

    if not _CustomBox then
        _CustomBox = p275.CustomBoxData or ""
    end

    p275.InjectCatalog = p275:ParseCustomFlagsToCatalog(_CustomBox)

    for k, v in pairs(p275.InjectCatalog) do
        t33[#t33 + 1] = {
			k,
			tostring(v.val),
			v.orig,
			true
		}
        p275.NativeFlags[k] = v.val
    end

    table.sort(t33, function(p276, p277)
        local v1273 = p276[1]
        local v1274 = t2.value25(v1273)
        local v1275 = t2.value25(p277[1])

        if v1274 ~= v1275 then
            return v1274 < v1275
        end

        return p276[1] < p277[1]
    end)

    local v901 = #t33
    local u902 = t2.value31(t33)
    local v903 = #u902
    local v904 = t2.value30(v903)

    p275:Log("[Engine] Initiating Masterstrap Flag Injection...")

    if v901 ~= v903 then
        p275:Log("[Engine] Queue: " .. v903 .. " unique (" .. v901 .. " parsed). Full multi-prefix ON.")
    else
        p275:Log("[Engine] Queue: " .. v903 .. " flags · full multi-prefix · catalog mode.")
    end

    if v903 >= 300 then
        p275:Log("[Engine] Large batch · pacing " .. string.format("%.3f", v904.drip_wait) .. "s/flag (power preserved).")
    end

    task.spawn(function()
        if p275.System.CurrentInjectId ~= CurrentInjectId then
            return
        end
        local n10 = 0
        local n11 = 0
        local n12 = 0
        for v1281, v1282 in ipairs(u902) do

            if p275.System.CurrentInjectId ~= CurrentInjectId then
                p275:Log("[Engine] Inject cancelled.")

                return
            end

            local v1283 = v1282[1]
            local v1284 = v1282[2]
            local v1285 = v1282[3]
            local v1286 = v1282[4]

            if Capabilities.setfflag and not v29(v1283, v1284, v1285, v904.variant_wait) then
                n12 += 1
            end

            if v1286 then
                n11 += 1

                if v904.log_each_custom then
                    p275:Log("[Custom] Applying: " .. v1283 .. " = " .. v1284)
                elseif n11 == 1 or n11 % 80 == 0 then
                    p275:Log("[Custom] Progress: " .. n11 .. " / " .. v903)
                end
            end

            task.wait(v904.drip_wait)
            n10 += 1

            local v1287 = v904.batch_every > 0

            if v1287 then
                v1287 = n10 % v904.batch_every == 0
            end

            if v1287 then
                task.wait(v904.batch_pause)

                if v904.batch_frames > 0 then
                    v28(v904.batch_frames)
                end
            end

            if n10 == 150 then
                p275:Log("[Engine] Optimizing graphics profile & rendering pipelines...")
            elseif n10 == 300 then
                p275:Log("[Engine] Bypassing graphics level limits & memory profiles...")
            elseif n10 == 450 then
                p275:Log("[Engine] Adjusting network buffer & latency stabilization...")
            end
        end
        if p275.System.CurrentInjectId ~= CurrentInjectId then
            return
        end
        local v1288 = p275:VerifyInjectedFlags(v904.verify_limit)
        if v1288 and v1288.checked > 0 then
            local System = p275.System
            local verified = v1288.verified
            local checked = v1288.checked
            local failed = v1288.failed

            System.LastInjectStats = {
				applied = n10,
				verified = verified,
				checked = checked,
				failed = failed
			}
            p275:Log(string.format("[Engine] Verified %d/%d sampled flags.", v1288.verified, v1288.checked))

            local v1293 = v1288.failed > 0

            if v1293 then
                v1293 = Capabilities.setfflag

                if v1293 then
                    v1293 = v1288.failed_names and #v1288.failed_names > 0
                end
            end

            if v1293 then
                local v1294 = math.min(#v1288.failed_names, v904.retry_limit)

                p275:Log("[Engine] Retrying " .. v1294 .. " mismatched flags (full prefix)...")

                for i = 1, v1294 do
                    if p275.System.CurrentInjectId ~= CurrentInjectId then
                        return
                    end

                    local v1296 = v1288.failed_names[i]
                    local v1297 = p275.NativeFlags[v1296]
                    local v1298 = v1297 == nil

                    if v1298 then
                        v1298 = p275.InjectCatalog[v1296]
                    end

                    if v1298 then
                        v1297 = p275.InjectCatalog[v1296].val
                    end

                    if v1297 ~= nil then
                        v29(v1296, tostring(v1297), p275.OriginalNames[v1296], v904.variant_wait)
                        task.wait((math.max(v904.drip_wait, 0.012)))
                    end
                end

                v28(1)

                local v1299 = p275:VerifyInjectedFlags(math.min(v904.verify_limit, 18))

                if v1299 and v1299.checked > 0 then
                    p275:Log(string.format("[Engine] After retry: %d/%d samples OK.", v1299.verified, v1299.checked))
                end
            elseif v1288.failed > 0 then
                p275:Log("[Engine] Note: " .. v1288.failed .. " samples differ — normal on some builds.")
            end
        elseif Capabilities.getfflag then
            p275:Log("[Engine] Verify skipped (no readable samples).")
        end
        if n12 > 0 then
            p275:Log("[Engine] " .. n12 .. " setfflag calls failed.")
        end
        if p275.System.CurrentInjectId ~= CurrentInjectId then
            return
        end
        p275:PurgeInjectBloat()
        p275.System.IsInjecting = false
        if p275.UI.InjectBtn then
            if p275.UI.InjectBg then
                p275.UI.InjectBg.BackgroundColor3 = p275.Theme.Accent
            end

            if p275.UI.InjectText then
                p275.UI.InjectText.Text = "INJECT ALL"
            else
                p275.UI.InjectBtn.Text = "INJECT ALL"
            end
        end
        p275:Log("[Engine] Successfully applied " .. n10 .. " system adjustments!")
        if n11 > 0 then
            p275:Log("[System] Synced " .. n11 .. " custom modifications.")
        end
        p275:Log("[System] All changes applied. Masterstrap is Ready!")
    end)
end
function t2.value21.InitializeHook(p278, p279)
    local g913
    local result
    if p279 then
        p278.System.IsHooked = false
    end
    if p278.System.IsHooked then
        return true
    end
    p278:DetectCapabilities()
    local v907 = not p278.System.Capabilities.hookfunction
    if not v907 then
        v907 = not p278.System.Capabilities.get_module_base
    end
    if v907 then
        return false
    end
    local v908
    local v909, v910, v911 = ipairs({
		"libroblox.so",
		"lib_roblox.so",
		"lib_roblox_vng.so",
		"librbx.so"
	})
    repeat
        local v912

        v911, v912 = v909(v910, v911)

        if not v911 then
            g913 = true
        end

        if g913 then
            break
        end

        local v914 = v912
        local ok

        ok, result = pcall(function()
            return get_module_base(v914)
        end)

        if ok then
            ok = result and result ~= 0
        end
    until ok
    if not g913 then
        v908 = result
    end
    if not v908 then
        return false
    end
    local u917 = v908 + 40395740
    local u918 = false
    pcall(function()
        local u1300
        u1300 = hookfunction(u917, function(p280, p281)
            local s4 = ""
            pcall(function()
                if type(p280) == "string" then
                    s4 = p280

                    return
                end

                if readstring then
                    s4 = readstring(p280)

                    return
                end

                s4 = tostring(p280)
            end)
            if s4 ~= "" then
                local v1568 = t2.value23(s4)
                local FlagOverride = t2.value21:GetFlagOverride(v1568)

                if FlagOverride ~= nil then
                    local v1570 = tostring(FlagOverride):lower()

                    if v1570 == "true" then
                        return true
                    end

                    if v1570 == "false" then
                        return false
                    end

                    local num = tonumber(FlagOverride)

                    if num ~= nil then
                        return num
                    end
                end
            end

            return u1300(p280, p281)
        end)
        u918 = true
    end)
    if u918 then
        p278.System.IsHooked = true
        p278.System.HookGeneration = (p278.System.HookGeneration or 0) + 1

        return true
    end

    return false
end
function t2.value21.IsQuietLog(_, p283)
    local v921 = tostring(p283):lower()

    if v921:find("reverted flags", 1, true) then
        return true
    end

    if v921:find("re%-enforcing", 1, true) then
        return true
    end

    if v921:find("rejoin", 1, true) then
        return true
    end

    return false
end
function t2.value21.Log(p284, p285)
    if p284:IsQuietLog(p285) then
        return
    end

    if p284.UI.LogLabel then
        p284.UI.LogLabel.Text = "> " .. p285
    end
end
function t2.value72()
    local ok, result = pcall(function()
        return game:GetService("UserInputService"):GetPlatform()
    end)

    if ok then
        ok = result == Enum.Platform.IOS
    end

    return ok
end
t2.value73 = nil
function t2.value73()
    local CurrentCamera = workspace.CurrentCamera
    local v927 = CurrentCamera

    if CurrentCamera then
        v927 = CurrentCamera.ViewportSize.X > 0

        if v927 then
            v927 = CurrentCamera.ViewportSize.Y > 0
        end
    end

    if v927 then
        return CurrentCamera.ViewportSize
    end

    return Vector2.new(800, 450)
end
function t2.value74()
    local v928 = t2.value73()
    local v929 = t2.value72()
    local v930 = math.min(v928.X, v928.Y)

    math.max(v928.X, v928.Y)

    local vector2 = Vector2.new(680, 420)
    local vector2_2 = Vector2.new(400, 250)
    local t34 = {
		isIOS = v929,
		viewport = v928,
		mainFillX = 0.85,
		mainFillY = 0.85,
		maxSize = vector2,
		minSize = vector2_2,
		uiScale = 1,
		miniBarPx = 50,
		sidebarW = 170,
		contentTop = 58,
		contentBottom = 85,
		logBottom = 28,
		customCardH = 160,
		flagCardH = 44,
		bodyText = 11,
		btnH = 30
	}

    if v929 then
        t34.mainFillX = 0.9
        t34.mainFillY = 0.88
        t34.uiScale = math.clamp(v930 / 720, 1, 1.35)
        t34.miniBarPx = 50
        t34.sidebarW = 170
        t34.contentTop = 58
        t34.contentBottom = 85
        t34.logBottom = 28
        t34.customCardH = 160
        t34.flagCardH = 44
        t34.bodyText = 11
        t34.btnH = 30
        t34.maxSize = Vector2.new(math.min(680, (math.floor(v928.X * 0.92))), (math.min(420, (math.floor(v928.Y * 0.86)))))
        t34.minSize = Vector2.new(math.min(400, (math.floor(v928.X * 0.62))), (math.min(250, (math.floor(v928.Y * 0.42)))))

        return t34
    end

    t34.maxSize = Vector2.new(math.min(680, (math.floor(v928.X * 0.92))), (math.min(420, (math.floor(v928.Y * 0.86)))))
    t34.minSize = Vector2.new(math.min(400, (math.floor(v928.X * 0.62))), (math.min(250, (math.floor(v928.Y * 0.42)))))

    return t34
end
function t2.value21.ApplyMobileUILayout(p286, p287)
    local v936 = not p286.UI

    if not v936 then
        v936 = not p286.UI.Main
    end

    if v936 then
        return
    end

    local v937 = p287 or t2.value74()

    p286.MobileLayout = v937
    t2.value21.MobileLayout = v937

    if p286.UserResizedSize then
        local v938 = math.min(p286.UserResizedSize.X, v937.viewport.X / v937.uiScale)
        local v939 = math.min(p286.UserResizedSize.Y, v937.viewport.Y / v937.uiScale)

        p286.UI.Main.Size = UDim2.new(0, v938, 0, v939)
    else
        p286.UI.Main.Size = UDim2.new(v937.mainFillX, 0, v937.mainFillY, 0)
    end

    if p286.UI.SizeConstraint then
        p286.UI.SizeConstraint.MaxSize = v937.maxSize
        p286.UI.SizeConstraint.MinSize = v937.minSize
    end

    if p286.UI.RootUIScale then
        p286.UI.RootUIScale.Scale = v937.uiScale
    end

    if p286.UI.MiniBar then
        local miniBarPx = v937.miniBarPx

        p286.UI.MiniBar.Size = UDim2.new(0, miniBarPx, 0, miniBarPx)
        p286.UI.MiniBar.Position = UDim2.new(0.5, -math.floor(miniBarPx / 2), 0.05, 0)
    end

    local v941 = v937.sidebarW or 170
    local v942 = v941 + 8
    local v943 = -(v941 + 15)

    if p286.UI.Sidebar then
        p286.UI.Sidebar.Size = UDim2.new(0, v941, 1, 0)
    end

    if p286.UI.Content then
        local v944 = v937.contentBottom or 85

        p286.UI.Content.Size = UDim2.new(1, v943, 1, -v944)
        p286.UI.Content.Position = UDim2.new(0, v942, 0, v937.contentTop or 58)
    end

    if p286.UI.Header then
        local v945 = not v937.isIOS and 54 or 46

        p286.UI.Header.Size = UDim2.new(1, -v941, 0, v945)
        p286.UI.Header.Position = UDim2.new(0, v941, 0, 0)
    end

    if p286.UI.LogBg then
        p286.UI.LogBg.Size = UDim2.new(1, v943 + 3, 0, v937.logBottom or 28)
        p286.UI.LogBg.Position = UDim2.new(0, v941 + 5, 1, -(v937.logBottom or 28) - 2)
    end

    if p286.UI.CustomCard then
        p286.UI.CustomCard.Size = UDim2.new(0.98, 0, 0, v937.customCardH or 160)
    end

    if p286.UI.CustomInput then
        local v946 = v937.btnH or 30

        p286.UI.CustomInput.Size = UDim2.new(1, -16, 1, -(v946 + 18))
        p286.UI.CustomInput.TextSize = v937.bodyText or 11
    end

    if p286.UI.LogLabel then
        p286.UI.LogLabel.TextSize = v937.bodyText or 10
    end
end
function t2.value21.BuildUI(p288)
    local t35 = {}
    local t36 = {
		value1 = p288
	}
    local v950 = t2.value74()

    t36.value2 = Instance.new("ScreenGui")
    t36.value2.Name = game:GetService("HttpService"):GenerateGUID(false)
    t36.value2.ResetOnSpawn = false
    t36.value2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    t36.value2.IgnoreGuiInset = true
    pcall(function()
        t36.value2.ScreenInsets = Enum.ScreenInsets.None
    end)
    pcall(function()
        t36.value2.Parent = game:GetService("CoreGui")
    end)

    if not t36.value2.Parent then
        t36.value2.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local UIScale = Instance.new("UIScale", t36.value2)

    UIScale.Name = "MasterstrapUIScale"
    UIScale.Scale = v950.uiScale
    t36.value3 = Instance.new("Frame", t36.value2)
    t36.value3.Size = UDim2.new(v950.mainFillX, 0, v950.mainFillY, 0)
    t36.value3.AnchorPoint = Vector2.new(0.5, 0.5)
    t36.value3.Position = UDim2.new(0.5, 0, 0.5, 0)
    t36.value3.BackgroundColor3 = t36.value1.Theme.MainBg
    t36.value3.BorderSizePixel = 0
    t36.value3.ClipsDescendants = true

    local UISizeConstraint = Instance.new("UISizeConstraint", t36.value3)

    UISizeConstraint.MaxSize = v950.maxSize
    UISizeConstraint.MinSize = v950.minSize

    if v950.isIOS then
        local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint", t36.value3)

        UIAspectRatioConstraint.AspectRatio = 1.62
        UIAspectRatioConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
        UIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Width
    end

    local UIStroke = Instance.new("UIStroke", t36.value3)

    UIStroke.Color = t36.value1.Theme.CardBorder
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.4

    local ImageButton = Instance.new("ImageButton", t36.value3)

    ImageButton.Name = "ResizeHandle"
    ImageButton.Size = UDim2.new(0, 18, 0, 18)
    ImageButton.Position = UDim2.new(1, -18, 1, -18)
    ImageButton.BackgroundTransparency = 1
    ImageButton.Image = "rbxassetid://9712792823"
    ImageButton.ImageColor3 = t36.value1.Theme.Muted
    ImageButton.ZIndex = 100;
    (function(p289, p290)
        local UserInputService = game:GetService("UserInputService")
        local u1304
        local u1305
        local inputPosition
        local AbsoluteSize
        p290.InputBegan:Connect(function(input)
            local v1573 = input.UserInputType == Enum.UserInputType.MouseButton1

            if not v1573 then
                v1573 = input.UserInputType == Enum.UserInputType.Touch
            end

            if v1573 then
                u1304 = true
                inputPosition = input.Position
                AbsoluteSize = p289.AbsoluteSize

                local UIAspectRatioConstraint = p289:FindFirstChildOfClass("UIAspectRatioConstraint")

                if UIAspectRatioConstraint then
                    UIAspectRatioConstraint.Enabled = false
                end

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        u1304 = false
                    end
                end)
            end
        end)
        p290.InputChanged:Connect(function(input)
            local v1576 = input.UserInputType == Enum.UserInputType.MouseMovement

            if not v1576 then
                v1576 = input.UserInputType == Enum.UserInputType.Touch
            end

            if v1576 then
                u1305 = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == u1305 and u1304 then
                local inputPosition2 = input.Position
                local v1579 = p289
                local v1580 = inputPosition2 - inputPosition
                local n13 = 1
                local ScreenGui = v1579:FindFirstAncestorWhichIsA("ScreenGui")

                if ScreenGui then
                    ScreenGui = p289:FindFirstAncestorWhichIsA("ScreenGui"):FindFirstChildOfClass("UIScale")
                end

                if ScreenGui then
                    n13 = ScreenGui.Scale
                end

                local v1583 = math.clamp((AbsoluteSize.X + v1580.X) / n13, 380, 1200)
                local v1584 = math.clamp((AbsoluteSize.Y + v1580.Y) / n13, 240, 800)

                p289.Size = UDim2.new(0, v1583, 0, v1584)
                t36.value1.UserResizedSize = Vector2.new(v1583, v1584)
            end
        end)
    end)(t36.value3, ImageButton)

    local Frame = Instance.new("Frame", t36.value3)

    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Frame.BackgroundTransparency = 0.96
    Frame.ZIndex = 0
    Frame.BorderSizePixel = 0

    local UIGradient = Instance.new("UIGradient", Frame)

    UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 58, 58)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(44, 44, 44)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(38, 38, 38))
	})
    UIGradient.Rotation = 135
    UIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.85),
		NumberSequenceKeypoint.new(0.5, 0.97),
		NumberSequenceKeypoint.new(1, 0.9)
	})
    t36.value4 = Instance.new("Frame", t36.value2)

    local miniBarPx = v950.miniBarPx

    t36.value4.Size = UDim2.new(0, miniBarPx, 0, miniBarPx)
    t36.value4.Position = UDim2.new(0.5, -math.floor(miniBarPx / 2), 0.05, 0)
    t36.value4.BackgroundColor3 = t36.value1.Theme.Card
    t36.value4.Visible = false
    Instance.new("UICorner", t36.value4).CornerRadius = UDim.new(1, 0)

    local UIStroke2 = Instance.new("UIStroke", t36.value4)

    UIStroke2.Color = t36.value1.Theme.Accent
    UIStroke2.Thickness = 1.5
    UIStroke2.Transparency = 0.3
    t36.value5 = Instance.new("ImageLabel", t36.value4)
    t36.value5.Size = UDim2.new(0.8, 0, 0.8, 0)
    t36.value5.Position = UDim2.new(0.1, 0, 0.1, 0)
    t36.value5.BackgroundTransparency = 1
    t36.value5.ScaleType = Enum.ScaleType.Fit
    Instance.new("UICorner", t36.value5).CornerRadius = UDim.new(1, 0)
    t36.value6 = Instance.new("TextLabel", t36.value5)
    t36.value6.Size = UDim2.new(1, 0, 1, 0)
    t36.value6.BackgroundTransparency = 1
    t36.value6.Text = "M"
    t36.value6.TextColor3 = Color3.new(1, 1, 1)
    t36.value6.Font = Enum.Font.GothamBold
    t36.value6.TextSize = 16
    t36.value6.ZIndex = 2

    local TextButton = Instance.new("TextButton", t36.value4)

    TextButton.Size = UDim2.new(1, 0, 1, 0)
    TextButton.BackgroundTransparency = 1
    TextButton.Text = ""
    TextButton.ZIndex = 10

    function MakeDraggable(p291, p292, p293)
        local UserInputService = game:GetService("UserInputService")
        local u1312
        local u1313
        local inputPosition
        local p291Position
        local n14 = 0
        p292.InputBegan:Connect(function(input)
            local v1586 = input.UserInputType == Enum.UserInputType.MouseButton1

            if not v1586 then
                v1586 = input.UserInputType == Enum.UserInputType.Touch
            end

            if v1586 then
                u1312 = true
                inputPosition = input.Position
                p291Position = p291.Position
                n14 = 0
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        u1312 = false

                        if n14 < 5 and p293 then
                            p293()
                        end
                    end
                end)
            end
        end)
        p292.InputChanged:Connect(function(input)
            local v1588 = input.UserInputType == Enum.UserInputType.MouseMovement

            if not v1588 then
                v1588 = input.UserInputType == Enum.UserInputType.Touch
            end

            if v1588 then
                u1313 = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == u1313 and u1312 then
                local v1590 = input.Position - inputPosition

                n14 += v1590.Magnitude
                p291.Position = UDim2.new(p291Position.X.Scale, p291Position.X.Offset + v1590.X, p291Position.Y.Scale, p291Position.Y.Offset + v1590.Y)
            end
        end)
    end

    MakeDraggable(t36.value4, TextButton, function()
        t36.value3.Visible = true
        t36.value4.Visible = false
        t36.value1:SetTopHUDVisible(true)
    end)
    t36.value7 = Instance.new("Frame", t36.value3)
    t36.value7.Size = UDim2.new(0, v950.sidebarW, 1, 0)
    t36.value1.UI.Sidebar = t36.value7
    t36.value7.BackgroundColor3 = t36.value1.Theme.SidebarBg
    t36.value7.BackgroundTransparency = 0
    t36.value7.BorderSizePixel = 0
    t36.value8 = Instance.new("Frame", t36.value7)
    t36.value8.Size = UDim2.new(0, 20, 1, 0)
    t36.value8.Position = UDim2.new(1, -20, 0, 0)
    t36.value8.BackgroundColor3 = t36.value1.Theme.SidebarBg
    t36.value8.BorderSizePixel = 0
    t36.value9 = Instance.new("Frame", t36.value7)
    t36.value9.Size = UDim2.new(0, 1, 0.75, 0)
    t36.value9.Position = UDim2.new(1, 0, 0.125, 0)
    t36.value9.BackgroundColor3 = t36.value1.Theme.CardBorder
    t36.value9.BackgroundTransparency = 0.4
    t36.value9.BorderSizePixel = 0

    local Frame2 = Instance.new("Frame", t36.value7)

    Frame2.Size = UDim2.new(1, 0, 0, 65)
    Frame2.BackgroundTransparency = 1
    t36.value10 = Instance.new("ImageLabel", Frame2)
    t36.value10.Size = UDim2.new(0, 30, 0, 30)
    t36.value10.Position = UDim2.new(0, 12, 0, 14)
    t36.value10.BackgroundColor3 = t36.value1.Theme.Accent
    t36.value10.BackgroundTransparency = 0.5
    t36.value10.ScaleType = Enum.ScaleType.Fit
    Instance.new("UICorner", t36.value10).CornerRadius = UDim.new(0, 6)
    t36.value11 = Instance.new("TextLabel", t36.value10)
    t36.value11.Size = UDim2.new(1, 0, 1, 0)
    t36.value11.BackgroundTransparency = 1
    t36.value11.Text = "M"
    t36.value11.TextColor3 = Color3.new(1, 1, 1)
    t36.value11.Font = Enum.Font.GothamBold
    t36.value11.TextSize = 14
    t36.value11.ZIndex = 2
    task.spawn(function()
        local u1317 = false
        pcall(function()
            local v1591 = not u1317

            if v1591 then
                v1591 = isfile

                if v1591 then
                    v1591 = writefile and getcustomasset
                end
            end

            if v1591 then
                if not isfile("masterstrap_logo.png") then
                    local v1592 = game:HttpGet("https://media.discordapp.net/attachments/1465013576682180822/1489437156727324852/Untitled_image.png?ex=6a0d0ef2&is=6a0bbd72&hm=3026d8f0925c3c97d405d780bbc89630d6eabf3f16095967bf7c7ce7d19f1035&=&format=webp&quality=lossless&width=885&height=885")

                    if v1592 and #v1592 > 100 then
                        writefile("masterstrap_logo.png", v1592)
                    end
                end

                if isfile("masterstrap_logo.png") then
                    t36.value10.Image = getcustomasset("masterstrap_logo.png")
                    t36.value10.BackgroundTransparency = 1

                    if t36.value11 then
                        t36.value11:Destroy()
                    end

                    t36.value5.Image = getcustomasset("masterstrap_logo.png")
                    t36.value5.BackgroundTransparency = 1

                    if t36.value6 then
                        t36.value6:Destroy()
                    end

                    u1317 = true
                end
            end
        end)
        pcall(function()
            local v1593 = not u1317

            if v1593 then
                v1593 = isfile

                if v1593 then
                    v1593 = writefile and getsynasset
                end
            end

            if v1593 and isfile("masterstrap_logo.png") then
                t36.value10.Image = getsynasset("masterstrap_logo.png")
                t36.value10.BackgroundTransparency = 1

                if t36.value11 then
                    t36.value11:Destroy()
                end

                t36.value5.Image = getsynasset("masterstrap_logo.png")
                t36.value5.BackgroundTransparency = 1

                if t36.value6 then
                    t36.value6:Destroy()
                end

                u1317 = true
            end
        end)
        if not u1317 then
            pcall(function()
                t36.value10.Image = "rbxthumb://type=Asset&id=103107746630945&w=150&h=150"
                t36.value10.BackgroundTransparency = 1

                if t36.value11 then
                    t36.value11:Destroy()
                end

                t36.value5.Image = "rbxthumb://type=Asset&id=103107746630945&w=150&h=150"
                t36.value5.BackgroundTransparency = 1

                if t36.value6 then
                    t36.value6:Destroy()
                end

                u1317 = true
            end)
        end
        if not u1317 then
            pcall(function()
                t36.value10.Image = "rbxassetid://103107746630945"
                t36.value10.BackgroundTransparency = 1

                if t36.value11 then
                    t36.value11:Destroy()
                end

                t36.value5.Image = "rbxassetid://103107746630945"
                t36.value5.BackgroundTransparency = 1

                if t36.value6 then
                    t36.value6:Destroy()
                end
            end)
        end
    end)
    t36.value12 = Instance.new("TextLabel", Frame2)
    t36.value12.Size = UDim2.new(1, -54, 0, 22)
    t36.value12.Position = UDim2.new(0, 48, 0, 14)
    t36.value12.Text = "Masterstrap"
    t36.value12.TextColor3 = t36.value1.Theme.Text
    t36.value12.Font = Enum.Font.GothamBlack
    t36.value12.TextSize = 14
    t36.value12.BackgroundTransparency = 1
    t36.value12.TextXAlignment = Enum.TextXAlignment.Left
    t36.value13 = Instance.new("TextLabel", Frame2)
    t36.value13.Size = UDim2.new(1, -54, 0, 14)
    t36.value13.Position = UDim2.new(0, 48, 0, 36)
    t36.value13.Text = "v3.0 · Mobile"
    t36.value13.TextColor3 = t36.value1.Theme.Muted
    t36.value13.Font = Enum.Font.Gotham
    t36.value13.TextSize = 10
    t36.value13.BackgroundTransparency = 1
    t36.value13.TextXAlignment = Enum.TextXAlignment.Left
    t36.value14 = Instance.new("ScrollingFrame", t36.value7)
    t36.value14.Name = "TabMenuScroll"
    t36.value14.Size = UDim2.new(1, -14, 1, -230)
    t36.value14.Position = UDim2.new(0, 7, 0, 106)
    t36.value14.BackgroundTransparency = 1
    t36.value14.BorderSizePixel = 0
    t36.value1:ApplyScrollBarStyle(t36.value14, 5)
    t36.value14.ScrollingDirection = Enum.ScrollingDirection.Y
    t36.value14.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    t36.value14.CanvasSize = UDim2.new(0, 0, 0, 0)
    t36.value14.ClipsDescendants = true
    t36.value14.ScrollingEnabled = true
    t36.value1.UI.TabScroll = t36.value14
    t36.value15 = Instance.new("Frame", t36.value14)
    t36.value15.Name = "TabListInner"
    t36.value15.Size = UDim2.new(1, -4, 0, 0)
    t36.value15.BackgroundTransparency = 1
    t36.value16 = Instance.new("UIListLayout", t36.value15)
    t36.value16.Padding = UDim.new(0, 3)
    t36.value16.SortOrder = Enum.SortOrder.LayoutOrder
    t36.value16:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local AbsoluteContentSizeY = t36.value16.AbsoluteContentSize.Y

        if AbsoluteContentSizeY < 1 then
            return
        end

        t36.value15.Size = UDim2.new(1, -4, 0, AbsoluteContentSizeY)
        t36.value14.CanvasSize = UDim2.new(0, 0, 0, AbsoluteContentSizeY + 8)
    end)
    t36.value17 = Instance.new("TextButton", t36.value7)
    t36.value17.Size = UDim2.new(0.82, 0, 0, 36)
    t36.value17.Position = UDim2.new(0.09, 0, 1, -88)
    t36.value17.BackgroundColor3 = t36.value1.Theme.Accent
    t36.value17.Text = ""
    Instance.new("UICorner", t36.value17).CornerRadius = UDim.new(0, 8)

    local UIGradient2 = Instance.new("UIGradient", t36.value17)

    UIGradient2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, t36.value1.Theme.Accent),
		ColorSequenceKeypoint.new(1, t36.value1.Theme.AccentAlt)
	})
    UIGradient2.Rotation = 90
    t36.value18 = Instance.new("TextLabel", t36.value17)
    t36.value18.Size = UDim2.new(1, 0, 1, 0)
    t36.value18.BackgroundTransparency = 1
    t36.value18.Text = "INJECT ALL"
    t36.value18.TextColor3 = Color3.new(1, 1, 1)
    t36.value18.Font = Enum.Font.GothamBold
    t36.value18.TextSize = 12
    t36.value18.Interactable = false
    t36.value1.UI.InjectBtn = t36.value17
    t36.value1.UI.InjectBg = t36.value17
    t36.value1.UI.InjectText = t36.value18
    t36.value19 = Instance.new("TextButton", t36.value7)
    t36.value19.Size = UDim2.new(0.82, 0, 0, 36)
    t36.value19.Position = UDim2.new(0.09, 0, 1, -48)
    t36.value19.BackgroundColor3 = t36.value1.Theme.ToggleOff
    t36.value19.Text = "REJOIN"
    t36.value19.TextColor3 = t36.value1.Theme.Text
    t36.value19.Font = Enum.Font.GothamBold
    t36.value19.TextSize = 12
    Instance.new("UICorner", t36.value19).CornerRadius = UDim.new(0, 8)

    local UIStroke3 = Instance.new("UIStroke", t36.value19)

    UIStroke3.Color = t36.value1.Theme.CardBorder
    UIStroke3.Thickness = 1
    UIStroke3.Transparency = 0.2
    t36.value1.UI.RejoinBtn = t36.value19
    t36.value19.MouseButton1Click:Connect(function()
        t36.value1:RejoinSameServer()
    end)
    t36.value20 = Instance.new("Frame", t36.value3)

    local sidebarW = v950.sidebarW

    t36.value20.Size = UDim2.new(1, -(sidebarW + 15), 1, -(v950.contentBottom or 85))
    t36.value20.Position = UDim2.new(0, sidebarW + 8, 0, v950.contentTop)
    t36.value20.BackgroundTransparency = 1
    t36.value1.UI.Content = t36.value20
    t36.value21 = Instance.new("Frame", t36.value3)
    t36.value21.Size = UDim2.new(1, -sidebarW, 0, 54)
    t36.value21.Position = UDim2.new(0, sidebarW, 0, 0)
    t36.value1.UI.Header = t36.value21
    t36.value21.BackgroundTransparency = 1
    t36.value21.Active = true
    MakeDraggable(t36.value3, t36.value21)

    local Frame3 = Instance.new("Frame", t36.value21)

    Frame3.Size = UDim2.new(1, -20, 0, 1)
    Frame3.Position = UDim2.new(0, 10, 1, -1)
    Frame3.BackgroundColor3 = t36.value1.Theme.CardBorder
    Frame3.BackgroundTransparency = 0.5
    Frame3.BorderSizePixel = 0
    t36.value22 = Instance.new("TextLabel", t36.value21)
    t36.value22.Size = UDim2.new(0, 280, 1, 0)
    t36.value22.Position = UDim2.new(0, 18, 0, 0)
    t36.value22.Text = "Dashboard"
    t36.value22.TextColor3 = t36.value1.Theme.Text
    t36.value22.Font = Enum.Font.GothamBold
    t36.value22.TextSize = 18
    t36.value22.TextXAlignment = Enum.TextXAlignment.Left
    t36.value22.BackgroundTransparency = 1
    t36.value1.PageSearchQuery = {}
    t36.value1.PageFilterActive = {}
    t36.value1.PageUIElements = {}
    t36.value23 = {
		Dashboard = "rbxassetid://8992031167",
		Integrations = "rbxassetid://8992031246",
		Mods = "rbxassetid://8992030918",
		Optimizer = "rbxassetid://8992253678",
		["Engine Settings"] = "rbxassetid://8992031056",
		Appearance = "rbxassetid://8992253933",
		Presets = "rbxassetid://8992253511",
		About = "rbxassetid://8992238178"
	}

    local function v966(p294, p295)
        if not p294 then
            return
        end

        if p295 then
            p294.AnchorPoint = Vector2.new(0.5, 0.5)
            p294.Position = UDim2.new(0.5, 0, 0.5, 0)
            p294.Size = UDim2.new(0, 16, 0, 16)

            return
        end

        p294.AnchorPoint = Vector2.new(0, 0.5)
        p294.Position = UDim2.new(0, 9, 0.5, 0)
        p294.Size = UDim2.new(0, 14, 0, 14)
    end

    function t36.value24(p296, p297)
        if not p296 then
            return
        end

        p296.Visible = not p297

        if p297 then
            return
        end

        p296.AnchorPoint = Vector2.new(0, 0.5)
        p296.Position = UDim2.new(0, 28, 0.5, 0)
        p296.Size = UDim2.new(1, -34, 0, 14)
        p296.TextYAlignment = Enum.TextYAlignment.Center
    end

    t36.value25 = false

    local function v967(p298)
        local TextButton2 = Instance.new("TextButton", t36.value15)

        TextButton2.Size = UDim2.new(1, 0, 0, 30)
        TextButton2.BackgroundColor3 = t36.value1.Theme.TabActiveBg
        TextButton2.BackgroundTransparency = 1
        TextButton2.Text = ""
        Instance.new("UICorner", TextButton2).CornerRadius = UDim.new(0, 6)

        local ImageLabel = Instance.new("ImageLabel", TextButton2)

        ImageLabel.Name = "TabIcon"
        ImageLabel.BackgroundTransparency = 1

        local v1335 = t36.value23[p298]

        if not v1335 then
            v1335 = ""
        end

        ImageLabel.Image = v1335
        ImageLabel.ScaleType = Enum.ScaleType.Fit

        if not not ImageLabel then
            ImageLabel.AnchorPoint = Vector2.new(0, 0.5)
            ImageLabel.Position = UDim2.new(0, 9, 0.5, 0)
            ImageLabel.Size = UDim2.new(0, 14, 0, 14)
        end

        if not not ImageLabel then
            local v1336 = false

            if not v1336 then
                v1336 = t36.value1.Theme.Muted
            end

            ImageLabel.ImageColor3 = v1336
            ImageLabel.ImageTransparency = 0.2
        end

        local TextLabel = Instance.new("TextLabel", TextButton2)

        TextLabel.Text = p298
        TextLabel.TextColor3 = t36.value1.Theme.Muted
        TextLabel.Font = Enum.Font.Gotham
        TextLabel.TextSize = 11
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
        t36.value24(TextLabel, false)

        local Frame4 = Instance.new("Frame", TextButton2)

        Frame4.Size = UDim2.new(0, 3, 0.5, 0)
        Frame4.Position = UDim2.new(0, 0, 0.25, 0)
        Frame4.BackgroundColor3 = t36.value1.Theme.TabActiveBar
        Frame4.Visible = false
        Frame4.BorderSizePixel = 0
        Instance.new("UICorner", Frame4).CornerRadius = UDim.new(1, 0)
        TextButton2.MouseButton1Click:Connect(function()
            for _, v in pairs(t36.value1.UI.Tabs) do
                v.Page.Visible = false

                if v then
                    v.BtnLabel.TextColor3 = t36.value1.Theme.Muted

                    local BtnIcon = v.BtnIcon

                    if not not BtnIcon then
                        local v1597 = false

                        if not v1597 then
                            v1597 = t36.value1.Theme.Muted
                        end

                        BtnIcon.ImageColor3 = v1597
                        BtnIcon.ImageTransparency = 0.2
                    end

                    v.Btn.BackgroundTransparency = 1
                    v.Bar.Visible = false
                end
            end

            t36.value1.UI.Tabs[p298].Page.Visible = true

            local v1598 = t36.value1.UI.Tabs[p298]

            if v1598 then
                v1598.BtnLabel.TextColor3 = t36.value1.Theme.Text

                local BtnIcon = v1598.BtnIcon

                if not not BtnIcon then
                    local ThemeText = t36.value1.Theme.Text

                    if not ThemeText then
                        ThemeText = t36.value1.Theme.Muted
                    end

                    BtnIcon.ImageColor3 = ThemeText
                    BtnIcon.ImageTransparency = 0
                end

                v1598.Btn.BackgroundColor3 = t36.value1.Theme.TabActiveBg
                v1598.Btn.BackgroundTransparency = 0.08
                v1598.Bar.Visible = true
            end

            t36.value22.Text = p298
        end)

        local ScrollingFrame = Instance.new("ScrollingFrame", t36.value20)

        ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
        ScrollingFrame.BackgroundTransparency = 1
        ScrollingFrame.Visible = false
        t36.value1:ApplyScrollBarStyle(ScrollingFrame, 3)
        ScrollingFrame.ClipsDescendants = true
        ScrollingFrame.BorderSizePixel = 0

        local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)

        UIListLayout.Padding = UDim.new(0, 6)
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local n15 = 0
            local n16 = 0

            for _, child in ipairs(ScrollingFrame:GetChildren()) do
                if child:IsA("GuiObject") and child.Visible then
                    n16 += 1
                    n15 += child.Size.Y.Offset
                end
            end

            local PaddingOffset = UIListLayout.Padding.Offset
            local v1606 = n15 + math.max(0, n16 - 1) * PaddingOffset + 20

            ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, v1606)
        end)
        t36.value1.UI.Tabs[p298] = {
			Btn = TextButton2,
			Page = ScrollingFrame,
			Bar = Frame4,
			BtnLabel = TextLabel,
			BtnIcon = ImageLabel
		}
    end

    v967("Dashboard")
    v967("Integrations")
    v967("Mods")
    v967("Optimizer")
    v967("Engine Settings")
    v967("Appearance")
    v967("Presets")
    v967("About")
    t36.value26 = Instance.new("Frame", t36.value3)
    t36.value26.Size = UDim2.new(1, -(sidebarW + 13), 0, v950.logBottom)
    t36.value26.Position = UDim2.new(0, sidebarW + 5, 1, -(v950.logBottom + 2))
    t36.value1.UI.LogBg = t36.value26
    t36.value26.BackgroundColor3 = t36.value1.Theme.SidebarBg
    t36.value26.BackgroundTransparency = 0.3
    t36.value26.BorderSizePixel = 0

    local TextLabel = Instance.new("TextLabel", t36.value26)

    TextLabel.Size = UDim2.new(1, -16, 1, 0)
    TextLabel.Position = UDim2.new(0, 8, 0, 0)
    TextLabel.Text = "> System Status: Ready"
    TextLabel.TextColor3 = t36.value1.Theme.Terminal
    TextLabel.TextSize = 10
    TextLabel.Font = Enum.Font.RobotoMono
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundTransparency = 1
    t36.value1.UI.LogLabel = TextLabel
    t36.value27 = Instance.new("Frame", t36.value7)
    t36.value27.Size = UDim2.new(1, -14, 0, 28)
    t36.value27.Position = UDim2.new(0, 7, 0, 70)
    t36.value27.BackgroundColor3 = t36.value1.Theme.Card
    t36.value27.BorderSizePixel = 0
    Instance.new("UICorner", t36.value27).CornerRadius = UDim.new(0, 6)

    local UIStroke4 = Instance.new("UIStroke", t36.value27)

    UIStroke4.Color = t36.value1.Theme.CardBorder
    UIStroke4.Thickness = 1
    UIStroke4.Transparency = 0.5
    t36.value28 = Instance.new("TextBox", t36.value27)
    t36.value28.Size = UDim2.new(1, -10, 1, 0)
    t36.value28.Position = UDim2.new(0, 5, 0, 0)
    t36.value28.BackgroundColor3 = Color3.new(0, 0, 0)
    t36.value28.BackgroundTransparency = 1
    t36.value28.Text = ""
    t36.value28.PlaceholderText = "Search flags..."
    t36.value28.PlaceholderColor3 = t36.value1.Theme.Muted
    t36.value28.TextColor3 = t36.value1.Theme.Text
    t36.value28.Font = Enum.Font.Gotham
    t36.value28.TextSize = 10
    t36.value28.ClearTextOnFocus = false
    t36.value29 = Instance.new("TextButton", t36.value7)
    t36.value29.Size = UDim2.new(0, 20, 0, 20)
    t36.value29.Position = UDim2.new(1, -25, 0, 15)
    t36.value29.BackgroundColor3 = t36.value1.Theme.Card
    t36.value29.BackgroundTransparency = 0.2
    t36.value29.Text = "<"
    t36.value29.TextColor3 = t36.value1.Theme.Text
    t36.value29.Font = Enum.Font.GothamBold
    t36.value29.TextSize = 10
    Instance.new("UICorner", t36.value29).CornerRadius = UDim.new(1, 0)

    local UIStroke5 = Instance.new("UIStroke", t36.value29)

    UIStroke5.Color = t36.value1.Theme.CardBorder
    UIStroke5.Thickness = 1
    UIStroke5.Transparency = 0.4

    local function v971(p299)
        t36.value25 = p299

        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local v1343 = not p299 and 170 or 54
        local v1344 = p299 and -69 or -185
        local v1345 = not p299 and 178 or 62
        local v1346 = not p299 and 170 or 54
        local v1347 = p299 and -54 or -170
        local v1348 = not p299 and 175 or 59
        local v1349 = not p299 and -178 or -62

        game:GetService("TweenService"):Create(t36.value7, tweenInfo, {
			Size = UDim2.new(0, v1343, 1, 0)
		}):Play()

        local TweenService = game:GetService("TweenService")
        local value8 = t36.value8
        local v1352 = p299

        if p299 then
            v1352 = UDim2.new(0, 0, 1, 0)
        end

        if not v1352 then
            v1352 = UDim2.new(0, 20, 1, 0)
        end

        local v1353 = p299

        if p299 then
            v1353 = UDim2.new(1, 0, 0, 0)
        end

        if not v1353 then
            v1353 = UDim2.new(1, -20, 0, 0)
        end

        TweenService:Create(value8, tweenInfo, {
			Size = v1352,
			Position = v1353
		}):Play()
        game:GetService("TweenService"):Create(t36.value9, tweenInfo, {
			Position = UDim2.new(1, not p299 and 0 or -1, 0.125, 0)
		}):Play()

        local TweenService2 = game:GetService("TweenService")
        local value20 = t36.value20
        local uDim2 = UDim2.new(1, v1344, 1, -85)
        local uDim2_2 = UDim2.new(0, v1345, 0, 58)

        TweenService2:Create(value20, tweenInfo, {
			Size = uDim2,
			Position = uDim2_2
		}):Play()

        local TweenService3 = game:GetService("TweenService")
        local value21 = t36.value21
        local uDim2_3 = UDim2.new(1, v1347, 0, 54)
        local Create = TweenService3.Create
        local uDim2_4 = UDim2.new(0, v1346, 0, 0)

        Create(TweenService3, value21, tweenInfo, {
			Size = uDim2_3,
			Position = uDim2_4
		}):Play()

        local TweenService4 = game:GetService("TweenService")
        local value26 = t36.value26
        local new = UDim2.new
        local Create2 = TweenService4.Create
        local v1367 = new(1, v1349, 0, 24)
        local uDim2_5 = UDim2.new(0, v1348, 1, -28)

        Create2(TweenService4, value26, tweenInfo, {
			Size = v1367,
			Position = uDim2_5
		}):Play()
        game:GetService("TweenService"):Create(t36.value12, tweenInfo, {
			TextTransparency = not p299 and 0 or 1
		}):Play()
        game:GetService("TweenService"):Create(t36.value13, tweenInfo, {
			TextTransparency = not p299 and 0 or 1
		}):Play()
        t36.value29.Text = not p299 and "<" or ">"

        local TweenService5 = game:GetService("TweenService")
        local value29 = t36.value29
        local v1371 = p299

        if p299 then
            v1371 = UDim2.new(0.5, -10, 0, 15)
        end

        if not v1371 then
            v1371 = UDim2.new(1, -25, 0, 15)
        end

        TweenService5:Create(value29, tweenInfo, {
			Position = v1371
		}):Play()

        local TweenService6 = game:GetService("TweenService")
        local value27 = t36.value27
        local v1374 = p299

        if p299 then
            v1374 = UDim2.new(0, 0, 0, 0)
        end

        if not v1374 then
            v1374 = UDim2.new(1, -14, 0, 28)
        end

        local v1375 = p299

        if p299 then
            v1375 = UDim2.new(0, 27, 0, 70)
        end

        if not v1375 then
            v1375 = UDim2.new(0, 7, 0, 70)
        end

        TweenService6:Create(value27, tweenInfo, {
			Size = v1374,
			Position = v1375
		}):Play()
        t36.value27.Visible = not p299

        local TweenService7 = game:GetService("TweenService")
        local value14 = t36.value14
        local v1378 = p299

        if p299 then
            v1378 = UDim2.new(0, 36, 1, -195)
        end

        if not v1378 then
            v1378 = UDim2.new(1, -14, 1, -230)
        end

        local v1379 = p299

        if p299 then
            v1379 = UDim2.new(0, 9, 0, 72)
        end

        if not v1379 then
            v1379 = UDim2.new(0, 7, 0, 106)
        end

        TweenService7:Create(value14, tweenInfo, {
			Size = v1378,
			Position = v1379
		}):Play()

        for _, v in pairs(t36.value1.UI.Tabs) do
            local TweenService8 = game:GetService("TweenService")
            local Btn = v.Btn
            local v1384 = p299

            if p299 then
                v1384 = UDim2.new(0, 36, 0, 30)
            end

            if not v1384 then
                v1384 = UDim2.new(1, 0, 0, 30)
            end

            TweenService8:Create(Btn, tweenInfo, {
				Size = v1384
			}):Play()
            t36.value24(v.BtnLabel, p299)
            v966(v.BtnIcon, p299)
        end

        local TweenService9 = game:GetService("TweenService")
        local value17 = t36.value17
        local v1387 = p299

        if p299 then
            v1387 = UDim2.new(0, 36, 0, 36)
        end

        if not v1387 then
            v1387 = UDim2.new(0.82, 0, 0, 36)
        end

        local v1388 = p299

        if p299 then
            v1388 = UDim2.new(0, 9, 1, -88)
        end

        if not v1388 then
            v1388 = UDim2.new(0.09, 0, 1, -88)
        end

        TweenService9:Create(value17, tweenInfo, {
			Size = v1387,
			Position = v1388
		}):Play()
        t36.value18.Text = not p299 and "INJECT ALL" or "INJ"
        t36.value18.TextSize = not p299 and 12 or 9

        local TweenService10 = game:GetService("TweenService")
        local value19 = t36.value19
        local v1391 = p299

        if p299 then
            v1391 = UDim2.new(0, 36, 0, 36)
        end

        if not v1391 then
            v1391 = UDim2.new(0.82, 0, 0, 36)
        end

        local v1392 = p299

        if p299 then
            v1392 = UDim2.new(0, 9, 1, -48)
        end

        if not v1392 then
            v1392 = UDim2.new(0.09, 0, 1, -48)
        end

        TweenService10:Create(value19, tweenInfo, {
			Size = v1391,
			Position = v1392
		}):Play()
        t36.value19.Text = not p299 and "REJOIN" or "RE"
        t36.value19.TextSize = not p299 and 12 or 9
    end

    t36.value29.MouseButton1Click:Connect(function()
        v971(not t36.value25)
    end)

    local TextButton3 = Instance.new("TextButton", t36.value21)

    TextButton3.Size = UDim2.new(0, 24, 0, 24)
    TextButton3.Position = UDim2.new(1, -34, 0, 15)
    TextButton3.BackgroundColor3 = t36.value1.Theme.Red
    TextButton3.BackgroundTransparency = 0.15
    TextButton3.Text = "X"
    TextButton3.TextColor3 = Color3.new(1, 1, 1)
    TextButton3.Font = Enum.Font.GothamBold
    TextButton3.TextSize = 10
    Instance.new("UICorner", TextButton3).CornerRadius = UDim.new(1, 0)

    local TextButton4 = Instance.new("TextButton", t36.value21)

    TextButton4.Size = UDim2.new(0, 24, 0, 24)
    TextButton4.Position = UDim2.new(1, -64, 0, 15)
    TextButton4.BackgroundColor3 = t36.value1.Theme.CardBorder
    TextButton4.BackgroundTransparency = 0.3
    TextButton4.Text = "-"
    TextButton4.TextColor3 = t36.value1.Theme.Muted
    TextButton4.Font = Enum.Font.GothamBold
    TextButton4.TextSize = 14
    Instance.new("UICorner", TextButton4).CornerRadius = UDim.new(1, 0)
    TextButton4.MouseButton1Click:Connect(function()
        t36.value3.Visible = false
        t36.value4.Visible = true
        t36.value1:SetTopHUDVisible(false)
    end)
    TextButton3.MouseButton1Click:Connect(function()
        t36.value1:StopStretchResolution()
        t36.value1:Shutdown()
    end)
    t36.value17.MouseButton1Click:Connect(function()
        t36.value1:InjectAll()
    end)

    local Page = t36.value1.UI.Tabs.Dashboard.Page

    Page.ScrollingEnabled = true
    t36.value30 = Instance.new("Frame", Page)
    t36.value30.Size = UDim2.new(0.98, 0, 0, 100)
    t36.value30.BackgroundTransparency = 1

    local UIGridLayout = Instance.new("UIGridLayout", t36.value30)

    UIGridLayout.CellSize = UDim2.new(0.485, 0, 0, 44)
    UIGridLayout.CellPadding = UDim2.new(0.03, 0, 0.12, 0)

    local function v976(p300, p301, p302)
        local Frame5 = Instance.new("Frame", t36.value30)
        Frame5.BackgroundColor3 = t36.value1.Theme.Card
        Instance.new("UICorner", Frame5).CornerRadius = UDim.new(0, 8)
        local UIStroke6 = Instance.new("UIStroke", Frame5)
        UIStroke6.Color = t36.value1.Theme.CardBorder
        UIStroke6.Thickness = 1
        UIStroke6.Transparency = 0.6
        local TextLabel3 = Instance.new("TextLabel", Frame5)
        TextLabel3.Size = UDim2.new(1, -20, 0.45, 0)
        TextLabel3.Position = UDim2.new(0, 10, 0, 4)
        TextLabel3.Text = p300
        TextLabel3.TextColor3 = t36.value1.Theme.Muted
        TextLabel3.Font = Enum.Font.Gotham
        TextLabel3.TextSize = 10
        TextLabel3.BackgroundTransparency = 1
        TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
        local TextLabel4 = Instance.new("TextLabel", Frame5)
        TextLabel4.Size = UDim2.new(1, -20, 0.55, 0)
        TextLabel4.Position = UDim2.new(0, 10, 0.4, 0)
        TextLabel4.Text = p301
        TextLabel4.TextColor3 = t36.value1.Theme.Text
        TextLabel4.Font = Enum.Font.GothamBold
        TextLabel4.TextSize = 12
        TextLabel4.BackgroundTransparency = 1
        TextLabel4.TextXAlignment = Enum.TextXAlignment.Left
        local Frame6
        if p302 then
            TextLabel4.Position = UDim2.new(0, 24, 0.4, 0)
            Frame6 = Instance.new("Frame", Frame5)
            Frame6.Size = UDim2.new(0, 8, 0, 8)
            Frame6.Position = UDim2.new(0, 10, 0.4, 4)
            Frame6.BackgroundColor3 = t36.value1.Theme.Red
            Instance.new("UICorner", Frame6).CornerRadius = UDim.new(1, 0)
        end

        return TextLabel4, Frame6
    end

    t36.value31 = v976("MEMORY USAGE", "0.00 MB")
    t36.value32 = v976("CURRENT PING", "0 ms")
    t36.value33 = v976("ACTIVE FLAGS", "0")

    local v977, v978 = v976("REAL-TIME FPS", "0.0 FPS", true)

    t35.value1 = v977
    t35.value2 = v978
    t36.value34 = t35.value1
    t36.value35 = t35.value2

    local Frame7 = Instance.new("Frame", Page)

    Frame7.Size = UDim2.new(0.98, 0, 0, 200)
    Frame7.Position = UDim2.new(0.01, 0, 0, 108)
    Frame7.BackgroundColor3 = t36.value1.Theme.Card
    Instance.new("UICorner", Frame7).CornerRadius = UDim.new(0, 8)

    local UIStroke7 = Instance.new("UIStroke", Frame7)

    UIStroke7.Color = t36.value1.Theme.CardBorder
    UIStroke7.Thickness = 1
    UIStroke7.Transparency = 0.5

    local TextLabel5 = Instance.new("TextLabel", Frame7)

    TextLabel5.Size = UDim2.new(1, -20, 0, 24)
    TextLabel5.Position = UDim2.new(0, 10, 0, 4)
    TextLabel5.Text = "DIAGNOSTICS CONSOLE"
    TextLabel5.TextColor3 = t36.value1.Theme.Muted
    TextLabel5.Font = Enum.Font.GothamBold
    TextLabel5.TextSize = 10
    TextLabel5.BackgroundTransparency = 1
    TextLabel5.TextXAlignment = Enum.TextXAlignment.Left
    t36.value36 = Instance.new("ScrollingFrame", Frame7)
    t36.value36.Size = UDim2.new(1, -12, 1, -36)
    t36.value36.Position = UDim2.new(0, 6, 0, 28)
    t36.value36.BackgroundColor3 = t36.value1.Theme.SidebarBg
    t36.value36.BackgroundTransparency = 0.5
    t36.value1:ApplyScrollBarStyle(t36.value36, 3)
    Instance.new("UICorner", t36.value36).CornerRadius = UDim.new(0, 6)
    t36.value37 = Instance.new("UIListLayout", t36.value36)
    t36.value37.Padding = UDim.new(0, 2)
    t36.value38 = t36.value1.Log
    t36.value39 = {}

    local function v982(p303)
        if not t36.value36 then
            return
        end

        for match in tostring(p303):gmatch("[^\r\n]+") do
            local TextLabel6 = Instance.new("TextLabel", t36.value36)

            TextLabel6.Size = UDim2.new(1, -8, 0, 14)
            TextLabel6.BackgroundTransparency = 1
            TextLabel6.Text = " " .. match
            TextLabel6.TextColor3 = t36.value1.Theme.Terminal
            TextLabel6.Font = Enum.Font.RobotoMono
            TextLabel6.TextSize = 9
            TextLabel6.TextXAlignment = Enum.TextXAlignment.Left
            table.insert(t36.value39, TextLabel6)

            if #t36.value39 > 50 then
                t36.value39[1]:Destroy()
                table.remove(t36.value39, 1)
            end
        end

        t36.value36.CanvasSize = UDim2.new(0, 0, 0, t36.value37.AbsoluteContentSize.Y + 10)
        t36.value36.CanvasPosition = Vector2.new(0, (math.max(0, t36.value36.CanvasSize.Y.Offset - t36.value36.AbsoluteSize.Y)))
    end

    function t36.value1.Log(p304, p305)
        local IsQuietLog = p304.IsQuietLog

        if IsQuietLog then
            IsQuietLog = p304:IsQuietLog(p305)
        end

        if IsQuietLog then
            return
        end

        t36.value38(p304, p305)
        pcall(function()
            v982(p305)
        end)
    end

    t36.value40 = 60
    t36.value41 = 0

    local elapsed = os.clock()

    t36.value42 = nil
    t36.value42 = elapsed
    pcall(function()
        t36.value1:TrackConnection(game:GetService("RunService").RenderStepped:Connect(function()
            t36.value41 = t36.value41 + 1

            local elapsed2 = os.clock()

            if elapsed2 - t36.value42 >= 1 then
                t36.value40 = t36.value41 / (elapsed2 - t36.value42)
                t36.value42 = elapsed2
            end
        end))
    end)
    task.spawn(function()
        while true do
            local IsRunning = t36.value1.System.IsRunning

            if IsRunning then
                IsRunning = task.wait(1)
            end

            if not IsRunning then
                break
            end

            pcall(function()
                local v1608 = gcinfo()
                t36.value31.Text = string.format("%.2f MB", v1608 / 1024)
                local Network = game:GetService("Stats"):FindFirstChild("Network")
                local Value
                if Network then
                    local ServerStatsItem = Network:FindFirstChild("ServerStatsItem")

                    if ServerStatsItem then
                        ServerStatsItem = Network.ServerStatsItem:FindFirstChild("Ping")
                    end

                    if ServerStatsItem then
                        Value = ServerStatsItem:GetValue()
                    end
                end
                if not Value then
                    local ok, result = pcall(function()
                        return game:GetService("Players").LocalPlayer:GetNetworkPing() * 1000
                    end)

                    if ok and result then
                        Value = result
                    end
                end
                if Value then
                    t36.value32.Text = string.format("%.1f ms", Value)
                else
                    t36.value32.Text = "Detecting..."
                end
                local n17 = 0
                for _ in pairs(t36.value1.ActiveFlags) do
                    n17 += 1
                end
                t36.value33.Text = tostring(n17)
                local v1616 = t36.value40 > 0 and t36.value40
                local value34 = t36.value34
                local v1618 = v1616 or 60
                value34.Text = string.format("%.1f FPS", v1618)
                if v1618 >= 60 then
                    t36.value35.BackgroundColor3 = t36.value1.Theme.Green

                    return
                end
                if v1618 >= 30 then
                    t36.value35.BackgroundColor3 = Color3.fromRGB(241, 196, 15)

                    return
                end
                t36.value35.BackgroundColor3 = t36.value1.Theme.Red
            end)
        end
    end)
    t36.value43 = {
		"Integrations",
		"Mods",
		"Optimizer",
		"Engine Settings",
		"Appearance"
	}

    for _, v in ipairs(t36.value43) do
        t36.value1.PageUIElements[v] = {}
        t36.value1.PageSearchQuery[v] = ""
        t36.value1.PageFilterActive[v] = false
    end

    function t36.value44(p306)
        local v1409 = p306:lower()
        local t37 = {}
        local v1411 = v1409 ~= ""
        local v1412, v1413, v1414 = ipairs(t36.value43)
        local g1432
        while true do
            local v1415

            v1414, v1415 = v1412(v1413, v1414)

            if not v1414 then
                break
            end

            t37[v1415] = 0
        end
        for v1418, v1419 in ipairs(t36.value43) do

            if t36.value1.PageUIElements[v1419] then
                for _, v in ipairs(t36.value1.PageUIElements[v1419]) do
                    local v1422 = v.name:lower():find(v1409) or v.flag:lower():find(v1409) ~= nil

                    v.Card.Visible = v1422

                    if v1422 then
                        t37[v1419] = t37[v1419] + 1
                    end
                end
            end
        end
        for _, v in ipairs(t36.value43) do
            local v1425 = t36.value1.UI.Tabs[v]

            if v1425 then
                local v1426 = true

                if v1411 then
                    v1426 = t37[v] > 0
                end

                v1425.Btn.Visible = v1426
            end
        end
        local v1427
        local v1428, v1429, v1430 = pairs(t36.value1.UI.Tabs)
        repeat
            local v1431

            v1430, v1431 = v1428(v1429, v1430)

            if not v1430 then
                g1432 = true
            end

            if g1432 then
                break
            end
        until v1431.Page.Visible
        if not g1432 then
            v1427 = v1430
        end
        if v1427 then
            local v1433 = t36.value1.UI.Tabs[v1427]

            if v1433 then
                v1433 = not t36.value1.UI.Tabs[v1427].Btn.Visible
            end

            v1427 = v1433
        end
        if v1427 then
            local s5 = "Dashboard"

            for _, v in ipairs({
				"Dashboard",
				"Integrations",
				"Mods",
				"Optimizer",
				"Engine Settings",
				"Appearance",
				"Presets",
				"About"
			}) do
                local v1437 = t36.value1.UI.Tabs[v]

                if v1437 then
                    v1437 = t36.value1.UI.Tabs[v].Btn.Visible
                end

                if v1437 then
                    s5 = v

                    break
                end
            end

            pcall(function()
                local v1619 = t36.value1.UI.Tabs[s5]

                if v1619 then
                    for _, v in pairs(t36.value1.UI.Tabs) do
                        v.Page.Visible = false

                        if v then
                            v.BtnLabel.TextColor3 = t36.value1.Theme.Muted

                            local BtnIcon = v.BtnIcon

                            if not not BtnIcon then
                                local v1623 = false

                                if not v1623 then
                                    v1623 = t36.value1.Theme.Muted
                                end

                                BtnIcon.ImageColor3 = v1623
                                BtnIcon.ImageTransparency = 0.2
                            end

                            v.Btn.BackgroundTransparency = 1
                            v.Bar.Visible = false
                        end
                    end

                    v1619.Page.Visible = true

                    if v1619 then
                        v1619.BtnLabel.TextColor3 = t36.value1.Theme.Text

                        local BtnIcon = v1619.BtnIcon

                        if not not BtnIcon then
                            local ThemeText = t36.value1.Theme.Text

                            if not ThemeText then
                                ThemeText = t36.value1.Theme.Muted
                            end

                            BtnIcon.ImageColor3 = ThemeText
                            BtnIcon.ImageTransparency = 0
                        end

                        v1619.Btn.BackgroundColor3 = t36.value1.Theme.TabActiveBg
                        v1619.Btn.BackgroundTransparency = 0.08
                        v1619.Bar.Visible = true
                    end

                    t36.value22.Text = s5
                end
            end)
        end
    end

    t36.value28:GetPropertyChangedSignal("Text"):Connect(function()
        t36.value44(t36.value28.Text)
    end)

    local Dashboard = t36.value1.UI.Tabs.Dashboard

    if Dashboard then
        Dashboard.BtnLabel.TextColor3 = t36.value1.Theme.Text

        local BtnIcon = Dashboard.BtnIcon

        if not not BtnIcon then
            local ThemeText = t36.value1.Theme.Text

            if not ThemeText then
                ThemeText = t36.value1.Theme.Muted
            end

            BtnIcon.ImageColor3 = ThemeText
            BtnIcon.ImageTransparency = 0
        end

        Dashboard.Btn.BackgroundColor3 = t36.value1.Theme.TabActiveBg
        Dashboard.Btn.BackgroundTransparency = 0.08
        Dashboard.Bar.Visible = true
    end

    t36.value1.UI.Tabs.Dashboard.Page.Visible = true
    t36.value1.UI.ScreenGui = t36.value2
    t36.value1.UI.Main = t36.value3
    t36.value1.UI.MiniBar = t36.value4
    t36.value1.UI.SizeConstraint = UISizeConstraint
    t36.value1.UI.RootUIScale = UIScale

    local CurrentCamera = workspace.CurrentCamera

    if CurrentCamera then
        local value1 = t36.value1
        local GetPropertyChangedSignal = CurrentCamera.GetPropertyChangedSignal
        local TrackConnection = value1.TrackConnection

        function t35.value3()
            t36.value1:ApplyMobileUILayout()
        end

        TrackConnection(value1, GetPropertyChangedSignal(CurrentCamera, "ViewportSize"):Connect(t35.value3))
    end
end
function t2.value21.BuildTopHUD(p307)
    local ScreenGui = Instance.new("ScreenGui")

    ScreenGui.Name = game:GetService("HttpService"):GenerateGUID(false)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 100
    ScreenGui.IgnoreGuiInset = true
    pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)

    if not ScreenGui.Parent then
        ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    p307.UI.TopHUD = ScreenGui

    local Frame = Instance.new("Frame", ScreenGui)

    Frame.Size = UDim2.new(0, 210, 0, 28)
    Frame.Position = UDim2.new(1, -220, 0, 4)
    Frame.BackgroundColor3 = p307.Theme.SidebarBg
    Frame.BackgroundTransparency = 0.2
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local UIStroke = Instance.new("UIStroke", Frame)

    UIStroke.Color = p307.Theme.CardBorder
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.4

    local TextLabel = Instance.new("TextLabel", Frame)

    TextLabel.Size = UDim2.new(0, 45, 1, 0)
    TextLabel.Position = UDim2.new(0, 8, 0, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = "FPS: --"
    TextLabel.TextColor3 = p307.Theme.Green
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = 10
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left

    local TextLabel7 = Instance.new("TextLabel", Frame)

    TextLabel7.Size = UDim2.new(0, 52, 1, 0)
    TextLabel7.Position = UDim2.new(0, 56, 0, 0)
    TextLabel7.BackgroundTransparency = 1
    TextLabel7.Text = "Ping: --"
    TextLabel7.TextColor3 = p307.Theme.Text
    TextLabel7.Font = Enum.Font.GothamBold
    TextLabel7.TextSize = 10
    TextLabel7.TextXAlignment = Enum.TextXAlignment.Left

    local TextLabel8 = Instance.new("TextLabel", Frame)

    TextLabel8.Size = UDim2.new(0, 48, 1, 0)
    TextLabel8.Position = UDim2.new(0, 112, 0, 0)
    TextLabel8.BackgroundTransparency = 1
    TextLabel8.Text = "👤 --/--"
    TextLabel8.TextColor3 = p307.Theme.Text
    TextLabel8.Font = Enum.Font.GothamBold
    TextLabel8.TextSize = 10
    TextLabel8.TextXAlignment = Enum.TextXAlignment.Left

    local TextButton = Instance.new("TextButton", Frame)

    TextButton.Size = UDim2.new(0, 44, 1, 0)
    TextButton.Position = UDim2.new(1, -50, 0, 0)
    TextButton.BackgroundTransparency = 1
    TextButton.Text = "Detecting"
    TextButton.TextColor3 = p307.Theme.Terminal
    TextButton.Font = Enum.Font.GothamBold
    TextButton.TextSize = 10
    TextButton.TextXAlignment = Enum.TextXAlignment.Right

    local Frame8 = Instance.new("Frame", ScreenGui)

    Frame8.Size = UDim2.new(0, 210, 0, 200)
    Frame8.Position = UDim2.new(1, -220, 0, 34)
    Frame8.BackgroundColor3 = p307.Theme.MainBg
    Frame8.BackgroundTransparency = 0.05
    Frame8.Visible = false
    Instance.new("UICorner", Frame8).CornerRadius = UDim.new(0, 8)

    local UIStroke8 = Instance.new("UIStroke", Frame8)

    UIStroke8.Color = p307.Theme.CardBorder
    UIStroke8.Thickness = 1
    UIStroke8.Transparency = 0.3

    local ScrollingFrame = Instance.new("ScrollingFrame", Frame8)

    ScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
    ScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
    ScrollingFrame.BackgroundTransparency = 1
    p307:ApplyScrollBarStyle(ScrollingFrame, 3)

    local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)

    UIListLayout.Padding = UDim.new(0, 4)

    local t38 = { TextButton.MouseButton1Click:Connect(function()
        Frame8.Visible = not Frame8.Visible

        if Frame8.Visible and true then
            for _, child in ipairs(ScrollingFrame:GetChildren()) do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end

            local TextLabel9 = Instance.new("TextLabel", ScrollingFrame)

            TextLabel9.Size = UDim2.new(1, 0, 0, 30)
            TextLabel9.BackgroundTransparency = 1
            TextLabel9.Text = "Fetching servers..."
            TextLabel9.TextColor3 = Color3.new(1, 1, 1)
            TextLabel9.Font = Enum.Font.Gotham
            TextLabel9.TextSize = 12
            task.spawn(function()
                pcall(function()
                    local data = game:GetService("HttpService"):JSONDecode((game:HttpGet("https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?limit=100")))

                    TextLabel9:Destroy()

                    if data and data.data then
                        for _, v in ipairs(data.data) do
                            local v1706 = v
                            local playing = v1706.playing

                            if playing then
                                playing = v1706.maxPlayers

                                if playing then
                                    playing = v1706.playing < v1706.maxPlayers
                                end
                            end

                            if playing then
                                local Frame9 = Instance.new("Frame", ScrollingFrame)

                                Frame9.Size = UDim2.new(1, -5, 0, 32)
                                Frame9.BackgroundColor3 = p307.Theme.Card
                                Instance.new("UICorner", Frame9).CornerRadius = UDim.new(0, 6)

                                local UIStroke9 = Instance.new("UIStroke", Frame9)

                                UIStroke9.Color = p307.Theme.CardBorder
                                UIStroke9.Thickness = 1
                                UIStroke9.Transparency = 0.5

                                local TextLabel10 = Instance.new("TextLabel", Frame9)

                                TextLabel10.Size = UDim2.new(0.68, 0, 1, 0)
                                TextLabel10.Position = UDim2.new(0, 10, 0, 0)
                                TextLabel10.BackgroundTransparency = 1

                                local v1711 = tonumber(v1706.ping) or 999

                                TextLabel10.Text = tostring(v1706.playing) .. "/" .. tostring(v1706.maxPlayers) .. " · " .. tostring(v1711) .. "ms"
                                TextLabel10.TextColor3 = p307.Theme.Text
                                TextLabel10.Font = Enum.Font.Gotham
                                TextLabel10.TextSize = 10
                                TextLabel10.TextXAlignment = Enum.TextXAlignment.Left

                                local TextButton5 = Instance.new("TextButton", Frame9)

                                TextButton5.Size = UDim2.new(0, 55, 0, 22)
                                TextButton5.Position = UDim2.new(1, -60, 0.5, -11)
                                TextButton5.BackgroundColor3 = p307.Theme.Green
                                TextButton5.Text = "JOIN"
                                TextButton5.TextColor3 = Color3.new(1, 1, 1)
                                TextButton5.Font = Enum.Font.GothamBold
                                TextButton5.TextSize = 10
                                Instance.new("UICorner", TextButton5).CornerRadius = UDim.new(0, 5)
                                TextButton5.MouseButton1Click:Connect(function()
                                    TextButton5.Text = "..."
                                    p307:QueueAutoInjectOnTeleport()
                                    pcall(function()
                                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v1706.id, game.Players.LocalPlayer)
                                    end)
                                end)
                            end
                        end

                        ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
                    end
                end)
            end)
        end
    end) }

    p307:TrackConnection(v3(t38))

    local n18 = 0

    p307:TrackConnection(game:GetService("RunService").RenderStepped:Connect(function()
        n18 += 1
    end))
    task.spawn(function()
        local Stats = game:GetService("Stats")
        local Players = game:GetService("Players")

        while true do
            local IsRunning = p307.System.IsRunning

            if IsRunning then
                IsRunning = task.wait(1)
            end

            if not IsRunning then
                break
            end

            pcall(function()
                TextLabel.Text = "FPS: " .. tostring(n18)
                n18 = 0
            end)
            pcall(function()
                TextLabel7.Text = "Ping: " .. tostring((math.round((Stats.Network.ServerStatsItem["Data Ping"]:GetValue())))) .. "ms"
            end)
            pcall(function()
                TextLabel8.Text = "👤 " .. #Players:GetPlayers() .. "/" .. (Players.MaxPlayers or 0)
            end)
        end
    end)
    task.spawn(function()
        local u1444 = false
        pcall(function()
            local s6 = ""
            pcall(function()
                s6 = game:GetService("NetworkClient").MultiplayerConnection.Address:split(":")[1]
            end)
            if s6 ~= "" then
                local v1627 = game:HttpGet("http://ip-api.com/json/" .. s6)
                local data = game:GetService("HttpService"):JSONDecode(v1627)

                if data and data.countryCode then
                    local countryCode = data.countryCode
                    local s7 = "🌐"

                    if countryCode == "US" then
                        s7 = "🇺🇸"
                    elseif countryCode == "SG" then
                        s7 = "🇸🇬"
                    elseif countryCode == "JP" then
                        s7 = "🇯🇵"
                    elseif countryCode == "VN" then
                        s7 = "🇻🇳"
                    end

                    TextButton.Text = countryCode .. " " .. s7
                    u1444 = true
                end
            end
        end)
        if not u1444 then
            local Stats = game:GetService("Stats")

            while true do
                local IsRunning = p307.System.IsRunning

                if IsRunning then
                    IsRunning = task.wait(1)
                end

                if not IsRunning then
                    break
                end

                pcall(function()
                    local v1631 = math.round((Stats.Network.ServerStatsItem["Data Ping"]:GetValue()))
                    local s8 = "US"
                    local s9 = "🇺🇸"

                    if v1631 < 60 then
                        s8 = "SG"
                        s9 = "🇸🇬"
                    elseif v1631 >= 60 and v1631 < 140 then
                        s8 = "JP"
                        s9 = "🇯🇵"
                    end

                    TextButton.Text = s8 .. " " .. s9
                end)
            end
        end
    end)
end
function t2.value21.NextOptimizerLayoutOrder(p308)
    local System = p308.System

    System.optimizerLayoutSeq = (System.optimizerLayoutSeq or 0) + 1

    return System.optimizerLayoutSeq
end
function t2.value21.AddOptimizerSectionHeader(p309, p310, p311)
    local v1012 = p309.UI.Tabs[p310]

    if v1012 then
        v1012 = p309.UI.Tabs[p310].Page
    end

    if not v1012 then
        return
    end

    local MobileLayout = p309.MobileLayout

    if MobileLayout then
        MobileLayout = p309.MobileLayout.bodyText
    end

    local v1014 = MobileLayout or 11
    local v1015 = p311 or "Mode Presets"
    local Frame = Instance.new("Frame", v1012)

    Frame.Size = UDim2.new(0.98, 0, 0, 22)
    Frame.BackgroundTransparency = 1
    Frame.Name = "OptimizerPresetSectionHeader"
    Frame.LayoutOrder = p309:NextOptimizerLayoutOrder()

    local TextLabel = Instance.new("TextLabel", Frame)

    TextLabel.Size = UDim2.new(1, -8, 1, 0)
    TextLabel.Position = UDim2.new(0, 6, 0, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = v1015
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = v1014
    TextLabel.TextColor3 = Color3.new(1, 1, 1)
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left

    if p309.PageUIElements and p309.PageUIElements[p310] then
        table.insert(p309.PageUIElements[p310], {
			Card = Frame,
			name = v1015,
			flag = v1015,
			clean_name = v1015,
			isSection = true
		})
    end

    return Frame
end
function t2.value21.AddFlagUI(p312, p313, p314, p315, p316, p317)
    local v1024 = t2.value23(p316 or p314)

    if p317 then
        p312.Callbacks[v1024] = p317
    end

    if p312.ActiveFlags[v1024] == nil then
        local v1025 = p316

        if not v1025 then
            v1025 = p314
        end

        p312:SetFlagInternal(v1025, p315, true)
    end

    local v1026 = p312.ActiveFlags[v1024]
    local str = tostring(v1026 or "")
    local Page = p312.UI.Tabs[p313].Page
    local Frame = Instance.new("Frame", Page)
    local MobileLayout = p312.MobileLayout

    if MobileLayout then
        MobileLayout = p312.MobileLayout.flagCardH
    end

    local v1031 = MobileLayout or 44

    Frame.Size = UDim2.new(0.98, 0, 0, v1031)
    Frame.BackgroundColor3 = p312.Theme.Card
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local UIStroke = Instance.new("UIStroke", Frame)

    UIStroke.Color = p312.Theme.CardBorder
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.6

    if p313 == "Optimizer" then
        Frame.LayoutOrder = p312:NextOptimizerLayoutOrder()
    end

    local TextLabel = Instance.new("TextLabel", Frame)

    TextLabel.Size = UDim2.new(0.62, 0, 1, 0)
    TextLabel.Position = UDim2.new(0, 14, 0, 0)
    TextLabel.Text = p314
    TextLabel.TextColor3 = p312.Theme.Text
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Font = Enum.Font.Gotham

    local MobileLayout2 = p312.MobileLayout

    if MobileLayout2 then
        MobileLayout2 = p312.MobileLayout.bodyText
    end

    TextLabel.TextSize = MobileLayout2 or 11
    TextLabel.BackgroundTransparency = 1

    if not p312.UIRegistry[v1024] then
        p312.UIRegistry[v1024] = {}
    end

    local v1035 = v1024 == "TextureCompositorActiveJobs"
    local v1036 = v1035

    if not v1036 then
        v1036 = str == "True"

        if not v1036 then
            v1036 = str == "False"

            if not v1036 then
                v1036 = str == "true" or str == "false"
            end
        end

        if not v1036 then
            v1036 = tostring(p315 or ""):lower() == "true"

            if not v1036 then
                local v1037 = p315
                local _tostring = tostring

                if not p315 then
                    v1037 = ""
                end

                v1036 = _tostring(v1037):lower() == "false"
            end
        end
    end

    if v1036 then
        local TextButton = Instance.new("TextButton", Frame)

        TextButton.Size = UDim2.new(0, 44, 0, 22)
        TextButton.Position = UDim2.new(1, -58, 0.5, -11)

        local v1040 = if not v1035 then str:lower() == "true" else v1026 == 0 or v1026 == "0"
        local v1041 = v1040

        if v1040 then
            v1041 = p312.Theme.ToggleOn
        end

        if not v1041 then
            v1041 = p312.Theme.ToggleOff
        end

        TextButton.BackgroundColor3 = v1041
        TextButton.Text = ""
        Instance.new("UICorner", TextButton).CornerRadius = UDim.new(1, 0)

        local Frame10 = Instance.new("Frame", TextButton)

        Frame10.Size = UDim2.new(0, 18, 0, 18)

        if v1040 then
            v1040 = UDim2.new(1, -20, 0.5, -9)
        end

        if not v1040 then
            v1040 = UDim2.new(0, 2, 0.5, -9)
        end

        Frame10.Position = v1040
        Frame10.BackgroundColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", Frame10).CornerRadius = UDim.new(1, 0)
        table.insert(p312.UIRegistry[v1024], {
			Type = "Toggle",
			Bg = TextButton,
			Knob = Frame10
		})
        TextButton.MouseButton1Click:Connect(function()
            local v1447 = p312.ActiveFlags[v1024]
            local v1448 = if not v1035 then tostring(v1447):lower() ~= "true" and "True" or "False" else v1447 == 0 or (v1447 ~= "0" and 0 or 3)

            p312:SetFlag(p316 or p314, v1448)
        end)
    else
        local TextBox = Instance.new("TextBox", Frame)

        TextBox.Size = UDim2.new(0, 90, 0, 28)
        TextBox.Position = UDim2.new(1, -104, 0.5, -14)
        TextBox.BackgroundColor3 = p312.Theme.ToggleOff
        TextBox.Text = tostring(v1026 or "")
        TextBox.TextColor3 = p312.Theme.Accent
        TextBox.Font = Enum.Font.Gotham
        TextBox.TextSize = 11
        Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 6)

        local UIStroke10 = Instance.new("UIStroke", TextBox)

        UIStroke10.Color = p312.Theme.CardBorder
        UIStroke10.Thickness = 1
        UIStroke10.Transparency = 0.4
        table.insert(p312.UIRegistry[v1024], {
			Type = "Input",
			TextBox = TextBox
		})
        TextBox:GetPropertyChangedSignal("Text"):Connect(function()
            p312:SetFlag(p316 or p314, TextBox.Text, true)
        end)
    end

    local PageUIElements = p312.PageUIElements

    if PageUIElements then
        PageUIElements = p312.PageUIElements[p313]
    end

    if PageUIElements then
        local insert = table.insert
        local v1047 = p312.PageUIElements[p313]
        local v1048 = p316 or p314

        insert(v1047, {
			Card = Frame,
			name = p314,
			flag = v1048,
			clean_name = v1024,
			default_val = p315
		})
    end
end
function t2.value21.AddSliderUI(p318, p319, p320, p321, p322, p323, p324, p325)
    local v1057 = t2.value23(p324 or p320)

    if p325 then
        p318.Callbacks[v1057] = p325
    end

    if p318.ActiveFlags[v1057] == nil then
        p318:SetFlagInternal(p324 or p320, p321, true)
    end

    local v1058 = tonumber(p318.ActiveFlags[v1057]) or p321
    local Page = p318.UI.Tabs[p319].Page
    local Frame = Instance.new("Frame", Page)
    local MobileLayout = p318.MobileLayout

    if MobileLayout then
        MobileLayout = p318.MobileLayout.flagCardH
    end

    local v1062 = MobileLayout or 44

    Frame.Size = UDim2.new(0.98, 0, 0, v1062)
    Frame.BackgroundColor3 = p318.Theme.Card
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local UIStroke = Instance.new("UIStroke", Frame)

    UIStroke.Color = p318.Theme.CardBorder
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.6

    local TextLabel = Instance.new("TextLabel", Frame)

    TextLabel.Size = UDim2.new(0.48, 0, 1, 0)
    TextLabel.Position = UDim2.new(0, 14, 0, 0)
    TextLabel.Text = p320
    TextLabel.TextColor3 = p318.Theme.Text
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Font = Enum.Font.Gotham

    local MobileLayout3 = p318.MobileLayout

    if MobileLayout3 then
        MobileLayout3 = p318.MobileLayout.bodyText
    end

    TextLabel.TextSize = MobileLayout3 or 11
    TextLabel.BackgroundTransparency = 1

    if not p318.UIRegistry[v1057] then
        p318.UIRegistry[v1057] = {}
    end

    local TextButton = Instance.new("TextButton", Frame)

    TextButton.Size = UDim2.new(0, 110, 0, 6)
    TextButton.Position = UDim2.new(1, -164, 0.5, -3)
    TextButton.BackgroundColor3 = p318.Theme.ToggleOff
    TextButton.Text = ""
    Instance.new("UICorner", TextButton).CornerRadius = UDim.new(1, 0)

    local Frame11 = Instance.new("Frame", TextButton)

    Frame11.BackgroundColor3 = p318.Theme.Accent
    Instance.new("UICorner", Frame11).CornerRadius = UDim.new(1, 0)
    Instance.new("UIGradient", Frame11).Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 220))
	})

    local Frame12 = Instance.new("Frame", TextButton)

    Frame12.Size = UDim2.new(0, 12, 0, 12)
    Frame12.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame12.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Frame12).CornerRadius = UDim.new(1, 0)

    local UIStroke11 = Instance.new("UIStroke", Frame12)

    UIStroke11.Color = p318.Theme.CardBorder
    UIStroke11.Thickness = 1

    local TextLabel11 = Instance.new("TextLabel", Frame)

    TextLabel11.Size = UDim2.new(0, 42, 1, 0)
    TextLabel11.Position = UDim2.new(1, -48, 0, 0)
    TextLabel11.BackgroundTransparency = 1
    TextLabel11.TextColor3 = p318.Theme.Accent
    TextLabel11.Font = Enum.Font.GothamBold
    TextLabel11.TextSize = 10
    TextLabel11.TextXAlignment = Enum.TextXAlignment.Right

    local function v1071(p326)
        Frame11.Size = UDim2.new(p326, 0, 1, 0)
        Frame12.Position = UDim2.new(p326, 0, 0.5, 0)

        local round = math.round
        local v1451 = p326 * (p323 - p322)
        local v1452 = round(p322 + v1451)
        local v1453 = v1452 == 100

        if v1453 then
            v1453 = p320:lower():find("stretch")
        end

        if v1453 then
            TextLabel11.Text = "100%"

            return
        end

        TextLabel11.Text = tostring(v1452) .. "%"
    end

    local t39 = {
		Type = "Slider",
		LastValue = v1058
	}
    local u1073 = false

    local function v1074(p327)
        local AbsolutePositionX = TextButton.AbsolutePosition.X
        local AbsoluteSizeX = TextButton.AbsoluteSize.X

        if AbsoluteSizeX == 0 then
            return
        end

        local v1457 = math.round(math.clamp((p327.Position.X - AbsolutePositionX) / AbsoluteSizeX, 0, 1) * 100) / 100

        v1071(v1457)

        local v1458 = math.round(p322 + v1457 * (p323 - p322))

        t39.LastValue = v1458
        p318:SetFlag(p324 or p320, v1458)
    end

    TextButton.InputBegan:Connect(function(input)
        local v1460 = input.UserInputType == Enum.UserInputType.MouseButton1

        if not v1460 then
            v1460 = input.UserInputType == Enum.UserInputType.Touch
        end

        if v1460 then
            u1073 = true
            v1074(input)
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        local v1462 = u1073

        if v1462 then
            v1462 = input.UserInputType == Enum.UserInputType.MouseMovement

            if not v1462 then
                v1462 = input.UserInputType == Enum.UserInputType.Touch
            end
        end

        if v1462 then
            v1074(input)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        local v1464 = input.UserInputType == Enum.UserInputType.MouseButton1

        if not v1464 then
            v1464 = input.UserInputType == Enum.UserInputType.Touch
        end

        if not v1464 then
        end
    end)
    v1071((math.clamp((v1058 - p322) / (p323 - p322), 0, 1)))

    function t39.UpdateVisuals(p328)
        v1071(p328)
    end

    table.insert(p318.UIRegistry[v1057], t39)

    local PageUIElements = p318.PageUIElements

    if PageUIElements then
        PageUIElements = p318.PageUIElements[p319]
    end

    if PageUIElements then
        local insert = table.insert
        local v1077 = p318.PageUIElements[p319]
        local v1078 = p324 or p320

        insert(v1077, {
			Card = Frame,
			name = p320,
			flag = v1078,
			clean_name = v1057,
			default_val = p321
		})
    end
end
task.spawn(function()
    local v1079 = getgenv and getgenv()
    local v1080 = v1079

    if v1080 then
        v1080 = type(v1079.MasterstrapInstance) == "table"

        if v1080 then
            v1080 = v1079.MasterstrapInstance ~= t2.value21
        end
    end

    if v1080 then
        pcall(function()
            if type(v1079.MasterstrapInstance.Shutdown) == "function" then
                v1079.MasterstrapInstance:Shutdown()
            end
        end)
    end

    if v1079 then
        v1079.MasterstrapInstance = t2.value21
    end

    t2.value21:StopStretchResolution()
    t2.value21:LoadSettings()
    t2.value21:BuildUI()
    t2.value21:ApplyMobileUILayout(t2.value21.MobileLayout)
    t2.value21:BuildTopHUD()
    t2.value21:DetectCapabilities()
    t2.value21:SetupInjectLifecycle()
    t2.value21:InitializeHook(false)
    t2.value21:Log("[Engine] Inject engine initialized.")
    task.defer(function()
        local Page = t2.value21.UI.Tabs.About.Page
        Page.ScrollingEnabled = false
        local Frame = Instance.new("Frame", Page)
        Frame.Size = UDim2.new(0.96, 0, 0, 336)
        Frame.Position = UDim2.new(0.02, 0, 0, 10)
        Frame.BackgroundColor3 = t2.value21.Theme.Card
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
        local UIStroke = Instance.new("UIStroke", Frame)
        UIStroke.Color = t2.value21.Theme.CardBorder
        UIStroke.Thickness = 1
        UIStroke.Transparency = 0.4
        local TextLabel = Instance.new("TextLabel", Frame)
        TextLabel.Size = UDim2.new(1, -20, 0, 112)
        TextLabel.Position = UDim2.new(0, 10, 0, 12)
        TextLabel.Text = [[  __  __           _                 _                 
 |  \/  |         | |               | |                
 | \  / | __ _ ___| |_ ___ _ __ ___ | |_ _ __ __ _ _ __ 
 | |\/| |/ _` / __| __/ _ \ '__/ __|| __| '__/ _` | '_ \
 | |  | | (_| \__ \ ||  __/ |  \__ \| |_| | | (_| | |_) |
 |_|  |_|\__,_|___/\__\___|_|  |___/ \__|_|  \__,_| .__/
                                                  | |   
                                                  |_|   ]]
        TextLabel.TextColor3 = t2.value21.Theme.Accent
        TextLabel.Font = Enum.Font.RobotoMono
        TextLabel.TextSize = 10
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.TextYAlignment = Enum.TextYAlignment.Top
        local TextLabel12 = Instance.new("TextLabel", Frame)
        TextLabel12.Size = UDim2.new(1, -20, 0, 20)
        TextLabel12.Position = UDim2.new(0, 10, 0, 128)
        TextLabel12.Text = "Developed by: Dank1ngs"
        TextLabel12.TextColor3 = t2.value21.Theme.Muted
        TextLabel12.Font = Enum.Font.Gotham
        TextLabel12.TextSize = 11
        TextLabel12.BackgroundTransparency = 1
        TextLabel12.TextXAlignment = Enum.TextXAlignment.Left
        local TextLabel13 = Instance.new("TextLabel", Frame)
        TextLabel13.Size = UDim2.new(1, -20, 0, 20)
        TextLabel13.Position = UDim2.new(0, 10, 0, 150)
        TextLabel13.Text = "Website: masterstrap.org"
        TextLabel13.TextColor3 = t2.value21.Theme.Terminal
        TextLabel13.Font = Enum.Font.Gotham
        TextLabel13.TextSize = 11
        TextLabel13.BackgroundTransparency = 1
        TextLabel13.TextXAlignment = Enum.TextXAlignment.Left
        local TextLabel14 = Instance.new("TextLabel", Frame)
        TextLabel14.Size = UDim2.new(1, -20, 0, 20)
        TextLabel14.Position = UDim2.new(0, 10, 0, 172)
        TextLabel14.Text = "GitHub: https://github.com/Masterstrap/Mobilestrap"
        TextLabel14.TextColor3 = t2.value21.Theme.Terminal
        TextLabel14.Font = Enum.Font.Gotham
        TextLabel14.TextSize = 10
        TextLabel14.BackgroundTransparency = 1
        TextLabel14.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel14.TextWrapped = true
        local TextLabel15 = Instance.new("TextLabel", Frame)
        TextLabel15.Size = UDim2.new(1, -20, 0, 20)
        TextLabel15.Position = UDim2.new(0, 10, 0, 194)
        TextLabel15.Text = "Discord: https://discord.com/invite/masterstrap"
        TextLabel15.TextColor3 = t2.value21.Theme.Terminal
        TextLabel15.Font = Enum.Font.Gotham
        TextLabel15.TextSize = 10
        TextLabel15.BackgroundTransparency = 1
        TextLabel15.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel15.TextWrapped = true
        local TextLabel16 = Instance.new("TextLabel", Frame)
        TextLabel16.Size = UDim2.new(1, -20, 0, 22)
        TextLabel16.Position = UDim2.new(0, 10, 0, 216)
        TextLabel16.Text = "Join the Discord server to get free flags."
        TextLabel16.TextColor3 = t2.value21.Theme.Muted
        TextLabel16.Font = Enum.Font.Gotham
        TextLabel16.TextSize = 10
        TextLabel16.BackgroundTransparency = 1
        TextLabel16.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel16.TextWrapped = true
        local TextLabel17 = Instance.new("TextLabel", Frame)
        TextLabel17.Size = UDim2.new(1, -20, 0, 48)
        TextLabel17.Position = UDim2.new(0, 10, 0, 242)
        TextLabel17.Text = "Please continue to support me by following and starring this project so it stays free."
        TextLabel17.TextColor3 = t2.value21.Theme.Muted
        TextLabel17.Font = Enum.Font.Gotham
        TextLabel17.TextSize = 10
        TextLabel17.TextWrapped = true
        TextLabel17.BackgroundTransparency = 1
        TextLabel17.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel17.TextYAlignment = Enum.TextYAlignment.Top
        local TextButton = Instance.new("TextButton", Frame)
        TextButton.Size = UDim2.new(0.46, 0, 0, 32)
        TextButton.Position = UDim2.new(0.04, 0, 0, 294)
        TextButton.BackgroundColor3 = t2.value21.Theme.Accent
        TextButton.Text = "Copy Masterstrap"
        TextButton.TextColor3 = Color3.new(1, 1, 1)
        TextButton.Font = Enum.Font.GothamBold
        TextButton.TextSize = 10
        Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 8)
        TextButton.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard("https://masterstrap.org")
            elseif toclipboard then
                toclipboard("https://masterstrap.org")
            end

            t2.value21:Log("Masterstrap website copied!")
        end)
        local TextButton6 = Instance.new("TextButton", Frame)
        TextButton6.Size = UDim2.new(0.46, 0, 0, 32)
        TextButton6.Position = UDim2.new(0.5, 0, 0, 294)
        TextButton6.BackgroundColor3 = t2.value21.Theme.ToggleOff
        TextButton6.Text = "Copy Github"
        TextButton6.TextColor3 = t2.value21.Theme.Text
        TextButton6.Font = Enum.Font.GothamBold
        TextButton6.TextSize = 10
        Instance.new("UICorner", TextButton6).CornerRadius = UDim.new(0, 8)
        local UIStroke12 = Instance.new("UIStroke", TextButton6)
        UIStroke12.Color = t2.value21.Theme.CardBorder
        UIStroke12.Thickness = 1
        UIStroke12.Transparency = 0.3
        TextButton6.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard("https://github.com/Masterstrap/Mobilestrap")
            elseif toclipboard then
                toclipboard("https://github.com/Masterstrap/Mobilestrap")
            end

            t2.value21:Log("GitHub link copied!")
        end)
        local Page2 = t2.value21.UI.Tabs.Presets.Page
        local Frame13 = Instance.new("Frame", Page2)
        Frame13.Size = UDim2.new(0.98, 0, 0, 56)
        Frame13.BackgroundColor3 = t2.value21.Theme.Card
        Instance.new("UICorner", Frame13).CornerRadius = UDim.new(0, 8)
        local UIStroke13 = Instance.new("UIStroke", Frame13)
        UIStroke13.Color = t2.value21.Theme.CardBorder
        UIStroke13.Thickness = 1
        UIStroke13.Transparency = 0.5
        local TextBox = Instance.new("TextBox", Frame13)
        TextBox.Size = UDim2.new(0.68, 0, 0, 30)
        TextBox.Position = UDim2.new(0, 10, 0.5, -15)
        TextBox.BackgroundColor3 = t2.value21.Theme.ToggleOff
        TextBox.PlaceholderText = "Preset Name..."
        TextBox.PlaceholderColor3 = t2.value21.Theme.Muted
        TextBox.Text = ""
        TextBox.TextColor3 = t2.value21.Theme.Text
        TextBox.Font = Enum.Font.Gotham
        TextBox.TextSize = 11
        Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 6)
        local UIStroke14 = Instance.new("UIStroke", TextBox)
        UIStroke14.Color = t2.value21.Theme.CardBorder
        UIStroke14.Thickness = 1
        UIStroke14.Transparency = 0.4
        local TextButton7 = Instance.new("TextButton", Frame13)
        TextButton7.Size = UDim2.new(0.28, -10, 0, 30)
        TextButton7.Position = UDim2.new(0.72, 5, 0.5, -15)
        TextButton7.BackgroundColor3 = t2.value21.Theme.Accent
        TextButton7.Text = "SAVE"
        TextButton7.TextColor3 = Color3.new(1, 1, 1)
        TextButton7.Font = Enum.Font.GothamBold
        TextButton7.TextSize = 11
        Instance.new("UICorner", TextButton7).CornerRadius = UDim.new(0, 6)
        local Frame14 = Instance.new("Frame", Page2)
        Frame14.Size = UDim2.new(1, 0, 1, -70)
        Frame14.BackgroundTransparency = 1
        Instance.new("UIListLayout", Frame14).Padding = UDim.new(0, 6)
        local s10 = ""
        TextBox:GetPropertyChangedSignal("Text"):Connect(function()
            s10 = TextBox.Text
        end)
        local function u1487()
            pcall(function()
                for _, child in ipairs(Frame14:GetChildren()) do
                    if child:IsA("Frame") then
                        child:Destroy()
                    end
                end

                local n19 = 0

                for k, v in pairs(t2.value21.SavedPresets) do
                    local v1718 = v

                    n19 += 1

                    local Frame15 = Instance.new("Frame", Frame14)

                    Frame15.Size = UDim2.new(0.98, 0, 0, 38)
                    Frame15.BackgroundColor3 = t2.value21.Theme.Card
                    Instance.new("UICorner", Frame15).CornerRadius = UDim.new(0, 8)

                    local UIStroke15 = Instance.new("UIStroke", Frame15)

                    UIStroke15.Color = t2.value21.Theme.CardBorder
                    UIStroke15.Thickness = 1
                    UIStroke15.Transparency = 0.6

                    local TextLabel18 = Instance.new("TextLabel", Frame15)

                    TextLabel18.Size = UDim2.new(0.55, 0, 1, 0)
                    TextLabel18.Position = UDim2.new(0, 12, 0, 0)
                    TextLabel18.Text = k
                    TextLabel18.TextColor3 = t2.value21.Theme.Text
                    TextLabel18.Font = Enum.Font.Gotham
                    TextLabel18.TextSize = 11
                    TextLabel18.BackgroundTransparency = 1
                    TextLabel18.TextXAlignment = Enum.TextXAlignment.Left

                    local TextButton8 = Instance.new("TextButton", Frame15)

                    TextButton8.Size = UDim2.new(0, 55, 0, 24)
                    TextButton8.Position = UDim2.new(1, -120, 0.5, -12)
                    TextButton8.BackgroundColor3 = t2.value21.Theme.Accent
                    TextButton8.Text = "LOAD"
                    TextButton8.TextColor3 = Color3.new(1, 1, 1)
                    TextButton8.Font = Enum.Font.GothamBold
                    TextButton8.TextSize = 10
                    Instance.new("UICorner", TextButton8).CornerRadius = UDim.new(0, 5)

                    local TextButton9 = Instance.new("TextButton", Frame15)

                    TextButton9.Size = UDim2.new(0, 55, 0, 24)
                    TextButton9.Position = UDim2.new(1, -60, 0.5, -12)
                    TextButton9.BackgroundColor3 = t2.value21.Theme.Red
                    TextButton9.BackgroundTransparency = 0.15
                    TextButton9.Text = "DEL"
                    TextButton9.TextColor3 = Color3.new(1, 1, 1)
                    TextButton9.Font = Enum.Font.GothamBold
                    TextButton9.TextSize = 10
                    Instance.new("UICorner", TextButton9).CornerRadius = UDim.new(0, 5)
                    TextButton8.MouseButton1Click:Connect(function()
                        t2.value21.LastUsedPreset = k
                        for v1755, v1756 in pairs(v1718) do

                            local v1757 = t2.value23(v1755)

                            if not t2.value21:IsOptimizerEphemeralFlag(v1757) then
                                t2.value21:SetFlagInternal(v1755, v1756)
                                t2.value21:RefreshUIVisuals(v1757)
                            end
                        end
                        t2.value21:StripEphemeralOptimizerFlags()
                        for k2 in pairs(t2.value71) do
                            t2.value21:RefreshUIVisuals(k2)
                        end
                        t2.value21:FinalizeOptimizerTab()
                        t2.value21:SaveToDisk()
                        t2.value21:Log("Preset '" .. k .. "' Loaded & Synced")
                    end)
                    TextButton9.MouseButton1Click:Connect(function()
                        t2.value21.SavedPresets[k] = nil

                        if t2.value21.LastUsedPreset == k then
                            t2.value21.LastUsedPreset = nil
                        end

                        t2.value21:SaveToDisk()
                        u1487()
                    end)
                end

                local v1724 = n19 * 38 + math.max(0, n19 - 1) * 6

                Frame14.Size = UDim2.new(1, 0, 0, v1724)
            end)
        end
        TextButton7.MouseButton1Click:Connect(function()
            TextBox:ReleaseFocus()
            local TextBoxText = TextBox.Text
            if not TextBoxText then
                TextBoxText = s10 or ""
            end
            local v1637 = TextBoxText:match("^%s*(.-)%s*$")
            if v1637 == "" then
                t2.value21:Log("Error: Name required")

                return
            end
            local v1638 = t2.value21:CapturePresetConfig()
            t2.value21.SavedPresets[v1637] = v1638
            t2.value21.LastUsedPreset = v1637
            local v1639 = t2.value21:SaveToDisk()
            TextBox.Text = ""
            u1487()
            local n20 = 0
            for v1643 in pairs(v1638) do

                n20 += 1
            end
            if v1639 then
                t2.value21:Log("Preset '" .. v1637 .. "' Saved & Tracked (" .. n20 .. " flags)")

                return
            end
            t2.value21:Log("Save Error: preset not written to disk/cloud")
        end)
        u1487()
        local Page3 = t2.value21.UI.Tabs.Integrations.Page
        local v1489 = t2.value21.MobileLayout or t2.value74()
        local v1490 = v1489.customCardH or 160
        local v1491 = v1489.btnH or 30
        local v1492 = v1489.bodyText or 11
        local Frame16 = Instance.new("Frame", Page3)
        Frame16.Size = UDim2.new(0.98, 0, 0, v1490)
        Frame16.BackgroundColor3 = t2.value21.Theme.Card
        Frame16.ClipsDescendants = true
        Instance.new("UICorner", Frame16).CornerRadius = UDim.new(0, 8)
        local UIStroke16 = Instance.new("UIStroke", Frame16)
        UIStroke16.Color = t2.value21.Theme.CardBorder
        UIStroke16.Thickness = 1
        UIStroke16.Transparency = 0.5
        t2.value21.UI.CustomCard = Frame16
        local TextBox2 = Instance.new("TextBox", Frame16)
        TextBox2.Size = UDim2.new(1, -16, 1, -(v1491 + 18))
        TextBox2.Position = UDim2.new(0, 8, 0, 6)
        TextBox2.BackgroundColor3 = t2.value21.Theme.ToggleOff
        TextBox2.Text = t2.value21.CustomBoxData or ""
        TextBox2.PlaceholderText = "Paste flags JSON here..."
        TextBox2.PlaceholderColor3 = t2.value21.Theme.Muted
        TextBox2.TextColor3 = t2.value21.Theme.Terminal
        TextBox2.Font = Enum.Font.RobotoMono
        TextBox2.TextSize = v1492
        TextBox2.ClearTextOnFocus = false
        TextBox2.MultiLine = true
        TextBox2.TextWrapped = true
        TextBox2.TextXAlignment = Enum.TextXAlignment.Left
        TextBox2.TextYAlignment = Enum.TextYAlignment.Top
        Instance.new("UICorner", TextBox2).CornerRadius = UDim.new(0, 6)
        local UIStroke17 = Instance.new("UIStroke", TextBox2)
        UIStroke17.Color = t2.value21.Theme.CardBorder
        UIStroke17.Thickness = 1
        UIStroke17.Transparency = 0.4
        t2.value21.UI.CustomInput = TextBox2
        local TextButton10 = Instance.new("TextButton", Frame16)
        TextButton10.Size = UDim2.new(0.46, 0, 0, v1491)
        TextButton10.Position = UDim2.new(0.04, 0, 1, -(v1491 + 6))
        TextButton10.BackgroundColor3 = t2.value21.Theme.ToggleOff
        TextButton10.Text = "RESET FFLAG"
        TextButton10.TextColor3 = t2.value21.Theme.Text
        TextButton10.Font = Enum.Font.GothamBold
        TextButton10.TextSize = v1492
        Instance.new("UICorner", TextButton10).CornerRadius = UDim.new(0, 6)
        local UIStroke18 = Instance.new("UIStroke", TextButton10)
        UIStroke18.Color = t2.value21.Theme.Red
        UIStroke18.Thickness = 1
        UIStroke18.Transparency = 0.35
        TextButton10.MouseButton1Click:Connect(function()
            TextBox2.Text = ""
            t2.value21.ActiveFlags._CustomBox = ""
            t2.value21.CustomBoxData = ""
            t2.value21.InjectCatalog = {}
            t2.value21:PurgeInjectBloat()
            t2.value21:SaveToDisk()
            t2.value21:Log("Custom flags cleared.")
        end)
        local TextButton11 = Instance.new("TextButton", Frame16)
        TextButton11.Size = UDim2.new(0.46, 0, 0, v1491)
        TextButton11.Position = UDim2.new(0.5, 0, 1, -(v1491 + 6))
        TextButton11.BackgroundColor3 = t2.value21.Theme.Accent
        TextButton11.Text = "APPLY CUSTOM"
        TextButton11.TextColor3 = Color3.new(1, 1, 1)
        TextButton11.Font = Enum.Font.GothamBold
        TextButton11.TextSize = v1492
        Instance.new("UICorner", TextButton11).CornerRadius = UDim.new(0, 6)
        TextButton11.MouseButton1Click:Connect(function()
            local TextBox2Text = TextBox2.Text

            t2.value21.ActiveFlags._CustomBox = TextBox2Text
            t2.value21.CustomBoxData = TextBox2Text
            t2.value21:SaveToDisk()
            task.spawn(function()
                local n21 = 0

                t2.value21:Log("Registry Syncing...")

                for match, v1727 in TextBox2Text:gmatch("\"(.-)\"%s*:%s*\"(.-)\"") do
                    local v1728 = match
                    local v1729 = t2.value23(v1728)

                    if t2.value21.UIRegistry[v1729] then
                        t2.value21:SetFlagInternal(v1728, v1727)
                        t2.value21:RefreshUIVisuals(v1729)
                        n21 += 1
                    end
                end

                for match, v1731 in TextBox2Text:gmatch("\"(.-)\"%s*:%s*(%d+)") do
                    local v1732 = match
                    local v1733 = t2.value23(v1732)

                    if t2.value21.UIRegistry[v1733] then
                        local value21 = t2.value21
                        local t40 = { tonumber(v1731) }

                        value21:SetFlagInternal(v1732, v3(t40))
                        t2.value21:RefreshUIVisuals(v1733)
                        n21 += 1
                    end
                end

                t2.value21:Log("UI Sync Complete: " .. n21 .. " Flags Matched")
            end)
        end)
        t2.value21:MigrateOptimizerFlags()
        t2.value21.System.optimizerLayoutSeq = 0
        t2.value21:AddFlagUI("Optimizer", "NO TEXTURE", "False", "NoTexturesEnable", function(p329)
            if p329 then
                t2.value21:EnableNoTextures(false)
                t2.value21:Log("NO TEXTURE enabled (SmoothPlastic).")

                return
            end

            t2.value21:DisableNoTextures()
            t2.value21:Log("NO TEXTURE disabled (materials restored).")
        end)
        t2.value21:AddFlagUI("Optimizer", "No Meshes", "False", "NoMeshesEnable", function(p330)
            if p330 then
                t2.value21:EnableNoMeshes(false)
                t2.value21:Log("No Meshes enabled.")

                return
            end

            t2.value21:DisableNoMeshes()
            t2.value21:Log("No Meshes disabled.")
        end)
        t2.value21:AddFlagUI("Optimizer", "Vulkan Renderer", "False", "OptimizerVulkanEnable", function(p331)
            if p331 then
                t2.value21:EnableVulkanRenderer(false)
                t2.value21:Log("Vulkan renderer (Luau) enabled.")

                return
            end

            t2.value21:DisableVulkanRenderer()
            t2.value21:Log("Vulkan renderer (Luau) disabled.")
        end)
        t2.value21:AddFlagUI("Optimizer", "Prefer Vulkan (FFlag)", "False", "FFlagDebugGraphicsPreferVulkan", function(p332)
            t2.value21:SetFlagInternal("FFlagDebugGraphicsPreferVulkan", not p332 and "False" or "True", true)
            t2.value21:Log(not p332 and "Prefer Vulkan (FFlag) disabled." or "Prefer Vulkan (FFlag) enabled.")
        end)
        t2.value21:AddFlagUI("Optimizer", "FPS Unlock (Unlimited)", "False", "OptimizerFpsUnlock", function(p333)
            t2.value21:ApplyOptimizerFpsUnlock(p333)

            local value21 = t2.value21

            if p333 then
                p333 = "FPS unlock enabled."
            end

            value21:Log(p333 or "FPS cap restored.")
        end)
        t2.value21:AddFlagUI("Optimizer", "Low-Texture Sky", "False", "OptimizerLowSkyEnable", function(p334)
            if p334 then
                t2.value21:EnableLowTextureSky(false)
                t2.value21:Log("No-Texture Sky enabled.")

                return
            end

            t2.value21:DisableLowTextureSky()
            t2.value21:Log("No-Texture Sky disabled.")
        end)
        t2.value21:AddFlagUI("Optimizer", "Gray Sky (No Effects)", "False", "OptimizerGraySkyEnable", function(p335)
            if p335 then
                t2.value21:EnableGraySky(false)
                t2.value21:Log("Gray Sky: FULL FOG OFF + fast sky strip.")

                return
            end

            t2.value21:DisableGraySky()
            t2.value21:Log("Gray Sky disabled.")
        end)
        t2.value21:AddFlagUI("Optimizer", "Remove Lights & Particles", "False", "OptimizerNoLightsParticlesEnable", function(p336)
            if p336 then
                t2.value21:EnableNoLightsParticles(false)
                t2.value21:Log("Lights & particles off (batched, low lag).")

                return
            end

            t2.value21:DisableNoLightsParticles()
            t2.value21:Log("Strip stopped (effects not restored).")
        end)
        t2.value21:AddFlagUI("Optimizer", "Optimize Terrain & Water", "False", "OptimizerTerrainWaterEnable", function(p337)
            if p337 then
                t2.value21:EnableTerrainWaterOptimize(false)
                t2.value21:Log("Terrain & water on (FFlag + batched).")

                return
            end

            t2.value21:DisableTerrainWaterOptimize()
            t2.value21:Log("Terrain & water off (terrain restored).")
        end)
        t2.value21:AddOptimizerSectionHeader("Optimizer", "Boost FPS")
        t2.value21:AddFlagUI("Optimizer", "FPS BOOST", "False", "OptimizerMegaFpsBoost", function(p338)
            t2.value21:ApplyOptimizerMegaFpsBoost(p338)

            local value21 = t2.value21

            if p338 then
                p338 = "FPS BOOST on (L1, shadow off, post-fx off)."
            end

            value21:Log(p338 or "FPS BOOST off.")
        end)
        t2.value21:AddFlagUI("Optimizer", "ANTI LAG", "False", "OptimizerMegaAntiLag", function(p339)
            t2.value21:ApplyOptimizerMegaAntiLag(p339)

            local value21 = t2.value21

            if p339 then
                p339 = "ANTI LAG on (particles auto-catch)."
            end

            value21:Log(p339 or "ANTI LAG off.")
        end)
        t2.value21:AddFlagUI("Optimizer", "ANTI FREEZE", "False", "OptimizerMegaAntiFreeze", function(p340)
            t2.value21:ApplyOptimizerMegaAntiFreeze(p340)

            local value21 = t2.value21

            if p340 then
                p340 = "ANTI FREEZE on (GC + streaming)."
            end

            value21:Log(p340 or "ANTI FREEZE off.")
        end)
        t2.value21:AddOptimizerSectionHeader("Optimizer", "Mode Presets")
        t2.value21:AddFlagUI("Optimizer", "Ultra Mode", "False", "OptimizerUltraMode", function(p341)
            t2.value21:ApplyOptimizerPresetUltra(p341)

            local value21 = t2.value21

            if p341 then
                p341 = "Ultra Mode enabled."
            end

            value21:Log(p341 or "Ultra Mode disabled.")
        end)
        t2.value21:AddFlagUI("Optimizer", "Mega Boost", "False", "OptimizerMegaBoost", function(p342)
            t2.value21:ApplyOptimizerPresetMega(p342)

            local value21 = t2.value21

            if p342 then
                p342 = "Mega Boost enabled."
            end

            value21:Log(p342 or "Mega Boost disabled.")
        end)
        t2.value21:AddFlagUI("Optimizer", "Potato Mode", "False", "OptimizerPotatoMode", function(p343)
            t2.value21:ApplyOptimizerPresetPotato(p343)

            local value21 = t2.value21

            if p343 then
                p343 = "Potato Mode enabled."
            end

            value21:Log(p343 or "Potato Mode disabled.")
        end)
        t2.value21:FinalizeOptimizerTab()
        t2.value21:SetupVisualStripLifecycle()
        for _, v in ipairs({
			{
				"Gray Sky",
				"False",
				"FFlagDebugSkyGray"
			},
			{
				"Old Oof Sound",
				"False",
				"FFlagEnableOldDeathSound"
			},
			{
				"Display FPS",
				"False",
				"FFlagDebugDisplayFPS"
			}
		}) do
            local v1502 = t2.value23(v[3])

            if t2.value21.ActiveFlags[v1502] == nil then
                t2.value21:SetFlagInternal(v[3], v[2])
            end

            t2.value21:AddFlagUI("Mods", v[1], v[2], v[3])
        end
        t2.value21:SetFlagInternal("DesyncToggle", "True")
        t2.value21:AddFlagUI("Mods", "Desync", "True", "DesyncToggle", function(p344)
            if p344 then
                t2.value21:SetFlagInternal("DFIntDataSenderRate", 37860)
                t2.value21:SetFlagInternal("DFIntS2PhysicsSenderRate", 38760)
                t2.value21:SetFlagInternal("DFIntDataSenderMaxBandwidthBps", 100000000)

                return
            end

            t2.value21:SetFlagInternal("DFIntDataSenderRate", nil)
            t2.value21:SetFlagInternal("DFIntS2PhysicsSenderRate", 15)
            t2.value21:SetFlagInternal("DFIntDataSenderMaxBandwidthBps", nil)
        end)
        for _, v in ipairs({
			{
				"Graphic 10 Bypass",
				1,
				"DFIntDebugFRMQualityLevelOverride"
			},
			{
				"Shadow Intensity",
				0,
				"FIntRenderShadowIntensity"
			},
			{
				"Disable Shadows",
				"True",
				"FFlagDebugForceDisableShadows"
			},
			{
				"Disable Particles",
				"True",
				"FFlagDebugDisableParticles"
			},
			{
				"Disable Grass",
				0,
				"FintRenderGrassHeightScaler"
			},
			{
				"Force Voxel",
				"True",
				"DFFlagDebugRenderForceTechnologyVoxel"
			},
			{
				"SkipMips (Manager)",
				7,
				"FIntDebugTextureManagerSkipMips"
			},
			{
				"SkipMips (Legacy)",
				7,
				"DebugTextureManagerSkipMips"
			},
			{
				"SkipMips Resolution Limit",
				2147483647,
				"DebugLimitMinTextureResolutionWhenSkipMips"
			},
			{
				"Disable Player Skins",
				3,
				"DFIntTextureCompositorActiveJobs"
			}
		}) do
            local v1505 = t2.value23(v[3])

            if t2.value21.ActiveFlags[v1505] == nil then
                t2.value21:SetFlagInternal(v[3], v[2])
            end

            t2.value21:AddFlagUI("Engine Settings", v[1], v[2], v[3])
        end
        local t41 = {}
        local u1507 = false
        local s11 = "Arcade"
        local connection
        if t2.value21.ActiveFlags.CustomFontEnable == nil then
            t2.value21:SetFlagInternal("CustomFontEnable", "False")
        end
        if t2.value21.ActiveFlags.CustomFontName == nil then
            t2.value21:SetFlagInternal("CustomFontName", "Arcade")
        end
        t2.value21:AddFlagUI("Appearance", "Change Game Fonts", "False", "CustomFontEnable", function(p345)
            if p345 == u1507 then
                return
            end

            u1507 = p345

            if p345 then
                local function v1669(p346)
                    for _, descendant in ipairs(p346:GetDescendants()) do
                        local v1741 = descendant
                        local v1742 = v1741:IsA("TextLabel")

                        if not v1742 then
                            v1742 = v1741:IsA("TextButton")

                            if not v1742 then
                                v1742 = v1741:IsA("TextBox")
                            end
                        end

                        if v1742 and u1507 then
                            pcall(function()
                                local v1765 = s11
                                local insert = table.insert
                                local v1767 = t41
                                local v1768 = v1741
                                local v1769 = tostring(v1741.Font):split(".")[3]
                                local connection2 = v1741:GetPropertyChangedSignal("Font"):Connect(function()
                                    pcall(function()
                                        v1741.Font = Enum.Font[v1765]
                                    end)
                                end)

                                insert(v1767, {
									inst = v1768,
									font = v1769,
									connection = connection2
								})
                                pcall(function()
                                    v1741.Font = Enum.Font[v1765]
                                end)
                            end)
                        end
                    end
                end

                connection = game.DescendantAdded:Connect(function(descendant)
                    local v1737 = descendant:IsA("TextLabel")

                    if not v1737 then
                        v1737 = descendant:IsA("TextButton")

                        if not v1737 then
                            v1737 = descendant:IsA("TextBox")
                        end
                    end

                    if v1737 and u1507 then
                        pcall(function()
                            local v1759 = s11
                            local insert = table.insert
                            local v1761 = t41
                            local v1762 = descendant
                            local v1763 = tostring(descendant.Font):split(".")[3]
                            local connection3 = descendant:GetPropertyChangedSignal("Font"):Connect(function()
                                pcall(function()
                                    descendant.Font = Enum.Font[v1759]
                                end)
                            end)

                            insert(v1761, {
								inst = v1762,
								font = v1763,
								connection = connection3
							})
                            pcall(function()
                                descendant.Font = Enum.Font[v1759]
                            end)
                        end)
                    end
                end)
                pcall(v1669, game:GetService("CoreGui"))
                pcall(v1669, game:GetService("Players").LocalPlayer.PlayerGui)

                return
            end

            if connection then
                pcall(function()
                    connection:Disconnect()
                end)
                connection = nil
            end

            for _, v in ipairs(t41) do
                local v1672 = v

                pcall(function()
                    v1672.connection:Disconnect()
                    v1672.inst.Font = Enum.Font[v1672.font]
                end)
            end

            table.clear(t41)
        end)
        t2.value21:AddFlagUI("Appearance", "Font Name (e.g. Arial)", "Arcade", "CustomFontName", function(p347)
            local Name
            local v1675 = tostring(p347):lower()
            local v1676, v1677, v1678 = ipairs(Enum.Font:GetEnumItems())
            local g1680
            local v1679
            repeat
                v1678, v1679 = v1676(v1677, v1678)

                if not v1678 then
                    g1680 = true
                end

                if g1680 then
                    break
                end
            until v1675 == v1679.Name:lower()
            if not g1680 then
                Name = v1679.Name
            end
            if Name then
                local v1681 = u1507

                if v1681 then
                    v1681 = t2.value21.Callbacks.CustomFontEnable
                end

                if v1681 then
                    t2.value21.Callbacks.CustomFontEnable(false)
                    t2.value21.Callbacks.CustomFontEnable(true)

                    return
                end
            else
                t2.value21:Log("Error: Invalid Font Name")
            end
        end)
        for _, v in ipairs({
			{
				"Disable Terrain",
				"True",
				"FFlagDisableTerrainTextures"
			},
			{
				"Disable PostFX",
				"True",
				"FFlagDisablePostFx"
			},
			{
				"Dynamic Res",
				"True",
				"FFlagRenderDynamicResolutionScale11"
			},
			{
				"Player Network Update Rate",
				60,
				"DFIntPlayerNetworkUpdateRate"
			},
			{
				"Server Physics Update Rate",
				60,
				"DFIntServerPhysicsUpdateRate"
			},
			{
				"Optimize Ping Threshold",
				50,
				"DFIntOptimizePingThreshold"
			},
			{
				"Network Latency Tolerance",
				1,
				"DFIntNetworkLatencyTolerance"
			},
			{
				"S2 Physics Sender Rate",
				250,
				"DFIntS2PhysicsSenderRate"
			},
			{
				"RakNet RTT Multiple",
				1,
				"DFIntRakNetResendRttMultiple"
			}
		}) do
            local v1512 = t2.value23(v[3])

            if t2.value21.ActiveFlags[v1512] == nil then
                t2.value21:SetFlagInternal(v[3], v[2])
            end

            t2.value21:AddFlagUI("Appearance", v[1], v[2], v[3])
        end
        if t2.value21.ActiveFlags.DFIntTaskSchedulerTargetFps == nil then
            t2.value21:SetFlagInternal("DFIntTaskSchedulerTargetFps", 999)
        end
        t2.value21:AddFlagUI("Appearance", "Target FPS", "999", "DFIntTaskSchedulerTargetFps", function(p348)
            local u1683 = if type(p348) ~= "boolean" then tonumber(p348) else tonumber(t2.value21.ActiveFlags[t2.value23("DFIntTaskSchedulerTargetFps")]) or 999

            if u1683 then
                if u1683 > 60 then
                    t2.value21:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen", "False")
                    t2.value21:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen2", "False")
                    t2.value21:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen3", "False")
                    t2.value21:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen4", "False")
                    t2.value21:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen5", "False")
                    t2.value21:SetFlagInternal("FIntFRMMaxFPS", u1683)
                    t2.value21:SetFlagInternal("FFlagFrameRateManagerActive", "False")
                    t2.value21:SetFlagInternal("FFlagFrameRateManager", "False")
                    t2.value21:SetFlagInternal("FFlagFrameRateManager2", "False")
                    t2.value21:SetFlagInternal("FFlagFrameRateManager3", "False")
                else
                    t2.value21:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen", "True")
                    t2.value21:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen2", "True")
                    t2.value21:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen3", "True")
                    t2.value21:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen4", "True")
                    t2.value21:SetFlagInternal("FFlagTaskSchedulerLimitTargetFpsToScreen5", "True")
                    t2.value21:SetFlagInternal("FIntFRMMaxFPS", u1683)
                    t2.value21:SetFlagInternal("FFlagFrameRateManagerActive", "True")
                    t2.value21:SetFlagInternal("FFlagFrameRateManager", "True")
                    t2.value21:SetFlagInternal("FFlagFrameRateManager2", "True")
                    t2.value21:SetFlagInternal("FFlagFrameRateManager3", "True")
                end

                if setfpscap then
                    pcall(function()
                        setfpscap(u1683)
                    end)
                end
            end
        end)
        local t42 = {}
        t2.value21:AddFlagUI("Appearance", "Shrink Roblox GUI", "False", "GUIScalerEnable", function(p349)
            if p349 == false then
                return
            end

            if p349 then
                local function v1685(p350)
                    local GetChildren = p350.GetChildren

                    for _, v in ipairs(GetChildren(p350)) do
                        local v1747 = v.Name == "TouchGui"

                        if not v1747 then
                            v1747 = not v:IsA("ScreenGui")
                        end

                        if not v1747 then
                            local UIScale = v:FindFirstChildWhichIsA("UIScale")

                            if UIScale then
                                table.insert(t42, {
									oldscale = UIScale.Scale,
									scaler = UIScale
								})
                                UIScale.Scale = UIScale.Scale - 0.3
                            else
                                local UIScale2 = Instance.new("UIScale", v)

                                UIScale2.Scale = 0.7
                                table.insert(t42, {
									oldscale = 9000000000,
									scaler = UIScale2
								})
                            end
                        end
                    end
                end

                pcall(v1685, game:GetService("CoreGui"))
                pcall(v1685, game.Players.LocalPlayer.PlayerGui)

                return
            end

            for _, v in ipairs(t42) do
                local v1688 = v

                if v1688.oldscale == 9000000000 then
                    pcall(function()
                        v1688.scaler:Destroy()
                    end)
                else
                    pcall(function()
                        v1688.scaler.Scale = v1688.oldscale
                    end)
                end
            end

            table.clear(t42)
        end)
        local UIScale
        t2.value21:AddFlagUI("Appearance", "Increase Touch Control Size", "False", "TouchGuiSizeEn", function(p351)
            if p351 == false then
                return
            end

            pcall(function()
                local TouchGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui")

                if p351 and TouchGui then
                    if not UIScale then
                        UIScale = Instance.new("UIScale", TouchGui)
                    end

                    UIScale.Scale = 1.3

                    return
                end

                if UIScale then
                    UIScale:Destroy()
                end
            end)
        end)
        local ImageLabel
        local s12 = "rbxassetid://13164402636"
        local connection4
        if t2.value21.ActiveFlags.CrosshairUrl == nil then
            t2.value21:SetFlagInternal("CrosshairUrl", "rbxassetid://13164402636")
        end
        t2.value21:AddFlagUI("Appearance", "Custom Crosshair", "False", "CrosshairEnable", function(p352)
            if p352 == false then
                return
            end

            if p352 then
                pcall(function()
                    if not ImageLabel then
                        local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))

                        ScreenGui.Name = game:GetService("HttpService"):GenerateGUID(false)
                        ScreenGui.IgnoreGuiInset = true
                        ImageLabel = Instance.new("ImageLabel", ScreenGui)
                        ImageLabel.Size = UDim2.new(0, 20, 0, 20)
                        ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                        ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                        ImageLabel.BackgroundTransparency = 1
                        ImageLabel.Image = s12
                    end

                    if connection4 then
                        connection4:Disconnect()
                    end

                    connection4 = game:GetService("RunService").RenderStepped:Connect(function()
                        pcall(function()
                            local Character = game.Players.LocalPlayer.Character
                            local v1781 = Character

                            if Character then
                                v1781 = Character:FindFirstChild("Head")

                                if v1781 then
                                    v1781 = workspace.CurrentCamera
                                end
                            end

                            if v1781 then
                                ImageLabel.Visible = (Character.Head.Position - workspace.CurrentCamera.CFrame.Position).Magnitude <= 3
                            end
                        end)
                    end)
                end)

                return
            end

            if connection4 then
                connection4:Disconnect()
            end

            if ImageLabel then
                pcall(function()
                    ImageLabel.Parent:Destroy()
                end)
                ImageLabel = nil
            end
        end)
        t2.value21:AddFlagUI("Appearance", "Crosshair ID (rbxassetid)", "rbxassetid://13164402636", "CrosshairUrl", function(p353)
            s12 = tostring(p353)

            if ImageLabel then
                ImageLabel.Image = s12
            end
        end)
        t2.value21:AddFlagUI("Engine Settings", "Force MSAA 4x", "False", "ForceMSAA4x", function(p354)
            t2.value21:SetFlagInternal("FIntDebugForceMSAASamples", not p354 and 0 or 4)
        end)
        t2.value21:AddFlagUI("Engine Settings", "Force Future Lighting", "False", "ForceFutureLight", function(p355)
            t2.value21:SetFlagInternal("DFFlagDebugRenderForceTechnologyVoxel", "False")
            t2.value21:SetFlagInternal("DFFlagDebugRenderForceFutureIsBrightPhase2", "False")
            t2.value21:SetFlagInternal("DFFlagDebugRenderForceFutureIsBrightPhase3", not p355 and "False" or "True")

            if p355 then
                pcall(function()
                    sethiddenproperty(game.Lighting, "Technology", "Future")
                end)
            end
        end)
        local u1518 = false
        t2.value21:AddFlagUI("Mods", "De-Rendering (Anti-Lag)", "False", "DeRenderingEnable", function(p356)
            if p356 == u1518 then
                return
            end

            u1518 = p356

            if p356 then
                task.spawn(function()
                    while u1518 do
                        pcall(function()
                            local LocalPlayer6 = game.Players.LocalPlayer
                            local Character = LocalPlayer6.Character
                            local v1773 = Character

                            if Character then
                                v1773 = Character:FindFirstChild("HumanoidRootPart")
                            end

                            if v1773 then
                                for _, player in ipairs(game.Players:GetPlayers()) do
                                    local v1776 = player ~= LocalPlayer6

                                    if v1776 then
                                        v1776 = player.Character

                                        if v1776 then
                                            v1776 = player.Character:FindFirstChild("HumanoidRootPart")

                                            if v1776 then
                                                v1776 = player.Character:FindFirstChild("Humanoid")
                                            end
                                        end
                                    end

                                    if v1776 then
                                        local Magnitude = (Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude

                                        for _, v in ipairs(player.Character.Humanoid:GetPlayingAnimationTracks()) do
                                            v:AdjustSpeed(Magnitude <= 100 and 1 or 0)
                                        end
                                    end
                                end
                            end
                        end)
                        task.wait(1)
                    end
                end)
            end
        end)
        local getRotation
        if t2.value21.ActiveFlags.CamSensitivity == nil then
            t2.value21:SetFlagInternal("CamSensitivity", "1")
        end
        t2.value21:AddFlagUI("Mods", "Camera Sensitivity (1 to 7)", "1", "CamSensitivity", function(p357)
            local num = tonumber(p357)

            if num and num > 0 then
                pcall(function()
                    local CameraInput = require(game.Players.LocalPlayer.PlayerScripts.PlayerModule.CameraModule.CameraInput)

                    if not getRotation then
                        getRotation = CameraInput.getRotation
                    end

                    function CameraInput.getRotation(...)
                        return getRotation(...) * num
                    end
                end)
            end
        end)
        t2.value21:AddFlagUI("Mods", "Extreme Desync (38000)", "False", "ExtremeDesync", function(p358)
            if p358 then
                t2.value21:SetFlagInternal("DFIntS2PhysicsSenderRate", 38000)

                return
            end

            t2.value21:SetFlagInternal("DFIntS2PhysicsSenderRate", 15)
        end)
        t2.value21:AddFlagUI("Mods", "Advanced Hitreg Fix", "False", "AdvHitregFix", function(p359)
            if p359 then
                local t43 = {
					DFIntCodecMaxIncomingPackets = 100,
					DFIntCodecMaxOutgoingFrames = 10000,
					DFIntLargePacketQueueSizeCutoffMB = 1000,
					DFIntMaxProcessPacketsJobScaling = 10000,
					DFIntMaxProcessPacketsStepsAccumulated = 0,
					DFIntMaxProcessPacketsStepsPerCyclic = 5000,
					DFIntMegaReplicatorNetworkQualityProcessorUnit = 10,
					DFIntNetworkPrediction = 120,
					DFIntPlayerNetworkUpdateQueueSize = 20,
					DFIntRaknetBandwidthInfluxHundredthsPercentageV2 = 10000,
					DFIntRaknetBandwidthPingSendEveryXSeconds = 1,
					DFIntRakNetLoopMs = 1,
					DFIntServerTickRate = 60,
					DFIntWaitOnRecvFromLoopEndedMS = 100,
					DFIntWaitOnUpdateNetworkLoopEndedMS = 100,
					FFlagOptimizeNetwork = "True",
					FFlagOptimizeNetworkRouting = "True",
					FFlagOptimizeNetworkTransport = "True",
					FFlagOptimizeServerTickRate = "True",
					FIntRakNetResendBufferArrayLength = 128
				}

                for k, v in pairs(t43) do
                    t2.value21:SetFlagInternal(k, v)
                end
            end
        end)
        if t2.value21.ActiveFlags.StretchResolution == nil then
            t2.value21:SetFlagInternal("StretchResolution", 100)
        end
        t2.value21:AddSliderUI("Mods", "Stretch Resolution", 100, 1, 100, "StretchResolution", function(p360)
            if (tonumber(p360) or 100) >= 100 then
                t2.value21:StopStretchResolution()

                return
            end

            t2.value21:StartStretchResolution()
        end)
        local t44 = {
			DFIntTaskSchedulerTargetFps = 999,
			DFFlagVariableMaxFpsEnabled = "True",
			FFlagAdaptiveMeshCacheSizeForAndroid = "True",
			FIntGraphicsVulkanMinAndroidVersion = 25,
			DFIntAndroidActivityLifecycleHistoryMaxCount = 30
		}
        for v1523, v1524 in pairs(t44) do

            local v1525 = t2.value23(v1523)

            if t2.value21.ActiveFlags[v1525] == nil then
                t2.value21:SetFlagInternal(v1523, v1524)
            end

            t2.value21:AddFlagUI("Integrations", v1523, v1524, v1523)
        end
        for k, _ in pairs(t2.value21.UIRegistry) do
            local v1528 = k
            local v1529 = t2.value21.ActiveFlags[v1528]
            local v1530 = v1529 ~= nil

            if v1530 then
                v1530 = t2.value21.Callbacks[v1528]
            end

            if v1530 then
                local u1531 = v1529
                local v1532 = tostring(v1529):lower()
                local v1533 = v1532 == "true"

                if not v1533 then
                    v1533 = v1532 == "1" or v1532 == "on"
                end

                if v1533 then
                    u1531 = true
                else
                    local v1534 = v1532 == "false"

                    if not v1534 then
                        v1534 = v1532 == "0" or v1532 == "off"
                    end

                    if v1534 then
                        u1531 = false
                    elseif tonumber(v1529) ~= nil then
                        u1531 = tonumber(v1529)
                    end
                end

                if u1531 ~= false then
                    pcall(function()
                        t2.value21.Callbacks[v1528](u1531)
                    end)
                end
            end
        end
        t2.value21:PurgeInjectBloat()
        t2.value21:ApplyMobileUILayout()
        t2.value21:SyncStretchResolutionFromFlags()
        t2.value21:ReapplyVisualStripAfterJoin()
        t2.value21:CaptureRejoinTarget()
    end)
end)
