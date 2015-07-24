require 'xrvg'
include XRVG

def subarcs( arc, samples )
  return arc.samples( samples ).foreach(2).map do |points|
    ArcBezier[:support, points ]
  end
end

def arcrecurse( arcs, niter, samples )
  if niter == 0
    return arcs
  else
    subarcs = []
    arcs.each do |arc|
      subarcs += subarcs( arc, samples )
    end
    return arcrecurse( subarcs, niter-1, samples )
  end
end

render = SVGRender[:imagesize, "3cm" ]
style = Style[ :stroke, Color.blue, :strokewidth, 0.01 ]
samples = [0.1,0.3,0.4,0.6,0.7,0.9]
roots   = [ArcBezier[ :support, [V2D::O, V2D::X]]]
arcrecurse( roots, 4, samples ).each do |arc|
  render.add( arc, style )
end
render.end

