-- See https://github.com/msva/lua-htmlparser for getting started with this library.

local htmlparser = require("htmlparser")
htmlparser_looplimit = 10000

local function extract_book_link(html, title)
  local tree = htmlparser.parse(html)
  local links = tree:select('a.bookTitle')

	for _, link in ipairs(links) do
    -- First node is a <span> containing the name of the book.
		if link.nodes[1]:getcontent():match("^" .. title) then
			return "https://www.goodreads.com" .. link.attributes["href"]:gsub("?.*", "")
		end
	end
end

local function extract_book_details(html)
  local details = {}
  local tree = htmlparser.parse(html)

  local ratings = tree:select('div.RatingStatistics__rating')
  details.rating = ratings[1]:getcontent()

  details.num_ratings = html:match('([%d,]+)%s+ratings')
  details.num_pages = html:match('(%d+)%s+pages')

  local genres = {}
  for i, genre in ipairs(tree:select('div.BookPageMetadataSection__genres a')) do
    genres[i] = genre.nodes[1]:getcontent():lower()
  end

  details.genres = genres

  return details
end

local html = io.input("book.html"):read("a")

info = extract_book_details(html)
print("Rating: " .. (info.rating or "N/A"))
print("Number of Ratings: " .. (info.num_ratings or "N/A"))
print("Pages: " .. (info.num_pages or "N/A"))
print("Genres: " .. table.concat(info.genres, ", "))
