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

is_reality_checking = false

player_scriptable_info = create_scriptable_info {
	scripted_events = {
		[scriptable_component.INTENT_MESSAGE] = function (message) 
			if message.intent == custom_intents.JUMP then
				should_debug_draw = not message.state_flag
				
				--if message.state_flag then player.body.physics.body:ApplyLinearImpulse(b2Vec2(0, -50), player.body.physics.body:GetWorldCenter(), true) end
			
				get_self(message.subject):jump(message.state_flag)
				--get_self(message.subject):handle_jumping()
			elseif message.intent == custom_intents.INSTABILITY_RAY then 
				if message.state_flag and not is_reality_checking then
					player_ray_caster:cast(true)
				else
					player_ray_caster:cast(false)
				end
			elseif message.intent == custom_intents.REALITY_CHECK then
				if message.state_flag and not player_ray_caster.currently_casting then
					is_reality_checking = true
					player.body.movement.input_acceleration.x = 2000
					get_self(player.body).jump_force_multiplier = 0.4
				else
					player.body.movement.input_acceleration.x = 12000
					get_self(player.body).jump_force_multiplier = 1
					is_reality_checking = false
				end
			else
				return true
			end
			
			return false
		end,
		
		[scriptable_component.LOOP] = function (subject, is_substepping)
			local my_self = get_self(subject)
		
			if is_substepping then
				my_self:substep()
			else
				my_self:loop()
				player_ray_caster.position = player.body.transform.current.pos
				player_ray_caster.direction = (player.crosshair.transform.current.pos - player.body.transform.current.pos):normalize()
				--player_ray_caster.direction = vec2(-0.97090339660645, -0.23947174847126)
				
				--print "player"
				--pv(player.body.transform.current.pos)
				--print "crosshair"
				--pv(player.crosshair.transform.current.pos)
				--print "dir"
				--pv  (player.crosshair.transform.current.pos - player.body.transform.current.pos)
				--print "dirnorm"
				--pv  ((player.crosshair.transform.current.pos - player.body.transform.current.pos):normalize())
				
				
				player_ray_caster.current_ortho = vec2(world_camera.camera.ortho.r, world_camera.camera.ortho.b)
				player_ray_caster:loop()
				instability = instability + player_ray_caster.instability_bonus
				
			end
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
			pos = vec2(200, -200)*5
		},
		
		input = {
			--intent_message.MOVE_FORWARD,
			--intent_message.MOVE_BACKWARD,
			custom_intents.JUMP,
			intent_message.MOVE_LEFT,
			intent_message.MOVE_RIGHT,
			
			custom_intents.INSTABILITY_RAY,
			custom_intents.REALITY_CHECK
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

player_ray_caster = instability_ray_caster:create(player.body, filter_instability_ray_player)
get_self(player.body):set_foot_sensor_from_sprite(player_sprite, 3, 1)
--get_self(player.body):set_foot_sensor_from_circle(60, 6)
world_camera.chase:set_target(player.body)
world_camera.camera.player:set(player.body)
world_camera.camera.crosshair:set(player.crosshair)