# File for GeoVariety
# See (also):
# - InterBezier
# - Offsetvariety
# - FuseauVariety

require 'interbezier'

module XRVG

# = GeoVariety abstract module
# == Principle
# Base module to define geometrical spaces or canvas different from simple euclidean one to draw curves on.
# It provides three different services:
# - point computation
# - geodesic computation
# - arbitrary bezier computation, this one by computing sampling of euclidean curve on the variety, and then fitting point
#   sequence with FitBezierBuilder
module GeoVariety
  
  # must be overriden
  def point( point )
    raise NotImplementedError.new("#{self.class.name}#point is an abstract method.")
  end
  
  # must be overriden
  def line( x1, x2, y )
    raise NotImplementedError.new("#{self.class.name}#line is an abstract method.")
  end

  # see GeoVariety module description for algorithm
  def bezier( pointrange, bezier )
    bezier = bezier.similar( pointrange )
    points = bezier.samples( 20 )
    points = points.map {|point| self.point( point )}
    return FitBezierBuilder[ :points, points ]
  end
end

# = InterBezier GeoVariety implementation
# == Principle
# InterBezier defines a surface by the set of every possible curve sample from one interpolated curve to the other.
# Geodesic corresponds then to one interpolated result, and point to a point of this curve
class InterBezier
  include GeoVariety
  
  # Compute the geodesic curve by doing self.sample with y coord, and then compute point of this curve with length "x"
  def point( point )
    curve = self.sample( point.y )
    return curve.point( point.x )
  end

  # Compute the geodesic subcurve with y coord between x1 and x2
  def line( x1, x2, y )
    # Trace("interbezier line x1 #{x1} x2 #{x2} y #{y}")
    curve = self.sample( y )
    result = curve.apply_split( x1, x2 )
    # Trace("interbezier line result #{result.inspect}")
    return result
  end

end

# = OffsetVariety implementation
# == Principle
# Geovariety is defined by the set of offset curves from -ampl to +ampl
# == Extension
# Parameter could be a :samplable parameter : in that case, ampl will vary
#
# Another extension would be to parametrize range straightforwardly
#
# Finally, the two previous remarks must be synthetized :-)
class OffsetVariety
  include Attributable
  attribute :support
  attribute :ampl, nil, Float

  include GeoVariety

  # builder: init static offset range with (-self.ampl..self.ampl)
  def initialize( *args )
    super( *args )
    @range = (-self.ampl..self.ampl)
  end

  # point computed by computing offset curve with ampl y coord mapped onto offset range, and then sampling the curve with x coord
  def point( point )
    curve = Offset[ :support, @support, :ampl, @range.sample( point.y ) ]
    return curve.point( point.x )
  end

  # subgeodesic computed by computing offset curve with ampl y coord
  def line( x1, x2, y )
    curve = Offset[ :support, @support, :ampl, @range.sample( y ) ]
    return curve.apply_split( x1, x2 )
  end
  
end  

# = FuseauVariety implementation
# == Principle
# Same as OffsetVariety, with Fuseau shape, that is with linearly varying ampl range
class FuseauVariety
  include Attributable
  attribute :support
  attribute :ampl, nil, Float

  include GeoVariety

  def initialize( *args )
    super( *args )
    @range = (-self.ampl..self.ampl)
  end

  def point( point )
    curve = Offset[ :support, @support, :ampl, (0.0..@range.sample( point.y ))]
    return curve.point( point.x )
  end

  def line( x1, x2, y )
    curve = Offset[ :support, @support, :ampl, (0.0..@range.sample( y ))]
    return curve.apply_split( x1, x2 )
  end
end

end # XRVG

# see geovariety_test to see tests
