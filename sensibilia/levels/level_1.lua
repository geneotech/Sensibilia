should_world_be_reloaded = false
changing_gravity = false

level_world = world_class:create()
collectgarbage("collect")
level_world.loop = function(self)
	self:process_all_systems()
	
	if instability > 0.1 then
		call_once_after_loop = function()
			collectgarbage("collect")
			dofile "sensibilia\\levels\\level_2.lua"
			collectgarbage("collect")
		end
	end
	
	return input_system.quit_flag
end

level_world:set_current()
reload_default_level_resources("map_1", "loader.lua", nil)