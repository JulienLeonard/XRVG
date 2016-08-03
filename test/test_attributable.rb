require 'test_helper'
require 'attributable'
require 'utils'
include XRVG

class AttrClass
  include XRVG::Attributable
  
  attribute :a, 1.0
  attribute :b, nil, Float
  attribute :c
end

class AttrClass1
  include XRVG::Attributable
  
  attribute :a, []
  
  def adda (value)
    @a.push( value )
  end
end

# Test class
class AttributableTest < Minitest::Test

  def test_object
    Object[]
  end

  
  def test_nominal
    obj = AttrClass[ :b, 2.0, :c, 3.0 ]
    assert_equal( 1.0, obj.a)
    assert_equal( 2.0, obj.b)
    assert_equal( 3.0, obj.c)
  end

  def test_nominal2
    obj1 = AttrClass[ :b, 2.0, :c, 2.0 ]
    obj2 = AttrClass[ :b, 3.0, :c, 3.0 ]
    
    assert_equal( 1.0, obj1.a)
    assert_equal( 2.0, obj1.b)
    assert_equal( 3.0, obj2.c)
  end

  def test_init
    obj1 = AttrClass1[]
    obj2 = AttrClass1[]
    obj2.adda(1)
    assert_equal( [], obj1.a )
  end

  def test_error1
    assert_raise(RuntimeError) {AttrClass[:c, 1, :b, 1.0, :toto, 2]}
  end

  def test_error2
    assert_raise(RuntimeError) {AttrClass[:c, 1, :b, 1, :a, 2]}
  end

  def test_error3
    assert_raise(RuntimeError) {AttrClass[]}
  end

  # cannot be tested because cannot declare class in method
  #  class B;   
  #    include XRVG::Attributable;
  #    assert_raise(RuntimeError) {attribute :c, nil, :toto}
  #  end
  # end

end

