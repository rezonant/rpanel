require ::File.dirname(__FILE__) + '/../panel.rb'

describe Applet do
	before(:all) do
		Gtk.init
	end

	before(:each) do
		@p = Panel.new
		@a = Applet.new @p
		@p.show
		100.times { Gtk.main_iteration_do false }
	end

	it "can be created" do
		nil
	end

	it "knows its length" do
		@a.should respond_to :length
		@a.length.should be_a_kind_of Numeric
	end

	it "allows subclasses to change length" do
		@a.should respond_to :length=
		@a.instance_eval "self.length = 50"
		@a.length.should == 50
	end

	it "responds to :draw" do
		@a.should respond_to :draw
	end

	it "can be asked to redraw itself" do
		@a.should respond_to :redraw
		@a.redraw
	end

	it "accepts mouse events" do
		@a.should respond_to :mouse_down
		@a.should respond_to :mouse_up
		@a.should respond_to :mouse_motion
		@a.should respond_to :click
		@a.should respond_to :double_click
	end
end
