require '/usr/local/ruby-processing/ruby-processing'
require 'yaml'

WORKING_DIRECTORY = '/Users/ja8/LocalDocuments/Projects/pARP'
FILE_CHROMOSOME_METADATA = WORKING_DIRECTORY + '/data/meta_data.tsv'
FILE_READPAIRS = WORKING_DIRECTORY + '/data/data.tsv'
FILE_DISCRETE_FEATURES = WORKING_DIRECTORY + '/data/features.tsv'
FILE_INDEX_CONTINUOUS_FEATURES = WORKING_DIRECTORY + '/data/index_readdepth.tsv'
FILE_CONTINUOUS_FEATURES = WORKING_DIRECTORY + '/data/bindepth-500'

WIDTH = 1200
HEIGHT = 600

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
  attr_accessor :buffer_linear_continuous_features, :img_linear_continuous_features
  attr_accessor :buffer_controls, :img_controls
  attr_accessor :f
  attr_accessor :linear_representation
  attr_accessor :active_panel
  attr_accessor :buttons
  attr_accessor :diameter, :radius
  attr_accessor :circular_only
  attr_accessor :dragging_chr
  attr_accessor :thread_load_continuous_features, :thread_draw_continuous_features, :thread_update_x_continuous_features

  def setup
    @f = create_font("Arial", 12)
    text_font @f

    @circular_only = true
    @diameter = 7*self.height/8
    @radius = @diameter/2
    @dragging_chr = nil
    @calculating = false

    @chromosomes = Array.new
    self.load_chromosomes
    self.load_readpairs
    self.load_discrete_features
    self.load_index_continuous_features
    
    @buttons = Hash.new
    @buttons[:top] = Array.new
    @buttons[:bottom] = Array.new

    @linear_representation = Hash.new
    @chromosomes[20].set_linear(:top)
    @chromosomes[21].set_linear(:bottom)
    
    smooth
    no_loop

    self.draw_buffer_circular_all
    self.draw_buffer_circular_highlighted
    self.draw_buffer_linear_ideograms
    self.draw_buffer_linear_zoom
    self.draw_buffer_linear_highlighted
    self.draw_buffer_linear_continuous_features
    self.draw_buffer_controls

  end

  def draw
    background(255,255,255)
    
    # The circular bit
    image(@img_circular_highlighted,0,0)

    if ! @circular_only
      # The linear bit
      translate(0, self.height/2)

      image(@img_linear_highlighted,0,0)

      # Draw green line on ideogram
      if ! @active_panel.nil? and @active_panel > 1
        noFill
        strokeWeight 2
        stroke 0, 255,0,50
        line(mouse_x, @linear_representation[:top].baseline - 20, mouse_x, @linear_representation[:bottom].baseline + 20)

        strokeWeight 2
        stroke 0,255,0
        [:top, :bottom].each do |panel|
          chr = @linear_representation[panel]
          ideogram_line_x = map(mouse_x, 0, self.width, chr.zoom_box_ideogram_x1, chr.zoom_box_ideogram_x2)
          line(ideogram_line_x, chr.ideogram_y1 - 2, ideogram_line_x, chr.ideogram_y1 + chr.ideogram.height + 4 )
        end
      end
      translate(0, -self.height/2)
    end

    if !@dragging_chr.nil?
      fill(0,50)
      no_stroke
      rect(mouseX-2,mouseY-text_ascent,@dragging_chr.label.dx+4,@dragging_chr.label.dy+4)
      fill(0)
      text(@dragging_chr.label.label, mouseX, mouseY)
    end
    
    image(@img_controls,0,0)
  end
    
  def load_chromosomes
    File.open(FILE_CHROMOSOME_METADATA).each do |l|
      fields = l.chomp.split(/\t/)
      Chromosome.new(fields[0].to_i, fields[1].to_i, fields[2].to_i, fields[3].to_i)
    end
  end
  
  def load_readpairs
    File.open(FILE_READPAIRS).each do |l|
      fields = l.chomp.split(/\t/)
      ReadPair.new(fields[0].to_i, fields[1].to_i, fields[2].to_i, fields[3].to_i, fields[4])
    end
  end

  def load_discrete_features
    File.open(FILE_DISCRETE_FEATURES).each do |l|
      fields = l.chomp.split(/\t/)
      if fields[3].nil?
        DiscreteFeature.new(fields[0].to_i, fields[1].to_i, fields[2].to_i, nil)
      else
        DiscreteFeature.new(fields[0].to_i, fields[1].to_i, fields[2].to_i, fields[3])
      end
    end
  end

  def load_index_continuous_features
    File.open(FILE_INDEX_CONTINUOUS_FEATURES).each do |l|
      chr_number, first_line, last_line = l.chomp.split(/\t/)
      chr = @chromosomes.select{|c| c.number == chr_number.to_i}[0]
      chr.first_line_continuous = first_line.to_i
      chr.last_line_continuous = last_line.to_i
    end
  end
  
  def draw_buffer_circular_all
    @buffer_circular_all = buffer(self.width,self.height,JAVA2D) do |b|
      b.background(255)
      b.text_font @f
    
      b.smooth
      b.strokeCap(SQUARE)

      if ! @circular_only
        translate_x = 3*self.width.to_f/4
        translate_y = self.height.to_f/4
      else
        translate_x = self.width.to_f/2
        translate_y = self.height.to_f/2
      end
      b.translate(translate_x, translate_y)
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
      b.translate(-translate_x, -translate_y)
    end
    @img_circular_all = @buffer_circular_all.get(0, 0, @buffer_circular_all.width, @buffer_circular_all.height)
  end
  
  def draw_buffer_circular_highlighted
    @buffer_circular_highlighted = buffer(self.width,self.height,JAVA2D) do |b|
      b.background(@img_circular_all)
      b.smooth

      if ! @circular_only
        translate_x = 3*self.width.to_f/4
        translate_y = self.height.to_f/4
      else
        translate_x = self.width.to_f/2
        translate_y = self.height.to_f/2
      end
      b.translate(translate_x, translate_y)
    
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
      b.translate(-translate_x, -translate_y)
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
      [:top, :bottom].each do |panel|
        chr = @linear_representation[panel]
        chr.draw_buffer_linear_ideograms(b)
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
      [:top, :bottom].each do |panel|
        chr = @linear_representation[panel]
        chr.draw_buffer_linear_zoom(b)
      end

      #Draw between-chromosome readpairs
      start_chr, stop_chr = [@linear_representation[:top], @linear_representation[:bottom]].sort_by{|c| c.number}
      start_chr.between_chromosome_readpairs[stop_chr.number].each do |rp|
        rp.draw_buffer_linear(b, :zoom)
      end

    end
    @img_linear_zoom = @buffer_linear_zoom.get(0,0,@buffer_linear_zoom.width, @buffer_linear_zoom.height)
  end


  def draw_buffer_linear_highlighted
    @buffer_linear_highlighted = buffer(self.width, self.height/2, JAVA2D) do |b|
      b.smooth
      b.strokeCap SQUARE
      b.rectMode CORNERS
      b.text_font @f
      b.fill 0

      if @img_linear_continuous_features.nil?
        b.background(@img_linear_zoom)
        b.text("Calculating read depth...", 10, self.height/4)
      else
        b.background(@img_linear_continuous_features)
      end

      [:top, :bottom].each do |panel|
        chr = @linear_representation[panel]
        chr.draw_buffer_linear_highlighted(b)
      end

      #Draw between-chromosome readpairs
      start_chr, stop_chr = [@linear_representation[:top], @linear_representation[:bottom]].sort_by{|c| c.number}
      start_chr.between_chromosome_readpairs[stop_chr.number].select{|rp| rp.visible and rp.active}.each do |rp|
        rp.draw_buffer_linear(b, :highlighted)
      end
    end
    @img_linear_highlighted = @buffer_linear_highlighted.get(0,0,@buffer_linear_highlighted.width, @buffer_linear_highlighted.height)
  end

  def draw_buffer_linear_continuous_features
    @img_linear_continuous_features = nil
    @thread_draw_continuous_features = Thread.new do
      STDERR.puts "=========Started drawing thread"
      @buffer_linear_continuous_features = buffer(self.width, self.height/2, JAVA2D) do |b|
        b.background(@img_linear_zoom)
        b.smooth
        [:top,:bottom].each do |panel|
