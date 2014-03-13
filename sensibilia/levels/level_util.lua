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
	},	
	
	{
		caption = "interval second",
		title = "immersion",
		filename = "sensibilia\\levels\\level_1.lua"
	},	
	
	{
		caption = "interval third",
		title = "immersion",
		filename = "sensibilia\\levels\\level_1.lua"
	}
}

function load_level (filename, skip_intro)
	should_world_be_reloaded = false

	level_world = world_class:create()
	collectgarbage("collect")

	

	
	level_world:set_current()

	stop_all_music()
	
	dofile (filename)
	
	if skip_intro == nil or skip_intro == false then
			level_resources.introduction_procedure = coroutine.create(function() 
			clock_music:play()
			input_system:clear_contexts()
			input_system:add_context(cutscene_context)
			
			level_resources.draw_geometry = false
			level_world.is_paused = true
			
			coroutine.wait(5000, nil, true)
			
			level_resources.draw_geometry = true
			level_world.is_paused = false
			
			input_system:clear_contexts()
			input_system:add_context(main_context)
			clock_music:stop()
			if level_resources.after_introduction_callback then level_resources.after_introduction_callback() end
		end)
	else
		level_resources.introduction_procedure = coroutine.create(function() 
			if level_resources.after_introduction_callback then level_resources.after_introduction_callback() end
		end)
	end
	

	
	level_world.loop = function(self)
		if level_resources.introduction_procedure ~= nil and coroutine.status(level_resources.introduction_procedure) ~= "dead" then
			coroutine.resume(level_resources.introduction_procedure)
		end
		
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
	
	local found_level;
	local next_level;
	
	for i = 1, #global_level_table do
		if global_level_table[i].filename == filename then
			found_level = i
			
			if i < #global_level_table then
				next_level = i + 1
			end			
		end
	end
	
	
	level_resources.CURRENT_LEVEL = global_level_table[found_level]
	
	if next_level ~= nil then
		level_resources.NEXT_LEVEL = global_level_table[next_level]
	end
	
	current_zoom_level = 1000
	set_zoom_level(world_camera)
end