local menu = level_resources

menu.main_menu = screen_class:create()
menu.main_menu.buttons = {
	make_button(( { text_size_mult = 1, text_pos = vec2(0, -130-config_table.resolution_h/2+100), animated_text_input = { str = "sensibilia" } } )), 
	
	make_button(( { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*0), 
	
		callbacks = {
			mouseclick = function() 
				call_once_after_loop = function()
					load_level (global_level_table[1].filename)
				end
			end
		},
	
	animated_text_input = { str = "new_game" } } )), 
	make_button(( { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*1), 
		callbacks = {
			mouseclick = function()
				bigger_expand(300)
				menu.crosshair_group.crosshair.transform.current.pos.y = menu.crosshair_group.crosshair.transform.current.pos.y - 900
				menu.current_screen = menu.load_chapter_screen
			end
		},
	
	animated_text_input = { str = "load chapter" } } )), 
	make_button(( { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*2), animated_text_input = { str = "options" } } )), 
	
	make_button(( { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*3), 
		callbacks = {
			mouseclick = function()
				bigger_expand(850)
				menu.crosshair_group.crosshair.transform.current.pos.y = menu.crosshair_group.crosshair.transform.current.pos.y - 1600
				menu.current_screen = menu.help_screen
			end
		},

	animated_text_input = { str = "help" } } )), 
	
	make_button(( { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*4), 
		
		callbacks = {
			mouseclick = function()
				bigger_expand(300)
				menu.crosshair_group.crosshair.transform.current.pos.y = menu.crosshair_group.crosshair.transform.current.pos.y - 1000
				menu.current_screen = menu.credits_screen
			end
		},
		
	animated_text_input = { str = "credits" } } )), 
	
	make_button(( { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*5), 
	
	callbacks = {
		mouseclick = function() 
			input_system.quit_flag = 1
		end
	},
	
	animated_text_input = { str = "quit" } } )) 
}