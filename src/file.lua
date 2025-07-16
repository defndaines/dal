-- To write to a file
local data = ""
local file = io.open("path/file.txt", "w")
file:write(data)
file:close()

-- To read from a file
file = io.open("path/file.txt", "r")
local content = file:read("*a")
file:close()

assert(content)
