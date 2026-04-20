if 2 + 3 == 4 then
    print(true)

elseif 2 + 6  == 4 then
    print("2 + 2 == 4")

elseif 1 + 1 == 2 then
    print(" 1 + 1 does equal to 2")
    
else 
    print ("the if statement failed!")
end

local function addition(number1, number2)
	local call = number1 + number2
    if call == 3 then
        print("result is 3")
    elseif call == 6 then
        print("result is 6")
    else
        print("we dont know the number")
    end
end

addition(2, 4)
addition(1, 2)
addition(10, 10)