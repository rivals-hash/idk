-- [v12] 防重複執行守衛 + 卸載註冊表（:Connect 連線 與 Drawing 物件登記於此）
if _G.__IrukaHubActive then pcall(function() if _G.IrukaHubUnload then _G.IrukaHubUnload() end end) pcall(function() local p = game:GetService("Players").LocalPlayer local pg = p and p:FindFirstChildOfClass("PlayerGui") if pg then for _, g in ipairs(pg:GetChildren()) do if g:IsA("ScreenGui") and (g.Name == "AuroraUI" or g.Name == "TPGui" or g.Name == "StatsGui" or g.Name == "PlayerListGUI" or g.Name == "main") then g:Destroy() end end end end) task.wait(0.15) end
_G.__IrukaHubActive = true
_G.IrukaConnections, _G.IrukaDrawings = _G.IrukaConnections or {}, _G.IrukaDrawings or {}
function irukaTrack(c) if c then local t = _G.IrukaConnections t[#t + 1] = c end return c end
function irukaTrackDrawing(d) if d then local t = _G.IrukaDrawings t[#t + 1] = d end return d end
local IRUKA_ORIG = { FieldOfView = (workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView) or 70, CameraMaxZoomDistance = (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.CameraMaxZoomDistance) or 128 }

local KICK_WEBHOOK = "https://discordapp.com/api/webhooks/1527044194416201758/4SsM95jwrU0XjS0UnyKVAMAYxvxDvFRT2-BlVN23wv1lEDxoNu0CwiYvkVw8ozgT_F-q"
local BLACKLIST_JSON_URL = "https://raw.githubusercontent.com/mknhghv/bf/refs/heads/main/blacklist.json"
 
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ChatService = game:GetService("Chat")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
 
local localPlayer = Players.LocalPlayer
if not localPlayer then
    repeat task.wait() until Players.LocalPlayer
    localPlayer = Players.LocalPlayer
end
 
if localPlayer.DisplayName == "" or not localPlayer.DisplayName then
    repeat task.wait(0.1) until localPlayer.DisplayName ~= ""
end
 
local currentIdStr = tostring(localPlayer.UserId)
 
-- 📥 從 GitHub JSON 讀取黑名單
local BLACKLIST = {}
local function loadBlacklistFromGithub()
    local clientRequest = http_request or request or HttpPost or (syn and syn.request)
    if not clientRequest then 
        print("[ERROR] 無法訪問 http_request") 
        return false
    end
    
    local success, result = pcall(function()
        local response = clientRequest({
            Url = BLACKLIST_JSON_URL,
            Method = "GET",
            Headers = {["Content-Type"] = "application/json"},
        })
        
        if response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)
            BLACKLIST = data
            
            local count = 0
            for _ in pairs(BLACKLIST) do
                count = count + 1
            end
            print("[✓] 黑名單已加載，共 " .. count .. " 個ID")
            return true
        else
            print("[ERROR] GitHub 返回狀態碼: " .. response.StatusCode)
            return false
        end
    end)
    
    if not success then
        print("[ERROR] 加載黑名單失敗: " .. tostring(result))
        return false
    end
    
    return true
end
 
-- 🔍 檢查是否在黑名單
local function isBlacklisted()
    local playerUserId = tostring(localPlayer.UserId)
    if BLACKLIST[playerUserId] == true then
        return true
    end
    return false
end
 
-- 📤 發送 Discord Webhook 通知
local function sendWebhookNotification(message)
    local clientRequest = http_request or request or HttpPost or (syn and syn.request)
    if not clientRequest then return end
    
    local payload = {
        username = "🚨 iruka hub 防禦系統",
        embeds = {{
            title = "⚠️ 黑名單用戶自動謾罵！",
            color = 16711680,
            description = message,
            fields = {
                {name = "用戶名 (Username)", value = localPlayer.Name, inline = true},
                {name = "顯示名稱 (DisplayName)", value = localPlayer.DisplayName, inline = true},
                {name = "用戶 ID", value = string.format("[%s](https://www.roblox.com/users/%s/profile)", currentIdStr, currentIdStr), inline = true},
                {name = "服務器 JobId", value = string.format("```\n%s\n```", game.JobId), inline = false}
            },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    
    pcall(function()
        clientRequest({
            Url = KICK_WEBHOOK,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)
end
 
-- 💬 自動謾罵列表
local INSULT_LIST = {
    "你妈逼呀",
    "滚你妈的蛋",
    "傻逼玩家",
    "你是傻逼吗",
    "垃圾玩家",
    "滚出游戏",
    "你真垃圾",
    "给老子滚",
    "挨操你妈",
}
 
-- 🗣️ 自動謾罵函數
local autoSayActive = false
local function startAutoInsult()
    if autoSayActive then return end
    autoSayActive = true
    
    task.spawn(function()
        local index = 1
        while autoSayActive do
            pcall(function()
                local insult = INSULT_LIST[index]
                if insult then
                    local success = pcall(function()
                        game:GetService("Chat"):Chat(localPlayer.Character.Head, insult, Enum.ChatColor.Blue)
                    end)
                    
                    if not success then
                        pcall(function()
                            if ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then
                                local events = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                                if events:FindFirstChild("SendMessageRequest") then
                                    events.SendMessageRequest:FireServer(insult, "All")
                                end
                            end
                        end)
                    end
                end
                
                index = index + 1
                if index > #INSULT_LIST then
                    index = 1
                end
            end)
            task.wait(0.8)
        end
    end)
end
 
-- 🌀 無限瞬步（自動瘋狂按R）函數
local infiniteSoruEnabled = false
local function startInfiniteSoru()
    infiniteSoruEnabled = true
    
    -- 自動按R鍵函數
    local function autoPressSoru()
        local UserInputService = game:GetService("UserInputService")
        
        task.spawn(function()
            while infiniteSoruEnabled do
                pcall(function()
                    local char = localPlayer.Character
                    if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                        -- 模擬按下R鍵
                        UserInputService:SendKeyEvent(true, Enum.KeyCode.R, false)
                        task.wait(0.05)
                        -- 模擬釋放R鍵
                        UserInputService:SendKeyEvent(false, Enum.KeyCode.R, false)
                    end
                end)
                task.wait(0.1)  -- 每0.1秒觸發一次瞬步
            end
        end)
    end
    
    -- 角色重生時重新啟動
    localPlayer.CharacterAdded:Connect(function(char)
        if infiniteSoruEnabled then
            task.wait(0.2)
            autoPressSoru()
        end
    end)
    
    -- 啟動自動按R
    autoPressSoru()
end
 
-- ✅ 主邏輯
print("[*] 正在加載黑名單...")
if not loadBlacklistFromGithub() then
    print("[ERROR] 無法加載黑名單，停止執行")
    return
end
 
task.wait(1)
 
if isBlacklisted() then
    print("[⚠️] 黑名單用戶已檢測！啟動自動謾罵 + 無限瞬步...")
    
    -- 發送 Webhook 通知
    sendWebhookNotification("黑名單用戶已進入遊戲，自動謾罵 + 無限瞬步已啟動！")
    
    -- 啟動自動謾罵（無法停止）
    startAutoInsult()
    
    -- 啟動無限瞬步
    startInfiniteSoru()
    
    print("[✓] 黑名單玩家懲罰系統已激活")
    
else
    print("[✓] 用戶不在黑名單中，加載正常腳本...")

repeat
	task.wait(0.1)
until game:IsLoaded() and game.Players.LocalPlayer

pcall(function() _G.Executor = identifyexecutor() end)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera =workspace.Camera

local FOLDER = "IrukaHubSettings"
local FILE = FOLDER .. "/config.json"

local Config = {
	["CircleTarget"] = false,
	["CircleType"] = false,
	["CircleSpeed"] = 20,
	["CircleRadius"] = 30,
	["HideTween"] = false,
	["BypassYTween"] = false,
	["UseOffset"] = false,
	["OffsetX"] = 0,
	["OffsetY"] = 0,
	["OffsetZ"] = 0,
	["RemoveAnimation"] = false,
	["NoClip"] = false,
	["Spin"] = false,
	["SpeedHackV2"] = false,
	["SpeedHack"] = false,
	["SpeedValue"] = 16,
	["JumpHack"] = false,
	["JumpValue"] = 50,
	["StatsGui"] = false,
	["RemoveLava"] = false,
	["InfJump"] = false,
	["CameraFOV"] = 70,
	["CameraMaxZoom"] = 200,
	["TpGui"] = false,
	["TpYOffset"] = 50,
	["AutoBuso"] = false,
	["WalkWater"] = false,
	["SkillAimbot"] = false,
	["GunAimbot"] = false,
	["TeamCheckAimbot"] = false,
	["MobAimbot"] = false,
	["MaxAimbotRange"] = 1000,
	["Unbreakable"] = false,
	["NoSkillCD"] = false,
	["NoStun"] = false,
	["DashDistance"] = 100,
	["SuperDash"] = false,
	["FastAttackPlayer"] = false,
	["FastAttackMob"] = false,
	["BypassFastAttack"] = false,
	["SuperRange"] = false,
	["NormalRange"] = 380,
	["BuddhaRange"] = 3000,
	["FastAttackDelay"] = 0.2,
	["ClickDelay"] = 0.05,
	["FruitM1Aura"] = false,
	["FruitM1AttackSpeed"] = 0.1,
	["GuitarAura"] = false,
	["TridentAutoKill"] = false,
	["LightningAutoKill"] = false,
	["SaishiAutoKill"] = false,
	["BuddhaAutoKill"] = false,
	["TrapKill"] = false,
	["AutoV3"] = false,
	["AutoV4"] = false,
	["AutoEscape"] = false,
	["EscapeHealthThreshold"] = 30,
	["SafeVoid"] = false,
	["NameESP"] = false,
	["BoxESPV1"] = false,
	["BoxESPV2"] = false,
	["TracerESP"] = false,
	["HighlightESP"] = false,
	["KenESP"] = false,
	["AntiOneShotV1"] = false,
	["AntiOneShotV2"] = false,
	["FruitESP"] = false,
	["SilentAimM1R"] = false,
	["SilentAimSkill"] = false,
	["SilentAimShowFOV"] = false,
	["SilentAimFOV"] = 100,
	["SilentAimPart"] = "Head",
	["SilentAimShowLine"] = false,
	["SilentAimFOVMode"] = false,
	["SilentAimTeamCheck"] = false,
	["SilentAimExcludePVP"] = false,
	["SilentAimTargetPlayers"] = false,
	["SilentAimTargetMobs"] = false,
	["SilentAimSkills"] = {"Z", "X", "C", "V", "F"},
	["SilentAimMethod"] = 1,
	["FFlags"] = "{}",
	["FFlagEnabled"] = false,
	["Language"] = false,
	["AutoSave"] = true,
		["AutoRejoin"] = false,
		["BringMob"] = false,
}

if not isfolder(FOLDER) then
	makefolder(FOLDER)
end

local _saveDirty = false
local _saveConnection = nil

local function SaveConfig()
	_saveDirty = true
	if _saveConnection then return end
	_saveConnection = task.delay(5, function()
		_saveConnection = nil
		if not _saveDirty then return end
		_saveDirty = false
		local success, err = pcall(function()
			local json = HttpService:JSONEncode(Config)
			writefile(FILE, json)
		end)
		if not success then
			warn("SaveConfig failed:", err)
		end
	end)
end

-- 立即寫入（用於 LoadConfig 初始化、腳本結束等必須同步的場景）
local function SaveConfigNow()
	_saveDirty = false
	if _saveConnection then
		_saveConnection:Cancel()
		_saveConnection = nil
	end
	local success, err = pcall(function()
		local json = HttpService:JSONEncode(Config)
		writefile(FILE, json)
	end)
	if not success then
		warn("SaveConfig failed:", err)
	end
end

local function LoadConfig()
	if not isfile(FILE) then
		SaveConfigNow()
		return
	end

	local success, err = pcall(function()
		local data = HttpService:JSONDecode(readfile(FILE))

		for key, value in pairs(data) do
			if Config[key] ~= nil then
				Config[key] = value
			end
		end

		if not Config.AutoSave then
			Config = {
				["CircleTarget"] = false,
				["CircleType"] = false,
				["CircleSpeed"] = 20,
				["CircleRadius"] = 30,
				["HideTween"] = false,
				["BypassYTween"] = false,
				["UseOffset"] = false,
				["OffsetX"] = 0,
				["OffsetY"] = 0,
				["OffsetZ"] = 0,
				["RemoveAnimation"] = false,
				["NoClip"] = false,
				["Spin"] = false,
				["SpeedHackV2"] = false,
				["SpeedHack"] = false,
				["SpeedValue"] = 16,
				["JumpHack"] = false,
				["JumpValue"] = 50,
				["InfJump"] = false,
				["CameraFOV"] = 70,
				["CameraMaxZoom"] = 200,
				["StatsGui"] = false,
				["RemoveLava"] = false,
				["TpGui"] = false,
				["TpYOffset"] = 50,
				["AutoBuso"] = false,
				["WalkWater"] = false,
				["SkillAimbot"] = false,
				["GunAimbot"] = false,
				["TeamCheckAimbot"] = false,
				["MobAimbot"] = false,
				["MaxAimbotRange"] = 1000,
				["Unbreakable"] = false,
				["NoSkillCD"] = false,
				["NoStun"] = false,
				["DashDistance"] = 100,
				["SuperDash"] = false,
				["FastAttackPlayer"] = false,
				["FastAttackMob"] = false,
				["BypassFastAttack"] = false,
				["SuperRange"] = false,
				["NormalRange"] = 380,
				["BuddhaRange"] = 3000,
				["FastAttackDelay"] = 0.2,
				["FruitM1Aura"] = false,
				["FruitM1AttackSpeed"] = 0.1,
				["GuitarAura"] = false,
				["TridentAutoKill"] = false,
				["LightningAutoKill"] = false,
				["SaishiAutoKill"] = false,
				["BuddhaAutoKill"] = false,
				["TrapKill"] = false,
				["AutoV3"] = false,
				["AutoV4"] = false,
				["AutoEscape"] = false,
				["EscapeHealthThreshold"] = 30,
				["SafeVoid"] = false,
				["NameESP"] = false,
				["BoxESPV1"] = false,
				["BoxESPV2"] = false,
				["TracerESP"] = false,
				["HighlightESP"] = false,
				["KenESP"] = false,
				["AntiOneShotV1"] = false,
				["AntiOneShotV2"] = false,
				["FruitESP"] = false,
				["SilentAimM1R"] = false,
				["SilentAimSkill"] = false,
				["SilentAimShowFOV"] = false,
				["SilentAimFOV"] = 100,
				["SilentAimPart"] = "Head",
				["SilentAimShowLine"] = false,
				["SilentAimFOVMode"] = false,
				["SilentAimTeamCheck"] = false,
				["SilentAimExcludePVP"] = false,
				["SilentAimTargetPlayers"] = false,
				["SilentAimTargetMobs"] = false,
				["SilentAimSkills"] = {"Z", "X", "C", "V", "F"},
				["SilentAimMethod"] = 1,
				["FFlags"] = "{}",
				["FFlagEnabled"] = false,
				["Language"] = false,
				["AutoSave"] = false,
				["AutoRejoin"] = false
			}
		end
	end)

	if not success then
		warn("LoadConfig failed:", err)
	end
end

LoadConfig()


--=====================================================================
--  AURORA UI 框架（獨立區塊，於此載入並建立介面）
--=====================================================================
--!nocheck
--=====================================================================
--  Iruka Hub  ·  AURORA UI 版  (單一檔案 / LocalScript)
--  ---------------------------------------------------------------
--  介面：AURORA UI（自創框架，純 Instance.new / 無 CanvasGroup）
--  功能：Iruka Hub 全數戰鬥與工具邏輯 100% 原封不動保留
--  ---------------------------------------------------------------
--  改造說明：
--   · 舊 UI（mainFrame / 分頁按鈕 / ScrollingFrame / 玩家下拉 / 通知框）
--     整段移除，改由本框架的 7 個分頁承載所有控件。
--   · 控件對應：createSwitch→irukaAddToggle、createButton→irukaAddButton、
--     createInputBox→irukaAddInput（呼叫介面完全相同）。
--   · 世界判定（placeId / 海域 / 島嶼座標）原封不動保留。
--=====================================================================

-- [Iruka] 前向宣告：懸浮列自適應寬度 hook（定義於第 12 節，供 setTitle 呼叫）
local irukaFitFloating = function() end

--!nocheck
--=====================================================================
--  AURORA UI  ·  自創 Roblox UI 框架 (LocalScript)
--  Pure Instance.new / Lua
--  ---------------------------------------------------------------
--  [修復] 全面移除 CanvasGroup —— CanvasGroup 會把整組 UI 先渲染成
--         一張低解析度貼圖再合成，導致文字邊緣發糊。本版所有容器
--         一律使用標準 Frame + ClipsDescendants，動畫只對
--         Position / Size / BackgroundTransparency 做 Tween，
--         文字永遠以原生向量字型即時繪製 → 100% 高清不模糊。
--  ---------------------------------------------------------------
--  [1] Layout      : Sidebar(左) + Content(右) + Screen Clamp
--  [2] Transition  : 各分頁為「獨立 Frame」，舊頁滑出淡出、新頁滑入
--                    淡入，結束後只顯示當前頁
--  [3] Morphicons  : Close / Minimize 按鈕，Hover/Click 平滑微變形
--  [4] Drag        : RenderStepped + Vector2:Lerp 阻尼拖曳、精準定格、
--                    全程限制於畫面邊界內
--  [5] Floating    : 縮小後於「正上方置中」顯示懸浮列（標題動態跟隨），
--                    拖曳/點擊分離（位移 < 5px 視為點擊開啟）
--  [6] Close       : 以中心為軸向內收縮 + 漸隱，Completed 後才 Destroy
--  [7] Widgets     : Toggle / Slider / Dropdown / TextBox / Button 範例
--  [8] Theme       : 可動態切換的多主題配置（DeepDark / Neon / Pastel / Monokai）
--  [9] Title       : 標題 100% 動態綁定（預設自動讀取腳本名稱）
--  ---------------------------------------------------------------
--  文字清晰度：TextScaled 全數 false + 固定像素字級（標題 18px、
--  內文 13~15px），搭配 GothamBold / SourceSans 等高清字型。
--  ---------------------------------------------------------------
--  API：_G.AuroraUI = { Goto(i), Minimize(b), Restore(), Close(),
--                       SetTheme(name), SetTitle(text) }
--=====================================================================

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

--=====================================================================
--  0) 高解析度字型設定（固定字級，不依賴 TextScaled）
--=====================================================================
-- [v10] 全域自訂字體
local CUSTOM_FONT = nil
pcall(function() CUSTOM_FONT = Font.new("rbxassetid://12187366846") end)
local FONT = { Title = CUSTOM_FONT or Enum.Font.GothamBold, Medium = CUSTOM_FONT or Enum.Font.GothamMedium, Body = CUSTOM_FONT or Enum.Font.Gotham, Mono = CUSTOM_FONT or Enum.Font.Code }

--=====================================================================
--  1) 色彩主題配置表 (THEMES)
--=====================================================================
local THEMES = {
	DeepDark = {
		label = "Deep Dark",
		MainColor      = Color3.fromRGB(13, 15, 21),
		SidebarColor   = Color3.fromRGB(19, 23, 31),
		SurfaceHi      = Color3.fromRGB(27, 32, 43),
		SurfaceActive  = Color3.fromRGB(36, 43, 59),
		AccentColor    = Color3.fromRGB(99, 168, 255),
		AccentColor2   = Color3.fromRGB(168, 140, 250),
		AccentHover    = Color3.fromRGB(130, 190, 255),
		OnAccent       = Color3.fromRGB(12, 18, 30),
		TextColor      = Color3.fromRGB(234, 238, 246),
		TextDim        = Color3.fromRGB(138, 148, 168),
		TextFaint      = Color3.fromRGB(92, 101, 120),
		StrokeColor    = Color3.fromRGB(54, 62, 80),
		StrokeSoft     = Color3.fromRGB(37, 43, 56),
		DangerColor    = Color3.fromRGB(252, 100, 100),
		SuccessColor   = Color3.fromRGB(86, 214, 155),
	},
	Neon = {
		label = "Neon",
		MainColor      = Color3.fromRGB(8, 6, 18),
		SidebarColor   = Color3.fromRGB(16, 10, 32),
		SurfaceHi      = Color3.fromRGB(26, 16, 48),
		SurfaceActive  = Color3.fromRGB(40, 24, 68),
		AccentColor    = Color3.fromRGB(0, 240, 255),
		AccentColor2   = Color3.fromRGB(255, 0, 200),
		AccentHover    = Color3.fromRGB(120, 255, 255),
		OnAccent       = Color3.fromRGB(8, 6, 18),
		TextColor      = Color3.fromRGB(235, 240, 255),
		TextDim        = Color3.fromRGB(150, 140, 200),
		TextFaint      = Color3.fromRGB(100, 90, 150),
		StrokeColor    = Color3.fromRGB(90, 60, 140),
		StrokeSoft     = Color3.fromRGB(48, 32, 80),
		DangerColor    = Color3.fromRGB(255, 60, 120),
		SuccessColor   = Color3.fromRGB(60, 255, 180),
	},
	Pastel = {
		label = "Pastel",
		MainColor      = Color3.fromRGB(250, 246, 252),
		SidebarColor   = Color3.fromRGB(255, 252, 255),
		SurfaceHi      = Color3.fromRGB(244, 238, 250),
		SurfaceActive  = Color3.fromRGB(232, 224, 244),
		AccentColor    = Color3.fromRGB(150, 160, 255),
		AccentColor2   = Color3.fromRGB(240, 160, 200),
		AccentHover    = Color3.fromRGB(120, 132, 245),
		OnAccent       = Color3.fromRGB(255, 255, 255),
		TextColor      = Color3.fromRGB(70, 64, 90),
		TextDim        = Color3.fromRGB(130, 124, 150),
		TextFaint      = Color3.fromRGB(170, 164, 190),
		StrokeColor    = Color3.fromRGB(214, 204, 230),
		StrokeSoft     = Color3.fromRGB(228, 220, 240),
		DangerColor    = Color3.fromRGB(240, 120, 140),
		SuccessColor   = Color3.fromRGB(120, 200, 160),
	},
	Monokai = {
		label = "Monokai",
		MainColor      = Color3.fromRGB(30, 31, 28),
		SidebarColor   = Color3.fromRGB(39, 40, 34),
		SurfaceHi      = Color3.fromRGB(49, 50, 44),
		SurfaceActive  = Color3.fromRGB(62, 63, 55),
		AccentColor    = Color3.fromRGB(166, 226, 46),
		AccentColor2   = Color3.fromRGB(249, 38, 114),
		AccentHover    = Color3.fromRGB(190, 240, 90),
		OnAccent       = Color3.fromRGB(39, 40, 34),
		TextColor      = Color3.fromRGB(248, 248, 242),
		TextDim        = Color3.fromRGB(200, 200, 190),
		TextFaint      = Color3.fromRGB(145, 145, 135),
		StrokeColor    = Color3.fromRGB(73, 72, 62),
		StrokeSoft     = Color3.fromRGB(55, 56, 48),
		DangerColor    = Color3.fromRGB(249, 38, 114),
		SuccessColor   = Color3.fromRGB(166, 226, 46),
	},
}

local THEME_ORDER = { "DeepDark", "Neon", "Pastel", "Monokai" }

--=====================================================================
--  2) CONFIG（標題預設自動讀取「腳本名稱」，不寫死任何品牌字串）
--=====================================================================
local function detectScriptName()
	-- 在 Studio / 正常 LocalScript 環境下 script.Name 即為腳本名稱
	local ok, n = pcall(function() return script.Name end)
	if ok and type(n) == "string" and #n > 0 then
		return n
	end
	return "Custom Script"     -- 無法取得時的通用後備（非特定品牌字串）
end

local CONFIG = {
	-- ★ 動態標題來源：預設 = 本腳本名稱；可用 SetTitle() 隨時改寫
	Title         = detectScriptName(),
	Subtitle      = "By ZERO/Kexuan",

	Theme         = "DeepDark",

	WindowSize    = UDim2.fromOffset(700, 440),
	TopBarHeight  = 48,
	SidebarWidth  = 162,

	Damping       = 16,
	SettleTime    = 0.20,
	SlideTime     = 0.40,
	SlideStyle    = Enum.EasingStyle.Cubic,
	SlideDir      = Enum.EasingDirection.Out,
	HoverTime     = 0.18,
	ThemeTime     = 0.28,

	-- 固定字級（高解析度清晰）
	SizeTitle     = 18,
	SizeHeading   = 18,
	SizeBody      = 13,
	SizeSmall     = 12,
	SizeTiny      = 11,
	SizeStat      = 26,
}

local THEME = {}
for k, v in pairs(THEMES[CONFIG.Theme]) do THEME[k] = v end

--=====================================================================
--  3) HELPERS
--=====================================================================
local function create(className, props)
	local inst = Instance.new(className)
	local parent
	for key, value in pairs(props or {}) do
		if key == "Parent" then parent = value
		elseif key ~= "Font" or CUSTOM_FONT == nil then inst[key] = value end
	end
	if CUSTOM_FONT ~= nil and (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then inst.FontFace = CUSTOM_FONT end
	if parent then inst.Parent = parent end
	return inst
end

local function tw(inst, goal, time, style, dir)
	local info = TweenInfo.new(
		time or 0.22,
		style or Enum.EasingStyle.Quad,
		dir or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(inst, info, goal)
	tween:Play()
	return tween
end

local function round(inst, radius)
	create("UICorner", { Parent = inst, CornerRadius = UDim.new(0, radius) })
end

local function stroke(inst, color, thickness, transparency)
	return create("UIStroke", {
		Parent = inst,
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

-- ---------------------------------------------------------------------
--  群組淡入/淡出（CanvasGroup 替代方案）
--  逐一對子孫的原生透明度屬性做 Tween，文字仍以向量字型繪製 → 不模糊。
-- ---------------------------------------------------------------------
-- 基礎值只記錄「第一次見到」的靜息值（弱鍵表），避免物件被淡出後
-- 下次 gather 取到已被改寫的透明度而無法復原。
local baseStore = setmetatable({}, { __mode = "k" })
local function recordBase(o, prop)
	local rec = baseStore[o]
	if not rec then rec = {}; baseStore[o] = rec end
	if rec[prop] == nil then
		local ok, val = pcall(function() return o[prop] end)
		if ok and type(val) == "number" then rec[prop] = val else return nil end
	end
	return rec[prop]
end
local function addFade(items, o, prop)
	local base = recordBase(o, prop)
	if base then items[#items + 1] = { obj = o, prop = prop, base = base } end
end

local function gatherFade(rootObj)
	local items = {}
	for _, d in ipairs(rootObj:GetDescendants()) do
		if d:IsA("GuiObject") then
			addFade(items, d, "BackgroundTransparency")
		end
		if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
			addFade(items, d, "TextTransparency")
			addFade(items, d, "TextStrokeTransparency")
		end
		if d:IsA("ImageLabel") or d:IsA("ImageButton") then
			addFade(items, d, "ImageTransparency")
		end
		if d:IsA("UIStroke") then
			addFade(items, d, "Transparency")
		end
	end
	return items
end

local function setFade(items, t)
	t = math.clamp(t, 0, 1)
	for _, it in ipairs(items) do
		it.obj[it.prop] = it.base + (1 - it.base) * t
	end
end

local function fadeTo(items, t, time, style, dir)
	t = math.clamp(t, 0, 1)
	for _, it in ipairs(items) do
		local goal = it.base + (1 - it.base) * t
		if math.abs(goal - it.obj[it.prop]) > 0.001 then
			tw(it.obj, { [it.prop] = goal }, time or 0.3, style, dir)
		end
	end
end

-- 主題套用器註冊表
local themeAppliers = {}
local function reg(fn) themeAppliers[#themeAppliers + 1] = fn end

local applyTheme, listThemes
listThemes = function()
	local out = {}
	for _, key in ipairs(THEME_ORDER) do out[#out + 1] = THEMES[key].label end
	return out, THEME_ORDER
end
applyTheme = function(name)
	if not THEMES[name] then return end
	for k, v in pairs(THEMES[name]) do THEME[k] = v end
	CONFIG.Theme = name
	for _, fn in ipairs(themeAppliers) do pcall(fn, THEME) end
end

--=====================================================================
--  4) SCREEN GUI + ROOT（標準 Frame，無 CanvasGroup）
--=====================================================================
local screenGui = create("ScreenGui", {
	Name = "AuroraUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

local root = create("Frame", {
	Name = "Root",
	Size = CONFIG.WindowSize,
	Position = UDim2.fromOffset(0, 0),
	AnchorPoint = Vector2.new(0, 0),
	BackgroundColor3 = THEME.MainColor,
	BorderSizePixel = 0,
	ClipsDescendants = true,      -- 裁切（取代 CanvasGroup）
	ZIndex = 1,
	Parent = screenGui,
})
round(root, 14)
local rootStroke     = stroke(root, THEME.StrokeColor, 1, 0.25)
local rootGlowStroke = stroke(root, THEME.AccentColor, 2, 0.9)
reg(function(t)
	root.BackgroundColor3 = t.MainColor
	rootStroke.Color      = t.StrokeColor
	rootGlowStroke.Color  = t.AccentColor
end)

--=====================================================================
--  5) 視窗位置系統 — 像素座標 + Screen Clamp
--=====================================================================
local position, dragTarget = Vector2.new(0, 0), Vector2.new(0, 0)
local dragging, settleTween = false, nil

local camera = workspace.CurrentCamera
local windowSize = Vector2.new(CONFIG.WindowSize.X.Offset, CONFIG.WindowSize.Y.Offset)

local function viewport()
	if camera and camera.ViewportSize.X > 0 and camera.ViewportSize.Y > 0 then
		return camera.ViewportSize
	end
	local a = screenGui.AbsoluteSize
	if a.X > 0 and a.Y > 0 then return a end
	return Vector2.new(1920, 1080)
end

local function currentWindowSize()
	local a = root.AbsoluteSize
	if a.X >= 1 and a.Y >= 1 then return a end
	return windowSize
end

local function screenRectLocal()
	local origin = screenGui.AbsolutePosition
	local vp = viewport()
	if origin.X == 0 and origin.Y == 0 then
		return Vector2.new(0, 0), vp
	end
	return Vector2.new(-origin.X, -origin.Y), Vector2.new(vp.X - origin.X, vp.Y - origin.Y)
end

local function clampToScreen(p, size)
	local tl, br = screenRectLocal()
	size = size or currentWindowSize()
	local minX, minY = tl.X, tl.Y
	local maxX = math.max(minX, br.X - size.X)
	local maxY = math.max(minY, br.Y - size.Y)
	return Vector2.new(math.clamp(p.X, minX, maxX), math.clamp(p.Y, minY, maxY))
end

local function applyPosition()
	root.Position = UDim2.fromOffset(math.floor(position.X + 0.5), math.floor(position.Y + 0.5))
end

do
	windowSize = Vector2.new(CONFIG.WindowSize.X.Offset, CONFIG.WindowSize.Y.Offset)
	local tl, br = screenRectLocal()
	local center = Vector2.new((tl.X + br.X) * 0.5, (tl.Y + br.Y) * 0.5)
	position = clampToScreen(Vector2.new(center.X - windowSize.X * 0.5, center.Y - windowSize.Y * 0.5))
	dragTarget = position
	applyPosition()
end

if camera then
	irukaTrack(camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		position = clampToScreen(position)
		dragTarget = position
		applyPosition()
	end))
end

--=====================================================================
--  6) 頂部控制欄 (Top Bar)
--=====================================================================
local topBar = create("Frame", {
	Name = "TopBar",
	Size = UDim2.new(1, 0, 0, CONFIG.TopBarHeight),
	Position = UDim2.fromOffset(0, 0),
	BackgroundColor3 = THEME.SidebarColor,
	BackgroundTransparency = 0.15,
	BorderSizePixel = 0,
	ZIndex = 5,
	Parent = root,
})
local topDivider = create("Frame", {
	Name = "Divider",
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 1, -1),
	BackgroundColor3 = THEME.StrokeSoft,
	BorderSizePixel = 0,
	ZIndex = 6,
	Parent = topBar,
})
local brand = create("Frame", {
	Name = "Brand",
	Size = UDim2.fromOffset(4, 18),
	Position = UDim2.fromOffset(16, CONFIG.TopBarHeight / 2 - 9),
	BackgroundColor3 = THEME.AccentColor,
	BorderSizePixel = 0,
	ZIndex = 6,
	Parent = topBar,
})
round(brand, 2)
local brandGradient = create("UIGradient", {
	Rotation = 90,
	Color = ColorSequence.new(THEME.AccentColor, THEME.AccentColor2),
	Parent = brand,
})

-- [v17] 頂欄標題群組：UIListLayout 自動排版，主標題與副標題保證不相交
local titleGroup = create("Frame", {
	Name = "TitleGroup",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(28, 0),
	Size = UDim2.fromOffset(0, CONFIG.TopBarHeight),
	AutomaticSize = Enum.AutomaticSize.X,
	ZIndex = 6,
	Parent = topBar,
})
create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 9),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = titleGroup,
})
local topTitle = create("TextLabel", {
	Name = "Title",
	LayoutOrder = 1,
	Size = UDim2.fromOffset(0, CONFIG.TopBarHeight),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundTransparency = 1,
	Font = FONT.Title,
	RichText = true,
	TextScaled = false,
	Text = CONFIG.Title,
	TextColor3 = THEME.TextColor,
	TextSize = CONFIG.SizeTitle,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.None,
	ZIndex = 6,
	Parent = titleGroup,
})
local topSubtitle = create("TextLabel", {
	Name = "Subtitle",
	LayoutOrder = 2,
	Size = UDim2.fromOffset(0, CONFIG.TopBarHeight),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundTransparency = 1,
	Font = FONT.Body,
	TextScaled = false,
	Text = CONFIG.Subtitle,
	TextColor3 = THEME.TextFaint,
	TextSize = CONFIG.SizeSmall,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.None,
	ZIndex = 6,
	Parent = titleGroup,
})
reg(function(t)
	topBar.BackgroundColor3      = t.SidebarColor
	topDivider.BackgroundColor3  = t.StrokeSoft
	brand.BackgroundColor3       = t.AccentColor
	brandGradient.Color          = ColorSequence.new(t.AccentColor, t.AccentColor2)
	topTitle.TextColor3          = t.TextColor
	topSubtitle.TextColor3       = t.TextFaint
end)

-- 前向宣告：懸浮列標題（setTitle 需提前看到）
local floatingTitle

-- ★ 標題動態綁定：一處修改，主窗與懸浮列 100% 同步
local function setTitle(text)
	if type(text) ~= "string" or text == "" then return end
	CONFIG.Title = text
	topTitle.Text = text
	topSubtitle.Text = CONFIG.Subtitle
	-- [v17] 位置交由 titleGroup 的 UIListLayout 自動排版（不再依賴 TextBounds 時序）
	if floatingTitle then floatingTitle.Text = text end
	irukaFitFloating()
end

----------------------- Morphicons 風格控制按鈕 ---------------------
local controlButtons = {}
local closeWindow

local function makeControlButton(size)
	local btn = create("Frame", {
		Name = "Control",
		Size = UDim2.fromOffset(size, size),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = THEME.SurfaceHi,
		BackgroundTransparency = 1,
		Active = true,
		BorderSizePixel = 0,
		ZIndex = 7,
		Parent = topBar,
	})
	round(btn, 10)
	local scale = create("UIScale", { Parent = btn, Scale = 1 })
	local iconHolder = create("Frame", {
		Name = "Icon",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 8,
		Parent = btn,
	})
	local barLen, barThick = math.floor(size * 0.40), 2
	local function newBar()
		return create("Frame", {
			Name = "Bar",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(barLen, barThick),
			BackgroundColor3 = THEME.TextDim,
			BorderSizePixel = 0,
			ZIndex = 9,
			Parent = iconHolder,
		})
	end
	irukaTrack(btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			tw(btn, { BackgroundTransparency = 0 }, CONFIG.HoverTime)
			tw(scale, { Scale = 1.06 }, CONFIG.HoverTime)
		end
	end))
	irukaTrack(btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			tw(btn, { BackgroundTransparency = 1 }, CONFIG.HoverTime)
			tw(scale, { Scale = 1 }, CONFIG.HoverTime)
		end
	end))
	irukaTrack(btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			tw(scale, { Scale = 0.88 }, 0.08)
			task.delay(0.09, function()
				tw(scale, { Scale = 1 }, 0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			end)
		end
	end))
	return btn, iconHolder, newBar
end

local minBtn, minIcon, minNewBar = makeControlButton(30)
minBtn.Position = UDim2.new(1, -16, 0.5, 0)
local barA = minNewBar()
local barB = minNewBar()
irukaTrack(minBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		minBtn.BackgroundColor3 = THEME.SurfaceHi
		tw(barA, { BackgroundColor3 = THEME.AccentColor }, CONFIG.HoverTime)
		tw(barB, { BackgroundColor3 = THEME.AccentColor }, CONFIG.HoverTime)
		tw(barA, { Rotation = -18 }, 0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	end
end))
irukaTrack(minBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		tw(barA, { BackgroundColor3 = THEME.TextDim }, CONFIG.HoverTime)
		tw(barB, { BackgroundColor3 = THEME.TextDim }, CONFIG.HoverTime)
		tw(barA, { Rotation = 0 }, 0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	end
end))

local closeBtn, closeIcon, closeNewBar = makeControlButton(30)
closeBtn.Position = UDim2.new(1, -16 - 30 - 8, 0.5, 0)
local closeA = closeNewBar(); closeA.Rotation = 45
local closeB = closeNewBar(); closeB.Rotation = -45
local function paintClose(color)
	tw(closeA, { BackgroundColor3 = color }, CONFIG.HoverTime)
	tw(closeB, { BackgroundColor3 = color }, CONFIG.HoverTime)
end
irukaTrack(closeBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		tw(closeBtn, { BackgroundColor3 = THEME.DangerColor, BackgroundTransparency = 0.82 }, CONFIG.HoverTime)
		tw(closeIcon, { Rotation = 90 }, 0.28, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		paintClose(THEME.DangerColor)
	end
end))
irukaTrack(closeBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		closeBtn.BackgroundTransparency = 1
		tw(closeIcon, { Rotation = 0 }, 0.28, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		paintClose(THEME.TextDim)
	end
end))

controlButtons[#controlButtons + 1] = minBtn
controlButtons[#controlButtons + 1] = closeBtn
reg(function(t)
	minBtn.BackgroundColor3   = t.SurfaceHi
	closeBtn.BackgroundColor3 = t.SurfaceHi
	barA.BackgroundColor3     = t.TextDim
	barB.BackgroundColor3     = t.TextDim
	closeA.BackgroundColor3   = t.TextDim
	closeB.BackgroundColor3   = t.TextDim
end)

--=====================================================================
--  7) 左側分頁欄 (Sidebar / Tabs)
--=====================================================================
local sidebar = create("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, CONFIG.SidebarWidth, 1, -CONFIG.TopBarHeight),
	Position = UDim2.fromOffset(0, CONFIG.TopBarHeight),
	BackgroundColor3 = THEME.SidebarColor,
	BorderSizePixel = 0,
	ZIndex = 3,
	Parent = root,
})
local sidebarSep = create("Frame", {
	Name = "Sep",
	Size = UDim2.new(0, 1, 1, 0),
	Position = UDim2.new(1, -1, 0, 0),
	BackgroundColor3 = THEME.StrokeSoft,
	BorderSizePixel = 0,
	ZIndex = 4,
	Parent = sidebar,
})
local tabList = create("Frame", {
	Name = "TabList",
	Size = UDim2.new(1, -20, 1, -24),
	Position = UDim2.fromOffset(10, 12),
	BackgroundTransparency = 1,
	Parent = sidebar,
})
create("UIListLayout", {
	Parent = tabList,
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
})
create("UIPadding", { Parent = tabList, PaddingTop = UDim.new(0, 2) })
reg(function(t)
	sidebar.BackgroundColor3    = t.SidebarColor
	sidebarSep.BackgroundColor3 = t.StrokeSoft
end)

--=====================================================================
--  8) 右側功能區 — 獨立分頁 (Frame + ClipsDescendants)
--=====================================================================
local contentClip = create("Frame", {
	Name = "Content",
	Size = UDim2.new(1, -CONFIG.SidebarWidth, 1, -CONFIG.TopBarHeight),
	Position = UDim2.fromOffset(CONFIG.SidebarWidth, CONFIG.TopBarHeight),
	BackgroundColor3 = THEME.MainColor,
	BorderSizePixel = 0,
	ClipsDescendants = true,      -- 裁切，不使用 CanvasGroup
	ZIndex = 2,
	Parent = root,
})
reg(function(t) contentClip.BackgroundColor3 = t.MainColor end)

