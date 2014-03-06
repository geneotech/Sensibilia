local environmental_archetype = {
	physics = {
		body_type = Box2D.b2_dynamicBody,
		
		body_info = {
			shape_type = physics_info.POLYGON,
			filter = filter_objects,
			density = 100000000,
			friction = 0.1,
			
			linear_damping = 1000,
			angular_damping = 1000
		}
	}
}

return {
	world_property_default_type = {},

	default_type = {
		render_layer = "OBJECTS",
		texture = "my_type_1.jpg",
		entity_archetype = environmental_archetype
	},
	
	bg_object_3 = {
		color = rgba(82, 52, 52, 255),
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