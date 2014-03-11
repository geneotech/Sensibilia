METERS_TO_PIXELS = 50
PIXELS_TO_METERS = 1/METERS_TO_PIXELS

-- immutable libraries used not only for gameplay but also across main menus

ENGINE_DIRECTORY = "engine\\"

dofile (ENGINE_DIRECTORY .. "debugging.lua")
dofile (ENGINE_DIRECTORY .. "common.lua")

dofile (ENGINE_DIRECTORY .. "world_class.lua")
dofile (ENGINE_DIRECTORY .. "integrator.lua")
--dofile (ENGINE_DIRECTORY .. "sequence.lua")
dofile (ENGINE_DIRECTORY .. "entity_creation_util.lua" )
dofile (ENGINE_DIRECTORY .. "resource_creation_util.lua")
dofile (ENGINE_DIRECTORY .. "tiled_map_loader.lua")

dofile "sensibilia\\scripts\\level_loader.lua"
dofile "sensibilia\\levels\\level_1.lua"