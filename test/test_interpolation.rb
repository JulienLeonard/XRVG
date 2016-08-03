require 'test_helper'
require 'interpolation'

class InterpolatorTest < Minitest::Test
  
  def test_interpolator
    interpolator = Interpolator[ :samplelist, [0.0,0.0, 1.0,2.0, 2.0,0.0, 3.0,2.0]]
    assert_equal( 1.0, interpolator.interpolate( 0.5 ) )
    assert_equal( 1.0, interpolator.interpolate( 2.5 ) )
    assert_equal( 2.0, interpolator.interpolate( 3.5 ) )
  end

  class A
      include Interpolation
  end
  def test_interpolation
    assert_raise(NotImplementedError) {A[].samplelist}
    assert_equal( :linear, A[].interpoltype )
  end

end
