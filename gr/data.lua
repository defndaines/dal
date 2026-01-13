local data = {}

local tag = require("tag")

function data.parse_audio_book(line)
	local title, author, year, country, pages, hours, list, rating, num_ratings, id, url =
		line:match("| (.+) | (.+) | (.-) | (.-) | (.-) | (.-) | (.-) | (.-) | (.-) | %[(.+)%]%((.+)%) |")

	return {
		title = title,
		author = author,
		year = year,
		country = country,
		pages = pages,
		hours = hours,
		tags = tag.parse(list),
		rating = rating,
		num_ratings = num_ratings,
		id = id,
		url = url,
	}
end

local function parse_book(line)
	local title, author, year, country, pages, list, rating, num_ratings, id, url =
		line:match("| (.+) | (.+) | (.-) | (.-) | (.-) | (.-) | (.-) | (.-) | %[(.+)%]%((.+)%) |")

	return {
		title = title,
		author = author,
		year = year,
		country = country,
		pages = pages,
		tags = tag.parse(list),
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

	if count == 11 then
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

function data.parse_log(file)
	local fh = assert(io.open(file, "r"))
	local line

	repeat
		line = fh:read("l")
	until line:find("^|")

	-- skip the header
	fh:read("*l")
	line = fh:read("*l")

	local books = {}

	while line do
		local title, author, year, country, rating, format, pages, list =
			line:match("| (.+) | (.+) | (%d%d%d%d) | (.+) | (%d%.%d) | (.+) | (%d+) | (.+) |")

		books[#books + 1] = {
			title = title,
			author = author,
			year = year,
			country = country,
			rating = rating,
			format = format,
			pages = pages,
			tags = tag.parse(list),
		}

		line = fh:read("*l")
	end

	fh:close()

	return books
end

local function non_empty(str)
	if str then
		local trimmed = str:match("^%s*(.-)%s*$")
		if trimmed == "" then
			return nil
		else
			return trimmed
		end
	else
		return nil
	end
end

function data.merge(book, info)
	return {
		title = book.title or info.title,
		author = book.author or info.author,
		year = non_empty(book.year) or info.year,
		country = non_empty(book.country) or info.country,
		pages = non_empty(book.pages) or info.pages,
		hours = non_empty(book.hours) or info.hours,
		tags = next(book.tags) and book.tags or info.tags,
		rating = info.rating or book.rating,
		num_ratings = info.num_ratings,
		id = book.id or info.id,
		url = book.url or info.url,
	}
end

function data.output(book)
	local order = {}

	order[#order + 1] = book.title
	order[#order + 1] = book.author
	order[#order + 1] = book.year
	order[#order + 1] = book.country or "XXX" -- Country must still looked up manually
	order[#order + 1] = book.pages or ""

	if book.hours then
		order[#order + 1] = book.hours
	end

	order[#order + 1] = table.concat(tag.sort(book.tags), ", ")
	order[#order + 1] = string.format("%.2f", (book.rating or 0.0))
	order[#order + 1] = book.num_ratings or ""
	order[#order + 1] = "[" .. (book.id or "") .. "](" .. book.url .. ")"

	return "| " .. table.concat(order, " | ") .. " |"
end

function data.output_log(book)
	local order = {}

	order[#order + 1] = book.title
	order[#order + 1] = book.author
	order[#order + 1] = book.year
	order[#order + 1] = book.country
	order[#order + 1] = string.format("%.2f", (book.rating or 0.0))
	order[#order + 1] = book.format
	order[#order + 1] = book.pages
	order[#order + 1] = table.concat(tag.sort(book.tags), ", ")

	return "| " .. table.concat(order, " | ") .. " |"
end

return data
