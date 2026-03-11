local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local dashRemote = Remotes:WaitForChild("DashRemote")

local player = Players.LocalPlayer

local function getMoveDirection()
	local char = player.Character
	if not char then return Vector3.new(0, 0, 0) end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return Vector3.new(0, 0, 0) end

	local moveDir = hum.MoveDirection
	if moveDir.Magnitude > 0 then
		return moveDir.Unit
	end

	return Vector3.new(0, 0, 0)
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Q then
		dashRemote:FireServer(getMoveDirection())
	end
end)
