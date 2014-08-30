# Color functionalities file. See 
# - +Color+
# - +Palette+
# - +Gradient+

require 'geometry2D'; # for vector extension
require 'interpolation'
require 'attributable'
require 'utils'
require 'shape'; # for gradient

#
# Color class
#
# = Basics
# Class Color derives from Vector, and consists in a 4D vector of (0.0..1.0) values, for red, blue, green, and opacity
# = Utilities
# Conversion from hsv and hsl color spaces available (see this link[http://en.wikipedia.org/wiki/HSV_color_space])
# = Future
# - Must use this library[https://rubyforge.org/projects/color/], to avoid effort duplication
# - Must add relative color operations as Nodebox wants to
# - Must optimize 4D vector operations (as C extension ?)
class Color < Vector

  # Color builder
  #
  # only allows to build 4D vector, with composants between 0.0 and 1.0
  def initialize( *args )
    # TODO : check args number
    super( *args )
  end

  # return the red composant
  #  Color[0.1,0.2,0.3,0.4].r => 0.1
  def r
    return self[0]
  end

  # return the green composant
  #  Color[0.1,0.2,0.3,0.4].r => 0.2
  def g
    return self[1]
  end

  # return the blue composant
  #  Color[0.1,0.2,0.3,0.4].r => 0.3
  def b
    return self[2]
  end

  # return the opacity composant
  #  Color[0.1,0.2,0.3,0.4].r => 0.4
  def a
    return self[3]
  end

  # set the red composant
  #  Color[0.1,0.2,0.3,0.4].r = 0.5 => Color[0.5,0.2,0.3,0.4]
  def r=(n)
    self[0]= n
  end

  # set the green composant
  #  Color[0.1,0.2,0.3,0.4].g = 0.5 => Color[0.1,0.5,0.3,0.4]
  def g=(n)
    self[1] = n
  end

  # set the blue composant
  #  Color[0.1,0.2,0.3,0.4].b = 0.5 => Color[0.1,0.2,0.5,0.4]
  def b=(n)
    self[2] = n
  end

  # set the opacity composant
  #  Color[0.1,0.2,0.3,0.4].a = 0.5 => Color[0.1,0.2,0.3,0.5]
  def a=(n)
    self[3] = n
  end

  # return an array containing colors on 255 integer format
  #  Color[0.0,1.0,0.0,1.0].format255 => [0,255,0,255]
  def format255()
    return self.map {|v| (v * 255.0).to_i}
  end

  # return a random color vector, with 1.0 opacity !!
  #  Color.rand => Color[0.2345, 0.987623, 0.4123, 1.0]
  def Color.rand
    return Color[Kernel::rand,Kernel::rand,Kernel::rand,1.0] 
  end

  # return a black color vector
  def Color.black(opacity=1.0)
    return Color[0.0, 0.0, 0.0, opacity]
  end

  # return a blue color vector
  def Color.blue(opacity=1.0)
    return Color[0.0, 0.0, 1.0, opacity]
  end

  # return a red color vector
  def Color.red(opacity=1.0)
    return Color[1.0, 0.0, 0.0, opacity]
  end

  # return a yellow color vector
  def Color.yellow(opacity=1.0)
    return Color[1.0, 1.0, 0.0, opacity]
  end

  # return a orange color vector
  def Color.orange(opacity=1.0)
    return Color[1.0, 0.5, 0.0, opacity]
  end

  # return a green color vector
  def Color.green(opacity=1.0)
    return Color[0.0, 1.0, 0.0, opacity]
  end

  # return a white color vector
  def Color.white(opacity=1.0)
    return Color[1.0, 1.0, 1.0, opacity]
  end

  # build a color vector from hsv parametrization (convert from hsv to rgb) h, s, v being between 0.0 and 1.0
  # taken from wikipedia[http://en.wikipedia.org/wiki/HSV_color_space]
  def Color.hsv( h, s, v, a)
    if s == 0.0
      return Color[v, v, v, a]
    end
    h *= 360.0
    hi = (h/60.0).floor
    f  = (h/60.0) - hi
    p  = v * ( 1 -             s )
    q  = v * ( 1 -       f   * s )
    t  = v * ( 1 - ( 1 - f ) * s )
    if hi == 0 
      return Color[ v, t, p, a] 
    end
    if hi == 1 
      return Color[ q, v, p, a] 
    end
    if hi == 2 
      return Color[ p, v, t, a] 
    end
    if hi == 3 
      return Color[ p, q, v, a] 
    end
    if hi == 4 
      return Color[ t, p, v, a] 
    end
    if hi == 5 
      return Color[ v, p, q, a] 
    end
  end

  def Color.getHSLcomponent( tC, p, q ) #:nodoc:
    while tC < 0.0
      tC = tC + 1.0
    end
    while tC > 1.0
      tC = tC - 1.0
    end

    if tC < (1.0 / 6.0)
      tC = p + ( (q-p) * 6.0 * tC )
    elsif tC >=(1.0 / 6.0) and tC < 0.5
      tC = q
    elsif tC >= 0.5 and tC < (2.0 / 3.0)
      tC = p + ( (q-p) * 6.0 * ((2.0 / 3.0) - tC) )
    else
      tC = p
    end
    return tC
  end

  # build a color vector from hsl parametrization (convert from hsl to rgb) h, s, l being between 0.0 and 1.0
  # taken from [[http://en.wikipedia.org/wiki/HSV_color_space]]
  # h, s, l must be between 0.0 and 1.0
  def Color.hsl( h, s, l, a)
    h *= 360.0
    if l < 0.5
      q = l * (1.0 + s)
    else
      q = l+ s - (l * s)
    end
    p = 2 * l - q
    hk = h / 360.0
    tR = hk + 1.0 / 3.0
    tG = hk
    tB = hk - 1.0 / 3.0

    tR = self.getHSLcomponent( tR, p, q )
    tG = self.getHSLcomponent( tG, p, q )
    tB = self.getHSLcomponent( tB, p, q )
    return Color[tR, tG, tB, a]
  end

  # get svg description of a color
  def svg
    values = self[0..2].map {|v| (255.0 * v).to_i }
    return "rgb(#{values.join(",")})"
  end

