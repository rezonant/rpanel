class LauncherApplet < Applet
	def initialize(panel, iconFile, name, cmd)
		super(panel)
		@iconFile = iconFile
		@name = name
		@icon = Cairo::ImageSurface.from_png iconFile
		@command = cmd
	end

	attr_reader :iconFile, :name, :icon, :command

	def click(x, y, button)
		puts "clicked launcher... button: #{button}"
		fork { system @command }
	end

	def draw(cr, extrusion)
#		super(cr, extrusion)			# colored bgs for debugging
		if @icon.height > extrusion
			scale = extrusion / (@icon.height + 0.0)
			iw = scale * @icon.width
			self.length = iw + 2 if self.length != iw + 2
			x,y = (length - iw) / 2, 0
					
			cr.save
				cr.scale scale, scale
				cr.set_source(@icon, x, y)
				cr.rectangle(x, y, @icon.width, @icon.height)
				cr.fill
			cr.restore
		else
			self.length = @icon.width + 2 if self.length != @icon.width + 2
			x,y = (length - @icon.width) / 2, (extrusion - @icon.height) / 2
						
			cr.set_source(@icon, x, y)
			cr.rectangle(x, y, @icon.width, @icon.height)
			cr.fill
		end
	end
end


