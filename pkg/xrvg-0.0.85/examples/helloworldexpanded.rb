require 'xrvg'
include XRVG

render = SVGRender.new( :filename, "helloworldexpanded.svg" )
render.add( Circle.new )
render.end
