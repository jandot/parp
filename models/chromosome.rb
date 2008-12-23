class Chromosome
  attr_accessor :number, :length, :centromere
  attr_accessor :within_chromosome_readpairs, :between_chromosome_readpairs
  attr_accessor :centr_whole_genome, :centr_rad, :start_whole_genome, :start_rad, :stop_whole_genome, :stop_rad
  attr_accessor :ideogram, :ideogram_x1, :ideogram_y1, :baseline
  attr_accessor :zoom_box_ideogram_x1, :zoom_box_ideogram_x2, :zoom_box_ideogram_dx
  attr_accessor :left_border, :area
  attr_accessor :linear_representation
  attr_accessor :zoom_box_left_activated, :zoom_box_right_activated
  attr_accessor :label
  attr_accessor :discrete_features, :continuous_features
  attr_accessor :first_line_continuous, :last_line_continuous
  
  def initialize(nr, length, centromere_start, centromere_stop)
    @number = nr
    @length = length
    @centromere = ( centromere_start + centromere_stop )/2
    @x = MySketch.map(@number, 0, 25, 0, S.width)
    @linear_representation = nil
    @ideogram = S.loadImage("/Users/ja8/LocalDocuments/Projects/pARP/data/ideograms/chr" + @number.to_s + ".png")
    self.calculate_radians
    @label = ChromosomeLabel.new(self)
    S.chromosomes.push(self)
    
    @within_chromosome_readpairs = Array.new
    @between_chromosome_readpairs = Hash.new
    (@number..24).each do |n|
      @between_chromosome_readpairs[n] = Array.new
    end
    @discrete_features = Array.new
    @continuous_features = Array.new
    
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
    b.arc(0,0, S.diameter, S.diameter, @start_rad, @stop_rad)
    
    b.fill(0)
    b.strokeWeight(0.5)
    
    b.ellipse(S.radius*MySketch.cos(@centr_rad), S.radius*MySketch.sin(@centr_rad),5,5)
    
    b.text(@number, @label.x1, @label.y2)
  end
  
  def draw_buffer_linear_ideograms(b)
    b.image(@ideogram, @ideogram_x1, @ideogram_y1)
    b.stroke(0)
    b.line(0, @baseline, b.width, @baseline)
    if @linear_representation == :top
      S.buttons[:top].each do |button|
        button.draw(b)
      end
    else
      S.buttons[:bottom].each do |button|
        button.draw(b)
      end
    end
  end
  
  def draw_buffer_linear_zoom(b)
    b.fill 0,255,0,50
    b.stroke 0
    b.stroke_weight 1
    b.rect(@zoom_box_ideogram_x1, @ideogram_y1, @zoom_box_ideogram_x2, @ideogram_y1 + @ideogram.height)
    
    b.no_fill
    @within_chromosome_readpairs.select{|rp| rp.visible}.each do |rp|
      rp.draw_buffer_linear(b, :zoom)
    end
    
    b.fill 0,0,255,50
    b.no_stroke
    @discrete_features.select{|f| f.visible}.each do |f|
      f.draw_buffer_linear(b, :zoom)
    end
  end
  
  def draw_buffer_linear_highlighted(b)
    b.fill 0
    b.text("Chromosome " + @number.to_s + " (" + (@length/1000).to_i.format + "kb). Cursor position: " + MySketch.map(S.mouse_x, 0, b.width, @left_border, @left_border + @area).to_i.format + "bp. Showing " + @left_border.to_i.format + " to " + (@left_border + @area).to_i.format, @ideogram.width + 10, @ideogram_y1 + S.text_ascent());

    b.stroke 100
    b.stroke_weight 5
    b.stroke_cap(MySketch::ROUND)
    if @zoom_box_left_activated
      b.line(@zoom_box_ideogram_x1, @ideogram_y1, @zoom_box_ideogram_x1, @ideogram_y1 + @ideogram.height)
    elsif @zoom_box_right_activated
      b.line(@zoom_box_ideogram_x2, @ideogram_y1, @zoom_box_ideogram_x2, @ideogram_y1 + @ideogram.height)
    end
    
    b.no_fill
    @within_chromosome_readpairs.select{|rp| rp.visible and rp.active}.each do |rp|
      rp.draw_buffer_linear(b, :highlighted)
    end
  end

  def draw_buffer_linear_continuous_features(b)
    b.stroke 0, 150
    b.no_fill
    @continuous_features.select{|f| f.visible}.each do |f|
      f.draw_buffer_linear(b)
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
    if panel == :top
      @ideogram_y1 = 3
      @baseline = S.height/8
    else
      @ideogram_y1 = S.height/2 - @ideogram.height - 3
      @baseline = 3*S.height/8
    end
    @linear_representation = panel
    S.linear_representation[panel] = self

    @left_border = 0
    @area = @length
    @zoom_box_ideogram_x1 = MySketch.map(@left_border, 0, @length, @ideogram_x1, @ideogram_x1 + @ideogram.width)
    @zoom_box_ideogram_x2 = MySketch.map(@left_border + @area, 0, @length, @ideogram_x1, @ideogram_x1 + @ideogram.width)
    @zoom_box_ideogram_dx = @zoom_box_ideogram_x2 - @zoom_box_ideogram_x1

    self.load_continuous_features
    self.zoom_by_step(:show_complete)

    S.chromosomes.each do |chr|
      if ! chr == self
        chr.linear_representation[panel] = false
      end
    end
    
    S.buttons[panel] = Array.new
    S.buttons[panel].push(Button.new(self, :zoom, "Complete", :show_complete))
    S.buttons[panel].push(Button.new(self, :zoom, "zoom out 10x", :zoom_out_10x))
    S.buttons[panel].push(Button.new(self, :zoom, "zoom out 3x", :zoom_out_3x))
    S.buttons[panel].push(Button.new(self, :zoom, "zoom in 3x", :zoom_in_3x))
    S.buttons[panel].push(Button.new(self, :zoom, "zoom in 10x", :zoom_in_10x))
    S.buttons[panel].push(Button.new(self, :pan, "<<", :left_large))
    S.buttons[panel].push(Button.new(self, :pan, "<", :left_small))
    S.buttons[panel].push(Button.new(self, :pan, ">", :right_small))
    S.buttons[panel].push(Button.new(self, :pan, ">>", :right_large))
  end

  def load_continuous_features
    if @continuous_features.length == 0
      S.thread_load_continuous_features = Thread.new do
        file = File.open(FILE_CONTINUOUS_FEATURES)
        @first_line_continuous.times { file.gets }
        while file.lineno < @last_line_continuous
          chr, pos, value = file.gets.chomp.split(/\t/)
          value = MySketch.map(value.to_i, 100, 50000, 0, 20)
          ContinuousFeature.new(chr.to_i, pos.to_i, value.to_i)
        end
      end
    end
  end

  def update_x
    @discrete_features.each do |f|
      f.update_x
    end

    S.thread_update_x_continuous_features = Thread.new do
      if !S.thread_load_continuous_features.nil?
        S.thread_load_continuous_features.join
      end
      @continuous_features.each do |f|
        f.update_x
      end
    end
    
    @within_chromosome_readpairs.each do |rp|
      rp.update_x
    end
    
    unless S.linear_representation[:top].nil? or S.linear_representation[:bottom].nil?
      if @linear_representation == :top
        if @number < S.linear_representation[:bottom].number
          @between_chromosome_readpairs[S.linear_representation[:bottom].number].each do |rp|
            rp.update_x
          end
        else
          S.linear_representation[:bottom].between_chromosome_readpairs[@number].each do |rp|
            rp.update_x
          end
        end
      else
        if @number < S.linear_representation[:top].number
          @between_chromosome_readpairs[S.linear_representation[:top].number].each do |rp|
            rp.update_x
          end
        else
          S.linear_representation[:top].between_chromosome_readpairs[@number].each do |rp|
            rp.update_x
          end
        end
      end
    end
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
    end
    self.update_x
  end

  def zoom_by_step(action)
    if action == :show_complete
      @left_border = 0
      @area = @length
    elsif action == :zoom_in_10x
      orig_area = @area
      @area = [@area.to_f/10, 10].max
      @left_border += (orig_area - @area)/2
    elsif action == :zoom_in_3x
      orig_area = @area
      @area = [@area.to_f/3, 10].max
      @left_border += (orig_area - @area)/2
    elsif action == :zoom_out_3x
      orig_area = @area
      @area = [@area*3, @length].min
      @left_border += (orig_area - @area)/2
      if ( @left_border + @area > @length )
        @left_border = @length - @area
      elsif @left_border < 0
        @left_border = 0
      end
    elsif action == :zoom_out_10x
      orig_area = @area
      @area = [@area*10, @length].min
      @left_border += (orig_area - @area)/2
      if ( @left_border + @area > @length )
        @left_border = @length - @area
      elsif @left_border < 0
        @left_border = 0
      end
    end

    @zoom_box_ideogram_x1 = MySketch.map(@left_border, 0, @length, @ideogram_x1, @ideogram_x1 + @ideogram.width)
    @zoom_box_ideogram_x2 = MySketch.map(@left_border + @area, 0, @length, @ideogram_x1, @ideogram_x1 + @ideogram.width)
    @zoom_box_ideogram_dx = @zoom_box_ideogram_x2 - @zoom_box_ideogram_x1

    self.update_x

  end
  
  
  def pan_by_drag
    dx = S.mouse_x - S.pmouse_x
    if @zoom_box_ideogram_x1 + dx >= @ideogram_x1 and @zoom_box_ideogram_x2 + dx <= @ideogram_x2
      @zoom_box_ideogram_x1 += dx
      @zoom_box_ideogram_x2 += dx
      
      @left_border = MySketch.map(@zoom_box_ideogram_x1, @ideogram_x1, @ideogram_x2, 0, @length)
      self.update_x

    end
  end
  
  def pan_by_step(action)
    if action == :left_large
      @left_border = [@left_border - @area, 0].max
    elsif action == :left_small
      @left_border = [@left_border - @area.to_f/2, 0].max
    elsif action == :right_small
      @left_border = [@left_border + @area.to_f/2, @length - @area - 10].min
    elsif action == :right_large
      @left_border = [@left_border + @area, @length - @area - 10].min
    end
    
    @zoom_box_ideogram_x1 = MySketch.map(@left_border, 0, @length, @ideogram_x1, @ideogram_x1 + @ideogram.width)
    @zoom_box_ideogram_x2 = MySketch.map(@left_border + @area, 0, @length, @ideogram_x1, @ideogram_x1 + @ideogram.width)
    @zoom_box_ideogram_dx = @zoom_box_ideogram_x2 - @zoom_box_ideogram_x1
    
    self.update_x
  end

  def apply_button(type, action)
    if type == :zoom
      self.zoom_by_step(action)
    else
      self.pan_by_step(action)
    end
  end
end