local pages       = {}
local pageCount   = 0
local currentPage = 1
local tabButtons  = {}

local function makePage()
	pageCount += 1
	local idx = pageCount
	local page = create("Frame", {
		Name = "Page" .. idx,
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),   -- 內容區中心
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 2,
		Parent = contentClip,
	})
	create("UIPadding", {
		Parent = page,
		PaddingTop = UDim.new(0, 20),
		PaddingBottom = UDim.new(0, 16),
		PaddingLeft = UDim.new(0, 22),
		PaddingRight = UDim.new(0, 22),
	})
	local col = create("Frame", {
		Name = "Body",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = page,
	})
	create("UIListLayout", {
		Parent = col,
		Padding = UDim.new(0, 14),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	local sep = create("Frame", {
		Name = "Sep",
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = THEME.StrokeSoft,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = page,
	})
	reg(function(t) sep.BackgroundColor3 = t.StrokeSoft end)
	pages[idx] = page
	return page, col, idx
end

local animToken = 0

-- 分頁切換：舊頁滑出+淡出、新頁滑入+淡入，結束後只顯示當前頁
local function gotoPage(index)
	index = math.clamp(index, 1, pageCount)
	if index == currentPage and pages[index] and pages[index].Visible then return end

	local forward = index > currentPage
	local dir     = forward and 1 or -1
	local newPage = pages[index]
	local oldPage = pages[currentPage]

	animToken += 1
	local token = animToken
	currentPage = index

	for i, p in ipairs(pages) do
		if p ~= newPage and p ~= oldPage then
			p.Visible = false
			p.Position = UDim2.fromScale(0.5, 0.5)
		end
	end

	-- 新頁：先放到畫面外、淡出狀態，再滑入 + 淡入
	local newItems = gatherFade(newPage)
	setFade(newItems, 1)
	newPage.Visible = true
	newPage.Position = UDim2.new(0.5, 0, 0.5 + 1.0 * dir, 0)
	fadeTo(newItems, 0, CONFIG.SlideTime, CONFIG.SlideStyle, CONFIG.SlideDir)
	local tIn = tw(newPage, { Position = UDim2.fromScale(0.5, 0.5) },
		CONFIG.SlideTime, CONFIG.SlideStyle, CONFIG.SlideDir)
	irukaTrack(tIn.Completed:Connect(function()
		if token ~= animToken then return end
		setFade(gatherFade(newPage), 0)
		newPage.Position = UDim2.fromScale(0.5, 0.5)
	end))

	-- 舊頁：滑出 + 淡出
	if oldPage and oldPage ~= newPage then
		local oldItems = gatherFade(oldPage)
		fadeTo(oldItems, 1, CONFIG.SlideTime, CONFIG.SlideStyle, CONFIG.SlideDir)
		local tOut = tw(oldPage, { Position = UDim2.new(0.5, 0, 0.5 - 1.0 * dir, 0) },
			CONFIG.SlideTime, CONFIG.SlideStyle, CONFIG.SlideDir)
		irukaTrack(tOut.Completed:Connect(function()
			if token ~= animToken then return end
			oldPage.Visible = false
			oldPage.Position = UDim2.fromScale(0.5, 0.5)
			setFade(gatherFade(oldPage), 0)
		end))
	end

	for i, tab in ipairs(tabButtons) do tab.setActive(i == index) end
end

--=====================================================================
--  9) 分頁按鈕 (Tab Buttons)
--=====================================================================
local function makeTab(label, iconColor)
	local btn = create("Frame", {
		Name = "Tab_" .. label,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = THEME.SurfaceHi,
		BackgroundTransparency = 1,
		Active = true,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = tabList,
	})
	round(btn, 10)
	local indicator = create("Frame", {
		Name = "Indicator",
		Size = UDim2.new(0, 3, 0, 0),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = THEME.AccentColor,
		BorderSizePixel = 0,
		ZIndex = 7,
		Parent = btn,
	})
	round(indicator, 2)
	local dot = create("Frame", {
		Name = "Dot",
		Size = UDim2.fromOffset(7, 7),
		Position = UDim2.new(0, 16, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = iconColor or THEME.TextFaint,
		BorderSizePixel = 0,
		ZIndex = 7,
		Parent = btn,
	})
	round(dot, 2)
	local label_ = create("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, -38, 1, 0),
		Position = UDim2.new(0, 32, 0, 0),
		BackgroundTransparency = 1,
		Font = FONT.Medium,
		TextScaled = false,
		Text = label,
		TextColor3 = THEME.TextDim,
		TextSize = CONFIG.SizeBody,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 7,
		Parent = btn,
	})

	local active, hover = false, false
	local function refresh()
		tw(btn, {
			BackgroundColor3 = active and THEME.SurfaceActive or THEME.SurfaceHi,
			BackgroundTransparency = active and 0 or (hover and 0.25 or 1),
		}, CONFIG.HoverTime)
		tw(indicator, { Size = UDim2.new(0, 3, 0, active and 18 or 0) },
			0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		indicator.BackgroundColor3 = THEME.AccentColor
		tw(label_, { TextColor3 = (active or hover) and THEME.TextColor or THEME.TextDim }, CONFIG.HoverTime)
		tw(dot, {
			BackgroundColor3 = active and (iconColor or THEME.AccentColor) or THEME.TextFaint,
			Size = active and UDim2.fromOffset(9, 9) or UDim2.fromOffset(7, 7),
		}, 0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	end

	local tab = { button = btn, index = nil, setActive = function(s) active = s; refresh() end }
	reg(function(t) refresh() end)

	irukaTrack(btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			hover = true; refresh()
		elseif input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			if tab.index then gotoPage(tab.index) end
		end
	end))
	irukaTrack(btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			hover = false; refresh()
		end
	end))
	return tab
end

--=====================================================================
--  10) 範例頁面元件
--=====================================================================
local function makeSectionTitle(parent, text, sub)
	local holder = create("Frame", {
		Size = UDim2.new(1, 0, 0, sub and 46 or 30),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	local titleLbl = create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Font = FONT.Title,
		TextScaled = false,
		Text = text,
		TextColor3 = THEME.TextColor,
		TextSize = CONFIG.SizeHeading,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})
	reg(function(t) titleLbl.TextColor3 = t.TextColor end)
	if sub then
		local subLbl = create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 16),
			Position = UDim2.fromOffset(0, 24),
			BackgroundTransparency = 1,
			Font = FONT.Body,
			TextScaled = false,
			Text = sub,
			TextColor3 = THEME.TextDim,
			TextSize = CONFIG.SizeSmall,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = holder,
		})
		reg(function(t) subLbl.TextColor3 = t.TextDim end)
	end
	return holder
end

local function makeCard(parent, layoutOrder, widthScale)
	local card = create("Frame", {
		Name = "Card",
		Size = UDim2.new(widthScale or 0.32, -8, 0, 84),
		BackgroundColor3 = THEME.SidebarColor,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder or 1,
		Parent = parent,
	})
	round(card, 12)
	local cardStroke = stroke(card, THEME.StrokeSoft, 1, 0.3)
	reg(function(t)
		card.BackgroundColor3 = t.SidebarColor
		cardStroke.Color = t.StrokeSoft
	end)
	return card
end

local function makeButton(parent, text, primary)
	local btn = create("Frame", {
		Name = "Button",
		Size = UDim2.fromOffset(0, 38),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = primary and THEME.AccentColor or THEME.SurfaceHi,
		Active = true,
		BorderSizePixel = 0,
		Parent = parent,
	})
	round(btn, 10)
	local s = create("UIScale", { Parent = btn, Scale = 1 })
	create("UIPadding", {
		Parent = btn,
		PaddingLeft = UDim.new(0, 18),
		PaddingRight = UDim.new(0, 18),
	})
	local label = create("TextLabel", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Font = FONT.Medium,
		TextScaled = false,
		Text = text,
		TextColor3 = primary and THEME.OnAccent or THEME.TextColor,
		TextSize = CONFIG.SizeBody,
		Parent = btn,
	})
	local function baseColor() return primary and THEME.AccentColor or THEME.SurfaceHi end

	irukaTrack(btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			tw(btn, { BackgroundColor3 = primary and THEME.AccentHover or THEME.SurfaceActive }, CONFIG.HoverTime)
			tw(s, { Scale = 1.045 }, CONFIG.HoverTime)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			tw(s, { Scale = 0.93 }, 0.08)
			task.delay(0.09, function()
				tw(s, { Scale = 1 }, 0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			end)
			print("[AuroraUI] Button pressed:", text)
		end
	end))
	irukaTrack(btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			tw(btn, { BackgroundColor3 = baseColor() }, CONFIG.HoverTime)
			tw(s, { Scale = 1 }, CONFIG.HoverTime)
		end
	end))
	reg(function(t)
		btn.BackgroundColor3 = baseColor()
		label.TextColor3 = primary and t.OnAccent or t.TextColor
	end)
	return btn
end

