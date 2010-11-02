class Applet
	def initialize(panel)
		@panel = panel
		@length = 100
	end

	attr_reader :panel
protected
	def length=(v)
		@length = v
		@panel.applet_resized if @panel
	end
public
	def length
		@length
	end

	def redraw
		panel.redraw_applet self
	end

	def mouse_down(x, y, button)
		nil
	end

	def mouse_up(x, y, button)
		nil
	end

	def mouse_motion(x, y, button)
	end

	def click(x, y, button)
		puts "clicked on me! #{self.class}"
	end

	def double_click(x, y, button)
	end

	def draw(cr, extrusion)
		r,g,b = rand, rand, rand

		cr.set_source_rgb(r, g, b)
		cr.rectangle(0, 0, 100, length)
		cr.fill
	end
end
