reload_default_level_resources("map_4", "loader.lua", nil)

level_resources.after_introduction_callback = function()
	level_music:play()
end
