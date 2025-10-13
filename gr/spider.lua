local spider = {}

--[[
  Install libraries:
    luarocks install luasocket
    luarocks install luasec
    luarocks install lua-zlib
]]

local https = require("ssl.https")
local ltn12 = require("ltn12")
local zlib = require("zlib")

function spider.urlencode(str)
	return str:gsub("([^%w _%%%-%.~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end):gsub(" ", "+")
end

function spider.fetch_url(url)
	local response = {}

	local result, status_code, response_headers = https.request({
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
		local body = table.concat(response)
		local content_encoding = response_headers["content-encoding"] or response_headers["Content-Encoding"]

		if content_encoding and content_encoding:find("gzip") then
			local inflate_stream = zlib.inflate(15 + 16)
			local decompressed, eof, bytes_in, bytes_out = inflate_stream(body)

			if not decompressed then
				error("Failed to decompress gzip data: " .. tostring(eof))
			end

			body = decompressed
		end

		return body
	else
		return nil, status_code
	end
end

return spider
