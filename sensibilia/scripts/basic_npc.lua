


basic_npc_sprite = create_sprite {
	image = images.blank,
	size = vec2(30, 100),
	color = rgba(255, 0, 0, 200)
}

basic_npc_class = inherits_from (npc_class)

function basic_npc_class:initialize(subject_entity)
	npc_class.initialize(self, subject_entity)
	
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
	self:set_movement_mode_flying(false)
	
	
	self.was_seen = false
	self.is_seen = false
	self.is_alert = false
	self.last_seen_velocity = vec2(0, 0)
		
	self.steering_behaviours.forward_seeking.target_from:set(self.target_entities.forward)
	self.steering_behaviours.target_seeking.target_from:set(self.target_entities.navigation)
	self.steering_behaviours.sensor_avoidance.target_from:set(self.target_entities.navigation)
	
	self.steering_behaviours.pursuit.enabled = false
	
	self.current_pathfinding_eye = vec2(0, 0)
	self.can_jump_to_navpoint = false
	self.frozen_navpoint = vec2(0, 0)
end

function basic_npc_class:set_movement_mode_flying(flag)
	self.movement_mode_flying = flag
	self.entity.movement.sidescroller_setup = not flag
		
	if flag then
		self.entity.movement.requested_movement = vec2(0, 0)
		self.steering_behaviours.target_seeking.weight_multiplier = 1
		self.entity.physics.body:SetGravityScale(0.0)
		SetFriction(self.entity.physics.body, 0)
		
	else
		SetFriction(self.entity.physics.body, 2)		
		self.steering_behaviours.target_seeking.weight_multiplier = 0
		self.steering_behaviours.target_seeking.enabled = true
		self.steering_behaviours.sensor_avoidance.enabled = true
		self.steering_behaviours.forward_seeking.enabled = false
		--self:set_all_behaviours_enabled(false)
		-- the only behaviour that is enabled and will be mapped to the left-right-jump movement
		--self.steering_behaviours.target_seeking.enabled = true
	end
end

function basic_npc_class:set_all_behaviours_enabled(flag)
	for k, v in pairs(self.steering_behaviours) do
		v.enabled = flag
	end
end

function basic_npc_class:refresh_behaviours() 
	self.entity.steering:clear_behaviours()
	
	for k, v in pairs(self.steering_behaviours) do
		self.entity.steering:add_behaviour(v)
	end
end

function basic_npc_class:angle_fits_in_threshold(angle, axis_angle, threshold)
	angle = angle - self.entity.movement.axis_rotation_degrees
	return angle > axis_angle - threshold and angle < axis_angle + threshold
end

function basic_npc_class:map_vector_to_movement(real_vector)
	self.entity.movement.requested_movement = real_vector
	local should_jump = self:angle_fits_in_threshold(real_vector:get_degrees(), -90, 20)
	self:jump(should_jump)
	
	return should_jump
end

function basic_npc_class:determine_jumpability(queried_point)	
	local vel = self.entity.physics.body:GetLinearVelocity()
	local foot = self.entity.transform.current.pos + self.current_pathfinding_eye
	
	return can_point_be_reached_by_jump(base_gravity, self.entity.movement.input_acceleration/50, self.entity.movement.air_resistance, 
					queried_point/50, foot/50, vec2(vel.x, vel.y), vec2(0, -150), self.entity.physics.body:GetMass())
end

function basic_npc_class:pursue_target(target_entity)			
	self.steering_behaviours.pursuit.target_from:set(target_entity)
	self.steering_behaviours.pursuit.enabled = true
	self.steering_behaviours.obstacle_avoidance.enabled = false
end

function basic_npc_class:stop_pursuit()	
	self.steering_behaviours.pursuit.enabled = false
	self.steering_behaviours.obstacle_avoidance.enabled = true
end

function basic_npc_class:is_pathfinding()
	return self.entity.pathfinding:is_still_pathfinding() or self.entity.pathfinding:is_still_exploring()
end

function basic_npc_class:handle_steering()
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
	
	behaviours.sensor_avoidance.max_intervention_length = (entity.transform.current.pos - target_entities.navigation.transform.current.pos):length() - 70
	
	if behaviours.obstacle_avoidance.last_output_force:non_zero() then
		behaviours.wandering.current_wander_angle = behaviours.obstacle_avoidance.last_output_force:get_degrees()
	end
end

