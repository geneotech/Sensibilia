dofile "sensibilia\\scripts\\steering.lua"

npc_sprite = create_sprite {
	image = images.bullet_map,
	size = vec2(60, 60),
	color = rgba(255, 0, 0, 255)
}

coordination_module = inherits_from {}

function coordination_module:constructor(subject_entity)
	self.entity = subject_entity
	
	self.steering_behaviours = {	
		target_seeking = behaviour_state(target_seek_steering),
		forward_seeking = behaviour_state(forward_seek_steering),
		
		sensor_avoidance = behaviour_state(sensor_avoidance_steering),
		wandering = behaviour_state(wander_steering),
		obstacle_avoidance = behaviour_state(obstacle_avoidance_steering),
		separating = behaviour_state(separation_steering),
		pursuit = behaviour_state(pursuit_steering)
	}
		
	self.target_entities = {
		navigation = create_entity(target_entity_archetype),
		forward = create_entity(target_entity_archetype),
		last_seen = create_entity(target_entity_archetype)
	}
	
	self.movement_mode_flying = false
	
	self:refresh_behaviours()
	self:set_all_behaviours_enabled(false)
	self:set_movement_mode_flying(true)
	
	self.was_seen = false
	self.is_seen = false
	self.is_alert = false
	self.last_seen_velocity = vec2(0, 0)
		
	self.steering_behaviours.forward_seeking.target_from:set(self.target_entities.forward)
	self.steering_behaviours.target_seeking.target_from:set(self.target_entities.navigation)
	self.steering_behaviours.sensor_avoidance.target_from:set(self.target_entities.navigation)
	
	self.steering_behaviours.pursuit.enabled = false
	self.steering_behaviours.wandering.enabled = true
	
	self.current_pathfinding_eye = vec2(0, 0)
	self.can_jump_to_navpoint = false
	self.frozen_navpoint = vec2(0, 0)	
	
	self.flying_state_changer = coroutine.create(
		function() 
			while true do
				print "lecimy"
				self:set_movement_mode_flying(true)
				coroutine.stepped_wait(randval(1000/self.movement_speed_multiplier, 9000/self.movement_speed_multiplier))
				print "idziemy"
				self:set_movement_mode_flying(false)
				coroutine.stepped_wait(randval(500, 4000))
			end
		end
	)
end

function coordination_module:set_movement_mode_flying(flag)
	self.movement_mode_flying = flag
	self.entity.movement.sidescroller_setup = not flag
		
	if flag then
		self.entity.movement.requested_movement = vec2(0, 0)
		self.steering_behaviours.target_seeking.weight_multiplier = 1
		self.steering_behaviours.sensor_avoidance.enabled = true
		self.entity.physics.body:SetGravityScale(0.0)
		SetFriction(self.entity.physics.body, 0)
		
		self.entity.pathfinding.first_priority_navpoint_check = nil
		self.entity.pathfinding.target_visibility_condition = nil
		self.entity.pathfinding.enable_session_rollbacks = true
		self.entity.pathfinding.force_persistent_navpoints = false
		self.entity.pathfinding.force_touch_sensors = false
		self.entity.pathfinding.braking_damping = 20
		self.entity.pathfinding.target_offset = 100
		self.entity.pathfinding.distance_navpoint_hit = 2
		self.entity.pathfinding.mark_touched_as_discovered = false
			
		self.steering_behaviours.wandering.weight_multiplier = 1
	else
		SetFriction(self.entity.physics.body, 2)

		local height_callback = function(entity, pos, target)
			return (pos.y - target.y) <= self.jump_height 
		end
		
		self.entity.pathfinding.first_priority_navpoint_check = height_callback
		self.entity.pathfinding.target_visibility_condition = height_callback
		self.entity.pathfinding.enable_session_rollbacks = false
		self.entity.pathfinding.force_persistent_navpoints = true
		self.entity.pathfinding.force_touch_sensors = true
		self.entity.pathfinding.target_offset = 100
		self.entity.pathfinding.distance_navpoint_hit = 30
		self.entity.pathfinding.mark_touched_as_discovered = true
		
		self.steering_behaviours.target_seeking.weight_multiplier = 0
		self.steering_behaviours.target_seeking.enabled = true
		self.steering_behaviours.sensor_avoidance.enabled = false
		self.steering_behaviours.forward_seeking.enabled = false
		self.steering_behaviours.wandering.weight_multiplier = 0
		--self.entity.pathfinding.braking_damping = 0
		--self:set_all_behaviours_enabled(false)
		-- the only behaviour that is enabled and will be mapped to the left-right-jump movement
		--self.steering_behaviours.target_seeking.enabled = true
	end
