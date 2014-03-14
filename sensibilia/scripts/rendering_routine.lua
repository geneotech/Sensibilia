


EFFECTS_DIRECTORY = "sensibilia\\scripts\\effects\\"


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
			coroutine.wait(randval(1000, 7000), nil, false)
			is_instability_ray_over_postprocessing = false
			coroutine.wait(randval(100, 600), nil, true)
			is_instability_ray_over_postprocessing = true
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
	local last_mult = 0.1
		
	while true do
		local transition_duration = randval(1, 400)
		local target_variation = randval(0.1, 20.0)
		
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
player_light_fader.max_traces = -1

function rendering_routine(subject, 
			--visible_area, drawn_transform, 
			camera_draw_input,
			mask)
			local renderer = camera_draw_input.output
			local visible_area = camera_draw_input.visible_area
			
			local extracted_ms = my_timer:extract_milliseconds()
			
			clock_hand_time = clock_hand_time + extracted_ms
			local sent_time = (accumulated_camera_time + (extracted_ms*time_speed_variation) * (1+instability*instability*instability*instability*2) * physics_system.timestep_multiplier) 
			accumulated_camera_time = sent_time
				
			random_time_speed_variation_coroutine()
			random_instability_variation_coroutine()
			random_instability_ray_layer_order(1 + instability*5)
			
			if not level_resources.draw_geometry then
				is_instability_ray_over_postprocessing = false
			end
			
			--if instability > 1 then instability = 1 end
			
			--is_instability_ray_over_postprocessing = true--not (instability > 0.85)
			
			local prev_instability = instability
			instability = instability + temporary_instability
			
			if level_world.is_paused then instability = 0.2 end
			
			-- right away update all the uniforms
			scene_program:use()
			
			GL.glUniform1i(scene_shader_time_uniform, sent_time)
				
			my_atlas:bind()
			
			GL.glUniformMatrix4fv(
			projection_matrix_uniform, 
			1, 
			GL.GL_FALSE, 
			orthographic_projection(0, visible_area.x, visible_area.y, 0, 0, 1):data()
			--orthographic_projection(-visible_area.x*2, visible_area.x*2, visible_area.y*2, -visible_area.y*2, 0, 1):data()
			)
			
			local crosshair_pos = vec2(0, 0)
			local player_pos = vec2(0, 0)
			
			if level_resources.rendered_crosshair_entity ~= nil then
				crosshair_pos = level_resources.rendered_crosshair_entity.transform.current.pos
			elseif player ~= nil then
				crosshair_pos = player.crosshair:get().transform.current.pos
				player_pos = player.body:get().transform.current.pos
			end
			
			GL.glUniform2f(player_pos_uniform, crosshair_pos.x, crosshair_pos.y)
			
			instability = instability - temporary_instability + temporary_instability/2
			vertex_shift_coroutine(instability)
			instability = prev_instability + temporary_instability
			if level_world.is_paused then instability = 0.2 end
			
			--GL.glUniform1f(shift_amount_uniform, math.pow(700, instability))

			intensity_fbo:use()
			GL.glClear(GL.GL_COLOR_BUFFER_BIT)
			
		--	GL.glColorMask(GL.GL_TRUE, GL.GL_TRUE, GL.GL_TRUE, GL.GL_TRUE)
			
			if not level_world.is_paused and level_resources.draw_geometry then 
				renderer:generate_triangles(camera_draw_input, render_masks.EFFECTS) 
				if global_instability_rays ~= nil then
					for k, v in ipairs(global_instability_rays) do
						v:generate_triangles(camera_draw_input)
					end
				end
			end
			
			renderer:call_triangles()
			renderer:clear_triangles()
			
			GL.glColorMask(GL.GL_FALSE, GL.GL_FALSE, GL.GL_TRUE, GL.GL_TRUE)
			
			camera_draw_input.transform.pos = crosshair_pos
		
			local my_sprite = 
			(create_sprite {
				image = images.crosshair_map,
				color = rgba(0, 0, 255, 255),
				size_multiplier = vec2(0.5, 0.5)
			})
			
			my_sprite:draw(camera_draw_input)
			
			-- handle point lights and bounces
			
			local lighting_layer; 
			local bounce_layer;
			local bounce1_layer; 
			
			if level_resources.draw_geometry and not level_world.is_paused and player ~= nil then
				lighting_layer = player.body:get().visibility:get_layer(visibility_layers.BASIC_LIGHTING)
				bounce_layer = player.body:get().visibility:get_layer(visibility_layers.LIGHT_BOUNCE)
				bounce1_layer = player.body:get().visibility:get_layer(visibility_layers.LIGHT_BOUNCE + 1)
				
				handle_point_light = function(poly_vector, ms_fade, target_fade, light_distance, used_attenuation)
					local visibility_points = vector_to_table(poly_vector)
				
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
				
				handle_point_light(lighting_layer:get_polygon(1, player_pos, 0.01), 150, -0.1)
				if bounce_number >= 0.0 then handle_point_light(bounce_layer:get_polygon(1, player_pos, 0.01), 550, 254, bounce_layer.offset:length(), { 32.81166, 0.03501, 0.0000000 } ) end 
				if bounce_number > 1.5 then handle_point_light(bounce1_layer:get_polygon(1, player_pos, 0.01), 950, 254, bounce_layer.offset:length() + bounce1_layer.offset:length(), { 0, 0.020100, 0.000000000 } ) end
				
				player_light_fader:loop()
				player_light_fader:generate_triangles(camera_draw_input)
			
				local player_draw_input = draw_input(camera_draw_input)
				
				player_draw_input.additional_info = player.body:get().render
				player_draw_input.transform = player.body:get().transform.current
				
				player.body:get().render:get_sprite().color = rgba(0, 0, 0, 250-20*instability)
				player.body:get().render.model:draw(player_draw_input)
				player.body:get().render:get_sprite().color = rgba(255, 255, 255, 255)
			end
			
			
			
			renderer:call_triangles()
			renderer:clear_triangles()
			
			GL.glColorMask(GL.GL_TRUE, GL.GL_TRUE, GL.GL_TRUE, GL.GL_TRUE)
			
			
			current_postprocessing_fbo = 0
			
			postprocessing_fbos[0]:use()
			GL.glClear(GL.GL_COLOR_BUFFER_BIT)
			
			if level_resources.draw_geometry then
				renderer:generate_triangles(camera_draw_input, mask)
			end
			
			if level_resources.basic_geometry_callback then
				level_resources.basic_geometry_callback(camera_draw_input)
			end
			
			renderer:call_triangles()
			renderer:clear_triangles()
			
			--GL.glDisable(GL.GL_TEXTURE_2D)
			--renderer:draw_debug_info(visible_area, camera_draw_input.camera_transform, images.blank.tex)
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
				local used_offset = -gravity_angle_offset
				
				if level_world.is_paused then 
					used_offset = 0 
				end
				
				local screen_space_player = ((player_pos - camera_draw_input.camera_transform.pos):rotate(used_offset, vec2(0, 0)) + visible_area/2) / current_zoom_multiplier
				local screen_space_crosshair = ((crosshair_pos - camera_draw_input.camera_transform.pos):rotate(used_offset, vec2(0, 0)) + visible_area/2)  / current_zoom_multiplier
				--:rotate(gravity_angle_offset, vec2(0, 0)) 
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
				film_grain_variation_coroutine(1+ instability)
				--film_grain_program:use()
				GL.glUniform1i(time_uniform, clock_hand_time)
				fullscreen_quad()
				aberration_coroutine(instability)
				
			else
				film_grain_program:use()
				GL.glUniform1f(film_grain_intensity, 0.1)
				GL.glUniform1i(time_uniform, clock_hand_time)
				fullscreen_quad()
				refresh_coroutines()
			end
			
			if is_instability_ray_over_postprocessing then
				instability_ray_fx()
			else
				color_adjustment_program:use()
			end
			
			fullscreen_pass(true)
			
			instability = prev_instability
			
			if level_resources.draw_geometry and not level_world.is_paused and player ~= nil then
				lighting_layer.offset = vec2.random_on_circle(randval(1,59)*instability)
					
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
end

