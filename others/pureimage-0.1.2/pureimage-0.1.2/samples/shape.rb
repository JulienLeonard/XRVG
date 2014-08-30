# ruby -I../lib hello.rb

require 'pureimage'

class EllipseShape < PureImage::Shape

  def initialize(x, y, width, height)
    a = width.to_f / 2.0
    @a2 = a * a
    b = height.to_f / 2.0
    @b2 = b * b
    @x0 = x.to_f + a
    @y0 = y.to_f + b
    @x_min = x
    @x_max = x + width
    @y_min = y
    @y_max = y + height
  end

  def x_min
    return @x_min
  end

  def x_max
    return @x_max
  end

  def y_min
    return @y_min
  end

  def y_max
    return @y_max
  end

  def xpoints(y)
    dy = y.to_f - @y0
    dx = Math.sqrt(@a2 * (1 - dy * dy / @b2))
    return [@x0 - dx, @x0 + dx]
  end

end

# ---- Create image ----

title_font = PureImage::Font.new('../fonts/sazanami-gothic-20.fnt')
image = PureImage::Image.new(256, 256, 0xffffff, true)

# ---- Draw color ellipse ----

image.draw_rect(0, 0, image.width - 1, image.height - 1, 0x000000)
ellipse1 = EllipseShape.new(48, 10, 160, 160)
ellipse2 = EllipseShape.new(10, 86, 160, 160)
ellipse3 = EllipseShape.new(86, 86, 160, 160)
image.alpha = 128
image.draw(ellipse1, 0xff0000)
image.draw(ellipse2, 0x00ff00)
image.draw(ellipse3, 0x0000ff)

# ---- Draw title ----
title = "shape.rb"
x = (image.width - title_font.string_width(title)) / 2
y = (image.height - title_font.height) / 2 + title_font.ascent
image.font = title_font
image.alpha = 255
image.draw_string(title, x, y, 0xffffff)

# ---- Create PNG file ----
png = PureImage::PNGIO.new
png.save(image, "shape.png")
