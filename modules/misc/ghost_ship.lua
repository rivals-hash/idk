--[[
    Darling Hub - Delete Ghost Ship Suite
    Extracted and optimized from Sacred AHK v12.5.
    Removes interior collision, walls, and decorative models from Cursed Ship in Sea 2
    while preserving outer hull and navigable boundaries.
    Zero emojis, zero third-party references.
]]

local Workspace = game:GetService("Workspace")

local GhostShip = {
    Enabled = false,
    Running = false,
}

local SHIP_NAMES = { "CursedShip", "Cursed Ship", "Ship" }
local EXTERIOR_NAMES = { "Wall", "Floor", "Ceiling", "Base", "Hull", "Window", "DoorFrame" }

function GhostShip.DeleteStructure()
    if not GhostShip.Enabled then return end
    task.spawn(function()
        pcall(function()
            local desc = Workspace:GetDescendants()
            for i = 1, #desc do
                local obj = desc[i]
                if obj and (obj:IsA("Model") or obj:IsA("Folder")) then
                    local matched = false
                    local oName = tostring(obj.Name or "")
                    for _, sName in ipairs(SHIP_NAMES) do
                        if string.find(oName, sName, 1, true) then
                            matched = true
                            break
                        end
                    end

                    if matched then
                        local parts = obj:GetDescendants()
                        for j = 1, #parts do
                            local child = parts[j]
                            if child and child:IsA("BasePart") then
                                local parent = child.Parent
                                local hasHumanoid = parent and parent:FindFirstChildOfClass("Humanoid")
                                if not hasHumanoid then
                                    local isExterior = false
                                    local cName = tostring(child.Name or "")
                                    for _, ext in ipairs(EXTERIOR_NAMES) do
                                        if string.find(cName, ext, 1, true) then
                                            isExterior = true
                                            break
                                        end
                                    end
                                    if not isExterior then
                                        pcall(function() child:Destroy() end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end)
end

function GhostShip.StartLoop()
    if GhostShip.Running then return end
    GhostShip.Running = true
    task.spawn(function()
        while GhostShip.Enabled do
            GhostShip.DeleteStructure()
            task.wait(3)
        end
        GhostShip.Running = false
    end)
end

function GhostShip.SetEnabled(state)
    GhostShip.Enabled = state and true or false
    if GhostShip.Enabled then
        GhostShip.StartLoop()
    end
end

return GhostShip
