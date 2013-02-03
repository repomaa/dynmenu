#!/usr/bin/env ruby
require 'yaml'
$subtle = true
$lines = 20
begin
    require 'subtle/subtlext'
rescue LoadError
    $subtle = false
end
require './root_menu'
require './command'
require './style'
require './editor'
require './history'
require './run_menu'

license = <<END_LICENSE
dynmenu - A dmenu wrapper written in Ruby
---
Copyright (C) 2013 Joakim Reinert

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/

END_LICENSE

usage = <<END_USAGE 
Usage:  dynmenu [options] file
    Options:        -h --help   : Show this help
                    -r          : Open the menu as read only and static
                    -l <number> : Show max <number> lines in the menu (default=20)
    File:                       : The menu file to be loaded and saved to.
                                  It will be created if not existing.
END_USAGE

puts license

if ARGV.length > 4 || ARGV.length < 1 || ARGV.include?("-h") || ARGV.include?("--help")
    puts usage
    exit
elsif ARGV.include? "-l"
    lines = ARGV[ARGV.index("-l") + 1]
    if lines.to_i.to_s != lines || lines.to_i < 1
        puts usage
        exit
    end
    $lines = lines
else
    lines_matcher = Regexp.new(/^-l(\d+)$/)
    ARGV.each do |arg|
        if arg.match lines_matcher 
            $lines = Regexp.last_match(1)
        end
    end
end

file = ARGV[ARGV.length - 1]
if File.exist? file
    menu = YAML::load File.read(file)
else
    menu = Root_Menu.new
end
$read_only = ARGV.include? "-r"
menu.execute
File.open(file, "w+") { |f| YAML::dump menu, f }
