require 'xrvg'
include XRVG

render = SVGRender[:imagesize, "3cm" ]
style = Style[ :fill, Color.blue ]
Circle[].samples( 6 ) do |point|
  render.add( Circle[:center, point, :radius, 0.333 ], style)
end
render.end
