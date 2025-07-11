return function(n)
	local rain = { [3] = "Pling", [5] = "Plang", [7] = "Plong" }

	local result = ""

	for _, modulus in ipairs({ 3, 5, 7 }) do
		if n % modulus == 0 then
			result = result .. rain[modulus]
		end
	end

	if result == "" then
		return tostring(n)
	else
		return result
	end
end
