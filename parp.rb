require 'rubygems'
require 'ruby-processing'
require 'yaml'

WORKING_DIRECTORY = '/Users/ja8/LocalDocuments/Projects/pARP'
FILE_CHROMOSOME_METADATA = WORKING_DIRECTORY + '/data/meta_data.tsv'
#FILE_READPAIRS = WORKING_DIRECTORY + '/data/data.tsv'
#FILE_READPAIRS = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/NCI-H2171/read_pairs.parsed'
FILE_READPAIRS = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/COLO-829/read_pairs.parsed'
#FILE_READPAIRS = WORKING_DIRECTORY + '/data/small_dataset.tsv'
#FILE_COPY_NUMBER = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/NCI-H2171/copy_number_segmented.txt'
FILE_COPY_NUMBER = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/COLO-829/copy_number_segmented.txt'
FILE_SEGDUPS = WORKING_DIRECTORY + '/data/features.tsv'
#FILE_SEGDUPS = WORKING_DIRECTORY + '/data/small_features.tsv'

#WIDTH = 1200
#HEIGHT = 600
WIDTH = 1280
HEIGHT = 800

GENOME_SIZE = 3_080_587_442

# To go from bp to degree: value*BP_TO_DEGREE_FACTOR
BP_TO_DEGREE_FACTOR = 360.to_f/GENOME_SIZE.to_f
DEGREE_TO_BP_FACTOR = 1.to_f/BP_TO_DEGREE_FACTOR

# _locus.rb and _extensions.rb are preceded by underscore so that they gets loaded first
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/sketch_methods/*.rb'].each {|file| require file }

class MySketch < Processing::App
  attr_accessor :f, :big_f
  attr_accessor :chromosomes, :readpairs
  attr_accessor :radius, :diameter, :circumference
  attr_accessor :wheel
  attr_accessor :displays
  attr_accessor :slices
  attr_accessor :lenses
  attr_accessor :formatted_position_under_mouse

  attr_accessor :buffers

  def setup
    @diameter = [(@height*0.80).to_i, (@width*0.4).to_i].min
    @radius = @diameter/2
    @circumference = 2*3.141592*@radius

    @origin_x = width/2
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
#    @slices.push(Slice.new)
    @slices.push(Slice.new(0,350000000, 0, 50))
    @slices.push(Slice.new(350000001, 400000000, 51, 1000))
    @slices.push(Slice.new(400000001,GENOME_SIZE, 1001, @circumference))

    @slices.each do |slice|
      STDERR.puts slice.to_s
    end

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

S = MySketch.new :title => "My Sketch", :width => WIDTH, :height => HEIGHT