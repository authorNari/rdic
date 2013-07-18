require "mkmf"
if find_library("X11","XOpenDisplay","/usr/X11R6/lib")
  create_makefile "xselection"
end
