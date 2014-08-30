require 'test/unit'
require 'render'

class SVGRenderTest  < Test::Unit::TestCase

  def test_raster
    require 'shape'
    render = SVGRender.new( :filename, "output/svgrender.svg" )
    render.add( Circle.new( :style, Style.new( :stroke, "none" ) ) )
    render.end
    assert( File.exist?( "svgrender.jpg" ) )
  end
  
end
