return {
	rotate = function(input, key)
		local upper = ("A"):byte()
		local lower = ("a"):byte()

		return input:gsub("%a", function(ch)
			local byte = ch:byte()
			local offset = byte < lower and upper or lower
			return string.char(offset + ((byte - offset + key) % 26))
		end)
	end,
}
