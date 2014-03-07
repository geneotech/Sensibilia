shooter_sprite = create_sprite {
	image = images.bullet_map,
	size = vec2(120, 120),
	color = rgba(255, 0, 0, 0)
}

shooter_archetype = archetyped(pusher_archetype, {
	gun_entity = {
		gun = archetyped(instability_gun, {
			bullet_callback = function(subject, new_bullet)
				instability_gun_bullet_callback(subject, new_bullet, random_enemy_bullet_models, filter_enemy_bullets_passed_wall)
			end,
			
			bullets_once = 5,
			bullet_damage = minmax(1, 20),
			bullet_body = {
				filter = filter_enemy_bullets	
			}
		}),
		
		transform = {},

		lookat = {
			-- just some initial value, to be changed by logic
			target = "body"
		},
		
		chase = {
			target = "body",
			chase_rotation = false
		}
	},
	
	body = {
		render = {
			model = shooter_sprite
		},
		
		children = {
			"gun_entity"
		},
		
		movement = {
			inverse_thrust_brake = vec2(25000, 0),
			braking_damping = 1
		}
	}
})

function spawn_shooter(position)
	local new_group = spawn_entity(archetyped(shooter_archetype, { body = { transform = { pos = position } } } ))
	local gun_entity = new_group.gun_entity:get()
	local this = get_self(new_group.body:get())
	
	this.all_player_bullets = {}
	this.character = character_module:create(new_group.body:get(), 4000)
	this.character:init_hp(1000)
	
	this.coordination = coordination_module:create(new_group.body:get())
	
	this.loop = function()
		if this.coordination.is_seen then
			gun_entity.gun.trigger_mode = gun_component.SHOOT
		else
			gun_entity.gun.trigger_mode = gun_component.NONE
		end
	
		loop_instability_gun_bullets(new_group, 10+10*instability, rgba(255, 0, 0, 255))	
	end
	
	return new_group
end

_my_npc = spawn_shooter(world_information["ENEMY_START"][1].pos)
_my_npc2 = spawn_shooter(world_information["ENEMY_START"][2].pos)
_my_npc3 = spawn_shooter(world_information["ENEMY_START"][3].pos)