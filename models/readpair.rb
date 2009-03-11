class ReadPair
  attr_accessor :from_chr, :from_pos, :to_chr, :to_pos
  attr_accessor :code, :qual
  attr_accessor :normalized_bp_from, :normalized_bp_to
  attr_accessor :normalized_degree_from, :normalized_degree_to
  attr_accessor :interchromosomal
  
  def initialize(from_chr, from_pos, to_chr, to_pos, code, qual)
    @from_chr = S.chromosomes[from_chr]
    @to_chr = S.chromosomes[to_chr]
    @from_pos, @to_pos, @code, @qual = from_pos.to_i, to_pos.to_i, code, qual.to_i

    @interchromosomal = ( from_chr == to_chr ) ? false : true

    @normalized_bp_from = @from_chr.bp_offset + @from_pos
    @normalized_bp_to = @to_chr.bp_offset + @to_pos
    @normalized_degree_from = (@normalized_bp_from.to_f/GENOME_SIZE)*360
    @normalized_degree_to = (@normalized_bp_to.to_f/GENOME_SIZE)*360
  end

  def draw(b)
    b.no_fill
    b.stroke 200
    b.stroke_weight 0.5
    distance_from_circle = ( @interchromosomal ) ? 80 : 20
    b.bezier(S.cx(@normalized_degree_from, S.radius - distance_from_circle),
             S.cy(@normalized_degree_from, S.radius - distance_from_circle),
             S.cx(@normalized_degree_from, S.radius - distance_from_circle - 50),
             S.cy(@normalized_degree_from, S.radius - distance_from_circle - 50),
             S.cx(@normalized_degree_to, S.radius - distance_from_circle - 50),
             S.cy(@normalized_degree_to, S.radius - distance_from_circle - 50),
             S.cx(@normalized_degree_to, S.radius - distance_from_circle),
             S.cy(@normalized_degree_to, S.radius - distance_from_circle))
  end
end