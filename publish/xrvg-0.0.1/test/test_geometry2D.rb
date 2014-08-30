require 'test/unit'
require 'geometry2D.rb'

# Test class
class VectorTest < Test::Unit::TestCase
  
  def test_indice
    s = Vector[0,1]
    assert_equal(1, s[1])
    assert_equal(0, s[0])
  end
  
  def test_add
    s = Vector[0,1]
    t = Vector[2,3]
    assert_equal(Vector[2,4], s + t)
  end
  
  def test_norm
    assert_equal(Vector[0,1], Vector[0,2].norm)
  end
  
  def test_angle
    assert_equal(0.0,  Vector[0,0].angle)
    assert_equal(0.0,  Vector[1,0].angle)
    assert_equal(Math::PI * 0.5, Vector[0,1].angle)
    assert_equal(-Math::PI * 0.5, Vector[0,-1].angle)
  end
  
  def test_mean
    assert_equal(Vector[0,1], (Vector[0,0]..Vector[0,2]).middle)
  end
  
  def test_length
    assert_equal(1,Vector[0,1].length)
  end
  
  def test_interpol
    assert_equal(Vector[0.2,1.4], (Vector[0.0, 1.0]..Vector[1.0, 3.0]).sample( 0.2 ))
  end
  
  def test_createwithpoints
    
    assert_equal(Vector[1,1],Vector.createwithpoints(Point[0,0],
						     Point[1,1]))
  end

  def test_ortho
    assert_equal(Vector[-0.6,0.5],
		 Vector[0.5,0.6].ortho)
  end
  
  def test_reverse
    assert_equal(Vector[-0.6,-0.5],
		 Vector[0.6,0.5].reverse)
  end
  
  def test_viewbox
    assert_equal( [1.0, 1.0, 2.0, 2.0],
		 Point.viewbox( [Point[1.0, 2.0], Point[2.0, 1.0]] ))
  end
		 
  def test_size
    assert_equal( [1.0, 1.0],
		 Point.size( [Point[1.0, 2.0], Point[2.0, 1.0]] ))
  end

  def test_operation_sequences
    assert_equal(Vector[0.0,1.0],
		 Vector[1.0,0.0].norm.ortho)
  end

  def test_inner_product
    assert_equal( 1.0, Vector[1.0, 0.0].inner_product( Vector[1.0,1.0] ) )
  end
end
