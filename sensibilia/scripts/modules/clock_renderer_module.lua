clock_renderer_module = inherits_from {}

function clock_renderer_module:constructor(subject_group, clock_image, size_scalars, alpha_scalars, randomization_speed_mult)
	if alpha_scalars == nil then alpha_scalars = { 1, 1, 1, 1 } end
	if size_scalars == nil then size_scalars = { 1, 1, 1, 1 } end
	if randomization_speed_mult == nil then randomization_speed_mult = 1 end

	self.group = subject_group
	self.gravity_rotation_multiplier = 1
	self.size_scalars = size_scalars
	self.alpha_scalars = alpha_scalars
	
	self.randomized_hands_values = true
	
	self.second_rotation = 0
	self.minute_rotation = 0
	self.hour_rotation = 0
	
	self.randomization_speed_mult = randomization_speed_mult
	
	self.rotate_body = false
	
	self.body_rotation_variation_table = {
		min_value = -5, max_value = 5, min_transition_ms = 100, max_transition_ms = 200, wait_probability = 0.01, min_wait_ms = 100, max_wait_ms = 200, constant_transition_delta = false, 
		value_additive = false, callback = function(new_rotation) self.group.body:get().transform.current.rotation = new_rotation end
	}
	
	self.body_rotation_variation = coroutine.get_value_variator(self.body_rotation_variation_table)
	
	self.rotation_variation_tables = {
		{
			min_value = -100, max_value = 160, min_transition_ms = 100, max_transition_ms = 400, wait_probability = 0.01, min_wait_ms = 100, max_wait_ms = 1500, constant_transition_delta = false, 
			value_additive = true, callback = function(new_rotation) self.second_rotation = new_rotation end
		},
		
		{
			min_value = -100, max_value = 160, min_transition_ms = 100, max_transition_ms = 400, wait_probability = 0.01, min_wait_ms = 100, max_wait_ms = 1500, constant_transition_delta = false, 
			value_additive = true, callback = function(new_rotation) self.minute_rotation = new_rotation end
		},
		
		{
			min_value = -100, max_value = 160, min_transition_ms = 100, max_transition_ms = 400, wait_probability = 0.01, min_wait_ms = 100, max_wait_ms = 1500, constant_transition_delta = false, 
			value_additive = true, callback = function(new_rotation) self.hour_rotation = new_rotation end
		}
	}
	
	self.rotation_variations = {
		coroutine.get_value_variator(self.rotation_variation_tables[1]),
		coroutine.get_value_variator(self.rotation_variation_tables[2]),
		coroutine.get_value_variator(self.rotation_variation_tables[3])
	}
	
	self.clock_sprite = create_sprite {
		image = clock_image,
		size_multiplier = vec2(1.5, 1.5)*size_scalars[1]
	}
	
	self.second_hand_sprite = create_sprite {
		image = images.hand_3,
		size_multiplier = vec2(0.12, 0.12)*size_scalars[2]
	}
	
	self.minute_hand_sprite = create_sprite {
		image = images.hand_1,
		size_multiplier = vec2(0.10, 0.10)*size_scalars[3]
	}
	
	self.hour_hand_sprite = create_sprite {
		image = images.hand_2,
		size_multiplier = vec2(0.12, 0.12)*size_scalars[4]
	}
	
	local body_render = self.group.body:get().render
	body_render.model = self.clock_sprite
	
	self.group.second_hand = create_entity { render = { model = self.second_hand_sprite, mask = body_render.mask, layer = body_render.layer }, transform = {} } 
	self.group.minute_hand = create_entity { render = { model = self.minute_hand_sprite, mask = body_render.mask, layer = body_render.layer }, transform = {} } 
	self.group.hour_hand = create_entity { render = { model = self.hour_hand_sprite, mask = body_render.mask, layer = body_render.layer }, transform = {} } 
	
	self.clock_center = vec2(0, 0)
	self.overwrite_position = true
	
	self.clock_alpha = 1
	
	self.logarithmic_blink_params = {
		min_wait_ms = 100, max_wait_ms = 5000
	}
	
	self.logarithmic_blinks = false
	self.logarithmic_blink_mult = 1
	self.logarithmic_blink_coroutine = coroutine.wrap(function()
		local args = self.logarithmic_blink_params
		
		while true do
			coroutine.wait(randval(args.min_wait_ms, args.max_wait_ms), nil, false)
			
			local transition_duration =  randval(100, 3000)
			local my_val_animator = value_animator(2, 1, transition_duration)
			my_val_animator:set_logarithmic()
				
			coroutine.wait(transition_duration, function()
				self.logarithmic_blink_mult = my_val_animator:get_animated()
			end, true)
		end
	end)
	
	self.global_timer = timer()
	self.global_hand_time = 0
