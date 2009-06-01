class Slice
  class << self
    attr_accessor :sketch
  end
#  attr_accessor :start_chr, :start_bp, :stop_chr, :stop_bp
  attr_accessor :start_overall_bp, :stop_overall_bp, :range_overall_bp #counting over the whole genome
  attr_accessor :start_pixel, :stop_pixel, :range_pixel
  attr_accessor :resolution #in bp/pixel
  attr_accessor :formatted_resolution

  def initialize(start_overall_bp = 0, stop_overall_bp = GENOME_SIZE, start_pixel = 0, stop_pixel = self.class.sketch.circumference)
    @start_overall_bp = start_overall_bp
    @stop_overall_bp = stop_overall_bp
    @range_overall_bp = Range.new(@start_overall_bp, @stop_overall_bp)
    @start_pixel = start_pixel
    @stop_pixel = stop_pixel
    @range_overall_pixel = Range.new(@start_pixel, @stop_pixel)
    @resolution = (@stop_overall_bp - @start_overall_bp).to_f/(@stop_pixel - @start_pixel)
    @formatted_resolution = ''
    if @resolution < 1000
      @formatted_resolution = sprintf("%.2f", @resolution) + ' bp/pixel'
    elsif @resolution < 1_000_000
      @formatted_resolution = sprintf("%.2f", (@resolution.to_f/1000)) + ' kb/pixel'
    else
      @formatted_resolution = sprintf("%.2f", (@resolution.to_f/1_000_000)) + ' Mb/pixel'
    end
    STDERR.puts [@resolution, @formatted_resolution].join("\t")
  end

  def to_s
    output = Array.new
    output.push('-----')
    output.push("START BP=" + @start_overall_bp.to_s)
    output.push("STOP BP=" + @stop_overall_bp.to_s)
    output.push("START PIXEL=" + @start_pixel.to_s)
    output.push("STOP PIXEL=" + @stop_pixel.to_s)
    output.push("RESOLUTION=" + @resolution.to_s + " bp/pixel")
    return output.join("\n")
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
