# 
# Several Ruby base class extensions
#
# Please also refer to the following link[http://xrvg.rubyforge.org/], and more particularly this[http://xrvg.rubyforge.org/RubyXRVGExtension.html], for
# further details. 
#
# This contains :
# - +Range+ extension
# - +Array+ extension

require 'enumerator'
require 'trace'
require 'samplation'
require 'assertion'

#
# Extend class Range with module Samplable and other utilitary methods
# = Intro
# Range class is used in XRVG as a continuous 1D float interval.
# See this[http://xrvg.rubyforge.org/RubyXRVGExtension.html] for presentation
# = Use
#  (0.0..1.0).rand
#  (0.0..1.0).middle                    # => 0.5
#  (0.0..2.0).sample(0.3)               # => 0.6
#  (0.0..1.0).samples( 3 ) {|v| puts v} # => "0.0" "0.5" "1.0"
#   
class Range

  # return unitary range, that is 
  #   (0.0..1.0) 
  def Range.O
    return (0.0..1.0)
  end

  # return angle range, that is
  #   (0.0..2.0*Math::PI)
  def Range.Angle
    return (0.0..2.0*Math::PI)
  end

  # compute the symetric of value in context of range
  #  (0.0..1.0).complement( 0.3 ) => 0.7
  def complement( value )
    diff = value - self.begin
    return (self.end - value)
  end


# -------------------------------------------------------------
#  Samplable interface include and overriding
# -------------------------------------------------------------
  include Samplable
  include Splittable

  # Range base FloatFunctor overloading to do
  #   (1.0..2.0).sample( 0.3 ) => 1.3
  #   (1.0..2.0).samples( 3 )  => [1.0, 1.5, 2.0]
  def transform( value )
    return (self.begin + ( self.end - self.begin ) * value)
  end

  # to speed up samplation on ranges, as used everywhere
  def generate( nsamples ) #:nodoc:
    result = []
    if nsamples == 1
      result = [0.0]
    else
      (nsamples).times {|i| result.push( i.to_f / (nsamples-1) )}
    end
    return result
  end

  # apply_sample is good by default
  # apply_split  is good by default

  # size of the range
  #  (0.0..2.0).size => 2.0
  def size
    return self.end - self.begin
  end

  # returns a reversed range 
  #  (1.0..2.0).reverse => (2.0..1.0)
  def reverse
    return Range.new( self.end, self.begin )
  end

  # resize range by factor, with fixed point center of the range
  #  (1.0..2.0).resize( 0.5 ) => (1.25..1.75) 
  def resize( factor )
    center   =  self.sample( 0.5 )
    halfsize =  self.size / 2.0
    newhalfsize = halfsize * factor
    return (center - newhalfsize .. center + newhalfsize)
  end

  # mean value of the range (equiv to sample( 0.5 ))
  # -> define in Samplable
  # def mean()
  #  return self.sample( 0.5 )
  # end
  
  # alias mean as middle, as sample( 0.5 )
  # -> define in Samplable
  # alias middle mean

  # return range with previous begin as new middle
  #  (1.0..2.0).sym => (0.0..2.0)
  def sym()
    return (self.begin - (self.end - self.begin ) .. self.end )
  end

  # return range with previous end as new middle
  #  (1.0..2.0).symend => (1.0..3.0)
  def symend()
    return (self.begin .. self.end + (self.end - self.begin ) )
  end

  # inverse function of .sample
  #   (1.0..2.0).abscissa( 0.3 ) => 1.3
  def abscissa( value )
    return (value - self.begin) / (self.end - self.begin)
  end
  
  # return a new range with boundaries translated of "value"
  #   (1.0..2.0).translate( -1.0 ) => (0.0..1.0)
  def translate( value )
    return (self.begin + value..self.end + value)
  end
  
end

