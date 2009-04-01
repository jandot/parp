require 'rubygems'
require 'ruby-processing'
require 'yaml'
require 'bsearch'

WORKING_DIRECTORY = '/Users/ja8/LocalDocuments/Projects/pARP'
FILE_CHROMOSOME_METADATA = WORKING_DIRECTORY + '/data/meta_data.tsv'
#FILE_READPAIRS = WORKING_DIRECTORY + '/data/data.tsv'
#FILE_READPAIRS = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/NCI-H2171/read_pairs.parsed'
FILE_READPAIRS = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/COLO-829/read_pairs.parsed'
#FILE_READPAIRS = WORKING_DIRECTORY + '/data/small_dataset.tsv'
#FILE_COPY_NUMBER = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/NCI-H2171/copy_number_segmented.txt'
FILE_COPY_NUMBER = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/COLO-829/copy_number_segmented.txt'
FILE_SEGDUPS = WORKING_DIRECTORY + '/data/features.tsv'

WIDTH = 1200
HEIGHT = 600

SPACER = 20000000 # spacer in bp between chromosomes and sections

GENOME_SIZE = 3080419000

Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }

class MySketch < Processing::App
  attr_accessor :f
  attr_accessor :chromosomes, :readpairs, :reads
  attr_accessor :radius, :diameter
  attr_accessor :creating_new_selection
  attr_accessor :image_overview, :image_detail, :image_information
  attr_accessor :selection_start_degree, :selection_start
  attr_accessor :active_display, :origin_x, :origin_y
  attr_accessor :chromosome_under_mouse, :pos_under_mouse
  attr_accessor :formatted_position
  attr_accessor :displays, :selections
  attr_accessor :active_slice
  attr_accessor :next_selection_label
  attr_accessor :min_qual, :max_qual, :qual_cutoff
  attr_accessor :copy_numbers, :segdups

  def setup
    @diameter = 400
    @radius = @diameter/2
    
    @origin_x = width/4
    @origin_y = height/2

    @formatted_position = ''
    @displays = Hash.new
    @selections = Array.new
    @next_selection_label = 'A'

    @f = create_font("Arial", 12)
    text_font @f
    
    Chromosome.sketch = self
    ReadPair.sketch = self
    Read.sketch = self
    SegDup.sketch = self
    CopyNumber.sketch = self
    Slice.sketch = self
    Display.sketch = self

    self.load_chromosomes
    self.load_readpairs
    self.load_copy_numbers
    self.load_segdups

    @qual_cutoff = ((@min_qual + @max_qual)/2).ceil
    
    @displays[:overview] = Display.new(:overview, width/4, height/2)
    @displays[:detail] = Display.new(:detail, width/4, height/2)
    self.add_chromosomes_to_overview_display
    self.draw_overview_display
    self.draw_detail_display

    @active_display = @displays[:overview]
    smooth
    no_loop
  end

  def load_chromosomes
    @chromosomes = Hash.new
    File.open(FILE_CHROMOSOME_METADATA).each do |line|
      chr, len, centr_start, centr_stop = line.chomp.split("\t")
      @chromosomes[chr] = Chromosome.new(chr, len.to_i, centr_start.to_i)
    end
  end

  def load_readpairs
    @reads = Array.new
    @readpairs = Array.new
    File.open(FILE_READPAIRS).each do |line|
      from_chr, from_pos, to_chr, to_pos, code, qual = line.chomp.split("\t")
      @readpairs.push(ReadPair.new(from_chr, from_pos, to_chr, to_pos, code, qual))
    end
    @reads = @reads.sort_by{|r| r.as_string}
    all_qualities = @readpairs.collect{|rp| rp.qual}
    @min_qual = all_qualities.min
    @max_qual = all_qualities.max
  end

  def load_copy_numbers
    @copy_numbers = Array.new
    File.open(FILE_COPY_NUMBER).each do |line|
      chr, start, stop, value = line.chomp.split("\t")
      @copy_numbers.push(CopyNumber.new(chr, start, stop, value))
    end
    @copy_numbers = @copy_numbers.sort_by{|cn| cn.as_string}
  end

  def load_segdups
    @segdups = Array.new
    File.open(FILE_SEGDUPS).each do |line|
      chr, start, stop = line.chomp.split("\t")
      @segdups.push(SegDup.new(chr, start, stop))
    end
    @segdups = @segdups.sort_by{|sd| sd.as_string}
  end

  def add_chromosomes_to_overview_display
    @chromosomes.values.each do |chr|
      chr.slice(@displays[:overview])
    end
  end

  def draw
    background 255

    self.draw_information_display
    image(@image_overview,0,0)
    image(@image_detail, width/2, 0)
    image(@image_information, width/2-100, 10)

    #Selections
    no_stroke
    @displays[:detail].slices.each do |s|
      pline(s.start_degree[@displays[:overview]], s.stop_degree[@displays[:overview]], @diameter+100, width/4, height/2, :fill => color(0,0,255,50))
      fill 0
      text(s.label, cx((s.start_degree[@displays[:overview]]+s.stop_degree[@displays[:overview]]).to_f/2, @radius + 60, width/4), cy((s.start_degree[@displays[:overview]]+s.stop_degree[@displays[:overview]]).to_f/2, @radius + 60, height/2))
    end

    #Line following mouse
    stroke 100
    line @origin_x, @origin_y, cx(angle(mouse_x, mouse_y, @origin_x, @origin_y), @radius + 50, @origin_x), cy(angle(mouse_x, mouse_y, @origin_x, @origin_y), @radius + 50, @origin_y)

    #Selection being drawn (green)
    if @creating_new_selection
      fill 0,255,0,50
      no_stroke
      start_degree, stop_degree = [@selection_start_degree, angle(mouse_x, mouse_y, @origin_x, @origin_y)].sort
      pline(start_degree, stop_degree, @diameter+100, @origin_x, @origin_y, :fill => color(0,255,0,50))
      fill 0
    end
  end

  def draw_overview_display
    buffer_overview = buffer(self.width/2, self.height, JAVA2D) do |b|
      b.background 255
      b.text_font @f
      b.text_align CENTER
      b.smooth

      b.translate(self.width.to_f/4, self.height.to_f/2)
      @displays[:overview].draw(b)
      b.translate(self.width.to_f/4, self.height.to_f/2)
    end
    @image_overview = buffer_overview.get(0, 0, buffer_overview.width, buffer_overview.height)
  end

  def draw_detail_display
    buffer_detail = buffer(self.width/2, self.height, JAVA2D) do |b|
      b.background 255
      b.text_font @f
      b.text_align CENTER
      b.smooth

      b.translate(self.width.to_f/4, self.height.to_f/2)
      @displays[:detail].draw(b)
      b.translate(self.width.to_f/4, self.height.to_f/2)
    end
    @image_detail = buffer_detail.get(0,0,buffer_detail.width, buffer_detail.height)
  end

  def draw_information_display
    buffer_information = buffer(200,200,JAVA2D) do |b|
      b.background 220
      b.text_font @f
      b.text_align LEFT
      b.smooth

      b.fill 0
      b.text "Mouse position: " + @formatted_position, 10, 10 + text_ascent
      b.text "Quality score cutoff: " + @qual_cutoff.to_s, 10, 10+2*(text_ascent+2)
      b.text "Active display: " + @active_display.name.to_s, 10, 10 + 3*(text_ascent+2)
      b.text "Selections:", 10, 10 + 4*(text_ascent+2)
      counter = 0
      @displays[:detail].slices.each do |slice|
        counter += 1
        b.text "  " + slice.label + ": " + slice.formatted_position[@displays[:detail]],
          20, 10 + (4+counter)*(text_ascent+2)
      end
    end
    @image_information = buffer_information.get(0,0,buffer_information.width, buffer_information.height)
  end

  # cx is the x coordinate for a point on a circle
  def cx(alpha, r, origin_x = 0)
    return r*cos(MySketch.radians(alpha)) + origin_x
  end
  def cy(alpha, r, origin_y = 0)
    return r*sin(MySketch.radians(alpha)) + origin_y
  end
  
  def pline(alpha1, alpha2, r, origin_x = 0, origin_y = 0, args = {})
    if args[:fill].nil? or args[:fill] == false
      no_fill
    else
      fill args[:fill]
    end
    if args[:buffer].nil?
