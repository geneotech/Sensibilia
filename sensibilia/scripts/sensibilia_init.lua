level_world = world_class:create()
collectgarbage("collect")
level_world.loop = function(self)
	self:process_all_systems()
	return input_system.quit_flag
end

level_world:set_current()
reload_default_level_resources("menu_map", "loader.lua", nil)

input_system:clear_contexts()
input_system:add_context(gui_context)

level_resources.main_input_callback = function(message)
	--print "czo"
	return true
end


animated_menu_text = animated_text:create()
animated_menu_text:set("sensibilia", { font1, font2, font3 }, rgba(255, 255, 255, 255), 100)

level_resources.basic_geometry_callback = function(camera_draw_input)
	local my_text_draw_input = draw_input(camera_draw_input)
	my_text_draw_input.transform.rotation = 0
	
	my_text_draw_input.camera_transform.pos = vec2(0, 0)
	--my_text_draw_input.camera_transform.rotation = 0
	my_text_draw_input.additional_info = nil
	my_text_draw_input.always_visible = true
	
	local my_fstr = animated_menu_text:get_formatted_text()--format_text({ { str = "sensibilia", col = rgba(255, 255, 255, 255), font = font1 }})
	
	local bbox_vec = get_text_bbox(my_fstr, 0)
	
	my_text_draw_input.transform.pos.x = -bbox_vec.x/2
	my_text_draw_input.transform.pos.y = -config_table.resolution_h/2+30
	
	quick_print_text(my_text_draw_input, my_fstr, vec2_i(0, 0), 0)		
end



--dofile "sensibilia\\levels\\level_1.lua"