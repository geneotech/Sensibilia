local menu = level_resources

menu.credits_screen = screen_class:create()
menu.credits_screen.buttons = {
	text_button:create(archetyped(menu.menu_button_archetype, { text_size_mult = 1, text_pos = vec2(0, -130-config_table.resolution_h/2+100), animated_text_input = { str = "credits" } } )), 
	
	--text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*0), animated_text_input = { str = "new_game" } } )), 
	
	
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*0), text_size_mult = 0.2, animated_text_input = { 
			str = "lead programmer and originator" 
	} } )), 
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*1-30), animated_text_input = { str = "patryk beniamin czachurski" } } )), 
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*2), text_size_mult = 0.2, animated_text_input = { str = "graphics" } } )), 
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*3-30), animated_text_input = { str = "dominik bartosik" } } )), 
	
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*5), 
	
	callbacks = {
		mouseclick = function() 
			menu.current_screen = menu.main_menu
		end
	},
	
	animated_text_input = { str = "back" } } )) 
}