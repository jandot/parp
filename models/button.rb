class Button
  attr_accessor :contents, :action
  attr_accessor :x1, :x2, :y1, :y2
  
  def initialize(x1, y1, contents, &block)
    @x1 = x1
    @x2 = @x1 + S.textWidth(contents)
    @y1 = y1
    @y2 = @y1 + S.textAscent + 4
    @contents = contents
    @action = block
  end
  
  def draw(b)
    b.fill 240
    b.noStroke
    b.rect(@x1, @y1, @x2, @y2)
    b.fill 0
    b.text(@contents, @x1, @y1 + S.textAscent)
  end

  def execute
    @action.call
  end

  def under_mouse?
    return true if S.mouse_x.between?(@x1, @x2) and S.mouse_y.between?(@y1, @y2)
    return false
  end
end