end


function clock_renderer_module:loop()
	local extracted_ms = self.global_timer:extract_milliseconds()
	self.global_hand_time = self.global_hand_time + extracted_ms * physics_system.timestep_multiplier
	local delta_multiplier = ((1 + instability*30)*self.randomization_speed_mult)
	
	if self.overwrite_position then
		self.group.body:get().transform.current.pos = self.clock_center
	end
	
	if self.rotate_body then
		self.body_rotation_variation_table.min_value = -2 - 140*instability
		self.body_rotation_variation_table.max_value = 2 + 140*instability
		self.body_rotation_variation(delta_multiplier)
	end
	
	if self.logarithmic_blinks then
		self.logarithmic_blink_coroutine(1 + instability*10)
	end
	
	local actual_clock_center = self.group.body:get().transform.current.pos
	
	--print(actual_clock_center.x, actual_clock_center.y)
	--vec2(0, 0)--vec2(config_table.resolution_w/2, config_table.resolution_h/2)*(-1) + vec2(clock_sprite.size.x/2, clock_sprite.size.y/2) + vec2(20, 10)
	
	self.clock_sprite.color = rgba(255, 255, 255, 255*self.logarithmic_blink_mult*self.clock_alpha*self.alpha_scalars[1])
	self.second_hand_sprite.color = rgba(255, 0, 0, 50*self.logarithmic_blink_mult*self.clock_alpha*self.alpha_scalars[2])
	self.minute_hand_sprite.color = rgba(0, 0, 0, 255*self.logarithmic_blink_mult*self.clock_alpha*self.alpha_scalars[3])
	self.hour_hand_sprite.color = rgba(0, 0, 0, 255*self.logarithmic_blink_mult*self.clock_alpha*self.alpha_scalars[4])
	
	--print(self.clock_alpha)
	
	--clock_sprite:draw(clock_draw_input)
	
	
	local final_rotations = { 0, 0, 0 }
	
	if not self.randomized_hands_values then
		self.second_rotation = self.global_hand_time/6
		self.minute_rotation = -90 + (20 + (instability + temporary_instability/10) * 340)
		self.hour_rotation = -90 + (20 + (1-(character_module.sum_of_all_healths()/all_enemies_max_health_points)) * 340)
	else
		--debugger_break()
		self.rotation_variations[1](delta_multiplier)
		self.rotation_variations[2](delta_multiplier)
		self.rotation_variations[3](delta_multiplier)
	end
	
	self.group.second_hand.transform.current.pos = actual_clock_center + vec2.from_degrees(self.second_rotation) * ( (self.second_hand_sprite.size.x/2) - 5*self.size_scalars[2])
	self.group.second_hand.transform.current.rotation = self.second_rotation
	self.group.minute_hand.transform.current.pos = actual_clock_center + vec2.from_degrees(self.minute_rotation) * ( (self.minute_hand_sprite.size.x/2) - 5*self.size_scalars[3])
	self.group.minute_hand.transform.current.rotation = self.minute_rotation
	self.group.hour_hand.transform.current.pos = actual_clock_center + vec2.from_degrees(self.hour_rotation) * ( (self.hour_hand_sprite.size.x/2) - 5*self.size_scalars[4])
	self.group.hour_hand.transform.current.rotation = self.hour_rotation
end
