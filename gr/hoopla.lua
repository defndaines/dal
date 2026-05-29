local hoopla = {}

local json = require("json")

local script_dir = debug.getinfo(1, "S").source:match("^@(.+)/[^/]+$") or "."
local fetch_script = script_dir .. "/fetch_hoopla.py"

local function shell_escape(str)
	return "'" .. str:gsub("'", "'\\''") .. "'"
end

local function format_seconds(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60

	if s >= 30 then
		m = m + 1
		if m == 60 then
			h = h + 1
			m = 0
		end
	end

	return string.format("%02d:%02d", h, m)
end

function hoopla.find_audiobook(data, title, author)
	local hits = data.data and data.data.search and data.data.search.hits
	if not hits then
		return nil
	end

	local last_name = author:match("%S+$")
	local clean_title = title:lower()

	for _, hit in ipairs(hits) do
		local hit_title = (hit.title or ""):lower()

		if hit_title == clean_title or hit_title:sub(1, #clean_title) == clean_title then
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
					hours = format_seconds(hit.seconds or 0),
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

	local s_title = title:gsub("'s", ""):gsub(":.*", ""):gsub("%p", " ")
	local s_author = author:gsub("%s*%([^)]*%)", ""):gsub(":", ""):gsub("%.(%S)", "%1")
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
	return hoopla.find_audiobook(data, clean_title, author)
end

return hoopla
