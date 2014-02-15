global_instability_rays = {}

instability_ray_caster = inherits_from {}

function instability_ray_caster:constructor(entity)
	self.position = vec2(0, 0)
	self.direction = vec2(0, 0)
	
	self.current_endpoint = vec2(0, 0)
	
	self.ray_length = 0
	self.currently_casting = false
	
	self.delta_timer = timer()
	
	self.ray_quad_width = 100
	self.ray_quad_end_width = 200
	
	self.entity_owner = entity
	self.current_ortho = vec2(0, 0)
	
	self.trapezoid_height = 200

	-- for rendering
	table.insert(global_instability_rays, self)
end

function instability_ray_caster:render()
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
	pv(self.direction)
	local delta_ms = self.delta_timer:extract_milliseconds() * 3 * physics_system.timestep_multiplier
	
	
	if self.currently_casting then
		self.ray_length = self.ray_length + delta_ms 
	else
		self.ray_length = self.ray_length - delta_ms
	end

	if self.ray_length < 0 then
		self.ray_length = 0
	end 
	
	if self.ray_length <= 50 then
		return false
	end
	
	--print "loopin"
	pv(self.direction)
	local direction_lengthened = self.direction * self.ray_length
	pv(self.direction)
	direction_lengthened:clamp(self.current_ortho)
	pv(self.direction)
	
	local length_clamped = direction_lengthened:length()
	
	pv(self.direction)
	if self.ray_length > length_clamped then
		self.ray_length = length_clamped
	end
	
	pv(self.direction)
	self.current_endpoint = self.position
	pv(self.direction)
	self.current_endpoint = self.current_endpoint + direction_lengthened
	pv(self.direction)
	--render_system:push_line(debug_line(self.position, self.current_endpoint, rgba(255, 255, 255, 255)))

	pv(self.direction)
	-- check for collisions with enemies
	local world_polygon = vec2_vector()
	pv(self.direction)
	add_vals(world_polygon, self:construct_world_polygon())
	pv(self.direction)
		
		--print(debug.my_traceback())
		print(self.ray_length)
		pv(self.current_endpoint)
		pv(self.position)
		pv(self.direction)
		pv(world_polygon:at(0))
		pv(world_polygon:at(1))
		pv(world_polygon:at(2))
		pv(world_polygon:at(3))
	debugger_break()
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