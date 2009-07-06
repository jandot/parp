class Slice
  class << self
    attr_accessor :sketch
  end
#  attr_accessor :start_chr, :start_bp, :stop_chr, :stop_bp
  attr_accessor :start_cumulative_bp, :stop_cumulative_bp, :range_cumulative_bp, :length_bp #counting over the whole genome
  attr_accessor :start_pixel, :stop_pixel, :range_pixel, :length_pixel
  attr_accessor :resolution #in pixel/bp => high resolution = zoomed in
  attr_accessor :formatted_resolution
  attr_accessor :colour
  attr_accessor :fixed

  def initialize(start_cumulative_bp = 1, stop_cumulative_bp = GENOME_SIZE, start_pixel = 1, stop_pixel = self.class.sketch.circumference)
    @start_cumulative_bp = start_cumulative_bp
    @stop_cumulative_bp = stop_cumulative_bp
    @range_cumulative_bp = Range.new(@start_cumulative_bp, @stop_cumulative_bp)
    @length_bp = @stop_cumulative_bp - @start_cumulative_bp + 1
    @start_pixel = start_pixel
    @stop_pixel = stop_pixel
    @range_pixel = Range.new(@start_pixel, @stop_pixel)
    @length_pixel = @stop_pixel - @start_pixel + 1
    @resolution = @length_pixel.to_f/@length_bp
    @fixed = false
    @formatted_resolution = ''
    self.format_resolution
  end

  def set_colour
    red = nil
    if @resolution < 1E-6
      red = 0
    elsif @resolution > 1
      red = 255
    else
      red = self.class.sketch.class.map(Math.log(@resolution), Math.log(1E-6), Math.log(1), 0, 255)
    end
    @colour = self.class.sketch.color(red,0,0)
  end

  def name
    return [@start_pixel, @stop_pixel, @start_cumulative_bp, @stop_cumulative_bp].join('_')
  end

  # Fetches the slice that covers a given position
  def self.fetch_by_bp(position)
    return self.sketch.slices.select{|s| s.start_cumulative_bp <= position}[-1]
  end

  def format_resolution
    if @resolution > 0.001
      @formatted_resolution = sprintf("%.2f", 1.to_f/@resolution) + ' bp/pixel'
    elsif @resolution > 0.000001
      @formatted_resolution = sprintf("%.2f", 1.to_f/(1000*@resolution)) + ' kb/pixel'
    else
      @formatted_resolution = sprintf("%.2f", 1.to_f/(1_000_000*@resolution)) + ' Mb/pixel'
    end
  end

  def self.add(center_bp, length_bp, new_length_pixel = (self.sketch.circumference.to_f/4).floor)#, resolution = 10_000)
    slice_containing_center = self.fetch_by_bp(center_bp)

    start_bp = (center_bp - length_bp.to_f/2 + 1).round
    stop_bp = (center_bp + length_bp.to_f/2).round
    new_slice = Slice.new(start_bp, stop_bp)
    new_slice.length_pixel = new_length_pixel
    new_slice.resolution = new_slice.length_pixel.to_f/new_slice.length_bp

    original_length_pixel = length_bp*slice_containing_center.resolution
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
      slice.range_cumulative_bp = Range.new(slice.start_cumulative_bp, slice.stop_cumulative_bp)
      old_length_pixels = slice.length_bp*slice.resolution
      proportion_of_rest_of_genome = slice.length_bp.to_f/(GENOME_SIZE - length_bp + 1)
      slice.length_pixel = (old_length_pixels - proportion_of_rest_of_genome*pixels_not_available_for_other_slices).round
      
      # We have to check that the slice is not smaller than 1 pixel (i.e. 0 pixels) because that'll give
      # a divide-by-zero. In that case we set the length_pixel to 0.00001
      if slice.length_pixel == 0
        slice.length_pixel = 0.00001
      end
      slice.resolution = slice.length_pixel.to_f/slice.length_bp
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

    self.sketch.buffer_images[:zoomed] = self.sketch.draw_zoomed_buffer
    self.sketch.buffer_images[:information_panel] = self.sketch.draw_information_panel
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
    output.push("RESOLUTION=" + 1.to_f/@resolution.to_s + " bp/pixel")
    output.push("FIXED?=" + @fixed.to_s)
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
    @resolution = @length_pixel.to_f/@length_bp

    upstream_slice.stop_cumulative_bp = @start_cumulative_bp - 1
    downstream_slice.start_cumulative_bp = @stop_cumulative_bp + 1
    [upstream_slice, downstream_slice].each do |s|
      s.length_bp = s.stop_cumulative_bp - s.start_cumulative_bp + 1
      s.resolution = s.length_pixel.to_f/s.length_bp
      s.range_cumulative_bp = Range.new(s.start_cumulative_bp, s.stop_cumulative_bp)
    end
    self.class.sketch.slices.each{|s| s.format_resolution}

    self.class.sketch.buffer_images[:zoomed] = self.class.sketch.draw_zoomed_buffer
    self.class.sketch.buffer_images[:information_panel] = self.class.sketch.draw_information_panel
  end

  # Panning moves the slice window left or right by a given number of basepairs.
  # Pixel boundaries do not change.
  # When panning left, the bp boundary is moved so the basepairs upstream of the original boundary
  # are shown. As a result, the slice just upstream of the active slice will loose those basepairs.
  # Slices that are
  def pan(direction = :left, distance_bp = (self.length_bp.to_f/5).round)
    upstream_slice = self.class.sketch.slices.select{|s| s.start_cumulative_bp < @start_cumulative_bp}.sort_by{|s| s.start_cumulative_bp}[-1]
    downstream_slice = self.class.sketch.slices.select{|s| s.start_cumulative_bp > @start_cumulative_bp}.sort_by{|s| s.stop_cumulative_bp}[0]

    #Check if we actually _can_ pan. Can't do that if the slice in the panned
    #direction has less basepairs than what we want to add to our slice in focus
    if ( direction == :left and upstream_slice.length_bp > distance_bp ) or
       ( direction == :right and downstream_slice.length_bp > distance_bp )

      #Just so we can always add the distance_pixel
      if direction == :left
        distance_bp = -distance_bp
      end

      @start_cumulative_bp += distance_bp
      @stop_cumulative_bp += distance_bp

      upstream_slice.stop_cumulative_bp = @start_cumulative_bp - 1
      downstream_slice.start_cumulative_bp = @stop_cumulative_bp + 1
      [upstream_slice, downstream_slice].each do |s|
        s.length_bp = s.stop_cumulative_bp - s.start_cumulative_bp + 1
        s.resolution = s.length_pixel.to_f/s.length_bp
        s.range_cumulative_bp = Range.new(s.start_cumulative_bp, s.stop_cumulative_bp)
      end
      self.class.sketch.slices.each{|s| s.format_resolution}

      self.class.sketch.buffer_images[:zoomed] = self.class.sketch.draw_zoomed_buffer
      self.class.sketch.buffer_images[:information_panel] = self.class.sketch.draw_information_panel
    end
  end

  # This will collapse the slice to 5 pixels (default). The space that becomes
  # available is then evenly distributed over the other slices.
  def collapse(length_pixel = 20)
    new_pixels_available = @length_pixel - length_pixel
    @length_pixel = length_pixel

    # Distribute the pixels that became available of the other slices
    self.class.sketch.slices.reject{|s| s == self}.each do |slice|
      slice.length_pixel += (new_pixels_available.to_f/(self.class.sketch.slices.length - 1)).round
    end
    self.class.sketch.slices.each_with_index do |slice, i|
      if i == 0
        slice.start_pixel = 1
      else
        slice.start_pixel = self.class.sketch.slices[i-1].stop_pixel + 1
      end
      slice.stop_pixel = slice.start_pixel + slice.length_pixel - 1
      slice.range_pixel = Range.new(slice.start_pixel, slice.stop_pixel)
      slice.resolution = slice.length_pixel.to_f/slice.length_bp
      slice.format_resolution
    end

    self.class.sketch.buffer_images[:zoomed] = self.class.sketch.draw_zoomed_buffer
    self.class.sketch.buffer_images[:information_panel] = self.class.sketch.draw_information_panel
  end

  # This draws a line around the display showing which parts are zoomed in
  def draw(buffer)
    @colour = self.set_colour
    buffer.no_fill
    buffer.stroke 0

    start_degree = @start_pixel.to_f.pixel_to_degree
    stop_degree = @stop_pixel.to_f.pixel_to_degree
    buffer.stroke @colour
    buffer.stroke_weight 5
    self.class.sketch.pline(start_degree, stop_degree, self.class.sketch.diameter + 20, 0, 0, :buffer => buffer)
  end
end
