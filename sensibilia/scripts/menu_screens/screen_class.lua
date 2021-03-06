local menu = level_resources

screen_class = inherits_from {}

function screen_class:constructor()
	self.buttons = {}
	self.translation = vec2(0, 0)
end

function screen_class:draw(camera_draw_input)
	local my_text_draw_input = draw_input(camera_draw_input)
	my_text_draw_input.transform.rotation = 0
	
	my_text_draw_input.additional_info = nil
	my_text_draw_input.always_visible = true
	
	for i=1, #self.buttons do
		self.buttons[i].translation = self.translation
		self.buttons[i]:draw(my_text_draw_input)
	end
end

function screen_class:handle_events(message)
	for i=1, #self.buttons do
		self.buttons[i]:handle_events(message, menu.crosshair_group.crosshair.transform.current.pos)
	end
end

menu.current_screen = nil

menu.crosshair_group = create_entity_group {
	body = {
		transform = { pos = vec2(0, 0) }
	},
	
	crosshair = {
		transform = {
			pos = vec2(0, 0),
			rotation = 0
		},
		
		crosshair = {
			sensitivity = config_table.sensitivity,
			size_multiplier = vec2(10, 10)
		},
		
		chase = {
			target = "body",
			relative = true
		},
		
		input = {
			intent_message.AIM
		}
	}
}


function bigger_expand(units)
	local add_expand = 0
	if config_table.resolution_h < 1080 then
		add_expand = 1080 - config_table.resolution_h
	end
	
	world_camera.camera.max_look_expand = vec2(80, units + 220+add_expand*2)
end

function switch_to_gui(crosshair_pos)
	if crosshair_pos ~= nil then 
		menu.rendered_crosshair_entity.transform.current.pos = crosshair_pos 
		menu.crosshair_group.body.transform.current.pos = crosshair_pos	
		menu.crosshair_group.crosshair.transform.current.pos = crosshair_pos
	end
	
	menu.rendered_crosshair_entity = menu.crosshair_group.crosshair
	
	world_camera.chase:set_target(menu.crosshair_group.body)
	world_camera.camera.player:set(menu.crosshair_group.body)
	world_camera.camera.crosshair:set(menu.crosshair_group.crosshair)
	
	bigger_expand(0)
	
	input_system:clear_contexts()
	input_system:add_context(gui_context)
end

switch_to_gui()

menu.menu_button_archetype = { 
	bbox_callback = function(bbox, entry) 
		entry.text_pos.x = entry.text_pos.x - bbox.x/2 
	end,

	in_min_interval = 100, 
	in_max_interval = 120, 
	out_min_interval = 2000, 
	out_max_interval = 7000,
	text_size_mult = 0.5,
	callbacks = {},
	text_pos = vec2(0, 0),
	
	animated_text_input = {
		min_interval_ms = 100, 
		max_interval_ms = 120, 
		str = "new game", 
		font_table = { font1, font2, font3 }, 
		color = rgba(255, 255, 255, 255)
	}
}

function make_button(override)
	return text_button:create(archetyped(menu.menu_button_archetype, override))
end


dofile "sensibilia\\scripts\\menu_screens\\main_menu.lua"

dofile "sensibilia\\scripts\\menu_screens\\credits.lua"
dofile "sensibilia\\scripts\\menu_screens\\help.lua"
create_help_screen(menu.main_menu)
dofile "sensibilia\\scripts\\menu_screens\\load_chapter.lua"





