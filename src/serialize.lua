function serialize(o)
	local t = type(o)
	if t == "number" or t == "string" or t == "boolean" or t == "nil" then
		io.write(string.format("%q", o))
	elseif t == "table" then
		io.write("{\n")

		for k, v in pairs(o) do
			io.write(" ", k, " = ")
			serialize(v)
			io.write(",\n")
		end

		io.write("}\n")
	end
end

-- quoting arbitrary literal strings
function quote(s)
	-- find maximum length of sequence of equal signs
	local n = -1

	for w in string.gmatch(s, "]-*%f[%]]") do
		n = math.max(n, #w - 1) -- -1 to remove the ']'
	end

	-- produce a string with 'n' plus one equal signs
	local eq = string.rep("=", n + 1)

	-- build quoted string
	return string.format(" [%s[\n%s]%s] ", eq, s, eq)
end
