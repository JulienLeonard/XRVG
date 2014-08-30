# ruby -I../lib alpha.rb

require 'pureimage'

image = PureImage::Image.new(280, 170, 0xffffff, true)

font = PureImage::Font.new('../fonts/sazanami-mincho-20.fnt')

# ---- Draw frame ----

image.draw_rect(0, 0, 279, 169, 0x000000)

# ---- Draw title -----

title = "alpha.rb"
image.font = font
image.draw_string(title, 12, 22, 0x4080ff, 192)
image.draw_string(title, 10, 20, 0xff8040, 192)

image.draw_hline(10, 22, 260, 0x000000, 255)
image.draw_hline(10, 23, 260, 0x000000, 128)
image.draw_hline(10, 24, 260, 0x000000,  64)
image.draw_hline(10, 25, 260, 0x000000,  32)
image.draw_hline(10, 26, 260, 0x000000,  16)

# ---- Draw rectangles ----

image.draw_rect(20, 40, 100, 100, 0x808080)
image.draw_rect(30, 50, 100, 100, 0x000000, 64)
image.draw_rect(10, 60, 100, 100, 0x000000, 32)

image.draw_line(45, 75, 95, 125, 0xff0000, 64)
image.draw_line(45, 125, 95, 75, 0x0000ff, 64)

# ---- Fill rectangles ----

image.fill_rect(160, 40, 100, 100, 0xff0000, 64)
image.fill_rect(150, 50, 100, 100, 0x00ff00, 64)
image.fill_rect(170, 60, 100, 100, 0x0000ff, 64)

# ---- Create PNG -----

png = PureImage::PNGIO.new
png.save(image, 'alpha.png')
