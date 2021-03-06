-- Note: diggers go in group 3 and have an execute_dig method.

local digger_nodebox = {
	{-0.5, -0.5, 0, 0.5, 0.5, 0.4375}, -- Block
	{-0.4375, -0.3125, 0.4375, 0.4375, 0.3125, 0.5}, -- Cutter1
	{-0.3125, -0.4375, 0.4375, 0.3125, 0.4375, 0.5}, -- Cutter2
	{-0.5, -0.125, -0.125, 0.5, 0.125, 0}, -- BackFrame1
	{-0.125, -0.5, -0.125, 0.125, 0.5, 0}, -- BackFrame2
	{-0.25, -0.25, -0.5, 0.25, 0.25, 0}, -- Drive
}

local dual_digger_nodebox = {
	{-0.5, -0.4375, 0, 0.5, 0.5, 0.4375}, -- Block
	{-0.4375, -0.3125, 0.4375, 0.4375, 0.3125, 0.5}, -- Cutter1
	{-0.3125, -0.4375, 0.4375, 0.3125, 0.4375, 0.5}, -- Cutter2
	{-0.5, 0, -0.125, 0.5, 0.125, 0}, -- BackFrame1
	{-0.25, 0, -0.5, 0.25, 0.25, 0}, -- Drive
	{-0.25, 0.25, -0.25, 0.25, 0.5, 0}, -- Upper_Drive
	{-0.5, -0.4375, -0.5, 0.5, 0, 0.4375}, -- Lower_Block
	{-0.3125, -0.5, -0.4375, 0.3125, -0.4375, 0.4375}, -- Lower_Cutter_1
	{-0.4375, -0.5, -0.3125, 0.4375, -0.4375, 0.3125}, -- Lower_Cutter_2
}

local intermittent_formspec = 
	default.gui_bg ..
	default.gui_bg_img ..
	default.gui_slots ..
	"field[0.5,0.8;1,0.1;period;Periodicity;${period}]" ..
	"tooltip[period;Digger will dig once every n steps.\nThese steps are globally aligned, all diggers with\nthe same period and offset will dig on the same location.]" ..
	"field[1.5,0.8;1,0.1;offset;Offset;${offset}]" ..
	"tooltip[offset;Offsets the start of periodicity counting by this amount.\nFor example, a digger with period 2 and offset 0 digs\nevery even-numbered block and one with period 2 and\noffset 1 digs every odd-numbered block.]" ..
	"button_exit[2.2,0.5;1,0.1;set;Save]" ..
	"tooltip[set;Saves settings]"

local intermittent_on_construct = function(pos)
	local formspec = intermittent_formspec
	if minetest.get_modpath("doc") then
		formspec = "size[4.5,1]" .. formspec ..
		"button_exit[3.2,0.5;1,0.1;help;Help]" ..
		"tooltip[help;Show documentation about this block]"
	else
		formspec = "size[3.5,1]" .. formspec
	end
    local meta = minetest.get_meta(pos)
    meta:set_string("formspec", formspec)
	meta:set_int("period", 1) 
	meta:set_int("offset", 0) 
end

local intermittent_on_receive_fields = function(pos, formname, fields, sender)
    local meta = minetest.get_meta(pos)
	local period = tonumber(fields.period)
	local offset = tonumber(fields.offset)
	if  period and period > 0 then
		meta:set_int("period", math.floor(period))
	end
	if offset then
		meta:set_int("offset", math.floor(offset))
	end
	if fields.help and minetest.get_modpath("doc") then --check for mod in case someone disabled it after this digger was built
		local node_name = minetest.get_node(pos).name
		doc.show_entry(sender:get_player_name(), "nodes", node_name)
	end
end,

