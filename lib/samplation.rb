#
# Define float series functional processing
# The base module is FloatFunctor, used by Samplable and Splittable
#

require 'attributable'

module XRVG
#
# Base module to define float lists processing and computation.
# = Design principle
# Composite design pattern, to be able to chain functors
# = Concepts
# on each functor object :
# - "trigger" method triggers float processing, that is 
#   * if arg is integer, call "generate" to get values
#   * else (array float values), just keep them
# - pass inputs to "process" method, which wraps "compute" method to be able to call block and iterate
# - "compute" method first call "modify" which is the recursive processing function
# - then call "apply" which is specific processing method of the functor
# - "apply" then dispatchs processing according to the processing "type", ie "sample" or "split"
# - by default, FloatFunctor provides "transforms" and "transform" to be used by "type" processing
module FloatFunctor
# -------------------------------------------------------------
#  essential recursivity chaining  method
# -------------------------------------------------------------

  # building recursivity method
  #
  # is private => no for Array
  def addfilter( newfilter )
    if not @subfilter
      @subfilter = newfilter
    else
      @subfilter.addfilter( newfilter )
    end
    return self
  end

# -------------------------------------------------------------
#  generic generator method
# -------------------------------------------------------------

  # must not be overloaded
  def trigger( nsamples, type, &block )
    if nsamples.is_a? Integer
      indata     = self.generate( nsamples )
    else
      indata     = nsamples
    end
    return self.process( indata, type, &block )
  end

  # hook for Array
  def compute( indata, type, &block )
    return self.apply( self.modify( indata, type ), type, &block )
  end

  # hook for rand()
  def process( indata, type, &block )
    if not block
      return self.compute( indata, type )
    else
      self.compute( indata, type, &block )
    end
  end

  # recursive method to compose modifications.
  #
  # must not be overloaded
  def modify( inputs, type )
    if @subfilter
      inputs = @subfilter.modify( inputs, type )
    end
    result = self.transforms( inputs, type )
    return result    
  end
  
  # to be overloaded if needed
  def transforms( inputs, type )
    return inputs.map {|abs| self.transform( abs )}
  end

  # to be overloaded
  def transform( abs )
    return abs
  end

  # default generator method
  def generate( nsamples )
    return (0.0..1.0).generate( nsamples )
  end

  #
  # apply interface
  #
  # it is a registration interface
  #
  # must not be overloaded

  # must be refactored with some meta hooks
  def applyhash
    result = {}
    result[:sample] = :apply_samples
    result[:split]  = :apply_splits
    return result
  end

  # must not be overloaded (apart from Samplable containers)
  def apply( data, type, &block )
    @applyhash = self.applyhash
    if not @applyhash.key? type
      Kernel::raise("FloatFunctor::apply no regsitration for type #{type} and  object #{self.inspect}")
    else
      return self.send(@applyhash[type], data, &block )
    end
  end

# -------------------------------------------------------------
#   filters management
# -------------------------------------------------------------

  # geometric filter
  def geo( speed )
    return self.addfilter( Filter.with {|x| 1.0 - Math.exp(-speed * x)} )
  end

  # geometric filter full
  def geofull( factor )
    return self.addfilter( GeoFullFilter.new( factor ) )
  end


  # sin filter
  def sin( speed=1.0, phase=0.0 )
    return self.addfilter( Filter.with {|x| Math.sin( speed * x * Math::PI + phase) } )
  end

  # random filter
  def random(*args)
    return self.addfilter( RandomFilter.new(*args) )
  end
  
  # sorting filter
  def ssort()
    return self.addfilter( SortFilter.new )
  end

  # shuffle filter
  def shuffle()
    return self.addfilter( ShuffleFilter.new )
  end
  

  # alternate filter
  def alternate()
    return self.addfilter( AlternateFilter.new )
  end
  
  # shortcut method to build a sampler from self and a block
  def filter(samplemethod=:sample,&block)
    return Filter.new( self, samplemethod, &block )
  end
    
end

# -------------------------------------------------------------
#  Samplable interface
# -------------------------------------------------------------

