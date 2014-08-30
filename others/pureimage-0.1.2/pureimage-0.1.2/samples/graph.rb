# ruby -I../lib graph.rb

require 'pureimage'

BLACK = 0x000000

DARK_GREEN = 0x008000
DARK_BLUE  = 0x000080

GRAY = 0x808080

RED   = 0xff0000

LIGHT_RED   = 0xff8080
LIGHT_GREEN = 0x80ff80
LIGHT_BLUE  = 0x8080ff

t1 = Time.new

title_font = PureImage::Font.new('../fonts/sazanami-gothic-20.fnt')
axis_font  = PureImage::Font.new('../fonts/sazanami-mincho-14.fnt')

t2 = Time.new

image = PureImage::Image.new(320, 240, 0xffffff)

t3 = Time.new

# ---- Draw frame ----

image.draw_rect(0, 0, image.width - 1, image.height - 1, BLACK)

# ---- Draw title ----

title = 'graph.rb'
x = (image.width - title_font.string_width(title)) / 2
y = 10 + title_font.ascent
image.font = title_font
image.draw_string(title, x + 2, y + 2, GRAY)
image.draw_string(title, x, y, DARK_BLUE)

# ---- Draw graph ----

y_length = 170;     x_length = 240
x0 = 40;            y0 = 210
x1 = x0 + x_length; y1 = y0 - y_length
cs = [LIGHT_RED, LIGHT_GREEN, LIGHT_BLUE]
hs = [120, 40, 80]
for i in 0..(hs.length - 1)
  image.fill_rect(x0 + 40 + i * 60, y0 - hs[i], 40, hs[i], cs[i])
end

# --- Y axis ----

image.font = axis_font
image.color = DARK_GREEN
image.draw_line(x0 , y1, x0, y0)
image.draw_line(x0 , y1, x0 - 4, y1 + 16)
image.draw_line(x0 , y1, x0 + 4, y1 + 16)
image.draw_line(x0 - 4, y0 -  40, x0 + 4, y0 -  40)
image.draw_line(x0 - 4, y0 -  80, x0 + 4, y0 -  80)
image.draw_line(x0 - 4, y0 - 120, x0 + 4, y0 - 120)
title = "y"
x = x0 - (axis_font.string_width(title) / 2)
y = y0 - y_length - 4 - axis_font.descent
image.draw_string(title, x, y, RED)

# --- X axis ----

image.draw_line(x0, y0, x1, y0)
image.draw_line(x1, y0, x1 - 16, y0 - 4)
image.draw_line(x1, y0, x1 - 16, y0 + 4)
image.draw_line(x0 +  60, y0 - 4, x0 +  60, y0 + 4)
image.draw_line(x0 + 120, y0 - 4, x0 + 120, y0 + 4)
image.draw_line(x0 + 180, y0 - 4, x0 + 180, y0 + 4)
title = "x"
x = x0 + x_length + 4
y = y0
image.draw_string(title, x, y, RED)

# --- Draw O point ---

title = 'O'
x = x0 - axis_font.string_width(title)
y = y0 + axis_font.ascent
image.draw_string("O", x, y, RED)

t4 = Time.new

png = PureImage::PNGIO.new
png.save(image, 'graph.png')

t5 = Time.new

print "Font create: ", (t2 - t1), "\n"
print "Image create: ", (t3 - t2), "\n"
print "Drawing: ", (t4 - t3), "\n"
print "PNG create: ", (t5 - t4), "\n"
print "Total: ", (t5 - t1), "\n"
