loader_1 = {}
loader_1.create_entities_from_map = function(filename)
	local objects, types = tiled_map_loader.get_all_objects_by_type(filename)
	local polygons, rectangles = {}, {}
	
	for k, v in ipairs(table.concatenate { objects["bg_object_3"], objects["my_type_1"], objects["my_type_2"], objects["default_type"] }) do
		local new_entity = create_entity (tiled_map_loader.basic_entity_table(v, types[v], polygons, rectangles))
	end

	return { polygons, rectangles } 
end