local function makeToggle(parent, labelText, defaultOn)
	local row = create("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = THEME.SidebarColor,
		BorderSizePixel = 0,
		Parent = parent,
	})
	round(row, 10)
	local rowStroke = stroke(row, THEME.StrokeSoft, 1, 0.35)
	local lbl = create("TextLabel", {
		Size = UDim2.new(1, -80, 1, 0),
		Position = UDim2.fromOffset(16, 0),
		BackgroundTransparency = 1,
		Font = FONT.Medium,
		TextScaled = false,
		Text = labelText,
		TextColor3 = THEME.TextColor,
		TextSize = CONFIG.SizeBody,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	local track = create("Frame", {
		Size = UDim2.fromOffset(42, 22),
		Position = UDim2.new(1, -16, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = THEME.SurfaceHi,
		Active = true,
		BorderSizePixel = 0,
		Parent = row,
	})
	round(track, 11)
	local knob = create("Frame", {
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = THEME.TextDim,
		BorderSizePixel = 0,
		Parent = track,
	})
	round(knob, 8)

	local on = defaultOn and true or false
	local function refresh()
		tw(track, { BackgroundColor3 = on and THEME.AccentColor or THEME.SurfaceHi }, 0.22)
		tw(knob, {
			Position = on and UDim2.fromOffset(42 - 16 - 3, 3) or UDim2.fromOffset(3, 3),
			BackgroundColor3 = on and THEME.OnAccent or THEME.TextDim,
		}, 0.28, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	end
	refresh()
	irukaTrack(track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			on = not on
			refresh()
			print("[AuroraUI] Toggle:", labelText, on and "ON" or "OFF")
		end
	end))
	reg(function(t)
		row.BackgroundColor3 = t.SidebarColor
		rowStroke.Color = t.StrokeSoft
		lbl.TextColor3 = t.TextColor
		refresh()
	end)
	return row
end

local function makeSlider(parent, labelText, initial, layoutOrder)
	local row = create("Frame", {
		Name = "Slider",
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundColor3 = THEME.SidebarColor,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder or 1,
		Parent = parent,
	})
	round(row, 10)
	local rowStroke = stroke(row, THEME.StrokeSoft, 1, 0.35)
	local lbl = create("TextLabel", {
		Size = UDim2.new(1, -90, 0, 20),
		Position = UDim2.fromOffset(16, 9),
		BackgroundTransparency = 1,
		Font = FONT.Medium,
		TextScaled = false,
		Text = labelText,
		TextColor3 = THEME.TextColor,
		TextSize = CONFIG.SizeBody,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	local valueLabel = create("TextLabel", {
		Size = UDim2.fromOffset(80, 20),
		Position = UDim2.new(1, -16, 0, 9),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Font = FONT.Mono,
		TextScaled = false,
		Text = tostring(initial or 0) .. "%",
		TextColor3 = THEME.AccentColor,
		TextSize = CONFIG.SizeBody,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = row,
	})
	local track = create("Frame", {
		Name = "Track",
		Size = UDim2.new(1, -32, 0, 6),
		Position = UDim2.new(0, 16, 1, -18),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = THEME.SurfaceHi,
		BorderSizePixel = 0,
		Parent = row,
	})
	round(track, 3)
	local fill = create("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = THEME.AccentColor,
		BorderSizePixel = 0,
		Parent = track,
	})
	round(fill, 3)
	local fillGradient = create("UIGradient", {
		Rotation = 0,
		Color = ColorSequence.new(THEME.AccentColor, THEME.AccentColor2),
		Parent = fill,
	})
	local knob = create("Frame", {
		Name = "Knob",
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = THEME.TextColor,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = track,
	})
	round(knob, 8)
	local knobStroke = stroke(knob, THEME.AccentColor, 2, 0)
	local hit = create("Frame", {
		Name = "Hit",
		Size = UDim2.new(1, -16, 0, 22),
		Position = UDim2.new(0, 8, 1, -18),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Active = true,
		ZIndex = 3,
		Parent = row,
	})

	local value = math.clamp(initial or 0, 0, 100)
	local active = false
	local function render()
		local p = value / 100
		fill.Size = UDim2.fromScale(p, 1)
		knob.Position = UDim2.new(p, 0, 0.5, 0)
		valueLabel.Text = tostring(math.floor(value + 0.5)) .. "%"
	end
	local function setFromX(x)
		local tp, ts = track.AbsolutePosition, track.AbsoluteSize
		local t = math.clamp((x - tp.X) / math.max(ts.X, 1), 0, 1)
		value = t * 100
		render()
	end
	render()

	-- [v12] 效能優化：拖曳期間才接上全域輸入監聽（原本每個 Slider 整個 Session 都掛著
	--        UserInputService.InputChanged / InputEnded，滑鼠一動就打全部 handler）
	local dragMoved, dragEnded
	irukaTrack(hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			active = true
			setFromX(input.Position.X)
			tw(knob, { Size = UDim2.fromOffset(19, 19) }, 0.12)
			if dragMoved then dragMoved:Disconnect() end
			if dragEnded then dragEnded:Disconnect() end
			dragMoved = irukaTrack(irukaTrack(UserInputService.InputChanged:Connect(function(m)
				if not active then return end
				if m.UserInputType == Enum.UserInputType.MouseMovement or m.UserInputType == Enum.UserInputType.Touch then setFromX(m.Position.X) end
			end)))
			dragEnded = irukaTrack(irukaTrack(UserInputService.InputEnded:Connect(function(e)
				if not active then return end
				active = false
				if dragMoved then dragMoved:Disconnect() dragMoved = nil end
				if dragEnded then dragEnded:Disconnect() dragEnded = nil end
				tw(knob, { Size = UDim2.fromOffset(16, 16) }, 0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				print("[AuroraUI] Slider:", labelText, math.floor(value + 0.5))
			end)))
		end
	end))
	reg(function(t)
		row.BackgroundColor3 = t.SidebarColor
		rowStroke.Color = t.StrokeSoft
		lbl.TextColor3 = t.TextColor
		valueLabel.TextColor3 = t.AccentColor
		track.BackgroundColor3 = t.SurfaceHi
		fill.BackgroundColor3 = t.AccentColor
		fillGradient.Color = ColorSequence.new(t.AccentColor, t.AccentColor2)
		knob.BackgroundColor3 = t.TextColor
		knobStroke.Color = t.AccentColor
	end)
	return row
end

local function makeDropdown(parent, labelText, options, defaultIndex, layoutOrder, onSelect)
	local row = create("Frame", {
		Name = "Dropdown",
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = THEME.SidebarColor,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		LayoutOrder = layoutOrder or 1,
		ZIndex = 6,
		Parent = parent,
	})
	round(row, 10)
	local rowStroke = stroke(row, THEME.StrokeSoft, 1, 0.35)
	local header = create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundTransparency = 1,
		Active = true,
		ZIndex = 7,
		Parent = row,
	})
	local headLbl = create("TextLabel", {
		Size = UDim2.fromOffset(120, 46),
		Position = UDim2.fromOffset(16, 0),
		BackgroundTransparency = 1,
		Font = FONT.Medium,
		TextScaled = false,
		Text = labelText,
		TextColor3 = THEME.TextDim,
		TextSize = CONFIG.SizeBody,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 8,
		Parent = header,
	})
	local current = create("TextLabel", {
		Size = UDim2.fromOffset(0, 46),
		Position = UDim2.new(1, -38, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Font = FONT.Title,
		TextScaled = false,
		Text = options[defaultIndex or 1] or "",
		TextColor3 = THEME.TextColor,
		TextSize = CONFIG.SizeBody,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 8,
		Parent = header,
	})
	local chevron = create("Frame", {
		Name = "Chevron",
		Size = UDim2.fromOffset(8, 8),
		Position = UDim2.new(1, -16, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = THEME.TextDim,
		BorderSizePixel = 0,
		ZIndex = 8,
		Parent = header,
	})
	round(chevron, 2)
	local ITEM_H = 32
	local menu = create("Frame", {
		Name = "Menu",
		Size = UDim2.new(1, -16, 0, 0),
		Position = UDim2.fromOffset(8, 44),
		BackgroundColor3 = THEME.SurfaceHi,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
		ZIndex = 20,
		Parent = row,
	})
	round(menu, 10)
	local menuStroke = stroke(menu, THEME.StrokeColor, 1, 0.2)
	create("UIListLayout", {
		Parent = menu,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	create("UIPadding", {
		Parent = menu,
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
	})

	local open = false
	local itemRefs = {}
	local function closeMenu()
		open = false
		tw(chevron, { Rotation = 0 }, 0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		local t = tw(menu, { Size = UDim2.new(1, -16, 0, 0) }, 0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		irukaTrack(t.Completed:Connect(function() if not open then menu.Visible = false end end))
	end
	local function openMenu()
		open = true
		menu.Visible = true
		tw(chevron, { Rotation = 180 }, 0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		tw(menu, { Size = UDim2.new(1, -16, 0, #options * ITEM_H + 8) }, 0.24, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	end

	for i, opt in ipairs(options) do
		local item = create("Frame", {
			Name = "Item",
			Size = UDim2.new(1, -8, 0, ITEM_H),
			BackgroundColor3 = THEME.SurfaceHi,
			BackgroundTransparency = 1,
			Active = true,
			BorderSizePixel = 0,
			LayoutOrder = i,
			ZIndex = 21,
			Parent = menu,
		})
		round(item, 7)
		local itemLabel = create("TextLabel", {
			Size = UDim2.new(1, -24, 1, 0),
			Position = UDim2.fromOffset(12, 0),
			BackgroundTransparency = 1,
			Font = FONT.Body,
			TextScaled = false,
			Text = opt,
			TextColor3 = THEME.TextDim,
			TextSize = CONFIG.SizeBody,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 22,
			Parent = item,
		})
		itemRefs[i] = { item = item, label = itemLabel }
		irukaTrack(item.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				tw(item, { BackgroundTransparency = 0, BackgroundColor3 = THEME.SurfaceActive }, CONFIG.HoverTime)
				tw(itemLabel, { TextColor3 = THEME.TextColor }, CONFIG.HoverTime)
			elseif input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				current.Text = opt
				print("[AuroraUI] Dropdown:", labelText, "->", opt)
				closeMenu()
				if onSelect then pcall(onSelect, opt, i) end
			end
		end))
		irukaTrack(item.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				tw(item, { BackgroundTransparency = 1 }, CONFIG.HoverTime)
				tw(itemLabel, { TextColor3 = THEME.TextDim }, CONFIG.HoverTime)
			end
		end))
	end

	irukaTrack(header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			tw(row, { BackgroundColor3 = THEME.SurfaceActive }, CONFIG.HoverTime)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			if open then closeMenu() else openMenu() end
		end
	end))
	irukaTrack(header.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			tw(row, { BackgroundColor3 = THEME.SidebarColor }, CONFIG.HoverTime)
		end
	end))
	reg(function(t)
		row.BackgroundColor3 = t.SidebarColor
		rowStroke.Color = t.StrokeSoft
		headLbl.TextColor3 = t.TextDim
		current.TextColor3 = t.TextColor
		chevron.BackgroundColor3 = t.TextDim
		menu.BackgroundColor3 = t.SurfaceHi
		menuStroke.Color = t.StrokeColor
		for _, ref in ipairs(itemRefs) do
			ref.item.BackgroundColor3 = t.SurfaceHi
			ref.label.TextColor3 = t.TextDim
		end
	end)
	return row
end

local function makeTextBox(parent, labelText, placeholder, layoutOrder)
	local row = create("Frame", {
		Name = "TextBoxRow",
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = THEME.SidebarColor,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder or 1,
		Parent = parent,
	})
	round(row, 10)
	local rowStroke = stroke(row, THEME.StrokeSoft, 1, 0.25)
	local lbl = create("TextLabel", {
		Size = UDim2.fromOffset(80, 16),
		Position = UDim2.fromOffset(14, 8),
		BackgroundTransparency = 1,
		Font = FONT.Body,
		TextScaled = false,
		Text = labelText,
		TextColor3 = THEME.TextFaint,
		TextSize = CONFIG.SizeTiny,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	local box = create("TextBox", {
		Name = "Input",
		Size = UDim2.new(1, -28, 0, 22),
		Position = UDim2.fromOffset(14, 24),
		BackgroundTransparency = 1,
		Font = FONT.Body,
		TextScaled = false,
		PlaceholderText = placeholder or "",
		PlaceholderColor3 = THEME.TextFaint,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = CONFIG.SizeBody,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = row,
	})
	irukaTrack(box.Focused:Connect(function()
		tw(rowStroke, { Color = THEME.AccentColor, Transparency = 0, Thickness = 2 }, CONFIG.HoverTime)
		tw(row, { BackgroundColor3 = THEME.SurfaceActive }, CONFIG.HoverTime)
	end))
	irukaTrack(box.FocusLost:Connect(function()
		tw(rowStroke, { Color = THEME.StrokeSoft, Transparency = 0.25, Thickness = 1 }, CONFIG.HoverTime)
		tw(row, { BackgroundColor3 = THEME.SidebarColor }, CONFIG.HoverTime)
		print("[AuroraUI] TextBox:", labelText, "=", box.Text)
	end))
	reg(function(t)
		row.BackgroundColor3 = t.SidebarColor
		rowStroke.Color = t.StrokeSoft
lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
box.TextColor3 = Color3.fromRGB(255, 255, 255)
box.PlaceholderColor3 = Color3.fromRGB(180, 190, 210)
	end)
	return row
end

local function makeBody(parent, text)
	local lbl = create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = FONT.Body,
		RichText = true,
		TextScaled = false,
		Text = text,
		TextColor3 = THEME.TextDim,
		TextSize = CONFIG.SizeBody,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = parent,
	})
	reg(function(t) lbl.TextColor3 = t.TextDim end)
	return lbl
end

local function makeButtonRow(parent, layoutOrder)
	local row = create("Frame", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder or 1,
		Parent = parent,
	})
	create("UIListLayout", {
		Parent = row,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	return row
end

--=====================================================================
--  11) 建立範例分頁：Main / Combat / Settings / Widgets
--=====================================================================
local tabColors = {
	THEME.AccentColor, THEME.AccentColor2, THEME.SuccessColor,
	Color3.fromRGB(245, 178, 96),
}
--=====================================================================
--  11) Iruka 分頁：Home / ESP / Other / BF / Visual / Aim / Config
--=====================================================================
local irukaTabsMap = {
	{key = "home",   field = "tabHome",   label = "Home",   color = tabColors[1]},
	{key = "esp",    field = "tabEsp",    label = "ESP",    color = tabColors[2]},
	{key = "other",  field = "tabOther",  label = "Other",  color = THEME.SuccessColor},
	{key = "bf",     field = "tabBf",     label = "BF",     color = Color3.fromRGB(245, 178, 96)},
	{key = "visual", field = "tabVisual", label = "Visual", color = tabColors[1]},
	{key = "aim",    field = "tabAim",    label = "Aim",    color = tabColors[2]},
	{key = "config", field = "tabConfig", label = "Config", color = tabColors[3]},
}
local irukaContainers = {}
_G.IrukaUIContainers = irukaContainers
for _, d in ipairs(irukaTabsMap) do
	local page, col, idx = makePage()
	local tab = makeTab(d.label, d.color)
	tab.index = idx
	tabButtons[idx] = tab
	irukaContainers[d.field] = tab.button
	-- 內容欄改為可捲動（控件數量多，避免溢出被裁切）
	local scroll = create("ScrollingFrame", {
		Name = "Scroll", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
		BorderSizePixel = 0, ScrollBarThickness = 4, CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = col,
	})
	create("UIListLayout", { Parent = scroll, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder })
	irukaContainers[d.key] = scroll
end
irukaContainers.screenGui = screenGui
pages[1].Visible = true
pages[1].Position = UDim2.fromScale(0.5, 0.5)
currentPage = 1
for i, tab in ipairs(tabButtons) do tab.setActive(i == 1) end


--=====================================================================
--  11.5) 首頁：玩家選單（Select Player + 右側 Refresh）/ 移動速度
--        · 修正下拉文字重疊：標題靠左、選中玩家靠右，各自獨立區塊
--        · Refresh 按鈕與下拉橫向並排（同一列，緊貼右側）
--        · 玩家清單獨立懸浮（高 ZIndex），展開時不擠壓下方 Speed 與其他控件
--=====================================================================
do
	local home = irukaContainers.home

	-- 外層容器（僅保留「選擇列 + 速度列」的高度；清單獨立懸浮，不佔版面流）
	local rootRow = create("Frame", {
		Name = "PlayersRoot",
		Size = UDim2.new(1, 0, 0, 100),
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		ZIndex = 40,
		Parent = home,
	})

	-- ---------------- 第一列：Select Player（左） + Refresh（右） ----------------
	local selectRow = create("Frame", {
		Name = "SelectRow",
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundTransparency = 1,
		ZIndex = 41,
		Parent = rootRow,
	})

	-- Refresh 按鈕：固定寬度，緊貼右側
	local refreshBtn = create("TextButton", {
		Name = "RefreshBtn",
		Size = UDim2.fromOffset(96, 46),
		Position = UDim2.new(1, -96, 0, 0),
		BackgroundColor3 = THEME.SurfaceHi,
		BorderSizePixel = 0,
		Font = FONT.Medium,
		Text = "Refresh",
		TextColor3 = THEME.TextColor,
		TextSize = CONFIG.SizeBody,
		TextScaled = false,
		AutoButtonColor = false,
		ZIndex = 42,
		Parent = selectRow,
	})
	round(refreshBtn, 10)
	local refreshStroke = stroke(refreshBtn, THEME.StrokeSoft, 1, 0.35)

	-- Select Player 盒：佔滿左側剩餘寬度
	local ddBox = create("Frame", {
		Name = "SelectPlayer",
		Size = UDim2.new(1, -108, 0, 46),
		BackgroundColor3 = THEME.SidebarColor,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 42,
		Parent = selectRow,
	})
	round(ddBox, 10)
	local ddStroke = stroke(ddBox, THEME.StrokeSoft, 1, 0.35)
	-- 標題（固定靠左）
	create("TextLabel", {
		Name = "Title",
		Size = UDim2.fromOffset(110, 46),
		Position = UDim2.fromOffset(16, 0),
		BackgroundTransparency = 1,
		Font = FONT.Medium,
		Text = "Select Player",
		TextColor3 = THEME.TextDim,
		TextSize = CONFIG.SizeBody,
		TextScaled = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 43,
		Parent = ddBox,
	})
	-- 目前選中的玩家（固定靠右，各自獨立區塊 -> 不會與標題重疊）
	local ddCurrent = create("TextLabel", {
		Name = "Current",
		Size = UDim2.new(1, -166, 0, 46),
		Position = UDim2.fromOffset(126, 0),
		BackgroundTransparency = 1,
		Font = FONT.Title,
		Text = "",
		TextColor3 = THEME.TextColor,
		TextSize = CONFIG.SizeBody,
		TextScaled = false,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 43,
		Parent = ddBox,
	})
	local ddChevron = create("Frame", {
		Name = "Chevron",
		Size = UDim2.fromOffset(8, 8),
		Position = UDim2.new(1, -16, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = THEME.TextDim,
		BorderSizePixel = 0,
		ZIndex = 43,
		Parent = ddBox,
	})
	round(ddChevron, 2)

	-- ---------------- 玩家清單：獨立懸浮層（高 ZIndex，獨立於版面流） ----------------
	local listFrame = create("Frame", {
		Name = "PlayerList",
		Size = UDim2.new(1, -108, 0, 0),
		Position = UDim2.fromOffset(0, 52),
		BackgroundColor3 = THEME.SurfaceHi,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
		ZIndex = 60,
		Parent = rootRow,
	})
	round(listFrame, 10)
	local listStroke = stroke(listFrame, THEME.StrokeColor, 1, 0.2)
	local listScroll = create("ScrollingFrame", {
		Name = "Scroll",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 61,
		Parent = listFrame,
	})
	create("UIListLayout", {
		Parent = listScroll,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	create("UIPadding", {
		Parent = listScroll,
		PaddingTop = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
	})

	irukaContainers.dropdownCurrent = ddCurrent
	irukaContainers.dropdownFrame = listScroll
	irukaContainers.dropdown = { Text = "" }   -- 相容舊程式對 dropdown.Text 的存取
	irukaContainers.playersRoot = rootRow
	irukaContainers.selectRow = selectRow
	irukaContainers.dropdownBox = ddBox
	irukaContainers.playerListFrame = listFrame
	irukaContainers.refreshBtn = refreshBtn

	-- 依清單內容自動計算展開高度（不會與 Speed 或其他控件擠壓）
	local function listHeight()
		local lay = listScroll:FindFirstChildOfClass("UIListLayout")
		local content = lay and lay.AbsoluteContentSize.Y or 0
		return math.clamp(content + 12, 44, 180)
	end

	local listOpen = false
	local function setListOpen(v)
		v = v and true or false
		if listOpen == v then return end
		listOpen = v
		if v then
			listFrame.Visible = true
			tw(ddChevron, { Rotation = 180 }, 0.20, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			tw(listFrame, { Size = UDim2.new(1, -108, 0, listHeight()) }, 0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		else
			tw(ddChevron, { Rotation = 0 }, 0.20, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			local t = tw(listFrame, { Size = UDim2.new(1, -108, 0, 0) }, 0.20, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			irukaTrack(t.Completed:Connect(function()
				if not listOpen then listFrame.Visible = false end
			end))
		end
	end
	-- 供模組在「選取玩家 / 刷新」後關閉清單
	irukaContainers.togglePlayerList = setListOpen
	irukaContainers.closePlayerList = function() setListOpen(false) end

	irukaTrack(ddBox.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			tw(ddBox, { BackgroundColor3 = THEME.SurfaceActive }, CONFIG.HoverTime)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			setListOpen(not listOpen)
		end
	end))
	irukaTrack(ddBox.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			tw(ddBox, { BackgroundColor3 = THEME.SidebarColor }, CONFIG.HoverTime)
		end
	end))

	-- Refresh：與下拉橫向並排，點擊即刷新玩家清單
	irukaTrack(refreshBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			tw(refreshBtn, { BackgroundColor3 = THEME.SurfaceActive }, CONFIG.HoverTime)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			if _G.IrukaRefreshPlayers then _G.IrukaRefreshPlayers() end
		end
	end))
	irukaTrack(refreshBtn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			tw(refreshBtn, { BackgroundColor3 = THEME.SurfaceHi }, CONFIG.HoverTime)
		end
	end))
	irukaContainers.refreshButton = {
		TextLabel = refreshBtn,
		MouseButton1Click = refreshBtn.MouseButton1Click,
		setText = function(s) refreshBtn.Text = s end,
	}

	-- ---------------- 第二列：移動速度（獨立於清單，不會被展開清單擠壓） ----------------
	local speedRow = create("Frame", {
		Name = "SpeedRow",
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.fromOffset(0, 60),
		BackgroundTransparency = 1,
		ZIndex = 41,
		Parent = rootRow,
	})
	local speedLbl = create("TextLabel", {
		Name = "SpeedLabel",
		Size = UDim2.fromOffset(110, 40),
		BackgroundTransparency = 1,
		Font = FONT.Medium,
		Text = "Speed:",
		TextColor3 = THEME.TextDim,
		TextSize = CONFIG.SizeBody,
		TextScaled = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 42,
		Parent = speedRow,
	})
	local speedBox = create("TextBox", {
		Name = "MoveSpeed",
		Size = UDim2.fromOffset(110, 30),
		Position = UDim2.fromOffset(110, 5),
		BackgroundColor3 = THEME.SurfaceHi,
		BorderSizePixel = 0,
		Font = FONT.Mono,
		Text = "350",
		TextColor3 = THEME.TextColor,
		TextSize = CONFIG.SizeBody,
		ClearTextOnFocus = false,
		PlaceholderText = "350",
		PlaceholderColor3 = THEME.TextFaint,
		ZIndex = 42,
		Parent = speedRow,
	})
	round(speedBox, 8)
	local speedStroke = stroke(speedBox, THEME.StrokeSoft, 1, 0.5)
	irukaTrack(speedBox.Focused:Connect(function()
		speedStroke.Color = THEME.AccentColor
		speedStroke.Transparency = 0
	end))
	irukaTrack(speedBox.FocusLost:Connect(function()
		speedStroke.Color = THEME.StrokeSoft
		speedStroke.Transparency = 0.5
		local n = tonumber(speedBox.Text)
		if n and n > 0 then
			_G.IrukaMoveSpeed = n
		else
			speedBox.Text = "350"
			_G.IrukaMoveSpeed = 350
		end
	end))
	irukaContainers.speedLabel = speedLbl
	irukaContainers.speedBox = speedBox
	_G.IrukaMoveSpeed = tonumber(speedBox.Text) or 350
end

local function irukaProxy(obj, lbl, clickSignal)
	local bag = {}
	return setmetatable(bag, {
		__index = function(_, k)
			if k == "TextLabel" then return lbl end
			if k == "MouseButton1Click" and clickSignal then return clickSignal end
			local v = rawget(bag, k)
			if v ~= nil then
				if type(v) == "function" then return function(_, ...) return v(...) end end
				return v
			end
			v = obj[k]
			if type(v) == "function" then
				return function(_, ...) return v(obj, ...) end
			end
			return v
		end,
		__newindex = function(_, k, v)
			if k == "Text" then
				if lbl and lbl.Text ~= nil then lbl.Text = v else bag.Text = v end
			else
				rawset(bag, k, v)
			end
		end,
	})
end

local function irukaToggle(parent, label, default, cb)
	local row = makeToggle(parent, label, default)
	local track = row:FindFirstChildOfClass("Frame")
	local lbl = row:FindFirstChildOfClass("TextLabel")
	local state = default and true or false
	if track then
		irukaTrack(track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				state = not state
				if cb then cb(state) end
			end
		end))
	end
	local proxy = irukaProxy(row, lbl, nil)
	proxy.set = function(v)
		state = v and true or false
		if track then
			local knob = track:FindFirstChildOfClass("Frame")
			track.BackgroundColor3 = state and THEME.AccentColor or THEME.SurfaceHi
			if knob then
				knob.Position = state and UDim2.fromOffset(42 - 16 - 3, 3) or UDim2.fromOffset(3, 3)
			end
		end
	end
	proxy.get = function() return state end
	return proxy
end

local function irukaButton(parent, text, cb)
	local btn = makeButton(parent, text, false)
	local lbl = btn:FindFirstChildOfClass("TextLabel")
	local overlay = create("TextButton", {
		Name = "Hit", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "",
		ZIndex = 10, Parent = btn,
	})
	if cb then irukaTrack(overlay.MouseButton1Click:Connect(cb)) end
	return irukaProxy(btn, lbl, overlay.MouseButton1Click)
end

local function irukaInput(parent, label, defaultText, cb)
	local row = makeTextBox(parent, label, tostring(defaultText or ""), nil)
	local lbl = row:FindFirstChildOfClass("TextLabel")
	local box = row:FindFirstChild("Input")
	if box and cb then irukaTrack(box.FocusLost:Connect(function() cb(box.Text) end)) end
	local proxy = irukaProxy(row, lbl, nil)
	proxy.box = box
	return proxy
end
-- [v10] 下拉選單工廠
local function irukaDropdown(parent, labelText, options, defaultIndex, onSelect)
	local row = makeDropdown(parent, labelText, options, defaultIndex, nil, onSelect)
	local header = row:FindFirstChild("Header")
	local lbl = header and header:FindFirstChildOfClass("TextLabel") or nil
	return irukaProxy(row, lbl, nil)
end
_G.IrukaUIFactory = { toggle = irukaToggle, button = irukaButton, input = irukaInput, dropdown = irukaDropdown }

-- 右上滑入通知（Aurora 風格）
local function irukaNotify(text, color)
	local card = create("Frame", {
		Name = "Notify", Size = UDim2.new(0, 240, 0, 54), AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 260, 0, 16), BackgroundColor3 = THEME.SurfaceHi, BorderSizePixel = 0,
		ZIndex = 200, Parent = screenGui,
	})
	round(card, 10)
	stroke(card, THEME.StrokeColor, 1, 0.2)
	local bar = create("Frame", { Size = UDim2.fromOffset(3, 30), Position = UDim2.fromOffset(0, 12),
		BackgroundColor3 = color or THEME.AccentColor, BorderSizePixel = 0, ZIndex = 201, Parent = card })
	round(bar, 2)
	create("TextLabel", { Size = UDim2.new(1, -22, 1, 0), Position = UDim2.fromOffset(16, 0),
		BackgroundTransparency = 1, Font = FONT.Medium, Text = text, TextColor3 = THEME.TextColor,
		TextSize = CONFIG.SizeSmall, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 201, Parent = card })
	tw(card, { Position = UDim2.new(1, -16, 0, 16) }, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	task.delay(3, function()
		tw(card, { Position = UDim2.new(1, 260, 0, 16) }, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay(0.4, function() card:Destroy() end)
	end)
end
_G.IrukaUINotify = irukaNotify

--=====================================================================
--  14.0) 共用狀態宣告（提早宣告，供確認彈窗與收縮動畫使用）
--=====================================================================
local minimized, closing = false, false
local normalSize = CONFIG.WindowSize
local savedPos = Vector2.new(0, 0)
local rootFade = nil
local setMinimized      -- 於 14) 指派
local closeWindowCore   -- 於 14) 指派（真正執行銷毀動畫）
local closeRequest      -- 於 14.5) 指派（先跳二次確認彈窗）

--=====================================================================
--  11.9) 手機 UI 自適應（螢幕自動縮放 + 四角 L 握把手動縮放）
--        · 依 ViewportSize 自動計算縮放比例（手機預設自動適配，不再過大）
--        · 手機顯示四角 L 型握把：拖曳可縮放整個介面，並顯示縮放 % 提醒
--        · 非手機裝置維持原樣（僅在視窗超出畫面時才自動縮小）
--=====================================================================
local function irukaSetupMobileScale()
	local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local MIN_UI_SCALE, MAX_UI_SCALE = 0.35, 1.5
	local manualScale = false
	local rootScale = create("UIScale", { Parent = root, Scale = 1 })

	local function scaledSize(s)
		return Vector2.new(normalSize.X.Offset * s, normalSize.Y.Offset * s)
	end

	-- 以「中心固定」方式套用縮放，並重新夾限於畫面內
	local function applyScale(newScale)
		newScale = math.clamp(newScale, MIN_UI_SCALE, MAX_UI_SCALE)
		local oldSize = scaledSize(rootScale.Scale)
		local center = position + oldSize * 0.5
		rootScale.Scale = newScale
		local newSize = scaledSize(newScale)
		position = clampToScreen(center - newSize * 0.5, newSize)
		dragTarget = position
		applyPosition()
		return newScale
	end

	local function computeFitScale()
		local vp = viewport()
		local margin = IS_MOBILE and 12 or 24
		local fit = math.min(
			(vp.X - margin) / math.max(1, normalSize.X.Offset),
			(vp.Y - margin) / math.max(1, normalSize.Y.Offset)
		)
		return math.clamp(fit, MIN_UI_SCALE, 1)
	end

	-- 啟動時：手機一律自適應；其他裝置僅在視窗超出畫面時縮小
	local fit = computeFitScale()
	if IS_MOBILE or fit < 1 then
		applyScale(fit)
	end

	if camera then
		irukaTrack(camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			local newFit = computeFitScale()
			if (IS_MOBILE and not manualScale) or rootScale.Scale > newFit then
				applyScale(newFit)
			end
		end))
	end

	if not IS_MOBILE then return end

	-- ---------------- 縮放提醒（浮動於視窗旁，不隨縮放變形） ----------------
	local scaleHint = create("Frame", {
		Name = "ScaleHint",
		Size = UDim2.fromOffset(150, 30),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromOffset(0, 0),
		BackgroundColor3 = THEME.SurfaceHi,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 150,
		Parent = screenGui,
	})
	round(scaleHint, 8)
	local scaleHintStroke = stroke(scaleHint, THEME.StrokeColor, 1, 0.2)
	local scaleHintLabel = create("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = FONT.Medium,
		TextScaled = false,
		Text = "",
		TextColor3 = THEME.TextColor,
		TextSize = CONFIG.SizeSmall,
		ZIndex = 151,
		Parent = scaleHint,
	})
	reg(function(t)
		scaleHint.BackgroundColor3 = t.SurfaceHi
		scaleHintStroke.Color = t.StrokeColor
		scaleHintLabel.TextColor3 = t.TextColor
	end)

	local function showScaleHint()
		scaleHintLabel.Text = (Config.Language and "縮放 " or "Scale ")
			.. math.floor(rootScale.Scale * 100 + 0.5) .. "%"
		local ap, as = root.AbsolutePosition, root.AbsoluteSize
		local vp = viewport()
		local x = ap.X + as.X * 0.5
		local y
		if ap.Y + as.Y + 42 > vp.Y then
			scaleHint.AnchorPoint = Vector2.new(0.5, 1)
			y = ap.Y - 8
		else
			scaleHint.AnchorPoint = Vector2.new(0.5, 0)
			y = ap.Y + as.Y + 8
		end
		x = math.clamp(x, 80, math.max(80, vp.X - 80))
		y = math.clamp(y, 4, math.max(4, vp.Y - 34))
		scaleHint.Position = UDim2.fromOffset(math.floor(x), math.floor(y))
		scaleHint.Visible = true
	end

	local function hideScaleHint()
		scaleHint.Visible = false
	end

	-- ---------------- 四角 L 型握把 ----------------
	local HANDLE = 20
	local cornerDefs = {
		{ key = "TL", hAlign = 0, vAlign = 0 },
		{ key = "TR", hAlign = 1, vAlign = 0 },
		{ key = "BL", hAlign = 0, vAlign = 1 },
		{ key = "BR", hAlign = 1, vAlign = 1 },
	}
	local handleRefs = {}
	for _, def in ipairs(cornerDefs) do
		local h = create("Frame", {
			Name = "ScaleHandle_" .. def.key,
			Size = UDim2.fromOffset(HANDLE, HANDLE),
			Position = UDim2.new(def.hAlign, def.hAlign == 1 and -HANDLE or 0, def.vAlign, def.vAlign == 1 and -HANDLE or 0),
			BackgroundTransparency = 1,
			Active = true,
			ZIndex = 30,
			Parent = root,
		})
		local barH = create("Frame", {
			Name = "BarH",
			Size = UDim2.new(1, 0, 0, 3),
			Position = UDim2.new(0, 0, def.vAlign, def.vAlign == 1 and -3 or 0),
			BackgroundColor3 = THEME.AccentColor,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			ZIndex = 31,
			Parent = h,
		})
		local barV = create("Frame", {
			Name = "BarV",
			Size = UDim2.new(0, 3, 1, 0),
			Position = UDim2.new(def.hAlign, def.hAlign == 1 and -3 or 0, 0, 0),
			BackgroundColor3 = THEME.AccentColor,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			ZIndex = 31,
			Parent = h,
		})
		round(barH, 2)
		round(barV, 2)
		handleRefs[#handleRefs + 1] = { frame = h, def = def, barH = barH, barV = barV }
	end
	reg(function(t)
		for _, ref in ipairs(handleRefs) do
			ref.barH.BackgroundColor3 = t.AccentColor
			ref.barV.BackgroundColor3 = t.AccentColor
		end
	end)

	local scaleDrag = nil

	local function cornerAbs(def)
		local ap, as = root.AbsolutePosition, root.AbsoluteSize
		return Vector2.new(
			def.hAlign == 1 and (ap.X + as.X) or ap.X,
			def.vAlign == 1 and (ap.Y + as.Y) or ap.Y
		)
	end

	for _, ref in ipairs(handleRefs) do
		irukaTrack(ref.frame.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch then return end
			local center = root.AbsolutePosition + root.AbsoluteSize * 0.5
			local dir = cornerAbs(ref.def) - center
			if dir.Magnitude < 1 then dir = Vector2.new(1, 1) end
			scaleDrag = {
				startScale = rootScale.Scale,
				startInput = Vector2.new(input.Position.X, input.Position.Y),
				dir = dir.Unit,
				ref = math.max(160, (root.AbsoluteSize.X + root.AbsoluteSize.Y) * 0.35),
			}
			manualScale = true
			showScaleHint()
		end))
	end

	irukaTrack(UserInputService.InputChanged:Connect(function(input)
		if not scaleDrag then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local delta = Vector2.new(input.Position.X, input.Position.Y) - scaleDrag.startInput
		local proj = delta:Dot(scaleDrag.dir)
		applyScale(scaleDrag.startScale + proj / scaleDrag.ref)
		showScaleHint()
	end))

	irukaTrack(UserInputService.InputEnded:Connect(function(input)
		if not scaleDrag then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		scaleDrag = nil
		task.delay(0.9, function()
			if not scaleDrag then hideScaleHint() end
		end)
	end))

	-- 手機啟動提示（L 握把提醒）
	task.delay(1.5, function()
		pcall(function()
			irukaNotify(Config.Language and "手機模式：拖曳四角 L 握把可縮放介面"
				or "Mobile: drag the corner L handles to resize", THEME.AccentColor)
		end)
	end)
end
irukaSetupMobileScale()

--=====================================================================
--  12) 縮小後懸浮列 (Top-Center Floating Bar) — 標準 Frame
--=====================================================================
local setMinimized

local FLOAT_W, FLOAT_H = 268, 44
local DRAG_THRESHOLD = 5

local floating = create("Frame", {
	Name = "FloatingBar",
	Size = UDim2.fromOffset(FLOAT_W, FLOAT_H),
	AnchorPoint = Vector2.new(0.5, 0),          -- 頂邊中點
	Position = UDim2.new(0.5, 0, 0, 10),        -- 頂部正中央（距頂 10px）
	BackgroundColor3 = THEME.SurfaceHi,
	BorderSizePixel = 0,
	Active = true,
	Visible = false,
	ZIndex = 50,
	Parent = screenGui,
})
round(floating, 14)
local floatStroke     = stroke(floating, THEME.StrokeColor, 1, 0.15)
local floatGlowStroke = stroke(floating, THEME.AccentColor, 1.5, 0.55)
local floatGradient = create("UIGradient", {
	Rotation = 90,
	Color = ColorSequence.new(THEME.SurfaceHi, THEME.SidebarColor),
	Parent = floating,
})
local floatScale = create("UIScale", { Parent = floating, Scale = 1 })

local floatLogo = create("ImageLabel", {
	Name = "Logo",
	Size = UDim2.fromOffset(24, 24),
	Position = UDim2.new(0, 12, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundTransparency = 1,
	Image = "rbxassetid://125855645824065",
	ImageColor3 = Color3.fromRGB(255, 255, 255),
	ScaleType = Enum.ScaleType.Fit,
	BorderSizePixel = 0,
	ZIndex = 51,
	Parent = floating,
})
round(floatLogo, 8)

-- ★ 標題文字：100% 動態跟隨 CONFIG.Title（與主窗同步，非寫死）
floatingTitle = create("TextLabel", {
	Name = "Title",
	Size = UDim2.new(1, -50, 1, 0),
	Position = UDim2.fromOffset(44, 0),
	BackgroundTransparency = 1,
	Font = FONT.Title,
	TextScaled = false,
	Text = CONFIG.Title,
	TextColor3 = THEME.TextColor,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.None,
	TextWrapped = false,
	ZIndex = 51,
	Parent = floating,
})


local floatPos, floatTarget = Vector2.new(0, 0), Vector2.new(0, 0)
local floatDragging, floatMoved, floatSettle = false, false, nil
local floatStartInput, floatStartPos = Vector2.new(0, 0), Vector2.new(0, 0)
local floatPlaced = false

reg(function(t)
	floating.BackgroundColor3 = t.SurfaceHi
	floatStroke.Color = t.StrokeColor
	floatGlowStroke.Color = t.AccentColor
	floatGradient.Color = ColorSequence.new(t.SurfaceHi, t.SidebarColor)
	floatLogo.ImageColor3 = Color3.fromRGB(255, 255, 255)
	floatingTitle.TextColor3 = t.TextColor
end)

local function applyFloatPosition()
	floating.Position = UDim2.fromOffset(math.floor(floatPos.X + 0.5), math.floor(floatPos.Y + 0.5))
end

local function clampFloat(p)
	local tl, br = screenRectLocal()
	local fs = floating.AbsoluteSize
	local fw = (fs.X > 1) and fs.X or FLOAT_W
	local fh = (fs.Y > 1) and fs.Y or FLOAT_H
	local minX = tl.X + fw * 0.5
	local maxX = br.X - fw * 0.5
	local minY = tl.Y
	local maxY = br.Y - fh
	return Vector2.new(
		math.clamp(p.X, minX, math.max(minX, maxX)),
		math.clamp(p.Y, minY, math.max(minY, maxY))
	)
end

-- [Iruka] 依標題實際文字寬度動態調整懸浮列寬度（確保腳本名 100% 完整顯示）
irukaFitFloating = function()
	floatLogo.Position = UDim2.new(0, 12, 0.5, 0)
	local ok, bounds = pcall(function() return floatingTitle.TextBounds end)
	local tw = (ok and bounds and bounds.X) or 0
	if not tw or tw <= 0 then
		local n = (type(floatingTitle.Text) == "string") and #floatingTitle.Text or 0
		tw = n * CONFIG.SizeBody * 0.62
	end
	local w = math.max(FLOAT_W, math.ceil(12 + 24 + 10 + tw + 14))
	floating.Size = UDim2.fromOffset(w, FLOAT_H)
	floatingTitle.Size = UDim2.new(0, math.max(24, math.ceil(tw + 2)), 1, 0)
	floatingTitle.Position = UDim2.fromOffset(46, 0)
	floatingTitle.TextYAlignment = Enum.TextYAlignment.Center
	floatingTitle.TextXAlignment = Enum.TextXAlignment.Left
	floatingTitle.TextTruncate = Enum.TextTruncate.None
	floatingTitle.TextWrapped = false
	if floatPlaced then
		floatPos = clampFloat(floatPos)
		floatTarget = floatPos
		applyFloatPosition()
	end
end

local function placeFloatingDefault()
	local tl, br = screenRectLocal()
	local centerX = (tl.X + br.X) * 0.5
	floatPos = clampFloat(Vector2.new(centerX, tl.Y + 10))
	floatTarget = floatPos
	applyFloatPosition()
	floatPlaced = true
end

local floatFade
local function showFloating()
	irukaFitFloating()
	if not floatPlaced then placeFloatingDefault() end
	floatFade = gatherFade(floating)
	setFade(floatFade, 1)
	floating.Visible = true
	applyFloatPosition()
	fadeTo(floatFade, 0, 0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	tw(floatScale, { Scale = 1 }, 0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function hideFloating()
	if not floating.Visible then return end
	local items = gatherFade(floating)
	fadeTo(items, 1, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	task.delay(0.19, function()
		floating.Visible = false
		setFade(gatherFade(floating), 0)
	end)
end

irukaTrack(floating.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		tw(floatScale, { Scale = 1.10 }, CONFIG.HoverTime)
	elseif input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		floatDragging = true
		floatMoved = false
		floatStartInput = input.Position
		floatStartPos = floatPos
		floatTarget = floatPos
		if floatSettle then floatSettle:Cancel(); floatSettle = nil end
		tw(floatScale, { Scale = 0.90 }, 0.08)
	end
end))
irukaTrack(floating.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		tw(floatScale, { Scale = 1 }, CONFIG.HoverTime)
	end
end))

local function endFloatDrag()
	if not floatDragging then return end
	floatDragging = false
	tw(floatScale, { Scale = 1 }, 0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	if floatMoved then
		local final = clampFloat(floatTarget)
		floatPos, floatTarget = final, final
		if floatSettle then floatSettle:Cancel() end
		floatSettle = tw(floating, {
			Position = UDim2.fromOffset(math.floor(final.X + 0.5), math.floor(final.Y + 0.5)),
		}, CONFIG.SettleTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		irukaTrack(floatSettle.Completed:Connect(function()
			floatPos = final
			applyFloatPosition()
		end))
	else
		if setMinimized then setMinimized(false) end
	end
end

--=====================================================================
--  13) 阻尼拖曳系統 (Damped Dragging)
--=====================================================================
local dragStartInput, dragStartPos = Vector2.new(), Vector2.new()

local function pointInside(guiObject, p)
	local ap, as = guiObject.AbsolutePosition, guiObject.AbsoluteSize
	return p.X >= ap.X and p.X <= ap.X + as.X and p.Y >= ap.Y and p.Y <= ap.Y + as.Y
end
local function isOverControl(p)
	for _, btn in ipairs(controlButtons) do
		if pointInside(btn, p) then return true end
	end
	return false
end
local function beginDrag(input)
	if dragging then return end
	if isOverControl(input.Position) then return end
	dragging = true
	if settleTween then settleTween:Cancel(); settleTween = nil end
	dragStartInput = input.Position
	dragStartPos = position
	dragTarget = position
end
local function endDrag()
	if not dragging then return end
	dragging = false
	local final = clampToScreen(dragTarget)
	position = final
	local goal = UDim2.fromOffset(math.floor(final.X + 0.5), math.floor(final.Y + 0.5))
	if settleTween then settleTween:Cancel() end
	settleTween = tw(root, { Position = goal }, CONFIG.SettleTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	irukaTrack(settleTween.Completed:Connect(function()
		root.Position = goal
		position = final
	end))
end

irukaTrack(topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		beginDrag(input)
	end
end))

irukaTrack(UserInputService.InputChanged:Connect(function(input)
	local isPointer = input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	if not isPointer then return end
	if dragging then
		local delta = input.Position - dragStartInput
		dragTarget = clampToScreen(dragStartPos + Vector2.new(delta.X, delta.Y))
	end
	if floatDragging then
		local delta = input.Position - floatStartInput
		if delta.Magnitude >= DRAG_THRESHOLD then floatMoved = true end
		floatTarget = clampFloat(floatStartPos + Vector2.new(delta.X, delta.Y))
	end
end))

irukaTrack(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		endDrag()
		endFloatDrag()
	end
end))

irukaTrack(RunService.RenderStepped:Connect(function(dt)
	if not dragging and not floatDragging then return end
	local alpha = 1 - math.exp(-CONFIG.Damping * dt)
	if dragging then
		position = position:Lerp(dragTarget, alpha)
		applyPosition()
	end
	if floatDragging then
		floatPos = floatPos:Lerp(floatTarget, alpha)
		applyFloatPosition()
	end
end))
--=====================================================================
--  14.5) 關閉二次確認彈窗 (Close Confirmation Modal)
--        點擊右上角 (X) 不直接銷毀；先由主視窗中心彈出確認框，
--        確認 -> 執行縮小收縮銷毀動畫；取消 -> Tween 淡出關閉。
--        完全沿用 THEME 色彩 / 圓角 / 按鈕質感。
--=====================================================================
local confirmModal = nil

local function closeConfirmModal()
	if not confirmModal then return end
	local m = confirmModal
	confirmModal = nil
	local items = gatherFade(m)
	fadeTo(items, 1, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local shrink = tw(m, { Size = UDim2.fromOffset(0, 0) }, 0.18, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	irukaTrack(shrink.Completed:Connect(function() m:Destroy() end))
end

local function openConfirmModal()
	if confirmModal then return end

	local a = root.AbsoluteSize
	if a.X < 1 then a = Vector2.new(normalSize.X.Offset, normalSize.Y.Offset) end
	local center = position + Vector2.new(a.X * 0.5, a.Y * 0.5)

	local m = create("Frame", {
		Name = "CloseConfirm",
		Size = UDim2.fromOffset(0, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(math.floor(center.X + 0.5), math.floor(center.Y + 0.5)),
		BackgroundColor3 = THEME.SidebarColor,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		ZIndex = 120,
		Parent = screenGui,
	})
	round(m, 14)
	-- [手機適配] 確認彈窗跟隨主視窗縮放比例
	local rootUIScale = root:FindFirstChildOfClass("UIScale")
	if rootUIScale and rootUIScale.Scale ~= 1 then
		create("UIScale", { Parent = m, Scale = rootUIScale.Scale })
	end
	local mStroke = stroke(m, THEME.StrokeColor, 1, 0.15)
	local mGlow = stroke(m, THEME.AccentColor, 1.5, 0.6)
	local mGrad = create("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new(THEME.SurfaceHi, THEME.SidebarColor),
		Parent = m,
	})
	confirmModal = m
	if not rootFade then rootFade = gatherFade(root) end
	fadeTo(gatherFade(m), 0, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	tw(m, { Size = UDim2.fromOffset(320, 160) }, 0.30, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	-- 頂部強調條
	local accentBar = create("Frame", {
		Name = "AccentBar",
		Size = UDim2.new(1, -32, 0, 3),
		Position = UDim2.fromOffset(16, 18),
		BackgroundColor3 = THEME.AccentColor,
		BorderSizePixel = 0,
		ZIndex = 121,
		Parent = m,
	})
	round(accentBar, 2)

	local title = create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -32, 0, 26),
		Position = UDim2.fromOffset(16, 34),
		BackgroundTransparency = 1,
		Font = FONT.Title,
		Text = "Are you sure?",
		TextColor3 = THEME.TextColor,
		TextSize = CONFIG.SizeHeading,
		TextScaled = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 121,
		Parent = m,
	})
	local desc = create("TextLabel", {
		Name = "Desc",
		Size = UDim2.new(1, -32, 0, 40),
		Position = UDim2.fromOffset(16, 62),
		BackgroundTransparency = 1,
		Font = FONT.Body,
		RichText = true,
		Text = "Are you sure you want to close the interface?",
		TextColor3 = THEME.TextDim,
		TextSize = CONFIG.SizeBody,
		TextScaled = false,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = 121,
		Parent = m,
	})

	-- 按鈕列（沿用 makeButton 的外觀：圓角、UIScale、hover/click 動畫）
	local row = create("Frame", {
		Name = "Buttons",
		Size = UDim2.new(1, -32, 0, 38),
		Position = UDim2.new(0, 16, 1, -54),
		BackgroundTransparency = 1,
		ZIndex = 121,
		Parent = m,
	})
	create("UIListLayout", {
		Parent = row,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	local function makeModalButton(text, primary, order, onClick)
		local btn = create("Frame", {
			Name = primary and "Confirm" or "Cancel",
			Size = UDim2.fromOffset(primary and 120 or 96, 38),
			BackgroundColor3 = primary and THEME.AccentColor or THEME.SurfaceHi,
			BorderSizePixel = 0,
			Active = true,
			LayoutOrder = order,
			ZIndex = 122,
			Parent = row,
		})
		round(btn, 10)
		local bStroke = stroke(btn, THEME.StrokeSoft, 1, primary and 1 or 0.35)
		local bScale = create("UIScale", { Scale = 1, Parent = btn })
		local lbl = create("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Font = FONT.Medium,
			TextScaled = false,
			Font = FONT.Medium,
			Text = text,
			TextColor3 = primary and THEME.OnAccent or THEME.TextColor,
			TextSize = CONFIG.SizeBody,
			ZIndex = 123,
			Parent = btn,
		})
		irukaTrack(btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				tw(btn, { BackgroundColor3 = primary and THEME.AccentHover or THEME.SurfaceActive }, CONFIG.HoverTime)
				tw(bScale, { Scale = 1.045 }, CONFIG.HoverTime)
			elseif input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				tw(bScale, { Scale = 0.93 }, 0.08)
				task.delay(0.09, function()
					tw(bScale, { Scale = 1 }, 0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				end)
				if onClick then onClick() end
			end
		end))
		irukaTrack(btn.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				tw(btn, { BackgroundColor3 = primary and THEME.AccentColor or THEME.SurfaceHi }, CONFIG.HoverTime)
				tw(bScale, { Scale = 1 }, CONFIG.HoverTime)
			end
		end))
		return btn
	end
	local cancelBtn = makeModalButton("Cancel", false, 1, function() closeConfirmModal() end)
	local confirmBtn = makeModalButton("Confirm", true, 2, function()
		closeConfirmModal()
		-- [v12] Confirm 即執行完整卸載（GUI / 連線 / Drawing / 角色狀態；配置檔保留）
		if _G.IrukaHubUnload then _G.IrukaHubUnload() else closeWindowCore() end
	end)
	-- 記錄為控制項，避免拖曳時誤判；Esc 可取消
	controlButtons[#controlButtons + 1] = confirmBtn
	controlButtons[#controlButtons + 1] = cancelBtn
end
-- 對外：請求關閉（先跳確認框）
closeRequest = function()
	if confirmModal then closeConfirmModal() return end
	openConfirmModal()
end
--=====================================================================
--  14) 縮小 / 還原 / 關閉
--=====================================================================
local function setRootCenter(center)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromOffset(math.floor(center.X + 0.5), math.floor(center.Y + 0.5))
end
local function showRoot()
	if not rootFade then rootFade = gatherFade(root) end
	setFade(rootFade, 0)
	root.Visible = true
end
setMinimized = function(state)
	if closing or minimized == state then return end
	minimized = state
	local logical = Vector2.new(normalSize.X.Offset, normalSize.Y.Offset)
	local a = root.AbsoluteSize
	if a.X < 1 then a = logical end
	if minimized then
		savedPos = position
		local center = position + Vector2.new(a.X * 0.5, a.Y * 0.5)
		tw(barB, { Rotation = 90 }, 0.30, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		tw(barA, { Rotation = 0 }, 0.30, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		rootFade = gatherFade(root)
		setRootCenter(center)
		tw(root, { Size = UDim2.fromOffset(12, 12) }, 0.32, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		fadeTo(rootFade, 1, 0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		task.delay(0.34, function()
			if not minimized or closing then return end
			root.Visible = false
			root.AnchorPoint = Vector2.new(0, 0)
			root.Size = normalSize
			position = savedPos
			dragTarget = position
			applyPosition()
			setFade(gatherFade(root), 0)
			showFloating()
		end)
	else
		hideFloating()
		local center = savedPos + Vector2.new(a.X * 0.5, a.Y * 0.5)
		setRootCenter(center)
		root.Size = UDim2.fromOffset(12, 12)
		rootFade = gatherFade(root)
		setFade(rootFade, 1)
		root.Visible = true
		tw(root, { Size = normalSize }, 0.36, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		fadeTo(rootFade, 0, 0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		tw(barB, { Rotation = 0 }, 0.30, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		tw(barA, { Rotation = 0 }, 0.30, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		task.delay(0.38, function()
			if minimized or closing then return end
			root.AnchorPoint = Vector2.new(0, 0)
			root.Size = normalSize
			position = clampToScreen(savedPos)
			dragTarget = position
			applyPosition()
		end)
	end
end
irukaTrack(minBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		setMinimized(not minimized)
	end
end))
-- 關閉：以中心 (AnchorPoint 0.5,0.5) 向內收縮 + 漸隱，Completed 後 Destroy
closeWindowCore = function()
	if closing then return end
	closing = true
	if settleTween then settleTween:Cancel(); settleTween = nil end
	if floatSettle then floatSettle:Cancel(); floatSettle = nil end
	dragging, floatDragging = false, false
	local target = minimized and floating or root
	local logical = Vector2.new(normalSize.X.Offset, normalSize.Y.Offset)
	local a = (target == root) and root.AbsoluteSize or floating.AbsoluteSize
	if a.X < 1 then a = logical end
	if target == root then
		local basePos = minimized and savedPos or position
		local center = basePos + Vector2.new(a.X * 0.5, a.Y * 0.5)
		root.Visible = true
		root.AnchorPoint = Vector2.new(0.5, 0.5)
		root.Position = UDim2.fromOffset(math.floor(center.X + 0.5), math.floor(center.Y + 0.5))
		if root.Size.X.Offset < 1 then root.Size = normalSize end
		if not rootFade then rootFade = gatherFade(root) end
		fadeTo(rootFade, 1, 0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	else
		local items = gatherFade(floating)
		fadeTo(items, 1, 0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end
	local shrink = tw(target, { Size = UDim2.fromOffset(0, 0) }, 0.34, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	irukaTrack(shrink.Completed:Connect(function()
		screenGui:Destroy()
	end))
end
irukaTrack(closeBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		closeRequest()
	end
end))
--=====================================================================
--  15) 對外 API
--=====================================================================
_G.AuroraUI = {
	ScreenGui = screenGui,
	Root      = root,
	Floating  = floating,
	Goto      = gotoPage,
	Minimize  = setMinimized,
	Restore   = function() setMinimized(false) end,
	Close     = closeRequest,
	Pages     = pages,
	SetTheme  = applyTheme,
	SetTitle  = setTitle,
	Themes    = THEMES,
}
applyTheme(CONFIG.Theme)
-- [Iruka] 標題統一更名為 Iruka Hub[Premium]（主 UI 左上角 + 懸浮窗同步）
CONFIG.Title = "Iruka Hub[Premium]"
setTitle(CONFIG.Title)
-- 進場淡入（收集所有子孫透明度後 tween 回基礎值）
rootFade = gatherFade(root)
setFade(rootFade, 1)
root.Visible = true
fadeTo(rootFade, 0, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
print("Iruka Hub[Premium] by ZERO/Kexuan")
--=====================================================================
--  Iruka Hub 功能模組（所有戰鬥 / 工具 / 世界邏輯）
--=====================================================================
-- =====================================================================
-- [v16] 已徹底移除所有混淆器巨集標記：NoClip / SpeedHackV2 / StatsGui 的每幀
--       監聽器全部還原為原生匿名函數，確保 Junkie / Luraph v15 可正常混淆。
-- =====================================================================
;(function()


--------------------------------------------------------------------------------
-- [Aurora UI 改造]  原「Iruka Hub」舊介面（mainFrame / titleBar / 分頁按鈕 /
--  各 ScrollingFrame 分頁 / 目標玩家下拉 / 通知框 ...）已整段移除，改由下方
--  AURORA UI 框架提供介面。以下保留後續功能程式碼仍會引用到的變數，確保所有
--  戰鬥邏輯（追尾 / ESP / Fast Attack / SilentAim / Auto Kill / Hitbox ...）
--  100% 原封不動可執行。
--------------------------------------------------------------------------------
local irukaCore = game:GetService("CoreGui")

-- 原獨立小面板：TP Gui / Stats Gui（與 Aurora UI 並存，維持原功能）
local tpGui = Instance.new("ScreenGui")
tpGui.Name = "TPGui"
tpGui.ResetOnSpawn = false
pcall(function() tpGui.Parent = irukaCore end)
if not tpGui.Parent then pcall(function() tpGui.Parent = playerGui end) end
tpGui.Enabled = Config.TpGui

local statsGui = Instance.new("ScreenGui")
statsGui.Name = "StatsGui"
statsGui.ResetOnSpawn = false
pcall(function() statsGui.Parent = irukaCore end)
if not statsGui.Parent then pcall(function() statsGui.Parent = playerGui end) end
statsGui.Enabled = Config.StatsGui

local statsFrame = Instance.new("Frame", statsGui)
statsFrame.Size = UDim2.new(0, 320, 0, 30)
statsFrame.Position = UDim2.new(0.03, 0, 0, 0)
statsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
statsFrame.BackgroundTransparency = 0.2
statsFrame.Active = true
local statsFrameCorner = Instance.new("UICorner", statsFrame)
statsFrameCorner.CornerRadius = UDim.new(0, 12)

local statsLabel = Instance.new("TextLabel", statsFrame)
statsLabel.Size = UDim2.new(1, 0, 1, 0)
statsLabel.BackgroundTransparency = 1
statsLabel.FontFace = CUSTOM_FONT or Enum.Font.GothamBold
statsLabel.TextSize = 14
statsLabel.TextColor3 = Color3.new(1, 1, 1)
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Text = ""

-- 原「移動速度」變數（teleportTo 使用；可由輸入框即時改寫）
local MOVE_SPEED = 350

--------------------------------------------------------------------------------
-- 通知系統（Aurora 風格右上滑入提示；取代原 notifyFrame 實作）
--------------------------------------------------------------------------------
local irukaNotifyHolder = _G.IrukaUINotify
local function showNotification(textEn, textJp, color)
	if irukaNotifyHolder then
		irukaNotifyHolder(Config.Language and textJp or textEn, color)
		return
	end
	-- 後備：若框架通知未就緒，退回純輸出，不中斷任何邏輯
	print(Config.Language and textJp or textEn)
end

--------------------------------------------------------------------------------
-- 世界判定（placeId / 海域 / 島嶼座標）— 原封不動保留
--------------------------------------------------------------------------------
local placeId = tostring(game.PlaceId)
local sea = nil
local islands = {}
local pos1
local pos2
local bloxFruitsMode = false
if placeId == "4442272183" or placeId == "79091703265657" then
	bloxFruitsMode = true
	sea = "2nd"
	showNotification("Success!\nBlox Fruits Mode ON(2nd)", "成功！\n海賊王模式開啟(第二海)", Color3.fromRGB(255, 255, 255))
	islands = {
		["Swan Mansion"] = Vector3.new(-390, 332, 673),
		["Swan Room"] = Vector3.new(2285, 15, 905),
		["Cursed Ship"] = Vector3.new(923, 126, 32852),
		["Zombie Island"] = Vector3.new(-6509, 83, -133)
	}
	pos1 = Vector3.new(-287, 375, 597.9)
	pos2 = Vector3.new(938, 252.7, 32888)
elseif placeId == "7449423635" or placeId == "100117331123089" then
	bloxFruitsMode = true
	sea = "3rd"
	showNotification("Success!\nBlox Fruits Mode ON(3rd)", "成功！\n海賊王模式開啟(第三海)", Color3.fromRGB(255, 255, 255))
	islands = {
		["Floating Turtle"] = Vector3.new(-12462, 375, -7552),
		["Hydra Island"] = Vector3.new(5657.88623046875, 1013.0790405273438, -335.4996337890625),
		["Mansion"] = Vector3.new(-12462, 375, -7552),
		["Castle"] = Vector3.new(-5036, 315, -3179),
		["Dimensional Shift"] = Vector3.new(-2097.3447265625, 4776.24462890625, -15013.4990234375),
		["Beautiful Pirate"] = Vector3.new(5319, 23, -93),
		["Beautiful Room"] = Vector3.new(5314.58203, 22.5364361, -125.942276, 1, 2.14762768E-8, -1.99111154E-13, -2.14762768E-8, 1, -3.0510602E-8, 1.98455903E-13, 3.0510602E-8, 1),
		["Temple of Time"] = Vector3.new(28286, 14897, 103)
	}
	pos1 = Vector3.new(-12471, 374, -7554)
	pos2 = Vector3.new(-12492, 580, -6930)
elseif placeId == "85211729168715" or placeId == "2753915549" then
	bloxFruitsMode = true
	sea = "1st"
	islands = {
		["Sky3"] = Vector3.new(-7894, 5547, -380),
		["Sky3Exit"] = Vector3.new(-4607, 874, -1667),
		["UnderWater"] = Vector3.new(61163, 11, 1819),
		["Underwater City"] = Vector3.new(61165.19140625, 0.18704631924629211, 1897.379150390625),
		["Pirate Village"] = Vector3.new(-1242.4625244140625, 4.787059783935547, 3901.282958984375),
		["UnderwaterExit"] = Vector3.new(4050, -1, -1814)
	}
	showNotification("Success!\nBlox Fruits Mode ON(1st)", "成功！\n海賊王模式開啟(第一海)", Color3.fromRGB(255, 255, 255))
	pos1 = Vector3.new(-4652, 873, -1754)
	pos2 = Vector3.new(3865, 5, -1926)
elseif placeId == "73902483975735" then
	bloxFruitsMode = true
	sea = "Dungeon"
	islands = {}
	showNotification("Success!\nBlox Fruits Mode ON(Dungeon)", "成功！\n海賊王模式開啟(副本)", Color3.fromRGB(255, 255, 255))
	pos1 = Vector3.new(0, 0, 0)
	pos2 = Vector3.new(0, 0, 0)
end


--------------------------------------------------------------------------------
-- [Aurora UI]  由框架分頁取得各功能容器（對應原本的 buttonScroll / espFrame /
--  otherRightScroll / bloxfruitsRightScroll ...），並提供 Aurora 風格控件工廠。
--  後續所有功能程式碼把 createSwitch/createButton/createInputBox 換成
--  irukaAddToggle / irukaAddButton / irukaAddInput 即可直接掛上 Aurora 分頁。
--------------------------------------------------------------------------------
local irukaFactory   = _G.IrukaUIFactory
local irukaContainer = _G.IrukaUIContainers

-- 對應舊 UI 的各容器（全部指向對應的 Aurora 分頁內容欄）
local screenGui             = irukaContainer.screenGui
local buttonScroll          = irukaContainer.home
local espFrame              = irukaContainer.esp
local otherLeftScroll       = irukaContainer.other
local otherRightScroll      = irukaContainer.other
local bloxfruitsLeftScroll  = irukaContainer.bf
local bloxfruitsRightScroll = irukaContainer.bf
local visualLeftScroll      = irukaContainer.visual
local visualRightScroll     = irukaContainer.visual
local aimLeftScroll         = irukaContainer.aim
local aimRightScroll        = irukaContainer.aim
local configLeftScroll      = irukaContainer.config
local configRightScroll     = irukaContainer.config
local speedLabel            = irukaContainer.speedLabel
local dropdown              = irukaContainer.dropdown
local dropdownFrame         = irukaContainer.dropdownFrame
local refreshButton

-- 舊分頁按鈕（changeLanguage 會改其標籤文字；此處指向 Aurora 分頁按鈕）
local homeButton            = irukaContainer.tabHome
local espButton             = irukaContainer.tabEsp
local otherButton           = irukaContainer.tabOther
local bloxfruitsButton      = irukaContainer.tabBf
local visualButton          = irukaContainer.tabVisual
local aimButton             = irukaContainer.tabAim
local configButton          = irukaContainer.tabConfig

local irukaAddToggle = irukaFactory.toggle
local irukaAddButton = irukaFactory.button
local irukaAddInput  = irukaFactory.input
local irukaAddDropdown = irukaFactory.dropdown

-- ★ 記錄所有建立出來的「移動追蹤 (Move to Target)」開關，供各處重置邏輯使用。
--   （Aurora UI 無舊版 SwitchBase 結構，改以清單精確重置。）
local irukaMovingToggles = {}

-- ★ 安全設定 Aurora 分頁標籤文字（取代舊 changeLanguage 直接改 .Text）
local function irukaSetTabLabel(btn, txt)
	local lbl = btn and btn:FindFirstChild("Label")
	if lbl then lbl.Text = txt end
end

local selectedTarget = nil

local function updatePlayerList()
	for _, child in ipairs(dropdownFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -10, 0, 30)
			btn.Position = UDim2.new(0, 5, 0, 0)
			btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Text = plr.Name
			btn.FontFace = CUSTOM_FONT or Enum.Font.GothamBold
			btn.TextSize = 14
			btn.AutoButtonColor = true
			btn.Parent = dropdownFrame

			irukaTrack(btn.MouseButton1Click:Connect(function()
				selectedTarget = plr
				if irukaContainer.dropdownCurrent then irukaContainer.dropdownCurrent.Text = "Target: " .. plr.Name end
				if irukaContainer.closePlayerList then irukaContainer.closePlayerList() end
			end))
		end
	end

	local layout = dropdownFrame:FindFirstChildOfClass("UIListLayout")
	if not layout then
		layout = Instance.new("UIListLayout")
		layout.Parent = dropdownFrame
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 4)
	end
	dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	if irukaContainer.closePlayerList then irukaContainer.closePlayerList() end
end

-- 供 Aurora 首頁的 Refresh 按鈕呼叫
_G.IrukaRefreshPlayers = updatePlayerList

-- [Aurora UI] 舊版控件工廠已移除（由 irukaFactory 代理提供）

local refreshButton = irukaAddButton(buttonScroll, "Refresh", function() updatePlayerList() end)
irukaTrack(refreshButton.MouseButton1Click:Connect(function()
	updatePlayerList()
end))
function getNearestVehicleSeat()
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return nil
	end
	local root = character.HumanoidRootPart
	local nearestSeat = nil
	local nearestDistance = math.huge
	for _, descendant in ipairs(workspace.Boats:GetDescendants()) do
		if descendant:IsA("VehicleSeat") then
			local distance = (descendant.Position - root.Position).Magnitude
			if distance < nearestDistance then
				nearestDistance = distance
				nearestSeat = descendant
			end
		end
	end
	return nearestSeat
end

local takeShip = irukaAddButton(buttonScroll,"Take Ship")
irukaTrack(takeShip.MouseButton1Click:Connect(function()
	if not selectedTarget or not selectedTarget.Character and bloxFruitsMode then
		return
	end
	local vehicleSeat = getNearestVehicleSeat()
	if vehicleSeat and vehicleSeat.Occupant then
		local humanoid = vehicleSeat.Occupant
		if humanoid.Parent == player.Character then
			local parent = vehicleSeat.Parent
			if parent then
				local seat = parent:FindFirstChildWhichIsA("Seat")
				if seat then
					local offset = vehicleSeat.CFrame:ToObjectSpace(seat.CFrame)

					local hrp = selectedTarget.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						local newVehicleSeatCFrame = hrp.CFrame * offset:Inverse()

						local char = player.Character
						if char and char:FindFirstChild("HumanoidRootPart") then
							char.HumanoidRootPart.CFrame = newVehicleSeatCFrame
						end
					end
				end
			end
		end
	end
end))

local followPlatform = nil
local currentTween = nil

function createFollowPlatform(position)
	if followPlatform then
		followPlatform:Destroy()
	end
	followPlatform = Instance.new("Part")
	followPlatform.Size = Vector3.new(4, 1, 4)
	followPlatform.Anchored = true
	followPlatform.CanCollide = false
	followPlatform.Transparency = 1
	followPlatform.Position = position
	followPlatform.Parent = workspace
end

function destroyFollowPlatform()
	if followPlatform then
		followPlatform:Destroy()
		followPlatform = nil
	end
	if currentTween then
		currentTween:Cancel()
		currentTween = nil
	end
end

local useCircleTarget = false
local useTween = true

function teleportTo(position)
	if not player.Character then return end
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if not followPlatform or not followPlatform.Parent then
		createFollowPlatform(hrp.Position - Vector3.new(0, 2.5, 0))
	end
	
	if currentTween then
		currentTween:Cancel()
		currentTween = nil
	end

	if useTween and not useCircleTarget then
		local distance = (position - followPlatform.Position).Magnitude
		local time = distance / (_G.IrukaMoveSpeed or MOVE_SPEED)

		currentTween = TweenService:Create(
			followPlatform,
			TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{Position = position}
		)

		if followPlatform and followPlatform.Parent and hrp.Parent then
			hrp.CFrame = CFrame.new(
				followPlatform.Position + Vector3.new(0, 2.5, 0)
			)
		end
		currentTween:Play()
	else
		hrp.CFrame = CFrame.new(position + Vector3.new(0, 2.5, 0))
	end
end

function CheckNearestTeleporter(TargetPos)
    local distance = math.huge
    local nearestIslandPos = nil

    for _, islandPos in pairs(islands) do
        local magnitude = (islandPos - TargetPos).Magnitude
        if magnitude < distance then
            distance = magnitude
            nearestIslandPos = islandPos
        end
    end
    if distance <= (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - TargetPos).Magnitude - 50 then
        return nearestIslandPos
    else
        return 
    end
end

function CheckNearestTeleporter(TargetPos)
    local myPos = player.Character.HumanoidRootPart.Position
    local distance = math.huge
    local nearestIslandPos = nil

    local targetPosForCalc = TargetPos
    local myPosForCalc = myPos

    if Config.BypassYTween or Config.HideTween then
        targetPosForCalc = Vector3.new(TargetPos.X, 0, TargetPos.Z)
        myPosForCalc = Vector3.new(myPos.X, 0, myPos.Z)
    end

    for _, islandPos in pairs(islands) do
        local islandPosForCalc = islandPos
        
        if Config.BypassYTween or Config.HideTween then
            islandPosForCalc = Vector3.new(islandPos.X, 0, islandPos.Z)
        end

        local magnitude = (islandPosForCalc - targetPosForCalc).Magnitude
        
        if magnitude < distance then
            distance = magnitude
            nearestIslandPos = islandPos
        end
    end

    local myDistToTarget = (myPosForCalc - targetPosForCalc).Magnitude

    if distance <= myDistToTarget - 50 then
        return nearestIslandPos
    else
        return nil
    end
end

function requestEntrance(pos)
	game.ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", pos)
	local HumanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, Config.TpYOffset, 0)
    --task.wait(.1)
end

local circleAngle = 0

function getCirclePosition(targetPos, deltaTime)
    circleAngle += Config.CircleSpeed * deltaTime

    local finalAngle = circleAngle
    
    if Config.CircleType == true then
        local step = math.pi / 2 
        finalAngle = math.floor(circleAngle / step) * step
    end

    local x = math.cos(finalAngle) * Config.CircleRadius
    local z = math.sin(finalAngle) * Config.CircleRadius

    return targetPos + Vector3.new(x, 0, z)
end

local moving = false

irukaTrack(RunService.Heartbeat:Connect(function(delta)
	if moving and selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local basePos = selectedTarget.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
			local distance = (hrp.Position - basePos).Magnitude

			if Config.UseOffset then basePos = basePos + Vector3.new(Config.OffsetX, Config.OffsetY, Config.OffsetZ) end

			local targetPos = basePos

			if Config.CircleTarget and Config.CircleRadius > distance - 30 then
				useCircleTarget = true
				targetPos = getCirclePosition(basePos, delta)
			else 
				useCircleTarget = false
				targetPos = basePos
			end

			if bloxFruitsMode and useTween then
				local nearestIslandPos = CheckNearestTeleporter(targetPos)
            	if nearestIslandPos then
					destroyFollowPlatform()
                	requestEntrance(nearestIslandPos)
				elseif Config.BypassYTween and not Config.HideTween then
    				if math.abs(hrp.Position.Y - targetPos.Y) > 50 then
						destroyFollowPlatform()
        				hrp.CFrame = CFrame.new(hrp.Position.X, targetPos.Y, hrp.Position.Z)
    				end
				elseif Config.HideTween then
					if (Vector3.new(basePos.X, 0, basePos.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude < 50 then
						if tick() % 0.17 <= 0.09 then
							destroyFollowPlatform()
							hrp.CFrame = CFrame.new(basePos)
							targetPos = basePos
						else
							destroyFollowPlatform()
							hrp.CFrame = CFrame.new(basePos + Vector3.new(0, 9712, 0))
							targetPos = basePos + Vector3.new(0, 129659712, 0)
						end
					else
						targetPos = basePos + Vector3.new(0, 129659712, 0)
					end
					if hrp.Position.Y < targetPos.Y - 1000 then
						destroyFollowPlatform()
						hrp.CFrame = CFrame.new(hrp.Position.X, 129659712, hrp.Position.Z)
					end
				end

			end
			teleportTo(targetPos)
		end
	else
		destroyFollowPlatform()
	end
end))

local movingSwitch =irukaAddToggle(buttonScroll, "Move to Target", false, function(state)
	moving = state
end)
table.insert(irukaMovingToggles, movingSwitch)

local moveModeSwitch = irukaAddToggle(buttonScroll, "Tween Mode (TP/Tween)", true, function(state)
	useTween = state
end)

local BypassYTweenSwitch = irukaAddToggle(buttonScroll, "Bypass Y Tween", Config.BypassYTween, function(state)
	Config.BypassYTween = state
	SaveConfig()
end)

local circleModeSwitch = irukaAddToggle(buttonScroll, "Circle Target", Config.CircleTarget, function(state)
	Config.CircleTarget = state
	SaveConfig()
end)

local circleTypeSwitch = irukaAddToggle(buttonScroll, "Circle Type", Config.CircleType, function(state)
	Config.CircleType = state
	SaveConfig()
end)

local CircleSpeedInput = irukaAddInput(buttonScroll,"CircleSpeed",tostring(Config.CircleSpeed),function(value)
	local num =tonumber(value)
	if num and num >= 0 then
		Config.CircleSpeed = num
		SaveConfig()
	end
end)

local CircleRadiusInput = irukaAddInput(buttonScroll,"CircleRadius",tostring(Config.CircleRadius),function(value)
	local num =tonumber(value)
	if num and num >= 0 then
		Config.CircleRadius = num
		SaveConfig()
	end
end)

local hideTweenSwitch = irukaAddToggle(buttonScroll, "Hide Tween", Config.HideTween, function(state)
	Config.HideTween = state
	SaveConfig()
end)

local useOffsetSwitch = irukaAddToggle(buttonScroll, "Use Offset", Config.UseOffset, function(state)
	Config.UseOffset = state
	SaveConfig()
end)

local xOffsetInput = irukaAddInput(buttonScroll,"X Offset",tostring(Config.OffsetX),function(value)
	local num =tonumber(value)
	if num and num >= 0 then
		Config.OffsetX = num
		SaveConfig()
	end
end)

local yOffsetInput = irukaAddInput(buttonScroll,"Y Offset",tostring(Config.OffsetY),function(value)
	local num =tonumber(value)
	if num and num >= 0 then
		Config.OffsetY = num
		SaveConfig()
	end
end)

local zOffsetInput = irukaAddInput(buttonScroll,"Z Offset",tostring(Config.OffsetZ),function(value)
	local num =tonumber(value)
	if num and num >= 0 then
		Config.OffsetZ = num
		SaveConfig()
	end
end)

local camLock = false
local playerView =false

-- [v13] 效能：Cam Lock / Player View 皆關閉時整段跳過（原本每幀仍做 5 次 FindFirstChild 並重寫 CameraSubject）
local camViewActive = false
irukaTrack(RunService.Heartbeat:Connect(function()
	if not camLock and not playerView then
		if camViewActive then
			camViewActive = false
			local cam0 = workspace.CurrentCamera
			local myHum = player.Character and player.Character:FindFirstChild("Humanoid")
			if cam0 and myHum then cam0.CameraSubject = myHum end
		end
		return
	end

	local cam = workspace.CurrentCamera
	if not cam then return end
	local tChar = selectedTarget and selectedTarget.Character

	if playerView and tChar then
		local tHum = tChar:FindFirstChild("Humanoid")
		if tHum then
			if cam.CameraSubject ~= tHum then cam.CameraSubject = tHum end
			camViewActive = true
			return
		end
	end

	if camLock and tChar then
		local head = tChar:FindFirstChild("Head")
		if head then cam.CFrame = CFrame.new(cam.CFrame.Position, head.Position) end
	end
end))

local camLockSwitch = irukaAddToggle(buttonScroll, "Cam Lock", false, function(state)
	camLock = state
end)

local viewSwitch = irukaAddToggle(buttonScroll, "Player View", false, function(state)
	playerView =state
end)

local tracers = {}
local NameEspConnections = {}

function addNameEsp(plr)
    if plr.Character.Head:FindFirstChild("irukaNameESP") then return end

	local BillBoardSize = UDim2.new(0, 160, 0, 30)
	if Config.NameESP and Config.KenESP then
		BillBoardSize = UDim2.new(0, 160, 0, 50)
	elseif not Config.NameESP and Config.KenESP then
		BillBoardSize = UDim2.new(0, 160, 0, 15)
	end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "irukaNameESP"
    billboard.Size = BillBoardSize
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = plr.Character.Head

    local label = Instance.new("TextLabel", billboard)
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Position = UDim2.new(0.5, 0, 0.5, 0)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.5
    label.FontFace = CUSTOM_FONT or Enum.Font.Cartoon
    label.TextScaled = true
    label.RichText = true

    billboard.Parent = plr.Character.Head

    local _espNext = 0
    function updateLabel()
        local _espNow = os.clock()
        if _espNow < _espNext then return end
        _espNext = _espNow + 0.1
        local char = plr.Character
        local myChar = player.Character
        local humanoid = char and char:FindFirstChild("Humanoid")
    
        if not (myChar and myChar:FindFirstChild("HumanoidRootPart")) then return end
        if not (char and char:FindFirstChild("HumanoidRootPart") and humanoid) then return end

		local BillBoardSize = UDim2.new(0, 160, 0, 30)
		if Config.NameESP and Config.KenESP then
			BillBoardSize = UDim2.new(0, 160, 0, 50)
		elseif not Config.NameESP and Config.KenESP then
			BillBoardSize = UDim2.new(0, 160, 0, 15)
		end

		billboard.Size = BillBoardSize

        local distance = (myChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
        local lines = {}

        if Config.NameESP then
            local fruitName = ""
            if Config.FruitESP then
                pcall(function()
                    local devilFruit = plr.Data and plr.Data:FindFirstChild("DevilFruit")
                    if devilFruit and devilFruit.Value then
                        fruitName = string.format(" <font color='rgb(255,105,180)'>%s</font>", tostring(devilFruit.Value))
                    end
                end)
            end
            table.insert(lines, string.format(
                "<font color='rgb(255,255,255)'>%s</font>%s <font color='rgb(0,255,0)'> %.0f m </font>\n" ..
                "<font color='rgb(0,255,255)'>[%d / %d]</font>",
                plr.Name, fruitName, distance, math.floor(humanoid.Health), humanoid.MaxHealth
            ))
        end

        if Config.KenESP then
            local KenActiveValue = plr:GetAttribute("KenActive")
            local KenDodgesLeft = plr:GetAttribute("KenDodgesLeft") or 0
            local KenMaxDodges = plr:GetAttribute("KenMaxDodges") or 0

            if KenActiveValue == nil then
                table.insert(lines, "<font color='rgb(200,200,200)'>Ken: None</font>")
            else
                local statusText = KenActiveValue and "Active" or "Inactive"
                local statusColor = KenActiveValue and "rgb(0,255,0)" or "rgb(255,0,0)"
                
                table.insert(lines, string.format(
                    "<font color='rgb(255,165,0)'>Ken: </font><font color='%s'>%s</font><font color='rgb(255,165,0)'> [%d/%d]</font>",
                    statusColor, statusText, KenDodgesLeft, KenMaxDodges
                ))
            end
        end

        label.Text = table.concat(lines, "\n")
    end

    updateLabel()

    NameEspConnections[plr] = irukaTrack(RunService.PostSimulation:Connect(updateLabel))
end

function addBoxEsp(plr, v2)
	local hrp = plr.Character.HumanoidRootPart
	if hrp:FindFirstChild("irukaBoxESP") then return end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "irukaBoxESP"
	box.Size = v2 and Vector3.new(45,35,0.1) or Vector3.new(4,7,2)
	box.Color3 = v2 and Color3.new(0.4,0.4,0.4) or Color3.new(0, 0, 1)
	box.Transparency = 0.5
	box.AlwaysOnTop = true
	box.ZIndex = 5
	box.Adornee = hrp
	box.Parent = hrp
end

function addaHighlight(plr)
    local character = plr.Character
    if character and character:FindFirstChild("irukaHighlight") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "irukaHighlight"
    highlight.FillColor = Color3.fromRGB(195, 130, 254)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
end

task.spawn(function()
    while task.wait(1) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then continue end
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == player then continue end
            local char = plr.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Head") then continue end
            
            local hrp = char.HumanoidRootPart
            local head = char.Head
            local humanoid = char:FindFirstChild("Humanoid")

            if Config.NameESP  or Config.KenESP then addNameEsp(plr) end
            if Config.BoxESPV1 then addBoxEsp(plr, false) end
            if Config.BoxESPV2 then addBoxEsp(plr, true) end
			if Config.HighlightESP then addaHighlight(plr) end
        end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not Config.TracerESP then
            continue 
        end

        local myHRP = player.Character.HumanoidRootPart
        local myPos, onScreen1 = camera:WorldToViewportPoint(myHRP.Position)

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == player then continue end
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChild("Humanoid")

            if Config.TracerESP and hrp and humanoid and humanoid.Health > 0 then
                if not tracers[plr] then
                    local line = irukaTrackDrawing(Drawing.new("Line"))
                    line.Thickness = 2
                    line.Color = Color3.fromRGB(222,225,255)
                    tracers[plr] = line
                end

                local targetPos, onScreen2 = camera:WorldToViewportPoint(hrp.Position)
                local line = tracers[plr]

                if onScreen1 and onScreen2 then
                    line.From = Vector2.new(myPos.X, myPos.Y)
                    line.To = Vector2.new(targetPos.X, targetPos.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                if tracers[plr] then
                    tracers[plr]:Remove()
                    tracers[plr] = nil
                end
            end
        end
    end
end)

local nameespSwitch = irukaAddToggle(espFrame, "Name ESP", Config.NameESP, function(state)
	Config.NameESP = state
	SaveConfig()
	if state then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				addNameEsp(plr)
			end
		end
	elseif not state and not Config.KenESP then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChild("Head") then
				local esp = plr.Character.Head:FindFirstChild("irukaNameESP")
				if NameEspConnections[plr] then
					NameEspConnections[plr]:Disconnect()
					NameEspConnections[plr] = nil
				end
				if esp then esp:Destroy() end
			end
		end
	end
end)

local box1espSwitch = irukaAddToggle(espFrame, "Box ESP V1", Config.BoxESPV1, function(state)
	Config.BoxESPV1 = state
	SaveConfig()
	if Config.BoxESPV1 then
		Config.BoxESPV2 = false 
		SaveConfig()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				addBoxEsp(plr, false)
			end
		end
	else
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = plr.Character.HumanoidRootPart
				local box = hrp:FindFirstChild("irukaBoxESP")
				if box then box:Destroy() end
			end
		end
	end
end)

local box2espSwitch = irukaAddToggle(espFrame, "Box ESP V2", Config.BoxESPV2, function(state)
	Config.BoxESPV2 = state
	SaveConfig()
	if Config.BoxESPV2 then
		Config.BoxESPV1 = false
		SaveConfig() 
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				addBoxEsp(plr, true)
			end
		end
	else
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = plr.Character.HumanoidRootPart
				local box = hrp:FindFirstChild("irukaBoxESP")
				if box then box:Destroy() end
			end
		end
	end
end)

local tracerespSwitch = irukaAddToggle(espFrame, "Tracer ESP", Config.TracerESP, function(state)
	Config.TracerESP = state
	SaveConfig()
	if state then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and not tracers[plr] and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local line = irukaTrackDrawing(Drawing.new("Line"))
				line.Thickness = 2
				line.Color = Color3.fromRGB(222,225,255)
				tracers[plr] = line
			end
		end
	else
		for plr, line in pairs(tracers) do
			if line then
				line:Remove()
			end
			tracers[plr] = nil
		end
	end
end)

local highlighSwitch = irukaAddToggle(espFrame, "Highlight ESP", Config.HighlightESP, function(state)
	Config.HighlightESP = state
	SaveConfig()
	if state then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and not tracers[plr] and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				addaHighlight(plr)
			end
		end
	else
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local highlight = plr.Character:FindFirstChild("irukaHighlight")
				if highlight then
					highlight:Destroy()
				end
			end
		end
	end
end)

local kenespSwitch = irukaAddToggle(espFrame, "Ken ESP", Config.KenESP, function(state)
	Config.KenESP = state
	SaveConfig()
	if state then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and not tracers[plr] and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				addNameEsp(plr)
			end
		end
	elseif not state and not Config.NameESP then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local esp = plr.Character.Head:FindFirstChild("irukaNameESP")
				if NameEspConnections[plr] then
					NameEspConnections[plr]:Disconnect()
					NameEspConnections[plr] = nil
				end
				if esp then esp:Destroy() end
			end
		end
	end
end)

local fruitespSwitch = irukaAddToggle(espFrame, "Fruit ESP", Config.FruitESP, function(state)
	Config.FruitESP = state
	SaveConfig()
end)

function flygui()
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local LocalPlayer = Players.LocalPlayer


	local main = Instance.new("ScreenGui")
	main.Name = "main"
	main.Parent = playerGui
	main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	main.ResetOnSpawn = false

	local Frame = Instance.new("Frame", main)
	Frame.Size = UDim2.new(0, 190, 0, 57)
	Frame.Position = UDim2.new(0.1, 0, 0.38, 0)
	Frame.Active = true
	Frame.Draggable = true
	Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
	Frame.BackgroundTransparency = 0.1

	function addUICorner(obj, radius)
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0,radius)
		corner.Parent = obj
	end
	addUICorner(Frame, 10)

	function createButton(name, parent, size, pos, text, bgColor, textColor, textSize)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Parent = parent
		btn.Size = size
		btn.Position = pos
		btn.Text = text
		btn.FontFace = CUSTOM_FONT or Enum.Font.RobotoMono
		btn.TextColor3 = textColor
		btn.TextSize = textSize
		btn.BackgroundColor3 = bgColor
		btn.BackgroundTransparency = 0.1
		addUICorner(btn, 8)
		return btn
	end

	local up = createButton("up", Frame, UDim2.new(0,44,0,28), UDim2.new(0,0,0,0), "UP", Color3.fromRGB(0,0,0), Color3.fromRGB(255,255,255), 14)
	local down = createButton("down", Frame, UDim2.new(0,44,0,28), UDim2.new(0,0,0.49,0), "DOWN", Color3.fromRGB(50,50,50), Color3.fromRGB(255,255,255), 14)
	local onof = createButton("onof", Frame, UDim2.new(0,56,0,28), UDim2.new(0.7,0,0.49,0), "fly", Color3.fromRGB(0,0,0), Color3.fromRGB(255,255,255), 14)
	local plus = createButton("plus", Frame, UDim2.new(0,45,0,28), UDim2.new(0.23,0,0,0), "+", Color3.fromRGB(50,50,50), Color3.fromRGB(255,255,255), 14)
	local mine = createButton("mine", Frame, UDim2.new(0,45,0,29), UDim2.new(0.23,0,0.49,0), "-", Color3.fromRGB(50,50,50), Color3.fromRGB(255,255,255), 14)
	local closebutton = createButton("Close", Frame, UDim2.new(0,45,0,28), UDim2.new(0,0,-1,27), "X", Color3.fromRGB(200,0,0), Color3.fromRGB(255,255,255), 30)
	local mini = createButton("minimize", Frame, UDim2.new(0,45,0,28), UDim2.new(0,44,-1,27), "-", Color3.fromRGB(0,0,0), Color3.fromRGB(255,255,255), 40)
	local mini2 = createButton("minimize2", Frame, UDim2.new(0,45,0,28), UDim2.new(0,44,-1,57), "+", Color3.fromRGB(50,50,50), Color3.fromRGB(255,255,255), 40)
	mini2.Visible = false

	local TextLabel = Instance.new("TextLabel", Frame)
	TextLabel.Size = UDim2.new(0,100,0,28)
	TextLabel.Position = UDim2.new(0.47,0,0,0)
	TextLabel.Text = "iruka hub fly"
	TextLabel.FontFace = CUSTOM_FONT or Enum.Font.RobotoMono
	TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
	TextLabel.TextScaled = true
	TextLabel.TextWrapped = true
	TextLabel.BackgroundColor3 = Color3.fromRGB(20,20,20)
	TextLabel.BackgroundTransparency = 0.1
	addUICorner(TextLabel, 8)

	local speed = Instance.new("TextBox", Frame)
	speed.Size = UDim2.new(0,44,0,28)
	speed.Position = UDim2.new(0.47,0,0.49,0)
	speed.Text = "1"
	speed.FontFace = CUSTOM_FONT or Enum.Font.RobotoMono
	speed.TextColor3 = Color3.fromRGB(255,255,255)
	speed.TextScaled = true
	speed.TextWrapped = true
	speed.BackgroundColor3 = Color3.fromRGB(20,20,20)
	speed.BackgroundTransparency = 0.1
	addUICorner(speed, 8)

	local speeds = 1
	local nowe = false
	local speaker = LocalPlayer

	local connection

	function Loop()
		if connection then
			connection:Disconnect()
		end
	
		connection = irukaTrack(RunService.Heartbeat:Connect(function()
			if not nowe or not speaker.Character or not speaker.Character:FindFirstChild("Humanoid") then 
				connection:Disconnect()
				connection = nil
				return 
			end

		if main and nowe then
				speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)

				if speaker.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Swimming then
					speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
				end
			else
				speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
			end
		end))
	end

	onof.MouseButton1Down:connect(function()
		if nowe == true then
			nowe = false

			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
			speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
			connection:Disconnect()
			connection = nil
		else 
			nowe = true
			
			for i = 1, speeds do
				spawn(function()

					local hb = game:GetService("RunService").Heartbeat	

					tpwalking = true
					local chr = game.Players.LocalPlayer.Character
					local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
					while tpwalking and hb:Wait() and chr and hum and hum.Parent do
						if hum.MoveDirection.Magnitude > 0 then
							chr:TranslateBy(hum.MoveDirection)
						end
					end
				end)
			end
			game.Players.LocalPlayer.Character.Animate.Disabled = true
			local Char = game.Players.LocalPlayer.Character
			local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

			for i,v in next, Hum:GetPlayingAnimationTracks() do
				v:AdjustSpeed(0)
			end
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
			speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
			speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
			Loop()
		end

		if game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then

			local plr = game.Players.LocalPlayer
			local torso = plr.Character.Torso
			local flying = true
			local deb = true
			local ctrl = {f = 0, b = 0, l = 0, r = 0}
			local lastctrl = {f = 0, b = 0, l = 0, r = 0}
			local maxspeed = 50
			local speed = 0

			local bg = Instance.new("BodyGyro", torso)
			bg.P = 9e4
			bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
			bg.cframe = torso.CFrame
			local bv = Instance.new("BodyVelocity", torso)
			bv.velocity = Vector3.new(0,0.1,0)
			bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
			if nowe == true then
				plr.Character.Humanoid.PlatformStand = true
			end
			while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
				game:GetService("RunService").RenderStepped:Wait()

				if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
					speed = speed+.5+(speed/maxspeed)
					if speed > maxspeed then
						speed = maxspeed
					end
				elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
					speed = speed-1
					if speed < 0 then
						speed = 0
					end
				end
				if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
					bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
					lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
				elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
					bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				else
					bv.velocity = Vector3.new(0,0,0)
				end
				--	game.Players.LocalPlayer.Character.Animate.Disabled = true
				bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
			end
			ctrl = {f = 0, b = 0, l = 0, r = 0}
			lastctrl = {f = 0, b = 0, l = 0, r = 0}
			speed = 0
			bg:Destroy()
			bv:Destroy()
			plr.Character.Humanoid.PlatformStand = false
			game.Players.LocalPlayer.Character.Animate.Disabled = false
			tpwalking = false
		else
			local plr = game.Players.LocalPlayer
			local UpperTorso = plr.Character.UpperTorso
			local flying = true
			local deb = true
			local ctrl = {f = 0, b = 0, l = 0, r = 0}
			local lastctrl = {f = 0, b = 0, l = 0, r = 0}
			local maxspeed = 50
			local speed = 0


			local bg = Instance.new("BodyGyro", UpperTorso)
			bg.P = 9e4
			bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
			bg.cframe = UpperTorso.CFrame
			local bv = Instance.new("BodyVelocity", UpperTorso)
			bv.velocity = Vector3.new(0,0.1,0)
			bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
			if nowe == true then
				plr.Character.Humanoid.PlatformStand = true
			end
			while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
				wait()

				if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
					speed = speed+.5+(speed/maxspeed)
					if speed > maxspeed then
						speed = maxspeed
					end
				elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
					speed = speed-1
					if speed < 0 then
						speed = 0
					end
				end
				if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
					bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
					lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
				elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
					bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				else
					bv.velocity = Vector3.new(0,0,0)
				end

				bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
			end
			ctrl = {f = 0, b = 0, l = 0, r = 0}
			lastctrl = {f = 0, b = 0, l = 0, r = 0}
			speed = 0
			bg:Destroy()
			bv:Destroy()
			plr.Character.Humanoid.PlatformStand = false
			game.Players.LocalPlayer.Character.Animate.Disabled = false
			tpwalking = false
		end
	end)

	local tis

	up.MouseButton1Down:connect(function()
		tis = up.MouseEnter:connect(function()
			while tis do
				wait()
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
			end
		end)
	end)

	up.MouseLeave:connect(function()
		if tis then
			tis:Disconnect()
			tis = nil
		end
	end)

	local dis

	down.MouseButton1Down:connect(function()
		dis = down.MouseEnter:connect(function()
			while dis do
				wait()
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
			end
		end)
	end)

	down.MouseLeave:connect(function()
		if dis then
			dis:Disconnect()
			dis = nil
		end
	end)


	irukaTrack(game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
		wait(0.7)
		game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
		game.Players.LocalPlayer.Character.Animate.Disabled = false

	end))


	plus.MouseButton1Down:connect(function()
		speeds = speeds + 1
		speed.Text = speeds
		if nowe == true then

			tpwalking = false
			for i = 1, speeds do
				spawn(function()

					local hb = game:GetService("RunService").Heartbeat	

					tpwalking = true
					local chr = game.Players.LocalPlayer.Character
					local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
					while tpwalking and hb:Wait() and chr and hum and hum.Parent do
						if hum.MoveDirection.Magnitude > 0 then
							chr:TranslateBy(hum.MoveDirection)
						end
					end

				end)
			end
		end
	end)
	mine.MouseButton1Down:connect(function()
		if speeds == 1 then
			speed.Text = 'cannot be less than 1'
			wait(1)
			speed.Text = speeds
		else
			speeds = speeds - 1
			speed.Text = speeds
			if nowe == true then
				tpwalking = false
				for i = 1, speeds do
					spawn(function()

						local hb = game:GetService("RunService").Heartbeat	

						tpwalking = true
						local chr = game.Players.LocalPlayer.Character
						local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
						while tpwalking and hb:Wait() and chr and hum and hum.Parent do
							if hum.MoveDirection.Magnitude > 0 then
								chr:TranslateBy(hum.MoveDirection)
							end
						end

					end)
				end
			end
		end
	end)

	irukaTrack(closebutton.MouseButton1Click:Connect(function()
		main:Destroy()
	end))

	irukaTrack(mini.MouseButton1Click:Connect(function()
		up.Visible = false
		down.Visible = false
		onof.Visible = false
		plus.Visible = false
		speed.Visible = false
		mine.Visible = false
		mini.Visible = false
		mini2.Visible = true
		main.Frame.BackgroundTransparency = 1
		closebutton.Position =  UDim2.new(0, 0, -1, 57)
	end))
	
	irukaTrack(mini2.MouseButton1Click:Connect(function()
		up.Visible = true
		down.Visible = true
		onof.Visible = true
		plus.Visible = true
		speed.Visible = true
		mine.Visible = true
		mini.Visible = true
		mini2.Visible = false
		main.Frame.BackgroundTransparency = 0 
		closebutton.Position =  UDim2.new(0, 0, -1, 27)
	end))

	irukaTrack(speed.FocusLost:Connect(function()
		local newSpeed = tonumber(speed.Text)
		if newSpeed and newSpeed > 0 then
			speeds = newSpeed
			if nowe == true then
				tpwalking = false
				for i = 1, speeds do
					spawn(function()

						local hb = game:GetService("RunService").Heartbeat	

						tpwalking = true
						local chr = game.Players.LocalPlayer.Character
						local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
						while tpwalking and hb:Wait() and chr and hum and hum.Parent do
							if hum.MoveDirection.Magnitude > 0 then
								chr:TranslateBy(hum.MoveDirection)
							end
						end

					end)
				end
			end
		elseif newSpeed and newSpeed < 1 then
			speed.Text = 'cannot be less than 1'
			wait(1)
			speed.Text = speeds
		else
			speed.Text = 'Invalid value'
			wait(1)
			speed.Text = speeds
		end
	end))
end

local flyguiButton =irukaAddButton(otherLeftScroll,"Fly Gui")
irukaTrack(flyguiButton.MouseButton1Click:Connect(function()
	flygui()
end))

local FPSBoostButton =irukaAddButton(otherLeftScroll,"FPS Boost")
irukaTrack(FPSBoostButton.MouseButton1Click:Connect(function()
	local decalsyeeted = true
	local g = game
	local w = g.Workspace
	local l = g.Lighting
	local t = w.Terrain    
	sethiddenproperty(l, "Technology", 2)
	sethiddenproperty(t, "Decoration", false)
	t.WaterWaveSize = 0
	t.WaterWaveSpeed = 0
	t.WaterReflectance = 0
	t.WaterTransparency = 0
	l.GlobalShadows = false
	l.FogEnd = 9e9
	l.Brightness = 0
	settings().Rendering.QualityLevel = "Level01"    
	function optimizePart(v)
		if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
			v.Material = "Plastic"
			v.Reflectance = 0
		elseif v:IsA("Decal") or v:IsA("Texture") and decalsyeeted then
			v.Transparency = 1
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Lifetime = NumberRange.new(0)
		elseif v:IsA("Explosion") then
			v.BlastPressure = 1
			v.BlastRadius = 1
		elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
			v.Enabled = false
		elseif v:IsA("MeshPart") then
			v.Material = "Plastic"
			v.Reflectance = 0
			v.TextureID = 10385902758728957
		end
	end    
	for i, v in pairs(w:GetDescendants()) do
		if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") or v:IsA("MeshPart") then
			optimizePart(v)
		end
	end
	for i, e in pairs(l:GetChildren()) do
		if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
			e.Enabled = false
		end
	end
end))

function Desync()
	function Active()
		function respawn()
			local character = player.Character or player.CharacterAdded:Wait()
			local humanoid = character:WaitForChild("Humanoid")
			if humanoid then
				if bloxFruitsMode then
					humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				else
	    			humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	    			character:ClearAllChildren()
	    			local newChar = Instance.new('Model')
	    			newChar.Parent = workspace
	    			player.Character = newChar
	    			task.wait()
	    			player.Character = character
	    			newChar:Destroy()
				end
			end
		end
		
		pcall(function() raknet.desync(true) end)

		respawn()
	end

	Active()
end

local desyncButton = irukaAddButton(otherLeftScroll,"Desync")
irukaTrack(desyncButton.MouseButton1Click:Connect(function()
	Desync()
end))

local hitboxSize =Vector3.new(2,2,1)
local hitboxVisible = false
local hitboxInputValue =Vector3.new(60,60,60)

function setHitbox()
	for _,player in pairs(Players:GetPlayers()) do
		if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart
			hrp.Size = hitboxSize
			hrp.Transparency = hitboxVisible and 0.9 or 1
			hrp.BrickColor = BrickColor.new("Really blue")
			hrp.Material = Enum.Material.Neon
			hrp.CanCollide = false
		end
	end
end

local setHitboxSwitch = irukaAddToggle(otherRightScroll, "Hitbox Enabled", false, function(state)
	if state then
		hitboxSize = hitboxInputValue
	else
		hitboxSize = Vector3.new(2, 2, 1)
	end
	setHitbox()
end)

local hitboxSizeInput = irukaAddInput(otherRightScroll, "Hitbox Size", "60", function(value)
	local num = tonumber(value)
	if num then
		hitboxSize = Vector3.new(num, num, num)
		hitboxInputValue =Vector3.new(num, num, num)
		setHitbox()
	end
end)

local hitboxVisibleSwitch = irukaAddToggle(otherRightScroll, "Hitbox Visible", false, function(state)
	hitboxVisible = state
	setHitbox()
end)

local removeAnimationConnection =nil

local removeAnimationSwitch =irukaAddToggle(otherRightScroll,"Remove Animation",Config.RemoveAnimation,function(state)	
	Config.RemoveAnimation = state
	SaveConfig()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	if Config.RemoveAnimation then
		for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
			track:Stop()
		end
		removeAnimationConnection = irukaTrack(humanoid.AnimationPlayed:Connect(function(track)
			track:Stop()
		end))
	else
		if removeAnimationConnection then
			removeAnimationConnection:Disconnect()
			removeAnimationConnection = nil
		end
	end
end)

irukaTrack(player.CharacterAdded:Connect(function(char)
	if Config.RemoveAnimation then
		if removeAnimationConnection then
			removeAnimationConnection:Disconnect()
			removeAnimationConnection = nil
		end
		local humanoid = char:WaitForChild("Humanoid")
		for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
			track:Stop()
		end
		removeAnimationConnection = irukaTrack(humanoid.AnimationPlayed:Connect(function(track)
			track:Stop()
		end))
	end
end))

local noClipConnection =nil

-- [v13] 效能：NoClip 原本每幀對整個角色呼叫 GetDescendants()（配置/判定/字串比對全在每幀迴圈）
--        改為局部快取零件清單：換角色或每 0.5 秒才重建，每幀只做 CanCollide 寫入。
local noClipChar, noClipParts, noClipRefreshAt = nil, {}, 0
local function noClipRebuild()
	noClipChar = player.Character
	noClipParts = {}
	if noClipChar then
		for _, p in ipairs(noClipChar:GetDescendants()) do
			if p:IsA("BasePart") then noClipParts[#noClipParts + 1] = p end
		end
	end
end
function setUpNoClip()
	noClipRebuild()
	noClipRefreshAt = os.clock() + 0.5
	noClipConnection = irukaTrack(RunService.Stepped:Connect(function()
		local now = os.clock()
		if player.Character ~= noClipChar or now >= noClipRefreshAt then
			noClipRebuild()
			noClipRefreshAt = now + 0.5
		end
		for i = 1, #noClipParts do
			local p = noClipParts[i]
			if p.Parent ~= nil then p.CanCollide = false end
		end
	end))
end

local noClipSwitch =irukaAddToggle(otherRightScroll,"NoClip",Config.NoClip,function(state)
	Config.NoClip = state
	SaveConfig()
	local char = player.Character or player.CharacterAdded:Wait()
	if noClipConnection then
		noClipConnection:Disconnect() end
	if Config.NoClip then
		setUpNoClip()
	else
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = true end
		end
	end
end)

function applySpin(character)
	local hrp = character:WaitForChild("HumanoidRootPart")
	if not hrp:FindFirstChild("irukaSpinning") then
		local Spin = Instance.new("BodyAngularVelocity")
		Spin.Name = "irukaSpinning"
		Spin.Parent = player.Character:WaitForChild("HumanoidRootPart")
		Spin.MaxTorque = Vector3.new(0, math.huge, 0)
		Spin.AngularVelocity = Vector3.new(0,30,0)
	end
end

local spinSwitch = irukaAddToggle(otherRightScroll,"Spin",Config.Spin,function(state)
	Config.Spin = state
	SaveConfig()
	if state and player.Character then
		applySpin(player.Character)
	elseif not state and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		if player.Character.HumanoidRootPart:FindFirstChild("irukaSpinning") then
			player.Character.HumanoidRootPart.irukaSpinning:Destroy()
		end
	end
end)

irukaTrack(player.CharacterAdded:Connect(function(character)
	if Config.Spin then
		applySpin(character)
	end
end))

local speedV2Conn

function setUpSpeedV2()
	speedV2Conn = irukaTrack(game:GetService("RunService").RenderStepped:Connect(function()
		local char = player.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hrp and hum then
				local delta = hum.MoveDirection
				if delta.Magnitude > 0 then
					local alpha = Vector3.new(delta.X, 0, delta.Z).Unit
					hrp.CFrame = hrp.CFrame + alpha * 4.5
				end
			end
		end
	end))
end

local speedHackV2Switch = irukaAddToggle(otherRightScroll,"Speed Hack V2",Config.SpeedHackV2,function(state)
	Config.SpeedHackV2 = state
	SaveConfig()
	if speedV2Conn then
		speedV2Conn:Disconnect()
		speedV2Conn = nil
	end
	if state then
		setUpSpeedV2()
	end
end)

local SpeedConnection
function ApplySpeed()
	local Character = player.Character
	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			if Config.SpeedHack and Config.SpeedValue then
				if SpeedConnection then
					SpeedConnection:Disconnect()
				end
				Humanoid.WalkSpeed = Config.SpeedValue
				SpeedConnection = irukaTrack(Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
					if Config.SpeedHack then
						Humanoid.WalkSpeed = Config.SpeedValue
					end
				end))
			else
				Humanoid.WalkSpeed = 16
				if SpeedConnection then
					SpeedConnection:Disconnect()
				end
			end
		end
	end
end

local speedHackSwitch = irukaAddToggle(otherRightScroll,"Speed Hack",Config.SpeedHack,function(state)
	Config.SpeedHack = state
	SaveConfig()
	ApplySpeed()
end)

local speedHackInput =irukaAddInput(otherRightScroll,"Speed Value",tostring(Config.SpeedValue),function(value)
	local num =tonumber(value)
	if num and num >= 0 then
		Config.SpeedValue =num
		SaveConfig()
		ApplySpeed()
	end
end)

local JumpConnection
function ApplyJumpPower()
	local Character = player.Character
	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			if Config.JumpHack and Config.JumpValue then
				if JumpConnection then
					JumpConnection:Disconnect()
				end
				Humanoid.UseJumpPower = true
				Humanoid.JumpPower = Config.JumpValue
				JumpConnection = irukaTrack(Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
					if Config.JumpHack then
						Humanoid.JumpPower = Config.JumpValue
					end
				end))
			else
				Humanoid.JumpPower = 50
				if JumpConnection then
					JumpConnection:Disconnect()
				end
			end
		end
	end
end

local jumpHackSwitch = irukaAddToggle(otherRightScroll,"Jump Hack",Config.JumpHack,function(state)
	Config.JumpHack = state
	SaveConfig()
	ApplyJumpPower()
end)

local jumpHackInput = irukaAddInput(otherRightScroll,"Jump Value",tostring(Config.JumpValue),function(value)
	local num =tonumber(value)
	if num and num >= 0 then
		Config.JumpValue =num
		SaveConfig()
		ApplyJumpPower()
	end
end)

local infinityJumpSwitch = irukaAddToggle(otherRightScroll,"Infinity Jump",Config.InfJump,function(state)
	Config.InfJump = state
	SaveConfig()
end)

irukaTrack(UserInputService.JumpRequest:Connect(function()
    if not Config.InfJump then return end
	local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if humanoid and hrp then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        
		local JUMP_POWER = 62.5
		if Config.JumpValue and Config.JumpHack then
			JUMP_POWER = Config.JumpValue
		end

        hrp.Velocity = Vector3.new(hrp.Velocity.X, JUMP_POWER, hrp.Velocity.Z)
    end
end))

irukaTrack(player.CharacterAdded:Connect(function()
	task.wait(1)
	ApplySpeed()
	ApplyJumpPower()
end))

cameraFOVinput = irukaAddInput(otherRightScroll,"Camera FOV",tostring(Config.CameraFOV),function(value)
	local num = tonumber(value)
	if num and num >= 0 then
		Config.CameraFOV = num
		SaveConfig()
		workspace.CurrentCamera.FieldOfView = Config.CameraFOV
	end
end)

CameraMaxZoomInput = irukaAddInput(otherRightScroll,"Max Camera Zoom",tostring(Config.CameraMaxZoom),function(value)
	local num = tonumber(value)
	if num and num >= 0 then
		Config.CameraMaxZoom = num
		player.CameraMaxZoomDistance = Config.CameraMaxZoom
		SaveConfig()
	end
end)

local _statsFrameCount = 0
local _statsLastTime = tick()
local _statsFps = 0
local _statsHeartbeatConn = nil
local _statsUpdateConn = nil

local function _statsStart()
	_statsFrameCount = 0
	_statsLastTime = tick()
	_statsHeartbeatConn = irukaTrack(RunService.Heartbeat:Connect(function()
		_statsFrameCount += 1
	end))
	_statsUpdateConn = task.spawn(function()
		while true do
			task.wait(0.5)
			local now = tick()
			local elapsed = now - _statsLastTime
			if elapsed >= 1 then
				_statsFps = math.floor(_statsFrameCount / elapsed)
				_statsFrameCount = 0
				_statsLastTime = now
			end
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local ping = math.floor(player:GetNetworkPing() * 1000)
				local pos = hrp.Position
				statsLabel.Text = string.format("FPS: %d | Ping: %dms | POS: (%.1f, %.1f, %.1f)", _statsFps, ping, pos.X, pos.Y, pos.Z)
			end
		end
	end)
end

local function _statsStop()
	if _statsHeartbeatConn then
		_statsHeartbeatConn:Disconnect()
		_statsHeartbeatConn = nil
	end
	if _statsUpdateConn then
		task.cancel(_statsUpdateConn)
		_statsUpdateConn = nil
	end
end

local statsSwitch = irukaAddToggle(otherRightScroll,"Stats Gui",Config.StatsGui,function(state)
	Config.StatsGui = state
	SaveConfig()
	statsGui.Enabled = state
	_statsStop()
	if state then
		_statsStart()
	end
end)

function setff(flag,value)
	local type = type or typeof
	if type(flag) ~= "string" then return end
	local FFlag = flag:gsub("DFInt", ""):gsub("DFFlag", ""):gsub("FFlag", ""):gsub("FInt", ""):gsub("DFString", ""):gsub("FString", "") or flag
	
	if getfflag(FFlag) ~= nil then
		return setfflag(FFlag, tostring(value))
	end
end

local FFlagsBox = irukaAddInput(otherRightScroll,"FFlags",Config.FFlags,function(value)
	Config.FFlags = value
	SaveConfig()
	if Config.FFlagEnabled and Config.FFlags ~= nil then
    	local s = HttpService:JSONDecode(value:gsub('"True"', "true"):gsub('"False"', "false"))
    	for i,v in s do
        	setff(i,v)
    	end
	end
end)

local FFlagSwitch = irukaAddToggle(otherRightScroll,"Set FFlag",Config.FFlagEnabled,function(state)
	Config.FFlagEnabled = state
	SaveConfig()
	if Config.FFlagEnabled and Config.FFlags ~= nil then
		local s = HttpService:JSONDecode(Config.FFlags:gsub('"True"', "true"):gsub('"False"', "false"))
    	for i,v in s do
        	setff(i,v)
    	end
	end
end)

local PvpCheckGuiButton = irukaAddButton(bloxfruitsLeftScroll,"PvpCheckList")
irukaTrack(PvpCheckGuiButton.MouseButton1Click:Connect(function()
	local existingGui = playerGui:FindFirstChild("PlayerListGUI")
	if existingGui then
		return
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "PlayerListGUI"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 250, 0, 320)
	frame.Position = UDim2.new(0, 20, 0.5, -160)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Draggable = true
	frame.Parent = gui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0.9, 0, 0, 40)
	title.Position = UDim2.new(0.05,0,0,0)
	title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	title.Text = "Player Status"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.TextXAlignment =Enum.TextXAlignment.Left
	title.FontFace = CUSTOM_FONT or Enum.Font.SourceSansBold
	title.Parent = frame

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 25, 0, 25)
	closeButton.Position = UDim2.new(1, -35, 0, 10)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.Text = "×"
	closeButton.TextScaled = true
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.FontFace = CUSTOM_FONT or Enum.Font.SourceSansBold
	closeButton.Parent = frame

	irukaTrack(closeButton.MouseButton1Click:Connect(function()
		gui:Destroy()
	end))

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, -10, 1, -50)
	scrollingFrame.Position = UDim2.new(0, 5, 0, 45)
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.Parent = frame

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Padding = UDim.new(0, 5)
	UIListLayout.Parent = scrollingFrame

	function isInSafeZone(plr)
		if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
			return false
		end
		local root = plr.Character.HumanoidRootPart
		local safeZones = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("SafeZones")
		if not safeZones then return false end

		for _, zone in ipairs(safeZones:GetChildren()) do
			local mesh = zone:FindFirstChild("Mesh")
			if not mesh then continue end
			local distance = (root.Position - zone.Position).Magnitude
			if distance <= (zone.Size.X * mesh.Scale.X) / 2 then 
				return true
			end
		end
		return false
	end

	function updatePvpList()
		for _, child in pairs(scrollingFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		for _, plr in pairs(game.Players:GetPlayers()) do
			local item = Instance.new("TextButton")
			item.Size = UDim2.new(1, -10, 0, 30)
			item.TextScaled = true
			item.FontFace = CUSTOM_FONT or Enum.Font.SourceSansBold
			item.TextColor3 = Color3.fromRGB(255, 255, 255)
			item.Parent = scrollingFrame

			local pvpAttr = plr:GetAttribute("PvpDisabled")
			local safe = isInSafeZone(plr)
			local safeText = safe and "[SAFE]" or "[OUTSIDE]"
			local pvpText = (pvpAttr == nil or pvpAttr == false) and "[ON]" or "[OFF]"

			item.Text = plr.Name .. " " .. safeText .. " " .. pvpText

			if pvpAttr == true then
				item.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
			elseif not safe then
				item.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
			else
				item.BackgroundColor3 = Color3.fromRGB(40, 40, 160)
			end
		end

		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
	end

	local _pvpNext = 0
	irukaTrack(RunService.Heartbeat:Connect(function()
		local _n = os.clock()
		if _n < _pvpNext then return end
		_pvpNext = _n + 0.1
		updatePvpList()
	end))

	updatePvpList()
end))

local changeTeamButton =irukaAddButton(bloxfruitsLeftScroll,"Change Team")
irukaTrack(changeTeamButton.MouseButton1Click:Connect(function()
	if player.Team.Name == "Pirates" then
		game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Marines")
	else
		game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
	end
end))

-- [v9] 地圖優化：移除岩漿 / 霧 / 鬼船（三合一，統一綁定 Remove Lava 開關）
local lavaConnection = {}
local ghostShipConnection = nil

local function CheckAndDestroyLava(v)
	if not v then return end
	local name = v.Name
	if name == "Lava" then
		pcall(function() v:Destroy() end)
	elseif name == "LavaParts" then
		local parent = v.Parent
		if parent then
			local pName = parent.Name
			if (pName == "CircleIsland" or pName == "GhostShipInterior") then
				local grandParent = parent.Parent
				if grandParent and grandParent.Name == "Map" then
					pcall(function() v:Destroy() end)
				end
			end
		end
	end
end

local function StartRemoveLava()
	pcall(function()
		for _, v in pairs(workspace:GetDescendants()) do
			CheckAndDestroyLava(v)
		end
		for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
			CheckAndDestroyLava(v)
		end
	end)
end

local function StopRemoveLava()
	for _, co in pairs(lavaConnection) do
		pcall(function() co:Disconnect() end)
	end
	lavaConnection = {}
end

local function DoRemoveFog()
	pcall(function()
		local lightingService = game:GetService("Lighting")
		if lightingService:FindFirstChild("LightingLayers") then lightingService.LightingLayers:Destroy() end
		if lightingService:FindFirstChild("Sky") then lightingService.Sky:Destroy() end
		lightingService.FogEnd = 9000000000
	end)
end

local function RemoveGhostShipParts()
	local map = workspace:FindFirstChild("Map")
	if not map then return end
	local interior = map:FindFirstChild("GhostShipInterior")
	if not interior then return end
	for _, v in pairs(interior:GetChildren()) do
		if v.Name ~= "Teleport" and v.Name ~= "TeleportSpawn" then
			pcall(function() v:Destroy() end)
		end
	end
end

local function StartRemoveGhostShip()
	RemoveGhostShipParts()
	if not ghostShipConnection then
		local map = workspace:FindFirstChild("Map")
		if map then
			ghostShipConnection = irukaTrack(map.ChildAdded:Connect(function(child)
				if child.Name == "GhostShipInterior" then
					task.wait(0.1)
					RemoveGhostShipParts()
				end
			end))
		end
	end
end

local function StopRemoveGhostShip()
	if ghostShipConnection then
		ghostShipConnection:Disconnect()
		ghostShipConnection = nil
	end
end

function removeLava()
	-- 1) 移除岩漿（全地圖 + 持續監聽）
	StartRemoveLava()
	for _, areaName in ipairs({"CircleIsland", "GhostShipInterior"}) do
		local area = workspace:WaitForChild("Map"):FindFirstChild(areaName)
		if area then
			for _, obj in ipairs(area:GetDescendants()) do
				if obj.Name == "LavaParts" then
					obj:Destroy()
					showNotification("Lava Removed!", "マグマを削除しました", Color3.fromRGB(255, 255, 255))
				end
			end
			lavaConnection[areaName] = irukaTrack(area.ChildAdded:Connect(function(obj)
				if obj.Name == "LavaParts" then
					obj:Destroy()
					showNotification("Lava Removed!", "マグマを自動削除しました", Color3.fromRGB(255, 255, 255))
				end
			end))
		end
	end

	-- 2) 移除霧
	DoRemoveFog()
	showNotification("Fog Removed!", "霧を削除しました", Color3.fromRGB(255, 255, 255))

	-- 3) 移除鬼船
	StartRemoveGhostShip()
	showNotification("Ghost Ship Removed!", "ゴーストシップを削除しました", Color3.fromRGB(255, 255, 255))
end

local removeLavaSwitch = irukaAddToggle(bloxfruitsRightScroll, "Remove Lava", Config.RemoveLava, function(state)
	Config.RemoveLava = state
	SaveConfig()
	if Config.RemoveLava then
		removeLava()
	else
		StopRemoveLava()
		StopRemoveGhostShip()

		showNotification("Lava Removal OFF", "マグマ自動削除を無効化しました", Color3.fromRGB(255, 255, 255))
	end
end)

local tpSwitch = irukaAddToggle(bloxfruitsRightScroll, "TP Gui", Config.TpGui, function(state)
	Config.TpGui = state
	SaveConfig()
	local tpGui = game:GetService("CoreGui"):FindFirstChild("TPGui")
	if tpGui then
		tpGui.Enabled = Config.TpGui
	end
end)

tpYOffsetInput = irukaAddInput(bloxfruitsRightScroll,"TP Y Offset",tostring(Config.TpYOffset),function(value)
	local num = tonumber(value)
	if num then
		Config.TpYOffset = num
		SaveConfig()
	end
end)

function createDraggableButton(name, emoji, position, targetPos,keybind)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(0, 100, 0, 50)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	button.Text = emoji
	button.TextScaled = true
	button.FontFace = CUSTOM_FONT or Enum.Font.SourceSansBold
	button.Parent = tpGui
	button.Active = true
	button.Draggable = true

	irukaTrack(button.MouseButton1Click:Connect(function()
		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		requestEntrance(targetPos)
		_G.iruka_safe = false
		moving =false
		for _, mt in ipairs(irukaMovingToggles) do
			if mt and mt.set then mt.set(false) end
		end
	end))

	irukaTrack(game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == Enum.KeyCode[keybind] then
			local char = player.Character or player.CharacterAdded:Wait()
			local hrp = char:WaitForChild("HumanoidRootPart")
			hrp.CFrame = CFrame.new(targetPos)
			_G.iruka_safe = false
			moving =false
			for _, mt in ipairs(irukaMovingToggles) do
				if mt and mt.set then mt.set(false) end
			end
		end
	end))
end
if bloxFruitsMode and sea == "2nd" then
	createDraggableButton("Dolphin", "🐬", UDim2.new(0, 10, 0, 10), pos1,"H")
	createDraggableButton("Anchor", "⚓", UDim2.new(0, 120, 0, 10), pos2,"G")
elseif bloxFruitsMode and sea =="3rd" then
	createDraggableButton("Mansion", "🏨", UDim2.new(0, 10, 0, 10), pos1,"H")
	createDraggableButton("Tiki", "⚓", UDim2.new(0, 120, 0, 10), pos2,"G")
elseif bloxFruitsMode and sea =="1st" then
	createDraggableButton("Sky", "☁️", UDim2.new(0, 10, 0, 10), pos1,"H")
	createDraggableButton("Water", "⚓", UDim2.new(0, 120, 0, 10), pos2,"G")
end

local autoBusoSwitch = irukaAddToggle(bloxfruitsRightScroll,"Auto Buso",Config.AutoBuso,function(state)
	Config.AutoBuso = state
	SaveConfig()
end)

task.spawn(function()
	while task.wait(1) do
		if Config.AutoBuso then
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
				if not player.Character:FindFirstChild("HasBuso") then
					game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
				end
			end
		end
	end
end)

local walkWaterSwitch =irukaAddToggle(bloxfruitsRightScroll,"Walk Water",Config.WalkWater,function(state)
	Config.WalkWater = state
	SaveConfig()
	pcall(function()
		if Config.WalkWater then
			(game:GetService("Workspace")).Map["WaterBase-Plane"].Size = Vector3.new(1000, 112, 1000)
		else
			(game:GetService("Workspace")).Map["WaterBase-Plane"].Size = Vector3.new(1000, 80, 1000)
		end
	end)
end)

-- [v8] Aimbot 模組：從 BF 頁遷移至 Aim 頁 (節流：目標每 0.1s 刷新，hook 不呼叫 GetChildren)
local _M = {}
_M.ShopUI = {}
_M.AimUI = {}

-- [v9] Skill Aimbot / Gun Aimbot / Team Check Aimbot / Mob Aimbot 開關已移除
-- [v9] 瞄準改由 Aim 分頁 SilentAim（移植自 rjr2026）全權處理

function CheckPlayerAlly(other)
  if tostring(other.Team) == "Marines" and other.Team == player.Team then
    return false
  elseif other:HasTag("Ally" .. player.Name) or player:HasTag("Ally" .. other.Name) then
    return false
  end
  
  return true
end

local aimbotTarget = nil

function getAimbotTarget()
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then 
		aimbotTarget = nil
		return 
	end

	local myPos = char.HumanoidRootPart.Position
	local nearestDist = math.huge
	local nearestTarget = nil

	local MobFolders = {
		workspace.Characters,
    	workspace.Enemies
    }

    for _, Mobs in ipairs(MobFolders) do
		if Mobs.Name == "Enemies" and (not Config.FastAttackMob or nearestTarget) then continue end
        if Mobs then
        	for _, Mob in ipairs(Mobs:GetChildren()) do
				if Mob == char or not Mob:FindFirstChild("HumanoidRootPart") then continue end
        	    local plr = game.Players:GetPlayerFromCharacter(Mob)
				if Config.TeamCheckAimbot and plr then
					if not CheckPlayerAlly(plr) then continue end
				end
				local dist = (Mob.HumanoidRootPart.Position - myPos).Magnitude
					if dist < nearestDist and dist < Config.MaxAimbotRange then
					nearestDist = dist
					nearestTarget = Mob
				end
        	end
        end
    end

	if nearestTarget then return nearestTarget
	else return nil end
end

task.spawn(function()
-- [v8] 節流：自瞄目標每 0.1s 刷新 (非每幀)，避免 workspace:GetChildren() 熱循環
	while task.wait(0.1) do
		aimbotTarget = getAimbotTarget()
	end
end)

-- [v9] Gun/Skill Aimbot 的 __namecall hook 已移除（GunAimbot/SkillAimbot 開關已刪）

local unbreakableConnection = nil
unbreakableSwitch = irukaAddToggle(bloxfruitsRightScroll, "Unbreakable", Config.Unbreakable, function(state)
	Config.Unbreakable = state
	SaveConfig()
	if state then
		unbreakableConnection = irukaTrack(player.CharacterAdded:Connect(function(character)
			character:SetAttribute("UnbreakableAll", true)
		end))
		if player.Character then
			player.Character:SetAttribute("UnbreakableAll", true)
		end
	else 
		if unbreakableConnection then
			unbreakableConnection:Disconnect()
			unbreakableConnection = nil
		end
		if player.Character then
			player.Character:SetAttribute("UnbreakableAll", false)
		end
	end
end)

local noSkillCDConnection = nil
local ececutingNoCD = false

local function isInCombat()
	local gui = player:FindFirstChild("PlayerGui")
	if not gui then return false end
	local main = gui:FindFirstChild("Main")
	if not main then return false end
	local hud = main:FindFirstChild("BottomHUDList")
	if not hud then return false end
	local combat = hud:FindFirstChild("InCombat")
	if not combat then return false end
	return combat.Visible == true --and combat.Text ~= "⚔️In Combat⚔️"
end

local permanentFruits = {}
task.spawn(function()
	while task.wait(10) do
		local result = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("GetFruits", false)
		permanentFruits = {}
		for _,fruit in pairs(result) do
    		if fruit.HasPermanent then
        		table.insert(permanentFruits,fruit.Name)
    		end
		end
	end
end)

pcall(function()
	local Notification = require(game.ReplicatedStorage.Notification)
	ececutingNoCD = false
	task.spawn(function()
		local old
		old = hookfunction(Notification.new,function(text,duration)
    		text = tostring(text)
    		if ececutingNoCD and text:find("Cannot equip") or text:find("Cannot hold") or text:find("Cannot change") or text:find("activated") then
    			return {
    				Display = function() end,
    				Dead = function() return true end
        		}
    		end
    		return old(text,duration)
		end)
	end)
end)

if bloxFruitsMode then
local CommF = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
function executeNoCooldown()
    for _, item in player.Character:GetChildren() do
        if item:IsA("Tool") then
            if item.ToolTip == "Sword" or item.ToolTip == "Gun" or item.ToolTip == "Blox Fruit" then
                task.wait(.01)
				if item.ToolTip == "Blox Fruit" and not table.find(permanentFruits, item.Name) then
					return
				end
				ececutingNoCD = true
                player.PlayerGui:WaitForChild("Backpack").Enabled = false
                player.PlayerGui:WaitForChild("Main"):WaitForChild("Skills").Visible = false
                local result
                repeat
                    task.wait()
                    result =CommF:InvokeServer(table.unpack({
                        [1] = item.ToolTip == "Blox Fruit" and "SwitchFruit" or "LoadItem",
                        [2] = item.Name,
                    }))
                until result == true or isInCombat()

				if isInCombat() then
					player.Character:SetAttribute("AllCooldown", 0)
					task.spawn(function()
						repeat
							task.wait(.1)
						until not isInCombat()
						player.Character:SetAttribute("AllCooldown", 3)
					end)
				end
				ececutingNoCD = false
                player.PlayerGui.Backpack.Enabled = true
                player.Backpack[item.Name].Parent = player.Character
				break
            end
        end
    end
end

pcall(function()
    task.spawn(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall

        if setreadonly then setreadonly(mt, false) else make_writeable(mt) end
        
        mt.__namecall = newcclosure(function(self, ...)
			if checkcaller() then
				return oldNamecall(self, ...)
			end

			local method = getnamecallmethod()
            
			if (method == "InvokeServer" and tostring(self) == "") and Config.NoSkillCD then
				task.spawn(executeNoCooldown)
			end

            return oldNamecall(self, ...)
        end)

         if setreadonly then setreadonly(mt, true) else make_readonly(mt) end
    end)
end)
end


local noStunSwitch = irukaAddToggle(bloxfruitsRightScroll, "No Stun", Config.NoStun, function(state)
	Config.NoStun = state
	SaveConfig()
end)

task.spawn(function()
	while task.wait() do
		if Config.NoStun then
			pcall(function()
				local stun = player.Character and player.Character:FindFirstChild("Stun") or nil
				if stun then
					stun.Value = 0
				end
			end)
		end
	end
end)

function ApplySuperDash(char)
	char:SetAttribute("DashLengthAir", Config.SuperDash and Config.DashDistance or 1)
	char:SetAttribute("DashLengthGround", Config.SuperDash and Config.DashDistance or 1)
end

dashDistanceInput = irukaAddInput(bloxfruitsRightScroll,"Dash Distance",tostring(Config.DashDistance),function(value)
	local num = tonumber(value)
	if num and num >= 0 then
		Config.DashDistance = num
		SaveConfig()
		local char = player.Character or player.CharacterAdded:Wait()
		ApplySuperDash(char)
	end
end)

superDashSwitch = irukaAddToggle(bloxfruitsRightScroll, "Super Dash", Config.SuperDash, function(state)
	Config.SuperDash = state
	local char = player.Character or player.CharacterAdded:Wait()
	ApplySuperDash(char)
	SaveConfig()
end)

irukaTrack(player.CharacterAdded:Connect(function(char) ApplySuperDash(char) end))

local attackRange = 380

-- 【修正】M1Fruit / Guitar 提升到外層：原版宣告在 if bloxFruitsMode 裡面，
-- 下面 do 區塊根本讀不到 (永遠 nil)，提升後果實M1/吉他才能真正運作
local M1Fruit = nil
local Guitar = nil

if bloxFruitsMode then
    local flagFruit = false
    local flagGuitar = false

    task.spawn(function()
        while task.wait(1) do
            -- 【修正】重生瞬間 Character 是 nil，原版直接報錯會讓整條偵測死掉
            local char = player.Character
            if not char then continue end

            flagFruit = false
            flagGuitar = false
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    local isChop = string.find(string.lower(item.Name), "chop") ~= nil
                    if (item:GetAttribute('WeaponType') == 'Demon Fruit' or item.ToolTip == "Blox Fruit") and item:FindFirstChild("LeftClickRemote") and not isChop then
                        M1Fruit = item
                        flagFruit = true
                    elseif item:GetAttribute('WeaponType') == 'Gun' and item.Name == "Skull Guitar" then
                        Guitar = item
                        flagGuitar = true
                    end
                end
            end

            for _, item in ipairs(player.Backpack:GetChildren()) do
                if item:IsA("Tool") then
                    local isChop = string.find(string.lower(item.Name), "chop") ~= nil
                    if (item:GetAttribute('WeaponType') == 'Demon Fruit' or item.ToolTip == "Blox Fruit") and item:FindFirstChild("LeftClickRemote") and not isChop then
                        M1Fruit = item
                        flagFruit = true
                    elseif item:GetAttribute('WeaponType') == 'Gun' and item.Name == "Skull Guitar" then
                        Guitar = item
                        flagGuitar = true
                    end
                end
            end
            if not flagFruit then M1Fruit = nil end
            if not flagGuitar then Guitar = nil end
        end
    end)
end

do
    local Net = game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
    local RegisterHit = Net:WaitForChild("RE/RegisterHit")
    local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
    -- 【修正-龍炮】射擊遠端改成動態抓取：WaitForChild 逾時只會拿到一次 nil 就永遠不再重試，
    -- 遊戲更新把遠端改名/慢生成時龍炮會整個靜默失效(開關開著卻完全不出彈)。
    -- 先即時找(名稱完全相符或包含 ShootGun)，看門狗每 3 秒也會重抓。
    local function findShootRemote()
        local Modules = game.ReplicatedStorage:FindFirstChild("Modules")
        local NetFolder = Modules and Modules:FindFirstChild("Net")
        if NetFolder then
            local exact = NetFolder:FindFirstChild("RE/ShootGunEvent")
            if exact and exact:IsA("RemoteEvent") then return exact end
            for _, child in ipairs(NetFolder:GetChildren()) do
                if child:IsA("RemoteEvent") and child.Name:find("ShootGun", 1, true) then
                    return child
                end
            end
        end
        return nil
    end
    local ShootGunEvent = Net:FindFirstChild("RE/ShootGunEvent") or findShootRemote() or Net:WaitForChild("RE/ShootGunEvent", 5)
    local ShootFunction
    if _G.Executor and (not _G.Executor:lower():find("xeno") and not _G.Executor:lower():find("solara")) then
        pcall(function()
            ShootFunction = getupvalue(require(game:GetService("ReplicatedStorage").Controllers.CombatController).Attack, 9)
        end)
    end
    local GunValidator = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Validator2")
    local Folders = {
        game.ReplicatedStorage.Util,
        game.ReplicatedStorage.Common,
        game.ReplicatedStorage.Remotes,
        game.ReplicatedStorage.Assets,
        game.ReplicatedStorage.FX,
    }
    local remoteId = nil
    local remoteEvent = nil

    for _, Remotes in ipairs(Folders) do
        for _, remote in ipairs(Remotes:GetChildren()) do
            if remote:IsA('RemoteEvent') and remote:GetAttribute('Id') then
                remoteId = remote:GetAttribute('Id')
               	remoteEvent = remote
            end
        end

        irukaTrack(Remotes.ChildAdded:Connect(function(add)
            if add:IsA('RemoteEvent') and add:GetAttribute('Id') then
                remoteId = add:GetAttribute('Id')
                remoteEvent = add
            end
        end))
    end

    -- ══════════ 融合六路流轉狀態 ══════════
    local CombatFlags = nil
    local HitFunction = nil
    local CurrentLogic = 1
    local M1Combo = 0
    local ComboDebounce = 0
    local lastScanTime = 0
    local cachedBladeHits = nil
    local cachedHead = nil
    local failCount = 0

    -- 【修正-斷攻】遠端健康檢查：遊戲伺服器會定期銷毀重建 Net 底下的遠端，
    -- 舊引用 FireServer 不會報錯但完全沒效果 →「進場能打，約一分鐘後發不出包」。
    -- 被銷毀的實例 .Parent 會變 nil，用這個判斷並即時重抓 (不能用 pcall 失敗偵測)
    local function refreshCombatRemotes()
        local Modules = game.ReplicatedStorage:FindFirstChild("Modules")
        local NetModule = Modules and Modules:FindFirstChild("Net")
        if NetModule then
            if not RegisterHit or RegisterHit.Parent == nil then
                RegisterHit = NetModule:FindFirstChild("RE/RegisterHit")
                -- 備用查找機制
                if not RegisterHit then
                    for _, child in ipairs(NetModule:GetChildren()) do
                        if child:IsA("RemoteEvent") and child.Name:find("RegisterHit", 1, true) then
                            RegisterHit = child
                            break
                        end
                    end
                end
            end
            if not RegisterAttack or RegisterAttack.Parent == nil then
                RegisterAttack = NetModule:FindFirstChild("RE/RegisterAttack")
                -- 備用查找機制
                if not RegisterAttack then
                    for _, child in ipairs(NetModule:GetChildren()) do
                        if child:IsA("RemoteEvent") and child.Name:find("RegisterAttack", 1, true) then
                            RegisterAttack = child
                            break
                        end
                    end
                end
            end
            if not ShootGunEvent or ShootGunEvent.Parent == nil then
                ShootGunEvent = findShootRemote()
            end
        end
        if not GunValidator or GunValidator.Parent == nil then
            local Remotes = game.ReplicatedStorage:FindFirstChild("Remotes")
            local gv = Remotes and Remotes:FindFirstChild("Validator2")
            if gv then GunValidator = gv end
        end
    end

    -- 【新增】檢查遠端是否真的可用
    local function isRemoteValid(remote)
        return remote and remote.Parent and remote:IsDescendantOf(game)
    end

    -- 看門狗：官方函數 / 射擊函數 / 遠端實例掉了自動重抓
    task.spawn(function()
        while task.wait(3) do
            pcall(refreshCombatRemotes)
            if not HitFunction or not ShootFunction then
                pcall(function()
                    local Modules = game.ReplicatedStorage:FindFirstChild("Modules")
                    if Modules then
                        CombatFlags = require(Modules.Flags).COMBAT_REMOTE_THREAD
                        local LocalScript = player:FindFirstChild("PlayerScripts") and player.PlayerScripts:FindFirstChildOfClass("LocalScript")
                        if LocalScript and getsenv then
                            HitFunction = getsenv(LocalScript)._G.SendHitsToServer
                        end
                        if _G.Executor and (not _G.Executor:lower():find("xeno") and not _G.Executor:lower():find("solara")) then
                            ShootFunction = getupvalue(require(game.ReplicatedStorage.Controllers.CombatController).Attack, 9)
                        end
                    end
                end)
            end
        end
    end)

    -- 【新增-龍炮】Validator 索引自動檢測 (遊戲更新位移 upvalue 時自動適應)
	local V_Idx = { v26 = 12, v22 = 13, v25 = 14, v21 = 15, v23 = 16, v24 = 17, v27 = 18 }
	local getupval = debug.getupvalue or getupvalue
	local setupval = debug.setupvalue or setupvalue
	local getupvals = debug.getupvalues or getupvalues

	local function initDragonGun()
		local ok, combatController = pcall(require, game.ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("CombatController"))
		if ok and type(combatController) == "table" and type(combatController.Attack) == "function" and getupval then
			local okFunction, shootFunction = pcall(getupval, combatController.Attack, 9)
			if okFunction then ShootFunction = shootFunction end
		end
	end

    function GetValidator2()
		if not ShootFunction then initDragonGun() end
		if not ShootFunction or not getupval or not setupval then return 0, 0 end

        if getupvals then
            local ok, upvals = pcall(getupvals, ShootFunction)
			if not ok or type(upvals) ~= "table" then
				ShootFunction = nil
				return 0, 0
			end
			if upvals[V_Idx.v21] ~= 727595 then
				local found = false
                for i, v in pairs(upvals) do
                    if v == 727595 then
                        local offset = i - 15
                        V_Idx.v21 = i
                        V_Idx.v22 = 13 + offset
                        V_Idx.v23 = 16 + offset
                        V_Idx.v24 = 17 + offset
                        V_Idx.v25 = 14 + offset
                        V_Idx.v26 = 12 + offset
                        V_Idx.v27 = 18 + offset
						found = true
                        break
                    end
                end
				if not found then
					ShootFunction = nil
					return 0, 0
				end
            end
        end

		local okValues, v1, v2, v3, v4, v5, v6, v7 = pcall(function()
			return getupval(ShootFunction, V_Idx.v21), getupval(ShootFunction, V_Idx.v22),
				getupval(ShootFunction, V_Idx.v23), getupval(ShootFunction, V_Idx.v24),
				getupval(ShootFunction, V_Idx.v25), getupval(ShootFunction, V_Idx.v26),
				getupval(ShootFunction, V_Idx.v27)
		end)

		if not okValues or type(v1) ~= "number" or type(v2) ~= "number" or type(v3) ~= "number"
			or type(v4) ~= "number" or type(v5) ~= "number" or type(v6) ~= "number" or type(v7) ~= "number"
			or v3 == 0 or v4 == 0 then
			ShootFunction = nil
			return 0, 0
		end

        local v8 = v6 * v2
        local v9 = (v5 * v2 + v6 * v1) % v3
        v9 = (v9 * v3 + v8) % v4
        v5 = math.floor(v9 / v3)
        v6 = v9 - v5 * v3
        v7 = v7 + 1

		local okSetup = pcall(function()
			setupval(ShootFunction, V_Idx.v25, v5)
			setupval(ShootFunction, V_Idx.v26, v6)
			setupval(ShootFunction, V_Idx.v27, v7)
		end)
		if not okSetup then
			ShootFunction = nil
			return 0, 0
		end

        return math.floor(v9 / v4 * 16777215), v7
    end

    -- 【新增-龍炮】射擊目標：優先自瞄鎖定目標 → 再找最近的怪/玩家
    local function GetDragonGunTarget()
        local char = player.Character
        local root = char and char:FindFirstChild('HumanoidRootPart')
        if not root then return nil end

        if aimbotTarget and (Config.FastAttackMob or Config.FastAttackPlayer) then
            local aRoot = aimbotTarget:FindFirstChild("HumanoidRootPart")
            local aHum = aimbotTarget:FindFirstChildOfClass("Humanoid")
            if aRoot and aHum and aHum.Health > 0 then
                return aRoot
            end
        end

        -- 打怪/打玩家都關時，開了 GuitarAura 就兩邊都掃 (不然龍炮沒目標)
        local includeMobs = Config.FastAttackMob
        local includePlayers = Config.FastAttackPlayer

        local closest, minDist = nil, math.huge
        local myPos = root.Position

        if includeMobs then
            local folder = workspace:FindFirstChild("Enemies")
            if folder then
                for _, mob in ipairs(folder:GetChildren()) do
                    local mRoot = mob:FindFirstChild("HumanoidRootPart")
                    local mHum = mob:FindFirstChildOfClass("Humanoid")
                    if mRoot and mHum and mHum.Health > 0 then
                        local d = (mRoot.Position - myPos).Magnitude
                        if d < minDist then minDist = d; closest = mRoot end
                    end
                end
            end
        end

        if includePlayers then
            local folder = workspace:FindFirstChild("Characters")
            if folder then
                for _, mob in ipairs(folder:GetChildren()) do
                    if mob ~= char then
                        local mRoot = mob:FindFirstChild("HumanoidRootPart")
                        local mHum = mob:FindFirstChildOfClass("Humanoid")
                        if mRoot and mHum and mHum.Health > 0 then
                            local d = (mRoot.Position - myPos).Magnitude
                            if d < minDist then minDist = d; closest = mRoot end
                        end
                    end
                end
            end
        end

        return closest
    end

    task.spawn(function()
        while true do
            task.wait(math.max(0.01, Config.FastAttackDelay))  -- 最小0.01秒防止性能問題

if not (Config.FastAttackPlayer or Config.FastAttackMob or Config.GuitarAura) then
                continue
            end

            local Character = player.Character
            local hrp = Character and Character:FindFirstChild('HumanoidRootPart')
            if not Character or not hrp then continue end

            local Humanoid = Character:FindFirstChild('Humanoid')
            if not Humanoid or Humanoid.Health <= 0 then continue end
            -- 【替換-六路】6路.txt 實測版「不做」Stun/Busy 檢查：攻擊動作會讓 Busy 短暫為真，
            -- 檢查它會卡掉大量攻擊輪 = 打不出傷害。只保留遠端健康檢查(斷了馬上重抓)。
            pcall(refreshCombatRemotes)

            if Config.SuperRange and hrp:FindFirstChild("Buddha") then
             	attackRange = Config.BuddhaRange
            else
                attackRange = Config.NormalRange
            end

            -- 目標緩存掃描【優化版】
            local now = tick()
            local scanInterval = math.max(0.02, Config.FastAttackDelay * 0.5)
            if not cachedBladeHits or (now - lastScanTime) >= scanInterval then
                local BladeHits = {}
local includeMobs = Config.FastAttackMob
local includePlayers = Config.FastAttackPlayer
                local hrpPos = hrp.Position
                local distSqr = attackRange * attackRange  -- 平方距離用於快速比較

                if includeMobs then
                    local Mobs = workspace:FindFirstChild("Enemies")
                    if Mobs then
                        for _, Mob in ipairs(Mobs:GetChildren()) do
                            local MobRoot = Mob:FindFirstChild('HumanoidRootPart')
                            local MobHumanoid = Mob:FindFirstChild('Humanoid')
                            if MobRoot and MobHumanoid and MobHumanoid.Health > -5 then
                                -- 使用平方距離避免開平方運算
                                local diff = MobRoot.Position - hrpPos
                                if (diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z) <= distSqr then
                                    -- 只收集主要parts，不是所有parts
                                    BladeHits[#BladeHits + 1] = {Mob, MobRoot}
                                end
                            end
                        end
                    end
                end

                if includePlayers then
                    local Chars = workspace:FindFirstChild("Characters")
                    if Chars then
                        for _, Mob in ipairs(Chars:GetChildren()) do
                            local MobRoot = Mob:FindFirstChild('HumanoidRootPart')
                            local MobHumanoid = Mob:FindFirstChild('Humanoid')
                            if Mob ~= Character and MobRoot and MobHumanoid and MobHumanoid.Health > 0 then
                                -- 使用平方距離避免開平方運算
                                local diff = MobRoot.Position - hrpPos
                                if (diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z) <= distSqr then
                                    BladeHits[#BladeHits + 1] = {Mob, MobRoot}
                                end
                            end
                        end
                    end
                end

                lastScanTime = now
                cachedBladeHits = BladeHits
                cachedHead = nil
                if #BladeHits > 0 then
                    cachedHead = BladeHits[1][1]:FindFirstChild('Head') or BladeHits[1][1]:FindFirstChild('HumanoidRootPart')
                end
            end

            local BladeHits = cachedBladeHits or {}
            local _Head = cachedHead

            local Combo = (tick() - ComboDebounce) <= 0.35 and M1Combo or 0
            Combo = Combo >= 3 and 1 or Combo + 1
            ComboDebounce = tick()
            M1Combo = Combo

            local Tool = Character:FindFirstChildOfClass('Tool')
            local weaponType = Tool and Tool:GetAttribute('WeaponType')

            if #BladeHits > 0 and _Head and (Config.FastAttackPlayer or Config.FastAttackMob)
                and weaponType and (weaponType == 'Melee' or weaponType == 'Sword'
                or (weaponType == 'Demon Fruit' and (Tool.Name == "Light-Light" or Tool.Name == "Ice-Ice"))) then

                -- 【修正】檢查遠端是否有效
                if isRemoteValid(RegisterAttack) and isRemoteValid(RegisterHit) then
                    local fired = pcall(function()
                -- 【修正】檢查遠端是否有效
                    if CurrentLogic == 1 then
                        RegisterAttack:FireServer()
                        RegisterAttack:FireServer(Config.FastAttackDelay or 0)
                        RegisterHit:FireServer(_Head, BladeHits, {})
                    elseif CurrentLogic == 2 then
                        RegisterAttack:FireServer(0)
                        RegisterHit:FireServer(_Head, BladeHits, {})
                    elseif CurrentLogic == 3 then
                        RegisterAttack:FireServer()
                        if CombatFlags and HitFunction then
                            HitFunction(_Head, BladeHits)
                        else
                            RegisterHit:FireServer(_Head, BladeHits)
                        end
                    elseif CurrentLogic == 4 then
                        RegisterAttack:FireServer()
                        RegisterHit:FireServer(_Head, BladeHits, {})
                        task.delay(0.001, function()
                            pcall(function()
                                if Config.FastAttackPlayer or Config.FastAttackMob then
                                    RegisterHit:FireServer(_Head, BladeHits, {})
                                end
                            end)
                        end)
                    elseif CurrentLogic == 5 then
                        RegisterAttack:FireServer(-math.huge)
                        RegisterHit:FireServer(_Head, BladeHits)
                    else
                        RegisterAttack:FireServer(0)
                        RegisterHit:FireServer(_Head, BladeHits, {})
                    end

                    -- Bypass 加密路【保留原樣】
                    if Config.BypassFastAttack and remoteId and remoteEvent then
                        require(game.ReplicatedStorage.Modules.Net):RemoteEvent('RegisterHit', true)
                        cloneref(remoteEvent):FireServer(string.gsub('RE/RegisterHit', '.', function(p31)
                            return string.char(bit32.bxor(string.byte(p31), math.floor(workspace:GetServerTimeNow() / 10 % 10) + 1))
                        end), bit32.bxor(remoteId + 909090, game.ReplicatedStorage.Modules.Net.seed:InvokeServer() * 2), _Head, BladeHits)
                    end
                    end)

                        if fired then
                            failCount = 0
                        else
                            failCount = failCount + 1
                            if failCount >= 5 then
                                failCount = 0
                                pcall(refreshCombatRemotes)
                            end
                        end
                    end -- isRemoteValid check

                if Combo >= 3 then
                    task.wait(0.05)
                end

            elseif #BladeHits > 0 and weaponType == 'Demon Fruit' and Tool:FindFirstChild("LeftClickRemote")
and (Config.FastAttackPlayer or Config.FastAttackMob) then
                local attackCount = 1
                for i, data in ipairs(BladeHits) do
                    if i > 4 then break end
                    local targetModel = data[1]
                    local rootPart = targetModel:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local direction = (rootPart.Position - Character:GetPivot().Position).Unit
                        Tool.LeftClickRemote:FireServer(direction, attackCount)
                        attackCount = attackCount + 1
                    end
                end

                if Combo >= 3 then
                    task.wait(0.05)
                end
            end

            CurrentLogic = (CurrentLogic % 6) + 1

            task.spawn(function()
                if aimbotTarget and Guitar and Config.GuitarAura and (Config.FastAttackMob or Config.FastAttackPlayer) then
                    if aimbotTarget and aimbotTarget:FindFirstChild("HumanoidRootPart") then
                        pcall(function()
                            Guitar:SetAttribute("LocalTotalShots", (Guitar:GetAttribute("LocalTotalShots") or 0) + 1)
                            local valCode, valCount = GetValidator2()
                            if valCode ~= 0 then
                                GunValidator:FireServer(valCode, valCount)
                            end
                            Guitar.RemoteEvent:FireServer("TAP", aimbotTarget.HumanoidRootPart.Position)
                        end)
                    end
                end
            end)
        end
    end)

-- ══════════ 【修正-龍炮】★ 龍炮 M1 (攻速0，開關同樣綁定 Guitar Aura，使用新邏輯) ══════════
    -- 攻速調整為0：使用 task.wait(0) 讓出控制權但盡快繼續執行
    -- 邏輯來源：貼上的 dragon M1 邏輯，使用 GetNextValidator 進行 validator 索引自動檢測
    -- 只在 Config.GuitarAura 開啟 且 手上有槍 時運作，目標由 GetDragonGunTarget 決定
    task.spawn(function()
        while true do
            -- 攻速調整為0
            task.wait(0)

            if not Config.GuitarAura or not (Config.FastAttackMob or Config.FastAttackPlayer) then continue end

            pcall(refreshCombatRemotes)

            local shootRemote = ShootGunEvent
            if not shootRemote or shootRemote.Parent == nil then continue end

            local Character = player.Character
            local Humanoid = Character and Character:FindFirstChild('Humanoid')
            if not Character or not Humanoid or Humanoid.Health <= 0 then continue end

            -- 手上要實際拿著槍 (Skull Guitar 留給上面的 Guitar Aura 吉他邏輯)
            local gunTool = nil
            for _, t in ipairs(Character:GetChildren()) do
                if t:IsA('Tool') and t.Name ~= "Skull Guitar"
                    and (t:GetAttribute('WeaponType') == 'Gun' or t.ToolTip == "Gun") then
                    gunTool = t
                    break
                end
            end
            if not gunTool then continue end

            local targetPart = GetDragonGunTarget()
            if not targetPart then continue end

			local fired = pcall(function()
				-- 使用 script 現有的 GetValidator2 進行 validator 索引自動檢測
				local valCode, valCount = GetValidator2()
				if valCode ~= 0 and isRemoteValid(GunValidator) then
					GunValidator:FireServer(valCode, valCount)
				end

				-- 重置過熱 → 龍炮無限連發不過熱
				gunTool:SetAttribute("LocalOverheat", 0)
				gunTool:SetAttribute("LocalTotalShots", (gunTool:GetAttribute("LocalTotalShots") or 0) + 1)
				shootRemote:FireServer(targetPart.Position, { targetPart })
			end)
			if not fired then
				ShootFunction = nil
				refreshCombatRemotes()
			end
        end
    end)
end
local fastAttackMobSwitch =irukaAddToggle(bloxfruitsRightScroll,"Fast Attack Mob", Config.FastAttackMob,function(state)
	Config.FastAttackMob = state
	SaveConfig()
end)

local fastAttackPlayerSwitch =irukaAddToggle(bloxfruitsRightScroll,"Fast Attack Player", Config.FastAttackPlayer,function(state)
	Config.FastAttackPlayer = state
	SaveConfig()
end)

-- [Fruit M1] 果實 M1 光環：完整替換為 gemini-code-1785928360958 (2).lua 的版本
-- 綁定 FruitM1Aura 開關：開啟 -> 自動啟動；關閉 -> 立即終止並結束執行迴圈
-- 控制表掛在 _G（本函數 local 已接近 200 上限，且重複執行/卸載時可直接停掉舊迴圈）
if _G.IrukaFruitM1Ctl and _G.IrukaFruitM1Ctl.stop then
	pcall(_G.IrukaFruitM1Ctl.stop)
end
_G.IrukaFruitM1Ctl = { token = 0, thread = nil }

function _G.IrukaFruitM1Ctl.start()
	_G.IrukaFruitM1Ctl.stop()
	_G.IrukaFruitM1Ctl.token += 1
	local token = _G.IrukaFruitM1Ctl.token

	local DownVec = Vector3.new(0, -1, 0)
	local function isShadow(name)
		local lower = string.lower(name)
		return string.find(lower, "shadow") ~= nil
			or string.find(name, "'s Shadow") ~= nil
			or string.find(name, "\u{2019}s Shadow") ~= nil
	end

	local thread
	thread = task.spawn(function()
		while _G.IrukaFruitM1Ctl.token == token do
			task.wait(math.max(0.1, tonumber(Config.FruitM1AttackSpeed) or 0.1)) -- 果實M1頻率（最低限制 0.1）

			if _G.IrukaFruitM1Ctl.token ~= token then break end -- 開關關閉 -> 立即結束執行迴圈

			if not Config.FruitM1Aura then continue end
			if not Config.FastAttackPlayer and not Config.FastAttackMob then continue end

			local Character = player.Character
			local hrp = Character and Character:FindFirstChild('HumanoidRootPart')
			if not Character or not hrp then continue end

			local hum = Character:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then continue end

			if not M1Fruit or type(M1Fruit) ~= "userdata" or not M1Fruit.Parent or not M1Fruit:FindFirstChild("LeftClickRemote") then
				continue
			end

			local closestMob = nil
			local minDistance = Config.AttackRange or Config.NormalRange or 380

			local MobFolders = { workspace.Enemies, workspace.Characters }
			for _, Mobs in ipairs(MobFolders) do
				if not Mobs then continue end
				if Mobs.Name == "Enemies" and not Config.FastAttackMob then continue end
				if Mobs.Name == "Characters" and not Config.FastAttackPlayer then continue end

				for _, Mob in ipairs(Mobs:GetChildren()) do
					if Mob == Character or not Mob:IsA("Model") or isShadow(Mob.Name) or Mob.Name == "Blank Buddy" then continue end
					local mobHrp = Mob:FindFirstChild('HumanoidRootPart')
					local mobHum = Mob:FindFirstChild('Humanoid')
					if mobHrp and mobHum and mobHum.Health > (Config.HealthMobThreshold or 0) then
						local dist = (mobHrp.Position - hrp.Position).Magnitude
						if dist < minDistance then
							minDistance = dist
							closestMob = Mob
						end
					end
				end
			end

			if closestMob then
				pcall(function()
					M1Fruit.LeftClickRemote:FireServer(DownVec, 1, true)
				end)
			end
		end
		if _G.IrukaFruitM1Ctl.thread == thread then
			_G.IrukaFruitM1Ctl.thread = nil
		end
	end)
	_G.IrukaFruitM1Ctl.thread = thread
end

function _G.IrukaFruitM1Ctl.stop()
	_G.IrukaFruitM1Ctl.token += 1
	local th = _G.IrukaFruitM1Ctl.thread
	_G.IrukaFruitM1Ctl.thread = nil
	if th then
		pcall(task.cancel, th)
	end
end

local fruitM1AuraSwitch =irukaAddToggle(bloxfruitsRightScroll,"Fruit M1 Aura", Config.FruitM1Aura,function(state)
	Config.FruitM1Aura = state
	SaveConfig()
	if state then
		_G.IrukaFruitM1Ctl.start()
	else
		_G.IrukaFruitM1Ctl.stop()
	end
end)

if Config.FruitM1Aura then
	_G.IrukaFruitM1Ctl.start()
end

-- [Fruit M1] 攻速輸入（最低限制 0.1；輸入低於 0.1 一律默認為 0.1）
_G.IrukaFruitM1Ctl.speedInput = irukaAddInput(bloxfruitsRightScroll, "Fruit M1 Attack Speed", tostring(Config.FruitM1AttackSpeed), function(value)
	local num = tonumber(value)
	if not num or num < 0.1 then
		num = 0.1
		if _G.IrukaFruitM1Ctl.speedInput and _G.IrukaFruitM1Ctl.speedInput.box then
			_G.IrukaFruitM1Ctl.speedInput.box.Text = "0.1"
		end
	end
	Config.FruitM1AttackSpeed = num
	SaveConfig()
end)

local guitarAuraSwitch =irukaAddToggle(bloxfruitsRightScroll,"Guitar/Dragonstorm aura", Config.GuitarAura,function(state)
	Config.GuitarAura = state
	SaveConfig()
end)

local BypassfastAttackPSwitch =irukaAddToggle(bloxfruitsRightScroll,"Fast Attack Bypass", Config.BypassFastAttack,function(state)
	Config.BypassFastAttack = state
	SaveConfig()
end)

local superRangeSwitch = irukaAddToggle(bloxfruitsRightScroll, "Super Range(Buddha Only)", Config.SuperRange, function(state)
	Config.SuperRange= state
	SaveConfig()
end)

normalAttackRangeInput = irukaAddInput(bloxfruitsRightScroll,"Normal Attack Range",tostring(Config.NormalRange),function(value)
	local num = tonumber(value)
	if num and num >= 0 then
		Config.NormalRange = num
		SaveConfig()
	end
end)

buddhaAttackRangeInput = irukaAddInput(bloxfruitsRightScroll,"Buddha Attack Range",tostring(Config.BuddhaRange),function(value)
	local num = tonumber(value)
	if num and num >= 0 then
		Config.BuddhaRange = num
		SaveConfig()
	end
end)

fastAttackDelayInput = irukaAddInput(bloxfruitsRightScroll,"Fast Attack Delay",tostring(Config.FastAttackDelay),function(value)
	local num = tonumber(value)
	if num and num >= 0 then
		Config.FastAttackDelay = num
		SaveConfig()
	end
end)

task.spawn(function()
	while true do
		task.wait(0.5)        
		pcall(function()
			if Config.AutoV3 then
				game:GetService("ReplicatedStorage").Remotes.CommE:FireServer("ActivateAbility")
			end
		end)
	end
end)

-- [v8] Auto Kill 整組 (4 開關 + setKillConn + setAddConn) 已依需求移除

local CheckOneShotConn = nil
function CheckOneShot(char)
	if CheckOneShotConn then
		CheckOneShotConn:Disconnect()
		CheckOneShotConn = nil
	end
	local hrp = char:WaitForChild("HumanoidRootPart")
	CheckOneShotConn = irukaTrack(hrp:GetPropertyChangedSignal("Position"):Connect(function()
		if hrp.Position.Y < -100000 and Config.AntiOneShotV1 and not autoKillConn then
			hrp.CFrame = CFrame.new(hrp.Position.X, 100, hrp.Position.Z)
			hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		end
	end))
end

function EnabledAntiVoid(bool)
	game.Workspace.FallenPartsDestroyHeight = bool and 0/0 or -15000
end

irukaTrack(player.CharacterAdded:Connect(function(char) CheckOneShot(char) end))

local antiOneShotV1Switch = irukaAddToggle(bloxfruitsRightScroll,"Anti One Shot V1",Config.AntiOneShotV1,function(state)
	Config.AntiOneShotV1 = state
	CheckOneShot(player.Character or player.CharacterAdded:Wait())
	SaveConfig()
end)

local antiOneShotV2Switch = irukaAddToggle(bloxfruitsRightScroll,"Anti One Shot V2",Config.AntiOneShotV2,function(state)
	Config.AntiOneShotV2 = state
	EnabledAntiVoid(state)
	SaveConfig()
end)

local autoV3Switch = irukaAddToggle(bloxfruitsRightScroll,"Auto V3",Config.AutoV3,function(state)
	Config.AutoV3 = state
	SaveConfig()
end)

task.spawn(function()
	while true do
		task.wait(0.5)
		if Config.AutoV4 then
			local character = game.Players.LocalPlayer.Character
			if character and character:FindFirstChild("RaceEnergy") and character.RaceEnergy.Value >= 1 and not character.RaceTransformed.Value then
				if player.Backpack:FindFirstChild("Awakening") then
					if player.Backpack.Awakening:FindFirstChild("RemoteFunction") then
						player.Backpack.Awakening.RemoteFunction:InvokeServer(true)
					end
				elseif character:FindFirstChild("Awakening") then
					if character.Awakening:FindFirstChild("RemoteFunction") then
						character.Awakening.RemoteFunction:InvokeServer(true)
					end
				end
			end
		end
	end
end)

local autoV4Switch = irukaAddToggle(bloxfruitsRightScroll,"Auto V4",Config.AutoV4,function(state)
	Config.AutoV4 = state
	SaveConfig()
end)

-- [v8] Bring Mob (聚怪)：從 rjr2026 提取，雙向綁定 Config.BringMob
-- [v9] Bring Mob（聚怪）：完整移植 rjr2026 的實現（含快取、SimulationRadius、BodyVelocity、距離判定）
-- [v9.1] Bring Mob（聚怪）性能優化版：20Hz 節流 + 平方距離 + 弱鍵快取 + 條件寫入（解決卡頓 / 掉 FPS）
local bringMobsConnection = nil
local bringMobsCache = setmetatable({}, {__mode = "k"})
local _RunService = game:GetService("RunService")
local _Workspace = game:GetService("Workspace")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function GetBringMobsParts(enemy)
	local c = bringMobsCache[enemy]
	if c and c.hum and c.hum.Parent and c.root and c.root.Parent then
		return c.hum, c.root
	end
	local hum = enemy:FindFirstChildOfClass("Humanoid")
	local root = enemy:FindFirstChild("HumanoidRootPart")
	if not hum or not root then
		bringMobsCache[enemy] = nil
		return nil, nil
	end
	bringMobsCache[enemy] = { hum = hum, root = root }
	return hum, root
end

local lastExecution = 0
local UPDATE_INTERVAL = 0.05 -- 限制更新頻率為 20Hz (0.05秒)，大幅減輕 CPU 與繪圖負擔

local function StartBringMobs()
	if bringMobsConnection then return end

	bringMobsConnection = irukaTrack(_RunService.Heartbeat:Connect(function()
		if not _G.G_BringMobs then return end

		local now = os.clock()
		if now - lastExecution < UPDATE_INTERVAL then return end
		lastExecution = now

		pcall(function()
			local char = LocalPlayer.Character
			if not char then return end

			local hrp = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChild("Humanoid")
			if not hrp or not hum or hum.Health <= 0 then return end

			if sethiddenproperty then
				sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
			end

			local targetPos = hrp.Position
			local targetCF = CFrame.new(targetPos.X, targetPos.Y - 18, targetPos.Z)
			local enemies = _Workspace:FindFirstChild("Enemies")
			if not enemies then return end

			local enemyList = enemies:GetChildren()
			for i = 1, #enemyList do
				local enemy = enemyList[i]
				if enemy:IsA("Model") then
					local enemyHum, enemyRoot = GetBringMobsParts(enemy)
					if enemyHum and enemyRoot and enemyHum.Health > 0 then
						-- 使用平方距離比對，省去開根號 (Magnitude) 的運算負擔
						local offset = enemyRoot.Position - targetPos
						local distSq = offset.X*offset.X + offset.Y*offset.Y + offset.Z*offset.Z

						if distSq <= 9000000 then -- 3000^2
							if not enemyRoot:FindFirstChild("BodyVelocity") then
								local bv = Instance.new("BodyVelocity")
								bv.Name = "BodyVelocity"
								bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
								bv.Velocity = Vector3.zero
								bv.Parent = enemyRoot
							end

							if distSq > 324 then -- 18^2
								local isOwner = true
								if isnetworkowner then
									isOwner = isnetworkowner(enemyRoot)
								end
								if isOwner then
									enemyRoot.CFrame = targetCF
								end
							end

							if enemyRoot.CanCollide then enemyRoot.CanCollide = false end
							if enemyHum.WalkSpeed ~= 0 then enemyHum.WalkSpeed = 0 end
							if enemyHum.JumpPower ~= 0 then enemyHum.JumpPower = 0 end
						end
					end
				end
			end
		end)
	end))
end

local function StopBringMobs()
	_G.G_BringMobs = false
	Config.BringMob = false

	if bringMobsConnection then
		bringMobsConnection:Disconnect()
		bringMobsConnection = nil
	end
	bringMobsCache = {}

	pcall(function()
		local enemies = _Workspace:FindFirstChild("Enemies")
		if enemies then
			for _, enemy in ipairs(enemies:GetChildren()) do
				if enemy:IsA("Model") then
					local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
					if enemyRoot then
						local bv = enemyRoot:FindFirstChild("BodyVelocity")
						if bv then bv:Destroy() end
					end
				end
			end
		end
	end)
end

local bringMobSwitch = irukaAddToggle(bloxfruitsRightScroll,"Bring Mob",Config.BringMob,function(state)
	Config.BringMob = state
	_G.G_BringMobs = state
	SaveConfig()
	if state then StartBringMobs() else StopBringMobs() end
end)
_G.G_BringMobs = Config.BringMob and true or false
if _G.G_BringMobs then StartBringMobs() end

-- [v8] Safe Mode When Low Health / Escape Health % / Safe Void 整組已依需求移除

--[[local SkillColorSwitch = irukaAddToggle(bloxfruitsRightScroll,"Skill Color(Black)",Config.SkillColor,function(state)
	Config.SkillColor = state
	SaveConfig()
end)]]--

-- [Aurora UI] 分頁自帶捲動，無需手動 CanvasSize
updatePlayerList()

-- [Aurora UI] 舊視窗關閉確認框已移除（改由 Aurora 關閉鈕處理）

local inviteCode = "https://discord.gg/Gq4HKM6rcu"
local discordButton = irukaAddButton(configLeftScroll,"Join Discord")
irukaTrack(discordButton.MouseButton1Click:Connect(function()
	setclipboard(inviteCode)
	showNotification("setclipboard!","已複製!",Color3.fromRGB(255, 255, 255))
end))

-- [v8] Tiktok 按鈕已依需求移除

local AutoSaveSwitch = irukaAddToggle(configRightScroll,"Auto Save",Config.AutoSave,function(state)
	Config.AutoSave = state
	SaveConfig()
end)

function rejoin()
    task.wait(1)
    pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end)
end

irukaTrack(player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        rejoin()
    end
end))

irukaTrack(game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(v)
    if v.Name == "ErrorPrompt" and Config.AutoRejoin then
        rejoin()
    end
end))

local autoRejoinSwitch = irukaAddToggle(configRightScroll,"Auto Rejoin When Kicked",Config.AutoRejoin,function(state)
	Config.AutoRejoin = state
	SaveConfig()
end)

--======================================
--======================================
--======================================
--======================================
--======================================
--======================================
--======================================
--======================================
--======================================
--======================================

-- 前向宣告：商店/自瞄 UI 元件用 table 收集（避免超出 Lua 200 local 限制）

function changeLanguage()
    irukaSetTabLabel(homeButton, Config.Language and "主頁" or "Home")
	irukaSetTabLabel(espButton, Config.Language and "透視 (ESP)" or "ESP")
	irukaSetTabLabel(otherButton, Config.Language and "其他" or "Other")
	irukaSetTabLabel(bloxfruitsButton, Config.Language and "航海王 (BF)" or "BF")
	irukaSetTabLabel(configButton, Config.Language and "設定" or "Config")
	irukaSetTabLabel(visualButton, Config.Language and "視覺外觀" or "Visual")
	if irukaContainer.dropdownCurrent then irukaContainer.dropdownCurrent.Text = Config.Language and "選擇目標玩家" or "Select Player" end
	refreshButton.Text = Config.Language and "重新整理玩家" or "Refresh"
	takeShip.Text = Config.Language and "帶去船上" or "Take Ship"
	BypassYTweenSwitch.TextLabel.Text = Config.Language and "繞過 Y 軸緩動 (Tween)" or "Bypass Y Tween"
	circleModeSwitch.TextLabel.Text = Config.Language and "環繞模式" or "Circle Mode"
	circleTypeSwitch.TextLabel.Text = Config.Language and "環繞類型 (平滑/菱角)" or "Circle Type(Smooth/Angular)"
	CircleSpeedInput.TextLabel.Text = Config.Language and "環繞速度" or "Circle Speed"
	CircleRadiusInput.TextLabel.Text = Config.Language and "環繞半徑" or "Circle Radius"
	hideTweenSwitch.TextLabel.Text = Config.Language and "隱蔽緩動" or "Hide Tween"
	useOffsetSwitch.TextLabel.Text = Config.Language and "使用偏移量" or "Use Offset"
	xOffsetInput.TextLabel.Text = Config.Language and "X 軸偏移" or "Offset X"
	yOffsetInput.TextLabel.Text = Config.Language and "Y 軸偏移" or "Offset Y"
	zOffsetInput.TextLabel.Text = Config.Language and "Z 軸偏移" or "Offset Z"
	flyguiButton.Text = Config.Language and "飛行面板" or "Fly Gui"
	FPSBoostButton.Text = Config.Language and "FPS 優化" or "FPS Boost"
	changeTeamButton.Text = Config.Language and "更換陣營" or "Change Team" -- 此項為修正：這是 createButton 建立的按鈕(TextButton)，沒有 TextLabel 子物件，原本寫 .TextLabel.Text 會在這行報錯，導致 changeLanguage 中斷、後面全部翻譯失效
	PvpCheckGuiButton.Text = Config.Language and "PVP 查詢表" or "PvpCheckList"
	speedLabel.Text = Config.Language and "移動速度:" or "Speed:"
	discordButton.Text = Config.Language and "加入 Discord" or "Join Discord"
-- [v8] Tiktok 按鈕已移除
	desyncButton.Text = Config.Language and "非同步 (Desync)" or "Desync"
 	hitboxSizeInput.TextLabel.Text = Config.Language and "判定框大小" or "Hitbox Size"
	speedHackInput.TextLabel.Text = Config.Language and "速度數值" or "Speed Value"
	jumpHackInput.TextLabel.Text = Config.Language and "跳躍力數值" or "Jump Value"
	FFlagsBox.TextLabel.Text = Config.Language and "快顯旗標輸入 (FFlags)" or "FFlags"
	nameespSwitch.TextLabel.Text = Config.Language and "名稱透視" or "Name ESP"
	box1espSwitch.TextLabel.Text = Config.Language and "方框透視 V1" or "Box ESP V1"
	box2espSwitch.TextLabel.Text = Config.Language and "方框透視 V2" or "Box ESP V2"
	tracerespSwitch.TextLabel.Text = Config.Language and "追蹤連線透視" or "Tracer ESP"
	highlighSwitch.TextLabel.Text = Config.Language and "高亮透視" or "Highlight ESP"
	kenespSwitch.TextLabel.Text = Config.Language and "見聞色透視 (Ken)" or "Ken ESP"
	movingSwitch.TextLabel.Text = Config.Language and "移動追蹤" or "Move to Target"
	moveModeSwitch.TextLabel.Text = Config.Language and "追蹤模式 (傳送/緩動)" or "Tween Mode (TP/Tween)"
	camLockSwitch.TextLabel.Text = Config.Language and "鏡頭鎖定" or "Cam Lock"
	viewSwitch.TextLabel.Text = Config.Language and "觀戰玩家" or "Player View"
	setHitboxSwitch.TextLabel.Text = Config.Language and "啟用判定框" or "Hitbox Enabled"
	hitboxVisibleSwitch.TextLabel.Text = Config.Language and "顯示判定框" or "Hitbox Visible"
	removeAnimationSwitch.TextLabel.Text = Config.Language and "移除動畫" or "Remove Animation"
	noClipSwitch.TextLabel.Text = Config.Language and "穿牆 (NoClip)" or "NoClip"
	FFlagSwitch.TextLabel.Text = Config.Language and "啟用 FFlag" or "Set FFlag"
	removeLavaSwitch.TextLabel.Text = Config.Language and "移除岩漿" or "Remove Lava"
	tpSwitch.TextLabel.Text = Config.Language and "傳送面板" or "TP Gui"
	tpYOffsetInput.TextLabel.Text = Config.Language and "傳送 Y 軸偏移" or "TP Y Offset" -- 此項為新增
	walkWaterSwitch.TextLabel.Text = Config.Language and "水面行走" or "Walk Water"
	unbreakableSwitch.TextLabel.Text = Config.Language and "免疫中斷 (Unbreakable)" or "Unbreakable" -- 此項為新增
	dashDistanceInput.TextLabel.Text = Config.Language and "衝刺距離" or "Dash Distance" -- 此項為新增
	superDashSwitch.TextLabel.Text = Config.Language and "超級衝刺" or "Super Dash" -- 此項為新增
	normalAttackRangeInput.TextLabel.Text = Config.Language and "一般攻擊範圍" or "Normal Attack Range" -- 此項為新增
	buddhaAttackRangeInput.TextLabel.Text = Config.Language and "大佛攻擊範圍" or "Buddha Attack Range" -- 此項為新增
	fastAttackDelayInput.TextLabel.Text = Config.Language and "快速攻擊間隔" or "Fast Attack Delay" -- 此項為新增
	fastAttackMobSwitch.TextLabel.Text = Config.Language and "快速攻擊 NPC" or "Fast Attack Mob"
	fastAttackPlayerSwitch.TextLabel.Text = Config.Language and "快速攻擊玩家" or "Fast Attack Player"
	BypassfastAttackPSwitch.TextLabel.Text = Config.Language and "繞過快速攻擊檢測" or "Fast Attack Bypass"
	superRangeSwitch.TextLabel.Text = Config.Language and "超大攻擊範圍 (僅限大佛)" or "Super Range(Buddha Only)"
	fruitM1AuraSwitch.TextLabel.Text = Config.Language and "果實M1光環 (Fruit M1)" or "Fruit M1 Aura"
	if _G.IrukaFruitM1Ctl and _G.IrukaFruitM1Ctl.speedInput then
		_G.IrukaFruitM1Ctl.speedInput.TextLabel.Text = Config.Language and "果實M1攻速 (最低0.1)" or "Fruit M1 Attack Speed"
	end
guitarAuraSwitch.TextLabel.Text = Config.Language and "龍炮/吉他光環" or "Guitar/Dragonstorm aura"
	antiOneShotV1Switch.TextLabel.Text = Config.Language and "防秒殺 V1" or "Anti One Shot V1"
	antiOneShotV2Switch.TextLabel.Text = Config.Language and "防秒殺 V2" or "Anti One Shot V2"
	spinSwitch.TextLabel.Text = Config.Language and "旋轉" or "Spin"
	speedHackV2Switch.TextLabel.Text = Config.Language and "內核加速" or "Speed Hack V2"
	speedHackSwitch.TextLabel.Text = Config.Language and "加速" or "Speed Hack"
	jumpHackSwitch.TextLabel.Text = Config.Language and "修改跳躍力" or "Jump Hack"
	infinityJumpSwitch.TextLabel.Text = Config.Language and "無限跳躍" or "Infinity Jump"
	cameraFOVinput.TextLabel.Text = Config.Language and "鏡頭視野 (FOV)" or "Camera FOV" -- 此項為新增
	CameraMaxZoomInput.TextLabel.Text = Config.Language and "鏡頭最大縮放距離" or "Max Camera Zoom" -- 此項為新增
	statsSwitch.TextLabel.Text = Config.Language and "數值面板" or "Stats Gui"
	-- [v8] No Skill CD 開關已移除
	autoBusoSwitch.TextLabel.Text = Config.Language and "自動武裝色" or "Auto Buso"
	noStunSwitch.TextLabel.Text = Config.Language and "移除暈眩" or "No Stun"
	-- [v8] Auto Kill 4 開關已移除
	autoV3Switch.TextLabel.Text = Config.Language and "自動V3" or "Auto V3"
	autoV4Switch.TextLabel.Text = Config.Language and "自動V4" or "Auto V4"
	if bringMobSwitch then bringMobSwitch.TextLabel.Text = Config.Language and "聚怪 (Bring Mob)" or "Bring Mob" end
	-- [v8] Safe Mode / Escape % / Safe Void 已移除
	AutoSaveSwitch.TextLabel.Text = Config.Language and "自動儲存設定" or "Auto Save"
	autoRejoinSwitch.TextLabel.Text = Config.Language and "踢出時自動重新加入" or "Auto Rejoin When Kicked"
	changeLanguageSwitch.TextLabel.Text = Config.Language and "切換至英文 (Switch to English)" or "切換至中文 (Switch to Chinese)"
	fruitespSwitch.TextLabel.Text = Config.Language and "果實透視" or "Fruit ESP"
	if _M.ShopUI.resetStats then _M.ShopUI.resetStats.Text = Config.Language and "重置數據" or "Reset Stats" end
	if _M.ShopUI.rerollRace then _M.ShopUI.rerollRace.Text = Config.Language and "重置種族" or "Reroll Race" end
	if _M.ShopUI.joinPirates then _M.ShopUI.joinPirates.Text = Config.Language and "加入海盜" or "Join Pirates" end
	if _M.ShopUI.joinMarines then _M.ShopUI.joinMarines.Text = Config.Language and "加入海軍" or "Join Marines" end
	if _M.ShopUI.changeVampire then _M.ShopUI.changeVampire.Text = Config.Language and "更換吸血鬼" or "Change Vampire" end
	if _M.ShopUI.changeCyborg then _M.ShopUI.changeCyborg.Text = Config.Language and "更換機器人" or "Change Cyborg" end
	if _M.AimUI.showFov then _M.AimUI.showFov.TextLabel.Text = Config.Language and "顯示 FOV 範圍" or "Show FOV" end
	if _M.AimUI.fovMode then _M.AimUI.fovMode.TextLabel.Text = Config.Language and "FOV 置中模式" or "FOV Center Mode" end
	if _M.AimUI.fovInput then _M.AimUI.fovInput.TextLabel.Text = Config.Language and "FOV 半徑" or "FOV Radius" end
	if _M.AimUI.m1r then _M.AimUI.m1r.TextLabel.Text = Config.Language and "M1 靜默自瞄" or "M1 R Silent Aim" end
	if _M.AimUI.skill then _M.AimUI.skill.TextLabel.Text = Config.Language and "技能靜默自瞄" or "Skill Silent Aim" end
	if _M.AimUI.showLine then _M.AimUI.showLine.TextLabel.Text = Config.Language and "顯示鎖定線" or "Show Lock Line" end
	if _M.AimUI.targetPlayers then _M.AimUI.targetPlayers.TextLabel.Text = Config.Language and "瞄準玩家" or "Target Players" end
	if _M.AimUI.targetMobs then _M.AimUI.targetMobs.TextLabel.Text = Config.Language and "瞄準怪物" or "Target Mobs" end
	if _M.AimUI.teamCheck then _M.AimUI.teamCheck.TextLabel.Text = Config.Language and "隊伍檢查" or "Team Check" end
	if _M.AimUI.excludePVP then _M.AimUI.excludePVP.TextLabel.Text = Config.Language and "排除未開 PVP" or "Exclude PVP Off" end
	if _M.AimUI.method then _M.AimUI.method.TextLabel.Text = Config.Language and "方法 (1=鼠標/2=最近/3=選擇)" or "Method (1=Mouse/2=Nearest/3=Select)" end
	if _M.AimUI.part then _M.AimUI.part.TextLabel.Text = Config.Language and "瞄準部位" or "Aim Part" end
	if _M.AimUI.skillLabel then _M.AimUI.skillLabel.Text = Config.Language and "技能:" or "Skills:" end
	irukaSetTabLabel(aimButton, Config.Language and "自瞄" or "Aim")
end
--======================================
--======================================
--======================================
--======================================
--======================================
--======================================
--======================================
--======================================

if not bloxFruitsMode then

	local bloxfruitsGui ={takeShip,kenespSwitch,removeLavaSwitch,tpSwitch,fastAttackMobSwitch,fastAttackPlayerSwitch,BypassfastAttackPSwitch,
		superRangeSwitch,changeTeamButton,walkWaterSwitch,autoV3Switch,autoV4Switch,PvpCheckGuiButton,noStunSwitch
	}

	for i,switch in ipairs(bloxfruitsGui) do
		if switch:FindFirstChild("SwitchBase") then
			switch.TextLabel.Text =Config.Language and "Bloxfruit才能開" or "Bloxfruits only"
		else 
			switch.Text = Config.Language and "Bloxfruit才能開" or "Bloxfruits only"
		end
	end
end
changeLanguageSwitch = irukaAddToggle(configRightScroll, "Change Language(En/Cn)", Config.Language, function(state)
	Config.Language = state
	SaveConfig()
	changeLanguage()
end)

----------------------------------------
-- Visual 分頁：商店功能
----------------------------------------
_M.ShopUI.resetStats = irukaAddButton(visualLeftScroll, "Reset Stats")
irukaTrack(_M.ShopUI.resetStats.MouseButton1Click:Connect(function()
	pcall(function()
		game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "2")
	end)
end))

_M.ShopUI.rerollRace = irukaAddButton(visualLeftScroll, "Reroll Race")
irukaTrack(_M.ShopUI.rerollRace.MouseButton1Click:Connect(function()
	pcall(function()
		game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BlackbeardReward", "Reroll", "2")
	end)
end))

_M.ShopUI.joinPirates = irukaAddButton(visualLeftScroll, "Join Pirates")
irukaTrack(_M.ShopUI.joinPirates.MouseButton1Click:Connect(function()
	pcall(function()
		game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
	end)
end))

_M.ShopUI.joinMarines = irukaAddButton(visualLeftScroll, "Join Marines")
irukaTrack(_M.ShopUI.joinMarines.MouseButton1Click:Connect(function()
	pcall(function()
		game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Marines")
	end)
end))

_M.ShopUI.changeVampire = irukaAddButton(visualLeftScroll, "Change Vampire")
irukaTrack(_M.ShopUI.changeVampire.MouseButton1Click:Connect(function()
	pcall(function()
		game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Ectoplasm", "Change", 4)
	end)
end))

_M.ShopUI.changeCyborg = irukaAddButton(visualLeftScroll, "Change Cyborg")
irukaTrack(_M.ShopUI.changeCyborg.MouseButton1Click:Connect(function()
	pcall(function()
		game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CyborgTrainer", "Buy")
	end)
end))

----------------------------------------
-- Aim 分頁：SilentAim / FOV 繪製
----------------------------------------
task.spawn(function()
_M.SA = {};
_M.SA.ReplicatedStorage = game:GetService("ReplicatedStorage")
_M.SA.FovCircle = irukaTrackDrawing(Drawing.new("Circle"))
_M.SA.FovCircle.Visible = false
_M.SA.FovCircle.Color = Color3.fromRGB(255, 0, 0)
_M.SA.FovCircle.Radius = Config.SilentAimFOV or 100
_M.SA.FovCircle.Thickness = 2
_M.SA.FovCircle.Filled = false

_M.SA.Line = irukaTrackDrawing(Drawing.new("Line"))
_M.SA.Line.Thickness = 2
_M.SA.Line.Color = Color3.fromRGB(255, 0, 0)
_M.SA.Line.Transparency = 1
_M.SA.Line.Visible = false

if Config.SilentAimShowFOV then _M.SA.FovCircle.Visible = true end
if Config.SilentAimFOV then _M.SA.FovCircle.Radius = Config.SilentAimFOV end

-- FOV 圈跟隨鼠標/屏幕中心
task.spawn(function()
	irukaTrack(RunService.RenderStepped:Connect(function()
		if not _M.SA.FovCircle.Visible then return end
		local p
		if Config.SilentAimFOVMode then
			local v = workspace.CurrentCamera.ViewportSize
			p = Vector2.new(v.X / 2, v.Y / 2)
		else
			p = UserInputService:GetMouseLocation()
			if p.X <= 0 or p.Y <= 0 then
				local v = workspace.CurrentCamera.ViewportSize
				p = Vector2.new(v.X / 2, v.Y / 2)
			end
		end
		_M.SA.FovCircle.Position = p
	end))
end)

-- 技能按鍵追蹤
_M.SA.LastSkillPressed = "Z"
irukaTrack(UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if UserInputService:GetFocusedTextBox() then return end
	if input.KeyCode == Enum.KeyCode.Z then
		_M.SA.LastSkillPressed = "Z"
	elseif input.KeyCode == Enum.KeyCode.X then
		_M.SA.LastSkillPressed = "X"
	elseif input.KeyCode == Enum.KeyCode.C then
		_M.SA.LastSkillPressed = "C"
	elseif input.KeyCode == Enum.KeyCode.V then
		_M.SA.LastSkillPressed = "V"
	elseif input.KeyCode == Enum.KeyCode.F then
		_M.SA.LastSkillPressed = "F"
	end
end))

_M.SA.IsSkillSelected = function(skillName)
	local skills = Config.SilentAimSkills
	if not skills then return true end
	if type(skills) == "table" then
		if next(skills) == nil then return false end
		if skills[skillName] ~= nil then
			return skills[skillName] == true
		end
		for _, v in pairs(skills) do
			if v == skillName then return true end
		end
		return false
	end
	return true
end

_M.SA.IsCurrentSkillEnabled = function()
	return _M.SA.IsSkillSelected(_M.SA.LastSkillPressed)
end

_M.SA.IsSilentAimAlive = function(character)
	if not character then return false end
	local hum = character:FindFirstChildOfClass("Humanoid")
	return hum ~= nil and hum.Health > 0
end

_M.SA.IsSilentAimEnemy = function(otherPlayer)
	if not otherPlayer or otherPlayer == player then return false end
	local myTeam, targetTeam = player.Team, otherPlayer.Team
	if myTeam and targetTeam and myTeam.Name == "Marines" and targetTeam.Name == "Marines" then
		return false
	end
	return true
end

_M.SA.GetSilentAimOrigin = function()
	local p = UserInputService:GetMouseLocation()
	if Config.SilentAimFOVMode or p.X <= 0 or p.Y <= 0 then
		local v = workspace.CurrentCamera.ViewportSize
		return Vector2.new(v.X / 2, v.Y / 2)
	end
	return p
end

_M.SA.Target = nil

_M.SA.GetClosestTarget = function()
	local method = Config.SilentAimMethod or 1

	-- 方法3：選擇玩家
	if method == 3 then
		if not Config.SilentAimTargetPlayers then return nil end
		if not selectedTarget then return nil end
		local targetPlayer = selectedTarget
		if not targetPlayer or targetPlayer == player then return nil end
		if Config.SilentAimTeamCheck and not _M.SA.IsSilentAimEnemy(targetPlayer) then return nil end
		if Config.SilentAimExcludePVP and targetPlayer:GetAttribute("PvpDisabled") == true then return nil end
		local character = targetPlayer.Character
		if not _M.SA.IsSilentAimAlive(character) then return nil end
		return character:FindFirstChild(Config.SilentAimPart) or character:FindFirstChild("HumanoidRootPart")
	end

	-- 方法2：最近的玩家（3D 距離）
	if method == 2 then
		local myChar = player.Character
		local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if not myRoot then return nil end
		local closest, shortest = nil, math.huge
		local myPos = myRoot.Position

		local function checkNearest(character)
			if not _M.SA.IsSilentAimAlive(character) then return end
			local part = character:FindFirstChild(Config.SilentAimPart) or character:FindFirstChild("HumanoidRootPart")
			if not part then return end
			local d = (part.Position - myPos).Magnitude
			if d < shortest then closest, shortest = part, d end
		end

		if Config.SilentAimTargetPlayers then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player then
					if (not Config.SilentAimTeamCheck or _M.SA.IsSilentAimEnemy(p)) and not (Config.SilentAimExcludePVP and p:GetAttribute("PvpDisabled") == true) then
						checkNearest(p.Character)
					end
				end
			end
		end
		if Config.SilentAimTargetMobs and workspace:FindFirstChild("Enemies") then
			for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
				checkNearest(enemy)
			end
		end
		return closest
	end

	-- 方法1（默認）：鼠標最近的玩家（FOV 內屏幕距離）
	local origin = _M.SA.GetSilentAimOrigin()
	local closest, shortest = nil, math.huge

	local function check(character)
		if not _M.SA.IsSilentAimAlive(character) then return end
		local part = character:FindFirstChild(Config.SilentAimPart) or character:FindFirstChild("HumanoidRootPart")
		if not part then return end
		local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
		if onScreen then
			local dist = (Vector2.new(pos.X, pos.Y) - origin).Magnitude
			if dist <= (Config.SilentAimFOV or 100) and dist < shortest then closest, shortest = part, dist end
		end
	end

	if Config.SilentAimTargetPlayers then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player then
				if (not Config.SilentAimTeamCheck or _M.SA.IsSilentAimEnemy(p)) and not (Config.SilentAimExcludePVP and p:GetAttribute("PvpDisabled") == true) then
					check(p.Character)
				end
			end
		end
	end
	if Config.SilentAimTargetMobs and workspace:FindFirstChild("Enemies") then
		for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
			check(enemy)
		end
	end
	return closest
end

-- RenderStepped：更新目標 + 繪製鎖定線（目標掃描節流 ~20Hz，降低高頻重掃負擔）
local _saNext = 0
irukaTrack(RunService.RenderStepped:Connect(function()
	-- [v13] 效能：M1R / Skill / 鎖定線全關時直接跳過（原本每幀仍取滑鼠座標、重設 Drawing.Visible）
	if not (Config.SilentAimM1R or Config.SilentAimSkill or Config.SilentAimShowLine) then
		if _M.SA.Target ~= nil then _M.SA.Target = nil end
		if _M.SA.Line.Visible then _M.SA.Line.Visible = false end
		return
	end
	local p = UserInputService:GetMouseLocation()
	if Config.SilentAimFOVMode or p.X <= 0 or p.Y <= 0 then
		local v = workspace.CurrentCamera.ViewportSize
		p = Vector2.new(v.X / 2, v.Y / 2)
	end

	local _now = os.clock()
	if _now >= _saNext then
		_saNext = _now + 0.05
		if Config.SilentAimM1R or Config.SilentAimSkill or Config.SilentAimShowLine then
			_M.SA.Target = _M.SA.GetClosestTarget()
		else
			_M.SA.Target = nil
		end
	end

	if Config.SilentAimShowLine and _M.SA.Target then
		local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(_M.SA.Target.Position)
		-- [FOV 限制] 只有位在 FOV 範圍內的目標才顯示鎖定線
		local inFov = false
		if onScreen then
			inFov = (Vector2.new(pos.X, pos.Y) - p).Magnitude <= (Config.SilentAimFOV or 100)
		end
		if onScreen and inFov then
			_M.SA.Line.Visible = true
			_M.SA.Line.From = p
			_M.SA.Line.To = Vector2.new(pos.X, pos.Y)
		else
			_M.SA.Line.Visible = false
		end
	else
		_M.SA.Line.Visible = false
	end
end))

-- M1R 自瞄：hookmetamethod __index 攔截 mouse
_M.SA.mouse = player:GetMouse()
_M.SA.oldIndex = nil
if hookmetamethod and checkcaller then
	pcall(function()
		_M.SA.oldIndex = hookmetamethod(game, "__index", function(self, key)
			if Config.SilentAimM1R and _M.SA.IsCurrentSkillEnabled() and _M.SA.Target and not checkcaller() and self == _M.SA.mouse then
				local tp = _M.SA.Target.Position
				local cp = workspace.CurrentCamera.CFrame.Position
				if key == "Hit" then return CFrame.new(tp)
				elseif key == "Target" then return _M.SA.Target
				elseif key == "UnitRay" then return Ray.new(cp, (tp - cp).Unit)
				elseif key == "Origin" then return cp
				elseif key == "Direction" then return (tp - cp).Unit
				end
			end
			return _M.SA.oldIndex(self, key)
		end)
	end)
end

-- 技能自瞄：namecall 攔截 FireServer/InvokeServer + Vector3 替換
if getrawmetatable and newcclosure then
	pcall(function()
		local mt = getrawmetatable(game)
		local silentAimOldNamecall = mt.__namecall
		if setreadonly then setreadonly(mt, false) else make_writeable(mt) end

		mt.__namecall = newcclosure(function(self, ...)
			local method = getnamecallmethod()
			local args = {...}
			if Config.SilentAimSkill and _M.SA.IsCurrentSkillEnabled() and _M.SA.Target and (method == "FireServer" or method == "InvokeServer") then
				local sName = tostring(self)
				if sName == "RemoteEvent" or sName == "CommE" or sName == "RemoteFunction" then
					local targetPos = _M.SA.Target.Position
					for i, v in pairs(args) do
						if typeof(v) == "Vector3" then
							args[i] = targetPos
						end
					end
					return silentAimOldNamecall(self, unpack(args))
				end
			end
			return silentAimOldNamecall(self, ...)
		end)

		if setreadonly then setreadonly(mt, true) else make_readonly(mt) end
	end)
end

-- Mouse module hook
_M.SA.MouseModuleInstance = _M.SA.ReplicatedStorage:FindFirstChild("Mouse")
_M.SA.MouseModule = nil
if _M.SA.MouseModuleInstance then
	pcall(function() _M.SA.MouseModule = require(_M.SA.MouseModuleInstance) end)
end
if _M.SA.MouseModule and typeof(_M.SA.MouseModule) == "table" then
	pcall(function()
		local realStore = { Hit = rawget(_M.SA.MouseModule, "Hit"), Target = rawget(_M.SA.MouseModule, "Target") }
		local mmt = getrawmetatable(_M.SA.MouseModule)
		if mmt then setreadonly(mmt, false) else mmt = {}; setmetatable(_M.SA.MouseModule, mmt) end
		rawset(_M.SA.MouseModule, "Hit", nil); rawset(_M.SA.MouseModule, "Target", nil)
		mmt.__index = function(self, key)
			if key == "Hit" then
				if Config.SilentAimSkill and _M.SA.IsCurrentSkillEnabled() and _M.SA.Target then return CFrame.new(_M.SA.Target.Position) end
				return realStore.Hit
			elseif key == "Target" then
				if Config.SilentAimSkill and _M.SA.IsCurrentSkillEnabled() and _M.SA.Target then return _M.SA.Target end
				return realStore.Target
			end
		end
		mmt.__newindex = function(self, key, value)
			if key == "Hit" or key == "Target" then realStore[key] = value else rawset(self, key, value) end
		end
		setreadonly(mmt, true)
	end)
end

-- Aim 分頁 UI 開關
_M.AimUI.showFov = irukaAddToggle(aimLeftScroll, "Show FOV", Config.SilentAimShowFOV, function(state)
	Config.SilentAimShowFOV = state
	_M.SA.FovCircle.Visible = state
	SaveConfig()
end)

_M.AimUI.fovMode = irukaAddToggle(aimLeftScroll, "FOV Center Mode", Config.SilentAimFOVMode, function(state)
	Config.SilentAimFOVMode = state
	SaveConfig()
end)

_M.AimUI.fovInput = irukaAddInput(aimLeftScroll, "FOV Radius", tostring(Config.SilentAimFOV), function(value)
	local num = tonumber(value)
	if num and num >= 10 and num <= 1500 then
		Config.SilentAimFOV = num
		_M.SA.FovCircle.Radius = num
		SaveConfig()
	end
end)

_M.AimUI.m1r = irukaAddToggle(aimLeftScroll, "M1 R Silent Aim", Config.SilentAimM1R, function(state)
	Config.SilentAimM1R = state
	SaveConfig()
end)

_M.AimUI.skill = irukaAddToggle(aimLeftScroll, "Skill Silent Aim", Config.SilentAimSkill, function(state)
	Config.SilentAimSkill = state
	SaveConfig()
end)

_M.AimUI.showLine = irukaAddToggle(aimLeftScroll, "Show Lock Line", Config.SilentAimShowLine, function(state)
	Config.SilentAimShowLine = state
	if not state then _M.SA.Line.Visible = false end
	SaveConfig()
end)

_M.AimUI.targetPlayers = irukaAddToggle(aimLeftScroll, "Target Players", Config.SilentAimTargetPlayers, function(state)
	Config.SilentAimTargetPlayers = state
	SaveConfig()
end)

_M.AimUI.targetMobs = irukaAddToggle(aimLeftScroll, "Target Mobs", Config.SilentAimTargetMobs, function(state)
	Config.SilentAimTargetMobs = state
	SaveConfig()
end)

_M.AimUI.teamCheck = irukaAddToggle(aimLeftScroll, "Team Check", Config.SilentAimTeamCheck, function(state)
	Config.SilentAimTeamCheck = state
	SaveConfig()
end)

_M.AimUI.excludePVP = irukaAddToggle(aimLeftScroll, "Exclude PVP Off", Config.SilentAimExcludePVP, function(state)
	Config.SilentAimExcludePVP = state
	SaveConfig()
end)

-- 右側：方法、部位、技能選擇
_M.AimUI.method = irukaAddInput(aimRightScroll, "Method (1=Mouse/2=Nearest/3=Select)", tostring(Config.SilentAimMethod), function(value)
	local num = tonumber(value)
	if num and num >= 1 and num <= 3 then
		Config.SilentAimMethod = num
		SaveConfig()
	end
end)

-- [v10] Aim Part 改為下拉選單（Head / HumanoidRootPart）
local _aimPartOptions = {"Head", "HumanoidRootPart"}
local _aimPartIndex = (Config.SilentAimPart == "HumanoidRootPart") and 2 or 1
_M.AimUI.part = irukaAddDropdown(aimRightScroll, "Aim Part", _aimPartOptions, _aimPartIndex, function(opt)
	Config.SilentAimPart = opt
	SaveConfig()
end)

-- 技能選擇按鈕（Z/X/C/V/F 切換）
_M.SA.skillBtns = {}
_M.SA.updateSkillBtns = function()
	for _, btn in ipairs(_M.SA.skillBtns) do
		local skill = btn.Name
		local enabled = false
		for _, v in ipairs(Config.SilentAimSkills) do
			if v == skill then enabled = true break end
		end
		if enabled then
			btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
		else
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		end
	end
end

_M.SA.skillFrame = Instance.new("Frame", aimRightScroll)
_M.SA.skillFrame.Size = UDim2.new(1, -10, 0, 35)
_M.SA.skillFrame.BackgroundTransparency = 1
_M.AimUI.skillLabel = Instance.new("TextLabel", _M.SA.skillFrame)
_M.AimUI.skillLabel.Size = UDim2.new(1, 0, 0, 15)
_M.AimUI.skillLabel.BackgroundTransparency = 1
_M.AimUI.skillLabel.Text = "Skills:"
_M.AimUI.skillLabel.FontFace = CUSTOM_FONT or Enum.Font.GothamBold
_M.AimUI.skillLabel.TextSize = 14
_M.AimUI.skillLabel.TextColor3 = Color3.new(1, 1, 1)
_M.AimUI.skillLabel.TextXAlignment = Enum.TextXAlignment.Left
_M.SA.skillList = Instance.new("Frame", _M.SA.skillFrame)
_M.SA.skillList.Size = UDim2.new(1, 0, 0, 20)
_M.SA.skillList.Position = UDim2.new(0, 0, 0, 15)
_M.SA.skillList.BackgroundTransparency = 1
_M.SA.skillListLayout = Instance.new("UIListLayout", _M.SA.skillList)
_M.SA.skillListLayout.FillDirection = Enum.FillDirection.Horizontal
_M.SA.skillListLayout.Padding = UDim.new(0, 4)
for _, skill in ipairs({"Z", "X", "C", "V", "F"}) do
	local btn = Instance.new("TextButton", _M.SA.skillList)
	btn.Name = skill
	btn.Size = UDim2.new(0, 30, 0, 20)
	btn.Text = skill
	btn.FontFace = CUSTOM_FONT or Enum.Font.GothamBold
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1, 1, 1)
	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 6)
	irukaTrack(btn.MouseButton1Click:Connect(function()
		local found = false
		for i, v in ipairs(Config.SilentAimSkills) do
			if v == skill then
				table.remove(Config.SilentAimSkills, i)
				found = true
				break
			end
		end
		if not found then
			table.insert(Config.SilentAimSkills, skill)
		end
		_M.SA.updateSkillBtns()
		SaveConfig()
	end))
	table.insert(_M.SA.skillBtns, btn)
end
_M.SA.updateSkillBtns()
end) -- task.spawn end (SilentAim)

