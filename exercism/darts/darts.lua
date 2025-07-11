local Darts = {}

function Darts.score(x, y)
	local distance = math.sqrt(x ^ 2 + y ^ 2)

	if distance > 10 then
		return 0
	elseif distance > 5 then
		return 1
	elseif distance > 1 then
		return 5
	else
		return 10
	end
end

return Darts
