class Slice
  class << self
    attr_accessor :sketch
  end
#  attr_accessor :start_chr, :start_bp, :stop_chr, :stop_bp
  attr_accessor :start_overall_bp, :stop_overall_bp, :range_overall_bp #counting over the whole genome
  attr_accessor :start_pixel, :stop_pixel, :range_pixel
  attr_accessor :resolution #in bp/pixel

  def initialize(start_overall_bp = 0, stop_overall_bp = GENOME_SIZE, start_pixel = 0, stop_pixel = self.class.sketch.circumference)
    @start_overall_bp = start_overall_bp
    @stop_overall_bp = stop_overall_bp
    @range_overall_bp = Range.new(@start_overall_bp, @stop_overall_bp)
    @start_pixel = start_pixel
    @stop_pixel = stop_pixel
    @range_overall_pixel = Range.new(@start_pixel, @stop_pixel)
    @resolution = (@stop_overall_bp - @start_overall_bp).to_f/(@stop_pixel - @start_pixel)
#    STDERR.puts "DEBUG: slice with resolution " + @resolution.to_s
  end
end