class SegDup
  include IsLocus

  class << self
    attr_accessor :sketch
  end

  attr_accessor :chr, :start, :stop
  attr_accessor :as_string
  attr_accessor :start_degree, :stop_degree

  def initialize(chr, start, stop)
    @chr = self.class.sketch.chromosomes[chr]
    @start, @stop = start.to_i, stop.to_i
    @as_string = [chr.pad('0', 2), @start.to_s.pad('0', 9), @stop.to_s.pad('0', 9)].join('_')
    self.class.sketch.chromosomes[chr].segdups.push(self)
  end
end