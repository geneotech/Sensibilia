dofile "sensibilia\\scripts\\steering.lua"

function get_self(entity)
	return entity.scriptable.script_data
end

character_class = inherits_from {}

function character_class:constructor(subject_entity, base_movement_speed) 
	self.jump_timer = stepped_timer(physics_system)
	self.jetpack_timer = stepped_timer(physics_system)
	self.entity = subject_entity:get()
	self.foot_sensor_p1 = vec2(0, 0)
	self.foot_sensor_p2 = vec2(0, 0)
	
	self.wants_to_jump = false
	self.something_under_foot = false
	
	self.max_jetpack_steps = 15
	self.still_holding_jetpack = false
	self.jump_force_multiplier = 1
	
	self.jetpack_impulse = vec2(0, -10)
	self.jump_impulse = vec2(0, -31)
	
	self.base_movement_speed = base_movement_speed
	self.movement_speed_multiplier = 1
	
	self.jump_height = (50 * calc_max_jump_height(base_gravity, 0.1, self.jump_impulse, self.jetpack_impulse, self.max_jetpack_steps, self.entity.physics.body:GetMass())) - 2
	
	self.hp = 100
	
	self.ray_caster = instability_ray_caster:create(subject_entity, filter_instability_ray_player)
	self.ray_caster.polygon_color = rgba(0, 255, 0, 255);
	self.ray_caster.radius_of_effect = 5000
	
	self:update_movement_speeds()
end

function character_class:update_movement_speeds()
	if self.entity.steering then
		self.entity.steering.max_speed = self.base_movement_speed*1.4142135623730950488016887242097*self.movement_speed_multiplier
	end

	if self.entity.movement then
		self.entity.movement.input_acceleration.x = self.base_movement_speed*self.movement_speed_multiplier
		--print "WARNING: unset movement speed!!!"
		--debugger_break()
	end

end

function character_class:set_movement_speed_multiplier(multiplier)
	self.movement_speed_multiplier = multiplier
	self:update_movement_speeds()
end

function character_class:set_base_movement_speed(speed)
	self.base_movement_speed = base_movement_speed
	self:update_movement_speeds()
end

function character_class:take_damage(amount)
	self.hp = self.hp - amount
	
	if self.hp < 0 then
		self:death_callback()
	end
end

function character_class:jump(jump_flag)
	self.wants_to_jump = jump_flag
	if not jump_flag then self.still_holding_jetpack = false end
end

function character_class:set_gravity_shift_state(enable)
	local entity = self.entity

	if enable then
		entity.physics.enable_angle_motor = true
		entity.physics.body:SetFixedRotation(false)
	else
		entity.physics.body:SetFixedRotation(true)
		entity.physics.enable_angle_motor = false
	end
end

function character_class:handle_jumping()
	-- determine if something is under foot 
	local pos = self.entity.transform.current.pos
	local body = self.entity.physics.body
	
	local query_rect_p1 = pos + self.foot_sensor_p1
	local query_rect_p2 = pos + self.foot_sensor_p2
	local query_rect = vec2_vector()
	
	local query_coords = { 
		query_rect_p1,
		vec2(query_rect_p2.x, query_rect_p1.y),
		query_rect_p2,
		vec2(query_rect_p1.x, query_rect_p2.y)
	}
	
	for k, v in ipairs(query_coords) do
		query_coords[k]:rotate(gravity_angle_offset, pos)
	end
	
	add_vals(query_rect, query_coords)
		
	local under_foot_candidates = physics_system:query_polygon(query_rect, create(b2Filter, filter_character_feet), self.entity)
	
	self.something_under_foot = false
	
	for candidate in under_foot_candidates.bodies do
		self.something_under_foot = true
	end
	
	if self.something_under_foot and self.jump_timer:get_steps() > 7 then
		-- if there is, apply no gravity, simulate feet resistance
		body:SetGravityScale(0.0)
		SetFriction(body, 2)
		self.entity.movement.thrust_parallel_to_ground_length = 500
		--self.entity.movement.input_acceleration.x = 10000
	else
		--self.entity.movement.input_acceleration.x = 15000
		body:SetGravityScale(1.0)
		SetFriction(body, 0)
		self.entity.movement.thrust_parallel_to_ground_length = 0
	end
		
	-- perform jumping 
	if self.wants_to_jump and self.jump_timer:get_steps() > 7 then
		if self.something_under_foot then
			local jump_impulse = self.jump_impulse:rotate(gravity_angle_offset, vec2(0, 0)) * self.jump_force_multiplier
			
			body:SetGravityScale(1.0)
			self.entity.movement.thrust_parallel_to_ground_length = 0
			--body:SetLinearVelocity(b2Vec2(0, 0))
			--print "APPLYING"
			body:ApplyLinearImpulse(b2Vec2(jump_impulse.x, jump_impulse.y), body:GetWorldCenter(), true)
			
			
			self.still_holding_jetpack = true
			self.jetpack_timer:reset()
		end
		
		self.jump_timer:reset()
	end
