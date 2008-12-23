class DiscreteFeature
  attr_accessor :chr, :start, :stop, :x1, :x2, :label, :visible

  def initialize(chr, start, stop, label)
    @chr = S.chromosomes.select{|c| c.number == chr.to_i}[0]
    @start, @stop, @label = start, stop, label
    @chr.discrete_features.push(self)
  end
  
  def draw_buffer_linear(b, buffer_type)
    if @chr.linear_representation == :top
      y = @chr.baseline - 20
    else
      y = @chr.baseline + 20
    end
    b.rect(@x1, y - 5, @x2, y + 5)
  end

  def update_x
    @x1 = MySketch.map(@start, @chr.left_border, @chr.left_border + @chr.area, 0, S.width)
    @x2 = MySketch.map(@stop, @chr.left_border, @chr.left_border + @chr.area, 0, S.width)

    if ( @x1 < 0 or @x1 > S.width ) and ( @x2 < 0 or @x2 > S.width )
      @visible = false
    else
      @visible = true
    end
  end
end