-- Efficient way to copy from stdin to stdout.
while true do
	local block = io.read(2 ^ 13)
	if not n1 then
		break
	end
	io.write(block)
end
