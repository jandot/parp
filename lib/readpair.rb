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

  def draw(buffer)
    buffer.no_fill
    buffer.stroke 200
    if @code == 'DIST'
      buffer.stroke 255,0,0,50
    elsif @code == 'FF'
      buffer.stroke 0,0,255,200
    elsif @code == 'RF'
      buffer.stroke 0,255,0,200
    end
    buffer.stroke_weight 0.5

    distance_from_circle = nil
    bezier_distance = nil

    if ( @reads[0].chr == @reads[1].chr )
      distance_from_circle = 50
      bezier_distance = 20
    else
      distance_from_circle = 80
      bezier_distance = 50
    end
    buffer.bezier(self.class.sketch.cx(@reads[0].degree, self.class.sketch.radius - distance_from_circle),
                  self.class.sketch.cy(@reads[0].degree, self.class.sketch.radius - distance_from_circle),
                  self.class.sketch.cx(@reads[0].degree, self.class.sketch.radius - distance_from_circle - bezier_distance),
                  self.class.sketch.cy(@reads[0].degree, self.class.sketch.radius - distance_from_circle - bezier_distance),
                  self.class.sketch.cx(@reads[1].degree, self.class.sketch.radius - distance_from_circle - bezier_distance),
                  self.class.sketch.cy(@reads[1].degree, self.class.sketch.radius - distance_from_circle - bezier_distance),
                  self.class.sketch.cx(@reads[1].degree, self.class.sketch.radius - distance_from_circle),
                  self.class.sketch.cy(@reads[1].degree, self.class.sketch.radius - distance_from_circle))
  end
end