local function name2node(graph, name)
	local node = graph[name]
	if not node then
		node = { name = name, adj = {} }
		graph[name] = node
	end
	return node
end

function read_graph()
	local graph = {}
	for line in io.lines() do
		local name_from, name_to = string.match(line, "(%S+)%s+(%S+)")
		local from = name2node(graph, name_from)
		local to = name2node(graph, name_to)
		-- adds 'to' to the adjacent set of 'from'
		from.adj[to] = true
	end
	return graph
end

-- breadth-first search
function find_path(curr, to, path, visited)
	path = path or {}
	visited = visited or {}
	if visited[curr] then
		return nil
	end
	visited[curr] = true
	path[#path + 1] = curr
	if curr == to then
		return path
	end
	for node in pairs(curr.adj) do
		local p = find_path(node, to, path, visited)
		if p then
			return p
		end
	end
	table.remove(path)
end

function print_path(path)
	local out = {}
	for i = 1, #path do
		out[i] = path[i].name
	end
	print(table.concat(out, " -> "))
end

g = read_graph()
a = name2node(g, "a")
b = name2node(g, "b")
p = find_path(a, b)
if p then
	print_path(p)
end