#
# Samplable module, based on FloatFunctor
# = Concept  
# Basically allows advanced item computations from an continuous "Interval" object. 
# Is used by :
# - Range for computing float values
# - Curve for computing points
# - Palette for computing colors
# - ...
module Samplable 
  include FloatFunctor
  
  # -------------------------------------------------------------
  #  sampling generator methods
  # -------------------------------------------------------------

  # fundamental method of the module
  # 
  # call the FloatFunctor trigger method, with type :sample
  #
  #   (0.0..1.0).samples( 3 ) => [0.0, 0.5, 1.0]
  def samples( nsamples, &block )
    return self.trigger( nsamples, :sample, &block )
  end

  # shortcut method to call float processing for one input
  #
  # is basically .samples([abs]).pop
  def sample( abs )
    type = :sample
    return self.apply( self.modify( [abs], type ), type ).pop
  end

  def rand(nsamples=1,&block)#:nodoc:
    if nsamples == 1
      return sample( Range.O.rand )
    else
      return samples( Range.O.rand(nsamples), &block )
    end
  end

  # alias for sample( 0.5 )
  def mean()
    return self.sample( 0.5 )
  end

  # alias for mean
  alias middle mean
  
  # to be overloaded if needed
  #
  # called by FloatFunctor apply method
  def apply_samples( inputs, &block )
    if not block
      return inputs.map {|abs| self.apply_sample( abs ) }
    else
      if inputs.length > 0
	container = self.apply_sample( inputs[0] ); yield container;
	inputs[1..-1].each {|abs| yield self.apply_sample( abs, container ) }
      end
    end
  end

  # to be overloaded if needed
  def apply_sample( abs, container=nil )
    return abs
  end

  # method to transform any object into samplable object
  #
  # used to add Attribute type :samplable
  def Samplable.build( value )
    if value.is_a? Array
      return Roller[*value]
    elsif value.is_a? Samplable
      return value
    else
      return Roller[value]
    end
  end

  # apply_register( :sample, :apply_samples )

end

# -------------------------------------------------------------
#  Splittable interface
# -------------------------------------------------------------

#
# Splittable module, based on FloatFunctor
# = Concept
# Basically allows advanced subdivision computations from an continuous "Interval" object. 
# = Example
#  (1.0..2.0).splits(2) => [(1.0..1.5), (1.5..2.0)]
module Splittable 
  include FloatFunctor

  # generator method for split interface.
  # Must not be overriden
  #
  # Basically call FloatFunctor trigger method with at least 2 data !!
  def splits( nsamples, &block )
    if nsamples.is_a? Integer
      nsamples += 1
      if nsamples < 2
	Kernel::raise("Samplable#split method needs at least two data, instead of #{nsamples}")
      end
    else
      if nsamples.size < 2
	Kernel::raise("Samplable#split method needs at least two data, instead of #{nsamples.inspect}")
      end
    end
    return self.trigger( nsamples, :split, &block )
  end

  # must not be overriden
  def split( abs1, abs2 )
    type = :split
    return self.apply( self.modify( [abs1,abs2], type ), type ).pop
  end

  # to be overloaded if needed
  def apply_splits( inputs, &block )
    result = inputs.pairs.map {|t1,t2| self.apply_split( t1, t2 )}
    if not block
      return result
    else
      result.each {|v| yield v}
    end
  end

  # to be overloaded if needed
  def apply_split( t1, t2 )
    return self.class.new( t1, t2 )
  end

  # apply_register( :split, :apply_splits )
end

# -------------------------------------------------------------
#  Samplation synchronisation
# -------------------------------------------------------------
class SyncS
  attr_accessor :items

  include Samplable
  include Splittable

  # FloatFunctor overloading to synchronize content sampling and splitting
  def compute( inputs, type, &block )
    return self.items.map {|v| v.compute( inputs, type )}.forzip(nil,&block)
  end

  def addfilter( newfilter )
    self.items.each {|v| v.addfilter( newfilter )}
    return self
  end


  # create a new samplation synchronizer
  #  syncs = SyncS[ Range.O, Range.O.geo( 5.0 )]
  def SyncS.[]( *args )
    return SyncS.new(*args)
  end

  # builder
  def initialize( *args )
    newitems = []
    args.each do |item|
      if item.is_a? Array
	item = Roller[ *item ]
      end
      newitems << item
    end
    @items = newitems
  end
end
  

# -------------------------------------------------------------
#  Filter interface and classes
# -------------------------------------------------------------

# Filter class
# = Intro
# Filter class allows to call generically a method with arg between 0.0..0.1 on a given object, for use in a +FloatFunctor+ context.
# = Example
# this allow to do for example 
#  SyncS[bezier1.filter(:point), bezier1.filter(:tangent), palette].samples( 10 ) do |point, tangent, color|
class Filter
  include Samplable
  
  # to define a filter on "object" with method "samplemethod", or with a block (exclusive)
  #
  # from these two alternatives, returns a proc to call for float processing
  def initialize(object=nil, samplemethod=:sample, &block)
    if object
      # Trace("Filter::initialize object #{object.inspect} method #{samplemethod.inspect} ")
      @proc = object.method( samplemethod )
    else
      @proc = Proc.new( &block )
    end
  end

  # Samplable redefinition : call previous proc built from initialize to process float "abs"
  def transform( abs )
    result = @proc.call( abs )
    # Trace("Filter::transform abs #{abs} result #{result.inspect}")
    return result
  end

  # shortcut method aliasing Filter.new( nil, nil, &block)
  #
  # must change the name, because "with" seems to refer to LISP "with" design pattern, and this is not the case here
  def Filter.with( &block )
    return Filter.new( nil, nil, &block)
  end

