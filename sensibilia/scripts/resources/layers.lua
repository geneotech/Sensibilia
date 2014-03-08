render_layers = {
	GUI_OBJECTS = 0,
	FOREGROUND = 1,
	OBJECTS = 2,
	CHARACTERS = 3,
	CLOCKS = 4,
	BACKGROUND_1 = 5,
	BACKGROUND_2 = 6,
	BACKGROUND_3 = 7
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
	"BULLETS",
	"ENEMY_BULLETS"
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
local mask_all = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS, INSTABILITY_RAY, BULLETS, ENEMY_BULLETS)

filter_light_visibility = {
	categoryBits = mask_all,
	maskBits = bitor(STATIC_OBJECTS, OBJECTS, ENEMIES)
}

filter_bullets = {
	categoryBits = BULLETS,
	maskBits = bitor(ENEMIES, OBJECTS, STATIC_OBJECTS, ENEMY_BULLETS)
}

filter_enemy_bullets = {
	categoryBits = ENEMY_BULLETS,
	maskBits = bitor(CHARACTERS, OBJECTS, STATIC_OBJECTS, BULLETS)
}

filter_bullets_passed_wall = {
	categoryBits = BULLETS,
	maskBits = bitor(ENEMIES, ENEMY_BULLETS)
}

filter_enemy_bullets_passed_wall = {
	categoryBits = ENEMY_BULLETS,
	maskBits = bitor(CHARACTERS, BULLETS)
}

filter_static_objects = {
	categoryBits = STATIC_OBJECTS,
	maskBits = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS, BULLETS, ENEMY_BULLETS)
}

filter_objects = {
	categoryBits = OBJECTS,
	maskBits = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS, BULLETS, ENEMY_BULLETS)
}

filter_characters = {
	categoryBits = CHARACTERS,
	maskBits = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS, INSTABILITY_RAY, ENEMY_BULLETS)
}

filter_enemies = {
	categoryBits = ENEMIES,
	maskBits = bitor(CHARACTERS, ENEMIES, OBJECTS, STATIC_OBJECTS, INSTABILITY_RAY, BULLETS)
}










-- QUERIES



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