should_world_be_reloaded = false

level_world = world_class:create()
collectgarbage("collect")
level_world.loop = function(self)
	self:process_all_systems()
	
	if instability > 0.1 then
		call_once_after_loop = function()
			collectgarbage("collect")
			dofile "sensibilia\\levels\\level_1.lua"
			collectgarbage("collect")
		end
	end
	
	return input_system.quit_flag
end

level_world:set_current()
reload_default_level_resources("map_2", "loader.lua", nil)