local randomnum = math.random(1, 6)
print(randomnum)


local baseplate = game.Workspace.Baseplate
while true do
	local redVal = math.random(0, 255)
	local greenVal = math.random(0, 255)
	local blueVal = math.random(0, 255)
	local color = Color3.fromRGB(redVal, greenVal, blueVal)
	baseplate.Color = color
	wait(1)
end 