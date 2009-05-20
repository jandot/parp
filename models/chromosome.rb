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
    else
      prev_chr = self.class.sketch.chromosomes[(@name.to_i - 1).to_s]
      @offset_bp = prev_chr.offset_bp + prev_chr.length_bp
      @start_degree = @offset_bp*BP_TO_DEGREE_FACTOR
    end
    @stop_degree = @start_degree + @length_degree

    # Apply lenses
    @start_degree = @start_degree.to_f.apply_lenses
    @stop_degree = @stop_degree.to_f.apply_lenses
    @length_degree = @stop_degree - @start_degree
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
      read.calculate_degrees
    end
  end

  def fetch_copy_numbers(from_pos_string, to_pos_string)
    @copy_numbers = CopyNumber.fetch_region(from_pos_string, to_pos_string)
    @copy_numbers.each do |copy_number|
      copy_number.calculate_degrees
    end
  end

  def fetch_segdups(from_pos_string, to_pos_string)
    @segdups = SegDup.fetch_region(from_pos_string, to_pos_string)
    @segdups.each do |segdup|
      segdup.calculate_degrees
    end
  end

  def draw(buffer)
    # A. Draw the chromosomes themselves
    # a. ... the segment
    buffer.no_fill
    buffer.stroke_weight 3
    if @name.to_i % 2 == 0
      buffer.stroke 0
    else
      buffer.stroke 150
    end
    self.class.sketch.pline(@start_degree, @stop_degree, self.class.sketch.diameter, 0, 0, :buffer => buffer)

    # b. ... the label
    buffer.fill 0
    buffer.no_fill
    buffer.text_align MySketch::CENTER
    buffer.text_font self.class.sketch.f
    buffer.text(@name, self.class.sketch.cx(@start_degree + @length_degree/2, self.class.sketch.radius + 15), self.class.sketch.cy(@start_degree + @length_degree/2, self.class.sketch.radius + 15))
    buffer.text_align MySketch::LEFT
    
    # B. Draw the elements
    @copy_numbers.each do |copy_number|
      if copy_number.original_value < 20
        buffer.stroke 255,0,0
        buffer.stroke_weight 2
      elsif copy_number.original_value > 60
        buffer.stroke 0,255,0
        buffer.stroke_weight 2
      else
        buffer.stroke 0
        buffer.stroke_weight 0.5
      end
      self.class.sketch.pline(copy_number.start_degree, copy_number.stop_degree, self.class.sketch.diameter - 60 + copy_number.value, 0, 0, :buffer => buffer)
    end

    buffer.stroke 0,0,255,5
    buffer.stroke_weight 3

    @segdups.each do |segdup|
      self.class.sketch.pline(segdup.start_degree, segdup.stop_degree, self.class.sketch.diameter + 10, 0, 0)
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