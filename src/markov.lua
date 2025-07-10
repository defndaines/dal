-- Chapter 19

function all_words()
	local line = io.read()
	local pos = 1

	return function()
		while line do
			local w, e = string.match(line, "(%w+[,;.:“”!?—]?)()", pos)

			if w then
				pos = e
				return w
			else
				line = io.read()
				pos = 1
			end
		end

		return nil
	end
end

function prefix(w1, w2)
	return w1 .. " " .. w2
end

local state = {}

function insert(prefix, value)
	local list = state[prefix]

	if list == nil then
		state[prefix] = { value }
	else
		list[#list + 1] = value
	end
end

local MAX_GEN = 200
local NO_WORD = "\n"

local w1, w2 = NO_WORD, NO_WORD

for next_word in all_words() do
	insert(prefix(w1, w2), next_word)
	w1 = w2
	w2 = next_word
end

insert(prefix(w1, w2), NO_WORD)

w1 = NO_WORD
w2 = NO_WORD

for i = 1, MAX_GEN do
	local list = state[prefix(w1, w2)]
	local r = math.random(#list)
	local next_word = list[r]

	if next_word == NO_WORD then
		return
	end

	io.write(next_word, " ")
	w1 = w2
	w2 = next_word
end