end

# class Palette
# = Intro
# Palette defines color palettes, as interpolation between color points. As such, use Interpolation module, so uses for the moment only linear interpolation.
# But once built with interpolation, palette provides a continuous color "interval", and so is Samplable !
# = Use
#  palette  = Palette[ :colorlist, [ Color.blue, 0.0, Color.orange, 0.5, Color.yellow, 1.0 ] ]
#  palette.rand( 10 )   # => return 10 random colors in palette
#  palette.color( 0.5 ) # => Color.orange
class Palette
  include Attributable
  attribute :colorlist

  # compute color given float pourcentage.
  #  Palette[ :colorlist, [ Color.black, 0.0, Color.white, 1.0 ] ].sample( 0.5 ) => Color[0.5,0.5,0.5,1.O]
  # "sample" method as defined in Samplable module
  def color(dindex)
    result = self.interpolate(dindex)
    return Color.elements(result[0..-1],false)
  end

  # return a new palette by reversing the current one
  def reverse()
    newcolorlist = []
    self.colorlist.reverse.foreach do |index,color|
      newcolorlist += [color, (0.0..1.0).complement( index )]
    end
    return Palette[ :colorlist, newcolorlist ]
  end
  

  include Samplable
  include Interpolation

  def apply_sample( abs ) #:nodoc:
    # Trace("Palette#apply_sample abs #{abs}")
    return self.color( abs )
  end

  # alias apply_sample color
  # alias apply_split ? => TODO
  alias samplelist colorlist
  alias colors samples
end

class Gradient < Palette #:nodoc:
  def defsvg()
    Kernel::raise("Gradient::defsvg must be redefined in subclasses")
  end
end


class LinearGradient < Gradient #:nodoc:
  attribute :vector

  def svgdef
    template     = '<linearGradient id="%ID%" x1="0%" y1="0%" x2="0%" y2="100%">%stops%</linearGradient>'
    stoptemplate = '<stop offset="%offset%" stop-color="%color%" stop-opacity="%opacity%"/>'
    
    stops = "\n"
    self.colorlist.foreach do |color, index|
      stops += stoptemplate.subreplace( {"%offset%" => index, "%color%" => color.svg, "%opacity%" => color.a} )
      stops += "\n"
    end

    

    return template.subreplace( {"%stops%" => stops} )
  end
end

class CircularGradient < Gradient #:nodoc:
  attribute :circle, nil, Circle
  
  def svgdef
    template     = '<radialGradient id="%ID%" gradientUnits="userSpaceOnUse" cx="%cx%" cy="%cy%" r="%r%">%stops%</radialGradient>'
    stoptemplate = '<stop offset="%offset%" stop-color="%color%" stop-opacity="%opacity%"/>'
    
    stops = "\n"
    self.colorlist.foreach do |color, index|
      stops += stoptemplate.subreplace( {"%offset%" => index, "%color%" => color.svg, "%opacity%" => color.a} )
      stops += "\n"
    end
    
    return template.subreplace( {"%stops%" => stops,
				 "%cx%" => circle.center.x,
				 "%cy%" => circle.center.y,
				 "%r%" => circle.radius} )
  end
end
