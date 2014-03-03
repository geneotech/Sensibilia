current_zoom_level = 0
current_zoom_multiplier = 1

function set_zoom_level(camera)
	local mult = 1 + (current_zoom_level / 1000)
	local new_w = config_table.resolution_w*mult
	local new_h = config_table.resolution_h*mult
	current_zoom_multiplier = mult
	camera.camera.ortho = rect_ltrb(rect_xywh(0, 0, new_w, new_h))
	camera.camera.max_look_expand = vec2(new_w, new_h)/2
	
	--player.crosshair:get().crosshair.size_multiplier = vec2(mult, mult)
	--target_entity.crosshair.size_multiplier = vec2(mult, mult)
end

scriptable_zoom = create_scriptable_info {
	scripted_events = {
		[scriptable_component.INTENT_MESSAGE] = function(message)
				if message.intent == custom_intents.ZOOM_IN then
					current_zoom_level = current_zoom_level-120
					set_zoom_level(message.subject)
				elseif message.intent == custom_intents.ZOOM_OUT then
					current_zoom_level = current_zoom_level+120
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
		mask = render_masks.WORLD,
		
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

dofile "sensibilia\\scripts\\rendering_routine.lua"

world_camera = create_entity (archetyped(camera_archetype, {
	transform = {
		pos = world_information["PLAYER_START"][1].pos,
		rotation = 0
	},

	camera = {
		screen_rect = rect_xywh(0, 0, config_table.resolution_w, config_table.resolution_h),
		ortho = rect_ltrb(0, 0, config_table.resolution_w, config_table.resolution_h),
		drawing_callback = rendering_routine
	},
	
	input = {
		intent_message.SWITCH_LOOK,
		custom_intents.ZOOM_IN,
		custom_intents.ZOOM_OUT
	},
	
	chase = {
		chase_rotation = true,
		rotation_multiplier = -1
	},
	
	scriptable = {
		available_scripts = scriptable_zoom
	}
}))
