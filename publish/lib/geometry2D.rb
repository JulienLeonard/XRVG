#
# Contains Ruby Vector class extension. 
# See :
# - +Vector+
# - +Point+

require 'matrix'

# 
# Vector class extension, to provide several useful "geometrical" services
# 
# For example :
#   Vector[0.0,2.0].norm               => Vector[0.0,1.0]
#   Vector[0.0,2.0].angle              => 0.0
#   Vector[0.0,2.0].ortho              => Vector[-2.0,0.0]
#   Vector[0.0,2.0].rotate( Math::PI ) => Vector[0.0,-2.0]
#
# It could be efficient to define specific 2D vector, to speed up computation.
# It is however not compatible with Color definition, as Vector 4D, and prevent from using this lib in 3D or 4D (with time).
# Must be checked though.
#
# Another thing is to make this class C extension, to speed up computation.
class Vector
  include Comparable

  X = Vector[1.0, 0.0]
  Y = Vector[0.0, 1.0]
  O = Vector[0.0, 0.0]

  # to optimize for 2D
  if nil
  def *( scalar )
    return Vector[ self[0] * scalar, self[1] * scalar ]
  end
  
  def +(other)
    return Vector[ self[0] + other[0], self[1] + other[1] ]
  end
  end


  # method necessary to make Vector Ranges
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

  # method necessary to make Vector Ranges
  # 
  # simply call succ on each coord
  def succ()
    return Vector[ self.x.succ, self.y.succ ]
  end

  # compute the normalized vector given the current vector
  #  Vector[0.0,2.0].norm => Vector[0.0,1.0]
  def norm
    r = r()
    if r != 0.0
      return self / r
    else
      return Vector::O
    end
  end

  # compute the angle of a vector considering x axis.
  #  Vector[0.0,2.0].angle => 0.0
  # must be made in C extension, as expensive
  def angle
    r = self.r()
    if r == 0
      return 0
    else
      unitary = self/r
      cos, sin = unitary[0], unitary[1]
      angle = Math.acos( cos )
      if sin < 0.0
	angle = -angle
      end
      return angle
    end
  end

  # compute the angle between two vectors
  #  Vector.angle( Vector[1.0,0.0], Vector[0.0,1.0] ) => Math::PI/2.0
  def Vector.angle( v1, v2 )
    return v1.angle - v2.angle
  end

  # scale a vector with another one
  #  Vector[1.0,2.0].scale( Vector[3.0,4.0] ) => Vector[3.0,8.0]
  #  v.scale( Vector[a,a] ) <=> v * a
  def scale( scaler )
    return Vector[self.x * scaler.x, self.y * scaler.y ]
  end

  # rotate a 2D vector 
  #  Vector[1.0,0.0].rotate( Math::PI/2.0 ) => Vector[0.0,1.0]
  def rotate( angle )
    newx = self.x * Math.cos( angle ) - self.y * Math.sin( angle )
    newy = self.x * Math.sin( angle ) + self.y * Math.cos( angle )
    return Vector[ newx, newy ]
  end
  
  # compute the orthogonal vector. Equiv to .rotate( Math::PI/2.0 )
  #  Vector[1.0,0.0].ortho => Vector[0.0,1.0]
  def ortho
    return Vector[ -self[1], self[0] ]
  end
  
  # return first coord of a vector
  #  Vector[1.0,2.0].x => 1.0
  def x
    return self[0]
  end

  # return second coord of a vector
  #  Vector[1.0,2.0].y => 2.0
  def y
    return self[1]
  end
  
  # compute the symetric of vector considered as point, with center of symetrie being other considered as point
  #  Vector[1.0,2.0].sym( Vector[0.0,0.0] ) => Vector[-1.0,-2.0]
  def sym( other )
    return self * 2.0 - other
  end

  # shortcut method to do 
  #  vector * (1.0 / scalar)
  def /( scalar )
    return self * (1.0 / scalar)
  end

  # more efficient that self * -1.0
  def -@ ()
    return Vector[ -self[0], -self[1] ]
  end

  alias reverse -@

  # coords management between different coord systems (for the moment only euclidian and polar)
  #  Vector[0.0,1.0].coords         => [0.0,1.0]
  #  Vector[0.0,1.0].coords(:polar) => [1.0,Math::PI/2.0]
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
  def Vector.polar( r, angle )
    x = r * Math.cos( angle )
    y = r * Math.sin( angle )
    return Vector[x,y]
  end

  alias length r
  alias translate +
end

#
# Point class just to have some more meaningful notation, as Point::O
#
class Point < Vector

  O = Point[0.0, 0.0]

  # compute the coord box enclosing every 2D elements considered as points
  #  Point.viewbox( [Vector[1.0,2.0], Vector[2.0,1.0]] ) => [1.0, 1.0, 2.0, 2.0]
  def Point.viewbox (pointlist)
    if pointlist.size == 0
      return [0.0, 0.0, 0.0, 0.0]
    end

    xs = pointlist.map {|p| p.x}
    ys = pointlist.map {|p| p.y}

    return [xs.min, ys.min, xs.max, ys.max]
  end

  # compute dimension of the box enclosing 2D elemnts considered as points
  #   Point.viewbox( [Vector[1.0,2.0], Vector[10.0,1.0]] ) => [9.0, 1.0]
  # use +viewvox+
  def Point.size (pointlist)
    xmin, ymin, xmax, ymax = viewbox( pointlist )
    return [xmax - xmin, ymax - ymin]
  end

end




