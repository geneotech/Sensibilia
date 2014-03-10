METERS_TO_PIXELS = 50
PIXELS_TO_METERS = 1/METERS_TO_PIXELS

ENGINE_DIRECTORY = "engine\\"

dofile (ENGINE_DIRECTORY .. "debugging.lua")
dofile (ENGINE_DIRECTORY .. "common.lua")
dofile (ENGINE_DIRECTORY .. "integrator.lua")
--dofile (ENGINE_DIRECTORY .. "sequence.lua")
dofile (ENGINE_DIRECTORY .. "entity_creation_util.lua" )
dofile (ENGINE_DIRECTORY .. "resource_creation_util.lua")
dofile (ENGINE_DIRECTORY .. "tiled_map_loader.lua")

dofile "sensibilia\\scripts\\sensibilia_init.lua"