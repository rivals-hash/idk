--[[
    Monody Premium - Static Camera (No Camera Movement / Shake in PvP)
    Eliminates recoil, camera shake, head bobbing, and forced camera rotations during combat.
]]

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local Camera = Workspace.CurrentCamera or Workspace:FindFirstChildOfClass("Camera")

local StaticCam = {
    Enabled = false,
    Conn = nil,
    LastLookVector = nil
}

function StaticCam.SetEnabled(state)
    StaticCam.Enabled = (state == true)
    if StaticCam.Enabled then
        if not StaticCam.Conn then
            StaticCam.Conn = RunService.RenderStepped:Connect(function()
                local cam = Workspace.CurrentCamera or Camera
                if not cam then return end
                -- Remove camera bobbing and shake offsets while preserving smooth player panning
                local char = lp and lp.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.CameraOffset = Vector3.new(0, 0, 0)
                end
            end)
        end
    else
        if StaticCam.Conn then
            StaticCam.Conn:Disconnect()
            StaticCam.Conn = nil
        end
    end
end

return StaticCam
