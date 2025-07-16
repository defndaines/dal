local a = ("a"):byte()
local z = ("z"):byte()

return {
	encode = function(plaintext)
		local encoded = {}

		plaintext:lower():gsub("%w", function(ch)
			local byte = ch:byte()

			if byte >= a and byte <= z then
				table.insert(encoded, string.char(a + z - byte))
			else
				table.insert(encoded, ch)
			end

			if #encoded % 6 == 0 then
				table.insert(encoded, #encoded, " ")
			end
		end)

		return table.concat(encoded)
	end,
}
