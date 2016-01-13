local path = minetest.get_modpath("roomgen")

corridors = {
			{name="X"},
			{name="L"},
			{name="T"},
			{name="I"}, -- straight corridor
			{name="E"}, -- E is end
			}

function place_room(center, vm)
	local corridor = corridors[math.random(#corridors)].name

	local schematic = path .. "/schems/corridor_" .. corridor .. ".mts"
	minetest.place_schematic_on_vmanip(vm, center, schematic, "random") -- "random" is for the rotations
end

local A = 9 -- distance between the centers of the rooms (9 is the best value)

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
