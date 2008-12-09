class Chromosome
  attr_accessor :number, :length, :centromere
  attr_accessor :within_chromosome_readpairs, :between_chromosome_readpairs
  attr_accessor :centr_whole_genome, :centr_rad, :start_whole_genome, :start_rad, :stop_whole_genome, :stop_rad
  attr_accessor :ideogram, :ideogram_x1, :ideogram_y1, :baseline
  attr_accessor :zoom_box_ideogram_x1, :zoom_box_ideogram_x2, :zoom_box_ideogram_dx
  attr_accessor :left_border, :area
  attr_accessor :top_linear, :bottom_linear
  attr_accessor :zoom_box_left_activated, :zoom_box_right_activated
  attr_accessor :label
  
  def initialize(nr, length, centromere_start, centromere_stop)
    @number = nr
    @length = length
    @centromere = ( centromere_start + centromere_stop )/2
    @x = MySketch.map(@number, 0, 25, 0, S.width)
    @top_linear = false
    @bottom_linear = false
    @ideogram = S.loadImage("/Users/ja8/LocalDocuments/Projects/pARP/data/ideograms/chr" + @number.to_s + ".png")
    self.calculate_radians
    @label = ChromosomeLabel.new(self)
    S.chromosomes.push(self)
    
    @within_chromosome_readpairs = Array.new
    @between_chromosome_readpairs = Hash.new
    (@number..24).each do |n|
      @between_chromosome_readpairs[n] = Array.new
    end
  end
  
  def calculate_radians
    if @number == 1
      @start_whole_genome = 0
      @stop_whole_genome = @length
    else
      prev_chr = S.chromosomes[-1]
      @start_whole_genome = prev_chr.stop_whole_genome
      @stop_whole_genome = @start_whole_genome + @length
    end
    
    @centr_whole_genome = @start_whole_genome + @centromere
    centr_degree = (@centr_whole_genome.to_f/GENOME_SIZE)*360
    @centr_rad = MySketch.radians(centr_degree)
    
    start_degree = (@start_whole_genome.to_f/GENOME_SIZE)*360
    stop_degree = (@stop_whole_genome.to_f/GENOME_SIZE)*360
    @start_rad = MySketch.radians(start_degree)
    @stop_rad = MySketch.radians(stop_degree)
  end
  
  def draw_buffer_circular_all(b)
    b.noFill
    b.strokeWeight(3)
    if @number % 2 == 0
      b.stroke(0)
    else
      b.stroke(150)
    end
    b.arc(0,0, DIAMETER, DIAMETER, @start_rad, @stop_rad)
    
    b.fill(0)
    b.strokeWeight(0.5)
    
    b.ellipse(RADIUS*MySketch.cos(@centr_rad), RADIUS*MySketch.sin(@centr_rad),5,5)
    
    b.text(@number, @label.x1, @label.y2)
  end
  
  def draw_buffer_linear_ideograms(b)
    b.image(@ideogram, @ideogram_x1, @ideogram_y1)
    b.line(0, @baseline, b.width, @baseline)
  end
  
  def draw_buffer_linear_zoom(b)
    b.fill 0,255,0,50
    b.stroke 0
    b.strokeWeight 1
    b.rect(@zoom_box_ideogram_x1, @ideogram_y1, @zoom_box_ideogram_x2, @ideogram_y1 + @ideogram.height)
    
    b.noFill
    @within_chromosome_readpairs.select{|rp| rp.visible}.each do |rp|
      rp.draw_buffer_linear(b, :zoom)
    end
    if @top_linear
      if @number < S.bottom_linear.number
        @between_chromosome_readpairs[S.bottom_linear.number].select{|rp| rp.visible}.each do |rp|
          rp.draw_buffer_linear(b, :zoom)
        end
      else
        S.bottom_linear.between_chromosome_readpairs[@number].select{|rp| rp.visible}.each do |rp|
          rp.draw_buffer_linear(b, :zoom)
        end
      end
    end
  end
  
  def draw_buffer_linear_highlighted(b)
    b.fill 0
    b.text("Chromosome " + @number.to_s + " (" + (@length/1000).to_i.format + "kb). Cursor position: " + MySketch.map(S.mouse_x, 0, b.width, @left_border, @left_border + @area).to_i.format + "bp. Showing " + @left_border.to_i.format + " to " + (@left_border + @area).to_i.format, @ideogram.width + 10, @ideogram_y1 + S.text_ascent());
    
    b.stroke 100
    b.strokeWeight 5
    b.strokeCap(MySketch::ROUND)
    if @zoom_box_left_activated
      b.line(@zoom_box_ideogram_x1, @ideogram_y1, @zoom_box_ideogram_x1, @ideogram_y1 + @ideogram.height)
    elsif @zoom_box_right_activated
      b.line(@zoom_box_ideogram_x2, @ideogram_y1, @zoom_box_ideogram_x2, @ideogram_y1 + @ideogram.height)
    end
    
    b.noFill
    @within_chromosome_readpairs.select{|rp| rp.visible and rp.active}.each do |rp|
      rp.draw_buffer_linear(b, :highlighted)
    end
    if @top_linear
      if @number < S.bottom_linear.number
        @between_chromosome_readpairs[S.bottom_linear.number].select{|rp| rp.visible and rp.active}.each do |rp|
          rp.draw_buffer_linear(b, :highlighted)
        end
      else
        S.bottom_linear.between_chromosome_readpairs[@number].select{|rp| rp.visible and rp.active}.each do |rp|
          rp.draw_buffer_linear(b, :highlighted)
        end
      end
    end
  end
  
  def activate_zoom_boxes
    @zoom_box_left_activated = false
    @zoom_box_right_activated = false
    
    if S.pmouse_y >= @ideogram_y1 + S.height/2 and S.pmouse_y <= @ideogram_y1 + @ideogram.height + S.height/2
      if (S.pmouse_x - @zoom_box_ideogram_x1).abs < 5
        @zoom_box_left_activated = true
      elsif (S.pmouse_x - @zoom_box_ideogram_x2).abs < 5
        @zoom_box_right_activated = true
      end
    end
  end
  
  def set_linear(panel)
    @ideogram_x1 = 3
    @ideogram_x2 = @ideogram_x1 + @ideogram.width
    if panel == "top"
      @ideogram_y1 = 3
      @baseline = S.height/8
      @top_linear = true
      @bottom_linear = false
      @within_chromosome_readpairs.each do |rp|
        rp.visible = true
      end
      unless S.bottom_linear.nil?
        @between_chromosome_readpairs[S.bottom_linear.number].each do |rp|
          rp.visible = true
        end
      end
      
      S.chromosomes.each do |chr|
        if ! chr == self
          chr.top_linear = false
        end
      end
      
      S.top_linear = self
    else #panel == "bottom"
      @ideogram_y1 = S.height/2 - @ideogram.height - 3
      @baseline = 3*S.height/8
      @top_linear = false
      @bottom_linear = true
      @within_chromosome_readpairs.each do |rp|
        rp.visible = true
      end
      unless S.top_linear.nil?
        S.top_linear.between_chromosome_readpairs[@number].each do |rp|
          rp.visible = true
        end
      end

      S.chromosomes.each do |chr|
        if ! chr == self
          chr.bottom_linear = false
        end
      end

      S.bottom_linear = self
    end
    
    @left_border = 0
    @area = @length
    @zoom_box_ideogram_x1 = MySketch.map(@left_border, 0, @length, @ideogram_x1, @ideogram_x1 + @ideogram.width)
    @zoom_box_ideogram_x2 = MySketch.map(@left_border + @area, 0, @length, @ideogram_x1, @ideogram_x1 + @ideogram.width)
    @zoom_box_ideogram_dx = @zoom_box_ideogram_x2 - @zoom_box_ideogram_x1
  end
  
  def zoom_by_drag(side)
    x1 = @zoom_box_ideogram_x1
    x2 = @zoom_box_ideogram_x2
    if side == :left
      x1 += ( S.mouse_x - S.pmouse_x )
    else
      x2 += ( S.mouse_x - S.pmouse_x )
    end
    if ( x1 < x2 and x1 >= @ideogram_x1 and x2 <= @ideogram_x2 )
      if side == :left
        @zoom_box_ideogram_x1 = x1
        @left_border = MySketch.map(@zoom_box_ideogram_x1, @ideogram_x1, @ideogram_x1 + @ideogram.width, 0, @length)
      else
        @zoom_box_ideogram_x2 = x2
      end
      @zoom_box_ideogram_dx = @zoom_box_ideogram_x2 - @zoom_box_ideogram_x1
      @area = MySketch.map(@zoom_box_ideogram_dx, @ideogram_x1, @ideogram_x1 + @ideogram.width, 0, @length)
      
      @within_chromosome_readpairs.each do |rp|
        rp.update_x
      end
      if @top_linear
        if @number < S.bottom_linear.number
          @between_chromosome_readpairs[S.bottom_linear.number].each do |rp|
            rp.update_x
          end
        else
          S.bottom_linear.between_chromosome_readpairs[@number].each do |rp|
            rp.update_x
          end
        end
      else
        if @number < S.top_linear.number
          @between_chromosome_readpairs[S.top_linear.number].each do |rp|
            rp.update_x
          end
        else
          S.top_linear.between_chromosome_readpairs[@number].each do |rp|
            rp.update_x
          end
        end
      end
    end
  end
  
  def pan_by_drag
    dx = S.mouse_x - S.pmouse_x
    if @zoom_box_ideogram_x1 + dx >= @ideogram_x1 and @zoom_box_ideogram_x2 + dx <= @ideogram_x2
      @zoom_box_ideogram_x1 += dx
      @zoom_box_ideogram_x2 += dx
      
      @left_border = MySketch.map(@zoom_box_ideogram_x1, @ideogram_x1, @ideogram_x2, 0, @length)
      @within_chromosome_readpairs.each do |rp|
        rp.update_x
      end
      if @top_linear
        if @number < S.bottom_linear.number
          @between_chromosome_readpairs[S.bottom_linear.number].each do |rp|
            rp.update_x
          end
        else
          S.bottom_linear.between_chromosome_readpairs[@number].each do |rp|
            rp.update_x
          end
        end
      else
        if @number < S.top_linear.number
          @between_chromosome_readpairs[S.top_linear.number].each do |rp|
            rp.update_x
          end
        else
          S.top_linear.between_chromosome_readpairs[@number].each do |rp|
            rp.update_x
          end
        end
      end

    end
  end
end