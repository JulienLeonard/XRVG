require 'xrvg'
include XRVG

render = SVGRender[ :filename, "uplets.svg", :background, "white" ]
Circle[].samples(10).uplets do |p1,p2|
  render.add( Line[ :points, [p1,p2]], Style[ :stroke, "black", :strokewidth, 0.1 ] )
  render.add( Circle[:center, p1, :radius, 0.1], Style[ :fill, Color.red ] )
  render.add( Circle[:center, p2, :radius, 0.2], Style[ :fill, Color.blue ] )
end
render.end
