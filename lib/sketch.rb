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
  attr_accessor :seq_colour
  attr_accessor :right_mouse_click_menu_visible
  attr_accessor :selected_pixel

  attr_accessor :buffers, :buffer_images

  attr_accessor :user_action

  def setup
    @initialized = false

    @diameter = [(@height*0.80).to_i, (@width*0.4).to_i].min
    @radius = @diameter/2
    @circumference = (2*3.141592*@radius).ceil

    @origin_x = @radius + 50
    @origin_y = height/2

    @seq_colour = Hash.new
    @seq_colour['A'] = color(0,255,0)
    @seq_colour['C'] = color(0,0,255)
    @seq_colour['G'] = color(255,255,0)
    @seq_colour['T'] = color(255,0,0)

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

    @history = Array.new

    self.load_chromosomes
    self.load_readpairs
    self.load_copy_numbers
    self.load_segdups
    self.load_genes

    @chromosomes.values.each do |chr|
      chr.fetch_data
    end

    @slices = Array.new
    @slices.push(Slice.new)
    @current_slice = @slices[0]

    @buffer_images = Hash.new
    @buffer_images[:zoomed] = self.draw_zoomed_buffer
    @buffer_images[:information_panel] = self.draw_information_panel
    @buffer_images[:sequence_colour_scheme] = self.draw_sequence_colour_scheme
    @buffer_images[:right_mouse_click_menu] = self.draw_right_mouse_click_menu

    @formatted_position_under_mouse = ''
    @right_mouse_click_menu_visible = false
    @selected_pixel = nil

    smooth
    no_loop

    @user_action = nil
    @initialized = true
  end

  def draw
    background 255
    image(@buffer_images[:zoomed],0,0)
    image(@buffer_images[:information_panel],width - 550,0)
    image(@buffer_images[:sequence_colour_scheme], 20, height - 100)

    if @user_action == :moving_slice_boundary
      no_stroke
      fill 0,0,255
      pixel_on_circle = xy2pixel(mouse_x, mouse_y)
      x, y = pixel2xy(pixel_on_circle, @radius + 20)
      ellipse x, y, 10, 10
    end

    # Show right mouse click menu
    if @right_mouse_click_menu_visible
      image(@buffer_images[:right_mouse_click_menu], 100, 100)
    else
      self.draw_line_following_mouse
    end
end
