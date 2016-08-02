# File dedicated to Spiral curves
# - Spiral
# - SpiralParam
# - SpiralFrise

require 'shape'

module XRVG

# abstract class to define spiral types
# 
# use compute_radius to compute nsamples reference points, before interpolating with SimpleBezier
class GSpiral < Curve
  attribute :center, V2D::O, V2D
  attribute :ext,    V2D::O + V2D::X, V2D
  attribute :curvature, 1.0
  attribute :nsamples, 100
  attribute :sens, 1.0

  attr_accessor :angle0, :r0, :maxangle

  # delegate interfaces unknown for spiral to bezier
  # :length is computed by ParametricLength
  # extend Forwardable
  # def_delegators :bezier, :contour, :svg, :viewbox, :acc
  def contour( *args )
    return bezier.contour
  end

  def svg()
    return bezier.svg
  end

  def viewbox()
    return bezier.viewbox
  end

  def acc()
    return bezier.acc
  end

  #
  # builder
  #
  def initialize( *args )
    super( *args )
    @r0, @angle0 = (@ext - @center).coords(:polar)
  end

  include ParametricLength
  def parameter_range
    return (self.angle0..self.sens * self.maxangle)
  end

  def maxangle
    @maxangle ||= self.compute_maxangle( @r0, @angle0, @curvature )
  end

  def pointfromparameter( parameter, container )
    r = self.compute_radius( @r0, @angle0, @curvature, parameter )
    if not container
      container = V2D[ 0.0, 0.0]
    end
    container.xy = V2D.polar( r, parameter ).coords
    # Trace("parameter #{parameter} container #{container.inspect}")
    return container
  end

  # compute a point at curviligne abscissa
  #
  # curve method redefinition
  def point( l, container=nil )
    # Trace("point parameter #{l}")
    return pointfromparameter( parameterfromlength(l), container )
  end
  
  # compute tangent at curviligne abscissa
  #
  # curve method redefinition
  def tangent ( l, container=nil )
    raise NotImplementedError.new("#{self.class.name}#tangent is an abstract method.")
  end

  def compute_radius( r0, angle0, curvature, angle )
    raise NotImplementedError.new("#{self.class.name}#compute_radius is an abstract method.")
  end
  
  def compute_maxangle( r0, angle0, curvature )
    raise NotImplementedError.new("#{self.class.name}#compute_maxangle is an abstract method.")
  end

  def compute_bezier()
    return SimpleBezier.build( :support, self.refpoints )
  end

  def bezier
    @bezier ||= self.compute_bezier
  end

  def refpoints
    points = []
    self.parameter_range.samples( self.nsamples ) do |angle|
      r = self.compute_radius( r0, angle0, @curvature, angle )
      point = V2D.polar( r, angle )
      points.push( @center + point )
    end
    return points
  end

  # -------------------------------------------------------------
  #  sampler computation
  # -------------------------------------------------------------
  include Samplable
  include Splittable

  alias apply_sample point


end  

# at angle angle0,             r = r0
# at angle angle0 + curvature, r = 0.0
class SpiralLinear < GSpiral

  def compute_maxangle( r0, angle0, curvature )
    return (angle0 + curvature)
  end

  def compute_radius( r0, angle0, curvature, angle )
    return r0 * (1.0 - ( 1.0 + (Math.exp( - ( angle - angle0) / curvature ) ) ) * ( angle - angle0 ) /curvature )
    # return r0 * (1.0 - ( angle - angle0 ) /curvature )
  end

end

# curvature is in number of tour before center % extremity
class SpiralLog < GSpiral

  def nsamples
    return (self.curvature * 15.0).to_i
  end

  def compute_radius( r0, angle0, curvature, angle )
    return r0 * Math.exp( - self.sens * (angle - angle0) / curvature )
  end

  def compute_maxangle( r0, angle0, curvature )
    return angle0 - curvature * Math.log( 0.001 )
  end

  # method redefinition from GSpiral from Curve
  def tangent( length, container=nil )
    container = SpiralLog.tangent( self.center, self.point( length ), self.curvature )
  end

  def SpiralLog.tangent( center, ext, curvature )
    return (center - ext).rotate( -Math.atan( curvature ) ) 
  end

  def SpiralLog.fromtangent( tangent, ext, curvature, sens=1.0 )
    radial    = tangent.rotate( sens * Math.atan( curvature ) )
    newcenter = ext + radial
    # modelcenter  = V2D::O
    # radial       = (modelcenter - ext)
    # modeltangent = radial.rotate( -Math.atan( curvature ) ) 
    # scalefactor = tangent.r / modeltangent.r
    # angle = V2D.angle( modeltangent, tangent )
    # newcenter = (modelcenter - ext).rotate( angle ) * scalefactor + ext
    return SpiralLog[ :center, newcenter, :ext, ext, :curvature, curvature, :sens, sens ]
  end
end

end #XRVG

