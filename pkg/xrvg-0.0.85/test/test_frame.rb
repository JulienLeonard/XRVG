require 'test/unit'
require 'frame'
require 'geometry2D'

class FrameTest < Test::Unit::TestCase
  
  def test_frame1
    frame1 = Frame[ :center, V2D[0.0,0.0], :vector, V2D[1.0,0.0], :rotation, 0.0, :scale, 1.0 ]
    frame2 = Frame[ :center, V2D[0.0,0.0], :vector, V2D[1.0,0.0], :rotation, 0.0, :scale, 1.0 ]
    frame3 = Frame[ :center, V2D[0.0,0.0], :vector, V2D[1.0,0.0], :rotation, 1.0, :scale, 1.0 ]

    assert_equal( 0.0, frame1.center.x )
    assert( frame1 == frame2 )
    assert( !(frame1 == frame3) )
  end

end
