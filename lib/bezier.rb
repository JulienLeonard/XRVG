# +Bezier+ source
#

require 'interpolation'
require 'parametriclength'
require 'bezierspline'
require 'shape'

module XRVG
# = Base class for cubic bezier curves
# == Basics
# See http://en.wikipedia.org/wiki/B%C3%A9zier_curve
# == Examples
# Basically, a Bezier curve is a multi-pieces cubic bezier curve. As a first example, you can create bezier curves as follows :
#  b = Bezier[ :pieces, [[:raw, p1, pc1, pc2, p2]] ]; # raw description, as SVG
#  b = Bezier[ :pieces, [[:vector, p1, v1, p2, v2]] ]; # more "symetrical" description.
# For more extensive description, see http://xrvg.rubyforge.org/XRVGBezierCurve.html
# == Discussion
# In XRVG, bezier curves must be also viewed as a way to create smooth and non linear interpolation between values (see +Interpolation+)
#
# Other point : to run along a bezier curve, you can use two different parametrization :
# - the curve generic one, that is "curviligne" abscissa, that is length
# - the bezier parameter, as bezier curves are parametrized curves. For multi-pieces curve, by extension, parameter goes from one integer value to the next one 
# As Bezier class provides several methods with a parameter input, it is necessary to specify with parameter type you want to use ! For example,
# to compute a point from a bezier curve, Bezier class defines the point method as follows :
#   def point( t, parametertype=:length )
# This is a general declaration : every method with a parameter input will propose such a kind of interface :
# - t as Float parameter value
# - parametertype, by default :length, that can have two values, :length or :parameter. :parameter is kept because is far faster than other indexation.
# == Attributes
#  attribute :pieces
class Bezier < Curve
  attribute :pieces

