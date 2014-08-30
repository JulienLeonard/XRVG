require 'test/unit'
require 'fitting'

class FittingTest < Test::Unit::TestCase

  def test_base
    bezier = Bezier.raw( V2D[0.0, 0.0], V2D[100.0, 0.0], V2D[0.0, 100.0], V2D[100.0, 100.0] )
    points = bezier.samples( 30 )
    fit    = Fitting.compute( points, 0.000001, 500 )
    assert( V2D.vequal?( bezier.pointlist[1], fit.pointlist[1], 0.01) )
    assert( V2D.vequal?( bezier.pointlist[2], fit.pointlist[2], 0.01) )
  end

  def test_base2
    bezier = Bezier.raw( V2D[0.0, 0.0], V2D[100.0, 0.0], V2D[0.0, 100.0], V2D[100.0, 100.0] )
    points = bezier.samples( 15 )
    fit, error  = Fitting.adaptative_compute( points, 0.01 )
    assert_equal( 1, fit.piecenumber )
  end

  def test_base3
    bezier = Bezier.raw( V2D[0.0, 0.0], V2D[100.0, 0.0], V2D[0.0, 100.0], V2D[100.0, 100.0] )
    points = bezier.samples( 15 )
    fit, error  = Fitting.adaptative_compute( points, 0.001 )
    assert_equal( 3, fit.piecenumber )
  end


  def test_limit
    points = [V2D[0.0, 0.0]] * 10
    fit, error  = Fitting.adaptative_compute( points, 0.01 )
    assert_equal( 1, fit.piecenumber )
  end


  def test_limit2
    bezier = Bezier.raw( V2D[0.0, 0.0], V2D[100.0, 0.0], V2D[0.0, 100.0], V2D[100.0, 100.0] )
    points = bezier.samples( 30 )
    points = [points[0]] + points
    fit    = Fitting.compute( points, 0.000001, 500 )
    assert( V2D.vequal?( bezier.pointlist[1], fit.pointlist[1], 0.01) )
    assert( V2D.vequal?( bezier.pointlist[2], fit.pointlist[2], 0.01) )
  end



end
