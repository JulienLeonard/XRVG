require 'xrvg'
include XRVG

render = SVGRender[ :filename, "geodash2.svg" ]
bezier = Bezier.raw( V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0] )
[bezier.geo(2.0).splits( 30 ), (0.1..0.0).samples(30)].forzip do |drawn,width,dum,dum|
    render.add( drawn, Style[ :stroke, "blue", :strokewidth, width ] )
end
render.end
