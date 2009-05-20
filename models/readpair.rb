class ReadPair
  class << self
    attr_accessor :sketch
  end
  attr_accessor :reads
  attr_accessor :code, :qual

  def initialize(from_chr, from_pos, to_chr, to_pos, code, qual = 40)
    @reads = Array.new
    @reads.push(Read.new(from_chr, from_pos, self))
    @reads.push(Read.new(to_chr, to_pos, self))
    @code, @qual = code, qual.to_i
  end
end