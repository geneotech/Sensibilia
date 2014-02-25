render_layers = {
	GUI_OBJECTS = 0,
	FOREGROUND = 1,
	OBJECTS = 2,
	CHARACTERS = 3,
	BACKGROUND = 4
}

-- PHYSICS COLLISION LAYERS --
create_options { 
	"CHARACTERS",
	"ENEMIES",
	"OBJECTS", 
	"STATIC_OBJECTS",
	"INSTABILITY_RAY"
}


filter_nothing = {
	categoryBits = 0,
	maskBits = 0
}

-- used only for query/raycast filters
local mask_all = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS, INSTABILITY_RAY)




filter_static_objects = {
	categoryBits = STATIC_OBJECTS,
	maskBits = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS)
}

filter_objects = {
	categoryBits = OBJECTS,
	maskBits = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS)
}

filter_characters = {
	categoryBits = CHARACTERS,
	maskBits = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS, INSTABILITY_RAY)
}

filter_enemies = {
	categoryBits = ENEMIES,
	maskBits = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS, INSTABILITY_RAY)
}

filter_pathfinding_visibility = {
	categoryBits = STATIC_OBJECTS,
	maskBits = STATIC_OBJECTS
}

filter_character_feet = {
	categoryBits = mask_all,
	maskBits = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS)
}

filter_instability_ray_player = {
	categoryBits = mask_all,
	maskBits = bitor(ENEMIES)
}

filter_instability_ray_enemy = {
	categoryBits = mask_all,
	maskBits = bitor(CHARACTERS)
}

filter_instability_ray_obstruction = {
	categoryBits = mask_all,
	maskBits = bitor(STATIC_OBJECTS, OBJECTS)
}

filter_characters_separation = {
	categoryBits = mask_all,
	maskBits = bitor(ENEMIES)
}

filter_player_visibility = {
	categoryBits = mask_all,
	maskBits = bitor(STATIC_OBJECTS)
}

filter_obstacle_visibility = {
	categoryBits = mask_all,
	maskBits = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS)
}