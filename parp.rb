require '/usr/local/ruby-processing/ruby-processing'
require 'yaml'

WIDTH = 1200
HEIGHT = 800

#WIDTH=800
#HEIGHT=600

DIAMETER = 3*HEIGHT/8
RADIUS = DIAMETER/2

GENOME_SIZE = 3080419000

Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }

class Integer
  def format
    return self.to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2')
  end
end

class MySketch < Processing::App
  attr_accessor :chromosomes
  attr_accessor :buffer_circular_all, :img_circular_all, :buffer_circular_highlighted, :img_circular_highlighted
  attr_accessor :buffer_linear_ideograms, :img_linear_ideograms
  attr_accessor :buffer_linear_zoom, :img_linear_zoom
  attr_accessor :buffer_linear_highlighted, :img_linear_highlighted
  attr_accessor :f
  attr_accessor :top_linear, :bottom_linear
  attr_accessor :active_panel
  attr_accessor :buttons
  
  def setup
    @f = create_font("Arial", 12)
    text_font @f
    
    @zoomed = false
    
    @chromosomes = Array.new
    self.load_chromosomes
    self.load_readpairs
    
    @buttons = Hash.new
    @buttons[:top] = Array.new
    @buttons[:bottom] = Array.new

    @chromosomes[0].set_linear(:top)
    @chromosomes[1].set_linear(:bottom)
    
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
    
    # The circular bit
    image(@img_circular_highlighted,0,0)

    # The linear bit
    translate(0, self.height/2)
    image(@img_linear_highlighted,0,0)
    
    # Draw green line on ideogram
    if ! @active_panel.nil? and @active_panel > 1
      chr = ( @active_panel == 2 ) ? @top_linear : @bottom_linear
      noFill
      strokeWeight 2
      stroke 0, 255,0,50
      line(mouse_x, chr.baseline - 50, mouse_x, chr.baseline + 50)
      
      strokeWeight 2
      stroke 0,255,0,200
      [@top_linear, @bottom_linear].each do |chr|
        ideogram_line_x = map(mouse_x, 0, self.width, chr.zoom_box_ideogram_x1, chr.zoom_box_ideogram_x2)
        line(ideogram_line_x, chr.ideogram_y1 - 2, ideogram_line_x, chr.ideogram_y1 + chr.ideogram.height + 4 )
      end
    end
    translate(0, -self.height/2)
  end
    
  def load_chromosomes
    File.open('/Users/ja8/LocalDocuments/Projects/pARP/data/meta_data.tsv').each do |l|
      fields = l.chomp.split(/\t/)
      Chromosome.new(fields[0].to_i, fields[1].to_i, fields[2].to_i, fields[3].to_i)
    end
  end
  
  def load_readpairs
    File.open('/Users/ja8/LocalDocuments/Projects/pARP/data/data.tsv').each do |l|
      fields = l.chomp.split(/\t/)
      ReadPair.new(fields[0].to_i, fields[1].to_i, fields[2].to_i, fields[3].to_i, fields[4])
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
      @chromosomes.each do |chr|
        chr.draw_buffer_circular_all(b)
      end
    
      b.noFill
      @chromosomes.each do |chr|
        chr.between_chromosome_readpairs.values.flatten.each do |rp|
          rp.draw_buffer_circular(b, :all)
        end
      end
      b.translate(-self.width.to_f/4,-self.height.to_f/4)
    end
    @img_circular_all = @buffer_circular_all.get(0, 0, @buffer_circular_all.width, @buffer_circular_all.height)
  end
  
  def draw_buffer_circular_highlighted
    @buffer_circular_highlighted = buffer(self.width/2,self.height/2,JAVA2D) do |b|
      b.background(@img_circular_all)
      b.smooth
    
      b.translate(self.width.to_f/4,self.height.to_f/4)
    
      b.noFill
      @chromosomes.each do |chr|
        chr.between_chromosome_readpairs.values.flatten.select{|r| r.active}.each do |rp|
          rp.draw_buffer_circular(b, :highlighted)
        end
      end
      b.noStroke
      @chromosomes.select{|c| c.label.active}.each do |c|
        c.label.draw_buffer_circular(b, :highlighted)
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
      [:top, :bottom].each do |panel|
        @buttons[panel].each do |button|
          button.draw(b)
        end
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
      b.text_font @f
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
      @chromosomes.each do |chr|
        [chr.within_chromosome_readpairs, chr.between_chromosome_readpairs.values.flatten].flatten.each do |rp|
          if ( ( (rp.circular_x1 - mouse_x + self.width/4).abs < 5 and (rp.circular_y1 - mouse_y + self.height/4).abs < 5 ) or 
               ( (rp.circular_x2 - mouse_x + self.width/4).abs < 5 and (rp.circular_y2 - mouse_y + self.height/4).abs < 5 ) )
            rp.active = true
          else
            rp.active = false
          end
        end

        if chr.label.under_mouse?#mouse_x > chr.label.x1 + width/4 and mouse_x < chr.label.x2 + width/4 and mouse_y > chr.label.y1 + height/4 and mouse_y < chr.label.y2 + height/4
          chr.label.active = true
        else
          chr.label.active = false
        end
      end
      
      self.draw_buffer_circular_highlighted
      self.draw_buffer_linear_highlighted
      redraw
    elsif @active_panel == 2 or @active_panel == 3
      if @active_panel == 2
        chr = @top_linear
        other_chr = @bottom_linear
      else
        chr = @bottom_linear
        other_chr = @top_linear
      end
      chr.activate_zoom_boxes
      chr.within_chromosome_readpairs.select{|r| r.visible}.each do |rp|
        if (rp.linear_x1 - mouse_x).abs < 5 or (rp.linear_x2 - mouse_x).abs < 5
          rp.active = true
        else
          rp.active = false
        end
        
      end
      if @active_panel == 2
        chr.between_chromosome_readpairs[other_chr.number].select{|r| r.visible}.each do |rp|
          if (rp.linear_x1 - mouse_x).abs < 5 or (rp.linear_x2 - mouse_x).abs < 5
            rp.active = true
          else
            rp.active = false
          end
        end
      else
        other_chr.between_chromosome_readpairs[chr.number].select{|r| r.visible}.each do |rp|
          if (rp.linear_x1 - mouse_x).abs < 5 or (rp.linear_x2 - mouse_x).abs < 5
            rp.active = true
          else
            rp.active = false
          end
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
  
  def mouse_clicked
    if key_pressed? and ( key == 49 or key == 50)
      active_chr = @chromosomes.select{|l| l.label.active}
      unless active_chr.length == 0
        if key == 49
          active_chr[0].set_linear(:top)
        else
          active_chr[0].set_linear(:bottom)
        end
      end
      draw_buffer_linear_ideograms
      draw_buffer_linear_zoom
      draw_buffer_linear_highlighted
      redraw
    else
      changed = false
      [:top, :bottom].each do |panel|
        @buttons[panel].each do |button|
          if button.under_mouse?
            if panel == :top
              @top_linear.apply_button(button.type, button.action)
            else
              @bottom_linear.apply_button(button.type, button.action)
            end
            changed = true
          end
        end
      end
      if changed
        draw_buffer_linear_zoom
        draw_buffer_linear_highlighted
        redraw
      end
    end
  end
end

S = MySketch.new :title => "My Sketch", :width => WIDTH, :height => HEIGHT
