# _locus.rb and _extensions.rb are preceded by underscore so that they gets loaded first
Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file unless file == __FILE__}
Dir[File.dirname(__FILE__) + '/sketch_methods/*.rb'].each {|file| require file }

GENOME_SIZE = 3_080_587_442

# To go from bp to degree: value*BP_TO_DEGREE_FACTOR
BP_TO_DEGREE_FACTOR = 360.to_f/GENOME_SIZE.to_f
DEGREE_TO_BP_FACTOR = 1.to_f/BP_TO_DEGREE_FACTOR

class MySketch < Processing::App
  attr_accessor :data_directory
  
  attr_accessor :f, :big_f
  attr_accessor :chromosomes, :readpairs
  attr_accessor :radius, :diameter, :circumference
  attr_accessor :wheel
  attr_accessor :displays
  attr_accessor :slices
  attr_accessor :current_slice
  attr_accessor :lenses
  attr_accessor :formatted_position_under_mouse

  attr_accessor :buffers

  def initialize(opts)
    super
    @data_directory = opts[:data_directory]
  end

  def setup
    @diameter = [(@height*0.80).to_i, (@width*0.4).to_i].min
    @radius = @diameter/2
    @circumference = (2*3.141592*@radius).ceil
    STDERR.puts "DEBUG:" + @circumference.to_s

#    @origin_x = width/2
    @origin_x = @radius + 50
    @origin_y = height/2

    @f = create_font("Arial", 12)
    @big_f = create_font("Arial", 16)
    text_font @f

    Float.sketch = self
    Chromosome.sketch = self
    ReadPair.sketch = self
    Read.sketch = self
    CopyNumber.sketch = self
    SegDup.sketch = self
    Slice.sketch = self
    Lens.sketch = self

    @slices = Array.new
    @slices.push(Slice.new)
    @current_slice = @slices[0]

    self.load_chromosomes
    self.load_readpairs
    self.load_copy_numbers
    self.load_segdups

    @chromosomes.values.each do |chr|
      chr.fetch_data
    end

    @buffer_images = Hash.new
    @buffer_images[:zoomed] = self.draw_zoomed_buffer

    @formatted_position_under_mouse = ''

    smooth
    no_loop
  end

  def draw
    background 255
    image(@buffer_images[:zoomed],0,0)

    self.draw_line_following_mouse
  end

end
