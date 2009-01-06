class Slider
  attr_accessor :label, :value
  attr_accessor :x1, :x2, :y1, :y2

  def initialize(x1, y1, label, value)
    @x1 = x1
    @x2 = x1 + 20
    @y1 = y1
    @y2 = y1 + 100
    @label = label
    @value = value
  end

  def draw(b)
    b.fill 150
    b.no_stroke
    b.rect(@x1, @y2 - MySketch.map(@value, 0, 40, 0, 100), @x2, @y2)
    b.no_fill
    b.stroke 150
    b.rect(@x1, @y1, @x2, @y2)
    b.fill 0
    b.text(@label, @x1, @y1 - S.text_ascent)
    b.text(@value.to_s, @x2 + 5, @y2 - MySketch.map(@value, 0, 40, 0, 100))
  end

  def under_mouse?
    return true if S.mouse_x.between?(@x1, @x2) and S.mouse_y.between?(@y1, @y2)
    return false
  end
end