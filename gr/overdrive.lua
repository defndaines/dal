local overdrive = {}

--[[
  Uses LAPL’s overdrive by default, https://lapl.overdrive.com/search

  Some other options to look into implementing:
  - https://lacountylibrary.overdrive.com/
  - https://hcpl.overdrive.com/

  Could cascade to searching other overdrive accounts as needed, since there
  are some books not available from Overdrive but which are available from
  other libraries.
]]

overdrive.lapl_url = "https://lapl.overdrive.com"
overdrive.lacountylibrary_url = "https://lacountylibrary.overdrive.com"
overdrive.hcpl_url = "https://hcpl.overdrive.com"
overdrive.smpl_url = "https://santamonica.overdrive.com"
overdrive.tpl_url = "https://torrance.overdrive.com"

local spider = require("spider")
local json = require("json")

local function format_duration(duration)
	local h, m, s = duration:match("(%d%d):(%d%d):(%d%d)")

	if tonumber(s) >= 30 then
		m = tonumber(m) + 1
		if m == 60 then
			h = string.format("%02d", tonumber(h) + 1)
			m = "00"
		else
			m = string.format("%02d", m)
		end
	end

	return h .. ":" .. m
end

-- Given a set of results, return the best one.
local function select_book(results, title, author)
	local max_score = 0
	local winner
	local last_name = author:match("%S+$")

	for _, book in pairs(results) do
		if book.edition ~= "Unabridged" then
			goto continue
		end

		local score = 0

		local _title = book.title:lower():gsub("'", "’")
		if _title == title:lower() then
			score = score + 4
		elseif _title:sub(1, #title) == title:lower() then
			score = score + 2
		elseif _title:find("summary") then
			goto continue
		elseif _title:find(title:lower()) then
			score = score + 1
		else
			goto continue
		end

		-- Favor single narrators over ensemble cast. Fails when more than one author.
		if #book.creators == 2 then
			score = score + 1
		end

		local is_author_found = false
		for _, creator in ipairs(book.creators) do
			if creator.role == "Author" then
				if creator.name == author or creator.name:find(last_name) then
					score = score + 2
					is_author_found = true
				else
					score = score - 1
				end
			end
		end

		if not is_author_found then
			goto continue
		end

		if score > max_score then
			winner = book
			max_score = score
		end

		::continue::
	end

	return winner
end

local ignored_awards = {
	["Amazing Audiobooks for Young Adults"] = true,
	["American Indian Youth Literature Award Honor"] = true,
	["Audie Award Nominee"] = true,
	["Audie Award"] = true,
	["Best Audio Books"] = true,
	["Best Audiobooks"] = true,
	["Best Fiction for Young Adults"] = true,
	["Bram Stoker Award Nominee"] = true,
	["Damon Knight Memorial Grand Master Award"] = true,
	["Edgar Allan Poe Award Finalist"] = true,
	["Edgar nominee"] = true,
	["Excellence in Nonfiction for Young Adults"] = true,
	["Grand Master Award"] = true,
	["Hugo Award Nominee"] = true,
	["Ian Fleming Steel Dagger"] = true,
	["Libby Award Finalist"] = true,
	["Libby Award Winner"] = true,
	["Listen Up Award"] = true,
	["Man Booker Prize for Fiction Nominee"] = true,
	["National Book Award Finalist"] = true,
	["National Book Critics Circle Award Finalist"] = true,
	["Nebula Nominee"] = true,
	["Notable Books for Adults"] = true,
	["Notable Children's Recordings"] = true,
	["Pulitzer Prize Finalist"] = true,
	["Romantic Times Career Achievement Award Winner"] = true,
	["Romantic Times Reviewers' Choice Award Winner - Best Book"] = true,
	["Scotiabank Giller Prize Nominee"] = true,
	["Stonewall Honor Book Award"] = true,
	["Teens' Top Ten"] = true,
	["William C. Morris Debut Young Adult Award"] = true,
	["Young Adult Favorites Award"] = true,
}

function overdrive.parse_results(html, title, author)
	local results = html:match("window%.OverDrive%.mediaItems = ({.-});%s*window%.OverDrive%.")
	local decoded = json.decode(results)
	local book = select_book(decoded, title, author)

	if book then
		local ret = { title = book.title, author = book.creators[1].name }

		if book.subtitle then
			ret.title = ret.title .. ": " .. book.subtitle
		end

		for _, format in ipairs(book.formats) do
			if format.id == "audiobook-overdrive" then
				ret.duration = format_duration(format.duration)
			end
		end

		if book.awards then
			local awards = {}

			for _, award in ipairs(book.awards) do
				if award.description == "Nobel Prize in Literature Awarded Author" then
					awards[#awards + 1] = "Nobel"
				elseif award.description == "Man Booker Prize for Fiction" then
					awards[#awards + 1] = "Booker Prize"
				elseif awards.description == "Andre Norton Nebula Award for Middle Grade and Young Adult Fiction" then
					awards[#awards + 1] = "Nebula Award"
				elseif not ignored_awards[award.description] and award.source ~= "The New York Times" and award.description ~= "Finalist" then
					awards[#awards + 1] = award.description
				end
			end

			if #awards > 0 then
				ret.awards = awards
			end
		end

		return ret
	else
		return nil
	end
end

function overdrive.search(title, author, overdrive_url)
	local s_title = title:gsub("’s", ""):gsub(":.*", ""):gsub("%p", " ")
	local s_author = author:gsub("%s*%([^)]*%)", ""):gsub(":", ""):gsub("%.(%S)", "%1")
	local query = spider.urlencode(s_title .. " " .. s_author)
	overdrive_url = overdrive_url or overdrive.lapl_url
	local search_url = overdrive_url .. "/search?query=" .. query .. "&format=audiobook-overdrive&language=en"

	local html, err = spider.fetch_url(search_url)

	-- if overdrive_url == overdrive.lapl_url then
	--     print(search_url)
	--     local file = io.open("spec/" .. (title:gsub("%s", "-")) .. "-overdrive-search.html", "w")
	--     file:write(html)
	--     file:close()
	-- end

	if html then
		return overdrive.parse_results(html, title, author)
	else
		return nil, "Search fetch error: " .. err
	end
end

function overdrive.search_libraries(title, author)
	local urls = {
		overdrive.lapl_url,
		overdrive.lacountylibrary_url,
		overdrive.hcpl_url,
		overdrive.smpl_url,
		overdrive.tpl_url,
	}

	local i = 1
	local audiobook

	repeat
		audiobook = overdrive.search(title, author, urls[i])
		i = i + 1
	until audiobook or i > #urls

	return audiobook
end

-- local book = overdrive.search("Stay True", "Hua Hsu") -- single result, includes awards
-- local book = overdrive.search("The Golden Compass", "Philip Pullman") -- multiple results, including unrelated
-- local book = overdrive.search("Hurricane Season", "Fernanda Melchor") -- empty result
-- local book = overdrive.search("Project Hail Mary", "Andy Weir") -- 2 results are book

-- if book then
--     print("FOUND:", book.title, book.author)
--     print("  duration:", book.duration)

--     if book.awards then
--         print("  awards:", table.concat(book.awards, ", "))
--     end
-- end

return overdrive
