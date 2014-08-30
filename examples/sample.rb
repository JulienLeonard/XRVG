require 'xrvg'
include XRVG

render = SVGRender[ :filename, "sample.svg" ]

palette  = Palette[ :colorlist, [ 0.0, Color.blue,   0.25,  Color.orange,  
                                  0.5, Color.yellow, 0.75,  Color.green,
                                  1.0, Color.blue] ]
SyncS[Circle[], palette, (0.1..0.02).random()].samples(25) do |point, color, radius|
  render.add( Circle[ :center, point, :radius, radius ], Style[ :fill, color ])
end

render.end
