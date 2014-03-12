player_sprite = create_sprite {
	image = images.blank,
	size = vec2(15, 200)
	--size_multiplier = vec2(0.3, 0.3)
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
		
		animate = {},
		
		transform = {},
		
		input = {
			--intent_message.MOVE_FORWARD,
			--intent_message.MOVE_BACKWARD,
			custom_intents.JUMP,
			intent_message.MOVE_LEFT,
			intent_message.MOVE_RIGHT,
			
			--custom_intents.INSTABILITY_RAY,
			custom_intents.REALITY_CHECK,
			custom_intents.SPEED_CHANGE,
			custom_intents.GRAVITY_CHANGE,
			custom_intents.SHOW_CLOCK,
			
			
			intent_message.SHOOT,
			
			intent_message.AIM
		},
		
		scriptable = {
			available_scripts = player_scriptable_info
		},
		
		children = {
			"crosshair",
			"gun_entity"
		},
			
		visibility = {
			interval_ms = 16,
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
	self.all_player_bullets = entity_ptr_vector()
	

	self.showing_clock = false
	self.clock_alpha_animator = value_animator(0, 0, 1)
	
	self.timestep_corrector = value_animator(physics_system.timestep_multiplier, 1, 3500)
	self.base_crosshair_rotation = 0
	
	self.main_gui_clock = spawn_clock(vec2(0,0), { }, images.blue_clock )
	self.gui_clock_self = get_self(self.main_gui_clock.body:get())
	self.gui_clock_self.clock_renderer.randomized_hands_values = false

	self.changing_gravity = false
	self.delta_timer = timer()
end

function player_class:is_shooting()
	return self.parent_group.gun_entity:get().gun.trigger_mode == gun_component.SHOOT
end

function player_class:intent_message(message)

	local msg = animate_message()
	msg.subject = self.parent_group.body:get()
		
		
	--print "handling intent"
	if message.intent == custom_intents.JUMP then
		should_debug_draw = not message.state_flag
		
		--if message.state_flag then self.parent_group.body:get().physics.body:ApplyLinearImpulse(b2Vec2(0, -50), self.parent_group.body:get().physics.body:GetWorldCenter(), true) end
	
		msg.animation_priority = 1
		
		msg.set_animation = player_animations.take_jump
		msg.change_animation = true
		msg.change_speed = true
		msg.preserve_state_if_animation_changes = false
		
		msg.message_type = animate_message.START
		
		world:post_message(msg)
		
		get_self(message.subject).jumping:jump(message.state_flag)
		--get_self(message.subject):handle_jumping()
		
	elseif message.intent == intent_message.SHOOT then
		
		if message.state_flag then
			if self.jumping.something_under_foot then 
				msg.set_animation = player_animations.begin_shooting
			else
				msg.set_animation = player_animations.begin_shooting_in_air
			end
		else
			msg.set_animation = player_animations.stop_shooting
		end
		
		msg.animation_priority = 2
		
		msg.change_animation = true
		msg.change_speed = true
		msg.preserve_state_if_animation_changes = false
		
		msg.message_type = animate_message.START
		
		world:post_message(msg)
	elseif message.intent == custom_intents.REALITY_CHECK then
		if message.state_flag then
			self.is_reality_checking = true
			self.parent_group.body:get().movement.input_acceleration.x = 1000
			self.jumping.jump_force_multiplier = 0.4
		else
			self.is_reality_checking = false
			self.parent_group.body:get().movement.input_acceleration.x = 9000
			self.jumping.jump_force_multiplier = 1
		end
	elseif message.intent == custom_intents.SHOW_CLOCK then
		self.showing_clock = message.state_flag
		
		if not showing_clock then
			self.clock_alpha_animator = value_animator(1, 0, 1500)
			self.clock_alpha_animator:set_logarithmic()
		end	
	elseif message.intent == intent_message.AIM then
		if self.changing_gravity then
			local added_angle = message.mouse_rel.y * 0.6
		
			target_gravity_rotation = target_gravity_rotation + added_angle
			
			for i=1, #global_entity_table do
				if global_entity_table[i].character ~= nil then global_entity_table[i].parent_group.body:get().physics.target_angle = target_gravity_rotation end
			end
		end
	elseif message.intent == custom_intents.GRAVITY_CHANGE then
		self.changing_gravity = message.state_flag
		
		if message.state_flag then
			self.parent_group.crosshair:get().crosshair.sensitivity.y = 0
			self.base_crosshair_rotation = world_camera.camera.last_interpolant.rotation
			target_gravity_rotation = self.parent_group.body:get().physics.body:GetAngle() / 0.01745329251994329576923690768489
		else
			self.parent_group.crosshair:get().crosshair.sensitivity = config_table.sensitivity
			world_camera.camera.crosshair_follows_interpolant = false
		end
		
		for i=1, #global_entity_table do
			if global_entity_table[i].character ~= nil then global_entity_table[i].character:set_gravity_shift_state(self.changing_gravity) end
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

function player_class:substep()
	local should_return = false
	
	if instability < 0 then 
		if self.is_reality_checking then
			-- all wayward objects try to reach their initial position
			should_return = true
		end
		
		instability = 0 
	end
	
	process_all_entity_modules("waywardness", "return_to_initial_transform", should_return)
end

function player_class:loop()
	physics_system.timestep_multiplier = self.timestep_corrector:get_animated()
	
	local gun_info = self.parent_group.gun_entity:get().gun
	local player_body = self.parent_group.body:get()
	local crosshair = self.parent_group.crosshair:get()
	
	gun_info.spread_degrees = 5 + 30 * instability
	gun_info.shake_radius = 5+20*instability
		
	loop_instability_gun_bullets(rgba(0, 255, 0, 255), self.all_player_bullets, instability, physics_system.timestep_multiplier, base_gravity)
	
	
	-- handle variable gravity
	gravity_angle_offset = player_body.physics.body:GetAngle() / 0.01745329251994329576923690768489
	current_gravity = vec2(base_gravity):rotate(gravity_angle_offset, vec2(0, 0))
	
	for i=1, #global_entity_table do
		local maybe_movement = global_entity_table[i].parent_group.body:get().movement
		
		if maybe_movement ~= nil then
			maybe_movement.axis_rotation_degrees = gravity_angle_offset
		end
	end
	
	crosshair.transform.current.pos:rotate(self.base_crosshair_rotation - world_camera.camera.last_interpolant.rotation, player_body.transform.current.pos)
	self.base_crosshair_rotation = world_camera.camera.last_interpolant.rotation
	
	crosshair.crosshair.rotation_offset = -world_camera.camera.last_interpolant.rotation		
	crosshair.transform.current.rotation = -world_camera.camera.last_interpolant.rotation
	
	physics_system.b2world:SetGravity(b2Vec2(current_gravity.x, current_gravity.y))

	
	
	
	-- handle increasing/decreasing instability
	
	if self.changing_gravity then
		instability = instability + (self.delta_timer:get_seconds()/3)
	end
	
	if self:is_shooting() then
		instability = instability + self.delta_timer:get_milliseconds()/10000
	end
	
	if self.jumping.is_currently_post_jetpacking then
		instability = instability + self.delta_timer:get_milliseconds()/3000
	end
	
	instability = instability + (1-physics_system.timestep_multiplier) * self.delta_timer:get_milliseconds()/16000
	
	if not self:is_shooting() and not self.changing_gravity and not 
	self.jumping.is_currently_post_jetpacking and math.abs(physics_system.timestep_multiplier-1) < 0.1
	
	then
		local decrease_amount = (self.delta_timer:get_seconds() / 10)
		
		if get_self(player.body:get()).is_reality_checking then decrease_amount = decrease_amount * 3 end
		
		instability = instability - decrease_amount
	end
	
	--print ("instability")
	self.delta_timer:reset()
				
	
				
	-- handle clock gui
	local clock_alpha = 1
				
	if not self.showing_clock then
		clock_alpha = self.clock_alpha_animator:get_animated()
		--clock_alpha = prev_instability*prev_instability*prev_instability*prev_instability*prev_instability*prev_instability
	end
	--print(showing_clock, clock_alpha)
	self.gui_clock_self.clock_renderer.clock_center = vec2(world_camera.transform.previous.pos)
	self.gui_clock_self.clock_renderer.clock_alpha = clock_alpha
	
	
	-- handle animations
	
	local msg = animate_message()
	msg.subject = player_body
	
	local should_flip = false
	local target_animation;
	
	
	local vel = self.parent_group.body:get().physics.body:GetLinearVelocity()
	vel = vec2(vel.x, vel.y) * 50
	
	local is_in_movement = math.abs(vel.x) > 15
	
	if not is_in_movement then 
		should_flip = (player_body.transform.current.pos.x - crosshair.transform.current.pos.x) > 0
	else
		should_flip = vel.x < 0
		msg.speed_factor = vel:length()/6000
	end
	
	if self.jumping.something_under_foot then
		if is_in_movement then
			target_animation = "running"
		else
			target_animation = "standing"
		end
	else
		if vel.y > 0 then
			target_animation = "falling"
		else
			target_animation = "in_air"
		end
	end
	
	player_body.render.flip_horizontally = should_flip
	
	msg.set_animation = player_animations[target_animation]
	msg.change_animation = true
	msg.change_speed = true
	msg.preserve_state_if_animation_changes = false
	
	msg.message_type = animate_message.CONTINUE
	
	world:post_message(msg)
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
	
	new_group.body:get().name = "player_body"
	new_group.crosshair:get().name = "player_crosshair"
	new_group.gun_entity:get().name = "player_gun"
	
	setup_camera(new_group)
	
	return new_group
end


function setup_camera(group)
	world_camera.chase:set_target(group.body:get())
	world_camera.camera.player:set(group.body:get())
	world_camera.camera.crosshair:set(group.crosshair:get())
	world_camera.transform.pos = group.body:get().transform.current.pos
end