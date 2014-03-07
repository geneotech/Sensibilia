SHADERS_DIRECTORY = "sensibilia\\scripts\\resources\\shaders\\"
EFFECTS_DIRECTORY = "sensibilia\\scripts\\effects\\"

dofile (SHADERS_DIRECTORY .. "fullscreen_vertex_shader.lua")

dofile (SHADERS_DIRECTORY .. "scene_shader.lua")
dofile (SHADERS_DIRECTORY .. "film_grain.lua")
dofile (SHADERS_DIRECTORY .. "chromatic_aberration.lua")
dofile (SHADERS_DIRECTORY .. "blur.lua")
dofile (SHADERS_DIRECTORY .. "color_adjustment.lua")
dofile (SHADERS_DIRECTORY .. "spatial_instability.lua")

dofile (EFFECTS_DIRECTORY .. "utility.lua")
dofile (EFFECTS_DIRECTORY .. "blur.lua")
dofile (EFFECTS_DIRECTORY .. "chromatic_aberration.lua")
dofile (EFFECTS_DIRECTORY .. "film_grain_variation.lua")
dofile (EFFECTS_DIRECTORY .. "vertex_shift.lua")

function refresh_coroutines()
	hblur_coroutine = coroutine.wrap(hblur_instability_effect)
	vblur_coroutine = coroutine.wrap(vblur_instability_effect)
	aberration_coroutine = coroutine.wrap(aberration_instability_effect)
	film_grain_variation_coroutine = coroutine.wrap(film_grain_variation_instability_effect)
end

vertex_shift_coroutine = coroutine.wrap(vertex_shift_instability_effect)

is_instability_ray_over_postprocessing = true

random_instability_ray_layer_order = coroutine.wrap(
	function()
		while true do
			coroutine.wait(randval(50, 100), nil, false)
			
			--is_instability_ray_over_postprocessing = true
		end
	end
)

temporary_instability = 0

random_instability_variation_coroutine = coroutine.wrap(
function ()	
	local last_mult = 0
		
	while true do
		local transition_duration = randval(10, 300)
		local target_instability = randval(0.01, 0.16)
		
		local my_val_animator = value_animator(last_mult, target_instability, transition_duration)
		
		if randval(0, 1) > 0.5 then
			my_val_animator:set_exponential()
		else
			my_val_animator:set_quadratic()
		end
		
		coroutine.wait(transition_duration, function()			
			last_mult = my_val_animator:get_animated()
			temporary_instability = last_mult
		end, true)
	end
end
)


time_speed_variation = 0
random_time_speed_variation_coroutine = coroutine.wrap(
function ()	
	local last_mult = 0
		
	while true do
		local transition_duration = randval(1, 400)
		local target_variation = randval(0.01, 20.0)
		
		local my_val_animator = value_animator(last_mult, target_variation, transition_duration)
		
		if randval(0, 1) > 0.5 then
			my_val_animator:set_exponential()
		else
			my_val_animator:set_quadratic()
		end
		
		coroutine.wait(transition_duration, function()			
			last_mult = my_val_animator:get_animated()
			time_speed_variation = last_mult
		end, true)
	end
end
)



accumulated_camera_time = 0
clock_hand_time = 0

refresh_coroutines()

player_light_fader = polygon_fader()