function basic_npc_class:handle_player_visibility()
	--if not player.body:exists() then 
	--	self.is_seen = false
	--else
		-- resolve player visibility no matter what we're doing 
		local p1 = self.entity.transform.current.pos
		local p2 = player.body.transform.current.pos
		
		ray_output = physics_system:ray_cast(p1, p2, create(b2Filter, filter_player_visibility), self.entity)
		
		if not ray_output.hit then
			self.target_entities.last_seen.transform.current.pos = player.body.transform.current.pos
			
			self.was_seen = true
			self.is_seen = true
			self.is_alert = true
			
			local player_vel = player.body.physics.body:GetLinearVelocity()
			self.last_seen_velocity = vec2(player_vel.x, player_vel.y)
		else
			self.is_seen = false
		end
	--end
end

function basic_npc_class:handle_visibility_offset()
	if self:is_pathfinding() then
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
end

function basic_npc_class:handle_flying_state()
	 if self:is_pathfinding() then
		local vel = self.entity.physics.body:GetLinearVelocity()
		local nav_target = self.frozen_navpoint
		local foot = self.entity.transform.current.pos + self.current_pathfinding_eye
	 
		--print(self.movement_mode_flying, foot.y, nav_target.y, self.jump_height, (foot.y - nav_target.y))
	 
		local to_navigation_target_angle = (nav_target - foot):get_degrees()
		if self.movement_mode_flying and foot.y < nav_target.y-20 then
			self:set_movement_mode_flying(false)
			print"idziemy"
		elseif not self.movement_mode_flying then
			self.can_jump_there_now = self:determine_jumpability(nav_target)
			local is_reachable_height = (foot.y - nav_target.y) <= self.jump_height 
		
			print (self.can_jump_there_now, is_reachable_height)
			if not self.can_jump_there_now and not is_reachable_height then
				print"lecimy"
				self:set_movement_mode_flying(true)
			end
		end
	 end
end

function basic_npc_class:loop()
	-- if walking mode and in air, let us just peacefully fall to just one navigation point mkay?
	if not self.entity.pathfinding:exists_through_undiscovered_visible(self.frozen_navpoint, pathfinding_system.epsilon_distance_the_same_vertex)
	or not (not self.movement_mode_flying and not self.something_under_foot) then
		self.frozen_navpoint = self.entity.pathfinding:get_current_navigation_target()
	end
		
	self:handle_player_visibility()
	
	self:handle_visibility_offset()
	
	self:handle_flying_state()
	
	if self.movement_mode_flying then
		self:handle_steering()
	else
	 if self:is_pathfinding() then
		self.target_entities.navigation.transform.current.pos = self.frozen_navpoint
	 end
	 
		local decided_to_jump_because_under_navpoint = self:map_vector_to_movement(self.steering_behaviours.target_seeking.last_output_force)
		self:jump(not decided_to_jump_because_under_navpoint and self.can_jump_there_now)
		self:handle_jumping()
	end
	
	render_system:push_line(debug_line(self.entity.transform.current.pos, self.frozen_navpoint, rgba(255, 255, 0, 255)))
	
	
	--print "\n\nBehaviours:\n\n"
	--for k, v in pairs(self.steering_behaviours) do
	--	if type(v) == "userdata" then print(k, v.enabled) 
	--	else print (k, type(v)) end
	--end
end

my_basic_npc = spawn_npc({
	body = {
		--physics = {
		--	body_type = Box2D.b2_staticBody
		--},
		render = {
			model = basic_npc_sprite
		},
		
		transform = {
			pos = vec2(0, -10000)
		},
		
		visibility = {
			visibility_layers = {
				[visibility_component.DYNAMIC_PATHFINDING] = {
					square_side = 15000,
					color = rgba(0, 255, 255, 120),
					ignore_discontinuities_shorter_than = 200,
					filter = filter_pathfinding_visibility
				}
			}
		},
		
		pathfinding = {
			enable_backtracking = true,
			target_offset = 100,
			rotate_navpoints = 10,
			distance_navpoint_hit = 2,
			favor_velocity_parallellness = false
		},
		
		steering = {
			max_resultant_force = -1, -- -1 = no force clamping
			max_speed = 12000
		}
	}
}, basic_npc_class)


	--self.steering_behaviours.target_seeking.enabled = false
	--self.steering_behaviours.target_seeking.target:set(player.crosshair.transform.current.pos, vec2(0, 0))

get_self(my_basic_npc.body):set_foot_sensor_from_sprite(basic_npc_sprite, 3)
--my_basic_npc.body:disable()