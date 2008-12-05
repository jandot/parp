require '/usr/local/ruby-processing/ruby-processing'
require 'yaml'

WIDTH = 1200
HEIGHT = 600

DIAMETER = HEIGHT - 20
RADIUS = DIAMETER/2

GENOME_SIZE = 3080419000

Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }

class MySketch < Processing::App
  attr_accessor :chromosomes, :readpairs
  attr_accessor :buffer_circular_all, :img_circular_all, :buffer_circular_highlighted, :img_circular_highlighted
  attr_accessor :f
  
  def setup
    hint(ENABLE_NATIVE_FONTS)
    @f = create_font("Arial", 12)
    text_font @f, 1.0
    

    
    @chromosomes = Hash.new
    @readpairs = Array.new
    self.load_chromosomes
    @chromosomes.values.each do |chr|
      chr.calculate_radians
    end
    self.load_readpairs
    
    smooth
    no_loop
    
    self.draw_buffer_circular_all
    self.draw_buffer_circular_highlighted
  end

  def draw
    background(255,255,255)
    
    image(@img_circular_highlighted,0,0)
  end
    
  def load_chromosomes
    File.open('data/meta_data.tsv').each do |l|
      fields = l.chomp.split(/\t/)
      chr = Chromosome.new(fields[0].to_i, fields[1].to_i, fields[2].to_i, fields[3].to_i)
      @chromosomes[chr.number] = chr
    end
  end
  
  def load_readpairs
    File.open('data/data.tsv').each do |l|
      fields = l.chomp.split(/\t/)
      rp = ReadPair.new(fields[0].to_i, fields[1].to_i, fields[2].to_i, fields[3].to_i, fields[4])
      @readpairs.push(rp)
    end
  end
  
  def draw_buffer_circular_all
    @buffer_circular_all = create_graphics(self.width, self.height, JAVA2D);
    @buffer_circular_all.begin_draw
    @buffer_circular_all.background(255)
    @buffer_circular_all.text_font @f
    
    @buffer_circular_all.smooth
    @buffer_circular_all.strokeCap(SQUARE)
    
    @buffer_circular_all.translate(self.width.to_f/2,self.height.to_f/2)
    @buffer_circular_all.strokeWeight(3)
    @buffer_circular_all.stroke(0)
    @chromosomes.keys.each do |nr|
      @chromosomes[nr].draw_buffer_circular_all
    end
    
    @buffer_circular_all.noFill
    @readpairs.select{|rp| ! rp.within_chromosome}.each do |rp|
      rp.draw_buffer_circular(false)
    end
    @buffer_circular_all.translate(-self.width.to_f/2,-self.height.to_f/2)
    @buffer_circular_all.end_draw
    
    @img_circular_all = @buffer_circular_all.get(0, 0, @buffer_circular_all.width, @buffer_circular_all.height)
  end
  
  def draw_buffer_circular_highlighted
    @buffer_circular_highlighted = create_graphics(self.width, self.height, JAVA2D);
    @buffer_circular_highlighted.begin_draw
    @buffer_circular_highlighted.background(@img_circular_all)
    
    @buffer_circular_highlighted.smooth
    
    @buffer_circular_highlighted.translate(self.width.to_f/2,self.height.to_f/2)
    
    @buffer_circular_highlighted.noFill
    @readpairs.select{|rp| ! rp.within_chromosome and rp.active}.each do |rp|
      rp.draw_buffer_circular(true)
    end
    @buffer_circular_highlighted.translate(-self.width.to_f/2,-self.height.to_f/2)
    @buffer_circular_highlighted.end_draw
    
    @img_circular_highlighted = @buffer_circular_highlighted.get(0, 0, @buffer_circular_highlighted.width, @buffer_circular_highlighted.height)
  end
    
  def mouse_moved
    @readpairs.select{|rp| !rp.within_chromosome}.each do |rp|
      if ( ( (rp.circular_x1 - mouse_x + self.width/2).abs < 5 and (rp.circular_y1 - mouse_y + self.height/2).abs < 5 ) or 
           ( (rp.circular_x2 - mouse_x + self.width/2).abs < 5 and (rp.circular_y2 - mouse_y + self.height/2).abs < 5 ) )
        rp.active = true
      else
        rp.active = false
      end
    end
    self.draw_buffer_circular_highlighted
    redraw
  end
end

S = MySketch.new :title => "My Sketch", :width => WIDTH, :height => HEIGHT
