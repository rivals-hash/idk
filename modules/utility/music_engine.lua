--[[
    BestHub - modules/utility/music_engine.lua
    High-performance audio streaming & playback engine.
    Supports preset phonk soundtracks, custom sound IDs,
    volume, looping, and real-time playback state.
]]

local MusicEngine = {}

local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

MusicEngine.SoundInstance = nil
MusicEngine.CurrentTrackIndex = 1
MusicEngine.Volume = 0.5
MusicEngine.IsPlaying = false
MusicEngine.PlaybackSpeed = 1.0
MusicEngine.Looped = true

MusicEngine.Playlist = {
    { Title = "MONTAGEM BAILÃO (Phonk)", Id = "1843588265", Duration = 145 },
    { Title = "Darling Theme - Lo-Fi Chill", Id = "90089940136467", Duration = 180 },
    { Title = "Montagem Topaz (Speed)", Id = "15539566377", Duration = 132 },
    { Title = "Anime Vibes Aesthetic", Id = "6825487739", Duration = 210 },
    { Title = "Synthwave Night Drive", Id = "7024220379", Duration = 195 },
    { Title = "Spooky 3 Montagem", Id = "9114223171", Duration = 160 }
}

-- Listeners for playback events
MusicEngine.Listeners = {}

function MusicEngine.getSound()
    if MusicEngine.SoundInstance and MusicEngine.SoundInstance.Parent then
        return MusicEngine.SoundInstance
    end
    local existing = SoundService:FindFirstChild("BestHub_MusicPlayer")
    if existing and existing:IsA("Sound") then
        MusicEngine.SoundInstance = existing
        return existing
    end
    local snd = Instance.new("Sound")
    snd.Name = "BestHub_MusicPlayer"
    snd.Volume = MusicEngine.Volume
    snd.PlaybackSpeed = MusicEngine.PlaybackSpeed
    snd.Looped = MusicEngine.Looped
    snd.Parent = SoundService
    MusicEngine.SoundInstance = snd
    return snd
end

function MusicEngine.getCurrentTrack()
    local track = MusicEngine.Playlist[MusicEngine.CurrentTrackIndex]
    if not track then
        track = { Title = "Phonk Remix", Id = "1843588265", Duration = 145 }
    end
    return track
end

function MusicEngine.notifyListeners()
    local track = MusicEngine.getCurrentTrack()
    for _, fn in ipairs(MusicEngine.Listeners) do
        pcall(fn, {
            IsPlaying = MusicEngine.IsPlaying,
            Track = track,
            Volume = MusicEngine.Volume
        })
    end
end

function MusicEngine.onStateChange(callback)
    table.insert(MusicEngine.Listeners, callback)
    -- Initial dispatch
    pcall(callback, {
        IsPlaying = MusicEngine.IsPlaying,
        Track = MusicEngine.getCurrentTrack(),
        Volume = MusicEngine.Volume
    })
end

function MusicEngine.play(trackIndexOrId, customTitle)
    local snd = MusicEngine.getSound()
    local soundId = "1843588265"
    local title = "Phonk Remix"

    if type(trackIndexOrId) == "number" then
        if trackIndexOrId < 1 then trackIndexOrId = #MusicEngine.Playlist end
        if trackIndexOrId > #MusicEngine.Playlist then trackIndexOrId = 1 end
        MusicEngine.CurrentTrackIndex = trackIndexOrId
        local t = MusicEngine.Playlist[MusicEngine.CurrentTrackIndex]
        soundId = t.Id
        title = t.Title
    elseif type(trackIndexOrId) == "string" then
        soundId = trackIndexOrId:gsub("%D+", "")
        title = customTitle or ("Track #" .. soundId)
    end

    pcall(function() snd:Stop() end)
    snd.SoundId = "rbxassetid://" .. soundId
    snd.Volume = MusicEngine.Volume
    snd.PlaybackSpeed = MusicEngine.PlaybackSpeed
    snd.Looped = MusicEngine.Looped
    local ok = pcall(function() snd:Play() end)

    MusicEngine.IsPlaying = ok
    MusicEngine.notifyListeners()
    return ok, title
end

function MusicEngine.togglePlay()
    local snd = MusicEngine.getSound()
    if snd.IsPlaying then
        pcall(function() snd:Pause() end)
        MusicEngine.IsPlaying = false
    else
        if snd.SoundId == "" then
            return MusicEngine.play(MusicEngine.CurrentTrackIndex)
        else
            pcall(function() snd:Resume() end)
            MusicEngine.IsPlaying = true
        end
    end
    MusicEngine.notifyListeners()
    return MusicEngine.IsPlaying
end

function MusicEngine.nextTrack()
    local nextIdx = MusicEngine.CurrentTrackIndex + 1
    if nextIdx > #MusicEngine.Playlist then nextIdx = 1 end
    return MusicEngine.play(nextIdx)
end

function MusicEngine.prevTrack()
    local prevIdx = MusicEngine.CurrentTrackIndex - 1
    if prevIdx < 1 then prevIdx = #MusicEngine.Playlist end
    return MusicEngine.play(prevIdx)
end

function MusicEngine.setVolume(vol)
    vol = math.clamp(tonumber(vol) or 0.5, 0, 1)
    MusicEngine.Volume = vol
    local snd = MusicEngine.getSound()
    snd.Volume = vol
    MusicEngine.notifyListeners()
end

function MusicEngine.getProgress()
    local snd = MusicEngine.getSound()
    if snd and snd.TimeLength > 0 then
        return snd.TimePosition / snd.TimeLength, snd.TimePosition, snd.TimeLength
    end
    local track = MusicEngine.getCurrentTrack()
    return 0, 0, track.Duration or 150
end

-- Fallback/Simulation Loudness for the Visualizer
function MusicEngine.getLoudness()
    local snd = MusicEngine.getSound()
    if snd and snd.IsPlaying and snd.PlaybackLoudness and snd.PlaybackLoudness > 0 then
        return math.clamp(snd.PlaybackLoudness / 300, 0.1, 1.0)
    end
    if MusicEngine.IsPlaying then
        return 0.7
    end
    return 0.05
end

return MusicEngine
