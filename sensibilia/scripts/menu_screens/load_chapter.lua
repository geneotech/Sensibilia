local menu = level_resources

menu.load_chapter_screen = screen_class:create()
menu.load_chapter_screen.buttons = {
	make_button(( { text_size_mult = 1, text_pos = vec2(0, -330-config_table.resolution_h/2+100), animated_text_input = { str = "load chapter" } } )), 
	
	--make_button(( { text_pos = vec2(0, -130-config_table.resolution_h/2+430+150*0), animated_text_input = { str = "new_game" } } )), 
	
}

for i=1, #global_level_table do
	table.insert(menu.load_chapter_screen.buttons,
		make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*((i-1)*2)), text_size_mult = 0.2, animated_text_input = { 
				str = global_level_table[i].caption 
		} } )))
		
		
	table.insert(menu.load_chapter_screen.buttons,
		make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*((i-1)*2+1)-30), 
		callbacks = {
			mouseclick = function() 
				call_once_after_loop = function()
					load_level (global_level_table[i].filename)
				end
			end
		},
	
	animated_text_input = { str = global_level_table[i].title } } ))) 
end
	
table.insert(menu.load_chapter_screen.buttons,

make_button(( { text_pos = vec2(0, -330-config_table.resolution_h/2+430+120*11), 

callbacks = {
	mouseclick = function() 
		menu.current_screen = menu.main_menu
	end
},

animated_text_input = { str = "back" } } )) )