end

function coordination_module:death_callback()
end

function coordination_module:set_all_behaviours_enabled(flag)
	for k, v in pairs(self.steering_behaviours) do
		v.enabled = flag
	end
end

function coordination_module:refresh_behaviours() 
	self.entity.steering:clear_behaviours()
	
	for k, v in pairs(self.steering_behaviours) do
		self.entity.steering:add_behaviour(v)
	end
end

function coordination_module:angle_fits_in_threshold(angle, axis_angle, threshold)
	angle = angle - self.entity.movement.axis_rotation_degrees
	return angle > axis_angle - threshold and angle < axis_angle + threshold
end

function coordination_module:map_vector_to_movement(real_vector)
	self.entity.movement.requested_movement = real_vector
	local should_jump = self:angle_fits_in_threshold(real_vector:get_degrees(), -90, 20)
	self:jump(should_jump)
	
	return should_jump
end

function coordination_module:determine_jumpability(queried_point, apply_upwards_forces)	
	local vel = self.entity.physics.body:GetLinearVelocity()
	local foot = self.entity.transform.current.pos + self.current_pathfinding_eye
	
	local upward_force_multiplier = 1
	
	if not apply_upwards_forces then 
		upward_force_multiplier = 0 
		if math.abs(queried_point.x - foot.x) < 100 then 
			return queried_point.y > foot.y
		end
	end
	return true
	--return can_point_be_reached_by_jump(
	--base_gravity, 
	--self.entity.movement.input_acceleration/50, 
	--self.entity.movement.air_resistance, 
	--queried_point/50, 
	--foot/50, 
	--vec2(vel.x, vel.y),
	--self.jump_impulse*upward_force_multiplier, 
	--self.jetpack_impulse, 
	--self.max_jetpack_steps*upward_force_multiplier, 
	--self.entity.physics.body:GetMass())
end

function coordination_module:pursue_target(target_entity)			
	self.steering_behaviours.pursuit.target_from:set(target_entity)
	self.steering_behaviours.pursuit.enabled = true
	self.steering_behaviours.obstacle_avoidance.enabled = false
end

function coordination_module:stop_pursuit()	
	self.steering_behaviours.pursuit.enabled = false
	self.steering_behaviours.obstacle_avoidance.enabled = true
end

function coordination_module:is_pathfinding()
	return self.entity.pathfinding:is_still_pathfinding() or self.entity.pathfinding:is_still_exploring()
end

function coordination_module:handle_steering()
	local entity = self.entity
	local behaviours = self.steering_behaviours
	local target_entities = self.target_entities
	
	local myvel = entity.physics.body:GetLinearVelocity()
	target_entities.forward.transform.current.pos = entity.transform.current.pos + vec2(myvel.x, myvel.y) * 50
	
	if self:is_pathfinding() then
		target_entities.navigation.transform.current.pos = self.frozen_navpoint
		
		behaviours.obstacle_avoidance.enabled = true
		if behaviours.sensor_avoidance.last_output_force:non_zero() then
			behaviours.target_seeking.enabled = false
			behaviours.forward_seeking.enabled = true
			behaviours.obstacle_avoidance.enabled = true
		else
			behaviours.target_seeking.enabled = true
			behaviours.forward_seeking.enabled = false
		end
	else
		behaviours.target_seeking.enabled = false
		behaviours.forward_seeking.enabled = false
	end
	
		--behaviours.forward_seeking.enabled = false
	behaviours.sensor_avoidance.max_intervention_length = (entity.transform.current.pos - target_entities.navigation.transform.current.pos):length() - 70
	
	if behaviours.obstacle_avoidance.last_output_force:non_zero() then
		behaviours.wandering.current_wander_angle = behaviours.obstacle_avoidance.last_output_force:get_degrees()
	end
end