# -------------------------------------------------------------
#  builders
# -------------------------------------------------------------

  # Initialize with the Attributable format
  # 
  # 
  # Licit formats :
  #   b = Bezier.new( :pieces, [BezierSpline[:raw, p1, pc1, pc2, p2]] )
  #   b = Bezier[ :pieces, [BezierSpline[:vector, p1, v1, p2, v2]] ]
  # However, prefer the use of the following builders
  #   b = Bezier.vector( p1, v1, p2, v2 )
  #   b = Bezier.raw( p1, pc1, pc2, p2 )
  #   b = Bezier.single( :raw, p1, pc1, pc2, p2 )
  #   b = Bezier.multi( [[:raw, p1, pc1, pc2, p2], [:raw, p1, pc1, pc2, p2]] )
  # The two last syntaxes are provided as shortcuts, as used quite frequently, and must be used instead of :pieces attributable builder
  def Bezier.[]( *args )
    self.new( *args )
  end

  # Uni Bezier builder 
  #
  # type can be :raw or :vector
  def Bezier.single( type, p1, p2, p3, p4 )
    return Bezier.new( :pieces, [BezierSpline[type, p1, p2, p3, p4]] )
  end

  # Uni Bezier builder in :raw format
  def Bezier.raw( p1, pc1, pc2, p2 )
    return Bezier.single( :raw, p1, pc1, pc2, p2 )
  end

  # Uni Bezier builder in :vector format
  def Bezier.vector( p1, v1, p2, v2 )
    return Bezier.single( :vector, p1, v1, p2, v2 )
  end

  # Uni Bezier builder in :vector format, with vector length normalized at 1/3 dist between points
  def Bezier.vectorreg( p1, v1, p2, v2 )
    d = (p1 - p2).r
    v1 = v1.norm * d/3.0
    v2 = v2.norm * d/3.0
    return Bezier.vector( p1, v1, p2, v2 )
  end

  # Uni Bezier builder to make a line
  def Bezier.line( p1 = V2D::O, p2 = V2D::X )
    v = (p2-p1)
    return Bezier.vectorreg( p1, v, p2, v * -1.0 )
  end

  # Basic Multi Bezier builder
  #
  # raw pieces must be an array of arrays of the form [type, p1, p2, p3, p4] as defined for single
  def Bezier.multi( rawpieces )
    return Bezier.new( :pieces, rawpieces.map {|piece| BezierSpline[*piece]} )
  end

  # "regular" Multi Bezier :raw specification
  #
  # args is a list of points and control points as [p1, pc1, p2, pc2, p3, pc3]
  #
  # Beware that 
  #  Bezier.raw( p1, pc1, pc2, p2 ) == Bezier.raws( p1, pc1, p2, p2 + (p2-pc2))
  def Bezier.raws( *args )
    rawpieces = []
    args.foreach(2).pairs do |pair1, pair2|
      p1, pc1 = pair1 
      p2, pc2 = pair2
      rawpieces << [:raw, p1, pc1, p2+(p2-pc2), p2]
    end
    return Bezier.multi( rawpieces )
  end

  # "regular" Multi Bezier :vector specification
  #
  # args is a list of points and control points as [p1, v1, p2, v2, p3, v3]
  #
  # Beware that 
  #  Bezier.vector( p1, v1, p2, v2 ) == Bezier.vectors( p1, v1, p2, -v2)
  def Bezier.vectors( *args )
    rawpieces = []
    args.foreach(2).pairs do |pair1, pair2|
      p1, v1 = pair1 
      p2, v2 = pair2
      rawpieces << [:vector, p1, v1, p2, -v2]
    end
    return Bezier.multi( rawpieces )
  end
  

  

  # bezier point, as 
  #   Bezier[:raw, V2D::O, V2D::O, V2D::O, V2D::O]
  O = Bezier.raw( V2D::O, V2D::O, V2D::O, V2D::O )


  # return piece of index "index",as BezierSpline object
  #
  # index can be 
  # - integer : in that case, simple return @pieces[index]
  # - float   : in that case, use second default argument
  # this method must actually be very rarely called, as usually
  # we want to compute something with index, and in that case we 
  # want to delegate computation to a BezierSpline, with parameter
  # mapping parametermapping
  def piece( index, parametertype=:length )
    # puts "piece enter index #{index} parametertype #{parametertype}"
    pieceindex = index
    if index.is_a? Float
      pieceindex, _t = self.parametermapping( index, parametertype )
    end
    return @pieces[ pieceindex ]
  end

  # return number of pieces
  def piecenumber
    return @pieces.length
  end

# -------------------------------------------------------------
#  curve interface
# -------------------------------------------------------------

  # overload Curve::viewbox
  def viewbox
    return V2D.viewbox( self.pointlist() )
  end


# -------------------------------------------------------------
#  piece shortcuts
# -------------------------------------------------------------

  # generic method to return points list of a curve
  #   b = Bezier[ :pieces, [[:raw, p1, pc1, pc2, p2], [:raw, p2, pc2b, pc3, p3]] ]
  #   b.pointlist        #=> equiv to b.pointlist(:raw) 
  #   b.pointlist(:raw)  #=> [p1, pc1, pc2, p2, p2, pc2b, pc3, p3]
  # if you want to get a particular piece pointlist, do
  #   b.piece( t ).pointlist(nil|:raw|:vector)
  # TODO : result must be cached by type
  def pointlist( type=:raw )
    result = []
    @pieces.each {|piece| result = result + piece.pointlist(type)}
    # Trace("Bezier.pointlist result #{result.inspect}")
    return result
  end
    
  # shortcut method to get curve first point
  def firstpoint
    return self.pointlist()[0]
  end

  # shortcut method to get curve last point
  def lastpoint
    return self.pointlist()[-1]
  end

  # shortcut method to build Bezier objects from each piece
  def beziers
    return self.pieces.map{ |piece| Bezier.single( *piece.data ) }
  end

  # shortcut method to build Bezier objects from each not regular part
  def sides
    result = []

    piecesideindices().pairs do |i1, i2|
      if i1 < 0
	result << Bezier[ :pieces, pieces[i1..-1] + pieces[0..i2-1] ]
      else
	result << Bezier[ :pieces, pieces[i1..i2-1] ]
      end
    end
    
    return result
  end

  # shortcut method to retrieve a piece as an Bezier object
  def bezier( index )
    return Bezier.single( *self.piece( index ).data )
  end

  # shortcut method to retrieve data list of a bezier
  def data
    return self.pieces.map{ |piece| piece.data }
  end
  

