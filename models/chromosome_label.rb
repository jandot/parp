class ChromosomeLabel
  attr_accessor :rad, :x1, :y1, :x2, :y2, :dx, :dy, :label, :active
  attr_accessor :chr
  
  def initialize(chr)
    @rad = (chr.start_rad + chr.stop_rad)/2
    @dx = S.text_width(chr.number.to_s)
    @dy = S.text_ascent
    calculate_radians
    @label = chr.number.to_s
    @active = false
  end

  def calculate_radians
    @x1 = (S.radius+15)*MySketch.cos(@rad)
    @y1 = (S.radius+15)*MySketch.sin(@rad) - S.text_ascent
    @x2 = @x1 + @dx
    @y2 = @y1 + @dy
  end

  def draw_buffer_circular(b, buffer_type)
    if buffer_type == :highlighted
      b.fill(0,50)
      b.rect(@x1 -2,@y1 -2,@dx +4,@dy +4)
    end
  end
  
  def under_mouse?
    if S.circular_only
      return true if S.mouse_x.between?(@x1 + S.width/2, @x2 + S.width/2) and S.mouse_y.between?(@y1 + S.height/2, @y2 + S.height/2)
      return false
    else
      return true if S.mouse_x.between?(@x1 + 3*S.width/4, @x2 + 3*S.width/4) and S.mouse_y.between?(@y1 + S.height/4, @y2 + S.height/4)
      return false
    end
  end
end