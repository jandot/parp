class Gene
  include IsLocus

  class << self
    attr_accessor :sketch
  end

  attr_accessor :name
  attr_accessor :chr, :start, :stop
#  attr_accessor :start_cumulative_bp, :stop_cumulative_bp
  attr_accessor :as_string
  attr_accessor :start_degree, :stop_degree
  attr_accessor :start_pixel, :stop_pixel
#  attr_accessor :start_degree_through_lenses, :stop_degree_through_lenses

  def initialize(name, chr, start, stop)
    @name = name
    @chr = self.class.sketch.chromosomes[chr]
    @start, @stop = start.to_i, stop.to_i
    @as_string = [chr.pad('0', 2), @start.to_s.pad('0', 9), @stop.to_s.pad('0', 9)].join('_')
    self.class.sketch.chromosomes[chr].genes.push(self)
  end
end