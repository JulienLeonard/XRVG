require 'test/unit'
require 'color'


class ColorTest < Test::Unit::TestCase
  
  def test_color
    color = Color[0.1, 0.2, 0.3, 0.4]
    assert_equal( 0.1, color.r )
    assert_equal( 0.2, color.g )
    assert_equal( 0.3, color.b )
    assert_equal( 0.4, color.a )

    assert_equal( Color[0.5, 0.2, 0.3, 0.4], color.r(0.5) )
    assert_equal( Color[0.1, 0.5, 0.3, 0.4], color.g(0.5) )
    assert_equal( Color[0.1, 0.2, 0.5, 0.4], color.b(0.5) )
    assert_equal( Color[0.1, 0.2, 0.3, 0.5], color.a(0.5) )

    assert_equal( 0.0, Color.red.hue )
    assert_equal( Color.hsva( 0.1, 1.0, 1.0, 1.0 ), Color.red.hue( 0.1 ) )

    assert_equal( 1.0, Color.red.saturation )
    assert_equal( Color.hsva( 0.0, 0.1, 1.0, 1.0 ), Color.red.saturation( 0.1 ) )

    assert_equal( 1.0, Color.red.value )
    assert_equal( Color.hsva( 0.0, 1.0, 0.1, 1.0 ), Color.red.value( 0.1 ) )

    assert_equal( 0.5, Color.red.lightness )
    assert_equal( Color.hsla( 0.0, 1.0, 0.1, 1.0 ), Color.red.lightness( 0.1 ) )
  end

  def test_colors
    black  = Color[0.0, 0.0, 0.0, 1.0]
    white  = Color[1.0, 1.0, 1.0, 1.0]
    blue   = Color[0.0, 0.0, 1.0, 1.0]
    red    = Color[1.0, 0.0, 0.0, 1.0]
    green  = Color[0.0, 1.0, 0.0, 1.0]
    yellow = Color[1.0, 1.0, 0.0, 1.0]
    orange = Color[1.0, 0.5, 0.0, 1.0]
    grey10 = Color[0.1, 0.1, 0.1, 1.0]
    assert_equal( black, Color.black )
    assert_equal( white, Color.white )
    assert_equal( red, Color.red )
    assert_equal( blue, Color.blue )
    assert_equal( green, Color.green )
    assert_equal( yellow, Color.yellow )
    assert_equal( orange, Color.orange )
    assert_equal( grey10, Color.grey( 0.1 ) )
  end

  def test_rand
    assert_equal( 0.3, Color.rand( 0.3 ).a )
  end

  def test_svg
    assert_equal( "rgb(0,0,0)", Color.black.svg )
  end

  def test_hsv
    black = Color[0.0, 0.0, 0.0, 1.0]
    white = Color[1.0, 1.0, 1.0, 1.0]
    red   = Color[1.0, 0.0, 0.0, 1.0]
    assert_equal( black, Color.hsva( 0.0, 0.0, 0.0, 1.0 ) )
    assert_equal( white, Color.hsva( 0.0, 0.0, 1.0, 1.0 ) )
    assert_equal( red,   Color.hsva( 0.0, 1.0, 1.0, 1.0 ) )
    assert_equal( black, Color.hsva( 0.2, 1.0, 0.0, 1.0 ) )
    assert_equal( black, Color.hsva( 0.4, 1.0, 0.0, 1.0 ) )
    assert_equal( black, Color.hsva( 0.6, 1.0, 0.0, 1.0 ) )
    assert_equal( black, Color.hsva( 0.8, 1.0, 0.0, 1.0 ) )
    assert_equal( black, Color.hsva( 1.0, 1.0, 0.0, 1.0 ) )
    assert_equal( [0.0, 0.0, 0.0, 1.0], black.hsva )
    assert_equal( [2.0/3.0, 1.0, 1.0, 1.0], Color.blue.hsva )
    assert_equal( [1.0/3.0, 1.0, 1.0, 1.0], Color.green.hsva )
  end

  def test_hsl
    black = Color[0.0, 0.0, 0.0, 1.0]
    white = Color[1.0, 1.0, 1.0, 1.0]
    assert_equal( black, Color.hsla( 0.0, 0.0, 0.0, 1.0 ) )
    assert_equal( white, Color.hsla( 0.0, 0.0, 1.0, 1.0 ) )
    assert_equal( white, Color.hsla( 0.0, 1.0, 1.0, 1.0 ) )
    assert_equal( white, Color.hsla( 2.0, 1.0, 1.0, 1.0 ) )
    assert_equal( white, Color.hsla( 0.6, 1.0, 1.0, 1.0 ) )
    assert_equal( [0.0, 0.0, 0.0, 1.0], black.hsla )
    assert_equal( 0.0, Color[0.9,0.8,0.8,1.0].hsla[0] )
  end


  def test_accessors
    black = Color[0.0, 0.0, 0.0, 1.0]
    assert_equal( 0.0, black.r )
    assert_equal( 0.0, black.g )
    assert_equal( 0.0, black.b )
    assert_equal( 1.0, black.a )
    black.r = 1.0
    assert_equal( 1.0, black.r )
    black.g = 1.0
    assert_equal( 1.0, black.g )
    black.b = 1.0
    assert_equal( 1.0, black.b )
    black.a = 0.0
    assert_equal( 0.0, black.a )
  end

  def test_format255
    assert_equal( [255,255,255,255], Color.white.format255 )
    assert_equal( [25,25,25,25], Color[0.1,0.1,0.1,0.1].format255 )
  end

  def test_complement
    assert_equal( Color[ 0.0, 1.0, 1.0, 0.5], Color.red(0.5).complement )
  end

  def test_operators
    assert_equal( Color[0.2, 0.4, 0.6, 1.0], Color[0.1, 0.2, 0.3, 0.5 ] + Color[0.1, 0.2, 0.3, 0.5 ] )
    assert_equal( Color[0.2, 0.4, 0.6, 1.0], Color[0.1, 0.2, 0.3, 0.5 ] * 2.0 )
  end
