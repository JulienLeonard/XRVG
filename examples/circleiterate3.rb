require 'xrvg'
include XRVG

render = SVGRender[:imagesize, "3cm" ]
style = Style[ :fill, Color.blue ]
Circle[].samples( 6 ) do |point|
  Circle[:center, point, :radius, 0.3333 ].samples( 6 ) do |point|
    Circle[:center, point, :radius, 0.1111 ].samples( 6 ) do |point|
      render.add( Circle[:center, point, :radius, 0.037 ], style )
    end
  end
end
render.end
