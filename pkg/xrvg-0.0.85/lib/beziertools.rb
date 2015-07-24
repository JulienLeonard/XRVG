# Some BezierBuilder implementations
# - old-fashioned SimpleBezier
# - useful BezierLevel
# - powerful Offset
# - interesting Ondulation
# - simple ClosureBezier

require 'bezierbuilders'

module XRVG
# = SimpleBezier
# == Content
# Simple Bezier interpolator, that builds a multipiece "regular" bezier curve from a list of points
# == Algo
# For each point triplet :
# - tangent vector of the middle point is the vector mean of vector from first to middle and vector frommiddle to last.
# First and last tangents are computed by symetry
# == Note
# FittingBezier is a better class for point bezier interpolation. However, this class is kept mainly for historical reasons.
class SimpleBezier < BezierBuilder
  attribute :support, nil, Array

  # BezierBuilder overloading: see SimpleBezier description for algorithm
  def compute( )
    points = @support
    if points.length < 2
      Kernel::raise("SimpleBezier support must have at least two points")
    elsif points.length == 2
      return LinearBezier.build( :support, points).data
    end
    
    result = Array.new
    p1      = points[0]
    v1      = V2D::O
    cpiece = [:vector, p1, v1]
    
    points.triplets do |p1, p2, p3|
      v = ((p2 - p1)..( p3 - p2 )).middle * 1.0 / 3.0
      result.push( cpiece + [p2, v.reverse] )
      cpiece = [:vector, p2, v]
    end

    pr2 = points[-1]
    vr2 = V2D::O
    result.push( cpiece + [pr2, vr2] )

    # compute first and last piece again, by symetry
    piece0 = Bezier.single( *result[0] )
    p1, v1, p2, v2 = piece0.pointlist(:vector)
    pv     = (p2 - p1)
    angle  = v2.angle - pv.angle 
    v1     = (-v2).rotate( -2.0 * angle )
    result[0] = [:vector, p1, v1, p2, v2]

    piecel = Bezier.single( *result[-1] )
    p1, v1, p2, v2 = piecel.pointlist(:vector)
    pv     = (p2 - p1)
    angle  = v1.angle - pv.angle 
    v2     = (-v1).rotate(  -2.0 * angle )
    result[-1] = [:vector, p1, v1, p2, v2]

    return result
  end
end

#
# Interpolation extension with SimpleBezier
#
module Interpolation

  def compute_simplebezier
    points = self.samplelist.foreach(2).map { |index, value| V2D[index,value] }
    @simplebezier = SimpleBezier[ :support, points ]
  end
  
  def getcurve
    if not @simplebezier
      self.compute_simplebezier
    end
    return @simplebezier
  end

  def simplebezier( dindex )
    return self.getcurve.sample( dindex ).y
  end

end


# = Offset bezier builder
# == Content
# Generic offset bezier builder.
# == Attributes
#  attribute :support, nil, Curve
#  attribute :abscissasampler, (0.0..1.0), Samplable
#  attribute :ampl, 0.5, :samplable
#  attribute :nsamples, 100
class Offset < FitBezierBuilder
  attribute :support, nil, Curve
  attribute :abscissasampler, (0.0..1.0), Samplable
  attribute :ampl, 0.5, :samplable
  attribute :nsamples, 100

  # overload FitBezierBuilder.points to compute Offset points
  #
  # Algo: for each sample, compute point, normal and amp, and newpoint = point + normal.norm * ampl
  def points
    result = []
    SyncS[self.abscissasampler, self.ampl].samples( self.nsamples) do |abscissa, amplsample|
      frame = self.support.frame( abscissa )
      result << frame.center + frame.vector.ortho.norm * amplsample
    end
    return result
  end
end

# = Fuseau bezier builder
# == Content
# Just shortcut class for Offset with :ampl = (1.0..0.0)
# == Attributes
#    attribute :maxwidth, 0.1
class Fuseau < Offset
  attribute :maxwidth, 0.1

  # overload Offset.ampl method by returning (self.maxwidth..0.0)
  def ampl
    return (self.maxwidth..0.0)
  end
end



# = BezierLevel bezier builder
# == Content
# Compute "roller coaster" bezier curves
#
# Can be used as a x-progressing curve, that is as an interpolation curve
# == Attributes
#  attribute :samplelist, [], Array
# :samplelist must contain pairs of cartesien coords [x1,y1,x2,y2,...], x between 0.0 and 1.0 (as for interpolator)
class BezierLevel < BezierBuilder
  attribute :samplelist, [], Array

  # Overload BezierBuilder build method
  #
  # Algo: simply interpolate [x,y] couples as V2D, with SimpleBezier bezier builder
  def BezierLevel.build( *args )
    builder = BezierLevel.new( *args )
    points = []
    builder.samplelist.foreach do |x,y|
      points << V2D[x,y]
    end
    return SimpleBezier[ :support, points ]
  end
