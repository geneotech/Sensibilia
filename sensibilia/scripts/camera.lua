current_zoom_level = 0

function set_zoom_level(camera)
	local mult = 1 + (current_zoom_level / 1000)
	local new_w = config_table.resolution_w*mult
	local new_h = config_table.resolution_h*mult
	camera.camera.ortho = rect_ltrb(rect_xywh(0, 0, new_w, new_h))
	camera.camera.max_look_expand = vec2(new_w, new_h)/2
	
	--player.crosshair:get().crosshair.size_multiplier = vec2(mult, mult)
	--target_entity.crosshair.size_multiplier = vec2(mult, mult)
end

scriptable_zoom = create_scriptable_info {
	scripted_events = {
		[scriptable_component.INTENT_MESSAGE] = function(message)
				if message.intent == custom_intents.ZOOM_CAMERA then
					current_zoom_level = current_zoom_level-message.wheel_amount
					set_zoom_level(message.subject)
				end
			return false
		end
	}
}

camera_archetype = {
	transform = {
		pos = vec2(),
		rotation = 0
	},

	camera = {
		enabled = true,
		
		layer = 0, -- 0 = topmost
		mask = render_component.WORLD,
		
		enable_smoothing = true,
		smoothing_average_factor = 0.5,
		averages_per_sec = 15,
		
		crosshair = nil, 
		player = nil,
	
		orbit_mode = camera_component.LOOK,
		max_look_expand = vec2(config_table.resolution_w/2, config_table.resolution_h/2),
		angled_look_length = 100
	},
	
	chase = {
		relative = false
		--offset = vec2(config_table.resolution_w/(-2), config_table.resolution_h/(-2))
	}
}



SHADERS_DIRECTORY = "sensibilia\\scripts\\resources\\shaders\\"

dofile (SHADERS_DIRECTORY .. "fullscreen_vertex_shader.lua")

dofile (SHADERS_DIRECTORY .. "scene_shader.lua")
dofile (SHADERS_DIRECTORY .. "film_grain.lua")
dofile (SHADERS_DIRECTORY .. "chromatic_aberration.lua")
dofile (SHADERS_DIRECTORY .. "blur.lua")
dofile (SHADERS_DIRECTORY .. "color_adjustment.lua")

local my_timer = timer()

function fullscreen_quad()
	GL.glBegin(GL.GL_QUADS)	
		GL.glVertexAttrib2f(0,1,1)
		GL.glVertexAttrib2f(0,1,0)
		GL.glVertexAttrib2f(0,0,0)
		GL.glVertexAttrib2f(0,0,1)
	GL.glEnd()
end


--scene_fbo = framebuffer_object(config_table.resolution_w, config_table.resolution_h)

postprocessing_fbos = {
	[0] = framebuffer_object(config_table.resolution_w, config_table.resolution_h),
	[1] = framebuffer_object(config_table.resolution_w, config_table.resolution_h)
}

current_postprocessing_fbo = 0

function fullscreen_pass(is_finalizing)
	if is_finalizing == nil then
		is_finalizing = false
	end
	
	local tex_id = postprocessing_fbos[current_postprocessing_fbo]:get_texture_id()
	
	-- switch fbos
	current_postprocessing_fbo = 1 - current_postprocessing_fbo
	
	if is_finalizing then
		framebuffer_object.use_default()
	else
		postprocessing_fbos[current_postprocessing_fbo]:use()
	end
	
	GL.glBindTexture(GL.GL_TEXTURE_2D, tex_id)
	
	fullscreen_quad()
end



INSTABILITY_PASSES = 3

instability_passes = {
	
}

function table_of_tables(num)
	local out = {}
	
	for i = 1, num do
		out[i] = {}
	end
	
	return out
end


function randomize_properties(min_val, max_val, prop_name, target_table)
	for k, v in ipairs(target_table) do
		target_table[k][prop_name] = randval(min_val, max_val)
	end
end


function randomize_transitions(min_duration, max_duration, target_table)
	for k, v in ipairs(target_table) do
		target_table[k].transition_duration = randval(min_duration, max_duration)
	end
end

function randomize_translations(min_radius, max_radius, target_table)
	for k, v in ipairs(target_table) do
		target_table[k].translation = vec2.random_on_circle(randval(min_duration, max_duration))
	end
end
	

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


function refresh_coroutines()
	hblur_coroutine = coroutine.wrap(hblur_instability_effect)
end

instability_effects = {

}

function instability_pass_function(is_last)
	

	
end


--for i, INSTABILITY_PASSES do
--	instability_passes[i] = coroutine.wrap(
--		function(
--	
--	)
--end



--instability_pass_randomizer = coroutine.create(
--
--)

world_camera = create_entity (archetyped(camera_archetype, {
	transform = {
		pos = vec2(),
		rotation = 0
	},

	camera = {
		screen_rect = rect_xywh(0, 0, config_table.resolution_w, config_table.resolution_h),
		ortho = rect_ltrb(0, 0, config_table.resolution_w, config_table.resolution_h),
		
		drawing_callback = function (subject, renderer, visible_area, drawn_transform, target_transform, mask)
			scene_program:use()
			my_atlas:bind()
			
			renderer:generate_triangles(visible_area, drawn_transform, mask)
			
			GL.glUniformMatrix4fv(
			projection_matrix_uniform, 
			1, 
			GL.GL_FALSE, 
			orthographic_projection(visible_area.x, visible_area.r, visible_area.b, visible_area.y, 0, 1):data()
			)
			
			postprocessing_fbos[0]:use()
			GL.glClear(GL.GL_COLOR_BUFFER_BIT)
		
			renderer:call_triangles()
		
			renderer:clear_triangles()
			
			GL.glDisable(GL.GL_TEXTURE_2D)
			renderer:draw_debug_info(visible_area, drawn_transform)
			GL.glEnable(GL.GL_TEXTURE_2D)
			
			current_postprocessing_fbo = 0
			
			
			print(instability)
			
			
			-- postprocessing
			
			if instability > 0 then
			
			local new_multiplier = instability*300
			if new_multiplier < 1 then new_multiplier = 1 end
			
			--print (new_multiplier)
			hblur_coroutine()
			else
				refresh_coroutines()
			end
			
			--hblur_program:use()
			--fullscreen_pass()
			--
			--vblur_program:use()
			--fullscreen_pass()
			
			--chromatic_aberration_program:use()
			--fullscreen_pass()
			--
			color_adjustment_program:use()
			fullscreen_pass(true)
			
			film_grain_program:use()
			GL.glUniform1i(time_uniform, my_timer:get_milliseconds())
			
			fullscreen_quad()
			--framebuffer_object.use_default()
			--GL.glBindTexture(GL.GL_TEXTURE_2D, postprocessing_fbos[0]:get_texture_id())
			--fullscreen_quad()
		end
	},
	
	input = {
		intent_message.SWITCH_LOOK,
		custom_intents.ZOOM_CAMERA
	},
	
	chase = {
		chase_rotation = true,
		rotation_multiplier = -1
	},
	
	scriptable = {
		available_scripts = scriptable_zoom
	}
}))
