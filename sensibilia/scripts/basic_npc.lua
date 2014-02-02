basic_npc_sprite = create_sprite {
	image = images.blank,
	size = vec2(30, 100),
	color = rgba(255, 0, 0, 200)
}

my_basic_npc = spawn_npc {
	body = {
		render = {
			model = basic_npc_sprite
		},
		
		transform = {
			pos = vec2(500, -1000)
		}
	}
}

get_self(my_basic_npc.body):set_foot_sensor_from_sprite(basic_npc_sprite, 3)