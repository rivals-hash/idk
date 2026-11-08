--[[
    Darling Hub - Wallpaper Engine (Version 1.3)
    Self-contained background wallpaper manager for WindUI.
    Zero external video baggage, zero nil indexing errors.
    Displays custom assets and local cache files with independent dimming overlay.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local exRequest = request or http_request or (syn and syn.request)
local exWriteFile = writefile or (syn and syn.writefile)
local exReadFile = readfile or (syn and syn.readfile)
local exIsFile = isfile or is_file or (syn and syn.isfile)
local exMakeFolder = makefolder or make_folder or (syn and syn.makefolder)
local exGetCustomAsset = getcustomasset or getsynasset or (syn and syn.get_custom_asset)

local PRESET_FALLBACK_ASSETS = {
    ["hacker_room.jpg"] = "assets/backgrounds/hacker_room.jpg",
    ["lycoris_monochrome.jpg"] = "assets/backgrounds/lycoris_monochrome.jpg",
    ["cyan_neko.jpg"] = "assets/backgrounds/cyan_neko.jpg",
    ["frieren.jpg"] = "assets/backgrounds/frieren.jpg",
    ["cyberpunk_megalopolis.jpg"] = "assets/backgrounds/cyberpunk_megalopolis.jpg",
    ["green_night_driving.jpg"] = "assets/backgrounds/green_night_driving.jpg",
    ["monika_lonely.jpg"] = "assets/backgrounds/monika_lonely.jpg",
    ["purple_midnight.jpg"] = "assets/backgrounds/purple_midnight.jpg",
    ["persona_5_rainy.jpg"] = "assets/backgrounds/persona_5_rainy.jpg",
    ["rainy_tokyo.jpg"] = "assets/backgrounds/rainy_tokyo.jpg",
    ["shorekeeper.jpg"] = "assets/backgrounds/shorekeeper.jpg",
    ["skirk_neko.jpg"] = "assets/backgrounds/skirk_neko.jpg",
    ["snowy_bedroom.jpg"] = "assets/backgrounds/snowy_bedroom.jpg",
    ["snowy_forest.jpg"] = "assets/backgrounds/snowy_forest.jpg",
    ["dark_river_forest.jpg"] = "assets/backgrounds/dark_river_forest.jpg",
    ["witch_cauldron.jpg"] = "assets/backgrounds/witch_cauldron.jpg",
    ["deepseek_chan.jpg"] = "assets/backgrounds/deepseek_chan.jpg",
    ["yuta_blade.jpg"] = "assets/backgrounds/yuta_blade.jpg",
    ["zankou_nte.jpg"] = "assets/backgrounds/zankou_nte.jpg",
}

return function(Window, DarlingHub, universalHttpGet, loadCustomMediaAsset)
    local currentBackgroundTransparency = 0.25 -- default 25% dimming
    local currentScaleType = Enum.ScaleType.Crop
    local lastEnteredBackgroundInput = ""
    local currentAppliedMediaInput = nil

    local wallpaperContainer = nil
    local wallpaperImage = nil
    local dimOverlay = nil

    local function setupBackgroundContainers()
        if wallpaperContainer and wallpaperContainer.Parent then
            return wallpaperContainer
        end

        local main = (Window and Window.UIElements and Window.UIElements.Main)
            or (Window and Window.Frame)
            or (Window and Window.GetMainFrame and Window:GetMainFrame())
        if not main then return nil end

        local targetParent = main:FindFirstChild("Background") or main

        local existing = targetParent:FindFirstChild("DarlingWallpaper")
        if existing then
            wallpaperContainer = existing
            wallpaperImage = existing:FindFirstChild("WallpaperImage")
            dimOverlay = existing:FindFirstChild("DimOverlay")
            return wallpaperContainer
        end

        wallpaperContainer = Instance.new("Frame")
        wallpaperContainer.Name = "DarlingWallpaper"
        wallpaperContainer.Size = UDim2.fromScale(1, 1)
        wallpaperContainer.Position = UDim2.fromScale(0, 0)
        wallpaperContainer.BackgroundTransparency = 1
        wallpaperContainer.BorderSizePixel = 0
        wallpaperContainer.Active = false
        wallpaperContainer.ZIndex = 1
        wallpaperContainer.ClipsDescendants = true

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = wallpaperContainer

        wallpaperImage = Instance.new("ImageLabel")
        wallpaperImage.Name = "WallpaperImage"
        wallpaperImage.Size = UDim2.fromScale(1, 1)
        wallpaperImage.Position = UDim2.fromScale(0, 0)
        wallpaperImage.BackgroundTransparency = 1
        wallpaperImage.BorderSizePixel = 0
        wallpaperImage.ScaleType = currentScaleType
        wallpaperImage.ImageTransparency = 0
        wallpaperImage.Active = false
        wallpaperImage.ZIndex = 1
        wallpaperImage.Visible = false

        local imgCorner = Instance.new("UICorner")
        imgCorner.CornerRadius = UDim.new(0, 16)
        imgCorner.Parent = wallpaperImage
        wallpaperImage.Parent = wallpaperContainer

        dimOverlay = Instance.new("Frame")
        dimOverlay.Name = "DimOverlay"
        dimOverlay.Size = UDim2.fromScale(1, 1)
        dimOverlay.Position = UDim2.fromScale(0, 0)
        dimOverlay.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
        dimOverlay.BackgroundTransparency = 1 - currentBackgroundTransparency
        dimOverlay.BorderSizePixel = 0
        dimOverlay.Active = false
        dimOverlay.ZIndex = 2
        dimOverlay.Visible = false

        local dimCorner = Instance.new("UICorner")
        dimCorner.CornerRadius = UDim.new(0, 16)
        dimCorner.Parent = dimOverlay
        dimOverlay.Parent = wallpaperContainer

        wallpaperContainer.Parent = targetParent
        return wallpaperContainer
    end

    local function clearActiveMedia()
        currentAppliedMediaInput = nil
        setupBackgroundContainers()

        if wallpaperImage then
            wallpaperImage.Image = ""
            wallpaperImage.Visible = false
        end
        if dimOverlay then
            dimOverlay.Visible = false
        end

        -- Safe fallback for WindUI internal calls
        if Window then
            if Window.SetBackgroundImage then
                pcall(function() Window:SetBackgroundImage("") end)
            end
            if Window.SetBackgroundImageTransparency then
                pcall(function() Window:SetBackgroundImageTransparency(1) end)
            end
        end
    end

    local function setBackgroundImage(assetUri, dimPercent)
        if not assetUri or assetUri == "" or assetUri == "None" or assetUri == "None / Cleared" then
            clearActiveMedia()
            return
        end

        setupBackgroundContainers()
        if not wallpaperImage or not dimOverlay then return end

        currentAppliedMediaInput = assetUri
        wallpaperImage.Image = assetUri
        wallpaperImage.ScaleType = currentScaleType
        wallpaperImage.ImageTransparency = 0
        wallpaperImage.Visible = true

        local dim = tonumber(dimPercent)
        if dim then
            currentBackgroundTransparency = math.clamp(dim / 100, 0, 0.95)
        end

        dimOverlay.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
        dimOverlay.BackgroundTransparency = 1 - currentBackgroundTransparency
        dimOverlay.Visible = (currentBackgroundTransparency > 0)

        -- If WindUI has native background frame, ensure it allows the image to shine through
        local main = (Window and Window.UIElements and Window.UIElements.Main) or (Window and Window.Frame)
        local bg = main and main:FindFirstChild("Background")
        if bg and bg:IsA("Frame") then
            pcall(function() bg.BackgroundTransparency = 0.2 end)
        end
    end

    local function setCurrentBackgroundTransparency(v)
        local val = tonumber(v) or 0.25
        if val > 1 then val = val / 100 end
        currentBackgroundTransparency = math.clamp(val, 0, 0.95)

        setupBackgroundContainers()
        if dimOverlay then
            dimOverlay.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
            dimOverlay.BackgroundTransparency = 1 - currentBackgroundTransparency
            dimOverlay.Visible = (wallpaperImage and wallpaperImage.Visible and currentBackgroundTransparency > 0)
        end

        if Window and Window.SetBackgroundImageTransparency then
            pcall(function() Window:SetBackgroundImageTransparency(currentBackgroundTransparency) end)
        end
    end

    local function getCurrentBackgroundTransparency()
        return currentBackgroundTransparency
    end

    local function processAndApplyMediaInput(input)
        if not input or input == "" then
            clearActiveMedia()
            return
        end

        local clean = tostring(input):match("^%s*(.-)%s*$") or ""
        if clean == "" or clean == "None" or clean == "None / Cleared" then
            clearActiveMedia()
            return
        end

        -- 1. Direct Roblox Asset ID
        if tonumber(clean) then
            setBackgroundImage("rbxassetid://" .. clean)
            return
        elseif clean:match("^rbxassetid://") or clean:match("^rbxasset://") then
            setBackgroundImage(clean)
            return
        end

        -- 2. Web URL
        if clean:match("^https?://") then
            task.spawn(function()
                local cleanUrl = clean:match('(https?://[^%s"]+)') or clean
                local ext = cleanUrl:match("%.(%w+)%??") or "png"
                local hash = "DarlingHub/cache/darling_web_" .. tostring(#cleanUrl) .. "." .. ext

                if exIsFile and exIsFile(hash) and exGetCustomAsset then
                    local ok, asset = pcall(exGetCustomAsset, hash)
                    if ok and type(asset) == "string" and #asset > 0 then
                        setBackgroundImage(asset)
                        return
                    end
                end

                if loadCustomMediaAsset then
                    local asset = loadCustomMediaAsset(cleanUrl, hash)
                    if asset and #asset > 0 then
                        setBackgroundImage(asset)
                        return
                    end
                end

                -- Direct HTTP download fallback
                local content = nil
                if universalHttpGet then
                    content = universalHttpGet(cleanUrl, 10)
                end
                if not content and game and game.HttpGet then
                    pcall(function() content = game:HttpGet(cleanUrl, true) end)
                end

                if content and #content > 100 and exWriteFile and exGetCustomAsset then
                    if exMakeFolder then
                        pcall(exMakeFolder, "DarlingHub")
                        pcall(exMakeFolder, "DarlingHub/cache")
                    end
                    pcall(exWriteFile, hash, content)
                    local ok, asset = pcall(exGetCustomAsset, hash)
                    if ok and type(asset) == "string" and #asset > 0 then
                        setBackgroundImage(asset)
                        return
                    end
                end
            end)
            return
        end

        -- 3. Local custom asset path
        if exGetCustomAsset and exIsFile and exIsFile(clean) then
            local ok, asset = pcall(exGetCustomAsset, clean)
            if ok and type(asset) == "string" and #asset > 0 then
                setBackgroundImage(asset)
                return
            end
        end

        -- Fallback: try applying as raw asset string
        setBackgroundImage(clean)
    end

    -- Initial setup
    pcall(setupBackgroundContainers)

    return {
        setupBackgroundContainers = setupBackgroundContainers,
        clearActiveMedia = clearActiveMedia,
        setBackgroundImage = setBackgroundImage,
        playVideo = function(...) return setBackgroundImage(...) end,
        stopVideo = clearActiveMedia,
        processAndApplyMediaInput = processAndApplyMediaInput,
        PRESET_FALLBACK_ASSETS = PRESET_FALLBACK_ASSETS,
        getCurrentBackgroundTransparency = getCurrentBackgroundTransparency,
        setCurrentBackgroundTransparency = setCurrentBackgroundTransparency,
        getCurrentAppliedMediaInput = function() return currentAppliedMediaInput end,
        getLastEnteredBackgroundInput = function() return lastEnteredBackgroundInput end,
        setLastEnteredBackgroundInput = function(v) lastEnteredBackgroundInput = v or "" end,
    }
end
