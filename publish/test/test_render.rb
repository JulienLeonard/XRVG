require 'test/unit'
require 'render'

class SVGRenderTest  < Test::Unit::TestCase

  

  def test_raster
    if nil
    require 'shape'
    render = SVGRender.new( :filename, "output/svgrender.svg" )
    render.add( Circle[] )
    render.end
    assert( File.exist?( "svgrender.jpg" ) )
    end
  end

end
