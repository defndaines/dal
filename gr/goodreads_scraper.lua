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
	print(string.format("%3d", i) .. " " .. book.title)

	info, err = scraper.audit_book(book)

	if info then
		local has_audio = book.hours or info.hours

		if not has_audio then
			local audiobook = overdrive.search_libraries(info.title, info.author)

			if audiobook then
				book.hours = audiobook.duration
			else
				audiobook = audible.search(info.title, info.author)

				if audiobook and audiobook.hours then
					book.hours = audiobook.hours
					book.tags[#book.tags + 1] = "[Audible](" .. audiobook.audible .. ")"
				end
			end
		end

		book = data.merge(book, info)
		fout:write(data.output(book) .. "\n")
		fout:flush()
	else
		print("ERROR:", err)
	end

	socket.sleep(0.2)
end

fout:close()
