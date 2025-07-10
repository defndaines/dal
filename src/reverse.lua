-- Listing 24.4, Reversing a file in event-driven fashion.

local lib = require("async-lib")

local t = {}
local input = io.input()
local output = io.output()
local i

local function putline()
	i = i - 1

	if i == 0 then
		lib.stop()
	else
		lib.writeline(output, t[i] .. "\n", putline)
	end
end

local function getline(line)
	if line then
		t[#t + 1] = line
		lib.readline(input, getline)
	else
		i = #t + 1
		putline()
	end
end

lib.readline(input, getline)
lib.runloop()
