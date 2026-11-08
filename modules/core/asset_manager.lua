--[[
    BestHub - modules/core/asset_manager.lua
    Universal Asset Loader with getcustomasset and local disk caching.
    Downloads missing assets from GitHub raw repository and caches locally.
]]

local AssetManager = {}

local exGetCustomAsset = getcustomasset or getsynasset or (getgenv and (getgenv().getcustomasset or getgenv().getsynasset)) or (syn and syn.get_custom_asset)
local exWriteFile = writefile or (getgenv and getgenv().writefile) or (syn and syn.writefile)
local exReadFile = readfile or (getgenv and getgenv().readfile) or (syn and syn.readfile)
local exIsFile = isfile or is_file or (getgenv and getgenv().isfile) or (syn and syn.isfile)
local exIsFolder = isfolder or is_folder or (getgenv and getgenv().isfolder) or (syn and syn.isfolder)
local exMakeFolder = makefolder or make_folder or (getgenv and getgenv().makefolder) or (syn and syn.makefolder)
local exRequest = request or http_request or (syn and syn.request) or (http and http.request)

local BASE_URL = "https://raw.githubusercontent.com/rivals-hash/idk/main/assets/"
local CACHE_FOLDER = "Monody_Assets_v3"

pcall(function()
    if exMakeFolder and exIsFolder then
        if not exIsFolder(CACHE_FOLDER) then
            exMakeFolder(CACHE_FOLDER)
        end
    end
end)

local resolvedCache = {}

function AssetManager.get(filename, fallbackId)
    if resolvedCache[filename] then
        return resolvedCache[filename]
    end

    local localDiskPath = CACHE_FOLDER .. "/" .. filename

    -- 1. Check local executor cache first
    if exIsFile and exGetCustomAsset then
        local ok, exists = pcall(exIsFile, localDiskPath)
        if ok and exists then
            local okA, custom = pcall(exGetCustomAsset, localDiskPath)
            if okA and type(custom) == "string" and #custom > 0 then
                resolvedCache[filename] = custom
                return custom
            end
        end
    end

    -- 2. Check local dev directories (for testing on PC / Linux)
    local devCandidates = {
        "assets/" .. filename,
        "idk/assets/" .. filename,
        "BestHub/assets/" .. filename,
        "darling-hub/assets/" .. filename
    }
    if exIsFile and exGetCustomAsset then
        for _, dp in ipairs(devCandidates) do
            local ok, exists = pcall(exIsFile, dp)
            if ok and exists then
                local okA, custom = pcall(exGetCustomAsset, dp)
                if okA and type(custom) == "string" and #custom > 0 then
                    resolvedCache[filename] = custom
                    return custom
                end
            end
        end
    end

    -- 3. Download from GitHub raw repository
    local rawUrl = BASE_URL .. filename
    local data = nil
    pcall(function()
        if exRequest then
            local res = exRequest({ Url = rawUrl, Method = "GET" })
            if res and (res.StatusCode == 200 or res.Status == 200) and res.Body and #res.Body > 50 then
                data = res.Body
            end
        end
        if not data then
            data = game:HttpGet(rawUrl, true)
        end
    end)

    if data and #data > 50 and exWriteFile and exGetCustomAsset then
        pcall(function()
            if exMakeFolder and exIsFolder and not exIsFolder(CACHE_FOLDER) then
                exMakeFolder(CACHE_FOLDER)
            end
            exWriteFile(localDiskPath, data)
        end)
        local okA, custom = pcall(exGetCustomAsset, localDiskPath)
        if okA and type(custom) == "string" and #custom > 0 then
            resolvedCache[filename] = custom
            return custom
        end
    end

    -- 4. Fallback to Roblox Asset ID
    resolvedCache[filename] = fallbackId
    return fallbackId
end

return AssetManager