#      STDERR.puts '-------------'
#      STDERR.puts origin_x
#      STDERR.puts origin_y
#      STDERR.puts r
#      STDERR.puts alpha1
#      STDERR.puts alpha2
      return arc origin_x, origin_y, r, r, MySketch.radians(alpha1), MySketch.radians(alpha2)
    else
      return args[:buffer].arc origin_x, origin_y, r, r, MySketch.radians(alpha1), MySketch.radians(alpha2)
    end
  end

  def angle(x = mouse_x, y = mouse_y, origin_x = 0, origin_y = 0)
    alpha = 0
    if ( x <= origin_x ) and ( y > origin_y )# II
      theta = atan((origin_x - x).to_f/(y - origin_y).to_f)
      alpha = 90 + MySketch.degrees(theta)
    elsif ( x < origin_x ) and ( y <= origin_y ) # III
      theta = atan((origin_y - y).to_f/(origin_x - x).to_f)
      alpha = 180 + MySketch.degrees(theta)
    elsif ( x >= origin_x ) and ( y < origin_y) # IV
      theta = atan((x - origin_x).to_f/(origin_y - y).to_f)
      alpha = 270 + MySketch.degrees(theta)
    else # I
      theta = atan((y - origin_y).to_f/(x - origin_x).to_f)
      alpha = MySketch.degrees(theta)
    end
    return alpha
  end

  def calculate_position_under_mouse
    a = angle(mouse_x, mouse_y, @origin_x, @origin_y)
    b = map(a, 0, 360, 0, @active_display.length_bp)

    running_position = 0
    @active_display.slices.each do |slice|
      running_position += slice.length_bp
      if running_position >= b
        @active_slice = slice
        break
      end
    end

    chromosome_under_mouse = @active_slice.chr
    pos_under_mouse = (b - @active_slice.bp_offset + @active_slice.start_bp).to_i

    return [chromosome_under_mouse, pos_under_mouse]
  end

  def mouse_pressed
    if ( @active_display == @displays[:overview] )
      @selection_start_degree = angle(mouse_x, mouse_y, @origin_x, @origin_y)
      @chromosomes.values.sort_by{|c| c.name.to_i}.each do |chr|
        if chr.degree_offset < @selection_start_degree
          @start_selection_chr = chr.degree_offset
        end
      end
      under_mouse = self.calculate_position_under_mouse
      @selection_start_chromosome = under_mouse[0]
      @selection_start_pos = under_mouse[1]
    else # We're initiating a zoom on the detail
      @dragging_start_degree = angle(mouse_x, mouse_y, @origin_x, @origin_y)
      @dragging_start_radius = dist(mouse_x, mouse_y, @origin_x, @origin_y)
    end
  end

  def mouse_moved
    @active_display = ( mouse_x < width/2 ) ? @displays[:overview] : @displays[:detail]
    if ( @active_display == @displays[:overview] )
      @origin_x = width/4
    else
      @origin_x = 3*width/4
    end

    if @active_display == @displays[:overview] or ( @active_display == @displays[:detail] and @active_display.slices.length > 0 )
      under_mouse = self.calculate_position_under_mouse
      @chromosome_under_mouse = under_mouse[0]
      @pos_under_mouse = under_mouse[1]
      @formatted_position = @chromosome_under_mouse.name + ':' + @pos_under_mouse.format
      redraw
    end
  end

  def mouse_dragged
    under_mouse = self.calculate_position_under_mouse
    if @active_display == @displays[:overview]
      @creating_new_selection = true
      @chromosome_under_mouse = under_mouse[0]
      @pos_under_mouse = under_mouse[1]
      @formatted_position = @chromosome_under_mouse.name + ':' + @pos_under_mouse.format
    end
    redraw
  end

  def mouse_released
    under_mouse = self.calculate_position_under_mouse
    if @active_display == @displays[:overview]
      under_mouse = self.calculate_position_under_mouse
      start_degree, stop_degree = [@selection_start_degree, angle(mouse_x, mouse_y, @origin_x, @origin_y)].sort
      start_pos, stop_pos = [@selection_start_pos, under_mouse[1]].sort
      
      slice = Slice.new(@selection_start_chromosome, start_pos, stop_pos, @displays[:detail],
                        @next_selection_label.clone) #FIXME: I don't understand why I have to use clone here.
      slice.start_degree[@displays[:overview]] = start_degree
      slice.stop_degree[@displays[:overview]] = stop_degree
      @selection_start = nil

      @next_selection_label.succ!
      @creating_new_selection = false
      self.draw_detail_display
