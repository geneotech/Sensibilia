animated_text = inherits_from {}

function animated_text:constructor()
	self.main_timer = timer()
end

function animated_text:set(str, font_table, color, change_interval_ms)
	self.color = color
	self.str = str
	self.wstr = towchar_vec(str)
	self.font_table = font_table
	self.change_interval_ms = change_interval_ms
	
	self.character_font_tables = {}
	
	for i=1, self.wstr:size() do
		table.insert(self.character_font_tables, {})
		for f=1, #font_table do
			table.insert(self.character_font_tables[i], font_table[f])
		end
	end
	
	self:shuffle_tables()
end

function animated_text:shuffle_tables()
	for i=1, #self.character_font_tables do
		table.shuffle(self.character_font_tables[i])
	end
	
	self.current_iteration = 1
end


function animated_text:get_formatted_text()
	if self.main_timer:get_milliseconds() > self.change_interval_ms then
		self.current_iteration = self.current_iteration + 1
		
		if self.current_iteration == #self.font_table then
			self:shuffle_tables()
		end
		
		self.main_timer:reset()
	end
	
	local my_formatted_text = formatted_text() --{ { str = self.str, col = self.color, font = self.font_table[1] }}
	
	for i=1, #self.character_font_tables do
		my_formatted_text:add(create(formatted_char, {
			r = self.color.r, g = self.color.g, b = self.color.b, a = self.color.a,
			c = self.wstr:at(i-1), font_used = self.character_font_tables[i][self.current_iteration]
		}))
	end
	
	
	return my_formatted_text
end