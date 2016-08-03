require 'test_helper'
require 'xrvg'
include XRVG


class V2DExtTest < Minitest::Test

  def test_isLeft
    p0 = V2D::O
    p1 = V2D::X
    assert_equal(  :on,    V2D[ 0.5,  0.0].isLeft( p0, p1 ) )
    assert_equal(  :left,  V2D[ 0.5,  0.1].isLeft( p0, p1 ) )
    assert_equal(  :right, V2D[ 0.5, -0.1].isLeft( p0, p1 ) )
  end
end


class V2DSTest < Minitest::Test

  def test_intersect
    assert_equal( true, V2DS[ V2D[ 0.0, 0.5 ], V2D[ 1.0, -0.5 ] ].intersect?( V2DS[ V2D::X, V2D::O ] ))
    assert_equal( false, V2DS[ V2D[ 0.0, 0.5 ], V2D[ 1.0, -0.5 ] ].intersect?( V2DS[V2D[ 0.0, 1.0 ], V2D[ 1.0, 1.0 ] ]) )
    assert_equal( true, V2DS[ V2D::X, V2D::O ].intersect?( V2DS[ V2D::X, V2D::O ] ) )
    assert_equal( true, V2DS[ V2D::X, V2D::O ].intersect?( V2DS[ V2D::Y, V2D::O ] ) )
    assert_equal( false, V2DS[ V2D::X, V2D::O ].intersect?( V2DS[ V2D::Y + V2D::X, V2D::O + V2D::Y ] ) )
  end

  def test_intersection
    assert_equal( nil, V2DS[ V2D[ 0.0, 0.5 ], V2D[ 1.0, -0.5 ] ].intersection( V2DS[V2D[ 0.0, 1.0 ], V2D[ 1.0, 1.0 ] ]) )
    assert_equal( V2D[0.5,0.0], V2DS[ V2D[ 0.0, 0.5 ], V2D[ 1.0, -0.5 ] ].intersection( V2DS[ V2D::X, V2D::O ] ))
  end

  def test_intersections
    c1 = Bezier.raw( V2D[0.0, 0.0], V2D[1.0, 0.0], V2D[0.0, 1.0], V2D[1.0, 1.0] )
    c2 = LinearBezier[:support, [V2D::O  + V2D::Y, V2D::X]]
    [[0.5, 0.5], Bezier.intersections( c1, c2 )].forzip do |ve, vr|
      assert( ve.fequal?( vr ) )
    end
    c2 = LinearBezier[:support, [V2D::O, V2D::X + V2D::Y]]
    # assert_equal( [0.0, 0.0, 0.5, 0.5, 1.0, 1.0], Bezier.intersections( c1, c2 ) )
  end
end
