require 'test/unit'
require 'geometry2D.rb'

# Test class
class V2DTest < Test::Unit::TestCase
  
  def test_indice
    s = V2D[0,1]
    assert_equal(1, s.y)
    assert_equal(0, s.x)
  end
  
  def test_add
    s = V2D[0,1]
    t = V2D[2,3]
    assert_equal(V2D[2,4], s + t)
  end
    
  def test_angle
    assert_equal(0.0,  V2D[0,0].angle)
    assert_equal(0.0,  V2D[1,0].angle)
    assert_equal(Math::PI * 0.5, V2D[0,1].angle)
    assert_equal(-Math::PI * 0.5, V2D[0,-1].angle)
  end
  
  def test_mean
    assert_equal(V2D[0,1], (V2D[0,0]..V2D[0,2]).middle)
  end
  
  def test_length
    assert_equal(1,V2D[0,1].length)
  end
  
  def test_interpol
    assert_equal(V2D[0.2,1.4], (V2D[0.0, 1.0]..V2D[1.0, 3.0]).sample( 0.2 ))
  end
  
  def test_createwithpoints
    
    assert_equal(V2D[1,1], V2D[1,1] - V2D[0,0])

  end

  def test_norm
    assert_equal( V2D[0.0,1.0], V2D[0.0,2.0].norm )
    assert_equal( V2D[0.0,0.0], V2D[0.0,0.0].norm )
  end

  def test_ortho
    assert_equal(V2D[-0.6,0.5],
		 V2D[0.5,0.6].ortho)
  end
  
  def test_reverse
    assert_equal(V2D[-0.6,-0.5],
		 V2D[0.6,0.5].reverse)
  end
  
  def test_viewbox
    assert_equal( [1.0, 1.0, 2.0, 2.0], V2D.viewbox( [V2D[1.0, 2.0], V2D[2.0, 1.0]] ))
    assert_equal( [0.0, 0.0, 0.0, 0.0], V2D.viewbox( [] ))
  end
		 
  def test_size
    assert_equal( [1.0, 1.0],
		 V2D.size( [V2D[1.0, 2.0], V2D[2.0, 1.0]] ))
  end

  def test_operation_sequences
    assert_equal(V2D[0.0,1.0],
		 V2D[1.0,0.0].norm.ortho)
  end

  def test_inner_product
    assert_equal( 1.0, V2D[1.0, 0.0].inner_product( V2D[1.0,1.0] ) )
  end

  def test_vequal
    assert( V2D.vequal?( V2D::O, V2D::X * 0.0 ) ) 
    assert( V2D.vequal?( V2D::O, V2D::O + V2D::X * 0.01, 0.1 ) )
    assert_equal( false, V2D.vequal?( V2D::O, V2D::O + V2D::X * 0.01, 0.001 ) )
  end

  def test_pointer
    v = V2D[1.0,2.0]
    a = v
    a.x = 3.0
    assert_equal( 3.0, v.x )
  end

  def test_succ
    assert_equal( V2D[1.0,1.0], V2D[].succ )
  end

  def test_scale
    assert_equal( V2D[2.0,6.0], V2D[1.0,2.0].scale( V2D[2.0,3.0]) )
  end

  def test_sym
    assert_equal( V2D[2.0,4.0], V2D[1.0,2.0].sym( V2D[0.0,0.0] ) )
  end

  def test_coords
    assert_equal( [0.0,1.0], V2D[0.0,1.0].coords )
    assert_equal( [1.0,Math::PI/2.0], V2D[0.0,1.0].coords(:polar) )
    assert_raise(RuntimeError) {V2D[0.0,1.0].coords(:toto)}
  end

  def test_polar
    assert( V2D.vequal?( V2D[0.0,1.0], V2D.polar( 1.0, Math::PI/2.0 ) ) )
  end

end