# -------------------------------------------------------------
#  piece delegation computation
# -------------------------------------------------------------

  # with index (must be Float) and parametertype as inputs, must compute :
  # - the index of the piece on which the computation must take place
  # - the new parameter value corresponding to bezier computation input
  def parametermapping( index, parametertype=:length, side=:right ) #:nodoc:
    # puts "parametermapping enter index #{index} parametertype #{parametertype} side #{side}"
    check_parametertype( parametertype )
    result = []
    if parametertype == :length
      if index < 0.0 or index > 1.0
	Kernel::raise("parametermapping index #{index} not length ratio")
      end
      index = (0.0..1.0).trim( index )
      index = parameterfromlength( index )
    end
    
    index = (0.0..self.piecenumber.to_f).trim( index )
    pieceindex = -1
    # puts "parametermapping index #{index}"
    if index.to_i == index and (index.to_i == self.piecenumber or side == :right) and index.to_i != 0
      pieceindex = index.to_i - 1
      t          = 1.0
    else
      pieceindex = index.to_i
      t          = index - pieceindex
    end
    result = [pieceindex, t]
    # puts "parametermapping index #{index} result #{result.inspect}"
    return result
  end

  # utilitary method to factorize abscissa parameter type value checking
  def check_parametertype( parametertype ) #:nodoc:
    if !(parametertype == :parameter or parametertype == :length )
      Kernel::raise("Invalid parametertype value #{parametertype}")
    end
  end

# -------------------------------------------------------------
#  bezier computations
# -------------------------------------------------------------

  # compute a point at curviligne abscissa or parameter t 
  #
  # curve method redefinition
  def point( t, container=nil, parametertype=:length )
    pieceindex, t = parametermapping( t, parametertype )
    # puts "Bezier point pieceindex #{pieceindex} t #{t} piecenumber #{piecenumber}"
    return self.piece( pieceindex ).point( t, container )
  end
  
  # compute tangent at curviligne abscissa or parameter t 
  #
  # curve method redefinition
  def tangent ( t, container=nil, parametertype=:length )
    pieceindex, t = parametermapping( t, parametertype )
    return self.piece( pieceindex ).tangent( t, container )
  end

  # compute acceleration at curviligne abscissa or parameter t 
  #
  # curve method redefinition
  def acc( t, container=nil, parametertype=:length )
    pieceindex, t = parametermapping( t, parametertype )
    return self.piece( pieceindex ).acc( t, container )
  end

  # curve method redefinition to factorize parametermapping
  def frame( t, container=nil, parametertype=:length )
    pieceindex, t = parametermapping( t, parametertype )
    containerpoint   = container ? container.center : nil
    containertangent = container ? container.vector : nil
    point    = self.piece( pieceindex ).point( t, containerpoint )
    tangent  = self.piece( pieceindex ).tangent( t, containertangent )
    rotation = self.rotation( nil, tangent )
    scale    = self.scale( nil, tangent )
    result = container ? container : Frame[ :center, point, :vector, tangent, :rotation, rotation, :scale, scale ]
    return result
  end

