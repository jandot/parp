class MySketch < Processing::App
  # cx is the x coordinate for a point on a circle
  def cx(alpha, r, origin_x = 0)
    return r*cos(MySketch.radians(alpha)) + origin_x
  end
  def cy(alpha, r, origin_y = 0)
    return r*sin(MySketch.radians(alpha)) + origin_y
  end

  def pline(alpha1, alpha2, r, origin_x = 0, origin_y = 0, args = {})
    if args[:fill].nil? or args[:fill] == false
      no_fill
    else
      fill args[:fill]
    end
    if args[:buffer].nil?
      return arc origin_x, origin_y, r, r, MySketch.radians(alpha1), MySketch.radians(alpha2)
    else
      return args[:buffer].arc origin_x, origin_y, r, r, MySketch.radians(alpha1), MySketch.radians(alpha2)
    end
  end

  def pixel2xy(pixel, r = @radius, origin_x = @origin_x, origin_y = @origin_y)
    degree = map(pixel, 0, @circumference, 0, 360)
    x = cx(degree, r, origin_x)
    y = cy(degree, r, origin_y)
    return [x,y]
  end

  def xy2pixel(x, y, origin_x = @origin_x, origin_y = @origin_y)
    return angle(x, y, origin_x, origin_y).to_f.degree_to_pixel.floor
  end

  def angle(x = mouse_x, y = mouse_y, origin_x = 0, origin_y = 0)
    alpha = 0
    if ( x <= origin_x ) and ( y > origin_y )# II
      theta = atan((origin_x - x).to_f/(y - origin_y).to_f)
      alpha = 90 + MySketch.degrees(theta)
    elsif ( x < origin_x ) and ( y <= origin_y ) # III
      theta = atan((origin_y - y).to_f/(origin_x - x).to_f)
      alpha = 180 + MySketch.degrees(theta)
    elsif ( x >= origin_x ) and ( y < origin_y) # IV
      theta = atan((x - origin_x).to_f/(origin_y - y).to_f)
      alpha = 270 + MySketch.degrees(theta)
    else # I
      theta = atan((y - origin_y).to_f/(x - origin_x).to_f)
      alpha = MySketch.degrees(theta)
    end
    return alpha
  end

  def pixel_under_mouse
    return xy2pixel(mouse_x, mouse_y, @origin_x, @origin_y)
#    return angle(mouse_x, mouse_y, @origin_x, @origin_y).to_f.degree_to_pixel.floor
  end

  # The bp position under the mouse is the first bp within that pixel
  # Suppose resolution of 1 pixel per 3062214 bp. Pixel 1 therefore contains
  # basepairs 1 - 3062214; pixel 2 contains basepairs 3062215 - 6124428. The
  # value returned is the lower boundary: the "position_under_mouse" for
  # pixel 2 therefore is chr1:3062215.
  # Another example: with this resolution, pixel 81 contains part of chr1 and
  # part of chr2 (cumulative_bp from 244977121 to 248039344). The "position_under_mouse"
  # for that pixel is chr1:244977133. The next pixel (82) has the position_under_mouse
  # of chr2:789,627.
  def find_position_under_mouse(pixel = self.pixel_under_mouse)
    return [nil, nil] if @current_slice.nil?
    return [nil, nil] if @current_slice.resolution < 1E-7
    chromosome_under_mouse = @chromosomes.values.select{|chr| chr.stop_pixel.ceil >= pixel}.sort_by{|c| c.start_cumulative_bp}[0]
    bp_under_mouse = @current_slice.start_cumulative_bp + (pixel - @current_slice.start_pixel).to_f/@current_slice.resolution
    bp_under_mouse -= chromosome_under_mouse.start_cumulative_bp - 1

    return [chromosome_under_mouse.name, bp_under_mouse.floor]
  end
end
