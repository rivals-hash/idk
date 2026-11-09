--[[
    Darling Hub - controls_hud.lua (Version 1.0)
    Blox Fruits On-Screen Controls Layout Customizer
    Allows players to freely reposition and scale skill buttons (Z, X, C, V, F),
    Jump, Dash, and Hotbar with drag-and-drop overlays for both touch and mouse.
    Persists custom layouts to darling_hub/controls_layout.json.
    Zero Emojis standard across all interface elements.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local ControlsHUD = {
    IsEditing = false,
    GlobalScale = 1.0,
    Overlays = {},
    DragConnections = {},
    OriginalLayout = {},
    EditOverlayGui = nil,
    EditTopBanner = nil,
    OnModeChanged = nil,
}

_G.Darling_ControlsLayout = _G.Darling_ControlsLayout or {}

local ignoredHUDNames = {
    "health", "energy", "stamina", "level", "beli", "fragment", "stat",
    "compass", "quest", "menu", "dialogue", "top", "topbar", "bar",
    "characteravatar", "profile", "avatar", "crew", "leaderboard",
    "hotbar", "backpack", "inventory", "container", "itemslot"
}

local function isAllowedHUDButton(btn)
    if not btn or not btn:IsA("GuiObject") then return false end
    local n = string.lower(btn.Name)
    for _, ign in ipairs(ignoredHUDNames) do
        if string.find(n, ign) then return false end
    end
    return true
end

local function safeParent(gui)
    local p = nil
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then p = h end
    end
    if not p then
        if CoreGui and pcall(function() return CoreGui.Name end) then
            p = CoreGui
        else
            p = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
        end
    end
    gui.Parent = p
    return p
end

local function getBloxFruitsControlButtons()
    local btns = {}
    local seen = {}
    local pGui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pGui then return btns end

    local function addBtn(b, customKey)
        if not b or not b:IsA("GuiObject") then return end
        local key = customKey or b.Name
        if seen[key] or seen[b] then return end
        seen[key] = true
        seen[b] = true
        table.insert(btns, b)
    end

    local main = pGui:FindFirstChild("Main")
    if main then
        local skills = main:FindFirstChild("Skills")
        if skills then
            addBtn(skills, "PC_SkillsBar")
            for _, sChild in ipairs(skills:GetChildren()) do
                if sChild:IsA("GuiObject") and (sChild.Name == "Z" or sChild.Name == "X" or sChild.Name == "C" or sChild.Name == "V" or sChild.Name == "F") then
                    addBtn(sChild, "Skill_" .. sChild.Name)
                end
            end
        end
    end

    local touchGui = pGui:FindFirstChild("TouchGui")
    if touchGui then
        local tcFrame = touchGui:FindFirstChild("TouchControlFrame")
        if tcFrame then
            local jBtn = tcFrame:FindFirstChild("JumpButton")
            if jBtn and isAllowedHUDButton(jBtn) then addBtn(jBtn, "Jump") end
        end
    end

    local cag = pGui:FindFirstChild("ContextActionGui")
    if cag then
        local cbf = cag:FindFirstChild("ContextButtonFrame")
        if cbf then
            for _, ch in ipairs(cbf:GetChildren()) do
                if ch:IsA("GuiObject") and isAllowedHUDButton(ch) then
                    addBtn(ch)
                end
            end
        end
    end

    local mcb = pGui:FindFirstChild("MobileContextButtons")
    if mcb then
        local cbf = mcb:FindFirstChild("ContextButtonFrame") or mcb
        for _, ch in ipairs(cbf:GetChildren()) do
            if ch:IsA("GuiObject") and isAllowedHUDButton(ch) then
                addBtn(ch)
            end
        end
    end

    if main then
        for _, ch in ipairs(main:GetChildren()) do
            local nm = string.lower(ch.Name)
            if (nm:find("dash") or nm:find("jump") or nm:find("skill") or nm:find("mobilebutton") or nm:find("combatbutton")) and ch:IsA("GuiObject") then
                if isAllowedHUDButton(ch) then addBtn(ch) end
            end
        end
    end

    return btns
end
ControlsHUD.GetButtons = getBloxFruitsControlButtons

local function cleanupHudOverlays()
    for _, ov in ipairs(ControlsHUD.Overlays) do
        if ov and ov.Parent then
            pcall(function() ov:Destroy() end)
        end
    end
    table.clear(ControlsHUD.Overlays)

    for _, c in ipairs(ControlsHUD.DragConnections) do
        if c and c.Disconnect then
            pcall(function() c:Disconnect() end)
        end
    end
    table.clear(ControlsHUD.DragConnections)
end
ControlsHUD.CleanupOverlays = cleanupHudOverlays

local function getLayoutConfigPaths()
    return {
        "darling_hub/controls_layout.json",
        "darling_controls_layout.json"
    }
end

local function saveControlsLayoutToFile()
    pcall(function()
        local content = HttpService:JSONEncode(_G.Darling_ControlsLayout)
        for _, path in ipairs(getLayoutConfigPaths()) do
            if writefile then
                pcall(function() writefile(path, content) end)
            end
        end
    end)
end
ControlsHUD.SaveLayout = saveControlsLayoutToFile

local function loadControlsLayoutFromFile()
    pcall(function()
        local json = nil
        for _, path in ipairs(getLayoutConfigPaths()) do
            if isfile and isfile(path) and readfile then
                local data = readfile(path)
                if data and #data > 2 then
                    json = data
                    break
                end
            end
        end

        if json and json ~= "" then
            local ok, parsed = pcall(function() return HttpService:JSONDecode(json) end)
            if ok and type(parsed) == "table" then
                -- Purge any saved hotbar keys so hotbar is never displaced
                parsed["Hotbar"] = nil
                parsed["PC_Hotbar"] = nil
                parsed["Backpack_Hotbar"] = nil
                parsed["Container"] = nil

                _G.Darling_ControlsLayout = parsed
                local globalScale = parsed.globalScale or 1.0
                ControlsHUD.GlobalScale = globalScale

                for _, btn in ipairs(getBloxFruitsControlButtons()) do
                    local saved = _G.Darling_ControlsLayout[btn.Name]
                    if saved then
                        if saved.scaleX and saved.scaleY then
                            btn.Position = UDim2.new(saved.scaleX, saved.offsetX or 0, saved.scaleY, saved.offsetY or 0)
                        end
                        local sVal = saved.scale or globalScale
                        if sVal and sVal ~= 1.0 then
                            local s = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", btn)
                            s.Scale = sVal
                        end
                    elseif globalScale and globalScale ~= 1.0 then
                        local s = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", btn)
                        s.Scale = globalScale
                    end
                end
            end
        end
    end)
end
ControlsHUD.LoadLayout = loadControlsLayoutFromFile

local function cancelEditControlsMode()
    ControlsHUD.IsEditing = false
    cleanupHudOverlays()

    if ControlsHUD.EditTopBanner then
        ControlsHUD.EditTopBanner.Visible = false
    end

    for name, pos in pairs(ControlsHUD.OriginalLayout) do
        for _, b in ipairs(getBloxFruitsControlButtons()) do
            if b.Name == name then
                b.Position = pos
            end
        end
    end

    if ControlsHUD.OnModeChanged then
        pcall(ControlsHUD.OnModeChanged, false, "discarded")
    end
end
ControlsHUD.CancelEdit = cancelEditControlsMode

local function setEditControlsMode(enabled)
    ControlsHUD.IsEditing = enabled
    cleanupHudOverlays()

    if not enabled then
        if ControlsHUD.EditTopBanner then
            ControlsHUD.EditTopBanner.Visible = false
        end
        saveControlsLayoutToFile()
        if ControlsHUD.OnModeChanged then
            pcall(ControlsHUD.OnModeChanged, false, "saved")
        end
        return
    end

    local overlayGui = ControlsHUD.EditOverlayGui
    if not overlayGui or not overlayGui.Parent then
        local sg = Instance.new("ScreenGui")
        sg.Name = "Darling_HUDOverlay"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        safeParent(sg)
        ControlsHUD.EditOverlayGui = sg
        overlayGui = sg
    end

    if not ControlsHUD.EditTopBanner or not ControlsHUD.EditTopBanner.Parent then
        local bar = Instance.new("Frame")
        bar.Name = "TopBanner"
        bar.Size = UDim2.new(0, 440, 0, 42)
        bar.Position = UDim2.new(0.5, -220, 0, 15)
        bar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
        bar.BackgroundTransparency = 0.15
        bar.BorderSizePixel = 0
        bar.Parent = overlayGui

        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 8)
        barCorner.Parent = bar

        local barStroke = Instance.new("UIStroke")
        barStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        barStroke.Color = Color3.fromRGB(60, 60, 80)
        barStroke.Thickness = 1.2
        barStroke.Parent = bar

        local lbl = Instance.new("TextLabel")
        lbl.Name = "BannerTitle"
        lbl.Size = UDim2.new(0, 180, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = "HUD Drag Active (Touch / Mouse)"
        lbl.TextSize = 11.5
        lbl.TextColor3 = Color3.fromRGB(240, 240, 250)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = bar

        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Name = "CancelBtn"
        cancelBtn.Size = UDim2.new(0, 100, 0, 28)
        cancelBtn.Position = UDim2.new(1, -220, 0, 7)
        cancelBtn.BackgroundColor3 = Color3.fromRGB(36, 26, 32)
        cancelBtn.Text = ""
        cancelBtn.AutoButtonColor = false
        cancelBtn.Parent = bar

        local cLbl = Instance.new("TextLabel", cancelBtn)
        cLbl.Size = UDim2.new(1, 0, 1, 0)
        cLbl.BackgroundTransparency = 1
        cLbl.Font = Enum.Font.GothamBold
        cLbl.Text = "Discard"
        cLbl.TextColor3 = Color3.fromRGB(255, 200, 210)
        cLbl.TextSize = 11

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 6)
        cCorner.Parent = cancelBtn

        local cStroke = Instance.new("UIStroke")
        cStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        cStroke.Color = Color3.fromRGB(80, 45, 55)
        cStroke.Thickness = 1
        cStroke.Parent = cancelBtn

        cancelBtn.MouseButton1Click:Connect(cancelEditControlsMode)

        local doneBtn = Instance.new("TextButton")
        doneBtn.Name = "DoneBtn"
        doneBtn.Size = UDim2.new(0, 105, 0, 28)
        doneBtn.Position = UDim2.new(1, -114, 0, 7)
        doneBtn.BackgroundColor3 = Color3.fromRGB(26, 28, 38)
        doneBtn.Text = ""
        doneBtn.AutoButtonColor = false
        doneBtn.Parent = bar

        local dLbl = Instance.new("TextLabel", doneBtn)
        dLbl.Size = UDim2.new(1, 0, 1, 0)
        dLbl.BackgroundTransparency = 1
        dLbl.Font = Enum.Font.GothamBold
        dLbl.Text = "Save & Lock"
        dLbl.TextColor3 = Color3.fromRGB(240, 245, 255)
        dLbl.TextSize = 11

        local dCorner = Instance.new("UICorner")
        dCorner.CornerRadius = UDim.new(0, 6)
        dCorner.Parent = doneBtn

        local dStroke = Instance.new("UIStroke")
        dStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        dStroke.Color = Color3.fromRGB(180, 195, 230)
        dStroke.Thickness = 1
        dStroke.Parent = doneBtn

        doneBtn.MouseButton1Click:Connect(function()
            setEditControlsMode(false)
        end)

        ControlsHUD.EditTopBanner = bar
    else
        ControlsHUD.EditTopBanner.Visible = true
    end

    local targetButtons = getBloxFruitsControlButtons()
    local cam = Workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(800, 600)

    for _, btn in ipairs(targetButtons) do
        if not ControlsHUD.OriginalLayout[btn.Name] then
            ControlsHUD.OriginalLayout[btn.Name] = btn.Position
        end

        local posX = btn.AbsolutePosition.X
        local posY = btn.AbsolutePosition.Y
        local sizeW = math.max(btn.AbsoluteSize.X, 36)
        local sizeH = math.max(btn.AbsoluteSize.Y, 36)

        if posX <= 0 and posY <= 0 then
            if btn.Position.X.Scale > 0 or btn.Position.Y.Scale > 0 or btn.Position.X.Offset > 0 or btn.Position.Y.Offset > 0 then
                posX = math.clamp(btn.Position.X.Scale * vp.X + btn.Position.X.Offset, 10, vp.X - 70)
                posY = math.clamp(btn.Position.Y.Scale * vp.Y + btn.Position.Y.Offset, 10, vp.Y - 70)
            else
                local defaultOffsets = {
                    ["Z"] = {x = -130, y = -190}, ["Skill_Z"] = {x = -130, y = -190},
                    ["X"] = {x = -70, y = -190},  ["Skill_X"] = {x = -70, y = -190},
                    ["C"] = {x = -130, y = -130}, ["Skill_C"] = {x = -130, y = -130},
                    ["V"] = {x = -70, y = -130},  ["Skill_V"] = {x = -70, y = -130},
                    ["F"] = {x = -190, y = -160}, ["Skill_F"] = {x = -190, y = -160},
                    ["Dash"] = {x = -190, y = -95},
                    ["Jump"] = {x = -70, y = -70},
                }
                local off = defaultOffsets[btn.Name] or {x = -100, y = -100}
                posX = vp.X + off.x
                posY = vp.Y + off.y
            end
        end

        local ov = Instance.new("TextButton")
        ov.Name = "Overlay_" .. btn.Name
        ov.Size = UDim2.new(0, sizeW, 0, sizeH)
        ov.Position = UDim2.new(0, posX, 0, posY)
        ov.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        ov.BackgroundTransparency = 0.35
        ov.BorderSizePixel = 0
        ov.Active = true
        ov.Selectable = false
        ov.ZIndex = 250
        ov.Parent = overlayGui

        local cleanName = btn.Name:gsub("ContextAction", ""):gsub("Button", ""):gsub("Mobile", ""):gsub("Skill_", "")
        if cleanName == "Jump" or btn.Name == "JumpButton" then cleanName = "Jump"
        elseif cleanName:find("Dash") then cleanName = "Dash"
        end
        if #cleanName > 9 then cleanName = cleanName:sub(1, 7) .. ".." end
        ov.Text = cleanName
        ov.TextColor3 = Color3.fromRGB(245, 240, 255)
        ov.TextSize = 11
        ov.Font = Enum.Font.GothamBold

        local ovCorner = Instance.new("UICorner")
        ovCorner.CornerRadius = UDim.new(0, 6)
        ovCorner.Parent = ov

        local ovStroke = Instance.new("UIStroke")
        ovStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ovStroke.Color = Color3.fromRGB(160, 175, 215)
        ovStroke.Thickness = 1.2
        ovStroke.Parent = ov

        table.insert(ControlsHUD.Overlays, ov)

        local dragging = false
        local dragStart = nil
        local startBtnPos = nil
        local startOvPos = nil

        local c1 = ov.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local mPos = UserInputService:GetMouseLocation()
                dragStart = Vector3.new(mPos.X, mPos.Y, 0)
                startBtnPos = btn.Position
                startOvPos = ov.Position
            end
        end)

        local c2 = UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local mPos = UserInputService:GetMouseLocation()
                local curPos = Vector3.new(mPos.X, mPos.Y, 0)
                local deltaX = curPos.X - dragStart.X
                local deltaY = curPos.Y - dragStart.Y
                btn.Position = UDim2.new(
                    startBtnPos.X.Scale,
                    startBtnPos.X.Offset + deltaX,
                    startBtnPos.Y.Scale,
                    startBtnPos.Y.Offset + deltaY
                )
                ov.Position = UDim2.new(
                    startOvPos.X.Scale,
                    startOvPos.X.Offset + deltaX,
                    startOvPos.Y.Scale,
                    startOvPos.Y.Offset + deltaY
                )
            end
        end)

        local c3 = UserInputService.InputEnded:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = false
                _G.Darling_ControlsLayout[btn.Name] = _G.Darling_ControlsLayout[btn.Name] or {}
                _G.Darling_ControlsLayout[btn.Name].scaleX = btn.Position.X.Scale
                _G.Darling_ControlsLayout[btn.Name].offsetX = btn.Position.X.Offset
                _G.Darling_ControlsLayout[btn.Name].scaleY = btn.Position.Y.Scale
                _G.Darling_ControlsLayout[btn.Name].offsetY = btn.Position.Y.Offset
            end
        end)

        table.insert(ControlsHUD.DragConnections, c1)
        table.insert(ControlsHUD.DragConnections, c2)
        table.insert(ControlsHUD.DragConnections, c3)
    end

    if ControlsHUD.OnModeChanged then
        pcall(ControlsHUD.OnModeChanged, true, "active")
    end
