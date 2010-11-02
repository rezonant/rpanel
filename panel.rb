require ::File.dirname(__FILE__) + '/gtk.rb'
require ::File.dirname(__FILE__) + '/cairo_context_extn.rb'
require ::File.dirname(__FILE__) + '/applet.rb'
require ::File.dirname(__FILE__) + '/applets/clock_applet.rb'
require ::File.dirname(__FILE__) + '/applets/launcher_applet.rb'
require ::File.dirname(__FILE__) + '/applets/session_applet.rb'
require ::File.dirname(__FILE__) + '/applets/window_applet.rb'

srand(Time.now.to_i)

class Panel < Gtk::Window
	def initialize
		super

		self.decorated = false
		self.keep_above = true
		self.skip_taskbar_hint = true
		self.skip_pager_hint = true
		self.stick

		#self.opacity = 0.7

		@fg_color = [1,1,1,1]
		@bg_color = [0,0,0,1]
		@screen_edge = :top
		@position = 100
		@length = 100
		@extrusion = 75
		@pull_off_threshold = 10

		@canvas = Gtk::DrawingArea.new
		@canvas.signal_connect('expose-event') { |s,e| self.expose(s,e) }
		add(@canvas)

		@applets = []
		self.add_events(Gdk::Event::BUTTON_MOTION_MASK | Gdk::Event::BUTTON_PRESS_MASK | Gdk::Event::BUTTON_RELEASE_MASK)
		self.signal_connect('button-press-event') { |s,e| self.button_press(s,e) }
		self.signal_connect('button-release-event') { |s,e| self.button_release(s,e) }
		self.signal_connect('motion-notify-event') { |s,e| self.mouse_motion(s,e) }
		self.signal_connect('key-press-event') do |s,e|
			modify_prompt if not e.nil? and e.keyval == Gdk::Keyval::GDK_0
		end
		show_all
		sync_pos

	end
	
	attr_reader :extrusion, :position, :screen_edge, :length

	def redraw_applet(appl)
		@redrawing = appl
		expose(nil, nil)
		@redrawing = nil
	end

	def apply_fg_color(cr)
		if @fg_color.respond_to? :call
			@fg_color.call(cr) 
		elsif @fg_color.respond_to? :[]
			@fg_color << 1 if @fg_color.length == 3
			cr.set_source_rgba *@fg_color
		end
	end

	def apply_bg_color(cr)
		if @bg_color.respond_to? :call
			@bg_color.call(cr) 
		elsif @bg_color.respond_to? :[]
			@bg_color << 1 if @bg_color.length == 3
			cr.set_source_rgba *@bg_color
		end
	end

	def modify_prompt
		d = Gtk::Dialog.new
		l = Gtk::Label.new "rpanel>"
		txt = Gtk::Entry.new
		restart = true
		good = false
		d.vbox.add(l)
		d.vbox.add(txt)
		d.add_button(Gtk::Stock::OK, 0)
		d.add_button(Gtk::Stock::CANCEL, 1)
		txt.signal_connect('activate') { |s,e2| good = true; d.close }
		d.show_all
		while restart
			restart = false
			id = d.run
			if id == 0 or good
				begin
					self.instance_eval txt.text
				rescue Exception => e2
					bt = []
					e2.backtrace.each do |t|
						bt << "  #{::File.expand_path(t)}"
					end
		
					md = Gtk::MessageDialog.new self, Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::ERROR, Gtk::MessageDialog::BUTTONS_OK,
						"A(n) #{e2.class} with message '#{e2.message}' occurred while evaluating:\n\n    #{txt.text}\n\nBacktrace:\n" + bt.join("\n")
					md.run
					md.destroy
					restart = true
				end
			end
		end
		d.destroy
	end

