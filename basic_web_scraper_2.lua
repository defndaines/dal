local https = require("ssl.https")
local ltn12 = require("ltn12")
local htmlparser = require("htmlparser")

local function urlencode(str)
	return str:gsub("([^%w _%%%-%.~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end):gsub(" ", "+")
end

local function fetch_url(url)
	local response = {}
	local _, code = https.request({
		url = url,
		method = "GET",
		headers = {
			["User-Agent"] = "Mozilla/5.0",
		},
		sink = ltn12.sink.table(response),
	})

	if code == 200 then
		return table.concat(response)
	else
		return nil, "HTTP error: " .. tostring(code)
	end
end

local function extract_book_link(html)
	local tree = htmlparser.parse(html)
	local links = tree:select("a.bookTitle")
	if #links > 0 then
		local href = links[1]:attributes().href
		return "https://www.goodreads.com" .. href
	end
	return nil
end

local function trim(str)
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end

local function extract_book_details(html)
	local tree = htmlparser.parse(html)
	local details = {}

	-- Average Rating
	local rating_tag = tree:select("[itemprop=ratingValue]")[1]
	details.rating = rating_tag and trim(rating_tag:getcontent()) or "N/A"

	-- Number of Ratings
	local ratings_span = tree:select("meta[itemprop=ratingCount]")[1]
	details.num_ratings = ratings_span and ratings_span:attributes()["content"] or "N/A"

	-- Number of Pages
	for _, span in ipairs(tree:select("span")) do
		if span:getcontent():match("pages") then
			local num = span:getcontent():match("(%d+)%s+pages")
			if num then
				details.num_pages = num
				break
			end
		end
	end
	details.num_pages = details.num_pages or "N/A"

	-- Genres (grab first 3)
	details.genres = {}
	local genre_tags = tree:select("a.bookPageGenreLink")
	for i = 1, math.min(3, #genre_tags) do
		table.insert(details.genres, trim(genre_tags[i]:getcontent()))
	end

	return details
end

local function get_book_info(title, author)
	local query = urlencode(title .. " " .. author)
	local search_url = "https://www.goodreads.com/search?q=" .. query

	local search_html, err = fetch_url(search_url)
	if not search_html then
		return nil, "Search fetch error: " .. err
	end

	local book_url = extract_book_link(search_html)
	if not book_url then
		return nil, "Book link not found."
	end

	local book_html, err = fetch_url(book_url)
	if not book_html then
		return nil, "Book page fetch error: " .. err
	end

	local details = extract_book_details(book_html)
	details.url = book_url
	return details
end

-- Example Usage
local title = "The Name of the Wind"
local author = "Patrick Rothfuss"

local info, err = get_book_info(title, author)
if info then
	print("Title: " .. title)
	print("Author: " .. author)
	print("Rating: " .. info.rating)
	print("Number of Ratings: " .. info.num_ratings)
	print("Pages: " .. info.num_pages)
	print("Genres: " .. table.concat(info.genres, ", "))
	print("URL: " .. info.url)
else
	print("Error: " .. err)
end
