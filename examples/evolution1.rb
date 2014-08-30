require 'xrvg'
include XRVG

render = SVGRender[:imagesize, "3cm" ]
line = LinearBezier.buildwithangle( Range.Angle.sample( 0.95 ) )
style = Style[ :stroke, Color.blue, :strokewidth, 0.01 ]
render.add( line, style )
render.end
