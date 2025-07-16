local bob = {}

function bob.hey(say)
	if say:match("^%s*$") then
		return "Fine. Be that way!"
	elseif say:match("?$") and say == say:upper() and say:lower() ~= say then
		return "Calm down, I know what I'm doing!"
	elseif say:match("?%s*$") then
		return "Sure."
	elseif say == say:upper() and say:lower() ~= say then
		return "Whoa, chill out!"
	else
		return "Whatever."
	end
end

return bob
