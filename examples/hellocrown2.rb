require 'xrvg'
include XRVG

render = SVGRender[ :filename, "hellocrown2.svg" ]
SyncS[Circle[], (0.2..0.1)].samples( 10 ) do |point, radius|
  render.add( Circle[:center, point, :radius, radius ], Style[ :fill, Color.blue( 0.5 ) ] )
end
render.end
