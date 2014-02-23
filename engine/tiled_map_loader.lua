tiled_map_loader = {
	error_callback = function(msg)
		print (msg)
		debugger_break()
	end,
	
	texture_property_name = "texture",
	type_library = "sensibilia/maps/object_types",
	map_scale = 1,
	
	for_every_object = function(filename, callback)
		local this = tiled_map_loader
		local err = this.error_callback
		
		local map_table = require(filename)
		local type_table = require(this.type_library)
		
		if type_table == nil then 
			err ("error loading type table " .. this.type_library)
		end
		
		if map_table == nil then 
			err ("error loading map filename " .. filename)
		end
		
		if type_table.default_type == nil then 
			type_table.default_type = {}
		end
		
	
					
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
					
					-- validations 
					
					if this_type_table.entity_archetype == nil then
						err("unspecified entity archetype for type " .. object.type)
					end
					
					callback(object, this_type_table)
				end
			end
		end
		
		return needed_textures
	
	end,
	
	get_all_textures = function (filename)
		local this = tiled_map_loader
		local needed_textures = {}
		
		this.for_every_object(filename, function(object, this_type_table)
			local texture_name = this_type_table[this.texture_property_name]
				
			if texture_name ~= nil then
				needed_textures[texture_name] = true
			end
		end)
		
		return needed_textures
	end,
	
	load_map = function (filename)	
		local this = tiled_map_loader
		local err = this.error_callback
		
		local map_object = {
			all_entities = {
				named = {},
				unnamed = {}
			},
			
			all_polygons = {
			
			},
			
			all_sprites = {
			
			}
		}
			
		this.for_every_object(filename, function(object, this_type_table)
			local shape = object.shape
			local used_texture = textures_by_name[this_type_table.texture]
			local final_entity_table = {
				transform = {
					pos = vec2(object.x, object.y)
				}
			}
			local physics_body_type = 0
			
			if shape == "polygon" then
				physics_body_type = physics_info.POLYGON
				local new_polygon = simple_create_polygon (to_vec2_table (object.polygon))
				map_uv_square(new_polygon, used_texture)
				
				final_entity_table = archetyped(final_entity_table, { render = { model = new_polygon } })
				table.insert(map_object.all_polygons, new_polygon)
			elseif shape == "rectangle" then
				physics_body_type = physics_info.RECT
				
				local new_rectangle = create_sprite { 
					image = used_texture,
					size = vec2(object.width, object.height)
				}
				
				final_entity_table = archetyped(final_entity_table, { render = { model = new_rectangle } })
				table.insert(map_object.all_sprites, new_rectangle)
			else
				err ("shape type unsupported!")
			end
			
			
			-- handle physicsal body request
			if this_type_table.entity_archetype.physics ~= nil then
				final_entity_table = archetyped(final_entity_table, { 
					physics = { 
						body_info = {
							shape_type = physics_body_type
						} 
					} 
				})
			end
			
			-- create the entity
			local new_entity = create_entity (archetyped(this_type_table.entity_archetype, final_entity_table))
			
			-- and save it in map table
			if object.name == "" then 
				table.insert(map_object.all_entities.unnamed, new_entity)
			else
				if map_object.all_entities.named[object.name] ~= nil then
					err ("name conflict: " .. object.name)
				end
				
				map_object.all_entities.named[object.name] = new_entity
			end
				
		end)
		
		return map_object
	end
}


