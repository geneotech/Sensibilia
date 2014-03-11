

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

level_resources.basic_geometry_callback = function(camera_draw_input)
	local my_text_draw_input = draw_input(camera_draw_input)
	my_text_draw_input.transform.rotation = 0
	
	my_text_draw_input.camera_transform.pos = vec2(0, 0)
	--my_text_draw_input.camera_transform.rotation = 0
	my_text_draw_input.additional_info = nil
	my_text_draw_input.always_visible = true
	
	local my_fstr = format_text({ { str = "sensibilia", col = rgba(255, 255, 255, 255), font = new_font_object }})
	
	local bbox_vec = get_text_bbox(my_fstr, 0)
	
	my_text_draw_input.transform.pos.x = -bbox_vec.x/2
	my_text_draw_input.transform.pos.y = -config_table.resolution_h/2+30
	
	quick_print_text(my_text_draw_input, my_fstr, vec2_i(0, 0), 0)		
end



--dofile "sensibilia\\levels\\level_1.lua"