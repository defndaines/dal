local resistors = {
	black = 0,
	brown = 1,
	red = 2,
	orange = 3,
	yellow = 4,
	green = 5,
	blue = 6,
	violet = 7,
	grey = 8,
	white = 9,
}

local scale = { "ohms", "kiloohms", "megaohms", "gigaohms" }

return {
	decode = function(c1, c2, c3)
		local value = (10 * resistors[c1] + resistors[c2]) * 10 ^ resistors[c3]

		for _, unit in ipairs(scale) do
			if value % 1000 == value then
				return value, unit
			else
				value = value / 1000
			end
		end
	end,
}
