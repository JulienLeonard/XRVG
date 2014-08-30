#
# Contains Ruby geometric V2D 2D class. 
# See :
# - +V2D+

require 'attributable'

module XRVG
#
# 2D vector
#
# V2D class definition, to provide several useful "geometrical" services
#
# Extends and somehow redefines V2D class, to speed up computation, as less generic
# 
# For example :
#   V2D[0.0,2.0].norm               => V2D[0.0,1.0]
#   V2D[0.0,2.0].angle              => 0.0
#   V2D[0.0,2.0].ortho              => V2D[-2.0,0.0]
#   V2D[0.0,2.0].rotate( Math::PI ) => V2D[0.0,-2.0]
class V2D
  include Comparable
  include Attributable 
  attribute :x, 0.0, Float
  attribute :y, 0.0, Float

  # create a new 2D vector
  #  v = V2D[0.0,0.0]
  def V2D.[](x=0.0,y=0.0)
    return V2D.new(x,y)
  end

  # set coords
  def xy=(other)
    if other.is_a? Array
      self.x = other[0]
      self.y = other[1]
    else
      self.x = other.x
      self.y = other.y
    end
  end

  # initialize overloading on Attributable to speed up
  def initialize(x,y) #:nodoc:
    self.x = x
    self.y = y
  end

  X = V2D[1.0, 0.0]
  Y = V2D[0.0, 1.0]
  O = V2D[0.0, 0.0]

  # scalar multiplication
  #   V2D[1.0,2.0] * 2.0; #=> V2D[2.0,4.0]
  def *( scalar )
    return V2D[ self.x * scalar, self.y * scalar ]
  end

  # scalar division
  #  V2D[1.0,2.0] / 2.0; #=> V2D[0.5,1.0]
  # ruby checks for dividing by zero
  def /( scalar )
    return V2D[ self.x / scalar, self.y / scalar ]
  end
  
  # 2D vector addition
  #  V2D[1.0,2.0] + V2D[2.0,1.0]; #=> V2D[3.0,3.0]
  def +(other)
    return V2D[ self.x + other.x, self.y + other.y ]
  end

  # 2D vector substraction
  #  V2D[1.0,2.0] - V2D[2.0,1.0]; #=> V2D[-1.0,1.0]
  def -(other)
    return V2D[ self.x - other.x, self.y - other.y ]
  end

  # 2D vector negative
  #  -V2D[1.0,2.0]  #=> V2D[-1.0,2.0]
  def -@ ()
    return V2D[ -self.x, -self.y ]
  end

  # alias for 2D vector negative
  alias reverse   -@

  # method necessary to make V2D Ranges
  #
  # make <=> on x, then on y
  def <=>( other )
    first = self.x <=> other.x 
    if first != 0
      return first
    else
      return self.y <=> other.y
    end
  end

  # method necessary to make V2D Ranges
  # 
  # simply add 1.0 to each coord
  def succ()
    return V2D[ self.x + 1.0, self.y + 1.0 ]
  end

  # compute length of 2D vector (r notation to be compatible with V2D)
  def r()
    return Math.hypot( self.x, self.y )
  end

  # alias for computing 2D vector length
  alias length    r

  # compute the normalized vector given the current vector
  #  V2D[0.0,2.0].norm => V2D[0.0,1.0]
  def norm
    r = r()
    if r != 0.0
      return self / r
    else
      return V2D::O
    end
  end

  # compute the angle of a vector considering x axis.
  #  V2D[0.0,2.0].angle => 0.0
  def angle
    r = self.r()
    if r == 0.0
      return 0.0
    else
      unitary = self/r
      cos, sin = unitary.x, unitary.y
      angle = Math.acos( cos )
      if sin < 0.0
	angle = -angle
      end
      return angle
    end
  end

  # compute the angle between two vectors
  #  V2D.angle( V2D[1.0,0.0], V2D[0.0,1.0] ) => Math::PI/2.0
  def V2D.angle( v1, v2 )
    return v1.angle - v2.angle
  end

  # 2D translation, simply defines as addition
  alias translate +

  # scale a vector with another one
  #  V2D[1.0,2.0].scale( V2D[3.0,4.0] ) => V2D[3.0,8.0]
  #  v.scale( V2D[a,a] ) <=> v * a
  def scale( scaler )
    return V2D[self.x * scaler.x, self.y * scaler.y ]
  end

  # rotate a 2D vector 
  #  V2D[1.0,0.0].rotate( Math::PI/2.0 ) => V2D[0.0,1.0]
  def rotate( angle )
    newx = self.x * Math.cos( angle ) - self.y * Math.sin( angle )
    newy = self.x * Math.sin( angle ) + self.y * Math.cos( angle )
    return V2D[ newx, newy ]
  end
  
  # compute the orthogonal vector. Equiv to .rotate( Math::PI/2.0 )
  #  V2D[1.0,0.0].ortho => V2D[0.0,1.0]
  def ortho
    return V2D[ -self.y, self.x ]
  end

  # compute the symetric of vector "other" considering self as symetry center
  #  V2D[1.0,2.0].sym( V2D[0.0,0.0] ) => V2D[2.0,4.0]
  def sym( other )
    return self * 2.0 - other
  end

  # compute the symetric of point "self" considering (point,v) as symetry axis
  def axesym( point, axev )
    v = self - point
    angle = V2D.angle( v, axev )
    return point + v.rotate( -2.0 * angle )
  end

  # coords management between different coord systems (for the moment only euclidian and polar)
  #  V2D[0.0,1.0].coords         => [0.0,1.0]
  #  V2D[0.0,1.0].coords(:polar) => [1.0,Math::PI/2.0]
  def coords(type=:cartesien)
    if type == :cartesien
      return [self.x, self.y]
    elsif type == :polar
      if @polarcoords == nil
	@polarcoords = [self.r, self.angle]
      end
      return @polarcoords
    else
      Kernel.raise( "Unknown coord type #{type}" )      
    end
  end
  
  # build a vector from polar coords
  def V2D.polar( r, angle )
    x = r * Math.cos( angle )
    y = r * Math.sin( angle )
    return V2D[x,y]
  end

  # compute 2D inner_product as v1.x * v2.x + v1.y * v2.y
  #  V2D[ 1.0, 2.0 ].inner_product( V2D[3.0,4.0] ); #=> 11.0 
  def inner_product( other )
    return self.x * other.x + self.y * other.y
  end

  def V2D.crossproduct( v1, v2 )
    return (v1.x * v2.y - v2.x * v1.y)
  end

  # specific method to test vector equality with specified precision
  def V2D.vequal?( v1, v2, epsilon=0.000000001 )
    return ((v2-v1).r < epsilon)
  end

  # compute the coord box enclosing every 2D elements considered as points
  #  V2D.viewbox( [V2D[1.0,2.0], V2D[2.0,1.0]] ) => [1.0, 1.0, 2.0, 2.0]
  def V2D.viewbox (pointlist)
    if pointlist.size == 0
      return [0.0, 0.0, 0.0, 0.0]
    end

    xs = pointlist.map {|p| p.x}
    ys = pointlist.map {|p| p.y}

    return [xs.min, ys.min, xs.max, ys.max]
  end

  # compute dimension of the box enclosing 2D elemnts considered as points
  #   V2D.viewbox( [V2D[1.0,2.0], V2D[10.0,1.0]] ) => [9.0, 1.0]
  # use +viewvox+
  def V2D.size (pointlist)
    xmin, ymin, xmax, ymax = V2D.viewbox( pointlist )
    return [xmax - xmin, ymax - ymin]
  end

  # utilitary method to compute a random point
  # must be refactored in the future to depend on Shape
  def V2D.rand( rangex=Range.O, rangey=Range.O)
    return V2D[rangex.rand, rangey.rand]
  end
end
end
