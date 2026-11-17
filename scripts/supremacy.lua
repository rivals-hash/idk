-- Supremacy Hub | Silent Aim
local Players = game:GetService("Players")

-- CRITICO en Delta: esperar LocalPlayer (si es nil, el script muere en silencio)
local player = Players.LocalPlayer
if not player then
	player = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	player = Players.LocalPlayer
end
repeat task.wait() until player and player.Parent
print("[Supremacy] LocalPlayer OK:", player.Name)

print("[Supremacy] Loaded for", player.Name)


-- ERROR CATCHER (muestra el fallo en pantalla)
local function supremacyShowError(err)
	warn("[Supremacy ERROR]", err)
	pcall(function()
		local pg = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 3)
		local parent = pg
		pcall(function()
			if gethui then parent = gethui()
			elseif game:GetService("CoreGui") then parent = game:GetService("CoreGui") end
		end)
		local g = Instance.new("ScreenGui")
		g.Name = "SupremacyError"
		g.ResetOnSpawn = false
		g.DisplayOrder = 100000
		g.IgnoreGuiInset = true
		g.Parent = parent or pg
		local sc = Instance.new("ScrollingFrame")
		sc.Size = UDim2.new(0.9, 0, 0.4, 0)
		sc.Position = UDim2.new(0.05, 0, 0.3, 0)
		sc.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
		sc.BorderSizePixel = 0
		sc.ScrollBarThickness = 6
		sc.CanvasSize = UDim2.new(0, 0, 0, 400)
		sc.Parent = g
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, -16, 0, 400)
		l.Position = UDim2.new(0, 8, 0, 8)
		l.BackgroundTransparency = 1
		l.Text = "SUPREMACY ERROR:\n" .. tostring(err)
		l.TextColor3 = Color3.fromRGB(255, 80, 80)
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextYAlignment = Enum.TextYAlignment.Top
		l.TextWrapped = true
		l.Font = Enum.Font.Code
		l.TextSize = 12
		l.Parent = sc
	end)
end

local supremacyOk, supremacyErr = xpcall(function()


-- Tu script empieza debajo de esta línea

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

-- VARIABLES
local FreezeEnabled = false
local NoclipEnabled = false
local AntiLavaEnabled = false
local SilentAimEnabled = false
-- Predict (boton + ejes Y/X) en 1 tabla (ahorra locals)
local Predict = {
	on = false, yOn = false, y = 0, xOn = false, x = 0, look = nil,
	btn = nil, pos = UDim2.new(0, 220, 0, 200), keyOn = false,
}
local SuperDashEnabled = false
local SuperDashSpeed = 10
local SoruAimbotEnabled = false
local AimbotEnabled = false
local AimbotButtonEnabled = false
local AimbotSmooth = 50
local SmoothingEnabled = false
local AimPart = "Head"
local FOVCircleEnabled = false
local FOVCircleColor = Color3.fromHex("#222222")
local FOVHideEnabled = false
local FOVSizeEnabled = false
local FOVSize = 50
local AimDistanceEnabled = false
local AimDistanceValue = 1000
local FOVDrawing = nil
local isFrozen = false
local noclipConn = nil
local antiLavaConn = nil
local ZSanguineBoostEnabled = false
local lagGui = nil
local InfiniteJumpEnabled = false
local SuperJumpEnabled = false
local SafeZoneEnabled = false
local SafeZoneHealth = 500
local safeZoneTriggered = false
local lastInfiniteJump = 0

local savedFreezePos = UDim2.new(0, 150, 0, 200)
local savedAimbotPos = UDim2.new(0, 150, 0, 260)
local savedLagPos = UDim2.new(0.37, 0, 0.26, 0)
local savedSuperJumpPos = nil

local ButtonOpacityEnabled = false
local ButtonOpacity = 0
local MenuButtonOpacityEnabled = false

-- Click Sound: None / Type / Mech
local ClickSoundId = ""
local ClickSoundName = "None"
local ClickSoundSpeed = 1
local ClickSoundVol = 3.5
local clickSoundDropdownOpen = false
local clickSoundDropdown = nil
_G.SupremacyChOpen = false
_G.SupremacyChDropdown = nil
local CLICK_SOUNDS = {
	{ name = "None", id = "", speed = 1, vol = 0 },
	{ name = "Click 1", id = "rbxassetid://156286438", speed = 1.05, vol = 3.5 },
	{ name = "Click 2", id = "rbxassetid://4724430129", speed = 1.25, vol = 8 },
}
local function playClickSound()
	pcall(function()
		if ClickSoundName == "None" or not ClickSoundId or ClickSoundId == "" then return end
		local parent = player:FindFirstChild("PlayerGui") or workspace.CurrentCamera or workspace
		local s = Instance.new("Sound")
		s.Name = "SupremacyClick"
		s.SoundId = ClickSoundId
		s.Volume = ClickSoundVol or 3.5
		s.PlaybackSpeed = ClickSoundSpeed or 1
		s.Looped = false
		s.RollOffMaxDistance = 100000
		s.RollOffMinDistance = 100000
		s.Parent = parent
		task.spawn(function()
			local t0 = tick()
			while not s.IsLoaded and tick() - t0 < 1.2 do
				task.wait()
			end
			if not s.Parent then return end
			s.TimePosition = 0
			s:Play()
			task.wait(0.09)
			pcall(function()
				s:Stop()
				s:Destroy()
			end)
		end)
		task.delay(1.5, function()
			pcall(function() if s and s.Parent then s:Destroy() end end)
		end)
	end)
end

local ESPBoxEnabled = false
local ESPBoxColor = Color3.fromHex("#222222")
local ESPType = "2D"
local ESPFilled = false
local BoxDrawings = {}
local BoxHighlights = {}

local ESPNameEnabled = false
local ESPNameColor = Color3.fromHex("#222222")
local ESPDistanceEnabled = false
local ESPDistanceColor = Color3.fromHex("#222222")
local ESPHealthEnabled = false

local ESPSnapLineEnabled = false
local ESPSnapLineColor = Color3.fromHex("#222222")
local ESPAntennaEnabled = false
local ESPAntennaColor = Color3.fromHex("#222222")
local LimitDistanceEnabled = false
local LimitDistanceValue = 5000

local TeamCheckEnabled = false
local NPCCheckEnabled = false
local HealthCheckEnabled = false
_G.SupremacyHealthCheck = false
_G.SupremacyNPCCheck = false
local WhitelistedPlayers = {}
local WhiteListProtected = {}
local function isWhiteListProtected(plr)
	if not plr then return false end
	local uid = plr.UserId
	return WhiteListProtected[uid] == true or WhiteListProtected[tostring(uid)] == true
end
_G.SupremacyIsWhiteListProtected = isWhiteListProtected

local NameTexts = {}
local DistTexts = {}
local HealthBars = {}
local SnapLines = {}
local AntennaLines = {}

local NPCBoxDrawings = {}
local NPCNameTexts = {}
local NPCDistTexts = {}
local NPCHealthBars = {}
local NPCSnapLines = {}
local NPCHighlights = {}
local DeadNPCs = {}

local TEXT_SELECTED = Color3.fromRGB(0, 0, 0)
local TEXT_DIM = Color3.fromRGB(120, 120, 120)
local TEXT_LABEL = Color3.fromRGB(25, 25, 25)
local TOGGLE_ON = Color3.fromRGB(255, 255, 255)
local RED_BTN = Color3.fromRGB(220, 40, 40)

local function getAimPart(char)
	if not char then return nil end
	if AimPart == "Head" then return char:FindFirstChild("Head")
	elseif AimPart == "Torso" then return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	elseif AimPart == "Leg" then return char:FindFirstChild("LeftFoot") or char:FindFirstChild("RightFoot") or char:FindFirstChild("Left Leg") or char:FindFirstChild("Right Leg") or char:FindFirstChild("LeftLowerLeg") or char:FindFirstChild("HumanoidRootPart")
	end
	return char:FindFirstChild("HumanoidRootPart")
end

-- BUTTON OPACITY
local OpenBtn, FreezeBtn, AimbotBtn, FreezeContainer, SuperJumpBtn, SuperJumpContainer

local function getFeatureTransparency()
	if not ButtonOpacityEnabled then return 0 end
	return math.clamp(ButtonOpacity / 100, 0, 1)
end

local function getMenuBtnTransparency()
	if not MenuButtonOpacityEnabled then return 0 end
	return math.clamp(ButtonOpacity / 100, 0, 1)
end

local function applyOpacityToGui(gui, t)
	if not gui then return end
	local function setTrans(obj)
		if obj:IsA("GuiObject") then
			if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
				obj.TextTransparency = t
				obj.BackgroundTransparency = t
			elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
				obj.ImageTransparency = t
				obj.BackgroundTransparency = t
			elseif obj:IsA("Frame") then
				obj.BackgroundTransparency = t
			end
		elseif obj:IsA("UIStroke") then
			obj.Transparency = 0.15 + (0.85 * t)
		end
		for _, child in pairs(obj:GetChildren()) do setTrans(child) end
	end
	setTrans(gui)
end

local function applyAllButtonOpacity()
	local t = getFeatureTransparency()
	-- Freeze (Tab): nunca ocultar, solo transparencia → sigue clickeable al 100%
	if FreezeContainer then
		FreezeContainer.Visible = FreezeEnabled
		FreezeContainer.BackgroundTransparency = t
		for _, child in pairs(FreezeContainer:GetDescendants()) do
			if child:IsA("TextButton") or child:IsA("TextLabel") then
				child.BackgroundTransparency = t
				child.TextTransparency = t
			elseif child:IsA("UIStroke") then
				child.Transparency = 0.15 + (0.85 * t)
			elseif child:IsA("Frame") then
				child.BackgroundTransparency = t
			end
		end
	end
	if AimbotBtn then AimbotBtn.BackgroundTransparency = t AimbotBtn.TextTransparency = t end
	if Predict.container then
		Predict.container.Visible = Predict.keyOn
		Predict.container.BackgroundTransparency = t
		for _, child in pairs(Predict.container:GetDescendants()) do
			if child:IsA("TextButton") or child:IsA("TextLabel") then
				child.BackgroundTransparency = t
				child.TextTransparency = t
			elseif child:IsA("UIStroke") then
				child.Transparency = 0.15 + (0.85 * t)
			elseif child:IsA("Frame") then
				child.BackgroundTransparency = t
			end
		end
	end
	if SuperJumpContainer then
		SuperJumpContainer.Visible = SuperJumpEnabled
		SuperJumpContainer.BackgroundTransparency = t
		for _, child in pairs(SuperJumpContainer:GetDescendants()) do
			if child:IsA("TextButton") or child:IsA("TextLabel") then
				child.BackgroundTransparency = t
				child.TextTransparency = t
			elseif child:IsA("UIStroke") then
				child.Transparency = 0.15 + (0.85 * t)
			elseif child:IsA("Frame") then
				child.BackgroundTransparency = t
			end
		end
	end
	-- Sanguine Z Boost: nunca desactivar, solo transparencia
	if lagGui then
		lagGui.Enabled = true
		applyOpacityToGui(lagGui, t)
	end
	pcall(function()
		for _, gui in pairs(player.PlayerGui:GetChildren()) do
			local n = string.lower(gui.Name)
			if n:find("jump") or n:find("super") then applyOpacityToGui(gui, t) end
		end
	end)
	if OpenBtn then
		local mt = getMenuBtnTransparency()
		OpenBtn.ImageTransparency = mt
		OpenBtn.BackgroundTransparency = mt
	end
end

-- ESP COMPLETO (NUEVO)
;(function()
local function GetFilledColor()
	return Color3.new(
		math.clamp(ESPBoxColor.R + 0.25, 0, 1),
		math.clamp(ESPBoxColor.G + 0.25, 0, 1),
		math.clamp(ESPBoxColor.B + 0.25, 0, 1)
	)
end

local function ClearESPBoxes()
	for _, hl in pairs(BoxHighlights) do
		if hl then pcall(function() hl:Destroy() end) end
	end
	table.clear(BoxHighlights)
	for _, hl in pairs(NPCHighlights) do
		if hl then pcall(function() hl:Destroy() end) end
	end
	table.clear(NPCHighlights)
	for _, pack in pairs(BoxDrawings) do
		if type(pack) == "table" then
			for _, o in pairs(pack) do
				if typeof(o) == "Instance" then pcall(function() o:Destroy() end) end
			end
		end
	end
	table.clear(BoxDrawings)
	for _, pack in pairs(NPCBoxDrawings) do
		if type(pack) == "table" then
			for _, o in pairs(pack) do
				if typeof(o) == "Instance" then pcall(function() o:Destroy() end) end
			end
		end
	end
	table.clear(NPCBoxDrawings)
	for _, pack in pairs(SnapLines) do
		if type(pack) == "table" and pack.frame then pcall(function() pack.frame:Destroy() end) end
	end
	table.clear(SnapLines)
	for _, pack in pairs(AntennaLines) do
		if type(pack) == "table" and pack.frame then pcall(function() pack.frame:Destroy() end) end
	end
	table.clear(AntennaLines)
	for _, pack in pairs(NPCSnapLines) do
		if type(pack) == "table" and pack.frame then pcall(function() pack.frame:Destroy() end) end
	end
	table.clear(NPCSnapLines)
	for _, pack in pairs(NameTexts) do
		if type(pack) == "table" then
			for _, o in pairs(pack) do
				if typeof(o) == "Instance" then pcall(function() o:Destroy() end) end
			end
		end
	end
	table.clear(NameTexts)
	for _, pack in pairs(DistTexts) do
		if type(pack) == "table" then
			for _, o in pairs(pack) do
				if typeof(o) == "Instance" then pcall(function() o:Destroy() end) end
			end
		end
	end
	table.clear(DistTexts)
	for _, pack in pairs(HealthBars) do
		if type(pack) == "table" then
			for _, o in pairs(pack) do
				if typeof(o) == "Instance" then pcall(function() o:Destroy() end) end
			end
		end
	end
	table.clear(HealthBars)
	for _, pack in pairs(NPCNameTexts) do
		if type(pack) == "table" then
			for _, o in pairs(pack) do
				if typeof(o) == "Instance" then pcall(function() o:Destroy() end) end
			end
		end
	end
	table.clear(NPCNameTexts)
	for _, pack in pairs(NPCDistTexts) do
		if type(pack) == "table" then
			for _, o in pairs(pack) do
				if typeof(o) == "Instance" then pcall(function() o:Destroy() end) end
			end
		end
	end
	table.clear(NPCDistTexts)
	for _, pack in pairs(NPCHealthBars) do
		if type(pack) == "table" then
			for _, o in pairs(pack) do
				if typeof(o) == "Instance" then pcall(function() o:Destroy() end) end
			end
		end
	end
	table.clear(NPCHealthBars)
end
_G.SupremacyClearESP = ClearESPBoxes

local function isWhitelisted(plr)
	-- Solo aplica si Team Check esta ON. Al desactivar Team Check, los seleccionados siguen con ESP/aim normal.
	if not plr then return false end
	if not TeamCheckEnabled then return false end
	return WhitelistedPlayers[plr.UserId] == true
		or WhitelistedPlayers[tostring(plr.UserId)] == true
end
_G.SupremacyIsWhitelisted = isWhitelisted

local function isCombatNPC(modelo, hum, root)
	if not modelo or not hum or not root then return false end
	-- NO filtrar por Health aqui (si no el ESP de NPC se borra al morir sin Health Check)
	if hum.MaxHealth < 100 then return false end
	if root.Anchored then return false end
	if hum.WalkSpeed <= 0 and hum.JumpPower <= 0 and (hum.JumpHeight or 0) <= 0 then
		if not modelo:FindFirstChildOfClass("Tool") then return false end
	end
	local nameLower = string.lower(modelo.Name)
	local block = {
		"shop","seller","dealer","quest","trainer","teacher","merchant","gacha",
		"title","dialogue","dialog","manager","vendor","guide","helper","luxury",
		"boat","customer","spawn","set home","home point","marine recruit",
		"toribro","indra","nami","ability","sword dealer","weapon","fruit shop",
		"blox fruit","luxury boat","boat dealer","crew","captain","bartender",
		"quest giver","town"
	}
	for _, word in pairs(block) do
		if string.find(nameLower, word, 1, true) then return false end
	end
	if modelo:FindFirstChildWhichIsA("ProximityPrompt", true) then return false end
	if modelo:FindFirstChildWhichIsA("ClickDetector", true) then return false end
	local parentName = modelo.Parent and string.lower(modelo.Parent.Name) or ""
	local inEnemyFolder = parentName:find("enem") or parentName:find("monster")
		or parentName:find("mob") or parentName:find("npc") or parentName:find("unit")
		or parentName:find("character") or parentName:find("boss")
	if not inEnemyFolder and hum.MaxHealth < 500 then return false end
	return true
end

local function isDead(hum, char)
	-- Solo muerte REAL por vida/estado. Nunca apagar ESP por esto sin Health Check.
	if not hum then return false end
	if hum.Health <= 0 then return true end
	local ok, state = pcall(function() return hum:GetState() end)
	if ok and state == Enum.HumanoidStateType.Dead then return true end
	return false
end

-- color suave verde → amarillo → rojo
local function healthColor(pct)
	pct = math.clamp(pct, 0, 1)
	if pct <= 0 then
		return Color3.fromRGB(0, 0, 0)
	end
	if pct > 0.5 then
		local t = (pct - 0.5) / 0.5
		return Color3.new(1 - t, 1, 0)
	else
		local t = pct / 0.5
		return Color3.new(1, t, 0)
	end
end

-- Mas pequeño en general; fijo desde 35m
local function espScale(meters)
	if meters >= 35 then
		return 0.62
	end
	return 0.78 - (meters / 35) * 0.16
end

local function isPointInsideMenu(x, y)
	if not Main or not Main.Visible then return false end
	local pos = Main.AbsolutePosition
	local size = Main.AbsoluteSize
	local m = 8
	return x >= (pos.X - m) and x <= (pos.X + size.X + m)
		and y >= (pos.Y - m) and y <= (pos.Y + size.Y + m)
end

local function getOrHL(store, key, model)
	local hl = store[key]
	if hl and hl.Parent then return hl end
	pcall(function() if hl then hl:Destroy() end end)
	hl = Instance.new("Highlight")
	hl.Name = "SupESP"
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = model
	hl.Adornee = model
	store[key] = hl
	return hl
end

local espGui
local function getEspGui()
	if espGui and espGui.Parent then return espGui end
	local parent = player:FindFirstChild("PlayerGui")
	pcall(function()
		if gethui then parent = gethui() end
	end)
	if not parent then parent = game:GetService("CoreGui") end
	espGui = Instance.new("ScreenGui")
	espGui.Name = "SupESPOverlay"
	espGui.IgnoreGuiInset = true
	espGui.ResetOnSpawn = false
	espGui.DisplayOrder = 999
	espGui.Parent = parent
	return espGui
end

local function makeFrame(parent)
	local f = Instance.new("Frame")
	f.BorderSizePixel = 0
	f.BackgroundColor3 = Color3.new(1, 1, 1)
	f.Parent = parent
	return f
end

local function setScreenLine(pack, x1, y1, x2, y2, color, thickness)
	local gui = getEspGui()
	if not pack.frame then
		pack.frame = makeFrame(gui)
		pack.frame.AnchorPoint = Vector2.new(0.5, 0.5)
	end
	local dx, dy = x2 - x1, y2 - y1
	local len = math.sqrt(dx * dx + dy * dy)
	if len < 1 then
		pack.frame.Visible = false
		return
	end
	pack.frame.Visible = true
	pack.frame.BackgroundColor3 = color
	pack.frame.Size = UDim2.fromOffset(len, thickness)
	pack.frame.Position = UDim2.fromOffset((x1 + x2) * 0.5, (y1 + y2) * 0.5)
	pack.frame.Rotation = math.deg(math.atan2(dy, dx))
end

local function hideScreenLine(pack)
	if pack and pack.frame then pack.frame.Visible = false end
end

local function draw2DBox(store, key, cam, model, color, filled)
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	for _, part in pairs(model:GetChildren()) do
		if part:IsA("BasePart") then
			local sp, on = cam:WorldToViewportPoint(part.Position)
			if on and sp.Z > 0 then
				minX = math.min(minX, sp.X)
				minY = math.min(minY, sp.Y)
				maxX = math.max(maxX, sp.X)
				maxY = math.max(maxY, sp.Y)
			end
		end
	end
	if minX == math.huge then return false end
	minX, minY = minX - 3, minY - 3
	maxX, maxY = maxX + 3, maxY + 3
	local w, h = maxX - minX, maxY - minY
	if w < 4 or h < 4 then return false end

	local pack = store[key]
	if not pack or not pack.top then
		if pack then
			for _, o in pairs(pack) do
				if typeof(o) == "Instance" then pcall(function() o:Destroy() end) end
			end
		end
		local gui = getEspGui()
		pack = {
			top = makeFrame(gui),
			bottom = makeFrame(gui),
			left = makeFrame(gui),
			right = makeFrame(gui),
			fill = makeFrame(gui),
		}
		pack.fill.BackgroundTransparency = 0.6
		store[key] = pack
	end

	local th = 1
	if ESPBoxEnabled then
		for _, side in pairs({"top", "bottom", "left", "right"}) do
			pack[side].Visible = true
			pack[side].BackgroundColor3 = color
		end
		pack.top.Size = UDim2.fromOffset(w, th)
		pack.top.Position = UDim2.fromOffset(minX, minY)
		pack.bottom.Size = UDim2.fromOffset(w, th)
		pack.bottom.Position = UDim2.fromOffset(minX, maxY - th)
		pack.left.Size = UDim2.fromOffset(th, h)
		pack.left.Position = UDim2.fromOffset(minX, minY)
		pack.right.Size = UDim2.fromOffset(th, h)
		pack.right.Position = UDim2.fromOffset(maxX - th, minY)
	else
		pack.top.Visible = false
		pack.bottom.Visible = false
		pack.left.Visible = false
		pack.right.Visible = false
	end

	if filled then
		pack.fill.Visible = true
		pack.fill.BackgroundColor3 = GetFilledColor()
		pack.fill.Size = UDim2.fromOffset(w, h)
		pack.fill.Position = UDim2.fromOffset(minX, minY)
		pack.fill.ZIndex = 0
	else
		pack.fill.Visible = false
	end
	return true
end

local function hide2D(store, key)
	local pack = store[key]
	if not pack then return end
	for _, o in pairs(pack) do
		if typeof(o) == "Instance" then o.Visible = false end
	end
end

-- Text / barra en pantalla (tamaño FIJO, no cambia con distancia)
local function getNamePack(store, key)
	local pack = store[key]
	if pack and pack.lbl and pack.lbl.Parent then return pack end
	local gui = getEspGui()
	local lbl = Instance.new("TextLabel")
	lbl.Name = "SupName"
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.fromOffset(140, 14)
	lbl.AnchorPoint = Vector2.new(0.5, 1)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.TextStrokeTransparency = 0
	lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.Visible = false
	lbl.Parent = gui
	pack = { lbl = lbl }
	store[key] = pack
	return pack
end

local function getDistPack(store, key)
	local pack = store[key]
	if pack and pack.lbl and pack.lbl.Parent then return pack end
	local gui = getEspGui()
	local lbl = Instance.new("TextLabel")
	lbl.Name = "SupDist"
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.fromOffset(70, 13)
	lbl.AnchorPoint = Vector2.new(0.5, 0.5)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 11
	lbl.TextStrokeTransparency = 0
	lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.Visible = false
	lbl.Parent = gui
	pack = { lbl = lbl }
	store[key] = pack
	return pack
end

local function getHPPack(store, key)
	local pack = store[key]
	if pack and pack.border and pack.border.Parent then return pack end
	local gui = getEspGui()
	local border = Instance.new("Frame")
	border.Name = "SupHP"
	border.Size = UDim2.fromOffset(52, 8)
	border.AnchorPoint = Vector2.new(0.5, 0)
	border.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	border.BorderSizePixel = 0
	border.Visible = false
	border.Parent = gui
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 1
	stroke.Parent = border
	local bg = Instance.new("Frame")
	bg.Name = "BG"
	bg.Size = UDim2.new(1, -2, 1, -2)
	bg.Position = UDim2.fromOffset(1, 1)
	bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	bg.BorderSizePixel = 0
	bg.Parent = border
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	fill.BorderSizePixel = 0
	fill.Parent = bg
	pack = { border = border, bg = bg, fill = fill }
	store[key] = pack
	return pack
end

local function hideName(store, key)
	local pack = store[key]
	if pack and pack.lbl then pack.lbl.Visible = false end
end
local function hideDist(store, key)
	local pack = store[key]
	if pack and pack.lbl then pack.lbl.Visible = false end
end
local function hideHP(store, key)
	local pack = store[key]
	if pack and pack.border then pack.border.Visible = false end
end

local function showName(store, key, text, color, sx, sy, scale)
	scale = scale or 1
	local pack = getNamePack(store, key)
	pack.lbl.Text = text
	pack.lbl.TextColor3 = color
	pack.lbl.TextSize = math.floor(12 * scale + 0.5)
	pack.lbl.Size = UDim2.fromOffset(math.floor(140 * scale), math.floor(14 * scale))
	pack.lbl.Position = UDim2.fromOffset(sx, sy)
	pack.lbl.Visible = true
end

local function showDist(store, key, text, color, sx, sy, scale)
	scale = scale or 1
	local pack = getDistPack(store, key)
	pack.lbl.Text = text
	pack.lbl.TextColor3 = color
	pack.lbl.TextSize = math.floor(11 * scale + 0.5)
	pack.lbl.Size = UDim2.fromOffset(math.floor(70 * scale), math.floor(13 * scale))
	pack.lbl.Position = UDim2.fromOffset(sx, sy)
	pack.lbl.Visible = true
end

local function showHP(store, key, pct, color, sx, sy, dead, scale)
	scale = scale or 1
	local pack = getHPPack(store, key)
	local bw = math.floor(52 * scale)
	local bh = math.floor(8 * scale)
	pack.border.Size = UDim2.fromOffset(bw, bh)
	pack.border.Position = UDim2.fromOffset(sx, sy)
	pack.border.Visible = true
	if dead or pct <= 0 then
		-- muerto: solo fondo negro (sin fill verde residual)
		pack.fill.Size = UDim2.new(0, 0, 1, 0)
		pack.fill.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		pack.bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	else
		pack.fill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
		pack.fill.BackgroundColor3 = color
		pack.bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	end
end

local function updateBoxESP()
	for _, hl in pairs(BoxHighlights) do
		if hl then hl.Enabled = false end
	end
	for _, hl in pairs(NPCHighlights) do
		if hl then hl.Enabled = false end
	end
	for key in pairs(BoxDrawings) do hide2D(BoxDrawings, key) end
	for key in pairs(NPCBoxDrawings) do hide2D(NPCBoxDrawings, key) end
	for _, pack in pairs(SnapLines) do hideScreenLine(pack) end
	for _, pack in pairs(AntennaLines) do hideScreenLine(pack) end
	for _, pack in pairs(NPCSnapLines) do hideScreenLine(pack) end
	for key in pairs(NameTexts) do hideName(NameTexts, key) end
	for key in pairs(DistTexts) do hideDist(DistTexts, key) end
	for key in pairs(HealthBars) do hideHP(HealthBars, key) end
	for key in pairs(NPCNameTexts) do hideName(NPCNameTexts, key) end
	for key in pairs(NPCDistTexts) do hideDist(NPCDistTexts, key) end
	for key in pairs(NPCHealthBars) do hideHP(NPCHealthBars, key) end

	local camera = workspace.CurrentCamera
	if not camera then return end
	local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end
	local miPos = myRoot.Position
	local vp = camera.ViewportSize
	local bottomX, bottomY = vp.X * 0.5, vp.Y

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and not isWhitelisted(plr) and not isWhiteListProtected(plr) then
			local char = plr.Character
			local root = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChildOfClass("Humanoid")
			local head = char:FindFirstChild("Head")
			if root and hum then
				local dead = isDead(hum, char)
				local show = true
				-- SOLO con Health Check ON se oculta al morir (nunca solo)
				local hc = (_G.SupremacyHealthCheck == true) or (HealthCheckEnabled == true)
				if hc and dead then
					show = false
				end
				local distToMe = (root.Position - miPos).Magnitude
				local meters = distToMe / 3.5
				local scale = espScale(meters)
				if LimitDistanceEnabled and distToMe > math.min(LimitDistanceValue, 10000) then
					show = false
				end
				local spRoot, onRoot = camera:WorldToViewportPoint(root.Position)
				if isPointInsideMenu(spRoot.X, spRoot.Y) then
					show = false
				end
				if not onRoot or spRoot.Z <= 0 then
					show = false
				end

				if show then
					if ESPBoxEnabled or ESPFilled then
						if ESPType == "2D" then
							draw2DBox(BoxDrawings, plr, camera, char, ESPBoxColor, ESPFilled)
						else
							local hl = getOrHL(BoxHighlights, plr, char)
							hl.Enabled = true
							hl.OutlineColor = ESPBoxColor
							hl.FillColor = GetFilledColor()
							hl.OutlineTransparency = ESPBoxEnabled and 0 or 1
							hl.FillTransparency = ESPFilled and 0.55 or 1
						end
					end

					-- Uno debajo del otro, separacion corta
					local anchor, onA = camera:WorldToViewportPoint(root.Position)
					if onA and anchor.Z > 0 then
						local ax, ay = anchor.X, anchor.Y
						if ESPNameEnabled then
							showName(NameTexts, plr, plr.Name, ESPNameColor, ax, ay - 14 * scale, scale)
						end
						if ESPDistanceEnabled then
							showDist(DistTexts, plr, tostring(math.floor(meters)) .. " m", ESPDistanceColor, ax, ay - 1 * scale, scale)
						end
						if ESPHealthEnabled then
							local maxH = hum.MaxHealth > 0 and hum.MaxHealth or 100
							local pct = 0
							if not dead then
								pct = math.clamp(hum.Health / maxH, 0, 1)
							end
							showHP(HealthBars, plr, pct, healthColor(pct), ax, ay + 10 * scale, dead, scale)
						end
					end

					if ESPSnapLineEnabled then
						local feet = root.Position + Vector3.new(0, -3, 0)
						local sp, on = camera:WorldToViewportPoint(feet)
						if on and sp.Z > 0 then
							local pack = SnapLines[plr]
							if not pack then pack = {} SnapLines[plr] = pack end
							setScreenLine(pack, bottomX, bottomY, sp.X, sp.Y, ESPSnapLineColor, 1.5)
						end
					end

					if ESPAntennaEnabled and head then
						local hs, on = camera:WorldToViewportPoint(head.Position)
						if on and hs.Z > 0 then
							local pack = AntennaLines[plr]
							if not pack then pack = {} AntennaLines[plr] = pack end
							setScreenLine(pack, hs.X, hs.Y, hs.X, -30, ESPAntennaColor, 1.8)
						end
					end
				end
			end
		end
	end

	if not NPCCheckEnabled then
		local pcs = {}
		for _, p in pairs(Players:GetPlayers()) do
			if p.Character then pcs[p.Character] = true end
		end
		local function tryNPC(modelo)
			if not modelo or not modelo:IsA("Model") or pcs[modelo] then return end
			local hum = modelo:FindFirstChildOfClass("Humanoid")
			local root = modelo:FindFirstChild("HumanoidRootPart") or modelo.PrimaryPart
			local head = modelo:FindFirstChild("Head")
			if not hum or not root then return end
			if not isCombatNPC(modelo, hum, root) then return end
			local dead = isDead(hum, modelo)
			local hc = (_G.SupremacyHealthCheck == true) or (HealthCheckEnabled == true)
			if hc and dead then return end
			local distToMe = (root.Position - miPos).Magnitude
			local meters = distToMe / 3.5
			local scale = espScale(meters)
			if LimitDistanceEnabled and distToMe > math.min(LimitDistanceValue, 10000) then return end
			local spRoot, onRoot = camera:WorldToViewportPoint(root.Position)
			if not onRoot or spRoot.Z <= 0 then return end
			if isPointInsideMenu(spRoot.X, spRoot.Y) then return end

			if ESPBoxEnabled or ESPFilled then
				if ESPType == "2D" then
					draw2DBox(NPCBoxDrawings, modelo, camera, modelo, ESPBoxColor, ESPFilled)
				else
					local hl = getOrHL(NPCHighlights, modelo, modelo)
					hl.Enabled = true
					hl.OutlineColor = ESPBoxColor
					hl.FillColor = GetFilledColor()
					hl.OutlineTransparency = ESPBoxEnabled and 0 or 1
					hl.FillTransparency = ESPFilled and 0.55 or 1
				end
			end
			local ax, ay = spRoot.X, spRoot.Y
			if ESPNameEnabled then
				showName(NPCNameTexts, modelo, modelo.Name, ESPNameColor, ax, ay - 14 * scale, scale)
			end
			if ESPDistanceEnabled then
				showDist(NPCDistTexts, modelo, tostring(math.floor(meters)) .. " m", ESPDistanceColor, ax, ay - 1 * scale, scale)
			end
			if ESPHealthEnabled then
				local maxH = hum.MaxHealth > 0 and hum.MaxHealth or 100
				local pct = 0
				if not dead then
					pct = math.clamp(hum.Health / maxH, 0, 1)
				end
				showHP(NPCHealthBars, modelo, pct, healthColor(pct), ax, ay + 10 * scale, dead, scale)
			end
			if ESPSnapLineEnabled then
				local feet = root.Position + Vector3.new(0, -3, 0)
				local sp, on = camera:WorldToViewportPoint(feet)
				if on and sp.Z > 0 then
					local pack = NPCSnapLines[modelo]
					if not pack then pack = {} NPCSnapLines[modelo] = pack end
					setScreenLine(pack, bottomX, bottomY, sp.X, sp.Y, ESPSnapLineColor, 1.5)
				end
			end
			if ESPAntennaEnabled and head then
				local hs, on = camera:WorldToViewportPoint(head.Position)
				if on and hs.Z > 0 then
					local pack = AntennaLines[modelo]
					if not pack then pack = {} AntennaLines[modelo] = pack end
					setScreenLine(pack, hs.X, hs.Y, hs.X, -30, ESPAntennaColor, 1.8)
				end
			end
		end

		local scanned = {}
		local function scanFolder(folder)
			if not folder or scanned[folder] then return end
			scanned[folder] = true
			for _, c in pairs(folder:GetChildren()) do
				tryNPC(c)
				if c:IsA("Folder") or c:IsA("Model") then
					for _, c2 in pairs(c:GetChildren()) do
						tryNPC(c2)
					end
				end
			end
		end
		for _, n in pairs({
			"Enemies", "Enemy", "NPCs", "NPC", "Monsters", "Monster",
			"Mobs", "Mob", "Units", "Characters", "Bosses", "Boss"
		}) do
			local f = workspace:FindFirstChild(n)
			if f then scanFolder(f) end
		end
		for _, c in pairs(workspace:GetChildren()) do
			if c:IsA("Folder") then
				local ln = string.lower(c.Name)
				if ln:find("enem") or ln:find("mob") or ln:find("monster") or ln:find("boss") then
					scanFolder(c)
				end
			end
		end
	end
end

_G._updESP = updateBoxESP
end)()

local function updateBoxESP(...)
	if _G._updESP then return _G._updESP(...) end
end

local function isWhitelisted(plr)
	if _G.SupremacyIsWhitelisted then return _G.SupremacyIsWhitelisted(plr) end
	if not TeamCheckEnabled then return false end
	return WhitelistedPlayers[plr.UserId] == true
end

local function ClearESPBoxes()
	if _G.SupremacyClearESP then _G.SupremacyClearESP() end
end

-- FEATURES
local function createLagGui()
	if lagGui then lagGui:Destroy() end
	lagGui = Instance.new("ScreenGui", player.PlayerGui)
	lagGui.Name = "ZSanguineBoost"
	lagGui.ResetOnSpawn = false

	-- Diseño más pequeño y limpio (sin X)
	local frame = Instance.new("Frame", lagGui)
	frame.Size = UDim2.new(0, 56, 0, 56)
	frame.Position = savedLagPos
	frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	frame.Active = true
	frame.Draggable = true
	frame.BorderSizePixel = 0
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(70, 70, 80)
	stroke.Thickness = 1.3
	stroke.Transparency = 0.15

	local zBtn = Instance.new("TextButton", frame)
	zBtn.Size = UDim2.new(0, 42, 0, 42)
	zBtn.Position = UDim2.new(0.5, -21, 0.5, -21)
	zBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	zBtn.Text = "Z"
	zBtn.TextSize = 20
	zBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
	zBtn.Font = Enum.Font.GothamBlack
	zBtn.BorderSizePixel = 0
	zBtn.AutoButtonColor = true
	Instance.new("UICorner", zBtn).CornerRadius = UDim.new(0, 8)

	local zStroke = Instance.new("UIStroke", zBtn)
	zStroke.Color = Color3.fromRGB(100, 100, 115)
	zStroke.Thickness = 1
	zStroke.Transparency = 0.3

	-- Iluminación al pulsar
	zBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			zBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 105)
			zBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end)
	zBtn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			zBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
			zBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
		end
	end)
	-- Lanzamiento (velocidad) hacia donde miras — NO lag, NO teleport
	zBtn.MouseButton1Click:Connect(function()
		pcall(function()
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local cam = workspace.CurrentCamera
			if not root or not cam then return end
			local dir = cam.CFrame.LookVector
			if dir.Magnitude < 0.05 then return end
			dir = dir.Unit
			local speed = 480
			if hum then
				pcall(function()
					hum:ChangeState(Enum.HumanoidStateType.Freefall)
				end)
			end
			root.AssemblyLinearVelocity = dir * speed
			pcall(function()
				root.Velocity = dir * speed
			end)
		end)
	end)

	frame:GetPropertyChangedSignal("Position"):Connect(function() savedLagPos = frame.Position end)
	applyAllButtonOpacity()
end

-- FREEZE BUTTON
-- Freeze Button (COPIA EXACTA del diseño Sanguine Z Boost)
-- Contenedor exterior
FreezeContainer = Instance.new("Frame")
FreezeContainer.Name = "FreezeTabContainer"
FreezeContainer.Size = UDim2.new(0, 56, 0, 56)
FreezeContainer.Position = savedFreezePos
FreezeContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
FreezeContainer.BorderSizePixel = 0
FreezeContainer.Visible = false
FreezeContainer.Active = true
FreezeContainer.ZIndex = 10
Instance.new("UICorner", FreezeContainer).CornerRadius = UDim.new(0, 10)

local freezeOuterStroke = Instance.new("UIStroke", FreezeContainer)
freezeOuterStroke.Color = Color3.fromRGB(70, 70, 80)
freezeOuterStroke.Thickness = 1.3
freezeOuterStroke.Transparency = 0.15

-- Botón interior (igual que zBtn del Sanguine Z)
FreezeBtn = Instance.new("TextButton")
FreezeBtn.Name = "FreezeTabBtn"
FreezeBtn.Size = UDim2.new(0, 42, 0, 42)
FreezeBtn.Position = UDim2.new(0.5, -21, 0.5, -21)
FreezeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
FreezeBtn.Text = "T"
FreezeBtn.TextSize = 20
FreezeBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
FreezeBtn.Font = Enum.Font.GothamBlack
FreezeBtn.BorderSizePixel = 0
FreezeBtn.AutoButtonColor = false
FreezeBtn.Active = true
FreezeBtn.ZIndex = 11
FreezeBtn.Parent = FreezeContainer
Instance.new("UICorner", FreezeBtn).CornerRadius = UDim.new(0, 8)

local freezeInnerStroke = Instance.new("UIStroke", FreezeBtn)
freezeInnerStroke.Color = Color3.fromRGB(100, 100, 115)
freezeInnerStroke.Thickness = 1
freezeInnerStroke.Transparency = 0.3

-- Drag desde bordes (como Z) + click en el centro
FreezeContainer.Active = true
FreezeContainer.Draggable = true
FreezeContainer:GetPropertyChangedSignal("Position"):Connect(function()
	savedFreezePos = FreezeContainer.Position
end)

local function toggleFreeze()
	if not FreezeEnabled then return end
	isFrozen = not isFrozen
	local char = player.Character
	if char then
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if root and hum then
			root.Anchored = isFrozen
			hum.PlatformStand = isFrozen
			hum.AutoRotate = not isFrozen
		end
	end
	if isFrozen then
		FreezeBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 105)
		FreezeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		FreezeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
		FreezeBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
	end
	applyAllButtonOpacity()
end

-- Solo el centro (T) activa/desactiva
FreezeBtn.MouseButton1Click:Connect(function()
	toggleFreeze()
end)

-- SUPER JUMP BUTTON (J)
SuperJumpContainer = Instance.new("Frame")
SuperJumpContainer.Name = "SuperJumpContainer"
SuperJumpContainer.Size = UDim2.new(0, 56, 0, 56)
SuperJumpContainer.Position = UDim2.new(1, -110, 1, -210) -- junto al salto, mas arriba a la izquierda
SuperJumpContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
SuperJumpContainer.BorderSizePixel = 0
SuperJumpContainer.Visible = false
SuperJumpContainer.Active = true
SuperJumpContainer.Draggable = true
SuperJumpContainer.ZIndex = 10
Instance.new("UICorner", SuperJumpContainer).CornerRadius = UDim.new(0, 10)

do
	local sjStroke = Instance.new("UIStroke", SuperJumpContainer)
	sjStroke.Color = Color3.fromRGB(70, 70, 80)
	sjStroke.Thickness = 1.3
	sjStroke.Transparency = 0.15
end

SuperJumpBtn = Instance.new("TextButton")
SuperJumpBtn.Name = "SuperJumpBtn"
SuperJumpBtn.Size = UDim2.new(0, 42, 0, 42)
SuperJumpBtn.Position = UDim2.new(0.5, -21, 0.5, -21)
SuperJumpBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
SuperJumpBtn.Text = "J"
SuperJumpBtn.TextSize = 20
SuperJumpBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
SuperJumpBtn.Font = Enum.Font.GothamBlack
SuperJumpBtn.BorderSizePixel = 0
SuperJumpBtn.AutoButtonColor = false
SuperJumpBtn.Active = true
SuperJumpBtn.ZIndex = 11
SuperJumpBtn.Parent = SuperJumpContainer
Instance.new("UICorner", SuperJumpBtn).CornerRadius = UDim.new(0, 8)

do
	local sjBtnStroke = Instance.new("UIStroke", SuperJumpBtn)
	sjBtnStroke.Color = Color3.fromRGB(100, 100, 115)
	sjBtnStroke.Thickness = 1
	sjBtnStroke.Transparency = 0.3
end

SuperJumpContainer:GetPropertyChangedSignal("Position"):Connect(function()
	savedSuperJumpPos = SuperJumpContainer.Position
end)

-- Click del boton J: salto potente (~1000 studs)
SuperJumpBtn.MouseButton1Click:Connect(function()
	if not SuperJumpEnabled then return end
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root then return end

	-- v = sqrt(2 * g * h) con g~196.2 y h=1000 => ~626
	-- 1000 studs: v = sqrt(2 * 196.2 * 1000) ≈ 626.4
	local jumpVel = 626.4
	pcall(function()
		root.AssemblyLinearVelocity = Vector3.new(
			root.AssemblyLinearVelocity.X,
			jumpVel,
			root.AssemblyLinearVelocity.Z
		)
	end)
	pcall(function()
		root.Velocity = Vector3.new(root.Velocity.X, jumpVel, root.Velocity.Z)
	end)
	if hum then
		pcall(function()
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end)
	end

	-- feedback visual
	SuperJumpBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 105)
	SuperJumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	task.delay(0.15, function()
		if SuperJumpBtn then
			SuperJumpBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
			SuperJumpBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
		end
	end)
end)

-- AIMBOT
local PlayersPosition = nil
local AimTargetPart = nil
local SoruPosition = nil
local FOVGui, FOVRing, FOVStroke

local function getFOVRadius()
	local cam = workspace.CurrentCamera
	if not cam then return 80 end
	local vp = cam.ViewportSize
	-- 100 = casi toda la pantalla, pequenos huecos en esquinas
	local maxRadius = math.sqrt((vp.X * 0.5) ^ 2 + (vp.Y * 0.5) ^ 2) * 0.92
	local size = FOVSizeEnabled and FOVSize or 50
	return math.max(12, (size / 100) * maxRadius)
end

local function isInsideFOV(screenPos)
	if not FOVCircleEnabled then return true end
	local cam = workspace.CurrentCamera
	if not cam then return true end
	local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
	local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
	return dist <= getFOVRadius()
end

local function ensureFOVGui()
	if FOVGui and FOVGui.Parent then return end
	FOVGui = Instance.new("ScreenGui")
	FOVGui.Name = "SupremacyFOV"
	FOVGui.ResetOnSpawn = false
	FOVGui.IgnoreGuiInset = true
	FOVGui.DisplayOrder = 1
	FOVGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(FOVGui)
			FOVGui.Parent = CoreGui
		elseif gethui then
			FOVGui.Parent = gethui()
		else
			FOVGui.Parent = CoreGui
		end
	end)
	if not FOVGui.Parent then
		FOVGui.Parent = player:WaitForChild("PlayerGui")
	end

	FOVRing = Instance.new("Frame")
	FOVRing.Name = "FOVRing"
	FOVRing.AnchorPoint = Vector2.new(0.5, 0.5)
	FOVRing.Position = UDim2.new(0.5, 0, 0.5, 0)
	FOVRing.Size = UDim2.fromOffset(100, 100)
	FOVRing.BackgroundTransparency = 1
	FOVRing.BorderSizePixel = 0
	FOVRing.Visible = false
	FOVRing.ZIndex = 100
	FOVRing.Parent = FOVGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = FOVRing

	FOVStroke = Instance.new("UIStroke")
	FOVStroke.Thickness = 2
	FOVStroke.Color = FOVCircleColor
	FOVStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	FOVStroke.Parent = FOVRing
end

local function updateFOVCircle()
	local cam = workspace.CurrentCamera
	if not cam then return end

	-- visible si FOV activo y no Hide; debajo del menu para no traspasarlo
	local showRing = FOVCircleEnabled and not FOVHideEnabled

	if FOVCircleEnabled then
		ensureFOVGui()
		if FOVGui then FOVGui.DisplayOrder = 5 end -- debajo del menu, no lo tapa
		local radius = getFOVRadius()
		local diameter = math.floor(radius * 2)
		if FOVRing then
			FOVRing.Size = UDim2.fromOffset(diameter, diameter)
			FOVRing.Visible = showRing
		end
		if FOVStroke then
			FOVStroke.Color = FOVCircleColor
			FOVStroke.Thickness = 2
		end
		pcall(function()
			if not FOVDrawing then
				FOVDrawing = Drawing.new("Circle")
				FOVDrawing.Filled = false
				FOVDrawing.NumSides = 64
				FOVDrawing.Thickness = 2
				FOVDrawing.Transparency = 1
			end
			FOVDrawing.Color = FOVCircleColor
			FOVDrawing.Radius = radius
			FOVDrawing.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
			FOVDrawing.Visible = showRing
		end)
	else
		if FOVRing then FOVRing.Visible = false end
		if FOVDrawing then pcall(function() FOVDrawing.Visible = false end) end
	end
end

RunService.RenderStepped:Connect(function()
	local char = player.Character
	local myHrp = char and char:FindFirstChild("HumanoidRootPart")
	if not myHrp then
		PlayersPosition = nil
		SoruPosition = nil
		AimTargetPart = nil
		Predict.look = nil
		updateFOVCircle()
		return
	end

	local cam = workspace.CurrentCamera
	local maxDist = AimDistanceValue or 1000
	local closestSilentPos, distSilent, closestSilentPart = nil, math.huge, nil
	local closestSoruPos, distSoru, closestSoruPart = nil, math.huge, nil
	local closestAim, distAim = nil, math.huge

	for _, p in pairs(Players:GetPlayers()) do
		-- Pagina WhiteList: no AimBot/Silent/Soru
		if p ~= player and p.Character and not isWhiteListProtected(p) then
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			local targetPart = getAimPart(p.Character)
			if hum and hum.Health > 0 and targetPart then
				local d = (targetPart.Position - myHrp.Position).Magnitude

				-- Soru Aim: siempre al jugador aim (no flashstep libre a otro lado)
				if SoruAimbotEnabled and d < distSoru then
					distSoru = d
					closestSoruPos = targetPart.Position
					closestSoruPart = targetPart
				end

				if d <= maxDist then
					local screenPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
					local inFov = isInsideFOV(screenPos)
					-- Silent Aim: si FOV Circle esta ON, solo si esta dentro del circulo
					if (not FOVCircleEnabled or (onScreen and screenPos.Z > 0 and inFov)) and d < distSilent then
						distSilent = d
						closestSilentPos = targetPart.Position
						closestSilentPart = targetPart
					end
					-- Aimbot camara: visible + dentro del FOV
					if onScreen and screenPos.Z > 0 and inFov and d < distAim then
						distAim = d
						closestAim = targetPart
					end
				end
			end
		end
	end
	-- Predict: solo si boton Predict ON y el rival se mueve
	local function applyPredict(pos, part)
		if not pos then return nil end
		if not Predict.on then return pos end
		local vel = Vector3.zero
		if part then
			pcall(function()
				vel = part.AssemblyLinearVelocity
			end)
		end
		local ox, oy, oz = 0, 0, 0
		if Predict.y > 0 then
			if vel.Y < -2 then
				local t = math.clamp(math.abs(vel.Y) / 40, 0.25, 1)
				oy = -Predict.y * t
			elseif vel.Y > 2 then
				local t = math.clamp(vel.Y / 40, 0.25, 1)
				oy = Predict.y * t
			end
		end
		if Predict.x > 0 then
			local hx, hz = vel.X, vel.Z
			local hm = math.sqrt(hx * hx + hz * hz)
			if hm > 2 then
				local t = math.clamp(hm / 40, 0.25, 1)
				local lead = Predict.x * t
				ox = (hx / hm) * lead
				oz = (hz / hm) * lead
			end
		end
		if ox == 0 and oy == 0 and oz == 0 then return pos end
		return pos + Vector3.new(ox, oy, oz)
	end
	PlayersPosition = applyPredict(closestSilentPos, closestSilentPart)
	SoruPosition = applyPredict(closestSoruPos, closestSoruPart)
	AimTargetPart = closestAim
	if closestAim and closestAim.Parent then
		Predict.look = applyPredict(closestAim.Position, closestAim)
	else
		Predict.look = nil
	end
	updateFOVCircle()
end)

-- Camara aimbot: SOLO rota hacia el rival. No pelea el zoom del jugador.
-- Raycast para no atravesar suelo/paredes/casas.
local _aimRayParams = RaycastParams.new()
_aimRayParams.FilterType = Enum.RaycastFilterType.Exclude
_aimRayParams.IgnoreWater = true

RunService:BindToRenderStep("SupremacyAimbot", Enum.RenderPriority.Camera.Value + 1, function()
	if not AimbotEnabled then return end
	if _menuHold then return end
	local target = AimTargetPart
	if not target or not target.Parent then return end

	local cam = workspace.CurrentCamera
	if not cam then return end
	if cam.CameraType == Enum.CameraType.Scriptable then return end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local focus = root.Position + Vector3.new(0, 1.5, 0)
	local targetPos = Predict.look or target.Position
	local toTarget = targetPos - focus
	if toTarget.Magnitude < 2 then return end

	-- Distancia EXACTA que el jugador ya tiene (pinch/zoom libre, sin forzar)
	local camPos = cam.CFrame.Position
	local zoom = (camPos - focus).Magnitude
	if zoom < 0.5 then zoom = 12 end
	local minZ, maxZ = 0.5, 128
	pcall(function()
		minZ = cam.CameraMinZoomDistance or 0.5
		maxZ = cam.CameraMaxZoomDistance or 128
	end)
	zoom = math.clamp(zoom, minZ, maxZ)

	local lookDir = toTarget.Unit
	local desiredPos = focus - lookDir * zoom

	-- Colision: no traspasar suelo/casas/paredes
	pcall(function()
		_aimRayParams.FilterDescendantsInstances = { char }
		local delta = desiredPos - focus
		local hit = workspace:Raycast(focus, delta, _aimRayParams)
		if hit then
			desiredPos = hit.Position + hit.Normal * 1.2
			-- mantener distancia razonable tras el hit
			local d = (desiredPos - focus).Magnitude
			if d < 2 then
				desiredPos = focus - lookDir * 2
			end
		end
	end)

	local alpha
	if SmoothingEnabled then
		alpha = math.clamp(AimbotSmooth / 100, 0.04, 0.9)
	else
		alpha = 0.75
	end

	-- Solo orientacion + posicion colisionada; NO tocar CameraMin/Max ni forzar zoom
	local goal = CFrame.lookAt(desiredPos, targetPos)
	cam.CFrame = cam.CFrame:Lerp(goal, alpha)
end)

local mouse = player:GetMouse()

-- SORU AIM (Hit only, safe)
pcall(function()
	local mt = getrawmetatable(mouse)
	if not mt then return end
	local oldIndex = mt.__index
	setreadonly(mt, false)
	local function indexHook(self, key)
		if key == "Hit" and SoruAimbotEnabled and SoruPosition then
			local ok, cf = pcall(CFrame.new, SoruPosition)
			if ok and cf then return cf end
		end
		if type(oldIndex) == "function" then
			return oldIndex(self, key)
		elseif type(oldIndex) == "table" then
			return oldIndex[key]
		end
		return nil
	end
	mt.__index = (newcclosure and newcclosure(indexHook)) or indexHook
	setreadonly(mt, true)
end)

-- SILENT AIM (solo remotes de combate)
-- No toca mouse.Hit → no auto-apunta el Soru/TP
pcall(function()
	local mt = getrawmetatable(game)
	local oldNamecall = mt.__namecall
	setreadonly(mt, false)

	local function shouldSkipRemote(remote)
		if not remote then return false end
		local n = string.lower(tostring(remote.Name or ""))
		if n == "" then return false end
		-- movilidad / TP
		if string.find(n, "soru") or string.find(n, "teleport") or string.find(n, "dash")
			or string.find(n, "flash") or string.find(n, "blink") or string.find(n, "warp")
			or string.find(n, "portal") or string.find(n, "travel") or n == "tp" then
			return true
		end
		-- M1 / basic attacks (gun, fighting style, sword, etc.) → SIN aim
		-- Solo skills deben recibir Silent Aim
		if string.find(n, "m1") or string.find(n, "leftclick") or string.find(n, "mouse1")
			or string.find(n, "left.?click") or string.find(n, "shoot") or string.find(n, "bullet")
			or string.find(n, "projectile") or string.find(n, "tap") or string.find(n, "punch")
			or string.find(n, "slash") or string.find(n, "swing") or string.find(n, "melee")
			or string.find(n, "basic") or string.find(n, "normalattack") or string.find(n, "normal_attack")
			or string.find(n, "gun") or n == "combat" or string.find(n, "click") then
			return true
		end
		return false
	end

	local function namecallHook(self, ...)
		local method = getnamecallmethod()
		local n = select("#", ...)
		local args = {...}

		-- Aimbot: Camlock solo si esta en pantalla; Aim pega aunque no lo mires
		-- PlayersPosition = rival en rango (FOV si esta activo)
		local aimPos = nil
		if AimbotEnabled then
			if PlayersPosition then
				aimPos = PlayersPosition
			elseif AimTargetPart and AimTargetPart.Parent then
				aimPos = AimTargetPart.Position
			end
		elseif SilentAimEnabled and PlayersPosition then
			aimPos = PlayersPosition
		end
		if aimPos and (method == "FireServer" or method == "InvokeServer") then
			if checkcaller and checkcaller() then
				return oldNamecall(self, ...)
			end
			if shouldSkipRemote(self) then
				return oldNamecall(self, ...)
			end
			if n <= 3 then
				for i = 1, n do
					local v = args[i]
					if typeof(v) == "Vector3" then
						args[i] = aimPos
						return oldNamecall(self, unpack(args, 1, n))
					elseif typeof(v) == "CFrame" then
						args[i] = CFrame.new(aimPos)
						return oldNamecall(self, unpack(args, 1, n))
					end
				end
			end
		end

		return oldNamecall(self, ...)
	end

	mt.__namecall = (newcclosure and newcclosure(namecallHook)) or namecallHook
	setreadonly(mt, true)
end)


-- AIMBOT BUTTON
AimbotBtn = Instance.new("TextButton")
AimbotBtn.Name = "AimbotFollowBtn"
AimbotBtn.Size = UDim2.new(0, 52, 0, 52)
AimbotBtn.Position = savedAimbotPos
AimbotBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AimbotBtn.Text = "AB"
AimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotBtn.TextSize = 16
AimbotBtn.Font = Enum.Font.GothamBold
AimbotBtn.BorderSizePixel = 0
AimbotBtn.Visible = false
AimbotBtn.AutoButtonColor = false
AimbotBtn.Active = true
AimbotBtn.ZIndex = 10
Instance.new("UICorner", AimbotBtn).CornerRadius = UDim.new(0, 10)

local abDragging, abDragStart, abStartPos, abDragInput, abMoved = false, nil, nil, nil, false
AimbotBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		abDragging = true abMoved = false abDragStart = input.Position abStartPos = AimbotBtn.Position
	end
end)
AimbotBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then abDragInput = input end
end)
UIS.InputChanged:Connect(function(input)
	if abDragging and input == abDragInput then
		local delta = input.Position - abDragStart
		if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then abMoved = true end
		AimbotBtn.Position = UDim2.new(abStartPos.X.Scale, abStartPos.X.Offset + delta.X, abStartPos.Y.Scale, abStartPos.Y.Offset + delta.Y)
		savedAimbotPos = AimbotBtn.Position
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then abDragging = false end
end)

AimbotBtn.MouseButton1Click:Connect(function()
	if abMoved then abMoved = false return end
	if not AimbotButtonEnabled then return end
	AimbotEnabled = not AimbotEnabled
	AimbotBtn.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(180, 180, 180) or Color3.fromRGB(40, 40, 40)
	applyAllButtonOpacity()
end)

-- PREDICT BUTTON (mismo diseño que Freeze / Super Jump)
;(function()
	local container = Instance.new("Frame")
	container.Name = "PredictContainer"
	container.Size = UDim2.new(0, 56, 0, 56)
	container.Position = Predict.pos
	container.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	container.BorderSizePixel = 0
	container.Visible = false
	container.Active = true
	container.Draggable = true
	container.ZIndex = 10
	Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
	local outerStroke = Instance.new("UIStroke", container)
	outerStroke.Color = Color3.fromRGB(70, 70, 80)
	outerStroke.Thickness = 1.3
	outerStroke.Transparency = 0.15

	local btn = Instance.new("TextButton")
	btn.Name = "PredictBtn"
	btn.Size = UDim2.new(0, 42, 0, 42)
	btn.Position = UDim2.new(0.5, -21, 0.5, -21)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	btn.Text = "P"
	btn.TextSize = 20
	btn.TextColor3 = Color3.fromRGB(220, 220, 230)
	btn.Font = Enum.Font.GothamBlack
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Active = true
	btn.ZIndex = 11
	btn.Parent = container
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	local innerStroke = Instance.new("UIStroke", btn)
	innerStroke.Color = Color3.fromRGB(100, 100, 115)
	innerStroke.Thickness = 1
	innerStroke.Transparency = 0.3

	Predict.container = container
	Predict.btn = btn

	container:GetPropertyChangedSignal("Position"):Connect(function()
		Predict.pos = container.Position
	end)

	local lastTap = 0
	local function togglePredict()
		local now = tick()
		if now - lastTap < 0.2 then return end
		lastTap = now
		if not Predict.keyOn then return end
		Predict.on = not Predict.on
		if Predict.on then
			btn.BackgroundColor3 = Color3.fromRGB(90, 90, 105)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
			btn.TextColor3 = Color3.fromRGB(220, 220, 230)
		end
		applyAllButtonOpacity()
	end
	_G.SupremacyTogglePredict = togglePredict
	btn.MouseButton1Click:Connect(togglePredict)
	btn.Activated:Connect(togglePredict)
	-- Parent se asigna cuando exista ScreenGui (abajo)
end)()

-- SUPER DASH / NOCLIP / ANTI LAVA
local SuperDashRunning = false
local function startSuperDash()
	SuperDashEnabled = true
	if SuperDashRunning then return end
	SuperDashRunning = true
	task.spawn(function()
		while SuperDashEnabled do
			local char = player.Character
			if char then pcall(function() char:SetAttribute("DashLength", SuperDashSpeed) char:SetAttribute("DashLengthAir", SuperDashSpeed) end) end
			task.wait(0.1)
		end
		SuperDashRunning = false
	end)
end
local function stopSuperDash()
	SuperDashEnabled = false
	local char = player.Character
	if char then pcall(function() char:SetAttribute("DashLength", 1) char:SetAttribute("DashLengthAir", 1) end) end
end

local function handleNoclip(v)
	NoclipEnabled = v
	if v then
		if noclipConn then noclipConn:Disconnect() end
		noclipConn = RunService.Stepped:Connect(function()
			local char = player.Character
			if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end
		end)
	else
		if noclipConn then noclipConn:Disconnect() noclipConn = nil end
	end
end

local function handleAntiLava(v)
	AntiLavaEnabled = v
	if v then
		if antiLavaConn then antiLavaConn:Disconnect() end
		antiLavaConn = RunService.Stepped:Connect(function()
			local char = player.Character
			if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanTouch = false end end end
		end)
	else
		if antiLavaConn then antiLavaConn:Disconnect() antiLavaConn = nil end
		local char = player.Character
		if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanTouch = true end end end
	end
end

player.CharacterAdded:Connect(function(char)
	task.wait(1)
	if not SuperDashEnabled then pcall(function() char:SetAttribute("DashLength", 1) char:SetAttribute("DashLengthAir", 1) end) end
end)

-- UI
local function Create(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props) do obj[k] = v end
	return obj
end

local function ProtectGui(gui)
	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
			gui.Parent = CoreGui
		elseif gethui then
			gui.Parent = gethui()
		else
			gui.Parent = CoreGui
		end
	end)
	if not gui.Parent then
		gui.Parent = player:WaitForChild("PlayerGui")
	end
	print("[Supremacy] ScreenGui parent:", tostring(gui.Parent))
end

pcall(function()
	local function nuke(p)
		if p and p:FindFirstChild("SupremacyHub") then p.SupremacyHub:Destroy() end
	end
	nuke(game:GetService("CoreGui"))
	nuke(player:FindFirstChild("PlayerGui"))
	pcall(function() if gethui then nuke(gethui()) end end)
	-- NO desbindar Aimbot aqui: eso mataba el camlock al abrir el menu
end)

local ScreenGui = Create("ScreenGui", {
	Name = "SupremacyHub",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	IgnoreGuiInset = true,
	DisplayOrder = 50
})
ProtectGui(ScreenGui)
_G.SupremacyScreenGui = ScreenGui
FreezeContainer.Parent = ScreenGui
pcall(function() if SuperJumpContainer then SuperJumpContainer.Parent = ScreenGui end end)
AimbotBtn.Parent = ScreenGui
pcall(function()
	if Predict.container then
		Predict.container.Parent = ScreenGui
		Predict.container.Visible = Predict.keyOn and true or false
	end
end)

OpenBtn = Create("ImageButton", {
	Size = UDim2.new(0, 42, 0, 42),
	Position = UDim2.new(0, 12, 0, 70),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Image = "rbxassetid://128357067597318",
	ScaleType = Enum.ScaleType.Fit,
	Parent = ScreenGui,
	AutoButtonColor = false,
	Active = true,
	ZIndex = 15
})


local openDragging, openMoved, openDragStart, openStartPos, openDragInput = false, false, nil, nil, nil
OpenBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		openDragging = true openMoved = false openDragStart = input.Position openStartPos = OpenBtn.Position
	end
end)
OpenBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then openDragInput = input end
end)
UIS.InputChanged:Connect(function(input)
	if openDragging and input == openDragInput then
		local delta = input.Position - openDragStart
		if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then openMoved = true end
		OpenBtn.Position = UDim2.new(openStartPos.X.Scale, openStartPos.X.Offset + delta.X, openStartPos.Y.Scale, openStartPos.Y.Offset + delta.Y)
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then openDragging = false end
end)

Main = Create("Frame", {
	Name = "Main",
	Size = UDim2.new(0, 500, 0, 295),
	Position = UDim2.new(0.5, -250, 0.5, -147),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Visible = false,
	ClipsDescendants = true,
	ZIndex = 20,
	Parent = ScreenGui
})

Create("ImageLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Image = "rbxassetid://137715018178430",
	ScaleType = Enum.ScaleType.Fit,
	ZIndex = 1,
	Parent = Main
})

local Header = Create("Frame", {
	Size = UDim2.new(1, -50, 0, 26),
	Position = UDim2.new(0, 32, 0, 8),
	BackgroundTransparency = 1,
	ZIndex = 30,
	Parent = Main
})

Create("TextLabel", {
	Size = UDim2.new(0, 130, 1, 0),
	BackgroundTransparency = 1,
	Text = "Supremacy",
	Font = Enum.Font.GothamBold,
	TextSize = 15,
	TextColor3 = TEXT_LABEL,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 31,
	Parent = Header
})

-- Discord (logo + círculo negro pequeño)
local DiscordCircle = Create("Frame", {
	Size = UDim2.new(0, 26, 0, 26),
	Position = UDim2.new(1, -78, 0.5, -13),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
	ZIndex = 34,
	Parent = Header
})
Instance.new("UICorner", DiscordCircle).CornerRadius = UDim.new(1, 0)

local DiscordBtn = Create("ImageButton", {
	Size = UDim2.new(0, 22, 0, 22),
	Position = UDim2.new(1, -76, 0.5, -11),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Image = "rbxassetid://100811421674645",
	ImageColor3 = Color3.fromRGB(255, 255, 255),
	ScaleType = Enum.ScaleType.Fit,
	AutoButtonColor = true,
	ZIndex = 40,
	Parent = Header
})

-- texto encima de TODO + borde negro
local DiscordCopiedLabel = Create("TextLabel", {
	Size = UDim2.new(0, 160, 0, 20),
	Position = UDim2.new(0.5, -80, 0, 8),
	BackgroundTransparency = 1,
	Text = "Discord link copied",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextTransparency = 1,
	TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
	TextStrokeTransparency = 0,
	ZIndex = 200,
	Parent = ScreenGui
})

local MinBtn = Create("TextButton", {
	Size = UDim2.new(0, 22, 0, 22),
	Position = UDim2.new(1, -46, 0.5, -11),
	BackgroundTransparency = 1,
	Text = "−",
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	TextColor3 = RED_BTN,
	ZIndex = 31,
	Parent = Header
})

local CloseBtn = Create("TextButton", {
	Size = UDim2.new(0, 22, 0, 22),
	Position = UDim2.new(1, -22, 0.5, -11),
	BackgroundTransparency = 1,
	Text = "×",
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	TextColor3 = RED_BTN,
	ZIndex = 31,
	Parent = Header
})

DiscordBtn.MouseButton1Click:Connect(function()
	local url = "https://discord.gg/WVTC2XfCq5"
	pcall(function()
		if setclipboard then setclipboard(url)
		elseif toclipboard then toclipboard(url)
		elseif Clipboard and Clipboard.set then Clipboard.set(url)
		end
	end)
	-- mostrar texto
	DiscordCopiedLabel.Text = tr("Discord link copied")
	DiscordCopiedLabel.TextTransparency = 0
	task.delay(2, function()
		if DiscordCopiedLabel then
			TweenService:Create(DiscordCopiedLabel, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
		end
	end)
end)

MinBtn.MouseButton1Click:Connect(function() Main.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
	if lagGui then lagGui:Destroy() end
	ClearESPBoxes()
	if FOVDrawing then pcall(function() FOVDrawing:Remove() end) FOVDrawing = nil end
	pcall(function() RunService:UnbindFromRenderStep("SupremacyAimbot") end)
end)

OpenBtn.MouseButton1Click:Connect(function()
	if openMoved then openMoved = false return end
	Main.Visible = not Main.Visible
end)

local TabsFrame = Create("Frame", {
	Size = UDim2.new(0, 70, 1, -50),
	Position = UDim2.new(0, 18, 0, 40),
	BackgroundTransparency = 1,
	ZIndex = 30,
	Parent = Main
})
Create("UIListLayout", {
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	Parent = TabsFrame
})

local Content = Create("ScrollingFrame", {
	Size = UDim2.new(0, 400, 1, -52),
	Position = UDim2.new(0, 90, 0, 40),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 4,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ClipsDescendants = true,
	ZIndex = 30,
	Parent = Main
})
Create("UIListLayout", {
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = Content
})
Create("UIPadding", {
	PaddingRight = UDim.new(0, 16),
	PaddingBottom = UDim.new(0, 12),
	Parent = Content
})

local Pages = {}
local TabButtons = {}
local partDropdown, dropdownFrame, chooseTeamRow, selectLabel, dropdownShouldBeOpen, dropdownUpdateConn

local function CreateTab(name, order)
	local btn = Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = name,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = TEXT_DIM,
		TextXAlignment = Enum.TextXAlignment.Center,
		LayoutOrder = order,
		ZIndex = 32,
		Parent = TabsFrame
	})
	TabButtons[name] = btn
	btn.MouseButton1Click:Connect(function()
		for n, t in pairs(TabButtons) do t.TextColor3 = TEXT_DIM end
		btn.TextColor3 = TEXT_SELECTED
		for n, page in pairs(Pages) do page.Visible = (n == name) end
		pcall(function()
			Content.CanvasPosition = Vector2.new(0, 0)
		end)
		if _G.SupremacyCloseDropdowns then
			_G.SupremacyCloseDropdowns()
		end
		-- Put Key NO se cierra al cambiar pagina (solo con OK)
	end)
end

CreateTab("AimBot", 1)
CreateTab("Visual", 2)
CreateTab("Misc", 3)
CreateTab("Fps", 4)
CreateTab("WhiteList", 5)
CreateTab("Config", 6)
TabButtons["AimBot"].TextColor3 = TEXT_SELECTED

local function CreatePage(name)
	local page = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = (name == "AimBot"),
		ZIndex = 31,
		Parent = Content
	})
	Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = page
	})
	Pages[name] = page
	return page
end

-- TRIGGERS JUSTO AL BORDE (sin cortar)
-- LANGUAGE
_G.SupremacyLang = _G.SupremacyLang or "English"
_G.SupremacyLangLabels = {}
local LANG_DICT = {
	-- Tabs
	["AimBot"] = { en = "AimBot", es = "AimBot" },
	["Visual"] = { en = "Visual", es = "Visual" },
	["Misc"] = { en = "Misc", es = "Misc" },
	["Fps"] = { en = "Fps", es = "Fps" },
	["WhiteList"] = { en = "WhiteList", es = "WhiteList" },
	["Config"] = { en = "Config", es = "Config" },
	-- AimBot
	["Aimbot"] = { en = "Aimbot", es = "Aimbot" },
	["Aimbot Key"] = { en = "Aimbot Key", es = "Tecla Aimbot" },
	["Smoothing"] = { en = "Smoothing", es = "Suavizado" },
	["FOV Circle"] = { en = "FOV Circle", es = "Circulo FOV" },
	["FOV Hide"] = { en = "FOV Hide", es = "Ocultar FOV" },
	["FOV Size"] = { en = "FOV Size", es = "Tamano FOV" },
	["Silent Aim"] = { en = "Silent Aim", es = "Aim Silencioso" },
	["Soru Aim"] = { en = "Soru Aim", es = "Aim Soru" },
	["Predict"] = { en = "Predict", es = "Prediccion" },
	["Predict Y"] = { en = "Predict Y", es = "Prediccion Y" },
	["Predict X"] = { en = "Predict X", es = "Prediccion X" },
	["Select Part"] = { en = "Select Part", es = "Elegir Parte" },
	["Aim Distance"] = { en = "Aim Distance", es = "Distancia Aim" },
	-- Visual
	["ESP Box"] = { en = "ESP Box", es = "Caja ESP" },
	["ESP Filled"] = { en = "ESP Filled", es = "ESP Relleno" },
	["ESP Type"] = { en = "ESP Type", es = "Tipo ESP" },
	["ESP Name"] = { en = "ESP Name", es = "Nombre ESP" },
	["ESP Distance"] = { en = "ESP Distance", es = "Distancia ESP" },
	["ESP Health"] = { en = "ESP Health", es = "Vida ESP" },
	["ESP SnapLine"] = { en = "ESP SnapLine", es = "Linea ESP" },
	["ESP Antenna"] = { en = "ESP Antenna", es = "Antena ESP" },
	["Limit Distance"] = { en = "Limit Distance", es = "Limite Distancia" },
	["NPC Check"] = { en = "NPC Check", es = "Check NPC" },
	["Health Check"] = { en = "Health Check", es = "Check Vida" },
	-- Misc
	["Sanguine Z Boost"] = { en = "Sanguine Z Boost", es = "Sanguine Z Boost" },
	["Tab (Freeze)"] = { en = "Tab (Freeze)", es = "Tab (Congelar)" },
	["Super Jump"] = { en = "Super Jump", es = "Super Salto" },
	["Fly"] = { en = "Fly", es = "Volar" },
	["Super Dash"] = { en = "Super Dash", es = "Super Dash" },
	["Noclip"] = { en = "Noclip", es = "Noclip" },
	["Anti Lava"] = { en = "Anti Lava", es = "Anti Lava" },
	["Infinite Jump"] = { en = "Infinite Jump", es = "Salto Infinito" },
	["Safe Zone"] = { en = "Safe Zone", es = "Zona Segura" },
	-- Fps (traducidos de verdad)
	["Fast Flags"] = { en = "Fast Flags", es = "Banderas Rapidas" },
	["Fast Flags 2"] = { en = "Fast Flags 2", es = "Banderas Rapidas 2" },
	["Fast Flags 3"] = { en = "Fast Flags 3", es = "Banderas Rapidas 3" },
	["Structure Texture"] = { en = "Structure Texture", es = "Textura Estructuras" },
	["No Shadows"] = { en = "No Shadows", es = "Sin Sombras" },
	["No Particles"] = { en = "No Particles", es = "Sin Particulas" },
	["No Fog"] = { en = "No Fog", es = "Sin Niebla" },
	-- Config
	["File Manager"] = { en = "File Manager", es = "Gestor de Archivos" },
	["Language Menu"] = { en = "Language Menu", es = "Idioma del Menu" },
	["Open"] = { en = "Open", es = "Abrir" },
	["Button Opacity"] = { en = "Button Opacity", es = "Opacidad Botones" },
	["Menu Button"] = { en = "Menu Button", es = "Boton Menu" },
	["Click Sound"] = { en = "Click Sound", es = "Sonido Click" },
	["Crosshair"] = { en = "Crosshair", es = "Mira" },
	["Assistant"] = { en = "Assistant", es = "Asistente" },
	["Camera Zoom"] = { en = "Camera Zoom", es = "Zoom Camara" },
	["Pc Format"] = { en = "Pc Format", es = "Formato PC" },
	["Hide Skills"] = { en = "Hide Skills", es = "Ocultar Skills" },
	["Hide Use"] = { en = "Hide Use", es = "Ocultar Use" },
	["Slots Mini"] = { en = "Slots Mini", es = "Slots Mini" },
	["Hide Gun Cursor"] = { en = "Hide Gun Cursor", es = "Ocultar Mira Arma" },
	["Gui Mini"] = { en = "Gui Mini", es = "Gui Mini" },
	["Refresh"] = { en = "Refresh", es = "Actualizar" },
	["English"] = { en = "English", es = "Ingles" },
	["Spanish"] = { en = "Spanish", es = "Español" },
	["Enable Assistant"] = { en = "Enable Assistant", es = "Activar Asistente" },
	["Voice Assistant"] = { en = "Voice Assistant", es = "Voz Asistente" },
	["Sense Sound"] = { en = "Sense Sound", es = "Sonido Sense" },
	["Observe player"] = { en = "Observe player", es = "Observar jugador" },
	["Save"] = { en = "Save", es = "Guardar" },
	["Cancel"] = { en = "Cancel", es = "Cancelar" },
	["Delete"] = { en = "Delete", es = "Eliminar" },
	["Export"] = { en = "Export", es = "Exportar" },
	["Accept"] = { en = "Accept", es = "Aceptar" },
	["None"] = { en = "None", es = "Ninguno" },
	["Select Part"] = { en = "Select Part", es = "Elegir Parte" },
	["Select"] = { en = "Select", es = "Elegir" },
	["Head"] = { en = "Head", es = "Cabeza" },
	["Torso"] = { en = "Torso", es = "Torso" },
	["HumanoidRootPart"] = { en = "HumanoidRootPart", es = "HumanoidRootPart" },
	["Buscar jugador..."] = { en = "Search player...", es = "Buscar jugador..." },
	["Search player..."] = { en = "Search player...", es = "Buscar jugador..." },
	["Pick a Color"] = { en = "Pick a Color", es = "Elegir Color" },
	["Configuration name:"] = { en = "Configuration name:", es = "Nombre de configuracion:" },
	["Discord link copied"] = { en = "Discord link copied", es = "Link de Discord copiado" },
	["Put Key"] = { en = "Put Key", es = "Poner Tecla" },
	["Sense Prediction"] = { en = "Sense Prediction", es = "Prediccion Sense" },
	["No disappearance"] = { en = "No disappearance", es = "No Desaparecer" },
	["Enemy Nearby"] = { en = "Enemy Nearby", es = "Enemigo Cerca" },
	["Enemy Distance"] = { en = "Enemy Distance", es = "Distancia Enemigo" },
	["Low HP Alert"] = { en = "Low HP Alert", es = "Alerta Vida Baja" },
	["PvP Indicator"] = { en = "PvP Indicator", es = "Indicador PvP" },
	["Practice"] = { en = "Practice", es = "Practica" },
	["Introducir Habilidad"] = { en = "Enter Skill", es = "Introducir Habilidad" },
	["Enter Skill"] = { en = "Enter Skill", es = "Introducir Habilidad" },
	["Loading"] = { en = "Loading", es = "Cargando" },
	["WL_INFO"] = {
		en = "When you select a player, AimBot and Visual will not affect them.",
		es = "Al seleccionar un jugador, AimBot y Visual no le afectaran.",
	},
	["Type"] = { en = "Type", es = "Type" },
	["Mech"] = { en = "Mech", es = "Mech" },
	["Crosshair 1"] = { en = "Crosshair 1", es = "Mira 1" },
	["General"] = { en = "General", es = "General" },
	["Combat"] = { en = "Combat", es = "Combate" },
	["PvP Practice"] = { en = "PvP Practice", es = "Practica PvP" },
	["HP Threshold"] = { en = "HP Threshold", es = "Umbral de Vida" },
	["PvP Distance"] = { en = "PvP Distance", es = "Distancia PvP" },
	["Practice Combos"] = { en = "Practice Combos", es = "Practicar Combos" },
	["Skill:"] = { en = "Skill:", es = "Habilidad:" },
	["Skill"] = { en = "Skill", es = "Habilidad" },
	["Voice 1"] = { en = "Voice 1", es = "Voz 1" },
	["Voice 2"] = { en = "Voice 2", es = "Voz 2" },
}


local function tr(key)
	local e = LANG_DICT[key]
	if not e then return tostring(key or "") end
	if _G.SupremacyLang == "Spanish" then return e.es or e.en or key end
	return e.en or key
end
_G.SupremacyTr = tr
local function registerLangLabel(key, label)
	if key and label then
		_G.SupremacyLangLabels[key] = label
		pcall(function() label.Text = tr(key) end)
	end
end
local function applyLanguage(lang)
	if lang ~= "Spanish" then lang = "English" end
	_G.SupremacyLang = lang
	-- 1) labels registrados
	for key, label in pairs(_G.SupremacyLangLabels) do
		pcall(function() if label and label.Parent then label.Text = tr(key) end end)
	end
	-- 2) tabs
	pcall(function()
		for name, btn in pairs(TabButtons or {}) do
			if btn then btn.Text = tr(name) end
		end
	end)
	-- 3) dropdown idioma
	pcall(function()
		if _G.SupremacyLangDropButtons then
			for key, btn in pairs(_G.SupremacyLangDropButtons) do
				if btn and btn.Parent then
					btn.Text = tr(key)
					btn.BackgroundColor3 = (key == lang) and Color3.fromRGB(200,200,200) or Color3.fromRGB(40,40,40)
				end
			end
		end
	end)
	pcall(function()
		if _G.SupremacyLangCurrentBtn then
			_G.SupremacyLangCurrentBtn.Text = tr(lang)
		end
	end)
	-- 4) WhiteList
	pcall(function()
		if _G.SupremacyWLSearch then
			_G.SupremacyWLSearch.PlaceholderText = tr("Buscar jugador...")
		end
		if _G.SupremacyWLRefresh then
			_G.SupremacyWLRefresh.Text = tr("Refresh")
		end
	end)
	pcall(function()
		if _G.SupremacySkillPlaceholder then
			_G.SupremacySkillPlaceholder.PlaceholderText = tr("Introducir Habilidad")
		end
	end)
	-- 5) FALLBACK: cualquier TextLabel del menu cuyo Text sea una key conocida
	pcall(function()
		local sg = _G.SupremacyScreenGui
		if not sg then return end
		for _, d in ipairs(sg:GetDescendants()) do
			if d:IsA("TextLabel") or d:IsA("TextButton") then
				local t = d.Text
				if t and LANG_DICT[t] then
					-- el texto actual es una key EN o ES: re-traducir desde key
					-- buscar key por valor actual
					for key, entry in pairs(LANG_DICT) do
						if entry.en == t or entry.es == t or key == t then
							d.Text = tr(key)
							break
						end
					end
				else
					-- texto puede ya estar traducido: match by either lang value
					for key, entry in pairs(LANG_DICT) do
						if entry.en == t or entry.es == t then
							d.Text = tr(key)
							break
						end
					end
				end
			end
		end
	end)
	pcall(function()
		if _G.SupremacyRelocalizeAssistant then _G.SupremacyRelocalizeAssistant() end
	end)
end
_G.SupremacyApplyLanguage = applyLanguage

local function CreateToggle(parent, text, default, callback)

	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		ZIndex = 200,
		Parent = parent
	})
	local nameLbl = Create("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = TEXT_LABEL,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 201,
		Parent = row
	})
	registerLangLabel(text, nameLbl)
	local toggle = Create("Frame", {
		Size = UDim2.new(0, 28, 0, 12),
		Position = UDim2.new(1, -44, 0.5, -6), -- alineado a la linea blanca
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		BorderSizePixel = 0,
		ZIndex = 202,
		Parent = row
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggle})
	local ball = Create("Frame", {
		Size = UDim2.new(0, 8, 0, 8),
		Position = UDim2.new(0, 2, 0.5, -4),
		BackgroundColor3 = Color3.fromRGB(120, 120, 120),
		BorderSizePixel = 0,
		ZIndex = 203,
		Parent = toggle
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ball})

	local state = default
	local function Update(fromClick)
		if state then
			TweenService:Create(ball, TweenInfo.new(0.15), {Position = UDim2.new(0, 18, 0.5, -4), BackgroundColor3 = TOGGLE_ON}):Play()
		else
			TweenService:Create(ball, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -4), BackgroundColor3 = Color3.fromRGB(120, 120, 120)}):Play()
		end
		if callback then
			local s = state
			-- callback al siguiente frame: la animacion se ve, sin lag en el click
			task.delay(0, function()
				pcall(callback, s)
			end)
		end
	end
	Update(false)
	_G.SupremacyToggleUpdates = _G.SupremacyToggleUpdates or {}
	_G.SupremacyToggleUpdates[text] = function(newState)
		state = newState and true or false
		if state then
			TweenService:Create(ball, TweenInfo.new(0.12), {Position = UDim2.new(0, 18, 0.5, -4), BackgroundColor3 = TOGGLE_ON}):Play()
		else
			TweenService:Create(ball, TweenInfo.new(0.12), {Position = UDim2.new(0, 2, 0.5, -4), BackgroundColor3 = Color3.fromRGB(120, 120, 120)}):Play()
		end
	end
	local btn = Create("TextButton", {
		Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 204,
		Parent = toggle
	})
	btn.MouseButton1Click:Connect(function()
		state = not state
		Update(true)
	end)
	return row
end

local function CreateColorPicker(parent, defaultColor, onColorChanged)
	local picker = Create("TextButton", {
		Size = UDim2.new(0, 11, 0, 11),
		BackgroundColor3 = defaultColor or Color3.fromHex("#222222"),
		Text = "",
		BorderSizePixel = 0,
		AutoButtonColor = false,
		ZIndex = 202,
		Parent = parent
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = picker})
	local pickerStroke = Instance.new("UIStroke")
	pickerStroke.Thickness = 1
	pickerStroke.Color = Color3.fromRGB(80, 80, 80)
	pickerStroke.Parent = picker

	picker.MouseButton1Click:Connect(function()
		-- dentro del menu Main
		local oldColor = picker.BackgroundColor3
		local selectedColor = oldColor

		local frame = Instance.new("Frame")
		frame.Name = "ColorMenu"
		frame.Size = UDim2.new(0, 230, 0, 185)
		frame.Position = UDim2.new(0.5, -115, 0.5, -92)
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BorderSizePixel = 0
		frame.ZIndex = 200
		frame.Parent = Main
		local frameStroke = Instance.new("UIStroke", frame)
		frameStroke.Color = Color3.fromRGB(180, 180, 180)
		frameStroke.Thickness = 1
		-- destruir otro color menu si existe
		for _, c in pairs(Main:GetChildren()) do
			if c.Name == "ColorMenu" and c ~= frame then c:Destroy() end
		end

		local titleLbl = Instance.new("TextLabel")
		titleLbl.ZIndex = 201
		titleLbl.Size = UDim2.new(1, 0, 0, 28)
		titleLbl.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
		titleLbl.BorderSizePixel = 0
		titleLbl.Text = "Pick a Color"
		titleLbl.TextColor3 = Color3.fromRGB(20, 20, 20)
		titleLbl.Font = Enum.Font.GothamBold
		titleLbl.TextSize = 15
		titleLbl.Parent = frame

		local colors = {
			Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 128, 0), Color3.fromRGB(255, 255, 0),
			Color3.fromRGB(0, 255, 0), Color3.fromHex("#00FAFF"), Color3.fromRGB(80, 160, 255),
			Color3.fromRGB(200, 80, 255), Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0),
			Color3.fromRGB(120, 120, 120), Color3.fromRGB(255, 105, 180), Color3.fromRGB(255, 20, 147)
		}

		local startX = 19
		local startY = 36
		local spacing = 34
		local selectedStroke
		for i, color in ipairs(colors) do
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0, 30, 0, 30)
			local col = (i - 1) % 6
			local row = math.floor((i - 1) / 6)
			btn.Position = UDim2.new(0, startX + col * spacing, 0, startY + row * 36)
			btn.BackgroundColor3 = color
			btn.Text = ""
			btn.AutoButtonColor = false
			btn.ZIndex = 201
			btn.Parent = frame

			local stroke = Instance.new("UIStroke", btn)
			stroke.Thickness = 2
			stroke.Color = Color3.fromRGB(50, 50, 50)
			if color == oldColor then selectedStroke = stroke stroke.Color = Color3.fromRGB(30, 30, 30) stroke.Thickness = 3 end
			btn.MouseButton1Click:Connect(function()
				selectedColor = color
				if selectedStroke then selectedStroke.Color = Color3.fromRGB(50, 50, 50) selectedStroke.Thickness = 2 end
				selectedStroke = stroke
				stroke.Color = Color3.fromRGB(30, 30, 30)
				stroke.Thickness = 3
			end)
		end

		local save = Instance.new("TextButton")
		save.Size = UDim2.new(0, 90, 0, 28)
		save.Position = UDim2.new(0, 20, 1, -38)
		save.Text = "Save"
		save.Font = Enum.Font.GothamBold
		save.TextSize = 13
		save.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
		save.TextColor3 = Color3.new(1, 1, 1)
		save.AutoButtonColor = false
		save.ZIndex = 201
		save.Parent = frame

		local cancel = Instance.new("TextButton")
		cancel.Size = UDim2.new(0, 90, 0, 28)
		cancel.Position = UDim2.new(1, -110, 1, -38)
		cancel.Text = tr("Cancel")
		cancel.Font = Enum.Font.GothamBold
		cancel.TextSize = 13
		cancel.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
		cancel.TextColor3 = Color3.fromRGB(40, 40, 40)
		cancel.AutoButtonColor = false
		cancel.ZIndex = 201
		cancel.Parent = frame

		save.MouseButton1Click:Connect(function()
			picker.BackgroundColor3 = selectedColor
			if onColorChanged then onColorChanged(selectedColor) end
			frame:Destroy()
		end)
		cancel.MouseButton1Click:Connect(function() frame:Destroy() end)
	end)
	return picker
end

local function CreateToggleWithColor(parent, text, default, defaultColor, onToggle, onColorChanged)
	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		ZIndex = 200,
		Parent = parent
	})
	local nameLbl = Create("TextLabel", {
		Size = UDim2.new(1, -62, 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = TEXT_LABEL,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 201,
		Parent = row
	})
	registerLangLabel(text, nameLbl)
	local colorPicker = CreateColorPicker(row, defaultColor, onColorChanged)
	colorPicker.Position = UDim2.new(1, -58, 0.5, -5.5) -- junto al trigger
	local toggle = Create("Frame", {
		Size = UDim2.new(0, 28, 0, 12),
		Position = UDim2.new(1, -44, 0.5, -6),
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		BorderSizePixel = 0,
		ZIndex = 202,
		Parent = row
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggle})
	local ball = Create("Frame", {
		Size = UDim2.new(0, 8, 0, 8),
		Position = UDim2.new(0, 2, 0.5, -4),
		BackgroundColor3 = Color3.fromRGB(120, 120, 120),
		BorderSizePixel = 0,
		ZIndex = 203,
		Parent = toggle
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ball})
	local state = default
	local function Update()
		if state then
			TweenService:Create(ball, TweenInfo.new(0.15), {Position = UDim2.new(0, 18, 0.5, -4), BackgroundColor3 = TOGGLE_ON}):Play()
		else
			TweenService:Create(ball, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -4), BackgroundColor3 = Color3.fromRGB(120, 120, 120)}):Play()
		end
		if onToggle then
			local s = state
			task.delay(0, function() pcall(onToggle, s) end)
		end
	end
	Update()
	_G.SupremacyToggleUpdates = _G.SupremacyToggleUpdates or {}
	_G.SupremacyToggleUpdates[text] = function(newState)
		state = newState and true or false
		if state then
			TweenService:Create(ball, TweenInfo.new(0.12), {Position = UDim2.new(0, 18, 0.5, -4), BackgroundColor3 = TOGGLE_ON}):Play()
		else
			TweenService:Create(ball, TweenInfo.new(0.12), {Position = UDim2.new(0, 2, 0.5, -4), BackgroundColor3 = Color3.fromRGB(120, 120, 120)}):Play()
		end
	end
	_G.SupremacyColorUpdates = _G.SupremacyColorUpdates or {}
	_G.SupremacyColorUpdates[text] = function(c)
		if typeof(c) == "Color3" then
			colorPicker.BackgroundColor3 = c
			if onColorChanged then pcall(onColorChanged, c) end
		end
	end
	local btn = Create("TextButton", {
		Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 204,
		Parent = toggle
	})
	btn.MouseButton1Click:Connect(function()
		state = not state
		Update()
	end)
	return row
end

local function CreateToggleSlider(parent, text, min, max, default, onToggle, onValue, toggleDefault)
	local container = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		ZIndex = 200,
		Parent = parent
	})
	local topRow = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		ZIndex = 200,
		Parent = container
	})
	local nameLbl = Create("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = TEXT_LABEL,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 201,
		Parent = topRow
	})
	registerLangLabel(text, nameLbl)
	local toggle = Create("Frame", {
		Size = UDim2.new(0, 28, 0, 12),
		Position = UDim2.new(1, -44, 0.5, -6),
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		BorderSizePixel = 0,
		ZIndex = 202,
		Parent = topRow
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggle})
	local ball = Create("Frame", {
		Size = UDim2.new(0, 8, 0, 8),
		Position = UDim2.new(0, 2, 0.5, -4),
		BackgroundColor3 = Color3.fromRGB(120, 120, 120),
		BorderSizePixel = 0,
		ZIndex = 203,
		Parent = toggle
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ball})
	local state = (toggleDefault == true)
	local function UpdateToggle()
		if state then
			TweenService:Create(ball, TweenInfo.new(0.15), {Position = UDim2.new(0, 18, 0.5, -4), BackgroundColor3 = TOGGLE_ON}):Play()
		else
			TweenService:Create(ball, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -4), BackgroundColor3 = Color3.fromRGB(120, 120, 120)}):Play()
		end
		if onToggle then
			local s = state
			task.delay(0, function() pcall(onToggle, s) end)
		end
	end
	UpdateToggle()
	_G.SupremacyToggleUpdates = _G.SupremacyToggleUpdates or {}
	_G.SupremacyToggleUpdates[text] = function(newState)
		state = newState and true or false
		if state then
			TweenService:Create(ball, TweenInfo.new(0.15), {Position = UDim2.new(0, 18, 0.5, -4), BackgroundColor3 = TOGGLE_ON}):Play()
		else
			TweenService:Create(ball, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -4), BackgroundColor3 = Color3.fromRGB(120, 120, 120)}):Play()
		end
	end
	local btn = Create("TextButton", {
		Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 204,
		Parent = toggle
	})
	btn.MouseButton1Click:Connect(function()
		state = not state
		UpdateToggle()
	end)

	local bar = Create("Frame", {
		Size = UDim2.new(1, -70, 0, 8),
		Position = UDim2.new(0, 0, 0, 24),
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		BorderSizePixel = 0,
		ZIndex = 201,
		Parent = container
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = bar})
	local thumb = Create("Frame", {
		Size = UDim2.new(0, 10, 0, 10),
		Position = UDim2.new((default - min) / (max - min), -5, 0.5, -5),
		BackgroundColor3 = TOGGLE_ON,
		BorderSizePixel = 0,
		ZIndex = 202,
		Parent = bar
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = thumb})

	local function formatNum(n)
		local s = tostring(math.floor(n + 0.5))
		local rev = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
		if rev:sub(1, 1) == "," then rev = rev:sub(2) end
		return rev
	end

	local valueBox = Create("TextBox", {
		Size = UDim2.new(0, 52, 0, 14),
		Position = UDim2.new(1, -58, 0, 21),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0,
		Text = formatNum(default),
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Center,
		ClearTextOnFocus = true,
		ZIndex = 201,
		Parent = container
	})

	local currentValue = default
	_G.SupremacySliderUpdates = _G.SupremacySliderUpdates or {}
	_G.SupremacySliderUpdates[text] = function(v)
		v = tonumber(v)
		if not v then return end
		v = math.clamp(math.floor(v + 0.5), min, max)
		currentValue = v
		local pct = (max > min) and ((v - min) / (max - min)) or 0
		thumb.Position = UDim2.new(pct, -5, 0.5, -5)
		valueBox.Text = formatNum(v)
		if onValue then pcall(onValue, v) end
	end
	local dragging = false
	local lastCb = 0
	local pending = nil
	local function Update(value, forceCb)
		value = math.clamp(math.floor(value + 0.5), min, max)
		if value == currentValue and not forceCb then
			-- solo mover thumb si cambio
		end
		currentValue = value
		local pct = (max > min) and ((value - min) / (max - min)) or 0
		thumb.Position = UDim2.new(pct, -5, 0.5, -5)
		valueBox.Text = formatNum(value)
		if not onValue then return end
		-- throttle fuerte: max ~8 callbacks/seg al deslizar
		local now = tick()
		if forceCb or (now - lastCb) >= 0.12 then
			lastCb = now
			pending = nil
			local v = value
			task.delay(0, function() pcall(onValue, v) end)
		else
			pending = value
		end
	end
	_G.SupremacySliderUpdates = _G.SupremacySliderUpdates or {}
	_G.SupremacySliderUpdates[text] = function(newVal)
		if type(newVal) == "number" then
			Update(newVal, true)
		end
	end
	valueBox.FocusLost:Connect(function()
		local cleaned = valueBox.Text:gsub(",", ""):gsub("%s", "")
		local num = tonumber(cleaned)
		if num then Update(num, true) else valueBox.Text = formatNum(currentValue) end
	end)
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			if pending ~= nil then
				local v = pending
				pending = nil
				if onValue then
					task.delay(0, function() pcall(onValue, v) end)
				end
			end
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local pos = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
			Update(min + pos * (max - min), false)
		end
	end)
	return container
end

local function CreateESPTypeButton(parent)
	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		ZIndex = 200,
		Parent = parent
	})
	local etLbl = Create("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		BackgroundTransparency = 1,
		Text = "ESP Type",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = TEXT_LABEL,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 201,
		Parent = row
	})
	registerLangLabel("ESP Type", etLbl)
	local btn = Create("TextButton", {
		Size = UDim2.new(0, 52, 0, 14),
		Position = UDim2.new(1, -58, 0.5, -7),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0,
		Text = "2D",
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		ZIndex = 202,
		Parent = row
	})
	btn.MouseButton1Click:Connect(function()
		ESPType = ESPType == "2D" and "3D" or "2D"
		btn.Text = ESPType
		ClearESPBoxes()
	end)
	_G.SupremacyESPTypeBtn = btn
	return row
end

-- AIMBOT
local AimBotPage = CreatePage("AimBot")
CreateToggle(AimBotPage, "Aimbot", false, function(v)
	AimbotEnabled = v
	if AimbotBtn then AimbotBtn.BackgroundColor3 = v and Color3.fromRGB(180, 180, 180) or Color3.fromRGB(40, 40, 40) end
end)
CreateToggle(AimBotPage, "Aimbot Key", false, function(v)
	AimbotButtonEnabled = v
	AimbotBtn.Visible = v
	if not v then
		AimbotEnabled = false
		AimbotBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	end
	applyAllButtonOpacity()
end)

CreateToggleSlider(AimBotPage, "Smoothing", 0, 100, 50, function(v) SmoothingEnabled = v end, function(v) AimbotSmooth = v end, false)

CreateToggleWithColor(AimBotPage, "FOV Circle", false, FOVCircleColor, function(v)
	FOVCircleEnabled = v
	updateFOVCircle()
end, function(c)
	FOVCircleColor = c
	updateFOVCircle()
end)

CreateToggle(AimBotPage, "FOV Hide", false, function(v)
	FOVHideEnabled = v
	updateFOVCircle()
end)

CreateToggleSlider(AimBotPage, "FOV Size", 0, 100, 50, function(v)
	FOVSizeEnabled = v
	updateFOVCircle()
end, function(v)
	FOVSize = v
	updateFOVCircle()
end, false)

CreateToggle(AimBotPage, "Silent Aim", false, function(v) SilentAimEnabled = v end)
CreateToggle(AimBotPage, "Soru Aim", false, function(v) SoruAimbotEnabled = v end)
CreateToggle(AimBotPage, "Predict", false, function(v)
	Predict.keyOn = v and true or false
	if Predict.container then
		if not Predict.container.Parent and _G.SupremacyScreenGui then
			Predict.container.Parent = _G.SupremacyScreenGui
		end
		Predict.container.Visible = Predict.keyOn and true or false
	end
	if not Predict.keyOn then
		Predict.on = false
		if Predict.btn then
			Predict.btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
			Predict.btn.TextColor3 = Color3.fromRGB(220, 220, 230)
		end
	else
		-- aplicar letra Put Key al mostrar el boton
		_G.SupremacyKeys = _G.SupremacyKeys or {}
		if not _G.SupremacyKeys["Predict"] or _G.SupremacyKeys["Predict"] == "" then
			_G.SupremacyKeys["Predict"] = "P"
		end
		local letter = tostring(_G.SupremacyKeys["Predict"])
		if Predict.btn then Predict.btn.Text = letter end
	end
	applyAllButtonOpacity()
end)
-- Predict Y / X: solo slider (sin trigger). 0 = off de ese eje
do
	local function hideToggle(container)
		pcall(function()
			for _, ch in pairs(container:GetChildren()) do
				if ch:IsA("Frame") then
					for _, c2 in pairs(ch:GetChildren()) do
						if c2:IsA("Frame") and c2.Size.X.Offset == 28 and c2.Size.Y.Offset == 12 then
							c2.Visible = false
						end
					end
				end
			end
		end)
	end
	local yC = CreateToggleSlider(AimBotPage, "Predict Y", 0, 300, 0, function() end, function(v)
		Predict.y = v
	end, true)
	hideToggle(yC)
	local xC = CreateToggleSlider(AimBotPage, "Predict X", 0, 300, 0, function() end, function(v)
		Predict.x = v
	end, true)
	hideToggle(xC)
end

local partRow = Create("TextButton", {
	Size = UDim2.new(1, 0, 0, 20),
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
	ZIndex = 200,
	Parent = AimBotPage
})
do
	local spLbl = Create("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		BackgroundTransparency = 1,
		Text = "Select Part",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = TEXT_LABEL,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 201,
		Parent = partRow
	})
	registerLangLabel("Select Part", spLbl)
end
local partSelectLabel = Create("TextButton", {
	Size = UDim2.new(0, 52, 0, 14),
	Position = UDim2.new(1, -58, 0.5, -7),
	BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	BorderSizePixel = 0,
	Text = "Head",
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	AutoButtonColor = false,
	ZIndex = 202,
	Parent = partRow
})

CreateToggleSlider(AimBotPage, "Aim Distance", 0, 10000, 1000, function(v)
	AimDistanceEnabled = v
end, function(v)
	AimDistanceValue = v
end, false)


partDropdown = Create("ScrollingFrame", {
	Size = UDim2.new(0, 100, 0, 0),
	BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	BorderSizePixel = 0,
	Visible = false,
	ScrollBarThickness = 4,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ClipsDescendants = true,
	ZIndex = 60,
	Parent = Main
})
Create("UIListLayout", {Padding = UDim.new(0, 2), Parent = partDropdown})

local PART_SELECTED = Color3.fromRGB(200, 200, 200)
local PART_NORMAL = Color3.fromRGB(40, 40, 40)
local partOptions = {"Head", "Torso", "Leg"}
local partButtons = {}
local partDropdownOpen = false

local function refreshPartButtons()
	for _, name in ipairs(partOptions) do
		local btn = partButtons[name]
		if btn then btn.BackgroundColor3 = (AimPart == name) and PART_SELECTED or PART_NORMAL end
	end
end

for _, name in ipairs(partOptions) do
	local btn = Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundColor3 = (AimPart == name) and PART_SELECTED or PART_NORMAL,
		Text = name,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 10,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 61,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Parent = partDropdown
	})
	btn.MouseButton1Click:Connect(function()
		AimPart = name
		partSelectLabel.Text = name
		refreshPartButtons()
	end)
	partButtons[name] = btn
end

local function togglePartDropdown()
	partDropdownOpen = not partDropdownOpen
	if partDropdownOpen then
		-- cerrar otros
		dropdownShouldBeOpen = false
		if dropdownFrame then dropdownFrame.Visible = false end
		pcall(function()
			if clickSoundDropdown then clickSoundDropdown.Visible = false end
			clickSoundDropdownOpen = false
		end)
		local absPos = partSelectLabel.AbsolutePosition
		local absSize = partSelectLabel.AbsoluteSize
		local mainAbs = Main.AbsolutePosition
		local mainSize = Main.AbsoluteSize
		local h = #partOptions * 20
		local y = absPos.Y - mainAbs.Y + absSize.Y + 2
		-- no salir del menu por abajo
		if y + h > mainSize.Y - 8 then
			y = math.max(8, mainSize.Y - h - 8)
		end
		partDropdown.Parent = Main
		partDropdown.Size = UDim2.new(0, math.floor(absSize.X), 0, h)
		partDropdown.Position = UDim2.new(0, absPos.X - mainAbs.X, 0, y)
		partDropdown.ClipsDescendants = true
		partDropdown.Visible = true
		refreshPartButtons()
	else
		partDropdown.Visible = false
	end
end

partRow.MouseButton1Click:Connect(togglePartDropdown)
partSelectLabel.MouseButton1Click:Connect(togglePartDropdown)

-- al scrollear, cerrar para que no se despegue del boton
local function closeAllDropdowns()
	partDropdownOpen = false
	if partDropdown then partDropdown.Visible = false end
	dropdownShouldBeOpen = false
	if dropdownFrame then dropdownFrame.Visible = false end
	pcall(function()
		if selectLabel then selectLabel.Text = tr("Select") end
	end)
	if dropdownUpdateConn then dropdownUpdateConn:Disconnect() dropdownUpdateConn = nil end
	pcall(function()
		local pad = Content:FindFirstChildOfClass("UIPadding")
		if pad then pad.PaddingBottom = UDim.new(0, 12) end
	end)
end
_G.SupremacyCloseDropdowns = closeAllDropdowns

pcall(function()
	Content:GetPropertyChangedSignal("CanvasPosition"):Connect(closeAllDropdowns)
end)

-- Cerrar dropdowns solo si hay uno abierto (evita trabajo en cada click)
UserInputService.InputBegan:Connect(function(input, gpe)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	task.delay(0.12, function()
		if _G.SupremacyDropIgnoreUntil and tick() < _G.SupremacyDropIgnoreUntil then return end
		local pos = input.Position
		local function inside(gui)
			if not gui or not gui.Visible then return false end
			local p, s = gui.AbsolutePosition, gui.AbsoluteSize
			return pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
		end
		-- Part / Team
		if inside(partDropdown) or inside(dropdownFrame) then return end
		if partDropdownOpen and (inside(partSelectLabel) or inside(partRow)) then return end
		if dropdownShouldBeOpen and (inside(selectLabel) or inside(chooseTeamRow)) then return end
		if partDropdownOpen or dropdownShouldBeOpen then
			closeAllDropdowns()
		end
		-- Click Sound
		pcall(function()
			if clickSoundDropdownOpen and clickSoundDropdown then
				if inside(clickSoundDropdown) then return end
				-- si el toque fue el boton label, el toggle ya lo maneja
				clickSoundDropdownOpen = false
				clickSoundDropdown.Visible = false
			end
		end)
		-- Crosshair
		pcall(function()
			local chDrop = _G.SupremacyChDropdown
			if _G.SupremacyChOpen and chDrop then
				if inside(chDrop) then return end
				_G.SupremacyChOpen = false
				chDrop.Visible = false
			end
		end)
	end)
end)

-- VISUAL
local VisualPage = CreatePage("Visual")
CreateToggleWithColor(VisualPage, "ESP Box", false, ESPBoxColor, function(v) ESPBoxEnabled = v end, function(c) ESPBoxColor = c end)
CreateToggle(VisualPage, "ESP Filled", false, function(v) ESPFilled = v end)
CreateESPTypeButton(VisualPage)
CreateToggleWithColor(VisualPage, "ESP Name", false, ESPNameColor, function(v) ESPNameEnabled = v end, function(c) ESPNameColor = c end)
CreateToggleWithColor(VisualPage, "ESP Distance", false, ESPDistanceColor, function(v) ESPDistanceEnabled = v end, function(c) ESPDistanceColor = c end)
CreateToggle(VisualPage, "ESP Health", false, function(v) ESPHealthEnabled = v end)
CreateToggleWithColor(VisualPage, "ESP SnapLine", false, ESPSnapLineColor, function(v) ESPSnapLineEnabled = v end, function(c) ESPSnapLineColor = c end)
CreateToggleWithColor(VisualPage, "ESP Antenna", false, ESPAntennaColor, function(v) ESPAntennaEnabled = v end, function(c) ESPAntennaColor = c end)
CreateToggleSlider(VisualPage, "Limit Distance", 100, 10000, 5000, function(v) LimitDistanceEnabled = v end, function(v) LimitDistanceValue = v end)

CreateToggle(VisualPage, "NPC Check", false, function(v)
	NPCCheckEnabled = v and true or false
	_G.SupremacyNPCCheck = NPCCheckEnabled
end)
CreateToggle(VisualPage, "Health Check", false, function(v)
	HealthCheckEnabled = v and true or false
	_G.SupremacyHealthCheck = HealthCheckEnabled
end)

-- MISC
local MiscPage = CreatePage("Misc")
CreateToggle(MiscPage, "Sanguine Z Boost", false, function(v)
	ZSanguineBoostEnabled = v
	if v then createLagGui()
	else if lagGui then lagGui:Destroy() lagGui = nil end end
end)
CreateToggle(MiscPage, "Tab (Freeze)", false, function(v)
	FreezeEnabled = v
	if v then FreezeContainer.Position = savedFreezePos end
	applyAllButtonOpacity()
end)
CreateToggle(MiscPage, "Super Jump", false, function(v)
	SuperJumpEnabled = v
	if SuperJumpContainer then
		if v and savedSuperJumpPos then
			SuperJumpContainer.Position = savedSuperJumpPos
		elseif v then
			SuperJumpContainer.Position = UDim2.new(1, -110, 1, -210) -- junto al salto, mas arriba a la izquierda
		end
		SuperJumpContainer.Visible = v
	end
end)
CreateToggle(MiscPage, "Fly", false, function(v)
	if v then
		loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Fly-universal-gui-43716"))()
	else
		for _, gui in pairs(player.PlayerGui:GetChildren()) do
			if gui.Name:find("Fly") then pcall(function() gui:Destroy() end) end
		end
	end
end)
CreateToggleSlider(MiscPage, "Super Dash", 0, 200, 10, function(v)
	if v then startSuperDash() else stopSuperDash() end
end, function(v) SuperDashSpeed = v end)
CreateToggle(MiscPage, "Noclip", false, handleNoclip)
CreateToggle(MiscPage, "Anti Lava", false, handleAntiLava)
CreateToggle(MiscPage, "Infinite Jump", false, function(v) InfiniteJumpEnabled = v end)
CreateToggleSlider(MiscPage, "Safe Zone", 500, 5000, 500, function(v)
	SafeZoneEnabled = v
end, function(v)
	SafeZoneHealth = v
end)


-- Gui Mini: SOLO barras Health/Energy (sin tocar dinero/fragmentos)
;(function()
	local guiMiniOn = false
	local saved = {}
	local targets = {}
	local conn = nil
	local lastT = 0
	local SLOT = 22
	local BASE_Y = -14

	local function isOurs(obj)
		local p = obj
		while p do
			if string.find(string.lower(tostring(p.Name or "")), "supremacy", 1, true) then
				return true
			end
			p = p.Parent
		end
		return false
	end

	local function isMenuBlob(blob)
		if blob:find("available points", 1, true) then return true end
		if blob:find("melee", 1, true) and blob:find("defense", 1, true) then return true end
		if blob:find("refund", 1, true) then return true end
		return false
	end

	local function blobOf(obj)
		local b = ""
		pcall(function()
			for _, x in ipairs(obj:GetDescendants()) do
				if x:IsA("TextLabel") or x:IsA("TextButton") then
					b = b .. " " .. string.lower(tostring(x.Text or ""))
				end
			end
		end)
		return b
	end

	local function save(obj)
		if not obj or saved[obj] then return end
		saved[obj] = {
			pos = obj.Position,
			anchor = obj.AnchorPoint,
			visible = obj.Visible,
		}
	end

	local function restoreAll()
		for obj, data in pairs(saved) do
			pcall(function()
				if obj and obj.Parent and data then
					obj.Position = data.pos
					obj.AnchorPoint = data.anchor
					obj.Visible = data.visible
				end
			end)
		end
		table.clear(saved)
		table.clear(targets)
		-- limpiar restos de versiones anteriores
		pcall(function()
			local pg = player:FindFirstChild("PlayerGui")
			if not pg then return end
			for _, n in ipairs({"SupremacyMoneyHost", "SupremacyMoneyMini", "SupremacyGuiMini"}) do
				local c = pg:FindFirstChild(n)
				if c then c:Destroy() end
			end
		end)
	end

	local function collectBarFrames()
		local list, seen = {}, {}
		local pg = player:FindFirstChild("PlayerGui")
		if not pg then return list end
		local vw = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X) or 400
		for _, gui in ipairs(pg:GetChildren()) do
			if not gui:IsA("ScreenGui") or isOurs(gui) then continue end
			for _, d in ipairs(gui:GetDescendants()) do
				if not (d:IsA("TextLabel") or d:IsA("TextButton")) then continue end
				local t = string.lower(tostring(d.Text or ""))
				if not ((t:find("health", 1, true) or t:find("energy", 1, true)) and string.find(t, "%d+%s*/%s*%d+")) then
					continue
				end
				local best, node = nil, d.Parent
				for _ = 1, 10 do
					if not node or node == gui then break end
					if node:IsA("GuiObject") and not isOurs(node) and not isMenuBlob(blobOf(node)) then
						local asz = node.AbsoluteSize
						if asz.X >= 60 and asz.X <= vw * 0.7 and asz.Y >= 12 and asz.Y <= 100 then
							best = node
						end
					end
					node = node.Parent
				end
				if best and not seen[best] then
					seen[best] = true
					table.insert(list, best)
				end
			end
		end
		return list
	end

	local function placeFixed(fr, index, total)
		if not fr or not fr.Parent then return end
		save(fr)
		total = math.max(total or #targets, 1)
		-- Health arriba, Energy abajo
		local y = BASE_Y - (total - index) * SLOT
		pcall(function()
			fr.Visible = true
			fr.AnchorPoint = Vector2.new(0, 1)
			fr.Position = UDim2.new(0, 10, 1, y)
		end)
	end

	local levelObj = nil

	local function findLevel()
		local pg = player:FindFirstChild("PlayerGui")
		if not pg then return nil end
		for _, gui in ipairs(pg:GetChildren()) do
			if not gui:IsA("ScreenGui") or isOurs(gui) then continue end
			for _, d in ipairs(gui:GetDescendants()) do
				if d:IsA("TextLabel") or d:IsA("TextButton") then
					local t = tostring(d.Text or "")
					if (t:find("Lv%.") or t:find("Lv ")) and not string.lower(t):find("melee") then
						return d
					end
				end
			end
		end
		return nil
	end

	-- Solo bajar Level/EXP 2px (sin mover X)
	local function nudgeLevelDown2()
		levelObj = (levelObj and levelObj.Parent) and levelObj or findLevel()
		if not levelObj then return end
		save(levelObj)
		pcall(function()
			local p = levelObj.Position
			-- si ya lo movimos, no acumular; usar saved
			local data = saved[levelObj]
			if data and data.pos then
				p = data.pos
			end
			levelObj.Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset + 2)
		end)
	end

	local function discoverOnce()
		local frames = collectBarFrames()
		if #frames == 0 then return end
		table.sort(frames, function(a, b)
			local ta, tb = blobOf(a), blobOf(b)
			local ha = ta:find("health", 1, true) and 0 or 1
			local hb = tb:find("health", 1, true) and 0 or 1
			return ha < hb
		end)
		targets = frames
		for i, fr in ipairs(targets) do
			placeFixed(fr, i, #targets)
		end
		nudgeLevelDown2()
	end

	local function keepInPlace()
		if not guiMiniOn then return end
		local now = tick()
		if now - lastT < 1.0 then return end
		lastT = now
		if #targets == 0 then
			discoverOnce()
			return
		end
		local alive = 0
		for i, fr in ipairs(targets) do
			if fr and fr.Parent then
				alive = alive + 1
				local ap = fr.AbsolutePosition
				local vh = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y) or 800
				if ap.X > 90 or ap.Y < vh * 0.5 then
					placeFixed(fr, i, #targets)
				end
			end
		end
		if alive == 0 then
			table.clear(targets)
			discoverOnce()
		else
			nudgeLevelDown2()
		end
	end


	-- Pc Format extra: brujula + botones encima mas pequenos
	local pcScaled = {} -- [obj] = UIScale

	local function clearPcScale()
		for obj, us in pairs(pcScaled) do
			pcall(function()
				if us and us.Parent then us:Destroy() end
				if obj and obj.Parent and obj:GetAttribute("SupremacyPcAlign") ~= nil then
					local base = obj:GetAttribute("SupremacyPcAlign")
					local p = obj.Position
					obj.Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, base)
					obj:SetAttribute("SupremacyPcAlign", nil)
				end
				if obj and obj.Parent and obj:GetAttribute("SupremacyPcDown") then
					local p = obj.Position
					local down = tonumber(obj:GetAttribute("SupremacyPcDownAmt")) or 18
					obj.Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset - down)
					obj:SetAttribute("SupremacyPcDown", nil)
					obj:SetAttribute("SupremacyPcDownAmt", nil)
				end
			end)
		end
		table.clear(pcScaled)
	end

	local function isCompassOrMoveUI(obj)
		local p = obj
		local hops = 0
		while p and hops < 10 do
			local n = string.lower(tostring(p.Name or ""))
			if n:find("compass", 1, true) or n:find("joystick", 1, true) or n:find("thumbstick", 1, true)
				or n:find("dynamicthumb", 1, true) or n:find("touchcontrol", 1, true)
				or n:find("direction", 1, true) or n:find("movebutton", 1, true)
				or n:find("jumpbutton", 1, true) or n:find("contextaction", 1, true) then
				return true
			end
			p = p.Parent
			hops = hops + 1
		end
		return false
	end

	local function scalePcExtras()
		-- SOLO fila de iconos izq (gear/skull/crew/home/player amarillo). NO Menu. NO brujula.
		if not guiMiniOn then return end
		local pg = player:FindFirstChild("PlayerGui")
		if not pg then return end
		local cam = workspace.CurrentCamera
		local vw = (cam and cam.ViewportSize.X) or 800
		local vh = (cam and cam.ViewportSize.Y) or 600
		local SCALE_ICONS = 0.74

		local function stripScale(obj)
			pcall(function()
				local us = obj:FindFirstChild("SupremacyPcFormatScale")
				if us then us:Destroy() end
				pcScaled[obj] = nil
			end)
		end

		local icons = {}
		for _, gui in ipairs(pg:GetChildren()) do
			if gui:IsA("ScreenGui") and not isOurs(gui) then
				local gname = string.lower(tostring(gui.Name or ""))
				if not gname:find("touch", 1, true) then
					for _, d in ipairs(gui:GetDescendants()) do
						if isOurs(d) then
							-- skip
						elseif isCompassOrMoveUI(d) then
							stripScale(d) -- NUNCA brujula / move / triangulo de brujula
						elseif d:IsA("ImageButton") or d:IsA("ImageLabel") then
							local ap, asz = d.AbsolutePosition, d.AbsoluteSize
							-- excluir inventario / tools / hotbar / caña
							local dn = string.lower(tostring(d.Name or ""))
							local skip = dn:find("tool", 1, true) or dn:find("rod", 1, true)
								or dn:find("fish", 1, true) or dn:find("hotbar", 1, true)
								or dn:find("backpack", 1, true) or dn:find("invent", 1, true)
								or dn:find("slot", 1, true) or dn:find("item", 1, true)
							if not skip then
								local p = d.Parent
								for _ = 1, 5 do
									if not p then break end
									local pn = string.lower(tostring(p.Name or ""))
									if pn:find("hotbar", 1, true) or pn:find("backpack", 1, true)
										or pn:find("invent", 1, true) or pn:find("toolbar", 1, true)
										or pn:find("toolframe", 1, true) then
										skip = true
										break
									end
									p = p.Parent
								end
							end
							if skip then
								stripScale(d)
							elseif asz.X >= 14 and asz.Y >= 14 and asz.X <= 52 and asz.Y <= 52 then
								local cx = ap.X + asz.X * 0.5
								local cy = ap.Y + asz.Y * 0.5
								-- SOLO fila izq media-alta; NUNCA mitad baja (caña/hotbar/brujula)
								if cx < vw * 0.26 and cy > vh * 0.18 and cy < vh * 0.38 then
									table.insert(icons, d)
								end
							elseif asz.X > 52 then
								stripScale(d)
							end
						elseif d:IsA("TextButton") then
							stripScale(d)
						end
					end
				end
			end
		end

		if #icons == 0 then return end

		-- target = altura media de los iconos "fila" (gear/skull/crew/home), NO el mas alto
		-- el boton jugador (amarillo) baja al lado de la casa
		local ys = {}
		for _, ic in ipairs(icons) do
			table.insert(ys, ic.AbsolutePosition.Y + ic.AbsoluteSize.Y * 0.5)
		end
		table.sort(ys)
		-- usar la mediana del grupo inferior-medio (evita outliers muy arriba)
		local targetCy
		if #ys >= 4 then
			-- promedio de los 4 del medio/abajo (excluye 1 mas alto si hay outlier)
			local sum = 0
			local from = math.max(1, #ys - 3)
			for i = from, #ys do sum = sum + ys[i] end
			targetCy = sum / ( #ys - from + 1 )
		else
			local sum = 0
			for _, y in ipairs(ys) do sum = sum + y end
			targetCy = sum / #ys
		end

		for _, ic in ipairs(icons) do
			pcall(function()
				local us = ic:FindFirstChild("SupremacyPcFormatScale")
				if not us then
					us = Instance.new("UIScale")
					us.Name = "SupremacyPcFormatScale"
					us.Parent = ic
				end
				us.Scale = SCALE_ICONS
				pcScaled[ic] = us

				if not ic:GetAttribute("SupremacyPcAlign") then
					ic:SetAttribute("SupremacyPcAlign", ic.Position.Y.Offset)
				end
				local curCy = ic.AbsolutePosition.Y + ic.AbsoluteSize.Y * 0.5
				-- +2.5 px mas abajo (pedido usuario)
				local delta = (targetCy + 2.5) - curCy
				-- solo correcciones suaves (max 35px)
				if math.abs(delta) > 0.4 and math.abs(delta) < 35 then
					local p = ic.Position
					ic.Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset + delta)
				end
			end)
		end

	end

	local oldRestoreAll = restoreAll
	restoreAll = function()
		clearPcScale()
		oldRestoreAll()
	end


	-- Pc Format: ocultar joystick + jump (siguen funcionando)
	local touchHidden = {}
	local function hideTouchVisual(obj)
		if not obj or touchHidden[obj] then return end
		local data = {}
		pcall(function()
			if obj:IsA("GuiObject") then
				data.bg = obj.BackgroundTransparency
				obj.BackgroundTransparency = 1
			end
			if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
				data.img = obj.ImageTransparency
				obj.ImageTransparency = 1
			end
			if obj:IsA("TextLabel") or obj:IsA("TextButton") then
				data.text = obj.TextTransparency
				obj.TextTransparency = 1
			end
			if obj:IsA("UIStroke") then
				data.stroke = obj.Transparency
				obj.Transparency = 1
			end
			if obj:IsA("GuiButton") then
				obj.Active = true
				obj.AutoButtonColor = false
			end
		end)
		touchHidden[obj] = data
	end
	local function hideJoystickAndJump()
		local pg = player:FindFirstChild("PlayerGui")
		if not pg then return end
		pcall(function()
			local touch = pg:FindFirstChild("TouchGui")
			if touch then
				for _, d in ipairs(touch:GetDescendants()) do
					if d:IsA("GuiObject") or d:IsA("UIStroke") then
						hideTouchVisual(d)
					end
				end
				for _, ch in ipairs(touch:GetChildren()) do
					if ch:IsA("GuiObject") then hideTouchVisual(ch) end
				end
			end
		end)
		pcall(function()
			for _, gui in ipairs(pg:GetChildren()) do
				if gui:IsA("ScreenGui") and not isOurs(gui) then
					local n = string.lower(tostring(gui.Name or ""))
					if n:find("touch") or n:find("control") then
						for _, d in ipairs(gui:GetDescendants()) do
							local dn = string.lower(tostring(d.Name or ""))
							if dn:find("jump") or dn:find("thumbstick") or dn:find("dynamicthumb")
								or dn:find("touchcontrol") or dn:find("joystick") then
								hideTouchVisual(d)
							end
						end
					end
				end
			end
		end)
	end
	local function showJoystickAndJump()
		for obj, data in pairs(touchHidden) do
			pcall(function()
				if not obj or not obj.Parent or not data then return end
				if data.bg ~= nil and obj:IsA("GuiObject") then obj.BackgroundTransparency = data.bg end
				if data.img ~= nil then obj.ImageTransparency = data.img end
				if data.text ~= nil then obj.TextTransparency = data.text end
				if data.stroke ~= nil and obj:IsA("UIStroke") then obj.Transparency = data.stroke end
			end)
		end
		table.clear(touchHidden)
	end

	_G.SupremacyGuiMiniApply = function(v)
		guiMiniOn = v and true or false
		_G.SupremacyPcFormatOn = guiMiniOn
		if conn then pcall(function() conn:Disconnect() end) conn = nil end
		if guiMiniOn then
			table.clear(targets)
			discoverOnce()
			scalePcExtras()
			hideJoystickAndJump()
			task.delay(0.8, function()
				if guiMiniOn then
					pcall(discoverOnce)
					pcall(scalePcExtras)
					pcall(hideJoystickAndJump)
				end
			end)
			task.delay(2.5, function()
				if guiMiniOn then
					pcall(scalePcExtras)
					pcall(hideJoystickAndJump)
				end
			end)
			conn = nil
		else
			showJoystickAndJump()
			restoreAll()
		end
	end

	player.CharacterAdded:Connect(function()
		if not guiMiniOn then return end
		table.clear(targets)
		task.delay(1, function() if guiMiniOn then discoverOnce() end end)
	end)
end)()

-- Slots Mini: slider 0-100 | 0=normal 100=mitad | ancla abajo | solo hotbar
;(function()
	local slotsOn = false
	local slotsPct = 0
	local hiddenExtras = {} -- 0 normal, 100 = mitad
	local scaled = {} -- [obj] = UIScale
	local savedLayout = {} -- [obj] = {size, pos, anchor}
	local conn = nil
	local lastT = 0

	local function isOurs(obj)
		local p = obj
		while p do
			if string.find(string.lower(tostring(p.Name or "")), "supremacy", 1, true) then
				return true
			end
			p = p.Parent
		end
		return false
	end

	local function scaleFromPct()
		-- 0 → 1.0, 100 → 0.5
		return 1 - (math.clamp(slotsPct, 0, 100) / 100) * 0.5
	end

	local controlsHidden = {} -- [GuiObject] = {imgT, bgT, textT, children...}

	local function hideTouchControls()
		local pg = player:FindFirstChild("PlayerGui")
		if not pg then return end
		local function hideObj(obj)
			if not obj or controlsHidden[obj] then return end
			local data = { bg = obj.BackgroundTransparency }
			pcall(function()
				if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
					data.img = obj.ImageTransparency
					obj.ImageTransparency = 1
				end
				if obj:IsA("TextLabel") or obj:IsA("TextButton") then
					data.text = obj.TextTransparency
					obj.TextTransparency = 1
				end
				obj.BackgroundTransparency = 1
			end)
			controlsHidden[obj] = data
			for _, ch in ipairs(obj:GetDescendants()) do
				if ch:IsA("GuiObject") and not controlsHidden[ch] then
					local d2 = { bg = ch.BackgroundTransparency }
					pcall(function()
						if ch:IsA("ImageLabel") or ch:IsA("ImageButton") then
							d2.img = ch.ImageTransparency
							ch.ImageTransparency = 1
						end
						if ch:IsA("TextLabel") or ch:IsA("TextButton") then
							d2.text = ch.TextTransparency
							ch.TextTransparency = 1
						end
						if ch:IsA("UIStroke") then
							d2.stroke = ch.Transparency
							ch.Transparency = 1
						end
						ch.BackgroundTransparency = 1
					end)
					controlsHidden[ch] = d2
				elseif ch:IsA("UIStroke") and not controlsHidden[ch] then
					controlsHidden[ch] = { stroke = ch.Transparency }
					pcall(function() ch.Transparency = 1 end)
				end
			end
		end
		-- TouchGui completo (jump + joystick)
		pcall(function()
			local touch = pg:FindFirstChild("TouchGui")
			if not touch then return end
			local frame = touch:FindFirstChild("TouchControlFrame") or touch
			for _, name in ipairs({
				"DynamicThumbstickFrame", "ThumbstickFrame", "Thumbstick",
				"JumpButton", "JumpControl", "Jump", "JumpPower"
			}) do
				local o = frame:FindFirstChild(name, true)
				if o then hideObj(o) end
			end
			for _, d in ipairs(frame:GetDescendants()) do
				if d:IsA("GuiObject") then
					local n = string.lower(tostring(d.Name or ""))
					if n:find("thumb") or n:find("stick") or n:find("jump") or n:find("dynamic") then
						hideObj(d)
					end
				end
			end
		end)
		-- fallback por posicion: circulos abajo izq (joystick) y abajo der (jump)
		pcall(function()
			local cam = workspace.CurrentCamera
			local vw = (cam and cam.ViewportSize.X) or 800
			local vh = (cam and cam.ViewportSize.Y) or 600
			for _, gui in ipairs(pg:GetChildren()) do
				if gui:IsA("ScreenGui") then
					local gname = string.lower(tostring(gui.Name or ""))
					if gname:find("touch") or gname:find("control") then
						for _, d in ipairs(gui:GetDescendants()) do
							if d:IsA("ImageButton") or d:IsA("ImageLabel") then
								local ap, asz = d.AbsolutePosition, d.AbsoluteSize
								if asz.X >= 40 and asz.Y >= 40 and asz.X <= 160 and asz.Y <= 160 then
									local cx = ap.X + asz.X * 0.5
									local cy = ap.Y + asz.Y * 0.5
									if cy > vh * 0.70 then
										if cx < vw * 0.28 or cx > vw * 0.78 then
											hideObj(d)
										end
									end
								end
							end
						end
					end
				end
			end
		end)
	end

	local function showTouchControls()
		for obj, data in pairs(controlsHidden) do
			pcall(function()
				if not obj or not obj.Parent then return end
				if data.bg ~= nil then obj.BackgroundTransparency = data.bg end
				if data.img ~= nil and (obj:IsA("ImageLabel") or obj:IsA("ImageButton")) then
					obj.ImageTransparency = data.img
				end
				if data.text ~= nil and (obj:IsA("TextLabel") or obj:IsA("TextButton")) then
					obj.TextTransparency = data.text
				end
				if data.stroke ~= nil and obj:IsA("UIStroke") then
					obj.Transparency = data.stroke
				end
			end)
		end
		table.clear(controlsHidden)
	end

	local function restoreSlots()
		for obj, us in pairs(scaled) do
			pcall(function()
				if typeof(us) == "Instance" then us:Destroy() end
			end)
		end
		for obj, data in pairs(savedLayout) do
			pcall(function()
				if obj and obj.Parent and type(data) == "table" then
					if data.size then obj.Size = data.size end
					if data.pos then obj.Position = data.pos end
					if data.anchor then obj.AnchorPoint = data.anchor end
					if data.textSize and (obj:IsA("TextLabel") or obj:IsA("TextButton")) then
						obj.TextSize = data.textSize
					end
				end
			end)
		end
		table.clear(scaled)
		table.clear(savedLayout)
		for obj, tr in pairs(hiddenExtras) do
			pcall(function()
				if obj and obj.Parent then obj.TextTransparency = tr end
			end)
		end
		table.clear(hiddenExtras)
		showTouchControls()
	end

	local function badBlob(obj)
		local b = ""
		pcall(function()
			if obj:IsA("TextLabel") or obj:IsA("TextButton") then
				b = string.lower(tostring(obj.Text or ""))
			end
			for _, x in ipairs(obj:GetDescendants()) do
				if x:IsA("TextLabel") or x:IsA("TextButton") then
					b = b .. " " .. string.lower(tostring(x.Text or ""))
				end
			end
		end)
		if b:find("health") or b:find("energy") or b:find("safe zone") then return true end
		if b:find("lv%.") or b:find("menu") or b:find("shop") then return true end
		if b:find("use") and b:find("mas%.") then return true end -- lista de skills derecha
		if b:find("portal") or b:find("mastery") then return true end
		if b:find("crew") or b:find("abandon") or b:find("members:") then return true end
		if b:find("total bounty") or b:find("captain:") then return true end
		return false
	end

	local function isMobileControl(obj)
		-- botones salto / gesto derecha — NO tocar
		local ap = obj.AbsolutePosition
		local cam = workspace.CurrentCamera
		local vw = cam and cam.ViewportSize.X or 400
		if ap.X > vw * 0.72 then return true end
		local n = string.lower(tostring(obj.Name or ""))
		if n:find("jump") or n:find("thumbstick") or n:find("touchcontrol") then return true end
		if n:find("shiftlock") or n:find("sprint") or n:find("dodge") then return true end
		return false
	end

	local function applyTo(obj, sc)
		if not obj or not obj.Parent then return end
		if isOurs(obj) or badBlob(obj) or isMobileControl(obj) then return end
		-- no tocar crew / settings / menus
		do
			local p, hops = obj, 0
			while p and hops < 12 do
				local n = string.lower(tostring(p.Name or ""))
				if n:find("crew", 1, true) or n:find("setting", 1, true)
					or n:find("shop", 1, true) or n:find("abandon", 1, true) then
					return
				end
				p = p.Parent
				hops = hops + 1
			end
		end
		pcall(function()
			if not savedLayout[obj] then
				-- SOLO la primera vez (antes de escalar)
				local asz0 = obj.AbsoluteSize
				local ap0 = obj.AbsolutePosition
				savedLayout[obj] = {
					size = obj.Size,
					pos = obj.Position,
					anchor = obj.AnchorPoint,
					-- centro horizontal + borde inferior (NO se mueven al escalar)
					centerX = ap0.X + asz0.X * 0.5,
					bottomY = ap0.Y + asz0.Y,
					width = asz0.X,
					height = asz0.Y,
				}
			end
			local data = savedLayout[obj]
			local parent = obj.Parent
			local pap = parent.AbsolutePosition
			-- ancla centro-abajo: se queda en el mismo sitio, no va a la izquierda
			obj.AnchorPoint = Vector2.new(0.5, 1)
			local extraDown = 6
			obj.Position = UDim2.fromOffset(
				math.floor(data.centerX - pap.X),
				math.floor(data.bottomY - pap.Y + extraDown)
			)
			local us = obj:FindFirstChild("SupremacySlotsMini")
			if not us then
				us = Instance.new("UIScale")
				us.Name = "SupremacySlotsMini"
				us.Parent = obj
			end
			us.Scale = sc
			scaled[obj] = us
		end)
	end

	local function findHotbarSlots()
		local list = {}
		local pg = player:FindFirstChild("PlayerGui")
		if not pg then return list end
		local cam = workspace.CurrentCamera
		local vh = cam and cam.ViewportSize.Y or 800
		local vw = cam and cam.ViewportSize.X or 400

		-- contenedores tipicos de hotbar (herramientas)
		for _, gui in ipairs(pg:GetChildren()) do
			if not gui:IsA("ScreenGui") or isOurs(gui) then continue end
			local gn = string.lower(tostring(gui.Name or ""))
			for _, d in ipairs(gui:GetDescendants()) do
				if isOurs(d) then continue end
				local n = string.lower(tostring(d.Name or ""))
				if n:find("hotbar") or n:find("toolbar") or n:find("toolframe")
					or n:find("weaponbar") or n:find("bottombar") or n == "tools"
					or n:find("skillbar") or n:find("abilitybar") then
					if d:IsA("GuiObject") and not isMobileControl(d) and not badBlob(d) then
						table.insert(list, d)
					end
				end
			end
		end

		-- fila de iconos cuadrados abajo-centro (barra herramientas)
		if #list == 0 then
			for _, gui in ipairs(pg:GetChildren()) do
				if not gui:IsA("ScreenGui") or isOurs(gui) then continue end
				for _, d in ipairs(gui:GetDescendants()) do
					if not (d:IsA("Frame") or d:IsA("ImageLabel")) then continue end
					if isOurs(d) or isMobileControl(d) or badBlob(d) then continue end
					local ap, asz = d.AbsolutePosition, d.AbsoluteSize
					if ap.Y < vh * 0.72 then continue end
					if asz.Y < 28 or asz.Y > 120 then continue end
					if asz.X < 100 or asz.X > vw * 0.7 then continue end
					if ap.X > vw * 0.55 then continue end -- no panel derecha
					local count = 0
					for _, ch in ipairs(d:GetChildren()) do
						if ch:IsA("GuiObject") then
							local cs = ch.AbsoluteSize
							if cs.X >= 22 and cs.X <= 100 and cs.Y >= 22 and cs.Y <= 100 then
								count = count + 1
							end
						end
					end
					if count >= 3 then
						table.insert(list, d)
					end
				end
			end
		end

		-- iconos sueltos de tools abajo (no derecha)
		if #list == 0 then
			for _, gui in ipairs(pg:GetChildren()) do
				if not gui:IsA("ScreenGui") or isOurs(gui) then continue end
				for _, d in ipairs(gui:GetDescendants()) do
					if not (d:IsA("ImageButton") or d:IsA("ImageLabel")) then continue end
					if isOurs(d) or isMobileControl(d) or badBlob(d) then continue end
					local ap, asz = d.AbsolutePosition, d.AbsoluteSize
					if ap.Y < vh * 0.78 then continue end
					if ap.X > vw * 0.65 then continue end
					if asz.X < 24 or asz.X > 100 or asz.Y < 24 or asz.Y > 100 then continue end
					local ratio = asz.X / math.max(asz.Y, 1)
					if ratio < 0.7 or ratio > 1.4 then continue end
					table.insert(list, d)
				end
			end
		end
		return list
	end

	local function findTextsAboveSlots()
		-- textos encima de la hotbar (nombres / labels)
		local list = {}
		local pg = player:FindFirstChild("PlayerGui")
		if not pg then return list end
		local cam = workspace.CurrentCamera
		local vh = cam and cam.ViewportSize.Y or 800
		local vw = cam and cam.ViewportSize.X or 400
		for _, gui in ipairs(pg:GetChildren()) do
			if gui:IsA("ScreenGui") and not isOurs(gui) then
				for _, d in ipairs(gui:GetDescendants()) do
					if (not isOurs(d)) and (d:IsA("TextLabel") or d:IsA("TextButton")) then
						local ap, asz = d.AbsolutePosition, d.AbsoluteSize
						-- justo encima de slots (banda inferior)
						if ap.Y > vh * 0.62 and ap.Y < vh * 0.90 then
							if ap.X > vw * 0.15 and ap.X < vw * 0.75 then
								if asz.Y >= 8 and asz.Y <= 40 and asz.X >= 20 and asz.X <= vw * 0.5 then
									local t = string.lower(tostring(d.Text or ""))
									-- no health/energy/money/menu
									if not (t:find("health") or t:find("energy") or t:find("safe")
										or t:find("menu") or t:find("$") or t:find("lv")) then
										table.insert(list, d)
									end
								end
							end
						end
					end
				end
			end
		end
		return list
	end

	local function findSafeZoneLabels()
		-- SOLO 1 texto original (Safe Zone / Died Recently), sin duplicados
		local candidates = {}
		local pg = player:FindFirstChild("PlayerGui")
		if not pg then return candidates end
		local cam = workspace.CurrentCamera
		local vh = (cam and cam.ViewportSize.Y) or 600
		local vw = (cam and cam.ViewportSize.X) or 800
		for _, gui in ipairs(pg:GetChildren()) do
			if gui:IsA("ScreenGui") and not isOurs(gui) then
				for _, d in ipairs(gui:GetDescendants()) do
					if (not isOurs(d)) and (d:IsA("TextLabel") or d:IsA("TextButton")) then
						local t = string.lower(tostring(d.Text or ""))
						if t:find("safe zone", 1, true) or t:find("died recently", 1, true)
							or t:find("pvp disabled", 1, true) then
							-- saltar si un ancestro ya es el mismo texto (evita hijos duplicados)
							local skip = false
							local p = d.Parent
							for _ = 1, 4 do
								if not p then break end
								if p:IsA("TextLabel") or p:IsA("TextButton") then
									local pt = string.lower(tostring(p.Text or ""))
									if pt:find("safe zone", 1, true) or pt:find("pvp disabled", 1, true)
										or pt:find("died recently", 1, true) then
										skip = true
										break
									end
								end
								p = p.Parent
							end
							if not skip and d.Visible and d.TextTransparency < 0.9 then
								table.insert(candidates, d)
							end
						end
					end
				end
			end
		end
		-- elegir SOLO el mas centrado/abajo (1 texto)
		if #candidates <= 1 then return candidates end
		local best, bestScore = nil, -1e9
		for _, lab in ipairs(candidates) do
			local ap = lab.AbsolutePosition
			local asz = lab.AbsoluteSize
			local cx = ap.X + asz.X * 0.5
			local cy = ap.Y + asz.Y * 0.5
			-- preferir cerca del centro horizontal y en mitad inferior
			local score = -math.abs(cx - vw * 0.5) + (cy > vh * 0.4 and 200 or 0) + asz.X
			if score > bestScore then
				bestScore = score
				best = lab
			end
		end
		return best and { best } or {}
	end

	
	local function isStatusText(t)
		t = string.lower(tostring(t or ""))
		if t == "" then return false end
		-- SOLO avisos de estado del HUD (nunca crew / bounty / menus)
		return t:find("safe zone", 1, true)
			or t:find("died recently", 1, true)
			or t:find("pvp disabled", 1, true)
			or t:find("in combat", 1, true)
	end

	local function isMenuOrCrewUI(obj)
		local p = obj
		local hops = 0
		while p and hops < 14 do
			local n = string.lower(tostring(p.Name or ""))
			if n:find("crew", 1, true) or n:find("setting", 1, true)
				or n:find("shop", 1, true) or n:find("inventory", 1, true)
				or n:find("dialog", 1, true) or n:find("popup", 1, true)
				or n:find("modal", 1, true) or n:find("abandon", 1, true)
				or n:find("party", 1, true) or n:find("guild", 1, true) then
				return true
			end
			if p:IsA("TextLabel") or p:IsA("TextButton") then
				local t = string.lower(tostring(p.Text or ""))
				if t:find("crew", 1, true) or t:find("abandon", 1, true)
					or t:find("members:", 1, true) or t:find("total bounty", 1, true)
					or t:find("captain:", 1, true) or t:find("ability control", 1, true) then
					return true
				end
			end
			p = p.Parent
			hops = hops + 1
		end
		return false
	end

	local function placeSafeZoneAbove(sc, slotTop)
		if not slotTop then
			local cam = workspace.CurrentCamera
			slotTop = ((cam and cam.ViewportSize.Y) or 600) * 0.88
		end
		local visible = {}
		local pg = player:FindFirstChild("PlayerGui")
		if not pg then return end
		for _, gui in ipairs(pg:GetChildren()) do
			if gui:IsA("ScreenGui") and not isOurs(gui) then
				for _, d in ipairs(gui:GetDescendants()) do
					if (not isOurs(d)) and (d:IsA("TextLabel") or d:IsA("TextButton")) then
						if isStatusText(d.Text) and not isMenuOrCrewUI(d) then
							local showing = false
							pcall(function()
								showing = d.Visible and (d.TextTransparency or 0) < 0.5 and d.AbsoluteSize.X > 4
							end)
							if showing then
								table.insert(visible, d)
							end
						end
					end
				end
			end
		end
		-- de abajo hacia arriba: pegar justo arriba de slots
		table.sort(visible, function(a, b)
			return (a.AbsolutePosition.Y or 0) > (b.AbsolutePosition.Y or 0)
		end)
		local yCursor = slotTop - 2
		for _, lab in ipairs(visible) do
			pcall(function()
				if not lab.Parent then return end
				-- UIScale segun slider (0=1.0 normal)
				local us = lab:FindFirstChild("SupremacySlotsScale")
				if not us then
					us = Instance.new("UIScale")
					us.Name = "SupremacySlotsScale"
					us.Parent = lab
				end
				us.Scale = sc
				scaled[lab] = us
				-- tambien bajar TextSize si no esta TextScaled
				if not savedLayout[lab] then
					savedLayout[lab] = {
						pos = lab.Position,
						anchor = lab.AnchorPoint,
						textSize = lab.TextSize,
						textScaled = lab.TextScaled,
					}
				end
				if not lab.TextScaled then
					local base = savedLayout[lab].textSize or 14
					lab.TextSize = math.max(8, math.floor(base * sc + 0.5))
				end
				local h = 16
				pcall(function() h = math.max(lab.AbsoluteSize.Y, 10) end)
				lab.AnchorPoint = Vector2.new(0.5, 1)
				local parent = lab.Parent
				if parent and parent:IsA("GuiObject") then
					local pap = parent.AbsolutePosition
					lab.Position = UDim2.new(0.5, 0, 0, yCursor - pap.Y)
				else
					lab.Position = UDim2.new(0.5, 0, 0, yCursor)
				end
				yCursor = yCursor - h - 2
			end)
		end
	end



	local function applyAll()
		if not slotsOn then return end
		local sc = scaleFromPct()
		if sc >= 0.99 then
			-- 0 = tamaño normal: restaurar scales
			for obj, us in pairs(scaled) do
				pcall(function()
					if typeof(us) == "Instance" then us.Scale = 1 end
				end)
			end
			return
		end
		local items = findHotbarSlots()
		for _, t in ipairs(findTextsAboveSlots()) do
			table.insert(items, t)
		end
		local parents = {}
		for _, obj in ipairs(items) do
			local p = obj.Parent
			if p and p:IsA("GuiObject") then
				parents[p] = (parents[p] or 0) + 1
			end
		end
		local bestParent, bestN = nil, 0
		for p, n in pairs(parents) do
			if n > bestN then bestN = n bestParent = p end
		end
		local slotTop = nil
		if bestParent and bestN >= 3 then
			applyTo(bestParent, sc)
			pcall(function()
				slotTop = bestParent.AbsolutePosition.Y
			end)
		else
			for _, obj in ipairs(items) do
				applyTo(obj, sc)
			end
			pcall(function()
				local minT = 1e9
				for _, obj in ipairs(items) do
					if obj and obj.Parent then
						local t = obj.AbsolutePosition.Y
						if t < minT then minT = t end
					end
				end
				if minT < 1e9 then slotTop = minT end
			end)
		end
		placeSafeZoneAbove(sc, slotTop)
	end

	_G.SupremacySlotsMiniApply = function(v)
		slotsOn = v and true or false
		_G.SupremacySlotsMiniOn = slotsOn
		if conn then pcall(function() conn:Disconnect() end) conn = nil end
		if slotsOn then
			-- NO hide joystick/jump aqui (eso es Pc Format)
			slotsPct = tonumber(_G.SupremacySlotsMiniScale) or slotsPct or 0
			applyAll()
			task.delay(0.3, function() if slotsOn then pcall(applyAll) end end)
			task.delay(1.0, function() if slotsOn then pcall(applyAll) end end)
			task.delay(2.0, function() if slotsOn then pcall(applyAll) end end)
		else
			restoreSlots()
		end
	end
	_G.SupremacySlotsMiniValue = function(v)
		slotsPct = tonumber(v) or 0
		_G.SupremacySlotsMiniScale = slotsPct
		if slotsOn then
			pcall(applyAll)
		end
	end
	_G.SupremacySlotsMiniSetScale = function(v)
		slotsPct = tonumber(v) or 0
		_G.SupremacySlotsMiniScale = slotsPct
		if slotsOn then
			pcall(applyAll)
		end
	end
	_G.SupremacySlotsMiniOn = false
	_G.SupremacySlotsMiniScale = 0
end)()


-- Camera Zoom (Misc): solo sube el limite de zoom del juego.
-- NO fuerza CFrame cada frame (eso acercaba/alejaba solo y traspasaba suelo).
;(function()
	local enabled = false
	local zoomVal = 0
	local basePlrMax = nil
	local basePlrMin = nil
	local baseNameDist = nil
	local reasserting = false

	local function captureBase()
		pcall(function()
			if basePlrMax == nil then
				local v = player.CameraMaxZoomDistance
				if typeof(v) == "number" and v > 0 and v < 500 then
					basePlrMax = v
				else
					basePlrMax = 128
				end
			end
			if basePlrMin == nil then
				local v = player.CameraMinZoomDistance
				basePlrMin = (typeof(v) == "number" and v > 0) and v or 0.5
			end
			if baseNameDist == nil then
				baseNameDist = player.NameDisplayDistance
			end
		end)
	end

	local function maxAllowed()
		captureBase()
		local base = basePlrMax or 128
		if not zoomVal or zoomVal <= 0 then
			return base
		end
		-- 1..100 → base hasta base+2000
		return base + (zoomVal / 100) * 2000
	end

	local function unlockMax()
		if reasserting then return end
		reasserting = true
		pcall(function()
			local m = maxAllowed()
			local minZ = basePlrMin or 0.5
			player.CameraMaxZoomDistance = m
			player.CameraMinZoomDistance = minZ
			local cam = workspace.CurrentCamera
			if cam then
				pcall(function() cam.CameraMaxZoomDistance = m end)
				pcall(function() cam.CameraMinZoomDistance = minZ end)
			end
		end)
		reasserting = false
	end

	local function restore()
		pcall(function()
			if basePlrMax then player.CameraMaxZoomDistance = basePlrMax end
			if basePlrMin then player.CameraMinZoomDistance = basePlrMin end
			if baseNameDist ~= nil then player.NameDisplayDistance = baseNameDist end
			local cam = workspace.CurrentCamera
			if cam then
				if basePlrMax then pcall(function() cam.CameraMaxZoomDistance = basePlrMax end) end
				if basePlrMin then pcall(function() cam.CameraMinZoomDistance = basePlrMin end) end
			end
		end)
	end

	captureBase()

	-- Si BF resetea el max, volver a poner el nuestro (sin tocar CFrame)
	pcall(function()
		player:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(function()
			if not enabled or reasserting then return end
			local want = maxAllowed()
			local cur = player.CameraMaxZoomDistance
			if typeof(cur) == "number" and math.abs(cur - want) > 1 then
				unlockMax()
			end
		end)
	end)

	_G.SupremacyCameraZoomApply = function(on)
		enabled = on and true or false
		if enabled then
			captureBase()
			unlockMax()
			pcall(function()
				player.NameDisplayDistance = math.min(baseNameDist or 100, 80)
			end)
		else
			restore()
		end
	end
	_G.SupremacyCameraZoomValue = function(v)
		zoomVal = tonumber(v) or 0
		if enabled then
			unlockMax()
		end
	end

	-- Solo reafirma el limite de vez en cuando (NO mueve la camara)
	pcall(function()
		local acc = 0
		RunService.Heartbeat:Connect(function(dt)
			if not enabled then return end
			acc = acc + (dt or 0.03)
			if acc < 0.5 then return end
			acc = 0
			unlockMax()
		end)
	end)
end)()

-- FPS PAGE
;(function()
	local FpsPage = CreatePage("Fps")
	local Players = game:GetService("Players")
	local Lighting = game:GetService("Lighting")

	local state = {
		boost1 = false,
		boost2 = false,
		structTex = false,
		noShadows = false,
		noParticles = false,
		noFog = false,
	}
	_G.SupremacyFPSState = state

	local conns = {}
	local litBackup = nil
	local skyBackup = nil

	local function isParticle(obj)
		return obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")
	end

	local function isCharacterPart(obj)
		local p, g = obj, 0
		while p and p ~= workspace and g < 12 do
			if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then return true end
			p = p.Parent
			g = g + 1
		end
		return false
	end

	-- SOLO plataformas / suelos / paredes del mapa (NUNCA skills)
	local function isStructurePart(obj)
		if not obj:IsA("BasePart") then return false end
		if isCharacterPart(obj) then return false end
		-- skills casi siempre: no anclados, Neon, transparentes, CanCollide false
		if not obj.Anchored then return false end
		if obj.Transparency > 0.2 then return false end
		local mat = obj.Material
		if mat == Enum.Material.Neon or mat == Enum.Material.ForceField or mat == Enum.Material.Glass then
			return false
		end
		local n = string.lower(obj.Name)
		if n:find("effect") or n:find("skill") or n:find("vfx") or n:find("hitbox")
			or n:find("slash") or n:find("beam") or n:find("portal") or n:find("aura") then
			return false
		end
		if n:find("floor") or n:find("wall") or n:find("ceil") or n:find("roof")
			or n:find("ground") or n:find("base") or n:find("plat") or n:find("stair")
			or n:find("bridge") or n:find("dock") or n:find("road") or n:find("path")
			or n:find("slab") or n:find("terrain") or n:find("island") or n:find("rock")
			or n:find("sand") or n:find("grass") or n:find("wood") or n:find("plank")
			or n:find("build") or n:find("struct") or n:find("block") or n:find("part") then
			local s = obj.Size
			-- parts pequenos anclados con nombre generico no
			if n == "part" and s.X < 8 and s.Z < 8 then return false end
			return true
		end
		-- mapa: grande + anclado + material tipico de suelo
		local s = obj.Size
		if (s.X >= 16 or s.Z >= 16 or (s.X * s.Z >= 120)) then
			if mat == Enum.Material.SmoothPlastic or mat == Enum.Material.Plastic
				or mat == Enum.Material.Slate or mat == Enum.Material.Concrete
				or mat == Enum.Material.Grass or mat == Enum.Material.Sand
				or mat == Enum.Material.Wood or mat == Enum.Material.WoodPlanks
				or mat == Enum.Material.Brick or mat == Enum.Material.Cobblestone
				or mat == Enum.Material.Rock or mat == Enum.Material.Ground
				or mat == Enum.Material.Limestone or mat == Enum.Material.Asphalt
				or mat == Enum.Material.Mud or mat == Enum.Material.LeafyGrass
				or mat == Enum.Material.Glacier or mat == Enum.Material.Ice then
				return true
			end
		end
		return false
	end

	local function killFX(obj)
		pcall(function()
			if not obj or not obj.Parent then return end
			if obj:IsA("ParticleEmitter") then
				obj.Enabled = false
				obj.Rate = 0
			elseif obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
				obj.Enabled = false
			end
		end)
	end

	-- Boost 2: skills/props = 1 color plano, sin texturas/luces/particulas. NO estructuras.
	local function softTexture(obj)
		pcall(function()
			if not obj or not obj.Parent then return end
			if obj:IsA("BasePart") and isStructurePart(obj) then return end
			if obj.Parent and obj.Parent:IsA("BasePart") and isStructurePart(obj.Parent) then return end

			if obj:IsA("Texture") or obj:IsA("Decal") then
				if obj:GetAttribute("SupFPSTrans") == nil then
					obj:SetAttribute("SupFPSTrans", obj.Transparency)
				end
				obj.Transparency = 1
			elseif obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
				killFX(obj)
			elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
				if obj:GetAttribute("SupFPSLight") == nil then
					obj:SetAttribute("SupFPSLight", obj.Enabled)
				end
				if obj:GetAttribute("SupFPSBright") == nil then
					obj:SetAttribute("SupFPSBright", obj.Brightness)
				end
				obj.Enabled = false
				obj.Brightness = 0
			elseif obj:IsA("BasePart") then
				-- SOLO material plano, SIN cambiar Color (el color force = gris 1s)
				if obj:GetAttribute("SupFPSMat") == nil then
					obj:SetAttribute("SupFPSMat", obj.Material.Name)
				end
				if obj:GetAttribute("SupFPSRefl") == nil then
					obj:SetAttribute("SupFPSRefl", obj.Reflectance)
				end
				local hasMeshTex = false
				pcall(function()
					if obj:IsA("MeshPart") and obj.TextureID and obj.TextureID ~= "" then
						hasMeshTex = true
					end
				end)
				if not hasMeshTex then
					if obj:GetAttribute("SupFPSApplying") then return end
					obj:SetAttribute("SupFPSApplying", true)
					obj.Material = Enum.Material.SmoothPlastic
					obj:SetAttribute("SupFPSApplying", nil)
				end
				obj.Reflectance = 0
				-- si el juego revierte Material, volver a plastic (sin resweep global)
				if obj:GetAttribute("SupFPSWatch") == nil then
					obj:SetAttribute("SupFPSWatch", true)
					obj:GetPropertyChangedSignal("Material"):Connect(function()
						if not state.boost2 then return end
						if obj:GetAttribute("SupFPSApplying") then return end
						if isStructurePart(obj) then return end
						pcall(function()
							if obj.Material ~= Enum.Material.SmoothPlastic then
								local hasTex = false
								pcall(function()
									if obj:IsA("MeshPart") and obj.TextureID and obj.TextureID ~= "" then hasTex = true end
								end)
								if not hasTex then
									obj:SetAttribute("SupFPSApplying", true)
									obj.Material = Enum.Material.SmoothPlastic
									obj.Reflectance = 0
									obj:SetAttribute("SupFPSApplying", nil)
								end
							end
						end)
					end)
				end
			end
		end)
	end

	local function restoreTexture(obj)
		pcall(function()
			if obj:IsA("Texture") or obj:IsA("Decal") then
				local t = obj:GetAttribute("SupFPSTrans")
				if type(t) == "number" then
					obj.Transparency = t
					obj:SetAttribute("SupFPSTrans", nil)
				end
			elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
				local en = obj:GetAttribute("SupFPSLight")
				if en ~= nil then
					obj.Enabled = en and true or false
					obj:SetAttribute("SupFPSLight", nil)
				end
				local br = obj:GetAttribute("SupFPSBright")
				if type(br) == "number" then
					obj.Brightness = br
					obj:SetAttribute("SupFPSBright", nil)
				end
			elseif obj:IsA("BasePart") then
				local mat = obj:GetAttribute("SupFPSMat")
				if mat then
					pcall(function() obj.Material = Enum.Material[mat] end)
					obj:SetAttribute("SupFPSMat", nil)
				end
				local refl = obj:GetAttribute("SupFPSRefl")
				if type(refl) == "number" then
					obj.Reflectance = refl
					obj:SetAttribute("SupFPSRefl", nil)
				end
				local col = obj:GetAttribute("SupFPSColor2")
				if type(col) == "string" then
					local r, g, b = string.match(col, "([^,]+),([^,]+),([^,]+)")
					if r then obj.Color = Color3.new(tonumber(r) or 1, tonumber(g) or 1, tonumber(b) or 1) end
					obj:SetAttribute("SupFPSColor2", nil)
				end
			end
		end)
	end

	local function applyStructTex(obj)
		pcall(function()
			if not obj:IsA("BasePart") then return end
			if isCharacterPart(obj) then return end
			if not isStructurePart(obj) then return end
			if obj:GetAttribute("SupFPSMat") == nil then
				obj:SetAttribute("SupFPSMat", obj.Material.Name)
			end
			if obj:GetAttribute("SupFPSRefl") == nil then
				obj:SetAttribute("SupFPSRefl", obj.Reflectance)
			end
			local ok = pcall(function() obj.Material = Enum.Material.Cardboard end)
			if not ok then pcall(function() obj.Material = Enum.Material.SmoothPlastic end) end
			obj.Reflectance = 0
			-- color propio un poco mas claro
			if obj:GetAttribute("SupFPSColor") == nil then
				local c = obj.Color
				obj:SetAttribute("SupFPSColor", string.format("%f,%f,%f", c.R, c.G, c.B))
				obj.Color = Color3.new(
					math.clamp(c.R * 1.1 + 0.03, 0, 1),
					math.clamp(c.G * 1.1 + 0.03, 0, 1),
					math.clamp(c.B * 1.1 + 0.03, 0, 1)
				)
			end
		end)
	end

	local function restoreStruct(obj)
		pcall(function()
			if not obj:IsA("BasePart") then return end
			local mat = obj:GetAttribute("SupFPSMat")
			if mat then
				pcall(function() obj.Material = Enum.Material[mat] end)
				obj:SetAttribute("SupFPSMat", nil)
			end
			local refl = obj:GetAttribute("SupFPSRefl")
			if type(refl) == "number" then
				obj.Reflectance = refl
				obj:SetAttribute("SupFPSRefl", nil)
			end
			local col = obj:GetAttribute("SupFPSColor")
			if type(col) == "string" then
				local r, g, b = string.match(col, "([^,]+),([^,]+),([^,]+)")
				if r then obj.Color = Color3.new(tonumber(r) or 1, tonumber(g) or 1, tonumber(b) or 1) end
				obj:SetAttribute("SupFPSColor", nil)
			end
		end)
	end

	local function killShadow(obj)
		pcall(function()
			if obj:IsA("BasePart") then
				if obj:GetAttribute("SupFPSShadow") == nil then
					obj:SetAttribute("SupFPSShadow", obj.CastShadow)
				end
				obj.CastShadow = false
			end
		end)
	end

	local function restoreShadow(obj)
		pcall(function()
			if obj:IsA("BasePart") then
				local sh = obj:GetAttribute("SupFPSShadow")
				if sh ~= nil then
					obj.CastShadow = sh and true or false
					obj:SetAttribute("SupFPSShadow", nil)
				end
			end
		end)
	end

	local function killLight(obj)
		pcall(function()
			if not obj or not obj.Parent then return end
			if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
				if obj:GetAttribute("SupFPSLight") == nil then
					obj:SetAttribute("SupFPSLight", obj.Enabled)
				end
				if obj:GetAttribute("SupFPSBright") == nil then
					obj:SetAttribute("SupFPSBright", obj.Brightness)
				end
				obj.Enabled = false
				obj.Brightness = 0
				pcall(function() obj.Range = 0 end)
			elseif obj:IsA("Fire") then
				if obj:GetAttribute("SupFPSEn") == nil then
					obj:SetAttribute("SupFPSEn", obj.Enabled)
				end
				obj.Enabled = false
			elseif obj:IsA("ParticleEmitter") then
				if obj:GetAttribute("SupFPSLE") == nil then
					obj:SetAttribute("SupFPSLE", obj.LightEmission)
				end
				obj.LightEmission = math.min(obj.LightEmission, 0.08)
			elseif obj:IsA("Beam") or obj:IsA("Trail") then
				pcall(function()
					if obj:GetAttribute("SupFPSLE") == nil then
						obj:SetAttribute("SupFPSLE", obj.LightEmission)
					end
					obj.LightEmission = math.min(obj.LightEmission or 0, 0.08)
				end)
			elseif obj:IsA("BasePart") then
				-- quitar Neon / ForceField (brillo) sin dejar negro
				local mat = obj.Material
				if mat == Enum.Material.Neon or mat == Enum.Material.ForceField then
					if obj:GetAttribute("SupFPSMatL") == nil then
						obj:SetAttribute("SupFPSMatL", mat.Name)
					end
					if obj:GetAttribute("SupFPSNeonC") == nil then
						local c = obj.Color
						obj:SetAttribute("SupFPSNeonC", string.format("%f,%f,%f", c.R, c.G, c.B))
					end
					obj.Material = Enum.Material.SmoothPlastic
					obj.Reflectance = 0
					local c = obj.Color
					local avg = (c.R + c.G + c.B) / 3
					if avg < 0.2 then
						obj.Color = Color3.new(
							math.clamp(c.R + 0.45, 0, 1),
							math.clamp(c.G + 0.45, 0, 1),
							math.clamp(c.B + 0.45, 0, 1)
						)
					end
				end
			end
		end)
	end

	local function restoreLight(obj)
		pcall(function()
			if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
				local en = obj:GetAttribute("SupFPSLight")
				if en ~= nil then
					obj.Enabled = en and true or false
					obj:SetAttribute("SupFPSLight", nil)
				end
				local br = obj:GetAttribute("SupFPSBright")
				if type(br) == "number" then
					obj.Brightness = br
					obj:SetAttribute("SupFPSBright", nil)
				end
			elseif obj:IsA("Fire") then
				local en = obj:GetAttribute("SupFPSEn")
				if en ~= nil then
					obj.Enabled = en and true or false
					obj:SetAttribute("SupFPSEn", nil)
				end
			elseif obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
				local le = obj:GetAttribute("SupFPSLE")
				if type(le) == "number" then
					pcall(function() obj.LightEmission = le end)
					obj:SetAttribute("SupFPSLE", nil)
				end
			elseif obj:IsA("BasePart") then
				local mat = obj:GetAttribute("SupFPSMatL")
				if mat then
					pcall(function() obj.Material = Enum.Material[mat] end)
					obj:SetAttribute("SupFPSMatL", nil)
				end
				local col = obj:GetAttribute("SupFPSNeonC")
				if type(col) == "string" then
					local r, g, b = string.match(col, "([^,]+),([^,]+),([^,]+)")
					if r then obj.Color = Color3.new(tonumber(r) or 1, tonumber(g) or 1, tonumber(b) or 1) end
					obj:SetAttribute("SupFPSNeonC", nil)
				end
			end
		end)
	end

	local function processNew(obj)
		if state.noParticles or state.boost1 then
			if isParticle(obj) then killFX(obj) end
		end
		if state.boost1 then
			applyStructTex(obj)
		end
		if state.boost2 then
			softTexture(obj)
			if isParticle(obj) then killFX(obj) end
		end
		if state.structTex then applyStructTex(obj) end
		if state.noShadows then killShadow(obj) end
	end

	local function sweep(fn, batchSize)
		task.spawn(function()
			local list = workspace:GetDescendants()
			local i, n = 1, #list
			batchSize = batchSize or 250
			while i <= n do
				local batch = 0
				while i <= n and batch < batchSize do
					pcall(fn, list[i])
					i = i + 1
					batch = batch + 1
				end
				task.wait()
			end
		end)
	end

	local function clearConns()
		for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
		table.clear(conns)
	end

	local function ensureDescendantHook()
		-- un solo hook para todo lo nuevo
		for _, c in pairs(conns) do
			if typeof(c) == "RBXScriptConnection" then end
		end
		-- siempre reconectar limpio
		clearConns()
		table.insert(conns, workspace.DescendantAdded:Connect(function(obj)
			processNew(obj)
		end))
		for _, plr in pairs(Players:GetPlayers()) do
			if plr.Character then
				for _, o in pairs(plr.Character:GetDescendants()) do
					if (state.noParticles or state.boost1 or state.boost2) and isParticle(o) then
						killFX(o)
					end
				end
			end
			table.insert(conns, plr.CharacterAdded:Connect(function(char)
				task.wait(0.15)
				if not char then return end
				for _, o in pairs(char:GetDescendants()) do
					if (state.noParticles or state.boost1 or state.boost2) and isParticle(o) then
						killFX(o)
					end
				end
				table.insert(conns, char.DescendantAdded:Connect(function(o)
					if (state.noParticles or state.boost1 or state.boost2) and isParticle(o) then
						killFX(o)
					end
				end))
			end))
		end
		table.insert(conns, Players.PlayerAdded:Connect(function(plr)
			table.insert(conns, plr.CharacterAdded:Connect(function(char)
				task.wait(0.15)
				if not char then return end
				for _, o in pairs(char:GetDescendants()) do
					if (state.noParticles or state.boost1 or state.boost2) and isParticle(o) then
						killFX(o)
					end
				end
			end))
		end))
	end

	local function refreshHooks()
		local any = state.boost1 or state.boost2 or state.structTex or state.noShadows or state.noParticles
		clearConns()
		if any then ensureDescendantHook() end
	end

	-- ===== toggles individuales =====
	local function setBoost1(on)
		state.boost1 = on and true or false
		if on then
			-- particulas + textura carton SOLO en plataformas/estructuras
			sweep(function(o)
				if isParticle(o) then killFX(o) end
				applyStructTex(o)
			end)
		else
			-- si Structure Texture no esta activo, restaurar estructuras
			if not state.structTex then
				sweep(restoreStruct)
			end
		end
		refreshHooks()
	end

	local function setBoost2(on)
		state.boost2 = on and true or false
		if on then
			-- 1 solo barrido; lo nuevo va por DescendantAdded (sin loop = menos lag)
			sweep(softTexture)
		else
			sweep(restoreTexture)
		end
		refreshHooks()
	end

	local function setStructTex(on)
		state.structTex = on and true or false
		if on then
			sweep(applyStructTex)
		else
			-- no restaurar si FPS Boost sigue activo (tambien usa struct tex)
			if not state.boost1 then
				sweep(restoreStruct)
			end
		end
		refreshHooks()
	end

	local shadowLoop = nil
	local function setNoShadows(on)
		state.noShadows = on and true or false
		pcall(function()
			if shadowLoop then pcall(function() shadowLoop:Disconnect() end) shadowLoop = nil end
			if on then
				if not litBackup then litBackup = {} end
				if litBackup.GlobalShadows == nil then
					litBackup.GlobalShadows = Lighting.GlobalShadows
				end
				Lighting.GlobalShadows = false
				sweep(killShadow)
				-- solo mantener GlobalShadows off (barato), sin resweep cada 2s
				shadowLoop = game:GetService("RunService").Heartbeat:Connect(function()
					if not state.noShadows then return end
					if Lighting.GlobalShadows then
						Lighting.GlobalShadows = false
					end
				end)
			else
				if litBackup and litBackup.GlobalShadows ~= nil then
					Lighting.GlobalShadows = litBackup.GlobalShadows
					litBackup.GlobalShadows = nil
				end
				sweep(restoreShadow)
			end
		end)
		refreshHooks()
	end

	local function setNoParticles(on)
		state.noParticles = on and true or false
		if on then
			sweep(function(o) if isParticle(o) then killFX(o) end end)
		end
		refreshHooks()
	end


	local fogBackup = nil
	local fogLoop = nil
	local function applyNoFogNow()
		pcall(function()
			Lighting.FogStart = 0
			Lighting.FogEnd = 1e10
			Lighting.FogColor = Color3.fromRGB(200, 200, 200)
			pcall(function()
				Lighting.EnvironmentDiffuseScale = 0
				Lighting.EnvironmentSpecularScale = 0
			end)
			for _, ch in pairs(Lighting:GetChildren()) do
				if ch:IsA("Atmosphere") then
					if fogBackup and fogBackup.atmos then
						local known = false
						for _, a in pairs(fogBackup.atmos) do
							if a.obj == ch then known = true break end
						end
						if not known then
							table.insert(fogBackup.atmos, {
								obj = ch, Density = ch.Density, Offset = ch.Offset,
								Color = ch.Color, Decay = ch.Decay, Glare = ch.Glare, Haze = ch.Haze,
							})
						end
					end
					-- cero total + sacar de Lighting
					ch.Density = 0
					ch.Haze = 0
					ch.Offset = 0
					ch.Glare = 0
					ch.Parent = nil
				end
			end
			local terrain = workspace:FindFirstChildOfClass("Terrain")
			if terrain then
				for _, c in pairs(terrain:GetChildren()) do
					if c:IsA("Clouds") then
						if c:GetAttribute("SupFPSCloud") == nil then
							c:SetAttribute("SupFPSCloud", c.Enabled and 1 or 0)
						end
						c.Enabled = false
						pcall(function() c.Cover = 0 end)
						pcall(function() c.Density = 0 end)
					end
				end
			end
			for _, fx in pairs(Lighting:GetChildren()) do
				if fx:IsA("BloomEffect") then
					if fx:GetAttribute("SupFPSFogBloom") == nil then
						fx:SetAttribute("SupFPSFogBloom", fx.Enabled and 1 or 0)
						fx:SetAttribute("SupFPSFogBloomI", fx.Intensity)
						fx:SetAttribute("SupFPSFogBloomS", fx.Size)
						fx:SetAttribute("SupFPSFogBloomT", fx.Threshold)
					end
					fx.Intensity = 0
					fx.Size = 0
					fx.Enabled = false
				elseif fx:IsA("DepthOfFieldEffect") then
					if fx:GetAttribute("SupFPSFogDOF") == nil then
						fx:SetAttribute("SupFPSFogDOF", fx.Enabled and 1 or 0)
					end
					fx.Enabled = false
				elseif fx:IsA("SunRaysEffect") then
					if fx:GetAttribute("SupFPSFogSun") == nil then
						fx:SetAttribute("SupFPSFogSun", fx.Enabled and 1 or 0)
					end
					fx.Enabled = false
				elseif fx:IsA("ColorCorrectionEffect") then
					-- no tocar mucho; solo si tiene contraste de niebla raro
				end
			end
		end)
	end

	local function setNoFog(on)
		state.noFog = on and true or false
		pcall(function()
			if fogLoop then pcall(function() fogLoop:Disconnect() end) fogLoop = nil end
			if on then
				if not fogBackup then
					fogBackup = {
						FogStart = Lighting.FogStart,
						FogEnd = Lighting.FogEnd,
						FogColor = Lighting.FogColor,
						atmos = {},
					}
					for _, ch in pairs(Lighting:GetChildren()) do
						if ch:IsA("Atmosphere") then
							table.insert(fogBackup.atmos, {
								obj = ch,
								Density = ch.Density,
								Offset = ch.Offset,
								Color = ch.Color,
								Decay = ch.Decay,
								Glare = ch.Glare,
								Haze = ch.Haze,
							})
						end
					end
				end
				applyNoFogNow()
				local atmBlock
				atmBlock = Lighting.ChildAdded:Connect(function(ch)
					if not state.noFog then return end
					if ch:IsA("Atmosphere") then
						if fogBackup then
							table.insert(fogBackup.atmos, {
								obj = ch, Density = ch.Density, Offset = ch.Offset,
								Color = ch.Color, Decay = ch.Decay, Glare = ch.Glare, Haze = ch.Haze,
							})
						end
						task.defer(function() ch.Parent = nil end)
					end
				end)
				fogLoop = game:GetService("RunService").RenderStepped:Connect(function()
					if not state.noFog then return end
					applyNoFogNow()
				end)
				-- guardar conn en fogBackup para disconnect
				if fogBackup then fogBackup.atmBlock = atmBlock end
			else
				if fogBackup then
					if fogBackup.atmBlock then pcall(function() fogBackup.atmBlock:Disconnect() end) end
					Lighting.FogStart = fogBackup.FogStart or 0
					Lighting.FogEnd = fogBackup.FogEnd or 100000
					if fogBackup.FogColor then Lighting.FogColor = fogBackup.FogColor end
					for _, a in pairs(fogBackup.atmos or {}) do
						pcall(function()
							if a.obj then
								a.obj.Density = a.Density
								a.obj.Offset = a.Offset
								a.obj.Color = a.Color
								a.obj.Decay = a.Decay
								a.obj.Glare = a.Glare
								a.obj.Haze = a.Haze
								a.obj.Parent = Lighting
							end
						end)
					end
					for _, fx in pairs(Lighting:GetChildren()) do
						if fx:IsA("BloomEffect") and fx:GetAttribute("SupFPSFogBloom") ~= nil then
							fx.Enabled = fx:GetAttribute("SupFPSFogBloom") == 1
							local i = fx:GetAttribute("SupFPSFogBloomI")
							local s = fx:GetAttribute("SupFPSFogBloomS")
							local t = fx:GetAttribute("SupFPSFogBloomT")
							if type(i) == "number" then fx.Intensity = i end
							if type(s) == "number" then fx.Size = s end
							if type(t) == "number" then fx.Threshold = t end
							fx:SetAttribute("SupFPSFogBloom", nil)
							fx:SetAttribute("SupFPSFogBloomI", nil)
							fx:SetAttribute("SupFPSFogBloomS", nil)
							fx:SetAttribute("SupFPSFogBloomT", nil)
						end
					end
					local terrain = workspace:FindFirstChildOfClass("Terrain")
					if terrain then
						for _, c in pairs(terrain:GetChildren()) do
							if c:IsA("Clouds") then
								local e = c:GetAttribute("SupFPSCloud")
								if e ~= nil then
									c.Enabled = e == 1
									c:SetAttribute("SupFPSCloud", nil)
								end
							end
						end
					end
					fogBackup = nil
				end
			end
		end)
	end

	-- API save/load
	_G.SupremacyGetFPSState = function()
		return {
			FPSBoost = state.boost1,
			FPSBoost2 = state.boost2,
			FPSStructTex = state.structTex,
			FPSNoShadows = state.noShadows,
			FPSNoParticles = state.noParticles,
			FPSNoFog = state.noFog,
		}
	end
	_G.SupremacyApplyFPSState = function(t)
		if type(t) ~= "table" then return end
		if t.FPSBoost ~= nil then setBoost1(t.FPSBoost) end
		if t.FPSBoost2 ~= nil then setBoost2(t.FPSBoost2) end
		if t.FPSStructTex ~= nil then setStructTex(t.FPSStructTex) end
		if t.FPSNoShadows ~= nil then setNoShadows(t.FPSNoShadows) end
		if t.FPSNoParticles ~= nil then setNoParticles(t.FPSNoParticles) end
		if t.FPSNoFog ~= nil then setNoFog(t.FPSNoFog) end
		pcall(function()
			local tu = _G.SupremacyToggleUpdates
			if not tu then return end
			if tu["Fast Flags"] then tu["Fast Flags"](state.boost1) end
			if tu["Fast Flags 2"] then tu["Fast Flags 2"](state.boost2) end
			if tu["Structure Texture"] then tu["Structure Texture"](state.structTex) end
			if tu["No Shadows"] then tu["No Shadows"](state.noShadows) end
			if tu["No Particles"] then tu["No Particles"](state.noParticles) end
			if tu["No Fog"] then tu["No Fog"](state.noFog) end
		end)
	end

	-- compat viejo
	_G.SupremacySetFPSMode = function(m)
		m = tonumber(m) or 0
		setBoost1(m == 1)
		setBoost2(m == 2)
		if m == 3 then
			setStructTex(true)
			setNoParticles(true)
		end
	end
	_G.SupremacyFPSMode = 0
	_G.SupremacySetFPSBoost = function(v)
		setBoost2(v and true or false)
	end

	-- No GFX V1 (EXACTO NamelessWare)
	local noGfxOn = false
	local noGfxConnections = {}
	local noGfxModifiedObjects = {}

	local function restoreNoGfx()
		for obj, data in pairs(noGfxModifiedObjects) do
			pcall(function()
				if data.Texture ~= nil then obj.Texture = data.Texture end
				if data.Enabled ~= nil then obj.Enabled = data.Enabled end
			end)
		end
		noGfxModifiedObjects = {}
		if noGfxConnections.DescendantAdded then
			pcall(function() noGfxConnections.DescendantAdded:Disconnect() end)
			noGfxConnections.DescendantAdded = nil
		end
	end

	-- Nameless: solo Beam/Trail → textura solida, ParticleEmitter → off
	local function processObject(inst)
		pcall(function()
			local className = inst.ClassName
			if className == "Beam" or className == "Trail" then
				if not noGfxModifiedObjects[inst] then
					noGfxModifiedObjects[inst] = { Texture = inst.Texture }
					inst.Texture = "rbxassetid://84308155859778"
				end
			elseif className == "ParticleEmitter" then
				if not noGfxModifiedObjects[inst] then
					noGfxModifiedObjects[inst] = { Texture = inst.Texture, Enabled = inst.Enabled }
					inst.Texture = ""
					inst.Enabled = false
				end
			end
		end)
	end

	local function startNoGfxV1()
		restoreNoGfx()
		task.spawn(function()
			local descendants = workspace:GetDescendants()
			for i = 1, #descendants do
				local inst = descendants[i]
				if not inst:IsA("Terrain") and not inst:IsA("Camera") then
					processObject(inst)
				end
				if i % 100 == 0 then
					RunService.Heartbeat:Wait()
				end
			end
		end)
		noGfxConnections.DescendantAdded = workspace.DescendantAdded:Connect(processObject)
	end

	local function setNoGfxV1(on)
		noGfxOn = on and true or false
		if on then
			startNoGfxV1()
		else
			restoreNoGfx()
		end
	end
	_G.SupremacyNoGfxV1 = setNoGfxV1

	CreateToggle(FpsPage, "Fast Flags", false, function(v) setBoost1(v) end)
	CreateToggle(FpsPage, "Fast Flags 2", false, function(v) setBoost2(v) end)
	CreateToggle(FpsPage, "Fast Flags 3", false, function(v) setNoGfxV1(v) end)
	CreateToggle(FpsPage, "Structure Texture", false, function(v) setStructTex(v) end)
	CreateToggle(FpsPage, "No Shadows", false, function(v) setNoShadows(v) end)
	CreateToggle(FpsPage, "No Particles", false, function(v) setNoParticles(v) end)
	CreateToggle(FpsPage, "No Fog", false, function(v) setNoFog(v) end)

end)()


-- WHITELIST
local WhiteListPage = CreatePage("WhiteList")
;(function()
	local searchBox = nil
	local listHost = nil
	local rowMap = {}

	-- 1) Barra de busqueda PRIMERO + boton Refresh al lado (sin bordes redondeados)
	local searchRow = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		ZIndex = 200,
		Parent = WhiteListPage
	})

	searchBox = Create("TextBox", {
		Size = UDim2.new(1, -58, 0, 22),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = tr("Buscar jugador..."),
		PlaceholderColor3 = Color3.fromRGB(130, 130, 130),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(230, 230, 230),
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ZIndex = 201,
		Parent = searchRow
	})
	-- SIN UICorner (sin bordes redondeados)
	local sPad = Instance.new("UIPadding")
	sPad.PaddingLeft = UDim.new(0, 8)
	sPad.PaddingRight = UDim.new(0, 8)
	sPad.Parent = searchBox
	_G.SupremacyWLSearch = searchBox

	local refreshBtn = Create("TextButton", {
		Size = UDim2.new(0, 52, 0, 22),
		Position = UDim2.new(1, -52, 0, 0),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0,
		Text = tr("Refresh"),
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = Color3.fromRGB(230, 230, 230),
		AutoButtonColor = false,
		ZIndex = 201,
		Parent = searchRow
	})
	_G.SupremacyWLRefresh = refreshBtn
	registerLangLabel("Refresh", refreshBtn)
	-- SIN UICorner

	-- 2) Texto de ejemplo DEBAJO de la barra (poco espacio)
	local info = Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = tr("WL_INFO"),
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 0,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextWrapped = true,
		ZIndex = 201,
		Parent = WhiteListPage
	})
	registerLangLabel("WL_INFO", info)

	listHost = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 200,
		Parent = WhiteListPage
	})
	Create("UIListLayout", {
		Padding = UDim.new(0, 1),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = listHost
	})

	local function makePlayerRow(plr)
		if rowMap[plr.UserId] then return end
		local display = plr.DisplayName or plr.Name
		local label = string.format("%s [%s]", plr.Name, display)
		local row = CreateToggle(listHost, label, WhiteListProtected[plr.UserId] == true, function(v)
			if v then
				WhiteListProtected[plr.UserId] = true
			else
				WhiteListProtected[plr.UserId] = nil
			end
		end)
		row.Name = "WL_" .. tostring(plr.UserId)
		rowMap[plr.UserId] = row
	end

	local function clearRows()
		for uid, row in pairs(rowMap) do
			pcall(function() row:Destroy() end)
		end
		rowMap = {}
	end

	local function refreshList(filter)
		filter = string.lower(tostring(filter or ""))
		clearRows()
		local list = Players:GetPlayers()
		table.sort(list, function(a, b)
			return string.lower(a.Name) < string.lower(b.Name)
		end)
		for _, plr in ipairs(list) do
			if plr ~= player then
				local name = string.lower(plr.Name)
				local disp = string.lower(plr.DisplayName or "")
				if filter == "" or name:find(filter, 1, true) or disp:find(filter, 1, true) then
					makePlayerRow(plr)
				end
			end
		end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		refreshList(searchBox.Text)
	end)

	refreshBtn.MouseButton1Click:Connect(function()
		refreshList(searchBox.Text)
		refreshBtn.Text = "..."
		task.delay(0.25, function()
			if refreshBtn and refreshBtn.Parent then
				refreshBtn.Text = tr("Refresh")
			end
		end)
	end)

	Players.PlayerAdded:Connect(function()
		task.defer(function() refreshList(searchBox and searchBox.Text or "") end)
	end)
	Players.PlayerRemoving:Connect(function(plr)
		-- no borramos de WhitelistedPlayers al salir: al volver pueden seguir marcados si Team Check ON
		if rowMap[plr.UserId] then
			pcall(function() rowMap[plr.UserId]:Destroy() end)
			rowMap[plr.UserId] = nil
		end
	end)

	task.defer(function()
		refreshList("")
	end)

	_G.SupremacyRefreshWhiteList = function()
		refreshList(searchBox and searchBox.Text or "")
	end
end)()

-- CONFIG
local ConfigPage = CreatePage("Config")

-- FILE MANAGER
;(function()
	local CONFIG_FOLDER = "SupremacyHub/configs"
	local fmFrame = nil

	local function ensureFolder()
		pcall(function()
			if isfolder and makefolder then
				if not isfolder("SupremacyHub") then makefolder("SupremacyHub") end
				if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
			end
		end)
	end

	local function colorToHex(c)
		return string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
	end

	local function udim2ToTable(u)
		if typeof(u) ~= "UDim2" then return nil end
		return { u.X.Scale, u.X.Offset, u.Y.Scale, u.Y.Offset }
	end

	local function tableToUDim2(t)
		if type(t) ~= "table" then return nil end
		local a, b, c, d = t[1], t[2], t[3], t[4]
		if type(a) ~= "number" or type(b) ~= "number" or type(c) ~= "number" or type(d) ~= "number" then
			return nil
		end
		return UDim2.new(a, b, c, d)
	end

	local function collectConfig()
		-- actualizar posiciones actuales antes de guardar
		pcall(function()
			if FreezeContainer then savedFreezePos = FreezeContainer.Position end
			if AimbotBtn then savedAimbotPos = AimbotBtn.Position end
			if Predict.container then Predict.pos = Predict.container.Position end
			if SuperJumpContainer then savedSuperJumpPos = SuperJumpContainer.Position end
			if lagGui then
				local f = lagGui:FindFirstChildOfClass("Frame")
				if f then savedLagPos = f.Position end
			end
			if OpenBtn then
				-- guardar boton del menu tambien
			end
		end)
		return {
			AimbotEnabled = AimbotEnabled,
			AimbotButtonEnabled = AimbotButtonEnabled,
			AimbotSmooth = AimbotSmooth,
			SmoothingEnabled = SmoothingEnabled,
			AimPart = AimPart,
			FOVCircleEnabled = FOVCircleEnabled,
			FOVCircleColor = colorToHex(FOVCircleColor),
			FOVHideEnabled = FOVHideEnabled,
			FOVSizeEnabled = FOVSizeEnabled,
			FOVSize = FOVSize,
			AimDistanceEnabled = AimDistanceEnabled,
			AimDistanceValue = AimDistanceValue,
			SilentAimEnabled = SilentAimEnabled,
			SoruAimbotEnabled = SoruAimbotEnabled,
			PredictEnabled = Predict.on,
			PredictButtonEnabled = Predict.keyOn,
			PredictYValue = Predict.y,
			PredictXValue = Predict.x,
			PredictPos = udim2ToTable(Predict.pos),
			KeyPredict = (function()
				local k = _G.SupremacyKeys
				return (k and k["Predict"]) or "P"
			end)(),
			FPSBoost = (_G.SupremacyFPSState and _G.SupremacyFPSState.boost1) or false,
			FPSBoost2 = (_G.SupremacyFPSState and _G.SupremacyFPSState.boost2) or false,
			FPSStructTex = (_G.SupremacyFPSState and _G.SupremacyFPSState.structTex) or false,
			FPSNoShadows = (_G.SupremacyFPSState and _G.SupremacyFPSState.noShadows) or false,
			FPSNoParticles = (_G.SupremacyFPSState and _G.SupremacyFPSState.noParticles) or false,
			FPSNoFog = (_G.SupremacyFPSState and _G.SupremacyFPSState.noFog) or false,

			ESPBoxEnabled = ESPBoxEnabled,
			ESPBoxColor = colorToHex(ESPBoxColor),
			ESPType = ESPType,
			ESPFilled = ESPFilled,
			ESPNameEnabled = ESPNameEnabled,
			ESPNameColor = colorToHex(ESPNameColor),
			ESPDistanceEnabled = ESPDistanceEnabled,
			ESPDistanceColor = colorToHex(ESPDistanceColor),
			ESPHealthEnabled = ESPHealthEnabled,
			ESPSnapLineEnabled = ESPSnapLineEnabled,
			ESPSnapLineColor = colorToHex(ESPSnapLineColor),
			ESPAntennaEnabled = ESPAntennaEnabled,
			ESPAntennaColor = colorToHex(ESPAntennaColor),
			LimitDistanceEnabled = LimitDistanceEnabled,
			LimitDistanceValue = LimitDistanceValue,
			TeamCheckEnabled = TeamCheckEnabled,
			NPCCheckEnabled = NPCCheckEnabled,
			HealthCheckEnabled = HealthCheckEnabled,
			FreezeEnabled = FreezeEnabled,
			ZSanguineBoostEnabled = ZSanguineBoostEnabled,
			SuperDashEnabled = SuperDashEnabled,
			SuperDashSpeed = SuperDashSpeed,
			NoclipEnabled = NoclipEnabled,
			AntiLavaEnabled = AntiLavaEnabled,
			InfiniteJumpEnabled = InfiniteJumpEnabled,
			SuperJumpEnabled = SuperJumpEnabled,
			SafeZoneEnabled = SafeZoneEnabled,
			SafeZoneHealth = SafeZoneHealth,
			ButtonOpacityEnabled = ButtonOpacityEnabled,
			ButtonOpacity = ButtonOpacity,
			MenuButtonOpacityEnabled = MenuButtonOpacityEnabled,
			FreezePos = udim2ToTable(savedFreezePos),
			AimbotBtnPos = udim2ToTable(savedAimbotPos),
			LagPos = udim2ToTable(savedLagPos),
			SuperJumpPos = udim2ToTable(savedSuperJumpPos),
			OpenBtnPos = OpenBtn and udim2ToTable(OpenBtn.Position) or nil,
			KeySanguine = (function()
				local k = _G.SupremacyKeys
				return (k and k["Sanguine Z Boost"]) or "Z"
			end)(),
			KeyFreeze = (function()
				local k = _G.SupremacyKeys
				return (k and k["Tab (Freeze)"]) or "T"
			end)(),
			KeySuperJump = (function()
				local k = _G.SupremacyKeys
				return (k and k["Super Jump"]) or "J"
			end)(),
			KeyAimbot = (function()
				local k = _G.SupremacyKeys
				return (k and (k["Aimbot Key"] or k["Aimbot Button"])) or "A"
			end)(),
			-- NO se guarda lo de dentro del Assistant (Enable, Voice, Sense, Practice, etc.)
			ClickSoundName = ClickSoundName or "None",
			ClickSoundId = (function()
				for _, info in ipairs(CLICK_SOUNDS) do
					if info.name == ClickSoundName then return info.id end
				end
				return ClickSoundId or ""
			end)(),
			ClickSoundSpeed = (function()
				for _, info in ipairs(CLICK_SOUNDS) do
					if info.name == ClickSoundName then return info.speed or 1 end
				end
				return ClickSoundSpeed or 1
			end)(),
			ClickSoundVol = (function()
				for _, info in ipairs(CLICK_SOUNDS) do
					if info.name == ClickSoundName then return info.vol or 3.5 end
				end
				return ClickSoundVol or 3.5
			end)(),
			CrosshairMode = (_G.SupremacyCrosshairMode and _G.SupremacyCrosshairMode()) or "None",
			-- Config page (todo el menu principal)
			PcFormat = _G.SupremacyPcFormatOn == true,
			SlotsMiniOn = _G.SupremacySlotsMiniOn == true,
			SlotsMiniScale = tonumber(_G.SupremacySlotsMiniScale) or 0,
			CameraZoomOn = _G.SupremacyCameraZoomOn == true,
			CameraZoomValue = tonumber(_G.SupremacyCameraZoomVal) or 0,
			HideSkills = _G.SupremacyHideSkillsOn == true,
			HideUse = _G.SupremacyHideUseOn == true,
			HideGunCursor = _G.SupremacyHideGunCursorOn == true,
			PredictYEnabled = Predict.yOn == true,
			PredictXEnabled = Predict.xOn == true,
			-- Visual checks + whitelist
			TeamCheckEnabled = TeamCheckEnabled == true,
			NPCCheckEnabled = NPCCheckEnabled == true,
			HealthCheckEnabled = HealthCheckEnabled == true,
			WhitelistedIds = (function()
				local t = {}
				for uid, on in pairs(WhitelistedPlayers) do
					if on then table.insert(t, tostring(uid)) end
				end
				return table.concat(t, ",")
			end)(),
		}
	end

	local function encodeConfig(tbl)
		local lines = {}
		for k, v in pairs(tbl) do
			local val
			if type(v) == "boolean" then
				val = v and "true" or "false"
			elseif type(v) == "number" then
				val = tostring(v)
			elseif type(v) == "table" then
				if v[1] ~= nil and v[2] ~= nil and v[3] ~= nil and v[4] ~= nil then
					val = string.format("%s,%s,%s,%s", tostring(v[1]), tostring(v[2]), tostring(v[3]), tostring(v[4]))
				else
					val = ""
				end
			else
				val = tostring(v):gsub("\n", " ")
			end
			table.insert(lines, tostring(k) .. "=" .. val)
		end
		table.sort(lines)
		return table.concat(lines, "\n")
	end

	local function showAlert(parent, message, onAccept)
		local overlay = Instance.new("Frame")
		overlay.Size = UDim2.new(1, 0, 1, 0)
		overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		overlay.BackgroundTransparency = 0.45
		overlay.BorderSizePixel = 0
		overlay.ZIndex = 500
		overlay.Parent = parent

		local box = Instance.new("Frame")
		box.Size = UDim2.new(0, 260, 0, 110)
		box.Position = UDim2.new(0.5, -130, 0.5, -55)
		box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		box.BorderSizePixel = 0
		box.ZIndex = 501
		box.Parent = overlay

		local msg = Instance.new("TextLabel")
		msg.Size = UDim2.new(1, -20, 0, 50)
		msg.Position = UDim2.new(0, 10, 0, 10)
		msg.BackgroundTransparency = 1
		msg.Text = message
		msg.TextColor3 = Color3.fromRGB(0, 0, 0)
		msg.TextWrapped = true
		msg.Font = Enum.Font.Gotham
		msg.TextSize = 12
		msg.ZIndex = 502
		msg.Parent = box

		local accept = Instance.new("TextButton")
		accept.Size = UDim2.new(0, 90, 0, 26)
		accept.Position = UDim2.new(0.5, -100, 1, -36)
		accept.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		accept.Text = tr("Accept")
		accept.TextColor3 = Color3.fromRGB(255, 255, 255)
		accept.Font = Enum.Font.GothamBold
		accept.TextSize = 12
		accept.BorderSizePixel = 0
		accept.ZIndex = 502
		accept.Parent = box

		local cancel = Instance.new("TextButton")
		cancel.Size = UDim2.new(0, 90, 0, 26)
		cancel.Position = UDim2.new(0.5, 10, 1, -36)
		cancel.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		cancel.Text = tr("Cancel")
		cancel.TextColor3 = Color3.fromRGB(0, 0, 0)
		cancel.Font = Enum.Font.GothamBold
		cancel.TextSize = 12
		cancel.BorderSizePixel = 0
		cancel.ZIndex = 502
		cancel.Parent = box

		accept.MouseButton1Click:Connect(function()
			overlay:Destroy()
			if onAccept then onAccept() end
		end)
		cancel.MouseButton1Click:Connect(function()
			overlay:Destroy()
		end)
	end

	local function showNamePrompt(parent, onSave)
		local overlay = Instance.new("Frame")
		overlay.Size = UDim2.new(1, 0, 1, 0)
		overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		overlay.BackgroundTransparency = 0.45
		overlay.BorderSizePixel = 0
		overlay.ZIndex = 500
		overlay.Parent = parent

		local box = Instance.new("Frame")
		box.Size = UDim2.new(0, 260, 0, 120)
		box.Position = UDim2.new(0.5, -130, 0.5, -60)
		box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		box.BorderSizePixel = 0
		box.ZIndex = 501
		box.Parent = overlay

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -20, 0, 24)
		title.Position = UDim2.new(0, 10, 0, 8)
		title.BackgroundTransparency = 1
		title.Text = tr("Configuration name:")
		title.TextColor3 = Color3.fromRGB(0, 0, 0)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 12
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ZIndex = 502
		title.Parent = box

		local nameBox = Instance.new("TextBox")
		nameBox.Size = UDim2.new(1, -20, 0, 28)
		nameBox.Position = UDim2.new(0, 10, 0, 36)
		nameBox.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
		nameBox.Text = ""
		nameBox.PlaceholderText = "my_config"
		nameBox.TextColor3 = Color3.fromRGB(0, 0, 0)
		nameBox.Font = Enum.Font.Gotham
		nameBox.TextSize = 12
		nameBox.ClearTextOnFocus = false
		nameBox.BorderSizePixel = 0
		nameBox.ZIndex = 502
		nameBox.Parent = box

		local accept = Instance.new("TextButton")
		accept.Size = UDim2.new(0, 90, 0, 26)
		accept.Position = UDim2.new(0.5, -100, 1, -36)
		accept.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		accept.Text = tr("Accept")
		accept.TextColor3 = Color3.fromRGB(255, 255, 255)
		accept.Font = Enum.Font.GothamBold
		accept.TextSize = 12
		accept.BorderSizePixel = 0
		accept.ZIndex = 502
		accept.Parent = box

		local cancel = Instance.new("TextButton")
		cancel.Size = UDim2.new(0, 90, 0, 26)
		cancel.Position = UDim2.new(0.5, 10, 1, -36)
		cancel.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		cancel.Text = tr("Cancel")
		cancel.TextColor3 = Color3.fromRGB(0, 0, 0)
		cancel.Font = Enum.Font.GothamBold
		cancel.TextSize = 12
		cancel.BorderSizePixel = 0
		cancel.ZIndex = 502
		cancel.Parent = box

		accept.MouseButton1Click:Connect(function()
			local name = nameBox.Text
			name = string.gsub(name, "^%s+", "")
			name = string.gsub(name, "%s+$", "")
			name = string.gsub(name, "[^%w%-%_]", "_")
			if name == "" then return end
			if not string.find(string.lower(name), ".config", 1, true) then
				name = name .. ".config"
			end
			overlay:Destroy()
			if onSave then onSave(name) end
		end)
		cancel.MouseButton1Click:Connect(function()
			overlay:Destroy()
		end)
	end

	local function openFileManager()
		if fmFrame and fmFrame.Parent then
			fmFrame.Visible = true
			return
		end

		-- Parent = ScreenGui para que pueda salir del menu principal sin cortarse
		fmFrame = Instance.new("Frame")
		fmFrame.Name = "FileManagerPanel"
		fmFrame.Size = UDim2.new(0, 280, 0, 180)
		fmFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
		fmFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		fmFrame.BorderSizePixel = 0
		fmFrame.ZIndex = 100
		fmFrame.Active = true
		fmFrame.Parent = ScreenGui

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(180, 180, 180)
		stroke.Thickness = 1
		stroke.Parent = fmFrame

		local header = Instance.new("Frame")
		header.Size = UDim2.new(1, 0, 0, 28)
		header.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
		header.BorderSizePixel = 0
		header.ZIndex = 101
		header.Active = true
		header.Parent = fmFrame

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -36, 1, 0)
		title.Position = UDim2.new(0, 10, 0, 0)
		title.BackgroundTransparency = 1
		title.Text = tr("File Manager")
		title.TextColor3 = Color3.fromRGB(20, 20, 20)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 12
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ZIndex = 102
		title.Parent = header

		local closeBtn = Instance.new("TextButton")
		closeBtn.Size = UDim2.new(0, 24, 0, 24)
		closeBtn.Position = UDim2.new(1, -28, 0.5, -12)
		closeBtn.BackgroundTransparency = 1
		closeBtn.Text = "x"
		closeBtn.TextColor3 = Color3.fromRGB(80, 80, 80)
		closeBtn.Font = Enum.Font.GothamBold
		closeBtn.TextSize = 16
		closeBtn.ZIndex = 103
		closeBtn.Parent = header
		closeBtn.MouseButton1Click:Connect(function()
			fmFrame.Visible = false
		end)

		local dragging = false
		local dragStart = nil
		local startPos = nil
		header.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = fmFrame.Position
			end
		end)
		header.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				fmFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)

		-- lista simple de archivos (solo nombres, sin iconos)
		local listFrame = Instance.new("ScrollingFrame")
		listFrame.Size = UDim2.new(1, -16, 1, -70)
		listFrame.Position = UDim2.new(0, 8, 0, 32)
		listFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		listFrame.BorderSizePixel = 1
		listFrame.BorderColor3 = Color3.fromRGB(200, 200, 200)
		listFrame.ScrollBarThickness = 6
		listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		listFrame.ZIndex = 102
		listFrame.Parent = fmFrame
		local listLayout = Instance.new("UIListLayout")
		listLayout.Padding = UDim.new(0, 0)
		listLayout.Parent = listFrame

		local selectedName = nil

		local function refreshList()
			for _, ch in ipairs(listFrame:GetChildren()) do
				if ch:IsA("TextButton") then ch:Destroy() end
			end
			selectedName = nil
			_G.SupremacyConfigs = _G.SupremacyConfigs or {}
			local names = {}
			pcall(function()
				if makefolder then
					if not isfolder("SupremacyHub") then makefolder("SupremacyHub") end
					if not isfolder("SupremacyHub/configs") then makefolder("SupremacyHub/configs") end
				end
				if listfiles then
					for _, full in ipairs(listfiles("SupremacyHub/configs") or {}) do
						local fname = string.gsub(tostring(full), ".*[\\/]", "")
						if fname ~= "" then
							table.insert(names, fname)
							-- cargar contenido a memoria si no esta
							if not _G.SupremacyConfigs[fname] and readfile then
								local ok2, content = pcall(readfile, "SupremacyHub/configs/" .. fname)
								if ok2 and content then _G.SupremacyConfigs[fname] = content end
							end
						end
					end
				end
			end)
			for n, _ in pairs(_G.SupremacyConfigs) do
				local already = false
				for _, existing in ipairs(names) do
					if existing == n then already = true break end
				end
				if not already then table.insert(names, n) end
			end
			table.sort(names)
			for _, fname in ipairs(names) do
				local row = Instance.new("TextButton")
				row.Size = UDim2.new(1, 0, 0, 22)
				row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				row.Text = fname
				row.TextColor3 = Color3.fromRGB(0, 0, 0)
				row.Font = Enum.Font.Gotham
				row.TextSize = 12
				row.TextXAlignment = Enum.TextXAlignment.Left
				row.BorderSizePixel = 0
				row.AutoButtonColor = false
				row.ZIndex = 103
				row.Parent = listFrame
				local pad = Instance.new("UIPadding")
				pad.PaddingLeft = UDim.new(0, 8)
				pad.Parent = row
				row.MouseButton1Click:Connect(function()
					if selectedName == fname then
						-- quitar seleccion
						row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						row.TextColor3 = Color3.fromRGB(0, 0, 0)
						selectedName = nil
						return
					end
					for _, c in ipairs(listFrame:GetChildren()) do
						if c:IsA("TextButton") then
							c.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							c.TextColor3 = Color3.fromRGB(0, 0, 0)
						end
					end
					row.BackgroundColor3 = Color3.fromRGB(51, 153, 255)
					row.TextColor3 = Color3.fromRGB(255, 255, 255)
					selectedName = fname
				end)
			end
		end

		local saveBtn = Instance.new("TextButton")
		saveBtn.Size = UDim2.new(0, 60, 0, 24)
		saveBtn.Position = UDim2.new(0, 8, 1, -32)
		saveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		saveBtn.Text = tr("Save")
		saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		saveBtn.Font = Enum.Font.GothamBold
		saveBtn.TextSize = 11
		saveBtn.BorderSizePixel = 0
		saveBtn.ZIndex = 102
		saveBtn.Parent = fmFrame

		local deleteBtn = Instance.new("TextButton")
		deleteBtn.Size = UDim2.new(0, 60, 0, 24)
		deleteBtn.Position = UDim2.new(0.5, -30, 1, -32)
		deleteBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		deleteBtn.Text = tr("Delete")
		deleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		deleteBtn.Font = Enum.Font.GothamBold
		deleteBtn.TextSize = 11
		deleteBtn.BorderSizePixel = 0
		deleteBtn.ZIndex = 102
		deleteBtn.Parent = fmFrame

		local exportBtn = Instance.new("TextButton")
		exportBtn.Size = UDim2.new(0, 60, 0, 24)
		exportBtn.Position = UDim2.new(1, -68, 1, -32)
		exportBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		exportBtn.Text = tr("Export")
		exportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		exportBtn.Font = Enum.Font.GothamBold
		exportBtn.TextSize = 11
		exportBtn.BorderSizePixel = 0
		exportBtn.ZIndex = 102
		exportBtn.Parent = fmFrame

		saveBtn.MouseButton1Click:Connect(function()
			showNamePrompt(ScreenGui, function(name)
				if not name or name == "" then
					name = "config.config"
				end
				local encoded = encodeConfig(collectConfig())
				_G.SupremacyConfigs = _G.SupremacyConfigs or {}
				_G.SupremacyConfigs[name] = encoded
				_G.SupremacyLastConfig = name
				pcall(function()
					if makefolder then
						if not isfolder("SupremacyHub") then makefolder("SupremacyHub") end
						if not isfolder("SupremacyHub/configs") then makefolder("SupremacyHub/configs") end
					end
					if writefile then
						writefile("SupremacyHub/configs/" .. name, encoded)
					end
				end)
				print("[Supremacy] SAVED -> " .. tostring(name))
				refreshList()
			end)
		end)

		deleteBtn.MouseButton1Click:Connect(function()
			if not selectedName then
				showAlert(ScreenGui, "Select a file first.", function() end)
				return
			end
			local toDelete = selectedName
			showAlert(ScreenGui, "Delete " .. tostring(toDelete) .. "?", function()
				_G.SupremacyConfigs = _G.SupremacyConfigs or {}
				_G.SupremacyConfigs[toDelete] = nil
				if _G.SupremacyLastConfig == toDelete then
					_G.SupremacyLastConfig = nil
				end
				pcall(function()
					if delfile then
						delfile("SupremacyHub/configs/" .. toDelete)
					end
				end)
				selectedName = nil
				refreshList()
			end)
		end)

		exportBtn.MouseButton1Click:Connect(function()
			_G.SupremacyConfigs = _G.SupremacyConfigs or {}
			local chosen = selectedName
			local data = nil
			if chosen then
				pcall(function()
					if readfile then
						data = readfile("SupremacyHub/configs/" .. chosen)
					end
				end)
				if not data or data == "" then
					data = _G.SupremacyConfigs[chosen]
				end
			end
			if not chosen or not data then
				showAlert(ScreenGui, "Select a file first.", function() end)
				return
			end

			-- alerta de carga con barra azul
			local overlay = Instance.new("Frame")
			overlay.Size = UDim2.new(1, 0, 1, 0)
			overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			overlay.BackgroundTransparency = 0.45
			overlay.BorderSizePixel = 0
			overlay.ZIndex = 500
			overlay.Parent = ScreenGui

			local box = Instance.new("Frame")
			box.Size = UDim2.new(0, 220, 0, 70)
			box.Position = UDim2.new(0.5, -110, 0.5, -35)
			box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			box.BorderSizePixel = 0
			box.ZIndex = 501
			box.Parent = overlay

			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, -16, 0, 24)
			lbl.Position = UDim2.new(0, 8, 0, 8)
			lbl.BackgroundTransparency = 1
			lbl.Text = "Loading " .. tostring(chosen) .. "..."
			lbl.TextColor3 = Color3.fromRGB(0, 0, 0)
			lbl.Font = Enum.Font.Gotham
			lbl.TextSize = 12
			lbl.ZIndex = 502
			lbl.Parent = box

			local barBg = Instance.new("Frame")
			barBg.Size = UDim2.new(1, -16, 0, 12)
			barBg.Position = UDim2.new(0, 8, 1, -24)
			barBg.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
			barBg.BorderSizePixel = 0
			barBg.ZIndex = 502
			barBg.Parent = box

			local bar = Instance.new("Frame")
			bar.Size = UDim2.new(0, 0, 1, 0)
			bar.BackgroundColor3 = Color3.fromRGB(51, 153, 255)
			bar.BorderSizePixel = 0
			bar.ZIndex = 503
			bar.Parent = barBg

			task.spawn(function()
				local totalTime = math.random(1, 4) -- 1 a 4 segundos (entero aleatorio)
				local steps = 40
				local stepWait = totalTime / steps
				for i = 1, steps do
					bar.Size = UDim2.new(i / steps, 0, 1, 0)
					task.wait(stepWait)
				end
				-- aplicar config
				for line in string.gmatch(data, "[^\r\n]+") do
					local k, v = string.match(line, "^([^=]+)=(.*)$")
					if k and v then
						k = string.gsub(k, "^%s+", "")
						k = string.gsub(k, "%s+$", "")
						v = string.gsub(v, "^%s+", "")
						v = string.gsub(v, "%s+$", "")
						local val = v
						if v == "true" then val = true
						elseif v == "false" then val = false
						elseif tonumber(v) then val = tonumber(v)
						elseif string.find(v, ",", 1, true) then
							local parts = {}
							for p in string.gmatch(v, "[^,]+") do
								table.insert(parts, tonumber(p) or 0)
							end
							if #parts == 4 then val = parts end
						end
						if k == "AimbotEnabled" then
							AimbotEnabled = val
						elseif k == "AimbotButtonEnabled" then
							AimbotButtonEnabled = val
							if AimbotBtn then
								AimbotBtn.Visible = val
								if not val then
									AimbotEnabled = false
									AimbotBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
								end
							end
						elseif k == "AimbotSmooth" then AimbotSmooth = val
						elseif k == "SmoothingEnabled" then SmoothingEnabled = val
						elseif k == "AimPart" then AimPart = val
						elseif k == "FOVCircleEnabled" then FOVCircleEnabled = val
						elseif k == "FOVHideEnabled" then FOVHideEnabled = val
						elseif k == "FOVSizeEnabled" then FOVSizeEnabled = val
						elseif k == "FOVSize" then FOVSize = val
						elseif k == "AimDistanceEnabled" then AimDistanceEnabled = val
						elseif k == "AimDistanceValue" then AimDistanceValue = val
						elseif k == "SilentAimEnabled" then SilentAimEnabled = val
						elseif k == "SoruAimbotEnabled" then SoruAimbotEnabled = val
						elseif k == "PredictEnabled" then
							Predict.on = val and true or false
							if Predict.btn then
								if Predict.on then
									Predict.btn.BackgroundColor3 = Color3.fromRGB(90, 90, 105)
									Predict.btn.TextColor3 = Color3.fromRGB(255, 255, 255)
								else
									Predict.btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
									Predict.btn.TextColor3 = Color3.fromRGB(220, 220, 230)
								end
							end
						elseif k == "PredictButtonEnabled" then
							Predict.keyOn = val and true or false
							if Predict.container then
								if not Predict.container.Parent and _G.SupremacyScreenGui then
									Predict.container.Parent = _G.SupremacyScreenGui
								end
								Predict.container.Visible = Predict.keyOn
							end
						elseif k == "PredictYEnabled" then Predict.yOn = val and true or false
						elseif k == "PredictYValue" then Predict.y = tonumber(val) or 0
						elseif k == "PredictXEnabled" then Predict.xOn = val and true or false
						elseif k == "PredictXValue" then Predict.x = tonumber(val) or 0
						elseif k == "PredictPos" and type(val) == "table" then
							pcall(function()
								local u = UDim2.new(val[1] or 0, val[2] or 0, val[3] or 0, val[4] or 0)
								Predict.pos = u
								if Predict.container then Predict.container.Position = u end
							end)
						elseif k == "KeyPredict" then
							_G.SupremacyKeys = _G.SupremacyKeys or {}
							_G.SupremacyKeys["Predict"] = tostring(val or "P")
							if Predict.btn then Predict.btn.Text = tostring(val or "P") end
						elseif k == "AimPositionYEnabled" then Predict.yOn = val and true or false
						elseif k == "AimPositionYValue" then Predict.y = math.clamp(math.abs(tonumber(val) or 0), 0, 300)
						elseif k == "ESPBoxEnabled" then ESPBoxEnabled = val
						elseif k == "ESPType" then
							ESPType = val
							if _G.SupremacyESPTypeBtn then
								_G.SupremacyESPTypeBtn.Text = tostring(val)
							end
						elseif k == "ESPFilled" then ESPFilled = val
						elseif k == "ESPNameEnabled" then ESPNameEnabled = val
						elseif k == "ESPDistanceEnabled" then ESPDistanceEnabled = val
						elseif k == "ESPHealthEnabled" then ESPHealthEnabled = val
						elseif k == "ESPSnapLineEnabled" then ESPSnapLineEnabled = val
						elseif k == "ESPAntennaEnabled" then ESPAntennaEnabled = val
						elseif k == "LimitDistanceEnabled" then LimitDistanceEnabled = val
						elseif k == "LimitDistanceValue" then LimitDistanceValue = val
						elseif k == "TeamCheckEnabled" then TeamCheckEnabled = val and true or false
						elseif k == "NPCCheckEnabled" then NPCCheckEnabled = val and true or false
							_G.SupremacyNPCCheck = NPCCheckEnabled
						elseif k == "HealthCheckEnabled" then
							HealthCheckEnabled = val and true or false
							_G.SupremacyHealthCheck = HealthCheckEnabled
						elseif k == "WhitelistedIds" and type(val) == "string" then
							table.clear(WhitelistedPlayers)
							for id in string.gmatch(val, "[^,]+") do
								local n = tonumber(id)
								if n then WhitelistedPlayers[n] = true end
							end
						elseif k == "FreezeEnabled" then
							FreezeEnabled = val
							if FreezeContainer then FreezeContainer.Visible = val end
						elseif k == "NoclipEnabled" then handleNoclip(val)
						elseif k == "AntiLavaEnabled" then handleAntiLava(val)
						elseif k == "InfiniteJumpEnabled" then InfiniteJumpEnabled = val
						elseif k == "SuperJumpEnabled" then
							SuperJumpEnabled = val
							if SuperJumpContainer then
								SuperJumpContainer.Visible = val and true or false
								if val and savedSuperJumpPos then
									SuperJumpContainer.Position = savedSuperJumpPos
								elseif val then
									SuperJumpContainer.Position = UDim2.new(1, -110, 1, -210)
								end
							end
						elseif k == "FPSBoost" or k == "FPSBoost2" or k == "FPSStructTex"
							or k == "FPSNoShadows" or k == "FPSNoParticles" or k == "FPSNoLights"
							or k == "FPSGraySky" or k == "FPSNoFog" then
							_G.SupremacyPendingFPS = _G.SupremacyPendingFPS or {}
							_G.SupremacyPendingFPS[k] = val and true or false
						elseif k == "FPSMode" then
							-- compat
							local m = tonumber(val) or 0
							pcall(function() if _G.SupremacySetFPSMode then _G.SupremacySetFPSMode(m) end end)
						elseif k == "FPSBoostEnabled" then
							if val then
								_G.SupremacyPendingFPS = _G.SupremacyPendingFPS or {}
								_G.SupremacyPendingFPS.FPSBoost2 = true
							end
						elseif k == "SafeZoneEnabled" then SafeZoneEnabled = val
						elseif k == "SafeZoneHealth" then SafeZoneHealth = val
						elseif k == "FOVCircleColor" and type(val) == "string" then
							pcall(function() FOVCircleColor = Color3.fromHex(val) end)
						elseif k == "ESPBoxColor" and type(val) == "string" then
							pcall(function() ESPBoxColor = Color3.fromHex(val) end)
						elseif k == "ESPNameColor" and type(val) == "string" then
							pcall(function() ESPNameColor = Color3.fromHex(val) end)
						elseif k == "ESPDistanceColor" and type(val) == "string" then
							pcall(function() ESPDistanceColor = Color3.fromHex(val) end)
						elseif k == "ESPSnapLineColor" and type(val) == "string" then
							pcall(function() ESPSnapLineColor = Color3.fromHex(val) end)
						elseif k == "ESPAntennaColor" and type(val) == "string" then
							pcall(function() ESPAntennaColor = Color3.fromHex(val) end)
						elseif k == "SuperDashSpeed" then SuperDashSpeed = val
						elseif k == "SuperDashEnabled" then
							if val then startSuperDash() else stopSuperDash() end
						elseif k == "ZSanguineBoostEnabled" then
							ZSanguineBoostEnabled = val
							if val then
								createLagGui()
							elseif lagGui then
								lagGui:Destroy()
								lagGui = nil
							end
						elseif k == "ButtonOpacityEnabled" then ButtonOpacityEnabled = val
						elseif k == "ButtonOpacity" then ButtonOpacity = val
						elseif k == "MenuButtonOpacityEnabled" then MenuButtonOpacityEnabled = val
						elseif k == "FreezePos" then
							local u = tableToUDim2(val)
							if u then
								savedFreezePos = u
								if FreezeContainer then FreezeContainer.Position = u end
							end
						elseif k == "AimbotBtnPos" then
							local u = tableToUDim2(val)
							if u then
								savedAimbotPos = u
								if AimbotBtn then AimbotBtn.Position = u end
							end
						elseif k == "LagPos" then
							local u = tableToUDim2(val)
							if u then
								savedLagPos = u
								if lagGui then
									local f = lagGui:FindFirstChildOfClass("Frame")
									if f then f.Position = u end
								end
							end
						elseif k == "SuperJumpPos" then
							local u = tableToUDim2(val)
							if u then
								savedSuperJumpPos = u
								if SuperJumpContainer then SuperJumpContainer.Position = u end
							end
						elseif k == "OpenBtnPos" then
							local u = tableToUDim2(val)
							if u and OpenBtn then OpenBtn.Position = u end
						elseif k == "ClickSoundName" then
							ClickSoundName = tostring(val or "None")
							for _, info in ipairs(CLICK_SOUNDS) do
								if info.name == ClickSoundName then
									ClickSoundId = info.id
									ClickSoundSpeed = info.speed or 1
									ClickSoundVol = info.vol or 3.5
									break
								end
							end
						elseif k == "ClickSoundId" then
							if val and tostring(val) ~= "" then ClickSoundId = tostring(val) end
						elseif k == "ClickSoundSpeed" then
							ClickSoundSpeed = tonumber(val) or 1
						elseif k == "ClickSoundVol" then
							ClickSoundVol = tonumber(val) or 3.5
						elseif k == "CrosshairMode" then
							pcall(function()
								if _G.SupremacySetCrosshairMode then
									_G.SupremacySetCrosshairMode(tostring(val))
								end
							end)
						elseif k == "KeySanguine" or k == "KeyFreeze" or k == "KeySuperJump" or k == "KeyAimbot" then
							_G.SupremacyKeys = _G.SupremacyKeys or {}
							local letter = string.upper(string.sub(tostring(val or "A"), 1, 1))
							if k == "KeySanguine" then
								_G.SupremacyKeys["Sanguine Z Boost"] = letter
							elseif k == "KeyFreeze" then
								_G.SupremacyKeys["Tab (Freeze)"] = letter
							elseif k == "KeySuperJump" then
								_G.SupremacyKeys["Super Jump"] = letter
							elseif k == "KeyAimbot" then
								_G.SupremacyKeys["Aimbot Key"] = letter
								_G.SupremacyKeys["Aimbot Button"] = letter
							end
							pcall(function()
								if _G.SupremacyApplyKeys then _G.SupremacyApplyKeys() end
							end)
						-- Assist* / VoiceAssist: IGNORADOS a proposito (no guardar/cargar lo de dentro del Assistant)
						elseif k == "PcFormat" then
							_G.SupremacyPcFormatOn = val and true or false
						elseif k == "SlotsMiniOn" then
							_G.SupremacySlotsMiniOn = val and true or false
						elseif k == "SlotsMiniScale" then
							_G.SupremacySlotsMiniScale = tonumber(val) or 0
						elseif k == "CameraZoomOn" then
							_G.SupremacyCameraZoomOn = val and true or false
						elseif k == "CameraZoomValue" then
							_G.SupremacyCameraZoomVal = tonumber(val) or 0
						elseif k == "HideSkills" then
							_G.SupremacyHideSkillsOn = val and true or false
						elseif k == "HideUse" then
							_G.SupremacyHideUseOn = val and true or false
						elseif k == "HideGunCursor" then
							_G.SupremacyHideGunCursorOn = val and true or false
						elseif k == "PredictYEnabled" then
							Predict.yOn = val and true or false
						elseif k == "PredictXEnabled" then
							Predict.xOn = val and true or false
						end
					end
				end
				-- aplicar opciones Config del menu principal
				pcall(function()
					if _G.SupremacyGuiMiniApply then _G.SupremacyGuiMiniApply(_G.SupremacyPcFormatOn == true) end
					if _G.SupremacySlotsMiniSetScale then _G.SupremacySlotsMiniSetScale(tonumber(_G.SupremacySlotsMiniScale) or 0) end
					if _G.SupremacySlotsMiniApply then _G.SupremacySlotsMiniApply(_G.SupremacySlotsMiniOn == true) end
					if _G.SupremacyCameraZoomValue then _G.SupremacyCameraZoomValue(tonumber(_G.SupremacyCameraZoomVal) or 0) end
					if _G.SupremacyCameraZoomApply then _G.SupremacyCameraZoomApply(_G.SupremacyCameraZoomOn == true) end
					if _G.SupremacyApplyHideSkills then _G.SupremacyApplyHideSkills(_G.SupremacyHideSkillsOn == true) end
					if _G.SupremacyApplyHideUse then _G.SupremacyApplyHideUse(_G.SupremacyHideUseOn == true) end
					if _G.SupremacyApplyHideGunCursor then _G.SupremacyApplyHideGunCursor(_G.SupremacyHideGunCursorOn == true) end
				end)
				pcall(updateFOVCircle)
				pcall(applyAllButtonOpacity)
				pcall(ClearESPBoxes)
				-- Actualizar visual de los triggers según la config cargada
				pcall(function()
					local tu = _G.SupremacyToggleUpdates
					if tu then
						if tu["Aimbot"] then tu["Aimbot"](AimbotEnabled) end
						if tu["Aimbot Key"] then tu["Aimbot Key"](AimbotButtonEnabled) elseif tu["Aimbot Button"] then tu["Aimbot Button"](AimbotButtonEnabled) end
						if tu["Smoothing"] then tu["Smoothing"](SmoothingEnabled) end
						if tu["FOV Circle"] then tu["FOV Circle"](FOVCircleEnabled) end
						if tu["FOV Hide"] then tu["FOV Hide"](FOVHideEnabled) end
						if tu["FOV Size"] then tu["FOV Size"](FOVSizeEnabled) end
						if tu["Silent Aim"] then tu["Silent Aim"](SilentAimEnabled) end
						if tu["Soru Aim"] then tu["Soru Aim"](SoruAimbotEnabled) end
						if tu["Predict"] then tu["Predict"](Predict.keyOn) end
						if tu["Aim Distance"] then tu["Aim Distance"](AimDistanceEnabled) end
						if tu["ESP Box"] then tu["ESP Box"](ESPBoxEnabled) end
						if tu["ESP Filled"] then tu["ESP Filled"](ESPFilled) end
						if tu["ESP Name"] then tu["ESP Name"](ESPNameEnabled) end
						if tu["ESP Distance"] then tu["ESP Distance"](ESPDistanceEnabled) end
						if tu["ESP Health"] then tu["ESP Health"](ESPHealthEnabled) end
						if tu["ESP SnapLine"] then tu["ESP SnapLine"](ESPSnapLineEnabled) end
						if tu["ESP Antenna"] then tu["ESP Antenna"](ESPAntennaEnabled) end
						if tu["Limit Distance"] then tu["Limit Distance"](LimitDistanceEnabled) end
						if tu["Team Check"] then tu["Team Check"](TeamCheckEnabled) end
						if tu["NPC Check"] then tu["NPC Check"](NPCCheckEnabled) end
						if tu["Health Check"] then tu["Health Check"](HealthCheckEnabled) end
						-- Visual colors + type (file manager)
						if _G.SupremacyESPTypeBtn then
							_G.SupremacyESPTypeBtn.Text = tostring(ESPType)
						end
						local cu = _G.SupremacyColorUpdates
						if cu then
							if cu["ESP Box"] then pcall(cu["ESP Box"], ESPBoxColor) end
							if cu["ESP Name"] then pcall(cu["ESP Name"], ESPNameColor) end
							if cu["ESP Distance"] then pcall(cu["ESP Distance"], ESPDistanceColor) end
							if cu["ESP SnapLine"] then pcall(cu["ESP SnapLine"], ESPSnapLineColor) end
							if cu["ESP Antenna"] then pcall(cu["ESP Antenna"], ESPAntennaColor) end
						end
						local su = _G.SupremacySliderUpdates
						if su and su["Limit Distance"] then
							pcall(su["Limit Distance"], LimitDistanceValue)
						end
						if tu["Sanguine Z Boost"] then tu["Sanguine Z Boost"](ZSanguineBoostEnabled) end
						if tu["Tab (Freeze)"] then tu["Tab (Freeze)"](FreezeEnabled) end
						if tu["Super Dash"] then tu["Super Dash"](SuperDashEnabled) end
						if tu["Noclip"] then tu["Noclip"](NoclipEnabled) end
						if tu["Anti Lava"] then tu["Anti Lava"](AntiLavaEnabled) end
						if tu["Infinite Jump"] then tu["Infinite Jump"](InfiniteJumpEnabled) end
						if tu["Super Jump"] then tu["Super Jump"](SuperJumpEnabled) end
						if tu["Safe Zone"] then tu["Safe Zone"](SafeZoneEnabled) end
						pcall(function()
							local P = _G.SupremacyPendingFPS
							if P and _G.SupremacyApplyFPSState then
								_G.SupremacyApplyFPSState(P)
								_G.SupremacyPendingFPS = nil
							end
						end)
						if tu["Predict"] then tu["Predict"](Predict.keyOn) end
						if tu["Button Opacity"] then tu["Button Opacity"](ButtonOpacityEnabled) end
						if tu["Menu Button"] then tu["Menu Button"](MenuButtonOpacityEnabled) end
						if tu["Pc Format"] then tu["Pc Format"](_G.SupremacyPcFormatOn == true) end
						if tu["Slots Mini"] then tu["Slots Mini"](_G.SupremacySlotsMiniOn == true) end
						if tu["Camera Zoom"] then tu["Camera Zoom"](_G.SupremacyCameraZoomOn == true) end
						if tu["Hide Skills"] then tu["Hide Skills"](_G.SupremacyHideSkillsOn == true) end
						if tu["Hide Use"] then tu["Hide Use"](_G.SupremacyHideUseOn == true) end
						if tu["Hide Gun Cursor"] then tu["Hide Gun Cursor"](_G.SupremacyHideGunCursorOn == true) end
						if tu["Predict Y"] then tu["Predict Y"](Predict.yOn == true) end
						if tu["Predict X"] then tu["Predict X"](Predict.xOn == true) end
					end
					local su = _G.SupremacySliderUpdates
					if su then
						if su["Smoothing"] then su["Smoothing"](AimbotSmooth) end
						if su["FOV Size"] then su["FOV Size"](FOVSize) end
						if su["Predict Y"] then su["Predict Y"](Predict.y) end
						if su["Predict X"] then su["Predict X"](Predict.x) end
						if su["Aim Distance"] then su["Aim Distance"](AimDistanceValue) end
						if su["Limit Distance"] then su["Limit Distance"](LimitDistanceValue) end
						if su["Super Dash"] then su["Super Dash"](SuperDashSpeed) end
						if su["Safe Zone"] then su["Safe Zone"](SafeZoneHealth) end
						if su["Button Opacity"] then su["Button Opacity"](ButtonOpacity) end
						if su["Slots Mini"] then su["Slots Mini"](tonumber(_G.SupremacySlotsMiniScale) or 0) end
						if su["Camera Zoom"] then su["Camera Zoom"](tonumber(_G.SupremacyCameraZoomVal) or 0) end
					end
					-- actualizar label de part
					if partSelectLabel then partSelectLabel.Text = AimPart or "Head" end
					-- Team Check eliminado
					pcall(function() if _G.SupremacyRefreshWhiteList then _G.SupremacyRefreshWhiteList() end end)
					-- Click Sound: UI + datos resueltos
					pcall(function()
						for _, info in ipairs(CLICK_SOUNDS) do
							if info.name == ClickSoundName then
								ClickSoundId = info.id
								ClickSoundSpeed = info.speed or 1
								ClickSoundVol = info.vol or 3.5
								break
							end
						end
						if _G.SupremacyRefreshClickSound then
							_G.SupremacyRefreshClickSound()
						end
					end)
				end)
				print("[Supremacy] LOAD -> " .. tostring(chosen))
				overlay:Destroy()
			end)
		end)

		refreshList()
	end

	local fmRow = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		ZIndex = 200,
		Parent = ConfigPage
	})
	Create("TextLabel", {
		Size = UDim2.new(1, -62, 1, 0),
		BackgroundTransparency = 1,
		Text = "File Manager",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = TEXT_LABEL,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 201,
		Parent = fmRow
	})
	local openBtn = Create("TextButton", {
		Size = UDim2.new(0, 52, 0, 14),
		Position = UDim2.new(1, -58, 0.5, -7),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0,
		Text = "Open",
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		ZIndex = 202,
		Parent = fmRow
	})
	openBtn.MouseButton1Click:Connect(function()
		openFileManager()
	end)
	pcall(function()
		local lbl = fmRow:FindFirstChildWhichIsA("TextLabel")
		if lbl then registerLangLabel("File Manager", lbl) end
		registerLangLabel("Open", openBtn)
		openBtn.Text = tr("Open")
	end)
end)()

-- Language Menu
;(function()
	local langRow = Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 200,
		Parent = ConfigPage
	})
	local langTitle = Create("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		BackgroundTransparency = 1,
		Text = "Language Menu",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = TEXT_LABEL,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 201,
		Parent = langRow
	})
	registerLangLabel("Language Menu", langTitle)
	local langLabel = Create("TextButton", {
		Size = UDim2.new(0, 52, 0, 14),
		Position = UDim2.new(1, -58, 0.5, -7),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0,
		Text = "English",
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		ZIndex = 202,
		Parent = langRow
	})
	_G.SupremacyLangCurrentBtn = langLabel
	local langDrop = Create("ScrollingFrame", {
		Size = UDim2.new(0, 52, 0, 0),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BorderSizePixel = 0,
		Visible = false,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		ZIndex = 80,
		Parent = Main
	})
	Create("UIListLayout", { Padding = UDim.new(0, 2), Parent = langDrop })
	_G.SupremacyLangDropButtons = {}
	local open = false
	for _, name in ipairs({"English", "Spanish"}) do
		local b = Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundColor3 = (name == "English") and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(40, 40, 40),
			Text = tr(name),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 9,
			Font = Enum.Font.GothamBold,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			ZIndex = 81,
			Parent = langDrop
		})
		_G.SupremacyLangDropButtons[name] = b
		b.MouseButton1Click:Connect(function()
			open = false
			langDrop.Visible = false
			applyLanguage(name)
		end)
	end
	local function toggle()
		open = not open
		if open then
			local ap, asz, ma = langLabel.AbsolutePosition, langLabel.AbsoluteSize, Main.AbsolutePosition
			local h = 44
			local y = ap.Y - ma.Y + asz.Y + 2
			langDrop.Size = UDim2.new(0, math.max(math.floor(asz.X), 52), 0, h)
			langDrop.Position = UDim2.new(0, ap.X - ma.X, 0, y)
			langDrop.Visible = true
			_G.SupremacyDropIgnoreUntil = tick() + 0.25
		else
			langDrop.Visible = false
		end
	end
	langRow.MouseButton1Click:Connect(toggle)
	langLabel.MouseButton1Click:Connect(toggle)
end)()

-- Assistant (panel Open + Sense Prediction)
;(function()
	local DEF_COL = Color3.fromHex("#222222")
	-- limpiar panel viejo de ejecuciones anteriores (_G persiste en Delta)
	pcall(function()
		local old = _G.SupremacyAssistS
		if old then
			if old.frame then pcall(function() old.frame:Destroy() end) end
			if old.bubble then pcall(function() old.bubble:Destroy() end) end
		end
		local sg = _G.SupremacyScreenGui
		if sg then
			local af = sg:FindFirstChild("AssistantPanel")
			if af then af:Destroy() end
		end
		local pg = player:FindFirstChild("PlayerGui")
		if pg then
			local n = pg:FindFirstChild("SupremacyAssistNotify")
			-- no borrar notify
		end
	end)

	local S = {
		on = false,
		enemy = false,
		hp = false,
		sense = false,
		senseSound = "None",
		noDisappear = false,
		frame = nil,
		bubble = nil,
		enemyDist = 100,
		hpThresh = 500,
		senseDist = 100,
		enemyColor = DEF_COL,
		hpColor = DEF_COL,
		-- cooldown: solo reavisa al salir y volver a entrar
		enemyInside = false,
		hpInside = false,
		senseActive = false,
		senseShownAt = 0,
		pvpInd = false,
		pvpDist = 200,
		pvpLastTip = 0,
		pvpLastKey = "",
		_pvpPos = nil,
	}
	_G.SupremacyAssistS = S
	-- aplicar config pendiente (Files) si ya se cargo
	pcall(function()
		local P = _G.SupremacyPendingAssist
		if not P then return end
		if P.AssistSenseSound ~= nil then S.senseSound = tostring(P.AssistSenseSound) end
		if P.AssistPvpInd ~= nil then S.pvpInd = P.AssistPvpInd and true or false end
		if P.AssistPvpDist ~= nil then S.pvpDist = tonumber(P.AssistPvpDist) or S.pvpDist end
		if P.AssistOn ~= nil then S.on = P.AssistOn and true or false end
		if P.AssistSense ~= nil then S.sense = P.AssistSense and true or false end
		if P.AssistEnemy ~= nil then S.enemy = P.AssistEnemy and true or false end
		if P.AssistHp ~= nil then S.hp = P.AssistHp and true or false end
		if P.AssistNoDisappear ~= nil then S.noDisappear = P.AssistNoDisappear and true or false end
		if P.AssistEnemyDist ~= nil then S.enemyDist = tonumber(P.AssistEnemyDist) or S.enemyDist end
		if P.AssistHpThresh ~= nil then S.hpThresh = tonumber(P.AssistHpThresh) or S.hpThresh end
		if P.VoiceAssist ~= nil then _G.SupremacyVoiceAssist = tostring(P.VoiceAssist) end
	end)
	local activeSlider = nil
	local senseOn = false

	local function notify(msg)
		pcall(function()
			-- pantalla solo si Enable Assistant o Voice activo
			local voiceOn = false
			pcall(function()
				local v = tostring(_G.SupremacyVoiceAssist or "None")
				voiceOn = (v ~= "None" and v ~= "")
			end)
			local showScreen = (S.on == true) or voiceOn
			if not showScreen then
				-- solo voz si Voice activo (sin cartel)
				if voiceOn then
					pcall(function()
						if _G.SupremacySpeakAssist then _G.SupremacySpeakAssist(msg) end
					end)
				end
				return
			end
			local pg = player:FindFirstChild("PlayerGui")
			if not pg then return end
			local g = pg:FindFirstChild("SupremacyAssistNotify")
			if not g then
				g = Instance.new("ScreenGui")
				g.Name = "SupremacyAssistNotify"
				g.ResetOnSpawn = false
				g.IgnoreGuiInset = true
				g.DisplayOrder = 80
				g.Parent = pg
			end
			local old = g:FindFirstChild("Msg")
			if old then old:Destroy() end
			local l = Instance.new("TextLabel")
			l.Name = "Msg"
			l.Size = UDim2.new(0, 280, 0, 32)
			l.Position = UDim2.new(0.5, -140, 0.02, 0)
			l.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
			l.BackgroundTransparency = 0.15
			l.BorderSizePixel = 0
			l.Text = msg
			l.TextColor3 = Color3.fromRGB(255, 255, 255)
			l.Font = Enum.Font.GothamBold
			l.TextSize = 13
			l.Parent = g
			Instance.new("UICorner", l).CornerRadius = UDim.new(0, 8)
			-- mostrar texto YA; no quitar hasta que termine la voz (o timeout)
			local token = tostring(tick())
			l:SetAttribute("Token", token)
			local hold = 4
			pcall(function()
				if _G.SupremacySpeakAssist then
					_G.SupremacySpeakAssist(msg, function(dur)
						if type(dur) == "number" and dur > hold then
							hold = dur
						end
					end)
				end
			end)
			-- estimar por largo del texto (por si no hay TTS)
			local est = math.clamp(#tostring(msg) * 0.075, 2.8, 12)
			if est > hold then hold = est end
			task.delay(hold + 0.35, function()
				pcall(function()
					if S.noDisappear then return end
					if l and l.Parent and l:GetAttribute("Token") == token then
						l:Destroy()
					end
				end)
			end)
		end)
	end

	_G.SupremacyNotifyGreet = function(greet)
		-- muestra el saludo en pantalla y lo habla; no se quita hasta terminar
		notify(tostring(greet or ((_G.SupremacyLang == "Spanish") and "Hola" or "Hello")))
	end

	local function ensureSenseBorder()
		if S._senseEdges and S._senseEdges[1] and S._senseEdges[1].Parent then return end
		local pg = player:FindFirstChild("PlayerGui")
		if not pg then return end
		local old = pg:FindFirstChild("SupremacySenseBorder")
		if old then old:Destroy() end
		local senseGui = Instance.new("ScreenGui")
		senseGui.Name = "SupremacySenseBorder"
		senseGui.ResetOnSpawn = false
		senseGui.IgnoreGuiInset = true
		senseGui.DisplayOrder = 70
		senseGui.Parent = pg
		local function edge(name, size, pos, rot)
			local f = Instance.new("Frame")
			f.Name = name
			f.Size = size
			f.Position = pos
			f.BackgroundColor3 = DEF_COL
			f.BackgroundTransparency = 1
			f.BorderSizePixel = 0
			f.Parent = senseGui
			local g = Instance.new("UIGradient")
			g.Rotation = rot
			g.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.1),
				NumberSequenceKeypoint.new(0.45, 0.55),
				NumberSequenceKeypoint.new(1, 1),
			})
			g.Parent = f
			return f
		end
		S._senseEdges = {
			edge("Top", UDim2.new(1, 0, 0, 36), UDim2.new(0, 0, 0, 0), 90),
			edge("Bottom", UDim2.new(1, 0, 0, 36), UDim2.new(0, 0, 1, -36), 270),
			edge("Left", UDim2.new(0, 36, 1, 0), UDim2.new(0, 0, 0, 0), 0),
			edge("Right", UDim2.new(0, 36, 1, 0), UDim2.new(1, -36, 0, 0), 180),
		}
	end

	local function setSenseVisible(on, col)
		pcall(function()
			ensureSenseBorder()
			if not S._senseEdges then return end
			local c3 = col or DEF_COL
			for _, f in pairs(S._senseEdges) do
				f.BackgroundColor3 = c3
				TweenService:Create(f, TweenInfo.new(on and 0.18 or 0.3), {
					BackgroundTransparency = on and 0.2 or 1,
				}):Play()
			end
		end)
	end

	task.spawn(function()
		while true do
			task.wait(0.15)
			pcall(function()
				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local nearEnemy = false
				local lowHp = false
				if root then
					for _, plr in pairs(Players:GetPlayers()) do
						if plr ~= player and plr.Character then
							local r = plr.Character:FindFirstChild("HumanoidRootPart")
							local h = plr.Character:FindFirstChildOfClass("Humanoid")
							if r and h and h.Health > 0 then
								local d = (r.Position - root.Position).Magnitude
								if d <= (S.enemyDist or 100) then
									nearEnemy = true
								end
							end
						end
					end
				end
				if hum and hum.Health > 0 and hum.Health <= (S.hpThresh or 500) then
					lowHp = true
				end

				-- Sense: aparece al entrar; a los 4s se oculta (salvo No disappearance);
				-- al salir del area siempre se oculta
				if S.sense then
					local want = false
					local col = DEF_COL
					if nearEnemy and S.enemy then
						want = true
						col = S.enemyColor or DEF_COL
					elseif lowHp and S.hp then
						want = true
						col = S.hpColor or DEF_COL
					end
					if want then
						if not S.senseActive then
							S.senseActive = true
							S.senseShownAt = tick()
							senseOn = true
							setSenseVisible(true, col)
							-- pitido tipo sentido aracnido
							if S.senseSound and S.senseSound ~= "None" and S.senseSound ~= false then
								pcall(function()
									local function beep(speed, vol, delayT)
										task.delay(delayT or 0, function()
											local s = Instance.new("Sound")
											s.SoundId = "rbxasset://sounds/electronicpingshort.wav"
											s.Volume = vol or 2
											s.PlaybackSpeed = speed or 1
											s.Parent = SoundService
											s:Play()
											game:GetService("Debris"):AddItem(s, 1.5)
										end)
									end
									local m = tostring(S.senseSound)
									if m == "Sound 1" or m == "true" then
										beep(1.5, 2.0, 0) beep(1.85, 2.2, 0.07) beep(2.2, 2.4, 0.14)
									elseif m == "Sound 2" then
										beep(1.15, 2.3, 0) beep(1.35, 1.8, 0.12) beep(0.95, 1.2, 0.28)
									elseif m == "Sound 3" then
										beep(2.4, 1.8, 0) beep(2.6, 1.8, 0.05) beep(2.8, 1.6, 0.10) beep(3.0, 1.4, 0.15)
									elseif m == "Sound 4" then
										beep(1.0, 2.0, 0) beep(1.4, 2.1, 0.15) beep(1.9, 2.3, 0.25) beep(2.5, 2.5, 0.32)
									end
								end)
							end
						else
							local alive = S.noDisappear or ((tick() - (S.senseShownAt or 0)) < 4)
							if alive then
								if not senseOn then
									senseOn = true
									setSenseVisible(true, col)
								elseif S._senseEdges then
									for _, f in pairs(S._senseEdges) do
										f.BackgroundColor3 = col
									end
								end
							else
								if senseOn then
									senseOn = false
									setSenseVisible(false)
								end
							end
						end
					else
						if S.senseActive or senseOn then
							S.senseActive = false
							S.senseShownAt = 0
							senseOn = false
							setSenseVisible(false)
						end
					end
				else
					if senseOn or S.senseActive then
						S.senseActive = false
						S.senseShownAt = 0
						senseOn = false
						setSenseVisible(false)
					end
				end

				-- Notificaciones: con o sin Sense. Al salir del area se limpia el msg.
				if S.on then
					if S.enemy then
						if nearEnemy and not S.enemyInside then
							S.enemyInside = true
							notify((_G.SupremacyLang == "Spanish") and "Asistente: enemigo cerca" or "Assistant: enemy nearby")
						elseif not nearEnemy then
							if S.enemyInside then
								pcall(function()
									local pg = player:FindFirstChild("PlayerGui")
									local g = pg and pg:FindFirstChild("SupremacyAssistNotify")
									local m = g and g:FindFirstChild("Msg")
									if m then m:Destroy() end
								end)
							end
							S.enemyInside = false
						end
					else
						S.enemyInside = false
					end
					if S.hp then
						if lowHp and not S.hpInside then
							S.hpInside = true
							local hpMsgs = (_G.SupremacyLang == "Spanish") and {
								"Asistente: vida baja",
								"Asistente: estas bajo de vida",
								"Asistente: te queda poca vida",
								"Asistente: cuidado, vida baja",
								"Asistente: cura o retirate",
								"Asistente: vas mal de vida",
								"Asistente: vida critica",
								"Asistente: no pelees asi de bajo",
								"Asistente: recupera vida ya",
								"Asistente: estas en peligro, poca vida",
								"Asistente: reset, te van a matar",
								"Asistente: vida roja, juega seguro",
							} or {
								"Assistant: low health",
								"Assistant: your health is low",
								"Assistant: little health left",
								"Assistant: careful, low HP",
								"Assistant: heal or retreat",
								"Assistant: bad health status",
								"Assistant: critical health",
								"Assistant: do not fight this low",
								"Assistant: recover health now",
								"Assistant: danger, low health",
								"Assistant: reset, they will kill you",
								"Assistant: red health, play safe",
							}
							notify(hpMsgs[math.random(1, #hpMsgs)])
						elseif not lowHp then
							if S.hpInside then
								pcall(function()
									local pg = player:FindFirstChild("PlayerGui")
									local g = pg and pg:FindFirstChild("SupremacyAssistNotify")
									local m = g and g:FindFirstChild("Msg")
									if m then m:Destroy() end
								end)
							end
							S.hpInside = false
						end
					else
						S.hpInside = false
					end
				end

				-- PvP Indicator: solo si Enable Assistant esta ON
				if S.pvpInd and S.on and root and hum then
					local maxD = tonumber(S.pvpDist) or 200
					S._pvpPos = S._pvpPos or {}
					S._pvpHp = S._pvpHp or {}
					local now = tick()
					local myPct = hum.Health / math.max(hum.MaxHealth, 1)
					local look = root.CFrame.LookVector
					local lookFlat = Vector3.new(look.X, 0, look.Z)
					if lookFlat.Magnitude > 0.05 then lookFlat = lookFlat.Unit end

					local enemies = 0
					local closestD = math.huge
					local closestPlr = nil
					local closestR = nil
					local closestH = nil
					local closing, fleeing, behind = false, false, false
					local enemyLow, enemyMid = false, false
					local enemyStill = false
					local gotKill = false
					local anyInMelee = false
					local anyMidRange = false

					for _, plr in pairs(Players:GetPlayers()) do
						if plr ~= player and not isWhitelisted(plr) then
							local char = plr.Character
							local r = char and char:FindFirstChild("HumanoidRootPart")
							local h = char and char:FindFirstChildOfClass("Humanoid")
							local uid = plr.UserId
							if r and h then
								local dist = (r.Position - root.Position).Magnitude
								local hp = h.Health
								local prevHp = S._pvpHp[uid]
								if prevHp and prevHp > 1 and hp <= 0 and dist <= maxD * 1.5 then
									gotKill = true
								end
								S._pvpHp[uid] = hp
								if hp > 0 and dist <= maxD then
									enemies = enemies + 1
									if dist < closestD then
										closestD = dist
										closestPlr = plr
										closestR = r
										closestH = h
									end
									local ePct = hp / math.max(h.MaxHealth, 1)
									if ePct <= 0.30 then enemyLow = true
									elseif ePct <= 0.55 then enemyMid = true end
									if dist < 40 then anyInMelee = true end
									if dist >= 40 and dist <= 120 then anyMidRange = true end

									local flat = Vector3.new(r.Position.X - root.Position.X, 0, r.Position.Z - root.Position.Z)
									if flat.Magnitude > 3 and lookFlat.Magnitude > 0.05 then
										local dot = lookFlat:Dot(flat.Unit)
										-- detras de verdad (espalda)
										if dot < -0.55 and dist < maxD * 0.9 then
											behind = true
										end
									end

									local prev = S._pvpPos[uid]
									local speed = 0
									if prev and (now - prev.t) > 0.12 and (now - prev.t) < 1.0 then
										local dt = now - prev.t
										speed = (r.Position - prev.p).Magnitude / math.max(dt, 0.05)
										local oldD = (prev.p - root.Position).Magnitude
										-- se acerca / huye con umbral mas claro
										if dist < oldD - 7 and speed > 8 then closing = true end
										if dist > oldD + 7 and speed > 8 then fleeing = true end
										-- quieto real (no lag spike)
										if speed <= 6 and dist < maxD * 0.8 then
											enemyStill = true
										end
									end
									pcall(function()
										local v = r.AssemblyLinearVelocity.Magnitude
										if v > speed then speed = v end
										if v <= 5 and dist < maxD * 0.8 then enemyStill = true end
									end)
									S._pvpPos[uid] = { p = r.Position, t = now }
								end
							elseif S._pvpHp[uid] and S._pvpHp[uid] > 0 then
								S._pvpHp[uid] = 0
							end
						end
					end

					-- prioridad sobre el mas cercano
					if closestH and closestR then
						local ePct = closestH.Health / math.max(closestH.MaxHealth, 1)
						if ePct <= 0.28 then enemyLow = true end
					end

					local tips_es = {
						death = {
							"Asistente: eso no salio segun lo planeado",
							"Asistente: ok... eso dolio un poco",
							"Asistente: respawn y lo intentamos otra vez",
							"Asistente: no fue tu mejor momento, honestamente",
							"Asistente: todos caemos, lo importante es levantarse",
							"Asistente: anota mental: no repetir eso",
							"Asistente: bueno, al menos fue cinematografico",
							"Asistente: plan B: no morir asi otra vez",
							"Asistente: hey, incluso los buenos fallan",
							"Asistente: respirar, resetear, volver mas listo",
							"Asistente: esa no la teniamos en el guion",
							"Asistente: te vi venir... tarde, pero te vi",
							"Asistente: ok heroe, a levantarse",
							"Asistente: la proxima leemos mejor el timing",
							"Asistente: no pasa nada, aprendimos algo",
							"Asistente: enemigo 1, nosotros 0... por ahora",
							"Asistente: caida con estilo, digamos",
							"Asistente: siguiente ronda es nuestra",
							"Asistente: eso fue un plot twist no pedido",
							"Asistente: cuenta hasta tres y volvemos",
							"Asistente: fallamos el combo, no la actitud",
							"Asistente: nota: esquivar existe",
							"Asistente: dolor temporal, progreso permanente",
							"Asistente: no eras invencible... hoy",
						},
						kill = {
							"Asistente: bien jugado",
							"Asistente: buena esa",
							"Asistente: limpio, sigue asi",
							"Asistente: gran kill",
							"Asistente: lo leiste perfecto",
							"Asistente: eso fue inteligente",
							"Asistente: bien cerrado",
						},
						behind = {
							"Asistente: esta detras, gira ya",
							"Asistente: no dejes la espalda libre",
							"Asistente: voltea, te pueden castigar",
							"Asistente: cuidado atras",
							"Asistente: enemigo a tu espalda",
						},
						multi = {
							"Asistente: hay varios, no te centres en uno",
							"Asistente: 1v2 malo, juega seguro",
							"Asistente: no forcees con mas de uno",
							"Asistente: separa o retírate",
							"Asistente: multi, prioriza vivir",
						},
						retreat = {
							"Asistente: vas bajo, mejor retírate",
							"Asistente: no pelees asi de vida",
							"Asistente: reset ahora, estas mal",
							"Asistente: prioriza vivir",
							"Asistente: vida baja, sal de ahi",
						},
						press = {
							"Asistente: momento de presionarlo",
							"Asistente: esta debil, ataca ya",
							"Asistente: cierralo, no lo dejes escapar",
							"Asistente: hora de castigarlo",
							"Asistente: presiona fuerte ahora",
							"Asistente: terminas la pelea si entras bien",
						},
						still = {
							"Asistente: esta quieto, aprovecha",
							"Asistente: no se mueve, castigalo",
							"Asistente: blanco facil, entra ya",
							"Asistente: esta parado, no desperdicies",
							"Asistente: aprovecha que esta quieto",
						},
						advantage = {
							"Asistente: vas mejor, sigue controlando",
							"Asistente: ventaja tuya, no la regales",
							"Asistente: juega agresivo con cabeza",
							"Asistente: tienes la de ganar, no te apures",
						},
						incoming = {
							"Asistente: viene hacia ti, preparate",
							"Asistente: se acerca, no te quedes quieto",
							"Asistente: lista el counter",
							"Asistente: controla el espacio",
						},
						bait = {
							"Asistente: puede ser bait, no persigas loco",
							"Asistente: se aleja, lee antes de entrar",
							"Asistente: no gastes todo corriendo atras",
							"Asistente: espera, puede estar engañando",
						},
						close = {
							"Asistente: cerca, mueve y no tires todo",
							"Asistente: pelea corta, espera su error",
							"Asistente: concentra, no spam ciego",
							"Asistente: mindgame: finta y castiga",
						},
						mid = {
							"Asistente: distancia media, elige bien el engage",
							"Asistente: no entres en seco, espera timing",
							"Asistente: juega el espacio a tu favor",
						},
					}
					local tips_en = {
						death = {
							"Assistant: that did not go as planned",
							"Assistant: ok... that hurt a bit",
							"Assistant: respawn and try again",
							"Assistant: not your best moment honestly",
							"Assistant: we all fall, what matters is getting up",
							"Assistant: mental note: do not repeat that",
							"Assistant: at least it was cinematic",
							"Assistant: plan B: do not die like that again",
							"Assistant: hey, even the good ones fail",
							"Assistant: breathe, reset, come back smarter",
							"Assistant: that was not in the script",
							"Assistant: I saw it coming... late, but I saw it",
							"Assistant: ok hero, get up",
							"Assistant: next time read the timing better",
							"Assistant: all good, we learned something",
							"Assistant: enemy 1, us 0... for now",
							"Assistant: stylish fall, let's say",
							"Assistant: next round is ours",
							"Assistant: unrequested plot twist",
							"Assistant: count to three and we go again",
							"Assistant: we missed the combo, not the attitude",
							"Assistant: note: dodging exists",
							"Assistant: temporary pain, permanent progress",
							"Assistant: you were not invincible... today",
						},
						kill = {
							"Assistant: well played",
							"Assistant: nice one",
							"Assistant: clean, keep it up",
							"Assistant: great kill",
							"Assistant: perfect read",
							"Assistant: that was smart",
							"Assistant: well closed",
						},
						behind = {
							"Assistant: behind you, turn now",
							"Assistant: do not leave your back open",
							"Assistant: turn around, they can punish you",
							"Assistant: watch your back",
							"Assistant: enemy at your back",
						},
						multi = {
							"Assistant: multiple enemies, do not focus one",
							"Assistant: 1v2 is bad, play safe",
							"Assistant: do not force with more than one",
							"Assistant: separate or retreat",
							"Assistant: multi, prioritize living",
						},
						retreat = {
							"Assistant: you are low, better retreat",
							"Assistant: do not fight with that health",
							"Assistant: reset now, you are in bad shape",
							"Assistant: prioritize living",
							"Assistant: low health, get out",
						},
						press = {
							"Assistant: time to pressure them",
							"Assistant: they are weak, attack now",
							"Assistant: close it, do not let them escape",
							"Assistant: time to punish",
							"Assistant: press hard now",
							"Assistant: end the fight if you enter well",
						},
						still = {
							"Assistant: they are still, take advantage",
							"Assistant: not moving, punish them",
							"Assistant: easy target, go in",
							"Assistant: standing still, do not waste it",
							"Assistant: use that they are still",
						},
						advantage = {
							"Assistant: you are ahead, keep control",
							"Assistant: advantage is yours, do not throw it",
							"Assistant: play aggressive with brain",
							"Assistant: you can win, do not rush",
						},
						incoming = {
							"Assistant: coming at you, get ready",
							"Assistant: approaching, do not stand still",
							"Assistant: prepare the counter",
							"Assistant: control the space",
						},
						bait = {
							"Assistant: could be bait, do not chase wild",
							"Assistant: they run, read before entering",
							"Assistant: do not waste everything chasing",
							"Assistant: wait, they may be faking",
						},
						close = {
							"Assistant: close range, move and do not dump all",
							"Assistant: short fight, wait for their mistake",
							"Assistant: focus, no blind spam",
						},
					}
					local tips = (_G.SupremacyLang == "Spanish") and tips_es or tips_en

					-- muerte propia (personalidad tipo asistente Spidey)
					local iDied = false
					pcall(function()
						local alive = hum.Health > 0
						if S._myWasAlive == nil then S._myWasAlive = alive end
						if S._myWasAlive and not alive then
							iDied = true
					end
						S._myWasAlive = alive
					end)

					-- prioridad inteligente (critico primero)
					local key = nil
					if iDied then
						key = "death"
					elseif gotKill then
						key = "kill"
					elseif enemies >= 1 then
						if behind then
							key = "behind"
						elseif enemies >= 2 and myPct <= 0.55 then
							key = "multi"
						elseif myPct <= 0.25 then
							key = "retreat"
						elseif enemyLow and closestD < maxD * 0.95 then
							key = "press"
						elseif enemies >= 2 then
							key = "multi"
						elseif closing and closestD < maxD * 0.75 then
							key = "incoming"
						elseif fleeing and myPct <= 0.60 and closestD < maxD then
							key = "bait"
						elseif enemyStill and closestD < 90 and myPct >= 0.35 then
							key = "still"
						elseif enemyMid and myPct >= 0.50 and closestD < maxD * 0.85 then
							key = "advantage"
						elseif anyInMelee or closestD < 42 then
							key = "close"
						elseif anyMidRange then
							key = "mid"
						end
					end

					local same = (key == S.pvpLastKey)
					local cd = 2.4
					if key == "death" then cd = 1.2
					elseif key == "kill" then cd = 2.0
					elseif key == "behind" or key == "retreat" then cd = 2.2
					elseif same then cd = 4.0
					else cd = 2.8 end

					if key and (now - (S.pvpLastTip or 0)) >= cd then
						local list = tips[key]
						if list then
							S.pvpLastKey = key
							S.pvpLastTip = now
							notify(list[math.random(1, #list)])
						end
					end
					if enemies <= 0 and not gotKill then
						if S.pvpLastKey and S.pvpLastKey ~= "" and S.pvpLastKey ~= "kill" then
							if (now - (S.pvpLastTip or 0)) >= 2.5 then
								S.pvpLastKey = ""
							end
						end
					end
				end
			end)
		end
	end)

	local function openColorMenu(current, onPick)
		for _, ch in pairs(ScreenGui:GetChildren()) do
			if ch.Name == "AssistColorMenu" then ch:Destroy() end
		end
		local frame = Instance.new("Frame")
		frame.Name = "AssistColorMenu"
		frame.Size = UDim2.new(0, 200, 0, 150)
		frame.Position = UDim2.new(0.5, -100, 0.5, -75)
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BorderSizePixel = 0
		frame.ZIndex = 120
		frame.Parent = ScreenGui
		local frameStroke = Instance.new("UIStroke", frame)
		frameStroke.Color = Color3.fromRGB(180, 180, 180)
		frameStroke.Thickness = 1
		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, 0, 0, 24)
		title.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
		title.BorderSizePixel = 0
		title.Text = "Pick a Color"
		title.TextColor3 = Color3.fromRGB(20, 20, 20)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 13
		title.ZIndex = 121
		title.Parent = frame
		local colors = {
			Color3.fromHex("#222222"), Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 128, 0),
			Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 250, 255),
			Color3.fromRGB(80, 160, 255), Color3.fromRGB(200, 80, 255), Color3.fromRGB(255, 255, 255),
			Color3.fromRGB(0, 0, 0), Color3.fromRGB(120, 120, 120), Color3.fromRGB(255, 105, 180),
		}
		local selected = current
		local selStroke = nil
		for i, col in ipairs(colors) do
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0, 26, 0, 26)
			local coln = (i - 1) % 6
			local rown = math.floor((i - 1) / 6)
			btn.Position = UDim2.new(0, 12 + coln * 30, 0, 30 + rown * 32)
			btn.BackgroundColor3 = col
			btn.Text = ""
			btn.ZIndex = 122
			btn.Parent = frame
			local st = Instance.new("UIStroke", btn)
			st.Thickness = 2
			st.Color = Color3.fromRGB(50, 50, 50)
			if col == current then
				selStroke = st
				st.Color = Color3.fromRGB(30, 30, 30)
				st.Thickness = 3
			end
			btn.MouseButton1Click:Connect(function()
				selected = col
				if selStroke then selStroke.Color = Color3.fromRGB(50, 50, 50) selStroke.Thickness = 2 end
				selStroke = st
				st.Color = Color3.fromRGB(30, 30, 30)
				st.Thickness = 3
			end)
		end
		local save = Instance.new("TextButton")
		save.Size = UDim2.new(0, 80, 0, 24)
		save.Position = UDim2.new(0, 16, 1, -32)
		save.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
		save.Text = "Save"
		save.TextColor3 = Color3.new(1, 1, 1)
		save.Font = Enum.Font.GothamBold
		save.TextSize = 12
		save.ZIndex = 122
		save.Parent = frame
		local cancel = Instance.new("TextButton")
		cancel.Size = UDim2.new(0, 80, 0, 24)
		cancel.Position = UDim2.new(1, -96, 1, -32)
		cancel.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
		cancel.Text = tr("Cancel")
		cancel.TextColor3 = Color3.fromRGB(40, 40, 40)
		cancel.Font = Enum.Font.GothamBold
		cancel.TextSize = 12
		cancel.ZIndex = 122
		cancel.Parent = frame
		save.MouseButton1Click:Connect(function()
			if onPick then onPick(selected) end
			frame:Destroy()
		end)
		cancel.MouseButton1Click:Connect(function()
			frame:Destroy()
		end)
	end

	local function addToggle(parent, text, key, withColor, colorKey)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -10, 0, 20)
		row.BackgroundTransparency = 1
		row.Parent = parent
		local lab = Instance.new("TextLabel")
		lab.Size = UDim2.new(1, withColor and -70 or -44, 1, 0)
		lab.Position = UDim2.new(0, 8, 0, 0)
		lab.BackgroundTransparency = 1
		lab.Text = tr(text)
		lab.TextColor3 = Color3.fromRGB(25, 25, 25)
		lab.Font = Enum.Font.Gotham
		lab.TextSize = 11
		lab.TextXAlignment = Enum.TextXAlignment.Left
		registerLangLabel(text, lab)
		lab.Parent = row
		if withColor and colorKey then
			local cp = Instance.new("TextButton")
			cp.Size = UDim2.new(0, 12, 0, 12)
			cp.Position = UDim2.new(1, -52, 0.5, -6)
			cp.BackgroundColor3 = S[colorKey]
			cp.Text = ""
			cp.BorderSizePixel = 0
			cp.Parent = row
			Instance.new("UICorner", cp).CornerRadius = UDim.new(0, 3)
			local cst = Instance.new("UIStroke", cp)
			cst.Thickness = 1
			cst.Color = Color3.fromRGB(80, 80, 80)
			cp.MouseButton1Click:Connect(function()
				openColorMenu(S[colorKey], function(col)
					S[colorKey] = col
					cp.BackgroundColor3 = col
				end)
			end)
		end
		local tg = Instance.new("Frame")
		tg.Size = UDim2.new(0, 26, 0, 11)
		tg.Position = UDim2.new(1, -34, 0.5, -5.5)
		tg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		tg.BorderSizePixel = 0
		tg.Parent = row
		Instance.new("UICorner", tg).CornerRadius = UDim.new(1, 0)
		local ball = Instance.new("Frame")
		ball.Size = UDim2.new(0, 7, 0, 7)
		ball.Position = UDim2.new(0, S[key] and 16 or 2, 0.5, -3.5)
		ball.BackgroundColor3 = S[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
		ball.BorderSizePixel = 0
		ball.Parent = tg
		Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, 0, 1, 0)
		b.BackgroundTransparency = 1
		b.Text = ""
		b.Parent = tg
		b.MouseButton1Click:Connect(function()
			S[key] = not S[key]
			if S[key] then
				TweenService:Create(ball, TweenInfo.new(0.15), {
					Position = UDim2.new(0, 16, 0.5, -3.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				}):Play()
			else
				TweenService:Create(ball, TweenInfo.new(0.15), {
					Position = UDim2.new(0, 2, 0.5, -3.5),
					BackgroundColor3 = Color3.fromRGB(120, 120, 120),
				}):Play()
			end
			if key == "on" then
				if S.on then
					-- saludo SOLO al activar (1 vez); se resetea al desactivar
					-- si Practice esta ON: saluda completo y LUEGO arranca practice
					if not _G.SupremacyHasGreeted then
						_G.SupremacyHasGreeted = true
						_G.SupremacyGreetBusy = true
						local greet = nil
						pcall(function()
							if _G.SupremacyPickGreet then greet = _G.SupremacyPickGreet() end
						end)
						greet = greet or ((_G.SupremacyLang == "Spanish") and "Hola, listo para ayudarte." or "Hi, ready to help you.")
						_G.SupremacyPracticeHold = false
						_G.SupremacyOnNotifyDone = function()
							_G.SupremacyGreetBusy = false
							-- solo si sigue activo y hay practice esperando
							if S.on and _G.SupremacyPracticeEnabled and _G.SupremacyStartPracticeAfterGreet then
								local fn = _G.SupremacyStartPracticeAfterGreet
								_G.SupremacyStartPracticeAfterGreet = nil
								pcall(fn)
							end
						end
						pcall(function()
							if _G.SupremacyNotifyStream then
								_G.SupremacyNotifyStream(greet)
							else
								notify(greet)
							end
						end)
					elseif _G.SupremacyPracticeEnabled and not _G.SupremacyGreetBusy then
						-- ya saludo antes; practice puede empezar ya
						pcall(function()
							if _G.SupremacyStartPracticeAfterGreet then
								local fn = _G.SupremacyStartPracticeAfterGreet
								_G.SupremacyStartPracticeAfterGreet = nil
								fn()
							end
						end)
					end
				else
					-- al desactivar: limpia cartel + voz (no se queda eterno)
					_G.SupremacyHasGreeted = false
					_G.SupremacyGreetBusy = false
					_G.SupremacyStartPracticeAfterGreet = nil
					pcall(function()
						if _G.SupremacyClearNotify then
							_G.SupremacyClearNotify()
						else
							if _G.SupremacyStopTTS then _G.SupremacyStopTTS(true) end
							local pg = player:FindFirstChild("PlayerGui")
							local g = pg and pg:FindFirstChild("SupremacyAssistNotify")
							if g then for _, ch in pairs(g:GetChildren()) do pcall(function() ch:Destroy() end) end end
						end
					end)
				end
			end
			if key == "sense" and not S.sense then
				senseOn = false
				setSenseVisible(false)
			end
		end)
	end

	local function addSlider(parent, label, key, minV, maxV, defV)
		local box = Instance.new("Frame")
		box.Size = UDim2.new(1, -10, 0, 34)
		box.BackgroundTransparency = 1
		box.Parent = parent
		local lab = Instance.new("TextLabel")
		lab.Size = UDim2.new(1, -56, 0, 12)
		lab.Position = UDim2.new(0, 8, 0, 0)
		lab.BackgroundTransparency = 1
		lab.Text = tr(label)
		lab.TextColor3 = Color3.fromRGB(60, 60, 60)
		lab.Font = Enum.Font.Gotham
		lab.TextSize = 10
		lab.TextXAlignment = Enum.TextXAlignment.Left
		registerLangLabel(label, lab)
		lab.Parent = box
		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, -66, 0, 7)
		bar.Position = UDim2.new(0, 8, 0, 18)
		bar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		bar.BorderSizePixel = 0
		bar.Parent = box
		Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
		local thumb = Instance.new("Frame")
		thumb.Size = UDim2.new(0, 9, 0, 9)
		local pct0 = (defV - minV) / math.max(maxV - minV, 1)
		thumb.Position = UDim2.new(pct0, -4, 0.5, -4.5)
		thumb.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		thumb.BorderSizePixel = 0
		thumb.Parent = bar
		Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
		local num = Instance.new("TextBox")
		num.Size = UDim2.new(0, 44, 0, 14)
		num.Position = UDim2.new(1, -52, 0, 14)
		num.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
		num.BorderSizePixel = 0
		num.Text = tostring(defV)
		num.TextColor3 = Color3.fromRGB(0, 0, 0)
		num.Font = Enum.Font.GothamBold
		num.TextSize = 10
		num.ClearTextOnFocus = false
		num.Parent = box
		local function apply(v)
			v = math.clamp(math.floor(v + 0.5), minV, maxV)
			S[key] = v
			local pct = (v - minV) / math.max(maxV - minV, 1)
			thumb.Position = UDim2.new(pct, -4, 0.5, -4.5)
			num.Text = tostring(v)
		end
		apply(defV)
		local myId = {}
		bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				activeSlider = myId
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if activeSlider == myId then activeSlider = nil end
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if activeSlider ~= myId then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local x = (input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1)
				apply(minV + x * (maxV - minV))
			end
		end)
		num.FocusLost:Connect(function()
			local n = tonumber(num.Text)
			if n then apply(n) else num.Text = tostring(S[key]) end
		end)
	end

	local function showBubble()
		if S.bubble and S.bubble.Parent then
			S.bubble.Visible = true
			return
		end
		local b = Instance.new("TextButton")
		b.Name = "AssistBubble"
		b.Size = UDim2.new(0, 14, 0, 14)
		b.Position = UDim2.new(0.5, -7, 0.15, 0)
		b.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
		b.Text = ""
		b.BorderSizePixel = 0
		b.ZIndex = 12
		b.Active = true
		b.Parent = ScreenGui
		Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
		local st = Instance.new("UIStroke", b)
		st.Thickness = 1
		st.Color = Color3.fromRGB(120, 20, 20)
		S.bubble = b
		local dragging, moved, d0, p0 = false, false, nil, nil
		b.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				moved = false
				d0 = input.Position
				p0 = b.Position
			end
		end)
		b.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local d = input.Position - d0
				if math.abs(d.X) > 6 or math.abs(d.Y) > 6 then moved = true end
				b.Position = UDim2.new(p0.X.Scale, p0.X.Offset + d.X, p0.Y.Scale, p0.Y.Offset + d.Y)
			end
		end)
		b.MouseButton1Click:Connect(function()
			if moved then moved = false return end
			if _G.SupremacyOpenAssistant then
				_G.SupremacyOpenAssistant()
			end
		end)
	end

	local function openAssistant()
		if S.frame and S.frame.Parent then
			-- si falta Voice/Sense Sound, destruir y recrear
			local hasVoice = false
			pcall(function()
				for _, d in ipairs(S.frame:GetDescendants()) do
					if d.Name == "VoiceAssistantRow" then hasVoice = true break end
				end
			end)
			if hasVoice then
				S.frame.Visible = true
				if S.bubble then S.bubble.Visible = false end
				return
			end
			pcall(function() S.frame:Destroy() end)
			S.frame = nil
		end
		local f = Instance.new("Frame")
		f.Name = "AssistantPanel"
		f.Size = UDim2.new(0, 240, 0, 220)
		f.Position = UDim2.new(0.5, -120, 0.5, -110)
		f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		f.BorderSizePixel = 0
		f.Active = true
		f.ZIndex = 100
		f.Parent = ScreenGui
		S.frame = f
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(180, 180, 180)
		stroke.Thickness = 1
		stroke.Parent = f
		local hd = Instance.new("Frame")
		hd.Size = UDim2.new(1, 0, 0, 26)
		hd.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
		hd.BorderSizePixel = 0
		hd.Active = true
		hd.Parent = f
		local tt = Instance.new("TextLabel")
		tt.Size = UDim2.new(1, -56, 1, 0)
		tt.Position = UDim2.new(0, 10, 0, 0)
		tt.BackgroundTransparency = 1
		tt.Text = tr("Assistant")
		registerLangLabel("Assistant", tt)
		tt.TextColor3 = Color3.fromRGB(20, 20, 20)
		tt.Font = Enum.Font.GothamBold
		tt.TextSize = 12
		tt.TextXAlignment = Enum.TextXAlignment.Left
		tt.Parent = hd
		local minBtn = Instance.new("TextButton")
		minBtn.Size = UDim2.new(0, 22, 0, 22)
		minBtn.Position = UDim2.new(1, -48, 0.5, -11)
		minBtn.BackgroundTransparency = 1
		minBtn.Text = "-"
		minBtn.TextColor3 = Color3.fromRGB(80, 80, 80)
		minBtn.Font = Enum.Font.GothamBold
		minBtn.TextSize = 16
		minBtn.Parent = hd
		minBtn.MouseButton1Click:Connect(function()
			f.Visible = false
			showBubble()
		end)
		local cx = Instance.new("TextButton")
		cx.Size = UDim2.new(0, 22, 0, 22)
		cx.Position = UDim2.new(1, -26, 0.5, -11)
		cx.BackgroundTransparency = 1
		cx.Text = "x"
		cx.TextColor3 = Color3.fromRGB(80, 80, 80)
		cx.Font = Enum.Font.GothamBold
		cx.TextSize = 16
		cx.Parent = hd
		cx.MouseButton1Click:Connect(function()
			f.Visible = false
			if S.bubble then S.bubble.Visible = false end
		end)
		local drag, d0, p0 = false, nil, nil
		hd.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				drag = true
				d0 = input.Position
				p0 = f.Position
			end
		end)
		hd.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				drag = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local d = input.Position - d0
				f.Position = UDim2.new(p0.X.Scale, p0.X.Offset + d.X, p0.Y.Scale, p0.Y.Offset + d.Y)
			end
		end)
		-- Tabs: General | Combat | PvP Practice
		f.Size = UDim2.new(0, 300, 0, 280)
		f.Position = UDim2.new(0.5, -150, 0.5, -140)

		local tabBar = Instance.new("Frame")
		tabBar.Name = "TabBar"
		tabBar.Size = UDim2.new(1, -8, 0, 22)
		tabBar.Position = UDim2.new(0, 4, 0, 28)
		tabBar.BackgroundTransparency = 1
		tabBar.ZIndex = 101
		tabBar.Parent = f
		local tabLay = Instance.new("UIListLayout")
		tabLay.FillDirection = Enum.FillDirection.Horizontal
		tabLay.Padding = UDim.new(0, 6)
		tabLay.SortOrder = Enum.SortOrder.LayoutOrder
		tabLay.Parent = tabBar

		local pages = {}
		local tabBtns = {}
		local underlines = {}
		local currentTab = "General"

		local function makePage(name)
			local list = Instance.new("ScrollingFrame")
			list.Name = "Page_" .. name
			list.Size = UDim2.new(1, 0, 1, -54)
			list.Position = UDim2.new(0, 0, 0, 52)
			list.BackgroundTransparency = 1
			list.BorderSizePixel = 0
			list.ScrollBarThickness = 3
			list.CanvasSize = UDim2.new(0, 0, 0, 0)
			list.AutomaticCanvasSize = Enum.AutomaticSize.Y
			list.Visible = false
			list.ZIndex = 101
			list.Parent = f
			local lay = Instance.new("UIListLayout")
			lay.Padding = UDim.new(0, 3)
			lay.SortOrder = Enum.SortOrder.LayoutOrder
			lay.Parent = list
			local pad = Instance.new("UIPadding")
			pad.PaddingBottom = UDim.new(0, 8)
			pad.PaddingLeft = UDim.new(0, 2)
			pad.PaddingRight = UDim.new(0, 2)
			pad.Parent = list
			pages[name] = list
			return list
		end

		local function selectTab(name)
			currentTab = name
			for n, pg in pairs(pages) do
				pg.Visible = (n == name)
			end
			for n, btn in pairs(tabBtns) do
				btn.TextColor3 = (n == name) and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(140, 140, 140)
				btn.Font = (n == name) and Enum.Font.GothamBold or Enum.Font.Gotham
			end
			for n, line in pairs(underlines) do
				line.BackgroundTransparency = (n == name) and 0.35 or 1
			end
		end

		local tabNames = { "General", "Combat", "PvP Practice" }
		tabLay.Padding = UDim.new(0, 0)
		tabLay.HorizontalAlignment = Enum.HorizontalAlignment.Center
		local nTabs = #tabNames
		for i, name in ipairs(tabNames) do
			local wrap = Instance.new("Frame")
			wrap.Size = UDim2.new(1 / nTabs, 0, 1, 0)
			wrap.BackgroundTransparency = 1
			wrap.LayoutOrder = i
			wrap.ZIndex = 102
			wrap.Parent = tabBar
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 1, -3)
			btn.BackgroundTransparency = 1
			btn.Text = tr(name)
			btn.TextColor3 = Color3.fromRGB(140, 140, 140)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 9
			btn.AutoButtonColor = false
			btn.ZIndex = 103
			btn.Parent = wrap
			registerLangLabel(name, btn)
			local line = Instance.new("Frame")
			line.Name = "Underline"
			line.Size = UDim2.new(0.7, 0, 0, 2)
			line.Position = UDim2.new(0.15, 0, 1, -2)
			line.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			line.BackgroundTransparency = 1
			line.BorderSizePixel = 0
			line.ZIndex = 103
			line.Parent = wrap
			tabBtns[name] = btn
			underlines[name] = line
			btn.MouseButton1Click:Connect(function()
				selectTab(name)
			end)
			makePage(name)
		end

		local general = pages["General"]
		local combat = pages["Combat"]
		local pvpPage = pages["PvP Practice"]
		
		-- GENERAL: Enable -> Voice -> Sense -> Sense Sound -> No disappearance
		addToggle(general, "Enable Assistant", "on", false, nil)

		-- Voice Assistant dropdown (inline, no depende de modulo externo)
		do
			_G.SupremacyVoiceAssist = _G.SupremacyVoiceAssist or "None"
			local row = Instance.new("Frame")
			row.Name = "VoiceAssistantRow"
			row.Size = UDim2.new(1, -10, 0, 20)
			row.BackgroundTransparency = 1
			row.LayoutOrder = 2
			row.Visible = true
			row.ZIndex = 102
			row.Parent = general
			local lab = Instance.new("TextLabel")
			lab.Size = UDim2.new(1, -86, 1, 0)
			lab.Position = UDim2.new(0, 8, 0, 0)
			lab.BackgroundTransparency = 1
			lab.Text = tr("Voice Assistant")
			registerLangLabel("Voice Assistant", lab)
			lab.TextColor3 = Color3.fromRGB(25, 25, 25)
			lab.Font = Enum.Font.Gotham
			lab.TextSize = 11
			lab.TextXAlignment = Enum.TextXAlignment.Left
			lab.Parent = row
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0, 72, 0, 16)
			btn.Position = UDim2.new(1, -80, 0.5, -8)
			btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			btn.BorderSizePixel = 0
			btn.Text = tostring(_G.SupremacyVoiceAssist or "None")
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 10
			btn.AutoButtonColor = false
			btn.Parent = row
			local drop = Instance.new("ScrollingFrame")
			drop.Name = "AssistVoiceDrop"
			drop.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
			drop.BorderSizePixel = 0
			drop.Visible = false
			drop.ScrollBarThickness = 0
			drop.AutomaticCanvasSize = Enum.AutomaticSize.Y
			drop.CanvasSize = UDim2.new(0, 0, 0, 0)
			drop.ClipsDescendants = true
			drop.ZIndex = 250
			drop.Parent = ScreenGui
			Instance.new("UIListLayout", drop).Padding = UDim.new(0, 2)
			local open = false
			local opts = { "None", "Voice 1", "Voice 2" }
			local function closeDrop()
				open = false
				drop.Visible = false
			end
			local function openDrop()
				for _, ch in ipairs(drop:GetChildren()) do
					if ch:IsA("TextButton") then ch:Destroy() end
				end
				for _, name in ipairs(opts) do
					local b = Instance.new("TextButton")
					b.Size = UDim2.new(1, 0, 0, 16)
					b.BackgroundColor3 = (name == _G.SupremacyVoiceAssist) and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(40, 40, 40)
					b.Text = name
					b.TextColor3 = Color3.fromRGB(255, 255, 255)
					b.TextSize = 10
					b.Font = Enum.Font.GothamBold
					b.BorderSizePixel = 0
					b.ZIndex = 251
					b.Parent = drop
					b.MouseButton1Click:Connect(function()
						_G.SupremacyVoiceAssist = name
						btn.Text = name
						closeDrop()
						pcall(function()
							if name == "None" then
								if _G.SupremacyStopTTS then _G.SupremacyStopTTS(true) end
							else
								if _G.SupremacySpeakAssist then
									local g = (_G.SupremacyPickGreet and _G.SupremacyPickGreet()) or "Assistant ready"
									_G.SupremacySpeakAssist(g)
								end
							end
						end)
					end)
				end
				local ap = btn.AbsolutePosition
				local asz = btn.AbsoluteSize
				local sgPos = ScreenGui.AbsolutePosition
				local w = math.max(math.floor(asz.X), 56)
				local h = #opts * 16
				drop.Size = UDim2.fromOffset(w, h)
				local x = math.floor(ap.X - sgPos.X)
				local y = math.floor(ap.Y - sgPos.Y + asz.Y + 1)
				if x < 0 then x = 0 end
				drop.Position = UDim2.fromOffset(x, y)
				drop.Visible = true
				open = true
			end
			btn.MouseButton1Click:Connect(function()
				if open then closeDrop() else openDrop() end
			end)
			UserInputService.InputBegan:Connect(function(input)
				if not open then return end
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
				task.delay(0.08, function()
					if not open then return end
					local pos = input.Position
					local function inside(g)
						if not g or not g.Visible then return false end
						local p, sz = g.AbsolutePosition, g.AbsoluteSize
						return pos.X >= p.X and pos.X <= p.X + sz.X and pos.Y >= p.Y and pos.Y <= p.Y + sz.Y
					end
					if inside(drop) or inside(btn) then return end
					closeDrop()
				end)
			end)
		end

		addToggle(general, "Sense Prediction", "sense", false, nil)

		-- Sense Sound dropdown (inline)
		do
			S.senseSound = S.senseSound or "None"
			local row = Instance.new("Frame")
			row.Name = "SenseSoundRow"
			row.Size = UDim2.new(1, -10, 0, 20)
			row.BackgroundTransparency = 1
			row.LayoutOrder = 4
			row.Visible = true
			row.ZIndex = 102
			row.Parent = general
			local lab = Instance.new("TextLabel")
			lab.Size = UDim2.new(1, -86, 1, 0)
			lab.Position = UDim2.new(0, 8, 0, 0)
			lab.BackgroundTransparency = 1
			lab.Text = tr("Sense Sound")
			registerLangLabel("Sense Sound", lab)
			lab.TextColor3 = Color3.fromRGB(25, 25, 25)
			lab.Font = Enum.Font.Gotham
			lab.TextSize = 11
			lab.TextXAlignment = Enum.TextXAlignment.Left
			lab.Parent = row
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0, 72, 0, 16)
			btn.Position = UDim2.new(1, -80, 0.5, -8)
			btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			btn.BorderSizePixel = 0
			btn.Text = tostring(S.senseSound or "None")
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 10
			btn.AutoButtonColor = false
			btn.Parent = row
			local drop = Instance.new("ScrollingFrame")
			drop.Name = "AssistSenseDrop"
			drop.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
			drop.BorderSizePixel = 0
			drop.Visible = false
			drop.ScrollBarThickness = 0
			drop.AutomaticCanvasSize = Enum.AutomaticSize.Y
			drop.CanvasSize = UDim2.new(0, 0, 0, 0)
			drop.ClipsDescendants = true
			drop.ZIndex = 250
			drop.Parent = ScreenGui
			Instance.new("UIListLayout", drop).Padding = UDim.new(0, 2)
			local open = false
			local opts = { "None", "Sound 1", "Sound 2", "Sound 3", "Sound 4" }
			local function closeDrop()
				open = false
				drop.Visible = false
			end
			local function openDrop()
				for _, ch in ipairs(drop:GetChildren()) do
					if ch:IsA("TextButton") then ch:Destroy() end
				end
				for _, name in ipairs(opts) do
					local b = Instance.new("TextButton")
					b.Size = UDim2.new(1, 0, 0, 16)
					b.BackgroundColor3 = (name == S.senseSound) and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(40, 40, 40)
					b.Text = name
					b.TextColor3 = Color3.fromRGB(255, 255, 255)
					b.TextSize = 10
					b.Font = Enum.Font.GothamBold
					b.BorderSizePixel = 0
					b.ZIndex = 251
					b.Parent = drop
					b.MouseButton1Click:Connect(function()
						S.senseSound = name
						btn.Text = name
						closeDrop()
					end)
				end
				local ap = btn.AbsolutePosition
				local asz = btn.AbsoluteSize
				local sgPos = ScreenGui.AbsolutePosition
				local w = math.max(math.floor(asz.X), 56)
				local h = #opts * 16
				drop.Size = UDim2.fromOffset(w, h)
				local x = math.floor(ap.X - sgPos.X)
				local y = math.floor(ap.Y - sgPos.Y + asz.Y + 1)
				if x < 0 then x = 0 end
				drop.Position = UDim2.fromOffset(x, y)
				drop.Visible = true
				open = true
			end
			btn.MouseButton1Click:Connect(function()
				if open then closeDrop() else openDrop() end
			end)
			UserInputService.InputBegan:Connect(function(input)
				if not open then return end
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
				task.delay(0.08, function()
					if not open then return end
					local pos = input.Position
					local function inside(g)
						if not g or not g.Visible then return false end
						local p, sz = g.AbsolutePosition, g.AbsoluteSize
						return pos.X >= p.X and pos.X <= p.X + sz.X and pos.Y >= p.Y and pos.Y <= p.Y + sz.Y
					end
					if inside(drop) or inside(btn) then return end
					closeDrop()
				end)
			end)
		end

		addToggle(general, "No disappearance", "noDisappear", false, nil)
		-- orden fijo: Enable, Voice, Sense, Sense Sound, No disappearance
		pcall(function()
			local function setOrderByLabel(ch, n)
				ch.LayoutOrder = n
			end
			for _, ch in ipairs(general:GetChildren()) do
				if not ch:IsA("GuiObject") then
				elseif ch.Name == "VoiceAssistantRow" then
					ch.LayoutOrder = 2
					ch.Visible = true
				elseif ch.Name == "SenseSoundRow" then
					ch.LayoutOrder = 4
					ch.Visible = true
				else
					local label
					for _, d in ipairs(ch:GetDescendants()) do
						if d:IsA("TextLabel") then label = d.Text break end
					end
					label = tostring(label or "")
					if label:find("Enable") or label:find("Activar") then
						ch.LayoutOrder = 1
					elseif label:find("Sense Prediction") or label:find("Prediccion Sense") then
						ch.LayoutOrder = 3
					elseif label:find("No disappear") or label:find("No Desaparecer") then
						ch.LayoutOrder = 5
					end
				end
			end
		end)


		-- COMBAT
		addToggle(combat, "Enemy Nearby", "enemy", true, "enemyColor")
		addSlider(combat, "Enemy Distance", "enemyDist", 10, 500, S.enemyDist)
		addToggle(combat, "Low HP Alert", "hp", true, "hpColor")
		addSlider(combat, "HP Threshold", "hpThresh", 100, 5000, S.hpThresh)
		pcall(function()
			if _G.SupremacyMountObserve then
				_G.SupremacyMountObserve(combat, f, ScreenGui, player, Players, UserInputService, RunService)
			end
		end)
		addToggle(combat, "PvP Indicator", "pvpInd", false, nil)
		addSlider(combat, "PvP Distance", "pvpDist", 50, 1000, S.pvpDist)

		-- placeholders
		local function emptyHint(parent, text)
			local l = Instance.new("TextLabel")
			l.Size = UDim2.new(1, -8, 0, 40)
			l.BackgroundTransparency = 1
			l.Text = text
			l.TextColor3 = Color3.fromRGB(150, 150, 150)
			l.Font = Enum.Font.Gotham
			l.TextSize = 11
			l.TextWrapped = true
			l.Parent = parent
		end
												-- ===== PvP Practice: Practice Combos =====
		do
			local practiceEnabled = false
			local skills = {} -- ordered list of skill strings
			local stepIdx = 0
			local selectedIdx = nil

			-- Trigger arriba (igual que addToggle)
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, -10, 0, 20)
			row.BackgroundTransparency = 1
			row.LayoutOrder = 1
			row.Parent = pvpPage
			local lab = Instance.new("TextLabel")
			lab.Size = UDim2.new(1, -44, 1, 0)
			lab.Position = UDim2.new(0, 8, 0, 0)
			lab.BackgroundTransparency = 1
			lab.Text = tr("Practice Combos")
			registerLangLabel("Practice Combos", lab)
			lab.TextColor3 = Color3.fromRGB(25, 25, 25)
			lab.Font = Enum.Font.Gotham
			lab.TextSize = 11
			lab.TextXAlignment = Enum.TextXAlignment.Left
			lab.Parent = row
			local toggle = Instance.new("Frame")
			toggle.Size = UDim2.new(0, 26, 0, 11)
			toggle.Position = UDim2.new(1, -34, 0.5, -5.5)
			toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			toggle.BorderSizePixel = 0
			toggle.Parent = row
			Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
			local ball = Instance.new("Frame")
			ball.Size = UDim2.new(0, 7, 0, 7)
			ball.Position = UDim2.new(0, 2, 0.5, -3.5)
			ball.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
			ball.BorderSizePixel = 0
			ball.Parent = toggle
			Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)
			local state = false
			local function setVisual(on)
				state = on
				local TS = game:GetService("TweenService")
				if on then
					TS:Create(ball, TweenInfo.new(0.15), {
						Position = UDim2.new(0, 16, 0.5, -3.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					}):Play()
				else
					TS:Create(ball, TweenInfo.new(0.15), {
						Position = UDim2.new(0, 2, 0.5, -3.5),
						BackgroundColor3 = Color3.fromRGB(120, 120, 120),
					}):Play()
				end
			end
			_G.SupremacyPracticeSetVisual = setVisual

			-- Fila Skill: label + box + boton +
			local skillRow = Instance.new("Frame")
			skillRow.Size = UDim2.new(1, -10, 0, 22)
			skillRow.BackgroundTransparency = 1
			skillRow.LayoutOrder = 2
			skillRow.Parent = pvpPage
			local skillLab = Instance.new("TextLabel")
			skillLab.Size = UDim2.new(0, 36, 1, 0)
			skillLab.Position = UDim2.new(0, 8, 0, 0)
			skillLab.BackgroundTransparency = 1
			skillLab.Text = tr("Skill:")
			registerLangLabel("Skill:", skillLab)
			skillLab.TextColor3 = Color3.fromRGB(25, 25, 25)
			skillLab.Font = Enum.Font.Gotham
			skillLab.TextSize = 11
			skillLab.TextXAlignment = Enum.TextXAlignment.Left
			skillLab.Parent = skillRow
			local skillBox = Instance.new("TextBox")
			skillBox.Size = UDim2.new(1, -90, 0, 18)
			skillBox.Position = UDim2.new(0, 44, 0.5, -9)
			skillBox.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
			skillBox.BorderSizePixel = 0
			skillBox.Text = ""
			skillBox.PlaceholderText = tr("Introducir Habilidad")
			_G.SupremacySkillPlaceholder = skillBox
			skillBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
			skillBox.TextColor3 = Color3.fromRGB(20, 20, 20)
			skillBox.Font = Enum.Font.Gotham
			skillBox.TextSize = 11
			skillBox.ClearTextOnFocus = false
			skillBox.Parent = skillRow
			skillBox:GetPropertyChangedSignal("Text"):Connect(function()
				if #skillBox.Text > 30 then
					skillBox.Text = string.sub(skillBox.Text, 1, 30)
				end
			end)
			local addBtn = Instance.new("TextButton")
			addBtn.Size = UDim2.new(0, 22, 0, 18)
			addBtn.Position = UDim2.new(1, -28, 0.5, -9)
			addBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			addBtn.Text = "+"
			addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			addBtn.Font = Enum.Font.GothamBold
			addBtn.TextSize = 14
			addBtn.BorderSizePixel = 0
			addBtn.Parent = skillRow

			-- Lista de skills
			local listFrame = Instance.new("ScrollingFrame")
			listFrame.Size = UDim2.new(1, -10, 0, 110)
			listFrame.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
			listFrame.BorderSizePixel = 0
			listFrame.ScrollBarThickness = 3
			listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			listFrame.LayoutOrder = 3
			listFrame.Parent = pvpPage
			local listLay = Instance.new("UIListLayout", listFrame)
			listLay.Padding = UDim.new(0, 2)
			listLay.SortOrder = Enum.SortOrder.LayoutOrder
			local listPad = Instance.new("UIPadding", listFrame)
			listPad.PaddingTop = UDim.new(0, 3)
			listPad.PaddingBottom = UDim.new(0, 3)
			listPad.PaddingLeft = UDim.new(0, 3)
			listPad.PaddingRight = UDim.new(0, 3)

			local function refreshList()
				for _, ch in ipairs(listFrame:GetChildren()) do
					if ch:IsA("Frame") then ch:Destroy() end
				end
				for i, sk in ipairs(skills) do
					local item = Instance.new("Frame")
					item.Size = UDim2.new(1, -4, 0, 20)
					item.BackgroundColor3 = (selectedIdx == i) and Color3.fromRGB(210, 230, 255) or Color3.fromRGB(255, 255, 255)
					item.BorderSizePixel = 0
					item.LayoutOrder = i
					item.Parent = listFrame
					local num = Instance.new("TextLabel")
					num.Size = UDim2.new(0, 18, 1, 0)
					num.BackgroundTransparency = 1
					num.Text = tostring(i)
					num.TextColor3 = Color3.fromRGB(100, 100, 100)
					num.Font = Enum.Font.GothamBold
					num.TextSize = 10
					num.Parent = item
					local t = Instance.new("TextLabel")
					t.Size = UDim2.new(1, -78, 1, 0)
					t.Position = UDim2.new(0, 18, 0, 0)
					t.BackgroundTransparency = 1
					t.Text = sk
					t.TextColor3 = Color3.fromRGB(20, 20, 20)
					t.Font = Enum.Font.Gotham
					t.TextSize = 11
					t.TextXAlignment = Enum.TextXAlignment.Left
					t.TextTruncate = Enum.TextTruncate.AtEnd
					t.Parent = item
					local up = Instance.new("TextButton")
					up.Size = UDim2.new(0, 18, 0, 16)
					up.Position = UDim2.new(1, -58, 0.5, -8)
					up.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
					up.Text = "^"
					up.TextColor3 = Color3.fromRGB(40, 40, 40)
					up.Font = Enum.Font.GothamBold
					up.TextSize = 10
					up.BorderSizePixel = 0
					up.Parent = item
					local dn = Instance.new("TextButton")
					dn.Size = UDim2.new(0, 18, 0, 16)
					dn.Position = UDim2.new(1, -38, 0.5, -8)
					dn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
					dn.Text = "v"
					dn.TextColor3 = Color3.fromRGB(40, 40, 40)
					dn.Font = Enum.Font.GothamBold
					dn.TextSize = 10
					dn.BorderSizePixel = 0
					dn.Parent = item
					local del = Instance.new("TextButton")
					del.Size = UDim2.new(0, 18, 0, 16)
					del.Position = UDim2.new(1, -18, 0.5, -8)
					del.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
					del.Text = "x"
					del.TextColor3 = Color3.fromRGB(180, 40, 40)
					del.Font = Enum.Font.GothamBold
					del.TextSize = 11
					del.BorderSizePixel = 0
					del.Parent = item
					local hitItem = Instance.new("TextButton")
					hitItem.Size = UDim2.new(1, -60, 1, 0)
					hitItem.BackgroundTransparency = 1
					hitItem.Text = ""
					hitItem.ZIndex = 2
					hitItem.Parent = item
					hitItem.MouseButton1Click:Connect(function()
						selectedIdx = i
						refreshList()
					end)
					up.MouseButton1Click:Connect(function()
						if i > 1 then
							skills[i], skills[i - 1] = skills[i - 1], skills[i]
							if selectedIdx == i then selectedIdx = i - 1
							elseif selectedIdx == i - 1 then selectedIdx = i end
							refreshList()
						end
					end)
					dn.MouseButton1Click:Connect(function()
						if i < #skills then
							skills[i], skills[i + 1] = skills[i + 1], skills[i]
							if selectedIdx == i then selectedIdx = i + 1
							elseif selectedIdx == i + 1 then selectedIdx = i end
							refreshList()
						end
					end)
					del.MouseButton1Click:Connect(function()
						table.remove(skills, i)
						if selectedIdx == i then selectedIdx = nil
						elseif selectedIdx and selectedIdx > i then selectedIdx = selectedIdx - 1 end
						refreshList()
					end)
				end
			end

			addBtn.MouseButton1Click:Connect(function()
				local t = tostring(skillBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
				if t == "" then return end
				table.insert(skills, t)
				skillBox.Text = ""
				refreshList()
			end)

			local GREETS_ES = {
				"Hola, listo para ayudarte.",
				"Hey, aqui estoy.",
				"Que tal, coach activo.",
				"Hola de nuevo.",
				"Listo cuando tu lo estes.",
			}
			local GREETS_EN = {
				"Hi, ready to help you.",
				"Hey, I am here.",
				"Coach is active.",
				"Hello again.",
				"Ready when you are.",
			}
			local ASK_ES = {
				"Quieres practicar tu combo?",
				"Practicamos el combo ahora?",
				"Te guio con el combo, te late?",
				"Empezamos la practica del combo?",
				"Hacemos el combo paso a paso?",
			}
			local ASK_EN = {
				"Do you want to practice your combo?",
				"Shall we practice the combo now?",
				"I can guide your combo, ready?",
				"Start combo practice?",
				"Do the combo step by step?",
			}
			local EMPTY_ES = {
				"Para practicarlo agrega skills con el boton +.",
				"No hay skills. Anade habilidades arriba.",
				"Primero agrega skills a la lista.",
				"La lista esta vacia. Escribe una skill y pulsa +.",
			}
			local EMPTY_EN = {
				"Add skills with the + button to practice.",
				"No skills. Add abilities above.",
				"First add skills to the list.",
				"List is empty. Type a skill and press +.",
			}
			local function langList(es, en)
				return (_G.SupremacyLang == "Spanish") and es or en
			end
			local GREETS = GREETS_EN
			local ASK = ASK_EN
			local EMPTY = EMPTY_EN
			local STEP_FIRST = {
				"Empezamos con: %s",
				"Primer movimiento: %s",
				"Arranca con: %s",
				"Paso 1: %s",
			}
			local STEP_NEXT = {
				"Perfecto. Ahora el siguiente: %s",
				"Bien. Siguiente: %s",
				"Eso. Ahora: %s",
				"Correcto. Sigue con: %s",
				"Buen timing. Ahora: %s",
				"Va. Siguiente habilidad: %s",
				"Listo. Ahora toca: %s",
			}

			local function canCoach()
				return practiceEnabled and S and S.on
			end

			local function clearAlert()
				_G.SupremacyPracticeHold = false
				_G.SupremacyPracticeMode = nil
				_G.SupremacyPracticeOnNext = nil
				_G.SupremacyPracticeOnYes = nil
				_G.SupremacyPracticeOnNo = nil
				pcall(function()
					local pg = player:FindFirstChild("PlayerGui")
					local g = pg and pg:FindFirstChild("SupremacyAssistNotify")
					if g then for _, ch in pairs(g:GetChildren()) do ch:Destroy() end end
				end)
			end

			local function sayHold(msg, mode)
				if not canCoach() then clearAlert() return end
				_G.SupremacyPracticeHold = true
				_G.SupremacyPracticeMode = mode or "step"
				if _G.SupremacyNotifyStream then
					_G.SupremacyNotifyStream(msg)
				elseif notify then
					notify(msg)
				end
			end

			local END_MSGS = {
				"Combo completo. Bien hecho.",
				"Terminaste. Ahora ponlo en practica en PvP.",
				"Perfecto. Ya lo tienes memorizado.",
				"Listo. Sal y aplicalo en pelea real.",
				"Excelente practica. Repitelo cuando quieras.",
				"Muy bien. Confianza y timing, a pelear.",
				"Combo cerrado. Intentalo contra alguien.",
				"Buen trabajo. Ahora sin coach, hazlo solo.",
				"Finalizado. Lleva este combo al PvP.",
				"Hecho. Practica hace al maestro.",
			}
			local function showSkill()
				if not canCoach() then clearAlert() return end
				if stepIdx < 1 then stepIdx = 1 end
				if stepIdx > #skills then
					-- felicitacion final SIN botones, se quita sola
					_G.SupremacyPracticeHold = false
					_G.SupremacyPracticeMode = nil
					_G.SupremacyPracticeOnNext = nil
					local fin = END_MSGS[math.random(1, #END_MSGS)]
					if _G.SupremacyNotifyStream then
						_G.SupremacyNotifyStream(fin)
					elseif notify then
						notify(fin)
					end
					practiceEnabled = false
					setVisual(false)
					return
				end
				local skill = skills[stepIdx]
				local text
				if stepIdx == 1 then
					text = string.format(STEP_FIRST[math.random(1, #STEP_FIRST)], skill)
				else
					text = string.format(STEP_NEXT[math.random(1, #STEP_NEXT)], skill)
				end
				_G.SupremacyPracticeOnNext = function()
					if not canCoach() then clearAlert() return end
					stepIdx = stepIdx + 1
					showSkill()
				end
				sayHold(text, "step")
			end

			local function sayAuto(msg, afterCb)
				-- sin boton Next: desaparece cuando la voz termina
				if not canCoach() then clearAlert() return end
				_G.SupremacyPracticeHold = false
				_G.SupremacyPracticeMode = nil
				_G.SupremacyPracticeOnNext = nil
				_G.SupremacyPracticeOnYes = nil
				_G.SupremacyPracticeOnNo = nil
				if afterCb then
					_G.SupremacyOnNotifyDone = afterCb
				else
					_G.SupremacyOnNotifyDone = nil
				end
				if _G.SupremacyNotifyStream then
					_G.SupremacyNotifyStream(msg)
				elseif notify then
					notify(msg)
				end
			end

			local function askPractice()
				if not canCoach() then clearAlert() return end
				if #skills == 0 then
					-- lista vacia: solo aviso, SIN Next, se va al callar la voz
					sayAuto(langList(EMPTY_ES, EMPTY_EN)[math.random(1, #langList(EMPTY_ES, EMPTY_EN))], nil)
					return
				end
				_G.SupremacyPracticeOnYes = function()
					if not canCoach() then clearAlert() return end
					stepIdx = 1
					showSkill()
				end
				_G.SupremacyPracticeOnNo = function()
					clearAlert()
					practiceEnabled = false
					_G.SupremacyPracticeEnabled = false
					setVisual(false)
				end
				sayHold(langList(ASK_ES, ASK_EN)[math.random(1, #langList(ASK_ES, ASK_EN))], "ask")
			end

			local function beginFlow()
				if not canCoach() then clearAlert() return end
				if #skills == 0 then
					-- sin skills: mensaje y se va solo (sin Next)
					sayAuto(langList(EMPTY_ES, EMPTY_EN)[math.random(1, #langList(EMPTY_ES, EMPTY_EN))], nil)
					return
				end
				-- saludo de combo (sin Next); al callar la voz pregunta el combo
				local g = pickGreet()
				sayAuto(g, function()
					if canCoach() then askPractice() end
				end)
			end

			local function setPractice(on)
				practiceEnabled = on and true or false
				_G.SupremacyPracticeEnabled = practiceEnabled
				if not practiceEnabled then
					stepIdx = 0
					clearAlert()
					return
				end
				if not (S and S.on) then
					clearAlert()
					return
				end
				beginFlow()
			end

			local hit = Instance.new("TextButton")
			hit.Size = UDim2.new(1, 0, 1, 0)
			hit.BackgroundTransparency = 1
			hit.Text = ""
			hit.Parent = row
			hit.MouseButton1Click:Connect(function()
				setVisual(not state)
				setPractice(state)
			end)

			task.spawn(function()
				local lastOn = S.on
				while row and row.Parent do
					task.wait(0.35)
					_G.SupremacyPracticeEnabled = practiceEnabled
					if practiceEnabled and S.on and not lastOn then
						-- Practice ya ON + Assistant recien activado:
						-- esperar a que TERMINE el saludo, luego practice (sin otro saludo)
						local function startAfterGreet()
							if not (practiceEnabled and S and S.on) then return end
							-- ir directo a preguntar combo (el saludo del Assistant ya se hizo)
							if #skills == 0 then
								sayAuto(langList(EMPTY_ES, EMPTY_EN)[math.random(1, #langList(EMPTY_ES, EMPTY_EN))], nil)
							else
								askPractice()
							end
						end
						if _G.SupremacyGreetBusy then
							_G.SupremacyStartPracticeAfterGreet = startAfterGreet
						else
							task.defer(function()
								if practiceEnabled and S and S.on then
									if _G.SupremacyGreetBusy then
										_G.SupremacyStartPracticeAfterGreet = startAfterGreet
									else
										startAfterGreet()
									end
								end
							end)
						end
					elseif practiceEnabled and not S.on then
						clearAlert()
					end
					lastOn = S.on
				end
			end)
		end


		pcall(function()
			-- Orden fijo General: Enable, Voice, Sense Pred, Sense Sound, No Disappear
			local n = 0
			for _, ch in ipairs(general:GetChildren()) do
				if ch:IsA("Frame") or ch:IsA("TextButton") then
					n = n + 1
					if ch.Name == "VoiceAssistantRow" then
						ch.LayoutOrder = 50
					elseif ch.Name == "SenseSoundRow" then
						ch.LayoutOrder = 51
					else
						ch.LayoutOrder = n
					end
					ch.Visible = true
				end
			end
			for _, ch in ipairs(combat:GetChildren()) do
				if ch.Name == "ObservePlayerRow" then
					ch.LayoutOrder = 10
					ch.Visible = true
				end
			end
		end)

		selectTab("General")
	end

	_G.SupremacyOpenAssistant = openAssistant
end)()



CreateToggleSlider(ConfigPage, "Button Opacity", 0, 100, 0, function(v)
	ButtonOpacityEnabled = v
	applyAllButtonOpacity()
end, function(v)
	ButtonOpacity = v
	applyAllButtonOpacity()
end)
CreateToggle(ConfigPage, "Menu Button", false, function(v)
	MenuButtonOpacityEnabled = v
	applyAllButtonOpacity()
end)

-- Click Sound
;(function()
	local clickSoundRow = Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 200,
		Parent = ConfigPage
	})
	do
		local _lbl = Create("TextLabel", {
			Size = UDim2.new(1, -50, 1, 0),
			BackgroundTransparency = 1,
			Text = "Click Sound",
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = TEXT_LABEL,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 201,
			Parent = clickSoundRow
		})
		registerLangLabel("Click Sound", _lbl)
	end
	local clickSoundLabel = Create("TextButton", {
		Size = UDim2.new(0, 52, 0, 14),
		Position = UDim2.new(1, -58, 0.5, -7),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0,
		Text = ClickSoundName,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		ZIndex = 202,
		Parent = clickSoundRow
	})
	clickSoundDropdown = Create("ScrollingFrame", {
		Size = UDim2.new(0, 52, 0, 0),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BorderSizePixel = 0,
		Visible = false,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		ZIndex = 60,
		Parent = Main
	})
	Create("UIListLayout", { Padding = UDim.new(0, 2), Parent = clickSoundDropdown })
	local CLICK_SEL = Color3.fromRGB(200, 200, 200)
	local CLICK_NORM = Color3.fromRGB(40, 40, 40)
	local clickSoundBtns = {}
	for _, s in ipairs(CLICK_SOUNDS) do
		local b = Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundColor3 = (ClickSoundName == s.name) and CLICK_SEL or CLICK_NORM,
			Text = s.name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 10,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 61,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Parent = clickSoundDropdown
		})
		b.MouseButton1Click:Connect(function()
			ClickSoundName = s.name
			ClickSoundId = s.id
			ClickSoundSpeed = s.speed or 1
			ClickSoundVol = s.vol or 3.5
			clickSoundLabel.Text = s.name
			for _, info in ipairs(CLICK_SOUNDS) do
				if clickSoundBtns[info.name] then
					clickSoundBtns[info.name].BackgroundColor3 = (info.name == s.name) and CLICK_SEL or CLICK_NORM
				end
			end
			if s.name ~= "None" then playClickSound() end
			clickSoundDropdownOpen = false
			clickSoundDropdown.Visible = false
		end)
		clickSoundBtns[s.name] = b
	end
	_G.SupremacyRefreshClickSound = function()
		pcall(function()
			if clickSoundLabel then clickSoundLabel.Text = ClickSoundName or "None" end
			for _, info in ipairs(CLICK_SOUNDS) do
				if clickSoundBtns[info.name] then
					clickSoundBtns[info.name].BackgroundColor3 =
						(info.name == ClickSoundName) and CLICK_SEL or CLICK_NORM
				end
			end
		end)
	end
	local function toggleClickSoundDropdown()
		if ClickSoundName ~= "None" then playClickSound() end
		clickSoundDropdownOpen = not clickSoundDropdownOpen
		if clickSoundDropdownOpen then
			partDropdownOpen = false
			if partDropdown then partDropdown.Visible = false end
			dropdownShouldBeOpen = false
			if dropdownFrame then dropdownFrame.Visible = false end
			pcall(function()
				if _G.SupremacyChOpen ~= nil then _G.SupremacyChOpen = false end
				for _, ch in pairs(Main:GetChildren()) do
					if ch:IsA("ScrollingFrame") and ch ~= Content and ch ~= partDropdown and ch ~= dropdownFrame and ch ~= clickSoundDropdown then
						ch.Visible = false
					end
				end
			end)
			local absPos = clickSoundLabel.AbsolutePosition
			local absSize = clickSoundLabel.AbsoluteSize
			local mainAbs = Main.AbsolutePosition
			local h = #CLICK_SOUNDS * 22
			local mainSize = Main.AbsoluteSize
			-- abrir HACIA ABAJO
			local y = absPos.Y - mainAbs.Y + absSize.Y + 2
			if y + h > mainSize.Y - 6 then
				y = math.max(4, mainSize.Y - h - 6)
			end
			clickSoundDropdown.Size = UDim2.new(0, math.max(math.floor(absSize.X), 52), 0, h)
			clickSoundDropdown.Position = UDim2.new(0, absPos.X - mainAbs.X, 0, y)
			clickSoundDropdown.ClipsDescendants = true
			clickSoundDropdown.ZIndex = 80
			clickSoundDropdown.Visible = true
			_G.SupremacyDropIgnoreUntil = tick() + 0.25
		else
			clickSoundDropdown.Visible = false
		end
	end
	clickSoundRow.MouseButton1Click:Connect(toggleClickSoundDropdown)
	clickSoundLabel.MouseButton1Click:Connect(toggleClickSoundDropdown)
end)()




-- Crosshair
;(function()
	local CrosshairMode = "None"
	local function stopCrosshair()
		pcall(function()
			local function nuke(parent)
				if not parent then return end
				local g = parent:FindFirstChild("CustomCrosshair")
				if g then g:Destroy() end
			end
			nuke(player:FindFirstChild("PlayerGui"))
			nuke(CoreGui)
			pcall(function() if gethui then nuke(gethui()) end end)
		end)
	end

	local CAT_CURSOR_SRC = [=[
local player = game:GetService("Players").LocalPlayer
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local IMAGE_ID = "IMAGE_ID_PLACEHOLDER"
local CROSS_SIZE = CROSS_SIZE_PLACEHOLDER

local function parentGui(gui)
	pcall(function()
		if gethui then gui.Parent = gethui()
		elseif syn and syn.protect_gui then syn.protect_gui(gui) gui.Parent = CoreGui
		else gui.Parent = CoreGui end
	end)
	if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end
end

local gui = Instance.new("ScreenGui")
gui.Name = "CustomCrosshair"
gui.ResetOnSpawn = false
gui.DisplayOrder = 40
parentGui(gui)

local img = Instance.new("ImageLabel")
img.Name = "Crosshair"
img.Parent = gui
img.Size = UDim2.new(0,CROSS_SIZE,0,CROSS_SIZE)
img.BackgroundTransparency = 1
img.Position = UDim2.new(0.5, -math.floor(CROSS_SIZE/2), 0.34, -math.floor(CROSS_SIZE/2))
img.Visible = true
img.ZIndex = 10

local staticImg = Instance.new("ImageLabel")
staticImg.Name = "StaticCrosshair"
staticImg.Parent = gui
staticImg.Size = UDim2.new(0,CROSS_SIZE,0,CROSS_SIZE)
staticImg.BackgroundTransparency = 1
staticImg.Position = UDim2.new(0.5, -math.floor(CROSS_SIZE/2), 0.34, -math.floor(CROSS_SIZE/2))
staticImg.Visible = false
staticImg.ZIndex = 10

local function applyImage(idNum)
	local formats = {
		"rbxassetid://" .. idNum,
		"http://www.roblox.com/asset/?id=" .. idNum,
		"rbxthumb://type=Asset&id=" .. idNum .. "&w=150&h=150",
	}
	for _, url in ipairs(formats) do
		img.Image = url
		staticImg.Image = url
		task.wait(0.15)
		if img.IsLoaded or (img.Image ~= "" and not string.find(img.Image, "nil")) then
			return url
		end
	end
	img.Image = formats[1]
	staticImg.Image = formats[1]
	return formats[1]
end

task.spawn(function()
	local list = {}
	for id in string.gmatch(IMAGE_ID, "[%d]+") do
		table.insert(list, id)
	end
	if #list == 0 then list = {IMAGE_ID} end
	for _, idNum in ipairs(list) do
		local used = applyImage(idNum)
		task.wait(0.2)
		if img.IsLoaded then
			break
		end
	end
end)

local activeTouchInput = nil

local function checkAndClampPosition(inputX, inputY)
	local screenWidth = gui.AbsoluteSize.X
	local screenHeight = gui.AbsoluteSize.Y
	local minX = screenWidth * 0.22
	local maxX = screenWidth * 0.755
	local minY = screenHeight * 0.00
	local maxY = screenHeight * 0.76
	local isInside = (inputX >= minX and inputX <= maxX and inputY >= minY and inputY <= maxY)
	local half = math.floor(CROSS_SIZE / 2)
	local clampedX = math.clamp(inputX - half, minX - half, maxX - half)
	local clampedY = math.clamp(inputY - half, minY - half, maxY - half)
	return isInside, UDim2.new(0, clampedX, 0, clampedY)
end

local function isCandadoVerde()
	local touchGui = player.PlayerGui:FindFirstChild("TouchGui")
	local controlFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
	local shiftLockControl = controlFrame and (controlFrame:FindFirstChild("ShiftLockControl") or controlFrame:FindFirstChild("Shiftlock"))
	if shiftLockControl and shiftLockControl:FindFirstChild("ShiftLockIcon") then
		local icon = shiftLockControl.ShiftLockIcon
		if icon.ImageColor3.G > 0.7 and icon.ImageColor3.B < 0.6 and icon.ImageColor3.R < 0.6 then
			return true
		end
	end
	return userInputService.MouseBehavior == Enum.MouseBehavior.LockCenter and not userInputService.TouchEnabled
end

task.spawn(function()
	while gui and gui.Parent do
		task.wait(0.05)
		if isCandadoVerde() then
			pcall(function()
				for _, v in pairs(player.PlayerGui:GetDescendants()) do
					if v:IsA("ImageLabel") and v ~= staticImg and v ~= img and v.Name ~= "Crosshair" and v.Name ~= "StaticCrosshair" then
						local s = v.AbsoluteSize
						if s.X <= 20 and s.Y <= 20 then v.Visible = false end
					end
				end
			end)
		end
	end
end)

runService.RenderStepped:Connect(function()
	if not gui or not gui.Parent then return end
	if isCandadoVerde() then
		if img.Visible then img.Visible = false staticImg.Visible = true activeTouchInput = nil end
	else
		if not img.Visible then staticImg.Visible = false img.Visible = true end
	end
end)

userInputService.InputBegan:Connect(function(input)
	if isCandadoVerde() then return end
	if input.UserInputType == Enum.UserInputType.Touch then
		if activeTouchInput ~= nil then return end
		local isInside, targetPosition = checkAndClampPosition(input.Position.X, input.Position.Y)
		if isInside then
			activeTouchInput = input
			img:TweenPosition(targetPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
		end
	end
end)

userInputService.InputChanged:Connect(function(input)
	if isCandadoVerde() then return end
	if input.UserInputType == Enum.UserInputType.Touch and activeTouchInput == input then
		local _, targetPosition = checkAndClampPosition(input.Position.X, input.Position.Y)
		img:TweenPosition(targetPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.08, true)
	end
end)

userInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch and activeTouchInput == input then
		activeTouchInput = nil
	end
end)
]=]


	local CROSSHAIR_IMAGES = {
		["Crosshair 1"] = { ids = {"87816747676597"}, size = 16 },
		["Crosshair 2"] = { ids = {"108983828639730"}, size = 28 },
		["Crosshair 3"] = { ids = {"138873986192679", "129086650956053"}, size = 18 },
		["Crosshair 4"] = { ids = {"122656194352893", "140072734009082"}, size = 18 },
	}

	local function setCrosshairMode(mode)
		CrosshairMode = mode or "None"
		stopCrosshair()
		local info = CROSSHAIR_IMAGES[CrosshairMode]
		if info then
			local idStr = table.concat(info.ids, ",")
			local src = string.gsub(CAT_CURSOR_SRC, "IMAGE_ID_PLACEHOLDER", idStr, 1)
			src = string.gsub(src, "CROSS_SIZE_PLACEHOLDER", tostring(info.size), 1)
			local fn, err = loadstring(src)
			if fn then
				local ok, e = pcall(fn)
				if not ok then warn("[Supremacy] Crosshair:", e) end
			else
				warn("[Supremacy] Crosshair load:", err)
			end
		end
	end

	local chRow = Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 200,
		Parent = ConfigPage
	})
	do
		local _lbl = Create("TextLabel", {
			Size = UDim2.new(1, -50, 1, 0),
			BackgroundTransparency = 1,
			Text = "Crosshair",
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = TEXT_LABEL,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 201,
			Parent = chRow
		})
		registerLangLabel("Crosshair", _lbl)
	end
	local chLabel = Create("TextButton", {
		Size = UDim2.new(0, 52, 0, 14),
		Position = UDim2.new(1, -58, 0.5, -7),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0,
		Text = "None",
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		ZIndex = 202,
		Parent = chRow
	})
	local chDropdown = Create("ScrollingFrame", {
		Size = UDim2.new(0, 52, 0, 0),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BorderSizePixel = 0,
		Visible = false,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		ZIndex = 60,
		Parent = Main
	})
	Create("UIListLayout", { Padding = UDim.new(0, 2), Parent = chDropdown })

	local chOpen = false
	local function makeOpt(name)
		local b = Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundColor3 = (name == "None") and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(40, 40, 40),
			Text = name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 9,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextScaled = false,
			ZIndex = 61,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Parent = chDropdown
		})
		b.MouseButton1Click:Connect(function()
			chLabel.Text = name
			for _, c in ipairs(chDropdown:GetChildren()) do
				if c:IsA("TextButton") then
					c.BackgroundColor3 = (c.Text == name) and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(40, 40, 40)
				end
			end
			chOpen = false
			_G.SupremacyChOpen = false
			chDropdown.Visible = false
			setCrosshairMode(name)
		end)
	end
	makeOpt("None")
	makeOpt("Crosshair 1")
	makeOpt("Crosshair 2")
	makeOpt("Crosshair 3")
	makeOpt("Crosshair 4")

	local function toggleCh()
		chOpen = not chOpen
		_G.SupremacyChOpen = chOpen
		_G.SupremacyChDropdown = chDropdown
		if chOpen then
			partDropdownOpen = false
			if partDropdown then partDropdown.Visible = false end
			dropdownShouldBeOpen = false
			if dropdownFrame then dropdownFrame.Visible = false end
			clickSoundDropdownOpen = false
			if clickSoundDropdown then clickSoundDropdown.Visible = false end
			local absPos = chLabel.AbsolutePosition
			local absSize = chLabel.AbsoluteSize
			local mainAbs = Main.AbsolutePosition
			local h = 5 * 22
			local mainSize = Main.AbsoluteSize
			-- abrir HACIA ABAJO
			local y = absPos.Y - mainAbs.Y + absSize.Y + 2
			if y + h > mainSize.Y - 6 then
				y = math.max(4, mainSize.Y - h - 6)
			end
			chDropdown.Size = UDim2.new(0, math.max(math.floor(absSize.X), 52), 0, h)
			chDropdown.Position = UDim2.new(0, absPos.X - mainAbs.X, 0, y)
			chDropdown.ClipsDescendants = true
			chDropdown.ZIndex = 80
			chDropdown.Visible = true
			_G.SupremacyDropIgnoreUntil = tick() + 0.25
		else
			chDropdown.Visible = false
		end
	end
	chRow.MouseButton1Click:Connect(toggleCh)
	chLabel.MouseButton1Click:Connect(toggleCh)

	_G.SupremacyCrosshairMode = function() return CrosshairMode end
	_G.SupremacySetCrosshairMode = function(m)
		local mode = "None"
		if CROSSHAIR_IMAGES[m] then
			mode = m
		end
		chLabel.Text = mode
		for _, c in ipairs(chDropdown:GetChildren()) do
			if c:IsA("TextButton") then
				c.BackgroundColor3 = (c.Text == mode) and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(40, 40, 40)
			end
		end
		setCrosshairMode(mode)
	end
end)()

-- Assistant row (debajo de TODAS las opciones de Config)
do
	local asRow = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		ZIndex = 200,
		Parent = ConfigPage
	})
	do
		local _lbl = Create("TextLabel", {
			Size = UDim2.new(1, -62, 1, 0),
			BackgroundTransparency = 1,
			Text = "Assistant",
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = TEXT_LABEL,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 201,
			Parent = asRow
		})
		registerLangLabel("Assistant", _lbl)
	end
	local asOpen = Create("TextButton", {
		Size = UDim2.new(0, 52, 0, 14),
		Position = UDim2.new(1, -58, 0.5, -7),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0,
		Text = "Open",
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		ZIndex = 202,
		Parent = asRow
	})
	registerLangLabel("Open", asOpen)

	asOpen.MouseButton1Click:Connect(function()
		if _G.SupremacyOpenAssistant then
			_G.SupremacyOpenAssistant()
		end
	end)
end

-- Camera Zoom (debajo de Assistant)
CreateToggleSlider(ConfigPage, "Camera Zoom", 0, 100, 0, function(on)
	_G.SupremacyCameraZoomOn = on and true or false
	if _G.SupremacyCameraZoomApply then
		_G.SupremacyCameraZoomApply(on)
	end
end, function(v)
	_G.SupremacyCameraZoomVal = tonumber(v) or 0
	if _G.SupremacyCameraZoomValue then
		_G.SupremacyCameraZoomValue(v)
	end
end, false)

-- Config bottom: Slots Mini + Pc Format + Hide Skills
CreateToggle(ConfigPage, "Pc Format", false, function(v)
	_G.SupremacyPcFormatOn = v and true or false
	if _G.SupremacyGuiMiniApply then
		_G.SupremacyGuiMiniApply(v)
	end
end)

-- Hide Skills: SOLO los 6 botones derecha (Ken/Armadura/V3/Walk/Dash/Paso)
;(function()
	local hideOn = false
	local saved = {}
	local conn = nil

	local function isOurs(obj)
		local p = obj
		while p do
			if string.find(string.lower(tostring(p.Name or "")), "supremacy", 1, true) then
				return true
			end
			p = p.Parent
		end
		return false
	end

	local function hideVisual(obj)
		if not obj or saved[obj] then return end
		local data = {}
		pcall(function()
			if obj:IsA("GuiObject") then
				data.bg = obj.BackgroundTransparency
				obj.BackgroundTransparency = 1
			end
			if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
				data.img = obj.ImageTransparency
				obj.ImageTransparency = 1
			end
			if obj:IsA("TextLabel") or obj:IsA("TextButton") then
				data.text = obj.TextTransparency
				obj.TextTransparency = 1
			end
			if obj:IsA("GuiButton") then
				obj.Active = true
				obj.AutoButtonColor = false
			end
			for _, ch in ipairs(obj:GetDescendants()) do
				if not saved[ch] then
					if ch:IsA("UIStroke") then
						saved[ch] = { stroke = ch.Transparency }
						ch.Transparency = 1
					elseif ch:IsA("GuiObject") then
						local d2 = { bg = ch.BackgroundTransparency }
						ch.BackgroundTransparency = 1
						if ch:IsA("ImageLabel") or ch:IsA("ImageButton") then
							d2.img = ch.ImageTransparency
							ch.ImageTransparency = 1
						end
						if ch:IsA("TextLabel") or ch:IsA("TextButton") then
							d2.text = ch.TextTransparency
							ch.TextTransparency = 1
						end
						if ch:IsA("GuiButton") then ch.Active = true end
						saved[ch] = d2
					end
				end
			end
		end)
		saved[obj] = data
	end

	local function restoreAll()
		for obj, data in pairs(saved) do
			pcall(function()
				if not obj or not obj.Parent or not data then return end
				if data.bg ~= nil and obj:IsA("GuiObject") then
					obj.BackgroundTransparency = data.bg
				end
				if data.img ~= nil then obj.ImageTransparency = data.img end
				if data.text ~= nil then obj.TextTransparency = data.text end
				if data.stroke ~= nil and obj:IsA("UIStroke") then
					obj.Transparency = data.stroke
				end
			end)
		end
		table.clear(saved)
	end

	local function isGunCursorUI(obj)
		-- no tocar crosshair / cursor de guns / aim reticle
		local p = obj
		local hops = 0
		while p and hops < 8 do
			local n = string.lower(tostring(p.Name or ""))
			if n:find("cursor", 1, true) or n:find("crosshair", 1, true) or n:find("reticle", 1, true)
				or n:find("cross", 1, true) or n:find("aimicon", 1, true) or n:find("gunaim", 1, true)
				or n:find("mouse", 1, true) or n:find("targeticon", 1, true) then
				return true
			end
			p = p.Parent
			hops = hops + 1
		end
		return false
	end

	local function scanAndHide()
		if not hideOn then return end
		local pg = player:FindFirstChild("PlayerGui")
		if not pg then return end
		local cam = workspace.CurrentCamera
		local vw = (cam and cam.ViewportSize.X) or 800
		local vh = (cam and cam.ViewportSize.Y) or 600
		local candidates = {}

		for _, gui in ipairs(pg:GetChildren()) do
			if gui:IsA("ScreenGui") and not isOurs(gui) then
				local gname = string.lower(tostring(gui.Name or ""))
				-- touch + posibles GUIs de arma/cursor
				if not gname:find("touch", 1, true) and not gname:find("cursor", 1, true)
					and not gname:find("crosshair", 1, true) then
					for _, d in ipairs(gui:GetDescendants()) do
						if (not isOurs(d)) and (d:IsA("ImageButton") or d:IsA("ImageLabel") or d:IsA("TextButton")) then
							if isGunCursorUI(d) then
								-- skip cursor guns
							else
								local ap, asz = d.AbsolutePosition, d.AbsoluteSize
								-- solo botones de skill tipicos (cuadrados medianos)
								if asz.X >= 32 and asz.Y >= 32 and asz.X <= 88 and asz.Y <= 88 then
									local cx = ap.X + asz.X * 0.5
									local cy = ap.Y + asz.Y * 0.5
									-- MUY a la derecha (skills Ken/Armadura/V3/Walk/Dash/Paso)
									-- NUNCA centro ni zona de crosshair de guns
									if cx >= vw * 0.82 and cy >= vh * 0.08 and cy <= vh * 0.58 then
										if math.abs(cx - vw * 0.5) > vw * 0.28 then
											table.insert(candidates, d)
										end
									end
								end
							end
						end
					end
				end
			end
		end

		for _, c in ipairs(candidates) do
			hideVisual(c)
		end
	end

	local function applyHideSkills(v)
		hideOn = v and true or false
		_G.SupremacyHideSkillsOn = hideOn
		if conn then pcall(function() conn:Disconnect() end) conn = nil end
		if hideOn then
			scanAndHide()
			task.delay(0.5, function() if hideOn then pcall(scanAndHide) end end)
			task.delay(2.0, function() if hideOn then pcall(scanAndHide) end end)
			conn = nil
		else
			restoreAll()
		end
	end
	_G.SupremacyApplyHideSkills = applyHideSkills
	CreateToggle(ConfigPage, "Hide Skills", false, applyHideSkills)
end)()

-- Hide Use: oculta botones "Use", siguen clickeables, CD/mastery visible
;(function()
	local hideOn = false
	local saved = {}
	local conn = nil

	local function isOurs(obj)
		local p = obj
		while p do
			if string.find(string.lower(tostring(p.Name or "")), "supremacy", 1, true) then
				return true
			end
			p = p.Parent
		end
		return false
	end

	local function isUseButton(obj)
		if not (obj:IsA("TextButton") or obj:IsA("TextLabel") or obj:IsA("ImageButton")) then
			return false
		end
		local ok = false
		pcall(function()
			if obj:IsA("TextButton") or obj:IsA("TextLabel") then
				local t = string.lower(string.gsub(tostring(obj.Text or ""), "%s+", ""))
				if t == "use" then ok = true return end
			end
			for _, ch in ipairs(obj:GetDescendants()) do
				if ch:IsA("TextLabel") or ch:IsA("TextButton") then
					local t = string.lower(string.gsub(tostring(ch.Text or ""), "%s+", ""))
					if t == "use" then ok = true return end
				end
			end
		end)
		return ok
	end

	local function hideUseObj(obj)
		if not obj or saved[obj] then return end
		local data = {}
		pcall(function()
			if obj:IsA("GuiObject") then
				data.bg = obj.BackgroundTransparency
				obj.BackgroundTransparency = 1
			end
			if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
				data.img = obj.ImageTransparency
				obj.ImageTransparency = 1
			end
			if obj:IsA("TextLabel") or obj:IsA("TextButton") then
				data.text = obj.TextTransparency
				obj.TextTransparency = 1
			end
			if obj:IsA("GuiButton") then
				obj.Active = true
				obj.AutoButtonColor = false
			end
			for _, ch in ipairs(obj:GetDescendants()) do
				if ch:IsA("UIStroke") and not saved[ch] then
					saved[ch] = { stroke = ch.Transparency }
					ch.Transparency = 1
				elseif ch:IsA("GuiObject") and not saved[ch] then
					local d2 = { bg = ch.BackgroundTransparency }
					ch.BackgroundTransparency = 1
					if ch:IsA("ImageLabel") or ch:IsA("ImageButton") then
						d2.img = ch.ImageTransparency
						ch.ImageTransparency = 1
					end
					if ch:IsA("TextLabel") or ch:IsA("TextButton") then
						local t = string.lower(string.gsub(tostring(ch.Text or ""), "%s+", ""))
						if t == "use" or t == "" then
							d2.text = ch.TextTransparency
							ch.TextTransparency = 1
						end
					end
					if ch:IsA("GuiButton") then ch.Active = true end
					saved[ch] = d2
				end
			end
		end)
		saved[obj] = data
	end

	local function restoreAll()
		for obj, data in pairs(saved) do
			pcall(function()
				if not obj or not obj.Parent or not data then return end
				if data.bg ~= nil and obj:IsA("GuiObject") then
					obj.BackgroundTransparency = data.bg
				end
				if data.img ~= nil then obj.ImageTransparency = data.img end
				if data.text ~= nil then obj.TextTransparency = data.text end
				if data.stroke ~= nil and obj:IsA("UIStroke") then
					obj.Transparency = data.stroke
				end
			end)
		end
		table.clear(saved)
	end

	local function scan()
		if not hideOn then return end
		local pg = player:FindFirstChild("PlayerGui")
		if not pg then return end
		for _, gui in ipairs(pg:GetChildren()) do
			if gui:IsA("ScreenGui") and not isOurs(gui) then
				for _, d in ipairs(gui:GetDescendants()) do
					if not isOurs(d) and isUseButton(d) then
						hideUseObj(d)
					end
				end
			end
		end
	end

	local function applyHideUse(v)
		hideOn = v and true or false
		_G.SupremacyHideUseOn = hideOn
		if conn then pcall(function() conn:Disconnect() end) conn = nil end
		if hideOn then
			scan()
			task.delay(0.4, function() if hideOn then pcall(scan) end end)
			task.delay(1.5, function() if hideOn then pcall(scan) end end)
			conn = nil
		else
			restoreAll()
		end
	end
	_G.SupremacyApplyHideUse = applyHideUse
	CreateToggle(ConfigPage, "Hide Use", false, applyHideUse)
end)()


-- Slots Mini (abajo de todo en Config)
CreateToggleSlider(ConfigPage, "Slots Mini", 0, 100, 0, function(on)
	_G.SupremacySlotsMiniOn = on and true or false
	pcall(function()
		if _G.SupremacySlotsMiniApply then
			_G.SupremacySlotsMiniApply(_G.SupremacySlotsMiniOn)
		end
	end)
end, function(v)
	_G.SupremacySlotsMiniScale = tonumber(v) or 0
	pcall(function()
		if _G.SupremacySlotsMiniSetScale then
			_G.SupremacySlotsMiniSetScale(_G.SupremacySlotsMiniScale)
		end
	end)
end)


-- Hide Gun Cursor: mira de arma + Reloading (centro), no toca skills derecha
;(function()
	local hideOn = false
	local saved = {}
	local conn = nil

	local function isOurs(obj)
		local p = obj
		while p do
			if string.find(string.lower(tostring(p.Name or "")), "supremacy", 1, true) then
				return true
			end
			p = p.Parent
		end
		return false
	end

	local function hideVisual(obj)
		if not obj or saved[obj] then return end
		-- no tocar botones Use
		local block = false
		pcall(function()
			if obj:IsA("TextLabel") or obj:IsA("TextButton") then
				if string.gsub(string.lower(tostring(obj.Text or "")), "%s+", "") == "use" then
					block = true
				end
			end
			for _, ch in ipairs(obj:GetDescendants()) do
				if ch:IsA("TextLabel") or ch:IsA("TextButton") then
					if string.gsub(string.lower(tostring(ch.Text or "")), "%s+", "") == "use" then
						block = true
					end
				end
			end
		end)
		if block then return end
		local data = {}
		pcall(function()
			if obj:IsA("GuiObject") then
				data.bg = obj.BackgroundTransparency
				obj.BackgroundTransparency = 1
			end
			if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
				data.img = obj.ImageTransparency
				obj.ImageTransparency = 1
			end
			if obj:IsA("TextLabel") or obj:IsA("TextButton") then
				data.text = obj.TextTransparency
				obj.TextTransparency = 1
			end
			if obj:IsA("UIStroke") then
				data.stroke = obj.Transparency
				obj.Transparency = 1
			end
			for _, ch in ipairs(obj:GetDescendants()) do
				if not saved[ch] then
					if ch:IsA("UIStroke") then
						saved[ch] = { stroke = ch.Transparency }
						ch.Transparency = 1
					elseif ch:IsA("GuiObject") then
						local d2 = { bg = ch.BackgroundTransparency }
						ch.BackgroundTransparency = 1
						if ch:IsA("ImageLabel") or ch:IsA("ImageButton") then
							d2.img = ch.ImageTransparency
							ch.ImageTransparency = 1
						end
						if ch:IsA("TextLabel") or ch:IsA("TextButton") then
							local compact = string.gsub(string.lower(tostring(ch.Text or "")), "%s+", "")
							if compact ~= "use" then
								d2.text = ch.TextTransparency
								ch.TextTransparency = 1
							end
						end
						saved[ch] = d2
					end
				end
			end
		end)
		saved[obj] = data
	end

	local function restoreAll()
		for obj, data in pairs(saved) do
			pcall(function()
				if not obj or not obj.Parent or not data then return end
				if data.bg ~= nil and obj:IsA("GuiObject") then
					obj.BackgroundTransparency = data.bg
				end
				if data.img ~= nil then obj.ImageTransparency = data.img end
				if data.text ~= nil then obj.TextTransparency = data.text end
				if data.stroke ~= nil and obj:IsA("UIStroke") then
					obj.Transparency = data.stroke
				end
			end)
		end
		table.clear(saved)
	end

	local function looksLikeGunUI(obj)
		-- nunca inventario / hotbar
		local p = obj
		for _ = 1, 6 do
			if not p then break end
			local pn = string.lower(tostring(p.Name or ""))
			if pn:find("invent", 1, true) or pn:find("backpack", 1, true)
				or pn:find("hotbar", 1, true) or pn:find("toolbar", 1, true)
				or pn:find("toolframe", 1, true) then
				return false
			end
			p = p.Parent
		end
		local n = string.lower(tostring(obj.Name or ""))
		if n:find("cursor", 1, true) or n:find("cross", 1, true) or n:find("reticle", 1, true) then
			return true
		end
		if n:find("reload", 1, true) or n:find("aimdot", 1, true) or n:find("crosshair", 1, true) then
			return true
		end
		if n:find("sight", 1, true) or n:find("scope", 1, true) or n:find("muzzle", 1, true) then
			return true
		end
		-- "gun" solo si parece mira (nombre corto / cursor)
		if n:find("guncursor", 1, true) or n:find("gunaim", 1, true) or n == "gun" then
			return true
		end
		return false
	end

	local function scan()
		if not hideOn then return end
		local pg = player:FindFirstChild("PlayerGui")
		if not pg then return end
		local cam = workspace.CurrentCamera
		local vw = (cam and cam.ViewportSize.X) or 800
		local vh = (cam and cam.ViewportSize.Y) or 600

		local function walk(root)
			for _, d in ipairs(root:GetDescendants()) do
				if isOurs(d) then
					-- skip
				elseif d:IsA("TextLabel") or d:IsA("TextButton") then
					local t = string.lower(tostring(d.Text or ""))
					local compact = string.gsub(t, "%s+", "")
					if compact == "use" then
						-- NUNCA tocar Use
					elseif t:find("reload", 1, true) then
						hideVisual(d)
					end
				elseif d:IsA("GuiObject") then
					if looksLikeGunUI(d) then
						hideVisual(d)
					end
				end
			end
		end

		for _, gui in ipairs(pg:GetChildren()) do
			if (gui:IsA("ScreenGui") or gui:IsA("BillboardGui")) and not isOurs(gui) then
				walk(gui)
			end
		end
		-- a veces el cursor esta en CoreGui
		pcall(function()
			local cg = game:GetService("CoreGui")
			for _, gui in ipairs(cg:GetChildren()) do
				if gui:IsA("ScreenGui") and not isOurs(gui) then
					local n = string.lower(tostring(gui.Name or ""))
					if n:find("cursor") or n:find("cross") or n:find("gun") or n:find("aim") or n:find("reload") then
						walk(gui)
					end
				end
			end
		end)
	end

	local function applyHideGunCursor(v)
		hideOn = v and true or false
		_G.SupremacyHideGunCursorOn = hideOn
		if conn then pcall(function() conn:Disconnect() end) conn = nil end
		if hideOn then
			scan()
			task.delay(0.3, function() if hideOn then pcall(scan) end end)
			task.delay(1.2, function() if hideOn then pcall(scan) end end)
			conn = nil
		else
			restoreAll()
		end
	end
	_G.SupremacyApplyHideGunCursor = applyHideGunCursor
	CreateToggle(ConfigPage, "Hide Gun Cursor", false, applyHideGunCursor)
end)()




UserInputService.InputBegan:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and ClickSoundName ~= "None" then
		playClickSound()
	end
end)

-- Drag del menu = mismo sistema que OpenBtn (sin bloquear camara ni controles)
local draggingUI, dragMoved, dragStartUI, startPosUI, dragInputUI = false, false, nil, nil, nil
pcall(function() Header.Active = true end)

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingUI = true
		dragMoved = false
		dragStartUI = input.Position
		startPosUI = Main.Position
	end
end)

Header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInputUI = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingUI and input == dragInputUI then
		local delta = input.Position - dragStartUI
		if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
			dragMoved = true
		end
		Main.Position = UDim2.new(
			startPosUI.X.Scale,
			startPosUI.X.Offset + delta.X,
			startPosUI.Y.Scale,
			startPosUI.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingUI = false
	end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightShift then Main.Visible = not Main.Visible end
end)

RunService.Heartbeat:Connect(function()
	if FreezeContainer then
		FreezeContainer.Visible = FreezeEnabled
	end
	if SuperJumpContainer then
		SuperJumpContainer.Visible = SuperJumpEnabled
	end
end)

-- Infinite Jump (solo al presionar; salto un poco más alto)
UserInputService.JumpRequest:Connect(function()
	if not InfiniteJumpEnabled then return end
	local now = tick()
	if now - lastInfiniteJump < 0.25 then return end
	lastInfiniteJump = now
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end
	local oldPower = hum.JumpPower
	hum.JumpPower = math.max(oldPower, 68)
	hum:ChangeState(Enum.HumanoidStateType.Jumping)
	task.delay(0.12, function()
		if hum and hum.Parent then
			hum.JumpPower = oldPower
		end
	end)
end)

-- Safe Zone: si vida <= umbral → 1 teleport a 5000 (detección máxima)
local function doSafeZoneTeleport(root)
	if not root then return end
	safeZoneTriggered = true
	root.CFrame = CFrame.new(root.Position.X, 5000, root.Position.Z)
	root.AssemblyLinearVelocity = Vector3.zero
	pcall(function() root.Velocity = Vector3.zero end)
	pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)
end

local function trySafeZone()
	if not SafeZoneEnabled then
		safeZoneTriggered = false
		return
	end
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end
	local hp = hum.Health
	if hp <= 0 then return end
	-- dispara en cuanto la vida esté en o por debajo del número del slider
	if hp <= SafeZoneHealth then
		if not safeZoneTriggered then
			doSafeZoneTeleport(root)
		end
	else
		safeZoneTriggered = false
	end
end

RunService.RenderStepped:Connect(trySafeZone)
RunService.Heartbeat:Connect(trySafeZone)

local function bindSafeZoneHealth(hum)
	if not hum then return end
	hum.HealthChanged:Connect(function()
		trySafeZone()
	end)
	hum:GetPropertyChangedSignal("Health"):Connect(function()
		trySafeZone()
	end)
end

player.CharacterAdded:Connect(function(char)
	safeZoneTriggered = false
	local hum = char:WaitForChild("Humanoid", 5)
	bindSafeZoneHealth(hum)
end)

if player.Character then
	bindSafeZoneHealth(player.Character:FindFirstChildOfClass("Humanoid"))
end

RunService.RenderStepped:Connect(function()
	pcall(updateBoxESP)
end)
print("[Supremacy] ESP NUEVO activo (Highlight+Billboard)")

-- Menu libre: NO bloquear camara al tocar/deslizar (igual que el menu del Assistant)
_menuHold = false

print("[Supremacy] Loaded | Silent Aim ARREGLADO")





end, function(e)
	return tostring(e) .. "\n" .. tostring(debug.traceback())
end)

if not supremacyOk then
	supremacyShowError(supremacyErr)
end


-- OBSERVE PLAYER (modulo externo)
pcall(function()
	_G.SupremacyMountObserve = function(list, panel, screenGui, player, Players, UserInputService, RunService)
		if not list or not panel or not screenGui then return end
		if list:FindFirstChild("ObservePlayerRow") then return end

		local row = Instance.new("Frame")
		row.Name = "ObservePlayerRow"
		row.Size = UDim2.new(1, -10, 0, 22)
		row.BackgroundTransparency = 1
		row.Parent = list

		local lab = Instance.new("TextLabel")
		lab.Size = UDim2.new(1, -86, 1, 0)
		lab.Position = UDim2.new(0, 8, 0, 0)
		lab.BackgroundTransparency = 1
		lab.Text = tr("Observe player")
		registerLangLabel("Observe player", lab)
		lab.TextColor3 = Color3.fromRGB(25, 25, 25)
		lab.Font = Enum.Font.Gotham
		lab.TextSize = 11
		lab.TextXAlignment = Enum.TextXAlignment.Left
		lab.Parent = row

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 72, 0, 16)
		btn.Position = UDim2.new(1, -80, 0.5, -8)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		btn.BorderSizePixel = 0
		btn.Text = (_G.SupremacyObsTarget and _G.SupremacyObsTarget.Name) or "None"
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 10
		btn.TextTruncate = Enum.TextTruncate.AtEnd
		btn.AutoButtonColor = false
		btn.Parent = row
		_G.SupremacyObsLabel = btn

		local drop = Instance.new("ScrollingFrame")
		drop.Name = "ObserveDropdown"
		drop.Size = UDim2.new(0, 120, 0, 0)
		drop.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
		drop.BorderSizePixel = 0
		drop.Visible = false
		drop.ScrollBarThickness = 3
		drop.AutomaticCanvasSize = Enum.AutomaticSize.Y
		drop.CanvasSize = UDim2.new(0, 0, 0, 0)
		drop.ClipsDescendants = true
		drop.ZIndex = 200
		drop.Parent = screenGui
		Instance.new("UIListLayout", drop).Padding = UDim.new(0, 2)

		local open = false

		local function apply(plr)
			_G.SupremacyObsTarget = plr
			local cam = workspace.CurrentCamera
			if not cam then return end
			if not plr or not plr.Parent then
				btn.Text = "None"
				local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					cam.CameraType = Enum.CameraType.Custom
					cam.CameraSubject = hum
				end
				return
			end
			btn.Text = plr.Name
			local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				cam.CameraType = Enum.CameraType.Custom
				cam.CameraSubject = hum
			end
		end

		local function refresh()
			for _, ch in ipairs(drop:GetChildren()) do
				if ch:IsA("TextButton") then ch:Destroy() end
			end
			local function opt(name, plr)
				local b = Instance.new("TextButton")
				b.Size = UDim2.new(1, 0, 0, 16)
				local sel = (plr == nil and not _G.SupremacyObsTarget) or (plr and _G.SupremacyObsTarget == plr)
				b.BackgroundColor3 = sel and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(40, 40, 40)
				b.Text = name
				b.TextColor3 = Color3.fromRGB(255, 255, 255)
				b.TextSize = 10
				b.Font = Enum.Font.GothamBold
				b.BorderSizePixel = 0
				b.TextTruncate = Enum.TextTruncate.AtEnd
				b.ZIndex = 201
				b.Parent = drop
				b.MouseButton1Click:Connect(function()
					apply(plr)
					open = false
					drop.Visible = false
				end)
			end
			opt("None", nil)
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player then opt(plr.Name, plr) end
			end
		end

		btn.MouseButton1Click:Connect(function()
			open = not open
			if open then
				refresh()
				local ap = btn.AbsolutePosition
				local asz = btn.AbsoluteSize
				local sgPos = screenGui.AbsolutePosition
				local n = 1
				for _, plr in pairs(Players:GetPlayers()) do
					if plr ~= player then n = n + 1 end
				end
				-- recuadro compacto = ancho del boton
				-- mismo ancho y borde izquierdo que el boton (sin sobresalir a la izquierda)
				local w = math.floor(asz.X)
				if w < 56 then w = 56 end
				local h = math.min(n * 16, 48)
				drop.Size = UDim2.fromOffset(w, h)
				drop.ClipsDescendants = true
				drop.ScrollBarThickness = 2
				drop.BorderSizePixel = 0
				local x = math.floor(ap.X - sgPos.X)
				local y = math.floor(ap.Y - sgPos.Y + asz.Y + 1)
				-- si se sale por la izquierda del screenGui, pegar a 0
				if x < 0 then x = 0 end
				drop.Position = UDim2.fromOffset(x, y)
				drop.Visible = true
			else
				drop.Visible = false
			end
		end)

		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			if not open then return end
			task.delay(0.12, function()
				if not open then return end
				local pos = input.Position
				local function inside(g)
					if not g or not g.Visible then return false end
					local p, s = g.AbsolutePosition, g.AbsoluteSize
					return pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
				end
				if inside(drop) or inside(btn) then return end
				open = false
				drop.Visible = false
			end)
		end)

		if not _G.SupremacyObsLoop then
			_G.SupremacyObsLoop = true
			RunService.RenderStepped:Connect(function()
				local t = _G.SupremacyObsTarget
				local cam = workspace.CurrentCamera
				if not cam then return end
				if not t or not t.Parent then
					if _G.SupremacyObsTarget then
						_G.SupremacyObsTarget = nil
						if _G.SupremacyObsLabel then _G.SupremacyObsLabel.Text = "None" end
						local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
						if hum then
							cam.CameraType = Enum.CameraType.Custom
							cam.CameraSubject = hum
						end
					end
					return
				end
				local hum = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					if cam.CameraType ~= Enum.CameraType.Custom then
						cam.CameraType = Enum.CameraType.Custom
					end
					if cam.CameraSubject ~= hum then
						cam.CameraSubject = hum
					end
				end
			end)
			Players.PlayerRemoving:Connect(function(plr)
				if _G.SupremacyObsTarget == plr then
					_G.SupremacyObsTarget = nil
					if _G.SupremacyObsLabel then _G.SupremacyObsLabel.Text = "None" end
					local cam = workspace.CurrentCamera
					local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
					if cam and hum then
						cam.CameraType = Enum.CameraType.Custom
						cam.CameraSubject = hum
					end
				end
			end)
		end
	end
end)



-- VOICE ASSISTANT + SENSE SOUND (modulo externo)
pcall(function()
	_G.SupremacyVoiceAssist = _G.SupremacyVoiceAssist or "None"
	pcall(function() math.randomseed(math.floor(os.clock() * 1e6) % 1e9) end)

	local VOICE_MAP = {
		["Voice 1"] = { se = "Amy", speed = 1.00 },
		["Voice 2"] = { se = "Brian", speed = 0.92 },
	}

	-- Presentaciones / en que puedo ayudar (NO saludos genericos)
	local GREETS_ES = {
		"Hola, soy tu asistente, en que te puedo ayudar",
		"Soy tu asistente, listo para apoyarte",
		"Hola, me presento, soy tu asistente de combate",
		"Soy tu asistente, dime si necesitas ayuda",
		"Hola, soy tu asistente personal, cuento contigo",
		"Asistente listo, en que te ayudo",
		"Soy tu asistente, aqui para guiarte en la pelea",
		"Hola, soy tu asistente, avisame si hay peligro",
		"Me presento, soy tu asistente, vamos juntos",
		"Soy tu asistente de apoyo, en que puedo ayudar",
		"Hola, soy tu asistente, te aviso de enemigos y vida",
		"Listo, soy tu asistente, que necesitas",
		"Soy tu asistente, a tu servicio",
		"Hola, soy tu asistente, puedo alertarte en combate",
		"Me presento como tu asistente, en que te ayudo",
		"Soy tu asistente, preparado para ayudarte",
		"Hola, soy tu asistente, confia en mis alertas",
		"Asistente en linea, en que te puedo ayudar",
		"Soy tu asistente, aqui para lo que necesites",
		"Hola, soy tu asistente de batalla, vamos",
		"Me presento, tu asistente, listo cuando quieras",
		"Soy tu asistente, te apoyo con tips y alertas",
		"Hola, soy tu asistente, pregunta o deja que te avise",
		"Asistente activo, en que te puedo ayudar hoy",
		"Soy tu asistente personal, a la orden",
	}
	local GREETS_EN = {
		"Hi, I am your assistant, how can I help you",
		"I am your assistant, ready to support you",
		"Hello, I am your combat assistant",
		"I am your assistant, tell me if you need help",
		"Hi, I am your personal assistant",
		"Assistant ready, how can I help",
		"I am your assistant, here to guide you in the fight",
		"Hello, I am your assistant, I will warn you of danger",
		"I am your support assistant, how can I help",
		"Hi, I am your assistant, I alert enemies and health",
		"I am your assistant, at your service",
		"Hello, I am your assistant, I can alert you in combat",
		"I am your assistant, prepared to help you",
		"Hi, I am your assistant, trust my alerts",
		"Assistant online, how can I help you today",
		"I am your personal assistant, at your command",
	}
	local GREETS = GREETS_EN
	local function pickGreet()
		local list = (_G.SupremacyLang == "Spanish") and GREETS_ES or GREETS_EN
		return list[math.random(1, #list)]
	end
	_G.SupremacyPickGreet = pickGreet

	local function encodeURL(s)
		return tostring(s):gsub("\n", " "):gsub("([^%w%-_ .])", function(c)
			return string.format("%%%02X", string.byte(c))
		end):gsub(" ", "%%20")
	end

	local function getRequest()
		return (syn and syn.request) or http_request or request or (http and http.request)
	end

	local function fetch(url)
		local req = getRequest()
		if not req then return nil end
		local ok, res = pcall(function()
			return req({
				Url = url,
				Method = "GET",
				Headers = { ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" },
			})
		end)
		if not ok or type(res) ~= "table" or not res.Body then return nil end
		local b = tostring(res.Body)
		if #b < 200 then return nil end
		local c0 = b:sub(1, 1)
		if c0 == "{" or c0 == "<" or c0 == "[" then return nil end
		return res.Body
	end

	-- corta cualquier TTS anterior (evita 2 voces a la vez)
	local currentTtsOnDone = nil
	local function stopAllTTS(skipDone)
		pcall(function()
			local ss = game:GetService("SoundService")
			for _, s in ipairs(ss:GetChildren()) do
				if s:IsA("Sound") and s.Name == "SupremacyTTS" then
					pcall(function() s:Stop() end)
					pcall(function() s:Destroy() end)
				end
			end
		end)
		-- si cortamos a media palabra, avisar al notify para que no se quede eterno
		if not skipDone then
			local cb = currentTtsOnDone
			currentTtsOnDone = nil
			if cb then
				pcall(function() cb(0) end)
			end
		else
			currentTtsOnDone = nil
		end
	end

	local function playBytes(body, tag, speed, onDone)
		if not body or #tostring(body) < 200 then
			if onDone then onDone(0) end
			return false
		end
		stopAllTTS(true) -- no disparar onDone del anterior al reemplazar
		currentTtsOnDone = onDone
		local played = false
		pcall(function()
			if makefolder and not isfolder("SupremacyHub") then makefolder("SupremacyHub") end
			local path = string.format(
				"SupremacyHub/tts_%s_%d_%d.mp3",
				tostring(tag or "x"):gsub("%W", ""),
				math.floor(tick() * 1000) % 100000000,
				math.random(1000, 9999)
			)
			if not writefile then
				if onDone then onDone(0) end
				return
			end
			writefile(path, body)
			local sid = nil
			if getcustomasset then
				sid = getcustomasset(path)
			elseif getsynasset then
				sid = getsynasset(path)
			end
			if not sid or sid == "" then
				if onDone then onDone(0) end
				return
			end
			local s = Instance.new("Sound")
			s.Name = "SupremacyTTS"
			s.SoundId = sid
			s.Volume = 4
			s.PlaybackSpeed = speed or 1
			s.Parent = game:GetService("SoundService")
			s:Play()
			local done = false
			local function finish(dur)
				if done then return end
				done = true
				if onDone then onDone(dur or 3) end
			end
			-- esperar a que el audio termine de verdad
			s.Ended:Connect(function()
				local tl = 0
				pcall(function() tl = s.TimeLength or 0 end)
				if currentTtsOnDone == onDone then currentTtsOnDone = nil end
				finish(math.max(tl, 1))
			end)
			-- solo fallback si el sonido nunca dispara Ended (max 45s)
			task.delay(45, function()
				if not done then
					pcall(function() if s and s.IsPlaying then s:Stop() end end)
					finish(45)
				end
			end)
			game:GetService("Debris"):AddItem(s, 50)
			task.delay(30, function()
				pcall(function()
					if isfile and isfile(path) and delfile then delfile(path) end
				end)
			end)
			played = true
		end)
		return played
	end

	local function speakRaw(phrase, onDone)
		if not phrase or phrase == "" then
			if onDone then onDone(0) end
			return
		end
		local mode = tostring(_G.SupremacyVoiceAssist or "None")
		if mode == "None" then
			if onDone then onDone(0) end
			return
		end
		local cfg = VOICE_MAP[mode]
		if not cfg then
			if onDone then onDone(0) end
			return
		end

		stopAllTTS()
		local body = fetch("https://api.streamelements.com/kappa/v2/speech?voice="
			.. cfg.se .. "&text=" .. encodeURL(phrase))
		local tag = cfg.se
		local speed = cfg.speed
		if not body then
			body = fetch("https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=es&q="
				.. encodeURL(phrase))
			tag = "google_" .. cfg.se
			if mode == "Voice 1" then speed = 1.08 else speed = 0.82 end
		end
		if body then
			playBytes(body, tag, speed, onDone)
		else
			if onDone then onDone(math.clamp(#phrase * 0.08, 2.5, 10)) end
		end
	end

	_G.SupremacySpeakAssist = function(text, onDuration)
		task.spawn(function()
			pcall(function()
				local mode = tostring(_G.SupremacyVoiceAssist or "None")
				if mode == "None" or not text or text == "" then
					if onDuration then onDuration(0) end
					return
				end
				local clean = tostring(text)
				-- no leer en voz el prefijo Assistant: / Asistente:
				clean = clean:gsub("^[Aa]ssistant:%s*", "")
				clean = clean:gsub("^[Aa]ssistant%s+", "")
				clean = clean:gsub("^[Aa]sistente:%s*", "")
				clean = clean:gsub("^[Aa]sistente%s+", "")
				clean = clean:gsub("^%s+", ""):gsub("%s+$", "")
				local low = string.lower(clean)
				if low:find("activad", 1, true) or low == "" then
					clean = pickGreet()
				end
				if clean == "" then
					if onDuration then onDuration(0) end
					return
				end
				-- SOLO avisar cuando el audio realmente termina (no estimado)
				speakRaw(clean, function(dur)
					if onDuration then
						onDuration(tonumber(dur) or 0)
					end
				end)
			end)
		end)
	end

	_G.SupremacyPickGreet = pickGreet
	_G.SupremacyStopTTS = stopAllTTS

	_G.SupremacyMountVoice = function(list, screenGui)
		local UserInputService = game:GetService("UserInputService")
		if not list or list:FindFirstChild("VoiceAssistantRow") then return end
		local row = Instance.new("Frame")
		row.Name = "VoiceAssistantRow"
		row.Size = UDim2.new(1, -10, 0, 20)
		row.BackgroundTransparency = 1
		row.LayoutOrder = 2
		row.Parent = list

		local lab = Instance.new("TextLabel")
		lab.Size = UDim2.new(1, -86, 1, 0)
		lab.Position = UDim2.new(0, 8, 0, 0)
		lab.BackgroundTransparency = 1
		lab.Text = tr("Voice Assistant")
		registerLangLabel("Voice Assistant", lab)
		lab.TextColor3 = Color3.fromRGB(25, 25, 25)
		lab.Font = Enum.Font.Gotham
		lab.TextSize = 11
		lab.TextXAlignment = Enum.TextXAlignment.Left
		lab.Parent = row

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 72, 0, 16)
		btn.Position = UDim2.new(1, -80, 0.5, -8)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		btn.BorderSizePixel = 0
		btn.Text = tostring(_G.SupremacyVoiceAssist or "None")
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 10
		btn.AutoButtonColor = false
		btn.Parent = row

		local drop = Instance.new("ScrollingFrame")
		drop.Name = "AssistVoiceDrop"
		drop.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
		drop.BorderSizePixel = 0
		drop.Visible = false
		drop.ScrollBarThickness = 0
		drop.AutomaticCanvasSize = Enum.AutomaticSize.Y
		drop.CanvasSize = UDim2.new(0, 0, 0, 0)
		drop.ClipsDescendants = true
		drop.ZIndex = 250
		drop.Parent = screenGui
		Instance.new("UIListLayout", drop).Padding = UDim.new(0, 2)

		local open = false
		local opts = { "None", "Voice 1", "Voice 2" }
		local ignoreUntil = 0

		local function closeDrop()
			open = false
			drop.Visible = false
		end

		local function openDrop()
			-- cerrar otros dropdowns de assistant
			pcall(function()
				for _, ch in pairs(screenGui:GetChildren()) do
					if ch:IsA("ScrollingFrame") and ch ~= drop and (ch.Name == "AssistVoiceDrop" or ch.Name == "AssistSenseDrop" or ch.Name == "ObserveDropdown") then
						ch.Visible = false
					end
				end
			end)
			for _, ch in ipairs(drop:GetChildren()) do
				if ch:IsA("TextButton") then ch:Destroy() end
			end
			for _, name in ipairs(opts) do
				local b = Instance.new("TextButton")
				b.Size = UDim2.new(1, 0, 0, 16)
				b.BackgroundColor3 = (name == _G.SupremacyVoiceAssist) and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(40, 40, 40)
				b.Text = name
				b.TextColor3 = Color3.fromRGB(255, 255, 255)
				b.TextSize = 10
				b.Font = Enum.Font.GothamBold
				b.BorderSizePixel = 0
				b.TextTruncate = Enum.TextTruncate.AtEnd
				b.ZIndex = 251
				b.Parent = drop
				b.MouseButton1Click:Connect(function()
					_G.SupremacyVoiceAssist = name
					btn.Text = name
					closeDrop()
					pcall(function()
						local S2 = _G.SupremacyAssistS
						if name == "None" then
							-- solo MUTE: el mensaje se queda hasta su tiempo de lectura
							if _G.SupremacyStopTTS then
								_G.SupremacyStopTTS(true) -- skipDone = no borrar cartel
							end
							-- si Assistant OFF y no hay mensaje activo, nada
							if not (S2 and S2.on) and not _G.SupremacyNotifyState then
								if _G.SupremacyClearNotify then _G.SupremacyClearNotify() end
							end
						else
							-- activar voz a media frase: lee SOLO lo que falta
							if S2 and S2.on and _G.SupremacyNotifyState then
								if _G.SupremacyResumeNotifyVoice then
									_G.SupremacyResumeNotifyVoice()
								end
							end
						end
					end)
				end)
			end
			local ap = btn.AbsolutePosition
			local asz = btn.AbsoluteSize
			local sgPos = screenGui.AbsolutePosition
			-- recuadro = ancho del boton, SIEMPRE debajo
			local w = math.floor(asz.X)
			if w < 56 then w = 56 end
			local h = #opts * 16
			drop.Size = UDim2.fromOffset(w, h)
			drop.ClipsDescendants = true
			drop.BorderSizePixel = 0
			local x = math.floor(ap.X - sgPos.X)
			local y = math.floor(ap.Y - sgPos.Y + asz.Y + 1)
			if x < 0 then x = 0 end
			drop.Position = UDim2.fromOffset(x, y)
			drop.Visible = true
			open = true
			ignoreUntil = tick() + 0.2
		end

		btn.MouseButton1Click:Connect(function()
			if open then closeDrop() else openDrop() end
		end)

		pcall(function()
			list:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				if open then closeDrop() end
			end)
		end)

		UserInputService.InputBegan:Connect(function(input)
			if not open then return end
			if tick() < ignoreUntil then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			task.delay(0.05, function()
				if not open then return end
				local pos = input.Position
				local function inside(g)
					if not g or not g.Visible then return false end
					local p, sz = g.AbsolutePosition, g.AbsoluteSize
					return pos.X >= p.X and pos.X <= p.X + sz.X and pos.Y >= p.Y and pos.Y <= p.Y + sz.Y
				end
				if inside(drop) or inside(btn) then return end
				closeDrop()
			end)
		end)
	end

_G.SupremacyMountSenseSound = function(list, screenGui, S)
		local UserInputService = game:GetService("UserInputService")
		if list:FindFirstChild("SenseSoundRow") then return end
		local row = Instance.new("Frame")
		row.Name = "SenseSoundRow"
		row.Size = UDim2.new(1, -10, 0, 20)
		row.BackgroundTransparency = 1
		row.LayoutOrder = 4
		row.Parent = list

		local lab = Instance.new("TextLabel")
		lab.Size = UDim2.new(1, -86, 1, 0)
		lab.Position = UDim2.new(0, 8, 0, 0)
		lab.BackgroundTransparency = 1
		lab.Text = tr("Sense Sound")
		registerLangLabel("Sense Sound", lab)
		lab.TextColor3 = Color3.fromRGB(25, 25, 25)
		lab.Font = Enum.Font.Gotham
		lab.TextSize = 11
		lab.TextXAlignment = Enum.TextXAlignment.Left
		lab.Parent = row

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 72, 0, 16)
		btn.Position = UDim2.new(1, -80, 0.5, -8)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		btn.BorderSizePixel = 0
		btn.Text = tostring(S.senseSound or "None")
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 10
		btn.AutoButtonColor = false
		btn.Parent = row

		local drop = Instance.new("ScrollingFrame")
		drop.Name = "AssistSenseDrop"
		drop.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
		drop.BorderSizePixel = 0
		drop.Visible = false
		drop.ScrollBarThickness = 0
		drop.AutomaticCanvasSize = Enum.AutomaticSize.Y
		drop.CanvasSize = UDim2.new(0, 0, 0, 0)
		drop.ClipsDescendants = true
		drop.ZIndex = 250
		drop.Parent = screenGui
		Instance.new("UIListLayout", drop).Padding = UDim.new(0, 2)

		local open = false
		local opts = { "None", "Sound 1", "Sound 2", "Sound 3", "Sound 4" }
		local ignoreUntil = 0

		local function closeDrop()
			open = false
			drop.Visible = false
		end

		local function openDrop()
			pcall(function()
				for _, ch in pairs(screenGui:GetChildren()) do
					if ch:IsA("ScrollingFrame") and ch ~= drop and (ch.Name == "AssistVoiceDrop" or ch.Name == "AssistSenseDrop" or ch.Name == "ObserveDropdown") then
						ch.Visible = false
					end
				end
			end)
			for _, ch in ipairs(drop:GetChildren()) do
				if ch:IsA("TextButton") then ch:Destroy() end
			end
			for _, name in ipairs(opts) do
				local b = Instance.new("TextButton")
				b.Size = UDim2.new(1, 0, 0, 16)
				b.BackgroundColor3 = (name == S.senseSound) and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(40, 40, 40)
				b.Text = name
				b.TextColor3 = Color3.fromRGB(255, 255, 255)
				b.TextSize = 10
				b.Font = Enum.Font.GothamBold
				b.BorderSizePixel = 0
				b.TextTruncate = Enum.TextTruncate.AtEnd
				b.ZIndex = 251
				b.Parent = drop
				b.MouseButton1Click:Connect(function()
					S.senseSound = name
					btn.Text = name
					closeDrop()
				end)
			end
			local ap = btn.AbsolutePosition
			local asz = btn.AbsoluteSize
			local sgPos = screenGui.AbsolutePosition
			local w = math.floor(asz.X)
			if w < 56 then w = 56 end
			local h = #opts * 16
			drop.Size = UDim2.fromOffset(w, h)
			drop.ClipsDescendants = true
			drop.BorderSizePixel = 0
			local x = math.floor(ap.X - sgPos.X)
			local y = math.floor(ap.Y - sgPos.Y + asz.Y + 1)
			if x < 0 then x = 0 end
			drop.Position = UDim2.fromOffset(x, y)
			drop.Visible = true
			open = true
			ignoreUntil = tick() + 0.2
		end

		btn.MouseButton1Click:Connect(function()
			if open then closeDrop() else openDrop() end
		end)

		pcall(function()
			list:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				if open then closeDrop() end
			end)
		end)

		UserInputService.InputBegan:Connect(function(input)
			if not open then return end
			if tick() < ignoreUntil then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			task.delay(0.05, function()
				if not open then return end
				local pos = input.Position
				local function inside(g)
					if not g or not g.Visible then return false end
					local p, sz = g.AbsolutePosition, g.AbsoluteSize
					return pos.X >= p.X and pos.X <= p.X + sz.X and pos.Y >= p.Y and pos.Y <= p.Y + sz.Y
				end
				if inside(drop) or inside(btn) then return end
				closeDrop()
			end)
		end)
	end
end)

-- ASSIST ALERTS (sin chat IA)
pcall(function()
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local streamToken = 0

	-- limpia cartel + cancela callbacks (solo al apagar Assistant)
	_G.SupremacyClearNotify = function()
		pcall(function()
			streamToken = streamToken + 1
			_G.SupremacyOnNotifyDone = nil -- NO ejecutar (evita saltar a Practice)
			_G.SupremacyPracticeHold = false
			_G.SupremacyGreetBusy = false
			_G.SupremacyNotifyState = nil
			pcall(function()
				if _G.SupremacyStopTTS then _G.SupremacyStopTTS(true) end
			end)
			local pg = player:FindFirstChild("PlayerGui")
			local g = pg and pg:FindFirstChild("SupremacyAssistNotify")
			if g then
				for _, ch in pairs(g:GetChildren()) do
					pcall(function() ch:Destroy() end)
				end
			end
		end)
	end

	-- texto que falta por "leer" segun el tiempo transcurrido
	_G.SupremacyRemainingNotifyText = function()
		local st = _G.SupremacyNotifyState
		if not st or not st.text or st.text == "" then return "" end
		local elapsed = tick() - (st.start or tick())
		local dur = st.estDur or 4
		if dur < 0.5 then dur = 0.5 end
		local frac = math.clamp(elapsed / dur, 0, 1)
		if frac >= 0.97 then return "" end
		local idx = math.floor(#st.text * frac) + 1
		if idx < 1 then idx = 1 end
		-- saltar a inicio de palabra
		if idx > 1 then
			local sp = string.find(st.text, " ", idx, true)
			if sp then
				idx = sp + 1
			end
		end
		local rest = string.sub(st.text, idx)
		rest = string.gsub(rest, "^%s+", "")
		return rest
	end

	-- reanudar voz desde donde iba el mensaje
	_G.SupremacyResumeNotifyVoice = function()
		pcall(function()
			local mode = tostring(_G.SupremacyVoiceAssist or "None")
			if mode == "None" or mode == "" then return end
			local rest = ""
			if _G.SupremacyRemainingNotifyText then
				rest = _G.SupremacyRemainingNotifyText() or ""
			end
			if rest == "" then return end
			if _G.SupremacySpeakAssist then
				_G.SupremacySpeakAssist(rest, function() end)
			end
		end)
	end

	_G.SupremacyNotifyStream = function(msg)
		pcall(function()
			local S = _G.SupremacyAssistS
			if not (S and S.on) then
				pcall(function() if _G.SupremacySpeakAssist then _G.SupremacySpeakAssist(tostring(msg or "")) end end)
				return
			end
			streamToken = streamToken + 1
			local myTok = streamToken
			local full = tostring(msg or "")
			if full == "" then return end
			local hold = _G.SupremacyPracticeHold == true
			local pg = player:FindFirstChild("PlayerGui")
			if not pg then return end
			local g = pg:FindFirstChild("SupremacyAssistNotify")
			if not g then
				g = Instance.new("ScreenGui")
				g.Name = "SupremacyAssistNotify"
				g.ResetOnSpawn = false
				g.IgnoreGuiInset = true
				g.DisplayOrder = 80
				g.Parent = pg
			end
			-- limpiar alerta anterior
			for _, ch in pairs(g:GetChildren()) do
				ch:Destroy()
			end
			local h = hold and 70 or 34
			local frame = Instance.new("Frame")
			frame.Name = "Msg"
			frame.Size = UDim2.new(0, 280, 0, h)
			frame.Position = UDim2.new(0.5, -140, 0.02, 0)
			frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
			frame.BackgroundTransparency = 0.12
			frame.BorderSizePixel = 0
			frame.Parent = g
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
			local l = Instance.new("TextLabel")
			l.Size = UDim2.new(1, -12, hold and 0 or 1, hold and 36 or 0)
			l.Position = UDim2.new(0, 6, 0, 2)
			l.BackgroundTransparency = 1
			l.Text = full
			l.TextColor3 = Color3.fromRGB(255, 255, 255)
			l.Font = Enum.Font.GothamBold
			l.TextSize = 12
			l.TextWrapped = true
			l.Parent = frame
			if hold then
				local mode = tostring(_G.SupremacyPracticeMode or "step")
				if mode == "ask" then
					local yesBtn = Instance.new("TextButton")
					yesBtn.Name = "YesBtn"
					yesBtn.Size = UDim2.new(0, 72, 0, 22)
					yesBtn.Position = UDim2.new(0.5, -78, 1, -26)
					yesBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
					yesBtn.Text = "Si"
					yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					yesBtn.Font = Enum.Font.GothamBold
					yesBtn.TextSize = 11
					yesBtn.BorderSizePixel = 0
					yesBtn.Parent = frame
					Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 5)
					local noBtn = Instance.new("TextButton")
					noBtn.Name = "NoBtn"
					noBtn.Size = UDim2.new(0, 72, 0, 22)
					noBtn.Position = UDim2.new(0.5, 6, 1, -26)
					noBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
					noBtn.Text = "No"
					noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					noBtn.Font = Enum.Font.GothamBold
					noBtn.TextSize = 11
					noBtn.BorderSizePixel = 0
					noBtn.Parent = frame
					Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 5)
					yesBtn.MouseButton1Click:Connect(function()
						if _G.SupremacyPracticeOnYes then pcall(_G.SupremacyPracticeOnYes) end
					end)
					noBtn.MouseButton1Click:Connect(function()
						if _G.SupremacyPracticeOnNo then pcall(_G.SupremacyPracticeOnNo) end
					end)
				else
					local nextBtn = Instance.new("TextButton")
					nextBtn.Name = "NextBtn"
					nextBtn.Size = UDim2.new(0, 100, 0, 22)
					nextBtn.Position = UDim2.new(0.5, -50, 1, -26)
					nextBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
					nextBtn.Text = "Next"
					nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					nextBtn.Font = Enum.Font.GothamBold
					nextBtn.TextSize = 11
					nextBtn.BorderSizePixel = 0
					nextBtn.Parent = frame
					Instance.new("UICorner", nextBtn).CornerRadius = UDim.new(0, 5)
					nextBtn.MouseButton1Click:Connect(function()
						if _G.SupremacyPracticeOnNext then pcall(_G.SupremacyPracticeOnNext) end
					end)
				end
			end
			if not hold then
				local destroyed = false
				local estDur = math.clamp(#full * 0.075, 2.8, 14)
				-- progreso del mensaje (para reanudar voz a media frase)
				_G.SupremacyNotifyState = {
					text = full,
					start = tick(),
					estDur = estDur,
					token = myTok,
				}
				local function tryDestroy()
					if destroyed then return end
					destroyed = true
					if _G.SupremacyNotifyState and _G.SupremacyNotifyState.token == myTok then
						_G.SupremacyNotifyState = nil
					end
					if myTok == streamToken and frame and frame.Parent then
						local S2 = _G.SupremacyAssistS
						if not (S2 and S2.noDisappear) then
							frame:Destroy()
						end
					end
					pcall(function()
						local cb = _G.SupremacyOnNotifyDone
						if cb then
							_G.SupremacyOnNotifyDone = nil
							cb()
						end
					end)
				end
				-- SIEMPRE se quita al terminar el tiempo de lectura (con o sin voz)
				task.delay(estDur + 0.4, tryDestroy)
				local voiceOn = tostring(_G.SupremacyVoiceAssist or "None") ~= "None"
				if voiceOn and _G.SupremacySpeakAssist then
					_G.SupremacySpeakAssist(full, function(dur)
						-- si la voz termina antes, quitar un poco despues
						if type(dur) == "number" and dur > 0.5 then
							task.delay(0.2, tryDestroy)
						end
						-- si dur==0 fue corte de voz: NO quitar (el timer estDur se encarga)
					end)
				end
			else
				pcall(function() if _G.SupremacySpeakAssist then _G.SupremacySpeakAssist(full) end end)
			end
			-- si hold: no se quita hasta Next/Finalizado
		end)
	end
	_G.SupremacyOpenAssistChat = nil
end)



-- PUT KEY (modulo externo, no toca locals del hub)
pcall(function()
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local player = Players.LocalPlayer
	local ICON = "rbxassetid://132347723637709"
	local ICON2 = "rbxassetid://82724491814418"

	_G.SupremacyKeys = _G.SupremacyKeys or {
		["Sanguine Z Boost"] = "Z",
		["Tab (Freeze)"] = "T",
		["Super Jump"] = "J",
		["Aimbot Key"] = "A",
		["Aimbot Button"] = "A",
		["Predict"] = "P",
	}

	local MAP = {
		["Sanguine Z Boost"] = function(letter)
			pcall(function()
				local pg = player:FindFirstChild("PlayerGui")
				local g = pg and pg:FindFirstChild("ZSanguineBoost")
				if not g then return end
				for _, d in pairs(g:GetDescendants()) do
					if d:IsA("TextButton") then d.Text = letter break end
				end
			end)
		end,
		["Tab (Freeze)"] = function(letter)
			pcall(function()
				local sg = _G.SupremacyScreenGui
				if not sg then return end
				local btn = sg:FindFirstChild("FreezeTabBtn", true)
				if btn and btn:IsA("TextButton") then btn.Text = letter end
			end)
		end,
		["Super Jump"] = function(letter)
			pcall(function()
				local sg = _G.SupremacyScreenGui
				if not sg then return end
				local btn = sg:FindFirstChild("SuperJumpBtn", true)
				if btn and btn:IsA("TextButton") then btn.Text = letter end
			end)
		end,
		["Aimbot Key"] = function(letter)
			pcall(function()
				local sg = _G.SupremacyScreenGui
				if not sg then return end
				local btn = sg:FindFirstChild("AimbotFollowBtn", true)
				if btn and btn:IsA("TextButton") then btn.Text = letter end
			end)
		end,
		["Aimbot Button"] = function(letter)
			pcall(function()
				local sg = _G.SupremacyScreenGui
				if not sg then return end
				local btn = sg:FindFirstChild("AimbotFollowBtn", true)
				if btn and btn:IsA("TextButton") then btn.Text = letter end
			end)
		end,
		["Predict"] = function(letter)
			pcall(function()
				local sg = _G.SupremacyScreenGui
				local btn = nil
				if sg then btn = sg:FindFirstChild("PredictBtn", true) end
				if not btn and Predict.btn then btn = Predict.btn end
				if btn and btn:IsA("TextButton") then
					btn.Text = tostring(letter or "P")
				end
			end)
		end,
	}

	local function openPutKey(featureName, iconBtn)
		local sg = _G.SupremacyScreenGui
		if not sg then return end
		local main = sg:FindFirstChild("Main", true)
		if not main then return end
		for _, c in pairs(main:GetChildren()) do
			if c.Name == "PutKeyMenu" then c:Destroy() end
		end
		_G.SupremacyKeys = _G.SupremacyKeys or {}
		local cur = _G.SupremacyKeys[featureName]
			or (featureName == "Aimbot Key" and _G.SupremacyKeys["Aimbot Button"])
			or (featureName == "Aimbot Button" and _G.SupremacyKeys["Aimbot Key"])
			or nil
		-- defaults por feature si nunca se guardo
		if not cur or cur == "" then
			local defaults = {
				["Sanguine Z Boost"] = "Z",
				["Tab (Freeze)"] = "T",
				["Super Jump"] = "J",
				["Aimbot Key"] = "A",
				["Aimbot Button"] = "A",
				["Predict"] = "P",
			}
			cur = defaults[featureName] or "A"
		end
		cur = string.upper(string.sub(tostring(cur), 1, 1))
		-- asegurar que quede en memoria aunque no hayan dado OK aun
		_G.SupremacyKeys[featureName] = cur
		local frame = Instance.new("Frame")
		frame.Name = "PutKeyMenu"
		frame.Size = UDim2.new(0, 150, 0, 78)
		frame.Position = UDim2.new(0.5, -75, 0.5, -39)
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BorderSizePixel = 0
		frame.ZIndex = 220
		frame.Parent = main
		local frameStroke = Instance.new("UIStroke", frame)
		frameStroke.Color = Color3.fromRGB(180, 180, 180)
		frameStroke.Thickness = 1
		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, 0, 0, 22)
		title.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
		title.BorderSizePixel = 0
		title.Text = "Put Key"
		title.TextColor3 = Color3.fromRGB(20, 20, 20)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 12
		title.ZIndex = 221
		title.Parent = frame
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(0, 40, 0, 24)
		box.Position = UDim2.new(0.5, -20, 0, 28)
		box.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
		box.BorderSizePixel = 0
		box.Text = cur
		box.PlaceholderText = "A"
		box.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
		box.TextColor3 = Color3.fromRGB(20, 20, 20)
		box.Font = Enum.Font.GothamBold
		box.TextSize = 16
		box.TextXAlignment = Enum.TextXAlignment.Center
		box.ClearTextOnFocus = false
		box.ZIndex = 221
		box.Parent = frame
		local boxStroke = Instance.new("UIStroke", box)
		boxStroke.Color = Color3.fromRGB(200, 200, 200)
		boxStroke.Thickness = 1
		-- letra guardada siempre visible
		box.Text = tostring(cur)
		box:GetPropertyChangedSignal("Text"):Connect(function()
			local t = string.upper(box.Text or ""):gsub("[^A-Z0-9]", "")
			if #t > 1 then t = string.sub(t, 1, 1) end
			if box.Text ~= t then
				box.Text = t
			end
		end)
		local okBtn = Instance.new("TextButton")
		okBtn.Size = UDim2.new(0, 56, 0, 20)
		okBtn.Position = UDim2.new(0.5, -28, 1, -26)
		okBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		okBtn.Text = "OK"
		okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		okBtn.Font = Enum.Font.GothamBold
		okBtn.TextSize = 11
		okBtn.ZIndex = 221
		okBtn.Parent = frame
		local function save()
			local k = string.upper(tostring(box.Text or "")):gsub("[^A-Z0-9]", "")
			if k == "" then k = tostring(cur) end
			if k == "" then k = "A" end
			k = string.sub(k, 1, 1)
			_G.SupremacyKeys = _G.SupremacyKeys or {}
			_G.SupremacyKeys[featureName] = k
			-- aliases para no perder al reabrir
			if featureName == "Aimbot Key" then
				_G.SupremacyKeys["Aimbot Button"] = k
			elseif featureName == "Aimbot Button" then
				_G.SupremacyKeys["Aimbot Key"] = k
			end
			if MAP[featureName] then pcall(MAP[featureName], k) end
			if MAP["Aimbot Key"] and (featureName == "Aimbot Button" or featureName == "Aimbot Key") then
				pcall(MAP["Aimbot Key"], k)
			end
			pcall(function()
				if _G.SupremacyApplyKeys then _G.SupremacyApplyKeys() end
			end)
			frame:Destroy()
		end
		okBtn.MouseButton1Click:Connect(save)
		-- NO abrir teclado automaticamente (sin CaptureFocus)
	end

	local function applyAllKeys()
		local Keys = _G.SupremacyKeys or {}
		for name, fn in pairs(MAP) do
			local letter = Keys[name]
			if letter and fn then
				pcall(fn, tostring(letter))
			end
		end
	end
	_G.SupremacyApplyKeys = applyAllKeys

	local TARGETS = {
		"Sanguine Z Boost",
		"Tab (Freeze)",
		"Super Jump",
		"Aimbot Key",
		"Aimbot Button",
		"Predict",
	}

	local function inject()
		local sg = _G.SupremacyScreenGui
		if not sg then return end
		local function scan(obj)
			for _, ch in pairs(obj:GetDescendants()) do
				if ch:IsA("TextLabel") then
					local t = ch.Text
					for _, name in ipairs(TARGETS) do
						if t == name then
							local row = ch.Parent
							if row and row:IsA("Frame") and not row:FindFirstChild("PutKeyIcon") then
								-- mover label un poco para el icono
								ch.Size = UDim2.new(1, -78, 1, 0)
								local keyBtn = Instance.new("ImageButton")
								keyBtn.Name = "PutKeyIcon"
								keyBtn.Size = UDim2.new(0, 20, 0, 20)
								keyBtn.Position = UDim2.new(1, -68, 0.5, -10)
								keyBtn.BackgroundTransparency = 1
								keyBtn.BorderSizePixel = 0
								keyBtn.Image = ICON
								keyBtn.ScaleType = Enum.ScaleType.Fit
								keyBtn.ZIndex = 202
								keyBtn.Parent = row
								keyBtn.MouseButton1Click:Connect(function()
									openPutKey(name, keyBtn)
								end)
								task.defer(function()
									task.wait(0.4)
									pcall(function() keyBtn.Image = ICON2 end)
								end)
								-- aplicar letra guardada al boton flotante
								local letter = _G.SupremacyKeys[name]
								if letter and MAP[name] then MAP[name](letter) end
							end
						end
					end
				end
			end
		end
		scan(sg)
	end

	task.spawn(function()
		for i = 1, 30 do
			task.wait(0.25)
			if _G.SupremacyScreenGui then
				inject()
				applyAllKeys()
				break
			end
		end
		task.wait(1)
		inject()
		applyAllKeys()
	end)

	-- teclado fisico: misma accion que tocar el boton flotante
	UIS.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		local name = input.KeyCode and input.KeyCode.Name
		if not name then return end
		-- letras A-Z o digitos 0-9 (Name de 1 char)
		if #name ~= 1 then return end
		local k = string.upper(name)
		local Keys = _G.SupremacyKeys or {}
		local want = Keys["Predict"] or "P"
		if string.upper(tostring(want)) ~= k then return end
		-- misma accion que el boton P
		if _G.SupremacyTogglePredict then
			pcall(_G.SupremacyTogglePredict)
		end
	end)
end)



pcall(function()
	local savedMin, savedMax = nil, nil
	_G.SupremacyCameraZoomOn = _G.SupremacyCameraZoomOn or false
	_G.SupremacyCameraZoomVal = _G.SupremacyCameraZoomVal or 0
	_G.SupremacyCameraZoomApply = function(on)
		_G.SupremacyCameraZoomOn = on and true or false
		local cam = workspace.CurrentCamera
		if not cam then return end
		if on then
			if savedMin == nil then savedMin = cam.CameraMinZoomDistance savedMax = cam.CameraMaxZoomDistance end
			local v = tonumber(_G.SupremacyCameraZoomVal) or 0
			pcall(function()
				cam.CameraMinZoomDistance = 0.5
				cam.CameraMaxZoomDistance = 32 + (v / 100) * 168
			end)
		else
			pcall(function()
				if savedMin then cam.CameraMinZoomDistance = savedMin end
				if savedMax then cam.CameraMaxZoomDistance = savedMax end
			end)
			savedMin, savedMax = nil, nil
		end
	end
	_G.SupremacyCameraZoomValue = function(v)
		_G.SupremacyCameraZoomVal = tonumber(v) or 0
		if _G.SupremacyCameraZoomOn then _G.SupremacyCameraZoomApply(true) end
	end
end)
