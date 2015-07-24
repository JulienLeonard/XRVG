require 'xrvg'
include XRVG

render = SVGRender[ :filename, "hellocrownrecurse.svg" ]
Circle[].samples( 8 ) do |point|
  Circle[:center, point, :radius, 0.2 ].samples( 8 ) do |point|
    render.add( Circle[:center, point, :radius, 0.05 ], Style[ :fill, Color.blue ] )
  end
end
render.end
