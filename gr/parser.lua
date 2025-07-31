local parser = {}
--[[
  Install library:
    luarocks install htmlparser
]]

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
	["21st century"] = true,
	["YA fantasy"] = true,
	["academic"] = true,
	["action"] = true,
	["activism"] = true,
	["adult"] = true,
	["adventure"] = true,
	["africa"] = true,
	["agriculture"] = true,
	["algeria"] = true,
	["aliens"] = true,
	["american civil war"] = true,
	["american history"] = true,
	["american"] = true,
	["ancient history"] = true,
	["ancient"] = true,
	["angola"] = true,
	["animal"] = true,
	["animals"] = true,
	["anthologies"] = true,
	["anthropology"] = true,
	["anti racist"] = true,
	["archaeology"] = true,
	["art"] = true,
	["asia"] = true,
	["audiobook"] = true,
	["australia"] = true,
	["autobiography"] = true,
	["bande dessinée"] = true,
	["banned books"] = true,
	["biography memoir"] = true,
	["book club"] = true,
	["books about books"] = true,
	["brazil"] = true,
	["bulgaria"] = true,
	["business"] = true,
	["canada"] = true,
	["cats"] = true,
	["chick lit"] = true,
	["childrens"] = true,
	["china"] = true,
	["christianity"] = true,
	["christmas"] = true,
	["cities"] = true,
	["civil war"] = true,
	["collections"] = true,
	["college"] = true,
	["comedy"] = true,
	["comics manga"] = true,
	["comics"] = true,
	["contemporary romance"] = true,
	["cooking"] = true,
	["cozy fantasy"] = true,
	["cozy"] = true,
	["cultural"] = true,
	["cycling"] = true,
	["dark fantasy"] = true,
	["death"] = true,
	["denmark"] = true,
	["design"] = true,
	["dinosaurs"] = true,
	["dragonlance"] = true,
	["dragons"] = true,
	["drama"] = true,
	["dungeons and dragons"] = true,
	["ecology"] = true,
	["education"] = true,
	["egypt"] = true,
	["engineering"] = true,
	["environment"] = true,
	["epic fantasy"] = true,
	["epic"] = true,
	["ethiopia"] = true,
	["european history"] = true,
	["fae"] = true,
	["fairies"] = true,
	["fairy tales"] = true,
	["family"] = true,
	["fantasy romance"] = true,
	["female authors"] = true,
	["fiction"] = true,
	["food history"] = true,
	["forgotten realms"] = true,
	["france"] = true,
	["friendship"] = true,
	["gamebooks"] = true,
	["gaming"] = true,
	["gay"] = true,
	["gender"] = true,
	["germany"] = true,
	["ghost stories"] = true,
	["ghosts"] = true,
	["go"] = true,
	["graphic novels comics"] = true,
	["graphic novels"] = true,
	["greece"] = true,
	["grief"] = true,
	["hard boiled"] = true,
	["high fantasy"] = true,
	["historical fantasy"] = true,
	["horror thriller"] = true,
	["horses"] = true,
	["how to"] = true,
	["hugo awards"] = true,
	["hungary"] = true,
	["india"] = true,
	["ireland"] = true,
	["israel"] = true,
	["italy"] = true,
	["ivory coast"] = true,
	["japan"] = true,
	["jazz"] = true,
	["josei"] = true,
	["judaism"] = true,
	["juvenile"] = true,
	["kenya"] = true,
	["language"] = true,
	["latin american"] = true,
	["latinx"] = true,
	["legal thriller"] = true,
	["libya"] = true,
	["literary criticism"] = true,
	["lovecraftian"] = true,
	["magic"] = true,
	["mauritius"] = true,
	["medical"] = true,
	["medieval"] = true,
	["middle east"] = true,
	["middle grade"] = true,
	["military history"] = true,
	["military sci-fi"] = true,
	["military"] = true,
	["morocco"] = true,
	["mozambique"] = true,
	["music biography"] = true,
	["mystery thriller"] = true,
	["new weird"] = true,
	["new york"] = true,
	["nigeria"] = true,
	["nobel prize"] = true,
	["novel in verse"] = true,
	["novels"] = true,
	["oral history"] = true,
	["pakistan"] = true,
	["parenting"] = true,
	["philosophy"] = true,
	["photography"] = true,
	["picture books"] = true,
	["poland"] = true,
	["political science"] = true,
	["pop culture"] = true,
	["poverty"] = true,
	["psychology"] = true,
	["pulp"] = true,
	["read for school"] = true,
	["realistic fiction"] = true,
	["realistic"] = true,
	["reference"] = true,
	["relationships"] = true,
	["religion"] = true,
	["research"] = true,
	["robots"] = true,
	["role playing games"] = true,
	["roman"] = true,
	["romania"] = true,
	["russia"] = true,
	["satire"] = true,
	["school"] = true,
	["sci-fi fantasy"] = true,
	["science fiction fantasy"] = true,
	["scotland"] = true,
	["self help"] = true,
	["short story collection"] = true,
	["slice of life"] = true,
	["social media"] = true,
	["social movements"] = true,
	["somalia"] = true,
	["space"] = true,
	["spain"] = true,
	["spirituality"] = true,
	["supernatural"] = true,
	["survival"] = true,
	["suspense"] = true,
	["sustainability"] = true,
	["sweden"] = true,
	["teen"] = true,
	["the united states of america"] = true,
	["theatre"] = true,
	["theory"] = true,
	["transgender"] = true,
	["translated"] = true,
	["transport"] = true,
	["travel"] = true,
	["turkish"] = true,
	["ukraine"] = true,
	["unfinished"] = true,
	["united states"] = true,
	["urban design"] = true,
	["urban"] = true,
	["urbanism"] = true,
	["victorian"] = true,
	["weird"] = true,
	["witches"] = true,
	["wolves"] = true,
	["womens"] = true,
	["world history"] = true,
	["writing"] = true,
	["ya contemporary"] = true,
	["zambia"] = true,
	["zimbabwe"] = true,
	["漫画"] = true,
}

