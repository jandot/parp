require 'test/unit'
require 'rubygems'
require 'ruby-processing'

WORKING_DIRECTORY = '/Users/ja8/LocalDocuments/Projects/pARP'
FILE_CHROMOSOME_METADATA = WORKING_DIRECTORY + '/data/meta_data.tsv'

Dir[WORKING_DIRECTORY + '/models/*.rb'].each {|file| require file }

GENOME_SIZE = 3080419000

class MySketch < Processing::App
  attr_accessor :chromosomes
  def setup
    @chromosomes = Hash.new
    Chromosome.sketch = self

    File.open(FILE_CHROMOSOME_METADATA).each do |line|
      chr, len, centr_start, centr_stop = line.chomp.split("\t")
      @chromosomes[chr] = Chromosome.new(chr, len.to_i, centr_start.to_i)
    end

    no_loop
  end

  def draw
    
  end
end

S = MySketch.new

class ChromosomeBoundaries < Test::Unit::TestCase
  def test_offsets
    assert_equal(0, S.chromosomes['1'].bp_offset)
    assert_equal(247249719, S.chromosomes['2'].bp_offset)
    assert_equal(490200868, S.chromosomes['3'].bp_offset)
  end
end