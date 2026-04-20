local myBasePlate = game.Workspace.Baseplate

local function changeTransparency()
	myBasePlate.Transparency = 1
	task.wait(5)
	myBasePlate.Transparency = .5
	task.wait(5)
	myBasePlate.Transparency = 0
	task.wait(5)
end 

changeTransparency()



local function printABC()
print("A")
print("B")
print("C")
end

printABC()
printABC()
printABC()

local function printoneplusOne()
print(1 + 1)
end

printoneplusOne()