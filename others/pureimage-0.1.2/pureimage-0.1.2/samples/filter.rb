# ruby -I../lib filter.rb

require 'pureimage'

class Sample1ImageFilter < PureImage::ImageFilter

  attr_accessor :bright

  def initialize(bright)
    @bright = bright
  end

  def effect(src_image, src_x, src_y, width, height, dst_image, dst_x, dst_y)
    src_x0 = src_x;         src_y0 = src_y
    src_x1 = src_x + width; src_y1 = src_y + height
    dy = dst_y
    for sy in src_y0..src_y1
      dx = dst_x
      for sx in src_x0..src_x1
        col = src_image.get(sx, sy)
        r = ((col[0] + @bright) / 2).to_i
        g = ((col[1] + @bright) / 2).to_i
        b = ((col[2] + @bright) / 2).to_i
        dst_image.set(dx, dy, [r, g, b, col[3]])
        dx += 1
      end
      dy += 1
    end
  end

end

# ---- PNG utility ----

png = PureImage::PNGIO.new
font_head = PureImage::Font.new('../fonts/sazanami-mincho-16.fnt')
font_title = PureImage::Font.new('../fonts/sazanami-gothic-24.fnt')

# ---- Create image ----

src_image = png.load('../images/Parrots.png')
dst_image = PureImage::Image.new(src_image.width, src_image.height, 0xffffff)

# ---- Effect filter ----

filter = Sample1ImageFilter.new(0)
filter.effect(src_image,   0,   0, 127, 127, dst_image,   0,   0)
filter.bright = 64
filter.effect(src_image, 128,   0, 127, 127, dst_image, 128,   0)
filter.bright = 128
filter.effect(src_image,   0, 128, 127, 127, dst_image,   0, 128)
filter.bright = 255
filter.effect(src_image, 128, 128, 127, 127, dst_image, 128, 128)

# ---- Draw frame ----

dst_image.color = 0x000000
dst_image.draw_rect(0, 0, dst_image.width - 1, dst_image.height - 1)

# ---- Draw title ----

title = "filter.rb"
x = 255 - 8 - font_title.string_width(title)
y = 255 - 8
dst_image.font = font_title
dst_image.alpha = 128
dst_image.color = 0x000000
dst_image.draw_string(title, x, y)
dst_image.color = 0xff0000
dst_image.draw_string(title, x - 2, y - 2)

# ---- Draw head ----

x = 10
y = 10 + font_head.ascent
dst_image.font = font_head
dst_image.color = 0x000000
dst_image.alpha = 255
dst_image.draw_string("0",   x,       y)
dst_image.draw_string("64",  x + 128, y)
dst_image.draw_string("128", x,       y + 128)
dst_image.draw_string("255", x + 128, y + 128)
x -= 2
y -= 2
dst_image.color = 0xffffff
dst_image.draw_string("0",   x,       y)
dst_image.draw_string("64",  x + 128, y)
dst_image.draw_string("128", x,       y + 128)
dst_image.draw_string("255", x + 128, y + 128)

# ---- Create PNG ----

png.save(dst_image, 'filter.png')
