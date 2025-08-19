local audible = {}

--[[
  Install libraries:
    luarocks install htmlparser
]]

local htmlparser = require("htmlparser")
local spider = require("spider")

local function find_duration(html)
	local h = html:match("(%d+) hrs?") or "0"
	local m = html:match("(%d+) mins?") or "0"

	if h and m then
		h = tonumber(h)
		m = tonumber(m)
		return string.format("%02d:%02d", h, m)
	else
		return nil
	end
end

function audible.find_link(html, title, author)
	local last_name = author:match("%S+$")
	html = html:gsub("<script.-</script>", "")
	local tree = htmlparser.parse(html, 10000)
	local results = tree:select('div[data-widget="productList"] li.productListItem')

	for _, result in pairs(results) do
		local link = result:select("a")[1]

		if link then
			local h2 = result:select("h2")

			if h2 and #h2 > 0 then
				local _title = h2[1]:getcontent():gsub("%s+$", ""):lower()

				if _title:gsub("'", "’"):sub(1, #title) == title:lower() then
					local is_match = false
					local hours = "00:00"

					for _, span in pairs(result:select("li.bc-list-item")) do
						local list_item =
							span:getcontent():gsub("<.->", ""):gsub("%s%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

						if not is_match and list_item:find("By") and list_item:find(last_name) then
							link = link.attributes["href"]:gsub("%?.*", "")
							is_match = true
						elseif list_item:find("Length: ") then
							hours = find_duration(list_item)
						end
					end

					if is_match then
						return {
							title = title,
							author = author,
							hours = hours,
							audible = "https://www.audible.com" .. link,
						}
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

	-- feature six is English
	-- feature nine is Unabridged
	local search_url = "https://www.audible.com/search?feature_six_browse-bin=18685580011"
		.. "&feature_nine_browse-bin=18685524011"
		.. "&i=na-audible-us"
		.. "&keywords="
		.. query
	-- print(search_url)

	local html, err = spider.fetch_url(search_url)

	if html then
		-- local file = io.open("spec/" .. (title:gsub("%s", "-")) .. "-audible-search.html", "w")
		-- file:write(html)
		-- file:close()

		return audible.find_link(html, title, author)
	else
		return nil, "Search fetch error: " .. err
	end
end

-- local title = "Emergency Skin"
-- local author = "N. K. Jemisin"
-- local book = audible.search(title, author)

-- if book then
--     assert(book.title == title)
--     assert(book.author == author)
--     assert(book.hours == "01:04")
-- end

return audible
