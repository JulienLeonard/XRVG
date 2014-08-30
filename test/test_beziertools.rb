require 'beziertools'
require 'test/unit'

class SimpleBezierTest < Test::Unit::TestCase
  def test_all
    bezier = SimpleBezier[ :support, [V2D::O,V2D::X, V2D::X+V2D::Y] ]
    assert_equal( V2D::O, bezier.firstpoint )
    assert_equal( 2, bezier.piecenumber )
    assert_raise(RuntimeError){SimpleBezier[ :support, [V2D::O] ]}
    assert_equal( SimpleBezier[ :support, [V2D::O,V2D::X] ].point( 0.3 ), LinearBezier[ :support, [V2D::O,V2D::X] ].point( 0.3 )  )
  end

  def test_interpolation
    interpolator = Interpolator[ :samplelist, [0.0,0.0, 0.5,1.0, 1.0,0.0], :interpoltype, :simplebezier]
    assert( 1.0.fequal?( interpolator.interpolate( 0.5 ) ) )
    assert( 0.0.fequal?( interpolator.interpolate( 1.0 ) ) )
  end

end

class ClosureTest < Test::Unit::TestCase

  def test_all
    bezier = SimpleBezier[ :support, [V2D::O, V2D::X, V2D::X+V2D::Y] ]
    closure = ClosureBezier[ :bezierlist, [bezier, LinearBezier[ :support, [V2D::X, -V2D::X] ]]]
    assert_equal( V2D::O, closure.lastpoint )
    assert_equal( 5, closure.piecenumber )
  end

end

class OffestTest < Test::Unit::TestCase

  def test_all
    bezier = LinearBezier.buildwithangle( 0.0 )
    offset = Offset[ :support, bezier, :ampl, 1.0, :nsamples, 10 ]
    assert( V2D.vequal?( V2D::O + V2D::Y, offset.firstpoint ) )
    assert( V2D.vequal?( V2D::O + V2D::X + V2D::Y, offset.lastpoint ) )
  end

  def test_roller
    bezier = LinearBezier.buildwithangle( 0.0 )
    offset = Offset[ :support, bezier, :ampl, (0.0..1.0).samples(10), :nsamples, 10 ]
    assert( V2D.vequal?( V2D::O, offset.firstpoint ) )
    assert( V2D.vequal?( V2D::O + V2D::X + V2D::Y, offset.lastpoint ) )
  end

  def test_sampler
    bezier = LinearBezier.buildwithangle( 0.0 )
    offset = Offset[ :support, bezier, :ampl, (0.0..1.0), :nsamples, 10 ]
    assert( V2D.vequal?( V2D::O, offset.firstpoint ) )
    assert( V2D.vequal?( V2D::O + V2D::X + V2D::Y, offset.lastpoint ) )
  end

end
    
class FuseauTest < Test::Unit::TestCase

  def test_all
    bezier = LinearBezier.buildwithangle( 0.0 )
    offset = Fuseau[ :support, bezier, :maxwidth, 1.0, :nsamples, 10 ]
    assert( V2D.vequal?( V2D::O + V2D::X, offset.lastpoint ) )
    assert( V2D.vequal?( V2D::O + V2D::Y, offset.firstpoint ) )
  end

end

class BezierLevelTest < Test::Unit::TestCase

  def test_all
    offset = BezierLevel[ :samplelist, [0.0,0.0, 1.0,1.0]]
    assert( V2D.vequal?( V2D::O, offset.firstpoint ) )
    assert( V2D.vequal?( V2D::O + V2D::Y + V2D::X, offset.lastpoint ) )
  end

end

class OndulationTest < Test::Unit::TestCase

  def test_all
    bezier = LinearBezier.buildwithangle( 0.0 )
    ondulation = Ondulation[ :support, bezier, :ampl, 1.0, :freq, 2 ]
    assert( V2D.vequal?( V2D::O, ondulation.firstpoint ) )
    assert_equal( 4, ondulation.piecenumber )
  end

  def test_roller
    bezier = LinearBezier.buildwithangle( 0.0 )
    ondulation = Ondulation[ :support, bezier, :ampl, (0.0..1.0).samples(2), :freq, 2 ]
    assert( V2D.vequal?( V2D::O, ondulation.firstpoint ) )
    assert_equal( 4, ondulation.piecenumber )
  end

  def test_sampler
    bezier = LinearBezier.buildwithangle( 0.0 )
    ondulation = Ondulation[ :support, bezier, :ampl, (0.0..1.0), :freq, 2 ]
    assert( V2D.vequal?( V2D::O, ondulation.firstpoint ) )
    assert_equal( 4, ondulation.piecenumber )
  end

end


    
