global_instability_rays = {}

function handle_dying_instability_rays()
	local i = 1
	
	while i <= #global_instability_rays do
		local self = global_instability_rays[i]
		local was_removed = false
		
		if not self.owner_entity:exists() then
			self:cast(false)
			
			if self.polygon_fader:get_num_traces() < 1 then
				table.remove(global_instability_rays, i)
				was_removed = true
			else
				
				-- this instability ray is slowly dying because no entity can call its loop routine
				global_instability_rays[i]:loop()
			end
		end
		
		if not was_removed then
			i = i + 1
		end
	end
end

instability_ray_module = inherits_from {}

function instability_ray_module:constructor(entity, ray_filter)
	self.position = vec2(0, 0)
	self.direction = vec2(0, 0)
	
	self.current_endpoint = vec2(0, 0)
	
	self.ray_length = 0
	self.currently_casting = false
	
	self.delta_timer = timer()
	
	self.ray_quad_width = 20
	self.ray_quad_end_width = 50
	
	self.owner_entity = entity
	self.current_ortho = vec2(0, 0)
	self.radius_of_effect = 8000
	
	self.trapezoid_height = 200

	self.trace_timer = timer()
	
	self.polygon_fader = polygon_fader()
	
	self.instability_ray_filter = ray_filter
	-- for rendering
	table.insert(global_instability_rays, self)
	
	self.polygon_color = rgba(255, 255, 255, 255)
end

function instability_ray_module:generate_triangles(camera_transform, output_buffer, visible_area)
	self.polygon_fader:generate_triangles(camera_transform, output_buffer, visible_area)
end

function instability_ray_module:cast(flag)
	self.currently_casting = flag
end

function instability_ray_module:construct_world_polygon()
	-- bind draw input
	local perpendicular = self.direction:perpendicular_cw()
	local width_at_end = self.ray_quad_width + (self.ray_quad_end_width - self.ray_quad_width) * (self.ray_length / self.trapezoid_height)
	
	return reversed ({ 
		self.position - perpendicular * self.ray_quad_width/2,
		self.current_endpoint - perpendicular * width_at_end/2,
		self.current_endpoint + perpendicular * width_at_end/2,
		self.position + perpendicular * self.ray_quad_width/2
	})
end

function instability_ray_module:loop()
	self.instability_bonus = 0
	local delta_ms = self.delta_timer:extract_milliseconds() * physics_system.timestep_multiplier
	
	self.polygon_fader:loop()
	
	if self.currently_casting then
		self.ray_length = self.ray_length + delta_ms * 5
		self.instability_bonus = delta_ms/1000/10
	else
		self.ray_length = self.ray_length - delta_ms * 5
	end

	if self.ray_length < 0 then
		self.ray_length = 0
	end 
	
	if self.ray_length <= 50 then
		return false
	end
	
	
	if self.ray_length > self.radius_of_effect then
		self.ray_length = self.radius_of_effect
	end
	
	self.current_endpoint = self.position + self.direction * self.ray_length

	-- check for collisions with enemies
	local world_polygon = vec2_vector()
	local polygon_table = self:construct_world_polygon()
	
	add_vals(world_polygon, polygon_table)
	
	-- leave a polygon trace every some small interval
	if self.trace_timer:get_milliseconds() > 5 and self.polygon_fader:get_num_traces() < 50 then
		-- leave a trace 
		
		local alpha_animator = value_animator(255, -0.1, 250)
		alpha_animator:set_exponential()
		
		local new_trace_poly = simple_create_polygon (polygon_table)
		set_polygon_color(new_trace_poly, self.polygon_color)
		map_uv_square(new_trace_poly, images.blank)
		
		self.polygon_fader:add_trace(new_trace_poly, alpha_animator)
		
		self.trace_timer:reset()
	end

	
	local ignored_entity = nil
	
	if self.owner_entity:exists() then
		ignored_entity = self.owner_entity:get()
	end
	
	local hit_enemies_candidates = physics_system:query_polygon(world_polygon, create(b2Filter, self.instability_ray_filter), ignored_entity)
	
	for candidate in hit_enemies_candidates.bodies do
		local enemy_entity = body_to_entity(candidate)
		local p1 = self.position
		local p2 = enemy_entity.transform.current.pos
		
		ray_output = physics_system:ray_cast(p1, p2, create(b2Filter, filter_instability_ray_obstruction), ignored_entity)
		
		-- there are no obstructions on the way
		if not ray_output.hit then
			local enemy_self = get_self(enemy_entity)
			
			if enemy_self then
				if enemy_self.character then 
					enemy_self.character:damage_message({ amount = delta_ms }) 
				end
			end
		end
	end
	
	render_system:push_line(debug_line(world_polygon:at(0), world_polygon:at(1), rgba(255, 255, 255, 255)))
	render_system:push_line(debug_line(world_polygon:at(1), world_polygon:at(2), rgba(255, 255, 255, 255)))
	render_system:push_line(debug_line(world_polygon:at(2), world_polygon:at(3), rgba(255, 255, 255, 255)))
	render_system:push_line(debug_line(world_polygon:at(3), world_polygon:at(0), rgba(255, 255, 255, 255)))
end