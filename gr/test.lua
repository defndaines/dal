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

local file = io.open("spec/lighthouse.html", "r")
local search_html = file:read("*a")
file:close()

local title = "To the Lighthouse"
local author = "Virginia Woolf"
local book_link = parser.book_link(search_html, title, author)

assert(
	-- "https://www.goodreads.com/book/show/59716.To_the_Lighthouse" == book_link,
	"https://www.goodreads.com/book/show/23632005-to-the-lighthouse" == book_link,
	"Incorrect book link: " .. book_link
)

-- Author Name Has Hyphen

local file = io.open("spec/City-of-Ash-and-Red.html", "r")
local search_html = file:read("*a")
file:close()

local title = "City of Ash and Red"
local author = "Hye-Young Pyun"
local book_link = parser.book_link(search_html, title, author)

assert(
	"https://www.goodreads.com/book/show/39331853-city-of-ash-and-red" == book_link,
	"Incorrect book link: " .. book_link
)

-- Author Name Has Extra Spaces

local file = io.open("spec/Remember-You-Will-Die.html", "r")
local search_html = file:read("*a")
file:close()

local title = "Remember You Will Die"
local author = "Eden Robins"
local book_link = parser.book_link(search_html, title, author)

assert(
	"https://www.goodreads.com/book/show/203751806-remember-you-will-die" == book_link,
	"Incorrect book link: " .. book_link
)

-- When the Search Title Is WaCkY!
--   -> [(Girl in a Band)] [Author: Kim Gordon] published on (February, 2015)

local file = io.open("spec/Girl-in-a-Band.html", "r")
local search_html = file:read("*a")
file:close()

local title = "Girl in a Band"
local author = "Kim Gordon"
local book_link = parser.book_link(search_html, title, author)

assert(
	"https://www.goodreads.com/book/show/159719031-girl-in-a-band-author" == book_link,
	"Incorrect book link: " .. book_link
)

-- Test Extracting Book Details
file = io.open("spec/book.html", "r")
local book_html = file:read("*a")
file:close()

local details = parser.book_details(book_html)

assert(details.id == "186074", "id was '" .. details.id .. "'")
assert(details.rating == "4.52", "rating was '" .. details.rating .. "'")
assert(details.num_ratings == "1049625", "num_ratings was '" .. details.num_ratings .. "'")
assert(details.pages == "662", "pages was '" .. details.pages .. "'")
assert(details.year == "2007", "year was '" .. details.year .. "'")
assert(details.published == "March 27, 2007", "published was '" .. details.published .. "'")
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
local author_html = file:read("*a")
file:close()

country = parser.author_details(author_html)
assert(country == "South Korea", "Sohn Won-Pyung’s birthplace: " .. country)

-- Test Author with No Birth Info
file = io.open("spec/caitlin-yarsky.html", "r")
local author_html = file:read("*a")
file:close()

country = parser.author_details(author_html)
assert(country == nil, "Caitlin Yarsky’s birthplace: " .. (country or "nil"))
