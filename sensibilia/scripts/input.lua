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
	
	"INSTABILITY_RAY"
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
		[keys.V] 				= custom_intents.INSTANT_SLOWDOWN,
		[keys.E] 				= custom_intents.MY_INTENT,
		
		[mouse.ldoubleclick] 	= custom_intents.INSTABILITY_RAY,
		[mouse.ltripleclick] 	= custom_intents.INSTABILITY_RAY,
		[mouse.ldown] 			= custom_intents.INSTABILITY_RAY,
		
		[keys.LSHIFT] 			= intent_message.SWITCH_LOOK,
		[mouse.rdown] 			= custom_intents.GRAVITY_CHANGE,
		[mouse.rdoubleclick] 	= custom_intents.GRAVITY_CHANGE,
		[mouse.wheel]			= custom_intents.ZOOM_CAMERA,
		[keys.ADD] 				= custom_intents.SPEED_INCREASE,
		[keys.SUBTRACT] 		= custom_intents.SPEED_DECREASE
	}
}

input_system:clear_contexts()
input_system:add_context(main_context)