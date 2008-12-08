require '/usr/local/ruby-processing/ruby-processing'
require 'yaml'

WIDTH = 1200
HEIGHT = 800

DIAMETER = 3*HEIGHT/8
RADIUS = DIAMETER/2

GENOME_SIZE = 3080419000

Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }

class MySketch < Processing::App
  attr_accessor :chromosomes, :readpairs
  attr_accessor :buffer_circular_all, :img_circular_all, :buffer_circular_highlighted, :img_circular_highlighted
  attr_accessor :buffer_linear_ideograms, :img_linear_ideograms
  attr_accessor :buffer_linear_zoom, :img_linear_zoom
  attr_accessor :buffer_linear_highlighted, :img_linear_highlighted
  attr_accessor :f
  attr_accessor :top_linear, :bottom_linear
  attr_accessor :active_panel
  
  def setup
    @f = create_font("Arial", 12)
    text_font @f, 1.0
    
    @zoomed = false
    
    @chromosomes = Hash.new
    @readpairs = Array.new
    self.load_chromosomes
    @chromosomes.values.each do |chr|
      chr.calculate_radians
    end
    self.load_readpairs
    
    @chromosomes.values[0].set_linear("top")
    @chromosomes.values[1].set_linear("bottom")
    
    smooth
    no_loop
    
    self.draw_buffer_circular_all
    self.draw_buffer_circular_highlighted
    self.draw_buffer_linear_ideograms
    self.draw_buffer_linear_zoom
    self.draw_buffer_linear_highlighted
  end

  def draw
    background(255,255,255)
    
    image(@img_circular_highlighted,0,0)
    translate(0, self.height/2)
    image(@img_linear_highlighted,0,0)
    translate(0, -self.height/2)
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
    @buffer_circular_all = buffer(self.width/2,self.height/2,JAVA2D) do |b|
      b.background(255)
      b.text_font @f
    
      b.smooth
      b.strokeCap(SQUARE)
    
      b.translate(self.width.to_f/4,self.height.to_f/4)
      b.strokeWeight(3)
      b.stroke(0)
      @chromosomes.keys.each do |nr|
        @chromosomes[nr].draw_buffer_circular_all(b)
      end
    
      b.noFill
      @readpairs.select{|rp| ! rp.within_chromosome}.each do |rp|
        rp.draw_buffer_circular(b, :all)
      end
      b.translate(-self.width.to_f/4,-self.height.to_f/4)
      b.end_draw
    end
    @img_circular_all = @buffer_circular_all.get(0, 0, @buffer_circular_all.width, @buffer_circular_all.height)
  end
  
  def draw_buffer_circular_highlighted
    @buffer_circular_highlighted = buffer(self.width/2,self.height/2,JAVA2D) do |b|
      b.background(@img_circular_all)
      b.smooth
    
      b.translate(self.width.to_f/4,self.height.to_f/4)
    
      b.noFill
      @readpairs.select{|rp| ! rp.within_chromosome and rp.active}.each do |rp|
        rp.draw_buffer_circular(b, :highlighted)
      end
      b.translate(-self.width.to_f/4,-self.height.to_f/4)
    end
    @img_circular_highlighted = @buffer_circular_highlighted.get(0, 0, @buffer_circular_highlighted.width, @buffer_circular_highlighted.height)
  end
  
  def draw_buffer_linear_ideograms
    @buffer_linear_ideograms = buffer(self.width, self.height/2, JAVA2D) do |b|
      b.background 255
      b.text_font @f
      b.smooth
      b.strokeCap SQUARE
      b.rectMode CORNERS
      b.stroke 0
      [@top_linear,@bottom_linear].each do |panel|
        panel.draw_buffer_linear_ideograms(b)
      end
    end
    @img_linear_ideograms = @buffer_linear_ideograms.get(0,0,@buffer_linear_ideograms.width, @buffer_linear_ideograms.height)
  end
  
  def draw_buffer_linear_zoom
    @buffer_linear_zoom = buffer(self.width, self.height/2, JAVA2D) do |b|
      b.background(@img_linear_ideograms)
      b.smooth
      b.strokeCap SQUARE
      b.rectMode CORNERS
      b.text_font @f
      [@top_linear, @bottom_linear].each do |panel|
        panel.draw_buffer_linear_zoom(b)
      end
    end
    @img_linear_zoom = @buffer_linear_zoom.get(0,0,@buffer_linear_zoom.width, @buffer_linear_zoom.height)
  end
  
  def draw_buffer_linear_highlighted
    @buffer_linear_highlighted = buffer(self.width, self.height/2, JAVA2D) do |b|
      b.background(@img_linear_zoom)
      b.smooth
      b.strokeCap SQUARE
      b.rectMode CORNERS
      [@top_linear, @bottom_linear].each do |panel|
        panel.draw_buffer_linear_highlighted(b)
      end
    end
    @img_linear_highlighted = @buffer_linear_highlighted.get(0,0,@buffer_linear_highlighted.width, @buffer_linear_highlighted.height)
  end
  
  
  def mouse_moved
    if mouse_y < self.height/2
      @active_panel = 1
    elsif mouse_y < 3*self.height/4
      @active_panel = 2
    else
      @active_panel = 3
    end
    if @active_panel == 1
      @readpairs.each do |rp|
#      @readpairs.select{|rp| !rp.within_chromosome}.each do |rp|
        if ( ( (rp.circular_x1 - mouse_x + self.width/4).abs < 5 and (rp.circular_y1 - mouse_y + self.height/4).abs < 5 ) or 
             ( (rp.circular_x2 - mouse_x + self.width/4).abs < 5 and (rp.circular_y2 - mouse_y + self.height/4).abs < 5 ) )
          rp.active = true
        else
          rp.active = false
        end
      end
      self.draw_buffer_circular_highlighted
      self.draw_buffer_linear_highlighted
      redraw
    end
  end
  
  def mouse_dragged
    dragging = false
    if @active_panel == 2 or @active_panel == 3
      if @active_panel == 2
        panel = @top_linear
        if pmouse_y >= self.height/2 + 5 and pmouse_y <= self.height/2 + panel.ideogram.height + 5
          dragging = true
        end
      else
        panel = @bottom_linear
        if pmouse_y <= self.height - 5 and pmouse_y >= self.height - panel.ideogram.height - 5
          dragging = true
        end
      end
      if dragging
        if (pmouse_x - panel.zoom_box_ideogram_x1).abs < 5
          panel.zoom_by_drag(:left)
        elsif (pmouse_x - panel.zoom_box_ideogram_x2).abs < 5
          panel.zoom_by_drag(:right)
        elsif (pmouse_x > panel.zoom_box_ideogram_x1 + 5 and pmouse_x < panel.zoom_box_ideogram_x2 - 5)
          panel.pan_by_drag
        end
        self.draw_buffer_linear_zoom
        self.draw_buffer_linear_highlighted
        redraw
      end
    end
  end
end

S = MySketch.new :title => "My Sketch", :width => WIDTH, :height => HEIGHT
