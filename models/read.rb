class Read
  attr_accessor :chr, :pos, :pair
  attr_accessor :as_string

  def initialize(chr, pos, pair)
    @chr, @pos = chr, pos.to_i
    @as_string = [@chr.pad('0', 2), @pos.to_s.pad('0', 9)].join('_')
    @pair = pair
    S.reads.push(self)
  end

  def self.fetch_region(start, stop) #start and stop must be in 05_000123456 format
    from_index = Read.get_index(start)
    to_index = Read.get_index(stop)
    STDERR.puts [from_index, to_index].join("\t")
    return S.reads[from_index, to_index - from_index]
  end

  def self.get_index(value)
    return S.reads.collect{|r| r.as_string}.binary_search(value, :before)
  end

  def to_s
    return @as_string
  end
end