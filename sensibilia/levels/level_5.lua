reload_default_level_resources("map_5", "loader.lua", nil)

level_resources.after_introduction_callback = function()
	level2_music:play()
end
