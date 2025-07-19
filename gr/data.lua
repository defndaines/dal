local data = {}

function data.parse(file)
	local fh = assert(io.open(file, "r"))
	local books = {}
	local content = fh:read("l")

	while content do
		title, author, rating, hours, list = content:match("(.+) | (.+) | (.+) | (.+) | (.+)")

		local book = {}
		local tags = {}
		book.title = title
		book.author = author
		book.rating = rating
		book.hours = hours

		for tag in list:gmatch("[^,]+") do
			tags[#tags + 1] = tag:gsub("^%s+", ""):gsub("%s+$", "")
		end

		book.tags = tags
		books[#books + 1] = book

		content = fh:read("*l")
	end

	fh:close()

	return books
end

--[[
file = "../..//kiroku/data/audiobooks.txt"
books = data.parse(file)
print(#books)
book = books[1]
print("title: ", book.title)
print("author: ", book.author)
print("rating: ", book.rating)
print("hours: ", book.hours)
print("tags: ", table.concat(book.tags, ", "))
]]

return data
