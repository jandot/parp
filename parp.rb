require 'ruby-processing'
require 'yaml'

WORKING_DIRECTORY = '/Users/ja8/LocalDocuments/Projects/pARP'
FILE_CHROMOSOME_METADATA = WORKING_DIRECTORY + '/data/meta_data.tsv'
FILE_READPAIRS = WORKING_DIRECTORY + '/data/data.tsv'

WIDTH = 1200
HEIGHT = 600

GENOME_SIZE = 3080419000

Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }


class MySketch < Processing::App
  attr_accessor :chromosomes, :reads
  
  def setup
    load_chromosomes
    load_readpairs
  end

  def load_chromosomes
    @chromosomes = Hash.new
    File.open(FILE_CHROMOSOME_METADATA).each do |line|
      chr, len, centr_start, centr_stop = line.chomp.split("\t")
      @chromosomes[chr] = Chromosome.new(chr, len.to_i, centr_start.to_i, centr_stop.to_i)
    end
  end

  def load_readpairs
    @reads = Array.new
    File.open(FILE_READPAIRS).each do |line|
      from_chr, from_pos, to_chr, to_pos, code = line.chomp.split("\t")
      ReadPair.new(from_chr, from_pos, to_chr, to_pos, code)
    end
    @reads = @reads.sort_by{|r| r.as_string}
    STDERR.puts "Finished loading"
    Read.fetch_region('01_012300000', '01_012400000').each do |r|
      STDERR.puts r.as_string
    end
    STDERR.puts "...and there's the list"
  end

  def draw
    background 255
  end
end


S = MySketch.new :title => "My Sketch", :width => WIDTH, :height => HEIGHT
