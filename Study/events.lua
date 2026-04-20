local function playerAdded(player)
	print ("A new player has joined")
	print(player)
end

game.Players.PlayerAdded:Connect(playerAdded)


--[[
this is dbounce meaning we have a cooldown as task.wait 
making a 2 second cooldown before a second touch
]]
local touchpart = game.Workspace.Part

local partIsTouched = false
touchpart.Touched:Connect(function(otherPart)
	if partIsTouched == false then
		partIsTouched = true
		print(otherPart.Name)
		
		task.wait(2)
		partIsTouched = false
	end
end)

local touchpart = game.Workspace.Part

local partIsTouched = false
touchpart.Touched:Connect(function(otherPart)
	if partIsTouched == false then
		partIsTouched = true
		print(otherPart.Name)
        touchpart.BrickColor = BrickColor.new("Dark Brown")
		
		task.wait(2)
		partIsTouched = false
	end
end)



