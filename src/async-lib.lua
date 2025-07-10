-- Listing 24.3, An ugly implementation of the asynchronous I/O library

local cmd_queue = {}

local lib = {}

function lib.readline(stream, callback)
	local next_cmd = function()
		callback(stream:read())
	end

	table.insert(cmd_queue, next_cmd)
end

function lib.writeline(stream, line, callback)
	local next_cmd = function()
		callback(stream:write(line))
	end

	table.insert(cmd_queue, next_cmd)
end

function lib.stop()
	table.insert(cmd_queue, "stop")
end

function lib.runloop()
	while true do
		local next_cmd = table.remove(cmd_queue, 1)

		if next_cmd == "stop" then
			break
		else
			next_cmd()
		end
	end
end

return lib
