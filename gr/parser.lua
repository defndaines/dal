local parser = {}

local htmlparser = require("htmlparser")

function parser.book_link(html, title, author)
	local tree = htmlparser.parse(html, 10000)

	local books = tree:select("table tr")

	for _, book in ipairs(books) do
		-- if link.nodes[1]:getcontent():match("^" .. title) then
		--     return "https://www.goodreads.com" .. link.attributes["href"]:gsub("?.*", "")
		-- end
		local book_title = book:select("a.bookTitle")

		if book_title[1].nodes[1]:getcontent():match("^" .. title) then
			print(book_title[1].nodes[1]:getcontent())
			local aut = book:select("a.authorName")
			if aut[1].nodes[1]:getcontent():match(author) then
				print((book_title[1].attributes["href"]:gsub("?.*", "")))
				return "https://www.goodreads.com" .. book_title[1].attributes["href"]:gsub("?.*", "")
			end
		end
	end

	local links = tree:select("a.bookTitle")

	for _, link in ipairs(links) do
		--[[ First node is a <span> containing the name of the book.
		       Goodreads has a lot of junk like "Study Guide" and "Summary of"
		       "books" that are often ahead of the obvious book being searched for.]]
		if link.nodes[1]:getcontent():match("^" .. title) then
			return "https://www.goodreads.com" .. link.attributes["href"]:gsub("?.*", "")
		end
		-- TODO: Have a fallback if that doesn't capture the link correctly.
	end

	return nil
end

local ignore_genres = {
	["adult"] = true,
	["audiobook"] = true,
	["epic fantasy"] = true,
	["fiction"] = true,
	["high fantasy"] = true,
	["magic"] = true,
	["science fiction fantasy"] = true,
}

function parser.book_details(html)
	local details = {}

	details.id = html:match('{\\"legacyId\\":\\"(%d+)\\"}')
	-- print("id: ", details.id)

	local tree = htmlparser.parse(html, 10000)

	local ratings = tree:select("div.RatingStatistics__rating")

	if #ratings > 0 then
		details.rating = ratings[1]:getcontent()
		-- print("rating: ", details.rating)
	else
		print("WARNING: rating not found!")
	end

	local num_ratings = tree:select("div.RatingStatistics__meta span")

	if #num_ratings > 0 then
		details.num_ratings = num_ratings[1]:getcontent():gsub("%D", "")
		-- print("num_ratings: ", details.num_ratings)
	else
		print("WARNING: number of ratings not found!")
	end

	local num_pages = tree:select("div.FeaturedDetails p")

	if #num_pages > 0 then
		details.num_pages = num_pages[1]:getcontent():gsub("%D", "")
		-- print("num_pages: ", details.num_pages)

		if num_pages[2] then
			details.year = num_pages[2]:getcontent():match("%d%d%d%d")
			-- print("year: ", details.year)
			details.published = num_pages[2]:getcontent():match("%w+ %d+, %d%d%d%d")
			-- print("published: ", details.published)
		end
	else
		print("WARNING: number of pages not found!")
	end

	local genres = {}

	for _, genre in ipairs(tree:select("div.BookPageMetadataSection__genres a")) do
		local g = genre.nodes[1]:getcontent():lower()

		if not ignore_genres[g] then
			table.insert(genres, g)
		end
	end

	details.genres = genres
	-- print("genres: ", table.concat(genres, ", "))

	local series = tree:select("div.BookPageTitleSection__title h3 a")

	if #series > 0 then
		local serie, volume = series[1]:getcontent():match("(.*) #(%d+)")
		details.series = serie
		details.volume = volume
		-- else
		--     print("INFO: not a part of a series")
	end

	-- print("series: ", details.series)
	-- print("volume: ", details.volume)

	-- TODO: Check awards. Remove nominations, just want wins. "Literary awards"
	-- TODO: Author pages sometimes include "Born" field, worth capturing?
	-- TODO: If there is a setting, extract it. "Setting"

	return details
end

return parser
