local environmental_archetype = {
	physics = {
		body_type = Box2D.b2_dynamicBody,
		
		body_info = {
			shape_type = physics_info.POLYGON,
			filter = filter_objects,
			density = 1.0,
			friction = 0.1,
			
			linear_damping = 1000,
			angular_damping = 1000
		}
	}
}

return {
	world_property_default_type = {},

	clock1_pos = {
		texture = "blue_clock.png"
	},
	
	clock2_pos = {
		texture = "brown_clock.png"
	},
	
	clock3_pos = {
		texture = "blue_clock.png",
		color = rgba(50, 50, 50, 255)
	},
	
	default_type = {
		render_layer = "OBJECTS",
		texture = "my_type_1.jpg",
		entity_archetype = environmental_archetype
	},
	
	bg_object_3 = {
		color = rgba(82, 82, 82, 255),
		render_layer = "BACKGROUND_3",
		scrolling_speed = 0.3,
		texture = "my_type_1.jpg",
		entity_archetype = {}
	},
	
	my_type_1 = {
		render_layer = "OBJECTS",
		texture = "my_type_1.jpg",
		entity_archetype = environmental_archetype
	},
	
	my_type_2 = {
		render_layer = "OBJECTS",
		texture = "my_type_2.jpg",
		entity_archetype = environmental_archetype
	}
}