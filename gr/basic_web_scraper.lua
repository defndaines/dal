--[[
  Install libraries:
    luarocks install luasocket
    luarocks install luasec
    luarocks install htmlparser

  https://www.goodreads.com/book/show/<book-id>
]]

local https = require("ssl.https")
local ltn12 = require("ltn12")
local parser = require("parser")

-- Simple URL encoding function
local function urlencode(str)
	return str:gsub("([^%w _%%%-%.~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end):gsub(" ", "+")
end

-- Get HTML content from a URL
local function fetch_url(url)
	local response = {}

	local result, status_code = https.request({
		url = url,
		method = "GET",
		headers = { ["User-Agent"] = "Mozilla/5.0" },
		sink = ltn12.sink.table(response),
	})

	if result and status_code == 200 then
		return table.concat(response)
	else
		return nil, status_code
	end
end

-- Main function
local function get_book_info(title, author)
	local query = urlencode(title .. " " .. author)
	local search_url = "https://www.goodreads.com/search?q=" .. query

	local html, err
	html, err = fetch_url(search_url)

	if not html then
		return nil, "Search fetch error: " .. err
	end

	local file = io.open("spec/" .. (title:gsub("%s", "-")) .. ".html", "w")
	file:write(html)
	file:close()

	local book_url = parser.book_link(html, title, author)

	if not book_url then
		return nil, "Book link not found."
	end

	html, err = fetch_url(book_url)

	if not html then
		return nil, "Book page fetch error: " .. err
	end

	local details = parser.book_details(html)
	details.url = book_url
	details.title = title
	details.author = author

	return details
end

-- Example usage
-- local title = "The Name of the Wind"
-- local author = "Patrick Rothfuss"

-- WTF?!? The search on this fails to parse the first result, which is the book link.
-- local title = "To the Lighthouse"
-- local author = "Virginia Woolf"

-- TODO: This doesn't correctly get https://www.goodreads.com/book/show/7235533-the-way-of-kings
-- local title = "The Way of Kings"
-- local author = "Brandon Sanderson"

-- TODO: AGAIN! Failing to find first (and only) result.
-- local title = "Waste Tide"
-- local author = "Chen Qiufan"

-- TODO: AGAIN! Failing to find first (and only) result.
local title = "Give Me Some Truth"
local author = "Eric Gansworth"

local info, err = get_book_info(title, author)

if info then
	print("Rating: " .. (info.rating or "N/A"))
	print("Number of Ratings: " .. (info.num_ratings or "N/A"))
	print("Pages: " .. (info.num_pages or "N/A"))
	print("Year: " .. (info.year or "N/A"))
	print("Published: " .. (info.published or "N/A"))
	print("Genres: " .. table.concat(info.genres, ", "))
	print("Series: " .. (info.series or "N/A"))
	print("Volume: " .. (info.volume or "N/A"))
	print("URL: " .. info.url)
else
	print("Error: " .. err)
end
