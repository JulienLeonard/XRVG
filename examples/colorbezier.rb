require 'xrvg'
include XRVG

render = SVGRender[:imagesize, "20cm" ]
palette  = Palette[ :colorlist, [ 0.0, Color.blue,
                                  0.1, Color.grey(0.5),
                                  0.3, Color.grey(0.25),
                                  0.5, Color.grey(0.75),
                                  0.7, Color.grey(0.25),
                                  0.9, Color.grey(0.5),
                                  1.0, Color.yellow],
                    :interpoltype, :simplebezier]
style = Style[ :fill, Color.black ]
line = Line[ :points, [V2D::O, V2D::X] ]
SyncS[line, palette].samples( 100 ) do |point, color|
  style.fill = color
  render.add( Circle[:center, point, :radius, 0.01 ], style)
end

curves = []
palette.interpolators.each do |interpol|
  curves << interpol.getcurve
end

curves.each do |curve|
  render.add( curve, Style[ :stroke, Color.black, :strokewidth, 0.01 ] )
  curve.gdebug( render )
end


line = Line[ :points, [V2D::O, V2D::X] ].translate( V2D::Y * 0.1 )
palette.interpoltype = :linear
SyncS[line, palette].samples( 100 ) do |point, color|
  style.fill = color
  render.add( Circle[:center, point, :radius, 0.01 ], style)
end

render.end
