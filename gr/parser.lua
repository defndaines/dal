local parser = {}
--[[
  Install library:
    luarocks install htmlparser
]]

local htmlparser = require("htmlparser")
local json = require("json")

function parser.book_link(html, title, author)
	-- Bug workaround: https://github.com/msva/lua-htmlparser/issues/67
	html = html:gsub("<script.-</script>", "")

	local tree = htmlparser.parse(html, 10000)
	local books = tree:select("table tr")

	local link
	local highest = 0
	local last_name

	if author then
		last_name = author:match("%S+$")
	end

	for _, book in ipairs(books) do
		local book_title = book:select("a.bookTitle")[1]

		local _title = book_title:select("span")[1]:getcontent():lower()

		if not _title:find(title:lower()) then
			goto continue
		elseif _title:find("Summary") then
			goto continue
		elseif _title:find("Study Guide") then
			goto continue
		end

		local _authors = book:select("div.authorName__container a span")
		local is_author_found = false

		for _, _author in ipairs(_authors) do
			local name = _author:getcontent():gsub("%s%s+", " ")

			if name == "Unknown Author" then
				goto continue
			elseif name:lower() == author:lower() then
				is_author_found = true
			elseif last_name and name:find(last_name) then
				is_author_found = true
			end
		end

		if not is_author_found then
			goto continue
		end

		local rating = book:select("div span span")[1]:getcontent()
		local count = rating:match("([%d,]+) ratings?"):gsub(",", "")

		if tonumber(count) > highest then
			highest = tonumber(count)
			link = "https://www.goodreads.com" .. book_title.attributes["href"]:gsub("?.*", "")
		end

		::continue::
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
	local details = { tags = {}, genres = {}, contributors = {}, secondaries = {}, awards = {} }

	local results = html:match('<script id="__NEXT_DATA__" type="application/json">(.-)</script>')
	local decoded = json.decode(results)
	local state = decoded.props.pageProps.apolloState

	for key, data in pairs(state) do
		if string.find(key, "Contributor:") then
			details.contributors[key] = { name = data.name, url = data.webUrl }
		elseif string.find(key, "User:") then
			-- Skip User, prefer Contributor. These are the data for any official GR user.
		elseif string.find(key, "Series:") then
			details.series =
				data.title:gsub("'", "’"):gsub("%[.-%]", ""):gsub("%(.-%)", ""):gsub(":", ""):gsub("%s+$", "")
		elseif string.find(key, "Book:") then
			details.title = data.title
			details.id = data.legacyId
			details.url = data.webUrl

			if data.primaryContributorEdge then
				details.primary = {
					ref = data.primaryContributorEdge.node.__ref,
					role = data.primaryContributorEdge.role:lower(),
				}
			end

			if data.secondaryContributorEdges then
				for _, secondary in ipairs(data.secondaryContributorEdges) do
					details.secondaries[#details.secondaries + 1] = {
						ref = secondary.node.__ref,
						role = secondary.role:lower(),
					}
				end
			end

			if data.bookSeries and next(data.bookSeries) ~= nil and data.bookSeries[1].userPosition ~= "" then
				details.volume = data.bookSeries[1].userPosition
			end

			if data.bookGenres then
				for _, entry in ipairs(data.bookGenres) do
					details.genres[#details.genres + 1] = entry.genre.name:lower()
				end
			end

			if data.details then
				details.pages = data.details.numPages
				if data.details.publicationTime and details.year == nil then
					details.year = os.date("%Y", data.details.publicationTime / 1000)
				end
				if data.details.format then
					details.format = data.details.format:lower()
				end
			end
		elseif string.find(key, "Work:") then
			details.rating = data.stats.averageRating
			details.num_ratings = data.stats.ratingsCount

			if data.details.publicationTime then
				-- Original publication date.
				details.year = os.date("%Y", data.details.publicationTime / 1000)
			end

			if data.details.awardsWon then
				for _, award in ipairs(data.details.awardsWon) do
					if award.designation == "WINNER" then
						-- Maybe only store if the first characters is [A-Z]?
						details.awards[#details.awards + 1] = award.name
					end
				end
			end
		elseif string.find(key, "Review:") then
			-- Skip
		elseif string.find(key, "Shelving:") then
			-- Skip
		elseif string.find(key, "Genre:") then
			details.genres[#details.genres + 1] = data.name
		elseif key ~= "ROOT_QUERY" then
			print("unknown key", key)
		end
	end

	local author = details.contributors[details.primary.ref]
	if author then
		details.author = author.name
		details.author_link = author.url
	else
		print("WARNING: Author not found.", details.primary.ref, details.primary.role)
	end

	for _, secondary in ipairs(details.secondaries) do
		local contrib = details.contributors[secondary.ref]
		if contrib then
			if secondary.role == "author" or secondary.role == "contributor" then
				details.author = (details.author or "") .. ", " .. contrib.name
			elseif secondary.role == "editor" then
				details.author = (details.author or "") .. ", " .. contrib.name .. " (editor)"
			elseif secondary.role:find("translat") then
				details.author = (details.author or "") .. ", " .. contrib.name .. " (translator)"
			end
		end
	end

	local genres = {}
	local is_memoir = false
	local is_nonfiction = false
	local is_romantasy = false
	local is_post_apocalyptic = false
	local is_world_war = false

	for _, g in ipairs(details.genres) do
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
		elseif is_world_war and g == "war" then
			g = ""
		end

		if g == "19th century" then
			local year = tonumber(details.year)
			if year > 1799 and year < 1900 then
				g = ""
			end
		end

		g = g:gsub("science fiction", "sci-fi")
			:gsub("african american", "Black")
			:gsub("holocaust", "Holocaust")
			:gsub("jewish", "Jewish")
			:gsub("lgbt", "LGBT")
			:gsub("native americans", "Native American")
			:gsub("native american", "Native American")
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
			if g:find("WW") then
				is_world_war = true
				local war
				for i, v in ipairs(genres) do
					if v == "war" then
						war = i
					end
				end
				if war then
					table.remove(genres, war)
				end
			end
		end
	end

	details.tags = uniq(genres)

	if details.series then
		local series_tag = details.series:lower():gsub(",", ""):gsub("%s+$", ""):gsub("%s+", "-")
		if details.volume and details.volume ~= "" then
			series_tag = series_tag .. "-" .. details.volume
		end

		details.tags[#details.tags + 1] = series_tag
	end

	for _, award in pairs(details.awards) do
		details.tags[#details.tags + 1] = award
	end

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
