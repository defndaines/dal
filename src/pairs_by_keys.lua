--[[
  Iterator which traverses a table by the keys in order.

  for name, line in pairs_by_keys(lines) do
    print(name, line)
  end
]]
function pairs_by_keys(t, f)
	local a = {}

	for n in pairs(t) do
		a[#a + 1] = n
	end

	-- Note that if `f` is `nil`, it sorts by natural ordering.
	table.sort(a, f)
	local i = 0

	return function()
		i = i + 1
		return a[i], t[a[i]]
	end
end
