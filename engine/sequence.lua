timed_sequence = inherits_from {}

function timed_sequence:constructor()
	self.actions = {}
	self.current_action = nil
	self.current_timer = stepped_timer(physics_system)
	self.loop = false
end

function timed_sequence:add_action(action_entry)
	table.insert(self.actions, action_entry)
end

function timed_sequence:should_loop(flag)
	self.loop = flag
end

function timed_sequence:now_action()
	return self.actions[self.current_action]
end

function timed_sequence:set_current_action(number)
	self.current_action = number
	self.current_timer:reset()
	
	if self:now_action().duration_ms ~= nil then
		self:now_action().current_duration_ms = self:now_action().duration_ms
	else
		self:now_action().current_duration_ms = randval(self:now_action().min_duration_ms, self:now_action().max_duration_ms)
	end
end

function timed_sequence:start()
	self:set_current_action(1)
end

-- if the sequence should not be looped, this function returns false when the sequence ends
function timed_sequence:play()
	-- check if the action number is valid
	if self.current_action == nil or self.current_action > #self.actions then
		self:start()
	end
	
	if self.current_timer:get_milliseconds() <= self:now_action().current_duration_ms then
		self:now_action().callback()
	else
		self.current_action = self.current_action + 1
		
		if self.current_action > #self.actions then
			if self.loop then
				self:start()
			else
				return false
			end
		else
			self:set_current_action(self.current_action)
		end
	end
	
	return true
end