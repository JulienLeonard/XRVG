require 'minitest/autorun'

class Minitest::Test
  alias_method :assert_raise, :assert_raises
  alias_method :assert_not_equal, :refute_equal
end
