require 'test/unit'
require 'frame'
require 'geometry2D'

class FrameTest < Test::Unit::TestCase
  
  def test_frame1
    frame = Frame[ :center, Vector[0.0,0.0], :vector, Vector[1.0,0.0], :rotation, 0.0, :scale, 1.0 )
    assert_equal( 0.0, frame.center[0] )
  end

end
