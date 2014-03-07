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
local level_textures = tiled_map_loader.get_all_textures(CURRENT_LEVEL)
print (table.inspect(level_textures))

for filename, v in pairs(level_textures) do
	textures_by_name[filename] = true
end

-- prepare essential textures
images = {
	blank = "blank.png",
	metal = "metal.jpg",
	crosshair_map = "crosshair_map.png",
	bullet_map = "bullet_map.png",
	
	blue_clock = "blue_clock.png",
	brown_clock = "brown_clock.png",
	hand_1 = "hand_1.png",
	hand_2 = "hand_2.png",
	hand_3 = "hand_3.png"
	--protagonist = "protagonist.png"
}

for k, filename in pairs(images) do
	print (filename)
	textures_by_name[filename] = true
end
	
create_textures(my_atlas, textures_by_name)

my_atlas:build()
my_atlas:nearest()

-- setup shortcuts after textures have been created
for k, filename in pairs(images) do
	images[k] = textures_by_name[filename]
end