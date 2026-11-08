-- music engine
local DarlingMusic = {}
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

DarlingMusic.SoundInstance = nil
DarlingMusic.CurrentTrackName = "None"
DarlingMusic.CurrentTrackId = ""
DarlingMusic.Volume = 0.5
DarlingMusic.PlaybackSpeed = 1.0
DarlingMusic.Looped = true

DarlingMusic.PresetTracks = {
    { Name = "phonk", Id = "1843588265", File = "MONTAGEM BAILÃO.mp3" },
    { Name = "Darling Theme - Lo-Fi Chill", Id = "90089940136467" },
    { Name = "Anime Vibes - Aesthetic Chill", Id = "6825487739" },
    { Name = "Synthwave Night Drive", Id = "7024220379" },
    { Name = "Combat Anthem", Id = "1843588265" }
}

DarlingMusic.Favorites = {}
local FAVORITES_FILE = "darling_hub/favorites.json"

-- sound instance helper
function DarlingMusic.getSound()
    if DarlingMusic.SoundInstance and DarlingMusic.SoundInstance.Parent then
        return DarlingMusic.SoundInstance
    end
    local existing = SoundService:FindFirstChild("DarlingMusicPlayer")
    if existing and existing:IsA("Sound") then
        DarlingMusic.SoundInstance = existing
        return existing
    end
    local snd = Instance.new("Sound")
    snd.Name = "DarlingMusicPlayer"
    snd.Volume = DarlingMusic.Volume
    snd.PlaybackSpeed = DarlingMusic.PlaybackSpeed
    snd.Looped = DarlingMusic.Looped
    snd.Parent = SoundService
    DarlingMusic.SoundInstance = snd
    return snd
end

local PRESET_ROBLOX_AUDIO_IDS = {
    ["d_2fb943edb8ef"] = "1843588265",     -- Montagem Ceita
    ["d_afb0b4b1f348"] = "90089940136467", -- Montagem Fearless
    ["d_def47db76206"] = "15539566377",    -- Montagem Topaz
    ["d_dbdeeddfb5e1"] = "9114223171",     -- Spooky 3
}

-- resolve sound asset or executor file bypass
local function resolveSoundSource(identifier)
    if not identifier or identifier == "" then return nil end
    local str = tostring(identifier)

    -- check custom asset bypass
    if type(isfile) == "function" and type(getcustomasset) == "function" then
        local candidates = {
            str,
            "darling_hub/" .. str,
            str .. ".mp3",
            "darling_hub/" .. str .. ".mp3"
        }
        for _, path in ipairs(candidates) do
            local okCheck, exists = pcall(function() return isfile(path) end)
            if okCheck and exists then
                local okAsset, asset = pcall(function() return getcustomasset(path) end)
                if okAsset and asset then
                    return asset
                end
            end
        end
    end

    if str:find("rbxassetid://") or str:find("rbxasset://") then
        return str
    end

    -- Never assign raw http(s) URL directly to Sound.SoundId (Roblox does not support it)
    if str:find("http://") or str:find("https://") then
        local cleanId = PRESET_ROBLOX_AUDIO_IDS[str] or "1843588265"
        return "rbxassetid://" .. cleanId
    end

    local clean = str:gsub("%D+", "")
    if clean ~= "" then
        return "rbxassetid://" .. clean
    end

    return "rbxassetid://1843588265"
end

-- play track
function DarlingMusic.play(trackInput, trackName)
    local source = resolveSoundSource(trackInput)
    if not source or source == "" then
        return false, "Invalid sound source or asset ID"
    end

    local snd = DarlingMusic.getSound()
    pcall(function() snd:Stop() end)
    snd.SoundId = source
    snd.Volume = DarlingMusic.Volume
    snd.PlaybackSpeed = DarlingMusic.PlaybackSpeed
    snd.Looped = DarlingMusic.Looped
    pcall(function() snd:Play() end)

    DarlingMusic.CurrentTrackName = trackName or tostring(trackInput)
    DarlingMusic.CurrentTrackId = tostring(trackInput)
    return true, "Now playing: " .. DarlingMusic.CurrentTrackName
end

-- pause or resume
function DarlingMusic.pauseResume()
    local snd = DarlingMusic.getSound()
    if snd.IsPlaying then
        pcall(function() snd:Pause() end)
        return false, "Playback paused"
    else
        pcall(function() snd:Resume() end)
        return true, "Playback resumed"
    end
end

-- stop track
function DarlingMusic.stop()
    local snd = DarlingMusic.getSound()
    pcall(function() snd:Stop() end)
    DarlingMusic.CurrentTrackName = "None"
    return true, "Playback stopped"
end

-- volume control
function DarlingMusic.setVolume(volPercent)
    local v = math.clamp(tonumber(volPercent or 50) / 100, 0, 1)
    DarlingMusic.Volume = v
    local snd = DarlingMusic.getSound()
    snd.Volume = v
end

-- playback speed and pitch
function DarlingMusic.setSpeed(speedVal)
    local s = tonumber(speedVal) or 1.0
    DarlingMusic.PlaybackSpeed = s
    local snd = DarlingMusic.getSound()
    snd.PlaybackSpeed = s
end

