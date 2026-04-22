local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatEvent = ReplicatedStorage:WaitForChild("CombatEvent")

local player = game.Players.LocalPlayer
local character = script.Parent 
-- FIX: Humanoid is in the Character, not the Player!
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

-- Setup Animation
local punchAnim = Instance.new("Animation")
punchAnim.AnimationId = "rbxassetid://122679000956985"
local punchTrack = animator:LoadAnimation(punchAnim)
punchTrack.Priority = Enum.AnimationPriority.Action4 -- Higher priority

print("Combat Script Loaded Successfully") -- Check your Output for this!

UIS.InputBegan:Connect(function(input, processed, gps)
	if processed then return end
	if gps then return end
	if character:GetAttribute("IsStunned") == true then 
		character.Humanoid.WalkSpeed = 0
		character.Humanoid.JumpPower = 0
		character.Humanoid.JumpHeight = 0
		character.HumanoidRootPart.Anchored = true
		task.delay(2, function() 
			character.HumanoidRootPart.Anchored = false
			character.Humanoid.WalkSpeed = 16
			character.Humanoid.JumpPower = 50
			character.Humanoid.JumpHeight = 7.2 end)
		
	return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		print("Click detected!") -- Debugging
		if not punchTrack.IsPlaying then
			punchTrack:Play()
			CombatEvent:FireServer("Attack")
			processed = true
		end
	elseif input.KeyCode == Enum.KeyCode.F then
		CombatEvent:FireServer("Parry")
	end
end)



UIS.InputEnded:Connect(function(input, gps)
	if gps then return end
	if input.KeyCode == Enum.KeyCode.F then
		CombatEvent:FireServer("BlockEnd")
	end
end)