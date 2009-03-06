class ReadPair
  attr_accessor :reads
  attr_accessor :code
  
  def initialize(from_chr, from_pos, to_chr, to_pos, code)
    @reads = Array.new
    @reads.push(Read.new(from_chr, from_pos, self))
    @reads.push(Read.new(to_chr, to_pos, self))
  end
end