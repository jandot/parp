# _locus.rb and _extensions.rb are preceded by underscore so that they gets loaded first
Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file unless file == __FILE__}
Dir[File.dirname(__FILE__) + '/sketch_methods/*.rb'].each {|file| require file }

GENOME_SIZE = 3_080_587_442

# To go from bp to degree: value*BP_TO_DEGREE_FACTOR
BP_TO_DEGREE_FACTOR = 360.to_f/GENOME_SIZE.to_f
DEGREE_TO_BP_FACTOR = 1.to_f/BP_TO_DEGREE_FACTOR

class MySketch < Processing::App
  attr_accessor :data_directory

  attr_accessor :f12, :f16, :f24
  attr_accessor :chromosomes, :readpairs
  attr_accessor :radius, :diameter, :circumference
  attr_accessor :slices
  attr_accessor :current_slice
  attr_accessor :formatted_position_under_mouse
  attr_accessor :history
  attr_accessor :initialized
  attr_accessor :dragged_slice

  attr_accessor :buffers, :buffer_images

  def setup
    @initialized = false

    @diameter = [(@height*0.80).to_i, (@width*0.4).to_i].min
    @radius = @diameter/2
    @circumference = (2*3.141592*@radius).ceil

    @origin_x = @radius + 50
    @origin_y = height/2

    @f12 = create_font("Arial", 12)
    @f16 = create_font("Arial", 16)
    @f24 = create_font("Arial", 24)
    text_font @f12

    Float.sketch = self
    Chromosome.sketch = self
    ReadPair.sketch = self
    Read.sketch = self
    CopyNumber.sketch = self
    SegDup.sketch = self
    Gene.sketch = self
    Slice.sketch = self

    @slices = Array.new
    @slices.push(Slice.new)
    @current_slice = @slices[0]

    @history = Array.new

    self.load_chromosomes
    self.load_readpairs
    self.load_copy_numbers
    self.load_segdups
    self.load_genes

    @chromosomes.values.each do |chr|
      chr.fetch_data
    end

    @buffer_images = Hash.new
    @buffer_images[:zoomed] = self.draw_zoomed_buffer
    @buffer_images[:information_panel] = self.draw_information_panel

    @formatted_position_under_mouse = ''

    smooth
    no_loop

    @initialized = true
  end

  def draw
    background 255
    image(@buffer_images[:zoomed],0,0)
    image(@buffer_images[:information_panel],width - 350,0)

    self.draw_line_following_mouse

    unless @dragged_slice.nil?
      no_stroke
      fill 0,0,255
      pixel_on_circle = xy2pixel(mouse_x, mouse_y)
      x, y = pixel2xy(pixel_on_circle, @radius + 20)
      ellipse x, y, 10, 10
    end

    unless @slices.length == 1
      start_bar = width.to_f/2
      no_fill
      255.times do |number|
        stroke 255, number, number
        line start_bar + number, height - 50, start_bar + number, height - 20
      end
      no_stroke
      fill 0
      text "1bp/pixel", start_bar - text_width("1bp/pixel") - 5, height - 35
      text ">1Mb/pixel", start_bar + 255 + 5, height - 35
      
      @slices.each do |slice|
        x = nil
        if slice.resolution < 1E-6
          x = start_bar + 255
        elsif slice.resolution > 1
          x = start_bar
        else
          x = map(Math.log(slice.resolution), Math.log(1E-6), Math.log(1), start_bar + 255, start_bar)
        end

        no_fill
        stroke 0
        line x, height - 60, x, height - 50
        no_stroke
        fill 0
        text slice.label, x, height - 60
      end
    end
  end

end
