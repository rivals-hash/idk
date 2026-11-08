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
local CACHE_FOLDER = "Monody_Assets_v5"

-- Candidate folders to look for already cached files
local CANDIDATE_FOLDERS = {
    CACHE_FOLDER,
    "Monody_Assets_v4",
    "Monody_Assets_v3",
    "Monody_Assets_v2",
    "Monody_Assets",
    "assets",
    "idk/assets",
    "BestHub/assets",
    "darling-hub/assets"
}

pcall(function()
    if exMakeFolder and exIsFolder then
        if not exIsFolder(CACHE_FOLDER) then
            exMakeFolder(CACHE_FOLDER)
        end
    end
end)

local resolvedCache = {}
local downloadCallbacks = {}
local isDownloading = {}

-- Try to resolve from disk immediately (0 latency, 0 freeze)
local function resolveFromDisk(filename)
    if not (exIsFile and exGetCustomAsset) then return nil end
    for _, folder in ipairs(CANDIDATE_FOLDERS) do
        local path = folder .. "/" .. filename
        local ok, exists = pcall(exIsFile, path)
        if ok and exists then
            local okA, custom = pcall(exGetCustomAsset, path)
            if okA and type(custom) == "string" and #custom > 0 then
                return custom
            end
        end
    end
    return nil
end

-- Asynchronous non-blocking download via task.spawn
local function triggerAsyncDownload(filename, onComplete)
    if onComplete then
        downloadCallbacks[filename] = downloadCallbacks[filename] or {}
        table.insert(downloadCallbacks[filename], onComplete)
    end

    if isDownloading[filename] then return end
    isDownloading[filename] = true

    task.spawn(function()
        local rawUrl = BASE_URL .. filename
        local data = nil

        pcall(function()
            if exRequest then
                local res = exRequest({ Url = rawUrl, Method = "GET" })
                if res and (res.StatusCode == 200 or res.Status == 200) and res.Body and #res.Body > 50 then
                    data = res.Body
                end
            end
            if not data and game and game.HttpGet then
                data = game:HttpGet(rawUrl, true)
            end
        end)

        local resolved = nil
        if data and #data > 50 and exWriteFile and exGetCustomAsset then
            local targetPath = CACHE_FOLDER .. "/" .. filename
            pcall(function()
                if exMakeFolder and exIsFolder and not exIsFolder(CACHE_FOLDER) then
                    exMakeFolder(CACHE_FOLDER)
                end
                exWriteFile(targetPath, data)
            end)
            local okA, custom = pcall(exGetCustomAsset, targetPath)
            if okA and type(custom) == "string" and #custom > 0 then
                resolved = custom
            end
        end

        isDownloading[filename] = false
        if resolved then
            resolvedCache[filename] = resolved
            local cbs = downloadCallbacks[filename]
            downloadCallbacks[filename] = nil
            if cbs then
                for _, cb in ipairs(cbs) do
                    pcall(cb, resolved)
                end
            end
        end
    end)
end

function AssetManager.get(filename, fallbackId, onReady)
    if resolvedCache[filename] then
        if onReady then pcall(onReady, resolvedCache[filename]) end
        return resolvedCache[filename]
    end

    -- 1. Check local disk cache (instant)
    local diskAsset = resolveFromDisk(filename)
    if diskAsset then
        resolvedCache[filename] = diskAsset
        if onReady then pcall(onReady, diskAsset) end
        return diskAsset
    end

    -- 2. Trigger async background download without freezing frame
    triggerAsyncDownload(filename, onReady)

    -- Return fallback immediately so UI loads with 0 lag
    return fallbackId or ""
end

function AssetManager.bindImage(imageObject, filename, fallbackId)
    if not imageObject then return end
    local asset = AssetManager.get(filename, fallbackId, function(newUri)
        if imageObject and imageObject.Parent then
            pcall(function()
                imageObject.Image = newUri
            end)
        end
    end)
    if asset and #asset > 0 then
        pcall(function()
            imageObject.Image = asset
        end)
    end
end

return AssetManager
