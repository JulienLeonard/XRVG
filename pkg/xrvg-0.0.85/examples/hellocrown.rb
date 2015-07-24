require 'xrvg'
include XRVG

render = SVGRender[ :filename, "hellocrown.svg" ]
Circle[].samples( 8 ) do |point|
  render.add( Circle[:center, point, :radius, 0.2 ], Style[ :fill, Color.blue ] )
end
render.end
