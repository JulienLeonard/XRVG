require 'shape'
require 'test_helper'

class ShapeTest < Minitest::Test

  def test_abstract
    assert_raise(NotImplementedError){Shape[].contour}
    assert_raise(NotImplementedError){Shape[].svg}
    assert_raise(NotImplementedError){Shape[].viewbox}
  end

  def test_default_style
    assert_equal( Color.black, Shape[].default_style.fill )
  end

end

class CurveTest < Minitest::Test

  def test_abstract
    assert_raise(NotImplementedError){Curve[].contour}
    assert_raise(NotImplementedError){Curve[].svg}
    assert_raise(NotImplementedError){Curve[].point(0.0)}
    assert_raise(NotImplementedError){Curve[].tangent(0.0)}
    assert_raise(NotImplementedError){Curve[].acc(0.0)}
    assert_raise(NotImplementedError){Curve[].length(0.0)}
    assert_raise(NotImplementedError){Curve[].rotation(0.0)}
    assert_raise(NotImplementedError){Curve[].scale(0.0)}
  end

  def test_default_style
    assert_equal( Color.black, Shape[].default_style.fill )
  end

end


class LineTest <  Minitest::Test
  @@line = Line[ :points, [ V2D[ 0.0, 0.0], V2D[ 0.0, 1.0] ] ]
  
  def test_point
    assert_equal( V2D[0.0, 0.3], @@line.point( 0.3 ) )
  end
  
  def test_points
    assert_equal( [V2D[0.0, 0.3], V2D[0.0, 0.7]] , @@line.points( [0.3,0.7] ) )
  end

  def test_tangent
    assert_equal( V2D[0.0, 1.0], @@line.tangent( 0.3 ) )
  end

  def test_tangents
    assert_equal( [V2D[0.0, 1.0],V2D[0.0, 1.0]], @@line.tangents( [0.3,0.7] ) )
  end

  def test_acc
    assert_equal( V2D[0.0, 0.0], @@line.acc( 0.3 ) )
  end
  
  def test_normal
    assert_equal( V2D[-1.0, 0.0], @@line.normal( 0.3 ) )
  end

  def test_normals
    assert_equal( [V2D[-1.0, 0.0],V2D[-1.0, 0.0]], @@line.normals( [0.3,0.7] ) )
  end

  def test_acc_normal
    assert_equal( 0.0, @@line.acc_normal( 0.3 ) )
  end

  def test_curvature
    assert_equal( 0.0, @@line.curvature( 0.3 ) )
  end

  def test_surface
    assert_equal( 0.0, @@line.surface  )
    assert_equal( 1.0, Line[ :points, [ V2D[ 0.0, 0.0], V2D[ 1.0, 1.0] ] ].surface )
  end

  def test_frame
    result = Frame[ :center, V2D[0.0,0.5], :vector,  V2D[0.0,1.0], :rotation,  0.0, :scale, 1.0 ]
    assert_equal( result, @@line.frame( 0.5 ) )
  end

  def test_frames
    result = [Frame[ :center, V2D[0.0,0.5], :vector,  V2D[0.0,1.0], :rotation,  0.0, :scale, 1.0 ],
              Frame[ :center, V2D[0.0,0.7], :vector,  V2D[0.0,1.0], :rotation,  0.0, :scale, 1.0 ]]
    assert_equal( result, @@line.frames( [0.5, 0.7] ) )
  end

  def test_framev
    result = [ V2D[0.0,0.5], V2D[0.0,1.0] ]
    assert_equal( result, @@line.framev( 0.5 ) )
  end


  def test_svg
    line = Line[ :points, [ V2D[ 0.0, 0.0], V2D[ 0.0, 1.0], V2D[ 0.0, 2.0] ] ]
    assert_equal( '<path d="M 0.0 0.0 L 0.0 1.0L 0.0 2.0"/>', line.svg )
  end

  def test_samples
    [Line[].samples(3), [V2D[0.0,0.0], V2D[0.5,0.5], V2D[1.0,1.0]] ].forzip do |v1, v2|
      assert( V2D.vequal?( v1, v2 ) )
    end
  end
  
  def test_length
    line = Line[ :points, [ V2D[ 0.0, 0.0], V2D[ 0.0, 1.0], V2D[ 1.0, 1.0] ] ]
    assert_equal( 2.0, line.length )
  end

  def test_translate
    line = Line[ :points, [ V2D[ 0.0, 0.0], V2D[ 0.0, 1.0], V2D[ 1.0, 1.0] ] ].translate( V2D[1.0,2.0] )
    assert_equal( V2D[ 1.0, 2.0], line.point( 0.0 ) )
    assert_equal( V2D[ 2.0, 3.0], line.point( 2.0 ) )
  end

  def test_reverse
    line = Line[ :points, [ V2D[ 0.0, 0.0], V2D[ 0.0, 1.0], V2D[ 1.0, 1.0] ] ].reverse
    assert_equal( V2D[ 1.0, 1.0], line.point( 0.0 ) )
    assert_equal( V2D[ 0.0, 0.0], line.point( 2.0 ) )
  end
  
end

class CircleTest < Minitest::Test

  def test_default
    circle = Circle[]
    assert_equal( '<circle cx="0.0" cy="0.0" r="1.0"/>', circle.svg )
  end    

  def test_svg
    circle = Circle[ :center, V2D[ 0.0, 0.0 ], :radius, 1.0 ]
    assert_equal( '<circle cx="0.0" cy="0.0" r="1.0"/>', circle.svg )
  end

  def test_viewbox
    circle = Circle[ :center, V2D[ 0.0, 0.0 ], :radius, 1.0 ]
    assert_equal( [-1.0, -1.0, 1.0, 1.0], circle.viewbox )
  end

  def test_samples
    [Circle[].samples(3), [V2D[1.0,0.0], V2D[-1.0,0.0], V2D[1.0,0.0]] ].forzip do |v1, v2|
      assert( V2D.vequal?( v1, v2 ) )
    end
  end

  def test_curvature
    assert( 1.0.fequal?( Circle[].curvature( 0.0 ) ) )
    assert( Circle[].curvature( Range.O.rand ).fequal?( Circle[].curvature( Range.O.rand ) ) )
  end

  def test_diameter
    cd = Circle.diameter( V2D[0.0,1.0], V2D[0.0,-1.0] )
    c2 = Circle[ :center, V2D::O, :radius, 1.0 ]
    assert( V2D.vequal?( cd.center, c2.center ) )
    assert_equal( cd.radius, c2.radius )
    assert( V2D.vequal?( V2D[0.0,1.0], cd.point( 0.0 ) ) )
  end

  def test_rotate
    assert( V2D.vequal?( V2D[0.0,1.0], Circle[].rotate(Math::PI/2.0).point( 0.0 ) ) )
  end
end
