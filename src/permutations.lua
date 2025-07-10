-- Listing 24.2, iterator function to generate permutations.

function permgen(a, n)
	n = n or #a

	if n <= 1 then
		coroutine.yield(a)
	else
		for i = 1, n do
			a[n], a[i] = a[i], a[n] -- put i element last
			permgen(a, n - 1) -- permutate all other elements
			a[n], a[i] = a[i], a[n] -- restore i element
		end
	end
end

function print_result(a)
	for i = 1, #a do
		io.write(a[i], " ")
	end

	io.write("\n")
end

function permutations(a)
	--[[ ... without `wrap`.
	local co = coroutine.create(function()
		permgen(a)
	end)

	return function()
		local code, result = coroutine.resume(co)
		return result
	end
	]]

	return coroutine.wrap(function()
		permgen(a)
	end)
end

for p in permutations({ "a", "b", "c" }) do
	print_result(p)
end
