class ReadPair
  attr_accessor :code, :qual
  attr_accessor :reads
  attr_accessor :normalized_bp_from, :normalized_bp_to
  attr_accessor :normalized_degree_from, :normalized_degree_to
#  attr_accessor :interchromosomal
  
  def initialize(from_chr, from_pos, to_chr, to_pos, code, qual = 40)
    @reads = Array.new
    @reads.push(Read.new(from_chr, from_pos, self))
    @reads.push(Read.new(to_chr, to_pos, self))
    @code, @qual = code, qual.to_i
    @reads_visible = Hash.new
#    @interchromosomal = ( from_chr == to_chr ) ? false : true
  end


  def draw(b, display)
    if self.visible(display)
      b.no_fill
        b.stroke 200
      if @code == 'DIST'
        b.stroke 255,0,0,200
      elsif @code == 'FF'
        b.stroke 0,0,255,200
      elsif @code == 'RF'
        b.stroke 0,255,0,200
      end
      b.stroke_weight 0.5

      distance_from_circle = nil
      bezier_distance = nil

      if ( @reads[0].slices[display] == @reads[1].slices[display] )
        distance_from_circle = 50
        bezier_distance = 20
      else
        distance_from_circle = 80
        bezier_distance = 50
      end
      b.bezier(S.cx(@reads[0].degree[display], S.radius - distance_from_circle),
               S.cy(@reads[0].degree[display], S.radius - distance_from_circle),
               S.cx(@reads[0].degree[display], S.radius - distance_from_circle - bezier_distance),
               S.cy(@reads[0].degree[display], S.radius - distance_from_circle - bezier_distance),
               S.cx(@reads[1].degree[display], S.radius - distance_from_circle - bezier_distance),
               S.cy(@reads[1].degree[display], S.radius - distance_from_circle - bezier_distance),
               S.cx(@reads[1].degree[display], S.radius - distance_from_circle),
               S.cy(@reads[1].degree[display], S.radius - distance_from_circle))
    end
  end

  def visible(display)
    if @reads[0].visible[display] and @reads[1].visible[display]
      return true
    else
      return false
    end
  end

  def to_s
    return @reads[0].as_string + "\t" + @reads[1].as_string
  end
end