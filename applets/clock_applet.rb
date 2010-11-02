class ClockApplet < Applet
	def initialize(panel)
		super(panel)
		length = 150

		GLib::Timeout.add(500) { redraw; true }
	end

	def draw(cr, extrusion)
		#puts "drawing clock"
		t = Time.now
		hour = (t.hour > 12 ? t.hour - 12 : t.hour)
		ampm = (t.hour > 12 ? 'PM' : 'AM')
		text = "#{hour}:#{'%02d' % t.min}:#{'%02d' % t.sec} #{ampm}"
		date_text = t.strftime '%a %b %d'

		panel.apply_fg_color(cr)
		cr.select_font_face "Bitstream Vera Sans", Cairo::FONT_SLANT_NORMAL, Cairo::FONT_WEIGHT_NORMAL
		cr.set_font_size 22
		min_width = cr.text_extents(text).width + 15
		self.length = min_width unless length == min_width

		cr.move_to 0, 5
		cr.show_text_centered length, text

		cr.set_font_size 12
		cr.move_to 0, 25
		cr.show_text_centered length, date_text
	end
end
