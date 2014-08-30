require 'xrvg'
include XRVG

render = SVGRender[:imagesize,"3cm"]
style = Style[ :stroke, Color.blue( 0.3 ), :strokewidth, 0.01 ]
support1 = LinearBezier[ :support, [V2D::O, V2D::X] ]
support2 = support1.translate( V2D::Y )
interbezier  = InterBezier[ :bezierlist, [0.0, support1, 1.0, support2 ] ]

100.times do
  xs = (0.0..1.0).ssort().rand( 2 )
  render.add( interbezier.line( xs[0], xs[1], (0.0..1.0).rand ), style )
end
render.end
