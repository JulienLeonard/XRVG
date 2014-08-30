# See 
# - BezierMotif
# - PicBezier
# - ArcBezier
# - LinearBezier

require 'bezierbuilders'

module XRVG

# = BezierMotif class
# == Content
# Abstract class to define prototype of a motif bezier factory
# Motif is localized by the :support attribute
# == Attributes
#  attribute :support
class BezierMotif < BezierBuilder
  include Attributable
  attribute :support

  def BezierMotif.build( *args )
    builder = self.new( *args )
    result = []
    builder.support.pairs do |p1,p2|
      builder.support = [p1,p2]
      result << Bezier.multi( builder.compute )
    end
    return result.sum
  end

end



# = PicBezier class
# == Content
# Build a curved "pic" bezier whose base is specified by two points, and whose shape is controlled by two attributes, :height and :curvature.
# :height parameter is a factor of base length
# == Attributes
#   attribute :height,    1.0
#   attribute :curvature, 1.0
# == Example
#  pic = PicBezier[ :support, [V2D::O, V2D::X], :height, 1.0, :curvature, 2.0 ]
class PicBezier < BezierMotif
  attribute :height,    1.0
  attribute :curvature, 1.0

  # BezierBuilder compute overloading.
  #
  # See code for algorithm
  def compute
    p1, p2 = self.support
    onethird = (1.0 / 3.0)
    p1top2  = p2 - p1
    pp1     =  p1 + p1top2.ortho.*(@height)
    pp2     = pp1 + ( p1top2 * @curvature )

    p1topp2 = pp2 - p1
    pc1     = p1 + ( p1topp2 * onethird )
    pc2     = p2 + ( p1topp2 * onethird )

    p3      = p1 + ( p1top2 * @curvature )
    p4      = p1 + ( p1top2 * ( @curvature + 1.0 ) )
    
    pp1top2 = p3 - pp1
    pp1top3 = p4 - pp1

    pp1c1 = pp1 + ( pp1top2 * onethird )
    pp1c2 = pp1 + ( pp1top3 * onethird )
    
    return [[:raw, p1, pc1, pp1c1, pp1], [:raw, pp1, pp1c2, pc2, p2]]
  end
end

# = ArcBezier class
# == Content
# Build an "arc" bezier whose base is specified by two points, and whose shape is controlled by a :height attribute.
# :height parameter is a factor of base length
# == Attributes
#   attribute :height,    1.0
# == Example
#  arc = ArcBezier[ :support, [V2D::O, V2D::X], :height, 1.0 ]
class ArcBezier < BezierMotif
  attribute :height,    1.0

  # BezierBuilder compute overloading.
  #
  # See code for algorithm  
  def compute
    p1, p2 = self.support
    v = (p2 - p1).ortho * @height
    return [[:vector, p1, v, p2, v]]
  end
end

# = LinearBezier class
# == Content
# Build an line bezier whose base is specified by two points.
# == Attributes
# None, apart from :support
# == Example
#  line = LinearBezier[ :support, [V2D::O, V2D::X] ]
class LinearBezier < BezierMotif
  attribute :support, [V2D::O, V2D::X]

  # BezierBuilder compute overloading.
  #
  # See code for algorithm
  def compute
    p1, p2 = self.support
    return [[:vector, p1, (p2-p1) * 1.0 / 3.0,  p2, (p1 - p2) * 1.0 / 3.0]]
  end

  # Utilitary method to build a unit bezier line with angle
  def LinearBezier.buildwithangle( angle )
    return LinearBezier[ :support, [V2D::O, V2D::X.rotate( angle )]]
  end

end

end # end XRVG
