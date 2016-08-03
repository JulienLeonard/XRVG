require 'test_helper'
require 'xrvg'
include XRVG


class StringTest < Minitest::Test

  def test_subreplace
    alpha  = "1"
    beta   = "2"
    tokens = {"%ALPHA%" => alpha, 
      "%BETA%"  => beta }
    assert_equal( "1 > 2", "%ALPHA% > %BETA%".subreplace( tokens ) )
  end
end


class ArrayTest < Minitest::Test

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
    b = []
    [1, 2, 3, 4].foreach {|i, j| b.push( [j,i] )}
    assert_equal( [[2, 1], [4, 3]], b)

    b = []
    [1, 2, 3, 4].foreach {|i| b << i}
    assert_equal( [1, 2, 3, 4], b)
  end
  
  def test_slice
    assert_equal( [1, 2, 3], [0, 1, 2, 3].[](1..-1) )
  end

  def test_slice2
    a = [0, 1, 2, 3]
    assert_equal( [1, 2, 3], a[1..-1] )
  end


  def test_uplets
    assert_equal( [[1, 2], [2, 3]], [1, 2, 3].uplets(2) )
    result = [];     [1, 2, 3].uplets {|i,j| result.push( [i,j] )}
    assert_equal( [[1, 2], [2, 3]], result )
  end

  def test_triplets
    assert_equal( [[1, 2, 3], [2, 3, 4]], [1, 2, 3, 4].triplets )
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
    result = []
    [ [1,2,3,4], ["a","b"] ].forpattern( [0,1,0] ) do |v1, v2, v3|
      result += [v1,v2,v3]
    end
    assert_equal( [1,"a",2,3,"b",4], result )
  end

  def test_sub
    assert_equal( [1,3,5], [1,2,3,4,5].sub(2) )
    assert_equal( [1,3,5], [1,2,3,4,5].half )
    result = []
    [1,2,3,4,5].sub(2) {|v| result << v}
    assert_equal( [1,3,5], result )
  end

  def test_mean
    assert_equal( 3, [1,3,5].mean )    
  end

  def test_range
    assert_equal( (1.0..5.0), [5.0,3.0,1.0].range )    
    assert_equal( (1.0..2.0), [V2D[2.0,1.0], V2D[1.0,2.0]].range( :x ) )    
  end

  def test_choice
    assert_equal( 0.0, [0.0,0.0,0.0].choice )
  end

  def test_rotate
    assert_equal( [3,1,2], [1,2,3].rotate(:right) )
    assert_equal( [2,3,1], [1,2,3].rotate(:left) )
  end
  
  def test_rotations
    assert_equal( [[1,2,3],[2,3,1],[3,1,2]], [1,2,3].rotations(:left) )
    assert_equal( [[1,2,3],[3,1,2],[2,3,1]], [1,2,3].rotations(:right) )
  end

  def test_shuffle
    assert_not_equal( [0.0, 0.1, 0.2, 0.5, 1.0], [0.0,0.1, 0.2, 0.5,1.0].shuffle )
  end
end

class FloatTest < Minitest::Test

  def test_interpol
    assert_equal( 2.3, ( 2.0..3.0 ).sample( 0.3 ) )
  end

  def test_complement
    assert_equal( 0.75, (0.0..1.0).complement( 0.25 ) )
  end

  def test_fequal
    assert( 0.25.fequal?( 0.26,0.02) )
    assert_equal( false, 0.25.fequal?( 0.26,0.01) )
  end

  def test_sort_float_list
    assert_equal( [0.25],      Float.sort_float_list([0.26,0.25], 0.02 ) )
    assert_equal( [0.25,0.26], Float.sort_float_list([0.26,0.25], 0.01 ) )
  end

  def test_float_include
    assert( Float.floatlist_include?( [1.0,2.0,3.0001,4.0], 3.0, 0.001 ) )
    assert_equal( false, Float.floatlist_include?( [1.0,2.0,3.0001,4.0], 3.0, 0.0001 ) )
  end

end

