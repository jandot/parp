class ReadPair
  attr_accessor :chr1, :pos1, :x1, :chr2, :pos2, :x2
  attr_accessor :bezier_y
  attr_accessor :code
  attr_accessor :activated
  
  def initialize(chr1, pos1, chr2, pos2, code)
    @chr1 = S.chromosomes[chr1]
    @pos1 = pos1
    @chr2 = S.chromosomes[chr2]
    @pos2 = pos2
    @code = code
    
    @x1 = MySketch.map(@pos1, 0, @chr1.length, 0, S.width)
    @x2 = MySketch.map(@pos2, 0, @chr2.length, 0, S.width)
    
    if ( code == 'DIST' )
      @bezier_y = S.height/2 - 80 + (rand(20)-10);
    else
      @bezier_y = S.height/2 + 80 + (rand(20)-10);
    end
  end
  
  def draw
    S.stroke(0)
    S.bezier(@x1, S.height/2, @x1, @bezier_y, @x2, @bezier_y, @x2, S.height/2)
  end
end