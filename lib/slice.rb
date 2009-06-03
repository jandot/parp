class Slice
  class << self
    attr_accessor :sketch
  end
#  attr_accessor :start_chr, :start_bp, :stop_chr, :stop_bp
  attr_accessor :start_cumulative_bp, :stop_cumulative_bp, :range_cumulative_bp, :length_bp #counting over the whole genome
  attr_accessor :start_pixel, :stop_pixel, :range_pixel, :length_pixel
  attr_accessor :resolution #in bp/pixel
  attr_accessor :formatted_resolution

  def initialize(start_cumulative_bp = 1, stop_cumulative_bp = GENOME_SIZE, start_pixel = 1, stop_pixel = self.class.sketch.circumference)
    @start_cumulative_bp = start_cumulative_bp
    @stop_cumulative_bp = stop_cumulative_bp
    @range_cumulative_bp = Range.new(@start_cumulative_bp, @stop_cumulative_bp)
    @length_bp = @stop_cumulative_bp - @start_cumulative_bp + 1
    @start_pixel = start_pixel
    @stop_pixel = stop_pixel
    @range_pixel = Range.new(@start_pixel, @stop_pixel)
    @length_pixel = @stop_pixel - @start_pixel + 1
    @resolution = @length_bp.to_f/@length_pixel
    @formatted_resolution = ''
    if @resolution < 1000
      @formatted_resolution = sprintf("%.2f", @resolution) + ' bp/pixel'
    elsif @resolution < 1_000_000
      @formatted_resolution = sprintf("%.2f", (@resolution.to_f/1000)) + ' kb/pixel'
    else
      @formatted_resolution = sprintf("%.2f", (@resolution.to_f/1_000_000)) + ' Mb/pixel'
    end
  end

  def name
    return [@start_pixel, @stop_pixel, @start_cumulative_bp, @stop_cumulative_bp].join('_')
  end

  def self.add(center_bp, length_bp, new_length_pixel = (self.sketch.circumference.to_f/8).floor)#, resolution = 10_000)
    slice_containing_center = self.sketch.slices.select{|s| s.start_pixel <= center_bp}[-1]

    start_bp = (center_bp - length_bp.to_f/2 + 1).round
    stop_bp = (center_bp + length_bp.to_f/2).round
    new_slice = Slice.new(start_bp, stop_bp)
    new_slice.length_pixel = new_length_pixel
    new_slice.resolution = new_slice.length_bp.to_f/new_slice.length_pixel

    original_length_pixel = length_bp.to_f/slice_containing_center.resolution
    pixels_not_available_for_other_slices = new_length_pixel - original_length_pixel

    # First calculate resolutions for all slices
    # start_pixel and stop_pixel will be wrong but will be set later
    self.sketch.slices.delete(slice_containing_center)
    five_prime_slice = Marshal::load(Marshal.dump(slice_containing_center)) #deep copy
    five_prime_slice.stop_cumulative_bp = new_slice.start_cumulative_bp - 1
    five_prime_slice.length_bp = five_prime_slice.stop_cumulative_bp - five_prime_slice.start_cumulative_bp + 1
    three_prime_slice = Marshal::load(Marshal.dump(slice_containing_center)) #deep copy
    three_prime_slice.start_cumulative_bp = new_slice.stop_cumulative_bp + 1
    three_prime_slice.length_bp = three_prime_slice.stop_cumulative_bp - three_prime_slice.start_cumulative_bp + 1

    self.sketch.slices.push(five_prime_slice)
    self.sketch.slices.push(three_prime_slice)

    self.sketch.slices.each do |slice|
      old_length_pixels = slice.length_bp.to_f/slice.resolution
      proportion_of_rest_of_genome = slice.length_bp.to_f/(GENOME_SIZE - length_bp + 1)
      slice.length_pixel = (old_length_pixels - proportion_of_rest_of_genome*pixels_not_available_for_other_slices).round
      slice.resolution = slice.length_bp/slice.length_pixel
    end

    self.sketch.slices.push(new_slice)

    self.sketch.slices = self.sketch.slices.sort_by{|s| s.start_cumulative_bp}

    # This is when we can set start_pixel and stop_pixel
    self.sketch.slices.each_with_index do |slice, i|
      previous_slice_stop_pixel = ( i == 0 ) ? 0 : self.sketch.slices[i-1].stop_pixel
      slice.start_pixel = previous_slice_stop_pixel + 1
      slice.stop_pixel = slice.start_pixel + slice.length_pixel - 1
    end
  end

  def to_s
    output = Array.new
    output.push('-----')
    output.push("START BP=" + @start_cumulative_bp.to_s)
    output.push("STOP BP=" + @stop_cumulative_bp.to_s)
    output.push("LENGTH BP=" + @length_bp.to_s)
    output.push("START PIXEL=" + @start_pixel.to_s)
    output.push("STOP PIXEL=" + @stop_pixel.to_s)
    output.push("LENGTH PIXEL=" + @length_pixel.to_s)
    output.push("RESOLUTION=" + @resolution.to_s + " bp/pixel")
    return output.join("\n")
  end

  #Lets you change the pixel boundaries but not the basepair boundaries
  def zoom

  end

  def pan
    
  end

  #Lets you cram in more or less bp into the slice without changing the pixel boundaries
  def change_contents

  end

  # This draws a line around the display showing which parts are zoomed in
  def draw(buffer)
    buffer.no_fill
    buffer.stroke 0

    start_degree = @start_pixel.to_f.pixel_to_degree
    stop_degree = @stop_pixel.to_f.pixel_to_degree
    resolutions = self.class.sketch.slices.collect{|s| s.resolution}
    value = self.class.sketch.map(@resolution, resolutions.min, resolutions.max, 0, 20)
    self.class.sketch.pline(start_degree, stop_degree, self.class.sketch.diameter + 60 - value, 0, 0, :buffer => buffer)
  end
end
