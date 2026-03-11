local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local slideRemote = Remotes:WaitForChild("SlideRemote")

local player = Players.LocalPlayer

-- We assume MovementClient exposes a global function getMoveDirection()
-- If not, I can help you modularize it.
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

	-- Slide on C or LeftControl
	if input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.LeftControl then
		local dir = getMoveDirection()
		slideRemote:FireServer(dir)
	end
end)
