local scraper = require("scraper")
local data = require("data")
local overdrive = require("overdrive")
local audible = require("audible")
local socket = require("socket")

local path = "../../kiroku/data/audiobooks.md"
-- local path = "../../kiroku/data/ebooks.md"
-- local path = "../../kiroku/data/printbooks.md"

local books = data.parse(path)
local outfile = "/tmp/" .. path:gsub(".*/", "")
local fout = io.open(outfile, "a+")
local info, err

if path:find("audio") then
	fout:write("| title | author | year | country | pages | hours | tags | rating | # ratings | goodreads |\n")
	fout:write("| --- | --- | :---: | --- | ---: | ---: | --- | :---: | ---: | --- |\n")
else
	fout:write("| title | author | year | country | pages | tags | rating | # ratings | goodreads |\n")
	fout:write("| --- | --- | :---: | --- | ---: | --- | :---: | ---: | --- |\n")
end

for i, book in ipairs(books) do
	-- print(string.format("%3d", i) .. " " .. book.title)

	info, err = scraper.audit_book(book)

	if tonumber(book.rating) and math.abs(book.rating - (info.rating or book.rating)) > 0.02 then
		print(string.format("%3d", i) .. " " .. book.title .. ", rating: " .. book.rating .. " -> " .. info.rating)
	end

	if info then
		local has_audio = book.hours or info.hours

		if not has_audio then
			local audiobook = overdrive.search_libraries(info.title, info.author)

			if audiobook then
				book.hours = audiobook.duration
				print(string.format("%3d", i) .. " " .. book.title .. ", new audiobook: " .. book.hours)
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
		fout:write(data.output(book) .. "\n")
		fout:flush()
	else
		print("ERROR (" .. i .. "):", err)
	end

	socket.sleep(0.2)
end

fout:close()
