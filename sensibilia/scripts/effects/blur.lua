function hblur_instability_effect()
	while true do
		local transitions = table_of_tables(randval(10, 20))
		
		--if #transitions < 1 then coroutine.yield() end
		
		
		--print (#transitions)
		
		randomize_properties(10, 500, "transition_duration", transitions)
		randomize_properties(0.1, 1, "target_mult", transitions)
		
		--print (table.inspect(transitions))
		
		local last_mult = 0
		for k, v in ipairs(transitions) do
			--print(last_mult, v.target_mult)
			local my_val_animator = value_animator(last_mult, v.target_mult, v.transition_duration)
			my_val_animator:set_exponential()
		
			coroutine.wait(v.transition_duration, function()
				hblur_program:use()
				
				last_mult = my_val_animator:get_animated()
				--print (last_mult)
				GL.glUniform1f(h_offset_multiplier, last_mult*instability)
				
				
				fullscreen_pass()
				
				
				vblur_program:use()
				
				--last_mult = my_val_animator:get_animated()
				--print (last_mult)
				GL.glUniform1f(v_offset_multiplier, last_mult*instability)
				
				
				fullscreen_pass()
			end)
		end
	end
end	