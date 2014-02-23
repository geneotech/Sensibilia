dofile "sensibilia\\scripts\\instability_ray.lua"

print (table.inspect(tiled_map_loader.get_all_textures("sensibilia/maps/example_map")))

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
dofile "sensibilia\\scripts\\camera.lua"

current_zoom_level = 0
current_zoom_level = 5000
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
)


ground_poly2 = simple_create_polygon ( (
	to_vec2_table(poly2)
))

map_uv_square(ground_poly, images.metal)
map_uv_square(ground_poly2, images.metal)
set_color(ground_poly, rgba(255, 255, 225, 255))
set_color(ground_poly2, rgba(255, 255, 225, 255))

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

dofile "sensibilia\\scripts\\character.lua"
dofile "sensibilia\\scripts\\player.lua"

base_crosshair_rotation = 0

instability_decreaser = timer()


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
				instability = instability + (instability_decreaser:get_seconds()/3)
			end
			
			
			if not get_self(player.body:get()).ray_caster.currently_casting and not changing_gravity then
				--print(instability_decreaser:extract_milliseconds() / 1000 / 10)
				local decrease_amount = (instability_decreaser:get_seconds() / 10)
				
				if is_reality_checking then decrease_amount = decrease_amount * 3 end
				
				instability = instability - decrease_amount
			end
			
			if instability < 0 then instability = 0 end
			instability_decreaser:reset()
				
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



player.body:get().name = "player_body"
environment_entity.name = "environment_entity"

						--player.body:get().physics.body:SetFixedRotation(false)
						--player.body:get().physics.enable_angle_motor = true
						--player.body:get().physics.target_angle = 90
physics_system.b2world:SetGravity(b2Vec2(base_gravity.x, base_gravity.y))
