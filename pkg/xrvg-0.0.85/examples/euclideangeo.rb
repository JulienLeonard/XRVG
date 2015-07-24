require 'xrvg'
include XRVG

render = SVGRender[:imagesize,"3cm"]
style = Style[ :stroke, Color.blue( 0.3 ), :strokewidth, 0.01 ]
100.times do
  xs = (0.0..1.0).ssort().rand( 2 )
  y  = (0.0..1.0).rand
  render.add( Line[ :points, xs.map {|x| V2D[x, y]} ], style )
end
render.end
