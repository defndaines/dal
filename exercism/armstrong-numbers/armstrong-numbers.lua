local ArmstrongNumbers = {}

function ArmstrongNumbers.is_armstrong_number(number)
	local string = tostring(number)
	local sum = 0

	for digit in string:gmatch("%d") do
		sum = sum + tonumber(digit) ^ #string
	end

	return number == sum
end

return ArmstrongNumbers
