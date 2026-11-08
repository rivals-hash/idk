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
local CACHE_FOLDER = "Monody_Assets_v9"

-- Candidate folders to look for already cached files
local CANDIDATE_FOLDERS = {
    CACHE_FOLDER,
    CACHE_FOLDER .. "/backgrounds",
    "assets/backgrounds",
    "assets",
    "idk/assets/backgrounds",
    "idk/assets",
    "DarlingHub/cache",
    "Darling-hub/assets/backgrounds",
    "Darling-hub/assets",
    "BestHub/assets",
    "Monody_Assets_v9",
    "Monody_Assets_v8",
    "Monody_Assets_v7",
    "Monody_Assets_v6",
    "Monody_Assets_v5",
    "Monody_Assets_v4",
    "Monody_Assets_v3",
    "Monody_Assets_v2",
    "Monody_Assets"
}

pcall(function()
    if exMakeFolder and exIsFolder then
        if not exIsFolder(CACHE_FOLDER) then
            exMakeFolder(CACHE_FOLDER)
        end
        local bgFolder = CACHE_FOLDER .. "/backgrounds"
        if not exIsFolder(bgFolder) then
            exMakeFolder(bgFolder)
        end
    end
end)

local resolvedCache = {}

-- Try to resolve from disk immediately (0 latency, 0 freeze)
local function resolveFromDisk(filename)
    if not (exIsFile and exGetCustomAsset) then return nil end
    local candidates = {
        filename,
        "backgrounds/" .. filename,
    }
    for _, folder in ipairs(CANDIDATE_FOLDERS) do
        for _, rel in ipairs(candidates) do
            local path = folder .. "/" .. rel
            local ok, exists = pcall(exIsFile, path)
            if ok and exists then
                local okA, custom = pcall(exGetCustomAsset, path)
                if okA and type(custom) == "string" and #custom > 0 then
                    return custom
                end
            end
        end
    end
    return nil
end

-- Synchronous download from GitHub raw with writefile and getcustomasset
local function downloadSync(filename)
    local rawUrl = BASE_URL .. filename
    if filename:match("%.jpg$") and not filename:find("^backgrounds/") then
        rawUrl = "https://raw.githubusercontent.com/rivals-hash/idk/main/assets/backgrounds/" .. filename
    end
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
        local safeName = filename:gsub("/", "_")
        local targetPath = CACHE_FOLDER .. "/" .. safeName
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

    if resolved then
        resolvedCache[filename] = resolved
    end
    return resolved
end

-- Get background asset with guaranteed resolution
function AssetManager.getBackground(filename, fallbackId)
    if not filename or #filename == 0 then return "" end
    if filename:find("^rbxassetid://") or filename:find("^http://") or filename:find("^https://") then
        return filename
    end
    local cleanName = filename:gsub("^assets/backgrounds/", ""):gsub("^backgrounds/", "")
    local cacheKey = "bg_" .. cleanName
    if resolvedCache[cacheKey] then
        return resolvedCache[cacheKey]
    end

    local disk = resolveFromDisk(cleanName)
    if disk then
        resolvedCache[cacheKey] = disk
        return disk
    end

    local downloaded = downloadSync(cleanName)
    if downloaded then
        resolvedCache[cacheKey] = downloaded
        return downloaded
    end

    return fallbackId or ""
end

-- Get asset with guaranteed resolution
function AssetManager.get(filename, fallbackId)
    if not filename or #filename == 0 then return "" end

    if filename:match("%.jpg$") or filename:find("backgrounds") then
        return AssetManager.getBackground(filename, fallbackId)
    end

    if resolvedCache[filename] then
        return resolvedCache[filename]
    end

    -- 1. Check local disk cache (instant 0 ms)
    local diskAsset = resolveFromDisk(filename)
    if diskAsset then
        resolvedCache[filename] = diskAsset
        return diskAsset
    end

    -- 2. Download from GitHub raw repository
    local downloaded = downloadSync(filename)
    if downloaded then
        return downloaded
    end

    -- 3. If download failed, NEVER return a dead asset ID!
    if fallbackId and not fallbackId:find("139820186687064") and not fallbackId:find("10039618734") and not fallbackId:find("93891873418133") then
        return fallbackId
    end
    return ""
end

-- Helper: Bind asset to ImageLabel safely
function AssetManager.bindImage(imageObject, filename, fallbackId)
    if not imageObject then return end
    imageObject.BackgroundTransparency = 1

    local asset = AssetManager.get(filename, fallbackId)
    if asset and #asset > 0 then
        pcall(function()
            imageObject.Image = asset
        end)
    else
        task.spawn(function()
            for attempt = 1, 4 do
                task.wait(0.5 * attempt)
                if not (imageObject and imageObject.Parent) then break end
                local retryAsset = AssetManager.get(filename, fallbackId)
                if retryAsset and #retryAsset > 0 then
                    pcall(function()
                        imageObject.Image = retryAsset
                    end)
                    break
                end
            end
        end)
    end
end

-- Preload all core images
function AssetManager.preload(list)
    list = list or {
        "header_profile_panel_red.png",
        "stats_panel_red.png",
        "music_player_red.png",
        "sidebar_bg_red.png",
        "floating_avatar_red.png",
        "header_profile_panel.png",
        "stats_panel_v2.png",
        "music_player.png",
        "sidebar_bg_v2.png",
        "floating_avatar.png"
    }
    for _, fname in ipairs(list) do
        pcall(function()
            AssetManager.get(fname)
        end)
    end
end

return AssetManager
