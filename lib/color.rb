# Color functionalities file. See 
# - +Color+
# - +Palette+
# - +Gradient+

require 'utils'
require 'interpolation'
require 'shape'; # for gradient

module XRVG
#
# Color class
#
# = Basics
# Class Color consists in a 4D vector of (0.0..1.0) values, for red, blue, green, and opacity
# = Utilities
# Conversion from hsv and hsl color spaces available (see this link[http://en.wikipedia.org/wiki/HSV_color_space])
# = Future
# - Must use this library[https://rubyforge.org/projects/color/], to avoid effort duplication
# - Must add relative color operations as Nodebox wants to
# - Must optimize 4D vector operations (as C extension ?)
class Color

  # Color builder
  #
  # only allows to build 4D vector, with composants between 0.0 and 1.0
  def Color.[]( *args )
    # TODO : check args number
    Color.new( *args )
  end

  # builder
  #
  # r, g, b, a must be between 0.0 and 1.0
  def initialize( r, g, b, a)
    # cannot trim because otherwise color interpolation cannot be right !!
    # r = Range.O.trim( r )
    # g = Range.O.trim( g )
    # b = Range.O.trim( b )
    # a = Range.O.trim( a )
    @items = [r,g,b,a]
  end

  # delegation componant indexation method
  def [](index)
    return @items[index]
  end

  # define addition operation, for interpolation
  def +( other )
    return Color[ self.r + other.r,
                  self.g + other.g,
                  self.b + other.b,
                  self.a + other.a ]
  end

  # define scalar multiplication, for interpolation
  def *( scalar )
    return Color[ self.r * scalar,
                  self.g * scalar,
                  self.b * scalar,
                  self.a * scalar ]
  end

  # return [r,g,b,a]
  def rgba
    return @items
  end

  # return hsva components
  def hsva
    return (Color.rgb2hsv(self.r, self.g, self.b) + [self.a])
  end

  # return hsla components
  def hsla
    return (Color.rgb2hsl(self.r, self.g, self.b) + [self.a])
  end

  # equality operator
  def ==( other )
    return (self.rgba == other.rgba)
  end

  # return the red composant
  #  Color[0.1,0.2,0.3,0.4].r        => 0.1
  #  Color[0.1,0.2,0.3,0.4].r( 0.3 ) => Color[0.3,0.2,0.3,0.4]
  def r(val=nil)
    if not val
      return self[0]
    else
      return Color[ val, self.g, self.b, self.a ]
    end
  end

  # return the green composant
  #  Color[0.1,0.2,0.3,0.4].r => 0.2
  def g(val=nil)
    if not val
      return self[1]
    else
      return Color[ self.r, val, self.b, self.a ]
    end
  end

  # return the blue composant
  #  Color[0.1,0.2,0.3,0.4].r => 0.3
  def b(val=nil)
    if not val
      return self[2]
    else
      return Color[ self.r, self.g, val, self.a ]
    end
  end

  # return the opacity composant
  #  Color[0.1,0.2,0.3,0.4].r => 0.4
  def a(val=nil)
    if not val
      return self[3]
    else
      return Color[ self.r, self.g, self.b, val ]
    end
  end
  
  # get or set hue of color
  #  Color.red.hue        => 0.0
  #  Color.red.hue( 0.1 ) => Color.hsva( 0.1, 1.0, 1.0, 1.0 )
  def hue(newhue=nil)
    if not newhue
      return self.hsva[0]
    else
      hsva = self.hsva
      hsva[0] = newhue
      return Color.hsva( *hsva )
    end
  end

  # set saturation of color
  #  Color.red.saturation        => 1.0
  #  Color.red.saturation( 0.1 ) => Color.hsva( 0.0, 0.1, 1.0, 1.0 )
  def saturation(newsat=nil)
    if not newsat
      return self.hsva[1]
    else
      hsva = self.hsva
      hsva[1] = newsat
      return Color.hsva( *hsva )
    end
  end

  # set value (from hsv) of color
  #  Color.red.value        => 1.0
  #  Color.red.value( 0.1 ) => Color.hsva( 0.0, 1.0, 0.1, 1.0 )
  def value(newval=nil)
    if not newval
      return self.hsva[2]
    else
      hsva = self.hsva
      hsva[2] = newval
      return Color.hsva( *hsva )
    end
  end
  
  # set lightness (from hsl) of color
  #  Color.white.lightness        => 1.0
  #  Color.white.lightness( 0.1 ) => Color.hsla( 1.0, 1.0, 0.1, 1.0 )
  def lightness(newlight=nil)
    if not newlight
      return self.hsla[2]
    else
      hsla = self.hsla
      hsla[2] = newlight
      return Color.hsla( *hsla )
    end
  end

  # set the red composant
  #  Color[0.1,0.2,0.3,0.4].r = 0.5 => Color[0.5,0.2,0.3,0.4]
  def r=(n)
    @items[0]= n
  end

  # set the green composant
  #  Color[0.1,0.2,0.3,0.4].g = 0.5 => Color[0.1,0.5,0.3,0.4]
  def g=(n)
    @items[1] = n
  end

  # set the blue composant
  #  Color[0.1,0.2,0.3,0.4].b = 0.5 => Color[0.1,0.2,0.5,0.4]
  def b=(n)
    @items[2] = n
  end

  # set the opacity composant
  #  Color[0.1,0.2,0.3,0.4].a = 0.5 => Color[0.1,0.2,0.3,0.5]
  def a=(n)
    @items[3] = n
  end

  # compute complementary color
  #  Color.red.complement => Color.green
  def complement
    newvalues = self.rgba[0..-2].map {|v| Range.O.complement( v )}
    newvalues += [self.a]
    return Color[ *newvalues ]
  end

  # return an array containing colors on 255 integer format
  #  Color[0.0,1.0,0.0,1.0].format255 => [0,255,0,255]
  def format255()
    return @items.map {|v| (v * 255.0).to_i}
  end

  # return a random color vector, with 1.0 opacity !!
  #  Color.rand => Color[0.2345, 0.987623, 0.4123, 1.0]
  def Color.rand( opacity=1.0 )
    return Color[Kernel::rand,Kernel::rand,Kernel::rand,opacity] 
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

  # return a grey color vector
  def Color.grey(light,opacity=1.0)
    return Color[light, light, light, opacity]
  end
  

  # build a color vector from hsv parametrization (convert from hsv to rgb) h, s, v being between 0.0 and 1.0
  #
  # taken from wikipedia[http://en.wikipedia.org/wiki/HSV_color_space]
  #
  # error on algo with h = 1.0 => hi == 6 must be taken into account
  def Color.hsva( h, s, v, a)
    h = Range.O.trim( h )
    s = Range.O.trim( s )
    v = Range.O.trim( v )
    a = Range.O.trim( a )
    values = Color.hsv(h,s,v) + [a]
    return Color[*values]
  end

  def Color.hsv( h, s, v)
    if s == 0.0
      return [v, v, v]
    end
    h *= 360.0
    hi = (h/60.0).floor
    if hi == 6
      hi = 5
    end
    f  = (h/60.0) - hi
    p  = v * ( 1 -             s )
    q  = v * ( 1 -       f   * s )
    t  = v * ( 1 - ( 1 - f ) * s )
    if hi == 0 
      return [ v, t, p] 
    end
    if hi == 1 
      return [ q, v, p] 
    end
    if hi == 2 
      return [ p, v, t] 
    end
    if hi == 3 
      return [ p, q, v] 
    end
    if hi == 4 
      return [ t, p, v] 
    end
    if hi == 5 
      return [ v, p, q] 
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
  def Color.hsla( h, s, l, a)
    h = Range.O.trim( h )
    s = Range.O.trim( s )
    l = Range.O.trim( l )
    a = Range.O.trim( a )
    values = Color.hsl( h, s, l ) + [a]
    return Color[*values]
  end

  def Color.hsl( h, s, l)
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
    return [tR, tG, tB]
  end

  # from http://en.wikipedia.org/wiki/HSL_and_HSV#Conversion_from_RGB_to_HSL_or_HSV
  def Color.rgb2h(r,g,b)
    result = 0.0
    range = [r,g,b].range
    if range.begin == range.end
      result = 0.0
    elsif range.end == r
      result = (60.0 * (g - b) / range.size +   0.0)
    elsif range.end == g
      result = (60.0 * (b - r) / range.size + 120.0)
    else
      result = (60.0 * (r - g) / range.size + 240.0)
    end
    return (result % 360.0) / 360.0
  end

  def Color.rgb2sl(r,g,b)
    range = [r,g,b].range
    l = range.middle
    s = 0.0
    if range.begin == range.end
      s = 0.0
    elsif l <= 0.5
      s = range.size / (2.0 * l)
    else
      s = range.size / (2.0 - 2.0 * l)
    end
    return [s,l]
  end

  def Color.rgb2sv(r,g,b)
    range = [r,g,b].range
    v = range.end
    if v == 0.0
      s = 0.0
    else
      s = (1.0 - (range.begin/range.end))
    end
    return [s,v]
  end

  def Color.rgb2hsl(r,g,b)
    h    = Color.rgb2h(r,g,b)
    s, l = Color.rgb2sl(r,g,b)
    return [h,s,l]
  end

  def Color.rgb2hsv(r,g,b)
    h    = Color.rgb2h(r,g,b)
    s, v = Color.rgb2sv(r,g,b)
    return [h,s,v]
  end

  # get svg description of a color
  def svg
    values = self[0..2].map do |v|
      v = Range.O.trim( v )
      (255.0 * v).to_i 
    end
    return "rgb(#{values.join(",")})"
  end

