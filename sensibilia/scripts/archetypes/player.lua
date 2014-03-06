player_sprite = create_sprite {
	image = images.blank,
	size = vec2(15, 50)
}

debug_sensor = create_sprite {
	image = images.blank,
	size = vec2(40, 5),
	color = rgba(0, 0, 255, 122)
}

my_crosshair_sprite = create_sprite {
	image = images.blank,
	size = vec2(550, 550),
	color = rgba(255, 0, 255, 255)
}

player_debug_circle = simple_create_polygon (reversed(gen_circle_vertices(60, 5)))
map_uv_square(player_debug_circle, images.blank)



player_group_archetype = archetyped(character_group_archetype, {
	gun_entity = {
		gun = archetyped(instability_gun, {
			bullet_callback = function(subject, new_bullet)
				instability_gun_bullet_callback(subject, new_bullet, random_player_bullet_models, filter_bullets_passed_wall)
			end
		}),
		
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
		
		transform = {},
		
		input = {
			--intent_message.MOVE_FORWARD,
			--intent_message.MOVE_BACKWARD,
			custom_intents.JUMP,
			intent_message.MOVE_LEFT,
			intent_message.MOVE_RIGHT,
			
			--custom_intents.INSTABILITY_RAY,
			custom_intents.REALITY_CHECK,
			custom_intents.SPEED_CHANGE
		},
		
		scriptable = {
			available_scripts = player_scriptable_info
		},
		
		children = {
			"crosshair",
			"gun_entity"
		},
			
		visibility = {
			visibility_layers = {
				[visibility_layers.BASIC_LIGHTING] = {
					square_side = 6000,
					color = rgba(0, 255, 255, 120),
					ignore_discontinuities_shorter_than = -1,
					filter = filter_light_visibility
				},
				
				[visibility_layers.LIGHT_BOUNCE] = {
					square_side = 6000,
					color = rgba(0, 255, 255, 120),
					ignore_discontinuities_shorter_than = -1,
					filter = filter_light_visibility
				},
				
				[visibility_layers.LIGHT_BOUNCE + 1] = {
					square_side = 6000,
					color = rgba(255, 0, 0, 120),
					ignore_discontinuities_shorter_than = -1,
					filter = filter_light_visibility
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
})


player_class = inherits_from (entity_class)

function player_class:constructor(parent_group)
	entity_class.constructor(self, parent_group)
	
	self.is_reality_checking = false
	self.all_player_bullets = {}
	
	self.timestep_corrector = value_animator(physics_system.timestep_multiplier, 1, 3500)
end

function is_player_raycasting()
	return player.gun_entity:get().gun.trigger_mode == gun_component.SHOOT
end


function player_class:intent_message(message)
	--print "handling intent"
	if message.intent == custom_intents.JUMP then
		should_debug_draw = not message.state_flag
		
		--if message.state_flag then player.body:get().physics.body:ApplyLinearImpulse(b2Vec2(0, -50), player.body:get().physics.body:GetWorldCenter(), true) end
	
		get_self(message.subject).jumping:jump(message.state_flag)
		--get_self(message.subject):handle_jumping()
	elseif message.intent == custom_intents.REALITY_CHECK then
		if message.state_flag then
			self.is_reality_checking = true
			player.body:get().movement.input_acceleration.x = 1000
			get_self(player.body:get()).jumping.jump_force_multiplier = 0.4
		else
			self.is_reality_checking = false
			player.body:get().movement.input_acceleration.x = 9000
			get_self(player.body:get()).jumping.jump_force_multiplier = 1
		end
	elseif message.intent == custom_intents.SPEED_CHANGE then
		physics_system.timestep_multiplier = physics_system.timestep_multiplier + message.wheel_amount/60.0 * 0.05
		
		if physics_system.timestep_multiplier < 0.01 then
			physics_system.timestep_multiplier = 0.01
		end
		
		if physics_system.timestep_multiplier > 1 then
			physics_system.timestep_multiplier = 1
		end
		
		self.timestep_corrector = value_animator(physics_system.timestep_multiplier, 1, 5500)
		self.timestep_corrector:set_linear()
	end
end

function player_class:loop()
	physics_system.timestep_multiplier = self.timestep_corrector:get_animated()
	
	loop_instability_gun_bullets(player, 5+20*instability, rgba(0, 255, 0, 255))
end

function spawn_player(position)
	local new_group = spawn_entity(archetyped(player_group_archetype, { body = { transform = { pos = position } }}), player_class)
	local this = get_self(new_group.body:get())
	
	this.jumping = jumping_module:create(new_group.body:get())
	this.jumping:set_foot_sensor_from_sprite(player_sprite, 3, 1)
	this.jumping.max_after_jetpack_steps = 125
	this.jumping.after_jetpack_force_mult = 0.5
	this.jumping.pre_after_jetpack_steps = 17
	
	this.character = character_module:create(new_group.body:get(), 12000)
	this.character:init_hp(30000)
	this.character.is_enemy = false
	
	this.character.damage_message = function(self, message)
		instability = instability + message.amount / 4000
	end
	
	return new_group
end

player = spawn_player(world_information["PLAYER_START"][1].pos)

--get_self(player.body:get()):set_foot_sensor_from_circle(60, 6)
world_camera.chase:set_target(player.body:get())
world_camera.camera.player:set(player.body:get())
world_camera.camera.crosshair:set(player.crosshair:get())