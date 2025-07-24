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
local data = require("data")

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
	-- local file = io.open("spec/" .. (title:gsub("%s", "-")) .. ".html", "w")
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

	local details = parser.book_details(html)
	details.url = book_url
	details.title = title
	details.author = author

	return details
end

local books = data.parse("../../kiroku/data/audiobooks.md")

local fout = io.open("print.md", "a+")
local info, err

for _, book in pairs(books) do
	print(book.title)

	info, err = get_book_info(book.title, book.author)

	if info then
		fout:write(data.output_book(book, info) .. "\n")
	else
		print("Error: " .. err)
	end

	os.execute("sleep 1")
end

fout:close()
