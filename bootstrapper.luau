local libraryUrl = "https://raw.githubusercontent.com/nemilyia/bootstrapper/refs/heads/main/library.strap"

local placeId = tostring(game.PlaceId)

local function fetch(url: string): string?
	local ok, result = pcall(game.HttpGet, game, url)
	if not ok then
		warn(`Bootstrapper: Failed to fetch {url}: {result}`)
		return nil
	end
	return result
end

local function parseStrap(raw: string): { [string]: string }
	local entries: { [string]: string } = {}
	for line in raw:gmatch("[^\n]+") do
		local key, value = line:match("^([^:]+):(.+)$")
		if key and value then
			entries[key:match("^%s*(.-)%s*$")] = value:match("^%s*(.-)%s*$")
		end
	end
	return entries
end

local function parseOrder(raw: string): { [number]: string }
	local order: { [number]: string } = {}
	for line in raw:gmatch("[^\n]+") do
		local index, url = line:match("^(%d+):(.+)$")
		if index and url then
			order[tonumber(index) :: number] = url:match("^%s*(.-)%s*$")
		end
	end
	return order
end

local libraryRaw = fetch(libraryUrl)
if not libraryRaw then return end

local library = parseStrap(libraryRaw)
local orderUrl = library[placeId]

if not orderUrl then
	warn(`Bootstrapper: No entry for place {placeId} in library.strap`)
	return
end

local orderRaw = fetch(orderUrl)
if not orderRaw then return end

local order = parseOrder(orderRaw)

local keys: { number } = {}
for k in order do
	table.insert(keys, k)
end
table.sort(keys)

for _, index in keys do
	local scriptUrl = order[index]
	local source = fetch(scriptUrl)
	if not source then
		warn(`Bootstrapper: Skipping entry {index}, failed to fetch {scriptUrl}`)
		continue
	end
	local ok, err = pcall(loadstring(source))
	if not ok then
		warn(`Bootstrapper: Entry {index} errored: {err}`)
	end
end
