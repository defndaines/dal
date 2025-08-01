local data = {}

local function parse_tags(list)
	local tags = {}

	for tag in list:gmatch("[^,]+") do
		tags[#tags + 1] = tag:gsub("^%s+", ""):gsub("%s+$", "")
	end

	return tags
end

function data.parse_audio_book(line)
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
			book = data.parse_audio_book(content)
		else
			book = parse_book(content)
		end

		books[#books + 1] = book

		content = fh:read("*l")
	end

	fh:close()

	return books
end

function data.output_book(book, info)
	local order = {}
	order[#order + 1] = book.title or info.title
	order[#order + 1] = book.author or info.author
	order[#order + 1] = book.year or info.year
	order[#order + 1] = book.country or info.country or "XXX"
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

	order[#order + 1] = table.concat(tags, ", ")
	order[#order + 1] = info.rating
	order[#order + 1] = info.num_ratings or ""
	order[#order + 1] = book.id or info.id or ""
	order[#order + 1] = book.url or info.url

	if book.audible then
		order[#order] = order[#order] .. " ; " .. book.audible
	end

	return "| " .. table.concat(order, " | ") .. " |"
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
