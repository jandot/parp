class CopyNumber
  include IsLocus
  
  class << self
    attr_accessor :sketch
  end
  attr_accessor :chr, :start, :stop, :original_value, :value
  attr_accessor :as_string
  attr_accessor :start_degree, :stop_degree
  attr_accessor :slices
  
  def initialize(chr, start, stop, value)
    @chr = chr
    @start, @stop = start.to_i, stop.to_i
    @original_value = value.to_f
    @value = self.class.sketch.map(@original_value.to_f, 0, 382, 0, 80)
    @as_string = [@chr.pad('0', 2), @start.to_s.pad('0', 9), @stop.to_s.pad('0', 9)].join('_')
    @start_degree = Hash.new
    @stop_degree = Hash.new
    @slices = Hash.new
    self.class.sketch.copy_numbers.push(self)
  end

  def self.fetch_region(start, stop) #start and stop must be in 05_000123456 format
    from_index = CopyNumber.get_index(start)
    to_index = CopyNumber.get_index(stop) - 1
    if to_index >= from_index
      return self.sketch.copy_numbers[[0, from_index - 1].max, to_index - from_index + 2]
    else
      return []
    end
  end

  def self.get_index(value)
    return self.sketch.copy_numbers.collect{|r| r.as_string}.bsearch_lower_boundary{|x| x <=> value}
  end

  def to_s
    return @as_string
  end
end