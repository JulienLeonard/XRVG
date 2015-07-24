#
# Contains Ruby geometric V2D extension to deal with intersection. 
# taken from http://geometryalgorithms.com/Archive/algorithm_0108/algorithm_0108.htm
# See :
# - +V2D+

require 'geometry2D'

module XRVG

  class V2D

    # compute if self is Left|On|Right of the line p0 to p1
    # >0 for Left, 0 for On, <0 for right
    def isLeft( p0, p1 )
      criteria = (p1.x - p0.x)*(self.y-p0.y) - (self.x - p0.x) * (p1.y - p0.y)
      if criteria > 0.0
	return :left
      elsif criteria < 0.0
	return :right
      else
	return :on
      end
    end

    alias xyorder <=>
    
  end
  
  # 2D segment 
  class V2DS
    include Attributable 
    attribute :p0, nil, V2D
    attribute :p1, nil, V2D

    # create a new 2D segment
    #  v = V2DS[V2D::O,V2D::X]
    def V2DS.[](p0,p1)
      return V2DS.new(p0,p1)
    end

    # initialize overloading on Attributable to speed up
    def initialize(p0,p1) #:nodoc:
      self.p0 = p0
      self.p1 = p1
    end

    def left
      return p0.x < p1.x ? p0 : p1
    end

    def right
      return p0.x > p1.x ? p0 : p1
    end

    def V2DS.sameside?( s1, s2 )
      lsign = s1.left.isLeft( s2.left, s2.right )
      rsign = s1.right.isLeft( s2.left, s2.right )
      if lsign == rsign and lsign != :on
	return true
      end
      return false
    end

    def intersect?( other )
      if V2DS.sameside?( other, self )
	return false
      elsif V2DS.sameside?( self, other )
	return false
      end
      return true
    end

    def intersection( other )
      if not self.intersect?( other )
	return nil
      end

      x1, y1 = self.p0.coords
      x2, y2 = self.p1.coords
      x3, y3 = other.p0.coords
      x4, y4 = other.p1.coords
	
      newx = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4 ) ) / (( x1 - x2) * (y3 - y4) - ( y1 - y2 ) * (x3 - x4))
      newy = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4 ) ) / (( x1 - x2) * (y3 - y4) - ( y1 - y2 ) * (x3 - x4))
      return V2D[ newx, newy ]
    end
  end
end
