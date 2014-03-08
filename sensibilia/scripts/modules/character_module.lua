character_module = inherits_from {}

function character_module:constructor(subject_entity, base_movement)
	self.entity = subject_entity
	self.movement_speed_multiplier = 1
	self.base_movement_speed = base_movement
	
	
	self.is_enemy = true
	self.hp = 100
	self.max_hp = 100
	self:update_movement_speeds()
end

function character_module:update_movement_speeds()
	if self.entity.steering then
		self.entity.steering.max_speed = self.base_movement_speed*1.4142135623730950488016887242097*self.movement_speed_multiplier
	end

	if self.entity.movement then
		self.entity.movement.input_acceleration.x = self.base_movement_speed*self.movement_speed_multiplier
		--print "WARNING: unset movement speed!!!"
		--debugger_break()
	end
end

function character_module:init_hp(hp_amount)
	self.hp = hp_amount
	self.max_hp = hp_amount
end

function character_module:set_movement_speed_multiplier(multiplier)
	self.movement_speed_multiplier = multiplier
	self:update_movement_speeds()
end

function character_module:set_base_movement_speed(speed)
	self.base_movement_speed = speed
	self:update_movement_speeds()
end

function character_module:damage_message(message)
	self.hp = self.hp - message.amount
	
	if self.hp < 0 then
		-- remove its reference in global entity table
		if self.is_enemy then
			instability = instability - 0.3
		end
		
		for i=1, #global_entity_table do
			if global_entity_table[i].character ~= nil and global_entity_table[i].character == self then
				table.remove(global_entity_table, i)
				print "removing"
				break
			end
		end
		
		local msg = destroy_message()
		msg.subject = self.entity
		world:post_message(msg)
	end
end

function character_module:set_gravity_shift_state(enable)
	local entity = self.entity

	if enable then
		entity.physics.enable_angle_motor = true
		entity.physics.body:SetFixedRotation(false)
	else
		entity.physics.body:SetFixedRotation(true)
		entity.physics.enable_angle_motor = false
	end
end

-- a generic entity group archetype that make up a typical character
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
				angled_damping = true,
				
				--,
				fixed_rotation = true
			}	
		},
		
		render = {
			layer = render_layers.OBJECTS
		},
		
		transform = {},
		
		movement = {
			input_acceleration = vec2(6000, 0),
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
		
		scriptable = {}
	}
}
