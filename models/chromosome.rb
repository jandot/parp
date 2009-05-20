class Chromosome
  class << self
    attr_accessor :sketch
  end
  attr_accessor :name, :length_bp, :centromere
  attr_accessor :reads, :copy_numbers, :segdups
  attr_accessor :offset_bp
  attr_accessor :start_degree, :stop_degree, :length_degree

  def initialize(name, length, centromere)
    @name, @length_bp, @centromere = name, length, centromere
    @reads = Array.new
    @copy_numbers = Array.new
    @segdups = Array.new

    @length_degree = @length_bp*BP_TO_DEGREE_FACTOR
    if @name == '1'
      @offset_bp = 0
      @start_degree = 0
      @stop_degree = @length_degree
    else
      prev_chr = self.class.sketch.chromosomes[(@name.to_i - 1).to_s]
      @offset_bp = prev_chr.offset_bp + prev_chr.length_bp
      @start_degree = @offset_bp*BP_TO_DEGREE_FACTOR
      @stop_degree = @start_degree + @length_degree
    end
  end

  def fetch_data
    start_bp_string = ( @name.length == 1) ? '0' + @name : @name
    start_bp_string += '_' + 0.to_s.pad('0', 9)
    stop_bp_string = ( @name.length == 1) ? '0' + @name : @name
    stop_bp_string += '_' + @length_bp.to_s.pad('0', 9)

    self.fetch_reads(start_bp_string, stop_bp_string)
    self.fetch_copy_numbers(start_bp_string, stop_bp_string)
    self.fetch_segdups(start_bp_string, stop_bp_string)
  end

  def fetch_reads(from_pos_string, to_pos_string)
    @reads = Read.fetch_region(from_pos_string, to_pos_string)
    @reads.each do |read|
      read.degree = (self.offset_bp + read.pos)*BP_TO_DEGREE_FACTOR
    end
  end

  def fetch_copy_numbers(from_pos_string, to_pos_string)
    STDERR.puts @name + " " + from_pos_string + " " + to_pos_string
    @copy_numbers = CopyNumber.fetch_region(from_pos_string, to_pos_string)
    @copy_numbers.each do |copy_number|
      copy_number.start_degree = (self.offset_bp + copy_number.start)*BP_TO_DEGREE_FACTOR
      copy_number.stop_degree = (self.offset_bp + copy_number.stop)*BP_TO_DEGREE_FACTOR
#      STDERR.puts [self.name, self.offset_bp, copy_number.start, copy_number.start_degree, copy_number.stop_degree].join("\t")
    end
#    STDERR.puts "NUMBER OF COPY_NUMBER FOR CHR " + @name + ": " + @copy_numbers.length.to_s
  end

  def fetch_segdups(from_pos_string, to_pos_string)
    @segdups = SegDup.fetch_region(from_pos_string, to_pos_string)
    @segdups.each do |segdup|
      segdup.start_degree = (self.offset_bp + segdup.start)*BP_TO_DEGREE_FACTOR
      segdup.stop_degree = (self.offset_bp + segdup.stop)*BP_TO_DEGREE_FACTOR
    end
  end

  def draw
    # A. Draw the chromosomes themselves
    # a. ... the segment
    self.class.sketch.no_fill
    self.class.sketch.stroke_weight 3
    if @name.to_i % 2 == 0
      self.class.sketch.stroke 0
    else
      self.class.sketch.stroke 150
    end
    self.class.sketch.pline(@start_degree, @start_degree + @length_degree, self.class.sketch.diameter, 0, 0)

    # b. ... the label
    self.class.sketch.fill 0
    self.class.sketch.no_fill
    self.class.sketch.text_align MySketch::CENTER
    self.class.sketch.text(@name, self.class.sketch.cx(@start_degree + @length_degree/2, self.class.sketch.radius + 15), self.class.sketch.cy(@start_degree + @length_degree/2, self.class.sketch.radius + 15))
    self.class.sketch.text_align MySketch::LEFT
    
    # B. Draw the elements
    @copy_numbers.each do |copy_number|
      if copy_number.original_value < 20
        self.class.sketch.stroke 255,0,0
        self.class.sketch.stroke_weight 2
      elsif copy_number.original_value > 60
        self.class.sketch.stroke 0,255,0
        self.class.sketch.stroke_weight 2
      else
        self.class.sketch.stroke 0
        self.class.sketch.stroke_weight 0.5
      end
      self.class.sketch.pline(copy_number.start_degree, copy_number.stop_degree, self.class.sketch.diameter - 60 + copy_number.value, 0, 0)
    end

#    @resolution[display] = @length_bp.to_f/@length_degree[display]
#
#    # Draw the curve
#    STDERR.puts "Drawing the curve for chr " + @name.to_s
#    b.no_fill
#    b.stroke_weight 3
#    if index % 2 == 0
#      b.stroke 0
#    else
#      b.stroke 150
#    end
#    self.class.sketch.pline(@start_degree[display], @start_degree[display] + @length_degree[display], self.class.sketch.diameter, 0, 0, :buffer => b)
#
#    b.stroke 0
#    b.stroke_weight 1
#    b.line(self.class.sketch.cx(@start_degree[display], self.class.sketch.radius - 5), self.class.sketch.cy(@start_degree[display], self.class.sketch.radius - 5), self.class.sketch.cx(@start_degree[display], self.class.sketch.radius + 5), self.class.sketch.cy(@start_degree[display], self.class.sketch.radius + 5))
#    if display == self.class.sketch.displays[:detail]
#      b.stroke 200
#      b.line(0,0, self.class.sketch.cx(@start_degree[display], self.class.sketch.radius + 5), self.class.sketch.cy(@start_degree[display], self.class.sketch.radius + 5))
#    end
#
#    # Draw the label
#    b.fill 0
#    b.no_fill
#    b.text_align MySketch::CENTER
#    b.text(@label, self.class.sketch.cx(@start_degree[display] + @length_degree[display]/2, self.class.sketch.radius + 15), self.class.sketch.cy(@start_degree[display] + @length_degree[display]/2, self.class.sketch.radius + 15))
#    b.text_align MySketch::LEFT
#
#    @copy_numbers.each do |copy_number|
#      if copy_number.original_value < 20
#        b.stroke 255,0,0
#        b.stroke_weight 2
#      elsif copy_number.original_value > 60
#        b.stroke 0,255,0
#        b.stroke_weight 2
#      else
#        b.stroke 0
#        b.stroke_weight 0.5
#      end
#      self.class.sketch.pline(copy_number.start_degree[display], copy_number.stop_degree[display], self.class.sketch.diameter - 60 + copy_number.value, 0, 0, :buffer => b)
#    end
#
#    b.stroke 0,0,255,50
#    b.stroke_weight 1
#
#    @segdups.each do |segdup|
#      self.class.sketch.pline(segdup.start_degree[display], segdup.stop_degree[display], self.class.sketch.diameter + 10, 0, 0, :buffer => b)
#    end

  end
end