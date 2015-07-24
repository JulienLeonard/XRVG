require 'test/unit'
require 'xrvg'
include XRVG

class STest < Test::Unit::TestCase

  def test_sin
    [[0.0,0.0], (0.0..1.0).sin().samples( 2 )].forzip do |exp, real|
      assert( exp.fequal?( real ) )
    end
  end

  def test_random
    result = (0.0..1.0).random.samples( 10 )
    assert_not_equal( result, result.sort )
    result = (0.0..1.0).random(:sort,true).samples( 10 )
    assert_equal( result, result.sort )
    result = (0.0..1.0).random(:mindiff, 0.01).samples( 10 )
    assert_not_equal( result, result.sort )
  end
end

class SyncTest < Test::Unit::TestCase

  def test_samples
    assert_equal( [0.0, 1.0, 0.5, 0.5, 1.0, 0.0], SyncS[(0.0..1.0), (1.0..0.0)].samples(3))
  end

  def test_samples2
    result = []
    SyncS[(0.0..1.0), (1.0..0.0)].samples(3) {|v1,v2| result += [v1,v2] }
    assert_equal( [0.0, 1.0, 0.5, 0.5, 1.0, 0.0], result )
  end

  def test_sample
    assert_equal( [0.0, 0.5, 0.75], SyncS[(0.0..0.75)].geofull(2.0).samples( 3 ) )
    assert_equal( [0,1,0], SyncS[ [0,1] ].samples( 3 ) )
  end

end

class RollerTest < Test::Unit::TestCase

  def test_roller
    assert_equal( ["a", "b", "a"], Roller["a","b"].samples(3))

    randresult = Roller["a","b"].rand
    assert( ["a","b"].include?( randresult ) )

    randresult = Roller["a","b"].rand(2)
    randresult.each do |value|
      assert( ["a","b"].include?( value ) )
    end
  end

  def test_next
    roller = Roller[0,1]
    result = []
    3.times do
      result << roller.next
    end
    assert_equal( [0,1,0], result )
  end

end

class RandomTest < Test::Unit::TestCase

  def test_random
    result = Range.O.random(:mindiff,0.0).samples( 3 )
    # what kinf of test ?
    assert_raise(RuntimeError) {Range.O.random(:mindiff,6.0).samples( 3 )}
    assert_equal( [0.0,1.0,2.0], (0.0..2.0).random(:mindiff,0.5,:sort,true).samples( 3 ) )
    assert_not_equal( [0.0, 1.0], (0.0..1.0).random.samples(2))
    assert_equal( [0.0, 0.5, 1.0], (0.0..1.0).random(:mindiff,0.5,:sort,true).samples(3))
    assert_raise(RuntimeError) {(0.0..1.0).random(:mindiff,0.6).samples(3)}

    result = Range.O.random(:mindiff,0.0, :withboundaries, true).samples( 3 )
    assert_equal( 0.0, result[0] )
    assert_equal( 1.0, result[-1] )
  end

end

