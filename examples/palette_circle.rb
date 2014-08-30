require 'xrvg'
include XRVG

render = SVGRender[ :filename, "palette_circle.svg", :background, "white" ]

palette  = Palette[ :colorlist, [  0.0, Color.black,  1.0 ,  Color.blue] ]
SyncS[Circle[], palette, (0.1..0.02).random()].samples(25) do |point, color, radius|
  render.add( Circle[ :center, point, :radius, radius ], Style[ :fill, color ])
end

render.end
