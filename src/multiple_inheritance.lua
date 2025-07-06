local function search(k, plist)
	for i = 1, #plist do
		local v = plist[i][k]

		if v then
			return v
		end
	end
end

function create_class(...)
	local c = {}
	local parents = { ... }

	setmetatable(c, {
		__index = function(t, k)
			-- cache prototype calls to improve performance
			local v = search(k, parents)
			t[k] = v
			return v
		end,
	})

	c.__index = c

	function c:new(o)
		o = o or {}
		setmetatable(o, c)
		return o
	end

	return c
end
