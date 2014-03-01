render_layers = {
	GUI_OBJECTS = 0,
	FOREGROUND = 1,
	OBJECTS = 2,
	CHARACTERS = 3,
	BACKGROUND_1 = 4,
	BACKGROUND_2 = 5,
	BACKGROUND_3 = 6
}

render_masks = {
	WORLD = 0,
	EFFECTS = 1
}

-- PHYSICS COLLISION LAYERS --
create_options { 
	"CHARACTERS",
	"ENEMIES",
	"OBJECTS", 
	"STATIC_OBJECTS",
	"INSTABILITY_RAY",
	"BULLETS"
}

-- VISIBILITY LAYERS --
visibility_layers = {
	BASIC_LIGHTING = 998,
	
	
	LIGHT_BOUNCE = 999
	-- do not add anything below as these values are used by another light bounces
}

filter_nothing = {
	categoryBits = 0,
	maskBits = 0
}

-- used only for query/raycast filters
local mask_all = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS, INSTABILITY_RAY, BULLETS)

filter_light_visibility = {
	categoryBits = mask_all,
	maskBits = bitor(STATIC_OBJECTS, OBJECTS, ENEMIES)
}

filter_bullets = {
	categoryBits = BULLETS,
	maskBits = bitor(ENEMIES, OBJECTS, STATIC_OBJECTS)
}

filter_static_objects = {
	categoryBits = STATIC_OBJECTS,
	maskBits = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS, BULLETS)
}

filter_objects = {
	categoryBits = OBJECTS,
	maskBits = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS, BULLETS)
}

filter_characters = {
	categoryBits = CHARACTERS,
	maskBits = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS, INSTABILITY_RAY)
}

filter_enemies = {
	categoryBits = ENEMIES,
	maskBits = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS, INSTABILITY_RAY, BULLETS)
}

filter_pathfinding_visibility = {
	categoryBits = mask_all,
	maskBits = bitor(STATIC_OBJECTS, OBJECTS)
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
	maskBits = bitor(STATIC_OBJECTS, OBJECTS)
}

filter_obstacle_visibility = {
	categoryBits = mask_all,
	maskBits = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS)
}