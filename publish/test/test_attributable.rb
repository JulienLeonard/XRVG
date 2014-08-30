require 'test/unit'
require 'attributable'
require 'utils'

class AttrClass
  include Attributable

  attribute :a, 1.0
  attribute :b, nil, Float
  attribute :c
end


# Test class
class AttributableTest < Test::Unit::TestCase
  
  def test_nominal
    obj = AttrClass[ :b, 2.0, :c, 3.0 ]
    assert_equal( 1.0, obj.a)
    assert_equal( 2.0, obj.b)
    assert_equal( 3.0, obj.c)
  end

end
