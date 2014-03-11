function reload_default_level_resources(
		map_filename, 
		map_loader_filename, 
		gameplay_textures -- optional, if not provided then switching to default gameplay textures
		)
		
	-- destruct previous level data
	level_resources = {}
	collectgarbage("collect")
	
	MAP_FILENAME = "sensibilia\\maps\\" .. map_filename
	MAP_LOADER_FILENAME = "sensibilia\\maps\\" .. map_loader_filename
	GAMEPLAY_TEXTURES = gameplay_textures
	
	dofile "sensibilia\\scripts\\resources\\layers.lua"
	dofile "sensibilia\\scripts\\resources\\textures.lua"
	dofile "sensibilia\\scripts\\resources\\particle_effects.lua"
	dofile "sensibilia\\scripts\\settings.lua"
	
	
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
	
	current_zoom_level = 0
	current_zoom_level = 0
	set_zoom_level(world_camera)
	
	
	dofile "sensibilia\\scripts\\entity_class.lua"
	
	dofile "sensibilia\\scripts\\instability_gun.lua"
	
	dofile "sensibilia\\scripts\\enemy_ai.lua"
	
	dofile "sensibilia\\scripts\\modules\\clock_renderer_module.lua"
	dofile "sensibilia\\scripts\\modules\\character_module.lua"
	dofile "sensibilia\\scripts\\modules\\jumping_module.lua"
	dofile "sensibilia\\scripts\\modules\\coordination_module.lua"
	dofile "sensibilia\\scripts\\modules\\instability_ray_module.lua"
	dofile "sensibilia\\scripts\\modules\\waywardness_module.lua"
	
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
				handle_dying_instability_rays()
				-- process entities
				
				local method_name = "loop"
				
				if is_substepping then
					method_name = "substep"
				end
				
				process_all_entities(
				function(e)
					e:try_module_method("character", method_name)
					e:try_module_method("jumping", method_name)
					e:try_module_method("coordination", method_name)
					e:try_module_method("instability_ray", method_name)
					e:try_module_method("clock_renderer", method_name)
					e:try_module_method("waywardness", method_name)
				end
				)
				
				local name_map = {
					[scriptable_component.DAMAGE_MESSAGE] = "damage_message",
					[scriptable_component.INTENT_MESSAGE] = "intent_message"
				}
				
				-- send all events to entities globally
				for msg_key, msg_table in pairs(global_message_table) do
					for k, msg in pairs(global_message_table[msg_key]) do
						local entity_self = get_self(msg.subject)
						
						-- callback
						local callback = entity_self[name_map[msg_key]]
						
						if callback ~= nil then
							callback(entity_self, msg)
						end
						
						-- by the way, send every single event to all interested modules of this entity respectively
						entity_self:all_modules(name_map[msg_key], msg)
					end
				end
				
				--player.gun_entity:get().gun.trigger_mode = gun_component.SHOOT
				--physics_system.timestep_multiplier = 0.01
				-- messages processed, clear tables
				flush_message_tables()
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