debug_target_sprite = create_sprite {
	image = images.blank,
	size = vec2(50, 50),
	color = rgba(0, 255, 255, 0)
}

stability = 1
base_gravity = vec2(0, 120)
gravity_angle_offset = 0
target_gravity_rotation = 0
changing_gravity = false

current_gravity = vec2(0, 120)

dofile "sensibilia\\scripts\\input.lua"
dofile "sensibilia\\scripts\\camera.lua"

current_zoom_level = 2000
current_zoom_level = 10000
set_zoom_level(world_camera)

function set_color(poly, col)
	for i = 0, poly:get_vertex_count()-1 do
		poly:get_vertex(i).color = col
	end
end

environment_archetype = {
	physics = {
		body_type = Box2D.b2_staticBody,
		
		body_info = {
			shape_type = physics_info.POLYGON,
			filter = filter_static_objects,
			density = 1000,
			friction = 0.1,
			
			linear_damping = 10,
			angular_damping = 10
		}
	},
	
	render = {
		layer = render_layers.BACKGROUND
	},
	
	transform = {
	
	}
}

poly1 = {
    { x = 0, y = 0 },
    { x = 0, y = 340 },
    { x = 640, y = 340 },
    { x = 640, y = 280 },
    { x = 60, y = 280 },
    { x = 60, y = 180 },
    { x = 240, y = 180 },
    { x = 240, y = 120 },
    { x = 60, y = 120 },
    { x = 60, y = 0 }
}

poly2 = {
	{ x = 0, y = 0 },
	{ x = -80, y = 80 },
	{ x = -80, y = 740 },
	{ x = 720, y = 820 },
	{ x = 1160, y = 760 },
	{ x = 1180, y = 40 },
	{ x = 960, y = -20 },
	{ x = 1060, y = 120 },
	{ x = 1040, y = 700 },
	{ x = 720, y = 720 },
	{ x = 0, y = 660 }
}


function to_vec2_table(xytable)
	local newtable = {}
	
	for k, v in pairs(xytable) do
		newtable[k] = vec2(v.x, v.y)*5
	end
	
	return newtable
end

ground_poly = simple_create_polygon (

	(to_vec2_table(poly1))

	--(vec2(0, 10) + vec2(-800, 0)) 		* vec2(10, 25) ,
	--(vec2(0, 10) + vec2(500, 0))		* vec2(10, 25) ,
	--(vec2(0, 10) + vec2(900, -200))	* vec2(10, 25) ,
	--(vec2(0, 10) + vec2(1400, -300))	* vec2(10, 25) ,
	--(vec2(0, 10) + vec2(3000, -300))	* vec2(10, 25) ,
	--(vec2(0, 10) + vec2(3000, 200))	* vec2(10, 25) ,
	--(vec2(0, 10) + vec2(-800, 200))   *  vec2(10, 25) 
)


ground_poly2 = simple_create_polygon ( (
	to_vec2_table(poly2)
))

map_uv_square(ground_poly, images.blank)
map_uv_square(ground_poly2, images.blank)
set_color(ground_poly, rgba(0, 255, 0, 255))
set_color(ground_poly2, rgba(0, 255, 0, 255))

environment_entity = create_entity (archetyped(environment_archetype, {
	transform = {
		pos = vec2(220, 140)*5
	},
	
	render = {
		model = ground_poly
	}
}))

environment_entity2 = create_entity (archetyped(environment_archetype, {
	transform = {
		pos = vec2(140, 60)*5
	},
	render = {
		model = ground_poly2
	}
}))

dofile "sensibilia\\scripts\\npc.lua"
dofile "sensibilia\\scripts\\player.lua"

base_crosshair_rotation = 0

my_sequence = timed_sequence:create()

my_sequence:add_action {
	on_enter = function() 
		print "Action 1."
	end,
	
	duration_ms = 1000
}

my_sequence:add_action {
	on_enter = function() 
		print "Action 2."
	end,
	
	min_duration_ms = 1000,
	max_duration_ms = 2000
}

