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
local hoopla = require("hoopla")
local audible = require("audible")

local function plausible_duration(hours, pages)
	if not pages or not hours then return true end
	local pages_num = tonumber(pages)
	if not pages_num or pages_num == 0 then return true end
	local h, m = hours:match("(%d+):(%d+)")
	if not h then return true end
	-- Require at least 0.4 minutes per page; typical audiobooks are ~1.5-2 min/page
	return (tonumber(h) * 60 + tonumber(m)) >= pages_num * 0.4
end

local book, err = scraper.get_book_info(arg[1], arg[2])

if book then
	local audiobook = overdrive.search_libraries(book.title, book.author)

	if audiobook and plausible_duration(audiobook.duration, book.pages) then
		book.hours = audiobook.duration

		if audiobook.awards then
			for _, award in ipairs(audiobook.awards) do
				book.tags[#book.tags + 1] = award
			end
		end

		local hooplabook = hoopla.search(book.title, book.author)
		if hooplabook and plausible_duration(hooplabook.hours, book.pages) then
			book.tags[#book.tags + 1] = "[hoopla](" .. hooplabook.hoopla .. ")"
		end
	else
		audiobook = hoopla.search(book.title, book.author)

		if audiobook and plausible_duration(audiobook.hours, book.pages) then
			book.hours = audiobook.hours
			book.tags[#book.tags + 1] = "[hoopla](" .. audiobook.hoopla .. ")"
		else
			audiobook = audible.search(book.title, book.author)

			if audiobook and plausible_duration(audiobook.hours, book.pages) then
				book.hours = audiobook.hours
				book.tags[#book.tags + 1] = "[Audible](" .. audiobook.audible .. ")"
			end
		end
	end

	print(data.output(book))
else
	print("ERROR:", err)
end
