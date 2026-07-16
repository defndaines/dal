local hoopla = {}

local json = require("json")
local spider = require("spider")

local script_dir = debug.getinfo(1, "S").source:match("^@(.+)/[^/]+$") or "."
local fetch_script = script_dir .. "/fetch_hoopla.py"

local function shell_escape(str)
	return "'" .. str:gsub("'", "'\\''") .. "'"
end


function hoopla.find_audiobook(data, title, author)
	local hits = data.data and data.data.search and data.data.search.hits
	if not hits then
		return nil
	end

	local clean_author = (author:match("^[^,]+") or author):gsub("%s*%([^)]*%)", "")
	local last_name = clean_author:match("%S+$")
	local clean_title = title:gsub("\xe2\x80\x99", "'"):gsub("\xe2\x80\x98", "'"):lower()

	for _, hit in ipairs(hits) do
		local hit_title = (hit.title or ""):lower()
		local language = hit.language and hit.language.name

		if (hit_title == clean_title
			or hit_title:sub(1, #clean_title) == clean_title
			or clean_title:sub(1, #hit_title) == hit_title)
			and (not language or language == "ENGLISH")
		then
			local artist_name = hit.primaryArtist and hit.primaryArtist.name or ""
			local is_author = artist_name:find(last_name)

			if not is_author then
				for _, a in ipairs(hit.authors or {}) do
					if (a.name or ""):find(last_name) then
						is_author = true
						break
					end
				end
			end

			if is_author then
				return {
					title = hit.title,
					author = artist_name,
					hours = spider.format_seconds(hit.seconds or 0),
					hoopla = "https://www.hoopladigital.com/title/" .. hit.titleId,
				}
			end
		end
	end

	return nil
end

function hoopla.search(title, author)
	if not title or not author then
		return nil
	end

	local s_title = spider.search_title(title)
	local s_author = spider.search_author(author)
	local query = s_title .. " " .. s_author

	local cmd = shell_escape(fetch_script) .. " " .. shell_escape(query)
	local handle = io.popen(cmd)
	if not handle then
		return nil, "fetch_hoopla.py failed to start"
	end
	local result = handle:read("*a")
	handle:close()

	local body, status_str = result:match("^(.*)\n(%d+)%s*$")
	local status = tonumber(status_str)

	if not status or status ~= 200 then
		return nil, "Hoopla search error: " .. tostring(status)
	end

	local data = json.decode(body)
	if not data then
		return nil, "Hoopla JSON parse error"
	end

	local clean_title = title:gsub(":.*", ""):gsub("%s+$", "")
	local audiobook = hoopla.find_audiobook(data, clean_title, author)

	if not audiobook then
		-- Fallback: title-only query (some author names break Hoopla's ranking)
		cmd = shell_escape(fetch_script) .. " " .. shell_escape(s_title)
		handle = io.popen(cmd)
		if handle then
			result = handle:read("*a")
			handle:close()
			body, status_str = result:match("^(.*)\n(%d+)%s*$")
			status = tonumber(status_str)
			if status == 200 then
				data = json.decode(body)
				if data then
					audiobook = hoopla.find_audiobook(data, clean_title, author)
				end
			end
		end
	end

	return audiobook
end

return hoopla
