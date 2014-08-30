require 'xrvg'
include XRVG

render = SVGRender[:imagesize,"3cm"]
style  = Style[ :stroke, Color.blue( 0.3 ), :strokewidth, 0.01 ]
support = LinearBezier[ :support, [V2D::O, V2D::X] ]
support = Ondulation[ :support, support, :freq, 2, :ampl, 0.5 ]
fuseauvariety = FuseauVariety[ :support, support, :ampl, 0.2 ]

100.times do
  xs = (0.0..1.0).ssort().rand( 2 )
  y  = (0.0..1.0).rand
  render.add( fuseauvariety.line( xs[0], xs[1], y), style )
end
render.end

