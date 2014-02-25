custom_intents = create_inverse_enum {
	"ZOOM_CAMERA",
	"STEERING_REQUEST",
	"RESTART",
	"INSTANT_SLOWDOWN",
	"SPEED_INCREASE",
	"SPEED_DECREASE",
	"QUIT",
	"DROP_WEAPON",
	"JUMP",
	"GRAVITY_CHANGE",
	"MY_INTENT",
	
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
		[keys.E] 				= custom_intents.MY_INTENT,
		
		[mouse.ldoubleclick] 	= custom_intents.INSTABILITY_RAY,
		[mouse.ltripleclick] 	= custom_intents.INSTABILITY_RAY,
		[mouse.ldown] 			= custom_intents.INSTABILITY_RAY,
		
		[keys.LSHIFT] 			= intent_message.SWITCH_LOOK,
		[keys.G] 				= custom_intents.GRAVITY_CHANGE,
		[mouse.wheel]			= custom_intents.ZOOM_CAMERA,
		[keys.ADD] 				= custom_intents.SPEED_INCREASE,
		[keys.SUBTRACT] 		= custom_intents.SPEED_DECREASE
	}
}

input_system:clear_contexts()
input_system:add_context(main_context)

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
		
		for k, v in ipairs(global_character_table) do
			v:set_gravity_shift_state(changing_gravity)
		end
		
	elseif message.intent == custom_intents.RESTART then
			set_world_reloading_script(reloader_script)
			print "setting reloader script"
	elseif message.intent == intent_message.AIM then
		if changing_gravity then
			local added_angle = message.mouse_rel.y * 0.6
		
			target_gravity_rotation = target_gravity_rotation + added_angle
			
			for k, v in ipairs(global_character_table) do
				v.entity.physics.target_angle = target_gravity_rotation
			end
		end
	elseif message.intent == custom_intents.INSTANT_SLOWDOWN then
		physics_system.timestep_multiplier = 0.00001
	elseif message.intent == custom_intents.SPEED_INCREASE then
		physics_system.timestep_multiplier = physics_system.timestep_multiplier + 0.05
	elseif message.intent == custom_intents.SPEED_DECREASE then
		physics_system.timestep_multiplier = physics_system.timestep_multiplier - 0.05
		
		if physics_system.timestep_multiplier < 0.01 then
			physics_system.timestep_multiplier = 0.01
		end
	elseif message.intent == custom_intents.MY_INTENT then
	
	end

	
	return false
end