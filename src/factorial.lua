-- defines a factorial function
function fact (n)
  if n <= 0 then
    return 1
  else
    return n * fact(n - 1)
  end
end

print("enter a number:")
a = io.read("*n") -- reads a number
print(fact(a))

--[[
  answers only valid up to 20
  fact(20) ==  2,432,902,008,176,640,000
  fact(21) == 51,090,942,171,709,440,000 ... but -4249290049419214848 is returned
--]]
