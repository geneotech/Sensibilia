CURRENT_LEVEL = "sensibilia\\maps\\example_map"

should_world_be_reloaded = false
changing_gravity = false

level_1_world = world_class:create() 
level_1_world.loop = function(self)
	self:process_all_systems()
	
	if should_world_be_reloaded then
		call_once_after_loop = function()
			collectgarbage("collect")
			dofile "init.lua"
			collectgarbage("collect")
		end
	end
	
	return input_system.quit_flag
end

level_1_world:set_current()

dofile "sensibilia\\scripts\\settings.lua"
dofile "sensibilia\\scripts\\sensibilia.lua"
