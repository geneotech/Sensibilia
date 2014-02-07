dofile "sensibilia\\scripts\\steering.lua"

function get_self(entity)
	return entity.scriptable.script_data
end

npc_class = inherits_from {}

function npc_class:initialize(subject_entity) 
	self.jump_timer = stepped_timer(physics_system)
	self.entity = subject_entity
	self.foot_sensor_p1 = vec2(0, 0)
	self.foot_sensor_p2 = vec2(0, 0)
	
	self.is_jumping = false
	self.something_under_foot = false
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
	
	if self.something_under_foot and self.jump_timer:get_steps() > 7 then
		-- if there is, apply no gravity, simulate feet resistance
		--self.entity.physics.body:SetGravityScale(0.0)
		self.entity.movement.thrust_parallel_to_ground_length = 500
		--self.entity.movement.input_acceleration.x = 10000
	else
		--self.entity.movement.input_acceleration.x = 15000
		self.entity.physics.body:SetGravityScale(1.0)
		self.entity.movement.thrust_parallel_to_ground_length = 0
	end
		
	-- perform jumping 
	if self.is_jumping and self.jump_timer:get_steps() > 7 then
		if self.something_under_foot then
			local body = self.entity.physics.body
			local jump_impulse = vec2(0, -150):rotate(gravity_angle_offset, vec2(0, 0)) 
			
			self.entity.physics.body:SetGravityScale(1.0)
			self.entity.movement.thrust_parallel_to_ground_length = 0
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