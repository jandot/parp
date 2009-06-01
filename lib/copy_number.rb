class CopyNumber
  include IsLocus

  class << self
    attr_accessor :sketch
  end

  attr_accessor :chr, :start, :stop, :value, :original_value
#  attr_accessor :start_overall_bp, :stop_overall_bp
  attr_accessor :as_string
  attr_accessor :start_degree, :stop_degree
  attr_accessor :start_pixel, :stop_pixel
#  attr_accessor :start_degree_through_lenses, :stop_degree_through_lenses

  def initialize(chr, start, stop, value)
    @chr = self.class.sketch.chromosomes[chr]
    @start, @stop = start.to_i, stop.to_i
    @original_value = value.to_f
    @value = self.class.sketch.map(@original_value.to_f, 0, 382, 0, 80)
    @as_string = [chr.pad('0', 2), @start.to_s.pad('0', 9), @stop.to_s.pad('0', 9)].join('_')
    self.class.sketch.chromosomes[chr].copy_numbers.push(self)
  end
end