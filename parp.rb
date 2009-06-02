require 'rubygems'
require 'ruby-processing'
require 'yaml'


#FILE_CHROMOSOME_METADATA = WORKING_DIRECTORY + '/data/meta_data.tsv'
##FILE_READPAIRS = WORKING_DIRECTORY + '/data/data.tsv'
##FILE_READPAIRS = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/NCI-H2171/read_pairs.parsed'
#FILE_READPAIRS = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/COLO-829/read_pairs.parsed'
##FILE_READPAIRS = WORKING_DIRECTORY + '/data/small_dataset.tsv'
##FILE_COPY_NUMBER = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/NCI-H2171/copy_number_segmented.txt'
#FILE_COPY_NUMBER = '/Users/ja8/LocalDocuments/Projects/parp_data/data_for_Jan/COLO-829/copy_number_segmented.txt'
##FILE_SEGDUPS = WORKING_DIRECTORY + '/data/features.tsv'
#FILE_SEGDUPS = WORKING_DIRECTORY + '/data/small_features.tsv'

WIDTH = 1280
HEIGHT = 800

require File.dirname(__FILE__) + '/lib/sketch.rb'

#WORKING_DIRECTORY = '/Users/ja8/LocalDocuments/Projects/pARP'
#DATA_DIRECTORY = WORKING_DIRECTORY + '/data/development'
#FILE_CHROMOSOME_METADATA = DATA_DIRECTORY + '/meta_data.tsv'
#FILE_READPAIRS = DATA_DIRECTORY + '/read_pairs.txt'
#FILE_COPY_NUMBER = DATA_DIRECTORY + '/copy_number.txt'
#FILE_SEGDUPS = DATA_DIRECTORY + '/segdups.txt'

S = MySketch.new :title => "My Sketch", :width => WIDTH, :height => HEIGHT, :data_directory => File.dirname(__FILE__) + '/data/development'
