class ReadPair
  attr_accessor :chr1, :pos1, :x1, :chr2, :pos2, :x2
  attr_accessor :bezier_y
  attr_accessor :code
  attr_accessor :active
  attr_accessor :within_chromosome
  attr_accessor :pos1_whole_genome, :pos2_whole_genome
  attr_accessor :pos1_rad, :pos2_rad
  attr_accessor :circular_x1, :circular_y1, :circular_x2, :circular_y2
  attr_accessor :circular_bezier1_x, :circular_bezier1_y, :circular_bezier2_x, :circular_bezier2_y
  
  def initialize(chr1, pos1, chr2, pos2, code)
    @chr1 = S.chromosomes[chr1]
    @pos1 = pos1
    @chr2 = S.chromosomes[chr2]
    @pos2 = pos2
    @code = code
    @active = false
    @within_chromosome = (chr1 == chr2) ? true : false

    @pos1_whole_genome = @chr1.start_whole_genome + @pos1
    @pos2_whole_genome = @chr2.start_whole_genome + @pos2
    
    pos1_degree = (@pos1_whole_genome.to_f/GENOME_SIZE)*360
    pos2_degree = (@pos2_whole_genome.to_f/GENOME_SIZE)*360
    @pos1_rad = MySketch.radians(pos1_degree)
    @pos2_rad = MySketch.radians(pos2_degree)
    @circular_x1 = RADIUS*MySketch.cos(@pos1_rad)
    @circular_y1 = RADIUS*MySketch.sin(@pos1_rad)
    @circular_bezier1_x = (RADIUS-30)*MySketch.cos(@pos1_rad)
    @circular_bezier1_y = (RADIUS-30)*MySketch.sin(@pos1_rad)
    @circular_bezier2_x = (RADIUS-30)*MySketch.cos(@pos2_rad)
    @circular_bezier2_y = (RADIUS-30)*MySketch.sin(@pos2_rad)
    @circular_x2 = RADIUS*MySketch.cos(@pos2_rad)
    @circular_y2 = RADIUS*MySketch.sin(@pos2_rad)
  end
  
  def draw_buffer_circular(highlighted)
    if highlighted
      S.buffer_circular_highlighted.stroke(255,0,0)
      S.buffer_circular_highlighted.bezier(@circular_x1, @circular_y1, @circular_bezier1_x, @circular_bezier1_y, @circular_bezier2_x, @circular_bezier2_y, @circular_x2, @circular_y2)
    else
      S.buffer_circular_all.stroke(0,0,0,10)
      S.buffer_circular_all.bezier(@circular_x1, @circular_y1, @circular_bezier1_x, @circular_bezier1_y, @circular_bezier2_x, @circular_bezier2_y, @circular_x2, @circular_y2)
    end
  end
  
  def draw_buffer_circular_highlighted
    S.buffer_circular_all.bezier(@circular_x1, @circular_y1, @circular_bezier1_x, @circular_bezier1_y, @circular_bezier2_x, @circular_bezier2_y, @circular_x2, @circular_y2)
  end
end