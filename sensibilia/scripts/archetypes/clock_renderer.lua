clock_renderer_archetype = {
	body = {
		render = {
			mask = render_masks.WORLD,
			layer = render_layers.GUI_OBJECTS,
			model = clock_sprite
		},
		
		transform = {}
	}
}

function spawn_clock(position, body_override, ...)
	local final_group = archetyped(clock_renderer_archetype, { body = body_override })
	--print(table.inspect(final_group))
	
	local new_group = spawn_entity(final_group)
	local this = get_self(new_group.body:get())
	
	new_group.body:get().transform.pos = position
	
	this.clock_renderer = clock_renderer_module:create(new_group, ...)
	
	return new_group
end