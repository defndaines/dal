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

-- Prefer the canonical book over a wacky-titled listing with few ratings

file = io.open("spec/Girl-in-a-Band.html", "r")
search_html = file:read("*a")
file:close()

title = "Girl in a Band"
author = "Kim Gordon"
book_link = parser.book_link(search_html, title, author)

assert(
	"https://www.goodreads.com/book/show/144105269-girl-in-a-band" == book_link,
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

-- New React search layout (div.Book)

file = io.open("spec/Samurai-and-the-Prisoner-search.html", "r")
search_html = file:read("*a")
file:close()

title = "The Samurai and the Prisoner"
author = "Honobu Yonezawa"
book_link = parser.book_link(search_html, title, author)

assert("https://www.goodreads.com/book/show/64007884" == book_link, "Incorrect book link: " .. tostring(book_link))
