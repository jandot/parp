class ContinuousFeature
  attr_accessor :chr, :pos, :x, :value, :visible

  def initialize(chr, pos, value)
    @chr = S.chromosomes.select{|c| c.number == chr.to_i}[0]
    @pos, @value = pos, value
    @chr.continuous_features.push(self)
  end

  def draw_buffer_linear(b)
    b.line(@x, @chr.baseline - @value, @x, @chr.baseline + 2)
  end

  def update_x
    @x = MySketch.map(@pos, @chr.left_border, @chr.left_border + @chr.area, 0, S.width)

    if @x < 0 or @x > S.width
      @visible = false
    else
      @visible = true
    end
  end
end