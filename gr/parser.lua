local parser = {}

local htmlparser = require("htmlparser")

function parser.book_link(html, title, author)
	-- Bug workaround: https://github.com/msva/lua-htmlparser/issues/67
	html = html:gsub("<script.-</script>", "")

	local tree = htmlparser.parse(html, 10000)
	local books = tree:select("table tr")

	local link
	local highest = 0

	for _, book in ipairs(books) do
		local book_title = book:select("a.bookTitle")

		local rating = book:select("div span span")[1]:getcontent()
		local count = rating:match("([%d,]+) ratings?"):gsub(",", "")

		if tonumber(count) > highest then
			highest = tonumber(count)
			link = "https://www.goodreads.com" .. book_title[1].attributes["href"]:gsub("?.*", "")
		end
	end

	return link
end

local ignore_genres = {
	["20th century"] = true,
	["YA fantasy"] = true,
	["adult"] = true,
	["africa"] = true,
	["american history"] = true,
	["ancient history"] = true,
	["ancient"] = true,
	["asia"] = true,
	["asian literature"] = true,
	["audiobook"] = true,
	["biography memoir"] = true,
	["book club"] = true,
	["china"] = true,
	["epic fantasy"] = true,
	["fiction"] = true,
	["high fantasy"] = true,
	["india"] = true,
	["indian literature"] = true,
	["literature"] = true,
	["magic"] = true,
	["mystery thriller"] = true,
	["novels"] = true,
	["realistic fiction"] = true,
	["school"] = true,
	["science fiction fantasy"] = true,
	["sci-fi fantasy"] = true,
	["world history"] = true,
}

local function uniq(list)
	local hash = {}

	for _, v in ipairs(list) do
		hash[v] = true
	end

	local deduped = {}

	for k, _ in pairs(hash) do
		deduped[#deduped + 1] = k
	end

	return deduped
end

function parser.book_details(html)
	local details = {}

	details.id = html:match('{\\"legacyId\\":\\"(%d+)\\"}')
	html = html:gsub("<script.-</script>", "")

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
		g = g:gsub("science fiction", "sci-fi"):gsub("young adult", "YA"):gsub("lgbt", "LGBT"):gsub("world war ii", "WWII")

		if not ignore_genres[g] then
			table.insert(genres, (g:gsub("%s+fiction", "")))
		end
	end

	details.genres = uniq(genres)
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
