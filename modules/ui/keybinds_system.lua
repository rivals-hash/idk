--[[
    Darling Hub - PC Keybinds System
    Universal keybind manager for any button or toggle in the hub.
    Supports Toggle mode, Hold/Release mode, and instant Press mode.
    No default keybinds (starts empty). Full config persistence.
]]

local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local KeybindsSystem = {
    List = {},
    Bindables = {},
    ListeningForIndex = nil,
    OnChanged = nil,
    Loaded = false,
}

local CONFIG_FILE = "DarlingX_Keybinds.json"
local inputBeganConn = nil
local inputEndedConn = nil

local exIsFile = isfile or is_file
local exReadFile = readfile or read_file
local exWriteFile = writefile or write_file

function KeybindsSystem.RegisterBindable(name, kind, data)
    if not name or name == "" then return end
    KeybindsSystem.Bindables[name] = {
        name = name,
        kind = kind or "Toggle",
        get = data and data.get or function() return false end,
        set = data and data.set or function(v) end,
        toggle = data and data.toggle or function() end,
        trigger = data and data.trigger or function() end,
    }
end

function KeybindsSystem.GetBindable(name)
    if KeybindsSystem.Bindables[name] then
        return KeybindsSystem.Bindables[name]
    end
    if _G.DarlingX_Bindables and _G.DarlingX_Bindables[name] then
        return _G.DarlingX_Bindables[name]
    end
    if _G.UI_TOGGLES and _G.UI_TOGGLES[name] then
        local t = _G.UI_TOGGLES[name]
        return {
            name = name,
            kind = "Toggle",
            get = t.get or function() return false end,
            set = function(v) if t.set then t.set(v, true) end end,
            toggle = function()
                if t.get and t.set then
                    t.set(not t.get(), true)
                end
            end,
        }
    end
    return nil
end

function KeybindsSystem.GetAllBindablesList()
    local names = {}
    local seen = {}

    for name, _ in pairs(KeybindsSystem.Bindables) do
        if not seen[name] then
            seen[name] = true
            table.insert(names, name)
        end
    end

    if _G.DarlingX_Bindables then
        for name, _ in pairs(_G.DarlingX_Bindables) do
            if not seen[name] then
                seen[name] = true
                table.insert(names, name)
            end
        end
    end

    if _G.UI_TOGGLES then
        for name, _ in pairs(_G.UI_TOGGLES) do
            if not seen[name] then
                seen[name] = true
                table.insert(names, name)
            end
        end
    end

    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names
end

function KeybindsSystem.AddKeybind(targetName, keyName, mode)
    if not targetName or not keyName then return end
    local b = KeybindsSystem.GetBindable(targetName)
    local defaultMode = (b and b.kind == "Button") and "Press" or "Toggle"

    table.insert(KeybindsSystem.List, {
        target = targetName,
        key = keyName,
        mode = mode or defaultMode,
        isHeld = false,
    })

    KeybindsSystem.Save()
    if KeybindsSystem.OnChanged then
        pcall(KeybindsSystem.OnChanged)
    end
end

function KeybindsSystem.RemoveKeybind(index)
    if KeybindsSystem.List[index] then
        table.remove(KeybindsSystem.List, index)
        KeybindsSystem.Save()
        if KeybindsSystem.OnChanged then
            pcall(KeybindsSystem.OnChanged)
        end
    end
end

function KeybindsSystem.ClearAll()
    KeybindsSystem.List = {}
    KeybindsSystem.Save()
    if KeybindsSystem.OnChanged then
        pcall(KeybindsSystem.OnChanged)
    end
end

function KeybindsSystem.SetKey(index, keyName)
    if KeybindsSystem.List[index] and keyName then
        KeybindsSystem.List[index].key = keyName
        KeybindsSystem.Save()
        if KeybindsSystem.OnChanged then
            pcall(KeybindsSystem.OnChanged)
        end
    end
end

function KeybindsSystem.SetMode(index, mode)
    if KeybindsSystem.List[index] and mode then
        KeybindsSystem.List[index].mode = mode
        KeybindsSystem.Save()
        if KeybindsSystem.OnChanged then
            pcall(KeybindsSystem.OnChanged)
        end
    end
end

function KeybindsSystem.Save()
    if not exWriteFile then return end
    local data = {}
    for _, item in ipairs(KeybindsSystem.List) do
        table.insert(data, {
            target = item.target,
            key = item.key,
            mode = item.mode or "Toggle",
        })
    end
    pcall(function()
        exWriteFile(CONFIG_FILE, HttpService:JSONEncode(data))
    end)
end

function KeybindsSystem.Load()
    if KeybindsSystem.Loaded then return end
    KeybindsSystem.Loaded = true
    if not exIsFile or not exReadFile then return end

    local ok, content = pcall(function()
        if exIsFile(CONFIG_FILE) then
            return exReadFile(CONFIG_FILE)
        end
        return nil
    end)

    if ok and content and #content > 2 then
        local okDecode, decoded = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if okDecode and type(decoded) == "table" then
            KeybindsSystem.List = {}
            for _, item in ipairs(decoded) do
                if type(item) == "table" and item.target and item.key then
                    table.insert(KeybindsSystem.List, {
                        target = tostring(item.target),
                        key = tostring(item.key),
                        mode = item.mode or "Toggle",
                        isHeld = false,
                    })
                end
            end
        end
    end
end

function KeybindsSystem.Init()
    KeybindsSystem.Load()

    if inputBeganConn then inputBeganConn:Disconnect() end
    if inputEndedConn then inputEndedConn:Disconnect() end

    inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

        local keyName = input.KeyCode.Name

        for _, item in ipairs(KeybindsSystem.List) do
            if item.key == keyName then
                local b = KeybindsSystem.GetBindable(item.target)
                if b then
                    if item.mode == "Toggle" then
                        if b.kind == "Toggle" then
                            b.toggle()
                        else
                            b.trigger()
                        end
                    elseif item.mode == "Hold" then
                        item.isHeld = true
                        if b.kind == "Toggle" then
                            b.set(true)
                        else
                            b.trigger()
                        end
                    elseif item.mode == "Press" then
                        if b.kind == "Button" then
                            b.trigger()
                        else
                            b.toggle()
                        end
                    end
                end
            end
        end
    end)

    inputEndedConn = UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

        local keyName = input.KeyCode.Name

        for _, item in ipairs(KeybindsSystem.List) do
            if item.key == keyName and item.mode == "Hold" then
                item.isHeld = false
                local b = KeybindsSystem.GetBindable(item.target)
                if b and b.kind == "Toggle" then
                    b.set(false)
                end
            end
        end
    end)
end

_G.DarlingX_KeybindsSystem = KeybindsSystem
return KeybindsSystem
