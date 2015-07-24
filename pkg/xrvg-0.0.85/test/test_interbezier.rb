require 'test/unit'
require 'interbezier.rb'

# Test class
class InterBezierTest < Test::Unit::TestCase
  
  def test_base
    bezier1 = Bezier.raw( V2D::O, V2D::X, V2D::O, V2D::X  )
    center  = V2D::O + V2D::Y
    bezier2 = Bezier.raw( center, center, center, center )
    interbezier  = InterBezier.new( :bezierlist, [0.0, bezier1, 1.0, bezier2] )
    v = V2D::Y * 0.5
    assert_equal( [V2D::O + v, V2D::X * 0.5 + v, V2D::O + v, V2D::X * 0.5 + v], interbezier.sample( 0.5 ).pointlist )
  end
end


# Test class
class GradientBezierTest < Test::Unit::TestCase
  
  def test_base
    bezier1 = Bezier.raw( V2D::O, V2D::X, V2D::O, V2D::X  )
    center  = V2D::O + V2D::Y
    bezier2 = Bezier.raw( center, center, center, center )
    interbezier  = GradientBezier.new( :bezierlist, [0.0, bezier1, 1.0, bezier2] )
    v = V2D::Y * 0.5
    assert_equal( [V2D::O + v, V2D::X * 0.5 + v, V2D::O + v, V2D::X * 0.5 + v], interbezier.samples( 10 )[5].bezier(0).pointlist )
  end
end