#          @thread_load_continuous_features.join
#          STDERR.puts "Loading thread joined"
          @thread_update_x_continuous_features.join
          STDERR.puts "Updating thread joined"
          @linear_representation[panel].draw_buffer_linear_continuous_features(b)
        end
      end
      @img_linear_continuous_features = @buffer_linear_continuous_features.get(0,0,@buffer_linear_continuous_features.width,@buffer_linear_continuous_features.height)
      self.draw_buffer_linear_highlighted
      redraw
      STDERR.puts "++++++++Finished drawing thread"
    end
  end

  def draw_buffer_controls
    @buffer_controls = buffer(self.width/4, self.height/2, JAVA2D) do |b|
      b.background(255)
      b.text_font @f
      b.smooth
      
      b.fill(0)
      control_lines = Array.new
      control_lines.push('Selected chromosomes')
      control_lines.push('  Top: ' + @linear_representation[:top].number.to_s)
      control_lines.push('  Bottom: ' + @linear_representation[:bottom].number.to_s)
      b.text(control_lines.join("\n"), 5, 20)

    end
    @img_controls = @buffer_controls.get(0,0,@buffer_controls.width,@buffer_controls.height)
  end

  def mouse_moved
    if @circular_only
      @chromosomes.each do |chr|
        [chr.within_chromosome_readpairs, chr.between_chromosome_readpairs.values.flatten].flatten.each do |rp|
          if ( ( (rp.circular_x1 - mouse_x + self.width/2).abs < 5 and (rp.circular_y1 - mouse_y + self.height/2).abs < 5 ) or
               ( (rp.circular_x2 - mouse_x + self.width/2).abs < 5 and (rp.circular_y2 - mouse_y + self.height/2).abs < 5 ) )
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
    else
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
            if ( ( (rp.circular_x1 - mouse_x + 3*self.width/4).abs < 5 and (rp.circular_y1 - mouse_y + self.height/4).abs < 5 ) or
                 ( (rp.circular_x2 - mouse_x + 3*self.width/4).abs < 5 and (rp.circular_y2 - mouse_y + self.height/4).abs < 5 ) )
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
          chr = @linear_representation[:top]
          other_chr = @linear_representation[:bottom]
        else
          chr = @linear_representation[:bottom]
          other_chr = @linear_representation[:top]
        end
        chr.activate_zoom_boxes
        chr.within_chromosome_readpairs.select{|r| r.visible}.each do |rp|
          if (rp.linear_x1 - mouse_x).abs < 5 or (rp.linear_x2 - mouse_x).abs < 5
            rp.active = true
          else
            rp.active = false
          end
        end

        larger_chr = [@linear_representation[:top], @linear_representation[:bottom]].sort_by{|c| c.number}[0]
        smaller_chr = [@linear_representation[:top], @linear_representation[:bottom]].sort_by{|c| c.number}[1]

        larger_chr.between_chromosome_readpairs[smaller_chr.number].select{|r| r.visible}.each do |rp|
          if (rp.linear_x1 - mouse_x).abs < 5 or (rp.linear_x2 - mouse_x).abs < 5
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
  end
  
  def mouse_dragged
    dragging = false
    if !@circular_only
      if @active_panel == 2
        panel = @linear_representation[:top]
        if pmouse_y >= self.height/2 + 5 and pmouse_y <= self.height/2 + panel.ideogram.height + 5
          dragging = true
        end
      else
        panel = @linear_representation[:bottom]
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

        if @thread_draw_continuous_features.alive?
