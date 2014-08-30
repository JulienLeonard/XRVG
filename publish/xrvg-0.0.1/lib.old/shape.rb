# shape.rb file
# See
# - Shape interface
# - Curve interface
# - Line class
# - Circle class
require 'frame'
require 'geometry2D'
require 'utils'
require 'attributable'

# Shape abstract interface
# = Intro
# To provide a set of services a shape class must provide
class Shape
  include Attributable
  
  # must return the contour of the shape, of Curve type
  #
  # abstract
  #
  # not yet used
  def contour( *args )
    Kernel::raise("Shape::contour must be redefined in subclasses")
  end

  # must return the svg description of the shape
  #
  # abstract
  #
  # must be defined
  def svg()
    Kernel::raise("Shape::svg must be redefined in subclasses")
  end
  
  # must return the enclosing box of the shape, that is [xmin, ymin, xmax, ymax]
  #
  # abstract
  #
  # must be defined
  def viewbox()
    Kernel::raise("Shape::viewbox must be redefined in subclasses")
  end
  
  # compute size of the shape, from viewbox
  def size()
    xmin, ymin, xmax, ymax = self.viewbox
    return [xmax-xmin, ymax-ymin]
  end

  # must return the enclosing box of the shape, that is [xmin, ymin, xmax, ymax]
  #
  # abstract
  def default_style()
    return Style[:fill, Color.black ]
  end

  # compute the "surface" of the viewbox of the shape
  #
  # use size method
  def surface
    width, height = self.size
    return width * height
  end

end

# Curve abstract interface
# = Intro
# To provide a set of services a curve class must provide
class Curve < Shape
  # must compute the point at curve abscissa
  #
  # abstract
  #
  # must be defined
  def point( abscissa )
    Kernel::raise("Curve::point must be redefined in subclasses")
  end

  # must compute the tangent at curve abscissa
  #
  # abstract
  #
  # must be defined
  def tangent( abscissa )
    Kernel::raise("Curve::tangent must be redefined in subclasses")
  end

  # must compute the acceleration at curve abscissa
  #
  # abstract
  #
  # must be defined
  def acc( abscissa )
    Kernel::raise("Curve::acc must be redefined in subclasses")
  end

  # must compute the rotation at curve abscissa
  #
  # abstract
  #
  # must be defined
  def rotation( abscissa )
    Kernel::raise("Curve::rotation must be redefined in subclasses")
  end

  # must compute the scale at curve abscissa
  #
  # abstract
  #
  # must be defined
  def scale( abscissa )
    Kernel::raise("Curve::scale must be redefined in subclasses")
  end

  # must return the length at abscissa, or total length if abscissa nil
  #
  # abstract
  #
  # must be defined
  def length(abscissa=nil)
    Kernel::raise("Curve::length must be redefined in subclasses")
  end

  # default style of a curve, as stroked with stroke width 1% of length
  def default_style
    return Style[ :stroke, Color.black, :strokewidth, self.length / 100.0 ]
  end
  
  # compute frame at abscissa t
  def frame( t )
    return Frame[ :center, self.point( t ), :vector, self.tangent( t ), :rotation, self.rotation( t ), :scale, self.scale( t ) ]
  end

  # compute normal at abscissa t
  #
  # do tangent.ortho
  def normal( t )
    return self.tangent( t ).ortho
  end

  # compute normal acceleration at abscissa t
  def acc_normal( t )
    normal = self.normal( t ).norm
    result = self.acc( t ).inner_product( normal )
    return result
  end

  # compute curvature at abscissa t
  def curvature( t )
    if self.acc_normal( t ) == 0.0
      return 0.0
    end
    return 1.0 / (self.tangent( t ).r / self.acc_normal( t ))
  end

  # shortcut method to map frames from abscissas
  def frames (abscissas)
    return abscissas.map { |abscissa| self.frame( abscissa ) }
  end

  # shortcut method to map points from abscissas
  def points (abscissas)
    result = abscissas.map { |abscissa| self.point( abscissa ) }
    return result
  end

  # shortcut method to map tangents from abscissas
  def tangents (abscissas)
    return abscissas.map { |abscissa| self.tangent( abscissa ) }
  end

