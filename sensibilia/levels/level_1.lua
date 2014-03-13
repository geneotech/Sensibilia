should_world_be_reloaded = false

level_world = world_class:create()
collectgarbage("collect")
level_world.loop = function(self)
	self:process_all_systems()
	
	if should_world_be_reloaded then
		call_once_after_loop = function()
			collectgarbage("collect")
			dofile "sensibilia\\levels\\level_1.lua"
			collectgarbage("collect")
		end
	end
	
	return input_system.quit_flag
end

level_world:set_current()
reload_default_level_resources("map_1", "loader.lua", nil)

	current_zoom_level = 1000
	set_zoom_level(world_camera)
	
menu_music:stop()
level_music:play()