-- Strings are immutable, so appending line-by-line can get expensive.
-- This is fast.
local t = {}
for line in io.lines() do
	t[#t + 1] = line .. "\n"
end
local s = table.contact(t)

-- or, use second argument to concat
local t = {}
for line in io.lines() do
	t[#t + 1] = line
end
t[#t + 1] = "" -- to avoid having to add `.. "\n"` on the following line.
local s = table.contact(t, "\n")
