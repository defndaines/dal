local scraper = {}
--[[
  Install libraries:
    luarocks install luasocket
    luarocks install luasec

  https://www.goodreads.com/book/show/<book-id>
]]

local socket = require("socket")
local spider = require("spider")
local parser = require("parser")

local author_cache = {}

-- Goodreads occasionally serves a 200 OK with a degraded/stub page (no
-- primary contributor in the embedded data) instead of a proper error
-- status. Retry those like the 429/503 backoff in fetch_url.py.
local PARSE_RETRY_BACKOFFS = { 3, 8 }

local function fetch_author_country(url)
	if author_cache[url] ~= nil then
		return author_cache[url]
	end
	local html = spider.fetch_url(url)
	local country = html and parser.author_details(html)
	author_cache[url] = country or false
	return country
end

local function fetch_and_parse_book(url)
	local html, err = spider.fetch_url(url)
	if not html then
		return nil, "Book page fetch error: " .. err
	end

	local ok, book = pcall(parser.book_details, html)

	for _, delay in ipairs(PARSE_RETRY_BACKOFFS) do
		if ok then
			break
		end
		io.stderr:write("[scraper] parse error for " .. url .. " (" .. book .. ") — retrying in " .. delay .. "s\n")
		socket.sleep(delay)
		html, err = spider.fetch_url(url)
		if not html then
			return nil, "Book page fetch error: " .. err
		end
		ok, book = pcall(parser.book_details, html)
	end

	if not ok then
		return nil, "Book page parse error: " .. book
	end

	return book
end

function scraper.audit_book(orig)
	local gr_url = orig.url:gsub(" ;.*", "")
	local book, err = fetch_and_parse_book(gr_url)

	if not book then
		return nil, err
	end
	book.url = orig.url

	-- if book.title ~= orig.title then
	--     print(
	--         "INFO:",
	--         "original title '" .. (orig.title or "nil") .. "' differs from '" .. (book.title or "nil") .. "'"
	--     )
	-- end

	book.title = orig.title

	-- if book.author ~= orig.author then
	--     print("INFO:", "original author '" .. orig.author .. "' differs from " .. book.author)
	-- end

	if book.author_link and not (orig.country and orig.country ~= "") then
		book.country = fetch_author_country(book.author_link)
		-- https://en.wikipedia.org/w/index.php?search=Author+Name ???
	end

	-- https://app.thestorygraph.com/browse?search_term= ???

	return book
end

function scraper.get_book_info(title, author)
	title = title:gsub("\xe2\x80\x99", "'"):gsub("\xe2\x80\x98", "'")
	local query = spider.urlencode(title)

	local search_url = "https://www.goodreads.com/search?q=" .. query .. "&search%5Bfield%5D=title"

	local html, err
	html, err = spider.fetch_url(search_url)

	if not html then
		return nil, "Search fetch error: " .. err
	end

	-- print(search_url)
	-- local file = io.open("spec/" .. (title:gsub("%s", "-")) .. "-search.html", "w")
	-- file:write(html)
	-- file:close()

	local book_url = parser.book_link(html, title, author)

	if not book_url and author then
		local last_name = (author:match("^[^,]+") or author):match("%S+$")
		local fallback_url = "https://www.goodreads.com/search?q=" .. query .. "+" .. spider.urlencode(last_name)
		html, err = spider.fetch_url(fallback_url)
		if html then
			book_url = parser.book_link(html, title, author)
		end
	end

	if not book_url then
		return nil, "Book link not found."
	end

	local book
	book, err = fetch_and_parse_book(book_url)

	if not book then
		return nil, err
	end
	book.url = book_url

	-- if not is_search and book.title ~= title then
	--     print("INFO:", "original title '" .. title .. "' differs from " .. book.title)
	--     book.title = title
	-- end

	-- if not is_search and book.author ~= author then
	--     print("INFO:", "original author '" .. author .. "' differs from " .. book.author)
	-- end

	if book.author_link then
		book.country = fetch_author_country(book.author_link)
		-- https://en.wikipedia.org/w/index.php?search=Author+Name ???
	end

	return book
end

return scraper
