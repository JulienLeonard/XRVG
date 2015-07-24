require 'xrvg'
include XRVG

render = SVGRender[:imagesize, "3cm" ]
line = LinearBezier.buildwithangle( Range.Angle.sample( 0.45 ) )
line = ArcBezier[ :support, [line.pointlist[0], line.pointlist[-1]], :height, 0.7 ]
pics = line.reverse.geofull(1.2).samples( 20 ).foreach(2).map {|points| PicBezier[:support, points, :height, -3.0]}
style = Style[ :stroke, Color.blue, :strokewidth, 0.01 ]
pics.each {|pic| render.add( pic, style )}
render.end
