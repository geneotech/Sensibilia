local menu = level_resources

menu.load_chapter_screen = screen_class:create()
menu.load_chapter_screen.buttons = {
	text_button:create(archetyped(menu.menu_button_archetype, { text_size_mult = 1, text_pos = vec2(0, -330-config_table.resolution_h/2+100), animated_text_input = { str = "load chapter" } } )), 
	
	--text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*0), animated_text_input = { str = "new_game" } } )), 
	
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*0), text_size_mult = 0.2, animated_text_input = { 
			str = "prelude" 
	} } )), 
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*1-30), 
		callbacks = {
			mouseclick = function() 
				call_once_after_loop = function()
					dofile "sensibilia\\levels\\level_1.lua"
				end
			end
		},
	
	animated_text_input = { str = "homecoming" } } )), 
	
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*2), text_size_mult = 0.2, animated_text_input = { str = "interval first" } } )), 
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*3-30), 
		callbacks = {
			mouseclick = function() 
				call_once_after_loop = function()
					dofile "sensibilia\\levels\\level_2.lua"
				end
			end
		},
	
	animated_text_input = { str = "in crisis" } } )), 
	
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*4), text_size_mult = 0.2, animated_text_input = { str = "interval second" } } )), 
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*5-30), animated_text_input = { str = "immersion" } } )), 
	
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*6), text_size_mult = 0.2, animated_text_input = { str = "interval third" } } )), 
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*7-30), animated_text_input = { str = "addiction" } } )), 
	
	
	text_button:create(archetyped(menu.menu_button_archetype, { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*9), 
	
	callbacks = {
		mouseclick = function() 
			menu.current_screen = menu.main_menu
		end
	},
	
	animated_text_input = { str = "back" } } )) 
}