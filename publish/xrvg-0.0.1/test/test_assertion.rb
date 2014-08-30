require 'test/unit'
require 'assertion'

class AssertionTest < Test::Unit::TestCase
  
  def test_assertion
    # TODO : conflict between TestUnit assert and new assert general method in assertion.rb
    # ::assert {1 == 2}
  end
end

puts "test true"
assert { 1 == 1}
puts "test false"
assert { 1 == 2}
