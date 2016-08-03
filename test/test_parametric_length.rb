require 'test_helper'
require 'bezier'

class ParametricLengthTest < Minitest::Test

  class A
    include ParametricLength
  end
  
  def test_holes
    assert_raise(NotImplementedError) {A[].parameter_range}
    assert_raise(NotImplementedError) {A[].pointfromparameter( 0.0, V2D[] )}
  end

end
