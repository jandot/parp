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
    return angle(mouse_x, mouse_y, @origin_x, @origin_y).to_f.degree_to_pixel.floor
  end

  def find_position_under_mouse(pixel = self.pixel_under_mouse)
    return '' if @current_slice.nil?
    chromosome_under_mouse = @chromosomes.values.select{|chr| chr.start_pixel <= pixel and chr.stop_pixel >= pixel}[0]
    bp_under_mouse = @current_slice.start_cumulative_bp + (pixel - @current_slice.start_pixel).to_f/@current_slice.resolution
    bp_under_mouse -= chromosome_under_mouse.start_cumulative_bp
    return [chromosome_under_mouse.name, bp_under_mouse.floor]
  end
end
