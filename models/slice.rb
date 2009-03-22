class Slice
  attr_accessor :display #either :overview or :detail -> will know left or right
  attr_accessor :chr, :start_bp, :stop_bp
  attr_accessor :start_degree, :stop_degree
  attr_accessor :length_bp, :length_degree
  attr_accessor :bp_offset
  attr_accessor :reads
  attr_accessor :label
  attr_accessor :formatted_position
  attr_accessor :copy_numbers

  def initialize(chr, start_bp, stop_bp, display, label = '')
    @chr, @start_bp, @stop_bp, @display = chr, start_bp, stop_bp, display
    @length_bp = @stop_bp - @start_bp + 1
    @display.length_bp += @length_bp
    @label = label
    @formatted_position = Hash.new
    @formatted_position[display] = @chr.name + ':' + @start_bp.format + ".." + @stop_bp.format
    @start_degree = Hash.new
    @stop_degree = Hash.new
    @length_degree = Hash.new
    
    start_bp_string = ( @chr.name.length == 1) ? '0' + @chr.name : @chr.name
    start_bp_string += '_' + @start_bp.to_s.pad('0', 9)
    stop_bp_string = ( @chr.name.length == 1) ? '0' + @chr.name : @chr.name
    stop_bp_string += '_' + @stop_bp.to_s.pad('0', 9)

    self.fetch_reads(start_bp_string, stop_bp_string)
    self.fetch_copy_numbers(start_bp_string, stop_bp_string)
    
    @display.add_slice(self)
  end

  def fetch_reads(from_pos_string, to_pos_string)
    @reads = Read.fetch_region(from_pos_string, to_pos_string)
    @reads.each do |read|
      read.slices[@display] = self
    end
  end

  def fetch_copy_numbers(from_pos_string, to_pos_string)
    @copy_numbers = CopyNumber.fetch_region(from_pos_string, to_pos_string)
    @copy_numbers.each do |copy_number|
      copy_number.slices[@display] = self
    end
  end

  def calculate_degree(display, i = nil, dependent = true)
    @length_degree[display] = S.map(@length_bp, 0, display.length_bp, 0, 360)
    if i.nil?
      @start_degree[S.displays[:overview]] = @chr.degree_offset + S.map(@start_bp, 0, @chr.length, 0, @chr.overview_slice.length_degree[S.displays[:overview]])
    else
      if i == 0
        @bp_offset = 0
        @start_degree[display] = 0
      else
        @bp_offset = @display.slices[i-1].bp_offset + @display.slices[i-1].length_bp
        @start_degree[display] = @display.slices[i-1].start_degree[display] + @display.slices[i-1].length_degree[display]
      end
    end
    @stop_degree[display] = @start_degree[display] + @length_degree[display]
  end
  
  def draw(b, display, index = 0)
    # Draw the curve
    b.no_fill
    b.stroke_weight 3
    if index % 2 == 0
      b.stroke 0
    else
      b.stroke 150
    end
    S.pline(@start_degree[display], @start_degree[display] + @length_degree[display], S.diameter, 0, 0, :buffer => b)
    b.stroke 0
    b.stroke_weight 1
    b.line(S.cx(@start_degree[display], S.radius - 5), S.cy(@start_degree[display], S.radius - 5), S.cx(@start_degree[display], S.radius + 5), S.cy(@start_degree[display], S.radius + 5))

    # Draw the label
    b.fill 0
    b.no_fill
    b.text_align MySketch::CENTER
    b.text(@label, S.cx(@start_degree[display] + @length_degree[display]/2, S.radius + 15), S.cy(@start_degree[display] + @length_degree[display]/2, S.radius + 15))
    b.text_align MySketch::LEFT

    @copy_numbers.each do |copy_number|
      if copy_number.original_value < 20
        b.stroke 255,0,0
        b.stroke_weight 2
      elsif copy_number.original_value > 60
        b.stroke 0,255,0
        b.stroke_weight 2
      else
        b.stroke 0
        b.stroke_weight 0.5
      end
      S.pline(copy_number.start_degree[display], copy_number.stop_degree[display], S.diameter - 60 + copy_number.value, 0, 0, :buffer => b)
    end
  end
end