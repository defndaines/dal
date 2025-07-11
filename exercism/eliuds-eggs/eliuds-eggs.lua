local EliudsEggs = {}

function EliudsEggs.egg_count(number)
	local count = 0

	while number > 0 do
		count = count + (number & 1)
		number = number >> 1
	end

	return count
end

return EliudsEggs
