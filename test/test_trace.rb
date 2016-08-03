require 'test_helper'
require 'utils'

class TraceTest < Minitest::Test

  def test_trace
    Trace("hello")
    Trace.inhibit
    Trace("ghost")
    Trace.activate
    Trace("goodbye")
  end
end
