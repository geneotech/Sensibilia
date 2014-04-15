wayward_archetype = {
	body = {
		scriptable = {}
	}	
}

function spawn_wayward(position, body_override, ...)
	local final_group = archetyped(wayward_archetype, { body = body_override })
	
	local new_group = ptr_create_entity_group(final_group)
	local this = generate_entity_object(new_group.body)
	
	new_group.body:get().transform.pos = position
	
	this.waywardness = waywardness_module:create(new_group.body:get(), ...)
	
	return new_group
end