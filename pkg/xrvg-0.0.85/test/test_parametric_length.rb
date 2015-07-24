require 'test/unit'
require 'bezier'

class ParametricLengthTest < Test::Unit::TestCase

  class A
    include ParametricLength
  end
  
  def test_holes
    assert_raise(NotImplementedError) {A[].parameter_range}
    assert_raise(NotImplementedError) {A[].pointfromparameter( 0.0, V2D[] )}
  end

end
