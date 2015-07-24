require 'test/unit'
require 'geovariety'


class GeoVarietor
  include GeoVariety
end

class GeoVarietyTest < Test::Unit::TestCase

  def test_abstract
    assert_raise(NotImplementedError){GeoVarietor[].point(V2D::O)}
    assert_raise(NotImplementedError){GeoVarietor[].line(0.0,1.0,0.5)}
  end
end

class InterBezierTest2 < Test::Unit::TestCase

  def test_point
    bezier1 = Bezier.raw( V2D::O, V2D::X, V2D::O, V2D::X  )
    center  = V2D::O
    bezier2 = Bezier.raw( center, center, center, center )
    interbezier  = InterBezier.new( :bezierlist, [0.0, bezier1, 1.0, bezier2] )
    assert( V2D.vequal?( interbezier.sample( 0.5 ).point( 0.5 ), interbezier.point( V2D[0.5,0.5] ) ) )
  end

  def test_line
    bezier1 = Bezier.raw( V2D::O, V2D::X, V2D::O, V2D::X  )
    center  = V2D::O
    bezier2 = Bezier.raw( center, center, center, center )
    interbezier  = InterBezier.new( :bezierlist, [0.0, bezier1, 1.0, bezier2] )
    raw = interbezier.sample( 0.5 ).subbezier( 0.3, 0.7 )
    geo = interbezier.line( 0.3, 0.7, 0.5 )
    [raw.pointlist, geo.pointlist].forzip do |p1,p2|
      assert( V2D.vequal?( p1, p2 ) )
    end
  end

  def test_bezier
    bezier1     = Bezier.raw( V2D::O, V2D::X, V2D::O, V2D::X  )
    center      = V2D::O
    bezier2     = Bezier.raw( center, center, center, center )
    interbezier = InterBezier.new( :bezierlist, [0.0, bezier1, 1.0, bezier2] )

    geo = interbezier.bezier( (V2D[0.0,0.5]..V2D[1.0,0.5]), bezier1 )
    raw = LinearBezier[ :support, [V2D::O, V2D::X * 0.5] ]
    [raw.pointlist, geo.pointlist].forzip do |p1,p2|
      assert( V2D.vequal?( p1, p2 ) )
    end
  end
end


class OffsetVarietyTest < Test::Unit::TestCase

  def test_point
    offsetvariety = OffsetVariety[ :support, LinearBezier.buildwithangle( 0.0 ), :ampl, 1.0 ]
    assert( V2D.vequal?( V2D[0.5,0.0], offsetvariety.point( V2D[0.5,0.5] ) ) )
  end

  def test_line
    offsetvariety = OffsetVariety[ :support, LinearBezier.buildwithangle( 0.0 ), :ampl, 1.0 ]
    geo = offsetvariety.line( 0.25, 0.75, 0.75 )
    raw = LinearBezier[ :support, [V2D[0.25,0.5], V2D[0.75,0.5]] ]
    [raw.pointlist, geo.pointlist].forzip do |p1,p2|
      assert( V2D.vequal?( p1, p2 ) )
    end
  end

  def test_bezier
    offsetvariety = OffsetVariety[ :support, LinearBezier.buildwithangle( 0.0 ), :ampl, 1.0 ]
    geo = offsetvariety.bezier( (V2D[0.25,0.75]..V2D[0.75,0.75]), LinearBezier.buildwithangle( 0.0 ) )
    raw = LinearBezier[ :support, [V2D[0.25,0.5], V2D[0.75,0.5]] ]
    [raw.pointlist, geo.pointlist].forzip do |p1,p2|
      assert( V2D.vequal?( p1, p2 ) )
    end
  end
end

class FuseauVarietyTest < Test::Unit::TestCase

  def test_point
    offsetvariety = FuseauVariety[ :support, LinearBezier.buildwithangle( 0.0 ), :ampl, 1.0 ]
    assert( V2D.vequal?( V2D[0.5,0.0], offsetvariety.point( V2D[0.5,0.5] ) ) )
  end

  def test_line
    offsetvariety = FuseauVariety[ :support, LinearBezier.buildwithangle( 0.0 ), :ampl, 1.0 ]
    geo = offsetvariety.line( 0.25, 0.75, 0.5 )
    raw = LinearBezier[ :support, [V2D[0.0,0.0], V2D[1.0,0.0]] ].subbezier( 0.25, 0.75 )
    [raw.pointlist, geo.pointlist].forzip do |p1,p2|
      assert( V2D.vequal?( p1, p2 ) )
    end
  end

  def test_bezier
    offsetvariety = FuseauVariety[ :support, LinearBezier.buildwithangle( 0.0 ), :ampl, 1.0 ]
    geo = offsetvariety.bezier( (V2D[0.25,0.5]..V2D[0.75,0.5]), LinearBezier.buildwithangle( 0.0 ) )
    raw = LinearBezier[ :support, [V2D[0.25,0.0], V2D[0.75,0.0]] ]
    [raw.pointlist, geo.pointlist].forzip do |p1,p2|
      assert( V2D.vequal?( p1, p2 ) )
    end
  end
end

