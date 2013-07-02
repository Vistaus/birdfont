#!/usr/bin/python
"""
Copyright (C) 2012, 2013 Eduardo Naufel Schettino and Johan Mattsson

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
"""
import version
import time;

VERSION = version.VERSION

def write_config (prefix):
	print ("Writing Config.vala")

	vars = (('VERSION', VERSION),
		('BUILD_TIMESTAMP', time.asctime( time.localtime(time.time()))),
		('PREFIX', prefix),
		)

	f = open('./libbirdfont/Config.vala', 'w+')
	f.write("// Don't edit this file -- it is generated by the build script\n")
	f.write("namespace BirdFont {\n")

	var_line = '	internal static const string %s = "%s";\n'
	for name, value in vars:
		f.write(var_line % (name, value))

	f.write("}")

def write_compile_parameters (prefix, dest, cc):
	f = open('./scripts/config.py', 'w+')
	f.write("#!/usr/bin/python\n")
	f.write("PREFIX =  \"" + prefix + "\"\n")
	f.write("DEST = \"" + dest + "\"\n")
	f.write("CC = \"" + cc + "\"\n")
