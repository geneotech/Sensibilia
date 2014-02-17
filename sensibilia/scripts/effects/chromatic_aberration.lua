function aberration_instability_effect()
	while true do
		if randval(0, 1) > 0.5 then
			coroutine.wait(randval(500, 1000), nil, false)
		end
	
		local transition_duration = randval(1, 50)
		local aberration_offset = vec2.random_on_circle(randval(0.001, 0.09))
		
		coroutine.wait(transition_duration, function()
			chromatic_aberration_program:use()
	
			GL.glUniform2f(chromatic_aberration_offset, aberration_offset.x*instability, aberration_offset.y*instability)
		
			fullscreen_pass()
		end, true)
	end
end	