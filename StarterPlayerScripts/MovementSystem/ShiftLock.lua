local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hum = character:WaitForChild("Humanoid")

local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local SS = game:GetService("SoundService")

local TI = TweenInfo.new(.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

local renderConnection = nil
local shiftLockEnabled = false
local animationDelay = 0.3
local canSprint = true
local isSprinting = false
local isInAir = false
local currentTime = tick()

local activeKeys = {
	W = false,
	A = false,
	S = false,
	D = false,
}

local landingVfxEvent = game.ReplicatedStorage.Events.LandingVFX
local SoundEvent = game.ReplicatedStorage.Events.SoundEvent

local walkAnimation = hum:LoadAnimation(game.ReplicatedStorage.Animations.WalkAnimation)
local runAnimation = hum:LoadAnimation(game.ReplicatedStorage.Animations.RunAnimation)

local function rotateCharacterToCamera()
	local camera = game.Workspace.CurrentCamera
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if rootPart then
		local lookVector = camera.CFrame.LookVector
		local flatLookVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit 
		local targetCFrame = CFrame.new(rootPart.Position, rootPart.Position + flatLookVector)
		rootPart.CFrame = targetCFrame
	end
end

local function tweenOffset(bool)
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if bool then
		UIS.MouseBehavior = Enum.MouseBehavior.LockCenter

		local TG = {CameraOffset = Vector3.new(2,0,0)}
		local tween = TS:Create(character.Humanoid, TI, TG)
		tween:Play()

		if renderConnection then renderConnection:Disconnect() end

		renderConnection = RS.RenderStepped:Connect(function()
			rotateCharacterToCamera()
		end)
	else
		UIS.MouseBehavior = Enum.MouseBehavior.Default

		local TG = {CameraOffset = Vector3.new(0,0,0)}
		local tween = TS:Create(character.Humanoid, TI, TG)
		tween:Play()

		if renderConnection then renderConnection:Disconnect() end
	end
end

local timelimit = 0.3
local lastTimePressed = 0

UIS.InputBegan:Connect(function(input, gps)
	if gps then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		shiftLockEnabled = not shiftLockEnabled
		tweenOffset(shiftLockEnabled)
	end

	if input.KeyCode == Enum.KeyCode.W then
		local currentTime = tick()

		if currentTime - lastTimePressed <= timelimit and canSprint and not isSprinting then
			if walkAnimation.IsPlaying then
				walkAnimation:Stop(animationDelay)
			end
			runAnimation:Play(animationDelay)
			isSprinting = true
		else
			activeKeys.W = true
			if not isSprinting then
				walkAnimation:Play(animationDelay)
			end
		end

		lastTimePressed = currentTime
	elseif input.KeyCode == Enum.KeyCode.A then
		activeKeys.A = true
		if not isSprinting then
			walkAnimation:Play(animationDelay)
		end
	elseif input.KeyCode == Enum.KeyCode.S then 
		activeKeys.S = true
		if not isSprinting then
			walkAnimation:Play(animationDelay)
		end
	elseif input.KeyCode == Enum.KeyCode.D then
		activeKeys.D = true
		if not isSprinting then
			walkAnimation:Play(animationDelay)
		end
	end
end)

UIS.InputEnded:Connect(function(input, gps)
	if gps then return end

	if input.KeyCode == Enum.KeyCode.W then
		activeKeys.W = false
		walkAnimation:Stop(animationDelay)
		if isSprinting then
			runAnimation:Stop(animationDelay)
		end
		isSprinting = false
	elseif input.KeyCode == Enum.KeyCode.A then
		activeKeys.A = false
		walkAnimation:Stop(animationDelay)
	elseif input.KeyCode == Enum.KeyCode.S then
		activeKeys.S = false
		walkAnimation:Stop(animationDelay)
	elseif input.KeyCode == Enum.KeyCode.D then
		activeKeys.D = false
		walkAnimation:Stop(animationDelay)
	end
end)