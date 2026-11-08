--[[
    Darling Hub - Translations Proxy Module (Version 1.4)
    Delegates localization to modular on-demand translations hub.
]]

local hub = _G.DarlingHub or (getgenv and getgenv().DarlingHub)
if hub and hub.Require then
    local mod = hub:Require("modules/core/translations/init.lua")
    if mod then return mod end
end

local ok, initMod = pcall(loadfile, "modules/core/translations/init.lua")
if ok and type(initMod) == "function" then
    local okExec, res = pcall(initMod)
    if okExec and type(res) == "table" then
        return res
    end
end

return loadfile("modules/core/translations/init.lua")()
