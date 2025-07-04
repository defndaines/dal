-- To create a set
function Set(list)
	local set = {}

	for _, l in ipairs(list) do
		set[l] = true
	end

	return set
end

-- A bag is a frequency-count table
function insert(bag, element)
	bag[element] = (bag[element] or 0) + 1
end

function remove(bag, element)
	local count = bag[element]
	bag[element] = (count and count > 1) and count - 1 or nil
end
