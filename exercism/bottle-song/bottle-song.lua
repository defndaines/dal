local BottleSong = {}

local verse = [[
BEFORE green bottles hanging on the wall,
BEFORE green bottles hanging on the wall,
And if one green bottle should accidentally fall,
There'll be AFTER green bottles hanging on the wall.
]]

local numbers = { "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "Ten", [0] = "no" }

function BottleSong.recite(start_bottles, take_down)
	local song = {}

	for i = start_bottles, start_bottles - take_down + 1, -1 do
		local this = verse:gsub("BEFORE", (numbers[i]:gsub("^%l", string.upper))):gsub("AFTER", numbers[i - 1])

		if i == 1 or i == 2 then
			this = this:gsub("ne green bottles", "ne green bottle")
		end

		table.insert(song, this)
	end

	return table.concat(song, "\n")
end

return BottleSong
