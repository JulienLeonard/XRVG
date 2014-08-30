# BezierBuilder file
# See:
# - BezierBuilder
# - SimilarMotifIterator
# - AttributeMotifIterator
# - FitBezierBuilder

require 'bezier'
require 'fitting'

module XRVG

# = BezierBuilder class
# == Content
# Abstract class to define prototype of a bezier factory
#
# Provides the notation
#  bezierresult = BezierBuilder[ :parameter1, arg1, :parameter2, arg2 ]
# with bezierresult the computed Bezier object from the BezierBuilder algorithm
class BezierBuilder
  include Attributable

  # Hook for subclassing : must return a list of raw pieces, to be provided to Bezier.multi
  def compute()
    raise NotImplementedError.new("#{self.class.name}#compute is an abstract method.")
  end

  # syntax sugar method to replace BezierBuilder.build notation with the simpler BezierBuilder[] one
  #
  # Note that BezierBuilder[] does not return a BezierBuilder object, but a Bezier one
  def BezierBuilder.[](*args)
    return self.build( *args )
  end

  # create the BezierBuilder, and build a Bezier.multi by calling BezierBuilder.compute
  def BezierBuilder.build( *args )
    builder = self.new( *args )
    return Bezier.multi( builder.compute )
  end

  # multipiece bezier operator to smooth tangents of piece junctions
  #
  # Algo:
  # - for each pair of pieces, take last and first vector
  # - compute the mean of these vectors
  # - for each vector, linearly interpolate given :factor between initial vector and mean
  # As a consequence, default :factor value means that by default, we take vector means, and this operator
  # do nothing if you set :factor to 0.0
  def BezierBuilder.lissage( bezier, factor=1.0 )
    result = [[:vector] + (bezier.pieces[0].pointlist(:vector))[0..1]]
    bezier.pieces.pairs do |piece1, piece2|
      p = piece1.lastpoint;# equal to piece2.firstpoint
      v1, v2 = [-piece1.lastvector, piece2.firstvector]
      mean = (v1..v2).mean
      newv1 = (v1..mean).sample( factor )
      newv2 = (v2..mean).sample( factor )
      result[-1] += [p,-newv1]
      result << [:vector, p, newv2]
    end
    result[-1] += (bezier.pieces[-1].pointlist(:vector))[-2..-1]
    return Bezier.multi( result )
  end
end


#-------------------------------------------------------------------------------
# We can now build on these atomic motifs some motif iterators
#-------------------------------------------------------------------------------

# = Similar Motif Iterator
# == Content
# Take a bezier curve as :motif, and a "curvesampler" as a support with sampling description, and iterate motif on each pair computed by sampling
# == Attributes
#  attribute :curvesampler, nil, Samplable
#  attribute :motif, nil, Bezier
#  attribute :nmotifs, 10
# == Example
#  motif        = PicBezier[ :support, [V2D::O, V2D::X], :height, -1.0 ]
#  curvesampler = bezier.geo( 3.0 )
#  bezier       = SimilarMotifIterator[ :curvesampler, curvesampler, :motif, motif, :nmotifs, 10 ]
# == TODO
# Represents the basic operator to compute bezier fractal curves !!
class SimilarMotifIterator < BezierBuilder
  attribute :curvesampler, nil, Samplable
  attribute :motif, nil, Bezier
  attribute :nmotifs, 10

  # BezierBuilder overloading
  #
  # Algo
  # - sample @nmotif+1 times @curvesampler to get @nmotifs point pairs
  # - foreach pair, compute new bezier by calling Bezier.similar on @motif
  def compute
    result = []
    self.curvesampler.samples( self.nmotifs + 1).pairs do |p1,p2|
      # Trace("SimilarMotifIterator::compute p1 #{p1.inspect} p2 #{p2.inspect}")
      newbezier = self.motif.similar( (p1..p2) )
      result += newbezier.data
    end
    return result
  end

end

# = Attribute Motif Iterator
# == Content
# More advanced motif iterator than SimilarMotifIterator, and also more expensive, AttributeMotifIterator samples
# a curvesampler and foreach pair build a new bezier motif, with varying attributes
# == Attributes
#  attribute :curvesampler, nil, Splittable
#  attribute :motifclass
#  attribute :nmotifs, 10
#  attribute :attributes, [], Array
#  attribute :closed, false
# :motifclass is a BezierBuilder class, as ArcBezier, PicBezier, or even AttributeMotifIterator...
#
# :attributes is of the form [attribute1, specification1, :attribute2, specification, ...] with
# - attribute1, attribute2 attributes of the :motifclass
# - specification can be : 
#   - single value
#   - sampler
#
# :closed attribute state if each subbezier computed for each point pair must be closed with the corresponding subbezier of the :curvesampler
# == Example
#  motif        = PicBezier[ :support, [V2D::O, V2D::X], :height, -1.0 ]
#  curvesampler = bezier.geo( 3.0 )
#  result = AttributeMotifIterator[ :curvesampler, curvesampler, :motifclass, ArcBezier, :attributes, [:height, (-2.0..0.0).random], :nmotifs, 30, :closed, true ]
# == WARNING
# Only works with BezierMotif defined by two points
class AttributeMotifIterator < BezierBuilder
  attribute :curvesampler, nil, Splittable
  attribute :motifclass
  attribute :nmotifs, 10
  attribute :attributes, [], Array
  attribute :closed, false

  # BezierBuilder overloading
  #
  # See AttributeMotifIterator class description for details
  def compute
    result = []
    attrvalues = []
    self.attributes.foreach do |name, spec|
      attrvalues += [name, Samplable.build( spec ).samples( self.nmotifs )]
    end
    self.curvesampler.splits( self.nmotifs ).each_with_index do |subbezier,index|
      pair = [subbezier.firstpoint, subbezier.lastpoint]
      p1, p2 = pair
      args = [:support, pair]
      attrvalues.foreach do |name, values|
	args += [name, values[index]]
      end
      newbezier = self.motifclass[ *args ]
      if self.closed
	newbezier = newbezier + subbezier.reverse
      end
      result += newbezier.data
    end
    return result
  end

end

# = FitBezierBuilder class
# == Content
# Build a bezier from a point list defined by :points by computing adaptative multipiece bezier fitting.
#
# While this class is by itself quite usefull, it can also be subclassed by overloading "points" method to
# compute all sorts of curve (as Offset for example)
# == Attributes
#    attribute :points, [], Array; # to be able to subclass FitBezierBuilder to compute points by diverse means
#    attribute :maxerror, 0.001
# :maxerror attribute represents the bezier curve matching error (as explained in Fitting)
class FitBezierBuilder < BezierBuilder
  attribute :points, [], Array; # to be able to subclass FitBezierBuilder to compute points by diverse means
  attribute :maxerror, 0.001
  
  def FitBezierBuilder.build( *args )
    builder = self.new( *args )
    return Fitting.adaptative_compute( builder.points, builder.maxerror )[0]
  end

end

# Extend Circle class for subcurve definition
class Circle
  # return approximating bezier curve
  def bezier
    # following computation is too expensive
    # return FitBezierBuilder[ :points, self.samples( 20 ) ]

    # based on http://www.whizkidtech.redprince.net/bezier/circle/
    kappa = 0.5522847498

    beziers = []
    self.frames( (0.0..1.0).samples(5) ).pairs do |f1,f2|
      beziers << Bezier.vector( f1.center, f1.vector.norm * kappa * self.radius, f2.center, f2.vector.norm * kappa * (-self.radius) )
    end

    result = beziers[0]
    beziers[1..-1].each do |b|
      result = result + b
    end

    return result
  end
end


end # end XRVG
