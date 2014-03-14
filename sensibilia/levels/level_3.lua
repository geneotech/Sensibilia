reload_default_level_resources("map_3", "loader.lua", nil)

level_resources.after_introduction_callback = function()
	level3_music:play()
end
