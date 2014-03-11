level_world = world_class:create()
collectgarbage("collect")
level_world.loop = function(self)
	self:process_all_systems()
	return input_system.quit_flag
end

level_world:set_current()
reload_default_level_resources("menu_map", "loader.lua", nil)

level_resources.basic_geometry_callback = function(camera_draw_input)
			local my_text_draw_input = draw_input(camera_draw_input)
			my_text_draw_input.transform.rotation = 0
			
			my_text_draw_input.camera_transform.pos = vec2(0, 0)
			--my_text_draw_input.camera_transform.rotation = 0
			my_text_draw_input.additional_info = nil
			my_text_draw_input.always_visible = true
			
			local characters = {
				create(formatted_char, {
					r = 255, g = 255, b = 255, a = 255,
					c = towchar("s"), font_used = new_font_object
				}),
				
				create(formatted_char, {
					r = 255, g = 255, b = 255, a = 255,
					c = towchar("e"), font_used = new_font_object
				}),	
				
				create(formatted_char, {
					r = 255, g = 255, b = 255, a = 255,
					c = towchar("n"), font_used = new_font_object
				}),	
				
				create(formatted_char, {
					r = 255, g = 255, b = 255, a = 255,
					c = towchar("s"), font_used = new_font_object
				}),	
				
				create(formatted_char, {
					r = 255, g = 255, b = 255, a = 255,
					c = towchar("i"), font_used = new_font_object
				}),	
				
				create(formatted_char, {
					r = 255, g = 255, b = 255, a = 255,
					c = towchar("b"), font_used = new_font_object
				}),	
				
				create(formatted_char, {
					r = 255, g = 255, b = 255, a = 255,
					c = towchar("i"), font_used = new_font_object
				}),	
				
				create(formatted_char, {
					r = 255, g = 255, b = 255, a = 255,
					c = towchar("l"), font_used = new_font_object
				}),	
				
				create(formatted_char, {
					r = 255, g = 255, b = 255, a = 255,
					c = towchar("i"), font_used = new_font_object
				}),	
				
				create(formatted_char, {
					r = 255, g = 255, b = 255, a = 255,
					c = towchar("a"), font_used = new_font_object
				})
			}
			
			local my_fstr = formatted_text()
			my_fstr:add(characters[1])
			my_fstr:add(characters[2])
			my_fstr:add(characters[3])
			my_fstr:add(characters[4])
			my_fstr:add(characters[5])
			my_fstr:add(characters[6])
			my_fstr:add(characters[7])
			my_fstr:add(characters[8])
			my_fstr:add(characters[9])
			my_fstr:add(characters[10])
			
			
			local bbox_vec = get_text_bbox(my_fstr, 0)
			
			my_text_draw_input.transform.pos.x = -bbox_vec.x/2
			my_text_draw_input.transform.pos.y = -config_table.resolution_h/2+30
			
			quick_print_text(my_text_draw_input, my_fstr, vec2_i(0, 0), 0)		
end



--dofile "sensibilia\\levels\\level_1.lua"