should_debug_draw = false
function debug_draw(p1, p2, r, g, b, a)
	if should_debug_draw then render_system:push_non_cleared_line(debug_line(p1*50, p2*50, rgba(r,g,b,a))) end
end

function quadratic_integration(p, dt)
	local new_p = {}
	
	new_p.acc = p.acc
	new_p.vel = p.vel + p.acc * dt 
	new_p.pos = p.pos + new_p.vel * dt
	--if should_debug_draw then print ("since " ..  new_p.pos.x ..  " = " ..  p.pos.x ..  " + " .. p.vel.x .. " * " .. dt .. "\n") end
	-- uncomment this if you want to use quadratic integration
	-- but with small timesteps even this is an overkill since Box2D itself uses traditional Euler
	-- and I found that for calculations to be accurate I either way must keep the timesteps very low at the beginning of the jump
	 --+ p.acc * dt * dt * 0.5
	
	return new_p
end

function point_below_segment(a, b, p)
	-- make sure a is to the left
	if a.x > b.x then a,b = b,a end
	
	return ((b.x - a.x)*(p.y - a.y) - (b.y - a.y)*(p.x - a.x)) < 0
end

-- returns true or false
function can_point_be_reached_by_jump
(
gravity, -- vector (meters per seconds^2)
movement_force, -- vector (meters per seconds^2)
air_resistance_mult, -- scalar
queried_point, -- vector (meters)
starting_position, -- vector (meters)
starting_velocity, -- vector (meters per seconds)
jump_impulse, -- vector (meters per seconds)
mass -- scalar (kilogrammes)
)
	
	local my_point = {
		pos = starting_position,
		vel = starting_velocity + jump_impulse/mass
	}
	
	render_system:push_line(debug_line(queried_point*50, queried_point*50 + vec2(0, 5), rgba(0, 255, 255, 255)))
	
	local accumulated_time = 0
	
	local direction_left = movement_force.x < 0
	
	local step = 1/60
	
	--if should_debug_draw then print("\nBEGIN\n", step) end
	--local res = (vec2(my_point.vel):normalize() * -1 * air_resistance_mult * my_point.vel:length_sq())
	--print(res.x, res.y, my_point.vel:length(), vec2(my_point.vel):normalize().x, vec2(my_point.vel):normalize().y)
	while true do			
		-- calculate resultant force
		my_point.acc = 
		-- air resistance (multiplier * squared length of the velocity * opposite normalized velocity)
		(vec2(my_point.vel):normalize() * -1 * air_resistance_mult * my_point.vel:length_sq()) / mass
		-- remaining forces
		+ gravity + movement_force/mass
		
		--if should_debug_draw then
		--
		--	print (my_point.acc.x, my_point.acc.y)
		--	print (my_point.vel.x, my_point.vel.y)
		--	print (my_point.pos.x, my_point.pos.y)
		--end
		
		-- i've discarded any timestep optimizations at the moment as they are very context specific
		local new_p = quadratic_integration(my_point, step)
	
		debug_draw(my_point.pos, new_p.pos, 255, 0, 255, 255)
		debug_draw(new_p.pos, new_p.pos+vec2(0, -1), 255, 255, 0, 255)
		
		if (direction_left and new_p.pos.x < queried_point.x) or (not direction_left and new_p.pos.x > queried_point.x) then
			if point_below_segment(new_p.pos, my_point.pos, queried_point) then
				debug_draw(new_p.pos, my_point.pos, 255, 0, 0, 255)
				return true
			else
				debug_draw(new_p.pos, my_point.pos, 255, 255, 255, 255)
				return false
			end
		else 
			my_point = new_p
		end
	end

	return false
end