local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("InputEvent")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hum = character:WaitForChild("Humanoid")
local animator = hum:WaitForChild("Animator")

local walkAnimation = animator:LoadAnimation(ReplicatedStorage.Animations:WaitForChild("WalkAnimation"))
local runAnimation = animator:LoadAnimation(ReplicatedStorage.Animations:WaitForChild("RunAnimation"))
local punchAnimation = animator:LoadAnimation(ReplicatedStorage.Animations:WaitForChild("PunchAnimation"))

local animationDelay = 0.2

local activeKeys = {W=false,A=false,S=false,D=false}
local isSprinting = false

local doubleTapTime = 0.3
local lastWPress = 0

local function isMoving()
	return activeKeys.W or activeKeys.A or activeKeys.S or activeKeys.D
end

local function playWalk()
	if runAnimation.IsPlaying then
		runAnimation:Stop(animationDelay)
	end
	if not walkAnimation.IsPlaying then
		walkAnimation:Play(animationDelay)
	end
end

local function playRun()
	if walkAnimation.IsPlaying then
		walkAnimation:Stop(animationDelay)
	end
	if not runAnimation.IsPlaying then
		runAnimation:Play(animationDelay)
	end
end

local function stopAllMovement()
	walkAnimation:Stop(animationDelay)
	runAnimation:Stop(animationDelay)
end

local function updateMovementAnimation()
	if isMoving() then
		if isSprinting then
			playRun()
		else
			playWalk()
		end
	else
		stopAllMovement()
	end
end

UIS.InputBegan:Connect(function(input, processed)
	if character:GetAttribute("IsStunned") == true then 
		return 
	end
	if processed then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if not punchAnimation.IsPlaying then
			punchAnimation:Play()
			InputEvent:FireServer("Attack")
		end

	elseif input.KeyCode == Enum.KeyCode.F then
		InputEvent:FireServer("Parry")
	end

	if input.KeyCode == Enum.KeyCode.W then
		local now = os.clock()
		activeKeys.W = true

		if (now - lastWPress) <= doubleTapTime then
			if not isSprinting then
				isSprinting = true
				InputEvent:FireServer("StartSprint")
			end
		end

		lastWPress = now

	elseif input.KeyCode == Enum.KeyCode.A then
		activeKeys.A = true

	elseif input.KeyCode == Enum.KeyCode.S then
		activeKeys.S = true

	elseif input.KeyCode == Enum.KeyCode.D then
		activeKeys.D = true
	end

	updateMovementAnimation()
end)

UIS.InputEnded:Connect(function(input, processed)
	if processed then return end

	if input.KeyCode == Enum.KeyCode.F then
		InputEvent:FireServer("BlockEnd")

	elseif input.KeyCode == Enum.KeyCode.W then
		activeKeys.W = false
		if isSprinting then
			isSprinting = false
			InputEvent:FireServer("StopSprint")
		end

	elseif input.KeyCode == Enum.KeyCode.A then
		activeKeys.A = false

	elseif input.KeyCode == Enum.KeyCode.S then
		activeKeys.S = false

	elseif input.KeyCode == Enum.KeyCode.D then
		activeKeys.D = false
	end

	updateMovementAnimation()
end)