#          @thread_update_x_continuous_features.kill
          @thread_draw_continuous_features.kill
          @img_draw_continuous_features = nil
        end
        self.draw_buffer_linear_zoom
        self.draw_buffer_linear_continuous_features
        self.draw_buffer_linear_highlighted
      end
      if dragging or !@dragging_chr.nil?
        self.redraw
      end
    end
  end
  
  def mouse_clicked
    changed = false
    [:top, :bottom].each do |panel|
      @buttons[panel].each do |button|
        if button.under_mouse?
          STDERR.puts "Button: " + button.action.to_s
          if panel == :top
            STDERR.puts "Applying button"
            @linear_representation[:top].apply_button(button.type, button.action)
          else
            @linear_representation[:bottom].apply_button(button.type, button.action)
          end
          changed = true
        end
      end
    end
    STDERR.puts "Changed = " + changed.to_s
    if changed
      if @thread_draw_continuous_features.alive?
#        @thread_update_x_continuous_features.kill
        @thread_draw_continuous_features.kill
        @img_draw_continuous_features = nil
      end
      self.draw_buffer_linear_zoom
      self.draw_buffer_linear_continuous_features
      self.draw_buffer_linear_highlighted
      self.redraw
    end
  end

  def mouse_pressed
    if !@circular_only and @active_panel == 1
      @chromosomes.each do |chr|
        if chr.label.under_mouse?
          @dragging_chr = chr
        end
      end
    end
  end

  def mouse_released
    if !@circular_only
      if mouse_y < self.height/2
        @active_panel = 1
      elsif mouse_y < 3*self.height/4
        @active_panel = 2
      else
        @active_panel = 3
      end

      if @active_panel > 1
        if ! @dragging_chr.nil?
          if @active_panel == 2
            @dragging_chr.set_linear(:top)
          else
            @dragging_chr.set_linear(:bottom)
          end
          if @thread_draw_continuous_features.alive?
#            @thread_update_x_continuous_features.kill
            @thread_draw_continuous_features.kill
            @img_draw_continuous_features = nil
          end
          @dragging_chr = nil
          self.draw_buffer_linear_ideograms
          self.draw_buffer_linear_zoom
          self.draw_buffer_linear_continuous_features
          self.draw_buffer_linear_highlighted
          self.draw_buffer_controls
          self.redraw
        end
      end
    end
  end

  def key_pressed
    if key == 122 #'z'
      @circular_only = !@circular_only

      if @circular_only
        @diameter = 7*self.height/8
        @radius = @diameter/2
      else
        @diameter = 3*self.height/8
        @radius = @diameter/2
      end

      @chromosomes.each do |chr|
        chr.label.calculate_radians
        chr.between_chromosome_readpairs.values.flatten.each do |rp|
          rp.calculate_radians
        end
      end

      self.draw_buffer_circular_all
      self.draw_buffer_circular_highlighted
      self.redraw
    end
  end
end

S = MySketch.new :title => "My Sketch", :width => WIDTH, :height => HEIGHT
