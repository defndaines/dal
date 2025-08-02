local libro = require("libro")

-- Audiobook not found

local title = "Imperfect Victims: Criminalized Survivors and the Promise of Abolition Feminism"
local author = "Leigh Goodmark"

local file = io.open("spec/Imperfect-Victims.html", "r")
local search_html = file:read("*a")
file:close()

local book = libro.find_book(search_html, title, author)
assert(not book)

-- Search result found

title = "Stone Mattress"
author = "Margaret Atwood"
file = io.open("spec/Stone-Mattress-search.html", "r")
search_html = file:read("*a")
file:close()

book = libro.find_book(search_html, title, author)
assert(book.title == title, "title did not match, " .. book.title)
assert(book.author == author, "author did not match, " .. book.author)
assert(book.libro == "https://www.libro.fm/audiobooks/9780553546040-stone-mattress", "URL did not match, " .. book.libro)
assert(book.unabridged, "book is abridged!")
assert(book.hours == "10:01", "hours did not match, " .. book.hours)
