render_layers = {
	GUI_OBJECTS = 0,
	EFFECTS = 1,
	OBJECTS = 2,
	HEADS = 3,
	WIELDED_GUNS = 4,
	PLAYERS = 5,
	BULLETS = 6,
	WIELDED = 7,
	LEGS = 8,
	SHELLS = 9,
	ON_GROUND = 10,
	--CORPSES = 11,
	UNDER_CORPSES = 12,
	GROUND = 13
}

-- PHYSICS COLLISION LAYERS --
create_options { 
	"CHARACTERS", 
	"OBJECTS", 
	"STATIC_OBJECTS"
}


filter_nothing = {
	categoryBits = 0,
	maskBits = 0
}

local mask_all = bitor(CHARACTERS, OBJECTS, STATIC_OBJECTS)


filter_npc_feet = {
	categoryBits = mask_all,
	maskBits = mask_all
}

filter_static_objects = {
	categoryBits = STATIC_OBJECTS,
	maskBits = mask_all
}

filter_objects = {
	categoryBits = OBJECTS,
	maskBits = mask_all
}

filter_characters = {
	categoryBits = CHARACTERS,
	maskBits = mask_all
}

filter_pathfinding_visibility = {
	categoryBits = STATIC_OBJECTS,
	maskBits = STATIC_OBJECTS
}

filter_characters_separation = {
	categoryBits = mask_all,
	maskBits = bitor(CHARACTERS)
}

filter_player_visibility = {
	categoryBits = mask_all,
	maskBits = bitor(STATIC_OBJECTS)
}

filter_obstacle_visibility = {
	categoryBits = mask_all,
	maskBits = mask_all
}