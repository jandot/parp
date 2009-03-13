class Chromosome
  attr_accessor :name, :length, :centromere
  attr_accessor :readpairs
  attr_accessor :normalized_length, :normalized_centromere #to 360 TODO: move this to slice
  attr_accessor :bp_offset, :degree_offset # TODO: move this to slice

  def initialize(name, length, centr)
    @name, @length, @centromere = name, length, centr
    @normalized_length = (@length.to_f/GENOME_SIZE)*360
    @normalized_centromere = (@centromere.to_f/GENOME_SIZE)*360
    if @name == '1'
      @bp_offset, @degree_offset = 0, 0
    else
      prev_chr = S.chromosomes[(@name.to_i - 1).to_s]
      @bp_offset = prev_chr.bp_offset + prev_chr.length
      @degree_offset = prev_chr.degree_offset + prev_chr.normalized_length
    end
  end

  def slice(display)
    offset = display.bp_length
    slice = Slice.new(self, 0, @length, display)
    slice.bp_offset = offset
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
    S.pline(offset, offset + @normalized_length, S.diameter, 0, 0, :buffer => b)

    b.fill 0
    b.no_stroke
    b.ellipse(S.cx(@normalized_centromere + offset, S.radius), S.cy(@normalized_centromere + offset, S.radius),5,5)
    b.text_align MySketch::CENTER
    b.text(@name, S.cx(@normalized_centromere + offset, S.radius + 15), S.cy(@normalized_centromere + offset, S.radius + 15))
    b.text_align MySketch::LEFT
  end
end