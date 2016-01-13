local path = minetest.get_modpath("roomgen")
function place_room(vmanip, pos)
	local schematic = path .. "/schems/corridor_X.mts"
	--minetest.place_schematic_on_vmanip(vmanip, pos, schematic, rotation, replacement, force_placement)
	minetest.place_schematic_on_vmanip(vmanip, pos, schematic)
end




local A = 20 -- distance between the centers of the rooms (9 is the best value)
local R = 4

minetest.register_on_mapgen_init(function(params) -- Automatically turn on singlenode generator
	minetest.set_mapgen_params({
		mgname = "singlenode"
	})
end)

local abs = math.abs
local floor = math.floor

function s_dist(n1, n2)
	return abs(n2 - n1)
end

rooms = {}

minetest.register_on_generated(function(minp, maxp, seed)

	local t1 = os.clock()
	local geninfo = "[mg] generates..."
	minetest.chat_send_all(geninfo)

	local schematic = path .. "/schems/corridor_X.mts"
	minetest.place_schematic({x=-R,y=0,z=-R}, schematic)

--	place_room(vm, {x=0,y=0,z=0})
--[[
	local center = {}
	for x=minp.x,maxp.x do
		for z=minp.z,maxp.z do
			for y=minp.y,maxp.y do
				local center_new = {
								x=A*floor((x + A/2)/A), -- these have to be shifted due to the nature of floor function
								y=A*floor((y + A/2)/A),
								z=A*floor((z + A/2)/A),
									}
				if center_new ~= center then
					center = center_new
					place_room(vm, center)
				end
			end
		end
	end
--]]
--[[
				local id = center.x .. "," .. center.y .. "," .. center.z
				if not rooms[id] then
--					print(minetest.serialize(rooms[center]))
					local random = math.random(2)
					if random == 1 then
						rooms[id] = "stone"
					else
						rooms[id] = "empty"
					end
--				else
--					print(minetest.serialize(rooms[id]))
				end

				local p_pos = area:index(x, y, z)

				place_room(vm, center)


				local dx = s_dist(center.x, x)
				local dy = s_dist(center.y, y)
				local dz = s_dist(center.z, z)

				if x == center.x and y == center.y and z == center.z then
					data[p_pos] = minetest.get_content_id("wool:red") -- for debug puproses
				elseif rooms[id] == "empty" then
					if (dx == R and dz <= R and dy <= R) or (dz == R and dx <= R and dy <= R) or (dy == R and dz <= R and dx <= R) then
						data[p_pos] = minetest.get_content_id("default:desert_stonebrick")
					end
				elseif rooms[id] == "stone" then
					if (dx <= R and dz <= R and dy <= R) then
						data[p_pos] = minetest.get_content_id("default:desert_stonebrick")
					end
				end

			end
		end
	end
--]]
	local t2 = os.clock()
	local calcdelay = string.format("%.2fs", t2 - t1)

	local t3 = os.clock()
	local geninfo = "[mg] done after ca.: "..calcdelay.." + "..string.format("%.2fs", t3 - t2).." = "..string.format("%.2fs", t3 - t1)
	print(geninfo)
	minetest.chat_send_all(geninfo)
end)
