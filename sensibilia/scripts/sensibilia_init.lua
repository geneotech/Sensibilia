-- initialize game-related libraries
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


dofile "sensibilia\\scripts\\resources\\layers.lua"

dofile "sensibilia\\scripts\\instability_gun.lua"

dofile "sensibilia\\scripts\\enemy_ai.lua"
	
dofile "sensibilia\\scripts\\modules\\clock_renderer_module.lua"
dofile "sensibilia\\scripts\\modules\\character_module.lua"
dofile "sensibilia\\scripts\\modules\\jumping_module.lua"
dofile "sensibilia\\scripts\\modules\\coordination_module.lua"
dofile "sensibilia\\scripts\\modules\\instability_ray_module.lua"
dofile "sensibilia\\scripts\\modules\\waywardness_module.lua"

	
dofile "sensibilia\\scripts\\enter_menu_screen.lua"