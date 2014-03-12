duration_multiplier = 0.7
npc_size_multiplier = vec2(0.4, 0.4)

player_animations = {}

player_animations.standing = create_animation {
	frames = {
		{ model = { image = images.stand,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier }
	},
	
	loop_mode = animation.REPEAT
}


player_animations.running = create_animation {
	frames = {
		{ model = { image = images.run_1,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier },
		{ model = { image = images.run_2,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier },
		{ model = { image = images.run_3,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier },
		{ model = { image = images.run_4,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier },
		{ model = { image = images.run_5,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier },
		{ model = { image = images.run_6,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier },
		{ model = { image = images.run_7,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier },
		{ model = { image = images.run_8,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier }
	},
	
	loop_mode = animation.REPEAT
}


player_animations.take_jump = create_animation {
	frames = {
		{ model = { image = images.jump_1,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier },
		{ model = { image = images.jump_2,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier }
	},
	
	loop_mode = animation.NONE
}

player_animations.in_air = create_animation {
	frames = {
		{ model = { image = images.jump_2,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier }
	},
	
	loop_mode = animation.NONE
}

player_animations.falling = create_animation {
	frames = {
		{ model = { image = images.jump_1,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier }
	},
	
	loop_mode = animation.NONE
}

player_animations.begin_shooting = create_animation {
	frames = {
		{ model = { image = images.shoot_1,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier },
		{ model = { image = images.shoot_2,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier },
		{ model = { image = images.shoot_3,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier }
	},
	
	loop_mode = animation.NONE
}

player_animations.stop_shooting = create_animation {
	frames = {
		{ model = { image = images.shoot_3,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier },
		{ model = { image = images.shoot_2,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier },
		{ model = { image = images.shoot_1,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier }
	},
	
	loop_mode = animation.NONE
}


player_animations.begin_shooting_in_air = create_animation {
	frames = {
		{ model = { image = images.jump_shoot,  size_multiplier = npc_size_multiplier }, duration_ms = 20*duration_multiplier }
	},
	
	loop_mode = animation.NONE
}