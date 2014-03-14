jumping_module = inherits_from {}

function jumping_module:constructor(receiver_entity)
	self.entity = receiver_entity

	self.jump_timer = stepped_timer(physics_system)
	self.jetpack_timer = stepped_timer(physics_system)
	self.foot_sensor_p1 = vec2(0, 0)
	self.foot_sensor_p2 = vec2(0, 0)
	
	self.wants_to_jump = false
	self.something_under_foot = false
	
	self.max_jetpack_steps = 15
	
	self.max_after_jetpack_steps = 0
	self.after_jetpack_force_mult = 0.5
	self.pre_after_jetpack_steps = 5
	self.is_currently_post_jetpacking = false
	
	self.still_holding_jetpack = false
	self.jump_force_multiplier = 1
	
	self.jetpack_impulse = vec2(0, -10)
	self.jump_impulse = vec2(0, -34)
	
	self.jump_height = (50 * calc_max_jump_height(base_gravity, 0.1, self.jump_impulse, self.jetpack_impulse, self.max_jetpack_steps, self.entity.physics.body:GetMass())) - 2
	self.base_movement_speed = base_movement_speed
end


function jumping_module:jump(jump_flag)
	self.wants_to_jump = jump_flag
	if not jump_flag then self.still_holding_jetpack = false end
end

function jumping_module:handle_jumping()
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
			local jump_impulse = vec2(self.jump_impulse):rotate(gravity_angle_offset, vec2(0, 0)) * self.jump_force_multiplier * body:GetMass()
			
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

function jumping_module:handle_variable_height_jump()
	local body = self.entity.physics.body
	self.is_currently_post_jetpacking = false
	if self.still_holding_jetpack then
		local jetpack_steps = self.jetpack_timer:get_steps()
		local jetpack_force = vec2(self.jetpack_impulse):rotate(gravity_angle_offset, vec2(0, 0)) * self.jump_force_multiplier  * body:GetMass()
			
		if jetpack_steps < self.max_jetpack_steps then
		--	print(self.still_holding_jetpack, self.jetpack_timer:get_steps(), self.max_jetpack_steps)
		--print "JETPACKING"
			body:ApplyLinearImpulse(b2Vec2(jetpack_force.x, jetpack_force.y), body:GetWorldCenter(), true)
		elseif (jetpack_steps-self.max_jetpack_steps > self.pre_after_jetpack_steps) and
			(jetpack_steps < self.max_jetpack_steps + self.pre_after_jetpack_steps + self.max_after_jetpack_steps) then
			
			self.is_currently_post_jetpacking = true
			jetpack_force = jetpack_force * self.after_jetpack_force_mult
			body:ApplyLinearImpulse(b2Vec2(jetpack_force.x, jetpack_force.y), body:GetWorldCenter(), true)
		end
	end
end

function jumping_module:substep()
	self:handle_jumping()
	self:handle_variable_height_jump()
end

function jumping_module:loop()
end

function jumping_module:set_foot_sensor_from_sprite(subject_sprite, thickness, edge_threshold)
	if edge_threshold == nil then
		edge_threshold = 0
	end
	
	self.foot_sensor_p1 = vec2(-subject_sprite.size.x / 2 + edge_threshold, subject_sprite.size.y / 2)
	self.foot_sensor_p2 = vec2( subject_sprite.size.x / 2 - edge_threshold, subject_sprite.size.y / 2 + thickness) 
end

function jumping_module:set_foot_sensor_from_circle(radius, thickness) 
	self.foot_sensor_p1 = vec2(-radius, radius)
	self.foot_sensor_p2 = vec2( radius, radius + thickness) 
end