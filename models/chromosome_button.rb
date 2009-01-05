class ChromosomeButton < Button
  attr_accessor :chr
  
  def initialize(chr, contents, &block)
    @chr = chr
    @contents = contents
    @action = block
    
    if @chr == S.linear_representation[:top]
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

  def under_mouse?
    return true if S.mouse_x.between?(@x1, @x2) and S.mouse_y.between?(@y1 + S.height/2, @y2 + S.height/2)
    return false
  end
end