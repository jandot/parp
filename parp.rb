require 'rubygems'
#require '/Users/ja8/LocalDocuments/Projects/ruby-processing/lib/ruby-processing.rb'
#require 'ruby-processing'
require 'yaml'
require 'open-uri'

class MySketch < Processing::App
end
require File.dirname(__FILE__) + '/lib/sketch.rb'

CONFIG_FILE = File.dirname(__FILE__) + '/config.yml'

config = YAML::load(File.open(CONFIG_FILE))

WIDTH = config['width']
HEIGHT = config['height']
DATA_DIRECTORY = config['data_directory']

if WIDTH.nil? or HEIGHT.nil? or DATA_DIRECTORY.nil?
  STDERR.puts "[ERROR] At least width, height and data_directory have to be specified in config file"
  exit
end

S = MySketch.new :title => "My Sketch", :width => WIDTH, :height => HEIGHT, :data_directory => DATA_DIRECTORY

# Apply zooms as defined in config file
until S.initialized
  sleep 1
end

unless config['loci'].nil?
  config['loci'].each do |locus|
    center_bp = ((locus['start'] + locus['stop']).to_f/2).floor
    center_bp += S.chromosomes[locus['chromosome'].to_s].start_cumulative_bp
    length_bp = locus['stop'] - locus['start'] + 1
    length_pixel = (S.circumference.to_f/3).floor
    Slice.add(center_bp, length_bp, length_pixel)
  end
  S.buffer_images[:zoomed] = S.draw_zoomed_buffer
  S.buffer_images[:information_panel] = S.draw_information_panel
  S.redraw
end