end


# = RandomFilter class, to resample randomly
# == Attributes
#   attribute :mindiff, 0.0
#   attribute :sort, false
# :mindiff specifies which minimum interval must be preserved between random values. Of course, the number of sampling must then be above a given value so that this constraint can be verified.
class RandomFilter < Filter
  include Attributable
  attribute :mindiff, 0.0
  attribute :sort, false
  attribute :withboundaries, false

  # make sampling by trying to check :mindiff constraint
  # 
  # generate an exception if not possible
  def rawtransforms(nsamples)
    size  = 1.0
    nsplit = nsamples - 1
    rsize = size - nsplit * @mindiff
    if rsize < 0.0
      raise("RandomFilter rawtransforms error: nsamples #{nsamples} mindiff #{@mindiff} are incompatible")
    end
    
    mindiffs = Array.new( nsplit, @mindiff )
    
    # compute now nsplit values whose sum is <= to rsize
    randarray = [0.0]
    subarray = (0.0..rsize).rand( nsplit-1 )
    if not subarray.is_a? Array
      subarray = [subarray]
    end
    randarray += subarray
    randarray.push( rsize )
    randarray.sort!

    rsizes = Array.new
    randarray.each_cons(2) { |min, max| rsizes.push( (0.0..max-min).rand ) }

    rsum = rsizes.sum
    root = (0.0..(rsize-rsum)).rand

    # Trace("mindiffs #{mindiffs.inspect} rsizes #{rsizes.inspect} rsize #{rsize} rsum #{rsum} root #{root}")

    preresult = []
    mindiffs.zip( rsizes ) {|mindiff, rsize| preresult.push( mindiff + rsize )}

    result = [root]
    preresult.each {|v| newv = result[-1] + v; result << newv }

    return result
  end
  
  # do (0.0..1.0).rand to speed up computation if @mindiff is 0.0
  def basictransform( v )
    return (0.0..1.0).rand
  end

  def transforms( inputs, type )  #:nodoc:
    if type == :split
      @sort = true
    end
    if @mindiff == 0.0
      result = inputs.map { |v| self.basictransform( v ) }
      if @sort
	result = result.sort
      end
      if type == :split
	result[0]  = 0.0
	result[-1] = 1.0
      end
    else
      result = self.rawtransforms( inputs.size )
      if not @sort
	result = result.shuffle
      end
    end
    if self.withboundaries
      result[0] = inputs[0]
      result[-1] = inputs[-1]
    end
    return result
  end
end

# SortFilter, to sort inputs (in particular from Shuffle)
class SortFilter < Filter
  def initialize(*args)  #:nodoc:
  end

  def transforms( inputs, type )  #:nodoc:
    return inputs.sort
  end
end

# GeoFullFilter, to transform inputs into geometrical sequence converging to 1.0
class GeoFullFilter < Filter
  def initialize(factor)  #:nodoc:
    @factor = factor
  end


  # make sampling by trying to check :mindiff constraint
  # 
  # generate an exception if not possible
  def transforms( inputs, type )  #:nodoc:
    nsamples = inputs.size
    result = [1.0]
    (nsamples-1).times do
      result << result[-1] / @factor
    end
    range = (1.0..result[-1])
    result = result.map {|v| range.abscissa( v )}
    return result
  end
end


# ShuffleFilter, to unsort inputs (in particular from Random)
class ShuffleFilter < Filter
  def initialize(*args)  #:nodoc:
  end

  def transforms( inputs, type )  #:nodoc:
    return inputs.shuffle
  end
end


# AlternateFilter, to inverse one value per two
class AlternateFilter < Filter
  def initialize(range=nil)  #:nodoc:
    if range 
      self.addfilter( range )
    end
  end

  def transforms( inputs, type )  #:nodoc:
    result = []
    inputs.foreach do |v1, v2|
      result += [v1, -v2]
    end
    return result
  end
end

# Experimental class to add discrete processing in float processing chains
#  Roller["white","black"].samples(3) => ["white","black","white"]
class Roller
  include Samplable

  def initialize( *args )  #:nodoc:
    @index = 0
    @items = args
  end

  def Roller.[](*args)  #:nodoc:
    return self.new(*args)
  end

  def transform( abs )  #:nodoc:
    result = @items[@index]
    @index += 1
    if @index >= @items.size
      @index = 0
    end
    return result
  end

  def next()
    return transform( 0.0 )
  end
end

require 'attributable'
Attribute.addtype( :samplable, Samplable.method("build") )
end
