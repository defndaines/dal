local scraper = {}
--[[
  Install libraries:
    luarocks install luasocket
    luarocks install luasec

  https://www.goodreads.com/book/show/<book-id>
]]

local spider = require("spider")
local parser = require("parser")

function scraper.audit_book(orig)
	local gr_url = orig.url:gsub(" ;.*", "")
	local html, err = spider.fetch_url(gr_url)

	if not html then
		return nil, "Book page fetch error: " .. err
	end

	local book = parser.book_details(html)
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

	if book.author_link then
		html = spider.fetch_url(book.author_link)

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
	-- local s_author = author:gsub("%s*%([^)]*%)", ""):gsub("%p", " "):gsub("%s%s+", " ")
	local s_author = author:gsub("%s*%([^)]*%)", ""):gsub("%s%s+", " ")
	local query = spider.urlencode(s_title .. " " .. s_author)
	local search_url = "https://www.goodreads.com/search?q=" .. query

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

	if not book_url then
		return nil, "Book link not found."
	end

	html, err = spider.fetch_url(book_url)

	if not html then
		return nil, "Book page fetch error: " .. err
	end

	-- local file = io.open("spec/" .. (title:gsub("%s", "-")) .. ".html", "w")
	-- file:write(html)
	-- file:close()

	local book = parser.book_details(html)
	book.url = book_url

	-- if not is_search and book.title ~= title then
	--     print("INFO:", "original title '" .. title .. "' differs from " .. book.title)
	--     book.title = title
	-- end

	-- if not is_search and book.author ~= author then
	--     print("INFO:", "original author '" .. author .. "' differs from " .. book.author)
	-- end

	if book.author_link then
		html, err = spider.fetch_url(book.author_link)

		if html then
			book.country = parser.author_details(html)
		else
			print("WARNING:", err)
		end
		-- https://en.wikipedia.org/w/index.php?search=Author+Name ???
	end

	return book
end

return scraper
