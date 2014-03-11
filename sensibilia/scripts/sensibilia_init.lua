level_world = world_class:create()
collectgarbage("collect")
level_world.loop = function(self)
	self:process_all_systems()
	return input_system.quit_flag
end

level_world:set_current()
reload_default_level_resources("menu_map", "loader.lua", nil)

crosshair_group = create_entity_group {
	body = {
		transform = { pos = vec2(0, 0) }
	},
	
	crosshair = {
		transform = {
			pos = vec2(0, 0),
			rotation = 0
		},
		
		crosshair = {
			sensitivity = config_table.sensitivity,
			size_multiplier = vec2(10, 10)
		},
		
		chase = {
			target = "body",
			relative = true
		},
		
		input = {
			intent_message.AIM
		}
	}
}

level_resources.rendered_crosshair_entity = crosshair_group.crosshair

world_camera.chase:set_target(crosshair_group.body)
world_camera.camera.player:set(crosshair_group.body)
world_camera.camera.crosshair:set(crosshair_group.crosshair)
world_camera.camera.max_look_expand = vec2(40, 40)

input_system:clear_contexts()
input_system:add_context(gui_context)

menu_button_archetype = { 
	bbox_callback = function(bbox, entry) 
		entry.text_pos.x = entry.text_pos.x - bbox.x/2 
	end,

	in_min_interval = 100, 
	in_max_interval = 120, 
	out_min_interval = 2000, 
	out_max_interval = 7000,
	text_size_mult = 0.8,
	callbacks = {},
	text_pos = vec2(0, 0),
	
	animated_text_input = {
		min_interval_ms = 100, 
		max_interval_ms = 120, 
		str = "new game", 
		font_table = { font1, font2, font3 }, 
		color = rgba(255, 255, 255, 255)
	}
}

menu_buttons = {
	text_button:create(archetyped(menu_button_archetype, { text_pos = vec2(0, -config_table.resolution_h/2+430), animated_text_input = { str = "new_game" } } )), 
	text_button:create(archetyped(menu_button_archetype, { text_pos = vec2(0, -config_table.resolution_h/2+630), animated_text_input = { str = "options" } } )), 
	text_button:create(archetyped(menu_button_archetype, { text_pos = vec2(0, -config_table.resolution_h/2+830), animated_text_input = { str = "quit" } } )) 
}

level_resources.main_input_callback = function(message)
	for i=1, #menu_buttons do
		menu_buttons[i]:handle_events(message, crosshair_group.crosshair.transform.current.pos)
	end
	
	--print "czo"
	return true
end


--animated_menu_text = animated_text:create()
--animated_menu_text:set("sensibilia", { font1, font2, font3 }, rgba(255, 255, 255, 255), 100, 120)

level_resources.basic_geometry_callback = function(camera_draw_input)
	local my_text_draw_input = draw_input(camera_draw_input)
	my_text_draw_input.transform.rotation = 0
	
	--my_text_draw_input.camera_transform.pos = vec2(0, 0)
	--my_text_draw_input.camera_transform.rotation = 0
	my_text_draw_input.additional_info = nil
	my_text_draw_input.always_visible = true
	
	--local my_fstr = animated_menu_text:get_formatted_text()--format_text({ { str = "sensibilia", col = rgba(255, 255, 255, 255), font = font1 }})
	--
	--local bbox_vec = get_text_bbox(my_fstr, 0)
	--
	--my_text_draw_input.transform.pos.x = -bbox_vec.x/2
	--my_text_draw_input.transform.pos.y = -config_table.resolution_h/2+30
	--
	--quick_print_text(my_text_draw_input, my_fstr, vec2_i(0, 0), 0)
	
	
	for i=1, #menu_buttons do
		menu_buttons[i]:draw(my_text_draw_input)
	end
end



--dofile "sensibilia\\levels\\level_1.lua"