pcall(function() changeLanguage() end) -- 此項為修正：啟動時的 changeLanguage 加上 pcall 保護，避免未來任何一行翻譯出錯就直接中斷後面整個腳本載入(套用設定、Discord 紀錄等)

local setUpPlayer = player.Character or player.CharacterAdded:Wait()
if Config.RemoveAnimation then
	local humanoid = player.Character:WaitForChild("Humanoid")
	for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
		track:Stop()
	end
	removeAnimationConnection = irukaTrack(humanoid.AnimationPlayed:Connect(function(track)
		track:Stop()
	end))
end 

-- 【修正-config】啟動套用區加上 pcall 保護：之前任何一行出錯(例如相機暫時為 nil、
-- 地圖物件還沒生成)會讓後面所有功能直接跳過不載入 → 開關顯示開著但功能沒生效
pcall(function()
	if Config.Spin then applySpin(player.Character) end
end)

pcall(function()
	if Config.FFlagEnabled and Config.FFlags ~= nil then
		local s = HttpService:JSONDecode(Config.FFlags:gsub('"True"', "true"):gsub('"False"', "false"))
    	for i,v in s do
    		setff(i,v)
		end
	end
end)

if Config.NoClip then setUpNoClip() end
if Config.SpeedHackV2 then setUpSpeedV2() end
if Config.SpeedHack then ApplySpeed() end
if Config.JumpHack then ApplyJumpPower() end
pcall(function()
	workspace.CurrentCamera.FieldOfView = Config.CameraFOV
end)
player.CameraMaxZoomDistance = Config.CameraMaxZoom
if Config.StatsGui then  
	_statsStart()
