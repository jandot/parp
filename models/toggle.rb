class Toggle
  class << self
    attr_accessor :sketch
  end
  attr_accessor :label, :value
  attr_accessor :x1, :y1, :x2, :y2
  attr_accessor :text

  def initialize(label, value = true)
    @label = label
    @value = value
    @text = @label + ': ' + @value.to_s
  end

  def draw(b, offset)
    @text = @label + ': ' + @value.to_s
    @x1 = offset
    @x2 = @x1 + self.class.sketch.text_width(@text)
    @y1 = 0
    @y2 = self.class.sketch.text_ascent
    b.text @text, offset, self.class.sketch.text_ascent
  end

  def under_mouse?
    return true if S.mouse_x.between?(@x1, @x2) and S.mouse_y.between?(self.class.sketch.height - 20 + @y1, self.class.sketch.height - 20 + @y2)
    return false
  end

  def toggle
    @value = !@value
  end
end