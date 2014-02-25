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
	}
}

return {
	world_property_default_type = {
	
	},

	default_type = {
		render_layer = "OBJECTS",
		texture = "my_type_1.jpg",
		entity_archetype = environmental_archetype
	},
	
	bg_object_1 = {
		render_layer = "BACKGROUND",
		scrolling_speed = 0.5,
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