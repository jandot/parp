class Slider
  class << self
    attr_accessor :sketch
  end
  attr_accessor :label, :value
  attr_accessor :min, :max
  attr_accessor :line_start, :line_stop
  attr_accessor :x1, :y1, :x2, :y2 # For the line only, not for the label
  attr_accessor :value_x

  def initialize(label, value, min, max)
    @label = label
    @value = value
    @min, @max = min, max
    @line_start = self.class.sketch.text_width(@label) + 5
    @line_stop = @line_start + 100
  end

  def draw(b, offset)
    @x1 = @line_start + offset
    @x2 = @line_stop + offset
    @y1 = self.class.sketch.text_ascent/2
    @y2 = @y1
    value_x = self.class.sketch.class.map(@value, @min, @max, @line_start, @line_stop)
    b.text @label, offset, self.class.sketch.text_ascent
    b.line @x1, @y1, @x2, @y2
    b.line value_x + offset, @y1 - 5, value_x + offset, @y2 + 5
  end

  def under_mouse?
    return true if S.mouse_x.between?(@x1, @x2) and S.mouse_y.between?(self.class.sketch.height - 20 + @y1 - 10, self.class.sketch.height - 20 + @y2 + 10)
    return false
  end
end