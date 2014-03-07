npc_sprite = create_sprite {
	image = images.bullet_map,
	size = vec2(60, 60),
	color = rgba(255, 0, 0, 0)
}

pusher_archetype = archetyped(character_group_archetype, {
	body = {
		particle_emitter = {
			available_particle_effects = npc_effects
		},
		
		physics = {
			--body_type = Box2D.b2_staticBody,
			
			body_info = {
				filter = filter_enemies,
				density = 100
				--linear_damping = 18
			}
		},
		
		behaviour_tree = {
			trees = {
				npc_alertness.behave,
				enemy_movement_behaviour_tree.movement
			}
		},
		
		lookat = {
			update_value = false,
			easing_mode = lookat_component.EXPONENTIAL,
			averages_per_sec = 10
		},
		
		render = {
			model = npc_sprite,
			mask = render_masks.WORLD
		},
		
		transform = {
			pos = vec2(10000, -5000)
		},
		
		visibility = {
			visibility_layers = {
				[visibility_component.DYNAMIC_PATHFINDING] = {
					square_side = 2000,
					color = rgba(0, 255, 255, 120),
					ignore_discontinuities_shorter_than = 150,
					filter = filter_pathfinding_visibility
				}
			}
		},
		
		pathfinding = {
			enable_backtracking = true,
			target_offset = 3,
			rotate_navpoints = 10,
			distance_navpoint_hit = 2,
			favor_velocity_parallellness = false,
			force_persistent_navpoints = true,
			force_touch_sensors = true
		},
		
		steering = {
			max_resultant_force = -1, -- -1 = no force clamping
			max_speed = 12000*1.4142135623730950488016887242097
		},
		
		movement = {
			inverse_thrust_brake = vec2(15000, 0)
		}
	}
})

function spawn_pusher(position)
	local new_group = spawn_entity(archetyped(pusher_archetype, { body = { transform = { pos = position } }}))
	local this = get_self(new_group.body:get())
	
	this.character = character_module:create(new_group.body:get(), 4000)
	this.jumping = jumping_module:create(new_group.body:get())
	this.coordination = coordination_module:create(new_group.body:get())
	
	this.jumping:set_foot_sensor_from_sprite(npc_sprite, 3)
	
	this.instability_ray = instability_ray_module:create(new_group.body, filter_instability_ray_enemy)
	this.instability_ray.ray_quad_width = randval(15, 20)
	this.instability_ray.ray_quad_end_width = randval(70, 280)
	this.instability_ray.polygon_color = rgba(50, 0, 0, 1)
	this.instability_ray.radius_of_effect = randval(20, 150)
	this.character:init_hp(2000)
	
	this.damage_message = function(msg)
		this.coordination:handle_player_visibility(true)
	end
	
	this.loop = function()
		local caster = this.instability_ray
	
		caster.position = this.parent_group.body:get().transform.current.pos
		caster.direction = vec2.from_degrees(this.parent_group.body:get().lookat.last_value)
		caster.current_ortho = vec2(world_camera.camera.ortho.r, world_camera.camera.ortho.b)
	
		caster:cast(this.coordination.is_seen)
	end
	
	new_group.body:get().pathfinding:start_exploring()
	
	return new_group
end

my_npc = spawn_pusher(world_information["ENEMY_START"][1].pos)
my_npc2 = spawn_pusher(world_information["ENEMY_START"][2].pos)
my_npc3 = spawn_pusher(world_information["ENEMY_START"][3].pos)