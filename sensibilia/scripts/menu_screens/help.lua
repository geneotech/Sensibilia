function create_help_screen(back_button_target)

	local menu = level_resources
	
	menu.help_screen = screen_class:create()
	menu.help_screen.buttons = {
		make_button(( { text_size_mult = 1, text_pos = vec2(0, -450-130-config_table.resolution_h/2+100), animated_text_input = { str = "help" } } )), 
		
		--make_button(( { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*0), animated_text_input = { str = "new_game" } } )), 
		
		
		make_button(( { text_pos = vec2(0, -550-130-config_table.resolution_h/2+430+120*0), text_size_mult = 0.2, animated_text_input = { 
				str = "move with" 
		} } )), 
		make_button(( { text_pos = vec2(0, -550-130-config_table.resolution_h/2+430+120*1-30), animated_text_input = { str = "a  d" } } )), 
		
		
		make_button(( { text_pos = vec2(0, -550-130-config_table.resolution_h/2+430+120*2), text_size_mult = 0.2, animated_text_input = { str = "jump with" } } )), 
		make_button(( { text_pos = vec2(0, -550-130-config_table.resolution_h/2+430+120*3-30), animated_text_input = { str = "w" } } )), 
		
		
		make_button(( { text_pos = vec2(0, -550-130-config_table.resolution_h/2+430+120*4), text_size_mult = 0.2, animated_text_input = { str = "instability ray" } } )), 
		make_button(( { text_pos = vec2(0, -550-130-config_table.resolution_h/2+430+120*5-30), animated_text_input = { str = "left mouse button" } } )), 
		
		
		make_button(( { text_pos = vec2(0, -550-130-config_table.resolution_h/2+430+120*6), text_size_mult = 0.2, animated_text_input = { str = "reality check" } } )), 
		make_button(( { text_pos = vec2(0, -550-130-config_table.resolution_h/2+430+120*7-30), animated_text_input = { str = "right mouse button" } } )), 
		
		
		make_button(( { text_pos = vec2(0, -550-130-config_table.resolution_h/2+430+120*8), text_size_mult = 0.2, animated_text_input = { str = "change gravity" } } )), 
		make_button(( { text_pos = vec2(0, -550-130-config_table.resolution_h/2+430+120*9-30), animated_text_input = { str = "g and move mouse" } } )), 
		
		
		make_button(( { text_pos = vec2(0, -550-130-config_table.resolution_h/2+430+120*10), text_size_mult = 0.2, animated_text_input = { str = "slow motion" } } )), 
		make_button(( { text_pos = vec2(0, -550-130-config_table.resolution_h/2+430+120*11-30), animated_text_input = { str = "mouse scroll" } } )), 
		
		make_button(( { text_pos = vec2(0, -550-130-config_table.resolution_h/2+430+120*13), text_size_mult = 1, animated_text_input = { str = "stay in the dream..." } } )), 
		make_button(( { text_pos = vec2(0, -550-130-config_table.resolution_h/2+430+120*15), text_size_mult = 0.3, animated_text_input = { str = "..please just dont wake up." } } )), 
		
		make_button(( { text_pos = vec2(0, -550-130-config_table.resolution_h/2+430+120*17), 
		
		callbacks = {
			mouseclick = function()
				bigger_expand(0)
				menu.current_screen = back_button_target
			end
		},
		
		animated_text_input = { str = "back" } } ))	
	}

end