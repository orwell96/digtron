-- Storage buffer. Builder nodes draw from this inventory and digger nodes deposit into it.
-- Note that inventories are digtron group 2.
minetest.register_node("digtron:inventory", {
	description = "Digtron Inventory Storage",
	_doc_items_longdesc = digtron.doc.inventory_longdesc,
    _doc_items_usagehelp = digtron.doc.inventory_usagehelp,
	groups = {cracky = 3,  oddly_breakable_by_hand=3, digtron = 2, tubedevice = 1, tubedevice_receiver = 1},
	drop = "digtron:inventory",
	sounds = digtron.metal_sounds,
	paramtype2= "facedir",
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	tiles = {"digtron_plate.png^digtron_inventory.png"},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", 
			"size[8,9.3]" ..
			default.gui_bg ..
			default.gui_bg_img ..
			default.gui_slots ..
			"label[0,0;Inventory items]" ..
			"list[current_name;main;0,0.6;8,4;]" ..
			"list[current_player;main;0,5.15;8,1;]" ..
			"list[current_player;main;0,6.38;8,3;8]" ..
			"listring[current_name;main]" ..
			"listring[current_player;main]" ..
			default.get_hotbar_bg(0,5.15)
		)
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
	end,
	
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	
	-- Pipeworks compatibility
	----------------------------------------------------------------

	tube = (function() if minetest.get_modpath("pipeworks") then return {
		insert_object = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:add_item("main", stack)
		end,
		can_insert = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:room_for_item("main", stack)
		end,
		input_inventory = "main",
		connect_sides = {left = 1, right = 1, back = 1, front = 1, bottom = 1, top = 1}
	} end end)(),
	
	after_place_node = (function() if minetest.get_modpath("pipeworks") then return pipeworks.after_place end end)(),
	after_dig_node = (function() if minetest.get_modpath("pipeworks") then return pipeworks.after_dig end end)()
})

-- Fuel storage. Controller node draws fuel from here.
-- Note that fuel stores are digtron group 5.
minetest.register_node("digtron:fuelstore", {
	description = "Digtron Fuel Storage",
	_doc_items_longdesc = digtron.doc.fuelstore_longdesc,
    _doc_items_usagehelp = digtron.doc.fuelstore_usagehelp,
	groups = {cracky = 3,  oddly_breakable_by_hand=3, digtron = 5, tubedevice = 1, tubedevice_receiver = 1},
	drop = "digtron:fuelstore",
	sounds = digtron.metal_sounds,
	paramtype2= "facedir",
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	tiles = {"digtron_plate.png^digtron_fuelstore.png"},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", 
			"size[8,9.3]" ..
			default.gui_bg ..
			default.gui_bg_img ..
			default.gui_slots ..
			"label[0,0;Fuel items]" ..
			"list[current_name;fuel;0,0.6;8,4;]" ..
			"list[current_player;main;0,5.15;8,1;]" ..
			"list[current_player;main;0,6.38;8,3;8]" ..
			"listring[current_name;fuel]" ..
			"listring[current_player;main]" ..
			default.get_hotbar_bg(0,5.15)
		)
		local inv = meta:get_inventory()
		inv:set_size("fuel", 8*4)
	end,
	
	-- Only allow fuel items to be placed in fuel
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		if listname == "fuel" then
			if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then
				return stack:get_count()
			else
				return 0
			end
		end
		return 0
	end,
	
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("fuel")
	end,
	
	-- Pipeworks compatibility
	----------------------------------------------------------------

	tube = (function() if minetest.get_modpath("pipeworks") then return {
		insert_object = function(pos, node, stack, direction)
			if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				return inv:add_item("fuel", stack)
			end
			return stack
		end,
		can_insert = function(pos, node, stack, direction)
			if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				return inv:room_for_item("fuel", stack)
			end
			return false
		end,
		input_inventory = "fuel",
		connect_sides = {left = 1, right = 1, back = 1, front = 1, bottom = 1, top = 1}
	} end end)(),
	
	after_place_node = (function() if minetest.get_modpath("pipeworks") then return pipeworks.after_place end end)(),
	after_dig_node = (function() if minetest.get_modpath("pipeworks")then return pipeworks.after_dig end end)()
})

