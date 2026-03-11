-- MovementServer.lua
-- Physics-based dash using LinearVelocity (Option A)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- RemoteEvents
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local dashRemote = Remotes:WaitForChild("DashRemote")

-- Modules
local Modules = ReplicatedStorage:WaitForChild("Modules")
local MovementState = require(Modules:WaitForChild("MovementState"))
local CombatState = require(Modules:WaitForChild("CombatState"))

---------------------------------------------------------------------
-- Utility
---------------------------------------------------------------------

local function humanoidAndRoot(char)
	if not char then return nil, nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	return hum, root
end

---------------------------------------------------------------------
-- OPTIONAL: disable ControllerManager to avoid conflicts
---------------------------------------------------------------------

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local cm = char:FindFirstChild("ControllerManager")
		if cm then
			cm:Destroy()
			print("Destroyed ControllerManager for", player.Name)
		end
	end)
end)

---------------------------------------------------------------------
-- DASH CONFIG
---------------------------------------------------------------------

local DASH_SPEED = 75          -- studs per second
local DASH_TIME = 0.20         -- duration in seconds

dashRemote.OnServerEvent:Connect(function(player, moveDir)
	local char = player.Character
	if not char then return end

	local hum, root = humanoidAndRoot(char)
	if not hum or not root or hum.Health <= 0 then return end

	-- camera-based direction so idle dash works
	local camera = Workspace.CurrentCamera
	if not camera then return end

	local camLook = camera.CFrame.LookVector
	local flatCamLook = Vector3.new(camLook.X, 0, camLook.Z)
	if flatCamLook.Magnitude < 0.1 then
		flatCamLook = -root.CFrame.LookVector
	else
		flatCamLook = flatCamLook.Unit
	end

	local dir

	if typeof(moveDir) == "Vector3" and moveDir.Magnitude > 0.1 then
		dir = moveDir.Unit
	else
		-- neutral dash = backward relative to camera
		dir = -flatCamLook
	end

	-- Build dash vector (horizontal only, slight lift if you want)
	local dashVector = dir * DASH_SPEED

	print("DASH: player =", player.Name)
	print("  dir =", dir)
	print("  dashVector =", dashVector)

	-----------------------------------------------------------------
	-- Create a temporary LinearVelocity to own movement
	-----------------------------------------------------------------
	local existing = root:FindFirstChild("DashVelocity")
	if existing then
		existing:Destroy()
	end

	local attachment = root:FindFirstChild("DashAttachment")
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "DashAttachment"
		attachment.Parent = root
	end

	local lv = Instance.new("LinearVelocity")
	lv.Name = "DashVelocity"
	lv.Attachment0 = attachment
	lv.MaxForce = 1e6        -- big enough to beat controller
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.VectorVelocity = dashVector
	lv.Parent = root

	-- Optionally reduce player control slightly during dash
	local oldAutoRotate = hum.AutoRotate
	hum.AutoRotate = false

	-- End dash after DASH_TIME
	task.delay(DASH_TIME, function()
		if lv and lv.Parent then
			lv:Destroy()
		end
		if hum and hum.Parent then
			hum.AutoRotate = oldAutoRotate
		end
	end)
end)

---------------------------------------------------------------------
-- Cleanup
---------------------------------------------------------------------

Players.PlayerRemoving:Connect(function(plr)
	if plr.Character then
		MovementState.Cleanup(plr.Character)
	end
end)