#
# Array extension to synchronize enumerations, and also provide other recurrent services
# See this[http://xrvg.rubyforge.org/RubyXRVGExtension.html] for presentation
#
class Array

  # take only the nieme elements
  #
  # Experimental
  #   [1, 2, 3, 4].sub(2) => [1, 3]
  def sub(period, &block)
    result = []
    self.foreach(period) do |slice|
      item = slice[0]
      if block
	yield item
      else
	result.push( item )
      end
    end
    return result
  end

  # return the sum of the elements of the Array
  # works for array whose content defines the + operator
  #  [1.0, 2.0].sum                           => 3.0
  #  [Vector[-1.0,-1.0], Vector[1.0,1.0]].sum => Vector[0.0,0.0]
  #  [curve1, curve2].sum                     => concatenation of curves
  def sum
    sum = self[0]
    self[1..-1].each {|v| sum += v}
    return sum
  end

  # returns the mean of the array content
  #  [Vector[0.0,0.0], Vector[1.0,1.0]].mean => Vector[0.5,0.5]
  def mean
    return self.sum / self.size
  end

  # compute range of an array
  # - if proc nil, returns (min..max)
  # - else, first compute new array with proc, then (min..max) on this array
  #   [1.0, 3.0, 2.0].range => (1.0..3.0) 
  def range( proc=nil )
    if not proc
      return (self.min..self.max)
    else
      arraytmp = self.map {|item| item.send( proc )}
      return arraytmp.range
    end
  end

  # alias for sub(2)
  #  [1,2,3,4].half => [1,3]
  def half( &block )
    return sub(2,&block)
  end

  # flatten an array of arrays
  #  [[1,1], [2,2]].flattenonce => [1,1,2,2]
  def flattenonce
    result = []
    self.each do |subarray|
      result += subarray
    end
    return result
  end

  # same as Enumerator.each_slice with implicit size given by block.arity, or explicit if no blocks
  # (in that case, return array of array)
  # same enumeration model as for Tcl foreach command (see Array.zip method for further compatibility)
  #   [1,2,3,4].foreach {|v1,v2| puts "#{v1} #{v2}"} => "1 2" "3 4"
  def foreach( arity=nil, &block )
    if not arity
      arity = block.arity
    end
    if block
      if arity == 1
	return self.each( &block )
      else
	return self.each_slice(arity, &block)
      end
    else
      return self.enum_slice(arity).to_a
    end
  end

  # same as Enumerator.each_cons with implicit size given by block.arity, or explicit if no blocks
  # (in that case, return array of array)
  #   [1,2,3,4].uplets {|v1,v2| puts "#{v1} #{v2}"} => "1 2" "2 3" "3 4"
  def uplets(arity=nil, &block )
    if not arity
      arity = block.arity
    end
    if block
      return self.each_cons(arity, &block)
    else
      return self.enum_cons(arity).to_a
    end
  end

  # alias for uplets(2, &block)
  #   [1,2,3,4].pairs {|v| puts "#{v[0]} #{v[1]}"} => "1 2" "2 3" "3 4"
  def pairs( &block )
    return self.uplets(2, &block)
  end

  # alias for uplets(3, &block)
  #   [1,2,3,4].pairs {|v| puts "#{v[0]} #{v[1]} #{v[2]}"} => "1 2 3" "2 3 4"
  def triplets( &block )
    return self.uplets(3, &block)
  end

  # aarity = array of arity
  # if nil, default value is Array.new( self.size, 1 )
  # size of aarity must be inferior or equal to self.size. If inferior, is completed with 1
  # Rke : with array size 1, is equivalent to foreach
  #    [ [1,2,3,4], [a,b] ].forzip( [2,1] ) => [1,2,a,3,4,b]
  #    [ [1,2,3,4], [a,b] ].forzip          => [[1,a], [2,b], [3,nil], [4,nil]]
  #    [ [a,b], [1,2,3,4] ].forzip          => [[a,1], [b,2], [nil,3], [nil,4]]
  def forzip(aarity=nil, &block)
    if not aarity
      aarity = Array.new( self.size, 1 )
    end
    if aarity.size < self.size
      aarity = aarity.concat( Array.new( self.size - aarity.size, 1 ) )
    end
    tozip = Array.new
    self.zip( aarity ) do |subarray, arity|
      tozip.push( subarray.foreach(arity) )
    end
    result = tozip[0].zip( *tozip[1..-1] )
    result = result.flattenonce.flattenonce
    if block
      return result.foreach( nil, &block )
    end
    return result
  end

  # in same idea as forzip, but with explicit array index
  # if pattern is nil, is equivalent to [0,1,..., self.size-1]
  #   [ [1,2,3,4], [a,b] ].forpattern( [0,0,1] ) => [1,2,a,3,4,b]
  #   [ [1,2,3,4], [a,b] ].forpattern( [0,1,0] ) => [1,a,2,3,b,4]
  # 
  # Rke : an interesting application is to use this method to filter some item periodically
  #       for example [[array]].forpattern( [0,0] ) {|i,j| result.push( i )} take only first item on a pair (to be tested)
  # Rke2 : not so usefull for the moment (since compared with forzip, the only added value is to allow permutations of values between different subarrays)
  def forpattern(pattern, &block)
    cindexes = Array.new( self.size, 0 )
    result = []
    while true
      newitem = []
      pattern.each do |arrayindex|
	newitem.push( self.[]( arrayindex )[ cindexes[ arrayindex] ] )
	cindexes[ arrayindex] += 1
      end
      if newitem.compact.size == 0
	break
      end
      result += newitem
    end
    # result = result.flatten
    if block
      return result.foreach( nil, &block )
    end
    return result
  end

