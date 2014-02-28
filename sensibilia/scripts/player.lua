
player_class = inherits_from (character_class)

function player_class:take_damage(amount_ms)
	instability = instability + amount_ms / 4000
end
	
	

player_sprite = create_sprite {
	image = images.blank,
	size = vec2(15, 50)
}

debug_sensor = create_sprite {
	image = images.blank,
	size = vec2(40, 5),
	color = rgba(0, 0, 255, 122)
}

player_debug_circle = simple_create_polygon (reversed(gen_circle_vertices(60, 5)))
map_uv_square(player_debug_circle, images.blank)

is_reality_checking = false

function is_player_raycasting()
	return player.gun_entity:get().gun.trigger_mode == gun_component.SHOOT
end

player_scriptable_info = create_scriptable_info {
	scripted_events = {
		[scriptable_component.INTENT_MESSAGE] = function (message) 
			if message.intent == custom_intents.JUMP then
				should_debug_draw = not message.state_flag
				
				--if message.state_flag then player.body:get().physics.body:ApplyLinearImpulse(b2Vec2(0, -50), player.body:get().physics.body:GetWorldCenter(), true) end
			
				get_self(message.subject):jump(message.state_flag)
				--get_self(message.subject):handle_jumping()
			elseif message.intent == intent_message.SHOOT then 
				if message.state_flag and not is_reality_checking then
					get_self(message.subject).ray_caster:cast(true)
				else
					get_self(message.subject).ray_caster:cast(false)
				end
			elseif message.intent == custom_intents.REALITY_CHECK then
				if message.state_flag and not is_player_raycasting() then
					is_reality_checking = true
					player.body:get().movement.input_acceleration.x = 1000
					get_self(player.body:get()).jump_force_multiplier = 0.4
				else
					player.body:get().movement.input_acceleration.x = 9000
					get_self(player.body:get()).jump_force_multiplier = 1
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
			end
		end
	}
}

my_crosshair_sprite = create_sprite {
	image = images.blank,
	size = vec2(550, 550),
	color = rgba(255, 0, 255, 255)
}

player = spawn_character ({
	gun_entity = {
		gun = {
			bullets_once = 15,
			bullet_distance_offset = vec2(170, 10),
			bullet_damage = minmax(80, 110),
			bullet_speed = minmax(5000, 6000),
			bullet_render = { model = bullet_sprite, mask = render_masks.EFFECTS },
			is_automatic = true,
			max_rounds = 3000,
			shooting_interval_ms = 8,
			spread_degrees = 3.5,
			shake_radius = 19.5,
			shake_spread_degrees = 45,
			
			bullet_body = {
				filter = filter_nothing,
				shape_type = physics_info.RECT,
				rect_size = bullet_sprite.size,
				fixed_rotation = false,
				density = 0.1,
				air_resistance = 0,
				gravity_scale = 0
			},
			
			max_bullet_distance = 5000,
			current_rounds = 3000,
			
			target_camera_to_shake = world_camera 
		},
		
		transform = {},
		
		input = {
			intent_message.SHOOT
		},
		
		lookat = {
			target = "crosshair"
		},
		
		chase = {
			target = "body",
			chase_rotation = false
		}
	},
	
	body = {
		render = {
			model = player_sprite
		},
		
		transform = {
			pos = world_information["PLAYER_START"][1].pos
		},
		
		input = {
			--intent_message.MOVE_FORWARD,
			--intent_message.MOVE_BACKWARD,
			custom_intents.JUMP,
			intent_message.MOVE_LEFT,
			intent_message.MOVE_RIGHT,
			
			--custom_intents.INSTABILITY_RAY,
			custom_intents.REALITY_CHECK
		},
		
		scriptable = {
			available_scripts = player_scriptable_info
		},
		
			
		visibility = {
			visibility_layers = {
				[visibility_layers.BASIC_LIGHTING] = {
					square_side = 15000,
					color = rgba(0, 255, 255, 120),
					ignore_discontinuities_shorter_than = -1,
					filter = filter_pathfinding_visibility
				},
				
				[visibility_layers.LIGHT_BOUNCE] = {
					square_side = 15000,
					color = rgba(0, 255, 255, 120),
					ignore_discontinuities_shorter_than = -1,
					filter = filter_pathfinding_visibility
				}
			}
		}
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
			model = nil
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
}, player_class, 12000)

get_self(player.body:get()):set_foot_sensor_from_sprite(player_sprite, 3, 1)
get_self(player.body:get()).hp = 30000
--get_self(player.body:get()):set_foot_sensor_from_circle(60, 6)
world_camera.chase:set_target(player.body:get())
world_camera.camera.player:set(player.body:get())
world_camera.camera.crosshair:set(player.crosshair:get())