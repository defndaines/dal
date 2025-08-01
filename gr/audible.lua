local audible = {}

--[[
  Install libraries:
    luarocks install htmlparser
]]

local htmlparser = require("htmlparser")
local spider = require("spider")

function audible.find_duration(html)
	local h, m = html:match("(%d+) hours? and (%d+) minutes?")

	if h and m then
		h = tonumber(h)
		m = tonumber(m)
		return string.format("%02d:%02d", h, m)
	else
		return nil
	end
end

function audible.find_link(html, title, author)
	html = html:gsub("<script.-</script>", "")
	local tree = htmlparser.parse(html, 10000)
	local results = tree:select('div[data-cy="title-recipe"]')

	for _, result in pairs(results) do
		local link = result:select("a")[1]

		if link then
			local h2_span = link:select("h2 span")
			if h2_span and #h2_span > 0 then
				local _title = h2_span[1]:getcontent():gsub("%s+$", ""):lower()

				if _title:gsub("'", "’"):sub(1, #title) == title:lower() then
					for _, span in pairs(result:select("div div span")) do
						local _author = span:getcontent():gsub("%s+$", "")

						if _author == author then
							return link.attributes["href"]:gsub("ref=.*", "")
						end
					end
				end
			end
		end
	end

	return nil
end

function audible.search(title, author)
	local s_title = title:gsub("’s", ""):gsub(":.*", ""):gsub("%p", " ")
	local s_author = author:gsub("%s*%([^)]*%)", ""):gsub(":", ""):gsub("%.(%S)", "%1")
	local query = spider.urlencode(s_title .. " " .. s_author)
	local search_url = "https://www.amazon.com/s?k=" .. query .. "&i=audible"
	-- print(search_url)

	local html, err = spider.fetch_url(search_url)

	if html then
		local file = io.open("spec/" .. (title:gsub("%s", "-")) .. "-search.html", "w")
		file:write(html)
		file:close()

		local link = audible.find_link(html, title, author)

		if link then
			local url = "https://www.amazon.com/" .. link

			html, err = spider.fetch_url(url)

			if html then
				-- local file = io.open("spec/" .. (title:gsub("%s", "-")) .. ".html", "w")
				-- file:write(html)
				-- file:close()

				local duration = audible.find_duration(html)

				return { title = title, author = author, hours = duration, audible = url }
			else
				return nil, "Search fetch error: " .. err
			end
		end
	else
		return nil, "Search fetch error: " .. err
	end
end

-- local title = "Imperfect Victims: Criminalized Survivors and the Promise of Abolition Feminism"
-- local author = "Leigh Goodmark"
-- local book = audible.search(title, author)

-- if book then
--     assert(book.title == title)
--     assert(book.author == author)
--     assert(book.hours == "01:04")
-- end

return audible
