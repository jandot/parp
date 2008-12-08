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
  attr_accessor :linear_x1, :linear_x2, :linear_bezier_y, :bezier_random
  attr_accessor :visible
  
  def initialize(chr1, pos1, chr2, pos2, code)
    @chr1 = S.chromosomes[chr1]
    @pos1 = pos1
    @chr2 = S.chromosomes[chr2]
    @pos2 = pos2
    @code = code
    @active = false
    @within_chromosome = (chr1 == chr2) ? true : false
    if @within_chromosome
      @chr1.within_chromosome_readpairs.push(self)
    end

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
    
    @linear_x1 = MySketch.map(@pos1, 0, @chr1.length, 0, S.width)
    @linear_x2 = MySketch.map(@pos2, 0, @chr2.length, 0, S.width)
    @bezier_random = S.random(-5,5)
  end
  
  def draw_buffer_circular(b, buffer_type)
    if buffer_type == :all
      b.stroke(0,0,0,10)
      b.strokeWeight(0.5)
    else #buffer_type == :highlighted
      b.stroke(255,0,0,50)
      b.strokeWeight(2)
    end
    b.bezier(@circular_x1, @circular_y1, @circular_bezier1_x, @circular_bezier1_y, @circular_bezier2_x, @circular_bezier2_y, @circular_x2, @circular_y2)
  end
  
  def draw_buffer_linear(b, buffer_type, baseline, top_linear)
    if @visible
      dy = 0
      if top_linear # It's the top of the two
        dy = 20
      else # It's the bottom of the two
        dy = -20
      end
      if ( @code == 'DIST')
        @linear_bezier_y = baseline - dy + @bezier_random
      else
        @linear_bezier_y = baseline + dy + @bezier_random
      end
      if buffer_type == :zoom
        b.stroke 0, 50
        b.strokeWeight 1
      else #buffer_type == :highlight
        b.stroke 255,0,0,50
        b.strokeWeight 2
      end
      b.bezier(@linear_x1, baseline, @linear_x1, @linear_bezier_y, @linear_x2, @linear_bezier_y, @linear_x2, baseline)
    end
  end
  
  def update_x(left_border, area)
    @linear_x1 = MySketch.map(@pos1, left_border, left_border + area, 0, S.width)
    @linear_x2 = MySketch.map(@pos2, left_border, left_border + area, 0, S.width)
    
    if ( @linear_x1 < 0 or @linear_x1 > S.width ) and ( @linear_x2 < 0 or @linear_x2 > S.width )
      @visible = false
    else
      @visible = true
    end
  end
end