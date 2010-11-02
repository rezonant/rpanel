require ::File.dirname(__FILE__) + '/../panel.rb'

describe Panel do
	before(:each) do
		@p = Panel.new
		Gtk.init
		100.times { Gtk.main_iteration_do false }
	end

	it "can be shown" do
		@p.show
	end

	it "can be hidden" do
		@p.hide
	end

	it "can have more than one instance" do
		p2 = Panel.new
		p2.show
	end

	it "can be asked to add an applet to itself" do
		@p.add_applet Applet.new @p
	end

	it "knows to complain when asked to add a non-applet to itself" do
		@p.add_applet "Not a good value"
	end

	it "can list its applets" do
		@p.add_applet Applet.new @p
		v = @p.applets
		v.should respond_to :each
		v.should respond_to :length
		v.should respond_to :[]
		v.length.should > 0
		v[0].should be_a_kind_of Applet
	end

	it "should be empty upon creation" do
		@p.applets.length.should == 0
	end

	it "and its subclasses can locate the applet under the mouse" do
		a = Applet.new @p
		p = @p
		@p.instance_eval do 
			p.add_applet a
			p.applet_under(5, 5).should == a 
		end
	end
end
