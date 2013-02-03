dynmenu
---
... is a wrapper for dmenu written in ruby with inbuilt functions for the [subtle wm](http://subforge.org/projects/subtle/wiki). It has advanced functions like web search, command completion, smart history and ad-hoc customization.

Usage
---
- clone the repo
- start with `dynmenu.rb <file>` with `<file>` being the menu file. If it doesn't exist, it will be created.

####Commands
- `g` or `s` for web search. Example: `g dynmenu github`
- `w` for webpage. Example: `w github.com` (you can also just enter the url, but it has to include the protocol)

####Subtle commands and modes
Same syntax as in subtles own launcher. See <http://subforge.org/projects/subtle-contrib/wiki/Launcher#Examples>

In dynmenu you can also add the mode character (`+^\*`) after the command. (Helps with command completion)

Check out `dynmenu.rb -h` for more info

License
---
Copyright (C) 2013 Joakim Reinert

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>
