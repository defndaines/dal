local tag = {}

function tag.parse(list)
	local tags = {}
	if list == nil then
		list = ""
	end

	for t in list:gmatch("[^,]+") do
		tags[#tags + 1] = t:gsub("^%s+", ""):gsub("%s+$", "")
	end

	return tags
end

local positions = {
	["nonfiction"] = 1,
	["DNF"] = 1,
	["classics"] = 3,
	["literary"] = 4,
	["unread country"] = 15,
	["half read"] = 16,
	["[own]"] = 17,
	["[not owned]"] = 17,
	-- formats
	["essays"] = 2,
	["graphic novel"] = 2,
	["light novel"] = 2,
	["manga"] = 2,
	["novelette"] = 2,
	["novella"] = 2,
	["play"] = 2,
	["poetry"] = 2,
	["short stories"] = 2,
	-- major genre
	["biography"] = 5,
	["fantasy"] = 5,
	["historical"] = 5,
	["history"] = 5,
	["horror"] = 5,
	["memoir"] = 5,
	["mystery"] = 5,
	["sci-fi"] = 5,
	["thriller"] = 5,
	-- minor genre
	["Black"] = 6,
	["LGBT"] = 6,
	["Native American"] = 6,
	["YA"] = 6,
	["adventure"] = 6,
	["coming of age"] = 6,
	["contemporary"] = 6,
	["crime"] = 6,
	["dystopian"] = 6,
	["economics"] = 6,
	["humor"] = 6,
	["magical realism"] = 6,
	["mythology"] = 6,
	["noir"] = 6,
	["paranormal"] = 6,
	["politics"] = 6,
	["pulp"] = 6,
	["retelling"] = 6,
	["romance"] = 6,
	["romantasy"] = 6,
	["space opera"] = 6,
	["speculative"] = 6,
	["sword and sorcery"] = 6,
	["time travel"] = 6,
	["true crime"] = 6,
	["urban fantasy"] = 6,
	["war"] = 6,
}

function tag.sort(tags)
	local sorted = {}

	for i = 1, 17 do
		sorted[i] = {}
	end

	for _, t in ipairs(tags) do
		if positions[t] then
			local position = positions[t]
			sorted[position][#sorted[position] + 1] = t
		elseif t:find("^%d") then
			sorted[8][#sorted[8] + 1] = t
		elseif t:find("^%(") then
			sorted[10][#sorted[10] + 1] = t
		elseif t:find("Award") then
			sorted[11][#sorted[11] + 1] = t
		elseif t:find("Prize") then
			sorted[11][#sorted[11] + 1] = t
		elseif t:find("Medal") then
			sorted[11][#sorted[11] + 1] = t
		elseif t:find("-%d") then
			sorted[12][#sorted[12] + 1] = t
		elseif t:find("-rec$") then
			sorted[13][#sorted[13] + 1] = t
		elseif t:find("Audible") then
			sorted[14][#sorted[14] + 1] = t
		elseif t:find("hoopla") then
			sorted[14][#sorted[14] + 1] = t
		elseif t:find("Spotify") then
			sorted[14][#sorted[14] + 1] = t
		elseif t:find("reread") then
			sorted[16][#sorted[16] + 1] = t
		elseif t:find("^[A-Z]") then
			sorted[9][#sorted[9] + 1] = t
		else
			sorted[7][#sorted[7] + 1] = t
		end
	end

	local out = {}
	for _, ts in ipairs(sorted) do
		for _, v in pairs(ts) do
			table.insert(out, v)
		end
	end

	return out
end

return tag
