local MIN_GENERATION_HEIGHT = -1000


-- ----------------------------------------------------------------------------
-- Helpers:

local serialize = minetest.serialize

local function compare(cor1, cor2) -- Compares two tables with positioning information
	for index, item in pairs(cor1) do
		if not ((item == cor2[index]) or (cor2[index] == nil and item == false)) then -- "not item" <-> "item == false"
			return false
		end
	end
	return true
end

-- ----------------------------------------------------------------------------
-- Constants:

local coordinates = {"x", "y", "z"}

local path = minetest.get_modpath("roomgen")

local A = 9 -- distance between the centers of the rooms (9 is the best value)

-- ----------------------------------------------------------------------------
-- Corridor registration:

-- Places treasure in the treasureroom and fixes metal bars
local function place_treasure(ctr, rotation, vm)
    local next_pos

    if rotation == 0 then
        next_pos = {x = ctr.x + 2,
                    y = ctr.y + 1,
                    z = ctr.z + 4}
    elseif rotation == 90 then
        next_pos = {x = ctr.x + 5,
                    y = ctr.y + 1,
                    z = ctr.z + 8}
    elseif rotation == 180 then
        next_pos = {x = ctr.x + 8,
                    y = ctr.y + 1,
                    z = ctr.z + 5}
    elseif rotation == 270 then
        next_pos = {x = ctr.x + 4,
                    y = ctr.y + 1,
                    z = ctr.z + 2}
    end
    
    local meta = minetest.get_meta(next_pos)

    local chest_formspec =
	    "size[8,9]" ..
	    default.gui_bg ..
	    default.gui_bg_img ..
	    default.gui_slots ..
	    "list[current_name;main;0,0.3;8,4;]" ..
	    "list[current_player;main;0,4.85;8,1;]" ..
	    "list[current_player;main;0,6.08;8,3;8]" ..
	    "listring[current_name;main]" ..
	    "listring[current_player;main]" ..
	    default.get_hotbar_bg(0,4.85)
    
    meta:set_string("formspec", chest_formspec)
	meta:set_string("infotext", "Chest")
	local inv = meta:get_inventory()
	inv:set_size("main", 8*4)

	local function fill_chest(inv)
	    local function add(itm)
	        inv:add_item("main", itm)
	        --minetest.debug("adding " .. itm .. " at " .. minetest.serialize(next_pos))
	    end
	
        if math.random(3) == 1 then
            add("default:dirt" .. " " .. tostring(math.random(99)))
        end
        if math.random(3) == 1 then
            add("default:stone" .. " " .. tostring(math.random(99)))
        end
        if math.random(3) == 1 then
            add("default:apple" .. " " .. tostring(math.random(99)))
        end
        --[[
        if math.random(5) == 1 then -- picks
            local picks = {"wood",
                           "stone",
                           "steel",
                           "bronze",
                           "mese",
                           "diamond"}
            add("default:pick_" .. picks[math.random(#picks)] .. " " .. "1")
        end
        if math.random(5) == 1 then -- shovels
            local picks = {"wood",
                           "stone",
                           "steel",
                           "bronze",
                           "mese",
                           "diamond"}
            add("default:shovel_" .. picks[math.random(#picks)] .. " " .. "1")
        end
        if math.random(5) == 1 then -- axes
            local picks = {"wood",
                           "stone",
                           "steel",
                           "bronze",
                           "mese",
                           "diamond"}
            add("default:axe_" .. picks[math.random(#picks)] .. " " .. "1")
        end
        if math.random(5) == 1 then -- swords
            local picks = {"wood",
                           "stone",
                           "steel",
                           "bronze",
                           "mese",
                           "diamond"}
            add("default:sword_" .. picks[math.random(#picks)] .. " " .. "1")
        end
        --]]
        --[[
        if math.random(5) == 1 then -- dyes
            local picks = {"white", "grey", "black", "red", "yellow", "green", "cyan", "blue", "magenta"}
            add("dye:" .. picks[math.random(#picks)] .. " " .. tostring(math.random(99)))
        end
        --]]
        if math.random(20) == 1 then
            add("default:diamond" .. " " .. tostring(math.random(99)))
        end
        if math.random(3) == 1 then
            add("default:coalblock" .. " " .. tostring(math.random(99)))
        end
        if math.random(3) == 1 then
            add("default:wood" .. " " .. tostring(math.random(99)))
        end
        if math.random(3) == 1 then
            add("default:clay" .. " " .. tostring(math.random(99)))
        end
        if math.random(3) == 1 then
            add("farming:wheat" .. " " .. tostring(math.random(99)))
        end
        if math.random(3) == 1 then
            add("farming:flour" .. " " .. tostring(math.random(99)))
        end
        if math.random(3) == 1 then
            add("farming:bread" .. " " .. tostring(math.random(99)))
        end
        --if math.random(3) == 1 then
        --    add("farming:cotton" .. " " .. tostring(math.random(99)))
        --end
        if math.random(3) == 1 then
            add("farming:straw" .. " " .. tostring(math.random(99)))
        end
        if math.random(20) == 1 then
            add("default:nyancat" .. " " .. tostring(math.random(3)))
            add("default:nyancat_rainbow" .. " " .. tostring(math.random(20)))
        end
        if math.random(20) == 1 then
            add("default:gold_lump" .. " " .. tostring(math.random(20)))
        end
	end
	
	fill_chest(inv)
	fill_chest(inv)
	fill_chest(inv)
end
--[[
local function place_staircase(ctr, rotation, vm)
	local schematic = path .. "/schems/staircase.mts"
	local chandelier_pos = {x = ctr.x + 3, y = ctr.y + 1, z = ctr.z + 3}
	minetest.place_schematic_on_vmanip(vm, chandelier_pos, schematic)
end

local function place_staircase_passage(ctr, rotation, vm)
	local schematic = path .. "/schems/staircase_passage.mts"
	local chandelier_pos = {x = ctr.x + 3, y = ctr.y, z = ctr.z + 3}
	minetest.place_schematic_on_vmanip(vm, chandelier_pos, schematic)
end

local function place_UD_staircase(ctr, rotation, vm)
    place_staircase(ctr, rotation, vm)
    place_staircase_passage(ctr, rotation, vm)
end
--]]

local function place_ladder_UP(ctr, rotation, vm)
	local schematic = path .. "/schems/ladder_UP.mts"
	local chandelier_pos = {x = ctr.x + 3, y = ctr.y + 1, z = ctr.z + 3}
	minetest.place_schematic_on_vmanip(vm, chandelier_pos, schematic)
end

local function place_ladder_DOWN(ctr, rotation, vm)
	local schematic = path .. "/schems/ladder_DOWN.mts"
	local chandelier_pos = {x = ctr.x + 3, y = ctr.y, z = ctr.z + 3}
	minetest.place_schematic_on_vmanip(vm, chandelier_pos, schematic)
end

local function place_ladder_UP_DOWN(ctr, rotation, vm)
	local schematic = path .. "/schems/ladder_UP_DOWN.mts"
	local chandelier_pos = {x = ctr.x + 3, y = ctr.y, z = ctr.z + 3}
	minetest.place_schematic_on_vmanip(vm, chandelier_pos, schematic)
end

corridors = {}

-- String ConnectTo Boolean Boolean (Pos Rotation VoxelManip -> (Void)) -> (Void)
-- Add given corridor to the corridors list
function register_corridor(name, connect_to, rotate, staircase, after)
    local function rotate_connect(connect_to)
        local rsf = {} -- rsf: ConnectTo; result so far accumulator
        local connection, state
        for connection, state in pairs(connect_to) do
           if connection == "px" and state then
               rsf.nz = true
           end
           if connection == "nz" and state then
               rsf.nx = true
           end
           if connection == "nx" and state then
               rsf.pz = true
           end
           if connection == "pz" and state then
               rsf.px = true
           end
        end
        
        return rsf
    end

    local rsf = {} -- rsf: Corridor; result so far accumulator
    table.insert(rsf, {name=name, connect_to = connect_to})
    if rotate then
        local A = rotate_connect(connect_to)
        local B = rotate_connect(A)
        local C = rotate_connect(B)
		table.insert(rsf, {name=name, connect_to = A, rotation =  90})
		table.insert(rsf, {name=name, connect_to = B, rotation = 180})
		table.insert(rsf, {name=name, connect_to = C, rotation = 270})
    end
    
    if after then
        for n,i in ipairs(rsf) do
            i.after = after
        end
    end
    
    for _,i in ipairs(rsf) do
        table.insert(corridors, i)
    end
end

register_corridor("corridor_X", {px=true, pz=true, nx=true, nz=true}, true, true)
register_corridor("corridor_I", {px=true, nx=true}, true, true)
register_corridor("corridor_L", {px=true, nz=true}, true, true)
register_corridor("corridor_E", {px=true}, true, true)
register_corridor("corridor_T", {px=true, pz=true, nz=true}, true, true)
register_corridor("corridor_S", {}, false, false)

--register_corridor("corridor_X", {px=true, pz=true, nx=true, nz=true, py=true}, true, true, place_ladder_UP)
--register_corridor("corridor_I", {px=true, nx=true, py=true}, true, true, place_ladder_UP)
--register_corridor("corridor_L", {px=true, nz=true, py=true}, true, true, place_ladder_UP)
--register_corridor("corridor_E", {px=true, py=true}, true, true, place_ladder_UP)
--register_corridor("corridor_T", {px=true, pz=true, nz=true, py=true}, true, true, place_ladder_UP)
--register_corridor("corridor_UD", {py=true}, false, false, place_ladder_UP)

--register_corridor("corridor_X", {px=true, pz=true, nx=true, nz=true, ny=true}, true, true, place_ladder_DOWN)
--register_corridor("corridor_I", {px=true, nx=true, ny=true}, true, true, place_ladder_DOWN)
--register_corridor("corridor_L", {px=true, nz=true, ny=true}, true, true, place_ladder_DOWN)
--register_corridor("corridor_E", {px=true, ny=true}, true, true, place_ladder_DOWN)
--register_corridor("corridor_T", {px=true, pz=true, nz=true, ny=true}, true, true, place_ladder_DOWN)
--register_corridor("corridor_UD", {ny=true}, false, false, place_ladder_DOWN)

--register_corridor("corridor_X", {px=true, pz=true, nx=true, nz=true, py=true, ny=true}, true, true, place_ladder_UP_DOWN)
--register_corridor("corridor_I", {px=true, nx=true, py=true, ny=true}, true, true, place_ladder_UP_DOWN)
--register_corridor("corridor_L", {px=true, nz=true, py=true, ny=true}, true, true, place_ladder_UP_DOWN)
--register_corridor("corridor_E", {px=true, py=true, ny=true}, true, true, place_ladder_UP_DOWN)
--register_corridor("corridor_T", {px=true, pz=true, nz=true, py=true, ny=true}, true, true, place_ladder_UP_DOWN)
--register_corridor("corridor_UD", {py=true, ny=true}, false, false, place_ladder_UP_DOWN)

register_corridor("treasureroom_1", {px=true}, false, false, place_treasure)

-- ----------------------------------------------------------------------------
-- Functions and Variables:

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

	if #possible_corridors > 1 then
	    -- If we can place something besides the dead end we will place it
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
	
		-- If it is possible not to place a ladder in the highly connected room, don't place it
	for position, corridor in pairs(possible_corridors) do
--		if #possible_corridors > 1 then
		    if corridor.connect_to.py or corridor.connect_to.ny then
		        table.remove(possible_corridors, position)
		    end
--		end
	end

	local corridor
	if #possible_corridors == 1 then
		corridor = possible_corridors[1]
	else
	if #possible_corridors == 0 then
	    print("ERROR: NOT ENOUGH CORRIDORS")
	    return {name="corridor_S", connect_to = {}}
	end
		corridor = possible_corridors[math.random(#possible_corridors)]
		for position, itr_corridor in pairs(possible_corridors) do
			if itr_corridor.name == "S" and math.random(10) ~= 1 then
				corridor = itr_corridor
				break
			end
		end
	end

	if not corridor then
		print("SAVE ME FROM MY LONELINESS. I AM AT " .. serialize(corridor_pos) .. " AND I HAVE " .. serialize(connect_to))
		corridor = corridors[math.random(#corridors)]
	end

	return corridor
end

minetest.register_node("roomgen:light", {
    description = "Light",
    drawtype = "airlike",
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    climbable = false,
    paramtype = "light",
    light_source = 12,
    sunlight_propagates = true,
    groups = {not_in_creative_inventory=1},
})

local function place_room(center, vm)
	local corridor_pos = {}

	for _,coordinate in pairs(coordinates) do
		corridor_pos[coordinate] = center[coordinate]/A
	end

	local corridor = check_neighbours(corridor_pos)
	local name = corridor.name

	if not placed_corridors[corridor_pos.x] then
		placed_corridors[corridor_pos.x] = {}
	end

	if not placed_corridors[corridor_pos.x][corridor_pos.y] then
		placed_corridors[corridor_pos.x][corridor_pos.y] = {}
	end

	placed_corridors[corridor_pos.x][corridor_pos.y][corridor_pos.z] = corridor.connect_to
	check_neighbours(corridor_pos)


	if corridor.name == "S" then
		return -- if it is stone, don't place anything
	end

	local rotation = corridor.rotation

	if not rotation then
		rotation = 0
	end
	
	local replacements = corridor.replacements

    if not replacements then
        replacements = {}
    end

    replacements["air"] = "roomgen:light"

	local schematic = path .. "/schems/" .. name .. ".mts"
	minetest.place_schematic_on_vmanip(vm, center, schematic, rotation, replacements)
	
	if corridor.after then
	    corridor.after(center, rotation, vm)
	end

--[[
	schematic = path .. "/schems/chandelier.mts"
	local chandelier_pos = {x = center.x + 3, y = center.y + 6, z = center.z + 3}
	minetest.place_schematic_on_vmanip(vm, chandelier_pos, schematic)
--]]
end

minetest.register_on_generated(function(minp, maxp, seed)
    if (maxp.y > MIN_GENERATION_HEIGHT) then
        return
    end

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
