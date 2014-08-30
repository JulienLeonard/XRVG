require 'xrvg'
include XRVG

render = SVGRender[ :filename, "bezierbasicvector.svg" ]
bezier = Bezier.vector( V2D[0.0, 1.0], V2D[1.0, 0.0], V2D[1.0, 0.0], V2D[-1.0, 0.0] )
render.add( bezier, Style[ :stroke, "blue", :strokewidth, 0.1 ] )
bezier.gdebug( render )
render.end
