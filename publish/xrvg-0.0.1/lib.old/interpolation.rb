# Interpolation file.
#
# See
# - +Interpolation+
# - +Interpolator+

require 'utils'
require 'attributable'

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
    return [0.0, 0.0, 1.0, 1.0]
  end

  # computing method
  #
  # from an input between 0.0 and 1.0, returns linear interpolated value
  def interpolate( dindex )
    result = nil
    pvalue, pindex = self.samplelist[0..1]
    self.samplelist.foreach do |value, index|
      if dindex <= index
	if dindex == index
	  return value
	end
	result = pvalue + ((value - pvalue ) * ((dindex - pindex) / (index - pindex )))
	break
      end
      pvalue, pindex = value, index
    end
    if not result
      result = self.samplelist[-2]
    end
    return result
  end
end

# Buildable interpolator
# 
# Simply instanciated module in a class
class Interpolator
  include Attributable
  attribute :samplelist
  include Interpolation
end
