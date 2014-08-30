# ruby -I../lib filter2.rb

require 'pureimage'

class Sample2ImageFilter < PureImage::ImageFilter

  attr_accessor :affine

  def initialize(affine)
    @affine = affine
  end

  def effect(src_image, src_x, src_y, width, height, dst_image, dst_x, dst_y)
    src_x0 = src_x; src_x1 = src_x + width
    src_y0 = src_y; src_y1 = src_y + height
    dst_x0 = affine.xd(src_x0, src_y0)
    dst_x1 = dst_x0
    dst_y0 = affine.yd(src_x0, src_y0)
    dst_y1 = dst_y0
    x = affine.xd(src_x1, src_y0)
    y = affine.yd(src_x1, src_y0)
    dst_x0 = dst_x0 < x ? dst_x0 : x
    dst_x1 = dst_x1 > x ? dst_x1 : x
    dst_y0 = dst_y0 < y ? dst_y0 : y
    dst_y1 = dst_y1 > y ? dst_y1 : y
    x = affine.xd(src_x0, src_y1)
    y = affine.yd(src_x0, src_y1)
    dst_x0 = dst_x0 < x ? dst_x0 : x
    dst_x1 = dst_x1 > x ? dst_x1 : x
    dst_y0 = dst_y0 < y ? dst_y0 : y
    dst_y1 = dst_y1 > y ? dst_y1 : y
    x = affine.xd(src_x1, src_y1)
    y = affine.yd(src_x1, src_y1)
    dst_x0 = dst_x0 < x ? dst_x0.to_i : x.to_i
    dst_x1 = dst_x1 > x ? dst_x1.to_i : x.to_i
    dst_y0 = dst_y0 < y ? dst_y0.to_i : y.to_i
    dst_y1 = dst_y1 > y ? dst_y1.to_i : y.to_i
    for dy in dst_y0..dst_y1
      for dx in dst_x0..dst_x1
        sx = affine.x(dx, dy)
        sy = affine.y(dx, dy)
        if sx >= src_x0 && sx <= src_x1 && sy >= src_y0 && sy <= src_y1 then
          col = src_image.get(affine.x(dx, dy).to_i, affine.y(dx, dy).to_i)
          dst_image.set(dx + dst_x, dy + dst_y, col)
        end
      end
    end
  end

end

# ---- PNG utility ----

png = PureImage::PNGIO.new
src_image = png.load('../images/Lenna.png')
dst_image = PureImage::Image.new(src_image.width, src_image.height, 0xffffff)

# ---- Effect filter ----

rsqr2 = 1.0 / Math.sqrt(2.0)
affine = PureImage::Affine.new(rsqr2, rsqr2, -rsqr2, rsqr2, 64, -64)
filter = Sample2ImageFilter.new(affine)
filter.effect(src_image, 64, 64, 127, 127, dst_image, 0, 0)

# ---- Create PNG ----

png.save(dst_image, 'filter2.png')
