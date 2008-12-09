class Button
  attr_accessor :chr, :contents, :action, :type
  attr_accessor :x1, :x2, :y1, :y2
  
  def initialize(chr, type, contents, action)
    @chr = chr
    @contents = contents
    @action = action
    @type = type
    
    if @chr == S.top_linear
      if S.buttons[:top].length > 0
        @x1 = S.buttons[:top][S.buttons[:top].length - 1].x2 + 10
      else
        @x1 = @chr.ideogram.width + 10
      end
    else
      if S.buttons[:bottom].length > 0
        @x1 = S.buttons[:bottom][S.buttons[:bottom].length - 1].x2 + 10
      else
        @x1 = @chr.ideogram.width + 10
      end
    end
    @x2 = @x1 + S.textWidth(@contents)
    @y1 = @chr.ideogram_y1 + 1.2*S.textAscent
    @y2 = @y1 + S.textAscent
  end
  
  def draw(b)
    b.fill 240
    b.noStroke
    b.rect(@x1, @y1, @x1 + S.textWidth(@contents) + 4, @y1 + S.textAscent + 4)
    b.fill 0
    b.text(@contents, @x1, @y1 + S.textAscent)
  end
  
  def under_mouse?
    return true if S.mouse_x.between?(@x1, @x2) and S.mouse_y.between?(@y1 + S.height/2, @y2 + S.height/2) 
    return false
  end
end