protected
	def expose(s,e)
		draw @canvas.window.create_cairo_context
	end	

	attr_accessor :bg_color, :fg_color

	def draw(cr)

		unless @redrawing
			apply_bg_color cr
			cr.paint
		end
		
		horz = [ :top, :bottom ].member? @screen_edge

		cr.save
		
		if @screen_edge == :left
			cr.translate(0, @length)
			cr.rotate -Math::PI / 2
		elsif @screen_edge == :right
			cr.translate(@extrusion, 0)
			cr.rotate Math::PI / 2
		end

		@applets.each do |appl|
			draw = true
			if @redrawing 
				draw = (appl == @redrawing)
			end

			if draw
				cr.save
					cr.rectangle(0, 0, appl.length, @extrusion)
					cr.clip
					if @redrawing
						apply_bg_color cr
						cr.paint
					end
					apply_fg_color(cr)
					appl.draw cr, @extrusion
				cr.restore
			end

			cr.translate(appl.length, 0)
		end
		cr.restore
	end

	def button_press(s,e)
		appl = applet_under e.x, e.y
		if appl
			if appl.mouse_down e.x, e.y, e.button
				# applet chose to grab the mouse
				@mouse_applet = appl
				return
			end
		end
		@button_down = true
		o = window.origin
		@start_point = [ o[0] + e.x, o[1] + e.y ]
		@start_pos = @position
		@moved = false
	end

	def mouse_motion(s,e)
		# TODO
		if @button_down
			@moved = true
			o = window.origin
			old_edge = @screen_edge
			pulling_off = false

			if [:top, :bottom].member? @screen_edge
				@position = @start_pos + (o[0] + e.x - @start_point[0])
				pulling_off = (@screen_edge == :top ? 
								o[1] + e.y > 0 + @extrusion + @pull_off_threshold : 
								o[1] + e.y < screen.height - @extrusion - @pull_off_threshold)

				if pulling_off 
 
					if @position <= 10
						self.screen_edge = :left
						puts "pulled off from #{old_edge} onto #{screen_edge}"
						self.position = (old_edge == :top ? 20 : max_pos - 20)
						@start_point = [ o[0] + e.x, o[1] + e.y ]
						@start_pos = @position
					elsif @position >= max_pos - 10
						self.screen_edge = :right
						puts "pulled off from #{old_edge} onto #{screen_edge}"
						self.position = (old_edge == :top ? 20 : max_pos - 20)
						@start_point = [ o[0] + e.x, o[1] + e.y ]
						@start_pos = @position
					end
				end
			else
				@position = @start_pos + (o[1] + e.y - @start_point[1])
				pulling_off = (@screen_edge == :left ? 
								o[0] + e.x > 0 + @extrusion + @pull_off_threshold : 
								o[0] + e.x < screen.width - @extrusion - @pull_off_threshold)
				if pulling_off
					if @position <= 10
						self.screen_edge = :top
						puts "pulled off from #{old_edge} onto #{screen_edge}"
						self.position = (old_edge == :left ? 0 : max_pos)
						@start_point = [ o[0] + e.x, o[1] + e.y ]
						@start_pos = @position
					elsif @position >= max_pos - 10
						self.screen_edge = :bottom
						puts "pulled off from #{old_edge} onto #{screen_edge}"
						self.position = (old_edge == :left ? 0 : max_pos)
						@start_point = [ o[0] + e.x, o[1] + e.y ]
						@start_pos = @position
					end
				end
			end

			pos_check_bounds
			sync_pos
		end
	end

	def pos_check_bounds
		@position = [[ @position, 0 ].max, max_pos].min 
	end

	def applet_under(x, y)
		return nil if y < 0 or y > @extrusion

		px = 0
		@applets.each do |a|
			return a if x >= px and x <= px + a.length
			px += a.length
		end
		nil
	end

	def button_release(s,e)
		if @button_down
			unless @moved
				appl = applet_under e.x, e.y
				appl.click e.x, e.y, e.button if appl
			end
			@button_down = nil
		end
	end

	def sync_pos
		if [ :top, :bottom ].member? @screen_edge
			if @screen_edge == :top
				x, y = position, 0
			else
				x, y = position, screen.height - extrusion
			end

			w, h = @length, @extrusion
		else

			if @screen_edge == :left
				x, y = 0, position
			else
				x, y = screen.width - extrusion, position
			end

			w, h = @extrusion, @length
		end

		move(x, y)
		resize(w, h)
	end


public
	attr_reader :applets

	def remove_applet(appl)
		@applets -= [ appl ]
		applet_resized
	end

	def add_applet(appl)
		@applets << appl
		applet_resized
	end

	def applet_resized
		len = 0
		@applets.each { |x| len += x.length }
		puts "relengthing to #{len}"
		self.length = len if len > 0
		window.invalidate(Gdk::Rectangle.new(0, 0, size[0], size[1]), false)
	end

	def max_pos
		if [:top, :bottom].member? @screen_edge
			screen.width - @length
		else
			screen.height - @length
		end
	end


	def position=(v)
		@position = v
		sync_pos
	end

	def length=(v)
		@length = v
		sync_pos
	end

	def screen_edge=(v)
		@screen_edge = v
		sync_pos
	end

	def extrusion=(v)
		@extrusion = v
		sync_pos
	end
end

