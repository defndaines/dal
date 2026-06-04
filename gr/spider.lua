local spider = {}

local script_dir = debug.getinfo(1, "S").source:match("^@(.+)/[^/]+$") or "."
local fetch_script = script_dir .. "/fetch_url.py"

function spider.format_seconds(seconds)
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

function spider.search_title(title)
	return title:gsub("'s", ""):gsub(":.*", ""):gsub("%p", " ")
end

function spider.search_author(author)
	return (author:match("^[^,]+") or author):gsub("%s*%([^)]*%)", ""):match("%S+$") or author
end

function spider.urlencode(str)
	return str:gsub("([^%w _%%%-%.~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end):gsub(" ", "+")
end

local function shell_escape(str)
	return "'" .. str:gsub("'", "'\\''") .. "'"
end

local function parse_fetch_result(result)
	local body, status_str = result:match("^(.*)\n(%d+)%s*$")
	local status = tonumber(status_str)

	if not status then
		return nil, "fetch error"
	end

	if status == 200 then
		return body
	end

	if status == 202 then
		io.stderr:write("[spider] Goodreads WAF challenge (202) — run refresh_cookie.sh\n")
	end

	return nil, status
end

function spider.fetch_url(url)
	local cmd = shell_escape(fetch_script) .. " " .. shell_escape(url)

	local handle = io.popen(cmd)
	if not handle then
		return nil, "fetch_url.py failed to start"
	end
	local result = handle:read("*a")
	handle:close()

	return parse_fetch_result(result)
end

function spider.open_fetch(url)
	local cmd = shell_escape(fetch_script) .. " " .. shell_escape(url)
	return io.popen(cmd)
end

function spider.read_fetch(handle)
	local result = handle:read("*a")
	handle:close()
	return parse_fetch_result(result)
end

return spider
