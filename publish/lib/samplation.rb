#
# Define float series functional processing
# The base module is FloatFunctor, used by Samplable and Splittable
#

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
  # is private ?
  def addfilter( newfilter )
    # Trace("Sampler addfilter method self #{self.inspect}")
    if not @subfilter
      @subfilter = newfilter
    else
      # Trace("Sampler addfilter recurse on subfilter #{@subfilter.inspect}")
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
  def compute( indata, type )
    return self.apply( self.modify( indata ), type )
  end

  # hook for rand()
  def process( indata, type, &block )
    outdata    = self.compute( indata, type )
    if not block
      # Trace("Samplable#trigger object #{self.inspect} indata #{indata.inspect} outdata #{outdata.inspect}")
      return outdata
    else
      outdata.foreach(nil,&block)
    end
  end

  # recursive method to compose modifications.
  #
  # must not be overloaded
  def modify( inputs )
    # Trace("Samplable#modify object #{self.inspect} inputs #{inputs.inspect}")
    if @subfilter
      inputs = @subfilter.modify( inputs )
    end
    result = self.transforms( inputs )
    # Trace("Samplable#filter object #{self.inspect} inputs #{inputs.inspect}  result #{result.inspect}")
    return result    
  end
  
  # to be overloaded if needed
  def transforms( inputs )
    return inputs.map {|abs| self.transform( abs )}
  end

  # to be overloaded
  def transform( abs )
    return abs
  end

  # default generator method
  def generate( nsamples )
    # Trace("Samplable#generate object #{self.inspect} nsamples #{nsamples}")
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
  def apply( data, type )
    @applyhash = self.applyhash
    if not @applyhash.key? type
      Kernel::Raise("FloatFunctor::apply no regsitration for type #{type} and  object #{object.inspect}")
    else
      return self.send(@applyhash[type], data )
    end
  end

# -------------------------------------------------------------
#   filters management
# -------------------------------------------------------------

  # geometric filter
  def geo( speed )
    return self.addfilter( Filter.with {|x| 1.0 - Math.exp(-speed * x)} )
  end

  # random filter
  def random()
    return self.addfilter( RandomFilter.new )
  end
  
  # sorting filter
  def ssort()
    return self.addfilter( SortFilter.new )
  end

  # shortcut method to build a sampler from self and a block
  def filter(samplemethod=:sample,&block)
    return Filter.new( self, samplemethod, &block )
  end


# -------------------------------------------------------------
#   old methods to be refactored
# -------------------------------------------------------------

  # deprecated
  #
  # ratios sum must be equal to 1.0
  def multisamples( nsamples, ratios )
    ratiosum  = ratios.sum
    samplesum = nsamples.sum
    ratios = ratios.map {|ratio| ratio / ratiosum}
    
    rratios = ratios
    index = 0
    ratios.each do |ratio|
      rratios[index] = ratio / nsamples[index]
      index += 1
    end
    
    sum = 0.0
    samples = [0.0]
    periodindex = 0
    while sum <= 1.0
      sum += rratios[ periodindex ]
      if sum > 1.0
	break
      end
      samples += [sum]
      periodindex += 1
      if periodindex >= rratios.length
	periodindex = 0.0
      end 
    end
    return self.samples( samples )
  end

  # deprecated
  #
  # TODO : must add gauss parameters
  def randgauss()
    begin 
      x1 = 2.0 * Kernel::rand - 1.0
      x2 = 2.0 * Kernel::rand - 1.0
      w  = x1 * x1 + x2 * x2
    end while w >= 1.0
    w = Math.sqrt( ( -2.0 * Math.log( w ) ) / w )
    return 1.0/2.0 * ( 1.0 + x1 * w )
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
    return self.apply( self.modify( [abs] ), :sample ).pop
  end

  # alias for sample( 0.5 )
  def mean()
    return self.sample( 0.5 )
  end

  # alias for mean
  alias middle mean
  
  # alias for .random.samples
  def rand(nsamples=1,&block)
    inputs = []
    nsamples.times {|v| inputs.push( Kernel::rand )}
    result = self.process( inputs, :sample, &block )
    return nsamples == 1 ? result[0] : result
  end

  # to be overloaded if needed
  #
  # called by FloatFunctor apply method
  def apply_samples( inputs )
    return inputs.map {|abs| self.apply_sample( abs ) }
  end

  # to be overloaded if needed
  def apply_sample( abs )
    return abs
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
	Kernel::Raise("Samplable#split method needs at least two data, instead of #{nsamples}")
      end
    else
      if nsamples.size < 2
	Kernel::Raise("Samplable#split method needs at least two data, instead of #{nsamples.inspect}")
      end
    end
    return self.trigger( nsamples, :split, &block )
  end

  # must not be overriden
  def split( abs1, abs2 )
    return self.apply( self.filter( [abs1,abs2] ), :split ).pop
  end

  # to be overloaded if needed
  def apply_splits( inputs )
    return inputs.pairs.map {|t1,t2| self.apply_split( t1, t2 )}
  end

  # to be overloaded if needed
  def apply_split( t1, t2 )
    return self.class.new( t1, t2 )
  end

  # apply_register( :split, :apply_splits )
end


# Filter class
# = Intro
# Filter class allows to call generically a method with arg between 0.0..0.1 on a given object, for use in a +FloatFunctor+ context.
# = Example
# this allow to do for example 
#  [bezier1.filter(:point), bezier1.filter(:tangent), palette].samples( 10 ) do |point, tangent, color|
class Filter

  include Samplable

  # identity functor
  def Filter.identity
    return Filter.new(nil,nil) {|x| x}
  end
  
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

# RandomFilter class, to resample randomly
class RandomFilter < Filter
  def initialize(*args)  #:nodoc:
  end
  
  def transform(abs)  #:nodoc:
    return (0.0..1.0).rand
  end
  
  def transforms( inputs )  #:nodoc:
    result = inputs.map { |v| self.transform( v ) }
    result[0]  = 0.0
    result[-1] = 1.0
    return result
  end
end

# SortFilter, to sort inputs (in particular from Random)
class SortFilter < Filter
  def initialize(*args)  #:nodoc:
  end

  def transforms( inputs )  #:nodoc:
    return inputs.sort
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

  # TODO : must be generalized
  def rand()  #:nodoc:
    index = (0.0..@items.size).rand.to_i
    return @items[index]
  end

end
