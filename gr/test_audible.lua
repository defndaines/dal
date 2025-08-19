local audible = require("audible")

-- Find link from search results

local title = "The Will of the Many"
local author = "James Islington"

local file = io.open("spec/The-Will-of-the-Many-audible-search.html", "r")
local search_html = file:read("*a")
file:close()

local book = audible.find_link(search_html, title, author)
assert(
	book.audible == "https://www.audible.com/pd/The-Will-of-the-Many-Audiobook/B0BXTL5Y9C",
	"link not found, " .. (book.audible or "nil")
)
assert(book.hours == "28:14", "hours not found, " .. (book.hours or "nil"))

-- Single-digit durations

title = "Emergency Skin"
author = "N. K. Jemisin"
file = io.open("spec/Emergency-Skin-audible-search.html", "r")
search_html = file:read("*a")
file:close()

book = audible.find_link(search_html, title, author)
assert(
	book.audible == "https://www.audible.com/pd/Emergency-Skin-Audiobook/1978650841",
	"link not found, " .. (book.audible or "nil")
)
assert(book.hours == "01:04", "hours not found, " .. (book.hours or "nil"))

-- Audiobook not found

title = "Imperfect Victims: Criminalized Survivors and the Promise of Abolition Feminism"
author = "Leigh Goodmark"
file = io.open("spec/Imperfect-Victims.html", "r")
search_html = file:read("*a")
file:close()

book = audible.find_link(search_html, title, author)
assert(not book)

-- Author with Periods, but also multiple results

title = "Dragon Mage"
author = "M.L. Spencer"
file = io.open("spec/Dragon-Mage-audible-search.html", "r")
search_html = file:read("*a")
file:close()

book = audible.find_link(search_html, title, author)
assert(book.audible == "https://www.audible.com/pd/Dragon-Mage-Audiobook/1039402372")
assert(book.hours == "27:18")

-- Duration with no minutes

title = "The Road to the Salt Sea"
author = "Samuel Kolawole"
file = io.open("spec/The-Road-to-the-Salt-Sea-audible-search.html", "r")
search_html = file:read("*a")
file:close()

book = audible.find_link(search_html, title, author)
assert(book.audible == "https://www.audible.com/pd/The-Road-to-the-Salt-Sea-Audiobook/B0CKNLB7XD")
assert(book.hours == "09:00")
