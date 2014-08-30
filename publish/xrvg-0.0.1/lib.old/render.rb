# 
# Render file. See
# - +Render+ for render "abstraction"
# - +SVGRender+ for effective SVG render 

require 'color'
require 'attributable'
require 'style'

# Render abstract class
#
# Is pretty useless for the moment
class Render
  include Attributable
  attr_accessor :width
  attr_accessor :height
end

# SVG Render class
#
# In charge of generating a svg output file from different object passed to it
# = Use
# Canonical use of the class
#  render = SVGRender[ :filename, "essai.svg" ]
#  render.add( Circle[] )
#  render.end
# = Improvements
# Allows also the "with" syntax
# = Attributes
#  attribute :filename, "", String
#  attribute :imagesize, "2cm", String
#  attribute :background, Color.white, [Color, String]
class SVGRender < Render
  attribute :filename, "", String
  attribute :imagesize, "2cm", String
  attribute :background, Color.white, [Color, String]
  attr_reader :viewbox

  # SVGRender builder
  #
  # Allows to pass a block, to avoid using .end
  #  SVGRender.[] do |render|
  #    render.add( Circle[] )
  #  end
  def SVGRender.[](*args,&block)
    result = self.new( *args )
    if block
      yield result
      result.end
    end
    return result
  end

  
  def initialize ( *args, &block ) #:nodoc:
    super( *args )
    @layers  = {}
    @defs    = ""
    @ngradients = 0
    if @filename.length == 0
      @filename = $0.split(".")[0..-2].join(".") + ".svg"
      Trace("filename is #{filename}")
    end
  end

  def layers=( backtofront ) #:nodoc:
    @sortlayers = backtofront
  end
  
  def add_content (string, layer) #:nodoc:
    if not @layers.key? layer
      @layers[ layer ] = ""
    end
    @layers[ layer ] += string
  end

  def svg_template #:nodoc:
    return '<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="%SIZE%" height="%SIZE%" %VIEWBOX% version="1.1"
     xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    %DEFS%
    %BACKGROUND%
    %CONTENT%
</svg>'
  end
  
  def add_def (object) #:nodoc:
    @defs += object
  end

  def add_gradient( gradient ) #:nodoc:
    id = "gradient#{@ngradients}"
    add_def( gradient.svgdef.subreplace( {"%ID%" => id} ) )
    @ngradients += 1
    return id
  end

  # render fundamental method
  # 
  # used to render an object, with a particular style, on an optional layer.
  #  render.add( Circle[], Style[ :fill, Color.black ], 1 )
  # If style is not provided, render asked to object its default_style, if any
  def add(object, style=nil, layer=0, type=:object)
    add_content( render( object, style ), layer)
    refresh_viewbox( object )
  end
  
  def adds (objects) #:nodoc:
    objects.each { |object| add( object )}
  end

  def render (object, style=nil) #:nodoc:
    owidth, oheight = object.size

    res     = 0.0000001
    if owidth < res and oheight < res
      return ""
    end

    if not style
      style = object.default_style
    end

    result  = "<g #{style.svgline}>\n"
    result += object.svg + "\n"
    result += "</g>\n"

    # puts "result #{result}"

    if style.fill.is_a? Gradient
      gradientID = add_gradient( style.fill )
      result = result.subreplace( {"%fillgradient%" => "url(##{gradientID})"} )
    end
    
    if style.stroke.is_a? Gradient
      gradientID = add_gradient( style.stroke )
      result = result.subreplace( {"%strokegradient%" => "url(##{gradientID})"} )
    end
    return result
  end

  def viewbox #:nodoc:
    return @viewbox
  end

  def size #:nodoc:
    xmin, ymin, xmax, ymax  = viewbox
    return [xmax - xmin, ymax - ymin]
  end

  def refresh_viewbox (object) #:nodoc:
    newviewbox = object.viewbox
    if newviewbox.length > 0
      if @viewbox == nil
	@viewbox = newviewbox
      else
	newxmin, newymin, newxmax, newymax = newviewbox
	xmin, ymin, xmax, ymax = viewbox
	
	if newxmin < xmin 
	  xmin = newxmin
	end
	if newymin < ymin 
	  ymin = newymin
	end
	if newxmax > xmax
	  xmax = newxmax
	end
	if newymax > ymax
	  ymax = newymax
	end

	@viewbox = [xmin, ymin, xmax, ymax]
      end
    end
  end
  
  def get_background_svg #:nodoc:
    xmin, ymin, width, height = get_carre_viewbox( get_final_viewbox() )
    template = '<rect x="%x%" y="%y%" width="%width%" height="%height%" fill="%fill%"/>' 
    bg = self.background
    if bg.is_a? Color
      bg = bg.svg
    end
    return template.subreplace( {"%x%"      => xmin,
				 "%y%"      => ymin,
				 "%width%"  => width,
				 "%height%" => height,
				 "%fill%"   => bg} )
  end

  def get_final_viewbox #:nodoc:
    marginfactor = 0.2
    xmin, ymin, xmax, ymax = viewbox()
    width, height          = size()
    
    xcenter = (xmin + xmax)/2.0
    ycenter = (ymin + ymax)/2.0
    
    width  *= 1.0 + marginfactor
    height *= 1.0 + marginfactor
    
    if width == 0.0
      width = 1.0
    end
    if height == 0.0
      height = 1.0
    end

    xmin = xcenter - width  / 2.0
    ymin = ycenter - height / 2.0
									
    return xmin, ymin, width, height
  end

  def get_viewbox_svg #:nodoc:
    return viewbox_svg( get_final_viewbox() )
  end

  def get_carre_viewbox( viewbox ) #:nodoc:
    xmin, ymin, width, height = viewbox
    xcenter = xmin + width  / 2.0
    ycenter = ymin + height / 2.0
    maxsize = width < height ? height : width
    return [xcenter - maxsize/2.0, ycenter - maxsize/2.0, maxsize, maxsize]
  end

  def viewbox_svg( viewbox ) #:nodoc:
    xmin, ymin, width, height = viewbox
    return "viewBox=\"#{xmin} #{ymin} #{width} #{height}\""
  end

  def content #:nodoc:
    keys = @sortlayers ? @sortlayers : @layers.keys.sort
    return keys.inject("") {|result,key| result += @layers[key]}
  end

  def svgdef #:nodoc:
    return "<defs>\n#{@defs}\n</defs>\n"
  end

  def end () #:nodoc:
    svgcontent    = content()
    svgviewbox    = get_viewbox_svg()
    svgbackground = get_background_svg()

    content = svg_template().subreplace( {"%VIEWBOX%"    => svgviewbox,
					  "%SIZE%"       => @imagesize,
					  "%DEFS%"       => svgdef,
					  "%BACKGROUND%" => svgbackground,
					  "%CONTENT%"    => svgcontent})
    
    File.open(filename(), "w") do |f|
      f << content
    end
   
    puts "render #{filename()} OK"; # necessary for Emacs to get output name !!!!
  end
  
  def raster () #:nodoc:
    # bg = background.format255

    # Kernel.system( "ruby", "svg2png.rb", filename(), "2.0" )
    # Kernel.system( "i_view32", filename().subreplace( ".svg" => ".png" ), "/fs" )
  end
   
end
