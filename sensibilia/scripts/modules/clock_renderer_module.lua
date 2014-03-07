clock_renderer_module = inherits_from {}

function clock_renderer_module:constructor(subject_group, clock_image, size_scalar, alpha_scalar)
	if alpha_scalar == nil then alpha_scalar = 1 end

	self.group = subject_group
	self.gravity_rotation_multiplier = 1
	self.size_scalar = size_scalar
	self.alpha_scalar = alpha_scalar
	
	self.randomized_hands_values = false
	
	self.clock_sprite = create_sprite {
		image = clock_image,
		size_multiplier = vec2(1.5, 1.5)*size_scalar
	}
	
	self.second_hand_sprite = create_sprite {
		image = images.hand_3,
		size_multiplier = vec2(0.12, 0.12)*size_scalar
	}
	
	self.minute_hand_sprite = create_sprite {
		image = images.hand_1,
		size_multiplier = vec2(0.10, 0.10)*size_scalar
	}
	
	self.hour_hand_sprite = create_sprite {
		image = images.hand_2,
		size_multiplier = vec2(0.12, 0.12)*size_scalar
	}
	
	local body_render = self.group.body:get().render
	body_render.model = self.clock_sprite
	
	self.group.second_hand = create_entity { render = { model = self.second_hand_sprite, mask = body_render.mask, layer = body_render.layer }, transform = {} } 
	self.group.minute_hand = create_entity { render = { model = self.minute_hand_sprite, mask = body_render.mask, layer = body_render.layer }, transform = {} } 
	self.group.hour_hand = create_entity { render = { model = self.hour_hand_sprite, mask = body_render.mask, layer = body_render.layer }, transform = {} } 
	
	self.clock_center = vec2(0, 0)
	self.overwrite_position = true
	
	self.clock_alpha = 1
	
	self.logarithmic_blinks = false
	
	self.global_timer = timer()
	self.global_hand_time = 0
end


function clock_renderer_module:loop()
	local extracted_ms = self.global_timer:extract_milliseconds()
	self.global_hand_time = self.global_hand_time + extracted_ms * physics_system.timestep_multiplier
	
	if self.overwrite_position then
		self.group.body:get().transform.current.pos = self.clock_center
	end
	
	local actual_clock_center = self.group.body:get().transform.current.pos
	
	--print(actual_clock_center.x, actual_clock_center.y)
	--vec2(0, 0)--vec2(config_table.resolution_w/2, config_table.resolution_h/2)*(-1) + vec2(clock_sprite.size.x/2, clock_sprite.size.y/2) + vec2(20, 10)
	
	self.clock_sprite.color = rgba(255, 255, 255, 255*self.clock_alpha*self.alpha_scalar)
	self.second_hand_sprite.color = rgba(0, 0, 0, 50*self.clock_alpha*self.alpha_scalar)
	self.minute_hand_sprite.color = rgba(0, 0, 0, 255*self.clock_alpha*self.alpha_scalar)
	self.hour_hand_sprite.color = rgba(0, 0, 0, 255*self.clock_alpha*self.alpha_scalar)
	
	--print(self.clock_alpha)
	
	--clock_sprite:draw(clock_draw_input)
	
	local current_sum_of_all_healths = 0
	
	local final_rotations = { 0, 0, 0 }
	
	if not self.randomized_hands_values then
		for k, v in pairs(global_entity_table) do
			if v.character ~= nil then
				if v.character.is_enemy then
					current_sum_of_all_healths = current_sum_of_all_healths + v.character.hp
				end
			end
		end
	
		final_rotations[1] = self.global_hand_time/6
		final_rotations[2] = -90 + (20 + (instability + temporary_instability/10) * 340)
		final_rotations[3] = -90 + (20 + (1-(current_sum_of_all_healths/all_enemies_max_health_points)) * 340)
	else
	
	end
	
	self.group.second_hand.transform.current.pos = actual_clock_center + vec2.from_degrees(final_rotations[1]) * ( (self.second_hand_sprite.size.x/2) - 5*self.size_scalar)
	self.group.second_hand.transform.current.rotation = final_rotations[1]
	self.group.minute_hand.transform.current.pos = actual_clock_center + vec2.from_degrees(final_rotations[2]) * ( (self.minute_hand_sprite.size.x/2) - 5*self.size_scalar)
	self.group.minute_hand.transform.current.rotation = final_rotations[2]
	self.group.hour_hand.transform.current.pos = actual_clock_center + vec2.from_degrees(final_rotations[3]) * ( (self.hour_hand_sprite.size.x/2) - 5*self.size_scalar)
	self.group.hour_hand.transform.current.rotation = final_rotations[3]
end
