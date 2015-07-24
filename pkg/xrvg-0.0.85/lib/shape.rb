# shape.rb file
# See
# - Shape interface
# - Curve interface
# - Line class
# - Circle class
require 'utils'
require 'frame'
require 'geometry2D'


module XRVG
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
    raise NotImplementedError.new("#{self.class.name}#contour is an abstract method.")
  end

  # must return the svg description of the shape
  #
  # abstract
  #
  # must be defined
  def svg()
    raise NotImplementedError.new("#{self.class.name}#svg is an abstract method.")
  end
  
  # must return the enclosing box of the shape, that is [xmin, ymin, xmax, ymax]
  #
  # abstract
  #
  # must be defined
  def viewbox()
    raise NotImplementedError.new("#{self.class.name}#viewbox is an abstract method.")
  end
  
  # compute size of the shape, from viewbox
  def size()
    xmin, ymin, xmax, ymax = self.viewbox
    return [xmax-xmin, ymax-ymin]
  end

  # return the default style for a Shape instance
  #
  # is done on instance, because for Curve for example, strokewidth is proportional to length
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
# To define a set of services a curve class must provide
class Curve < Shape
  # must compute the point at curve abscissa
  #
  # abstract
  #
  # must be defined
  def point( abscissa, container=nil )
    raise NotImplementedError.new("#{self.class.name}#curve is an abstract method.")
  end

  # must compute the tangent at curve abscissa
  #
  # abstract
  #
  # must be defined
  def tangent( abscissa, container=nil )
    raise NotImplementedError.new("#{self.class.name}#tangent is an abstract method.")
  end

  # must compute the acceleration at curve abscissa
  #
  # abstract
  #
  # must be defined
  def acc( abscissa, container=nil )
    raise NotImplementedError.new("#{self.class.name}#acc is an abstract method.")
  end

  # must return the length at abscissa, or total length if abscissa nil
  #
  # abstract
  #
  # must be defined
  def length(abscissa=nil)
    raise NotImplementedError.new("#{self.class.name}#length is an abstract method.")
  end

  # default style of a curve, as stroked with stroke width 1% of length
  def default_style
    return Style[ :stroke, Color.black, :strokewidth, self.length / 100.0 ]
  end

  # compute the rotation at curve abscissa, or directly from tangent (for frame computation speed up),
  # as angle between tangent0 angle and tangent( abscissa ) (or tangent) angle
  def rotation( abscissa, tangent=nil )
    if not tangent
      tangent = self.tangent( abscissa )
    end
    return (tangent.angle - self.tangent0_angle)
  end

  # must compute the scale at curve abscissa, or directly from tangent (for frame computation speed up)
  # as ratio between tangent0 size and tangent( abscissa ) (or tangent) size
  def scale( abscissa, tangent=nil )
    if not tangent
      tangent = self.tangent( abscissa )
    end
    result = 0.0
    if not self.tangent0_length == 0.0
      result = (tangent.r / self.tangent0_length)
    end
    return result
  end

  def tangent0
    if not @tangent0
      @tangent0 = self.tangent( 0.0 )
    end
    return @tangent0
  end

  # TODO : must be cached in vector
  def tangent0_angle
    if not @tangent0_angle
      @tangent0_angle = self.tangent0.angle
    end
    return @tangent0_angle
  end

  # TODO : must be cached in vector
  def tangent0_length
    if not @tangent0_length
      @tangent0_length = self.tangent0.r
    end
    return @tangent0_length
  end
  
  # compute frame vector at abscissa t, that is [curve.point( t ), curve.tangent( t ) ]
  def framev( t )
    return [self.point( t ), self.tangent( t ) ]
  end

  # compute frame at abscissa t
  def frame( t )
    point, tangent = self.framev( t )
    return Frame[ :center, point, :vector, tangent, :rotation, self.rotation( nil, tangent ), :scale, self.scale( nil, tangent ) ]
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
    acc_normal = self.acc_normal( t )
    if acc_normal == 0.0
      return 0.0
    end
    return 1.0 / (self.tangent( t ).r / acc_normal )
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

  # shortcut method, map of normal
  def normals( indexes )
    return indexes.map {|i| self.normal( i )}
  end

end


