loader_1 = {}
loader_1.create_entities_from_map = function(filename)
	local objects, types = tiled_map_loader.get_all_objects_by_type(filename)
	local polygons, rectangles = {}, {}
	
	for k, v in ipairs(table.concatenate { 	objects["my_type_1"], objects["my_type_2"], objects["default_type"] }) do
		local new_object_group = spawn_wayward (v.pos, tiled_map_loader.basic_entity_table(v, types[v], polygons, rectangles), 500)
	end
	
	for k, v in ipairs(table.concatenate { objects["bg_object_3"] }) do
		local new_entity = create_entity (tiled_map_loader.basic_entity_table(v, types[v], polygons, rectangles))
	end

	local clocks_table = table.concatenate({ objects["clock1_pos"], objects["clock2_pos"] })
	
	for k, v in ipairs(clocks_table) do
		types[v].scrolling_speed = randval(0.05, 0.3)
	end
	
	for k, v in spairs(clocks_table, function(t, a, b) return types[t[a]].scrolling_speed > types[t[b]].scrolling_speed end) do
		local chosen_image = textures_by_name[types[v].texture]
	
		local body_size = randval(0.6, 1)
		local new_clock_group = spawn_clock(v.pos, { render = { layer = render_layers.CLOCKS }, chase = component_helpers.parallax_chase(types[v].scrolling_speed, v.pos, world_camera) },
			chosen_image, { body_size, body_size+randval(-0.1, 0.5), body_size+randval(-0.1, 0.5), body_size+randval(-0.1, 0.5) }, { randval(0.1, 0.5), randval(0.2, 0.5), randval(0.8, 1), randval(0.8, 1) },
			randval(0.7, 5)
			)
		
		local new_clock_self = get_self(new_clock_group.body:get())
		
		local randomized_vals = randval(0, 1) > 0.2
		new_clock_self.clock_renderer.overwrite_position = false
		new_clock_self.clock_renderer.randomized_hands_values = randomized_vals
		new_clock_self.clock_renderer.rotate_body = randomized_vals
		new_clock_self.clock_renderer.logarithmic_blinks = randomized_vals
	end
	
	return { polygons, rectangles }
end