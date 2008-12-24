class ChromosomeButton < Button
  attr_accessor :chr, :type
  
  def initialize(chr, type, contents, action)
    @chr = chr
    @contents = contents
    @action = action
    @type = type
    
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

end