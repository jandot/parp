class Slice
  attr_accessor :display #either :overview or :detail -> will know left or right
  attr_accessor :chr, :from_pos, :to_pos
  attr_accessor :length, :normalized_length
  attr_accessor :bp_offset, :degree_offset
  attr_accessor :reads
  attr_accessor :selections
  attr_accessor :label
  attr_accessor :formatted_position

  def initialize(chr, from_pos, to_pos, display)
    @chr, @from_pos, @to_pos, @display = chr, from_pos, to_pos, display
    @length = @to_pos - @from_pos + 1
    @display.bp_length += @length
    @label = ''
    @formatted_position = @chr.name + ':' + @from_pos.format + ".." + @to_pos.format

    from_pos_string = ( @chr.name.length == 1) ? '0' + @chr.name : @chr.name
    from_pos_string += '_' + @from_pos.to_s.pad('0', 9)
    to_pos_string = ( @chr.name.length == 1) ? '0' + @chr.name : @chr.name
    to_pos_string += '_' + @to_pos.to_s.pad('0', 9)

    @reads = Read.fetch_region(from_pos_string, to_pos_string)
    @reads.each do |read|
      read.slices[display] = self
    end

    @display.add_slice(self)
  end

  def calculate_degree(total_bp_length, i)
    @normalized_length = (@length.to_f/total_bp_length)*360
    if i == 0
      @bp_offset = 0
      @degree_offset = 0
    else
      @bp_offset = @display.slices[i-1].bp_offset + @display.slices[i-1].length
      @degree_offset = @display.slices[i-1].degree_offset + @display.slices[i-1].normalized_length
    end
  end
  
  def draw(b, index = 0)
    # Draw the curve
    b.no_fill
    b.stroke_weight 3
    if index % 2 == 0
      b.stroke 0
    else
      b.stroke 150
    end
    S.pline(@degree_offset, @degree_offset + @normalized_length, S.diameter, 0, 0, :buffer => b)
    b.stroke 0
    b.stroke_weight 1
    b.line(S.cx(@degree_offset, S.radius - 5), S.cy(@degree_offset, S.radius - 5), S.cx(@degree_offset, S.radius + 5), S.cy(@degree_offset, S.radius + 5))

    # Draw the label
    b.fill 0
    b.no_fill
    b.text_align MySketch::CENTER
    b.text(@label, S.cx(@degree_offset + @normalized_length/2, S.radius + 15), S.cy(@degree_offset + @normalized_length/2, S.radius + 15))
    b.text_align MySketch::LEFT
  end
end