loop_only_info = create_scriptable_info {
	scripted_events = {
		[scriptable_component.INTENT_MESSAGE] = 
			function(message)
				if message.intent == custom_intents.QUIT then
					input_system.quit_flag = 1
				elseif message.intent == custom_intents.GRAVITY_CHANGE then
					changing_gravity = message.state_flag
					
					if message.state_flag then
						player.crosshair.crosshair.sensitivity.y = 0
						base_crosshair_rotation = world_camera.camera.last_interpolant.rotation
						target_gravity_rotation = player.body.physics.body:GetAngle() / 0.01745329251994329576923690768489
					else
						player.crosshair.crosshair.sensitivity = config_table.sensitivity
						world_camera.camera.crosshair_follows_interpolant = false
					end
					
					get_self(player.body):set_gravity_shift_state(changing_gravity)
					get_self(my_basic_npc.body):set_gravity_shift_state(changing_gravity)
					
				elseif message.intent == custom_intents.RESTART then
						set_world_reloading_script(reloader_script)
				elseif message.intent == intent_message.AIM then
					if changing_gravity then
						local added_angle = message.mouse_rel.y * 0.6
					
						target_gravity_rotation = target_gravity_rotation + added_angle
						
						player.body.physics.target_angle = target_gravity_rotation
						my_basic_npc.body.physics.target_angle = target_gravity_rotation
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
					my_basic_npc.body.pathfinding:start_exploring()
				end

				
				return false
			end,
				
		[scriptable_component.LOOP] = function(subject)
			gravity_angle_offset = player.body.physics.body:GetAngle() / 0.01745329251994329576923690768489
			current_gravity = vec2(base_gravity):rotate(gravity_angle_offset, vec2(0, 0))
			
			player.body.movement.axis_rotation_degrees = gravity_angle_offset
			my_basic_npc.body.movement.axis_rotation_degrees = gravity_angle_offset
			
			player.crosshair.transform.current.pos:rotate(base_crosshair_rotation - world_camera.camera.last_interpolant.rotation, player.body.transform.current.pos)
			base_crosshair_rotation = world_camera.camera.last_interpolant.rotation
			
			player.crosshair.crosshair.rotation_offset = -world_camera.camera.last_interpolant.rotation		
			player.crosshair.transform.current.rotation = -world_camera.camera.last_interpolant.rotation
			
			physics_system.b2world:SetGravity(b2Vec2(current_gravity.x, current_gravity.y))
			
			local vel = player.body.physics.body:GetLinearVelocity()
			
			local f = 1
			
			local sensor = vec2(get_self(player.body).foot_sensor_p1)
			if player.body.transform.current.pos.x > 1000/50 then 
				f = -f 
				sensor = get_self(player.body).foot_sensor_p1
			else
				sensor.x = get_self(player.body).foot_sensor_p2.x
			end
			
			--should_debug_draw = get_self(player.body).something_under_foot
			if should_debug_draw then render_system:clear_non_cleared_lines() end
			
			local self = get_self(player.body)
			
			--can_point_be_reached_by_jump(base_gravity, self.entity.movement.input_acceleration/50, self.entity.movement.air_resistance, 
			--vec2(1000, 1000)/50, player.body.transform.current.pos/50 + sensor/50, vec2(vel.x, vel.y), 
			--self.jump_impulse, self.jetpack_impulse, self.max_jetpack_steps, player.body.physics.body:GetMass())	
			
			render_system:push_line(debug_line(
				player.body.transform.current.pos + sensor, 
				player.body.transform.current.pos  + sensor + vec2(0, -self.jump_height) , rgba(255, 0, 0, 255)))
			
			if not should_debug_draw then 
				render_system:push_non_cleared_line(debug_line(player.body.transform.current.pos+ sensor , 
				player.body.transform.current.pos + sensor + vec2(0, 10), rgba(255, 0, 0, 255)))
			end
			
			my_sequence:play()
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

global_sprites = {}

swing_script = create_scriptable_info {
	scripted_events = {
		[scriptable_component.LOOP] = function(subject)
			subject.physics.body:SetGravityScale(randval(-0.01, 0.01))
			subject.physics.body:ApplyTorque(randval(-0.1, 0.1), true)
		end
	}
}



rects = {
	{
       x = 840,
       y = 660,
       width = 100,
       height = 20
	},
    
	{
      x = 980,
      y = 540,
      width = 100,
      height = 40
    },
    
	{
      x = 1040,
      y = 220,
      width = 100,
      height = 40
    },
	
    {
      x = 680,
      y = 280,
      width = 100,
      height = 60
    }
}

for k, v in pairs(rects) do
	local my_sprite = create_sprite {
		image = images.blank,
		color = rgba(0, 255, 0, 125),
		size = vec2(v.width, v.height)*5
	}
	
	table.insert(global_sprites, my_sprite)

	local new_entity = create_entity(archetyped(environment_archetype, {
		transform = {
			pos = vec2(v.x, v.y)*5,
			--pos = vec2(300, -200),
			rotation = 0
			--rotation = 0
		},
		
		physics = {
			body_type = Box2D.b2_staticBody,
			
			body_info = {
				shape_type = physics_info.RECT,
				density = 1000,
				restitution = randval(0.00, 0.01)
			}
		},
		
		render = {
			model = my_sprite
		}
		
		--scriptable = {
		--	available_scripts = swing_script
		--}
	}))
	
	new_entity.physics.body:SetGravityScale(0)
end



--for i = 1, 50 do
--	local my_sprite = create_sprite {
--		image = images.blank,
--		color = rgba(0, 255, 0, 125),
--		size = vec2(randval(100, 3000), randval(100, 400))
--	}
--	
--	table.insert(global_sprites, my_sprite)
--
--	local new_entity = create_entity(archetyped(environment_archetype, {
--		transform = {
--			pos = vec2(randval(-8000, 16000), randval(-6000, -1000)),
--			--pos = vec2(300, -200),
--			rotation = randval(0, 360)
--			--rotation = 0
--		},
--		
--		physics = {
--			body_type = Box2D.b2_dynamicBody,
--			
--			body_info = {
--				shape_type = physics_info.RECT,
--				density = 1000,
--				restitution = randval(0.00, 0.01)
--			}
--		},
--		
--		render = {
--			model = my_sprite
--		}
--		
--		--scriptable = {
--		--	available_scripts = swing_script
--		--}
--	}))
--	
--	new_entity.physics.body:SetGravityScale(0)
--	
--
--end



player.body.name = "player_body"
environment_entity.name = "environment_entity"

						--player.body.physics.body:SetFixedRotation(false)
						--player.body.physics.enable_angle_motor = true
						--player.body.physics.target_angle = 90
physics_system.b2world:SetGravity(b2Vec2(base_gravity.x, base_gravity.y))

	--get_self(my_basic_npc.body).steering_behaviours.target_seeking.target_from:set(player.crosshair)