-- Digs out nodes that are "in front" of the digger head.
minetest.register_node("digtron:digger", {
	description = "Digtron Digger Head",
	_doc_items_longdesc = digtron.doc.digger_longdesc,
    _doc_items_usagehelp = digtron.doc.digger_usagehelp,
	groups = {cracky = 3,  oddly_breakable_by_hand=3, digtron = 3},
	drop = "digtron:digger",
	sounds = digtron.metal_sounds,
	paramtype = "light",
	paramtype2= "facedir",
	is_ground_content = false,	
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = digger_nodebox,
	},
	
	-- Aims in the +Z direction by default
	tiles = {
		"digtron_plate.png^[transformR90",
		"digtron_plate.png^[transformR270",
		"digtron_plate.png",
		"digtron_plate.png^[transformR180",
		{
			name = "digtron_digger_yb.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0,
			},
		},
		"digtron_plate.png^digtron_motor.png",
	},

	-- returns fuel_cost, item_produced
	execute_dig = function(pos, protected_nodes, nodes_dug, controlling_coordinate, lateral_dig)
		local facing = minetest.get_node(pos).param2
		local digpos = digtron.find_new_pos(pos, facing)

		if protected_nodes:get(digpos.x, digpos.y, digpos.z) then
			return 0, {}
		end
		
		return digtron.mark_diggable(digpos, nodes_dug)
	end,
	
	damage_creatures = function(player, pos, controlling_coordinate)
		local facing = minetest.get_node(pos).param2
		digtron.damage_creatures(player, digtron.find_new_pos(pos, facing), 8)
	end,
})

-- Digs out nodes that are "in front" of the digger head.
minetest.register_node("digtron:intermittent_digger", {
	description = "Digtron Intermittent Digger Head",
	_doc_items_longdesc = digtron.doc.intermittent_digger_longdesc,
    _doc_items_usagehelp = digtron.doc.intermittent_digger_usagehelp,
	groups = {cracky = 3,  oddly_breakable_by_hand=3, digtron = 3},
	drop = "digtron:intermittent_digger",
	sounds = digtron.metal_sounds,
	paramtype = "light",
	paramtype2= "facedir",
	is_ground_content = false,	
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = digger_nodebox,
	},
	
	-- Aims in the +Z direction by default
	tiles = {
		"digtron_plate.png^[transformR90",
		"digtron_plate.png^[transformR270",
		"digtron_plate.png",
		"digtron_plate.png^[transformR180",
		{
			name = "digtron_digger_yb.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0,
			},
		},
		"digtron_plate.png^digtron_intermittent.png^digtron_motor.png",
	},
	
	on_construct = intermittent_on_construct,
	
	on_receive_fields = intermittent_on_receive_fields,

	-- returns fuel_cost, item_produced
	execute_dig = function(pos, protected_nodes, nodes_dug, controlling_coordinate, lateral_dig)
		if lateral_dig == true then
			return 0, {}
		end

		local facing = minetest.get_node(pos).param2
		local digpos = digtron.find_new_pos(pos, facing)

		if protected_nodes:get(digpos.x, digpos.y, digpos.z) then
			return 0, {}
		end
		
		local meta = minetest.get_meta(pos)
		if (digpos[controlling_coordinate] + meta:get_int("offset")) % meta:get_int("period") ~= 0 then
			return 0, {}
		end
		
		return digtron.mark_diggable(digpos, nodes_dug)
	end,
	
	damage_creatures = function(player, pos, controlling_coordinate)
		local facing = minetest.get_node(pos).param2
		local targetpos = digtron.find_new_pos(pos, facing)
		local meta = minetest.get_meta(pos)
		if (targetpos[controlling_coordinate] + meta:get_int("offset")) % meta:get_int("period") == 0 then
			digtron.damage_creatures(player, targetpos, 8)
		end
	end
})

-- A special-purpose digger to deal with stuff like sand and gravel in the ceiling. It always digs (no periodicity or offset), but it only digs falling_block nodes
minetest.register_node("digtron:soft_digger", {
	description = "Digtron Soft Material Digger Head",
	_doc_items_longdesc = digtron.doc.soft_digger_longdesc,
    _doc_items_usagehelp = digtron.doc.soft_digger_usagehelp,
	groups = {cracky = 3,  oddly_breakable_by_hand=3, digtron = 3},
	drop = "digtron:soft_digger",
	sounds = digtron.metal_sounds,
	paramtype = "light",
	paramtype2= "facedir",
	is_ground_content = false,	
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = digger_nodebox,
	},
	
	-- Aims in the +Z direction by default
	tiles = {
		"digtron_plate.png^[transformR90^[colorize:" .. digtron.soft_digger_colorize,
		"digtron_plate.png^[transformR270^[colorize:" .. digtron.soft_digger_colorize,
		"digtron_plate.png^[colorize:" .. digtron.soft_digger_colorize,
		"digtron_plate.png^[transformR180^[colorize:" .. digtron.soft_digger_colorize,
		{
			name = "digtron_digger_yb.png^[colorize:" .. digtron.soft_digger_colorize,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0,
			},
		},
		"digtron_plate.png^digtron_motor.png^[colorize:" .. digtron.soft_digger_colorize,
	},
	
	execute_dig = function(pos, protected_nodes, nodes_dug, controlling_coordinate, lateral_dig)
		local facing = minetest.get_node(pos).param2
		local digpos = digtron.find_new_pos(pos, facing)
		
		if protected_nodes:get(digpos.x, digpos.y, digpos.z) then
			return 0, {}
		end
			
		if digtron.is_soft_material(digpos) then
			return digtron.mark_diggable(digpos, nodes_dug)
		end
		
		return 0, {}
	end,

	damage_creatures = function(player, pos, controlling_coordinate)
		local facing = minetest.get_node(pos).param2
		digtron.damage_creatures(player, digtron.find_new_pos(pos, facing), 4)
	end,
})

