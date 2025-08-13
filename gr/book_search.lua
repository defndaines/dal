#!/usr/bin/env lua

local scraper = require("scraper")
local data = require("data")
local overdrive = require("overdrive")
local libro = require("libro")
local audible = require("audible")

local book, err = scraper.get_book_info(arg[1], arg[2], true)

if book then
	local audiobook = overdrive.search_libraries(book.title, book.author)

	if audiobook then
		book.hours = audiobook.duration
		if audiobook.awards then
			for _, award in ipairs(audiobook.awards) do
				book.tags[#book.tags + 1] = award
			end
		end
	else
		audiobook = libro.search(book.title, book.author)

		if audiobook then
			book.hours = audiobook.hours
			book.tags[#book.tags + 1] = "[Libro]"
			book.url = book.url .. " ; " .. audiobook.libro
		end

		audiobook = audible.search(book.title, book.author)

		if audiobook then
			book.hours = audiobook.hours
			book.tags[#book.tags + 1] = "[Audible]"
			book.url = book.url .. " ; " .. audiobook.audible
		end
	end

	print(data.output(book))
else
	print("ERROR:", err)
end