#    else
#      #TODO: center of zooming should not be center of slice, but start degree of mouse
#        #Taking zooming of 2x for 100px => /50
#        slice_center = slice.start_bp + slice.length_bp/2
#        slice.length_bp = map(@dragging_radius, 0, @dragging_start_radius, 0, slice.length_bp)
#        slice.start_bp = slice_center - (slice.length_bp/2).to_i
#        slice.stop_bp = slice_center + (slice.length_bp/2).to_i
#
#        from_pos_string = ( slice.chr.name.length == 1) ? '0' + slice.chr.name : slice.chr.name
#        from_pos_string += '_' + slice.start_bp.to_s.pad('0', 9)
#        to_pos_string = ( slice.chr.name.length == 1) ? '0' + slice.chr.name : slice.chr.name
#        to_pos_string += '_' + slice.stop_bp.to_s.pad('0', 9)
#        slice.fetch_reads(from_pos_string, to_pos_string)
#        slice.fetch_copy_numbers(from_pos_string, to_pos_string)
#
#        slice.calculate_degree(S.displays[:overview], nil, false)
#        self.draw_detail_display
#      end
    end
    redraw
  end

  def key_pressed
    if key == 'r'
      @selections = Array.new
      @next_selection_label = 'A'
      @displays[:detail] = Display.new(:detail, width/4, height/2)
      self.draw_detail_display
      redraw
    elsif key == 'i' or key == 'o' #zooming
      @displays[:detail].slices.each_with_index do |slice,i|
        slice_center = slice.start_bp + slice.length_bp/2
        if key == 'i'
          slice.start_bp = [0, slice_center - (slice.length_bp/4).to_i].max
          slice.stop_bp = [slice_center + (slice.length_bp/4).to_i, slice.chr.length].min
        else
          slice.start_bp = [0,slice_center - (3*slice.length_bp/4).to_i].max
          slice.stop_bp = [slice_center + (3*slice.length_bp/4).to_i, slice.chr.length].min
        end
        if slice.start_bp > slice.stop_bp
          slice.start_bp, slice.stop_bp = slice.stop_bp, slice.start_bp
        end
        slice.length_bp = slice.stop_bp - slice.start_bp
        slice.calculate_degree(S.displays[:overview], nil, false)

        from_pos_string = ( slice.chr.name.length == 1) ? '0' + slice.chr.name : slice.chr.name
        from_pos_string += '_' + slice.start_bp.to_s.pad('0', 9)
        to_pos_string = ( slice.chr.name.length == 1) ? '0' + slice.chr.name : slice.chr.name
        to_pos_string += '_' + slice.stop_bp.to_s.pad('0', 9)
        slice.fetch_reads(from_pos_string, to_pos_string)
        slice.fetch_copy_numbers(from_pos_string, to_pos_string)
        slice.fetch_segdups(from_pos_string, to_pos_string)
      end
      self.draw_detail_display
      redraw
    elsif key_code
      if key_code == UP and @qual_cutoff < @max_qual
        @qual_cutoff += 1
      elsif key_code == DOWN and @qual_cutoff > @min_qual
        @qual_cutoff -= 1
      end
      self.draw_overview_display
      self.draw_detail_display
      redraw
    end
  end
end


S = MySketch.new :title => "My Sketch", :width => WIDTH, :height => HEIGHT
