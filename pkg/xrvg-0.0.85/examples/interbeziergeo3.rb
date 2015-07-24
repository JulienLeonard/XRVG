require 'xrvg'
include XRVG

render = SVGRender[:imagesize,"3cm"]
style = Style[ :stroke, Color.blue( 0.3 ), :strokewidth, 0.01 ]
support  = LinearBezier[ :support, [V2D::O, V2D::X] ]
support  = Ondulation[ :support, support, :freq, 2, :ampl, 0.3 ]
support1 = Offset[ :support, support, :ampl,  0.2 ]
support2 = Offset[ :support, support, :ampl, -0.2 ]

interbezier  = InterBezier[ :bezierlist, [0.0, support1, 1.0, support2 ] ]

100.times do
  xs = (0.0..1.0).ssort().rand( 2 )
  render.add( interbezier.line( xs[0], xs[1], (0.0..1.0).rand ), style )
end
render.end
