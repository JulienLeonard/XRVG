require 'xrvg'
include XRVG

render = SVGRender[ :filename, "randomdash.svg" ]
bezier = Bezier.raw( V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0] )
[bezier.ssort.random.splits( 30 ), (0.1..0.0).rand(30)].forzip do |drawn,width,dum,dum|
    render.add( drawn, Style[ :stroke, "blue", :strokewidth, width ] )
end
render.end
