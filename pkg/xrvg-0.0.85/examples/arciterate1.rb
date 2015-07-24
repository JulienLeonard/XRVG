require 'xrvg'
include XRVG

render = SVGRender[:imagesize, "3cm" ]
style = Style[ :stroke, Color.blue, :strokewidth, 0.01 ]
arc = ArcBezier[ :support, [V2D::O, V2D::X] ]
samples = [0.1,0.3,0.4,0.6,0.7,0.9]
subarcs = arc.samples( samples ).foreach(2).map do |points|
  ArcBezier[ :support, points ]
end
render.add( arc, style )
subarcs.each {|arc| render.add( arc, style ) }
render.end
