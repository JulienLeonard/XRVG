require 'test/unit'
require 'color'


class ColorTest < Test::Unit::TestCase
  
  def test_color
    color = Color[0.1, 0.2, 0.3, 0.4]
    assert_equal( 0.1, color.r )
    assert_equal( 0.2, color.g )
    assert_equal( 0.3, color.b )
    assert_equal( 0.4, color.a )
  end

  def test_colors
    black = Color[0.0, 0.0, 0.0, 1.0]
    white = Color[1.0, 1.0, 1.0, 1.0]
    assert_equal( black, Color.black )
    assert_equal( white, Color.white )
  end

  def test_svg
    assert_equal( "rgb(0,0,0)", Color.black.svg )
  end

  def test_hsv
    black = Color[0.0, 0.0, 0.0, 1.0]
    white = Color[1.0, 1.0, 1.0, 1.0]
    red   = Color[1.0, 0.0, 0.0, 1.0]
    assert_equal( black, Color.hsv( 0.0, 0.0, 0.0, 1.0 ) )
    assert_equal( white, Color.hsv( 0.0, 0.0, 1.0, 1.0 ) )
    assert_equal( red,   Color.hsv( 0.0, 1.0, 1.0, 1.0 ) )
  end

end


class PaletteTest < Test::Unit::TestCase

  def test_palette
    palette = Palette.new( :colorlist, [ Color.black, 0.0, Color.white, 1.0 ] )
    assert_equal( Color[0.5, 0.5, 0.5, 1.0], palette.color( 0.5 ) )
  end
end

class GradientTest < Test::Unit::TestCase

  def test_gradient
    gradient = LinearGradient.new( :colorlist, [Color.black, 0.0, Color.white, 1.0] )
    assert_equal( gradient.svgdef,
		 "<linearGradient id=\"%ID%\">\n<stop offset=\"0.0\" stop-color=\"rgb(0,0,0)\" stop-opacity=\"1.0\"/>\n<stop offset=\"1.0\" stop-color=\"rgb(255,255,255)\" stop-opacity=\"1.0\"/>\n</linearGradient>")
  end


  def test_gradient1
    require 'render'
    require 'shape'
    render = SVGRender.new( :filename, "gradient1.svg" )
    render.add( Circle.new, Style.new( :stroke, "none", :fill, LinearGradient.new( :colorlist, [Color.black, 0.0, Color.white, 1.0] ) ) )
    render.end
    assert( File.exist?( "gradient1.png" ) )
  end

  def test_gradient2
    require 'render'
    require 'shape'
    render = SVGRender.new( :filename, "gradient2.svg" )
    circle = Circle.new
    style = Style.new( :stroke, "none", :fill, CircularGradient.new( :colorlist, [Color.black(1.0), 0.0, Color.black(0.0), 1.0], :circle, circle ) )
    render.add( circle, style )
    render.end
    assert( File.exist?( "gradient2.png" ) )
  end

end
