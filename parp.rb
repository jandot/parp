require 'ruby-processing'
require 'yaml'

WORKING_DIRECTORY = '/Users/ja8/LocalDocuments/Projects/pARP'
FILE_CHROMOSOME_METADATA = WORKING_DIRECTORY + '/data/meta_data.tsv'
#FILE_READPAIRS = WORKING_DIRECTORY + '/data/data.tsv'
FILE_READPAIRS = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/COLO-829/read_pairs.parsed'
FILE_READDEPTH = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/COLO-829/copy_number_segmented.txt'

WIDTH = 1200
HEIGHT = 600

SPACER = 20000000 # spacer in bp between chromosomes and sections

GENOME_SIZE = 3080419000

Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }


class MySketch < Processing::App
  attr_accessor :f
  attr_accessor :chromosomes, :readpairs, :reads
  attr_accessor :radius, :diameter
  attr_accessor :dragging
  attr_accessor :image_genome_overview
  attr_accessor :start_degree_segment
  
  def setup
    @diameter = 400
    @radius = @diameter/2

    @f = create_font("Arial", 12)
    text_font @f
    text_align CENTER
    
    self.load_chromosomes
    self.load_readpairs

    self.draw_genome_overview

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

    image(@image_genome_overview,0,0)
    image(@image_genome_overview, width/2, 0)

    stroke 100
    if mouse_x < width/2
      line width/4, height/2, mouse_x, mouse_y
    else
      line 3*width/4, height/2, mouse_x, mouse_y
    end

    if @dragging
      fill 0,255,0,50
      no_stroke
      if mouse_x < width/2
        pline(@start_degree_segment, angle(mouse_x, mouse_y, width/4, height/2), @diameter+100, width/4, height/2, :fill => color(0,255,0,50))
#
#        triangle(cx(@start_degree_segment, @radius+50, width/4),
#                 cy(@start_degree_segment, @radius+50, height/2),
#                 width/4,
#                 height/2,
#                 mouse_x,
#                 mouse_y
#                )
#        stroke 0,255,0
#        pline(@start_degree_segment, angle(mouse_x, mouse_y, width/4, height/2), @diameter+100, width/4, height/2)
#
      else
        triangle(cx(@start_degree_segment, @radius+50, 3*width/4),
                 cy(@start_degree_segment, @radius+50, height/2),
                 3*width/4,
                 height/2,
                 mouse_x,
                 mouse_y
                )
      end

    end

    unless @start_degree_segment.nil?
      fill 0
      text @start_degree_segment.to_s, 100, 20
    end
  end

  def draw_genome_overview
    buffer_genome_overview = buffer(self.width/2,self.height,JAVA2D) do |b|
      b.background 255
      b.text_font @f
      b.text_align CENTER

      b.smooth

      b.translate(self.width.to_f/4, self.height.to_f/2)
      @chromosomes.values.each do |chr|
        chr.draw(b)
      end
      @readpairs.each do |readpair|
        readpair.draw(b)
      end
      b.translate(-self.width.to_f/4, self.height.to_f/2)
    end
    @image_genome_overview = buffer_genome_overview.get(0, 0, buffer_genome_overview.width, buffer_genome_overview.height)
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

  def mouse_pressed
    if mouse_x < width/2
      @start_degree_segment = angle(mouse_x, mouse_y, width/4, height/2)
    else
      @start_degree_segment = angle(mouse_x, mouse_y, 3*width/4, height/2)
    end
  end

  def mouse_moved
    redraw
  end
  
  def mouse_dragged
    @dragging = true
    redraw
  end

  def mouse_released
    @dragging = false
    @segment_line_angles = Array.new
    redraw
  end
end


S = MySketch.new :title => "My Sketch", :width => WIDTH, :height => HEIGHT
