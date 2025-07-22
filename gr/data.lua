local data = {}

function data.parse(file)
	local fh = assert(io.open(file, "r"))
	local books = {}
	local content = fh:read("l")

	while content do
		local title, author, rating, list = content:match("(.+) | (.+) | (.+) | (.+)")

		local book = {}
		local tags = {}
		book.title = title
		book.author = author
		book.rating = rating
		-- book.pages = pages

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

function data.output_audiobook(book, info)
	local order = {}
	order[1] = info.title
	order[2] = info.author
	order[3] = info.year
	order[4] = "XXX" -- Country still calculated by hand
	order[5] = info.num_pages or ""
	order[6] = book.hours

	local tags = info.genres
	local g_set = {}

	for _, genre in ipairs(info.genres) do
		g_set[genre] = true
	end

	if info.series then
		if info.volume then
			tags[#tags + 1] = info.series:lower():gsub("%s", "-") .. "-" .. info.volume
		else
			tags[#tags + 1] = info.series:lower():gsub("%s", "-")
		end
	end

	for _, tag in ipairs(book.tags) do
		if not g_set[tag] then
			tags[#tags + 1] = tag
		end
	end

	order[7] = table.concat(tags, ", ")
	order[8] = info.rating
	order[9] = info.num_ratings or ""
	order[10] = info.id or ""
	order[11] = info.url

	return "| " .. table.concat(order, " | ") .. " | "
end

function data.output_book(book, info)
	local order = {}
	order[1] = info.title
	order[2] = info.author
	order[3] = info.year
	order[4] = "XXX" -- Country still calculated by hand
	order[5] = info.num_pages or ""

	local tags = info.genres
	local g_set = {}

	for _, genre in ipairs(info.genres) do
		g_set[genre] = true
	end

	if info.series then
		tags[#tags + 1] = info.series:lower():gsub("%s", "-") .. "-" .. info.volume
	end

	for _, tag in ipairs(book.tags) do
		if not g_set[tag] then
			tags[#tags + 1] = tag
		end
	end

	order[6] = table.concat(tags, ", ")
	order[7] = info.rating
	order[8] = info.num_ratings or ""
	order[9] = info.id or ""
	order[10] = info.url

	return "| " .. table.concat(order, " | ") .. " | "
end

return data
