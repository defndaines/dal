#!/usr/bin/env lua

local scraper = require("scraper")
local data = require("data")
local overdrive = require("overdrive")

local book, err = scraper.get_book_info(arg[1], arg[2], true)

if book then
	local audiobook = overdrive.search(book.title, book.author)

	if audiobook then
		book.hours = audiobook.duration
		if audiobook.awards then
			for _, award in ipairs(audiobook.awards) do
				book.tags[#book.tags + 1] = award
			end
		end
	end

	print(data.output(book))
else
	print("ERROR:", err)
end
