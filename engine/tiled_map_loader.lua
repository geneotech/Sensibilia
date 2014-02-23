tiled_map_loader = {
	error_callback = function(msg)
		print (msg)
		debugger_break()
	end,
	
	texture_property_name = "texture",
	type_library = "sensibilia/maps/object_types",
	
	_get_table = function (filename)
		return require(filename)
	end,
	
	get_all_textures = function (filename)
		local this = tiled_map_loader
		local err = this.error_callback
		
		local map_table = this._get_table(filename)
		local type_table = this._get_table(this.type_library)
		
		if type_table == nil then 
			err ("error loading type table " .. this.type_library)
		end
		
		if map_table == nil then 
			err ("error loading map filename " .. filename)
		end
		
		if type_table.default_type == nil then 
			type_table.default_type = {}
		end
		
		local needed_textures = {}
	
					
		for a, layer in ipairs(map_table.layers) do
			if layer.type == "objectgroup" then
				for b, object in ipairs(layer.objects) do
					if object.type == "" then
						object.type = "default_type"
					end
					
					local this_type_table = type_table[object.type]
					
					if this_type_table == nil then
						err ("couldn't find type " .. object.type .. " for object \"" .. object.name .. "\" in layer \"" .. layer.name .. "\"")
					end
					
					local texture_name = this_type_table[this.texture_property_name]
					
					if texture_name ~= nil then 
						print "adding"
						needed_textures[texture_name] = true
					end
				end
			end
		end
		
		return needed_textures
	end
}


