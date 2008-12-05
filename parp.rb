require '/usr/local/ruby-processing/ruby-processing'
require 'yaml'

WIDTH = 800
HEIGHT = 200

GENOME_SIZE = 3080419000

Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }

class MySketch < Processing::App
  attr_accessor :chromosomes, :readpairs, :buffer, :img
  
  def setup
    hint(ENABLE_NATIVE_FONTS)
    font = create_font("Monospaced", 66)
    text_font font, 1.0
    

    
    @chromosomes = Hash.new
    @readpairs = Hash.new
    self.load_chromosomes
    self.load_readpairs
    
    smooth
    no_loop
  end

  def draw
    background(255,255,255)
    
    @buffer = create_graphics(self.width, self.height, JAVA2D);
    @buffer.begin_draw
    @buffer.background(255,255,255)
    @buffer.fill(0,0,255,50)
    @buffer.noStroke
    @buffer.smooth
    @chromosomes.keys.each do |nr|
      @chromosomes[nr].draw
    end
    @buffer.end_draw
    @img = @buffer.get(0, 0, @buffer.width, @buffer.height);
    image(@img,0,0)
    
    stroke 0
    no_fill
    @readpairs.values.each do |rp|
      rp.draw
    end
    
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
      @readpairs[@readpairs.length + 1] = rp
    end
  end
  
  def mouse_moved
    @chromosomes.keys.each do |nr|
      if ( @chromosomes[nr].covers?(mouseX,mouseY) )
        @chromosomes[nr].active = true
      else
        @chromosomes[nr].active = false
      end
    end
    loop
  end
end

S = MySketch.new :title => "My Sketch", :width => WIDTH, :height => HEIGHT
