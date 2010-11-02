#!/usr/bin/ruby

require ::File.dirname(__FILE__) + '/panel.rb'

panel = Panel.new
panel.extrusion = 40
panel.length = 100

panel.add_applet SessionApplet.new(panel)
panel.add_applet ClockApplet.new(panel)
panel.add_applet LauncherApplet.new(panel, "/usr/share/icons/gnome/48x48/stock/generic/stock_notes.png", "Notes", "tomboy")
panel.add_applet LauncherApplet.new(panel, "/usr/share/pixmaps/firefox.png", "Firefox", "firefox")
panel.add_applet LauncherApplet.new(panel, "/usr/share/icons/hicolor/48x48/apps/chromium-browser.png", "Chromium", "chromium-browser")

panel.show

Gtk.main
