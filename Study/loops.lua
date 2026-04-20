for mycounter = 1, 5, 1 do
	print ("statement 1")
	print ("statement 2")
	print ("statement 3")
	if mycounter == 2 then
		continue
	end
	
	if mycounter == 3 then
		break
	end
end

local myWhileCounter = 1

while myWhileCounter <= 5 do
	print(1)
	print(2)
	print(3)
	myWhileCounter += 1
end