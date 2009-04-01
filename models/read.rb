class Read
  class << self
    attr_accessor :sketch
  end
  attr_accessor :chr, :pos, :readpair
  attr_accessor :degree
  attr_accessor :slices
  attr_accessor :as_string
  attr_accessor :visible

  def initialize(chr, pos, readpair)
    @chr, @pos = chr, pos.to_i
    @as_string = [@chr.pad('0', 2), @pos.to_s.pad('0', 9)].join('_')
    @readpair = readpair
    @degree = Hash.new
    @slices = Hash.new
    @visible = Hash.new
    self.class.sketch.reads.push(self)
  end

  def self.fetch_region(start, stop) #start and stop must be in 05_000123456 format
    from_index = Read.get_index(start)
    to_index = Read.get_index(stop) - 1
    if to_index >= from_index
      return self.sketch.reads[from_index, to_index - from_index + 1]
    else
      return []
    end
  end

  def self.get_index(value)
    return self.sketch.reads.collect{|r| r.as_string}.bsearch_lower_boundary{|x| x <=> value}
#    return @sketch.reads.collect{|r| r.as_string}.binary_search(value, direction)
  end

  def calculate_degree(display)
    @degree[display] = self.class.sketch.map(@pos, @slices[display].start_bp, @slices[display].stop_bp, @slices[display].start_degree[display], @slices[display].stop_degree[display])
  end

  def to_s
    return @as_string
  end
end