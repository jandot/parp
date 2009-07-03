require 'rubygems'
require 'ruby-processing'
require 'yaml'

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
