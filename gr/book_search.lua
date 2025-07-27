local scraper = require("scraper")
local data = require("data")

local book = { title = arg[1], author = arg[2] }

local info, err = scraper.get_book_info(book.title, book.author)

if info then
	for k, v in pairs(info) do
		if not book[k] then
			book[k] = v
		end
	end

	print(data.output(book))
else
	print("ERROR:", err)
end

