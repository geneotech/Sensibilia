function film_grain_variation_instability_effect()
	while true do
		if randval(0, 1) > 0.5 then
			coroutine.wait(randval(100, 3000), function()  
				GL.glUniform1f(film_grain_intensity, 0.1) 
			end, false)
		end
	
		local transition_duration = randval(1, 50)
		local intensity_offset = randval(0.0, 0.5)
		
		coroutine.wait(transition_duration, function()
			local new_intensity =  0.1 + intensity_offset * instability
			print (new_intensity)
			GL.glUniform1f(film_grain_intensity, new_intensity)
		
			fullscreen_pass()
		end, true)
	end
end	


GL.glUniform1f(film_grain_intensity, 0.1)