minetest.register_node("digtron:intermittent_soft_digger", {
	description = "Digtron Intermittent Soft Material Digger Head",
	_doc_items_longdesc = digtron.doc.intermittent_soft_digger_longdesc,
    _doc_items_usagehelp = digtron.doc.intermittent_soft_digger_usagehelp,
	groups = {cracky = 3,  oddly_breakable_by_hand=3, digtron = 3},
	drop = "digtron:intermittent_soft_digger",
	sounds = digtron.metal_sounds,
	paramtype = "light",
	paramtype2= "facedir",
	is_ground_content = false,
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = digger_nodebox,
	},
	
	-- Aims in the +Z direction by default
	tiles = {
		"digtron_plate.png^[transformR90^[colorize:" .. digtron.soft_digger_colorize,
		"digtron_plate.png^[transformR270^[colorize:" .. digtron.soft_digger_colorize,
		"digtron_plate.png^[colorize:" .. digtron.soft_digger_colorize,
		"digtron_plate.png^[transformR180^[colorize:" .. digtron.soft_digger_colorize,
		{
			name = "digtron_digger_yb.png^[colorize:" .. digtron.soft_digger_colorize,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0,
			},
		},
		"digtron_plate.png^digtron_intermittent.png^digtron_motor.png^[colorize:" .. digtron.soft_digger_colorize,
	},
	
	on_construct = intermittent_on_construct,
	
	on_receive_fields = intermittent_on_receive_fields,

	execute_dig = function(pos, protected_nodes, nodes_dug, controlling_coordinate, lateral_dig)
		if lateral_dig == true then
			return 0, {}
		end

		local facing = minetest.get_node(pos).param2
		local digpos = digtron.find_new_pos(pos, facing)
		
		if protected_nodes:get(digpos.x, digpos.y, digpos.z) then
			return 0, {}
		end
		
		local meta = minetest.get_meta(pos)
		if (digpos[controlling_coordinate] + meta:get_int("offset")) % meta:get_int("period") ~= 0 then
			return 0, {}
		end
		
		if digtron.is_soft_material(digpos) then
			return digtron.mark_diggable(digpos, nodes_dug)
		end
		
		return 0, {}
	end,

	damage_creatures = function(player, pos, controlling_coordinate)
		local meta = minetest.get_meta(pos)
		local facing = minetest.get_node(pos).param2
		local targetpos = digtron.find_new_pos(pos, facing)		
		if (targetpos[controlling_coordinate] + meta:get_int("offset")) % meta:get_int("period") == 0 then
			digtron.damage_creatures(player, targetpos, 4)
		end
	end,
})

