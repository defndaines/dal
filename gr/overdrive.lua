local overdrive = {}

--[[
  Install libraries:
    luarocks install luasocket
    luarocks install luasec

  Uses LAPL’s overdrive, https://lapl.overdrive.com/search

  Could cascade to searching other overdrive accounts as needed, since there
  are some books not available from Overdrive but which are available from
  other libraries.
]]

local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("json")

local function urlencode(str)
	return str:gsub("([^%w _%%%-%.~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end):gsub(" ", "+")
end

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

	for _, book in pairs(results) do
		local score = 0

		if book.title:sub(1, #title) == title then
			score = score + 1
		else
			score = score - 2
		end

		if book.edition == "Unabridged" then
			score = score + 1
		end

		-- Favor single narrators over ensemble cast. Fails when more than one author.
		if #book.creators == 2 then
			score = score + 1
		end

		for _, creator in ipairs(book.creators) do
			if creator.role == "Author" and creator.name == author then
				score = score + 1
			end
		end

		if score > max_score then
			winner = book
			max_score = score
		end
	end

	return winner
end

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
				if award.source ~= "The New York Times" then
					awards[#awards + 1] = award.description
				end
			end

			ret.awards = awards
		end

		return ret
	else
		return nil
	end
end

function overdrive.search(title, author)
	local s_title = title:gsub(":", "")
	local s_author = author:gsub("%s*%([^)]*%)", ""):gsub(":", "")
	local query = urlencode(s_title .. " " .. s_author)
	local search_url = "https://lapl.overdrive.com/search?query=" .. query .. "&format=audiobook-overdrive&language=en"

	local html, err = fetch_url(search_url)

	-- print(search_url)
	-- local file = io.open("spec/" .. (title:gsub("%s", "-")) .. "-search.html", "w")
	-- file:write(html)
	-- file:close()

	if html then
		return overdrive.parse_results(html, title, author)
	else
		return nil, "Search fetch error: " .. err
	end
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
