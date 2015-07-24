require 'xrvg'
include XRVG

def subcircles( circle, nsamples, radiusfactor )
  return circle.samples( nsamples )[1..-1].map do |point|
    Circle[:center, point, :radius, circle.radius * radiusfactor ]
  end
end

def circlerecurse( circles, niter, nsamples, radiusfactor )
  if niter == 0
    return circles
  else
    subcircles = []
    circles.each do |circle|
      subcircles += subcircles( circle, nsamples, radiusfactor )
    end
    return circlerecurse( subcircles, niter-1, nsamples, radiusfactor )
  end
end

render = SVGRender[:imagesize, "3cm" ]
style = Style[ :fill, Color.blue ]
circlerecurse( [Circle[]], 5, 6, 1.0/3.0 ).each do |circle|
  render.add( circle, style )
end
render.end
