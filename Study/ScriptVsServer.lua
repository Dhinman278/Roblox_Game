-- this code is to show the difference between localscripts and regular scripts
--This code is placed in a local script
local part = game.Workspace:WaitForChild("Blaster")

part.Touched:Connect(function()
	part.BrickColor = BrickColor.new("Bright red")
end)
