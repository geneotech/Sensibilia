-- make it a group because the clock module accepts a group as input
clock_renderer_archetype = {
	body = {
		render = {
			mask = render_masks.WORLD,
			layer = render_layers.GUI_OBJECTS,
			model = clock_sprite
		},
		
		transform = {},
		
		scriptable = {}
	}
}

function spawn_clock(position, body_override, ...)
	local final_group = archetyped(clock_renderer_archetype, { body = body_override })
	--print(table.inspect(final_group))
	
	local new_group = ptr_create_entity_group(final_group)
	local this = generate_entity_object(new_group.body)
	
	new_group.body:get().transform.pos = position
	
	this.clock_renderer = clock_renderer_module:create(new_group, ...)
	
	return new_group
end