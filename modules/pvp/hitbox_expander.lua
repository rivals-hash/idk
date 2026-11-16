--[[
    Monody Premium - PvP Hitbox Expander Engine
    Aesthetic custom hitbox expansion with soft-pulse shader & non-skidded presentation.
    Supports adjustable size, clean restore, CanCollide safety, and team filtering.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local HitboxExpander = {
    Enabled = false,
    Size = 25,
    Transparency = 0.65,
    ShowVisuals = true,
    Color = Color3.fromRGB(180, 80, 240),
    OriginalSizes = {},
    LoopConn = nil
}

local function isEnemy(player)
    if not player or player == lp then return false end
    if not player.Character then return false end
    local myTeam = lp and lp.Team
    local theirTeam = player.Team
    if myTeam and theirTeam and myTeam == theirTeam and myTeam.Name == "Marines" then
        return false
    end
    return true
end

local function restoreTarget(hrp)
    if hrp and hrp.Parent then
        local orig = HitboxExpander.OriginalSizes[hrp]
        if orig then
            pcall(function()
                hrp.Size = orig.size
                hrp.Transparency = orig.transparency
                hrp.CanCollide = orig.canCollide
            end)
            HitboxExpander.OriginalSizes[hrp] = nil
        end
    end
end

local function applyHitbox(player)
    if not HitboxExpander.Enabled then return end
    if not isEnemy(player) then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not HitboxExpander.OriginalSizes[hrp] then
        HitboxExpander.OriginalSizes[hrp] = {
            size = hrp.Size,
            transparency = hrp.Transparency,
            canCollide = hrp.CanCollide
        }
    end

    pcall(function()
        hrp.Size = Vector3.new(HitboxExpander.Size, HitboxExpander.Size, HitboxExpander.Size)
        hrp.CanCollide = false
        if HitboxExpander.ShowVisuals then
            hrp.Transparency = HitboxExpander.Transparency
            hrp.Material = Enum.Material.ForceField
            hrp.Color = HitboxExpander.Color
        else
            hrp.Transparency = 1
        end
    end)
end

function HitboxExpander.SetEnabled(state)
    HitboxExpander.Enabled = (state == true)
    if HitboxExpander.Enabled then
        if not HitboxExpander.LoopConn then
            HitboxExpander.LoopConn = RunService.Heartbeat:Connect(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lp then applyHitbox(p) end
                end
            end)
        end
    else
        if HitboxExpander.LoopConn then
            HitboxExpander.LoopConn:Disconnect()
            HitboxExpander.LoopConn = nil
        end
        for hrp, _ in pairs(HitboxExpander.OriginalSizes) do
            restoreTarget(hrp)
        end
        table.clear(HitboxExpander.OriginalSizes)
    end
end

function HitboxExpander.SetSize(newSize)
    HitboxExpander.Size = math.clamp(tonumber(newSize) or 25, 10, 50)
    if HitboxExpander.Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then applyHitbox(p) end
        end
    end
end

function HitboxExpander.SetVisuals(show)
    HitboxExpander.ShowVisuals = (show == true)
    if HitboxExpander.Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then applyHitbox(p) end
        end
    end
end

return HitboxExpander
