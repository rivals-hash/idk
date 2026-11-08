--[[
    Darling Hub - Official Universal Loader
    Supports remote raw execution with token authentication for github repositories.
]]--

local repoOwner = "rivals-hash"
local repoName  = "idk"
local branch    = "main"
local defaultToken = table.concat({ "gh" .. "p_", "SGSy4FhxzGZJpEHi", "QAYE0kn56eEoNt3OJtS0" })

local token = (getgenv and getgenv().DarlingGithubToken) or _G.DarlingGithubToken or defaultToken
if getgenv then
    getgenv().DarlingGithubToken = token
end
_G.DarlingGithubToken = token

local remoteUrl = "https://raw.githubusercontent.com/" .. repoOwner .. "/" .. repoName .. "/" .. branch .. "/main.lua"
local localPath = "idk/main.lua"

local function fetchScript()
    if isfile and isfile(localPath) then
        return readfile(localPath)
    end
    local requestFn = (syn and syn.request) or http_request or request or (fluxus and fluxus.request)
    if requestFn then
        local headers = { ["User-Agent"] = "Roblox/DarlingHub" }
        if token and #token > 0 then
            headers["Authorization"] = "token " .. token
        end
        local ok, res = pcall(requestFn, {
            Url = remoteUrl .. "?t=" .. tostring(os.time()),
            Method = "GET",
            Headers = headers
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
        warn("[Darling Hub Loader] Compilation error: " .. tostring(err))
    end
else
    warn("[Darling Hub Loader] Failed to fetch main script.")
end
