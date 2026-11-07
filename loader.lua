--[[
    ========================================================================
    BESTHUB - UNIVERSAL LOADER
    ========================================================================
    Supports Delta, Fluxus, Codex, Arceus X, Wave, and Solara.
    Loads the latest responsive Mobile UI build directly from GitHub.
    ========================================================================
]]--

local remoteUrl = "https://raw.githubusercontent.com/rivals-hash/idk/main/main.lua"
local localPath = "idk/main.lua"

local function fetchScript()
    if isfile and isfile(localPath) then
        return readfile(localPath)
    end
    local requestFn = (syn and syn.request) or http_request or request or (fluxus and fluxus.request)
    if requestFn then
        local ok, res = pcall(requestFn, {
            Url = remoteUrl .. "?t=" .. tostring(os.time()),
            Method = "GET",
            Headers = { ["User-Agent"] = "Roblox/BestHub" }
        })
        if ok and res and (res.StatusCode == 200 or res.Status == 200) and type(res.Body) == "string" and #res.Body > 50 then
            return res.Body
        end
    end
    local okG, body = pcall(function() return game:HttpGet(remoteUrl, true) end)
    if okG and type(body) == "string" and #body > 50 then
        return body
    end
    return nil
end

local content = fetchScript()
if content and #content > 0 then
    local fn, err = loadstring(content)
    if fn then
        fn()
    else
        warn("[BestHub Loader] Compilation error: " .. tostring(err))
    end
else
    warn("[BestHub Loader] Failed to fetch main script from GitHub.")
end
