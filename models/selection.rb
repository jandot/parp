class Selection
  attr_accessor :start_overview_degree, :stop_overview_degree
  attr_accessor :degree_offset, :bp_offset
  attr_accessor :chr, :start_pos, :stop_pos
  attr_accessor :length
  attr_accessor :slice
  attr_accessor :label

  def initialize(start_degree, stop_degree, chr, start_pos, stop_pos, label)
    @start_overview_degree, @stop_overview_degree = start_degree, stop_degree
    @chr, @start_pos, @stop_pos = chr, start_pos, stop_pos
    @length = ((@stop_overview_degree - @start_overview_degree).to_f/360)*GENOME_SIZE.to_i
    @label = label

    offset = S.displays[:detail].bp_length
    @slice = Slice.new(@chr, @start_pos, @stop_pos, S.displays[:detail])
    @slice.bp_offset = offset
    @slice.label = @label
  end
  
#  def slice(display)
#    offset = display.bp_length
#    slice = Slice.new(@chr, @start_pos, @stop_pos, display)
#    slice.label = self.name
#    slice.bp_offset = offset
#    return slice
#  end
end