end

# = ClosureBezier bezier builder
# == Content
# Simple bezier operator that take a list of beziers and produce a concatenate multipieces closed bezier curve.
# Missing segments are completed with lines
class ClosureBezier < BezierBuilder
  attribute :bezierlist

  # BezierBuilder compute overloading
  def compute
    result = []
    result += self.bezierlist[0].pieces
    self.bezierlist[1..-1].each do |bezier|
      lastpoint = result[-1].lastpoint
      newpoint  = bezier.firstpoint
      if not V2D.vequal?( lastpoint, newpoint )
	result += LinearBezier[ :support, [lastpoint, newpoint]].pieces
      end
      result += bezier.pieces
    end
    lastpoint = result[-1].lastpoint
    newpoint  = result[0].firstpoint
    if not V2D.vequal?( lastpoint, newpoint )
      result += LinearBezier[ :support, [lastpoint, newpoint]].pieces
    end
    result = result.map {|piece| piece.data}
    # Trace("result #{result.inspect}")
    return result
  end
end

# = Ondulation bezier builder
# == Content
# Generic ondulation bezier builder.
# == Attributes
#  attribute :support, nil, Curve
#  attribute :ampl, 0.5, :samplable
#  attribute :abscissasampler, (0.0..1.0), Samplable
#  attribute :freq, 10
# :support is a Curve
# :abscissas must be a Float Samplable, as (0.0..1.0).geo(3.0)
# :ampl can be a constant or a sampler
# :freq is the number of oscillations to be computed
class Ondulation < BezierBuilder
  attribute :support, nil, Curve
  attribute :ampl, 0.5, :samplable
  attribute :abscissasampler, (0.0..1.0), Samplable
  attribute :freq, 10

  # atomic pattern computation
  # 
  def compute_arc( abs1, abs2, amplitude, sens )
    mabs = (abs1 + abs2)/2.0
    p1, halfpoint, p2 = self.support.points( [abs1, mabs, abs2] )
    # Trace("mabs #{mabs} abs1 #{abs1} abs2 #{abs2} halfpoint #{halfpoint.inspect} p1 #{p1.inspect} p2 #{p2.inspect}")
    halfnormal = self.support.normal( mabs ).norm * ( sens * amplitude * (p2 - p1).length)
    # Trace("halfnormal #{halfnormal.inspect}")
    newpoint = halfpoint + halfnormal
    tpoint = halfpoint + halfnormal * 3.0
    t1 = (tpoint - p1 ) / 6.0
    t2 = (tpoint - p2 ) / 6.0
    # Trace("newpoint #{newpoint.inspect} p1 #{p1.inspect} (newpoint - p1) #{(newpoint - p1).inspect}")
    # TODO: following lines repetitive
    halftangent = self.support.tangent( mabs ).norm * (newpoint - p1).length / 3.0
    halftangent = self.support.tangent( mabs ).norm * (p2 - p1).length / 3.0
    # Trace("halftangent #{halftangent.inspect} t1 #{t1.inspect} t2 #{t2.inspect}")
    return [[:vector, p1, t1, newpoint, -halftangent], [:vector, newpoint, halftangent, p2, t2]]
  end
  
  def compute_interpol( abs1, abs2, amplitude, sens )
    orientation = amplitude > 0.0 ? 1.0 : -1.0
    arc = Bezier.multi( self.compute_arc( abs1, abs2, orientation, sens ) )
    subsupport = self.support.subbezier( abs1, abs2 )
    return InterBezier[ :bezierlist, [0.0, subsupport, 1.0, arc] ].sample( amplitude.abs ).data
  end

  # algo : for each abscissa, 0.0 of the curve (given the normal)
  #    and for each mean abscissa, :amp normal
  def compute
    abscissas = self.abscissasampler.samples( self.freq + 1 )
    sens = 1.0
    pieces = []
    [abscissas.pairs, self.ampl.samples( self.freq )].forzip do |abspair, amplitude|
      abs1, abs2 = abspair
      pieces += self.compute_interpol( abs1, abs2, amplitude, sens )
      sens *= -1.0
    end
    return pieces
  end
end

end # XRVG
