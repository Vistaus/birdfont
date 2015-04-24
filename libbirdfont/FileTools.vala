/*
    Copyright (C) 2015 Johan Mattsson

    This library is free software; you can redistribute it and/or modify 
    it under the terms of the GNU Lesser General Public License as 
    published by the Free Software Foundation; either version 3 of the 
    License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful, but 
    WITHOUT ANY WARRANTY; without even the implied warranty of 
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
    Lesser General Public License for more details.
*/

using Cairo;
using Math;

namespace BirdFont {

public class FileTools : ToolCollection  {
	public static Gee.ArrayList<Expander> expanders;

	public FileTools () {
		expanders = new Gee.ArrayList<Expander> ();

		Expander font_name = new Expander ();
		font_name.add_tool (new FontName ());

		Expander file_tools = new Expander ();
		
		Tool new_font = new Tool ("new_font", t_("New font"));
		new_font.select_action.connect ((self) => {
			MenuTab.new_file ();
		});	
		file_tools.add_tool (new_font);

		Tool open_font = new Tool ("open_font", t_("Open font"));
		open_font.select_action.connect ((self) => {
			MenuTab.load ();
		});	
		file_tools.add_tool (open_font);

		Tool save_font = new Tool ("save_font", t_("Save font"));
		save_font.select_action.connect ((self) => {
			MenuTab.save ();
		});	
		file_tools.add_tool (save_font);

		Tool settings = new Tool ("settings", t_("Settings"));
		settings.select_action.connect ((self) => {
			MenuTab.show_settings_tab ();
		});	
		file_tools.add_tool (settings);
		
		Expander themes = new Expander (t_("Themes"));

		foreach (string theme in Theme.themes) {			
			string label;
			LabelTool theme_label;
			
			label = ThemeTab.get_label_from_file_name (theme);
			
			theme_label = new LabelTool (label);
			theme_label.data = theme;
			
			theme_label.select_action.connect((self) => {
				TabBar tb;
				LabelTool s = (LabelTool) self;
				string theme_file = s.data;

				Preferences.set ("theme", theme_file);
				Theme.load_theme (theme_file);

				Toolbox.redraw_tool_box ();
				GlyphCanvas.redraw ();
				
				tb = MainWindow.get_tab_bar ();
				tb.redraw (0, 0, tb.width, tb.height);
			});
			
			themes.add_tool (theme_label);
		}
		
		expanders.add (font_name);					
		expanders.add (file_tools);
		expanders.add (themes);
	}

	public override Gee.ArrayList<string> get_displays () {
		Gee.ArrayList<string> d = new Gee.ArrayList<string> ();
		return d;
	}
	
	public override Gee.ArrayList<Expander> get_expanders () {
		return expanders;
	}
}

}
