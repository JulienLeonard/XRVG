require 'test/unit'
require 'bezier'

class BezierTest < Test::Unit::TestCase

  @@piece = [ :raw, V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0] ]
  @@bezier = Bezier.single( *@@piece )
  @@beziersym = Bezier.raw( V2D[0.0, 0.0], V2D[1.0, 0.0], V2D[0.0, 1.0], V2D[1.0, 1.0] )
  @@pieces = [[:raw, V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0,   0.0],   V2D[1.0, 0.0] ],
              [:raw, V2D[1.0, 0.0], V2D[2.0, 2.0], V2D[1.0, 1.0], V2D[2.0, 0.0] ]]
  @@multibezier = Bezier.multi( @@pieces )

  def test_builder
    b = Bezier.new( :pieces, [BezierSpline[:raw, V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0]]] )
    assert_equal( V2D[0.0, 1.0], b.firstpoint )

    b = Bezier[ :pieces, [BezierSpline[:raw, V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0]]]]
    assert_equal( V2D[0.0, 1.0], b.firstpoint )

    b = Bezier.single( :raw, V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0] )
    assert_equal( V2D[0.0, 1.0], b.firstpoint )

    b = Bezier.raw( V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0] )
    assert_equal( V2D[0.0, 1.0], b.firstpoint )
    
    b = Bezier.vector( V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0] )
    assert_equal( V2D[0.0, 1.0], b.firstpoint )
    
    b = Bezier.multi( [@@piece] )
    assert_equal( V2D[0.0, 1.0], b.firstpoint )

    b = Bezier.multi( [@@piece,@@piece] )
    assert_equal( V2D[0.0, 1.0], b.firstpoint )
  end

  def test_builder2
    b = Bezier.raws( V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[1.0, 0.0], V2D[2.0, 0.0] )
    assert_equal( V2D[0.0, 1.0], b.firstpoint )
    assert( V2D.vequal?( @@bezier.point( 0.1, nil, :parameter ), b.point( 0.1, nil, :parameter ) ) )

    b = Bezier.vectors( V2D[0.0, 1.0], V2D[1.0, 0.0], V2D[1.0, 0.0], V2D[1.0, 0.0] )
    assert_equal( V2D[0.0, 1.0], b.firstpoint )
    assert( V2D.vequal?( @@bezier.point( 0.1, nil, :parameter ), b.point( 0.1, nil, :parameter ) ) )
  end

  def test_builder3
    b = Bezier[ :pieces, [BezierSpline[:vector, V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0]]]]
    assert_equal( V2D[0.0, 1.0], b.firstpoint )
    assert_equal( V2D[0.0, 0.0], b.lastpoint )

    assert_raise(RuntimeError) {Bezier.raws( 1.0, V2D[1.0, 1.0], V2D[1.0, 0.0], V2D[2.0, 0.0] )}
  end

  def test_builder4
    b = Bezier.vectorreg( V2D::O, V2D[0.1,0.0], V2D::X, V2D[-0.1,0.0] )
    c = LinearBezier[]
    assert_equal( b.pointlist, c.pointlist )
  end


  def test_piece_f
    piece = BezierSpline[:vector, V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0]]
    assert_equal( V2D[0.0, 1.0], piece.firstpoint )
    assert_equal( V2D[0.0, 0.0], piece.lastpoint )
    piece = BezierSpline[:vector, V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0]]
    assert_equal( V2D[1.0, 1.0], piece.tangent(0.0) )
    piece = BezierSpline[:vector, V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0]]
    assert_equal( V2D[-2.0, -6.0], piece.acc(0.0) )
  end
  
  def test_O
    assert_equal( [V2D::O, V2D::O, V2D::O, V2D::O], Bezier::O.pointlist )
    assert_equal( V2D::O, Bezier::O.sample(0.5) )
  end
  
  def test_piece
    assert_equal( V2D[0.0, 1.0], @@multibezier.piece( 0 ).firstpoint )
    assert_equal( V2D[1.0, 0.0], @@multibezier.piece( 1 ).firstpoint )
    
    assert_equal( V2D[0.0, 1.0], @@multibezier.piece( 0.2 ).firstpoint )
    assert_equal( V2D[1.0, 0.0], @@multibezier.piece( 0.7 ).firstpoint )

    assert_equal( V2D[0.0, 1.0], @@multibezier.piece( 0.2, :parameter ).firstpoint )
    assert_equal( V2D[0.0, 1.0], @@multibezier.piece( 0.7, :parameter ).firstpoint )
    assert_equal( V2D[1.0, 0.0], @@multibezier.piece( 1.2, :parameter ).firstpoint )
  end
  
  def test_piecenumber
    assert_equal( 1, @@bezier.piecenumber )
    assert_equal( 2, @@multibezier.piecenumber )
  end
  
  def test_viewbox
    assert_equal( [0.0, 0.0, 1.0, 1.0], @@bezier.viewbox )
  end

  def test_pointlist
    assert_equal( [ V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0],
		   V2D[1.0, 0.0],  V2D[2.0, 2.0], V2D[1.0, 1.0], V2D[2.0, 0.0] ], @@multibezier.pointlist() )
    assert_equal( [ V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0],
		   V2D[1.0, 0.0],  V2D[2.0, 2.0], V2D[1.0, 1.0], V2D[2.0, 0.0] ], @@multibezier.pointlist(:raw) )
    assert_equal( [ V2D[0.0, 1.0], V2D[1.0, 0.0], V2D[1.0, 0.0], V2D[-1.0, 0.0],
		   V2D[1.0, 0.0],  V2D[1.0, 2.0], V2D[2.0, 0.0], V2D[-1.0, 1.0] ], @@multibezier.pointlist(:vector) )

    assert_equal( [ V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0]], @@multibezier.piece(0).pointlist() )
    assert_equal( [ V2D[1.0, 0.0], V2D[2.0, 2.0], V2D[1.0, 1.0], V2D[2.0, 0.0]], @@multibezier.piece(1).pointlist() )

    assert_equal( [ V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0]], @@multibezier.piece(0).pointlist(:raw) )
    assert_equal( [ V2D[1.0, 0.0], V2D[2.0, 2.0], V2D[1.0, 1.0], V2D[2.0, 0.0]], @@multibezier.piece(1).pointlist(:raw) )

    assert_equal( [ V2D[0.0, 1.0], V2D[1.0, 0.0], V2D[1.0, 0.0], V2D[-1.0, 0.0]], @@multibezier.piece(0).pointlist(:vector) )
    assert_equal( [ V2D[1.0, 0.0], V2D[1.0, 2.0], V2D[2.0, 0.0], V2D[-1.0, 1.0]], @@multibezier.piece(1).pointlist(:vector) )
    
    assert_equal( [ V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0]], @@multibezier.piece(0.2).pointlist(:raw) )
    assert_equal( [ V2D[1.0, 0.0], V2D[2.0, 2.0], V2D[1.0, 1.0], V2D[2.0, 0.0]], @@multibezier.piece(0.8).pointlist(:raw) )

    assert_equal( [ V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0]], @@multibezier.piece(0.2, :parameter).pointlist )
    assert_equal( [ V2D[1.0, 0.0], V2D[2.0, 2.0], V2D[1.0, 1.0], V2D[2.0, 0.0]], @@multibezier.piece(1.2, :parameter).pointlist )

    assert_raise(RuntimeError) {@@multibezier.pointlist(:toto)}
    assert_raise(RuntimeError) {@@multibezier.piece(0.2,:toto).pointlist}
    
  end

  def test_firstpoint
    assert_equal( V2D[0.0, 1.0], @@multibezier.firstpoint )
  end

  def test_lastpoint
    assert_equal( V2D[2.0, 0.0], @@multibezier.lastpoint )
  end

  def test_beziers
    beziers = @@multibezier.beziers
    assert_equal( 2, beziers.length )
    assert_equal( V2D[0.0, 1.0], beziers[0].firstpoint )
    assert_equal( V2D[1.0, 0.0], beziers[1].firstpoint )
  end

  def test_bezier_index
    assert_equal( V2D[0.0, 1.0],  @@multibezier.bezier(0).firstpoint )
    assert_equal( V2D[1.0, 0.0],  @@multibezier.bezier(1).firstpoint )
  end

  def test_data
    assert_equal( [@@piece], @@bezier.data )
  end

  def test_subbezier
    assert_equal( 1, @@multibezier.subbezier(0.0,0.1).piecenumber )
    assert_equal( 2, @@multibezier.subbezier(0.1,0.6).piecenumber )

    pieces = [[:raw, V2D[0.0, 1.0], V2D[1.0, 1.0], V2D[0.0, 0.0], V2D[1.0, 0.0] ],
              [:raw, V2D[1.0, 0.0], V2D[2.0, 2.0], V2D[1.0, 1.0], V2D[2.0, 0.0] ],
              [:raw, V2D[2.0, 0.0], V2D[2.0, 2.0], V2D[1.0, 1.0], V2D[3.0, 0.0] ]]
    assert_equal( 3, Bezier.multi( pieces ).subbezier(0.1,0.9).piecenumber )
    assert_equal( 3, Bezier.multi( pieces ).subbezier(0.9,0.1).piecenumber )
  end

  def test_computelength
    assert( (1.0 -  Bezier.raw( V2D[0.0, 0.0], V2D[1.0, 0.0], V2D[0.0, 0.0], V2D[1.0, 0.0] ).length()).abs < 0.00001 ) 
  end


  def test_point
    assert( V2D.vequal?( V2D[0.5, 0.5], @@beziersym.point( 0.5 ) ) )
  end


