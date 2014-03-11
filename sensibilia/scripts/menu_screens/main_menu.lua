local menu = level_resources

menu.main_menu = screen_class:create()
menu.main_menu.buttons = {
	text_button:create(archetyped(menu.menu_button_archetype, { text_size_mult = 1, text_pos = vec2(0, -130-config_table.resolution_h/2+100), animated_text_input = { str = "sensibilia" } } )), 
	
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*0), animated_text_input = { str = "new_game" } } )), 
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*1), 
		callbacks = {
			mouseclick = function()
				bigger_expand(100)
				menu.crosshair_group.crosshair.transform.current.pos.y = menu.crosshair_group.crosshair.transform.current.pos.y - 700
				menu.current_screen = menu.load_chapter_screen
			end
		},
	
	animated_text_input = { str = "load chapter" } } )), 
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*2), animated_text_input = { str = "options" } } )), 
	
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*3), 
		callbacks = {
			mouseclick = function()
				bigger_expand(700)
				menu.crosshair_group.crosshair.transform.current.pos.y = menu.crosshair_group.crosshair.transform.current.pos.y - 1000
				menu.current_screen = menu.help_screen
			end
		},

	animated_text_input = { str = "help" } } )), 
	
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*4), 
		
		callbacks = {
			mouseclick = function()
				menu.crosshair_group.crosshair.transform.current.pos.y = menu.crosshair_group.crosshair.transform.current.pos.y - 700
				menu.current_screen = menu.credits_screen
			end
		},
		
	animated_text_input = { str = "credits" } } )), 
	
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*5), 
	
	callbacks = {
		mouseclick = function() 
			input_system.quit_flag = 1
		end
	},
	
	animated_text_input = { str = "quit" } } )) 
}