end

function character_class:handle_variable_height_jump()
	local body = self.entity.physics.body
	if self.still_holding_jetpack and self.jetpack_timer:get_steps() < self.max_jetpack_steps then
	--	print(self.still_holding_jetpack, self.jetpack_timer:get_steps(), self.max_jetpack_steps)
	--print "JETPACKING"
		local jetpack_force = self.jetpack_impulse:rotate(gravity_angle_offset, vec2(0, 0)) * self.jump_force_multiplier
		body:ApplyLinearImpulse(b2Vec2(jetpack_force.x, jetpack_force.y), body:GetWorldCenter(), true)
		
	end
end

function character_class:loop()	
	--self:handle_jumping()
end

function character_class:substep()
	self:handle_jumping()
	self:handle_variable_height_jump()
end

function character_class:set_foot_sensor_from_sprite(subject_sprite, thickness, edge_threshold)
	if edge_threshold == nil then
		edge_threshold = 0
	end
	
	self.foot_sensor_p1 = vec2(-subject_sprite.size.x / 2 + edge_threshold, subject_sprite.size.y / 2)
	self.foot_sensor_p2 = vec2( subject_sprite.size.x / 2 - edge_threshold, subject_sprite.size.y / 2 + thickness) 
end

function character_class:set_foot_sensor_from_circle(radius, thickness) 
	self.foot_sensor_p1 = vec2(-radius, radius)
	self.foot_sensor_p2 = vec2( radius, radius + thickness) 
end

character_basic_loop = create_scriptable_info {
	scripted_events = {
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

character_group_archetype = {
	body = {
		physics = {
			body_type = Box2D.b2_dynamicBody,
			
			body_info = {
				shape_type = physics_info.RECT,
				radius = 60,
				--rect_size = vec2(30, 30),
				filter = filter_characters,
				density = 1,
				friction = 2,
				bullet = true,
				
				--,
				fixed_rotation = true
			}	
		},
		
		render = {
			layer = render_layers.OBJECTS
		},
		
		transform = {},
		
		movement = {
			input_acceleration = vec2(12000, 0),
			max_speed_animation = 2300,
			air_resistance = 0.1,
			inverse_thrust_brake = vec2(1500, 0),
			
			ground_filter = filter_character_feet,
			
			receivers = {},
			
			sidescroller_setup = true
			
			--force_offset = vec2(0, 5)
			
			--receivers = {
			--	{ target = "body", stop_at_zero_movement = false }, 
			--	{ target = "legs", stop_at_zero_movement = true  }
			--}
		},
		
		scriptable = {
			available_scripts = character_basic_loop
		}
	}
}

global_character_table = {

}

function spawn_character(group_overrider, what_class, ...)
	if what_class == nil then what_class = character_class end
	
	local my_new_character = ptr_create_entity_group (archetyped(character_group_archetype, group_overrider))
	
	local new_character_scriptable = what_class:create(my_new_character.body, table.unpack({...}))
	
	my_new_character.body:get().scriptable.script_data = new_character_scriptable
	
	table.insert(global_character_table, new_character_scriptable)
	
	return my_new_character
end

dofile "sensibilia\\scripts\\npc.lua"