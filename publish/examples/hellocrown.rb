require 'xrvg'

render = SVGRender[ :filename, "hellocrown.svg" ]
Circle[].samples( 8 ) do |point|
  render.add( Circle[:center, point, :radius, 0.2 ], Style[ :fill, Color.black ] )
end
render.end
