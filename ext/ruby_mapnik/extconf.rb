=begin 
Copyright (C) 2011 Elliot Laster

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the ‘Software’), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
=end

# Compile with Rice rather than straight mkmf
require 'rubygems'
require 'mkmf-rice'

# Add the arguments to the linker flags.
def append_ld_flags(flags) 
  flags = [flags] unless flags.is_a?(Array)
  with_ldflags("#{$LDFLAGS} #{flags.join(' ')}") { true }
end

# Check for mapnik-config
if %x{which mapnik-config}.length == 0
  abort("\n***\n mapnik-config is missing!\n Is mapnik2 installed?\n Is mapnik-config in your $PATH?\n***\n\n")
end

LIBDIR = Config::CONFIG['libdir']
INCLUDEDIR = Config::CONFIG['includedir'] 

$LDFLAGS += " -lmapnik2 "
$CFLAGS += %x{mapnik-config --cflags}

#------------------------------------------------------------------------------#
# Ruby-Mapnik configuration
# 
# Creates a ruby file with the constants for the input and font paths.
#------------------------------------------------------------------------------#
input_plugin_path = %x{mapnik-config --input-plugins}.chomp
font_path = %x{mapnik-config --fonts}.chomp
ruby_mapnik_config = <<-EOF
# This file is generated by extconf.rb DO NOT MODIFY!
module Mapnik
  INPUT_PLUGIN_PATH = '#{input_plugin_path}'
  FONT_PATH = '#{font_path}'
end
EOF

mapnik_config_file_path = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', 'lib', 'ruby_mapnik_config.rb')
FileUtils.rm(mapnik_config_file_path) if File.exists?(mapnik_config_file_path)
File.open(mapnik_config_file_path, 'w+') do |file|  
  file.write(ruby_mapnik_config)
end


if RUBY_PLATFORM =~ /darwin/
    # In order to link the shared library into our bundle with GCC 4.x on OSX, we have to work around a bug:
    #   GCC redefines symbols - which the -fno-common prohibits.  In order to keep the -fno-common, we
    #   remove the flat_namespace (we now have two namespaces, which fixes the GCC clash).  Also, we now lookup
    #   symbols in both the namespaces (dynamic_lookup).
    
    $LDSHARED_CXX.gsub!('suppress', 'dynamic_lookup')
    $LDSHARED_CXX.gsub!('-flat_namespace', '')
    
    append_ld_flags '-all_load'
end

create_makefile("ruby_mapnik")
