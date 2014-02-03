basic_npc_sprite = create_sprite {
	image = images.blank,
	size = vec2(30, 100),
	color = rgba(255, 0, 0, 200)
}

basic_npc_class = inherits_from (npc_class)

function basic_npc_class:loop()
	npc_class.loop(self)
	
	self.steering_behaviours.target_seeking.enabled = true
	self.steering_behaviours.target_seeking.target:set(player.crosshair.transform.current.pos, vec2(0, 0))
	
	self:map_vector_to_movement(self.steering_behaviours.target_seeking.last_output_force)
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