class Slice
  class << self
    attr_accessor :sketch
  end
#  attr_accessor :start_chr, :start_bp, :stop_chr, :stop_bp
  attr_accessor :start_cumulative_bp, :stop_cumulative_bp, :range_cumulative_bp, :length_bp #counting over the whole genome
  attr_accessor :start_pixel, :stop_pixel, :range_pixel, :length_pixel
  attr_accessor :resolution #in bp/pixel
  attr_accessor :formatted_resolution
  attr_accessor :colour

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
    self.format_resolution
    @colour = self.class.sketch.color(self.class.sketch.random(0,255),self.class.sketch.random(0,255),self.class.sketch.random(0,255))
  end

  def name
    return [@start_pixel, @stop_pixel, @start_cumulative_bp, @stop_cumulative_bp].join('_')
  end

  # Fetches the slice that covers a given position
  def self.fetch_by_bp(position)
    return self.sketch.slices.select{|s| s.start_cumulative_bp <= position}[-1]
  end

  def format_resolution
    if @resolution < 1000
      @formatted_resolution = sprintf("%.2f", @resolution) + ' bp/pixel'
    elsif @resolution < 1_000_000
      @formatted_resolution = sprintf("%.2f", (@resolution.to_f/1000)) + ' kb/pixel'
    else
      @formatted_resolution = sprintf("%.2f", (@resolution.to_f/1_000_000)) + ' Mb/pixel'
    end
  end

  def self.add(center_bp, length_bp, new_length_pixel = (self.sketch.circumference.to_f/4).floor)#, resolution = 10_000)
    slice_containing_center = self.fetch_by_bp(center_bp)

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
    
    five_prime_slice.colour = self.sketch.color(self.sketch.random(0,255),self.sketch.random(0,255),self.sketch.random(0,255))
    three_prime_slice.colour = self.sketch.color(self.sketch.random(0,255),self.sketch.random(0,255),self.sketch.random(0,255))

    self.sketch.slices.push(five_prime_slice)
    self.sketch.slices.push(three_prime_slice)

    self.sketch.slices.each do |slice|
      slice.range_cumulative_bp = Range.new(slice.start_cumulative_bp, slice.stop_cumulative_bp)
      old_length_pixels = slice.length_bp.to_f/slice.resolution
      proportion_of_rest_of_genome = slice.length_bp.to_f/(GENOME_SIZE - length_bp + 1)
      slice.length_pixel = (old_length_pixels - proportion_of_rest_of_genome*pixels_not_available_for_other_slices).round
      
      # We have to check that the slice is not smaller than 1 pixel (i.e. 0 pixels) because that'll give
      # a divide-by-zero. In that case we set the length_pixel to 0.00001
      if slice.length_pixel == 0
        slice.length_pixel = 0.00001
      end
      slice.resolution = slice.length_bp/slice.length_pixel
    end

    self.sketch.slices.push(new_slice)

    # Sort slices on position
    self.sketch.slices = self.sketch.slices.sort_by{|s| s.start_cumulative_bp}

    # This is when we can set start_pixel and stop_pixel
    self.sketch.slices.each_with_index do |slice, i|
      previous_slice_stop_pixel = ( i == 0 ) ? 0 : self.sketch.slices[i-1].stop_pixel
      slice.start_pixel = previous_slice_stop_pixel + 1
      slice.stop_pixel = slice.start_pixel + slice.length_pixel - 1
      slice.range_pixel = Range.new(slice.start_pixel, slice.stop_pixel)
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

  # Lets you change the basepair boundaries but not the pixel boundaries
  # To zoom out, use a number < 1 (e.g. 0.2 to zoom out 5X)
  # Only the bp content of the neighbouring slices is changed as well. Content
  # of slices further away stays the same.
  def zoom(factor = 5)
    upstream_slice = self.class.sketch.slices.select{|s| s.start_cumulative_bp < @start_cumulative_bp}.sort_by{|s| s.start_cumulative_bp}[-1]
    downstream_slice = self.class.sketch.slices.select{|s| s.start_cumulative_bp > @start_cumulative_bp}.sort_by{|s| s.start_cumulative_bp}[0]

    center_bp = (@start_cumulative_bp + @length_bp.to_f/2).round

    @length_bp = (@length_bp.to_f/factor).round
    @start_cumulative_bp = (center_bp - @length_bp.to_f/2).round
    @stop_cumulative_bp = (center_bp + @length_bp.to_f/2 - 1).round
    @resolution = @length_bp.to_f/@length_pixel

    upstream_slice.stop_cumulative_bp = @start_cumulative_bp - 1
    downstream_slice.start_cumulative_bp = @stop_cumulative_bp + 1
    [upstream_slice, downstream_slice].each do |s|
      s.length_bp = s.stop_cumulative_bp - s.start_cumulative_bp + 1
      s.resolution = s.length_bp.to_f/s.length_pixel
      s.range_cumulative_bp = Range.new(s.start_cumulative_bp, s.stop_cumulative_bp)
      s.range_pixel = Range.new(s.start_pixel, s.stop_pixel)
    end
    self.class.sketch.slices.each{|s| s.format_resolution}
  end

  # Panning moves the slice window left or right by a given number of pixels. This will also change
  # the bp contents of the slice.
  # When panning left, the bp boundary is moved so the basepairs upstream of the original boundary
  # are shown. As a result, the slice just upstream of the active slice will loose those basepairs.
  # Slices that are
  def pan(distance_pixel = 10, direction = :left)
    upstream_slice = self.class.sketch.slices.select{|s| s.start_cumulative_bp < @start_cumulative_bp}.sort_by{|s| s.start_cumulative_bp}[-1]
    downstream_slice = self.class.sketch.slices.select{|s| s.start_cumulative_bp > @start_cumulative_bp}.sort_by{|s| s.stop_cumulative_bp}[0]

    #Just so we can always add the distance_pixel
    if direction == :left
      distance_pixel = -distance_pixel
    end

    @start_pixel += distance_pixel
    @stop_pixel += distance_pixel
    @start_cumulative_bp += (@resolution*distance_pixel).round
    @stop_cumulative_bp += (@resolution*distance_pixel).round

    upstream_slice.stop_pixel = @start_pixel - 1
    upstream_slice.stop_cumulative_bp = @start_cumulative_bp - 1
    downstream_slice.start_pixel = @stop_pixel + 1
    downstream_slice.start_cumulative_bp = @stop_cumulative_bp + 1
    [upstream_slice, downstream_slice].each do |s|
      s.length_pixel = s.stop_pixel - s.start_pixel + 1
      s.length_bp = s.stop_cumulative_bp - s.start_cumulative_bp + 1
      s.resolution = s.length_bp.to_f/s.length_pixel
      s.range_cumulative_bp = Range.new(s.start_cumulative_bp, s.stop_cumulative_bp)
      s.range_pixel = Range.new(s.start_pixel, s.stop_pixel)
    end
    self.class.sketch.slices.each{|s| s.format_resolution}
  end
end
