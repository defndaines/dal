-- Listing 20.1, A simple module for sets (pg. 187)

local Set = {}
local mt = {}

function Set.new(l)
	local set = {}
	setmetatable(set, mt)

	for _, v in ipairs(l) do
		set[v] = true
	end

	return set
end

function Set.union(a, b)
  -- for a more lucid error when attempting to add non-like types.
  if getmetatable(a) ~= mt or getmetatable(b) ~= mt then
    error("attempt to 'add' a set with a non-set value", 2)
  end

	local result = Set.new({})

	for k in pairs(a) do
		result[k] = true
	end

	for k in pairs(b) do
		result[k] = true
	end

	return result
end

function Set.intersection(a, b)
	local result = Set.new({})

	for k in pairs(a) do
		result[k] = b[k]
	end

	return result
end

function Set.tostring(set)
	local l = {}

	for e in pairs(set) do
		l[#l + 1] = tostring(e)
	end

	return "{" .. table.concat(l, ", ") .. "}"
end

mt.__add = Set.union
mt.__mul = Set.intersection

mt.__le = function(a, b) -- subset
  for k in pairs(a) do
    if not b[k] then return false end
  end

  return true
end

mt.__lt = function(a, b) -- proper subset
  return a <= b and not (b <= a)
end

mt.__eq = function(a, b)
  return a <= b and b <= a
end

mt.__tostring = Set.tostring

return Set
