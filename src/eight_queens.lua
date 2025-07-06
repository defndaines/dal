local N = 8 -- board size

-- check whether position (n,c) is free form attacks
local function is_place_ok(a, n, c)
	for i = 1, n - 1 do
		if (a[i] == c) or (a[i] - i == c - n) or (a[i] + i == c + n) then
			return false
		end
	end
	return true
end

-- print a board
local function print_solution(a)
	for i = 1, N do
		for j = 1, N do
			io.write(a[i] == j and "X" or "-", " ")
		end
		io.write("\n")
	end
	io.write("\n")
end

-- add to board 'a' all queens from 'n' to 'N'
local function add_queen(a, n)
	if n > N then
		print_solution(a)
	else
		for c = 1, N do
			if is_place_ok(a, n, c) then
				a[n] = c
				add_queen(a, n + 1)
			end
		end
	end
end

-- run the program
add_queen({}, 1)
