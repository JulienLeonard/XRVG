require 'test/unit'
require 'utils'

class IntegerTest < Test::Unit::TestCase

  def test_denum!
    assert_equal( [10.0, 20.0, 30.0], (10.0..30.0).samples( 3 ) )
  end

  def test_numsplit!
    assert_equal( [0.0, 5.0, 10.0], (0.0..10.0).samples( 3 ) )
  end

  def test_itergeo!
    # assert_equal( [1.0, 0.246596963941606, 0.0608100626252179], (1.0..0.0).geo(2.8).samples(3) )
  end

  def test_randsplit1!
    result = 3.randsplit!
    puts "result #{result.join(" ")}"
    assert_equal( 1.0, result[0] + result[1] + result[2] )
  end

  def test_randsplit2!
    result = 3.randsplit!(0.3)
    puts "result minsize 0.3 #{result.join(" ")}"
    assert_equal( 1.0, result[0] + result[1] + result[2] )
    result.each {|v| assert( v > 0.3 ) }
  end

  def test_randsplitsum!
    result = 3.randsplitsum!
    puts "test_randsplitsum! result #{result.join(" ")}"
    result.each_cons(2) {|min, max| assert( min <= max )}
  end

  def test_randsplitsum2!
    result = 3.randsplitsum!(0.3)
    puts "test_randsplitsum! minsize result #{result.join(" ")}"
    result.each_cons(2) {|min, max| assert( min <= max )}
  end

end

class StringTest < Test::Unit::TestCase

  def test_subreplace
    alpha  = "1"
    beta   = "2"
    tokens = {"%ALPHA%" => alpha, 
      "%BETA%"  => beta }
    assert_equal( "1 > 2", "%ALPHA% > %BETA%".subreplace( tokens ) )
  end
end


class ArrayTest < Test::Unit::TestCase

  def test_pairs
    a = [ 1, 2, 3]
    b = Array.new
    a.pairs { |i1, i2| b.push( [i1, i2] ) }
    assert_equal( [[1,2] , [2,3]], b )
  end

  def test_pairs2
    a = [ 1, 2, 3]
    assert_equal( [[1,2] , [2,3]], a.pairs )
  end


  def test_foreach
    b = Array.new
    [1, 2, 3, 4].foreach {|i, j| b.push( [j,i] )}
    assert_equal( [[2, 1], [4, 3]], b)
  end
  
  def test_slice
    assert_equal( [1, 2, 3], [0, 1, 2, 3].[](1..-1) )
  end

  def test_uplets
    assert_equal( [[1, 2], [2, 3]], [1, 2, 3].uplets(2) )
    result = [];     [1, 2, 3].uplets {|i,j| result.push( [i,j] )}
    assert_equal( [[1, 2], [2, 3]], result )
  end

  def test_assignment
    a, b, c = [1, 2, 3]
    assert_equal( a, 1 )
    assert_equal( b, 2 )
    assert_equal( c, 3 )
  end
  
  def test_hash
    a = ["a", 1, "b", 2, "c", 3]
    b = Hash[ *a ]
    assert_equal( 1, b["a"] )
  end

  def test_flattenonce
    assert_equal( [1,2], [[1], [2]].flattenonce )
  end

  def test_forzip
    assert_equal( [1,2,"a",3,4,"b"], [ [1,2,3,4], ["a","b"] ].forzip( [2,1] ) )
    assert_equal( [1,2,"a",3,4,"b"], [ [1,2,3,4], ["a","b"] ].forzip( [2] ) )
    result = []; [ [1,2,3,4], ["a","b"] ].forzip( [2,1] ) {|i,j,k| result.push( [k,j,i] )}
    assert_equal( [["a",2,1],["b",4,3]], result )
    assert_equal( [[1], 1, [2], 2], [[[1],[2]], [1, 2]].forzip )
  end

  def test_forpattern
    assert_equal( [1,2,"a",3,4,"b"], [ [1,2,3,4], ["a","b"] ].forpattern( [0,0,1] ) )
    assert_equal( [1,"a",2,3,"b",4], [ [1,2,3,4], ["a","b"] ].forpattern( [0,1,0] ) )
  end

  def test_sub
    assert_equal( [1,3,5], [1,2,3,4,5].sub(2) )
    assert_equal( [1,3,5], [1,2,3,4,5].half )
  end

end

class FloatTest < Test::Unit::TestCase

  def test_interpol
    assert_equal( 2.3, ( 2.0..3.0 ).sample( 0.3 ) )
  end

  def test_complement
    assert_equal( 0.75, 0.25.complement )
  end

  def test_randsplit
    assert_equal( 2, 0.25.randsplit.length )
    puts "randsplit 0.25 #{0.25.randsplit}"
    r = 0.25.randsplit
    assert_equal( 0.25, r[0] + r[1] )
  end

end

class RangeTest  < Test::Unit::TestCase
  
  def test_samples
    assert_equal( [0.0, 0.5, 1.0], (0.0..1.0).samples(3))
  end

  def test_samples2
    # assert_equal( [0.0, 0.667128916301921, 0.889196841637666], (0.0..1.0).geo(2.2).samples(3))
  end

  def test_split
    assert_equal( [(0.0..0.5), (0.5..1.0)], (0.0..1.0).splits(2) )
  end

  def test_split2
    # assert_equal( [(0.0..0.75), (0.75..1.0)], (0.0..1.0).geo(3.0).splits(2) )
  end

  def test_period
    assert_equal( [0.0, 0.5, 1.0], (0.0..1.0).samples(3))
    assert_equal( [0.0, 0.5, 1.0, 1.5, 2.0], (0.0..2.0).samples(5))
  end

  def test_bisamples
    # assert_equal( [0.0, 0.5, 1.0], (0.0..1.0).bisamples([0.5, 0.5]) )
    # assert_equal( [0.0, 0.4, 0.5, 0.9, 1.0], (0.0..1.0).bisamples([0.4, 0.1]) )
  end
end

class SampleClass
  include Samplable

  def sampleA( abs ) 
    return "a#{abs}"
  end

  def sampleB( abs ) 
    return "b#{abs}"
  end
end

class SampleTest < Test::Unit::TestCase

  def test_samples
    assert_equal( [0.0, 1.0, 2.0], (0.0..2.0).samples(3))
  end

  def test_array_samples
    # TODO
    # assert_equal( [0.0, 0.0, 0.864664716763387, 1.72932943352677], [(0.0..1.0),(0.0..2.0)].geo(2.0).samples(3))
  end

  def test_class_sample
    s = SampleClass.new
    assert_equal( ["a0.0", "b0.0", "a0.5", "b0.5", "a1.0", "b1.0"], [s.filter(:sampleA), s.filter(:sampleB)].samples(3))
  end

  def test_roller
    assert_equal( ["a", "b", "a"], Roller["a","b"].samples(3))
  end

end
