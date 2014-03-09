script_reloader:add_directory ("sensibilia\\scripts", true)

CURRENT_LEVEL = "sensibilia/maps/example_map"

textures = 						open_script "sensibilia\\scripts\\resources\\textures.lua"

layers = 						open_script "sensibilia\\scripts\\resources\\layers.lua"

reloader_script = open_script "sensibilia\\scripts\\sensibilia.lua"

call_on_modification( textures, { textures, reloader_script  } )
call_on_modification( layers, { layers, reloader_script  } )
call_on_modification( reloader_script, { reloader_script } )

my_instance = world_instance()
input_system = my_instance.input_system
visibility_system = my_instance.visibility_system
pathfinding_system = my_instance.pathfinding_system
render_system = my_instance.render_system
physics_system = my_instance.physics_system
world = my_instance.world

dofile "sensibilia\\scripts\\settings.lua"
changing_gravity = false
augmentations_main_loop_callback = function()
	my_instance.world:validate_delayed_messages();

	my_instance.input_system:process_entities(world)
	my_instance.camera_system:consume_events(world)

	my_instance.movement_system:process_entities(world)

	my_instance.camera_system:process_entities(world)

	if not changing_gravity then
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
		end
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
	
	return input_system.quit_flag
end

dofile "sensibilia\\scripts\\sensibilia.lua"
