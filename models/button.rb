class Button
  attr_accessor :contents, :action
  attr_accessor :x1, :x2, :y1, :y2
  
  def initialize(x1, x2, y1, y2, contents, action)
    @x1 = x1
    @x2 = x2
    @y1 = y1
    @y2 = y2
    @contents = contents
    @action = action
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