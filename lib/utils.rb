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
  
  # constant for (0.0..1.0) range
  #
  # must be used only as const (else use Range.O)
  O = (0.0..1.0)

  # constant for Angle range
  #
  # must be used only as const (else use Range.Angle)
  Angle = (0.0..2.0*Math::PI)
  
  # return unitary range, that is 
  #   (0.0..1.0) 
  def Range.O
    return Range::O.clone
  end

  # return angle range, that is
  #   (0.0..2.0*Math::PI)
  def Range.Angle
    return Range::Angle.clone
  end

  # return symetric angle between 0 and of size .. 2*size
  #   (-size..size)
  def Range.sym( size )
    size = size > 0.0 ? size : -size
    return (-size..size)
  end

  # compute the symetric of value in context of range
  #  (0.0..1.0).complement( 0.3 ) => 0.7
  #  (1.0..2.0).complement( 1.3 ) => 1.7
  def complement( value )
    diff = value - self.begin
    result = (self.end - diff)
    return result
  end

  # utilitary method to force value to be in range
  #  (0.0..1.0).trim( 3.0  ) => 1.0
  #  (0.0..1.0).trim( -3.0 ) => 0.0
  def trim( value )
    if value >= self.max
      result = self.max
    elsif value <= self.min
      result = self.min
    else
      result = value
    end
    return result
  end

  # return modulo of value given interval
  #  (-1.0..1.5).modulo( 2.0 ) => -0.5
  #
  # TODO: manage special case range size = 0.0
  def modulo( value )
    return ((value - self.min)%self.size + self.min)
  end

  # compute list of "modulo boundaries"
  #  (-1.0..1.5).modulos( (-1.2..2.4) ) => [(1.3..1.5), (-1.0..1.5), (-1.0..0.4)]
  def modulos( range )
    t1 = self.modulo( range.min )
    t2 = self.modulo( range.max )
    s1 = ((range.min - self.min)/self.size).floor
    s2 = ((range.max - self.min)/self.size).floor
    if s1 == s2
      result = [(t1..t2)]
    else
      result = [(t1..self.max)]
      (s2-s1-1).times do 
	result << (self.min..self.max)
      end
      if t2 - self.min > 0.0
	result << (self.min..t2)
      end
    end
    if range.begin > range.end
      result = result.reverse.map {|v| v.reverse}
    end
    # Trace("modulos range #{range.inspect} result #{result.inspect}")
    return result
  end

  # return max value of range
  def max
    return (self.begin > self.end) ? self.begin : self.end
  end

  # return min value of range
  def min
    return (self.begin < self.end) ? self.begin : self.end
  end

  # return size of the range
  def size
    return (self.max - self.min)
  end

# -------------------------------------------------------------
#  Samplable interface include and overriding
# -------------------------------------------------------------
  include XRVG::Samplable
  include XRVG::Splittable

  # Range base FloatFunctor overloading to do
  #   (1.0..2.0).sample( 0.3 ) => 1.3
  #   (1.0..2.0).samples( 3 )  => [1.0, 1.5, 2.0]
  def transform( value )
    return (self.begin + ( self.end - self.begin ) * value)
  end

  # Very fundamental generator
  #
  # Generates a sequence of "nsamples" floats between 0.0 and 1.0 (included)
  def Range.generate( nsamples )
    result = []
    if nsamples == 1
      result = [0.0]
    else
      (nsamples).times {|i| result.push( i.to_f / (nsamples-1) )}
    end
    return result
  end
  
  # Simply redirect on Range.generate
  def generate( nsamples ) #:nodoc:
    return Range.generate( nsamples )
  end

  # apply_sample is good by default
  # apply_split  is good by default

  # returns a reversed range 
  #  (1.0..2.0).reverse => (2.0..1.0)
  def reverse
    return Range.new( self.end, self.begin )
  end
  
  # returns an increasing Range
  #  (2.0..1.0).sort => (1.0..2.0)
  def sort
    return (self.begin > self.end ? Range.new( self.end, self.begin ) : Range.new( self.begin, self.end ))
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
    if self.begin == self.end
      return self.begin
    else
      return (value - self.begin) / (self.end - self.begin)
    end
  end
  
  # return a new range with boundaries translated of "value"
  #   (1.0..2.0).translate( -1.0 ) => (0.0..1.0)
  def translate( value )
    return (self.begin + value..self.end + value)
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

  # alias for .random.samples
  def rand(nsamples=1,&block)
    inputs = []
    nsamples.times {|v| inputs.push( Kernel::rand )}
    result = self.process( inputs, :sample, &block )
    return nsamples == 1 ? result[0] : result
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

#
# Array extension (see SyncS for enumeration synchronisation)
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
  #  [V2D[-1.0,-1.0], V2D[1.0,1.0]].sum => V2D[0.0,0.0]
  #  [curve1, curve2].sum                     => concatenation of curves
  def sum
    sum = self[0]
    self[1..-1].each {|v| sum += v}
    return sum
  end

  # returns the mean of the array content
  #  [V2D[0.0,0.0], V2D[1.0,1.0]].mean => V2D[0.5,0.5]
  def mean
    return self.sum / self.size
  end

  # return a random item from array
  def choice
    return self[Kernel::rand(self.size)]
  end

  # return an array with same elements as self, but rotated
  def rotate(sens=:right)
    result = []
    if sens == :right
      result = [self[-1]] + self[0..-2]
    else
      result = self[1..-1] + [self[0]]
    end
    return result
  end

  # generate every rotation for the array, with as first element self
  def rotations(sens=:right)
    result = [self]
    current = self
    (self.size-1).times do 
      result << current.rotate(sens)
      current = result[-1]
    end
    return result
  end

  # compute range of an array by returning (min..max)
  #   [1.0, 3.0, 2.0].range => (1.0..3.0) 
  # if proc supplied, use it to return range of subvalues
  #  [V2D::O, V2D::X].range( :x ) => (0.0..1.0)
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
      return self.each_slice(arity).to_a
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
      return self.each_cons(arity).to_a
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

  # shuffle values in array
  def shuffle
    return self.sort_by{ rand }
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

# Ruby base class Float extension
#
# Mainly to be able to compare two floats with specific accuracy
class Float
  
  # compare two Float with specific precision
  #  assert( 0.25.fequal?( 0.26,0.02) )
  #  assert_equal( false, 0.25.fequal?( 0.26,0.01) )
  def fequal?( other, epsilon=0.0000000001 )
    return ((self - other).abs < epsilon)
  end

  # sort and remove duplicated elements of a float list with specific precision
  #    assert_equal( [0.25],      Float.sort_float_list([0.26,0.25], 0.02 ) )
  #    assert_equal( [0.25,0.26], Float.sort_float_list([0.26,0.25], 0.01 ) )
  def Float.sort_float_list( floatlist, epsilon=0.0000001 )
    floatlist = floatlist.uniq.sort
    result = [floatlist[0]]
    floatlist[1..-1].each do |item|
      if not item.fequal?( result[-1], epsilon)
	result.push( item )
      end
    end
    return result
  end

  # check if an Float item is included in a Float list, with specific precision
  #   assert( Float.floatlist_include?( [1.0,2.0,3.0001,4.0], 3.0, 0.001 ) )
  #   assert_equal( false, Float.floatlist_include?( [1.0,2.0,3.0001,4.0], 3.0, 0.0001 ) )
  def Float.floatlist_include?( floatlist, float, epsilon=0.0000001 )
    floatlist.each do |item|
      if item.fequal?( float, epsilon )
	return true
      end
    end
    return false
  end
end

