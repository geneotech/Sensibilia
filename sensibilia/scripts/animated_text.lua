animated_text = inherits_from {}

function animated_text:constructor(initial_table)
	self.main_timer = timer()
	
	if initial_table ~= nil then
		self:set(initial_table)
	end
end

function animated_text:set(entry)
	self.color = entry.color
	self.str = entry.str
	self.wstr = towchar_vec(entry.str)
	self.font_table = entry.font_table
	self.change_interval_ms = entry.change_interval_ms
	
	self.min_interval_ms = entry.min_interval_ms
	self.max_interval_ms = entry.max_interval_ms
	
	self.characters = {}
	
	for i=1, self.wstr:size() do
		table.insert(self.characters, {})
		self:reset_character(i)
	end
end

function animated_text:randomize_duration(i)
	self.characters[i].duration = randval(self.min_interval_ms, self.max_interval_ms)
end

function animated_text:refresh_characters()
	for i=1, #self.characters do
		self:randomize_duration(i)
	end
end

function animated_text:reset_character(i)
	self:randomize_duration(i)
	self.characters[i].change_timer = timer()
	self.characters[i].iteration = 1
	self.characters[i].font_table = {}
	
	for f=1, #self.font_table do
		table.insert(self.characters[i].font_table, self.font_table[f])
	end
	
	table.shuffle(self.characters[i].font_table)
end

function animated_text:get_formatted_text()
	for i=1, #self.characters do
		if self.characters[i].change_timer:get_milliseconds() > self.characters[i].duration then
			self.characters[i].iteration = self.characters[i].iteration + 1
			self:randomize_duration(i)
			
			if self.characters[i].iteration == #self.font_table then
				self:reset_character(i)
			end
		end
	end

	local my_formatted_text = formatted_text() --{ { str = self.str, col = self.color, font = self.font_table[1] }}
	
	for i=1, #self.characters do
		my_formatted_text:add(create(formatted_char, {
			r = self.color.r, g = self.color.g, b = self.color.b, a = self.color.a,
			c = self.wstr:at(i-1), font_used = self.characters[i].font_table[self.characters[i].iteration]
		}))
	end
	
	return my_formatted_text
end