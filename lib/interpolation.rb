# Interpolation file.
#
# See
# - +Interpolation+
# - +Interpolator+
# - +InterpolatorBinaryTree+

require 'utils'

module XRVG
# Interpolation module
# = Intro
# Defines an interpolation service from a samplelist that must be a list [value1, index1, value2, index2, ..., valueN, indexN],
# with index between 0.0 and 1.0 and in increasing order.
# value must be an object with + and * scalar operators defined
# = Uses
# Used for example by Palette
# = Future
# Must be extended for all kinds of interpolation (bezier, ...)
module Interpolation
  
  # must be the overloaded method to adapt Interpolation
  #
  # for example, Palette redefines samplelist as
  #  alias samplelist colorlist
  def samplelist()
    raise NotImplementedError.new("#{self.class.name}#samplelist is an abstract method.")
  end

  # must be the overloaded method to adapt Interpolation
  #
  # is usually provided by a side-effect of a :attribute declaration in including class
  def interpoltype()
    return :linear
  end

  # overall computation method
  #
  # from an input between 0.0 and 1.0, returns an interpolated value computed by interpolation method deduced from interpoltype
  def interpolate( dindex )
    return method( self.interpoltype ).call( dindex )
  end

  def build_indices #nodoc
    @indices = []
    @values  = []
    samplelist.foreach do |index,value|
      @indices << index
      @values  << value
    end
  end

  # computing method
  #
  # from an input between 0.0 and 1.0, returns linear interpolated value
  #
  # interpolate uses + and * scalar operators on interpolation values
  def linear( dindex )
    #puts "interpolate dindex #{dindex}"
    #puts "interpolate indices #{@indices.inspect}"
    #puts "interpolate values #{@values.inspect}"

    if not defined? @indices
      build_indices
    end
    
    if @indices.length == 1
      return @values[0]
    end

    irange = [0, @indices.length-1]

    if dindex < @indices[irange[0]]
      dindex = @indices[irange[0]]
    elsif dindex > @indices[irange[1]]
      dindex = @indices[irange[1]]
    end

    maxiter = 1000
    niter = 0
    while (irange[1]-irange[0] >1 and niter < maxiter)
      niter += 1
      if dindex == @indices[irange[0]]
	return @values[irange[0]]
      elsif dindex == @indices[irange[1]]
	return @values[irange[1]]
      else
	imean   = ((irange[1]+irange[0])/2).to_i
	if dindex <= @indices[imean]
	  newirange = [irange[0],imean]
	else
	  newirange = [imean, irange[1]]
	end
	irange = newirange
      end
    end

    if niter == maxiter
      Kernel::raise("WARNING: niter maxiter for dindex #{dindex} and @indices #{@indices}")
    end
    
    pindex, pvalue, index, value = [@indices[irange[0]], @values[irange[0]], @indices[irange[1]], @values[irange[1]]]
    # puts "dindex #{dindex} pindex #{pindex}, pvalue #{pvalue}, index #{index}, value #{value}"
    if pindex.fequal?(index)
      result = value
    else
      result = pvalue + ((value + pvalue * (-1.0) ) * ((dindex - pindex) / (index - pindex )))
    end
    # puts "interpolate result #{result}"
    return result
  end
end

# Buildable interpolator
# 
# Simply instanciated module in a class
class Interpolator
  include Attributable
  attribute :samplelist
  attribute :interpoltype, :linear
  include Interpolation
  include Samplable
  alias apply_sample interpolate
end

end
