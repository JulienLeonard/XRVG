require 'test/unit'
require 'bezierbuilders'


class BezierBuilderTest < Test::Unit::TestCase

  def test_abstract
    assert_raise(NotImplementedError){BezierBuilder.new.compute}
  end

  def test_lissage
    bezier = Bezier.multi( [[:vector, V2D::O, V2D::X, V2D::X, V2D::X], [:vector, V2D::X, V2D::X, V2D::X * 2.0, V2D::X]] )
    assert_equal( bezier.pointlist, BezierBuilder.lissage( bezier, 0.0 ).pointlist )
    assert_equal( [V2D::O, V2D::X, V2D::X, V2D::O, V2D::X, V2D::O, V2D::X * 2.0, V2D::X], BezierBuilder.lissage( bezier, 1.0 ).pointlist(:vector) )
  end

end

class SimilarMotifIteratorTest < Test::Unit::TestCase

  def test_all
    bezier = Bezier.multi( [[:vector, V2D::O, V2D::X, V2D::X, V2D::X]] )
    simibezier = SimilarMotifIterator[ :curvesampler, bezier, :motif, bezier, :nmotifs, 2 ]
    assert( V2D.vequal?( bezier.firstpoint, simibezier.firstpoint ))
    assert( V2D.vequal?(bezier.lastpoint, simibezier.lastpoint ))
    assert( V2D.vequal?(bezier.point( 0.5 ), simibezier.bezier(0).lastpoint ))
  end
end

class AttributeMotifIteratorTest < Test::Unit::TestCase

  def test_all
    require 'beziermotifs'
    bezier = Bezier.multi( [[:vector, V2D::O, V2D::X, V2D::X, V2D::X]] )
    simibezier = AttributeMotifIterator[ :curvesampler, bezier, :motifclass, LinearBezier, :nmotifs, 2, :closed, false ]
    assert( V2D.vequal?( bezier.firstpoint, simibezier.firstpoint ))
    assert( V2D.vequal?(bezier.lastpoint, simibezier.lastpoint ))
    assert( V2D.vequal?(bezier.point( 0.5 ), simibezier.bezier(0).lastpoint ))
  end

  def test_all2
    require 'beziermotifs'
    bezier = Bezier.multi( [[:vector, V2D::O, V2D::X, V2D::X, V2D::X]] )
    simibezier = AttributeMotifIterator[ :curvesampler, bezier, :motifclass, LinearBezier, :nmotifs, 2, :closed, true ]
    assert( V2D.vequal?( bezier.firstpoint, simibezier.firstpoint ))
    assert( V2D.vequal?(bezier.point( 0.5 ), simibezier.lastpoint ))
    assert( V2D.vequal?(bezier.point( 0.5 ), simibezier.bezier(0).lastpoint ))
    assert_equal( 4, simibezier.piecenumber )
  end

  def test_all3
    require 'beziermotifs'
    bezier = Bezier.multi( [[:vector, V2D::O, V2D::X, V2D::X, V2D::X]] )
    simibezier = AttributeMotifIterator[ :curvesampler, bezier, :motifclass, PicBezier, :attributes, [:height, (0.0..1.0)], :nmotifs, 2, :closed, true ]
    assert( V2D.vequal?( bezier.firstpoint, simibezier.firstpoint ))
    assert( V2D.vequal?(bezier.point( 0.5 ), simibezier.lastpoint ))
    assert( V2D.vequal?(bezier.point( 0.5 ), simibezier.bezier(1).lastpoint ))
    assert_equal( 6, simibezier.piecenumber )
  end

  def test_all4
    require 'beziermotifs'
    bezier = Bezier.multi( [[:vector, V2D::O, V2D::X, V2D::X, V2D::X]] )
    simibezier = AttributeMotifIterator[ :curvesampler, bezier, :motifclass, ArcBezier, :attributes, [:height, 1.0], :nmotifs, 2, :closed, true ]
    assert( V2D.vequal?( bezier.firstpoint, simibezier.firstpoint ))
    assert( V2D.vequal?(bezier.point( 0.5 ), simibezier.lastpoint ))
    assert( V2D.vequal?(bezier.point( 0.5 ), simibezier.bezier(2).firstpoint ))
    assert_equal( 4, simibezier.piecenumber )
  end

  def test_complete
    assert_equal( V2D::O, LinearBezier.buildwithangle( 0.0 ).firstpoint )
  end

end

class FitBezierBuilderTest < Test::Unit::TestCase

  def test_all
    bezier = Bezier.raw( V2D[0.0, 0.0], V2D[100.0, 0.0], V2D[0.0, 100.0], V2D[100.0, 100.0] )
    points = bezier.samples( 15 )
    fit  = FitBezierBuilder[ :points, points, :maxerror, 0.001 ]
    assert_equal( 3, fit.piecenumber )
  end
end

class CircleTest < Test::Unit::TestCase

  def test_bezier
    assert_equal( 4, Circle[].bezier.piecenumber )
  end
end
