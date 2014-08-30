#
# See +Style+
#
require 'attributable'
require 'utils'
require 'color'

#
# Style class 
#
# Used to define the way an object has to be rendered.
# For the moment, only the following style attributes are really useful :
# - attribute :fill,          "none", [String, Color, Gradient]
# - attribute :stroke,        "none", [String, Color, Gradient]
# - attribute :strokewidth,   1.0
#
# For example :
#   render.add( Circle[], Style[ :fill,   Color.red ] )
#   render.add( Circle[], Style[ :stroke, Color.red ] )
class Style
  include Attributable
  attribute :opacity,       1.0
  attribute :fill,          "none", [String, Color, Gradient]
  attribute :fillopacity,   1.0
  attribute :stroke,        "none", [String, Color, Gradient]
  attribute :strokewidth,   1.0
  attribute :strokeopacity, 1.0

  def fill=( color )
    if color.is_a? Color
      self.fillopacity = color.a
    end
    @fill = color
  end

  def stroke=( color )
    if color.is_a? Color
      self.strokeopacity = color.a
    end
    @stroke = color
  end

  def svgfill
    if fill.is_a? Color
      return fill.svg
    elsif fill.is_a? Gradient
      return "%fillgradient%"
    else
      return fill
    end
  end

  def svgstroke
    if stroke.is_a? Color
      return stroke.svg
    elsif stroke.is_a? Gradient
      return "%strokegradient%"
    else
      return stroke
    end
  end

  def svgline
    template = 'style="opacity:%opacity%;fill:%fill%;fill-opacity:%fillopacity%;stroke:%stroke%;stroke-width:%strokewidth%;stroke-opacity:%strokeopacity%"'
    
    return template.subreplace( {"%opacity%" => opacity,
				 "%fill%"    => svgfill,
				 "%fillopacity%" => fillopacity,
				 "%stroke%"  => svgstroke,
				 "%strokewidth%" => strokewidth,
				 "%strokeopacity%" => strokeopacity} )
  end
end

