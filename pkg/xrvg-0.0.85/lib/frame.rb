# frame.rb file
# 
# See +Frame+
require 'attributable'

module XRVG
#
# Frame class
# = Intro
# Defines a local geometry. Used by +Curve+ interface.
# = Attributes
#   attribute :center
#   attribute :vector
#   attribute :rotation
#   attribute :scale
class Frame
  include Attributable
  attribute :center
  attribute :vector
  attribute :rotation
  attribute :scale

  def ==(other)
    if self.center == other.center and
	self.vector == other.vector and
	self.rotation == other.rotation and
	self.scale == other.scale
      return true
    end
    return false
  end
end
end
