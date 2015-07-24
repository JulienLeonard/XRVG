require 'xrvg'
include XRVG

render = SVGRender[:imagesize, "3cm" ]
line = LinearBezier.buildwithangle( Range.Angle.sample( 0.45 ) )
line = ArcBezier[ :support, [line.pointlist[0], line.pointlist[-1]], :height, 0.7 ]
style = Style[ :stroke, Color.blue, :strokewidth, 0.01 ]
render.add( line, style )
render.end