function rendering_routine(subject, renderer, visible_area, drawn_transform, target_transform, mask)

			
			local extracted_ms = my_timer:extract_milliseconds()
			
			clock_hand_time = clock_hand_time + extracted_ms * physics_system.timestep_multiplier
			local sent_time = (accumulated_camera_time + (extracted_ms*time_speed_variation) * (1+instability*instability*instability*instability*2) * physics_system.timestep_multiplier) 
			accumulated_camera_time = sent_time
				
			random_time_speed_variation_coroutine()
			random_instability_variation_coroutine()
			random_instability_ray_layer_order()
			
			if instability > 1 then instability = 1 end
			
			is_instability_ray_over_postprocessing = not (instability > 0.85)
			
			local prev_instability = instability
			instability = instability + temporary_instability
			
			-- right away update all the uniforms
			scene_program:use()
			
			GL.glUniform1i(scene_shader_time_uniform, sent_time)
				
			my_atlas:bind()
			
			GL.glUniformMatrix4fv(
			projection_matrix_uniform, 
			1, 
			GL.GL_FALSE, 
			orthographic_projection(visible_area.x, visible_area.r, visible_area.b, visible_area.y, 0, 1):data()
			)
			
			local crosshair_pos = player.crosshair:get().transform.current.pos
			local player_pos = player.body:get().transform.current.pos
			
			GL.glUniform2f(player_pos_uniform, crosshair_pos.x, crosshair_pos.y)
			
			instability = instability - temporary_instability + temporary_instability/2
			vertex_shift_coroutine(instability)
			instability = prev_instability + temporary_instability
			
			--GL.glUniform1f(shift_amount_uniform, math.pow(700, instability))

			intensity_fbo:use()
			GL.glClear(GL.GL_COLOR_BUFFER_BIT)
			
		--	GL.glColorMask(GL.GL_TRUE, GL.GL_TRUE, GL.GL_TRUE, GL.GL_TRUE)
			
			renderer:generate_triangles(visible_area, drawn_transform, render_masks.EFFECTS)
			for k, v in ipairs(global_instability_rays) do
				v:generate_triangles(drawn_transform, renderer.triangles, visible_area)
			end
			
			renderer:call_triangles()
			renderer:clear_triangles()
			
			GL.glColorMask(GL.GL_FALSE, GL.GL_FALSE, GL.GL_TRUE, GL.GL_TRUE)
			
			local my_draw_input = draw_input()
			my_draw_input.camera_transform = drawn_transform
			my_draw_input.transform.pos = crosshair_pos
			my_draw_input.output = renderer.triangles
			my_draw_input.visible_area = rect_ltrb(visible_area)
		
			local my_sprite = 
			(create_sprite {
				image = images.crosshair_map,
				color = rgba(0, 0, 255, 255),
				size_multiplier = vec2(0.5, 0.5)
			})
			
			my_sprite:draw(my_draw_input)
			
			
			-- handle point lights and bounces
			
			local lighting_layer = player.body:get().visibility:get_layer(visibility_layers.BASIC_LIGHTING)
			local bounce_layer = player.body:get().visibility:get_layer(visibility_layers.LIGHT_BOUNCE)
			local bounce1_layer = player.body:get().visibility:get_layer(visibility_layers.LIGHT_BOUNCE + 1)
			
			handle_point_light = function(poly_vector, ms_fade, target_fade, light_distance, used_attenuation)
				local visibility_points = vector_to_table(poly_vector)
				--
				---- expand these points a little
				for k, v in ipairs(visibility_points) do
					visibility_points[k] = visibility_points[k] + (vec2(visibility_points[k] - player_pos)*0.01)
				end
			
				local my_light_poly = simple_create_polygon(visibility_points)
				map_uv_square(my_light_poly, images.blank)
				set_polygon_color(my_light_poly, rgba(0, 0, 255, 255))
				
				
				local attenuation_mult = 1
			    
				if light_distance ~= nil then
					attenuation_mult = 1.0/(used_attenuation[1]+used_attenuation[2]*light_distance+used_attenuation[3]*light_distance*light_distance)
				end
			    
				local new_light_animator = value_animator(255*attenuation_mult, target_fade*attenuation_mult, ms_fade)
				new_light_animator:set_quadratic()
				
				player_light_fader:add_trace(my_light_poly, new_light_animator)
			end
			
			handle_point_light(lighting_layer:get_polygon(1), 150, -0.1)
			if bounce_number >= 0.0 then handle_point_light(bounce_layer:get_polygon(1), 950, 254, bounce_layer.offset:length(), { 32.81166, 0.03501, 0.0000000 } ) end 
			if bounce_number > 1.5 then handle_point_light(bounce1_layer:get_polygon(1), 2950, 254, bounce_layer.offset:length() + bounce1_layer.offset:length(), { 0, 0.020100, 0.000000000 } ) end
			
			player_light_fader:loop()
			player_light_fader:generate_triangles(drawn_transform, renderer.triangles, visible_area)
			
			renderer:call_triangles()
			renderer:clear_triangles()
			
			GL.glColorMask(GL.GL_TRUE, GL.GL_TRUE, GL.GL_TRUE, GL.GL_TRUE)
			
			
			current_postprocessing_fbo = 0
			
			postprocessing_fbos[0]:use()
			GL.glClear(GL.GL_COLOR_BUFFER_BIT)
			
			renderer:generate_triangles(visible_area, drawn_transform, mask)
			

			
			
	

			--hour_hand_sprite:draw(clock_draw_input)
			
			--hour_hand_sprite:draw(clock_draw_input)
			
			renderer:call_triangles()
			renderer:clear_triangles()
			
			--GL.glDisable(GL.GL_TEXTURE_2D)
			--renderer:draw_debug_info(visible_area, drawn_transform, images.blank.tex)
			--GL.glEnable(GL.GL_TEXTURE_2D)
			
			
			
			
			
			
			-- postprocessing
			
			hblur_program:use()
			GL.glUniform1f(h_offset_multiplier, instability*instability*instability*instability*instability*instability*instability*instability*1.8)
			fullscreen_pass(false, nil, intensity_fbo)
			vblur_program:use()
			GL.glUniform1f(v_offset_multiplier, instability*instability*instability*instability*instability*instability*instability*instability*1.8)
			fullscreen_pass(true, intensity_fbo)
			
			current_postprocessing_fbo = 0
			
			local instability_ray_fx = function()
				spatial_instability_program:use()
				
				
				local visibility_vec = vec2(visible_area.w, visible_area.h)
				local screen_space_player = (player_pos - (drawn_transform.pos - visibility_vec/2)) / current_zoom_multiplier
				local screen_space_crosshair = (crosshair_pos - (drawn_transform.pos - visibility_vec/2))  / current_zoom_multiplier
				
				GL.glUniform1i(spatial_instability_time, sent_time)
				GL.glUniform1f(spatial_instability_rotation, (crosshair_pos - player_pos):perpendicular_cw():get_radians() + 3.14159265)
				GL.glUniform2f(spatial_instability_player_pos, screen_space_player.x, config_table.resolution_h-screen_space_player.y)
				GL.glUniform2f(spatial_instability_crosshair_pos, screen_space_crosshair.x, config_table.resolution_h-screen_space_crosshair.y)
				GL.glUniform1f(spatial_instability_zoom, current_zoom_multiplier)
				GL.glUniform1f(spatial_instability_multiplier, instability)
				
				GL.glActiveTexture(GL.GL_TEXTURE1)
				GL.glBindTexture(GL.GL_TEXTURE_2D, intensity_fbo:get_texture_id())
				GL.glActiveTexture(GL.GL_TEXTURE0)
			end
			
			current_postprocessing_fbo = 0
			postprocessing_fbos[0]:use()
			
			if not is_instability_ray_over_postprocessing then
				instability_ray_fx()
				fullscreen_pass()
			end
			
			if instability > 0 then
				hblur_coroutine()
				vblur_coroutine()
				
				film_grain_program:use()
				film_grain_variation_coroutine(instability)
				--film_grain_program:use()
				GL.glUniform1i(time_uniform, sent_time)
				fullscreen_quad()
				aberration_coroutine(instability)
				
			else
				film_grain_program:use()
				GL.glUniform1f(film_grain_intensity, 0.1)
				GL.glUniform1i(time_uniform, sent_time)
				fullscreen_quad()
				refresh_coroutines()
			end
			
			if is_instability_ray_over_postprocessing then
				instability_ray_fx()
			else
				color_adjustment_program:use()
			end
			
			fullscreen_pass(true)
			
			
			lighting_layer.offset = vec2.random_on_circle(randval(1,59)*instability)
			
			instability = prev_instability
			
			local random_discontinuity_end = function(source_layer)
				local randomized_num = 0
			
				local num_discontinuities = source_layer:get_num_discontinuities()
				local random_offseted_position = vec2(0, 0)
					
				if num_discontinuities ~= 0 then
					if num_discontinuities > 1 then
						randomized_num = randval_i(0, source_layer:get_num_discontinuities()-1)
					end
					
					local random_discontinuity = source_layer:get_discontinuity(randomized_num)
					
					return random_discontinuity.points.second + (random_discontinuity.points.first - random_discontinuity.points.second):set_length(randval(1, 2))
				end
				
				return vec2(0, 0)
			end
			
			bounce_layer.offset = random_discontinuity_end(lighting_layer) - player_pos
			bounce1_layer.offset = random_discontinuity_end(bounce_layer) - player_pos
end