-- Digs out nodes that are "in front" of the digger head and "below" the digger head (can be rotated).
minetest.register_node("digtron:dual_digger", {
	description = "Digtron Dual Digger Head",
	_doc_items_longdesc = digtron.doc.dual_digger_longdesc,
    _doc_items_usagehelp = digtron.doc.dual_digger_usagehelp,
	groups = {cracky = 3,  oddly_breakable_by_hand=3, digtron = 3},
	drop = "digtron:dual_digger",
	sounds = digtron.metal_sounds,
	paramtype = "light",
	paramtype2= "facedir",
	is_ground_content = false,	
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = dual_digger_nodebox,
	},
	
	-- Aims in the +Z and -Y direction by default
	tiles = {
		"digtron_plate.png^digtron_motor.png",
		{
			name = "digtron_digger_yb.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0,
			},
		},
		"digtron_plate.png",
		"digtron_plate.png^[transformR180",
		{
			name = "digtron_digger_yb.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0,
			},
		},
		"digtron_plate.png^digtron_motor.png",
	},

	-- returns fuel_cost, items_produced
	execute_dig = function(pos, protected_nodes, nodes_dug, controlling_coordinate, lateral_dig)
		local facing = minetest.get_node(pos).param2
		local digpos = digtron.find_new_pos(pos, facing)
		local digdown = digtron.find_new_pos_downward(pos, facing)

		local items = {}
		local cost = 0
		
		if protected_nodes:get(digpos.x, digpos.y, digpos.z) ~= true then
			local forward_cost, forward_items = digtron.mark_diggable(digpos, nodes_dug)
			for _, item in pairs(forward_items) do
				table.insert(items, item)
			end
			cost = cost + forward_cost
		end
		if protected_nodes:get(digdown.x, digdown.y, digdown.z) ~= true then
			local down_cost, down_items = digtron.mark_diggable(digdown, nodes_dug)
			for _, item in pairs(down_items) do
				table.insert(items, item)
			end
			cost = cost + down_cost
		end
		
		return cost, items
	end,
	
	damage_creatures = function(player, pos, controlling_coordinate)
		local facing = minetest.get_node(pos).param2
		digtron.damage_creatures(player, digtron.find_new_pos(pos, facing), 8)
		digtron.damage_creatures(player, digtron.find_new_pos_downward(pos, facing), 8)
	end,
})

-- Digs out soft nodes that are "in front" of the digger head and "below" the digger head (can be rotated).
minetest.register_node("digtron:dual_soft_digger", {
	description = "Digtron Dual Soft Material Digger Head",
	_doc_items_longdesc = digtron.doc.dual_soft_digger_longdesc,
    _doc_items_usagehelp = digtron.doc.dual_soft_digger_usagehelp,
	groups = {cracky = 3,  oddly_breakable_by_hand=3, digtron = 3},
	drop = "digtron:dual_soft_digger",
	sounds = digtron.metal_sounds,
	paramtype = "light",
	paramtype2= "facedir",
	is_ground_content = false,	
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = dual_digger_nodebox,
	},
	
	-- Aims in the +Z and -Y direction by default
	tiles = {
		"digtron_plate.png^digtron_motor.png^[colorize:" .. digtron.soft_digger_colorize,
		{
			name = "digtron_digger_yb.png^[colorize:" .. digtron.soft_digger_colorize,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0,
			},
		},
		"digtron_plate.png^[colorize:" .. digtron.soft_digger_colorize,
		"digtron_plate.png^[transformR180^[colorize:" .. digtron.soft_digger_colorize,
		{
			name = "digtron_digger_yb.png^[colorize:" .. digtron.soft_digger_colorize,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0,
			},
		},
		"digtron_plate.png^digtron_motor.png^[colorize:" .. digtron.soft_digger_colorize,
	},

	-- returns fuel_cost, items_produced
	execute_dig = function(pos, protected_nodes, nodes_dug, controlling_coordinate, lateral_dig)
		local facing = minetest.get_node(pos).param2
		local digpos = digtron.find_new_pos(pos, facing)
		local digdown = digtron.find_new_pos_downward(pos, facing)

		local items = {}
		local cost = 0
		
		if protected_nodes:get(digpos.x, digpos.y, digpos.z) ~= true and digtron.is_soft_material(digpos) then
			local forward_cost, forward_items = digtron.mark_diggable(digpos, nodes_dug)
			for _, item in pairs(forward_items) do
				table.insert(items, item)
			end
			cost = cost + forward_cost
		end
		if protected_nodes:get(digdown.x, digdown.y, digdown.z) ~= true and digtron.is_soft_material(digdown) then
			local down_cost, down_items = digtron.mark_diggable(digdown, nodes_dug)
			for _, item in pairs(down_items) do
				table.insert(items, item)
			end
			cost = cost + down_cost
		end
		
		return cost, items
	end,
	
	damage_creatures = function(player, pos, controlling_coordinate)
		local facing = minetest.get_node(pos).param2
		digtron.damage_creatures(player, digtron.find_new_pos(pos, facing), 4)
		digtron.damage_creatures(player, digtron.find_new_pos_downward(pos, facing), 4)
	end,
})