class Cairo::Context
	def show_text_centered(width, text)
		e = text_extents(text)
		self.rel_move_to((width - e.width) / 2, e.height)
		show_text text
	end

	def show_text_box_centered(width, height, text)
		e = self.text_extents(text)
		self.rel_move_to((width - e.width) / 2, e.height + (height - e.height) / 2)
		show_text text
	end
end