# -------------------------------------------------------------
#  Samplable interface include and overriding
# -------------------------------------------------------------
  include Samplable
  include Splittable

  # FloatFunctor overloading to synchronize content sampling and splitting
  def compute( inputs, type )
    return self.map {|v| v.compute( inputs, type )}.forzip
  end

end

# -------------------------------------------------------------
#  String class
# -------------------------------------------------------------

class String #:nodoc:

  def subreplace (tokens)
    gsub(/#{tokens.keys.join("|")}/) { tokens[$&] }
  end

end

class Float #:nodoc:

  def complement( max = 1.0, min = 0.0 )
    return ( max - ( self.to_f - min ) )
  end

  def randsplit(minsize=0.0)
    v = self.to_f
    rand = minsize + Kernel::rand * (1.0 - minsize )
    min = v * rand
    max = v - min
    return [min, max]
  end

end


class Integer #:nodoc:


  def randsplit!(minsize=0.0)
    size  = 1.0
    nsplit = self.to_i
    rsize = size - nsplit * minsize
    if rsize < 0.0
      return []
    end
    
    minsizes = Array.new( nsplit, minsize )
    # puts "minsizes #{minsizes.join(" ")}"
    
    randarray = [0.0]
    subarray = (0.0..rsize).rand( nsplit - 1 )
    Trace("subarray #{subarray.inspect}")
    randarray += subarray
    randarray.push( rsize )
    randarray.sort!

    # puts "randarray #{randarray.join(" ")}"
    
    rsizes = Array.new
    randarray.each_cons(2) { |min, max| rsizes.push( max - min ) }

    # puts "rsizes #{rsizes.join(" ")}"
    
    result = Array.new
    minsizes.zip( rsizes ) {|minsize, rsize| result.push( minsize + rsize )}
    
    # puts "result randsplit! #{result.join(" ")}"

    return result
  end

  def randsplitsum!(minsize=0.0)
    preresult = self.randsplit!(minsize)
    
    result = Array.new
    sum = 0
    preresult.each {|v| sum += v; result.push( sum ) }
    
    # puts "result randsplitsum! #{result.join(" ")}"
    return result
  end


end

