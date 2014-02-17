function hblur_instability_effect()
	local last_mult = 0
		
	while true do
		
		local transition_duration = randval(10, 500)
		local target_mult = randval(0.1, 1)
		
		local my_val_animator = value_animator(last_mult, target_mult, transition_duration)
		
		my_val_animator:set_exponential()
		
		coroutine.wait(transition_duration, function()
			hblur_program:use()
			
			last_mult = my_val_animator:get_animated()
			--print (last_mult)
			GL.glUniform1f(h_offset_multiplier, last_mult*instability)
			
			
			fullscreen_pass()
			
			
			vblur_program:use()
			
			GL.glUniform1f(v_offset_multiplier, last_mult*instability)
			fullscreen_pass()
		end)
	end
end	