local serialize = minetest.serialize

local function compare(cor1, cor2) -- Compares two tables with positioning information
	for index, item in pairs(cor1) do
		if not ((item == cor2[index]) or (cor2[index] == nil and item == false)) then -- "not item" <-> "item == false"
			return false
		end
	end
	return true
end

local floor = math.floor
local coordinates = {"x", "y", "z"}

local path = minetest.get_modpath("roomgen")

local A = 9 -- distance between the centers of the rooms (9 is the best value)

corridors = {
			{name="X", connect_to = {px=true, pz=true, nx=true, nz=true}},
			{name="I", connect_to = {px=true, nx=true}}, -- straight corridor (rotation angle is 0)
			{name="I", connect_to = {pz=true, nz=true}, rotation = 90},
			{name="L", connect_to = {px=true, nz=true}},
			{name="L", connect_to = {nx=true, nz=true}, rotation = 90}, --
			{name="L", connect_to = {nx=true, pz=true}, rotation = 180},
			{name="L", connect_to = {px=true, pz=true}, rotation = 270},
			{name="E", connect_to = {px=true}}, -- E is end
			{name="E", connect_to = {nz=true}, rotation = 90},
			{name="E", connect_to = {nx=true}, rotation = 180},
			{name="E", connect_to = {pz=true}, rotation = 270},
			{name="T", connect_to = {px=true, pz=true, nz=true}},
			{name="T", connect_to = {px=true, nx=true, nz=true}, rotation = 90},
			{name="T", connect_to = {nx=true, pz=true, nz=true}, rotation = 180},
			{name="T", connect_to = {px=true, nx=true, pz=true}, rotation = 270},
			{name="S", connect_to = {}}, -- A corridor filled with stone (doesn't connect to anything)
			}

placed_corridors = {}

local function check_neighbours(corridor_pos) -- Returns a list of possible corridors
	local x = corridor_pos.x
	local y = corridor_pos.y
	local z = corridor_pos.z

	local px = x + 1
	local py = y + 1
	local pz = z + 1
	local nx = x - 1
	local ny = y - 1
	local nz = z - 1

	local connect_to = {}

	if placed_corridors[px] then
	if placed_corridors[px][y] then
	if placed_corridors[px][y][z] then
	if placed_corridors[px][y][z].nx then
		connect_to.px = true
	else
		connect_to.px = false
	end
	end
	end
	end
	if placed_corridors[x] then
	if placed_corridors[x][py] then
	if placed_corridors[x][py][z] then
	if placed_corridors[x][py][z].ny then
		connect_to.py = true
	else
		connect_to.py = false
	end
	end
	end
	end
	if placed_corridors[x] then
	if placed_corridors[x][y] then
	if placed_corridors[x][y][pz] then
	if placed_corridors[x][y][pz].nz then
		connect_to.pz = true
	else
		connect_to.pz = false
	end
	end
	end
	end
	if placed_corridors[nx] then
	if placed_corridors[nx][y] then
	if placed_corridors[nx][y][z] then
	if placed_corridors[nx][y][z].px then
		connect_to.nx = true
	else
		connect_to.nx = false
	end
	end
	end
	end
	if placed_corridors[x] then
	if placed_corridors[x][ny] then
	if placed_corridors[x][ny][z] then
	if placed_corridors[x][ny][z].py then
		connect_to.ny = true
	else
		connect_to.ny = false
	end
	end
	end
	end
	if placed_corridors[x] then
	if placed_corridors[x][y] then
	if placed_corridors[x][y][nz] then
	if placed_corridors[x][y][nz].pz then
		connect_to.nz = true
	else
		connect_to.nz = false
	end
	end
	end
	end

	local possible_corridors = {} -- Now seaech for the right corridor
	for _, corridor in pairs(corridors) do
		if compare(connect_to, corridor.connect_to) then
			table.insert(possible_corridors, corridor)
		end
	end

	if #possible_corridors > 1 then -- If we can place something besides the dead end we will place it
		for position, corridor in pairs(possible_corridors) do
			local number_of_connections = 0 -- Count how many connections a given room has
			for _, dir in pairs(corridor.connect_to) do
				number_of_connections = number_of_connections + 1
			end
			if number_of_connections == 1 then
				table.remove(possible_corridors, position)
			end
		end
	end

	local corridor
	if #possible_corridors == 1 then
		corridor = possible_corridors[1]
	else
--[[
		for position, itr_corridor in possible_corridors do
			if #itr_corridor.name == "S" then
				corridor = possible_corridors[position]
				print("1")
				break
			end
		end
			print("2")
--]]
		corridor = possible_corridors[math.random(#possible_corridors)]
	end

	if not corridor then
		print("SAVE ME FROM MY LONELINESS. I AM AT " .. serialize(corridor_pos) .. " AND I HAVE " .. serialize(connect_to))
		corridor = corridors[math.random(#corridors)]
	end

	return corridor
end

local function place_room(center, vm)
	local corridor_pos = {}

	for _,coordinate in pairs(coordinates) do
--		corridor_pos[coordinate] = floor(center[coordinate]/A)
		corridor_pos[coordinate] = center[coordinate]/A
	end

	local corridor = check_neighbours(corridor_pos)
	local name = corridor.name
	local rotation = corridor.rotation

	if not rotation then
		rotation = 0
	end

	local schematic = path .. "/schems/corridor_" .. name .. ".mts"
	minetest.place_schematic_on_vmanip(vm, center, schematic, rotation)

	schematic = path .. "/schems/chandelier.mts"
	local chandelier_pos = {x = center.x + 3, y = center.y + 6, z = center.z + 3}
	minetest.place_schematic_on_vmanip(vm, chandelier_pos, schematic)

	if not placed_corridors[corridor_pos.x] then
		placed_corridors[corridor_pos.x] = {}
	end

	if not placed_corridors[corridor_pos.x][corridor_pos.y] then
		placed_corridors[corridor_pos.x][corridor_pos.y] = {}
	end

	placed_corridors[corridor_pos.x][corridor_pos.y][corridor_pos.z] = corridor.connect_to
	check_neighbours(corridor_pos)
end

minetest.register_on_generated(function(minp, maxp, seed)
	local t1 = os.clock()
	local geninfo = "[mg] generates..."

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")

	local center = {}
	for x=minp.x,maxp.x do
		if x % A == 0 then
			center.x = x
			for z=minp.z,maxp.z do
				if z % A == 0 then
					center.z = z
					for y=minp.y,maxp.y do
						if y % A == 0 then
							center.y = y
							place_room(center, vm)
						end
					end
				end
			end
		end
	end

	local t2 = os.clock()
	local calcdelay = string.format("%.2fs", t2 - t1)

	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map()

	local t3 = os.clock()
	local geninfo = "[mg] done after ca.: "..calcdelay.." + "..string.format("%.2fs", t3 - t2).." = "..string.format("%.2fs", t3 - t1)
	print(geninfo)
end)

minetest.register_on_mapgen_init(function(params) -- Automatically turn on singlenode generator
	minetest.set_mapgen_params({
		mgname = "singlenode"
	})
end)