end

if bloxFruitsMode then
    if Config.RemoveLava then
	    removeLava()
    end
	if Config.Unbreakable then
		unbreakableConnection = irukaTrack(player.CharacterAdded:Connect(function(character)
			character:SetAttribute("UnbreakableAll", true)
		end))
		if player.Character then
			player.Character:SetAttribute("UnbreakableAll", true)
		end
	-- [v8] No Skill CD 開關已移除 (Backend 保留，Config.NoSkillCD 預設 false 不觸發)
	pcall(function()
		-- [v8] WatchHealth (Safe Mode) 已移除
	end)
    if Config.WalkWater then
		pcall(function()
			(game:GetService("Workspace")).Map["WaterBase-Plane"].Size = Vector3.new(1000, 112, 1000)
		end)
    end
	pcall(function()
		ApplySuperDash(player.Character)
	end)
	EnabledAntiVoid(Config.AntiOneShotV2)
	pcall(function()
		CheckOneShot(player.Character)
	end)
end

----------------------------------------
-- Discord Webhook
----------------------------------------
task.spawn(function()
    -- 檢查 HTTP 請求 API
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
    if not requestFunc then return end

    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")

    -- 確保 LocalPlayer 已載入
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        LocalPlayer = Players.LocalPlayer
    end

    local webhookUrl = "https://discord.com/api/webhooks/1527044194416201758/4SsM95jwrU0XjS0UnyKVAMAYxvxDvFRT2-BlVN23wv1lEDxoNu0CwiYvkVw8ozgT_F-q"

    -- 1. 設備類型判斷
    local deviceType = "💻 PC (電腦)"
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        deviceType = "📱 Mobile / Tablet (手機/平板)"
    elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
        deviceType = "🎮 Console / Gamepad (家機/手把)"
    end

    -- 2. 紀錄與計算執行次數
    local execCountStr = "1 次"
    pcall(function()
        local countFolder = "Hub_Config"
        local countFile = countFolder .. "/exec_count.txt"

        if typeof(isfolder) == "function" and typeof(makefolder) == "function" and not isfolder(countFolder) then
            makefolder(countFolder)
        end

        local currentCount = 1
        if typeof(isfile) == "function" and isfile(countFile) and typeof(readfile) == "function" then
            local storedCount = tonumber(readfile(countFile))
            if storedCount then
                currentCount = storedCount + 1
            end
        end

        if typeof(writefile) == "function" then
            writefile(countFile, tostring(currentCount))
        end

        execCountStr = currentCount .. " 次"
    end)

    -- 3. 取得玩家頭像直鏈
    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"
    pcall(function()
        local thumbApiUrl = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. LocalPlayer.UserId .. "&size=420x420&format=Png&isCircular=false"
        local thumbRes = requestFunc({ Url = thumbApiUrl, Method = "GET" })
        if thumbRes and thumbRes.Body then
            local thumbData = HttpService:JSONDecode(thumbRes.Body)
            if thumbData and thumbData.data and thumbData.data[1] and thumbData.data[1].imageUrl then
                avatarUrl = thumbData.data[1].imageUrl
            end
        end
    end)

    -- 4. 基礎資訊整理
    local executor = (identifyexecutor and identifyexecutor()) or "未知執行器"
    local isPremium = (LocalPlayer.MembershipType == Enum.MembershipType.Premium) and "👑 Premium 會員" or "無會員"
    local accountAge = LocalPlayer.AccountAge .. " 天"
    local localTime = os.date("%Y-%m-%d %H:%M:%S")
    local profileLink = "[點擊查看主頁](https://www.roblox.com/users/" .. LocalPlayer.UserId .. "/profile)"

    -- 5. 伺服器人數與玩家名單整理
    local allPlayers = Players:GetPlayers()
    local playerCount = #allPlayers .. " / " .. Players.MaxPlayers

    local playerNamesList = {}
    for _, player in ipairs(allPlayers) do
        -- 格式：- 暱稱 (@帳號名稱)
        table.insert(playerNamesList, "- " .. player.DisplayName .. " (@" .. player.Name .. ")")
    end

    -- 將名單合併成字串，並使用換行符號(\n)
    local playerNamesString = table.concat(playerNamesList, "\n")

    -- 確保字元不超過 Discord Embed 限制
    if #playerNamesString > 980 then
        playerNamesString = string.sub(playerNamesString, 1, 950) .. "\n... (已省略過長名單)"
    end
    if playerNamesString == "" then
        playerNamesString = "無"
    end

    -- 6. 建立 Discord Embed
    local embedData = {
        ["username"] = "irukahub監控系統",
        ["avatar_url"] = avatarUrl,
        ["embeds"] = {{
            ["title"] = "腳本執行紀錄(irukahub)",
            ["color"] = math.random(0, 16777215),
            ["author"] = {
                ["name"] = LocalPlayer.Name .. " (" .. LocalPlayer.DisplayName .. ")",
                ["icon_url"] = avatarUrl,
                ["url"] = "https://www.roblox.com/users/" .. LocalPlayer.UserId .. "/profile"
            },
            ["fields"] = {
                -- 玩家資訊
                { ["name"] = "👤 玩家名稱", ["value"] = LocalPlayer.Name .. " (`" .. LocalPlayer.DisplayName .. "`)", ["inline"] = true },
                { ["name"] = "🆔 玩家 ID", ["value"] = tostring(LocalPlayer.UserId), ["inline"] = true },
                { ["name"] = "🔗 玩家主頁", ["value"] = profileLink, ["inline"] = true },

                { ["name"] = "👑 會員身份", ["value"] = isPremium, ["inline"] = true },
                { ["name"] = "🎂 帳號創立天數", ["value"] = accountAge, ["inline"] = true },

                -- 設備與執行器資訊
                { ["name"] = "💻 執行設備", ["value"] = deviceType, ["inline"] = true },
                { ["name"] = "⚙️ 執行器", ["value"] = executor, ["inline"] = true },

                -- 伺服器資訊
                { ["name"] = "👥 伺服器人數", ["value"] = playerCount, ["inline"] = true },
                { ["name"] = "🔢 執行紀錄次數", ["value"] = execCountStr, ["inline"] = true },

                -- 伺服器玩家名單 (換行顯示)
                { ["name"] = "📜 伺服器玩家名單", ["value"] = "```\n" .. playerNamesString .. "\n```", ["inline"] = false }
            },
            ["thumbnail"] = { ["url"] = avatarUrl },
            ["footer"] = { ["text"] = "執行時間: " .. localTime }
        }}
    }

    -- 發送 Webhook
    pcall(function()
        requestFunc({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(embedData)
        })
    end)
end)