# Line class
# = Intro
# Used to draw polylines and polygons
# = Attributes
#  attribute :points, [V2D[0.0, 0.0], V2D[1.0, 1.0]]
# WARNING : getter "points" is not defined, because is defined as Curve.points( abscissa ) !!!
# = Example
#  line = Line[ :points, [V2D::O, V2D::X] ]
class Line < Curve
  attribute :points, [V2D[0.0, 0.0], V2D[1.0, 1.0]]

  def initialize (*args) #:nodoc:
    super( *args )
    self.init_tangents
  end

  def init_tangents #:nodoc:
    index = 0
    @tangents = Array.new
    @points.pairs { |p1, p2| 
      @tangents[ index ] = (p2-p1).norm 
      index += 1
    }
  end

  # return the total length of the polyline
  def length
    if not @length
      @length = 0.0
      @points.pairs do |p1, p2|
	@length += (p1 - p2).r
      end
    end
    return @length
  end

  # compute line point at abscissa
  #   Line[ :points, [V2D::O, V2D::X] ].point( 0.3 ) => V2D[0.0,0.3]
  def point (abscissa, container=nil)
    container ||= V2D[]
    piece1   = abscissa.to_int
    if piece1 == @points.size - 1
      container.xy = @points[-1]
    else
      abscissa -= piece1
      cpoints = @points.slice( piece1, 2 )
      container.xy = [(cpoints[0].x..cpoints[1].x).sample( abscissa ), 
	              (cpoints[0].y..cpoints[1].y).sample( abscissa )]
    end
    return container
  end

  # redefining to discriminate between @points and map.point
  def points(arg=nil)
    if not arg
      return @points
    else
      super(arg)
    end
  end

  # compute line tangent at abscissa
  def tangent (abscissa, container=nil)
    container ||= V2D[]
    container.xy = @tangents[abscissa.to_int]
    return container
  end

  # acc V2D.O
  def acc( abscissa, container=nil )
    container ||= V2D[]
    container.xy = [0.0,0.0]
    return container
  end

  # compute viewbox of the line
  #
  # simply call V2D.viewbox on :points
  def viewbox
    return V2D.viewbox( @points )
  end

  # translate a line of v offset, v being a vector
  #
  # return a new line with every point of :points translated
  def translate( v )
    return Line[ :points, @points.map {|ext| ext + v } ]
  end

  # reverse a line
  #
  # return a new line with :points reversed
  def reverse
    return Line[ :points, @points.reverse ]
  end

  # return line svg description
  def svg
    path = "M #{points[0].x} #{points[0].y} "
    @points[1..-1].each { |p|
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
#   attribute :center, V2D[0.0,0.0]
#   attribute :radius, 1.0
#   attribute :initangle, 0.0
# = Example
#  c = Circle[ :center, V2D::O, :radius, 1.0 ] # equiv Circle[] 
class Circle < Curve
  attribute :center, V2D[0.0,0.0]
  attribute :radius, 1.0
  attribute :initangle, 0.0

  # Circle builder from points diametraly opposed
  #   Circle.diameter( V2D[-1.0,0.0], V2D[1.0,0.0] ) == Circle[ :center, V2D::O, :radius, 1.0 ]
  def Circle.diameter( p1, p2 )
    initangle = ( p1 - p2 ).angle
    return Circle[ :center, (p1 + p2)/2.0, :radius, (p1 - p2).r/2.0, :initangle, initangle ]
  end

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

  def rotate( angle )
    return Circle[:center, self.center, :radius, self.radius, :initangle, self.initangle + angle]
  end
  
  # svg description of the circle
  def svg
    template = '<circle cx="%cx%" cy="%cy%" r="%r%"/>'
    return template.subreplace( {"%cx%" => cx,
				 "%cy%" => cy,
				 "%r%"  => radius} )
  end

  # compute point at abscissa
  def point (abscissa, container=nil)
    angle = Range::Angle.sample( abscissa ) + @initangle
    container ||=V2D[]
    container.x = self.cx + self.radius * Math.cos( angle )
    container.y = self.cy + self.radius * Math.sin( angle )
    return container
  end

  # compute tangent at abscissa
  def tangent( abscissa, container=nil )
    angle = Range::Angle.sample( abscissa ) + @initangle
    container ||=V2D[]
    container.x = -self.radius * Math.sin( angle )
    container.y = self.radius * Math.cos( angle )
    return container
  end

  # compute acc at abscissa
  def acc( abscissa, container=nil )
    angle = Range::Angle.sample( abscissa ) + @initangle
    container ||=V2D[]
    container.x = -self.radius * Math.cos( angle )
    container.y = -self.radius * Math.sin( angle )
    return container
  end


  include Samplable
  alias apply_sample point
end
end
