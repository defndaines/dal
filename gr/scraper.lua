local scraper = {}
--[[
  Install libraries:
    luarocks install luasocket
    luarocks install luasec

  https://www.goodreads.com/book/show/<book-id>
]]

local https = require("ssl.https")
local ltn12 = require("ltn12")
local parser = require("parser")

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

function scraper.audit_book(orig)
	html, err = fetch_url(orig.url)

	if not html then
		return nil, "Book page fetch error: " .. err
	end

	local book = parser.book_details(html)
	book.url = book_url

	if book.title ~= orig.title then
		print("INFO:", "original title '" .. orig.title .. "' differs from '" .. book.title .. "'")
	end

	book.title = orig.title

	if book.author ~= orig.author then
		print("INFO:", "original author '" .. orig.author .. "' differs from " .. book.author)
	end

	if book.author_link then
		html, err = fetch_url(book.author_link)

		if html then
			book.country = parser.author_details(html)
		end
		-- https://en.wikipedia.org/w/index.php?search=Author+Name ???
	end

	-- https://app.thestorygraph.com/browse?search_term= ???

	return book
end

function scraper.get_book_info(title, author)
	local s_title = title:gsub("%p", " ")
	local s_author = author:gsub("%s*%([^)]*%)", ""):gsub("%p", " ")
	local query = urlencode(s_title .. " " .. s_author)
	local search_url = "https://www.goodreads.com/search?q=" .. query

	local html, err
	html, err = fetch_url(search_url)

	if not html then
		return nil, "Search fetch error: " .. err
	end

	-- print(search_url)
	-- local file = io.open("spec/" .. (title:gsub("%s", "-")) .. "-search.html", "w")
	-- file:write(html)
	-- file:close()

	local book_url = parser.book_link(html, title, author)

	if not book_url then
		return nil, "Book link not found."
	end

	html, err = fetch_url(book_url)

	if not html then
		return nil, "Book page fetch error: " .. err
	end

	-- local file = io.open("spec/" .. (title:gsub("%s", "-")) .. ".html", "w")
	-- file:write(html)
	-- file:close()

	local book = parser.book_details(html)
	book.url = book_url

	if book.title ~= title then
		print("INFO:", "original title '" .. title .. "' differs from " .. book.title)
	end

	book.title = title

	if book.author ~= author then
		print("INFO:", "original author '" .. author .. "' differs from " .. book.author)
	end

	if book.author_link then
		html, err = fetch_url(book.author_link)

		if html then
			book.country = parser.author_details(html)
		end
		-- https://en.wikipedia.org/w/index.php?search=Author+Name ???
	end

	return book
end

return scraper
