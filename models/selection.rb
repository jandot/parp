class Selection
  attr_accessor :start_overview_degree, :stop_overview_degree
  attr_accessor :degree_offset, :bp_offset
  attr_accessor :chr, :start_pos, :stop_pos
  attr_accessor :length
  attr_accessor :slice

  def initialize(start_degree, stop_degree, chr, start_pos, stop_pos)
    @start_overview_degree, @stop_overview_degree = start_degree, stop_degree
    @chr, @start_pos, @stop_pos = chr, start_pos, stop_pos
    @length = ((@stop_overview_degree - @start_overview_degree).to_f/360)*GENOME_SIZE.to_i

    offset = S.displays[:detail].bp_length
    @slice = Slice.new(@chr, @start_pos, @length, S.displays[:detail])
    @slice.bp_offset = offset
  end
  
  def slice(display)
    offset = display.bp_length
    slice = Slice.new(@chr, @start_pos, @stop_pos, display)
    slice.label = self.label
    slice.bp_offset = offset
    return slice
  end

  def label
    return @chr.name + ':' + @start_pos.to_s + '..' + @stop_pos.to_s
  end
end