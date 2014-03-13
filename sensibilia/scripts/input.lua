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
	"REALITY_CHECK",
	
	"GUI_MOUSECLICK"
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
		--[keys.C] 				= custom_intents.MY_INTENT,
		
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

gui_context = create_input_context {
	intents = { 
		[mouse.raw_motion] 		= intent_message.AIM,
		
		[mouse.ldoubleclick] 	= custom_intents.GUI_MOUSECLICK,
		[mouse.ltripleclick] 	= custom_intents.GUI_MOUSECLICK,
		[mouse.ldown] 			= custom_intents.GUI_MOUSECLICK,
		
		[keys.ESC] 				= custom_intents.QUIT
	}
}

main_input_component = {
	custom_intents.INSTANT_SLOWDOWN,
	custom_intents.QUIT,
	custom_intents.RESTART,
	custom_intents.MY_INTENT,

	intent_message.AIM,
	custom_intents.GUI_MOUSECLICK
}

input_system:clear_contexts()
input_system:add_context(main_context)

bounce_number = 2

function unpause_world()
	local menu = level_resources
	
	menu.pause_screen = nil
	menu.current_screen = nil
	menu.main_input_callback = nil
	menu.basic_geometry_callback = nil
	menu.rendered_crosshair_entity = nil
	
	setup_camera(player)
	set_zoom_level(world_camera)
	
	
	input_system:clear_contexts()
	input_system:add_context(main_context)
	
	level_world.is_paused = false
	current_zoom_level = 1000
	set_zoom_level(world_camera)
end

function main_input_routine(message)
	local continue_input = true

	if level_resources.main_input_callback ~= nil then
		continue_input = level_resources.main_input_callback(message)
	end
	
	if continue_input then
		if message.intent == custom_intents.QUIT and message.state_flag then
			level_world.is_paused = not level_world.is_paused
			get_self(player.body:get()).delta_timer:pause(level_world.is_paused)
			
			if level_world.is_paused then
				local menu = level_resources
				
				dofile "sensibilia\\scripts\\menu_screens\\screen_class.lua"
				dofile "sensibilia\\scripts\\menu_screens\\pause_screen.lua"
				dofile "sensibilia\\scripts\\menu_screens\\help.lua"
				create_help_screen(menu.pause_screen)
				
				menu.current_screen = menu.pause_screen
				
				menu.main_input_callback = function(message)
					menu.current_screen:handle_events(message)
					return true
				end
				
				menu.basic_geometry_callback = function(camera_draw_input)
					--camera_draw_input.camera_transform.rotation = player.body:get().transform.current.pos
					menu.current_screen.translation = player.body:get().transform.current.pos
					menu.current_screen:draw(camera_draw_input)
				end
				
				switch_to_gui(player.body:get().transform.current.pos)
	current_zoom_level = 0
	set_zoom_level(world_camera)
			else
				unpause_world()
			end

		elseif message.intent == custom_intents.RESTART then
				should_world_be_reloaded = true
				print "reloading world"
	
		elseif message.intent == custom_intents.INSTANT_SLOWDOWN then
			physics_system.timestep_multiplier = 0.00001
	
		--elseif message.intent == custom_intents.MY_INTENT then
		--	if not message.state_flag then 
		--		bounce_number = bounce_number + 1 
		--		bounce_number = bounce_number - math.floor(bounce_number/3)*3
		--		print(bounce_number)
		--	end 
		end
	end
end