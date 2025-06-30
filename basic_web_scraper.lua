--[[
  Install libraries:
    luarocks install luasocket
    luarocks install luasec
    luarocks install htmlparser
]]

local https = require("ssl.https")
local ltn12 = require("ltn12")
local htmlparser = require("htmlparser")
htmlparser_looplimit = 10000

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
		headers = {
			["User-Agent"] = "Mozilla/5.0",
		},
		sink = ltn12.sink.table(response),
	})

	if result and status_code == 200 then
		return table.concat(response)
	else
		return nil, status_code
	end
end

-- Extract first book link from search results
local function extract_book_link(html, title)
	local tree = htmlparser.parse(html)
	local links = tree:select("a.bookTitle")

	for _, link in ipairs(links) do
		-- First node is a <span> containing the name of the book.
		if link.nodes[1]:getcontent():match("^" .. title) then
			return "https://www.goodreads.com" .. link.attributes["href"]:gsub("?.*", "")
		end
	end
end

-- Extract details from a book page
local function extract_book_details(html)
	local details = {}

	details.rating = html:match('itemprop="ratingValue"%s*>%s*(.-)%s*<')
	details.num_ratings = html:match("([%d,]+)%s+ratings")
	details.num_pages = html:match("(%d+)%s+pages")
	details.genres = {}

	for genre in html:gmatch('genreName">([^<]+)</a>') do
		table.insert(details.genres, genre)
	end

	return details
end

-- Main function
local function get_book_info(title, author)
	local details = {}
	local tree = htmlparser.parse(html)

	local ratings = tree:select("div.RatingStatistics__rating")
	print(#ratings)
	details.rating = ratings[1]:getcontent()

	-- details.rating = html:match('itemprop="ratingValue"%s*>%s*(.-)%s*<')
	details.num_ratings = html:match("([%d,]+)%s+ratings")
	details.num_pages = html:match("(%d+)%s+pages")

	genres = {}
	for i, genre in ipairs(tree:select("div.BookPageMetadataSection__genres a")) do
		genres[i] = genre.nodes[1]:getcontent():lower()
	end

	details.genres = genres

	-- TODO: Collect where it is in a series. Confidence in ratings past first is lower. "Series"
	-- TODO: Check awards. Remove nominations, just want wins. "Literary awards"
	-- TODO: Author pages sometimes include "Born" field, worth capturing?
	-- TODO: If there is a setting, extract it. "Setting"

	--[[
  TODO: Extract the first published year? "First published" over "Published"
    <div class="FeaturedDetails">
      <p data-testid="pagesFormat">662 pages, Hardcover</p>
      <p data-testid="publicationInfo">First published March 27, 2007</p>
    </div>
  ]]

	return details
end

-- Example usage
local title = "The Name of the Wind"
local author = "Patrick Rothfuss"
-- local title = "To the Lighthouse"
-- local author = "Virginia Woolf"

local info, err = get_book_info(title, author)
if info then
	print("Rating: " .. (info.rating or "N/A"))
	print("Number of Ratings: " .. (info.num_ratings or "N/A"))
	print("Pages: " .. (info.num_pages or "N/A"))
	print("Genres: " .. table.concat(info.genres, ", "))
	print("URL: " .. info.url)
else
	print("Error: " .. err)
end
