waywardness_module = inherits_from {}

function waywardness_module:constructor(subject_entity, force_multiplier)
	self.entity = subject_entity
	
	self.waywardness_amount = 0
	self.max_waywardness = 2000

	self.force_multiplier = force_multiplier 
	
	local coord_variation_archetype = {
		min_value = -800, max_value = 800, min_transition_ms = 50, max_transition_ms = 100, wait_probability = 0.01, min_wait_ms = 100, max_wait_ms = 500, constant_transition_delta = false, 
		value_additive = false
	}
	
	self.randomized_center = vec2(0, 0)
	self.randomized_force = vec2(0, 0)
	
	self.coord_variation_tables = {
		archetyped(coord_variation_archetype, { callback = function(new_x_coord) self.randomized_center.x = new_x_coord end } ),
		archetyped(coord_variation_archetype, { callback = function(new_y_coord) self.randomized_center.y = new_y_coord end } ),
		archetyped(coord_variation_archetype, { callback = function(new_x_coord) self.randomized_force.x = new_x_coord end } ),
		archetyped(coord_variation_archetype, { callback = function(new_y_coord) self.randomized_force.y = new_y_coord end } )
	}

	self.coord_variations = {
		coroutine.get_value_variator(self.coord_variation_tables[1]),
		coroutine.get_value_variator(self.coord_variation_tables[2]),
		coroutine.get_value_variator(self.coord_variation_tables[3]),
		coroutine.get_value_variator(self.coord_variation_tables[4])
	}
	
	self.waywardness_decreaser = stepped_timer(physics_system)
end

function waywardness_module:damage_message(msg)
	self.waywardness_amount = self.waywardness_amount + msg.amount*100
end

function waywardness_module:substep()
	if self.waywardness_amount > self.max_waywardness then self.waywardness_amount = self.max_waywardness end
	self.waywardness_amount = self.waywardness_amount - self.waywardness_decreaser:extract_milliseconds()*2*(1-instability)
	if self.waywardness_amount < 0 then self.waywardness_amount = 0 end
	
	local waywardness_mult = self.waywardness_amount/self.max_waywardness
	
	local delta_multiplier = 1 + instability*30
	
	self.coord_variations[1](delta_multiplier)
	self.coord_variations[2](delta_multiplier)
	self.coord_variations[3](delta_multiplier)
	self.coord_variations[4](delta_multiplier)
	
	local body = self.entity.physics.body
	local force = (self.randomized_force / 50) * waywardness_mult * self.force_multiplier * body:GetMass()
	local center = (self.randomized_center / 50) * waywardness_mult
	
	
	--if self.waywardness_amount > 0 then 
	--print(force.x, force.y) 
	--
	--end
	
	body:ApplyForce(b2Vec2(force.x, force.y), b2Vec2(body:GetWorldCenter().x + center.x, body:GetWorldCenter().y + center.y), true)
end