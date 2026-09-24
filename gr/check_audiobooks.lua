-- Checks records in a file like eyebooks.md for audiobooks that have since
-- become available at Overdrive, Hoopla, or Audible.

local data = require("data")
local overdrive = require("overdrive")
local hoopla = require("hoopla")
local audible = require("audible")
local socket = require("socket")

local path = arg[1]
if not path then
	io.stderr:write("Usage: lua check_audiobooks.lua <path to books file>\n")
	os.exit(1)
end

local books = data.parse(path)
local found = 0
local dots_on_line = false

local function progress()
	io.write(".")
	io.stdout:flush()
	dots_on_line = true
end

local function report(...)
	if dots_on_line then
		io.write("\n")
		dots_on_line = false
	end
	print(...)
	io.stdout:flush()
end

for i, book in ipairs(books) do
	local reported = false
	local has_audio = book.hours
	local no_audio = false
	local has_exclusive_audible = false
	local has_plain_audible = false

	for _, t in ipairs(book.tags) do
		if t == "no-audio" then
			no_audio = true
		elseif t:find("^%[Audible Exclusive%]") then
			has_exclusive_audible = true
		elseif t:find("^%[Audible%]") then
			has_plain_audible = true
		end
	end

	if (not has_audio or has_plain_audible) and not has_exclusive_audible and not no_audio then
		local audiobook = overdrive.search_libraries(book.title, book.author)

		if audiobook then
			book.hours = audiobook.duration

			-- The library copy supersedes the non-exclusive Audible link.
			if has_plain_audible then
				local kept_tags = {}
				for _, t in ipairs(book.tags) do
					if not t:find("^%[Audible%]") then
						kept_tags[#kept_tags + 1] = t
					end
				end
				book.tags = kept_tags
			end

			local hooplabook = hoopla.search(book.title, book.author)
			if hooplabook then
				book.tags[#book.tags + 1] = "[hoopla](" .. hooplabook.hoopla .. ")"
			end

			found = found + 1
			reported = true
			report(string.format("%3d", i) .. " " .. book.title .. " -- new audiobook (" .. book.hours .. ")")
			report(data.output(book))
		elseif has_plain_audible then
			-- Already found on Audible; just check whether Hoopla has it too.
			local hooplabook = hoopla.search(book.title, book.author)
			if hooplabook then
				book.tags[#book.tags + 1] = "[hoopla](" .. hooplabook.hoopla .. ")"

				found = found + 1
				reported = true
				report(string.format("%3d", i) .. " " .. book.title .. " -- now also on hoopla")
				report(data.output(book))
			end
		else
			local audiobook2 = audible.search(book.title, book.author)

			-- Audible will put up the page for upcoming books without the time.
			if audiobook2 and audiobook2.hours ~= "00:00" then
				book.hours = audiobook2.hours

				local kept_tags = {}
				for _, t in ipairs(book.tags) do
					if not t:find("^%[hoopla%]") then
						kept_tags[#kept_tags + 1] = t
					end
				end
				book.tags = kept_tags

				local audible_label = audiobook2.exclusive and "Audible Exclusive" or "Audible"
				book.tags[#book.tags + 1] = "[" .. audible_label .. "](" .. audiobook2.audible .. ")"

				found = found + 1
				reported = true
				report(string.format("%3d", i) .. " " .. book.title .. " -- new audiobook (" .. book.hours .. ")")
				report(data.output(book))
			end
		end
	end

	if not reported then
		progress()
	end

	socket.sleep(2)
end

report("Checked " .. #books .. " books, found " .. found .. " new audiobook(s).")
