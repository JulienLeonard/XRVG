# +BezierSpline+ source


module XRVG
# BezierSpline class
#
# Internal class to represent a single-piece cubic bezier curve, defined by four points or two point + two vectors.
# You may never have to use this class. Prefer the use of +Bezier+ class
class BezierSpline #:nodoc:

  def BezierSpline.[](*args)
    return BezierSpline.new( *args )
  end
  
  def initialize( type, v1, v2, v3, v4 )
    self.checktype( type )
    self.checkvalues( v1, v2, v3, v4 )
    self.initdata( type, v1, v2, v3, v4 )
  end
  
  def checkvalues( v1, v2, v3, v4 )
    [v1, v2, v3, v4].each do |v| 
      if not (v.respond_to?(:x) || v.respond_to?(:y))
	Kernel::raise( "BezierSpline : init value #{v.inspect} does not respond to :x or :y" )
      end
    end
  end

  def checktype( type )
    if not type == :raw || type == :vector
      Kernel::raise( "BezierSpline : type #{type.inspect} is not :raw or :vector" )
    end
  end

  def data()
    return [:raw] + self.pointlist
  end
  
  def initdata( type, v1, v2, v3, v4 )
    @rawpointlist      = nil
    @vectorpointlist   = nil
    if type == :raw
      @rawpointlist       = [v1, v2, v3, v4]
    else
      @vectorpointlist    = [v1, v2, v3, v4]
    end
  end

  def compute_rawpointlist
    # Assert{ @vectorpointlist }
    @rawpointlist = [@vectorpointlist[0], @vectorpointlist[0] +  @vectorpointlist[1], @vectorpointlist[2] +  @vectorpointlist[3], @vectorpointlist[2]]
  end

  def compute_vectorpointlist
    # Assert{ @rawpointlist }
    @vectorpointlist = [@rawpointlist[0], @rawpointlist[1] - @rawpointlist[0], @rawpointlist[3], @rawpointlist[2] - @rawpointlist[3]]
  end

  
  def pointlist(type=:raw)
    self.checktype( type )
    if type == :raw
      if not @rawpointlist
	self.compute_rawpointlist
      end
      return @rawpointlist
    elsif type == :vector
      if not @vectorpointlist
	self.compute_vectorpointlist
      end
      return @vectorpointlist
    end
  end

  # shortcut method to get piece first point
  def firstpoint
    return self.pointlist()[0]
  end

  # shortcut method to get piece last point
  def lastpoint
    return self.pointlist()[-1]
  end

  # shortcut method to get piece first vector
  def firstvector
    return self.pointlist(:vector)[1]
  end

  # shortcut method to get piece last vector
  def lastvector
    return self.pointlist(:vector)[-1]
  end

# -------------------------------------------------------------
#  bezier formula
# -------------------------------------------------------------

  def compute_factors
    p1, p2, p3, p4 = self.pointlist
    @factors  = [-(p1 - p2 * 3.0 + p3 * 3.0 - p4), (p1 - p2 * 2.0 + p3) * 3.0, (p2 - p1) * 3.0, p1]
    @tfactors = [@factors[0], @factors[1] * 2.0 / 3.0, @factors[2] / 3.0]
    @afactors = [@tfactors[0] * 2.0, @tfactors[1]]
  end

  # get point from the bezier curve
  # this method use the definition of the bezier curve
  def point( t, result=nil )
    # puts "BezierSpline point t #{t}"
    t2 = t * t
    t3 = t2 * t
    if not result
      result = V2D[0.0,0.0]
    end
    
    if not @factors
      compute_factors
    end

    # decomposed because avoid to build useless V2D
    result.x = @factors[3].x + @factors[2].x * t + @factors[1].x * t2 + @factors[0].x * t3
    result.y = @factors[3].y + @factors[2].y * t + @factors[1].y * t2 + @factors[0].y * t3

    return result
  end

  # compute the bezier tangent vector
  #
  # Beware that what is actually computed here is 1/3 tangent !!
  def tangent( t, result=nil )
    t2 = t * t
    if not result
      result = V2D[0.0,0.0]
    end

    if not @factors
      compute_factors
    end

    # decomposed because avoid to build useless V2D
    result.x = @tfactors[2].x + @tfactors[1].x * t + @tfactors[0].x * t2
    result.y = @tfactors[2].y + @tfactors[1].y * t + @tfactors[0].y * t2

    return result
  end

  # compute the acc of bezier curve at t abscissa
  def acc( t, result=nil )
    if not result
      result = V2D[0.0,0.0]
    end

    if not @factors
      compute_factors
    end

    result.x = @afactors[1].x  + @afactors[0].x * t
    result.y = @afactors[1].y  + @afactors[0].y * t

    return result
  end

  # compute tangent vectors corresponding to the new subbezier
  # very strange method, but effective
  def subtangents (t1, t2 )
    v1 = self.tangent( t1 ) * (t2 - t1)
    v2 = self.tangent( t2 ) * (t1 - t2)
    return [v1, v2]
  end

  # compute a subpiece of the current bezier
  # t1 and t2 must correspond to the same atomic bezier
  def subpiece (t1, t2)
    tan1, tan2 = self.subtangents( t1, t2 )
    return BezierSpline.new( :vector, self.point( t1 ), tan1, self.point( t2 ), tan2 )
  end

  def reverse()
    return BezierSpline[ :raw, *self.pointlist().reverse ]
  end

  # simple translation operation : translate every point of the piece
  # return a new BezierSpline
  def translate( v )
    newpoints = self.pointlist.map {|point| point + v}
    return BezierSpline[ :raw, *newpoints ]
  end

  # simple rotation operation : rotate every point of the piece
  # return a new BezierSpline
  def rotate( angle, center )
    newpoints = self.pointlist.map {|point| center + (point-center).rotate( angle )}
    return BezierSpline[ :raw, *newpoints ]
  end

  # simple sym operation : sym every point of the piece
  # return a new BezierSpline
  def sym( center )
    newpoints = self.pointlist.map {|point| center.sym( point )}
    return BezierSpline[ :raw, *newpoints ]
  end


  # simple axe sym operation : sym every point of the piece
  # return a new BezierSpline
  def axesym( origin, v )
    newpoints = self.pointlist.map {|point| point.axesym( origin, v )}
    return BezierSpline[ :raw, *newpoints ]
  end

  def gdebug(render)
    p1, pc1, pc2, p2 = self.pointlist()
    v1 = pc1 - p1
    r1 = v1.r / 30.0
    v2 = pc2 - p2
    r2 = v2.r / 30.0
    render.add( Circle[ :center, p1, :radius, r1  ],  Style[ :fill, "red" ])
    render.add( Circle[ :center, pc1, :radius, r1 ],  Style[ :fill, "red" ])
    render.add( Line[ :points, [p1, pc1]          ],  Style[ :stroke, "red", :strokewidth, (r1 / 10.0) ])
    render.add( Circle[ :center, p2, :radius, r2  ],  Style[ :fill, "red" ])
    render.add( Circle[ :center, pc2, :radius, r1 ],  Style[ :fill, "red" ])
    render.add( Line[ :points, [p2, pc2]          ],  Style[ :stroke, "red", :strokewidth, (r2 / 10.0) ])
  end

end
end
