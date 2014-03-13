level_world = world_class:create()
collectgarbage("collect")

level_world.loop = function(self)
	self:process_all_systems()
	return input_system.quit_flag
end

level_world:set_current()
reload_default_level_resources("menu_map", "loader.lua", nil)

dofile "sensibilia\\levels\\level_util.lua"
dofile "sensibilia\\scripts\\menu_screens\\screen_class.lua"


local menu = level_resources


level_music:stop()
menu_music:play()
menu_music:setLoop(true)
menu_music:setVolume(100)


menu.current_screen = menu.main_menu

menu.main_input_callback = function(message)
	menu.current_screen:handle_events(message)
	
	if message.intent == custom_intents.QUIT then
		input_system.quit_flag = 1
		return false
	end
	
	return true
end

menu.basic_geometry_callback = function(camera_draw_input)
	menu.current_screen:draw(camera_draw_input)
end