#   def test_point_boundary
#     assert( V2D.vequal?( @@beziersym.point( 0.0 ), @@beziersym.point( -1.0 ) ) )
#     assert( V2D.vequal?( @@beziersym.point( 1.0 ), @@beziersym.point( 2.0 ) ) )
#   end

  def test_parameter
    assert( V2D.vequal?( @@beziersym.piece(0).point( 0.1 ), @@beziersym.point( 0.1, nil, :parameter ) ) )
  end

  def test_tangent
    assert( V2D.vequal?( V2D[0.0, 0.5], @@beziersym.tangent( 0.5 ) ) )
  end

  def test_acc
    assert( V2D.vequal?( V2D[0.0, 0.0], @@beziersym.acc( 0.5 ) ) )
  end

  def test_point2
    container = V2D[0.0,0.0]
    assert( V2D.vequal?( V2D[0.5, 0.5], @@beziersym.point( 0.5, container ) ) )
    assert( V2D.vequal?( V2D[0.5, 0.5], container ) )
  end

  def test_tangent2
    container = V2D[0.0,0.0]
    assert( V2D.vequal?( V2D[0.0, 0.5], @@beziersym.tangent( 0.5, container ) ) )
    assert( V2D.vequal?( V2D[0.0, 0.5], container ) )
  end

  def test_tangent3
    container = V2D[0.0,0.0]
    assert( V2D.vequal?( V2D[0.0, 0.0], @@beziersym.acc( 0.5, container ) ) )
    assert( V2D.vequal?( V2D[0.0, 0.0], container ) )
  end
  
  def test_frame
    frame = @@bezier.frame( 0.0 )
    assert_equal( @@bezier.point( 0.0 ), frame.center )
    assert_equal( @@bezier.tangent( 0.0 ), frame.vector )
  end

  def test_reverse
    assert_equal( [V2D[1.0, 0.0], V2D[0.0, 0.0], V2D[1.0, 1.0], V2D[0.0, 1.0]], @@bezier.reverse.pointlist )
  end

  def test_translate
    assert_equal( [V2D[1.0, 4.0], V2D[2.0, 4.0], V2D[1.0, 3.0], V2D[2.0, 3.0] ], @@bezier.translate( V2D[1.0,3.0] ).pointlist )
  end

  def test_similar
    assert_equal( [V2D[1.0, 4.0], V2D[2.0, 4.0], V2D[1.0, 3.0], V2D[2.0, 3.0] ], @@bezier.similar( (V2D[1.0,4.0]..V2D[2.0,3.0]) ).pointlist )
    assert_raise(RuntimeError) {(@@bezier + @@bezier.reverse).similar( (V2D::O..V2D::X) )}
  end

  def test_split1
    assert( V2D.vequal?( V2D[0.5, 0.5], @@beziersym.split(0.0,0.5).lastpoint ) )
    assert( V2D.vequal?( V2D[0.5, 0.5], @@beziersym.split(0.5,1.0).firstpoint ) )
  end

  def test_split2
    assert( V2D.vequal?( V2D::O, Bezier::O.split( 0.0,0.5 ).firstpoint ) )
    assert( V2D.vequal?( V2D::O, Bezier::O.split( 0.5,0.8 ).lastpoint ) )
  end

  def test_splitblock
    result = []
    @@beziersym.splits( 2 ) do |subbezier|
      result << subbezier
    end
    assert_equal( 2, result.length )
  end

  def test_svg
    assert_equal( "<path d=\"M 0.0,1.0C 1.0,1.0 0.0,0.0 1.0,0.0\"/>", @@bezier.svg )
    assert_equal( "<path d=\"M 0.0,1.0C 1.0,1.0 0.0,0.0 1.0,0.0C 0.0,0.0 1.0,1.0 0.0,1.0 z\"/>", (@@bezier + @@bezier.reverse).svg )
  end

  def test_gdebug
    # require 'render'
    render = SVGRender[]
    @@bezier.gdebug( render )
  end

  def test_piecelength
    assert_equal( [0.0,1.0], @@bezier.piecelengths )
    lengths = (@@bezier + @@bezier.reverse).piecelengths
    [lengths, [0.0,0.5,1.0]].forzip do |r,v|
      assert( r.fequal?(v) )
    end
  end

  def test_length_parameter_mapping
    pieceindex, t = (@@bezier + @@bezier.reverse).parametermapping(0.5, :length, :left)
    assert_equal( 1, pieceindex )
    assert( t.fequal?( 0.0 ) )
    assert_raise(RuntimeError) {@@multibezier.parametermapping(1.1, :length, :left)}
  end

  def test_filter
    assert( V2D.vequal?( V2D[0.5, 0.5], @@beziersym.filter(:point).sample( 0.5 ) ) )
  end

  def test_transform
    bezier = Bezier.raw( V2D[0.0, 0.0], V2D[1.0, 0.0], V2D[-1.0, 0.0], V2D[1.0, 0.0] )
    # assert_equal( [V2D[0.0, 0.0], V2D[-1.0, 0.0], V2D[1.0, 0.0], V2D[-1.0, 0.0]], bezier.rotate( Range.Angle.sample( 0.5 ) ).pointlist )
    assert_equal( V2D[0.0, 0.0], bezier.rotate( Range.Angle.sample( 0.5 ) ).firstpoint )
    # assert_equal( bezier.pointlist, bezier.rotate( Range.Angle.sample( 1.0 ) ).pointlist )
    assert_equal( bezier.firstpoint, bezier.rotate( Range.Angle.sample( 1.0 ) ).firstpoint )
    # assert_equal( [V2D[0.0, 0.0], V2D[-1.0, 0.0], V2D[1.0, 0.0], V2D[-1.0, 0.0]], bezier.sym( V2D::O ).pointlist )
    assert_equal( V2D[0.0, 0.0], bezier.sym( V2D::O ).firstpoint )
    # assert_equal( bezier.pointlist, bezier.sym( V2D::O ).sym( V2D::O ).pointlist  )
    assert_equal( bezier.firstpoint, bezier.sym( V2D::O ).sym( V2D::O ).firstpoint  )
    # assert_equal( [V2D[0.0, 0.0], V2D[-1.0, 0.0], V2D[1.0, 0.0], V2D[-1.0, 0.0]], bezier.axesym( V2D::O, V2D[0.0,1.0] ).pointlist )
    assert_equal( V2D[0.0, 0.0], bezier.axesym( V2D::O, V2D[0.0,1.0] ).firstpoint )
    # assert_equal( bezier.pointlist, bezier.axesym( V2D::O, V2D[1.0,0.0] ).pointlist )
    assert_equal( bezier.firstpoint, bezier.axesym( V2D::O, V2D[1.0,0.0] ).firstpoint )
  end

  def test_sides
    assert_equal( 1, Circle[].bezier.sides.length )
    c1 = Ondulation[ :support, LinearBezier[], :freq, 1, :ampl, 2.0 ]
    c2 = Ondulation[ :support, LinearBezier[], :freq, 1, :ampl, -2.0 ]
    c  = ClosureBezier[ :bezierlist, [c1, c2.reverse] ]
    assert_equal( 2, c.sides.length )

    # sub = c1.subbezier( 0.5, 0.6 )
    # assert_equal( 2, (sub + LinearBezier[ :support, [sub.lastpoint, sub.firstpoint] ]).sides.length )
  end

  def test_piecesideindices
    assert_equal( [0,4], Circle[].bezier.piecesideindices )
    assert_equal( [0,1], Bezier.line().piecesideindices )

    # c1 = Ondulation[ :support, LinearBezier[], :freq, 2, :ampl, 2.0 ]
    # c2 = Ondulation[ :support, LinearBezier[], :freq, 2, :ampl, -2.0 ]
    # c  = ClosureBezier[ :bezierlist, [c1, c2.reverse] ]
    points = [V2D[], V2D[0.0,1.0], V2D[0.5,0.5], V2D[]]
    beziers = points.pairs.map {|p1, p2| Bezier.line( p1, p2) }
    c = beziers.sum
    assert_equal( [0,1,2,3], c.piecesideindices )

    puts "alle retour"
    points = [V2D[], V2D[0.0,1.0], V2D[]]
    beziers = points.pairs.map {|p1, p2| Bezier.line( p1, p2) }
    c = beziers.sum
    assert_equal( [0,1,2], c.piecesideindices )

    puts "on on two"
    period = 1
    sub = 0
    bezier = Circle[].bezier
    beziers = []
    Range.O.samples( 4 ).pairs do |a1,a2|
      if (sub < period)
	beziers << bezier.subbezier( a1, a2 )
      else
	beziers << Bezier.line( bezier.point( a1 ), bezier.point( a2 ) )
      end
      sub += 1
      if (sub > period)
	sub = 0
      end
    end
    c = beziers.sum
    assert_equal( [-2,2,3], c.piecesideindices )
    assert_equal( 2, c.sides.length )
  end

end

  
      
  
