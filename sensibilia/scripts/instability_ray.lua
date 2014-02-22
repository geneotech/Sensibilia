global_instability_rays = {}

instability_ray_caster = inherits_from {}

function instability_ray_caster:constructor(entity)
	self.position = vec2(0, 0)
	self.direction = vec2(0, 0)
	
	self.current_endpoint = vec2(0, 0)
	
	self.ray_length = 0
	self.currently_casting = false
	
	self.delta_timer = timer()
	
	self.ray_quad_width = 20
	self.ray_quad_end_width = 50
	
	self.entity_owner = entity
	self.current_ortho = vec2(0, 0)
	self.radius_of_effect = 8000
	
	self.trapezoid_height = 200

	self.trace_timer = timer()
	
	self.polygon_traces = {
	
	}
	-- for rendering
	table.insert(global_instability_rays, self)
end

function instability_ray_caster:generate_triangles(camera_transform, output_buffer, visible_area)
	for k, v in ipairs(self.polygon_traces) do	
		local my_draw_input = draw_input()
		my_draw_input.camera_transform = camera_transform
		my_draw_input.output = output_buffer
		my_draw_input.visible_area = rect_ltrb(visible_area)
		
		v.poly:draw(my_draw_input)
	end
end

function instability_ray_caster:cast(flag)
	self.currently_casting = flag
end

function instability_ray_caster:construct_world_polygon()
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

function instability_ray_caster:loop()
	self.instability_bonus = 0
	local delta_ms = self.delta_timer:extract_milliseconds() * physics_system.timestep_multiplier
	
	local to_delete = {}
	
	for k, v in ipairs(self.polygon_traces) do
		for i = 1, 4 do
			local final_alpha = self.polygon_traces[k].alpha_animator:get_animated()
			
			if final_alpha <= 0 then
				table.insert(to_delete, k)
				break
			else
				self.polygon_traces[k].poly:get_vertex(i-1).color.a = final_alpha
			end	
		end
	end
	
	for k, v in pairs(to_delete) do
		table.remove(self.polygon_traces, v)
	end
	
	
	if self.currently_casting then
		self.ray_length = self.ray_length + delta_ms * 10
		self.instability_bonus = delta_ms/1000/10
	else
		self.ray_length = self.ray_length - delta_ms * 10
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
	if self.trace_timer:get_milliseconds() > 5 then
		-- leave a trace 
		
		local new_trace = {
			poly = create_polygon ({
				{ pos = polygon_table[1], color = rgba(255, 255, 255, 255), texcoord = vec2(0, 0), image = images.blank },
				{ pos = polygon_table[2], color = rgba(255, 255, 255, 255), texcoord = vec2(1, 0), image = images.blank },
				{ pos = polygon_table[3], color = rgba(255, 255, 255, 255), texcoord = vec2(1, 1), image = images.blank },
				{ pos = polygon_table[4], color = rgba(255, 255, 255, 255), texcoord = vec2(0, 1), image = images.blank }
			}),
			alpha_animator = value_animator(255, -0.1, 250)
		}
		
		new_trace.alpha_animator:set_exponential()
		
		table.insert(self.polygon_traces, new_trace)
		
		self.trace_timer:reset()
	end

	local hit_enemies_candidates = physics_system:query_polygon(world_polygon, create(b2Filter, filter_instability_ray), self.entity_owner)
	
	for candidate in hit_enemies_candidates.bodies do
		local enemy_self = get_self(body_to_entity(candidate))
		enemy_self:take_damage(delta_ms)
	end
	
	render_system:push_line(debug_line(world_polygon:at(0), world_polygon:at(1), rgba(255, 255, 255, 255)))
	render_system:push_line(debug_line(world_polygon:at(1), world_polygon:at(2), rgba(255, 255, 255, 255)))
	render_system:push_line(debug_line(world_polygon:at(2), world_polygon:at(3), rgba(255, 255, 255, 255)))
	render_system:push_line(debug_line(world_polygon:at(3), world_polygon:at(0), rgba(255, 255, 255, 255)))
end