end

# class Palette
# = Intro
# Palette defines color palettes, as interpolation between color points. As such, use Interpolation module, so uses for the moment only linear interpolation.
# But once built with interpolation, palette provides a continuous color "interval", and so is Samplable !
# = Use
#  palette  = Palette[ :colorlist, [ 0.0, Color.blue, 0.5, Color.orange, 1.0, Color.yellow ] ]
#  palette.rand( 10 )   # => return 10 random colors in palette
#  palette.color( 0.5 ) # => Color.orange
class Palette
  include Attributable
  attribute :colorlist, nil, Array
  attribute :interpoltype, :linear
  attribute :interpoldomain, :rgb # can also be :hsv or :hsl

  include Samplable
  include Interpolation

  def initialize( *args )
    super( *args )
    build_interpolators
  end

  # build an interpolator by color componant
  def build_interpolators()
    vlists = [[],[],[],[]]
    self.colorlist.foreach do |index, color|
      values = []
      if self.interpoldomain == :rgb
	values = color.rgba
      elsif self.interpoldomain == :hsv
	values = color.hsva
      elsif self.interpoldomain == :hsl
	values = color.hsla
      else
	raise RuntimeError.new("#{self.interpoldomain} is an unknown color scheme.")
      end
      vlists[0] += [index, values[0] ]
      vlists[1] += [index, values[1] ]
      vlists[2] += [index, values[2] ]
      vlists[3] += [index, values[3] ]
    end
    @interpolators = vlists.map {|samplelist| Interpolator[ :samplelist, samplelist, :interpoltype, self.interpoltype]}
  end

  # interpolators accessor (for debugging)
  def interpolators()
    return @interpolators
  end

  # overloading to reset interpolators if interpoltype changes
  def interpoltype=(value)
    @interpoltype = value
    if defined? @interpolators
      self.build_interpolators
    end
  end

  # method overloading to delegate computation to componant interpolators
  def interpolate( dindex )
    vs = self.interpolators.map {|inter| inter.interpolate( dindex )}
    if self.interpoldomain == :rgb
      return Color[ *vs ]
    elsif self.interpoldomain == :hsv
      return Color.hsva( *vs )
    else
      return Color.hsla( *vs )
    end
  end

  # compute color given float pourcentage.
  #  Palette[ :colorlist, [ 0.0, Color.black, 1.0, Color.white ] ].sample( 0.5 ) => Color[0.5,0.5,0.5,1.O]
  # "sample" method as defined in Samplable module
  def color(dindex)
    result = self.interpolate(dindex)
    return result
  end

  # return a new palette by reversing the current one
  def reverse()
    newcolorlist = []
    self.colorlist.reverse.foreach do |color, index|
      newcolorlist += [(0.0..1.0).complement( index ), color]
    end
    return Palette[ :colorlist, newcolorlist ]
  end

  def apply_sample( abs ) #:nodoc:
    return self.color( abs )
  end


  # alias apply_sample color
  # alias apply_split ? => TODO
  alias samplelist colorlist
  alias colors samples
end

class Gradient < Palette #:nodoc:
  def defsvg()
    raise NotImplementedError.new("#{self.class.name}#defsvg is an abstract method.")
  end
end


class LinearGradient < Gradient #:nodoc:

  def svgdef
    template     = '<linearGradient id="%ID%" x1="0%" y1="0%" x2="0%" y2="100%">%stops%</linearGradient>'
    stoptemplate = '<stop offset="%offset%" stop-color="%color%" stop-opacity="%opacity%"/>'
    
    stops = "\n"
    self.colorlist.foreach do |index, color|
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
    self.colorlist.foreach do |index, color|
      stops += stoptemplate.subreplace( {"%offset%" => index, "%color%" => color.svg, "%opacity%" => color.a} )
      stops += "\n"
    end
    
    return template.subreplace( {"%stops%" => stops,
				 "%cx%"    => circle.center.x,
				 "%cy%"    => circle.center.y,
				 "%r%"     => circle.radius} )
  end
end
end
