text_button = inherits_from {}

function text_button:constructor(entry)
	if entry ~= nil then self:set(entry) end
end

-- entry.text_pos specifies the left-top corner of the text
function text_button:set(entry)
	self.text = animated_text:create(entry.animated_text_input)
	self.text.min_interval_ms = entry.out_min_interval
	self.text.max_interval_ms = entry.out_max_interval
	
	-- sample formatted text to position the event button
	local my_fstr = self.text:get_formatted_text()
	local bbox_i = get_text_bbox(my_fstr, 0)
	local bbox_vec = vec2(bbox_i.x, bbox_i.y) * entry.text_size_mult
	
	-- user may want to change the position after bbox is calculated
	if entry.bbox_callback ~= nil then entry.bbox_callback(bbox_vec, entry) end
	
	self.event_handler = button_class:create()
	self.text_size_mult = entry.text_size_mult
	
	self.my_callbacks = entry.callbacks
	self.text_pos = entry.text_pos
	
	self.translation = vec2(0, 0)
	
	--self.event_handler:set_from_xywh(rect_xywh(text_pos.x, text_pos.y, bbox_vec.x, bbox_vec.y), callbacks)
	self.event_handler:set(entry.text_pos, bbox_vec, 
	{
		mousein = function()
			self.text.min_interval_ms = entry.in_min_interval
			self.text.max_interval_ms = entry.in_max_interval
			self.text:refresh_characters()
			if self.my_callbacks.mousein ~= nil then self.my_callbacks.mousein() end
		end,
		
		mouseout = function()
			self.text.min_interval_ms = entry.out_min_interval
			self.text.max_interval_ms = entry.out_max_interval
			self.text:refresh_characters()
			if self.my_callbacks.mouseout ~= nil then self.my_callbacks.mouseout() end
		end,
		
		mouseclick = function()
			self.text.min_interval_ms = entry.out_min_interval
			self.text.max_interval_ms = entry.out_max_interval
			self.text:refresh_characters()
			if self.my_callbacks.mouseclick ~= nil then self.my_callbacks.mouseclick() end
		end
	})
end

function text_button:handle_events(message, crosshair_pos)
	self.event_handler:check_mouse_events(message, crosshair_pos - self.translation, intent_message.AIM, custom_intents.GUI_MOUSECLICK)
end

function text_button:draw(my_draw_input)
	local myfstr = self.text:get_formatted_text()
	
	local input_copy = draw_input(my_draw_input)
	input_copy.transform.pos = self.text_pos + self.translation
	
	quick_print_text(input_copy, myfstr, vec2_i(0, 0), self.text_size_mult, 0)	
end