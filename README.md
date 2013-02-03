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

