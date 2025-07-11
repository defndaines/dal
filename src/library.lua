-- Library Functions
-- i.e., functions I expect to reuse (like in exercism)

local function todigits(n)
	local digits = {}

	while n > 0 do
		table.insert(digits, 1, n % 10)
		n = math.floor(n / 10)
	end

	return digits
end

return todigits
