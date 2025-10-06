#!/usr/bin/env lua

local parser = require("parser")
local data = require("data")

-- Test Extracting Book Title

local file = io.open("spec/search.html", "r")
local search_html = file:read("*a")
file:close()

local title = "The Name of the Wind"
local author = "Patrick Rothfuss"
local book_link = parser.book_link(search_html, title, author)

assert(
	"https://www.goodreads.com/book/show/186074.The_Name_of_the_Wind" == book_link,
	"Incorrect book link: " .. book_link
)

-- More Complicated Book Link

file = io.open("spec/lighthouse.html", "r")
search_html = file:read("*a")
file:close()

title = "To the Lighthouse"
author = "Virginia Woolf"
book_link = parser.book_link(search_html, title, author)

assert(
	-- "https://www.goodreads.com/book/show/59716.To_the_Lighthouse" == book_link,
	"https://www.goodreads.com/book/show/23632005-to-the-lighthouse" == book_link,
	"Incorrect book link: " .. book_link
)

-- Author Name Has Hyphen

file = io.open("spec/City-of-Ash-and-Red.html", "r")
search_html = file:read("*a")
file:close()

title = "City of Ash and Red"
author = "Hye-Young Pyun"
book_link = parser.book_link(search_html, title, author)

assert(
	"https://www.goodreads.com/book/show/39331853-city-of-ash-and-red" == book_link,
	"Incorrect book link: " .. book_link
)

-- Author Name Has Extra Spaces

file = io.open("spec/Remember-You-Will-Die.html", "r")
search_html = file:read("*a")
file:close()

title = "Remember You Will Die"
author = "Eden Robins"
book_link = parser.book_link(search_html, title, author)

assert(
	"https://www.goodreads.com/book/show/203751806-remember-you-will-die" == book_link,
	"Incorrect book link: " .. book_link
)

-- When the Search Title Is WaCkY!
-- -> [(Girl in a Band)] [Author: Kim Gordon] published on (February, 2015)

file = io.open("spec/Girl-in-a-Band.html", "r")
search_html = file:read("*a")
file:close()

title = "Girl in a Band"
author = "Kim Gordon"
book_link = parser.book_link(search_html, title, author)

assert(
	"https://www.goodreads.com/book/show/159719031-girl-in-a-band-author" == book_link,
	"Incorrect book link: " .. book_link
)

-- Fine tuning results

file = io.open("spec/Stalin-search.html", "r")
search_html = file:read("*a")
file:close()

title = "Stalin"
author = "Leon Trotsky"
book_link = parser.book_link(search_html, title, author)

assert("https://www.goodreads.com/book/show/184428.Stalin" == book_link, "Incorrect book link: " .. book_link)

-- Test Extracting Book Details

file = io.open("spec/book.html", "r")
local book_html = file:read("*a")
file:close()

local details = parser.book_details(book_html)

assert(details.id == 186074, "id was '" .. details.id .. "'")
assert(details.rating == 4.52, "rating was '" .. details.rating .. "'")
assert(details.num_ratings == 1062761, "num_ratings was '" .. details.num_ratings .. "'")
assert(details.pages == 662, "pages was '" .. details.pages .. "'")
assert(details.year == "2007", "year was '" .. details.year .. "'")
assert(details.tags[1] == "fantasy", "fantasy genre missing")
assert(details.series == "The Kingkiller Chronicle", "series was '" .. details.series .. "'")
assert(details.volume == "1", "volume was '" .. details.volume .. "'")

-- Test Extracting Author Info
file = io.open("spec/nnedi-okorafor.html", "r")
local author_html = file:read("*a")
file:close()

local country = parser.author_details(author_html)
assert(country == "U.S.", "Nnedi Okorafor’s birthplace: " .. country)

-- Test Another Author
file = io.open("spec/sohn-won-pyung.html", "r")
author_html = file:read("*a")
file:close()

country = parser.author_details(author_html)
assert(country == "South Korea", "Sohn Won-Pyung’s birthplace: " .. country)

-- Test Author with No Birth Info
file = io.open("spec/caitlin-yarsky.html", "r")
author_html = file:read("*a")
file:close()

country = parser.author_details(author_html)
assert(not country, "Caitlin Yarsky’s birthplace: " .. (country or "nil"))

-- Test Series
file = io.open("spec/city-of-stairs.html", "r")
book_html = file:read("*a")
file:close()

details = parser.book_details(book_html)
assert(details.series == "The Divine Cities", "series was '" .. details.series .. "'")
assert(details.volume == "1", "volume was '" .. details.volume .. "'")

-- Test Series with Decimal
file = io.open("spec/after-the-coup.html", "r")
book_html = file:read("*a")
file:close()

details = parser.book_details(book_html)
assert(details.series == "Old Man’s War", "series was '" .. details.series .. "'")
assert(details.volume == "4.5", "volume was '" .. details.volume .. "'")

-- Test Series without Volume
file = io.open("spec/jayber-crow.html", "r")
book_html = file:read("*a")
file:close()

details = parser.book_details(book_html)
assert(details.series == "Port William", "series was '" .. details.series .. "'")
assert(not details.volume, "volume was '" .. (details.volume or "nil") .. "'")

-- Don't Double Print Series Information
local series_re = "the%-stormlight%-archive%-1"
local line = "| The Way of Kings | Brandon Sanderson | 2010 | U.S. | 1007 | 45:30 "
	.. "| fantasy, the-stormlight-archive-1 | 4.67 | 625908 "
	.. "| [7235533](https://www.goodreads.com/book/show/7235533-the-way-of-kings) |"
local book = data.parse_audio_book(line)

file = io.open("spec/The-Way-of-Kings.html", "r")
book_html = file:read("*a")
file:close()

local info = parser.book_details(book_html)
book = data.merge(book, info)
local output = data.output(book)

assert(not output:gsub(series_re, "", 1):match(series_re), "series tag appears more than once")
assert(output == line, "\n" .. output .. "\n does not match\n" .. line)
