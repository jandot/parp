class Chromosome
  class << self
    attr_accessor :sketch
  end
  attr_accessor :name, :length_bp, :centromere
  attr_accessor :reads, :copy_numbers, :segdups
  attr_accessor :offset_bp
  attr_accessor :start_degree, :stop_degree, :length_degree
  attr_accessor :start_pixel, :stop_pixel, :length_pixel
  attr_accessor :start_degree_through_lenses, :stop_degree_through_lenses, :length_degree_through_lenses

  def initialize(name, length, centromere)
    @name, @length_bp, @centromere = name, length, centromere
    @reads = Array.new
    @copy_numbers = Array.new
    @segdups = Array.new

#    @length_pixel = @length_bp*BP_TO_DEGREE_FACTOR
    if @name == '1'
      @offset_bp = 0
#      @start_pixel = 0
    else
      prev_chr = self.class.sketch.chromosomes[(@name.to_i - 1).to_s]
      @offset_bp = prev_chr.offset_bp + prev_chr.length_bp
#      @start_pixel = @offset_bp*BP_TO_DEGREE_FACTOR
    end
#    @stop_pixel = @start_degree + @length_pixel
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
    @start_pixel = @offset_bp.to_f.bp_to_pixel
    @stop_pixel = (@offset_bp + @length_bp).to_f.bp_to_pixel
    @start_degree = @start_pixel.to_f.pixel_to_degree
    @stop_degree = @stop_pixel.to_f.pixel_to_degree
    @length_degree = @stop_degree - @start_degree

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
      copy_number.start_pixel = (copy_number.chr.offset_bp + copy_number.start).to_f.bp_to_pixel
      copy_number.stop_pixel = (copy_number.chr.offset_bp + copy_number.stop).to_f.bp_to_pixel
      copy_number.start_degree = copy_number.start_pixel.to_f.pixel_to_degree
      copy_number.stop_degree = copy_number.stop_pixel.to_f.pixel_to_degree

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
      segdup.start_pixel = (segdup.chr.offset_bp + segdup.start).to_f.bp_to_pixel
      segdup.stop_pixel = (segdup.chr.offset_bp + segdup.stop).to_f.bp_to_pixel
      segdup.start_degree = segdup.start_pixel.to_f.pixel_to_degree
      segdup.stop_degree = segdup.stop_pixel.to_f.pixel_to_degree
      self.class.sketch.pline(segdup.start_degree, segdup.stop_degree, self.class.sketch.diameter + 10, 0, 0, :buffer => buffer)
    end

    @reads.each do |read|
      read.pixel = (read.chr.offset_bp + read.pos).to_f.bp_to_pixel
      read.degree = read.pixel.to_f.pixel_to_degree
    end
  end
end