-- loop audio
function DarlingMusic.setLooped(looped)
    DarlingMusic.Looped = (looped == true)
    local snd = DarlingMusic.getSound()
    snd.Looped = DarlingMusic.Looped
end

-- favorites persistence
function DarlingMusic.loadFavorites()
    DarlingMusic.Favorites = {}
    if type(isfile) == "function" and type(readfile) == "function" then
        local ok, exists = pcall(function() return isfile(FAVORITES_FILE) end)
        if ok and exists then
            pcall(function()
                local content = readfile(FAVORITES_FILE)
                local data = HttpService:JSONDecode(content)
                if type(data) == "table" then
                    for _, item in ipairs(data) do
                        if item.Name and item.Id then
                            table.insert(DarlingMusic.Favorites, {
                                Name = tostring(item.Name),
                                Id = tostring(item.Id)
                            })
                        end
                    end
                end
            end)
        end
    end
    return DarlingMusic.Favorites
end

function DarlingMusic.saveFavorites()
    if type(writefile) == "function" and type(makefolder) == "function" then
        pcall(function()
            makefolder("darling_hub")
            local raw = HttpService:JSONEncode(DarlingMusic.Favorites)
            writefile(FAVORITES_FILE, raw)
        end)
    end
end

function DarlingMusic.addFavorite(name, id)
    if not id or id == "" then return false, "Invalid ID" end
    local cleanName = (name and name ~= "") and name or ("Track #" .. tostring(id))
    for _, item in ipairs(DarlingMusic.Favorites) do
        if item.Id == tostring(id) then
            item.Name = cleanName
            DarlingMusic.saveFavorites()
            return true, "Updated favorite: " .. cleanName
        end
    end
    table.insert(DarlingMusic.Favorites, { Name = cleanName, Id = tostring(id) })
    DarlingMusic.saveFavorites()
    return true, "Saved to favorites: " .. cleanName
end

function DarlingMusic.removeFavorite(id)
    for i, item in ipairs(DarlingMusic.Favorites) do
        if item.Id == tostring(id) or item.Name == tostring(id) then
            table.remove(DarlingMusic.Favorites, i)
            DarlingMusic.saveFavorites()
            return true, "Removed from favorites"
        end
    end
    return false, "Track not found in favorites"
end

-- launch universal youtube player
function DarlingMusic.launchYoutubePlayer()
    return pcall(function()
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua'), true))()
    end)
end

local function getActiveApiUrl()
    local hub = (_G.DarlingHub) or (getgenv and getgenv().DarlingHub)
    if hub and hub.GetApiUrl then
        return hub:GetApiUrl()
    end
    local custom = (getgenv and getgenv().DarlingCustomApi) or _G.DarlingCustomApi
    if custom and #custom > 0 then return custom end
    local ok, raw = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/rivals-hash/idk/main/api_endpoint.json")
    end)
    if ok and raw and #raw > 10 then
        local HttpService = game:GetService("HttpService")
        local okJ, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if okJ and data and data.url then return data.url end
    end
    return "https://darling-media-api.onrender.com"
end

-- Pre-warm API / Tunnel asynchronously on startup
task.spawn(function()
    pcall(function()
        local apiUrl = getActiveApiUrl()
        game:HttpGet(apiUrl .. "/health")
    end)
end)

-- play stream directly without opening external GUI
function DarlingMusic.playStream(trackId, title, fallbackAssetId)
    title = title or ("Track #" .. tostring(trackId))
    local BASE_URL = getActiveApiUrl()
    local READ_KEY = "darling_secret_key"
    local fname = "devmp3_" .. tostring(trackId) .. ".mp3"

    local exIsFile = isfile or is_file
    local exWriteFile = writefile
    local exGetCustomAsset = getcustomasset

    task.spawn(function()
        local downloaded = false
        if type(exIsFile) == "function" and type(exWriteFile) == "function" and not exIsFile(fname) then
            local url = BASE_URL .. "/stream/" .. tostring(trackId) .. "?k=" .. READ_KEY
            local ok, data = pcall(function() return game:HttpGet(url) end)
            if ok and data and #data > 100 then
                pcall(exWriteFile, fname, data)
                downloaded = true
            end
        elseif type(exIsFile) == "function" and exIsFile(fname) then
            downloaded = true
        end

        if downloaded and type(exGetCustomAsset) == "function" then
            local okAsset, asset = pcall(exGetCustomAsset, fname)
            if okAsset and asset then
                DarlingMusic.play(asset, title)
                return
            end
        end

        -- Direct fallback to valid Roblox Asset ID (Guaranteed to play without active web server)
        local fallbackId = fallbackAssetId or PRESET_ROBLOX_AUDIO_IDS[tostring(trackId)] or "1843588265"
        DarlingMusic.play("rbxassetid://" .. tostring(fallbackId), title)
    end)
    return true, "Playing: " .. title
end

-- launch devmp3 bypass loader
function DarlingMusic.launchDevMp3()
    return pcall(function()
        local apiUrl = getActiveApiUrl()
        loadstring(game:HttpGet(apiUrl .. "/scripts/devmp3.lua"))()
    end)
end

-- initialize favorites
pcall(function() DarlingMusic.loadFavorites() end)

_G.DarlingMusic = DarlingMusic
if getgenv then pcall(function() getgenv().DarlingMusic = DarlingMusic end) end

return DarlingMusic
