dofile "sensibilia\\scripts\\steering.lua"

function get_self(entity)
	return entity.scriptable.script_data
end

npc_class = inherits_from {}

function npc_class:initialize(subject_entity) 
	self.jump_timer = timer()
	self.entity = subject_entity
	self.foot_sensor_p1 = vec2(0, 0)
	self.foot_sensor_p2 = vec2(0, 0)
	
	self.is_jumping = false
	self.something_under_foot = false
	
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
	
	self:refresh_behaviours()
	
	for k, v in pairs(self.steering_behaviours) do
		v.enabled = false
	end
	
	self.current_pathfinding_eye = vec2(0, 0)
end

function npc_class:refresh_behaviours() 
	self.entity.steering:clear_behaviours()
	
	for k, v in pairs(self.steering_behaviours) do
		self.entity.steering:add_behaviour(v)
	end
end
	
function npc_class:jump(jump_flag)
	self.is_jumping = jump_flag
end

function npc_class:set_gravity_shift_state(enable)
	local entity = self.entity

	if enable then
		entity.physics.enable_angle_motor = true
		entity.physics.body:SetFixedRotation(false)
	else
		entity.physics.body:SetFixedRotation(true)
		entity.physics.enable_angle_motor = false
	end
end

function npc_class:handle_steering()
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

function npc_class:handle_player_visibility()
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

function npc_class:handle_jumping()
	-- determine if something is under foot 
	local pos = self.entity.transform.current.pos
	
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
		
	local under_foot_candidates = physics_system:query_polygon(query_rect, create(b2Filter, filter_npc_feet), self.entity)
	
	self.something_under_foot = false
	
	for candidate in under_foot_candidates.bodies do
		self.something_under_foot = true
	end
	
	if self.something_under_foot then
		-- if there is, apply no gravity, simulate feet resistance
		self.entity.physics.body:SetGravityScale(0.0)
		self.entity.movement.thrust_parallel_to_ground_length = 500
		--self.entity.movement.input_acceleration.x = 10000
	else
		--self.entity.movement.input_acceleration.x = 15000
		self.entity.physics.body:SetGravityScale(1.0)
		self.entity.movement.thrust_parallel_to_ground_length = 0
	end
		
	-- perform jumping 
	if self.is_jumping and self.jump_timer:get_milliseconds() > 100 then
		if self.something_under_foot then
			local body = self.entity.physics.body
			local jump_impulse = vec2(0, -150):rotate(gravity_angle_offset, vec2(0, 0)) 
			
			body:ApplyLinearImpulse(b2Vec2(jump_impulse.x, jump_impulse.y), body:GetWorldCenter(), true)
		end
		
		self.jump_timer:reset()
	end
end

function npc_class:loop()	
	self:handle_jumping()
end

function npc_class:set_foot_sensor_from_sprite(subject_sprite, thickness) 
	self.foot_sensor_p1 = vec2(-subject_sprite.size.x / 2 + 1, subject_sprite.size.y / 2)
	self.foot_sensor_p2 = vec2( subject_sprite.size.x / 2 - 1, subject_sprite.size.y / 2 + thickness) 
end

function npc_class:set_foot_sensor_from_circle(radius, thickness) 
	self.foot_sensor_p1 = vec2(-radius, radius)
	self.foot_sensor_p2 = vec2( radius, radius + thickness) 
end

function npc_class:map_vector_to_movement(real_vector)
	local jump_angle_threshold = 10
	
	self.entity.movement.requested_movement = real_vector
	
	local angle = real_vector:get_degrees() - self.entity.movement.axis_rotation_degrees
	self:jump(angle > -90 - jump_angle_threshold and angle < -90 + jump_angle_threshold)
end

function npc_class:pursue_target(target_entity)			
	self.steering_behaviours.pursuit.target_from:set(target_entity)
	self.steering_behaviours.pursuit.enabled = true
	self.steering_behaviours.obstacle_avoidance.enabled = false
end

function npc_class:stop_pursuit()	
	self.steering_behaviours.pursuit.enabled = false
	self.steering_behaviours.obstacle_avoidance.enabled = true
end

npc_basic_loop = create_scriptable_info {
	scripted_events = {
		[scriptable_component.LOOP] = function (subject)
			get_self(subject):loop()
		end
	}
}

npc_group_archetype = {
	body = {
		physics = {
			body_type = Box2D.b2_dynamicBody,
			
			body_info = {
				shape_type = physics_info.RECT,
				radius = 60,
				--rect_size = vec2(30, 30),
				filter = filter_objects,
				density = 1,
				friction = 2,
				
				--,
				fixed_rotation = true
			}	
		},
		
		render = {
			layer = render_layers.OBJECTS
		},
		
		transform = {},
		
		movement = {
			input_acceleration = vec2(10000, 0),
			max_speed_animation = 2300,
			air_resistance = 0.1,
			inverse_thrust_brake = vec2(500, 0),
			
			ground_filter = filter_npc_feet,
			
			receivers = {},
			
			--force_offset = vec2(0, 5)
			
			--receivers = {
			--	{ target = "body", stop_at_zero_movement = false }, 
			--	{ target = "legs", stop_at_zero_movement = true  }
			--}
		},
		
		scriptable = {
			available_scripts = npc_basic_loop
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
}

function spawn_npc(group_overrider, what_class)
	if what_class == nil then what_class = npc_class end
	
	local my_new_npc = create_entity_group (archetyped(npc_group_archetype, group_overrider))
	
	local new_npc_scriptable = what_class:create()
	new_npc_scriptable:initialize(my_new_npc.body)
	
	my_new_npc.body.scriptable.script_data = new_npc_scriptable
	
	return my_new_npc
end

dofile "sensibilia\\scripts\\basic_npc.lua"