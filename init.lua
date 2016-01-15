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
			}

placed_corridors = {}

function mind_neighbours(center) -- Checks what blocks are placed near given block
	connect_to = {}
	local dist = A + 1
	nx = {x = center.x - dist, y = center.y, z = center.z}
end

function place_room(center, vm)
	local corridor = corridors[math.random(#corridors)]
	local name = corridor.name
	local rotation = corridor.rotation

	if not rotation then
		rotation = 0
	end

	local schematic = path .. "/schems/corridor_" .. name .. ".mts"
	minetest.place_schematic_on_vmanip(vm, center, schematic, rotation)

	table.insert(placed_corridors, corridor)
end

minetest.register_on_mapgen_init(function(params) -- Automatically turn on singlenode generator
	minetest.set_mapgen_params({
		mgname = "singlenode"
	})
end)

rooms = {}
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

	vm:calc_lighting(nil, nil, false)
	vm:write_to_map()

	local t3 = os.clock()
	local geninfo = "[mg] done after ca.: "..calcdelay.." + "..string.format("%.2fs", t3 - t2).." = "..string.format("%.2fs", t3 - t1)
	print(geninfo)
end)
