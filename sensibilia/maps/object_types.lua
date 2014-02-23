

local environmental_archetype = {
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
	}
}


return {
	default_type = {
		czo = 2,
		texture = "blank.png",
		entity_archetype = environmental_archetype
	},
	
	my_type_1 = {
		jacie = 234234,
		texture = "my_type_1.jpg",
		entity_archetype = environmental_archetype
	},
	
	my_type_2 = {
		texture = "my_type_2.jpg",
		entity_archetype = environmental_archetype
	}
}