# -------------------------------------------------------------
#  subpiece computation
# -------------------------------------------------------------

  # generalize Bezier method
  def subpieces (t1, t2) #:nodoc:
    # Trace("subpieces t1 #{t1} t2 #{t2}")
    pieceindex1, t1 = parametermapping( t1, :length, :left )
    pieceindex2, t2 = parametermapping( t2, :length, :right )
    # Trace("after translation pieceindex1 #{pieceindex1} t1 #{t1}  pieceindex2 #{pieceindex2} t2 #{t2}")
    result = []

    if pieceindex1 == pieceindex2
      result = [self.piece( pieceindex1 ).subpiece( t1, t2 )]
    else
      result << self.piece( pieceindex1 ).subpiece( t1, 1.0 )
      if pieceindex1 + 1 != pieceindex2
	result += self.pieces[pieceindex1+1..pieceindex2-1]
      end
      result << self.piece( pieceindex2 ).subpiece( 0.0, t2 )
    end
    return result
  end

  # compute the sub curve between abscissa t1 and t2
  #
  # may result in a multi-pieces Bezier
  #
  # Note: special modulo effect to deal with closed bezier curve
  #
  # TODO: improve code (bas design)
  def subbezier( t1, t2)
    # return Bezier.new( :pieces, self.subpieces( t1, t2 ) )
    ranges = (0.0..1.0).modulos( (t1..t2) )
    # Trace("Bezier::subbezier t1 #{t1} t2 #{t2} ranges #{ranges.inspect}")
    pieces = []
    ranges.each do |range|
      range = range.sort
      pieces += self.subpieces( range.begin, range.end )
    end

    bezier = Bezier.new( :pieces, pieces )
    if t1 > t2
      bezier = bezier.reverse
    end
    return bezier
  end

# -------------------------------------------------------------
#  reverse
# -------------------------------------------------------------

  # return a new Bezier curve reversed from current one
  #
  # simply reverse BezierSpline pieces, both internally and in the :pieces list
  def reverse
    newpieces = @pieces.map {|piece| piece.reverse()}
    return Bezier.new( :pieces, newpieces.reverse )
  end

# -------------------------------------------------------------
#  translation
# -------------------------------------------------------------

  # translate the Bezier curve, by translating its points
  def translate( v )
    return Bezier.new( :pieces, @pieces.map { |piece| piece.translate( v ) } )
  end

  # rotate the Bezier curve, by rotating its points
  def rotate( angle, center=V2D::O )
    return Bezier.new( :pieces, @pieces.map { |piece| piece.rotate( angle, center ) } )
  end
  
  # central symetry
  def sym( center )
    return Bezier.new( :pieces, @pieces.map { |piece| piece.sym( center ) } )
  end

  # axis symetry
  def axesym( point, v )
    return Bezier.new( :pieces, @pieces.map { |piece| piece.axesym( point, v ) } )
  end

# -------------------------------------------------------------
#  similar (transform is used for samplation)
#    see XRVG#33
# -------------------------------------------------------------

  # "Similitude" geometric transformation
  #
  # See http://en.wikipedia.org/wiki/Similitude_%28geometry%29
  #
  # Similtude geometric transformation is (firspoint..lastpoint) -> pointrange
  #
  # TODO : method must be put in Curve interface
  def similar( pointrange )
    oldRepere = [self.firstpoint,  self.lastpoint - self.firstpoint]
    newRepere = [pointrange.begin, pointrange.end - pointrange.begin]
    rotation    = V2D.angle( newRepere[1], oldRepere[1] )
    if oldRepere[1].r == 0.0
      Kernel::raise("similar error : bezier is length 0")
    end
    scale       = newRepere[1].r / oldRepere[1].r
    newpoints = []
    self.pointlist.each do |oldpoint|
      oldvector = oldpoint - oldRepere[0]
      newvector = oldvector.rotate( rotation ) * scale
      newpoints.push( newRepere[0] + newvector )
    end
    splines = []
    newpoints.foreach do |p1, p2, p3, p4|
      splines.push( BezierSpline[:raw, p1, p2, p3, p4] )
    end
    return Bezier[ :pieces, splines ]
  end    

