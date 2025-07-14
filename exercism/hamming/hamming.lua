local Hamming = {}

function Hamming.compute(a, b)
	if #a ~= #b then
		error("strands must be of equal length")
	end

	local distance = 0

	for i = 1, #a do
		if a:byte(i) ~= b:byte(i) then
			distance = distance + 1
		end
	end

	return distance
end

return Hamming
