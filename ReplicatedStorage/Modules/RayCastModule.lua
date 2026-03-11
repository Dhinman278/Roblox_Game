local RaycastModule = {}

function RaycastModule.RaycastFromPlayer(player, range)
	local char = player.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {char}

	local direction = root.CFrame.LookVector * range

	return workspace:Raycast(root.Position, direction, params)
end

return RaycastModule
