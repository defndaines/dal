local scraper = require("scraper")
local data = require("data")
local overdrive = require("overdrive")
local audible = require("audible")

local path = "../../kiroku/data/audiobooks.md"
-- local path = "../../kiroku/data/ebooks.md"
-- local path = "../../kiroku/data/printbooks.md"

local books = data.parse(path)
local outfile = "/tmp/" .. path:gsub(".*/", "")
local fout = io.open(outfile, "a+")
local info, err

for _, book in pairs(books) do
	print("  " .. book.title)

	info, err = scraper.audit_book(book)

	if info then
		local has_audio = book.hours or info.hours
		local has_audible = false

		for _, tag in ipairs(book.tags) do
			if tag == "[audio available]" then
				has_audio = true
			elseif tag:sub(1, 8) == "[hoopla]" then
				has_audio = true
			elseif tag:sub(1, 9) == "[Spotify]" then
				has_audio = true
			elseif tag:sub(1, 9) == "[Audible]" then
				has_audio = true
				has_audible = true
			end
		end

		if not has_audio then
			local audiobook = overdrive.search_libraries(info.title, info.author)

			if audiobook then
				book.hours = audiobook.duration
			elseif not has_audible then
				audiobook = audible.search(info.title, info.author)

				if audiobook and audiobook.hours then
					book.hours = audiobook.hours
					book.tags[#book.tags + 1] = "[Audible](" .. audiobook.audible .. ")"
				end
			end
		end

		fout:write(data.output_book(book, info) .. "\n")
	else
		print("ERROR:", err)
	end

	os.execute("sleep 1")
end

fout:close()
