--[[
    Darling X - Buddha Rainbow Circle
    Cosmetic and visible on your client only.
    Recolors Buddha circle with dynamic animated rainbow gradient.
    Works before or after transforming into Buddha.
]]

local cloneref = cloneref or function(o) return o end
local function service(name) return cloneref(game:GetService(name)) end

local Players = service("Players")
local RunService = service("RunService")
local Workspace = service("Workspace")
local player = Players.LocalPlayer

local BuddhaRainbow = {
    Enabled = false,
    CycleSeconds = 5,
    OnlyMyCircle = true,
}

local KEY = "DarlingBuddhaRainbowCircle"
local candidates = {}
local active = {}
local connections = {}
local hue = 0
local elapsed = 0
local reported = false
local circleAsset = "6960307279"

local function billboardOf(image)
    if not image then return nil end
    return image:FindFirstAncestorWhichIsA("BillboardGui")
end

local function isCircle(image)
    if not (image and (image:IsA("ImageLabel") or image:IsA("ImageButton"))) then
        return false
    end
    local billboard = billboardOf(image)
    return billboard ~= nil and (billboard.Name == "BuddhaBillboard"
        or tostring(image.Image):match("%d+") == circleAsset)
end

local function belongsToMe(image)
    if not BuddhaRainbow.OnlyMyCircle then return true end
    local billboard = billboardOf(image)
    if not billboard then return false end
    local character = player.Character
    if billboard:IsDescendantOf(player) then return true end
    if character and billboard:IsDescendantOf(character) then return true end
    local adornee = billboard.Adornee
    if not adornee then return false end
    return character ~= nil and (adornee == character or adornee:IsDescendantOf(character))
end

local function restore(image)
    local entry = active[image]
    if not entry then return end
    if entry.Gradient and entry.Gradient.Parent then
        pcall(function() entry.Gradient:Destroy() end)
    end
    if image.Parent then
        pcall(function()
            image.ImageColor3 = entry.OriginalColor or Color3.new(1, 1, 1)
            for gradient, enabled in pairs(entry.OtherGradients or {}) do
                if gradient and gradient.Parent == image then
                    gradient.Enabled = enabled
                end
            end
        end)
    end
    active[image] = nil
end

local function apply(image, sequence)
    local entry = active[image]
    if not entry then
        entry = { OriginalColor = image.ImageColor3, OtherGradients = {} }
        for _, child in ipairs(image:GetChildren()) do
            if child:IsA("UIGradient") then
                entry.OtherGradients[child] = child.Enabled
                child.Enabled = false
            end
        end
        local gradient = Instance.new("UIGradient")
        gradient.Name = "DarlingBuddhaRainbow"
        gradient.Color = sequence
        gradient.Parent = image
        entry.Gradient = gradient
        active[image] = entry
    end
    image.ImageColor3 = Color3.new(1, 1, 1)
    if entry.Gradient and entry.Gradient.Parent then
        entry.Gradient.Color = sequence
        entry.Gradient.Rotation = (hue * 360) % 360
    end
    if not reported then
        reported = true
    end
end

local function consider(instance)
    if isCircle(instance) then candidates[instance] = true end
end

local function watch(root)
    if not root then return end
    local conn = root.DescendantAdded:Connect(function(instance)
        task.defer(function()
            if not BuddhaRainbow.Enabled or not instance.Parent then return end
            consider(instance)
            if instance:IsA("BillboardGui") then
                for _, child in ipairs(instance:GetDescendants()) do consider(child) end
            end
        end)
    end)
    table.insert(connections, conn)
    for _, instance in ipairs(root:GetDescendants()) do consider(instance) end
end

function BuddhaRainbow.start()
    if BuddhaRainbow.Enabled then return end
    BuddhaRainbow.Enabled = true
    _G[KEY] = BuddhaRainbow

    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    connections = {}

    watch(Workspace)
    watch(player)

    local heartbeatConn = RunService.Heartbeat:Connect(function(dt)
        if not BuddhaRainbow.Enabled then return end
        hue = (hue + dt / math.max(BuddhaRainbow.CycleSeconds, 0.1)) % 1
        elapsed = elapsed + dt
        if elapsed < 1 / 20 then return end
        elapsed = 0

        local points = {}
        for index = 0, 6 do
            points[#points + 1] = ColorSequenceKeypoint.new(index / 6,
                Color3.fromHSV((hue + index / 6) % 1, 1, 1))
        end
        local sequence = ColorSequence.new(points)

        for image in pairs(candidates) do
            if not image.Parent then
                restore(image)
                candidates[image] = nil
            elseif not isCircle(image) then
                restore(image)
                candidates[image] = nil
            elseif belongsToMe(image) then
                apply(image, sequence)
            else
                restore(image)
            end
        end
    end)
    table.insert(connections, heartbeatConn)
end

function BuddhaRainbow.stop()
    BuddhaRainbow.Enabled = false
    for _, connection in ipairs(connections) do
        pcall(function() connection:Disconnect() end)
    end
    connections = {}

    local images = {}
    for image in pairs(active) do images[#images + 1] = image end
    for _, image in ipairs(images) do restore(image) end
    active = {}
    candidates = {}

    if _G[KEY] == BuddhaRainbow then _G[KEY] = nil end
end

function BuddhaRainbow.toggle(state)
    if state ~= nil then
        if state then BuddhaRainbow.start() else BuddhaRainbow.stop() end
    else
        if BuddhaRainbow.Enabled then BuddhaRainbow.stop() else BuddhaRainbow.start() end
    end
    return BuddhaRainbow.Enabled
end

function BuddhaRainbow.isEnabled()
    return BuddhaRainbow.Enabled == true
end

_G.DarlingX_BuddhaRainbow = BuddhaRainbow
return BuddhaRainbow
