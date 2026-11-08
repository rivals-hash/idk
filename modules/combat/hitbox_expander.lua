--[[
    Darling Hub - Hitbox Expander (Nameless Engine)
    Blox Fruits Weapon Hitbox Expansion via CombatUtil.GetWeaponData Hook
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HitboxExpander = {
    Enabled = false,
    Multiplier = 20,
    MaxMultiplier = 50,
    Hooked = false,
    OriginalGetWeaponData = nil,
}

local function getCombatUtil()
    local ok, mod = pcall(function()
        local repMods = ReplicatedStorage:FindFirstChild("Modules")
        if repMods and repMods:FindFirstChild("CombatUtil") then
            return require(repMods.CombatUtil)
        elseif ReplicatedStorage:FindFirstChild("CombatUtil") then
            return require(ReplicatedStorage.CombatUtil)
        end
        return nil
    end)
    if ok and mod and type(mod) == "table" and type(mod.GetWeaponData) == "function" then
        return mod
    end
    return nil
end

local function setupHook()
    if HitboxExpander.Hooked then return true end

    local combatUtil = getCombatUtil()
    if not combatUtil then return false end

    local clonefn = clonefunction or function(f) return f end
    local hookfn = hookfunction or (hookfunc and hookfunc)
    local newccl = newcclosure or function(f) return f end

    if not hookfn then return false end

    local original = nil
    pcall(function()
        if setthreadidentity then setthreadidentity(8) end
        original = clonefn(combatUtil.GetWeaponData)
        HitboxExpander.OriginalGetWeaponData = original

        hookfn(combatUtil.GetWeaponData, newccl(function(self, name, ...)
            local data = original(self, name, ...)
            if type(data) ~= "table" then
                return data
            end

            if not HitboxExpander.Enabled then
                return data
            end

            local mult = tonumber(HitboxExpander.Multiplier) or 20
            if mult <= 1 then
                return data
            end

            local proxy = {}
            return setmetatable(proxy, {
                __index = function(_, k)
                    if k == "HitboxMagnitude" then
                        local base = tonumber(data.HitboxMagnitude) or 2
                        return base * mult
                    end
                    return data[k]
                end,
                __newindex = function(_, k, v)
                    data[k] = v
                end,
            })
        end))

        HitboxExpander.Hooked = true
    end)

    return HitboxExpander.Hooked
end

function HitboxExpander.enable()
    HitboxExpander.Enabled = true
    getgenv().tomultiply = HitboxExpander.Multiplier
    return setupHook()
end

function HitboxExpander.disable()
    HitboxExpander.Enabled = false
    getgenv().tomultiply = 1
end

function HitboxExpander.toggle(state)
    if state == nil then
        state = not HitboxExpander.Enabled
    end
    if state then
        return HitboxExpander.enable()
    else
        HitboxExpander.disable()
        return false
    end
end

function HitboxExpander.setMultiplier(val)
    local num = tonumber(val) or 20
    HitboxExpander.Multiplier = math.clamp(num, 1, HitboxExpander.MaxMultiplier)
    getgenv().tomultiply = HitboxExpander.Multiplier
end

return HitboxExpander
