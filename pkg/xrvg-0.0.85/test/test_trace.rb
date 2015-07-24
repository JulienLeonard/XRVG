require 'test/unit'
require 'utils'

class TraceTest < Test::Unit::TestCase

  def test_trace
    Trace("hello")
    Trace.inhibit
    Trace("ghost")
    Trace.activate
    Trace("goodbye")
  end
end
