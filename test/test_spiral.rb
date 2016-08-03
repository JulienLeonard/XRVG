require 'test_helper'
# require 'XRVG'
# include XRVG

class SpiralTest < Minitest::Test

  def test_abstract1
    assert_raise(NotImplementedError) {GSpiral.new.compute_radius( 0.0,0.0,0.0,0.0)}
  end

  def test_abstract2
    assert_raise(NotImplementedError) {GSpiral.new.tangent( 0.0 )}
  end

  def test_bezier
    spiral = SpiralLog[]
    assert_equal( spiral.point( 0.0 ), spiral.bezier.point( 0.0 ) )
    # assert_equal( spiral.point( 1.0 ), spiral.bezier.point( 1.0 ) )
  end

  
  def test_all
    spiral = SpiralLog[]
    # assert_equal( V2D::O, spiral.point( 1.0 ) )
    assert_equal( V2D::X, spiral.point( 0.0 ) )
    spiral = SpiralLinear[]
    assert_equal( V2D::X, spiral.point( 0.0 ) )
    
    assert_raise(NotImplementedError) {GSpiral.new.compute_maxangle( 0.0,0.0,0.0)}
  end

  def test_tangent
    spiral    = SpiralLog[]
    tangent   = spiral.tangent( 0.0 )
    newspiral = SpiralLog.fromtangent( tangent, spiral.ext, spiral.curvature )
    assert_equal( spiral.point( 0.0 ), newspiral.point( 0.0 ) )
    assert_equal( spiral.point( 1.0 ), newspiral.point( 1.0 ) )
  end
  
end

