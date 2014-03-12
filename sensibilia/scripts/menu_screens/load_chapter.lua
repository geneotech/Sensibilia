local menu = level_resources

menu.load_chapter_screen = screen_class:create()
menu.load_chapter_screen.buttons = {
	make_button(( { text_size_mult = 1, text_pos = vec2(0, -330-config_table.resolution_h/2+100), animated_text_input = { str = "load chapter" } } )), 
	
	--make_button(( { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*0), animated_text_input = { str = "new_game" } } )), 
	
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*0), text_size_mult = 0.2, animated_text_input = { 
			str = "prelude" 
	} } )), 
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*1-30), 
		callbacks = {
			mouseclick = function() 
				call_once_after_loop = function()
					dofile "sensibilia\\levels\\level_1.lua"
				end
			end
		},
	
	animated_text_input = { str = "homecoming" } } )), 
	
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*2), text_size_mult = 0.2, animated_text_input = { str = "interval first" } } )), 
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*3-30), 
		callbacks = {
			mouseclick = function() 
				call_once_after_loop = function()
					dofile "sensibilia\\levels\\level_2.lua"
				end
			end
		},
	
	animated_text_input = { str = "in crisis" } } )), 
	
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*4), text_size_mult = 0.2, animated_text_input = { str = "interval second" } } )), 
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*5-30), animated_text_input = { str = "immersion" } } )), 
	
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*6), text_size_mult = 0.2, animated_text_input = { str = "interval third" } } )), 
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*7-30), animated_text_input = { str = "addiction" } } )), 
	
	
	make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*9), 
	
	callbacks = {
		mouseclick = function() 
			menu.current_screen = menu.main_menu
		end
	},
	
	animated_text_input = { str = "back" } } )) 
}