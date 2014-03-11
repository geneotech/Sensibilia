button_class = inherits_from {}

function button_class:constructor(pos, size, mousein_callback, mouseout_callback, click_callback)
	self.pos = pos
	self.size = size
	
	self.was_hovered = false
	
	self.mousein_callback = mousein_callback
	self.mouseout_callback = mouseout_callback
	self.click_callback = click_callback
end

function button_class:construct_xywh()
	return rect_xywh(self.pos.x - size.x/2, self.pos.y - size.y/2, self.pos.x + size.x/2, self.pos.y + size.y/2)
end

function button_class:check_mouse_events(message, crosshair_pos, mousemove_intent, mouseclick_intent)
	local is_hovering = self:construct_xywh():hover(message.mouse_pos)
	
	if message.intent == mousemove_intent then
		if is_hovering and not self.was_hovered then
			if self.mousein_callback ~= nil then self.mousein_callback() end
			self.was_hovered = true
		end
		
		if not is_hovering and self.was_hovered then
			if self.mouseout_callback ~= nil then self.mouseout_callback() end
			self.was_hovered = false
		end
	end
	
	if message.intent == mouseclick_intent then
		if is_hovering then
			if self.click_callback ~= nil then self.click_callback() end
		end
	end
end