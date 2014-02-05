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
	
	self.current_pathfinding_eye = vec2(0, 0)

end

function basic_npc_class:set_movement_mode_flying(flag)
	self.movement_mode_flying = flag

	if flag then
		self:set_all_behaviours_enabled(true)
	else
		self:set_all_behaviours_enabled(false)
		-- the only behaviour that is enabled and will be mapped to the left-right-jump movement
		self.steering_behaviours.target_seeking.enabled = true
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

function basic_npc_class:handle_steering()
	local entity = self.entity
	local behaviours = self.steering_behaviours
	local target_entities = self.target_entities
	
	local myvel = entity.physics.body:GetLinearVelocity()
	target_entities.forward.transform.current.pos = entity.transform.current.pos + vec2(myvel.x, myvel.y) * 50
	
	if entity.pathfinding:is_still_pathfinding() or entity.pathfinding:is_still_exploring() then
		target_entities.navigation.transform.current.pos = entity.pathfinding:get_current_navigation_target()
		
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

function basic_npc_class:map_vector_to_movement(real_vector)
	local jump_angle_threshold = 10
	
	self.entity.movement.requested_movement = real_vector
	
	local angle = real_vector:get_degrees() - self.entity.movement.axis_rotation_degrees
	self:jump(angle > -90 - jump_angle_threshold and angle < -90 + jump_angle_threshold)
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

function basic_npc_class:loop()
	self:handle_steering()
	self:handle_player_visibility()
	
		-- handle pathfinding
	if self.entity.pathfinding:is_still_pathfinding() or self.entity.pathfinding:is_still_exploring() then
		target_entities.navigation.transform.current.pos = entity.pathfinding:get_current_navigation_target()
		
		-- handle visibility offset for feet
		local decided_offset = vec2(0, self.foot_sensor_p1.y)
		
		if to_vec2(self.entity.physics.body:GetLinearVelocity()):rotate(-self.entity.movement.axis_rotation_degrees, vec2(0, 0)).x < 0 then
			decided_offset.x = self.foot_sensor_p1.x
		else
			decided_offset.x = self.foot_sensor_p2.x
		end
		
		self.entity.visibility:get_layer(visibility_component.DYNAMIC_PATHFINDING).offset = vec2(decided_offset):rotate(self.entity.movement.axis_rotation_degrees, vec2(0, 0))
	end
	
	self.steering_behaviours.target_seeking.enabled = true
	self.steering_behaviours.target_seeking.target:set(player.crosshair.transform.current.pos, vec2(0, 0))
	
	self:map_vector_to_movement(self.steering_behaviours.target_seeking.last_output_force)
	
	self:handle_jumping()
end

my_basic_npc = spawn_npc({
	body = {
		render = {
			model = basic_npc_sprite
		},
		
		transform = {
			pos = vec2(500, -1000)
		},
		
		visibility = {
			visibility_layers = {
				[visibility_component.DYNAMIC_PATHFINDING] = {
					square_side = 15000,
					color = rgba(0, 255, 255, 120),
					ignore_discontinuities_shorter_than = -1,
					filter = filter_pathfinding_visibility
				}
			}
		},
		
		pathfinding = {
			enable_backtracking = true,
			target_offset = 100,
			rotate_navpoints = 10,
			distance_navpoint_hit = 2,
			favor_velocity_parallellness = true
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