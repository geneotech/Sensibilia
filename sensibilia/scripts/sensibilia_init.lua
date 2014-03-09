CURRENT_LEVEL = "sensibilia\\maps\\example_map"

my_instance = world_instance()
collectgarbage("collect")
input_system = my_instance.input_system
visibility_system = my_instance.visibility_system
pathfinding_system = my_instance.pathfinding_system
render_system = my_instance.render_system
physics_system = my_instance.physics_system
world = my_instance.world

should_world_be_reloaded = false

dofile "sensibilia\\scripts\\settings.lua"
changing_gravity = false
augmentations_main_loop_callback = function()
	my_instance.world:validate_delayed_messages();

	my_instance.input_system:process_entities(world)
	my_instance.camera_system:consume_events(world)

	my_instance.movement_system:process_entities(world)

	my_instance.camera_system:process_entities(world)

	my_instance.physics_system:process_entities(world)

	my_instance.behaviour_tree_system:process_entities(world)
	my_instance.lookat_system:process_entities(world)
	my_instance.chase_system:process_entities(world)
	my_instance.crosshair_system:process_entities(world)
	my_instance.gun_system:process_entities(world)
	my_instance.damage_system:process_entities(world)
	my_instance.particle_group_system:process_entities(world)
	my_instance.animation_system:process_entities(world)
	my_instance.visibility_system:process_entities(world)
	my_instance.pathfinding_system:process_entities(world)
		
	my_instance.render_system:process_entities(world)
	my_instance.script_system:process_entities(world)

	my_instance.damage_system:process_events(world)
	my_instance.destroy_system:consume_events(world)

	my_instance.script_system:process_events(world)

	my_instance.damage_system:process_events(world)
	my_instance.destroy_system:consume_events(world)

	my_instance.movement_system:consume_events(world)
	my_instance.animation_system:consume_events(world)
	my_instance.crosshair_system:consume_events(world)
	my_instance.gun_system:consume_events(world)
	my_instance.particle_emitter_system:consume_events(world)

	my_instance.camera_system:process_rendering(world)

	my_instance.world:flush_message_queues()
	
	--if should_world_be_reloaded then
		call_once_after_loop = function()
			collectgarbage("collect")
			dofile "init.lua"
			collectgarbage("collect")
		end
	--end
	
	return input_system.quit_flag
end

dofile "sensibilia\\scripts\\sensibilia.lua"
