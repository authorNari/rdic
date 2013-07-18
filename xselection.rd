=begin
= Xselection


The Xselection class implement get String from X selection.

== Class Methods

new(display)
  - Xselection.new(ENV["DISPLAY"])
      normal return is nil
      raise if illegal display

== Methods

get()
  - get()
      return String if X selection has string
      return nil if X selection is null

check()
  - check()
      return String if X selection is changed
      return nil if X selection not changed or Xsellection is null

close()
  - close()
      close display

== Sample

  require 'xselection'
  require 'xselection'
  require 'jcode'
  $KCODE = "e"
  
  raise "DISPLAY is not available." unless ENV["DISPLAY"]
  begin
    x = Xselection.new(ENV["DISPLAY"])
    loop do 
      str = x.check()
      p str if str
      sleep(0.3)
    end
  ensure
    x.close()
  end

== Nihongo

  - check $LANG is ja_JP.eucJP
  - set $KCODE=e or ruby -Ke option

=end
