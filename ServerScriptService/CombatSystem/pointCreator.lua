local function SetupAttachments(character)
	-- Robust wait for R6 limbs
	local lArm = character:WaitForChild("Left Arm", 5)
	local rArm = character:WaitForChild("Right Arm", 5)

	local function createPoints(arm)
		if not arm then return end
		-- Clean up existing points to avoid duplicates if script runs twice
		for _, child in ipairs(arm:GetChildren()) do
			if child.Name == "DmgPoint" then child:Destroy() end
		end

		for i = -1, 1, 0.2 do
			local attachment = Instance.new("Attachment")
			attachment.Name = "DmgPoint"
			attachment.Position = Vector3.new(0, i, 0)
			attachment.Parent = arm
		end
	end

	createPoints(lArm)
	createPoints(rArm)
end

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		-- Wait for character to be parented to Workspace
		if not character.Parent then
			character.AncestryChanged:Wait()
		end
		SetupAttachments(character)
	end)
end)
