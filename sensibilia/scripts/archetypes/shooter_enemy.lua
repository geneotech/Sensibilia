shooter_npc_class = inherits_from (entity_class)

-- set it manually in spawn function
--function shooter_npc_class:set_movement_mode_flying(flag)
--	-- always set to true
--	--npc_class:set_movement_mode_flying(self, true)
--end

shooter_npc_archetype = archetyped(pusher_archetype, {
	gun_entity = {
		gun = archetyped(instability_gun, {
			
		
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
		children = {
			"gun_entity"
		},
		
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