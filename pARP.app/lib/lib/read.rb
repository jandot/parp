class Read
  include IsLocus
  
  class << self
    attr_accessor :sketch
  end

  attr_accessor :chr, :pos, :readpair
  attr_accessor :pixel
  attr_accessor :degree
#  attr_accessor :degree_through_lenses

  attr_accessor :as_string

  def initialize(chr, pos, readpair)
    @chr, @pos = self.class.sketch.chromosomes[chr], pos.to_i
    @as_string = [chr.pad('0', 2), @pos.to_s.pad('0', 9)].join('_')
    @readpair = readpair
    self.class.sketch.chromosomes[chr].reads.push(self)
  end

  def to_s
    return [@chr.name, @pos].join(":")
  end

end