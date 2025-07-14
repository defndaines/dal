return function(s)
	local letters = {}

	for ch in s:lower():gmatch("%l") do
		if letters[ch] then
			return false
		else
			letters[ch] = true
		end
	end

	return true
end
