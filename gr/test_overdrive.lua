local overdrive = require("overdrive")

-- single result, includes awards

local title = "Stay True"
local author = "Hua Hsu"
local file = io.open("spec/Stay-True-search.html", "r")
local search_html = file:read("*a")
file:close()

local book = overdrive.parse_results(search_html, title, author)

assert(book.title == "Stay True: A Memoir", "Book title does not match: " .. book.title)
assert(book.author == author, "Book author does not match: " .. book.author)
assert(book.duration == "05:29", "Book duration does not match: " .. book.duration)
assert(
	table.concat(book.awards, ", ") == "Pulitzer Prize, National Book Critics Circle Award",
	"Book awards do not match: " .. table.concat(book.awards, ", ")
)

-- multiple results, including unrelated

title = "The Golden Compass"
author = "Philip Pullman"
file = io.open("spec/The-Golden-Compass-search.html", "r")
search_html = file:read("*a")
file:close()

book = overdrive.parse_results(search_html, title, author)

assert(book.title == title, "Book title does not match: " .. book.title)
assert(book.author == author, "Book author does not match: " .. book.author)
assert(book.duration == "13:17", "Book duration does not match: " .. book.duration)
assert(not book.awards)

-- empty results

title = "Hurricane Season"
author = "Fernanda Melchor"
file = io.open("spec/Hurricane-Season-search.html", "r")
search_html = file:read("*a")
file:close()

assert(not overdrive.parse_results(search_html, title, author))

-- 2 results, both are not the book

title = "Project Hail Mary"
author = "Andy Weir"
file = io.open("spec/Project-Hail-Mary-search.html", "r")
search_html = file:read("*a")
file:close()

assert(not overdrive.parse_results(search_html, title, author))

-- duration rolls over the hour

title = "Maeve Fly"
author = "C.J. Leede"
file = io.open("spec/Maeve-Fly.html", "r")
local html = file:read("*a")
file:close()

book = overdrive.parse_results(html, title, author)
assert(book.duration == "08:00", "Book duration does not match: " .. book.duration)

-- False positive

title = "The Princess Bride"
author = "William Goldman"
file = io.open("spec/The-Princess-Bride-search.html", "r")
html = file:read("*a")
file:close()

book = overdrive.parse_results(html, title, author)
assert(not book)

-- No match

title = "Stalin"
author = "Leon Trotsky"
file = io.open("spec/Stalin-overdrive-search.html", "r")
html = file:read("*a")
file:close()

book = overdrive.parse_results(html, title, author)
-- print(book.title, book.author)
assert(not book)

