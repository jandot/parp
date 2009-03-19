class Read
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
    S.reads.push(self)
  end

  def self.fetch_region(start, stop) #start and stop must be in 05_000123456 format
    from_index = Read.get_index(start)
    to_index = Read.get_index(stop) - 1
    if to_index >= from_index
      return S.reads[from_index, to_index - from_index + 1]
    else
      return []
    end
  end

  def self.get_index(value)
    return S.reads.collect{|r| r.as_string}.bsearch_lower_boundary{|x| x <=> value}
#    return S.reads.collect{|r| r.as_string}.binary_search(value, direction)
  end

  def calculate_degree(display)
    @degree[display] = S.map(@pos, @slices[display].from_pos, @slices[display].to_pos, @slices[display].start_degree, @slices[display].stop_degree)
  end

  def to_s
    return @as_string
  end
end