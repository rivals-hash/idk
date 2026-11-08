--[[
    Darling Hub - modules/ui/tabs/players.lua
    Players Management & ESP Suite for WindUI.
    Includes:
    - Live server player selection dropdown & auto-refresh
    - Selected player details (Health, Race, Tool, Distance, Team)
    - Camera Spectate toggle
    - Smooth Tween-to-player teleportation
    - Aimbot Blacklist toggle for targeted players
    - Target highlight visualizer
]]

local PlayersTabMod = {}

function PlayersTabMod.init(WindowObj, dependencies)
    local Window = WindowObj.Window
    local WindUI = WindowObj.WindUI
    local AimbotCore = dependencies.AimbotCore
    local Utils = dependencies.Utils

    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer

    local Tab = Window:Tab({
        Title = "Players",
        Desc = "Player radar, spectate & blacklist",
        Icon = "solar:users-group-rounded-bold",
        IconColor = Color3.fromHex("#FF2A55"),
    })

    local selectedPlayer = nil
    local activeSpectate = false

    local function getPlayerNames()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(list, p.Name)
            end
        end
        if #list == 0 then table.insert(list, "No other players") end
        return list
    end

    local function getPlayerRace(plr)
        local r = "Human"
        pcall(function()
            if plr.Character and plr.Character:GetAttribute("Race") then
                r = tostring(plr.Character:GetAttribute("Race"))
            elseif plr:FindFirstChild("Data") and plr.Data:FindFirstChild("Race") then
                r = tostring(plr.Data.Race.Value)
            end
        end)
        return r
    end

    local function getPlayerTool(plr)
        local tName = "None"
        pcall(function()
            if plr.Character then
                local tool = plr.Character:FindFirstChildOfClass("Tool")
                if tool then tName = tool.Name end
            end
            if tName == "None" and plr:FindFirstChild("Backpack") then
                local bTool = plr.Backpack:FindFirstChildOfClass("Tool")
                if bTool then tName = bTool.Name end
            end
        end)
        return tName
    end

    local function getPlayerDistance(plr)
        local d = 0
        pcall(function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                d = math.floor((plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude + 0.5)
            end
        end)
        return d
    end

    local function getPlayerHealth(plr)
        local hp, maxHp = 0, 100
        pcall(function()
            if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                hp = math.floor(hum.Health + 0.5)
                maxHp = math.floor(hum.MaxHealth + 0.5)
            end
        end)
        return hp, maxHp
    end

    -- 1. Selection Section
    local PlayerSection = Tab:Section({
        Title = "Server Players & Target Info",
        Opened = true,
    })

    local TargetInfoPara = PlayerSection:Paragraph({
        Title = "Target: None Selected",
        Desc = "Select a player from the dropdown to interact.",
        Image = "solar:user-hand-up-bold",
        Color = Color3.fromHex("#FF2A55"),
    })

    local function updateParagraph(para, title, desc)
        if not para then return end
        pcall(function()
            if para.SetTitle then para:SetTitle(title) end
            if para.SetDesc then para:SetDesc(desc) end
            if para.ParagraphFrame and para.ParagraphFrame.UIElements then
                local ui = para.ParagraphFrame.UIElements
                if ui.Title and title then ui.Title.Text = title end
                if ui.Desc and desc then ui.Desc.Text = desc ui.Desc.Visible = true end
            end
        end)
    end

    local function refreshTargetDisplay()
        if not selectedPlayer or not selectedPlayer.Parent then
            updateParagraph(TargetInfoPara, "Target: None Selected", "Select a player from the dropdown to interact.")
            return
        end

        local hp, maxHp = getPlayerHealth(selectedPlayer)
        local dist = getPlayerDistance(selectedPlayer)
        local race = getPlayerRace(selectedPlayer)
        local tool = getPlayerTool(selectedPlayer)
        local team = selectedPlayer.Team and selectedPlayer.Team.Name or "None"
        local isBl = AimbotCore and AimbotCore.isPlayerExplicitlyBlacklisted and AimbotCore.isPlayerExplicitlyBlacklisted(selectedPlayer)

        local title = string.format("Target: %s (@%s)", selectedPlayer.DisplayName, selectedPlayer.Name)
        local desc = string.format("HP: %d/%d  •  Dist: %d studs  •  Team: %s\nRace: %s  •  Tool: %s  •  Blacklisted: %s",
            hp, maxHp, dist, team, race, tool, isBl and "YES" or "NO"
        )
        updateParagraph(TargetInfoPara, title, desc)
    end

    local initialNames = getPlayerNames()
    if #initialNames > 0 and initialNames[1] ~= "No other players" then
        selectedPlayer = Players:FindFirstChild(initialNames[1])
    end

    local PlayerDropdown = PlayerSection:Dropdown({
        Title = "Select Player",
        Desc = "Choose a player in the current server",
        Values = initialNames,
        Value = initialNames[1] or "No other players",
        Callback = function(chosenName)
            local p = Players:FindFirstChild(chosenName)
            if p then
                selectedPlayer = p
                refreshTargetDisplay()
            end
        end,
    })

    PlayerSection:Space()

    PlayerSection:Button({
        Title = "🔄 Refresh Players List",
        Desc = "Update list with recently joined players",
        Callback = function()
            local updated = getPlayerNames()
            if PlayerDropdown and PlayerDropdown.SetValues then
                PlayerDropdown:SetValues(updated)
            end
            if WindUI then
                WindUI:Notify({
                    Title = "Players",
                    Content = "Player list refreshed (" .. tostring(#updated) .. " found)",
                    Duration = 2,
                    Icon = "solar:refresh-bold",
                })
            end
        end,
    })

    Tab:Space()

    -- 2. Player Actions
    local ActionsSection = Tab:Section({
        Title = "Target Actions",
        Opened = true,
    })

    local ActionsGroup = ActionsSection:Group({})

    ActionsGroup:Button({
        Title = "👁 Spectate Target",
        Desc = "Toggle camera view to follow player",
        Callback = function()
            local cam = Workspace.CurrentCamera
            if not cam then return end
            if activeSpectate then
                activeSpectate = false
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    cam.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                end
                if WindUI then
                    WindUI:Notify({
                        Title = "Spectate",
                        Content = "Returned camera to LocalPlayer",
                        Duration = 2,
                    })
                end
            else
                if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    activeSpectate = true
                    cam.CameraSubject = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if WindUI then
                        WindUI:Notify({
                            Title = "Spectate",
                            Content = "Now spectating " .. selectedPlayer.DisplayName,
                            Duration = 2,
                            Icon = "solar:eye-bold",
                        })
                    end
                end
            end
        end,
    })

    ActionsGroup:Space()

    ActionsGroup:Button({
        Title = "🚀 Tween To Target",
        Desc = "Smoothly teleport behind selected player",
        Callback = function()
            if not selectedPlayer or not selectedPlayer.Character then return end
            local targetHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            local lpHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP and lpHRP then
                local dist = (targetHRP.Position - lpHRP.Position).Magnitude
                local speed = 250
                local dur = math.clamp(dist / speed, 0.3, 8)
                TweenService:Create(lpHRP, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
                    CFrame = targetHRP.CFrame + Vector3.new(0, 4, 0)
                }):Play()
                if WindUI then
                    WindUI:Notify({
                        Title = "Teleport",
                        Content = "Tweening to " .. selectedPlayer.DisplayName .. " (" .. string.format("%.1fs", dur) .. ")",
                        Duration = 2.5,
                        Icon = "solar:square-transfer-horizontal-bold",
                    })
                end
            end
        end,
    })

    ActionsGroup:Space()

    ActionsGroup:Button({
        Title = "🚫 Toggle Blacklist",
        Desc = "Exclude / Include target in Aimbot targeting",
        Callback = function()
            if not selectedPlayer then return end
            if AimbotCore and AimbotCore.setPlayerBlacklisted then
                local currentlyBl = AimbotCore.isPlayerExplicitlyBlacklisted and AimbotCore.isPlayerExplicitlyBlacklisted(selectedPlayer)
                local newState = not currentlyBl
                AimbotCore.setPlayerBlacklisted(selectedPlayer, newState)
                refreshTargetDisplay()
                if WindUI then
                    WindUI:Notify({
                        Title = "Blacklist",
                        Content = (newState and "Blacklisted " or "Unblacklisted ") .. selectedPlayer.DisplayName,
                        Duration = 2,
                        Icon = newState and "solar:forbidden-circle-bold" or "solar:check-circle-bold",
                    })
                end
            end
        end,
    })

    ActionsGroup:Space()

    ActionsGroup:Button({
        Title = "✨ Highlight Target",
        Desc = "Add luminous outline around player character",
        Callback = function()
            if not selectedPlayer or not selectedPlayer.Character then return end
            local char = selectedPlayer.Character
            local existing = char:FindFirstChild("Darling_TargetHighlight")
            if existing then
                existing:Destroy()
                if WindUI then
                    WindUI:Notify({
                        Title = "Highlight",
                        Content = "Removed highlight from " .. selectedPlayer.DisplayName,
                        Duration = 2,
                    })
                end
            else
                local hl = Instance.new("Highlight")
                hl.Name = "Darling_TargetHighlight"
                hl.FillColor = Color3.fromHex("#FF2A55")
                hl.OutlineColor = Color3.fromHex("#FFFFFF")
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0
                hl.Parent = char
                if WindUI then
                    WindUI:Notify({
                        Title = "Highlight",
                        Content = "Highlight applied to " .. selectedPlayer.DisplayName,
                        Duration = 2,
                        Icon = "solar:star-bold",
                    })
                end
            end
        end,
    })

    refreshTargetDisplay()

    return Tab
end

return PlayersTabMod
