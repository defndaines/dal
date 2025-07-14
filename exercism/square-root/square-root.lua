local SquareRoot = {}

local function square_root(radicand)
	if radicand < 2 then
		return radicand
	end

	local smaller = square_root(radicand >> 2) << 1
	local larger = smaller + 1

	if larger * larger > radicand then
		return smaller
	else
		return larger
	end
end

SquareRoot.square_root = square_root

return SquareRoot
