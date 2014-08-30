require 'test/unit'
require 'style'

class StyleTest < Test::Unit::TestCase

  def test_svgline
    style = Style.new(:fill, "red", :stroke, "none")
    assert_equal( 'style="opacity:1.0;fill:red;fill-opacity:1.0;stroke:none;stroke-width:1.0;stroke-opacity:1.0"', style.svgline )
  end

  def test_default
    style = Style.new
    assert_equal( 'style="opacity:1.0;fill:black;fill-opacity:1.0;stroke:black;stroke-width:1.0;stroke-opacity:1.0"', style.svgline )
  end

end