-- Combined storage. Group 6 has both an inventory and a fuel store
minetest.register_node("digtron:combined_storage", {
	description = "Digtron Combined Storage",
	_doc_items_longdesc = digtron.doc.combined_storage_longdesc,
    _doc_items_usagehelp = digtron.doc.combined_storage_usagehelp,
	groups = {cracky = 3,  oddly_breakable_by_hand=3, digtron = 6, tubedevice = 1, tubedevice_receiver = 1},
	drop = "digtron:combined_storage",
	sounds = digtron.metal_sounds,
	paramtype2= "facedir",
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	tiles = {"digtron_plate.png^digtron_combined_storage.png"},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", 
			"size[8,9.9]" ..
			default.gui_bg ..
			default.gui_bg_img ..
			default.gui_slots ..
			"label[0,0;Inventory items]" ..
			"list[current_name;main;0,0.6;8,3;]" ..
			"label[0,3.5;Fuel items]" ..
			"list[current_name;fuel;0,4.1;8,1;]" ..
			"list[current_player;main;0,5.75;8,1;]" ..
			"list[current_player;main;0,6.98;8,3;8]" ..
			"listring[current_name;fuel]" ..
			"listring[current_player;main]" ..
			default.get_hotbar_bg(0,5.75)
		)
		local inv = meta:get_inventory()
		inv:set_size("main", 8*3)
		inv:set_size("fuel", 8*1)
	end,
	
	-- Only allow fuel items to be placed in fuel
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		if listname == "fuel" then
			if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then
				return stack:get_count()
			else
				return 0
			end
		end
		return stack:get_count() -- otherwise, allow all drops
	end,
	
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if to_list == "main" then
			return count
		end
		
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack(from_list, from_index)
		if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then
			return stack:get_count()
		end
		return 0
	end,
	
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("fuel") and inv:is_empty("main")
	end,
	
	-- Pipeworks compatibility
	----------------------------------------------------------------
	tube = (function() if minetest.get_modpath("pipeworks") then return {
		insert_object = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 and direction.y == 1 then
				return inv:add_item("fuel", stack)
			end
			return inv:add_item("main", stack)
		end,
		can_insert = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 and direction.y == 1 then
				return inv:room_for_item("fuel", stack)
			end
			return inv:room_for_item("main", stack)
		end,
		input_inventory = "main",
		connect_sides = {left = 1, right = 1, back = 1, front = 1, bottom = 1, top = 1}
	} end end)(),
	
	after_place_node = (function() if minetest.get_modpath("pipeworks") then return pipeworks.after_place end end)(),
	after_dig_node = (function() if minetest.get_modpath("pipeworks") then return pipeworks.after_dig end end)()
})

-- Hopper compatibility
if minetest.get_modpath("hopper") and hopper ~= nil and hopper.add_source ~= nil and hopper.add_destination ~= nil then
	hopper.add_source("hopper:hopper", "digtron:inventory", "main")
	hopper.add_source("hopper:hopper", "digtron:fuelstore", "fuel")
	hopper.add_source("hopper:hopper", "digtron:combined_storage", "main")
	hopper.add_destination("hopper:hopper", "digtron:inventory", "main")
	hopper.add_destination("hopper:hopper", "digtron:fuelstore", "fuel")
	hopper.add_destination("hopper:hopper", "digtron:combined_storage", "main")

	hopper.add_source("hopper:hopper_side", "digtron:inventory", "main")
	hopper.add_source("hopper:hopper_side", "digtron:fuelstore", "fuel")
	hopper.add_source("hopper:hopper_side", "digtron:combined_storage", "main")
	hopper.add_destination("hopper:hopper_side", "digtron:inventory", "main")
	hopper.add_destination("hopper:hopper_side", "digtron:fuelstore", "fuel")
	hopper.add_destination("hopper:hopper_side", "digtron:combined_storage", "fuel")
end
