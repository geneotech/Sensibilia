player_sprite = create_sprite {
	image = images.blank,
	size = vec2(30, 100)
}

debug_sensor = create_sprite {
	image = images.blank,
	size = vec2(40, 5),
	color = rgba(0, 0, 255, 122)
}

player_debug_circle = simple_create_polygon (reversed(gen_circle_vertices(60, 5)))
map_uv_square(player_debug_circle, images.blank)

player_scriptable_info = create_scriptable_info {
	scripted_events = {
		[scriptable_component.INTENT_MESSAGE] = function (message) 
			if message.intent == custom_intents.JUMP then
				should_debug_draw = not message.state_flag
				
				--if message.state_flag then player.body.physics.body:ApplyLinearImpulse(b2Vec2(0, -50), player.body.physics.body:GetWorldCenter(), true) end
			
				get_self(message.subject):jump(message.state_flag)
				get_self(message.subject):handle_jumping()
			else 
				return true
			end
			
			return false
		end,
		
		[scriptable_component.LOOP] = function (subject)
			get_self(subject):loop()
			--render_system:push_line(debug_line(subject.transform.current.pos + get_self(subject).foot_sensor_p1, subject.transform.current.pos + get_self(subject).foot_sensor_p2, rgba(255, 0, 0, 255)))
		end
	}
}

my_crosshair_sprite = create_sprite {
	image = images.blank,
	size = vec2(550, 550),
	color = rgba(255, 0, 255, 255)
}

player = spawn_npc {
	body = {
		render = {
			model = player_sprite
		},
		
		transform = {
			pos = vec2(5000, -200)
		},
		
		input = {
			--intent_message.MOVE_FORWARD,
			--intent_message.MOVE_BACKWARD,
			custom_intents.JUMP,
			intent_message.MOVE_LEFT,
			intent_message.MOVE_RIGHT
		},
		
		scriptable = {
			available_scripts = player_scriptable_info
		},
		
			
		--visibility = {
		--	visibility_layers = {
		--		[visibility_component.DYNAMIC_PATHFINDING] = {
		--			square_side = 15000,
		--			color = rgba(0, 255, 255, 120),
		--			ignore_discontinuities_shorter_than = 500,
		--			filter = filter_pathfinding_visibility
		--		}
		--	}
		--},
		--pathfinding = {
		--	enable_backtracking = true,
		--	target_offset = 100,
		--	rotate_navpoints = 10,
		--	distance_navpoint_hit = 2,
		--	favor_velocity_parallellness = false
		--}
	},
	
	crosshair = { 
		transform = {
			pos = vec2(0, 0),
			rotation = 0
		},
		
		render = {
			layer = render_layers.GUI_OBJECTS,
			model = my_crosshair_sprite
		},
		
		crosshair = {
			sensitivity = config_table.sensitivity,
			size_multiplier = vec2(10, 10)
		},
		
		chase = {
			target = "body",
			relative = true
		},
		
		input = {
			intent_message.AIM
		}
	},
}


get_self(player.body):set_foot_sensor_from_sprite(player_sprite, 3, 1)
--get_self(player.body):set_foot_sensor_from_circle(60, 6)
world_camera.chase:set_target(player.body)
world_camera.camera.player:set(player.body)
world_camera.camera.crosshair:set(player.crosshair)