local x = os.clock()
local s = 0
for i = 1, 10000000 do s = s + i end
print(string.format("elapsed time: %.2f\n", os.clock() - x))
