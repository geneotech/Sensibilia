loader_1 = {}
loader_1.create_entities_from_map = function(filename)
	local objects, types = tiled_map_loader.get_all_objects_by_type(filename)
	local polygons, rectangles = {}, {}
	

	return tiled_map_loader.create_entities_from_map(filename)
end