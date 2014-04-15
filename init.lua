METERS_TO_PIXELS = 50
PIXELS_TO_METERS = 1/METERS_TO_PIXELS

-- immutable libraries used not only for gameplay but also across main menus

ENGINE_DIRECTORY = "engine\\"

dofile (ENGINE_DIRECTORY .. "debugging.lua")
dofile (ENGINE_DIRECTORY .. "common.lua")

dofile (ENGINE_DIRECTORY .. "text_util.lua")
dofile (ENGINE_DIRECTORY .. "button.lua")

dofile (ENGINE_DIRECTORY .. "integrator.lua")
--dofile (ENGINE_DIRECTORY .. "sequence.lua")
dofile (ENGINE_DIRECTORY .. "entity_creation_util.lua" )
dofile (ENGINE_DIRECTORY .. "resource_creation_util.lua")

dofile (ENGINE_DIRECTORY .. "entity_class.lua")
dofile (ENGINE_DIRECTORY .. "entity_system.lua")
dofile (ENGINE_DIRECTORY .. "world_class.lua")

dofile (ENGINE_DIRECTORY .. "tiled_map_loader.lua")

dofile "sensibilia\\scripts\\resources\\sounds.lua"

dofile "sensibilia\\scripts\\level_loader.lua"
dofile "sensibilia\\scripts\\animated_text.lua"
dofile "sensibilia\\scripts\\text_button.lua"

SHADERS_DIRECTORY = "sensibilia\\scripts\\resources\\shaders\\"

dofile (SHADERS_DIRECTORY .. "fullscreen_vertex_shader.lua")

dofile (SHADERS_DIRECTORY .. "scene_shader.lua")
dofile (SHADERS_DIRECTORY .. "film_grain.lua")
dofile (SHADERS_DIRECTORY .. "chromatic_aberration.lua")
dofile (SHADERS_DIRECTORY .. "blur.lua")
dofile (SHADERS_DIRECTORY .. "color_adjustment.lua")
dofile (SHADERS_DIRECTORY .. "spatial_instability.lua")

dofile "sensibilia\\scripts\\sensibilia_init.lua"

	
--dofile "sensibilia\\levels\\level_1.lua"