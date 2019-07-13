/*
	Copyright (C) 2012 Johan Mattsson

	This library is free software; you can redistribute it and/or modify 
	it under the terms of the GNU Lesser General Public License as 
	published by the Free Software Foundation; either version 3 of the 
	License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful, but 
	WITHOUT ANY WARRANTY; without even the implied warranty of 
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
	Lesser General Public License for more details.
*/

namespace BirdFont {

using Gee;

public class Preferences {
		
	static Gee.HashMap<string, string> data;
	public static bool draw_boundaries = false;

	public Preferences () {
		data = new Gee.HashMap<string, string> ();
	}

	public static void set_last_file (string fn) {
		set ("last_file", fn);
	}

	public static string @get (string k) {
		string? s;

		if (is_null (data)) {
			data = new Gee.HashMap<string, string> ();
		}
		
		s = data.get (k);
		
		return (s != null) ? (!) s : "";
	}

	public static void @set (string k, string v) {
		if (is_null (data)) {
			data = new Gee.HashMap<string, string> ();
		}
		
		data.set (k, v);
		save ();
	}

	public static string[] get_recent_files () {
		string recent = get ("recent_files");
		string[] files = recent.split ("\t");
		
		for (uint i = 0; i < files.length; i++) {
			files[i] = files[i].replace ("\\t", "\t");
		}
		
		return files;
	}
	
	public static File get_backup_directory () {
		File config_directory = BirdFont.get_settings_directory ();
		File backup_directory = get_child (config_directory, "backup");
		
		if (!backup_directory.query_exists ()) {
			int error = DirUtils.create ((!) backup_directory.get_path (), 0766);
			
			if (error == -1) {
				warning (@"Failed to create backup directory: $((!) backup_directory.get_path ())\n");
			}
		}
		
		return backup_directory;
	}
	
	public static File get_backup_directory_for_font (string bf_file_name) {
		if (bf_file_name == "") {
			warning ("no filename.");
		}
		
		if (bf_file_name.index_of ("/") > -1) {
			warning ("Expecting a file and not a folder got: " + bf_file_name);
		}
		
		File backup_directory = get_backup_directory ();
		string subdir_name = bf_file_name;
			
		if (subdir_name.has_suffix (".bf")) {
			subdir_name = subdir_name.substring (0, subdir_name.length - ".bf".length);
		}
		
		if (subdir_name.has_suffix (".birdfont")) {
			subdir_name = subdir_name.substring (0, subdir_name.length - ".birdfont".length);
		}
		
		subdir_name += ".backup";
				
		File backup_subdir = get_child (backup_directory, subdir_name);
		
		if (!backup_subdir.query_exists ()) {
			int error = DirUtils.create ((!) backup_subdir.get_path (), 0766);
			
			if (error == -1) {
				warning (@"Failed to create backup directory: $((!) backup_subdir.get_path ())\n");
			}
		}

		return backup_subdir;
	}

	public static void add_recent_files (string file) {
		string escaped_string = file.replace ("\t", "\\t");
		StringBuilder recent = new StringBuilder ();

		foreach (string f in get_recent_files ()) {
			if (f != file) {
				recent.append (f.replace ("\t", "\\t"));
				recent.append ("\t");
			}
		}

		recent.append (escaped_string);

		set ("recent_files", @"$(recent.str)");
	}

	public static void set_window_size (int x, int y, int width, int height) {
		set ("window_x", @"$x");
		set ("window_y", @"$y");
		set ("window_width", @"$width");
		set ("window_height", @"$height");
	}

	public static int get_window_x () {
		string wp = get ("window_x");
		int x = int.parse (wp);
		return x;
	}

	public static int get_window_y () {
		string wp = get ("window_y");
		int y = int.parse (wp);
		return y;
	}
	
	public static int get_window_width() {
		string wp = get ("window_width");
		int w = int.parse (wp);
		return (w == 0) ? 860 : w;
	}

	public static int get_window_height() {
		int h = int.parse (get ("window_height"));
		return (h == 0) ? 500 : h;
	}
	
	public static void load () {
		File config_dir;
		File settings;
		FileStream? settings_file;
		unowned FileStream b;
		string? l;
		
		config_dir = BirdFont.get_settings_directory ();
		settings = get_child (config_dir, "settings");

		data = new HashMap<string, string> ();

		if (!settings.query_exists ()) {
			return;
		}

		settings_file = FileStream.open ((!) settings.get_path (), "r");
		
		if (settings_file == null) {
			stderr.printf ("Failed to load settings from file %s.\n", (!) settings.get_path ());
			return;
		}
		
		b = (!) settings_file;
		l = b.read_line ();
		while ((l = b.read_line ())!= null) {
			string line;
			
			line = (!) l;
			
			if (line.get_char (0) == '#') {
				continue;
			}
			
			int i = 0;
			int s = 0;
			
			i = line.index_of_char(' ', s);
			string key = line.substring (s, i - s);

			s = i + 1;
			i = line.index_of_char('"', s);
			s = i + 1;
			i = line.index_of_char('"', s);
			string val = line.substring (s, i - s);
			
			data.set (key, val);
		}
	}
	
	public static void save () {
		try {
			File config_dir = BirdFont.get_settings_directory ();
			File settings = get_child (config_dir, "settings");

			return_if_fail (config_dir.query_exists ());
		
			if (settings.query_exists ()) {
				settings.delete ();
			}

			DataOutputStream os = new DataOutputStream(settings.create(FileCreateFlags.REPLACE_DESTINATION));
			uint8[] d;
			long written = 0;
			
			StringBuilder sb = new StringBuilder ();
			
			sb.append ("# BirdFont settings\n");
			sb.append ("# Version: 1.0\n");
			
			foreach (var k in data.keys) {
				sb.append (k);
				sb.append (" \"");
				sb.append (data.get (k));
				sb.append ("\"\n");
			}
			
			d = sb.str.data;
				
			while (written < d.length) { 
				written += os.write (d[written:d.length]);
			}
		} catch (Error e) {
			stderr.printf ("Can not save key settings. (%s)", e.message);	
		}	
	}
}

}
