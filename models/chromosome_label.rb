class ChromosomeLabel
  attr_accessor :x1, :y1, :x2, :y2, :dx, :dy, :label, :active
  attr_accessor :chr
  
  def initialize(chr)
    rad = (chr.start_rad + chr.stop_rad)/2
    @x1 = (RADIUS+15)*MySketch.cos(rad)
    @y1 = (RADIUS+15)*MySketch.sin(rad) - S.text_ascent
    @dx = S.text_width(chr.number.to_s)
    @dy = S.text_ascent
    @label = chr.number.to_s
    @x2 = @x1 + @dx
    @y2 = @y1 + @dy
    @active = false
  end
  
  def draw_buffer_circular(b, buffer_type)
    if buffer_type == :highlighted
      b.fill(0,50)
      b.rect(@x1 -2,@y1 -2,@dx +4,@dy +4)
    end
  end
  
  def under_mouse?
    return true if S.mouse_x.between?(@x1 + S.width/4, @x2 + S.width/4) and S.mouse_y.between?(@y1 + S.height/4, @y2 + S.height/4) 
    return false
  end
end