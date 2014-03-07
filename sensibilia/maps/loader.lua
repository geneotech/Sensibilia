loader_1 = {}
loader_1.create_entities_from_map = function(filename)
	local objects, types = tiled_map_loader.get_all_objects_by_type(filename)
	local polygons, rectangles = {}, {}
	
	for k, v in ipairs(table.concatenate { objects["bg_object_3"], objects["my_type_1"], objects["my_type_2"], objects["default_type"] }) do
		local new_entity = create_entity (tiled_map_loader.basic_entity_table(v, types[v], polygons, rectangles))
	end

	for k, v in ipairs(objects["clock1_pos"]) do
		types[v].scrolling_speed = randval(0.3, 0.8)
	end
	
	--for k, v in spairs(objects["clock1_pos"], function(t, a, b) return types[t[a]].scrolling_speed < types[t[b]].scrolling_speed end) do
	--	local new_clock_group = spawn_clock(v.pos, { render = { layer = render_layers.CLOCKS }, chase = component_helpers.parallax_chase(types[v].scrolling_speed, v.pos, world_camera) },
	--		images.blue_clock, randval(0.6, 1.2)
	--	)
	--	local new_clock_self = get_self(new_clock_group.body:get())
	--	
	--	new_clock_self.overwrite_position = false
	--end
	
	return { polygons, rectangles }
end