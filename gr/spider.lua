local spider = {}

--[[
  Install libraries:
    luarocks install luasocket
    luarocks install luasec
]]

local https = require("ssl.https")
local ltn12 = require("ltn12")

function spider.urlencode(str)
	return str:gsub("([^%w _%%%-%.~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end):gsub(" ", "+")
end

function spider.fetch_url(url)
	local response = {}

	local result, status_code = https.request({
		url = url,
		method = "GET",
		headers = {
			["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
				.. " AppleWebKit/537.36 (KHTML, like Gecko)"
				.. " Chrome/138.0.0.0 Safari/537.36",
		},
		sink = ltn12.sink.table(response),
	})

	if result and status_code == 200 then
		return table.concat(response)
	else
		return nil, status_code
	end
end


return spider
