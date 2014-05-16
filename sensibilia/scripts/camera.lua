dofile "sensibilia\\scripts\\rendering_routine.lua"

world_camera_ptr = ptr_create_entity ({
	transform = {
		pos = vec2(),
		rotation = 0
	},

	camera = {
		enabled = true,
		
		layer = 0, -- 0 = topmost
		mask = render_masks.WORLD,
		
		enable_smoothing = true,
		smoothing_average_factor = 0.5,
		averages_per_sec = 15,
		
		crosshair = nil, 
		player = nil,
	
		orbit_mode = camera_component.LOOK,
		max_look_expand = vec2(config_table.resolution_w/2, config_table.resolution_h/2),
		angled_look_length = 100,
		
		screen_rect = rect_xywh(0, 0, config_table.resolution_w, config_table.resolution_h),
		size = vec2(config_table.resolution_w, config_table.resolution_h),
		drawing_callback = rendering_routine
		
		--function (subject, renderer, visible_area, drawn_transform, target_transform, mask)
		--	scene_program:use()
		--	framebuffer_object.use_default()
		--	
		--	--GL.glUniform1i(scene_shader_time_uniform, sent_time)
		--		
		--	my_atlas:bind()
		--	
		--	GL.glUniformMatrix4fv(
		--	projection_matrix_uniform, 
		--	1, 
		--	GL.GL_FALSE, 
		--	orthographic_projection(visible_area.x, visible_area.r, visible_area.b, visible_area.y, 0, 1):data()
		--	)
		--
		--	GL.glColorMask(GL.GL_TRUE, GL.GL_TRUE, GL.GL_TRUE, GL.GL_TRUE)
		--	GL.glClear(GL.GL_COLOR_BUFFER_BIT)
		--	--renderer:generate_triangles(visible_area, drawn_transform, render_masks.EFFECTS)
		--	--renderer:call_triangles()
		--	--renderer:clear_triangles()
		--end
	},
	
	input = {
		intent_message.SWITCH_LOOK,
		custom_intents.SPEED_CHANGE
		--custom_intents.ZOOM_IN,
		--custom_intents.ZOOM_OUT
	},
	
	chase = {
		relative = false,
		chase_rotation = true,
		rotation_multiplier = -1
	},
	
	scriptable = {
		available_scripts = scriptable_zoom,
		script_data = {}
	}
})

-- convenience, will always exist
world_camera = world_camera_ptr:get()

world_camera_self = generate_entity_object(world_camera_ptr, camera_class)
world_camera_self.intent_message = function(self, message)
	if message.intent == custom_intents.SPEED_CHANGE and input_system:is_down(keys.LCTRL) then
		local zoom_level = self:get_zoom_level()
		
		zoom_level = zoom_level-message.wheel_amount
		if zoom_level < 0 then zoom_level = 0 end
		if zoom_level > 1000 then zoom_level = 1000 end
		self:set_zoom_level(zoom_level)
	end
	--elseif message.intent == custom_intents.ZOOM_OUT then
	--	current_zoom_level = current_zoom_level+120
	--	set_zoom_level(message.subject)
	--end
end