return function(numbers)
	local function is_multiple(n)
		for _, item in ipairs(numbers) do
			if n % item == 0 then
				return true
			end
		end

		return false
	end

	return {
		to = function(level)
			local sum = 0

			for i = 1, level - 1 do
				if is_multiple(i) then
					sum = sum + i
				end
			end

			return sum
		end,
	}
end
