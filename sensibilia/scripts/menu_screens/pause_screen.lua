local menu = level_resources

menu.pause_screen = screen_class:create()
menu.pause_screen.buttons = {
	make_button(( { text_size_mult = 1, text_pos = vec2(0, -160-config_table.resolution_h/2+100), animated_text_input = { str = "pause" } } )), 
	
	--make_button(( { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*0), animated_text_input = { str = "new_game" } } )), 
	
	
	make_button(( { text_pos = vec2(0, -160-config_table.resolution_h/2+430+150*0-30), 
		
	callbacks = {
		mouseclick = function() 
			call_once_after_loop = unpause_world
		end
	},
	
	animated_text_input = { str = "resume" } } )), 
	
	
	make_button(( { text_pos = vec2(0, -160-config_table.resolution_h/2+430+150*1-30), 
	
	callbacks = {
		mouseclick = function() 
			call_once_after_loop = function()
				bigger_expand(850)
				menu.crosshair_group.crosshair.transform.current.pos.y = menu.crosshair_group.crosshair.transform.current.pos.y - 1600
				menu.current_screen = menu.help_screen
			end
		end
	},
	
	animated_text_input = { str = "help" } } )), 
	
	make_button(( { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*3), 
	
	callbacks = {
		mouseclick = function() 
			call_once_after_loop = function()
				dofile "sensibilia\\scripts\\enter_menu_screen.lua"
			end
		end
	},
	
	animated_text_input = { str = "main menu" } } )) 
}