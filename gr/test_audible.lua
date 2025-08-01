local audible = require("audible")

-- Find link from search results

local title = "The Will of the Many"
local author = "James Islington"

local file = io.open("spec/The-Will-of-the-Many-search.html", "r")
local search_html = file:read("*a")
file:close()

local link = audible.find_link(search_html, title, author)
assert(link == "/Will-Many-Hierarchy-Book/dp/B0BXTVJK3Q/", "link not found, " .. (link or "nil"))

-- Parse the duration

file = io.open("spec/The-Will-of-the-Many.html", "r")
local html = file:read("*a")
file:close()

local duration = audible.find_duration(html)
assert(duration == "28:14", "duration not found, " .. (duration or "nil"))

-- Find link when author is not the first person listed

title = "Emergency Skin"
author = "N. K. Jemisin"
file = io.open("spec/Emergency-Skin-search.html", "r")
search_html = file:read("*a")
file:close()

link = audible.find_link(search_html, title, author)
assert(link == "/Emergency-Skin-N-K-Jemisin-audiobook/dp/B07X7HG6GW/", "link not found, " .. (link or "nil"))

-- Parse single-digit durations

file = io.open("spec/Emergency-Skin.html", "r")
html = file:read("*a")
file:close()

duration = audible.find_duration(html)
assert(duration == "01:04", "duration not found, " .. (duration or "nil"))

-- Audiobook not found

title = "Imperfect Victims: Criminalized Survivors and the Promise of Abolition Feminism"
author = "Leigh Goodmark"
file = io.open("spec/Imperfect-Victims.html", "r")
search_html = file:read("*a")
file:close()

link = audible.find_link(search_html, title, author)
assert(not link)
