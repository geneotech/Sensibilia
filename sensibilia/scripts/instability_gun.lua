bullet_sprite = create_sprite {
	image = images.blank,
	size = vec2(60, 65)
}

random_player_bullet_models = {}
random_enemy_bullet_models = {}

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
	
	set_color(new_bullet_poly, color)
	
	return new_bullet_poly
end


for i=1, 1000 do
	table.insert(random_player_bullet_models, random_polygon(rgba(0, 255, 0, 29), 1))
end

for i=1, 1000 do
	table.insert(random_enemy_bullet_models, random_polygon(rgba(255, 0, 0, 29), 1))
end

function loop_instability_gun_bullets(subject_group, shake_radius, init_color)
	local gun_info = subject_group.gun_entity:get().gun
	local self = get_self(subject_group.body:get())
	
	gun_info.spread_degrees = 5 + 30*instability
	gun_info.shake_radius = shake_radius
	--gun_info.bullet_speed = minmax(2000+7000*instability, 5000+7000*instability) 
	
	local i = 1
	while i <= #self.all_player_bullets do
		local v = self.all_player_bullets[i]
		
		if not v:exists() then
			table.remove(self.all_player_bullets, i)
		else
			v = v:get()
			v.damage.max_lifetime_ms = (500+300*instability)/physics_system.timestep_multiplier
			local body = v.physics.body
			local vel = vec2(body:GetLinearVelocity().x, body:GetLinearVelocity().y)
			local dist_from_start = v.damage.lifetime:get_milliseconds()
			local dist_from_starting_point = (v.damage.starting_point - v.transform.current.pos):length()
			vel:set_length(0.005 * dist_from_start) 
			--vel = vel + base_gravity/10*(dist_from_starting_point/700)
			
			--vel = vel
			
			body:ApplyForce(b2Vec2(vel.x, vel.y), body:GetWorldCenter(), true)  
			--body:ApplyAngularImpulse(randval(0, 0.01), true)
			
			local alpha_mult = (1 - (dist_from_start/v.damage.max_lifetime_ms))
			set_color(v.render.model, rgba(init_color.r, init_color.g, init_color.b, alpha_mult * alpha_mult * alpha_mult* 255  + (dist_from_starting_point/5000) * 90 ))
			
			i = i + 1
		end
	end
end

function instability_gun_bullet_callback(subject, new_bullet, bullet_models, wall_passed_filter)
	new_bullet.render.model = bullet_models[randval_i(1,#bullet_models)]
	new_bullet.damage.max_lifetime_ms = 500+300*instability
	new_bullet.damage.destroy_upon_hit = false
	local new_entity_ptr = entity_ptr()
	new_entity_ptr:set(new_bullet)
	
	table.insert(get_self(get_group_by_entity(subject).body:get()).all_player_bullets, new_entity_ptr)
	
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

instability_gun = {
	bullet_callback = function(subject, new_bullet)
		--instability_gun_bullet_callback(subject, new_bullet, your_table)
	end,
	
	bullets_once = 20,
	bullet_distance_offset = vec2(130, 0),
	bullet_damage = minmax(0.1, 1),
	bullet_speed = minmax(100, 6000),
	bullet_render = { model = bullet_sprite, mask = render_masks.EFFECTS },
	is_automatic = true,
	max_rounds = 3000,
	shooting_interval_ms = 50,
	spread_degrees = 5.5,
	shake_radius = 39.5,
	shake_spread_degrees = 45,
	
	bullet_body = {
		filter = filter_bullets,
		shape_type = physics_info.RECT,
		rect_size = bullet_sprite.size,
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