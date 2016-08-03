require 'test_helper'
require 'render'

class SVGRenderTest  < Minitest::Test

  def test_render
    if File.exist?( "svgrender.svg" ) 
      File.delete( "svgrender.svg" ) 
    end
    render = SVGRender.new( :filename, "svgrender.svg" )
    render.add( Circle[] )
    render.end
    assert( File.exist?( "svgrender.svg" ) )
  end

  def test_render2
    if File.exist?( "svgrender.svg" ) 
      File.delete( "svgrender.svg" ) 
    end
    SVGRender.[](:filename, "svgrender.svg") do |render|
      render.add( Circle[] )
      render.add( Circle[:center, V2D[1.0,1.0]] )
      render.add( Circle[:center, V2D[-1.0,-1.0]] )
      
    end
    assert( File.exist?( "svgrender.svg" ) )
  end

  def test_render3
    if File.exist?( "svgrender.svg" ) 
      File.delete( "svgrender.svg" ) 
    end
    SVGRender.[](:filename, "svgrender.svg") do |render|
      render.add( Circle[:radius, 0.0] )
    end
    assert( File.exist?( "svgrender.svg" ) )
  end

  def test_render4
    if File.exist?( "svgrender.svg" ) 
      File.delete( "svgrender.svg" ) 
    end
    circle   = Circle.new
    gradient = CircularGradient.new( :colorlist, [0.0, Color.black(1.0), 1.0, Color.black(0.0)], :circle, circle )
    render = SVGRender.new( :filename, "svgrender.svg" )
    render.add( Circle[], Style[ :fill, gradient, :stroke, gradient, :strokewidth, 0.01 ] )
    render.end
    assert( File.exist?( "svgrender.svg" ) )
  end

  def test_layer
    if File.exist?( "svgrender.svg" ) 
      File.delete( "svgrender.svg" ) 
    end
    render = SVGRender.new( :filename, "svgrender.svg" )
    render.layers = [:stars, :disk, :dustback, :halo, :dustforeground]
    render.add( Circle[], nil, :stars )
    render.end
    assert( File.exist?( "svgrender.svg" ) )
  end

end
