local spider = {}

local script_dir = debug.getinfo(1, "S").source:match("^@(.+)/[^/]+$") or "."
local fetch_script = script_dir .. "/fetch_url.py"

function spider.urlencode(str)
	return str:gsub("([^%w _%%%-%.~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end):gsub(" ", "+")
end

local function shell_escape(str)
	return "'" .. str:gsub("'", "'\\''") .. "'"
end

function spider.fetch_url(url)
	local cmd = shell_escape(fetch_script) .. " " .. shell_escape(url)

	local handle = io.popen(cmd)
	if not handle then
		return nil, "fetch_url.py failed to start"
	end
	local result = handle:read("*a")
	handle:close()

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

return spider
