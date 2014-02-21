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
	self.ray_quad_end_width = 30
	
	self.entity_owner = entity
	self.current_ortho = vec2(0, 0)
	self.radius_of_effect = 4000
	
	self.trapezoid_height = 200

	self.trace_timer = timer()
	
	self.polygon_traces = {
	
	}
	-- for rendering
	table.insert(global_instability_rays, self)
end

function instability_ray_caster:generate_triangles(camera_transform, output_buffer, visible_area)
	--self.direction = 
    --
	--local world_polygon = self:construct_world_polygon()
	for k, v in ipairs(self.polygon_traces) do	
	
		--for i = 1, 4 do
		--	pv(self.polygon_traces[k]:get_vertex(i-1).pos)
		--end
		
		local my_draw_input = draw_input()
		my_draw_input.camera_transform = camera_transform
		my_draw_input.output = output_buffer
		my_draw_input.visible_area = rect_ltrb(visible_area)
		
		v:draw(my_draw_input)
	end
	--coroutine.resume(self.rendering_routine)
end

function instability_ray_caster:cast(flag)
	self.currently_casting = flag
	--if flag then
	--	self.rendering_routine = coroutine.create( function () 
	--	
	--	
	--	end)
	--end
end

function instability_ray_caster:construct_world_polygon()
	-- bind draw input
	local perpendicular = self.direction:perpendicular_cw()
	--pv(self.direction)
	--print(self.ray_quad_width)
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
	--pv(self.direction)
	local delta_ms = self.delta_timer:extract_milliseconds() * physics_system.timestep_multiplier
	
	local to_delete = {}
	
	for k, v in ipairs(self.polygon_traces) do
		for i = 1, 4 do
			local my_alpha = self.polygon_traces[k]:get_vertex(i-1).color.a
			local final_alpha = my_alpha - delta_ms
			
			--print (final_alpha)
			if final_alpha < 0 then
				table.insert(to_delete, k)
				break
				--self.polygon_traces[k] = nil
			else
				self.polygon_traces[k]:get_vertex(i-1).color.a = final_alpha
			end	
		end
	end
	
	for k, v in pairs(to_delete) do
		table.remove(self.polygon_traces, v)
		print "deletin"
	end
	
	
	if self.currently_casting then
		self.ray_length = self.ray_length + delta_ms * 10
		self.instability_bonus = delta_ms/1000/10
	else
		self.ray_length = self.ray_length - delta_ms * 10
		--self.ray_length = 0
	end

	if self.ray_length < 0 then
		self.ray_length = 0
	end 
	
	if self.ray_length <= 50 then
		return false
	end
	
	--print "loopin"
	--pv(self.direction)
	--local direction_lengthened = 
	--pv(self.direction)
	
	--pv(self.direction)
	
	--local length_clamped = direction_lengthened:clamp(self.current_ortho):length()
	
	-- if close enough to maximum allowed ray length, leave a polygon 
	
	--pv(self.direction)
	if self.ray_length > self.radius_of_effect then
		self.ray_length = self.radius_of_effect
	end
	
	--pv(self.direction)
	self.current_endpoint = self.position
	--pv(self.direction)
	self.current_endpoint = self.current_endpoint + self.direction * self.ray_length
	--pv(self.direction)
	--render_system:push_line(debug_line(self.position, self.current_endpoint, rgba(255, 255, 255, 255)))

	--pv(self.direction)
	-- check for collisions with enemies
	
	local world_polygon = vec2_vector()
	local polygon_table = self:construct_world_polygon()
	
	--pv(self.direction)
	add_vals(world_polygon, polygon_table)
	
	

	
	if --(self.ray_length - self.radius_of_effect) < 1 and 
	self.trace_timer:get_milliseconds() > 16 then
		-- leave a trace 
		print "leavin"
		
		table.insert(self.polygon_traces, 
		create_polygon ({
			{ pos = polygon_table[1], color = rgba(255, 255, 255, 255), texcoord = vec2(0, 0), image = images.blank },
			{ pos = polygon_table[2], color = rgba(255, 255, 255, 255), texcoord = vec2(1, 0), image = images.blank },
			{ pos = polygon_table[3], color = rgba(255, 255, 255, 255), texcoord = vec2(1, 1), image = images.blank },
			{ pos = polygon_table[4], color = rgba(255, 255, 255, 255), texcoord = vec2(0, 1), image = images.blank }
		}
		))
		
		self.trace_timer:reset()
	end
	
	
	
	--pv(self.direction)
		
		--print(debug.my_traceback())
		--print(self.ray_length)
		--pv(self.current_endpoint)
		--pv(self.position)
		--pv(self.direction)
		--pv(world_polygon:at(0))
		--pv(world_polygon:at(1))
		--pv(world_polygon:at(2))
		--pv(world_polygon:at(3))
	--debugger_break()
	local hit_enemies_candidates = physics_system:query_polygon(world_polygon, create(b2Filter, filter_instability_ray), self.entity_owner)
	
	--self.something_under_foot = false
	
	for candidate in hit_enemies_candidates.bodies do
		local enemy_self = get_self(body_to_entity(candidate))
		enemy_self:take_damage(delta_ms)
		--print ("dealing" .. delta_ms)
	end
	
	render_system:push_line(debug_line(world_polygon:at(0), world_polygon:at(1), rgba(255, 255, 255, 255)))
	render_system:push_line(debug_line(world_polygon:at(1), world_polygon:at(2), rgba(255, 255, 255, 255)))
	render_system:push_line(debug_line(world_polygon:at(2), world_polygon:at(3), rgba(255, 255, 255, 255)))
	render_system:push_line(debug_line(world_polygon:at(3), world_polygon:at(0), rgba(255, 255, 255, 255)))
end