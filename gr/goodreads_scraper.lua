local scraper = require("scraper")
local data = require("data")
local overdrive = require("overdrive")
local libro = require("libro")
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
		local has_audio = false
		local has_libro = false
		local has_audible = false

		for _, tag in ipairs(book.tags) do
			if tag == "[audio available]" then
				has_audio = true
			elseif tag == "[Libro]" then
				has_libro = true
			elseif tag == "[Audible]" then
				has_audible = true
			end
		end

		if not has_audio then
			local audiobook = overdrive.search_libraries(info.title, info.author)

			if audiobook then
				book.hours = audiobook.duration

				if audiobook.awards then
					for _, award in ipairs(audiobook.awards) do
						book.tags[#book.tags + 1] = award
					end
				end
			else
				if not has_libro then
					audiobook = libro.search(book.title, book.author)

					if audiobook then
						book.hours = audiobook.hours
						book.tags[#book.tags + 1] = "[Libro]"
						book.url = book.url .. " ; " .. audiobook.libro
					end
				end

				if not has_audible then
					audiobook = audible.search(info.title, info.author)

					if audiobook and audiobook.hours then
						book.hours = audiobook.hours
						book.tags[#book.tags + 1] = "[Audible]"
						book.url = book.url .. " ; " .. audiobook.audible
					end
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
