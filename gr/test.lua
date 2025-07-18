local parser = require("parser")

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

-- TODO: Currently Fails. See https://github.com/msva/lua-htmlparser/issues/67

--[[
local file = io.open("spec/lighthouse.html", "r")
local search_html = file:read("*a")
file:close()

local title = "To the Lighthouse"
local author = "Virginia Woolf"
local book_link = parser.book_link(search_html, title, author)

assert(
	"https://www.goodreads.com/book/show/200822229-to-the-lighthouse" == book_link,
	"Incorrect book link: " .. book_link
)
]]

-- Test Extracting Book Details
file = io.open("spec/book.html", "r")
local book_html = file:read("*a")
file:close()

local details = parser.book_details(book_html)

assert(details.id == "186074", "id was '" .. details.id .. "'")
assert(details.rating == "4.52", "rating was '" .. details.rating .. "'")
assert(details.num_ratings == "1049174", "num_ratings was '" .. details.num_ratings .. "'")
assert(details.num_pages == "662", "num_pages was '" .. details.num_pages .. "'")
assert(details.year == "2007", "year was '" .. details.year .. "'")
assert(details.published == "March 27, 2007", "published was '" .. details.published .. "'")
assert(details.genres[1] == "fantasy", "fantasy genre missing")
assert(details.series == "The Kingkiller Chronicle", "series was '" .. details.series .. "'")
assert(details.volume == "1", "volume was '" .. details.volume .. "'")
