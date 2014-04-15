global_level_table = {
	{
		caption = "prelude",
		title = "homecoming",
		filename = "sensibilia\\levels\\level_1.lua",
		quote =  
			"Whatever I have accepted until now as most true has come to me through my senses.\nBut occasionally I have found that they have deceived me, and it is unwise to trust completely those who have deceived us even once."
	},
	
	{
		caption = "interval first",
		title = "in crisis",
		filename = "sensibilia\\levels\\level_2.lua",
		quote = 
		"For our ignorance, or at least disagreement about the nature of all things, let us hold on to the conception of DREAM,\nand be free of its any variation which voices an ultimacy: reality, life, death or afterlife."
	},	
	
	{
		caption = "interval second",
		title = "immersion",
		filename = "sensibilia\\levels\\level_3.lua",
		quote = "If there is anything that is ultimate, that would be the last dream ever dreamt."
	},	
	
	{
		caption = "interval third",
		title = "addiction",
		filename = "sensibilia\\levels\\level_4.lua",
		quote = "Yet the stupid believe they are awake, busily and brightly assuming they understand things, calling this man ruler, that one herdsman - how dense!"
	},	
	
	{
		caption = "epilogue",
		title = "step higher",
		filename = "sensibilia\\levels\\level_5.lua",
		quote = "There is no \"True\" Awakening:\none just occasionally comes a step higher in an endless mosaic of realities. "
	}
}

CREDITS_LEVEL = {
	filename = "creditslevel"
}

function load_level (filename, skip_intro)
	if filename == CREDITS_LEVEL.filename then
		dofile "sensibilia\\scripts\\sensibilia_init.lua"
		bigger_expand(300)
		level_resources.crosshair_group.crosshair.transform.current.pos.y = level_resources.crosshair_group.crosshair.transform.current.pos.y - 1000
		level_resources.current_screen = level_resources.credits_screen
	else
		should_world_be_reloaded = false
	
		level_world = world_class:create()
		collectgarbage("collect")
	
		
		level_world:set_current()
	
		stop_all_music()
		
		dofile (filename)
			
		local found_level = -1;
		local next_level = -1;
		
		for i = 1, #global_level_table do
			if global_level_table[i].filename == filename then
				found_level = i
				
				if i < #global_level_table then
					next_level = i + 1
				end			
			end
		end
		
		
		level_resources.CURRENT_LEVEL = global_level_table[found_level]
		
		if next_level > 0 then
			level_resources.NEXT_LEVEL = global_level_table[next_level]
		else
			level_resources.NEXT_LEVEL = CREDITS_LEVEL
			
			if player ~= nil then get_self(player.body:get()).blackout_after_nextlevel = true end
		end
	
		
		if skip_intro == nil or skip_intro == false then
				level_resources.introduction_procedure = coroutine.create(function() 
				clock_music:play()
				
				local my_alpha_animator = value_animator(0, 255, 3000)
				
				level_resources.basic_geometry_callback = function(camera_draw_input)
					local my_fstr = format_text { { str = level_resources.CURRENT_LEVEL.quote, col = rgba(255, 255, 255, my_alpha_animator:get_animated()), font = arial } }
					local bbox = get_text_bbox(my_fstr, 0)
					bbox = vec2(bbox.x, bbox.y)
					
					local input_copy = draw_input(camera_draw_input)
					input_copy.always_visible = true
					input_copy.transform.rotation = 0
					
					input_copy.additional_info = nil
					input_copy.always_visible = true
					input_copy.transform.pos = vec2(config_table.resolution_w, config_table.resolution_h) - bbox - vec2(20, 50)
					input_copy.camera_transform.pos = vec2(0, 0)
					
					quick_print_text(input_copy, my_fstr, vec2_i(0, 0), 1, 0)
				end
				
	
				input_system:clear_contexts()
				input_system:add_context(cutscene_context)
				
				level_resources.draw_geometry = false
				level_world.is_paused = true
				
				coroutine.wait(6000, nil, true)
				
				level_resources.basic_geometry_callback = nil
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
	
		world_camera_self:set_zoom_level(1000)
	end
end