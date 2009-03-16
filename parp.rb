require 'rubygems'
require 'ruby-processing'
require 'yaml'
require 'bsearch'

WORKING_DIRECTORY = '/Users/ja8/LocalDocuments/Projects/pARP'
FILE_CHROMOSOME_METADATA = WORKING_DIRECTORY + '/data/meta_data.tsv'
#FILE_READPAIRS = WORKING_DIRECTORY + '/data/data.tsv'
FILE_READPAIRS = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/COLO-829/read_pairs.parsed'
FILE_READDEPTH = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/COLO-829/copy_number_selectioned.txt'

WIDTH = 1200
HEIGHT = 600

SPACER = 20000000 # spacer in bp between chromosomes and sections

GENOME_SIZE = 3080419000

Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }

class Integer
  def format
    return self.to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2')
  end
end

class MySketch < Processing::App
  attr_accessor :f
  attr_accessor :chromosomes, :readpairs, :reads
  attr_accessor :radius, :diameter
  attr_accessor :dragging
  attr_accessor :image_overview, :image_detail
  attr_accessor :selection_start_degree, :selection_start
  attr_accessor :active_display, :origin_x, :origin_y
  attr_accessor :chromosome_under_mouse, :pos_under_mouse
  attr_accessor :formatted_position
  attr_accessor :displays, :selections
  attr_accessor :active_slice

  def setup
    @diameter = 400
    @radius = @diameter/2
    
    @active_display = :overview
    @origin_x = width/4
    @origin_y = height/2

    @formatted_position = ''
    @displays = Hash.new
    @selections = Array.new

    @f = create_font("Arial", 12)
    text_font @f
    
    self.load_chromosomes
    self.load_readpairs

    self.draw_overview_display
    self.draw_detail_display

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
  end

  def draw
    background 255

    image(@image_overview,0,0)
    image(@image_detail, width/2, 0)

    #Selections
    no_stroke
    @selections.each do |s|
      pline(s.start_overview_degree, s.stop_overview_degree, @diameter+100, width/4, height/2, :fill => color(0,0,255,50))
    end

    #Line following mouse
    stroke 100
    line @origin_x, @origin_y, cx(angle(mouse_x, mouse_y, @origin_x, @origin_y), @radius + 50, @origin_x), cy(angle(mouse_x, mouse_y, @origin_x, @origin_y), @radius + 50, @origin_y)

    fill 0
    text @formatted_position, 50, 50

    #Selection being drawn (green)
    if @dragging
      fill 0,255,0,50
      no_stroke
      pline(@selection_start_degree, angle(mouse_x, mouse_y, @origin_x, @origin_y), @diameter+100, @origin_x, @origin_y, :fill => color(0,255,0,50))
      fill 0
    end
  end

  def draw_overview_display
    buffer_overview = buffer(self.width/2, self.height, JAVA2D) do |b|
      b.background 255
      b.text_font @f
      b.text_align CENTER
      b.smooth
      
      @displays[:overview] = Display.new(:overview, width/4, height/2)
      @chromosomes.values.each do |chr|
        chr.slice(@displays[:overview])
      end

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

      @displays[:detail] = Display.new(:detail, width/4, height/2)
      @selections.each do |selection|
        selection.slice(@displays[:detail])
      end

      b.translate(self.width.to_f/4, self.height.to_f/2)
      @displays[:detail].draw(b)
      b.translate(self.width.to_f/4, self.height.to_f/2)
    end
    @image_detail = buffer_detail.get(0,0,buffer_detail.width, buffer_detail.height)
  end

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
    if a == 0
      return [@chromosomes['1'],0]
    end
    b = map(a, 0, 360, 0, GENOME_SIZE)

    chromosome_under_mouse = nil
    @chromosomes.values.sort_by{|c| c.bp_offset}.each do |chr|
      if chr.bp_offset < b
        chromosome_under_mouse = @chromosomes[chr.name]
      end
    end
    pos_under_mouse = (b - chromosome_under_mouse.bp_offset).to_i
    return [chromosome_under_mouse, pos_under_mouse]
  end

  def mouse_pressed
    @selection_start_degree = angle(mouse_x, mouse_y, @origin_x, @origin_y)
    @chromosomes.values.sort_by{|c| c.name.to_i}.each do |chr|
      if chr.degree_offset < @selection_start_degree
        @start_selection_chr = chr.degree_offset
      end
    end
    under_mouse = self.calculate_position_under_mouse
    @selection_start_chromosome = under_mouse[0]
    @selection_start_pos = under_mouse[1]
  end

  def mouse_moved
    @active_display = ( mouse_x < width/2 ) ? :overview : :detail
    if ( @active_display == :overview )
      @origin_x = width/4
    else
      @origin_x = 3*width/4
    end

    under_mouse = self.calculate_position_under_mouse
    @chromosome_under_mouse = under_mouse[0]
    @pos_under_mouse = under_mouse[1]
    @formatted_position = @chromosome_under_mouse.name + ':' + @pos_under_mouse.format
    redraw
  end

  def mouse_dragged
    under_mouse = self.calculate_position_under_mouse
    if @active_display == :overview
      @dragging = true
      @chromosome_under_mouse = under_mouse[0]
      @pos_under_mouse = under_mouse[1]
      @formatted_position = @chromosome_under_mouse.name + ':' + @pos_under_mouse.format
    end
    redraw
  end

  def mouse_released
    under_mouse = self.calculate_position_under_mouse
    if @active_display == :overview
      @dragging = false
      under_mouse = self.calculate_position_under_mouse
      selection = Selection.new(@selection_start_degree, angle(mouse_x, mouse_y, @origin_x, @origin_y),
                                @selection_start_chromosome, @selection_start_pos,
                                under_mouse[1])
      @selections.push(selection)
      @selection_start = nil

      self.draw_detail_display
    end
    redraw
  end

  def key_pressed
    if key == 'r'
      @selections = Array.new
      self.draw_detail_display
      redraw
    end
  end
end


S = MySketch.new :title => "My Sketch", :width => WIDTH, :height => HEIGHT
