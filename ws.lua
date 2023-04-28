local size = 8
local volt = 1638
local max = 16383

local MODE = 1;

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

function keyOf(table, value)
    for k, v in pairs(table) do
        if v == value then
            return k
        end
    end
    return nil
end

function log(x)
    print(x)
    return x 
end

function reducePitch(pitchRatio)
    if pitchRatio >= 1 and pitchRatio < 2 then
        return pitchRatio
    elseif pitchRatio >= 2 then
        return reducePitch(pitchRatio / 2)
    else
        return reducePitch(pitchRatio * 2)
    end
end

function createTonalityDiamond(n)
    local otonals = {}

    for i = 1, n do
        otonals[i] = reducePitch(1 + ((i - 1) * 2))
    end
    table.sort(otonals)

    local utonals = {}
    for i = 1, n do
        utonals[i] = reducePitch(1/otonals[i])
    end

    local m = {}
    for i = 1, n do 
        m[i] = {}
        for j = 1, n do 
            m[i][j] = reducePitch(otonals[j] * utonals[i])
        end
    end

    return m
end

local diamond = createTonalityDiamond(3)



function matrix(n) 
    local m = {} 

    for i = 1, n*n do 
        m[i] = {}
        for j = 1, n*n do 
            m[i][j] = 0
        end 
    end 

    local function posToIndex(x,y)
        return (y-1)*n + x
    end

    for i = 1,n do
        for j = 1,n do
            local index = posToIndex(i,j)

            if i > 1 then
                m[index][posToIndex(i-1,j)] = 1
            end

            if i < n then
                m[index][posToIndex(i+1,j)] = 1
            end

            if j > 1 then
                m[index][posToIndex(i,j-1)] = 1
            end

            if j < n then
                m[index][posToIndex(i,j+1)] = 1
            end
        end
    end

    return m
end

function bfs(matrix, start_node, visited)
    local queue = {start_node}

    while #queue > 0 do
        local node = table.remove(queue, 1)
        visited[node] = true

        for neighbor, weight in pairs(matrix[node]) do
            if weight > 0 and not visited[neighbor] then
                table.insert(queue, neighbor)
            end
        end

        for neighbor, weight in pairs(matrix[node]) do 
            if weight > 0 and not visited[neighbor] then
                return {neighbor, visited}
            end
        end
    end

    if #queue == 0 then
        print("im full!")
        return {start_node, {}}
    end
end

function dfs(graph, current_node, visited)
    visited[current_node] = true

    let neighbors = graph[current_node]
    
    for neihgbor, weight in pairs(neighbors) do
        if weight > 1 and not visited[neighbor] then
            return dfs(graph, neighbor, visited)
        end
    end

    for neihgbor, weight in pairs(neighbors) do
        if weight == 1 and not visited[neighbor] then
            return {neighbor, visited}
        end
    end

    for neihgbor, weight in pairs(neighbors) do
        if not visited[neihgbor] then 
            visited[neighbor] = true 
            return {neighbor, visited}
        end
    end


    return {current_node, visited}
end

-- local circle_of_fifths = {0, 7, 2, 9, 4, 11, 6, 1, 8, 3, 10, 5}

local diamond = createTonalityDiamond(size)
local graph = matrix(size)
local visited = {}

local current_node = 1
local start_node = 1

function init()
    print("hiiiiiii :3") 
end

function index_to_pos(index, n)
    -- indexes diamond with node id
    x = ((index - 1) % n) + 1
    y = (math.floor((index - 1) / n)) + 1

    return {x, y}
end

-- Call are useful to send args from TT to crow
function ii.self.call1(x)
    MODE = x;

    print(dump(visited))
    print("reset!")
    visited = {}
    current_node = start_node
end

-- query: useful to send args from TT to crow, with crow returning a single value
function ii.self.query0()
    local value;

    if MODE == 0 then
        value = bfs(graph, current_node, visited)
    else MODE == 1 then
        value = dfs(graph, current_node, visited)
    end
    
    current_node, visited = table.unpack(bfs(graph, current_node, visited))
    local x, y = table.unpack(index_to_pos(current_node, size))
    return diamond[x][y] * volt
end 

function note(current_node, size)
    local x, y = table.unpack(index_to_pos(current_node, size))
    return math.floor((math.log(diamond[x][y]) / math.log(2)) * volt)
end


current_node, visited = table.unpack(bfs(graph, start_node, visited))
print("first visited: " .. dump(visited))
print("first current_node: " .. current_node)
print("first note: " .. note(current_node, size))

current_node, visited = table.unpack(bfs(graph, current_node, visited))
print("visited: " .. dump(visited))
print("current_node: " .. current_node)
print("note: " .. note(current_node, size))

current_node, visited = table.unpack(bfs(graph, current_node, visited))
print("visited: " .. dump(visited))
print("current_node: " .. current_node)
print("note: " .. note(current_node, size))

current_node, visited = table.unpack(bfs(graph, current_node, visited))
print("visited: " .. dump(visited))
print("current_node: " .. current_node)
print("note: " .. note(current_node, size))

