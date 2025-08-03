local libro = {}

--[[
  Install libraries:
    luarocks install htmlparser
]]

local htmlparser = require("htmlparser")
local spider = require("spider")

function libro.find_book(html, title, author)
	html = html:gsub("<script.-</script>", "")
	local tree = htmlparser.parse(html, 10000)
	local results = tree:select("div.book-grid div.book-grid-item")

	local max_score = 0
	local winner

	for _, result in pairs(results) do
		local link = result:select("a.book")[1]

		if link then
			local score = 0
			book = { libro = "https://www.libro.fm" .. link.attributes["href"] }

			local title_span = link:select("div.book-info div.title")

			if
				title_span
				and #title_span > 0
				and title_span[1]:getcontent():gsub("'", "’"):lower():sub(1, #title) == title:lower()
			then
				score = score + 1
				book.title = title_span[1]:getcontent():gsub("'", "’")
			else
				score = score - 2
			end

			local author_span = link:select("div.book-info div.author")

			if
				author_span
				and #author_span > 0
				and author_span[1]:getcontent():gsub("'", "’"):lower():sub(1, #author) == author:lower()
			then
				score = score + 1
				book.author = author_span[1]:getcontent():gsub("'", "’")
			end

			local book_info = result:select("div.audiobook-info p.one-line")
			if book_info and #book_info > 0 then
				for i, p in ipairs(book_info) do
					local content = p:getcontent()
					local h = content:match("(%d+) hours?")
					local m = content:match("(%d+) minutes?")

					if h or m then
						h = tonumber(h or 0)
						m = tonumber(m or 0)
						book.hours = string.format("%02d:%02d", h, m)
					elseif content:match("Abridged:.*No") then
						score = score + 1
						book.unabridged = true
					elseif content:match("Length:.*TBA") then
						book.hours = "##:##"
					end
				end
				if not book.hours then
					for i, p in ipairs(book_info) do
						print("debug", p:getcontent())
					end
				end
			end

			if score > max_score then
				winner = book
				max_score = score
			end
		end
	end

	return winner
end

function libro.search(title, author)
	local s_title = title:gsub("’s", ""):gsub(":.*", ""):gsub("%p", " ")
	local s_author = author:gsub("%s*%([^)]*%)", ""):gsub(":", ""):gsub("%.(%S)", "%1")
	local query = spider.urlencode(s_title .. " " .. s_author)
	local search_url = "https://libro.fm/search?q=" .. query .. "&searchby=all&sortby=relevance&language_eng=true"

	-- print(search_url)

	local html, err = spider.fetch_url(search_url)

	if html then
		-- local file = io.open("spec/" .. (title:gsub("%s", "-")) .. "-search.html", "w")
		-- file:write(html)
		-- file:close()

		return libro.find_book(html, title, author)
	else
		return nil, "Search fetch error: " .. err
	end
end

-- local title = "Stone Mattress"
-- local author = "Margaret Atwood"
-- local book = libro.search(title, author)

-- if book then
--     assert(book.title == title)
--     assert(book.author == author)
--     assert(book.hours == "01:04")
-- end

local data = require("data")

-- local path = "../../kiroku/data/ebooks.md"
-- local books = data.parse(path)
-- local outfile = "/tmp/" .. path:gsub(".*/", "")
-- local fout = io.open(outfile, "a+")

-- for _, book in pairs(books) do
--     local audio = libro.search(book.title, book.author)
--     if audio then
--         print(
--             "| "
--                 .. audio.title
--                 .. " | "
--                 .. (audio.author or book.author)
--                 .. " | "
--                 .. audio.hours
--                 .. " | "
--                 .. audio.libro
--                 .. " |"
--         )
--     end
-- end

return libro
