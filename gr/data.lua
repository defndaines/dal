local data = {}

local function parse_tags(list)
	local tags = {}

	for tag in list:gmatch("[^,]+") do
		tags[#tags + 1] = tag:gsub("^%s+", ""):gsub("%s+$", "")
	end

	return tags
end

local function parse_audio_book(line)
	local title, author, year, country, pages, hours, list, rating, num_ratings, id, url =
		line:match("| (.+) | (.+) | (.+) | (.+) | (.+) | (.+) | (.+) | (.+) | (.+) | (.+) | (.+) |")

	return {
		title = title,
		author = author,
		year = year,
		country = country,
		pages = pages,
		hours = hours,
		tags = parse_tags(list),
		rating = rating,
		num_ratings = num_ratings,
		id = id,
		url = url,
	}
end

local function parse_book(line)
	local title, author, year, country, pages, list, rating, num_ratings, id, url =
		line:match("| (.+) | (.+) | (.+) | (.+) | (.+) | (.+) | (.+) | (.+) | (.+) | (.+) |")

	return {
		title = title,
		author = author,
		year = year,
		country = country,
		pages = pages,
		tags = parse_tags(list),
		rating = rating,
		num_ratings = num_ratings,
		id = id,
		url = url,
	}
end

function data.parse(file)
	local fh = assert(io.open(file, "r"))
	local book
	local books = {}
	local content = fh:read("l")
	local _, count = content:gsub("|", "|")
	local is_audio = false

	if count == 12 then
		is_audio = true
	end

	-- skip the header
	fh:read("*l")
	content = fh:read("*l")

	while content do
		if is_audio then
			book = parse_audio_book(content)
		else
			book = parse_book(content)
		end

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
	order[5] = info.pages or ""
	order[6] = book.hours

	local tags = info.genres
	local tag_set = {}

	for _, genre in ipairs(info.genres) do
		tag_set[genre] = true
	end

	if info.series then
		local series = info.series:lower():gsub("%p", " "):gsub("%s+$", ""):gsub("%s+", "-")

		if info.volume then
			series = series .. "-" .. info.volume
		end

		if not tag_set[series] then
			tags[#tags + 1] = info.series:lower():gsub("%s", "-")
		end
	end

	for _, tag in ipairs(book.tags) do
		if not tag_set[tag] then
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
	order[#order + 1] = info.title
	order[#order + 1] = book.author
	order[#order + 1] = book.year or info.year
	order[#order + 1] = info.country or book.country or "XXX"
	order[#order + 1] = book.pages or info.pages or ""

	if book.hours then
		order[#order + 1] = book.hours
	end

	local tags = book.tags or {}
	local tag_set = {}

	for _, tag in ipairs(book.tags) do
		tag_set[tag] = true
	end

	for _, tag in ipairs(info.tags) do
		if not tag_set[tag] then
			tags[#tags + 1] = tag
		end
	end

	if info.series then
		tags[#tags + 1] = info.series:lower():gsub("%s", "-") .. "-" .. info.volume
	end

	order[#order + 1] = table.concat(tags, ", ")
	order[#order + 1] = info.rating
	order[#order + 1] = info.num_ratings or ""
	order[#order + 1] = info.id or book.id or ""
	order[#order + 1] = info.url or book.url

	return "| " .. table.concat(order, " | ") .. " | "
end

function data.output(book)
	local order = {}

	order[#order + 1] = book.title
	order[#order + 1] = book.author
	order[#order + 1] = book.year
	order[#order + 1] = book.country or "XXX" -- Country still calculated by hand
	order[#order + 1] = book.pages or ""

	if book.hours then
		order[#order + 1] = book.hours
	end

	order[#order + 1] = table.concat(book.tags, ", ")
	order[#order + 1] = book.rating
	order[#order + 1] = book.num_ratings or ""
	order[#order + 1] = book.id or ""
	order[#order + 1] = book.url

	return "| " .. table.concat(order, " | ") .. " | "
end

return data
