# ruby -I../lib hello.rb

require 'pureimage'

$KCODE = 'Shift_JIS'

# ---- define constants ----

DARK_GRAY   = 0x404040
DARK_GREEN  = 0x008000

LIGHT_RED   = 0xff8080
LIGHT_GREEN = 0x80ff80
LIGHT_BLUE  = 0x8080ff

WHITE       = 0xffffff
RED         = 0xff0000
GREEN       = 0x00ff00
BLUE        = 0x0000ff

# ---- define style methods ----

def star(image)
  div = 5
  l = image.height / 2 - 5
  dr = 2 * Math::PI / div * 2
  r = Math::PI / 2
  x0 = image.height / 2
  y0 = image.height / 2
  xs = Array.new
  ys = Array.new
  for i in 1..div
    xs.push(x0 + (l * Math.cos(r)).to_i)
    ys.push(y0 - (l * Math.sin(r)).to_i)
    r += dr
  end
  return xs, ys
end

def batten(image)
  gap = 8
  x1 = image.width - gap - 1
  y1 = image.height - gap - 1
  x0 = x1 - (image.height - 2 * gap - 1)
  y0 = gap
  return x0, y0, x1, y1
end

def hello(image, font, title)
  x = (image.width - font.string_width(title)) / 2
  y = (image.height - font.height) / 2 + font.ascent
  return title, x, y
end

# ---- Create objects ----

image = PureImage::Image.new(240, 60, WHITE)
font  = PureImage::Font.new('../fonts/mikachan-pb-24.fnt')

# ---- Draw frame ----

image.draw_rect(0, 0, image.width - 1, image.height - 1, DARK_GREEN)
image.fill_rect(2, 2, image.width - 5, image.height - 5, LIGHT_BLUE)

# ---- Draw star ----

xs, ys = star(image)
image.fill_polygon(xs, ys, RED)

# ---- Draw batten ----

x0, y0, x1, y1 = batten(image)
image.draw_line(x0, y0, x1, y1, GREEN)
image.draw_line(x0, y1, x1, y0, GREEN)

# ---- Draw string ----

title, x, y = hello(image, font, 'Ç±ÇÒÇ…ÇøÇÕê¢äE!')
image.font = font
image.draw_string(title, x + 2, y + 2, DARK_GRAY)
image.draw_string(title, x, y, WHITE)

# ---- Create PNG ----

png = PureImage::PNGIO.new
png.save(image, "hello.png")
#png.save(image, File.new("hello.png", "w"))
