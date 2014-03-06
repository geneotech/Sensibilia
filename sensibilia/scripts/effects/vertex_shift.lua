function vertex_shift_instability_effect()
	local last_mult = 0
		
	while true do
		local transition_duration = randval(800, 1500)
		local target_mult = randval(1, 10)
		
		local my_val_animator = value_animator(last_mult, target_mult, transition_duration)
		
		if randval(0, 1) > 0.5 then
			my_val_animator:set_exponential()
		else
			my_val_animator:set_logarithmic()
		end
		
		local shift_multiplier = 1
		
		if randval(0, 1) > 0.5 then
			shift_multiplier = -1
		else
			shift_multiplier = 1
		end
		
		coroutine.wait(transition_duration, function()
			last_mult = my_val_animator:get_animated()
			local inst_mult = instability
			
			if inst_mult > 1 then inst_mult = 1 end
			
			GL.glUniform1f(shift_amount_uniform, shift_multiplier * last_mult * instability)
		end, true)
	end
end	