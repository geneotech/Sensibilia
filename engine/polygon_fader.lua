polygon_fader = inherits_from {}

function polygon_fader:constructor()
	self.trace_timer = timer()
	
	self.traces = {}
end

function polygon_fader:generate_triangles(camera_transform, output_buffer, visible_area)
	local my_draw_input = draw_input()
	my_draw_input.camera_transform = camera_transform
	my_draw_input.output = output_buffer
	my_draw_input.visible_area = rect_ltrb(visible_area)
		
	for k, v in ipairs(self.traces) do	
		v.poly:draw(my_draw_input)
	end
end

function polygon_fader:add_trace(my_poly, my_animator)
	table.insert(self.traces, {
		poly = my_poly,
		alpha_animator = my_animator
	})
end

function polygon_fader:loop()
	local i = 1
	while i <= #self.traces do
		
		local final_alpha = self.traces[i].alpha_animator:get_animated()
		
		if final_alpha <= 0 then
			table.remove(self.traces, i)
		else
			for j = 1, self.traces[i].poly:get_vertex_count() do
				self.traces[i].poly:get_vertex(j-1).color.a = final_alpha
			end
			
			i = i + 1
		end
	end
end