config_table = {
	godmode = 0,
	
	window_name = "example",
	fullscreen = 0,
	window_border = 0,
	window_x = 0,
	window_y = 0,
	bpp = 24,
	resolution_w = 1300,
	resolution_h = 1000,
	doublebuffer = 1,
	
	
	sensitivity = vec2(2.5, 2.5)
}

if config_table.fullscreen == 1 then
	config_table.resolution_w = get_display().w
	config_table.resolution_h = get_display().h
end