local function uniq(list)
	local set = {}
	local deduped = {}

	for _, v in ipairs(list) do
		if not set[v] then
			deduped[#deduped + 1] = v
			set[v] = true
		end
	end

	return deduped
end

function parser.book_details(html)
	local details = {}

	details.id = html:match('{\\"legacyId\\":\\"(%d+)\\"}')
	html = html:gsub("<script.-</script>", "")

	local tree = htmlparser.parse(html, 10000)

	local title = tree:select("h1")

	if #title > 0 then
		details.title = title[1]:getcontent():gsub("&#x27;", "’"):gsub("amp;", "")
	end

	local authors = {}
	local contributors = tree:select("div.ContributorLinksList a.ContributorLink")

	for _, contributor in pairs(contributors) do
		local role = contributor:select("span.ContributorLink__role")

		if not details.author_link then
			details.author_link = contributor.attributes["href"]
		end

		if #role > 0 and #authors > 0 then
			-- skip translators, editors, etc.
		else
			local span = contributor:select("span.ContributorLink__name")[1]
			authors[#authors + 1] = span:getcontent():gsub("%s+", " "):gsub("&#x27;", "’")
		end
	end

	details.author = table.concat(uniq(authors), ", ")

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

	local pages = tree:select("div.FeaturedDetails p")

	if #pages > 0 then
		details.pages = pages[1]:getcontent():gsub("%D", "")
		-- print("pages: ", details.pages)

		if pages[2] then
			details.year = pages[2]:getcontent():match("%d%d%d%d")
			-- print("year: ", details.year)
			details.published = pages[2]:getcontent():match("%w+ %d+, %d%d%d%d")
			-- print("published: ", details.published)
		end
	else
		print("WARNING: number of pages not found!")
	end

	local genres = {}
	local is_memoir = false
	local is_nonfiction = false
	local is_romantasy = false
	local is_post_apocalyptic = false

	for _, genre in ipairs(tree:select("div.BookPageMetadataSection__genres a")) do
		local g = genre.nodes[1]:getcontent():lower()

		if g == "memoir" then
			is_memoir = true
		elseif g == "post-apocalyptic" then
			is_post_apocalyptic = true
		elseif is_post_apocalyptic and g == "apocalyptic" then
			g = ""
		elseif g == "biography" and is_memoir then
			g = ""
		elseif is_romantasy and g == "fantasy" then
			g = ""
		elseif is_romantasy and g == "romance" then
			g = ""
		elseif g == "nonfiction" then
			is_nonfiction = true
			table.insert(genres, 1, g)
		elseif g == "historical" and is_nonfiction then
			g = ""
		elseif g == "romantasy" then
			is_romantasy = true
		end

		if g == "19th century" then
			local year = tonumber(details.year)
			if year > 1799 and year < 1900 then
				g = ""
			end
		end

		g = g:gsub("science fiction", "sci-fi")
			:gsub("african american", "Black")
			:gsub("gothic", "Gothic")
			:gsub("holocaust", "Holocaust")
			:gsub("jewish", "Jewish")
			:gsub("lgbt", "LGBT")
			:gsub("native americans", "Native American")
			:gsub("native american", "Native American")
			:gsub("southern", "Southern")
			:gsub("young adult", "YA")
			:gsub("post apocalyptic", "post-apocalyptic")
			:gsub("world war ii", "WWII")
			:gsub("world war i", "WWI")
			:gsub("dystopia", "dystopian")
			:gsub("plays", "play")
			:gsub("retellings", "retelling")
			:gsub("westerns", "western")
			:gsub("&#x27;", "’")
			:gsub("&amp;", "&")
			:gsub(".*literature", "")
			:gsub(".*mythology", "mythology")
			:gsub("%s+fiction", "")

		if not ignore_genres[g] and g ~= "" then
			table.insert(genres, g)
		end
	end

	details.tags = uniq(genres)

	local series = tree:select("div.BookPageTitleSection__title h3 a")

	if #series > 0 then
		local series_info = series[1]
			:getcontent()
			:gsub("&#x27;", "’")
			:gsub("'", "’")
			:gsub("&amp;", "&")
			:gsub("%[.-%]", "")
			:gsub("%(.-%)", "")
			:gsub(":", "")
		local serie = series_info:gsub("%s*#.*", "")

		if serie then
			details.series = serie:gsub("%s+$", "")

			if series_info:match("#([^#]+)") then
				local volume = series_info:gsub(".*#", "")
				details.volume = volume
			end
		else
			print("WARNING: Problem parsing series information " .. series[1]:getcontent())
		end
	end

	-- print("series: ", details.series)
	-- print("volume: ", details.volume)

	-- TODO: Check awards. Remove nominations, just want wins. "Literary awards"

	return details
end

-- For now, only extracting birthplace if present.
function parser.author_details(html)
	local birthplace = html:match('<div class="dataTitle">Born</div>([^<]*)')

	if birthplace then
		birthplace = birthplace:gsub("^%s*", ""):gsub("%s*$", ""):gsub("^in ", "")

		if birthplace:match("United States") then
			return "U.S."
		elseif birthplace:match("United Kingdom") then
			return "U.K."
		elseif birthplace:match("Korea, Republic of") then
			return "South Korea"
		elseif birthplace:match("Seoul") then
			return "South Korea"
		elseif birthplace:match("Korea, Democratic People") then
			return "North Korea"
		elseif birthplace:match("German") then
			return "Germany"
		elseif birthplace:match("Russia") then
			return "Russia"
		elseif birthplace:match("Kenya") then
			return "Kenya"
		else
			return birthplace:gsub("[^,]*, ", "")
		end
	end

	return birthplace
end

return parser
