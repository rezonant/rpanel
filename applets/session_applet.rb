class SessionApplet < Applet
	@@user = nil
	def initialize(panel)
		super(panel)
		@@user = `whoami`.strip unless @@user
	end

	def draw(cr, extrusion)
		puts "drawin!"
		panel.apply_fg_color cr
		cr.select_font_face "Bitstream Vera Sans", Cairo::FONT_SLANT_NORMAL, Cairo::FONT_WEIGHT_NORMAL
		cr.set_font_size 18

		e = cr.text_extents @@user
		cr.move_to(0, 0)
		cr.show_text_box_centered(@length, extrusion, @@user)
	end
end