end

--=====================================================================
--  [v12] 完整卸載 (Unload)：GUI / 連線 / Drawing / 角色狀態，配置檔不受影響
--=====================================================================
local function irukaPerformUnload()
	if _G.__IrukaHubUnloaded then return end
	_G.__IrukaHubUnloaded = true
	_G.__IrukaHubActive = nil

	-- (0) 停止 Fruit M1 執行迴圈（避免卸載後仍在背景攻擊）
	pcall(function()
		if _G.IrukaFruitM1Ctl and _G.IrukaFruitM1Ctl.stop then _G.IrukaFruitM1Ctl.stop() end
	end)

	-- (1) 斷開所有事件監聽與背景執行緒
	local conns = _G.IrukaConnections or {}
	for i = #conns, 1, -1 do
		local c = conns[i]
		pcall(function() if c and c.Disconnect then c:Disconnect() end end)
		conns[i] = nil
	end

	-- (2) 移除所有 Drawing 物件
	local draws = _G.IrukaDrawings or {}
	for i = #draws, 1, -1 do
		local d = draws[i]
		pcall(function() if d and d.Remove then d:Remove() end end)
		draws[i] = nil
	end

	-- (3) 銷毀所有 GUI 實體（主 UI / 懸浮窗 / TP GUI / Stats GUI / Fly GUI / PvpCheck）
	pcall(function()
		local coreGui = game:GetService("CoreGui")
		for _, name in ipairs({ "AuroraUI", "TPGui", "StatsGui", "PlayerListGUI", "main" }) do
			local g = playerGui and playerGui:FindFirstChild(name)
			if g then g:Destroy() end
			local cg = coreGui and coreGui:FindFirstChild(name)
			if cg then cg:Destroy() end
		end
	end)

	-- (4) 還原玩家角色與攝影機狀態
	pcall(function()
		local char = player.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.WalkSpeed = 16
				hum.UseJumpPower = true
				hum.JumpPower = 50
				hum.PlatformStand = false
			end
			local anim = char:FindFirstChild("Animate")
			if anim then anim.Disabled = false end
			for _, d in ipairs(char:GetDescendants()) do
				if d:IsA("BodyVelocity") or d:IsA("BodyGyro") or d:IsA("BodyAngularVelocity") then
					pcall(function() d:Destroy() end)
				end
			end
			for _, d in ipairs(char:GetDescendants()) do
				if d:IsA("BasePart") then d.CanCollide = true end
			end
		end
		if camera then
			camera.FieldOfView = IRUKA_ORIG.FieldOfView or 70
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then camera.CameraSubject = hum end
		end
		if player then
			player.CameraMaxZoomDistance = IRUKA_ORIG.CameraMaxZoomDistance or 128
		end
	end)

	-- (5) 清空註冊表後宣告完成（完全不動配置文件 IrukaHubSettings/config.json）
	_G.IrukaConnections = {}
	_G.IrukaDrawings = {}
	_G.IrukaHubUnload = nil
	print("[IrukaHub] 已完整卸載：GUI / 連線 / Drawing 已清除，角色與攝影機已還原，配置檔保留。")
end
_G.IrukaHubUnload = irukaPerformUnload

-- [v10] 全框架字體與輸入框文字顏色最終套用
local function applyCustomFont(inst)
	if not inst then return end
	pcall(function()
		local function one(d)
			if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
				if CUSTOM_FONT then d.FontFace = CUSTOM_FONT end
				if d:IsA("TextBox") then d.TextColor3 = Color3.fromRGB(255, 255, 255) end
			end
		end
		one(inst)
		for _, d in ipairs(inst:GetDescendants()) do one(d) end
	end)
end
_G.ApplyCustomFont = applyCustomFont
applyCustomFont(screenGui)
if floating then applyCustomFont(floating) end
end)()


-- 補齊原始腳本最外層 `if isBlacklisted() then ... else ...` 缺少的結尾 end
end