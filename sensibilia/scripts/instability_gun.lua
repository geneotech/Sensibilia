function random_polygon(color, scalar)
	local current_angle = 0
	local vertices = {}
	
	local vertex_amnt = randval_i(5, 13)
	local scale = randval(0.01, 1) * scalar
	
	for i = 1, vertex_amnt do
		current_angle = current_angle + randval(10, 40)
		if current_angle >= 350 then break end
		
		table.insert(vertices, vec2(2, 1) * vec2.from_degrees(current_angle):set_length(randval(10, 130)) * scale)
	end
	
	local new_bullet_poly = simple_create_polygon(vertices)
	map_uv_square(new_bullet_poly, images.bullet_map)
	
	set_polygon_color(new_bullet_poly, color)
	
	return new_bullet_poly
end

function initialize_random_bullet_models()
	local random_player_bullet_models = {}
	local random_enemy_bullet_models = {}
	
	for i=1, 1000 do
		table.insert(random_player_bullet_models, random_polygon(rgba(0, 255, 0, 29), 1))
	end
	
	for i=1, 1000 do
		table.insert(random_enemy_bullet_models, random_polygon(rgba(255, 0, 0, 29), 1))
	end
	
	return random_player_bullet_models, random_enemy_bullet_models
end

function instability_gun_bullet_callback(subject, new_bullet, bullet_models, wall_passed_filter)
	new_bullet.render.model = bullet_models[randval_i(1,#bullet_models)]
	new_bullet.damage.max_lifetime_ms = 500+300*instability
	new_bullet.damage.destroy_upon_hit = false
	local new_entity_ptr = entity_ptr()
	new_entity_ptr:set(new_bullet)
	
	get_self(get_group_by_entity(subject).body:get()).all_player_bullets:add(new_entity_ptr)
	
	--SetDensity(new_bullet.physics.body, 0.01)
	if randval(0, 1) > 0.5 then
		SetFilter(new_bullet.physics.body, create(b2Filter, wall_passed_filter))
	end
	
	new_bullet.physics.body:SetBullet(false)
	
	if randval(0, 1) > 0.95 then
		local body = new_bullet.physics.body
		local rand_vec = (vec2.from_degrees(new_bullet.transform.current.rotation + randval(-15, 15)) * randval(50, 10000))*2/50
		
		body:ApplyLinearImpulse(b2Vec2(rand_vec.x, rand_vec.y), body:GetWorldCenter(), true)
	end
end

function get_instability_gun()
	return {
		bullet_callback = function(subject, new_bullet)
			--instability_gun_bullet_callback(subject, new_bullet, your_table)
		end,
		
		bullets_once = 20,
		bullet_distance_offset = vec2(130, 0),
		bullet_damage = minmax(0.1, 1),
		bullet_speed = minmax(100, 6000),
		bullet_render = { model = nil, mask = render_masks.EFFECTS },
		is_automatic = true,
		max_rounds = 3000,
		shooting_interval_ms = 50,
		spread_degrees = 5.5,
		shake_radius = 39.5,
		shake_spread_degrees = 45,
		
		bullet_body = {
			filter = filter_bullets,
			shape_type = physics_info.RECT,
			rect_size = vec2(60, 60),
			fixed_rotation = false,
			density = 0.1,
			air_resistance = 0,
			gravity_scale = 0,
			linear_damping = 0,
			angular_damping = 160,
			restitution = 0,
			friction = 100
		},
		
		max_bullet_distance = 4000,
		current_rounds = 3000,
		
		target_camera_to_shake = world_camera 
	}
end