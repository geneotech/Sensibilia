local menu = level_resources

menu.credits_screen = screen_class:create()
menu.credits_screen.buttons = {
	make_button(( { text_size_mult = 1, text_pos = vec2(0, -330-config_table.resolution_h/2+100), animated_text_input = { str = "thank you for playing" } } )), 
	
	--make_button(( { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*0), animated_text_input = { str = "new_game" } } )), 
	
	
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+150*0), text_size_mult = 0.2, animated_text_input = { 
			str = "programmer and originator" 
	} } )), 
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+150*1-30), animated_text_input = { str = "patryk beniamin czachurski" } } )), 
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+150*2), text_size_mult = 0.2, animated_text_input = { str = "graphics" } } )), 
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+150*3-30), animated_text_input = { str = "dominik bartosik" } } )), 
	
	
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+150*5), text_size_mult = 0.6, animated_text_input = { str = "created for" } } )), 
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+150*7-100), text_size_mult = 0.75, animated_text_input = { str = "microsoft imaginecup contest" } } )), 
	
	
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+150*9-100), 
	
	callbacks = {
		mouseclick = function() 
			bigger_expand(0)
			menu.current_screen = menu.main_menu
		end
	},
	
	animated_text_input = { str = "main menu" } } )) 
}