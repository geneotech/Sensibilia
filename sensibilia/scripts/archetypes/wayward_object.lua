wayward_archetype = {}

function spawn_wayward(position, body_override, ...)
	local final_group = archetyped(wayward_archetype, { body = body_override })
	
	local new_group = spawn_entity(final_group)
	local this = get_self(new_group.body:get())
	
	new_group.body:get().transform.pos = position
	
	this.waywardness = waywardness_module:create(new_group.body:get(), table.unpack({...}))
	
	return new_group
end