require 'bezier'

module XRVG
class InterBezier
  include Attributable
  attribute :bezierlist

  include Interpolation

  def initialize( *args )
    super( *args )
    self.init_interpolation_structures
  end

  def init_interpolation_structures
    beziers = []
    indexes = []
    @bezierlist.foreach do |index, bezier| 
      beziers.push( bezier )
      indexes.push( index )
    end

    # TODO: lengthH is useless 
    lengthH = {}
    alllengths = []
    beziers.each do |bezier|
      lengths = bezier.piecelengths
      # Trace("bezier lengths #{lengths.inspect}")
      lengthH[ bezier ] = lengths
      alllengths += lengths
    end
    alllengths = Float.sort_float_list( alllengths )
    # Trace("alllengths #{alllengths.inspect}")
    
    newbezierlist = []
    beziers.each do |bezier|
      newpieces = []
      initlengths = lengthH[ bezier ]
      alllengths.pairs do |l1, l2| 
	newpieces += bezier.subbezier( l1, l2 ).pieces
      end
      newbezier = Bezier[ :pieces, newpieces ]
      newbezierlist << newbezier
    end

    # Trace("newbezierlist #{newbezierlist.length}")
    beziers = newbezierlist
    bezierpointlists = beziers.map {|bezier| bezier.pointlist(:vector) }
    # Trace("bezierpointlists #{bezierpointlists.map {|list| list.length}.inspect}")
    pointsequencelist = bezierpointlists.forzip
    @interpolatorlist = []
    pointsequencelist.foreach(beziers.size) do |pointsequence|
      interlist = [indexes, pointsequence].forzip
      @interpolatorlist.push( Interpolator.new( :samplelist, interlist ) )
    end
  end

  def interpolate( abs, container=nil )
    pieces = []
    @interpolatorlist.foreach(4) do |interpiece|
      piece = interpiece.map {|inter| inter.interpolate( abs )}
      pieces.push( [:vector] + piece )
    end
    return Bezier.multi( pieces )    
  end

  include Samplable
  alias apply_sample interpolate

end

class GradientBezier < InterBezier

  # TODO : does not work !!
  def samples( nsamples, &block )
    return super( nsamples + 1, &block )
  end

  def apply_samples( samples )
    samples = super( samples )
    result = []
    samples.pairs do |bezier1, bezier2|
      result.push( ClosureBezier.build( :bezierlist, [bezier1, bezier2.reverse]) )
    end
    return result
  end
end
end # XRVG  
