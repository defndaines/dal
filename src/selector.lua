-- See https://github.com/msva/lua-htmlparser for getting started with this library.

local htmlparser = require("htmlparser")
htmlparser_looplimit = 10000

local function extract_book_link(html, title)
	local tree = htmlparser.parse(html)
	local links = tree:select("a.bookTitle")

	for _, link in ipairs(links) do
		-- First node is a <span> containing the name of the book.
		if link.nodes[1]:getcontent():match("^" .. title) then
			return "https://www.goodreads.com" .. link.attributes["href"]:gsub("?.*", "")
		end
	end
end

local title = "The Name of the Wind"
local author = "Patrick Rothfuss"
local html = io.input("search.html"):read("a")

link = extract_book_link(html, title)
print(link)
