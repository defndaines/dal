-- Listing 24.5, Running synchronous code on top of asynchronous library.

local lib = require("async-lib")

function run(code)
	local co = coroutine.wrap(function()
		code()
		lib.stop()
	end)

	co()
	lib.runloop()
end

function putline(stream, line)
	local co = coroutine.running()

	local callback = function()
		coroutine.resume(co)
	end

	lib.writeline(stream, line, callback)
	coroutine.yield()
end

function getline(stream, line)
	local co = coroutine.running()

	local callback = function(l)
		coroutine.resume(co, l)
	end

	lib.readline(stream, callback)
	local line = coroutine.yield()
	return line
end

run(function()
	local t = {}
	local input = io.input()
	local output = io.output()

	while true do
		local line = getline(input)

		if not line then
			break
		end

		t[#t + 1] = line
	end

	for i = #t, 1, -1 do
		putline(output, t[i] .. "\n")
	end
end)
