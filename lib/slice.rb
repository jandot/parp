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

  # Fetches the slice that covers a given position
  def self.fetch_by_bp(position)
    return self.sketch.slices.select{|s| s.start_cumulative_bp <= position}[-1]
  end

  def self.add(center_bp, length_bp, new_length_pixel = (self.sketch.circumference.to_f/8).floor)#, resolution = 10_000)
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

  #Lets you change the basepair boundaries but not the pixel boundaries
  # To zoom out, use a number < 1 (e.g. 0.2 to zoom out 5X)
  def zoom(factor = 5)
    STDERR.puts "CURRENT SLICE STARTS AT " + @start_pixel.to_s
    upstream_slices = self.class.sketch.slices.select{|s| s.start_cumulative_bp < @start_cumulative_bp}
    downstream_slices = self.class.sketch.slices.select{|s| s.start_cumulative_bp > @start_cumulative_bp}

    center_bp = (@start_cumulative_bp + @length_bp.to_f/2).round
    old_start_bp = @start_cumulative_bp
    old_stop_bp = @stop_cumulative_bp

    @length_bp = (@length_bp.to_f/factor).round
    @start_cumulative_bp = (center_bp - @length_bp.to_f/2 + 1).round
    @stop_cumulative_bp = (center_bp + @length_bp.to_f/2).round
    @resolution = @length_bp.to_f/@length_pixel

    pixels_to_be_crammed_in_upstream_slices = @start_cumulative_bp - old_start_bp
    pixels_to_be_crammed_in_downstream_slices = old_stop_bp - @stop_cumulative_bp

    upstream_slices.each_with_index do |upstream_slice, i|
      proportion_of_upstream_sequence = upstream_slice.length_bp.to_f/@start_cumulative_bp
      STDERR.puts '+++++'
      STDERR.puts "UPSTREAM STARTING AT " + upstream_slice.start_cumulative_bp.to_s
      STDERR.puts "LENGTH BP = " + upstream_slice.length_bp.to_s
      STDERR.puts "ORIGINAL LENGTH PIXEL = " + upstream_slice.length_pixel.to_s
      if factor > 1
        STDERR.puts "a " + proportion_of_upstream_sequence.to_s
        STDERR.puts "b " + pixels_to_be_crammed_in_upstream_slices.to_s
        upstream_slice.length_bp -= (proportion_of_upstream_sequence*pixels_to_be_crammed_in_upstream_slices).round
      else
        upstream_slice.length_bp += (proportion_of_upstream_sequence*pixels_to_be_crammed_in_upstream_slices).round
      end
      upstream_slice.resolution = upstream_slice.length_bp.to_f/upstream_slice.length_pixel

      STDERR.puts "PROPORTION = " + proportion_of_upstream_sequence.to_s
      STDERR.puts "NEW PIXEL LENGTH = " + upstream_slice.length_pixel.to_s
      if i == 0 # looking at the slice that's at the start
        upstream_slice.start_cumulative_bp = 1
      else
        upstream_slice.start_cumulative_bp = upstream_slices[i-1].stop_cumulative_bp + 1
      end
      upstream_slice.stop_cumulative_bp = upstream_slice.start_cumulative_bp + upstream_slice.length_bp - 1
    end

    downstream_slices.each_with_index do |downstream_slice, i|
      STDERR.puts '+++++'
      STDERR.puts "DOWNSTREAM STARTING AT " + downstream_slice.start_cumulative_bp.to_s
      STDERR.puts "LENGTH BP = " + downstream_slice.length_bp.to_s
      STDERR.puts "ORIGINAL LENGTH PIXEL = " + downstream_slice.length_pixel.to_s
      proportion_of_downstream_sequence = downstream_slice.length_bp.to_f/(GENOME_SIZE - @stop_cumulative_bp)
      if factor > 1
        downstream_slice.length_bp += (proportion_of_downstream_sequence*pixels_to_be_crammed_in_downstream_slices).round
      else
        downstream_slice.length_bp -= (proportion_of_downstream_sequence*pixels_to_be_crammed_in_downstream_slices).round
      end
      downstream_slice.resolution = downstream_slice.length_bp.to_f/downstream_slice.length_pixel

      STDERR.puts "PROPORTION = " + proportion_of_downstream_sequence.to_s
      STDERR.puts "NEW PIXEL LENGTH = " + downstream_slice.length_pixel.to_s

      if i == 0 # looking at the slice that's next downstream of slice under focus
        downstream_slice.start_cumulative_bp = @stop_cumulative_bp + 1
      else
        downstream_slice.start_cumulative_bp = downstream_slices[i-1].stop_cumulative_bp + 1
      end
      downstream_slice.stop_cumulative_bp = downstream_slice.start_cumulative_bp + downstream_slice.length_bp - 1
    end

    self.class.sketch.slices.each do |slice|
      slice.range_cumulative_bp = Range.new(slice.start_cumulative_bp, slice.stop_cumulative_bp)
      slice.range_pixel = Range.new(slice.start_pixel, slice.stop_pixel)
    end
  end

  def pan(distance_pixel = 10, direction = :left)
    STDERR.puts "CURRENT SLICE STARTS AT " + @start_pixel.to_s
    upstream_slices = self.class.sketch.slices.select{|s| s.start_cumulative_bp < @start_cumulative_bp}
    downstream_slices = self.class.sketch.slices.select{|s| s.start_cumulative_bp > @start_cumulative_bp}
    
    if direction == :left
      distance_pixel = ( @start_pixel - distance_pixel < 1 ) ? distance_pixel - @start_pixel : distance_pixel
      @start_pixel -= distance_pixel
      @stop_pixel -= distance_pixel
      @start_cumulative_bp -= (@resolution*distance_pixel).round
      @stop_cumulative_bp -= (@resolution*distance_pixel).round
    else
      distance_pixel = ( @stop_pixel + distance_pixel > self.class.sketch.circumference ) ? self.class.sketch.circumference - @stop_pixel : distance_pixel
      @start_pixel += distance_pixel
      @stop_pixel += distance_pixel
      @start_cumulative_bp += (@resolution*distance_pixel).round
      @stop_cumulative_bp += (@resolution*distance_pixel).round
    end
    STDERR.puts "DISTANCE PIXEL = " + distance_pixel.to_s

    upstream_slices.each_with_index do |upstream_slice, i|
      proportion_of_upstream_sequence = upstream_slice.length_bp.to_f/@start_cumulative_bp
      STDERR.puts '+++++'
      STDERR.puts "UPSTREAM STARTING AT " + upstream_slice.start_cumulative_bp.to_s
      STDERR.puts "LENGTH BP = " + upstream_slice.length_bp.to_s
      STDERR.puts "ORIGINAL LENGTH PIXEL = " + upstream_slice.length_pixel.to_s
      if direction == :left
        upstream_slice.length_pixel -= (proportion_of_upstream_sequence*distance_pixel).round
      else
        upstream_slice.length_pixel += (proportion_of_upstream_sequence*distance_pixel).round
      end
      upstream_slice.resolution = upstream_slice.length_bp.to_f/upstream_slice.length_pixel

      STDERR.puts "PROPORTION = " + proportion_of_upstream_sequence.to_s
      STDERR.puts "NEW PIXEL LENGTH = " + upstream_slice.length_pixel.to_s
      if i == 0 # looking at the slice that's at the start
        upstream_slice.start_pixel = 1
      else
        upstream_slice.start_pixel = upstream_slices[i-1].stop_pixel + 1
      end
      upstream_slice.stop_pixel = upstream_slice.start_pixel + upstream_slice.length_pixel - 1
    end

    downstream_slices.each_with_index do |downstream_slice, i|
      STDERR.puts '+++++'
      STDERR.puts "DOWNSTREAM STARTING AT " + downstream_slice.start_cumulative_bp.to_s
      STDERR.puts "LENGTH BP = " + downstream_slice.length_bp.to_s
      STDERR.puts "ORIGINAL LENGTH PIXEL = " + downstream_slice.length_pixel.to_s
      proportion_of_downstream_sequence = downstream_slice.length_bp.to_f/(GENOME_SIZE - @stop_cumulative_bp)
      if direction == :left
        downstream_slice.length_pixel += (proportion_of_downstream_sequence*distance_pixel).round
      else
        downstream_slice.length_pixel -= (proportion_of_downstream_sequence*distance_pixel).round
      end
      downstream_slice.resolution = downstream_slice.length_bp.to_f/downstream_slice.length_pixel

      STDERR.puts "PROPORTION = " + proportion_of_downstream_sequence.to_s
      STDERR.puts "NEW PIXEL LENGTH = " + downstream_slice.length_pixel.to_s

      if i == 0 # looking at the slice that's next downstream of slice under focus
        downstream_slice.start_pixel = @stop_pixel + 1
      else
        downstream_slice.start_pixel = downstream_slices[i-1].stop_pixel + 1
      end
      downstream_slice.stop_pixel = downstream_slice.start_pixel + downstream_slice.length_pixel - 1
    end

    self.class.sketch.slices.each do |slice|
      slice.range_cumulative_bp = Range.new(slice.start_cumulative_bp, slice.stop_cumulative_bp)
      slice.range_pixel = Range.new(slice.start_pixel, slice.stop_pixel)
    end
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