# -------------------------------------------------------------
#  concatenation
# -------------------------------------------------------------

  # Bezier curve concatenation
  def +( other )
    return Bezier.new( :pieces, self.pieces + other.pieces )
  end

# -------------------------------------------------------------
#  svg
# -------------------------------------------------------------
  
  # return the svg description of the curve
  #
  # if firstpoint == lastpoint, curve is considered as closed
  def svg()
    # Trace("Bezier::svg #{self.inspect}")
    path     = ""
    previous = nil
    self.pieces().each do |piece|
      p1, pc1, pc2, p2 = piece.pointlist
      # Trace("previous #{previous.inspect} p1 #{p1.inspect}")
      if previous.nil? or not (previous - p1).r <= 0.0000001
	# Trace("svg bezier not equal => M")
	path += "M #{p1.x},#{p1.y}"
      end
      previous = p2
      path += "C #{pc1.x},#{pc1.y} #{pc2.x},#{pc2.y} #{p2.x},#{p2.y}"
    end

    if self.firstpoint == self.lastpoint
      path += " z"
    end

    result = "<path d=\"#{path}\"/>"
    return result
  end

# -------------------------------------------------------------
#  gdebug
# -------------------------------------------------------------

  # Display Bezier curve decorated with points and control points 
  def gdebug(render)
    self.pieces.each {|piece| piece.gdebug(render)}
  end


