local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local hitRemote = Remotes:WaitForChild("FireHitbox")

local attacking = false

local function fireM1()
	if attacking then return end
	attacking = true

	local controlHeld = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
	hitRemote:FireServer(controlHeld)

	task.delay(0.15, function()
		attacking = false
	end)
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		fireM1()
	end
end)