function coordination_module:handle_player_visibility()
	--if not player.body:get():exists() then 
	--	self.is_seen = false
	--else
		-- resolve player visibility no matter what we're doing 
		local p1 = self.entity.transform.current.pos
		local p2 = player.body:get().transform.current.pos
		
		ray_output = physics_system:ray_cast(p1, p2, create(b2Filter, filter_player_visibility), self.entity)
		
		if not ray_output.hit then
			self.target_entities.last_seen.transform.current.pos = player.body:get().transform.current.pos
			
			self.was_seen = true
			self.is_seen = true
			self.is_alert = true
			
			local player_vel = player.body:get().physics.body:GetLinearVelocity()
			self.last_seen_velocity = vec2(player_vel.x, player_vel.y)
		else
			self.is_seen = false
		end
	--end
end

function coordination_module:handle_visibility_offset()
	if self.movement_mode_flying then
		self.entity.visibility:get_layer(visibility_component.DYNAMIC_PATHFINDING).offset = vec2(0, 0)
	else
		self.target_entities.navigation.transform.current.pos = self.frozen_navpoint
		
		-- handle visibility offset for feet
		self.current_pathfinding_eye = vec2(0, self.foot_sensor_p1.y)
		
		if to_vec2(self.entity.physics.body:GetLinearVelocity()):rotate(-self.entity.movement.axis_rotation_degrees, vec2(0, 0)).x < 0 then
			self.current_pathfinding_eye.x = self.foot_sensor_p1.x
		else
			self.current_pathfinding_eye.x = self.foot_sensor_p2.x
		end
		
		self.entity.visibility:get_layer(visibility_component.DYNAMIC_PATHFINDING).offset = vec2(self.current_pathfinding_eye):rotate(self.entity.movement.axis_rotation_degrees, vec2(0, 0))
	end
end

function coordination_module:handle_flying_state()
	coroutine.resume(self.flying_state_changer)
end

function coordination_module:substep()
	if not self.movement_mode_flying then
		self:handle_jumping()
		self:handle_variable_height_jump()
	end
end

function coordination_module:loop()
	-- get the entity object to extract jumping module
	local jumping = get_self(self.entity).jumping
	
	if jumping ~= nil then
		-- it will only be enabled later on demand
		jumping.enabled = false
	end

	 if self:is_pathfinding() then
		self.frozen_navpoint = self.entity.pathfinding:get_current_navigation_target()
		self.entity.pathfinding.eye_offset = self.current_pathfinding_eye
		self.target_entities.navigation.transform.current.pos = self.frozen_navpoint
	end
	
	self:handle_player_visibility()
	self:handle_visibility_offset()
	self:handle_flying_state()
	
	if self.movement_mode_flying then
		self.entity.movement.requested_movement = vec2(0, 0)
		self:handle_steering()
	else
		if self:is_pathfinding() and not self.entity.pathfinding.first_priority_navpoint_check(self.entity, self.entity.transform.current.pos, self.frozen_navpoint) then
			self.entity.pathfinding:reset_persistent_navpoint()
		end
	
		local real_vector = self.steering_behaviours.target_seeking.last_output_force
		
		-- operations below can't be processed without accompanying jumping module
		if jumping ~= nil then
			-- if we can get there without applying more upward forces, then cancel out the jump behaviour (also stops holding the jetpack)
			if self:determine_jumpability(self.frozen_navpoint, false) then
				--print "stopping jump because we can get there"
				jumping:jump(false)
			-- maybe we can get there by taking the jump now; let's do this then
			elseif self:determine_jumpability(self.frozen_navpoint, true) then
				--print "starting jump; target reachable only in this way"
				jumping:jump(true)
			-- else let the simple movement mapper decide whether to jump or not
			else
				local should_jump = self:angle_fits_in_threshold(real_vector:get_degrees(), -90, 20)
				
				if should_jump then 
				--print 
				--	"jumping as target is higher up" 
					
					jumping:jump(true)
				end
			end
		end
		
		
		self.entity.movement.requested_movement = real_vector + self.steering_behaviours.wandering.last_output_force * 0.1
		
		-- we have disabled flying mode so we need to enable jumping module
		jumping.enabled = true
	end
	
	--render_system:push_line(debug_line(self.entity.transform.current.pos, self.frozen_navpoint, rgba(255, 255, 0, 255)))
	--render_system:push_line(debug_line(self.entity.transform.current.pos, self.entity.pathfinding:get_current_target(), rgba(255, 0, 0, 255)))
	--print "\n\nBehaviours:\n\n"
	--for k, v in pairs(self.steering_behaviours) do
	--	if type(v) == "userdata" then print(k, v.enabled) 
	--	else print (k, type(v)) end
	--end
end
