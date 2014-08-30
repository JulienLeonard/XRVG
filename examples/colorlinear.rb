require 'xrvg'
include XRVG

render = SVGRender[:imagesize, "3cm" ]
palette  = Palette[ :colorlist, [ 0.0, Color.blue,   0.25,  Color.orange,  
                                  0.5, Color.yellow, 0.75,  Color.green,
                                  1.0, Color.blue],
                    :interpoltype, :linear]
style = Style[ :fill, Color.black ]
line = Line[ :points, [V2D::O, V2D::X] ]
SyncS[line, palette].samples( 100 ) do |point, color|
  style.fill = color
  render.add( Circle[:center, point, :radius, 0.01 ], style)
end

curves = []
palette.interpolators.each do |interpol|
  points = []
  interpol.samples( 100 ).each_with_index do |y, index|
    points << V2D[ index.to_f/100.0, y ]
  end
  curves << SimpleBezier[ :support, points  ]
end

curves.each do |curve|
  render.add( curve, Style[ :stroke, Color.black, :strokewidth, 0.01 ] )
end
render.end