end


class PaletteTest < Test::Unit::TestCase

  def test_palette
    palette = Palette.new( :colorlist, [ 0.0, Color.black, 1.0, Color.white ] )
    assert_equal( Color[0.5, 0.5, 0.5, 1.0], palette.color( 0.5 ) )
    assert_equal( Color[0.5, 0.5, 0.5, 1.0], palette.sample( 0.5 ) )
    palette  = Palette[ :colorlist, [ 0.0, Color.blue,   0.3,  Color.orange,  0.5, Color.yellow, 0.7,  Color.green, 1.0, Color.blue] ]
    assert_equal( Color[1.0, 0.75, 0.0, 1.0], palette.sample( 0.4 ) )
  end

  def test_reverse
    palette = Palette.new( :colorlist, [ 0.0, Color.black, 0.3, Color.red,  1.0, Color.white ] ).reverse
    assert_equal( Color.red, palette.color( 0.7 ) )
  end

  def test_interpolator
    palette = Palette.new( :colorlist, [ 0.0, Color.black, 0.3, Color.red,  1.0, Color.white ] )
    palette.interpoltype = :linear
    assert_equal( :linear, palette.interpoltype  )
  end

  def test_hsv
    palette = Palette[ :colorlist, [ 0.0, Color.hsva( 0.5, 0.5, 0.5, 0.5), 1.0, Color.hsva( 0.6, 0.6, 0.6, 0.6 ) ], :interpoldomain, :hsv ]
    assert_equal( Color.hsva( 0.55, 0.55, 0.55, 0.55), palette.sample( 0.5 ) )
  end

  def test_hsl
    palette = Palette[ :colorlist, [ 0.0, Color.hsla( 0.5, 0.5, 0.5, 0.5), 1.0, Color.hsla( 0.6, 0.6, 0.6, 0.6 ) ], :interpoldomain, :hsl ]
    assert_equal( Color.hsla( 0.55, 0.55, 0.55, 0.55), palette.sample( 0.5 ) )
  end

  def test_error
    assert_raise(RuntimeError) {Palette[ :colorlist, [ 0.0, Color.hsla( 0.5, 0.5, 0.5, 0.5), 1.0, Color.hsla( 0.6, 0.6, 0.6, 0.6 ) ], :interpoldomain, :toto ]}
  end


end

class GradientTest < Test::Unit::TestCase

  def test_gradient
    assert_raise(NotImplementedError) {Gradient[ :colorlist, [0.0, Color.black, 1.0, Color.white]].defsvg}
  end

  def test_lineargradient
    gradient = LinearGradient.new( :colorlist, [0.0, Color.black, 1.0, Color.white] )
    assert_equal( gradient.svgdef,
		 "<linearGradient id=\"%ID%\" x1=\"0%\" y1=\"0%\" x2=\"0%\" y2=\"100%\">\n<stop offset=\"0.0\" stop-color=\"rgb(0,0,0)\" stop-opacity=\"1.0\"/>\n<stop offset=\"1.0\" stop-color=\"rgb(255,255,255)\" stop-opacity=\"1.0\"/>\n</linearGradient>")
	
  end

  def test_circulargradient
    circle   = Circle.new
    gradient = CircularGradient.new( :colorlist, [0.0, Color.black(1.0), 1.0, Color.black(0.0)], :circle, circle )
    assert_equal( gradient.svgdef,
		 "<radialGradient id=\"%ID%\" gradientUnits=\"userSpaceOnUse\" cx=\"0.0\" cy=\"0.0\" r=\"1.0\">\n<stop offset=\"0.0\" stop-color=\"rgb(0,0,0)\" stop-opacity=\"1.0\"/>\n<stop offset=\"1.0\" stop-color=\"rgb(0,0,0)\" stop-opacity=\"0.0\"/>\n</radialGradient>")

  end
end
