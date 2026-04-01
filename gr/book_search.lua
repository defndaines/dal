#!/usr/bin/env lua

local script_path = debug.getinfo(1, "S").source:match("^@(.+)$") or "."
local handle = io.popen("realpath '" .. script_path .. "'")
if handle then
	local real = handle:read("*l")
	handle:close()
	if real then script_path = real end
end
local script_dir = script_path:match("^(.+)/[^/]+$") or "."
package.path = script_dir .. "/?.lua;" .. package.path

local scraper = require("scraper")
local data = require("data")
local overdrive = require("overdrive")
local audible = require("audible")

local book, err = scraper.get_book_info(arg[1], arg[2])

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
		audiobook = audible.search(book.title, book.author)

		if audiobook then
			book.hours = audiobook.hours
			book.tags[#book.tags + 1] = "[Audible](" .. audiobook.audible .. ")"
		end
	end

	print(data.output(book))
else
	print("ERROR:", err)
end
