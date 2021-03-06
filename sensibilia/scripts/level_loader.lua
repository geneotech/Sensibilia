function reload_default_level_resources(
		map_filename, 
		map_loader_filename, 
		gameplay_textures -- optional, if not provided then switching to default gameplay textures
		)
		
	-- destruct previous level data
	level_resources = {}
	collectgarbage("collect")
	
	local prev_filename = MAP_FILENAME
	MAP_FILENAME = "sensibilia\\maps\\" .. map_filename
	MAP_LOADER_FILENAME = "sensibilia\\maps\\" .. map_loader_filename
	GAMEPLAY_TEXTURES = gameplay_textures
	
	
	if prev_filename == nil or MAP_FILENAME ~= prev_filename then
		dofile "sensibilia\\scripts\\resources\\textures.lua"
	end 
	
	dofile "sensibilia\\scripts\\resources\\animations.lua"
	dofile "sensibilia\\scripts\\resources\\particle_effects.lua"
	dofile "sensibilia\\scripts\\settings.lua"
	
	level_resources.draw_geometry = true
	
	-- 1 - max
	instability = 0
	player = nil
	
	base_gravity = vec2(0, 120)
	gravity_angle_offset = 0
	target_gravity_rotation = 0
	
	current_gravity = vec2(0, 120)
	
	dofile "sensibilia\\scripts\\input.lua"
	
	world_information = tiled_map_loader.load_world_properties (MAP_FILENAME)
	dofile "sensibilia\\scripts\\camera.lua"
	
	world_camera_self:set_zoom_level(0)
	
	random_player_bullet_models, random_enemy_bullet_models = initialize_random_bullet_models()
	instability_gun = get_instability_gun()
	
	
	dofile "sensibilia\\scripts\\archetypes\\clock_renderer.lua"
	dofile "sensibilia\\scripts\\archetypes\\pusher_enemy.lua"
	dofile "sensibilia\\scripts\\archetypes\\shooter_enemy.lua"
	dofile "sensibilia\\scripts\\archetypes\\player.lua"
	dofile "sensibilia\\scripts\\archetypes\\wayward_object.lua"

	
	tiled_map_loader.world_camera_entity = world_camera
	dofile (MAP_LOADER_FILENAME)
	
	all_enemies_max_health_points = 0
	
	for k, v in pairs(global_entity_table) do
		if v.character ~= nil then
			if v.character.is_enemy then
				all_enemies_max_health_points = all_enemies_max_health_points + v.character.max_hp
			end
		end
	end
	
	loop_only_info = create_scriptable_info {
		scripted_events = {
			[scriptable_component.INTENT_MESSAGE] = main_input_routine,
					
			[scriptable_component.LOOP] = function(subject, is_substepping)	
				if not level_world.is_paused then
					handle_dying_instability_rays()
					level_world.entity_system_instance:tick(is_substepping, {
						"character",
						"jumping",
						"coordination",
						"instability_ray",
						"clock_renderer",
						"waywardness"
					})
				end
			end
		}
	}
	
	create_entity {
		input = main_input_component,
			
		scriptable = {
			available_scripts = loop_only_info
		}	
	}
	
							--player.body:get().physics.body:SetFixedRotation(false)
							--player.body:get().physics.enable_angle_motor = true
							--player.body:get().physics.target_angle = 90
	physics_system.b2world:SetGravity(b2Vec2(base_gravity.x, base_gravity.y))
end