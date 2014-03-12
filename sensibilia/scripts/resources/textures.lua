function create_textures(atl, entries)
	for k,v in pairs(entries) do
		entries[k] = texture("sensibilia\\resources\\" .. k, atl)
	end
end

my_atlas = atlas()
collectgarbage("collect")

function add_roots(root_path, entries)
	local new_table = {}
	
	for k, v in pairs(entries) do
		new_table[k] = (root_path .. v)
	end
	
	return new_table
end

-- set up essential textures 
textures_by_name = {}

-- concatenate essential textures with level textures
local level_textures = tiled_map_loader.get_all_textures(MAP_FILENAME)
print (table.inspect(level_textures))

for filename, v in pairs(level_textures) do
	textures_by_name[filename] = true
end

DEFAULT_GAMEPLAY_TEXTURES = {
	blank = "blank.png",
	metal = "metal.jpg",
	crosshair_map = "crosshair_map.png",
	bullet_map = "bullet_map.png",
	
	blue_clock = "blue_clock.png",
	brown_clock = "brown_clock.png",
	hand_1 = "hand_1.png",
	hand_2 = "hand_2.png",
	hand_3 = "hand_3.png"
}

if GAMEPLAY_TEXTURES == nil then GAMEPLAY_TEXTURES = DEFAULT_GAMEPLAY_TEXTURES end
-- prepare gameplay textures
images = GAMEPLAY_TEXTURES

for k, filename in pairs(images) do
	print (filename)
	textures_by_name[filename] = true
end
	

font_files = {}
collectgarbage("collect")

function get_font(filename, size, letters)
	local new_font_file = font_file()
	new_font_file:open("sensibilia\\resources\\" .. filename, size, letters)
	
	local new_font_object = font_instance()
	new_font_object:build(new_font_file)
	new_font_object:add_to_atlas(my_atlas)	

	table.insert(font_files, new_font_file)
	
	return new_font_object
end

font1 = get_font("font.ttf", 120, "abcdefghijklmnoprstuvwxyzq. ")
font2 = get_font("font2.ttf", 120, "abcdefghijklmnoprstuvwxyzq. ")
font3 = get_font("font3.ttf", 120, "abcdefghijklmnoprstuvwxyzq. ")

create_textures(my_atlas, textures_by_name)

my_atlas:build()
my_atlas:nearest()

-- setup shortcuts after textures have been created
for k, filename in pairs(images) do
	images[k] = textures_by_name[filename]
end