# -------------------------------------------------------------
#  length computation
# -------------------------------------------------------------

  # return the length of the bezier curve
  #
  # simply add pieces lengths
  def length
    if not defined? @length
      compute_length
    end
    return @length
  end
  
  # compute length with length interpolator using bezier linear approximation
  def compute_length #:nodoc:
    compute_length_interpolator
  end
  
  # utilitary method for interbezier
  #
  # return list of piece lengths relatives to total bezier lengths, and cumulated
  #  Bezier.new( :pieces, [piece1, piece2] ).piecelengths; => [0.0, piece1.length / bezier.length, 1.0]
  def piecelengths
    if not defined? @piecelengths
      sum = 0.0
      @piecelengths = [0.0]
      pieces.each_with_index do |piece,i|
	sum += lengthfromparameter((i+1).to_f)
	@piecelengths << sum
      end
       if @piecelengths[-1] != 1.0
	 @piecelengths[-1] = 1.0
       end
    end
    return @piecelengths
  end

  
    # return a list of bezier params [a1,a2, b1, b2 ...] stating intersection points for each curve
    # Algo:
    #  - compute segment approximations of 2 curves, by keeping parameter values
    #  - for the moment, brute algorithm: try to match every segment of one curve with every of the other
    # - for every match, dychotomie to get precise parameter value
    def Bezier.intersections( c1, c2 )
      samples = Range.O.samples( 100 )
      
      # sample curves
      vs = []
      [c1,c2].each do |c|
	subvs = []
	samples.each do |t|
	  subvs << [t, c.point( t )]
	end
	vs << subvs
      end

      # detect segment intersections and keep corresponding coords
      rawresult = []
      vs[0].pairs do |s01, s02|
	vs[1].pairs do |s11, s12|
	  inter = V2DS[s01[1], s02[1]].intersection( V2DS[s11[1], s12[1]] )
	  if inter
	    # compute distances rapport
	    r0 = (inter - s01[1]).r / (s02[1] - s01[1]).r
	    r1 = (inter - s11[1]).r / (s12[1] - s11[1]).r
	    # Trace("Bezier.intersections rapports r0 #{r0} r1 #{r1} s0 V2DS #{V2DS[s01[1], s02[1]].inspect} s1 V2DS #{V2DS[s11[1], s12[1]].inspect}")
	    rawresult += [s01[0], s02[0], r0, s11[0], s12[0], r1]
	  end
	end
      end
      
      # Trace("Bezier.intersections rawresult #{rawresult.inspect}")

      # compute accurately coords
      # for the moment, just return mean
      result = []
      rawresult.foreach do |t1, t2, r12, t3, t4, r34|
	result += [(t1..t2).sample( r12 ), (t3..t4).sample( r34 )]
      end

      # Trace("Bezier.intersections result #{result.inspect}")
      
      return result
    end

    # return parameters corresponding to sides
    # must be so a list of "int" parameters (as uncontinuity in pieces tangent 
    # can only be between pieces)
    def piecesideindices()
      @piecesideindices ||=
        begin
          result = []
          p0, v0, p1, v1 = piece(0).pointlist(:vector)
          # puts "piecenumber #{piecenumber}"
          lastp = p1
          pieces[1..-1].each_with_index do |cpiece,index|
            _d0, fv, d1, fv1 = cpiece.pointlist(:vector)
            # puts "fv #{fv.inspect} v1 #{v1.inspect}"
            # puts "(fv * -1.0).norm #{(fv * -1.0).norm.inspect} v1.norm #{v1.norm.inspect}"
            if not (V2D.vequal?( (fv * -1.0).norm, v1.norm, 0.01) or fv.r.fequal?( 0.0) || v1.r.fequal?( 0.0))
              # puts "new side #{result[-1]} #{index}"
              if result.length == 0
                result << 0
              end
              result << index + 1
            end
            v1 = fv1
            lastp = d1
          end

          # puts "v0 #{v0.inspect} v1 #{v1.inspect}"
          if (V2D.vequal?( p0, lastp ))
            if (V2D.vequal?( (v0 * -1.0).norm, v1.norm, 0.01) or v0.r.fequal?( 0.0) || v1.r.fequal?( 0.0))
              if (v0.r.fequal?(0.0) or v1.r.fequal?( 0.0))
                puts "WARNING: parametersides: tangent null"
              end

              if (result.length > 0)
                result[0] = result[-1] - piecenumber
              else
                result = [0,piecenumber]
              end
            else 
              result << piecenumber
            end
          else
            if (result.length == 0)
              result << 0
            end
            result << piecenumber
          end
          # puts "piecesideindices result #{result.inspect}"
          result
        end
    end

    # used to compute parameter ranges for sides
    # Note: for the moment, divide first side if continuous with last and close curve
    def sideparameterranges
      result = []
      indices = piecesideindices
      indices.pairs do |i1, i2|
	if i1 < 0
	  indices << piecenumber
	  i1 = 0
	end
	result << (i1.to_f..i2.to_f)
      end
      # puts "sideparameterranges result #{result.inspect}"
      return result
    end


    # curve method utilitaries to compute frame side extremities
    def extsideframes( t1, t2, f1, f2 )
      # puts "extsideframes enter"
      @extsideframes_cache ||= {}
      [t1, f1, :left, t2, f2, :right].foreach do |t, f, side|
	if @extsideframes_cache["#{t}side"]
	  f.center.x, f.center.y, f.vector.x, f.vector.y = @extsideframes_cache["#{t}side"]
	  # f.center.y = @extsideframes_cache["#{t}side"][1]
	  # f.vector.x = @extsideframes_cache["#{t}side"][2]
	  # f.vector.y = @extsideframes_cache["#{t}side"][3]
	else
	  # pieceindex, t = parametermapping( t, :parameter, side )
	  # puts "extsideframes pieceindex #{pieceindex} t #{t}"
	  # point    = self.piece( pieceindex ).point( t, f.center )
	  # tangent  = self.piece( pieceindex ).tangent( t, f.vector )
	  # rotation = nil; #self.rotation( nil, tangent )
	  # scale    = nil; #self.scale( nil, tangent )
	  #@extsideframes_cache["#{t}side"] = [f.center.x, f.center.y, f.vector.x, f.vector.y]
	end
      end
    end

    # bezier into line segments approximation computation
    # must be computed only once and be cached
    # return parameter list to be used in parametric_length
    # TODO: index by error
