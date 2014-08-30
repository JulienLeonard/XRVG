require 'xrvg'

render = SVGRender[ :filename, "palette_circle.svg", :background, "white" ]

palette  = Palette[ :colorlist, [ Color.black, 0.0, Color.blue, 1.0 ] ]
[Circle[], palette, (0.1..0.02).random()].samples(25) do |point, color, radius|
  render.add( Circle[ :center, point, :radius, radius ], Style[ :fill, color ])
end

render.end
