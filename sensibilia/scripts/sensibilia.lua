dofile "sensibilia\\scripts\\instability_ray.lua"


debug_target_sprite = create_sprite {
	image = images.blank,
	size = vec2(50, 50),
	color = rgba(0, 255, 255, 0)
}

-- 1 - max
instability = 0

base_gravity = vec2(0, 120)
gravity_angle_offset = 0
target_gravity_rotation = 0
changing_gravity = false

current_gravity = vec2(0, 120)

dofile "sensibilia\\scripts\\input.lua"

world_information = tiled_map_loader.load_world_properties (CURRENT_LEVEL)
dofile "sensibilia\\scripts\\camera.lua"

tiled_map_loader.world_camera_entity = world_camera
example_map = tiled_map_loader.load_map(CURRENT_LEVEL)

current_zoom_level = 0
current_zoom_level = 0
set_zoom_level(world_camera)

dofile "sensibilia\\scripts\\character.lua"
dofile "sensibilia\\scripts\\player.lua"

base_crosshair_rotation = 0

main_delta_timer = timer()

loop_only_info = create_scriptable_info {
	scripted_events = {
		[scriptable_component.INTENT_MESSAGE] = main_input_routine,
				
		[scriptable_component.LOOP] = function(subject)
			gravity_angle_offset = player.body:get().physics.body:GetAngle() / 0.01745329251994329576923690768489
			current_gravity = vec2(base_gravity):rotate(gravity_angle_offset, vec2(0, 0))
			
			for k, v in ipairs(global_character_table) do
				v.entity.movement.axis_rotation_degrees = gravity_angle_offset
			end
			
			player.crosshair:get().transform.current.pos:rotate(base_crosshair_rotation - world_camera.camera.last_interpolant.rotation, player.body:get().transform.current.pos)
			base_crosshair_rotation = world_camera.camera.last_interpolant.rotation
			
			player.crosshair:get().crosshair.rotation_offset = -world_camera.camera.last_interpolant.rotation		
			player.crosshair:get().transform.current.rotation = -world_camera.camera.last_interpolant.rotation
			
			physics_system.b2world:SetGravity(b2Vec2(current_gravity.x, current_gravity.y))
			
			local vel = player.body:get().physics.body:GetLinearVelocity()
			
			local f = 1
			
			local sensor = vec2(get_self(player.body:get()).foot_sensor_p1)
			if player.body:get().transform.current.pos.x > 1000/50 then 
				f = -f 
				sensor = get_self(player.body:get()).foot_sensor_p1
			else
				sensor.x = get_self(player.body:get()).foot_sensor_p2.x
			end
			
			--should_debug_draw = get_self(player.body:get()).something_under_foot
			if should_debug_draw then render_system:clear_non_cleared_lines() end
			
			local self = get_self(player.body:get())
			
			--can_point_be_reached_by_jump(base_gravity, self.entity.movement.input_acceleration/50, self.entity.movement.air_resistance, 
			--vec2(1000, 1000)/50, player.body:get().transform.current.pos/50 + sensor/50, vec2(vel.x, vel.y), 
			--self.jump_impulse, self.jetpack_impulse, self.max_jetpack_steps, player.body:get().physics.body:GetMass())	
			
			--render_system:push_line(debug_line(
			--	player.body:get().transform.current.pos + sensor, 
			--	player.body:get().transform.current.pos  + sensor + vec2(0, -self.jump_height) , rgba(255, 0, 0, 255)))
			
			--if not should_debug_draw then 
			--	render_system:push_non_cleared_line(debug_line(player.body:get().transform.current.pos+ sensor , 
			--	player.body:get().transform.current.pos + sensor + vec2(0, 10), rgba(255, 0, 0, 255)))
			--end
			
			if changing_gravity then
				instability = instability + (main_delta_timer:get_seconds()/3)
			end
			
			if is_player_raycasting() then
				instability = instability + main_delta_timer:get_milliseconds()/10000
			end
			
			if not is_player_raycasting() and not changing_gravity then
				local decrease_amount = (main_delta_timer:get_seconds() / 10)
				
				if is_reality_checking then decrease_amount = decrease_amount * 3 end
				
				instability = instability - decrease_amount
			end
			
			if instability < 0 then instability = 0 end
			main_delta_timer:reset()
				
			handle_dying_instability_rays()
		end
	}
}

create_entity {
	input = {
			custom_intents.SPEED_INCREASE,
			custom_intents.SPEED_DECREASE,
			custom_intents.INSTANT_SLOWDOWN,
			custom_intents.QUIT,
			custom_intents.RESTART,
			custom_intents.GRAVITY_CHANGE,
			custom_intents.MY_INTENT,
			intent_message.AIM
	},
		
	scriptable = {
		available_scripts = loop_only_info
	}	
}

player.body:get().name = "player_body"

						--player.body:get().physics.body:SetFixedRotation(false)
						--player.body:get().physics.enable_angle_motor = true
						--player.body:get().physics.target_angle = 90
physics_system.b2world:SetGravity(b2Vec2(base_gravity.x, base_gravity.y))
