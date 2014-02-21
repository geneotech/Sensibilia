function state_changer_effect(min_wait, max_wait, flag_to_cha)
	while true do
		coroutine.wait(randval(min_wait, max_wait), nil, false)
		
		
		coroutine.wait(transition_duration, function()
			chromatic_aberration_program:use()
	
			GL.glUniform2f(chromatic_aberration_offset, aberration_offset.x*instability, aberration_offset.y*instability)
		
			fullscreen_pass()
		end, true)
	end
end	