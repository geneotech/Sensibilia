function hblur_instability_effect()
	local last_mult = 0
		
	while true do
		local transition_duration = randval(10, 300)
		local target_mult = randval(0.1, 0.3)
		
		local my_val_animator = value_animator(last_mult, target_mult, transition_duration)
		
		if randval(0, 1) > 0.5 then
			my_val_animator:set_exponential()
		else
			my_val_animator:set_quadratic()
		end
		
		coroutine.wait(transition_duration, function()
			hblur_program:use()
			
			last_mult = my_val_animator:get_animated()
			GL.glUniform1f(h_offset_multiplier, last_mult*instability)
			
			fullscreen_pass()
		end, true)
	end
end	

function vblur_instability_effect()
	local last_mult = 0
		
	while true do
		local transition_duration = randval(10, 300)
		local target_mult = randval(0.1, 0.3)
		
		local my_val_animator = value_animator(last_mult, target_mult, transition_duration)
		
		if randval(0, 1) > 0.5 then
			my_val_animator:set_exponential()
		else
			my_val_animator:set_logarithmic()
		end
		
		coroutine.wait(transition_duration, function()
			vblur_program:use()
			
			last_mult = my_val_animator:get_animated()
			GL.glUniform1f(v_offset_multiplier, last_mult*instability)
			
			fullscreen_pass()
		end, true)
	end
end	