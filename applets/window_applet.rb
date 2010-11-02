
class WindowApplet < Applet
	def initialize (panel)
		super(panel)
	end

	def draw(cr, extrusion)
		Gdk::Window.toplevels.each { |x| puts x }
	end
end
