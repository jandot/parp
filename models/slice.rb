class Slice
  class << self
    attr_accessor :sketch
  end
  attr_accessor :display #either :overview or :detail -> will know left or right
  attr_accessor :chr, :start_bp, :stop_bp
  attr_accessor :start_degree, :stop_degree
  attr_accessor :length_bp, :length_degree
  attr_accessor :bp_offset
  attr_accessor :reads
  attr_accessor :label
  attr_accessor :formatted_position
  attr_accessor :copy_numbers
  attr_accessor :segdups

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
    @reads = Array.new
    
    start_bp_string = ( @chr.name.length == 1) ? '0' + @chr.name : @chr.name
    start_bp_string += '_' + @start_bp.to_s.pad('0', 9)
    stop_bp_string = ( @chr.name.length == 1) ? '0' + @chr.name : @chr.name
    stop_bp_string += '_' + @stop_bp.to_s.pad('0', 9)

    self.fetch_reads(start_bp_string, stop_bp_string)
    self.fetch_copy_numbers(start_bp_string, stop_bp_string)
    self.fetch_segdups(start_bp_string, stop_bp_string)
    
    @display.slices.push(self)

    @display.slices.each_with_index do |s, i|
      s.calculate_degree(@display, i)
    end
  end

  def fetch_reads(from_pos_string, to_pos_string)
    @reads.each do |read|
      read.visible[@display] = false
    end
    @reads = Read.fetch_region(from_pos_string, to_pos_string)
    @reads.each do |read|
      read.slices[@display] = self
      read.visible[@display] = true
    end
  end

  def fetch_copy_numbers(from_pos_string, to_pos_string)
    @copy_numbers = CopyNumber.fetch_region(from_pos_string, to_pos_string)
    @copy_numbers.each do |copy_number|
      copy_number.slices[@display] = self
    end
  end

  def fetch_segdups(from_pos_string, to_pos_string)
    @segdups = SegDup.fetch_region(from_pos_string, to_pos_string)
    @segdups.each do |segdup|
      segdup.slices[@display] = self
    end
  end

  def calculate_degree(display, i = nil)
    @length_degree[display] = self.class.sketch.map(@length_bp, 0, display.length_bp, 0, 360)
    if i.nil?
      @start_degree[self.class.sketch.displays[:overview]] = @chr.degree_offset + self.class.sketch.map(@start_bp, 0, @chr.length, 0, @chr.overview_slice.length_degree[self.class.sketch.displays[:overview]])
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
    self.class.sketch.pline(@start_degree[display], @start_degree[display] + @length_degree[display], self.class.sketch.diameter, 0, 0, :buffer => b)
    b.stroke 0
    b.stroke_weight 1
    b.line(self.class.sketch.cx(@start_degree[display], self.class.sketch.radius - 5), self.class.sketch.cy(@start_degree[display], self.class.sketch.radius - 5), self.class.sketch.cx(@start_degree[display], self.class.sketch.radius + 5), self.class.sketch.cy(@start_degree[display], self.class.sketch.radius + 5))
    if display == self.class.sketch.displays[:detail]
      b.stroke 200
      b.line(0,0, self.class.sketch.cx(@start_degree[display], self.class.sketch.radius + 5), self.class.sketch.cy(@start_degree[display], self.class.sketch.radius + 5))
    end

    # Draw the label
    b.fill 0
    b.no_fill
    b.text_align MySketch::CENTER
    b.text(@label, self.class.sketch.cx(@start_degree[display] + @length_degree[display]/2, self.class.sketch.radius + 15), self.class.sketch.cy(@start_degree[display] + @length_degree[display]/2, self.class.sketch.radius + 15))
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
      self.class.sketch.pline(copy_number.start_degree[display], copy_number.stop_degree[display], self.class.sketch.diameter - 60 + copy_number.value, 0, 0, :buffer => b)
    end

    b.stroke 0,0,255,50
    b.stroke_weight 1

    @segdups.each do |segdup|
      self.class.sketch.pline(segdup.start_degree[display], segdup.stop_degree[display], self.class.sketch.diameter + 10, 0, 0, :buffer => b)
    end

  end
end