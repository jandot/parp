class Chromosome
  class << self
    attr_accessor :sketch
  end
  attr_accessor :name, :length, :centromere
  attr_accessor :readpairs
  attr_accessor :normalized_length, :normalized_centromere #to 360 TODO: move this to slice
  attr_accessor :bp_offset, :degree_offset # TODO: move this to slice
  attr_accessor :copy_numbers
  attr_accessor :overview_slice

  def initialize(name, length, centr)
    @name, @length, @centromere = name, length, centr
    @normalized_length = (@length.to_f/GENOME_SIZE)*360
    @normalized_centromere = (@centromere.to_f/GENOME_SIZE)*360
    if @name == '1'
      @bp_offset, @degree_offset = 0, 0
    else
      prev_chr = self.class.sketch.chromosomes[(@name.to_i - 1).to_s]
      @bp_offset = prev_chr.bp_offset + prev_chr.length
      @degree_offset = prev_chr.degree_offset + prev_chr.normalized_length
    end
  end

  def slice(display)
    offset = display.length_bp
    slice = Slice.new(self, 0, @length, display)
    slice.label = self.name
    slice.bp_offset = offset
    if display == self.class.sketch.displays[:overview]
      @overview_slice = slice
    end
    return slice
  end

  def draw(b, offset = 0, display = :overview)
    b.no_fill
    b.stroke_weight 3
    if @name.to_i % 2 == 0
      b.stroke 0
    else
      b.stroke 150
    end
    self.class.sketch.pline(offset, offset + @normalized_length, self.class.sketch.diameter, 0, 0, :buffer => b)

    b.fill 0
    b.no_stroke
    b.ellipse(self.class.sketch.cx(@normalized_centromere + offset, self.class.sketch.radius), self.class.sketch.cy(@normalized_centromere + offset, self.class.sketch.radius),5,5)
    b.text_align MySketch::CENTER
    b.text(@name, self.class.sketch.cx(@normalized_centromere + offset, self.class.sketch.radius + 15), self.class.sketch.cy(@normalized_centromere + offset, self.class.sketch.radius + 15))
    b.text_align MySketch::LEFT
  end
end