-- Shared error/diagnostic log for the Lua side of the scraper. Keeps noisy
-- retry/WAF/parse diagnostics out of the terminal so stdout stays readable.
local errlog = {}

local script_dir = debug.getinfo(1, "S").source:match("^@(.+)/[^/]+$") or "."
errlog.path = script_dir .. "/errors.log"

function errlog.write(msg)
	local f = io.open(errlog.path, "a")
	if f then
		f:write(os.date("[%H:%M:%S] ") .. msg .. "\n")
		f:close()
	end
end

-- Truncates the log for a fresh run; call once from the entry-point script.
function errlog.reset()
	local f = io.open(errlog.path, "w")
	if f then
		f:close()
	end
end

return errlog
