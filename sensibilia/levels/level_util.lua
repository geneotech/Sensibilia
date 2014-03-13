global_level_table = {
	{
		caption = "prelude",
		title = "homecoming",
		filename = "sensibilia\\levels\\level_1.lua"
	},
	
	{
		caption = "interval first",
		title = "in crisis",
		filename = "sensibilia\\levels\\level_2.lua"
	}
}

function load_level (filename)
	should_world_be_reloaded = false

	level_world = world_class:create()
	collectgarbage("collect")

	level_world:set_current()
	
	level_world.loop = function(self)
	self:process_all_systems()
	
	if should_world_be_reloaded then
		call_once_after_loop = function()
				collectgarbage("collect")
				load_level(filename)
				collectgarbage("collect")
			end
		end
		
		return input_system.quit_flag
	end

	stop_all_music()
	
	dofile (filename)
	
	--local found_level 
	--
	--level_resources.NEXT_LEVEL = 
	
	current_zoom_level = 1000
	set_zoom_level(world_camera)
end