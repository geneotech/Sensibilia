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

function randomize_properties_vector(min_radius, max_radius, prop_name, target_table)
	for k, v in ipairs(target_table) do
		target_table[k][prop_name] = vec2.random_on_circle(randval(min_duration, max_duration))
	end
end