class RangeTest  < Minitest::Test
  
  def test_samples
    assert_equal( [0.0, 0.5, 1.0], (0.0..1.0).samples(3))
    assert_equal( [1.0], (1.0..2.0).samples(1))
  end

  def test_samples2
    # assert_equal( [0.0, 0.667128916301921, 0.889196841637666], (0.0..1.0).geo(2.2).samples(3))
  end

  def test_samples3
    assert_not_equal( [0.0, 1.0], (0.0..1.0).ssort.random.samples(2))
  end
  
  def test_shuffle
    assert_not_equal( [0.0, 0.25, 0.5, 0.75, 1.0], (0.0..1.0).shuffle.samples(5))
    assert_equal( [0.0, 0.25, 0.5, 0.75, 1.0], (0.0..1.0).ssort.shuffle.samples(5))
  end

  def test_samplesblock
    result = []
    (0.0..1.0).samples(3) do |v|
      result << v
    end
    assert_equal( [0.0, 0.5, 1.0], result)
  end


  def test_split
    assert_equal( [(0.0..0.5), (0.5..1.0)], (0.0..1.0).splits(2) )
  end

  def test_modulo
    assert_equal( -0.5, (-1.0..1.5).modulo( 2.0 ) )
  end

  def test_modulos
    assert_equal( [(0.2..0.3)], (0.0..1.0).modulos( (0.2..0.3) ) )
    assert_equal( [(0.3..0.2)], (0.0..1.0).modulos( (0.3..0.2) ) )
    [(0.0..1.0).modulos( (1.1..0.2) ), [(0.1..0.0), (1.0..0.2)]].forzip do |res, exp|
      assert( res.begin.fequal?( exp.begin ) )
      assert( res.end.fequal?( exp.end ) )
    end
    [(0.0..1.0).modulos( (0.2..1.1) ), [(0.2..1.0), (0.0..0.1)]].forzip do |res, exp|
      assert( res.begin.fequal?( exp.begin ) )
      assert( res.end.fequal?( exp.end ) )
    end
    [(0.0..1.0).modulos( (0.2..2.1) ), [(0.2..1.0), (0.0..1.0), (0.0..0.1)]].forzip do |res, exp|
      assert( res.begin.fequal?( exp.begin ) )
      assert( res.end.fequal?( exp.end ) )
    end
  end

  def test_size
    assert_equal( 1.2, (2.0..0.8).size )
  end

  def test_splitblock
    result = []
    (0.0..1.0).splits(2) do |subrange|
      result << subrange
    end
    assert_equal( [(0.0..0.5), (0.5..1.0)], result )
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

  def test_ranges
    # Samplable module
    assert_equal( 1.5, (1.0..2.0).sample(0.5) )
    assert_equal( [1.0, 1.5, 2.0], (1.0..2.0).samples( 3 ) )
    assert_equal( 1.5, (1.0..2.0).mean )
    assert_equal( 1.5, (1.0..2.0).middle )
    assert( (1.0..2.0).rand >= 1.0 )
    assert( (1.0..2.0).rand <= 2.0 )
    assert_equal( 2, (1.0..2.0).rand( 2 ).length )
    assert_equal( 1.8, (1.0..2.0).complement(1.2) )
    assert_equal( 0.5, (1.0..2.0).abscissa(1.5) )
    assert_equal( 1.0, (1.0..1.0).abscissa(1.5) )

    # Splittable module
    assert_equal( (1.2..1.3), (1.0..2.0).split(0.2,0.3) )
    assert_equal( [(1.0..1.5),(1.5..2.0)], (1.0..2.0).splits( 2 ) )
  end

  def test_ranges2
    assert_equal( (0.0..1.0), Range.O  )
    assert_equal( (0.0..2.0*Math::PI), Range.Angle  )
    assert_equal( (2.0..1.0), (1.0..2.0).reverse  )
    assert_equal( (0.0..2.0), (1.0..2.0).sym  )
    assert_equal( (1.0..3.0), (1.0..2.0).symend  )
    assert_equal( 1.0, (1.0..2.0).size  )
    assert_equal( (1.3..2.3), (1.0..2.0).translate(0.3)  )
  end

  def test_range_sym
    assert_equal( (-0.3..0.3), Range.sym(  0.3 ) )
    assert_equal( (-0.5..0.5), Range.sym( -0.5 ) )
  end

  def test_resize
      assert_equal( (-0.5..1.5), Range.O.resize( 2.0 )  )
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

class SampleTest < Minitest::Test

  def test_samples
    assert_equal( [0.0, 1.0, 2.0], (0.0..2.0).samples(3))
  end

  def test_samples2
    assert_equal( [0.0, 1.0, 2.0], (0.0..2.0).samples([0.0,0.5,1.0]))
  end

  def test_hash
    assert_raise(RuntimeError) {Range.O.apply( [0.0], :toto )}
  end

  def test_limit
    assert_equal( [], Range.O.samples(0) )
    result = []
    Range.O.samples(0) {|v| result << v}
    assert_equal( [], result )
  end

  def test_array_samples
    # TODO
    # assert_equal( [0.0, 0.0, 0.864664716763387, 1.72932943352677], [(0.0..1.0),(0.0..2.0)].geo(2.0).samples(3))
  end

  def test_class_sample
    s = SampleClass.new
    assert_equal( ["a0.0", "b0.0", "a0.5", "b0.5", "a1.0", "b1.0"], SyncS[s.filter(:sampleA), s.filter(:sampleB)].samples(3))
  end

  def test_random_split
    splits = Range.O.random.splits( 2 )
    assert_equal( 0.0, splits[0].begin )
    assert_equal( 1.0, splits[1].end )
  end

  def test_geo
    assert_equal( 1.0, (0.0..1.0).geo(100.0).sample( 1.0 ) )
  end

  def test_geofull
    assert_equal( [0.0,2.0/3.0,1.0], (0.0..1.0).geofull(2.0).samples( 3 ))
  end

  def test_alternate
    assert_equal( [1.0,1.5], (1.0..0.0).alternate.samples( [0.0,0.5] ) )
    assert_equal( [0.0,-0.5], AlternateFilter[(0.0..1.0)].samples( [0.0,0.5] ) )
  end

  def test_split_errors
    assert_raise(RuntimeError){Range.O.random.splits( 0 )}
    assert_raise(RuntimeError){Range.O.random.splits( [0.0] )}
    assert_equal( [(0.0..1.0)], (0.0..1.0).splits(1) )
  end

  def test_multisamples
    assert_equal( [0.0, 0.1875, 0.3125, 0.5, 0.625, 0.8125, 0.9375], (0.0..1.0).multisamples( [4, 2], [3.0, 1.0] ) )
  end

  def test_randomgauss
    (0.0..1.0).randgauss
  end

end

