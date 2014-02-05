basic_npc_sprite = create_sprite {
	image = images.blank,
	size = vec2(30, 100),
	color = rgba(255, 0, 0, 200)
}

basic_npc_class = inherits_from (npc_class)

function basic_npc_class:loop()
	self:handle_steering()
	self:handle_player_visibility()
	
		-- handle pathfinding
	if self.entity.pathfinding:is_still_pathfinding() or self.entity.pathfinding:is_still_exploring() then
		target_entities.navigation.transform.current.pos = entity.pathfinding:get_current_navigation_target()
		
		-- handle visibility offset for feet
		local decided_offset = vec2(0, self.foot_sensor_p1.y)
		
		if to_vec2(self.entity.physics.body:GetLinearVelocity()):rotate(-self.entity.movement.axis_rotation_degrees, vec2(0, 0)).x < 0 then
			decided_offset.x = self.foot_sensor_p1.x
		else
			decided_offset.x = self.foot_sensor_p2.x
		end
		
		self.entity.visibility:get_layer(visibility_component.DYNAMIC_PATHFINDING).offset = vec2(decided_offset):rotate(self.entity.movement.axis_rotation_degrees, vec2(0, 0))
	end
	
	self.steering_behaviours.target_seeking.enabled = true
	self.steering_behaviours.target_seeking.target:set(player.crosshair.transform.current.pos, vec2(0, 0))
	
	self:map_vector_to_movement(self.steering_behaviours.target_seeking.last_output_force)
	
	self:handle_jumping()
end


my_basic_npc = spawn_npc({
	body = {
		render = {
			model = basic_npc_sprite
		},
		
		transform = {
			pos = vec2(500, -1000)
		}
	}
}, basic_npc_class)


	--self.steering_behaviours.target_seeking.enabled = false
	--self.steering_behaviours.target_seeking.target:set(player.crosshair.transform.current.pos, vec2(0, 0))

get_self(my_basic_npc.body):set_foot_sensor_from_sprite(basic_npc_sprite, 3)