end
ControlsHUD.SetEditMode = setEditControlsMode

local function resetControlsLayout()
    for _, path in ipairs(getLayoutConfigPaths()) do
        if isfile and isfile(path) and delfile then
            pcall(function() delfile(path) end)
        end
    end

    _G.Darling_ControlsLayout = {}
    ControlsHUD.GlobalScale = 1.0

    for name, pos in pairs(ControlsHUD.OriginalLayout) do
        for _, b in ipairs(getBloxFruitsControlButtons()) do
            if b.Name == name then
                b.Position = pos
            end
        end
    end

    for _, b in ipairs(getBloxFruitsControlButtons()) do
        local s = b:FindFirstChildOfClass("UIScale")
        if s then s.Scale = 1.0 end
    end

    if ControlsHUD.OnModeChanged then
        pcall(ControlsHUD.OnModeChanged, false, "reset")
    end
end
ControlsHUD.ResetLayout = resetControlsLayout

local function setControlsScale(val)
    local num = tonumber(val) or 1.0
    num = math.clamp(num, 0.50, 2.00)
    ControlsHUD.GlobalScale = num
    _G.Darling_ControlsLayout.globalScale = num

    for _, btn in ipairs(getBloxFruitsControlButtons()) do
        local s = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", btn)
        s.Scale = num
    end

    saveControlsLayoutToFile()
end
ControlsHUD.SetScale = setControlsScale

-- Safeguard: Ensure hotbar is never scaled or displaced by old configs
pcall(function()
    local pGui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pGui then
        local main = pGui:FindFirstChild("Main")
        local bp = pGui:FindFirstChild("Backpack")
        local candidates = {
            main and main:FindFirstChild("Hotbar"),
            bp and (bp:FindFirstChild("Hotbar") or bp:FindFirstChild("Container"))
        }
        for _, hb in ipairs(candidates) do
            if hb and hb:IsA("GuiObject") then
                local sc = hb:FindFirstChildOfClass("UIScale")
                if sc then sc:Destroy() end
            end
        end
    end
end)

task.spawn(function()
    task.wait(1.5)
    loadControlsLayoutFromFile()
end)

return ControlsHUD
