local scraper = require("scraper")
local data = require("data")

local path = "../../kiroku/data/audiobooks.md"
-- local path = "../../kiroku/data/ebooks.md"
-- local path = "../../kiroku/data/printbooks.md"

local books = data.parse(path)
local outfile = "/tmp/" .. path:gsub(".*/", "")
local fout = io.open(outfile, "a+")
local info, err

for _, book in pairs(books) do
	print("  " .. book.title)

	info, err = scraper.audit_book(book)

	if info then
		fout:write(data.output_book(book, info) .. "\n")
	else
		print("ERROR:", err)
	end

	os.execute("sleep 1")
end

fout:close()
