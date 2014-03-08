custom_intents = create_inverse_enum {
	"ZOOM_CAMERA",
	"STEERING_REQUEST",
	"RESTART",
	"INSTANT_SLOWDOWN",
	"ZOOM_IN",
	"ZOOM_OUT",
	"SPEED_CHANGE",
	"QUIT",
	"DROP_WEAPON",
	"JUMP",
	"GRAVITY_CHANGE",
	"MY_INTENT",
	"SHOW_CLOCK",
	
	"INSTABILITY_RAY",
	"REALITY_CHECK"
}

main_context = create_input_context {
	intents = { 
		[mouse.raw_motion] 		= intent_message.AIM,
		[keys.ESC] 				= custom_intents.QUIT,
		[keys.W] 				= custom_intents.JUMP,
		[keys.S] 				= intent_message.MOVE_BACKWARD,
		[keys.A] 				= intent_message.MOVE_LEFT,
		[keys.D] 				= intent_message.MOVE_RIGHT,
		[keys.R] 				= custom_intents.RESTART,
		[mouse.rdown] 			= custom_intents.REALITY_CHECK,
		[mouse.rdoubleclick] 	= custom_intents.REALITY_CHECK,
		[keys.V] 				= custom_intents.INSTANT_SLOWDOWN,
		[keys.E] 				= custom_intents.SHOW_CLOCK,
		--[keys.C] 				= custom_intents.SHOW_CLOCK,
		
		[mouse.ldoubleclick] 	= intent_message.SHOOT,
		[mouse.ltripleclick] 	= intent_message.SHOOT,
		[mouse.ldown] 			= intent_message.SHOOT,
		
		[keys.LSHIFT] 			= intent_message.SWITCH_LOOK,
		[keys.G] 				= custom_intents.GRAVITY_CHANGE,
		[mouse.wheel]			= custom_intents.SPEED_CHANGE,
		[keys.ADD] 				= custom_intents.ZOOM_IN,
		[keys.SUBTRACT] 		= custom_intents.ZOOM_OUT
	}
}

main_input_component = {
	custom_intents.INSTANT_SLOWDOWN,
	custom_intents.QUIT,
	custom_intents.RESTART,
	custom_intents.GRAVITY_CHANGE,
	custom_intents.MY_INTENT,
	intent_message.AIM,
	custom_intents.ZOOM_OUT,
	custom_intents.SHOW_CLOCK
}

input_system:clear_contexts()
input_system:add_context(main_context)

bounce_number = 2

showing_clock = false
clock_alpha_multiplier = 1
clock_alpha_animator = value_animator(0, 0, 1)

function main_input_routine(message)
	if message.intent == custom_intents.QUIT then
		input_system.quit_flag = 1
	elseif message.intent == custom_intents.GRAVITY_CHANGE then
		changing_gravity = message.state_flag
		
		if message.state_flag then
			player.crosshair:get().crosshair.sensitivity.y = 0
			base_crosshair_rotation = world_camera.camera.last_interpolant.rotation
			target_gravity_rotation = player.body:get().physics.body:GetAngle() / 0.01745329251994329576923690768489
		else
			player.crosshair:get().crosshair.sensitivity = config_table.sensitivity
			world_camera.camera.crosshair_follows_interpolant = false
		end
		
		for i=1, #global_entity_table do
			if global_entity_table[i].character ~= nil then global_entity_table[i].character:set_gravity_shift_state(changing_gravity) end
		end
		
	elseif message.intent == custom_intents.RESTART then
			set_world_reloading_script(reloader_script)
			print "setting reloader script"
	elseif message.intent == intent_message.AIM then
		if changing_gravity then
			local added_angle = message.mouse_rel.y * 0.6
		
			target_gravity_rotation = target_gravity_rotation + added_angle
			
			for i=1, #global_entity_table do
				if global_entity_table[i].character ~= nil then global_entity_table[i].parent_group.body:get().physics.target_angle = target_gravity_rotation end
			end
		end
	elseif message.intent == custom_intents.INSTANT_SLOWDOWN then
		physics_system.timestep_multiplier = 0.00001
	elseif message.intent == custom_intents.SHOW_CLOCK then
		showing_clock = message.state_flag
		
		if not showing_clock then
			clock_alpha_animator = value_animator(1, 0, 1500)
			clock_alpha_animator:set_logarithmic()
		end
		
	elseif message.intent == custom_intents.MY_INTENT then
		if not message.state_flag then 
			bounce_number = bounce_number + 1 
			bounce_number = bounce_number - math.floor(bounce_number/3)*3
			print(bounce_number)
		end 
	end
end