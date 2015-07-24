require 'xrvg'
include XRVG

render = SVGRender[ :filename, "geodash.svg" ]
bezier = Bezier.raw( V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0] )
bezier.geo(2.0).splits( 30 ).foreach do |drawn,dum|
    render.add( drawn, Style[ :stroke, "blue", :strokewidth, 0.1 ] )
end
render.end
