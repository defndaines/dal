#!/usr/bin/env lua

local scraper = require("scraper")
local data = require("data")

local book, err = scraper.get_book_info(arg[1], arg[2], true)

if book then
	print(data.output(book))
else
	print("ERROR:", err)
end