if nil
  def segmentparameters( error = 0.2 )
    return (0.0..piecenumber.to_f).samples( 129 )
  end
end

if true
  def segmentparametersrec( abs1, abs2, cresult, error, f1, f2 )
    extsideframes( abs1, abs2, f1, f2 )
    # puts "segmentparametersrec front abs1 #{abs1} abs2 #{abs2} f1 #{f1.inspect} f2 #{f2.inspect}"
    
    if nil
    deviation1 = V2D.angle( f1.vector, (f2.center - f1.center))
    if deviation1 > Math::PI
      deviation1 -= (2.0 * Math::PI)
    elsif deviation1 < -Math::PI
      deviation1 += (2.0 * Math::PI)
    end
    
    deviation2 = V2D.angle( f2.vector, (f2.center - f1.center))
    if deviation2 > Math::PI
      deviation2 -= (2.0 * Math::PI)
    elsif deviation2 < -Math::PI
      deviation2 += (2.0 * Math::PI)
    end
    end
    
    deviation1 = V2D.crossproduct( f1.vector, (f2.center - f1.center))
    deviation2 = V2D.crossproduct( f2.vector, (f2.center - f1.center))
 
    # puts "segmentparametersrec deviation1 #{deviation1} deviation2 #{deviation2}"
    if (deviation1.abs + deviation2.abs > error and ( abs1 - abs2).abs > 0.01)
      mean = (abs1 + abs2)/2.0
      cresult = segmentparametersrec(abs1, mean, cresult, error, f1, f2 )
      cresult = segmentparametersrec(mean, abs2, cresult, error, f1, f2 )
    else
      cresult << abs2
    end    
    return cresult
  end

  def segmentparameters( error = 0.01 )
    # puts "segmentparameters enter #{self}"
    @segmentparameters ||=
      begin
        sideranges = self.sideparameterranges
        rootvalues = []
        sideranges.each do |range|
          sublist = range.samples( 5 )
          rootvalues += sublist
        end

        result = [0.0]
        f1 = Frame[:center, V2D[], :vector, V2D[], :rotation, nil, :scale, nil]
        f2 = Frame[:center, V2D[], :vector, V2D[], :rotation, nil, :scale, nil]
        rootvalues.pairs do |r1, r2|
          result = segmentparametersrec( r1, r2, result, error, f1, f2 )
        end
        result
        # puts "segmentparameters #{segmentparameters.length} #{segmentparameters.inspect}"
      end
  end
end

# -------------------------------------------------------------
#  sampler computation
# -------------------------------------------------------------
  include Samplable
  include Splittable

  # filter, sampler methods
  #
  # just a shortcut to define easily specific sampler on bezier curve
  #
  # TODO : must be defined on Curve interface !!
  def filter(type=:point, &block)
      return super(type, &block).addfilter( (0.0..1.0) )
  end

  def apply_split( t1, t2 ) #:nodoc:
    return self.subbezier( t1, t2 )
  end

  alias apply_sample point
  # alias apply_split  subbezier
  alias sampler      filter

  # TODO : add generic bezier builder from points : must be adaptative !! (use Fitting)

  # length computation
  include ParametricLength
  def parameter_range
    return (0.0..piecenumber.to_f)
  end

  def pointfromparameter( t, container=nil )
    return point( t, container, :parameter )
  end

  # overload ParametricLength method, to use linear segmentation
  def compute_length_interpolator()
    # puts "compute_length_interpolator bezier enter"
    sum = 0.0
    sums = [0.0]
    p = firstpoint()
    segmentparameters[1..-1].each do |t|
      newpoint = pointfromparameter( t )
      sum += (newpoint - p).r()
      # puts "compute_length_interpolator t #{t} p #{p.inspect} newpoint #{newpoint.inspect} sum #{sum}"
      sums << sum
      p = newpoint
    end
    load_length_interpolator( segmentparameters, sums )
  end

end
end


