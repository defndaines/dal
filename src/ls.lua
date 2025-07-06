-- Use popen to grab output stream from command
local f = io.popen("ls", "r") -- "r" is optional, since it is default.
local dir = {}
for entry in f:lines() do
	dir[#dir + 1] = entry
end
