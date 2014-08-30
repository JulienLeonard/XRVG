require 'xrvg'
include XRVG

render = SVGRender[:imagesize,"3cm"]

line        = LinearBezier[ :support, [V2D::O, V2D::X]]
support     = line.translate( -V2D::Y )
ondulation  = Ondulation[ :support, support, :freq, 5, :ampl, 0.5 ]

gbezier  = GradientBezier[ :bezierlist, [0.0, line, 1.0, ondulation]]

palette = Palette[ :colorlist, [  0.0, Color.black,  
                                  0.5, Color.blue,  
                                  1.0, Color.white]]
style = Style.new( :strokewidth, 0.01 )
SyncS[gbezier, palette].samples( 10 ) do |bezier, color|
  style.fill = color
  style.stroke = color
  render.add( bezier, style )
end
render.end