end

# Line class
# = Intro
# Used to draw polylines and polygons
# = Attributes
#  attribute :exts, [Point[0.0, 0.0], Point[1.0, 1.0]]
# = Example
#  line = Line[ :exts, [Point::O, Point::X] ]
class Line < Curve
  attribute :exts, [Point[0.0, 0.0], Point[1.0, 1.0]]

  def initialize (*args) #:nodoc:
    super( *args )
    self.init_tangents
  end

  def init_tangents #:nodoc:
    index = 0
    @tangents = Array.new
    self.exts.pairs { |p1, p2| 
      @tangents[ index ] = Vector.createwithpoints( p1, p2 ).norm 
      index += 1
    }
  end

  # return the total length of the polyline
  def length
    if not @length
      @length = 0.0
      self.exts.pairs do |p1, p2|
	@length += (p1 - p2).r
      end
    end
    return @length
  end

  # compute line point at abscissa
  #   Line[ :exts, [Point::O, Point::X] ].point( 0.3 ) => Vector[0.0,0.3]
  def point (abscissa)
    piece1   = abscissa.to_int
    if piece1 == @exts.size - 1
      return @exts[-1]
    end
    abscissa -= piece1
    cexts = self.exts.slice( piece1, 2 )
    return (cexts[0]..cexts[1]).sample( abscissa )
  end

  # compute line frame at abscissa
  #  
  # for the moment, frame rotation is always 0.0, and scale always 1.0
  def frame (abscissa)
    return Frame[ :center, self.point( abscissa ), :vector, Vector[ 0.0, 0.0 ], :rotation, 0.0, :scale, 1.0 ]
  end

  # compute line tangent at abscissa
  def tangent (abscissa)
    return @tangents[abscissa.to_int].dup
  end

  # compute viewbox of the line
  #
  # simply call Point.viewbox on :exts
  def viewbox
    return Point.viewbox( self.exts )
  end

  # translate a line of v offset, v being a vector
  #
  # return a new line with every point of :exts translated
  def translate( v )
    return Line[ :exts, @exts.map {|ext| ext.translate( v )} ]
  end

  # reverse a line
  #
  # return a new line with :exts reversed
  def reverse
    return Line[ :exts, @exts.reverse ]
  end

  # return line svg description
  def svg
    path = "M #{exts[0].x} #{exts[0].y} "
    exts[1..-1].each { |p|
      path += "L #{p.x} #{p.y}"
    }
    return "<path d=\"" + path + "\"/>"
  end

  include Samplable
  alias apply_sample point
end

# Circle class
# = Intro
# define a circle curve
# = Attributes
#   attribute :center, Vector[0.0,0.0]
#   attribute :radius, 1.0
# = Example
#  c = Circle[ :center, Point::O, :radius, 1.0 ] # equiv Circle[] 
class Circle < Curve
  attribute :center, Vector[0.0,0.0]
  attribute :radius, 1.0

  # compute length of the circle
  def length
    if not @length
      @length = 2.0 * Math::PI * self.radius
    end
    return @length
  end

  # shortcut method to retun center.x
  def cx
    return self.center.x
  end

  # shortcut method to retun center.y
  def cy
    return self.center.y
  end
  
  # viewbox of the circle
  def viewbox
    return [ self.cx - self.radius,
             self.cy - self.radius,
             self.cx + self.radius,
             self.cy + self.radius ]
  end

  # size of the circle
  def size
    return [ self.radius, self.radius ]
  end
  
  # svg description of the circle
  def svg
    template = '<circle cx="%cx%" cy="%cy%" r="%r%"/>'
    return template.subreplace( {"%cx%" => cx,
				 "%cy%" => cy,
				 "%r%"  => radius} )
  end

  # compute point at abscissa
  def point (abscissa)
    angle = Range.Angle.sample( abscissa )
    return Point[ self.cx + self.radius * Math.cos( angle ),
                  self.cy + self.radius * Math.sin( angle )]
  end

  # compute tangent at abscissa
  #
  # TODO
  def tangent( abscissa )
    TODO
  end

  include Samplable
  alias apply_sample point

end

