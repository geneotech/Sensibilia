enemy_movement_behaviour_tree = create_behaviour_tree {
	decorators = {
	
	},
	
	nodes = {
		-- main node
		movement = {
			node_type = behaviour_node.SELECTOR,
			default_return = behaviour_node.SUCCESS,
			skip_to_running_child = 0
		},
	
		player_visible = {
			node_type = behaviour_node.SELECTOR,
			on_update = function(entity) 
				if player.body:get() and get_self(entity).is_seen then 
					entity.lookat.target:set(player.body:get())
					entity.lookat.look_mode = lookat_component.POSITION
					return behaviour_node.SUCCESS
				end
				
				entity.lookat.target:set(entity)
				entity.lookat.look_mode = lookat_component.VELOCITY
				return behaviour_node.FAILURE
			end
		},
		
		stand_still = {
			on_update = function(entity)
				if player.body:get() then
					get_self(entity):set_movement_speed_multiplier(0.4)
					get_self(entity):pursue_target(player.body:get())	
					return behaviour_node.RUNNING
				end
				return behaviour_node.FAILURE
			end,
			
			on_exit = function(entity, code)
				get_self(entity):stop_pursuit()
			end
		},
		
		is_alert = {
			node_type = behaviour_node.SELECTOR,
			on_update = function(entity)
				if get_self(entity).is_alert then
					get_self(entity):set_movement_speed_multiplier(1)
					return behaviour_node.SUCCESS 
				end
				return behaviour_node.FAILURE
			end
		},
		
		go_to_last_seen = {
			on_enter = function(entity, current_task)		
				current_task:interrupt_runner(behaviour_node.FAILURE)
				local npc_info = get_self(entity)
				
				local temporary_copy = vec2(npc_info.target_entities.last_seen.transform.current.pos.x, npc_info.target_entities.last_seen.transform.current.pos.y)
				local target_point_pushed_away = physics_system:push_away_from_walls(temporary_copy, 100, 10, create(b2Filter, filter_pathfinding_visibility), entity)
				npc_info.target_entities.last_seen.transform.current.pos = target_point_pushed_away
				
				render_system:push_non_cleared_line(debug_line(temporary_copy, target_point_pushed_away, rgba(0, 255, 0, 255)))
				
				entity.pathfinding:start_pathfinding(target_point_pushed_away)
			end,
			
			on_update = function(entity)
				local npc_info = get_self(entity)
			
				entity.pathfinding.custom_exploration_hint.origin = npc_info.target_entities.last_seen.transform.current.pos
				entity.pathfinding.custom_exploration_hint.target = npc_info.target_entities.last_seen.transform.current.pos + (npc_info.last_seen_velocity * 50)
				
				render_system:push_line(debug_line(entity.transform.current.pos, get_self(entity).target_entities.last_seen.transform.current.pos, rgba(255, 0, 0, 255)))
				render_system:push_line(debug_line(entity.pathfinding.custom_exploration_hint.origin, entity.pathfinding.custom_exploration_hint.target, rgba(255, 0, 255, 255)))
				
				if entity.pathfinding:is_still_pathfinding() then return behaviour_node.RUNNING end
				return behaviour_node.SUCCESS 
			end
			,
			
			on_exit = function(entity, status)
				entity.pathfinding:clear_pathfinding_info()
			end
		},
		
		follow_hint = {
			on_enter = function(entity, current_task)
				current_task:interrupt_runner(behaviour_node.FAILURE)
				local npc_info = get_self(entity)
			
				-- no need to update exploration hint, on every update go_to_last_seen does it for us
				--entity.pathfinding.custom_exploration_hint.origin = npc_info.target_entities.last_seen.transform.current.pos
				--entity.pathfinding.custom_exploration_hint.target = npc_info.target_entities.last_seen.transform.current.pos + (npc_info.last_seen_velocity * 50)
				
				entity.pathfinding.favor_velocity_parallellness = true
				entity.pathfinding.custom_exploration_hint.enabled = true
				entity.pathfinding:start_exploring()
			end,
			
			on_update = function(entity)
				render_system:push_line(debug_line(entity.pathfinding.custom_exploration_hint.origin, entity.pathfinding.custom_exploration_hint.target, rgba(255, 0, 255, 255)))
				return behaviour_node.RUNNING
			end,
			
			on_exit = function(entity, status)
				entity.pathfinding.custom_exploration_hint.enabled = false
				entity.pathfinding:clear_pathfinding_info()
			end
		},
		
		walk_around = {
			default_return = behaviour_node.RUNNING,
			
			on_enter = function(entity, current_task)
				current_task:interrupt_runner(behaviour_node.FAILURE)
				--npc_behaviour_tree.delay_chase.maximum_running_time_ms = 400
				get_self(entity):set_movement_speed_multiplier(0.2)
				entity.pathfinding:clear_pathfinding_info()
				entity.pathfinding:start_exploring()
				entity.pathfinding.favor_velocity_parallellness = false
				--get_self(entity).steering_behaviours.wandering.weight_multiplier = 0.2 
				--get_self(entity).steering_behaviours.forward_seeking.enabled = true 
			end,
			
			on_exit = function(entity, status)
				entity.pathfinding:clear_pathfinding_info()
			end
		}
	},
	
	connections = {
		movement = {
			"player_visible", "is_alert", "walk_around"
		},
		
		player_visible = {
			"stand_still"
		},
		
		is_alert = {
			"go_to_last_seen", "follow_hint"
		}
	},
	
	root = "movement"
}

npc_alertness = create_behaviour_tree {
	decorators = {
		temporary_alertness = {
			decorator_type = behaviour_timer_decorator,
			maximum_running_time_ms = 5000
		}
	},
	
	nodes = {
		behave = {
			default_return = behaviour_node.SUCCESS
		},
	
		limit_alertness = {
			decorator_chain = "temporary_alertness",
			
			on_update = function(entity)
				if get_self(entity).is_alert and not get_self(entity).is_seen then 
					return behaviour_node.RUNNING 
				end
				return behaviour_node.FAILURE
			end,
			
			on_exit = function(entity, code)
				if code == behaviour_node.SUCCESS then get_self(entity).is_alert = false end
			end
		}
	},
	
	connections = {
		behave = {
			"limit_alertness"
		}
	},
	
	root = "behave"
}
