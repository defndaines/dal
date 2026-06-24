-- luarocks install luasocket

local scraper = require("scraper")
local data = require("data")
local overdrive = require("overdrive")
local hoopla = require("hoopla")
local audible = require("audible")
local socket = require("socket")

local search_hoopla = false
for _, a in ipairs(arg or {}) do
	if a == "--hoopla" then search_hoopla = true end
end

-- local path = "../../kiroku/data/audiobooks.md"
local path = "../../kiroku/data/eyebooks.md"

local books = data.parse(path)
local outfile = "/tmp/" .. path:gsub(".*/", "")
local info, err

local resume_from = 1
local fcheck = io.open(outfile, "r")
if fcheck then
	local last_title
	for line in fcheck:lines() do
		local title = line:match("^| (.-) |")
		if title and title ~= "title" and not title:find("^[%- :]+$") then
			last_title = title
		end
	end
	fcheck:close()
	if last_title then
		for i, book in ipairs(books) do
			if book.title == last_title then
				resume_from = i + 1
				break
			end
		end
		print("Resuming from book " .. resume_from .. " (after \"" .. last_title .. "\")")
	end
end

local fout = assert(io.open(outfile, resume_from == 1 and "w" or "a"))

if resume_from == 1 then
	if path:find("audio") then
		fout:write("| title | author | year | country | pages | hours | tags | rating | # ratings | goodreads |\n")
		fout:write("| --- | --- | :---: | --- | ---: | ---: | --- | :---: | ---: | --- |\n")
	else
		fout:write("| title | author | year | country | pages | tags | rating | # ratings | goodreads |\n")
		fout:write("| --- | --- | :---: | --- | ---: | --- | :---: | ---: | --- |\n")
	end
end

for i, book in ipairs(books) do
	if i < resume_from then goto continue end

	-- print(string.format("%3d", i) .. " " .. book.title)

	info, err = scraper.audit_book(book)

	if info then
		if tonumber(book.rating) and math.abs(book.rating - (info.rating or book.rating)) > 0.02 then
			print(string.format("%3d", i) .. " " .. book.title .. ", rating: " .. book.rating .. " -> " .. info.rating)
		end

		local has_audio = book.hours or info.hours
		local no_audio = false
		for _, t in ipairs(book.tags) do
			if t == "no-audio" then no_audio = true; break end
		end

		if not has_audio and not no_audio then
			local audiobook = overdrive.search_libraries(info.title, info.author)

			if audiobook then
				book.hours = audiobook.duration
				print(string.format("%3d", i) .. " " .. book.title .. ", new audiobook: " .. book.hours)

				local hooplabook = hoopla.search(info.title, info.author)
				if hooplabook then
					book.tags[#book.tags + 1] = "[hoopla](" .. hooplabook.hoopla .. ")"
					print(string.format("%3d", i) .. " " .. book.title .. ", hoopla: " .. hooplabook.hoopla)
				end
			else
				audiobook = audible.search(info.title, info.author)

				-- Audible will put up the page for upcoming books without the time.
				if audiobook and audiobook.hours ~= "00:00" then
					book.hours = audiobook.hours
					print(string.format("%3d", i) .. " " .. book.title .. ", new Audible: " .. book.hours)
					book.tags[#book.tags + 1] = "[Audible](" .. audiobook.audible .. ")"
				end
			end
		end

		book = data.merge(book, info)

		if search_hoopla and (book.hours or info.hours) and not no_audio then
			local has_hoopla = false
			for _, t in ipairs(book.tags) do
				if t:find("^%[hoopla%]") then has_hoopla = true; break end
			end
			if not has_hoopla then
				local hooplabook = hoopla.search(info.title, info.author)
				if hooplabook then
					book.tags[#book.tags + 1] = "[hoopla](" .. hooplabook.hoopla .. ")"
					print(string.format("%3d", i) .. " " .. book.title .. ", hoopla: " .. hooplabook.hoopla)
				end
			end
		end

		fout:write(data.output(book) .. "\n")
		fout:flush()
	else
		print("ERROR (" .. i .. "):", err)
	end

	socket.sleep(0.2)
	::continue::
end

fout:close()
